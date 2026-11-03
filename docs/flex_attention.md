# Flex Attention: differences from PyTorch

`turbo.ops.flex_attention` follows the `torch.nn.attention.flex_attention` interface
(`flex_attention(query, key, value, score_mod=..., block_mask=...)`, `create_block_mask`,
`BlockMask`, `AuxRequest`), backed by Triton kernels for ROCm. This page lists where it
differs. See [examples.md](examples.md) for usage.

## Mods are Triton functions

PyTorch traces Python `score_mod` / `mask_mod` callables with `torch.compile`. Turbo
inlines them into the kernel, so they are `@triton.jit` functions:

```python
@triton.jit
def score_mod(score, b, h, q_idx, kv_idx):          # -> new score
    ...

@triton.jit
def mask_mod(b, h, q_idx, kv_idx):                   # -> bool tile, True = keep
    ...

# A mask reading a tensor: its pointer is appended to the arguments.
@triton.jit
def document_mask(b, h, q_idx, kv_idx, DOC):         # DOC: int32 [B, S] document ids
    q_doc = tl.load(DOC + b * S + q_idx, mask=q_idx < S, other=-1)
    kv_doc = tl.load(DOC + b * S + kv_idx, mask=kv_idx < S, other=-2)
    return (q_doc == kv_doc) & (q_idx >= kv_idx)

block_mask = turbo.ops.create_block_mask(document_mask, B, None, S, S, aux_tensors=[doc_ids])
```

`q_idx` / `kv_idx` are broadcastable index tiles; `b` and `h` are scalars. Consequences:

| | PyTorch | Turbo |
|---|---|---|
| Compilation | needs `torch.compile(flex_attention)`; uncompiled calls fall back to an unfused path that materializes the full score matrix | none needed: every call runs the fused kernels; Triton compiles one variant per distinct mod on first use |
| `score_mod` gradient | auto-differentiated | not traced: pass its VJP as `score_mod_bwd(dscore, score, b, h, q_idx, kv_idx)` (`identity_score_mod_bwd` for any additive mod) |
| Tensors read by `score_mod` | captured by closure | passed explicitly in `aux_tensors` (up to 4, contiguous), appended to the `score_mod` arguments; read-only in the kernel |
| Gradient of such a tensor | scattered with atomics into a buffer of its shape | opt-in: pass the tensor as `score_grad_target` with a `score_grad_hook(dscore, valid, b, h, q_idx, kv_idx, grad, *aux)`, which the dQ sweep calls once per tile to store it; no atomics, so the backward stays deterministic |
| Tensors read by `mask_mod` | captured by closure | passed to `create_block_mask(..., aux_tensors=[...])` / `create_block_mask_varlen(...)` (up to 4, contiguous), appended to the `mask_mod` arguments; the `BlockMask` carries them to the attention kernels. Read-only and not differentiable. `q_idx` / `kv_idx` run past the sequence end in each dimension's last tile, so loads indexed by them need a bounds mask |
| Parameterized mods | closures | build them from generated source so each parameter value is a distinct function (Triton keys compiled kernels on source); `sliding_window_mask` and `make_softcap_score_mod` do this |

## Block masks

| | PyTorch | Turbo |
|---|---|---|
| Building | evaluates `mask_mod` over the dense `[B, H, Q, KV]` grid (memory O(Q x KV) unless the builder is compiled) | a Triton kernel evaluates `mask_mod` per tile and stores one category per tile; the dense mask never exists |
| Reuse | each call builds a new mask; callers cache it themselves | **dense masks without aux tensors are memoized**: a repeated `create_block_mask` call with the same `mask_mod` object, `B`, `H`, lengths, block size and device returns the same `BlockMask`, together with every list it has built since (other block sizes, the backward's lists). Bounded LRU of 64 entries. A mask built with `aux_tensors` depends on their values and is rebuilt on every call |
| `BLOCK_SIZE` | any, may be non-square | square power of two >= 16 |
| Built-in masks | ordinary block masks | `causal_mask`, `sliding_window_mask(left, right)` and `noop_mask` run on the kernel's causal/window path when query and key lengths are equal: no block lists at all |
| Full vs partial blocks | `separate_full_blocks` | always separated in the forward (full tiles run with `mask_mod` compiled out); both backward passes walk one combined list |
| Block size per pass | fixed by the mask | the first call for a given mask and shape times the causal/window path and block sizes 64 / 128 separately for the forward and the backward and reuses the winners (`PRIMUS_TURBO_FLEX_ATTENTION_AUTOTUNE=0` uses static defaults) |
| `BlockMask` API | full | `kv_num_blocks`, `kv_indices`, `full_kv_num_blocks`, `full_kv_indices`, `shape`, `seq_lengths`, `BLOCK_SIZE`, `mask_mod`, `aux_tensors`, `to_dense()`, `sparsity()`, `materialize()`; no `from_kv_blocks`, slicing or `q_*` lists |

Memoization keys on the `mask_mod` object, so a mask defined anew on every call (a fresh
`@triton.jit` function each time) misses the cache; build parameterized masks once, for
example through `functools.lru_cache`.

## Packed sequences (varlen)

PyTorch has no varlen entry point; packed sequences are usually expressed as a document
mask over the concatenated batch. Turbo adds:

- `flex_attention_varlen(q, k, v, cu_seqlens_q, cu_seqlens_k, max_seqlen_q, max_seqlen_k, ...)`
  on `[total_tokens, H, D]` tensors. Sequences never attend each other; mods see
  sequence-local `q_idx` / `kv_idx` and the sequence index as `b`.
- `create_block_mask_varlen(mask_mod, cu_seqlens_q, cu_seqlens_k, max_seqlen_q, max_seqlen_k)`.
  A built-in mask takes the causal/window path when queries and keys share one
  `cu_seqlens` tensor. Custom masks are rebuilt per call (the lists depend on the
  `cu_seqlens` values, so they are not memoized), and the build reads nothing back from
  the device -- index tensors span the full block grid -- so a per-batch rebuild does not
  stall the host.
- `flex_attention_varlen_rel_bias(q, k, v, rel_logits, cu_seqlens, max_seqlen, ...)`:
  causal attention with a relative-position bias table `rel_logits[t, h, q - kv]`
  (Inkling), with gradients for q, k, v and `rel_logits`.

## FlyDSL backend

`kernel_options={"BACKEND": "FLYDSL"}` runs the call on FlyDSL kernels
(`primus_turbo.flydsl.flex_attention`, structured after flash-attention's FA4
`flash_attn/cute`), in place of Triton. `"AUTO"` picks FlyDSL when the call is supported
and Triton otherwise; `PRIMUS_TURBO_FLEX_ATTENTION_BACKEND` sets the default (`TRITON`).
PyTorch's own `kernel_options["BACKEND"]` selects among its backends the same way.

Mods are **dual**: the API still takes the `@triton.jit` function, and the FlyDSL
backend runs its registered twin, a plain Python function over `flydsl.expr` values
with FA4's signatures (one element at a time; branch with `.select`, not `if`):

```python
import flydsl.expr as fx

@triton.jit
def document_mask(b, h, q_idx, kv_idx, DOC):
    ...

def document_mask_flydsl(b, h, q_idx, kv_idx, seqlen_info, aux_tensors):
    docs = fx.slice(aux_tensors[0], (b, None))    # aux tensors keep their shapes
    return (fx.Int32(docs[q_idx]) == fx.Int32(docs[kv_idx])) & (kv_idx <= q_idx)

turbo.ops.dual_mod(document_mask, document_mask_flydsl)
```

`score_mod(score, b, h, q_idx, kv_idx, seqlen_info, aux_tensors)` and
`score_mod_bwd(dscore, score, b, h, q_idx, kv_idx, seqlen_info, aux_tensors)` work the
same way. Indices past a sequence's end are clamped to its last position before a
FlyDSL mod is called, so aux reads stay in bounds without a mask. The built-in masks,
`identity_score_mod_bwd` and `make_softcap_score_mod` have twins already.

| | Triton backend | FlyDSL backend |
|---|---|---|
| Masks | causal/window path or block lists, block size tuned per pass | causal/window path, or the block lists at block size 128 (full blocks skip `mask_mod` in both passes); varlen custom masks run elementwise over every block |
| Backward | dQ sweep plus dK/dV sweep | separate dQ and dK/dV kernels, deterministic, no atomics |
| `score_grad_hook` | supported | not supported (use Triton for trainable aux tensors, e.g. `flex_attention_varlen_rel_bias`) |
| Aux tensors | 4 for `score_mod` and 4 for `mask_mod` | 4 in total |
| `num_splits` | causal/window or no mask | the same |

The FlyDSL kernels themselves cover more than this interface exposes: paged KV,
`seqused_q` / `seqused_k`, learnable sinks, and fp8 forward (FNUZ on gfx942, OCP on
gfx950), with FA4's arguments (`FlashAttentionForward`, `FlashAttentionBackward`,
`flash_attn_combine`).

## Other differences

- `return_aux=AuxRequest(lse=True)` is supported; `max_scores` is not.
- `kernel_options` accepts `num_splits` (split the KV loop for short-query /
  long-context shapes; dense inputs with a causal/window or no mask) and `BACKEND`.
- fp16 / bf16 inputs only.
- The backward is deterministic: every dQ / dK / dV tile, and the `score_grad_hook`
  output, is written by a single program.

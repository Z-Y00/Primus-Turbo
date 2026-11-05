	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	kernel_0
	.p2align	8
	.type	kernel_0,@function
kernel_0:
	s_load_dwordx4 s[80:83], s[0:1], 0x390
	s_lshl_b32 s2, s2, 7
	s_waitcnt lgkmcnt(0)
	s_cmp_ge_i32 s2, s81
	s_cbranch_scc1 .LBB0_12
	s_ashr_i32 s5, s3, 31
	s_lshr_b32 s5, s5, 29
	s_add_i32 s5, s3, s5
	s_ashr_i32 s15, s5, 3
	s_and_b32 s5, s5, -8
	s_cmp_lg_u32 s3, s5
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s3, 0
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[6:7], s[10:11], s[6:7]
	s_subb_u32 s15, s15, 0
	s_abs_i32 s5, s80
	v_cvt_f32_u32_e32 v2, s5
	s_sub_i32 s17, 0, s5
	s_load_dwordx8 s[72:79], s[0:1], 0x48
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s12, s[0:1], 0x18
	s_load_dword s13, s[0:1], 0x20
	s_load_dword s14, s[0:1], 0x28
	s_load_dwordx2 s[84:85], s[0:1], 0x30
	s_abs_i32 s7, s4
	v_rcp_f32_e32 v2, v2
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[88:89], s[78:79]
	s_xor_b32 s6, s80, s4
	s_and_b32 s85, s85, 0xffff
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	s_and_b32 s89, s89, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_ashr_i32 s16, s6, 31
	v_readfirstlane_b32 s18, v2
	s_mul_i32 s17, s17, s18
	s_mul_hi_u32 s17, s18, s17
	s_add_i32 s18, s18, s17
	s_mul_hi_u32 s17, s7, s18
	s_mul_i32 s18, s17, s5
	s_sub_i32 s7, s7, s18
	s_add_i32 s18, s17, 1
	s_sub_i32 s19, s7, s5
	s_cmp_ge_u32 s7, s5
	s_cselect_b32 s17, s18, s17
	s_cselect_b32 s7, s19, s7
	s_add_i32 s18, s17, 1
	s_cmp_ge_u32 s7, s5
	s_cselect_b32 s5, s18, s17
	s_xor_b32 s17, s5, s16
	s_sub_i32 s5, s17, s16
	s_mul_i32 s5, s5, s80
	s_cmp_lg_u32 s4, s5
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[4:5], s[6:7], s[4:5]
	s_subb_u32 s33, s17, s16
	s_add_i32 s6, s82, 63
	s_ashr_i32 s4, s6, 31
	s_lshr_b32 s4, s4, 26
	s_add_i32 s4, s6, s4
	s_ashr_i32 s16, s4, 6
	s_andn2_b32 s4, s4, 63
	s_cmp_lg_u32 s6, s4
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[4:5], s[6:7], s[4:5]
	s_subb_u32 s20, s16, 0
	s_add_i32 s4, s2, 0x80
	s_min_i32 s4, s4, s81
	s_sub_i32 s27, s82, s81
	s_add_i32 s4, s27, s4
	s_max_i32 s4, s4, 0
	s_add_i32 s6, s4, 63
	s_ashr_i32 s4, s6, 31
	s_lshr_b32 s4, s4, 26
	s_add_i32 s4, s6, s4
	s_ashr_i32 s16, s4, 6
	s_andn2_b32 s4, s4, 63
	s_cmp_lg_u32 s6, s4
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	v_lshrrev_b32_e32 v4, 1, v0
	v_and_b32_e32 v3, 31, v0
	s_and_b64 s[4:5], s[6:7], s[4:5]
	v_and_b32_e32 v2, 0x60, v4
	s_subb_u32 s22, s16, 0
	v_or3_b32 v115, s2, v2, v3
	s_add_i32 s4, s81, -1
	v_min_i32_e32 v98, s4, v115
	s_mul_i32 s4, s12, s33
	s_mul_i32 s14, s14, s3
	v_bfe_u32 v1, v0, 5, 1
	v_mul_lo_u32 v2, s13, v98
	s_add_i32 s4, s4, s14
	s_mov_b32 s87, 0x27000
	s_mov_b32 s86, -1
	v_add_u32_e32 v2, s4, v2
	v_lshlrev_b32_e32 v5, 4, v1
	s_mov_b32 s10, s86
	s_mov_b32 s11, s87
	v_lshl_add_u32 v5, v2, 1, v5
	v_lshlrev_b32_e32 v113, 3, v1
	v_add_lshl_u32 v2, v2, v113, 1
	buffer_load_dwordx4 v[170:173], v5, s[8:11], 0 offen
	buffer_load_dwordx4 v[174:177], v2, s[8:11], 0 offen offset:32
	buffer_load_dwordx4 v[178:181], v2, s[8:11], 0 offen offset:64
	buffer_load_dwordx4 v[182:185], v2, s[8:11], 0 offen offset:96
	buffer_load_dwordx4 v[186:189], v2, s[8:11], 0 offen offset:128
	buffer_load_dwordx4 v[190:193], v2, s[8:11], 0 offen offset:160
	buffer_load_dwordx4 v[194:197], v2, s[8:11], 0 offen offset:192
	buffer_load_dwordx4 v[198:201], v2, s[8:11], 0 offen offset:224
	s_ashr_i32 s5, s82, 31
	s_lshr_b32 s5, s5, 26
	s_add_i32 s5, s82, s5
	s_min_i32 s24, s20, s22
	s_ashr_i32 s36, s5, 6
	s_andn2_b32 s5, s5, 63
	s_cmp_lg_u32 s82, s5
	s_cselect_b64 s[8:9], -1, 0
	s_cmp_lt_i32 s82, 0
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[28:29], s[10:11], s[8:9]
	s_subb_u32 s5, s36, 0
	s_add_i32 s2, s27, s2
	s_add_i32 s2, s2, 1
	s_max_i32 s2, s2, 0
	s_load_dwordx4 s[92:95], s[0:1], 0x78
	s_load_dwordx2 s[6:7], s[0:1], 0x88
	s_lshr_b32 s26, s2, 6
	v_mov_b32_e32 v5, s26
	v_mov_b32_e32 v6, s24
	v_min3_i32 v5, s5, v5, v6
	s_min_i32 s30, s24, 0
	v_readfirstlane_b32 s2, v5
	s_max_i32 s78, s2, s30
	v_cmp_gt_i32_e32 vcc, 1, v5
	s_movk_i32 s4, 0x60
	v_mov_b32_e32 v2, 0
	s_ashr_i32 s79, s78, 31
	s_and_b64 vcc, exec, vcc
	v_lshrrev_b32_e32 v119, 4, v0
	s_mul_i32 s39, s72, s33
	s_mul_i32 s40, s76, s15
	v_and_b32_e32 v99, 15, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s37, s92, s33
	s_mul_i32 s38, s6, s15
	v_and_b32_e32 v106, 64, v4
	v_and_b32_e32 v107, 64, v0
	v_lshlrev_b32_e32 v104, 7, v3
	v_lshlrev_b32_e32 v105, 3, v0
	v_lshlrev_b32_e32 v111, 1, v3
	v_lshlrev_b32_e32 v116, 11, v1
	s_cbranch_vccnz .LBB0_4
	v_and_b32_e32 v3, 0xf0, v0
	v_bitop3_b32 v4, v119, v99, 7 bitop3:0x6c
	v_or_b32_e32 v5, v4, v3
	v_lshlrev_b32_e32 v109, 4, v5
	s_movk_i32 s2, 0x1f0
	v_mov_b32_e32 v5, 0x100
	v_bitop3_b32 v5, v0, s2, v5 bitop3:0xc8
	v_or_b32_e32 v6, v4, v5
	v_lshlrev_b32_e32 v110, 4, v6
	s_movk_i32 s2, 0x2f0
	v_mov_b32_e32 v6, 0x200
	v_bitop3_b32 v6, v0, s2, v6 bitop3:0xc8
	v_or_b32_e32 v7, v4, v6
	v_lshlrev_b32_e32 v112, 4, v7
	s_movk_i32 s2, 0x3f0
	v_mov_b32_e32 v7, 0x300
	v_bitop3_b32 v7, v0, s2, v7 bitop3:0xc8
	v_or_b32_e32 v4, v4, v7
	v_lshlrev_b32_e32 v114, 4, v4
	v_sub_u32_e32 v4, v107, v106
	v_add_u32_e32 v3, v4, v3
	v_or_b32_e32 v3, v3, v99
	v_lshlrev_b32_e32 v117, 4, v3
	v_add_u32_e32 v3, v4, v5
	v_or_b32_e32 v3, v3, v99
	v_lshlrev_b32_e32 v120, 4, v3
	v_add_u32_e32 v3, v4, v6
	v_or_b32_e32 v3, v3, v99
	v_lshlrev_b32_e32 v121, 4, v3
	v_add_u32_e32 v3, v4, v7
	v_or_b32_e32 v3, v3, v99
	v_and_b32_e32 v4, 56, v105
	v_lshlrev_b32_e32 v123, 4, v3
	v_or_b32_e32 v3, v113, v104
	v_bitop3_b32 v5, v113, v4, v104 bitop3:0x36
	v_lshlrev_b32_e32 v124, 1, v5
	v_bitop3_b32 v5, v3, v4, 16 bitop3:0x36
	v_lshlrev_b32_e32 v125, 1, v5
	v_bitop3_b32 v5, v3, v4, 32 bitop3:0x36
	v_lshlrev_b32_e32 v126, 1, v5
	v_bitop3_b32 v5, v3, v4, 48 bitop3:0x36
	v_lshlrev_b32_e32 v127, 1, v5
	v_bitop3_b32 v5, v3, v4, 64 bitop3:0x36
	s_movk_i32 s2, 0x50
	v_lshlrev_b32_e32 v128, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	v_lshlrev_b32_e32 v129, 1, v5
	v_bitop3_b32 v5, v3, v4, s4 bitop3:0x36
	s_movk_i32 s2, 0x70
	v_lshlrev_b32_e32 v130, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	s_movk_i32 s2, 0x1010
	v_lshlrev_b32_e32 v131, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	s_movk_i32 s2, 0x1020
	v_lshlrev_b32_e32 v132, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	s_movk_i32 s2, 0x1030
	v_lshlrev_b32_e32 v133, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	s_movk_i32 s2, 0x1040
	v_lshlrev_b32_e32 v134, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	s_movk_i32 s2, 0x1050
	v_lshlrev_b32_e32 v135, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	s_movk_i32 s2, 0x1060
	v_lshlrev_b32_e32 v136, 1, v5
	v_bitop3_b32 v5, v3, v4, s2 bitop3:0x36
	s_movk_i32 s2, 0x1070
	s_ashr_i32 s21, s20, 31
	v_lshlrev_b32_e32 v137, 1, v5
	v_bitop3_b32 v3, v3, v4, s2 bitop3:0x36
	s_ashr_i32 s23, s22, 31
	v_mov_b64_e32 v[4:5], s[20:21]
	s_ashr_i32 s31, s30, 31
	s_add_i32 s25, s82, -1
	s_add_u32 s41, s39, s40
	s_add_u32 s42, s37, s38
	v_cmp_lt_i64_e32 vcc, s[22:23], v[4:5]
	s_movk_i32 s2, 0x4000
	s_and_b64 s[4:5], vcc, exec
	v_or3_b32 v139, v111, v116, s2
	s_cselect_b32 s2, s23, s21
	s_cselect_b32 s4, s22, s20
	s_and_b32 s2, s4, s2
	v_lshl_or_b32 v140, s2, 6, v119
	v_lshlrev_b32_e32 v108, 3, v99
	v_lshlrev_b32_e32 v138, 1, v3
	s_mov_b32 s34, s83
	s_mov_b32 s35, s83
	v_or_b32_e32 v141, 48, v140
	v_or_b32_e32 v142, 32, v140
	v_or_b32_e32 v143, 16, v140
	v_mov_b32_e32 v122, 0
	v_mov_b32_e32 v102, 0xf149f2ca
	s_mov_b32 s2, 0x3fb8aa3b
	s_mov_b32 s21, 0xc2fc0000
	v_mov_b32_e32 v144, 0x42800000
	v_not_b32_e32 v145, 63
	s_mov_b32 s23, 0x5040100
	v_mov_b64_e32 v[100:101], s[78:79]
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v9, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v16, v2
	v_mov_b32_e32 v17, v2
	v_mov_b32_e32 v50, v2
	v_mov_b32_e32 v51, v2
	v_mov_b32_e32 v52, v2
	v_mov_b32_e32 v53, v2
	v_mov_b32_e32 v54, v2
	v_mov_b32_e32 v55, v2
	v_mov_b32_e32 v56, v2
	v_mov_b32_e32 v57, v2
	v_mov_b32_e32 v58, v2
	v_mov_b32_e32 v59, v2
	v_mov_b32_e32 v60, v2
	v_mov_b32_e32 v61, v2
	v_mov_b32_e32 v62, v2
	v_mov_b32_e32 v63, v2
	v_mov_b32_e32 v64, v2
	v_mov_b32_e32 v65, v2
	v_mov_b32_e32 v34, v2
	v_mov_b32_e32 v35, v2
	v_mov_b32_e32 v36, v2
	v_mov_b32_e32 v37, v2
	v_mov_b32_e32 v38, v2
	v_mov_b32_e32 v39, v2
	v_mov_b32_e32 v40, v2
	v_mov_b32_e32 v41, v2
	v_mov_b32_e32 v42, v2
	v_mov_b32_e32 v43, v2
	v_mov_b32_e32 v44, v2
	v_mov_b32_e32 v45, v2
	v_mov_b32_e32 v46, v2
	v_mov_b32_e32 v47, v2
	v_mov_b32_e32 v48, v2
	v_mov_b32_e32 v49, v2
	v_mov_b32_e32 v18, v2
	v_mov_b32_e32 v19, v2
	v_mov_b32_e32 v20, v2
	v_mov_b32_e32 v21, v2
	v_mov_b32_e32 v22, v2
	v_mov_b32_e32 v23, v2
	v_mov_b32_e32 v24, v2
	v_mov_b32_e32 v25, v2
	v_mov_b32_e32 v26, v2
	v_mov_b32_e32 v27, v2
	v_mov_b32_e32 v28, v2
	v_mov_b32_e32 v29, v2
	v_mov_b32_e32 v30, v2
	v_mov_b32_e32 v31, v2
	v_mov_b32_e32 v32, v2
	v_mov_b32_e32 v33, v2
.LBB0_3:
	v_min_i32_e32 v66, s25, v140
	v_min_i32_e32 v67, s25, v143
	v_min_i32_e32 v68, s25, v142
	v_min_i32_e32 v69, s25, v141
	v_mul_lo_u32 v70, s74, v66
	v_mul_lo_u32 v71, s74, v67
	v_mul_lo_u32 v72, s74, v68
	v_mul_lo_u32 v73, s74, v69
	v_mul_lo_u32 v66, s94, v66
	v_mul_lo_u32 v67, s94, v67
	v_mul_lo_u32 v68, s94, v68
	v_mul_lo_u32 v69, s94, v69
	v_add_u32_e32 v70, s41, v70
	v_add_u32_e32 v71, s41, v71
	v_add_u32_e32 v72, s41, v72
	v_add_u32_e32 v73, s41, v73
	v_add_u32_e32 v66, s42, v66
	v_add_u32_e32 v67, s42, v67
	v_add_u32_e32 v68, s42, v68
	v_add_u32_e32 v69, s42, v69
	v_add_lshl_u32 v70, v108, v70, 1
	v_add_lshl_u32 v71, v108, v71, 1
	v_add_lshl_u32 v72, v108, v72, 1
	v_add_lshl_u32 v73, v108, v73, 1
	v_add_lshl_u32 v66, v108, v66, 1
	v_add_lshl_u32 v67, v108, v67, 1
	v_add_lshl_u32 v68, v108, v68, 1
	v_add_lshl_u32 v69, v108, v69, 1
	s_barrier
	s_mov_b32 s90, s86
	s_mov_b32 s91, s87
	buffer_load_dwordx4 v[74:77], v70, s[84:87], 0 offen
	buffer_load_dwordx4 v[78:81], v71, s[84:87], 0 offen
	buffer_load_dwordx4 v[82:85], v72, s[84:87], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[70:73], v73, s[84:87], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[86:89], v66, s[88:91], 0 offen
	buffer_load_dwordx4 v[90:93], v67, s[88:91], 0 offen
	buffer_load_dwordx4 v[94:97], v68, s[88:91], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[66:69], v69, s[88:91], 0 offen
	s_add_u32 s30, s30, 1
	s_addc_u32 s31, s31, 0
	v_add_u32_e32 v141, 64, v141
	v_add_u32_e32 v142, 64, v142
	v_add_u32_e32 v143, 64, v143
	v_add_u32_e32 v140, 64, v140
	s_waitcnt vmcnt(7)
	ds_write_b128 v109, v[74:77]
	s_waitcnt vmcnt(6)
	ds_write_b128 v110, v[78:81]
	s_waitcnt vmcnt(5)
	ds_write_b128 v112, v[82:85]
	s_waitcnt vmcnt(4)
	ds_write_b128 v114, v[70:73]
	s_waitcnt vmcnt(3)
	ds_write_b128 v117, v[86:89] offset:16384
	s_waitcnt vmcnt(2)
	ds_write_b128 v120, v[90:93] offset:16384
	s_waitcnt vmcnt(1)
	ds_write_b128 v121, v[94:97] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v123, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[82:85], v124
	ds_read_b128 v[146:149], v124 offset:8192
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[170:173], 0
	ds_read_u16 v162, v139 offset:1344
	ds_read_u16 v163, v139 offset:512
	ds_read_u16 v164, v139 offset:768
	ds_read_u16 v165, v139 offset:576
	ds_read_u16 v166, v139 offset:832
	ds_read_u16 v167, v139 offset:640
	ds_read_u16 v168, v139 offset:896
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[170:173], 0
	ds_read_b128 v[146:149], v125
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[174:177], v[66:81]
	ds_read_b128 v[146:149], v132
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[174:177], v[82:97]
	ds_read_b128 v[146:149], v126
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[178:181], v[66:81]
	ds_read_b128 v[146:149], v133
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[178:181], v[82:97]
	ds_read_b128 v[146:149], v127
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[182:185], v[66:81]
	ds_read_b128 v[146:149], v134
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[182:185], v[82:97]
	ds_read_b128 v[146:149], v128
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[186:189], v[66:81]
	ds_read_b128 v[146:149], v135
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[186:189], v[82:97]
	ds_read_b128 v[146:149], v129
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[190:193], v[66:81]
	ds_read_b128 v[146:149], v136
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[190:193], v[82:97]
	ds_read_b128 v[146:149], v130
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[194:197], v[66:81]
	ds_read_b128 v[146:149], v137
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[146:149], v[194:197], v[82:97]
	ds_read_b128 v[146:149], v131
	ds_read_b128 v[150:153], v138
	ds_read_u16 v103, v139
	ds_read_u16 v118, v139 offset:1024
	ds_read_u16 v160, v139 offset:1280
	ds_read_u16 v161, v139 offset:1088
	s_waitcnt lgkmcnt(5)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[146:149], v[198:201], v[66:81]
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[150:153], v[198:201], v[82:97]
	s_nop 9
	v_mul_f32_e64 v78, s34, v78
	v_mul_f32_e64 v79, s35, v79
	v_mul_f32_e64 v152, s34, v66
	v_mul_f32_e64 v153, s35, v67
	v_mul_f32_e64 v156, s34, v70
	v_mul_f32_e64 v157, s35, v71
	v_pk_mul_f32 v[80:81], s[34:35], v[80:81]
	v_pk_mul_f32 v[154:155], s[34:35], v[68:69]
	v_pk_mul_f32 v[150:151], s[34:35], v[76:77]
	v_pk_mul_f32 v[158:159], s[34:35], v[72:73]
	v_pk_mul_f32 v[86:87], s[34:35], v[86:87]
	v_pk_mul_f32 v[88:89], s[34:35], v[88:89]
	v_pk_mul_f32 v[70:71], v[86:87], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[86:87], v[78:79], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[78:79], v[152:153], s[2:3] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(1)
	v_perm_b32 v76, v160, v118, s23
	v_cmp_gt_f32_e32 vcc, v78, v79
	v_pk_mul_f32 v[72:73], v[88:89], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[88:89], v[80:81], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[80:81], v[154:155], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v118, v79, v78, vcc
	v_cmp_gt_f32_e32 vcc, v118, v80
	v_mul_f32_e32 v96, s83, v96
	v_mul_f32_e32 v97, s83, v97
	v_cndmask_b32_e32 v118, v80, v118, vcc
	v_pk_mul_f32 v[90:91], s[34:35], v[90:91]
	v_cmp_gt_f32_e32 vcc, v118, v81
	v_pk_mul_f32 v[148:149], s[34:35], v[74:75]
	ds_read_u16 v66, v139 offset:256
	ds_read_u16 v169, v139 offset:64
	ds_read_u16 v202, v139 offset:320
	ds_read_u16 v203, v139 offset:128
	ds_read_u16 v204, v139 offset:384
	ds_read_u16 v67, v139 offset:1536
	ds_read_u16 v68, v139 offset:1792
	ds_read_u16 v205, v139 offset:448
	ds_read_u16 v206, v139 offset:192
	ds_read_u16 v207, v139 offset:1600
	ds_read_u16 v208, v139 offset:1856
	s_waitcnt lgkmcnt(10)
	v_perm_b32 v74, v66, v103, s23
	v_mul_f32_e32 v209, 0x3fb8aa3b, v96
	v_mul_f32_e32 v103, 0x3fb8aa3b, v97
	v_pk_mul_f32 v[96:97], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[90:91], v[156:157], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v118, v81, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v90
	v_pk_mul_f32 v[92:93], s[34:35], v[92:93]
	v_pk_mul_f32 v[146:147], s[34:35], v[94:95]
	v_cndmask_b32_e32 v118, v90, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v91
	v_pk_mul_f32 v[94:95], v[92:93], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[92:93], v[146:147], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[146:147], v[158:159], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v118, v91, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v146
	v_pk_mul_f32 v[82:83], s[34:35], v[82:83]
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v77, v68, v67, s23
	v_cndmask_b32_e32 v118, v146, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v147
	v_pk_mul_f32 v[66:67], v[82:83], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[82:83], v[148:149], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v118, v147, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v82
	v_pk_mul_f32 v[84:85], s[34:35], v[84:85]
	v_perm_b32 v75, v164, v163, s23
	v_cndmask_b32_e32 v118, v82, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v83
	v_pk_mul_f32 v[68:69], v[84:85], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[84:85], v[150:151], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v118, v83, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v84
	ds_read_u16 v156, v139 offset:1984
	ds_read_u16 v157, v139 offset:1728
	v_cndmask_b32_e32 v118, v84, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v85
	ds_read_u16 v158, v139 offset:960
	ds_read_u16 v159, v139 offset:704
	v_cndmask_b32_e32 v118, v85, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v86
	s_nop 1
	v_cndmask_b32_e32 v118, v86, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v87
	s_nop 1
	v_cndmask_b32_e32 v118, v87, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v88
	s_nop 1
	v_cndmask_b32_e32 v118, v88, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v89
	s_nop 1
	v_cndmask_b32_e32 v118, v89, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v66
	s_nop 1
	v_cndmask_b32_e32 v118, v66, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v67
	s_nop 1
	v_cndmask_b32_e32 v118, v67, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v68
	s_nop 1
	v_cndmask_b32_e32 v118, v68, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v69
	s_nop 1
	v_cndmask_b32_e32 v118, v69, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v70
	s_nop 1
	v_cndmask_b32_e32 v118, v70, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v71
	s_nop 1
	v_cndmask_b32_e32 v118, v71, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v72
	s_nop 1
	v_cndmask_b32_e32 v118, v72, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v73
	s_nop 1
	v_cndmask_b32_e32 v118, v73, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v96
	s_nop 1
	v_cndmask_b32_e32 v118, v96, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v97
	s_nop 1
	v_cndmask_b32_e32 v118, v97, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v94
	s_nop 1
	v_cndmask_b32_e32 v118, v94, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v95
	s_nop 1
	v_cndmask_b32_e32 v118, v95, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v92
	s_nop 1
	v_cndmask_b32_e32 v118, v92, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v93
	s_nop 1
	v_cndmask_b32_e32 v118, v93, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v209
	s_nop 1
	v_cndmask_b32_e32 v118, v209, v118, vcc
	v_cmp_gt_f32_e32 vcc, v118, v103
	s_nop 1
	v_cndmask_b32_e32 v118, v103, v118, vcc
	v_mov_b32_e32 v148, v118
	v_mov_b32_e32 v149, v118
	s_nop 1
	v_permlane32_swap_b32_e32 v148, v149
	v_cmp_eq_u32_e32 vcc, v148, v118
	s_nop 1
	v_cndmask_b32_e32 v148, v148, v149, vcc
	v_cmp_gt_f32_e32 vcc, v118, v148
	s_nop 1
	v_cndmask_b32_e32 v118, v148, v118, vcc
	v_cmp_gt_f32_e32 vcc, v102, v118
	s_nop 1
	v_cndmask_b32_e32 v118, v118, v102, vcc
	v_pk_add_f32 v[78:79], v[78:79], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[148:149], v[90:91], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cmp_gt_f32_e32 vcc, s21, v79
	v_pk_add_f32 v[90:91], v[102:103], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[80:81], v[80:81], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e32 v102, 0, v144, vcc
	v_add_f32_e32 v79, v79, v102
	v_pk_add_f32 v[146:147], v[146:147], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cmp_gt_f32_e64 s[4:5], s21, v78
	v_cmp_gt_f32_e64 s[6:7], s21, v81
	v_cmp_gt_f32_e64 s[8:9], s21, v80
	v_exp_f32_e32 v79, v79
	v_cmp_gt_f32_e64 s[10:11], s21, v149
	v_cmp_gt_f32_e64 s[12:13], s21, v148
	v_cmp_gt_f32_e64 s[14:15], s21, v147
	v_cmp_gt_f32_e64 s[16:17], s21, v146
	v_cmp_gt_f32_e64 s[18:19], s21, v90
	v_cndmask_b32_e64 v103, 0, v144, s[4:5]
	v_cndmask_b32_e64 v150, 0, v144, s[6:7]
	v_cndmask_b32_e64 v151, 0, v144, s[8:9]
	v_cndmask_b32_e64 v152, 0, v144, s[10:11]
	v_cndmask_b32_e64 v153, 0, v144, s[12:13]
	v_add_f32_e32 v78, v78, v103
	v_cndmask_b32_e64 v102, 0, v144, s[14:15]
	v_cndmask_b32_e64 v103, 0, v144, s[16:17]
	v_add_f32_e32 v81, v81, v150
	v_add_f32_e32 v80, v80, v151
	v_cndmask_b32_e64 v150, 0, v144, s[18:19]
	v_cndmask_b32_e32 v151, 0, v145, vcc
	v_add_f32_e32 v149, v149, v152
	v_add_f32_e32 v148, v148, v153
	v_add_f32_e32 v102, v147, v102
	v_add_f32_e32 v147, v146, v103
	v_exp_f32_e32 v78, v78
	v_exp_f32_e32 v81, v81
	v_exp_f32_e32 v80, v80
	v_add_f32_e32 v90, v90, v150
	v_ldexp_f32 v210, v79, v151
	v_exp_f32_e32 v149, v149
	v_exp_f32_e32 v150, v148
	v_exp_f32_e32 v102, v102
	v_exp_f32_e32 v151, v147
	v_exp_f32_e32 v90, v90
	v_cndmask_b32_e64 v152, 0, v145, s[4:5]
	v_cndmask_b32_e64 v153, 0, v145, s[6:7]
	v_cndmask_b32_e64 v146, 0, v145, s[8:9]
	v_cndmask_b32_e64 v154, 0, v145, s[10:11]
	v_cndmask_b32_e64 v79, 0, v145, s[12:13]
	v_ldexp_f32 v211, v78, v152
	v_cndmask_b32_e64 v78, 0, v145, s[14:15]
	v_ldexp_f32 v103, v81, v153
	v_cndmask_b32_e64 v81, 0, v145, s[16:17]
	v_ldexp_f32 v146, v80, v146
	v_cndmask_b32_e64 v80, 0, v145, s[18:19]
	v_ldexp_f32 v148, v149, v154
	v_ldexp_f32 v150, v150, v79
	v_ldexp_f32 v147, v102, v78
	v_ldexp_f32 v149, v151, v81
	v_ldexp_f32 v90, v90, v80
	v_pk_mul_f32 v[16:17], v[16:17], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[90:91] op_sel_hi:[1,0]
	v_cvt_pk_bf16_f32 v81, v149, v147
	v_cvt_pk_bf16_f32 v80, v150, v148
	v_cvt_pk_bf16_f32 v79, v146, v103
	v_cvt_pk_bf16_f32 v78, v211, v210
	ds_read_u16 v102, v139 offset:1152
	ds_read_u16 v151, v139 offset:1408
	v_mfma_f32_32x32x16_bf16 v[2:17], v[74:77], v[78:81], v[2:17]
	s_waitcnt lgkmcnt(6)
	v_perm_b32 v77, v208, v207, s23
	v_perm_b32 v76, v162, v161, s23
	v_perm_b32 v75, v166, v165, s23
	ds_read_u16 v154, v139 offset:1664
	ds_read_u16 v155, v139 offset:1920
	v_perm_b32 v74, v202, v169, s23
	v_pk_mul_f32 v[64:65], v[64:65], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[62:63], v[62:63], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[60:61], v[60:61], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[58:59], v[58:59], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[56:57], v[56:57], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[54:55], v[54:55], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[52:53], v[52:53], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[50:51], v[50:51], v[90:91] op_sel_hi:[1,0]
	ds_read_u16 v152, v139 offset:1472
	ds_read_u16 v153, v139 offset:1216
	v_mfma_f32_32x32x16_bf16 v[50:65], v[74:77], v[78:81], v[50:65]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v77, v155, v154, s23
	v_perm_b32 v76, v151, v102, s23
	v_perm_b32 v75, v168, v167, s23
	v_perm_b32 v74, v204, v203, s23
	v_pk_mul_f32 v[48:49], v[48:49], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[46:47], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[42:43], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[40:41], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[38:39], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[36:37], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[90:91] op_sel_hi:[1,0]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[74:77], v[78:81], v[34:49]
	v_perm_b32 v77, v156, v157, s23
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v76, v152, v153, s23
	v_perm_b32 v75, v158, v159, s23
	v_perm_b32 v74, v205, v206, s23
	v_pk_mul_f32 v[28:29], v[28:29], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[90:91] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[90:91] op_sel_hi:[1,0]
	ds_read_u16 v102, v139 offset:4096
	ds_read_u16 v151, v139 offset:4608
	v_mfma_f32_32x32x16_bf16 v[18:33], v[74:77], v[78:81], v[18:33]
	v_add_f32_e64 v78, v82, -v118
	v_add_f32_e64 v79, v83, -v118
	v_add_f32_e64 v80, v84, -v118
	v_add_f32_e64 v81, v85, -v118
	ds_read_u16 v154, v139 offset:4864
	ds_read_u16 v155, v139 offset:5120
	ds_read_u16 v160, v139 offset:5376
	ds_read_u16 v161, v139 offset:5632
	ds_read_u16 v162, v139 offset:5888
	ds_read_u16 v163, v139 offset:4352
	v_pk_add_f32 v[82:83], v[86:87], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[84:85], v[88:89], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cmp_gt_f32_e32 vcc, s21, v79
	v_cmp_gt_f32_e64 s[4:5], s21, v78
	v_cmp_gt_f32_e64 s[6:7], s21, v81
	v_cmp_gt_f32_e64 s[8:9], s21, v80
	v_cmp_gt_f32_e64 s[10:11], s21, v83
	v_cmp_gt_f32_e64 s[12:13], s21, v82
	v_cmp_gt_f32_e64 s[14:15], s21, v85
	v_cmp_gt_f32_e64 s[16:17], s21, v84
	v_cndmask_b32_e32 v86, 0, v144, vcc
	v_cndmask_b32_e64 v87, 0, v144, s[4:5]
	v_cndmask_b32_e64 v88, 0, v144, s[6:7]
	v_cndmask_b32_e64 v89, 0, v144, s[8:9]
	v_add_f32_e32 v79, v79, v86
	v_add_f32_e32 v78, v78, v87
	v_cndmask_b32_e64 v86, 0, v144, s[10:11]
	v_cndmask_b32_e64 v87, 0, v144, s[12:13]
	v_add_f32_e32 v81, v81, v88
	v_add_f32_e32 v80, v80, v89
	v_cndmask_b32_e64 v88, 0, v144, s[14:15]
	v_cndmask_b32_e64 v89, 0, v144, s[16:17]
	v_add_f32_e32 v83, v83, v86
	v_add_f32_e32 v82, v82, v87
	v_add_f32_e32 v85, v85, v88
	v_add_f32_e32 v84, v84, v89
	v_exp_f32_e32 v79, v79
	v_exp_f32_e32 v78, v78
	v_exp_f32_e32 v81, v81
	v_exp_f32_e32 v80, v80
	v_exp_f32_e32 v83, v83
	v_exp_f32_e32 v82, v82
	v_exp_f32_e32 v85, v85
	v_exp_f32_e32 v84, v84
	ds_read_u16 v164, v139 offset:4160
	ds_read_u16 v165, v139 offset:4672
	ds_read_u16 v159, v139 offset:4928
	ds_read_u16 v166, v139 offset:5184
	ds_read_u16 v167, v139 offset:5440
	ds_read_u16 v168, v139 offset:4416
	s_waitcnt lgkmcnt(7)
	v_perm_b32 v77, v162, v161, s23
	v_perm_b32 v76, v160, v155, s23
	ds_read_u16 v160, v139 offset:5696
	ds_read_u16 v161, v139 offset:5952
	v_perm_b32 v75, v154, v151, s23
	s_waitcnt lgkmcnt(8)
	v_perm_b32 v74, v163, v102, s23
	v_cndmask_b32_e32 v86, 0, v145, vcc
	v_cndmask_b32_e64 v87, 0, v145, s[4:5]
	v_cndmask_b32_e64 v88, 0, v145, s[6:7]
	v_cndmask_b32_e64 v89, 0, v145, s[8:9]
	v_ldexp_f32 v151, v79, v86
	v_cndmask_b32_e64 v79, 0, v145, s[10:11]
	v_ldexp_f32 v152, v78, v87
	v_cndmask_b32_e64 v78, 0, v145, s[12:13]
	v_ldexp_f32 v153, v81, v88
	v_cndmask_b32_e64 v81, 0, v145, s[14:15]
	v_ldexp_f32 v154, v80, v89
	v_cndmask_b32_e64 v80, 0, v145, s[16:17]
	v_ldexp_f32 v155, v83, v79
	v_ldexp_f32 v158, v82, v78
	v_ldexp_f32 v156, v85, v81
	v_ldexp_f32 v157, v84, v80
	v_cvt_pk_bf16_f32 v81, v157, v156
	v_cvt_pk_bf16_f32 v80, v158, v155
	v_cvt_pk_bf16_f32 v79, v154, v153
	v_cvt_pk_bf16_f32 v78, v152, v151
	ds_read_u16 v82, v139 offset:5312
	ds_read_u16 v83, v139 offset:5760
	v_mfma_f32_32x32x16_bf16 v[2:17], v[74:77], v[78:81], v[2:17]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v77, v161, v160, s23
	v_perm_b32 v76, v167, v166, s23
	v_perm_b32 v75, v159, v165, s23
	v_perm_b32 v74, v168, v164, s23
	ds_read_u16 v88, v139 offset:4800
	ds_read_u16 v89, v139 offset:4480
	ds_read_u16 v169, v139 offset:4224
	ds_read_u16 v202, v139 offset:4736
	ds_read_u16 v203, v139 offset:4992
	ds_read_u16 v204, v139 offset:5248
	ds_read_u16 v205, v139 offset:5504
	ds_read_u16 v206, v139 offset:5568
	ds_read_u16 v84, v139 offset:6016
	ds_read_u16 v85, v139 offset:6080
	ds_read_u16 v86, v139 offset:5824
	ds_read_u16 v87, v139 offset:5056
	v_mfma_f32_32x32x16_bf16 v[50:65], v[74:77], v[78:81], v[50:65]
	ds_read_u16 v102, v139 offset:4544
	ds_read_u16 v159, v139 offset:4288
	s_waitcnt lgkmcnt(5)
	v_perm_b32 v77, v84, v83, s23
	v_perm_b32 v76, v205, v204, s23
	v_perm_b32 v75, v203, v202, s23
	v_perm_b32 v74, v89, v169, s23
	ds_read_u16 v83, v139 offset:8192
	ds_read_u16 v84, v139 offset:8704
	ds_read_u16 v163, v139 offset:9984
	ds_read_u16 v164, v139 offset:8448
	v_mfma_f32_32x32x16_bf16 v[34:49], v[74:77], v[78:81], v[34:49]
	s_waitcnt lgkmcnt(7)
	v_perm_b32 v77, v85, v86, s23
	v_perm_b32 v76, v206, v82, s23
	s_waitcnt lgkmcnt(6)
	v_perm_b32 v75, v87, v88, s23
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v74, v102, v159, s23
	ds_read_u16 v160, v139 offset:8960
	ds_read_u16 v161, v139 offset:9216
	v_pk_add_f32 v[66:67], v[66:67], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[68:69], v[68:69], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	ds_read_u16 v89, v139 offset:9472
	ds_read_u16 v162, v139 offset:9728
	v_pk_add_f32 v[70:71], v[70:71], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[72:73], v[72:73], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cmp_gt_f32_e32 vcc, s21, v67
	v_cmp_gt_f32_e64 s[4:5], s21, v66
	v_cmp_gt_f32_e64 s[6:7], s21, v69
	v_cmp_gt_f32_e64 s[8:9], s21, v68
	v_mfma_f32_32x32x16_bf16 v[18:33], v[74:77], v[78:81], v[18:33]
	s_waitcnt lgkmcnt(3)
	v_perm_b32 v75, v160, v84, s23
	v_perm_b32 v74, v164, v83, s23
	v_cmp_gt_f32_e64 s[10:11], s21, v71
	v_cmp_gt_f32_e64 s[12:13], s21, v70
	v_cmp_gt_f32_e64 s[14:15], s21, v73
	v_cmp_gt_f32_e64 s[16:17], s21, v72
	v_cndmask_b32_e32 v82, 0, v144, vcc
	v_cndmask_b32_e64 v83, 0, v144, s[4:5]
	v_cndmask_b32_e64 v84, 0, v144, s[6:7]
	v_cndmask_b32_e64 v85, 0, v144, s[8:9]
	v_add_f32_e32 v67, v67, v82
	v_add_f32_e32 v66, v66, v83
	v_cndmask_b32_e64 v82, 0, v144, s[10:11]
	v_cndmask_b32_e64 v83, 0, v144, s[12:13]
	v_add_f32_e32 v69, v69, v84
	v_add_f32_e32 v68, v68, v85
	v_cndmask_b32_e64 v84, 0, v144, s[14:15]
	v_cndmask_b32_e64 v85, 0, v144, s[16:17]
	v_add_f32_e32 v71, v71, v82
	v_add_f32_e32 v70, v70, v83
	v_add_f32_e32 v73, v73, v84
	v_add_f32_e32 v72, v72, v85
	v_exp_f32_e32 v67, v67
	v_exp_f32_e32 v66, v66
	v_exp_f32_e32 v69, v69
	v_exp_f32_e32 v68, v68
	v_exp_f32_e32 v71, v71
	v_exp_f32_e32 v70, v70
	v_exp_f32_e32 v73, v73
	v_exp_f32_e32 v72, v72
	ds_read_u16 v86, v139 offset:8256
	ds_read_u16 v167, v139 offset:8768
	ds_read_u16 v87, v139 offset:9024
	ds_read_u16 v88, v139 offset:9280
	ds_read_u16 v102, v139 offset:9536
	ds_read_u16 v168, v139 offset:8512
	s_waitcnt lgkmcnt(6)
	v_perm_b32 v77, v163, v162, s23
	v_perm_b32 v76, v89, v161, s23
	ds_read_u16 v89, v139 offset:9792
	ds_read_u16 v203, v139 offset:10048
	v_cndmask_b32_e32 v82, 0, v145, vcc
	v_cndmask_b32_e64 v83, 0, v145, s[4:5]
	v_cndmask_b32_e64 v84, 0, v145, s[6:7]
	v_cndmask_b32_e64 v85, 0, v145, s[8:9]
	v_ldexp_f32 v159, v67, v82
	v_cndmask_b32_e64 v67, 0, v145, s[10:11]
	v_ldexp_f32 v160, v66, v83
	v_cndmask_b32_e64 v66, 0, v145, s[12:13]
	v_ldexp_f32 v161, v69, v84
	v_cndmask_b32_e64 v69, 0, v145, s[14:15]
	v_ldexp_f32 v162, v68, v85
	v_cndmask_b32_e64 v68, 0, v145, s[16:17]
	v_ldexp_f32 v163, v71, v67
	v_ldexp_f32 v165, v70, v66
	v_ldexp_f32 v164, v73, v69
	v_ldexp_f32 v166, v72, v68
	v_cvt_pk_bf16_f32 v85, v166, v164
	v_cvt_pk_bf16_f32 v84, v165, v163
	v_cvt_pk_bf16_f32 v83, v162, v161
	v_cvt_pk_bf16_f32 v82, v160, v159
	ds_read_u16 v70, v139 offset:9408
	ds_read_u16 v71, v139 offset:9856
	v_mfma_f32_32x32x16_bf16 v[2:17], v[74:77], v[82:85], v[2:17]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v69, v203, v89, s23
	v_perm_b32 v68, v102, v88, s23
	v_perm_b32 v67, v87, v167, s23
	v_perm_b32 v66, v168, v86, s23
	ds_read_u16 v76, v139 offset:8896
	ds_read_u16 v77, v139 offset:8576
	ds_read_u16 v78, v139 offset:8320
	ds_read_u16 v79, v139 offset:8832
	ds_read_u16 v80, v139 offset:9088
	ds_read_u16 v81, v139 offset:9344
	ds_read_u16 v169, v139 offset:9600
	ds_read_u16 v202, v139 offset:9664
	ds_read_u16 v72, v139 offset:10112
	ds_read_u16 v73, v139 offset:10176
	v_mfma_f32_32x32x16_bf16 v[50:65], v[66:69], v[82:85], v[50:65]
	s_waitcnt lgkmcnt(3)
	v_perm_b32 v68, v169, v81, s23
	s_waitcnt lgkmcnt(1)
	v_perm_b32 v69, v72, v71, s23
	v_perm_b32 v67, v80, v79, s23
	v_perm_b32 v66, v77, v78, s23
	ds_read_u16 v74, v139 offset:9920
	ds_read_u16 v75, v139 offset:9152
	ds_read_u16 v71, v139 offset:13312
	ds_read_u16 v72, v139 offset:13568
	ds_read_u16 v79, v139 offset:13824
	ds_read_u16 v80, v139 offset:13376
	v_mfma_f32_32x32x16_bf16 v[34:49], v[66:69], v[82:85], v[34:49]
	s_waitcnt lgkmcnt(5)
	v_perm_b32 v89, v73, v74, s23
	v_perm_b32 v88, v202, v70, s23
	ds_read_u16 v70, v139 offset:14144
	ds_read_u16 v66, v139 offset:12800
	ds_read_u16 v67, v139 offset:13056
	ds_read_u16 v73, v139 offset:12288
	ds_read_u16 v77, v139 offset:13632
	ds_read_u16 v78, v139 offset:14080
	ds_read_u16 v81, v139 offset:13888
	ds_read_u16 v167, v139 offset:13440
	s_waitcnt lgkmcnt(12)
	v_perm_b32 v87, v75, v76, s23
	s_waitcnt lgkmcnt(10)
	v_perm_b32 v68, v72, v71, s23
	ds_read_u16 v71, v139 offset:12544
	ds_read_u16 v74, v139 offset:13952
	ds_read_u16 v75, v139 offset:12864
	ds_read_u16 v76, v139 offset:13120
	s_waitcnt lgkmcnt(9)
	v_perm_b32 v67, v67, v66, s23
	s_waitcnt lgkmcnt(7)
	v_perm_b32 v72, v77, v80, s23
	s_waitcnt lgkmcnt(3)
	v_perm_b32 v66, v71, v73, s23
	v_perm_b32 v73, v70, v81, s23
	ds_read_u16 v70, v139 offset:12352
	ds_read_u16 v77, v139 offset:12608
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v71, v76, v75, s23
	ds_read_u16 v75, v139 offset:14208
	ds_read_u16 v76, v139 offset:13696
	ds_read_u16 v86, v139 offset:8640
	ds_read_u16 v102, v139 offset:8384
	v_perm_b32 v69, v78, v79, s23
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v70, v77, v70, s23
	s_waitcnt lgkmcnt(3)
	v_perm_b32 v77, v75, v74, s23
	ds_read_u16 v74, v139 offset:12928
	ds_read_u16 v75, v139 offset:13184
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v86, v102, s23
	v_pk_add_f32 v[96:97], v[96:97], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[94:95], v[94:95], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cmp_gt_f32_e32 vcc, s21, v97
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v75, v74, s23
	ds_read_u16 v74, v139 offset:12416
	ds_read_u16 v78, v139 offset:12672
	v_cmp_gt_f32_e64 s[4:5], s21, v96
	v_cmp_gt_f32_e64 s[6:7], s21, v95
	v_cmp_gt_f32_e64 s[8:9], s21, v94
	v_pk_add_f32 v[92:93], v[92:93], v[118:119] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v74, v78, v74, s23
	ds_read_u16 v78, v139 offset:13760
	ds_read_u16 v79, v139 offset:14272
	ds_read_u16 v80, v139 offset:14016
	ds_read_u16 v102, v139 offset:13504
	v_cmp_gt_f32_e64 s[10:11], s21, v93
	v_cmp_gt_f32_e64 s[12:13], s21, v92
	v_cmp_gt_f32_e64 s[14:15], s21, v91
	s_waitcnt lgkmcnt(1)
	v_perm_b32 v81, v79, v80, s23
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v80, v78, v102, s23
	ds_read_u16 v78, v139 offset:13248
	ds_read_u16 v79, v139 offset:12992
	v_perm_b32 v76, v76, v167, s23
	v_mfma_f32_32x32x16_bf16 v[18:33], v[86:89], v[82:85], v[18:33]
	v_mul_f32_e32 v90, v122, v90
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v79, v78, v79, s23
	ds_read_u16 v78, v139 offset:12736
	ds_read_u16 v102, v139 offset:12480
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v78, v78, v102, s23
	v_cndmask_b32_e32 v102, 0, v144, vcc
	v_add_f32_e32 v97, v97, v102
	v_cndmask_b32_e64 v102, 0, v144, s[4:5]
	v_add_f32_e32 v96, v96, v102
	v_cndmask_b32_e64 v102, 0, v144, s[6:7]
	v_add_f32_e32 v95, v95, v102
	v_cndmask_b32_e64 v102, 0, v144, s[8:9]
	v_add_f32_e32 v94, v94, v102
	v_cndmask_b32_e64 v102, 0, v144, s[10:11]
	v_add_f32_e32 v102, v93, v102
	v_cndmask_b32_e64 v93, 0, v144, s[12:13]
	v_add_f32_e32 v167, v92, v93
	v_cndmask_b32_e64 v92, 0, v144, s[14:15]
	v_add_f32_e32 v168, v91, v92
	v_sub_f32_e32 v91, v209, v118
	v_cmp_gt_f32_e64 s[16:17], s21, v91
	v_cndmask_b32_e64 v93, 0, v145, s[4:5]
	v_exp_f32_e32 v94, v94
	v_cndmask_b32_e64 v92, 0, v144, s[16:17]
	v_add_f32_e32 v169, v91, v92
	v_exp_f32_e32 v91, v97
	v_cndmask_b32_e32 v92, 0, v145, vcc
	v_cndmask_b32_e64 v97, 0, v145, s[12:13]
	v_cmp_lt_i64_e32 vcc, s[30:31], v[100:101]
	v_ldexp_f32 v91, v91, v92
	v_exp_f32_e32 v92, v96
	v_cndmask_b32_e64 v96, 0, v145, s[10:11]
	s_and_b64 vcc, exec, vcc
	v_ldexp_f32 v93, v92, v93
	v_exp_f32_e32 v92, v95
	v_cndmask_b32_e64 v95, 0, v145, s[6:7]
	v_cvt_pk_bf16_f32 v82, v93, v91
	v_ldexp_f32 v92, v92, v95
	v_cndmask_b32_e64 v95, 0, v145, s[8:9]
	v_ldexp_f32 v95, v94, v95
	v_exp_f32_e32 v94, v102
	v_cndmask_b32_e64 v102, 0, v145, s[16:17]
	v_cvt_pk_bf16_f32 v83, v95, v92
	v_ldexp_f32 v94, v94, v96
	v_exp_f32_e32 v96, v167
	v_cndmask_b32_e64 v167, 0, v145, s[14:15]
	v_ldexp_f32 v96, v96, v97
	v_exp_f32_e32 v97, v169
	v_cvt_pk_bf16_f32 v84, v96, v94
	v_ldexp_f32 v97, v97, v102
	v_exp_f32_e32 v102, v168
	v_add_f32_e32 v168, v211, v210
	v_add_f32_e32 v86, v146, v168
	v_add_f32_e32 v86, v103, v86
	v_ldexp_f32 v167, v102, v167
	v_add_f32_e32 v86, v150, v86
	v_cvt_pk_bf16_f32 v85, v97, v167
	v_add_f32_e32 v86, v148, v86
	v_mov_b32_e32 v102, v118
	v_mfma_f32_32x32x16_bf16 v[2:17], v[66:69], v[82:85], v[2:17]
	v_add_f32_e32 v66, v149, v86
	v_add_f32_e32 v66, v147, v66
	v_add_f32_e32 v66, v152, v66
	v_add_f32_e32 v66, v151, v66
	v_add_f32_e32 v66, v154, v66
	v_add_f32_e32 v66, v153, v66
	v_add_f32_e32 v66, v158, v66
	v_add_f32_e32 v66, v155, v66
	v_add_f32_e32 v66, v157, v66
	v_add_f32_e32 v66, v156, v66
	v_add_f32_e32 v66, v160, v66
	v_add_f32_e32 v66, v159, v66
	v_add_f32_e32 v66, v162, v66
	v_add_f32_e32 v66, v161, v66
	v_add_f32_e32 v66, v165, v66
	v_add_f32_e32 v66, v163, v66
	v_add_f32_e32 v66, v166, v66
	v_add_f32_e32 v66, v164, v66
	v_add_f32_e32 v66, v93, v66
	v_add_f32_e32 v66, v91, v66
	v_add_f32_e32 v66, v95, v66
	v_add_f32_e32 v66, v92, v66
	v_add_f32_e32 v66, v96, v66
	v_add_f32_e32 v66, v94, v66
	v_mfma_f32_32x32x16_bf16 v[50:65], v[70:73], v[82:85], v[50:65]
	v_add_f32_e32 v66, v97, v66
	v_add_f32_e32 v66, v66, v167
	v_mov_b32_e32 v67, v66
	v_mov_b32_e32 v68, v66
	s_nop 1
	v_permlane32_swap_b32_e32 v67, v68
	v_cmp_eq_u32_e64 s[4:5], v67, v66
	v_mfma_f32_32x32x16_bf16 v[34:49], v[74:77], v[82:85], v[34:49]
	s_nop 0
	v_cndmask_b32_e64 v67, v67, v68, s[4:5]
	v_add_f32_e32 v66, v66, v67
	v_add_f32_e32 v122, v90, v66
	v_mfma_f32_32x32x16_bf16 v[18:33], v[78:81], v[82:85], v[18:33]
	s_cbranch_vccnz .LBB0_3
	s_branch .LBB0_5
.LBB0_4:
	v_mov_b32_e32 v3, v2
	v_mov_b32_e32 v4, v2
	v_mov_b32_e32 v5, v2
	v_mov_b32_e32 v6, v2
	v_mov_b32_e32 v7, v2
	v_mov_b32_e32 v8, v2
	v_mov_b32_e32 v9, v2
	v_mov_b32_e32 v10, v2
	v_mov_b32_e32 v11, v2
	v_mov_b32_e32 v12, v2
	v_mov_b32_e32 v13, v2
	v_mov_b32_e32 v14, v2
	v_mov_b32_e32 v15, v2
	v_mov_b32_e32 v16, v2
	v_mov_b32_e32 v17, v2
	v_mov_b32_e32 v118, 0xf149f2ca
	v_mov_b32_e32 v122, 0
	v_mov_b64_e32 v[32:33], v[16:17]
	v_mov_b64_e32 v[30:31], v[14:15]
	v_mov_b64_e32 v[28:29], v[12:13]
	v_mov_b64_e32 v[26:27], v[10:11]
	v_mov_b64_e32 v[24:25], v[8:9]
	v_mov_b64_e32 v[22:23], v[6:7]
	v_mov_b64_e32 v[20:21], v[4:5]
	v_mov_b64_e32 v[18:19], v[2:3]
	v_mov_b64_e32 v[48:49], v[16:17]
	v_mov_b64_e32 v[46:47], v[14:15]
	v_mov_b64_e32 v[44:45], v[12:13]
	v_mov_b64_e32 v[42:43], v[10:11]
	v_mov_b64_e32 v[40:41], v[8:9]
	v_mov_b64_e32 v[38:39], v[6:7]
	v_mov_b64_e32 v[36:37], v[4:5]
	v_mov_b64_e32 v[34:35], v[2:3]
	v_mov_b64_e32 v[64:65], v[16:17]
	v_mov_b64_e32 v[62:63], v[14:15]
	v_mov_b64_e32 v[60:61], v[12:13]
	v_mov_b64_e32 v[58:59], v[10:11]
	v_mov_b64_e32 v[56:57], v[8:9]
	v_mov_b64_e32 v[54:55], v[6:7]
	v_mov_b64_e32 v[52:53], v[4:5]
	v_mov_b64_e32 v[50:51], v[2:3]
.LBB0_5:
	v_and_b32_e32 v123, 63, v0
	s_cmp_ge_i32 s78, s24
	v_lshlrev_b32_e32 v100, 2, v1
	s_cbranch_scc1 .LBB0_9
	v_and_b32_e32 v1, 0xf0, v0
	v_bitop3_b32 v66, v119, v99, 7 bitop3:0x6c
	v_or_b32_e32 v67, v66, v1
	v_lshlrev_b32_e32 v125, 4, v67
	s_movk_i32 s2, 0x1f0
	v_mov_b32_e32 v67, 0x100
	v_bitop3_b32 v67, v0, s2, v67 bitop3:0xc8
	v_or_b32_e32 v68, v66, v67
	v_lshlrev_b32_e32 v126, 4, v68
	s_movk_i32 s2, 0x2f0
	v_mov_b32_e32 v68, 0x200
	v_bitop3_b32 v68, v0, s2, v68 bitop3:0xc8
	v_or_b32_e32 v69, v66, v68
	v_lshlrev_b32_e32 v127, 4, v69
	s_movk_i32 s2, 0x3f0
	v_mov_b32_e32 v69, 0x300
	v_bitop3_b32 v0, v0, s2, v69 bitop3:0xc8
	v_or_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v128, 4, v66
	v_sub_u32_e32 v66, v107, v106
	v_add_u32_e32 v1, v66, v1
	v_or_b32_e32 v1, v1, v99
	v_lshlrev_b32_e32 v129, 4, v1
	v_add_u32_e32 v1, v66, v67
	v_add_u32_e32 v0, v66, v0
	v_or_b32_e32 v1, v1, v99
	v_or_b32_e32 v0, v0, v99
	v_and_b32_e32 v67, 56, v105
	v_lshlrev_b32_e32 v130, 4, v1
	v_add_u32_e32 v1, v66, v68
	v_lshlrev_b32_e32 v132, 4, v0
	v_or_b32_e32 v66, v113, v104
	v_bitop3_b32 v0, v113, v67, v104 bitop3:0x36
	v_lshlrev_b32_e32 v133, 1, v0
	v_bitop3_b32 v0, v66, v67, 16 bitop3:0x36
	v_lshlrev_b32_e32 v134, 1, v0
	v_bitop3_b32 v0, v66, v67, 32 bitop3:0x36
	v_lshlrev_b32_e32 v135, 1, v0
	v_bitop3_b32 v0, v66, v67, 48 bitop3:0x36
	v_lshlrev_b32_e32 v136, 1, v0
	v_bitop3_b32 v0, v66, v67, 64 bitop3:0x36
	s_movk_i32 s2, 0x50
	v_lshlrev_b32_e32 v137, 1, v0
	v_bitop3_b32 v0, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x60
	v_lshlrev_b32_e32 v138, 1, v0
	v_bitop3_b32 v0, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x70
	v_lshlrev_b32_e32 v139, 1, v0
	v_bitop3_b32 v0, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1010
	v_bitop3_b32 v68, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1020
	v_lshlrev_b32_e32 v142, 1, v68
	v_bitop3_b32 v68, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1030
	v_lshlrev_b32_e32 v143, 1, v68
	v_bitop3_b32 v68, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1040
	v_lshlrev_b32_e32 v144, 1, v68
	v_bitop3_b32 v68, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1050
	v_lshlrev_b32_e32 v145, 1, v68
	v_bitop3_b32 v68, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1060
	v_lshlrev_b32_e32 v146, 1, v68
	v_bitop3_b32 v68, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1070
	v_bitop3_b32 v66, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x4000
	s_ashr_i32 s25, s24, 31
	s_add_i32 s72, s82, -1
	s_add_u32 s73, s39, s40
	s_add_u32 s75, s37, s38
	v_or3_b32 v149, v111, v116, s2
	s_ashr_i32 s2, s36, 31
	s_and_b64 s[4:5], s[28:29], exec
	s_cselect_b64 s[4:5], 1, 0
	s_sub_u32 s4, s36, s4
	s_subb_u32 s5, s2, s5
	v_lshlrev_b32_e32 v140, 1, v0
	v_add_u32_e32 v0, s27, v115
	v_lshlrev_b32_e32 v148, 1, v66
	s_mov_b32 s27, 0
	v_mov_b64_e32 v[66:67], s[4:5]
	v_cmp_lt_i64_e32 vcc, s[26:27], v[66:67]
	s_and_b64 s[6:7], vcc, exec
	s_cselect_b32 s2, 0, s5
	s_cselect_b32 s8, s26, s4
	s_ashr_i32 s21, s20, 31
	v_lshlrev_b32_e32 v147, 1, v68
	s_ashr_i32 s23, s22, 31
	v_mov_b64_e32 v[68:69], s[20:21]
	v_cmp_lt_i64_e32 vcc, s[22:23], v[68:69]
	s_and_b64 s[4:5], vcc, exec
	v_mov_b32_e32 v66, s8
	v_mov_b32_e32 v67, s2
	s_cselect_b32 s5, s23, s21
	s_cselect_b32 s4, s22, s20
	v_cmp_lt_i64_e32 vcc, s[4:5], v[66:67]
	s_and_b64 s[6:7], vcc, exec
	s_cselect_b32 s6, s4, s8
	s_mov_b32 s8, s5
	s_mov_b32 s9, s5
	s_cselect_b32 s7, s5, s2
	s_and_b64 s[4:5], s[4:5], s[8:9]
	v_mov_b64_e32 v[66:67], s[4:5]
	v_cmp_gt_i64_e32 vcc, s[6:7], v[66:67]
	s_and_b64 s[8:9], vcc, exec
	v_or_b32_e32 v1, v1, v99
	s_cselect_b32 s2, s6, s4
	v_lshlrev_b32_e32 v124, 3, v99
	v_lshlrev_b32_e32 v131, 4, v1
	v_or_b32_e32 v141, 1, v100
	v_or_b32_e32 v1, 3, v100
	v_or_b32_e32 v102, 2, v100
	v_or_b32_e32 v99, 9, v100
	v_or_b32_e32 v104, 8, v100
	v_or_b32_e32 v101, 11, v100
	v_or_b32_e32 v106, 10, v100
	v_or_b32_e32 v103, 17, v100
	v_or_b32_e32 v108, 16, v100
	v_or_b32_e32 v105, 19, v100
	v_or_b32_e32 v110, 18, v100
	v_or_b32_e32 v107, 25, v100
	v_or_b32_e32 v112, 24, v100
	v_or_b32_e32 v109, 27, v100
	v_or_b32_e32 v114, 26, v100
	s_mov_b32 s76, s82
	s_mov_b32 s77, s82
	v_mov_b32_e32 v111, v0
	s_mov_b32 s82, s83
	s_lshl_b32 s80, s2, 6
	v_or_b32_e32 v150, 48, v119
	v_or_b32_e32 v151, 32, v119
	v_or_b32_e32 v152, 16, v119
	s_mov_b32 s2, 0x3fb8aa3b
	v_mov_b32_e32 v153, 0xf149f2ca
	s_mov_b32 s92, 0xc2fc0000
	v_mov_b32_e32 v154, 0x42800000
	v_not_b32_e32 v155, 63
	s_mov_b32 s93, 0x5040100
	v_mov_b64_e32 v[116:117], s[24:25]
	s_mov_b32 s90, s86
	s_mov_b32 s91, s87
.LBB0_7:
	v_add_u32_e32 v66, s80, v119
	v_min_i32_e32 v66, s72, v66
	v_mul_lo_u32 v67, s74, v66
	v_add_u32_e32 v67, s73, v67
	v_add_lshl_u32 v67, v124, v67, 1
	s_barrier
	buffer_load_dwordx4 v[68:71], v67, s[84:87], 0 offen
	v_add_u32_e32 v67, s80, v152
	v_min_i32_e32 v67, s72, v67
	v_mul_lo_u32 v66, s94, v66
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v124, v66, 1
	s_add_i32 s34, s80, 32
	v_or_b32_e32 v120, s34, v103
	v_or_b32_e32 v121, s34, v108
	v_cmp_gt_i32_e64 s[4:5], s77, v120
	v_cmp_gt_i32_e32 vcc, s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[6:7], 1, v120
	v_cmp_gt_i32_e64 s[8:9], 1, v121
	v_or_b32_e32 v120, s34, v105
	v_or_b32_e32 v121, s34, v110
	s_and_b64 s[68:69], s[4:5], s[6:7]
	v_cmp_gt_i32_e64 s[6:7], s77, v120
	v_cmp_gt_i32_e64 s[4:5], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	s_and_b64 vcc, vcc, s[8:9]
	v_cmp_gt_i32_e64 s[8:9], 1, v120
	v_cmp_gt_i32_e64 s[10:11], 1, v121
	v_or_b32_e32 v120, s34, v107
	v_or_b32_e32 v121, s34, v112
	s_and_b64 s[4:5], s[4:5], s[10:11]
	s_and_b64 s[6:7], s[6:7], s[8:9]
	v_cmp_gt_i32_e64 s[10:11], s77, v120
	v_cmp_gt_i32_e64 s[8:9], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[12:13], 1, v120
	v_cmp_gt_i32_e64 s[14:15], 1, v121
	v_or_b32_e32 v120, s34, v109
	v_or_b32_e32 v121, s34, v114
	s_and_b64 s[8:9], s[8:9], s[14:15]
	s_and_b64 s[10:11], s[10:11], s[12:13]
	v_cmp_gt_i32_e64 s[14:15], s77, v120
	v_cmp_gt_i32_e64 s[12:13], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[16:17], 1, v120
	v_cmp_gt_i32_e64 s[18:19], 1, v121
	v_or_b32_e32 v120, s34, v141
	v_or_b32_e32 v121, s34, v100
	s_and_b64 s[12:13], s[12:13], s[18:19]
	s_and_b64 s[14:15], s[14:15], s[16:17]
	v_cmp_gt_i32_e64 s[18:19], s77, v120
	v_cmp_gt_i32_e64 s[16:17], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[20:21], 1, v120
	v_cmp_gt_i32_e64 s[22:23], 1, v121
	v_or_b32_e32 v120, s34, v1
	v_or_b32_e32 v121, s34, v102
	s_and_b64 s[16:17], s[16:17], s[22:23]
	s_and_b64 s[18:19], s[18:19], s[20:21]
	v_cmp_gt_i32_e64 s[22:23], s77, v120
	v_cmp_gt_i32_e64 s[20:21], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[24:25], 1, v120
	v_cmp_gt_i32_e64 s[26:27], 1, v121
	v_or_b32_e32 v120, s34, v99
	v_or_b32_e32 v121, s34, v104
	s_and_b64 s[20:21], s[20:21], s[26:27]
	s_and_b64 s[22:23], s[22:23], s[24:25]
	v_cmp_gt_i32_e64 s[26:27], s77, v120
	v_cmp_gt_i32_e64 s[24:25], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[28:29], 1, v120
	v_cmp_gt_i32_e64 s[30:31], 1, v121
	v_or_b32_e32 v120, s34, v101
	v_or_b32_e32 v121, s34, v106
	s_and_b64 s[24:25], s[24:25], s[30:31]
	s_and_b64 s[26:27], s[26:27], s[28:29]
	v_cmp_gt_i32_e64 s[30:31], s77, v120
	s_waitcnt vmcnt(0)
	ds_write_b128 v125, v[68:71]
	v_mul_lo_u32 v68, s74, v67
	v_add_u32_e32 v68, s73, v68
	v_add_lshl_u32 v68, v124, v68, 1
	buffer_load_dwordx4 v[68:71], v68, s[84:87], 0 offen
	v_cmp_gt_i32_e64 s[28:29], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[34:35], 1, v120
	v_cmp_gt_i32_e64 s[36:37], 1, v121
	v_or_b32_e32 v120, s80, v103
	v_or_b32_e32 v121, s80, v108
	s_and_b64 s[28:29], s[28:29], s[36:37]
	s_and_b64 s[30:31], s[30:31], s[34:35]
	v_cmp_gt_i32_e64 s[36:37], s77, v120
	v_cmp_gt_i32_e64 s[34:35], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[38:39], 1, v120
	v_cmp_gt_i32_e64 s[40:41], 1, v121
	v_or_b32_e32 v120, s80, v105
	v_or_b32_e32 v121, s80, v110
	s_and_b64 s[34:35], s[34:35], s[40:41]
	s_and_b64 s[36:37], s[36:37], s[38:39]
	v_cmp_gt_i32_e64 s[40:41], s77, v120
	v_cmp_gt_i32_e64 s[38:39], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[42:43], 1, v120
	v_cmp_gt_i32_e64 s[44:45], 1, v121
	v_or_b32_e32 v120, s80, v107
	v_or_b32_e32 v121, s80, v112
	s_and_b64 s[38:39], s[38:39], s[44:45]
	s_and_b64 s[40:41], s[40:41], s[42:43]
	v_cmp_gt_i32_e64 s[44:45], s77, v120
	v_cmp_gt_i32_e64 s[42:43], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[46:47], 1, v120
	v_cmp_gt_i32_e64 s[48:49], 1, v121
	v_or_b32_e32 v120, s80, v109
	v_or_b32_e32 v121, s80, v114
	s_and_b64 s[42:43], s[42:43], s[48:49]
	s_and_b64 s[44:45], s[44:45], s[46:47]
	v_cmp_gt_i32_e64 s[48:49], s77, v120
	v_cmp_gt_i32_e64 s[46:47], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[50:51], 1, v120
	v_cmp_gt_i32_e64 s[52:53], 1, v121
	v_or_b32_e32 v120, s80, v141
	v_or_b32_e32 v121, s80, v100
	s_and_b64 s[46:47], s[46:47], s[52:53]
	s_and_b64 s[48:49], s[48:49], s[50:51]
	v_cmp_gt_i32_e64 s[52:53], s77, v120
	v_cmp_gt_i32_e64 s[50:51], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[54:55], 1, v120
	v_cmp_gt_i32_e64 s[56:57], 1, v121
	s_and_b64 s[50:51], s[50:51], s[56:57]
	s_and_b64 s[52:53], s[52:53], s[54:55]
	v_or_b32_e32 v121, s80, v1
	v_cmp_gt_i32_e64 s[56:57], s77, v121
	v_sub_u32_e32 v121, v121, v111
	v_cmp_gt_i32_e64 s[58:59], 1, v121
	s_and_b64 s[56:57], s[56:57], s[58:59]
	v_or_b32_e32 v121, s80, v104
	s_waitcnt vmcnt(0)
	ds_write_b128 v126, v[68:71]
	v_add_u32_e32 v68, s80, v151
	v_min_i32_e32 v68, s72, v68
	v_mul_lo_u32 v69, s74, v68
	v_add_u32_e32 v69, s73, v69
	v_add_lshl_u32 v69, v124, v69, 1
	buffer_load_dwordx4 v[70:73], v69, s[84:87], 0 offen
	v_add_u32_e32 v69, s80, v150
	v_min_i32_e32 v69, s72, v69
	s_waitcnt vmcnt(0)
	ds_write_b128 v127, v[70:73]
	v_mul_lo_u32 v70, s74, v69
	v_add_u32_e32 v70, s73, v70
	v_add_lshl_u32 v70, v124, v70, 1
	buffer_load_dwordx4 v[70:73], v70, s[84:87], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v128, v[70:73]
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v67
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v124, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v129, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v68
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v124, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v130, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v69
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v124, v66, 1
	buffer_load_dwordx4 v[66:69], v66, s[88:91], 0 offen
	s_waitcnt vmcnt(1)
	ds_write_b128 v131, v[70:73] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v132, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[82:85], v133
	ds_read_b128 v[156:159], v133 offset:8192
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[170:173], 0
	ds_read_b128 v[82:85], v134
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[174:177], v[66:81]
	ds_read_b128 v[82:85], v135
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[178:181], v[66:81]
	ds_read_b128 v[82:85], v136
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[182:185], v[66:81]
	ds_read_b128 v[82:85], v137
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[186:189], v[66:81]
	ds_read_b128 v[82:85], v138
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[190:193], v[66:81]
	ds_read_b128 v[82:85], v139
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[194:197], v[66:81]
	ds_read_b128 v[82:85], v140
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[82:85], v[198:201], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[170:173], 0
	ds_read_b128 v[156:159], v142
	s_nop 9
	v_mul_f32_e64 v66, s82, v66
	v_mul_f32_e64 v67, s83, v67
	v_mul_f32_e64 v68, s82, v68
	v_mul_f32_e64 v69, s83, v69
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[68:69], v[68:69], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, v153, v67, s[52:53]
	v_cndmask_b32_e64 v66, v153, v66, s[50:51]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[174:177], v[82:97]
	ds_read_b128 v[156:159], v143
	v_cmp_gt_f32_e64 s[54:55], v66, v67
	v_cndmask_b32_e64 v69, v153, v69, s[56:57]
	v_mul_f32_e64 v70, s82, v70
	v_mul_f32_e64 v71, s83, v71
	v_cndmask_b32_e64 v120, v67, v66, s[54:55]
	v_pk_mul_f32 v[70:71], v[70:71], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[74:75], s[82:83], v[74:75]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[178:181], v[82:97]
	ds_read_b128 v[156:159], v144
	v_mul_f32_e64 v74, v74, s2
	v_mul_f32_e64 v75, v75, s2
	v_mul_f32_e64 v76, s82, v76
	v_mul_f32_e64 v77, s83, v77
	v_cndmask_b32_e64 v74, v153, v74, s[34:35]
	v_cndmask_b32_e64 v75, v153, v75, s[36:37]
	v_pk_mul_f32 v[76:77], v[76:77], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[78:79], s[82:83], v[78:79]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[182:185], v[82:97]
	ds_read_b128 v[156:159], v145
	v_cndmask_b32_e64 v76, v153, v76, s[38:39]
	v_cndmask_b32_e64 v77, v153, v77, s[40:41]
	v_mul_f32_e64 v78, v78, s2
	v_mul_f32_e64 v79, v79, s2
	v_pk_mul_f32 v[80:81], s[82:83], v[80:81]
	v_cndmask_b32_e64 v78, v153, v78, s[42:43]
	v_cndmask_b32_e64 v79, v153, v79, s[44:45]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[186:189], v[82:97]
	ds_read_b128 v[156:159], v146
	v_mul_f32_e64 v80, v80, s2
	v_mul_f32_e64 v81, v81, s2
	v_cndmask_b32_e64 v80, v153, v80, s[46:47]
	v_cndmask_b32_e64 v81, v153, v81, s[48:49]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[190:193], v[82:97]
	ds_read_b128 v[156:159], v147
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[194:197], v[82:97]
	ds_read_b128 v[156:159], v148
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[198:201], v[82:97]
	v_or_b32_e32 v156, s80, v102
	v_cmp_gt_i32_e64 s[54:55], s76, v156
	v_sub_u32_e32 v156, v156, v0
	v_cmp_gt_i32_e64 s[60:61], 1, v156
	s_and_b64 s[54:55], s[54:55], s[60:61]
	v_cndmask_b32_e64 v68, v153, v68, s[54:55]
	v_cmp_gt_f32_e64 s[58:59], v120, v68
	v_or_b32_e32 v158, s80, v106
	v_or_b32_e32 v157, s80, v101
	v_cndmask_b32_e64 v120, v68, v120, s[58:59]
	v_cmp_gt_f32_e64 s[58:59], v120, v69
	s_nop 0
	v_pk_mul_f32 v[82:83], s[82:83], v[82:83]
	v_pk_mul_f32 v[84:85], s[82:83], v[84:85]
	v_cndmask_b32_e64 v156, v69, v120, s[58:59]
	v_cmp_gt_i32_e64 s[58:59], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_or_b32_e32 v120, s80, v99
	v_cmp_gt_i32_e64 s[64:65], 1, v121
	v_cmp_gt_i32_e64 s[60:61], s77, v120
	v_sub_u32_e32 v120, v120, v111
	s_and_b64 s[58:59], s[58:59], s[64:65]
	v_cmp_gt_i32_e64 s[62:63], 1, v120
	v_cndmask_b32_e64 v120, v153, v70, s[58:59]
	s_and_b64 s[60:61], s[60:61], s[62:63]
	v_cmp_gt_f32_e64 s[62:63], v156, v120
	v_cndmask_b32_e64 v121, v153, v71, s[60:61]
	v_cmp_gt_i32_e64 s[64:65], s76, v158
	v_cndmask_b32_e64 v70, v120, v156, s[62:63]
	v_cmp_gt_f32_e64 s[62:63], v70, v121
	v_pk_mul_f32 v[82:83], v[82:83], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[84:85], v[84:85], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v156, v121, v70, s[62:63]
	v_pk_mul_f32 v[70:71], s[82:83], v[72:73]
	v_sub_u32_e32 v72, v158, v0
	v_cmp_gt_i32_e64 s[70:71], 1, v72
	v_pk_mul_f32 v[70:71], v[70:71], s[2:3] op_sel_hi:[1,0]
	v_sub_u32_e32 v73, v157, v111
	s_and_b64 s[64:65], s[64:65], s[70:71]
	v_cmp_gt_i32_e64 s[62:63], s77, v157
	v_cmp_gt_i32_e64 s[66:67], 1, v73
	v_cndmask_b32_e64 v72, v153, v70, s[64:65]
	s_and_b64 s[62:63], s[62:63], s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v156, v72
	v_cndmask_b32_e64 v73, v153, v71, s[62:63]
	v_cndmask_b32_e64 v82, v153, v82, s[16:17]
	v_cndmask_b32_e64 v70, v72, v156, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v73
	v_cndmask_b32_e64 v83, v153, v83, s[18:19]
	v_cndmask_b32_e64 v84, v153, v84, s[20:21]
	v_cndmask_b32_e64 v70, v73, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v74
	v_cndmask_b32_e64 v85, v153, v85, s[22:23]
	v_pk_mul_f32 v[86:87], s[82:83], v[86:87]
	v_cndmask_b32_e64 v70, v74, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v75
	v_pk_mul_f32 v[86:87], v[86:87], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[88:89], s[82:83], v[88:89]
	v_cndmask_b32_e64 v70, v75, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v76
	v_cndmask_b32_e64 v86, v153, v86, s[24:25]
	v_cndmask_b32_e64 v87, v153, v87, s[26:27]
	v_cndmask_b32_e64 v70, v76, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v77
	v_pk_mul_f32 v[88:89], v[88:89], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[90:91], s[82:83], v[90:91]
	v_cndmask_b32_e64 v70, v77, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v78
	v_cndmask_b32_e64 v88, v153, v88, s[28:29]
	v_cndmask_b32_e64 v89, v153, v89, s[30:31]
	v_cndmask_b32_e64 v70, v78, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v79
	v_pk_mul_f32 v[90:91], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[92:93], s[82:83], v[92:93]
	v_cndmask_b32_e64 v70, v79, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v80
	v_cndmask_b32_e32 v90, v153, v90, vcc
	v_cndmask_b32_e64 v91, v153, v91, s[68:69]
	v_cndmask_b32_e64 v70, v80, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v81
	v_pk_mul_f32 v[92:93], v[92:93], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[94:95], s[82:83], v[94:95]
	v_cndmask_b32_e64 v70, v81, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v82
	v_cndmask_b32_e64 v92, v153, v92, s[4:5]
	v_cndmask_b32_e64 v93, v153, v93, s[6:7]
	v_cndmask_b32_e64 v70, v82, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v83
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[96:97], s[82:83], v[96:97]
	v_cndmask_b32_e64 v70, v83, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v84
	v_cndmask_b32_e64 v94, v153, v94, s[8:9]
	v_cndmask_b32_e64 v95, v153, v95, s[10:11]
	v_cndmask_b32_e64 v70, v84, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v85
	v_pk_mul_f32 v[96:97], v[96:97], s[2:3] op_sel_hi:[1,0]
	s_add_u32 s78, s78, 1
	v_cndmask_b32_e64 v70, v85, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v86
	v_cndmask_b32_e64 v96, v153, v96, s[12:13]
	v_cndmask_b32_e64 v97, v153, v97, s[14:15]
	v_cndmask_b32_e64 v70, v86, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v87
	s_addc_u32 s79, s79, 0
	s_add_i32 s80, s80, 64
	v_cndmask_b32_e64 v70, v87, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v88
	s_nop 1
	v_cndmask_b32_e64 v70, v88, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v89
	s_nop 1
	v_cndmask_b32_e64 v70, v89, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v90
	s_nop 1
	v_cndmask_b32_e64 v70, v90, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v91
	s_nop 1
	v_cndmask_b32_e64 v70, v91, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v92
	s_nop 1
	v_cndmask_b32_e64 v70, v92, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v93
	s_nop 1
	v_cndmask_b32_e64 v70, v93, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v94
	s_nop 1
	v_cndmask_b32_e64 v70, v94, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v95
	s_nop 1
	v_cndmask_b32_e64 v70, v95, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v96
	s_nop 1
	v_cndmask_b32_e64 v70, v96, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v97
	s_nop 1
	v_cndmask_b32_e64 v70, v97, v70, s[66:67]
	v_mov_b32_e32 v71, v70
	v_mov_b32_e32 v156, v70
	s_nop 1
	v_permlane32_swap_b32_e32 v71, v156
	v_cmp_eq_u32_e64 s[66:67], v71, v70
	s_nop 1
	v_cndmask_b32_e64 v71, v71, v156, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v70, v71
	s_nop 1
	v_cndmask_b32_e64 v70, v71, v70, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], v118, v70
	s_nop 1
	v_cndmask_b32_e64 v70, v70, v118, s[66:67]
	v_sub_f32_e32 v71, v118, v70
	v_cmp_gt_f32_e64 s[66:67], s92, v71
	s_nop 1
	v_cndmask_b32_e64 v118, 0, v154, s[66:67]
	v_add_f32_e32 v71, v71, v118
	v_exp_f32_e32 v71, v71
	v_cndmask_b32_e64 v118, 0, v155, s[66:67]
	v_pk_add_f32 v[66:67], v[66:67], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_ldexp_f32 v118, v71, v118
	v_cmp_gt_f32_e64 s[66:67], s92, v66
	v_pk_mul_f32 v[16:17], v[16:17], v[118:119] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[118:119] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v71, 0, v154, s[66:67]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[66:67]
	v_cmp_gt_f32_e64 s[66:67], s92, v67
	v_pk_mul_f32 v[12:13], v[12:13], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v66, v66, v71
	v_cndmask_b32_e64 v71, 0, v154, s[66:67]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[66:67]
	v_cndmask_b32_e64 v163, 0, v66, s[50:51]
	v_pk_mul_f32 v[10:11], v[10:11], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v162, 0, v67, s[52:53]
	v_pk_add_f32 v[66:67], v[68:69], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[8:9], v[118:119] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[50:51], s92, v66
	v_pk_mul_f32 v[6:7], v[6:7], v[118:119] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[118:119] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v68, 0, v154, s[50:51]
	v_add_f32_e32 v66, v66, v68
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v68, 0, v155, s[50:51]
	v_cmp_gt_f32_e64 s[50:51], s92, v67
	v_pk_mul_f32 v[2:3], v[2:3], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v66, v66, v68
	v_cndmask_b32_e64 v68, 0, v154, s[50:51]
	v_add_f32_e32 v67, v67, v68
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v155, s[50:51]
	v_cndmask_b32_e64 v165, 0, v66, s[54:55]
	v_pk_mul_f32 v[64:65], v[64:65], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v68
	v_cndmask_b32_e64 v164, 0, v67, s[56:57]
	v_pk_add_f32 v[66:67], v[120:121], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[62:63], v[62:63], v[118:119] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[50:51], s92, v66
	v_pk_mul_f32 v[60:61], v[60:61], v[118:119] op_sel_hi:[1,0]
	v_pk_mul_f32 v[58:59], v[58:59], v[118:119] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v68, 0, v154, s[50:51]
	v_add_f32_e32 v66, v66, v68
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v68, 0, v155, s[50:51]
	v_cmp_gt_f32_e64 s[50:51], s92, v67
	v_pk_mul_f32 v[56:57], v[56:57], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v66, v66, v68
	v_cndmask_b32_e64 v68, 0, v154, s[50:51]
	v_add_f32_e32 v67, v67, v68
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v155, s[50:51]
	v_cndmask_b32_e64 v166, 0, v66, s[58:59]
	v_pk_mul_f32 v[54:55], v[54:55], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v68
	v_cndmask_b32_e64 v68, 0, v67, s[60:61]
	v_pk_add_f32 v[66:67], v[72:73], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[52:53], v[52:53], v[118:119] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[50:51], s92, v66
	v_pk_mul_f32 v[50:51], v[50:51], v[118:119] op_sel_hi:[1,0]
	v_pk_mul_f32 v[48:49], v[48:49], v[118:119] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v69, 0, v154, s[50:51]
	v_add_f32_e32 v66, v66, v69
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v69, 0, v155, s[50:51]
	v_cmp_gt_f32_e64 s[50:51], s92, v67
	v_pk_mul_f32 v[46:47], v[46:47], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v66, v66, v69
	v_cndmask_b32_e64 v69, 0, v154, s[50:51]
	v_add_f32_e32 v67, v67, v69
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v69, 0, v155, s[50:51]
	v_cndmask_b32_e64 v167, 0, v66, s[64:65]
	v_pk_mul_f32 v[44:45], v[44:45], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v69
	v_cndmask_b32_e64 v69, 0, v67, s[62:63]
	v_pk_add_f32 v[66:67], v[74:75], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[42:43], v[42:43], v[118:119] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[50:51], s92, v66
	v_pk_mul_f32 v[40:41], v[40:41], v[118:119] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[38:39], v[118:119] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v71, 0, v154, s[50:51]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[50:51]
	v_cmp_gt_f32_e64 s[50:51], s92, v67
	v_pk_mul_f32 v[36:37], v[36:37], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v66, v66, v71
	v_cndmask_b32_e64 v71, 0, v154, s[50:51]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[50:51]
	v_cndmask_b32_e64 v121, 0, v66, s[34:35]
	v_pk_mul_f32 v[34:35], v[34:35], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v120, 0, v67, s[36:37]
	v_pk_add_f32 v[66:67], v[76:77], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[32:33], v[32:33], v[118:119] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[34:35], s92, v66
	v_pk_mul_f32 v[30:31], v[30:31], v[118:119] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[118:119] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s92, v67
	v_pk_mul_f32 v[26:27], v[26:27], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v66, v66, v71
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cndmask_b32_e64 v157, 0, v66, s[38:39]
	v_pk_mul_f32 v[24:25], v[24:25], v[118:119] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v156, 0, v67, s[40:41]
	v_pk_add_f32 v[66:67], v[78:79], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[22:23], v[118:119] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[34:35], s92, v66
	v_pk_mul_f32 v[20:21], v[20:21], v[118:119] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[118:119] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s92, v67
	v_ldexp_f32 v66, v66, v71
	s_nop 0
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cndmask_b32_e64 v159, 0, v66, s[42:43]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v158, 0, v67, s[44:45]
	v_pk_add_f32 v[66:67], v[80:81], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[34:35], s92, v66
	s_nop 1
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s92, v67
	v_ldexp_f32 v66, v66, v71
	s_nop 0
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cndmask_b32_e64 v161, 0, v66, s[46:47]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v160, 0, v67, s[48:49]
	v_pk_add_f32 v[66:67], v[82:83], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[34:35], s92, v66
	s_nop 1
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s92, v67
	v_ldexp_f32 v66, v66, v71
	s_nop 0
	v_cndmask_b32_e64 v71, 0, v154, s[34:35]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[34:35]
	v_cndmask_b32_e64 v80, 0, v66, s[16:17]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v79, 0, v67, s[18:19]
	v_pk_add_f32 v[66:67], v[84:85], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[16:17], s92, v66
	s_nop 1
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cmp_gt_f32_e64 s[16:17], s92, v67
	v_ldexp_f32 v66, v66, v71
	s_nop 0
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cndmask_b32_e64 v82, 0, v66, s[20:21]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v81, 0, v67, s[22:23]
	v_pk_add_f32 v[66:67], v[86:87], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[16:17], s92, v66
	s_nop 1
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cmp_gt_f32_e64 s[16:17], s92, v67
	v_ldexp_f32 v66, v66, v71
	s_nop 0
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cndmask_b32_e64 v84, 0, v66, s[24:25]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v83, 0, v67, s[26:27]
	v_pk_add_f32 v[66:67], v[88:89], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[16:17], s92, v66
	s_nop 1
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cmp_gt_f32_e64 s[16:17], s92, v67
	v_ldexp_f32 v66, v66, v71
	s_nop 0
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cndmask_b32_e64 v86, 0, v66, s[28:29]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v85, 0, v67, s[30:31]
	v_pk_add_f32 v[66:67], v[90:91], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[16:17], s92, v66
	s_nop 1
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v66, v66, v71
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cmp_gt_f32_e64 s[16:17], s92, v67
	v_ldexp_f32 v66, v66, v71
	s_nop 0
	v_cndmask_b32_e64 v71, 0, v154, s[16:17]
	v_add_f32_e32 v67, v67, v71
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v155, s[16:17]
	v_cndmask_b32_e32 v72, 0, v66, vcc
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v71, 0, v67, s[68:69]
	v_pk_add_f32 v[66:67], v[92:93], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s92, v66
	s_nop 1
	v_cndmask_b32_e32 v73, 0, v154, vcc
	v_add_f32_e32 v66, v66, v73
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v73, 0, v155, vcc
	v_cmp_gt_f32_e32 vcc, s92, v67
	v_ldexp_f32 v66, v66, v73
	s_nop 0
	v_cndmask_b32_e32 v73, 0, v154, vcc
	v_add_f32_e32 v67, v67, v73
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v73, 0, v155, vcc
	v_cndmask_b32_e64 v74, 0, v66, s[4:5]
	v_ldexp_f32 v67, v67, v73
	v_cndmask_b32_e64 v73, 0, v67, s[6:7]
	v_pk_add_f32 v[66:67], v[94:95], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s92, v66
	s_nop 1
	v_cndmask_b32_e32 v75, 0, v154, vcc
	v_add_f32_e32 v66, v66, v75
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v75, 0, v155, vcc
	v_cmp_gt_f32_e32 vcc, s92, v67
	v_ldexp_f32 v66, v66, v75
	s_nop 0
	v_cndmask_b32_e32 v75, 0, v154, vcc
	v_add_f32_e32 v67, v67, v75
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v75, 0, v155, vcc
	v_cndmask_b32_e64 v76, 0, v66, s[8:9]
	v_ldexp_f32 v67, v67, v75
	v_cndmask_b32_e64 v75, 0, v67, s[10:11]
	v_pk_add_f32 v[66:67], v[96:97], v[70:71] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s92, v66
	s_nop 1
	v_cndmask_b32_e32 v77, 0, v154, vcc
	v_add_f32_e32 v66, v66, v77
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v77, 0, v155, vcc
	v_cmp_gt_f32_e32 vcc, s92, v67
	v_ldexp_f32 v66, v66, v77
	v_cndmask_b32_e64 v78, 0, v66, s[12:13]
	v_add_f32_e32 v66, v163, v162
	v_add_f32_e32 v66, v165, v66
	v_add_f32_e32 v66, v164, v66
	v_add_f32_e32 v66, v166, v66
	v_add_f32_e32 v66, v68, v66
	v_add_f32_e32 v66, v167, v66
	v_add_f32_e32 v66, v69, v66
	v_add_f32_e32 v66, v121, v66
	v_add_f32_e32 v66, v120, v66
	v_add_f32_e32 v66, v157, v66
	v_add_f32_e32 v66, v156, v66
	v_add_f32_e32 v66, v159, v66
	v_add_f32_e32 v66, v158, v66
	v_add_f32_e32 v66, v161, v66
	v_add_f32_e32 v66, v160, v66
	v_add_f32_e32 v66, v80, v66
	v_add_f32_e32 v66, v79, v66
	v_add_f32_e32 v66, v82, v66
	v_add_f32_e32 v66, v81, v66
	v_add_f32_e32 v66, v84, v66
	v_add_f32_e32 v66, v83, v66
	v_add_f32_e32 v66, v86, v66
	v_cndmask_b32_e32 v77, 0, v154, vcc
	v_add_f32_e32 v66, v85, v66
	v_add_f32_e32 v67, v67, v77
	v_add_f32_e32 v66, v72, v66
	v_exp_f32_e32 v67, v67
	v_add_f32_e32 v66, v71, v66
	v_add_f32_e32 v66, v74, v66
	v_add_f32_e32 v66, v73, v66
	v_cndmask_b32_e32 v77, 0, v155, vcc
	v_add_f32_e32 v66, v76, v66
	v_ldexp_f32 v67, v67, v77
	v_add_f32_e32 v66, v75, v66
	v_cndmask_b32_e64 v77, 0, v67, s[14:15]
	v_add_f32_e32 v66, v78, v66
	v_add_f32_e32 v66, v77, v66
	v_mov_b32_e32 v67, v66
	v_mov_b32_e32 v87, v66
	s_nop 1
	v_permlane32_swap_b32_e32 v67, v87
	v_cmp_eq_u32_e32 vcc, v67, v66
	v_cvt_pk_bf16_f32 v69, v167, v69
	v_cvt_pk_bf16_f32 v68, v166, v68
	v_cndmask_b32_e32 v67, v67, v87, vcc
	ds_read_u16 v87, v149
	ds_read_u16 v88, v149 offset:256
	ds_read_u16 v89, v149 offset:512
	ds_read_u16 v90, v149 offset:768
	ds_read_u16 v91, v149 offset:1024
	ds_read_u16 v92, v149 offset:1280
	ds_read_u16 v93, v149 offset:1536
	ds_read_u16 v94, v149 offset:1792
	v_add_f32_e32 v66, v66, v67
	v_mul_f32_e32 v67, v122, v118
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v92, v92, v91, s93
	v_perm_b32 v91, v90, v89, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v93, v94, v93, s93
	v_perm_b32 v90, v88, v87, s93
	v_add_f32_e32 v122, v67, v66
	v_cvt_pk_bf16_f32 v67, v165, v164
	v_cvt_pk_bf16_f32 v66, v163, v162
	v_cmp_lt_i64_e32 vcc, s[78:79], v[116:117]
	s_and_b64 vcc, exec, vcc
	v_mfma_f32_32x32x16_bf16 v[2:17], v[90:93], v[66:69], v[2:17]
	ds_read_u16 v87, v149 offset:64
	ds_read_u16 v88, v149 offset:320
	ds_read_u16 v89, v149 offset:576
	ds_read_u16 v92, v149 offset:832
	ds_read_u16 v90, v149 offset:1088
	ds_read_u16 v93, v149 offset:1344
	ds_read_u16 v91, v149 offset:1600
	ds_read_u16 v94, v149 offset:1856
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v89, v92, v89, s93
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v90, v93, v90, s93
	v_mov_b32_e32 v118, v70
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v91, v94, v91, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[50:65], v[88:91], v[66:69], v[50:65]
	ds_read_u16 v87, v149 offset:128
	ds_read_u16 v88, v149 offset:384
	ds_read_u16 v89, v149 offset:640
	ds_read_u16 v92, v149 offset:896
	ds_read_u16 v90, v149 offset:1152
	ds_read_u16 v93, v149 offset:1408
	ds_read_u16 v91, v149 offset:1664
	ds_read_u16 v94, v149 offset:1920
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v89, v92, v89, s93
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v90, v93, v90, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v91, v94, v91, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[34:49], v[88:91], v[66:69], v[34:49]
	ds_read_u16 v87, v149 offset:192
	ds_read_u16 v88, v149 offset:448
	ds_read_u16 v89, v149 offset:704
	ds_read_u16 v92, v149 offset:960
	ds_read_u16 v90, v149 offset:1216
	ds_read_u16 v93, v149 offset:1472
	ds_read_u16 v91, v149 offset:1728
	ds_read_u16 v94, v149 offset:1984
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v89, v92, v89, s93
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v90, v93, v90, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v91, v94, v91, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[18:33], v[88:91], v[66:69], v[18:33]
	ds_read_u16 v87, v149 offset:4096
	ds_read_u16 v88, v149 offset:4352
	ds_read_u16 v89, v149 offset:4608
	ds_read_u16 v92, v149 offset:4864
	ds_read_u16 v90, v149 offset:5120
	ds_read_u16 v93, v149 offset:5376
	ds_read_u16 v91, v149 offset:5632
	ds_read_u16 v94, v149 offset:5888
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v89, v92, v89, s93
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v90, v93, v90, s93
	v_cvt_pk_bf16_f32 v69, v161, v160
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v91, v94, v91, s93
	v_cvt_pk_bf16_f32 v68, v159, v158
	v_cvt_pk_bf16_f32 v67, v157, v156
	v_cvt_pk_bf16_f32 v66, v121, v120
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[2:17], v[88:91], v[66:69], v[2:17]
	ds_read_u16 v87, v149 offset:4160
	ds_read_u16 v88, v149 offset:4416
	ds_read_u16 v89, v149 offset:4672
	ds_read_u16 v92, v149 offset:4928
	ds_read_u16 v90, v149 offset:5184
	ds_read_u16 v93, v149 offset:5440
	ds_read_u16 v91, v149 offset:5696
	ds_read_u16 v94, v149 offset:5952
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v89, v92, v89, s93
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v90, v93, v90, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v91, v94, v91, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[50:65], v[88:91], v[66:69], v[50:65]
	ds_read_u16 v87, v149 offset:4224
	ds_read_u16 v88, v149 offset:4480
	ds_read_u16 v89, v149 offset:4736
	ds_read_u16 v92, v149 offset:4992
	ds_read_u16 v90, v149 offset:5248
	ds_read_u16 v93, v149 offset:5504
	ds_read_u16 v91, v149 offset:5760
	ds_read_u16 v94, v149 offset:6016
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v89, v92, v89, s93
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v90, v93, v90, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v91, v94, v91, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[34:49], v[88:91], v[66:69], v[34:49]
	ds_read_u16 v87, v149 offset:4288
	ds_read_u16 v88, v149 offset:4544
	ds_read_u16 v89, v149 offset:4800
	ds_read_u16 v92, v149 offset:5056
	ds_read_u16 v90, v149 offset:5312
	ds_read_u16 v93, v149 offset:5568
	ds_read_u16 v91, v149 offset:5824
	ds_read_u16 v94, v149 offset:6080
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v89, v92, v89, s93
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v90, v93, v90, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v91, v94, v91, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[18:33], v[88:91], v[66:69], v[18:33]
	v_cvt_pk_bf16_f32 v69, v86, v85
	v_cvt_pk_bf16_f32 v68, v84, v83
	v_cvt_pk_bf16_f32 v67, v82, v81
	v_cvt_pk_bf16_f32 v66, v80, v79
	ds_read_u16 v79, v149 offset:8192
	ds_read_u16 v80, v149 offset:8448
	ds_read_u16 v81, v149 offset:8704
	ds_read_u16 v84, v149 offset:8960
	ds_read_u16 v82, v149 offset:9216
	ds_read_u16 v85, v149 offset:9472
	ds_read_u16 v83, v149 offset:9728
	ds_read_u16 v86, v149 offset:9984
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v81, v84, v81, s93
	v_perm_b32 v80, v80, v79, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v82, v85, v82, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v83, v86, v83, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[2:17], v[80:83], v[66:69], v[2:17]
	ds_read_u16 v79, v149 offset:8256
	ds_read_u16 v80, v149 offset:8512
	ds_read_u16 v81, v149 offset:8768
	ds_read_u16 v84, v149 offset:9024
	ds_read_u16 v82, v149 offset:9280
	ds_read_u16 v85, v149 offset:9536
	ds_read_u16 v83, v149 offset:9792
	ds_read_u16 v86, v149 offset:10048
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v81, v84, v81, s93
	v_perm_b32 v80, v80, v79, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v82, v85, v82, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v83, v86, v83, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[50:65], v[80:83], v[66:69], v[50:65]
	ds_read_u16 v79, v149 offset:8320
	ds_read_u16 v80, v149 offset:8576
	ds_read_u16 v81, v149 offset:8832
	ds_read_u16 v84, v149 offset:9088
	ds_read_u16 v82, v149 offset:9344
	ds_read_u16 v85, v149 offset:9600
	ds_read_u16 v83, v149 offset:9856
	ds_read_u16 v86, v149 offset:10112
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v81, v84, v81, s93
	v_perm_b32 v80, v80, v79, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v82, v85, v82, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v83, v86, v83, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[34:49], v[80:83], v[66:69], v[34:49]
	ds_read_u16 v79, v149 offset:8384
	ds_read_u16 v80, v149 offset:8640
	ds_read_u16 v81, v149 offset:8896
	ds_read_u16 v84, v149 offset:9152
	ds_read_u16 v82, v149 offset:9408
	ds_read_u16 v85, v149 offset:9664
	ds_read_u16 v83, v149 offset:9920
	ds_read_u16 v86, v149 offset:10176
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v81, v84, v81, s93
	v_perm_b32 v80, v80, v79, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v82, v85, v82, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v83, v86, v83, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[18:33], v[80:83], v[66:69], v[18:33]
	v_cvt_pk_bf16_f32 v69, v78, v77
	v_cvt_pk_bf16_f32 v68, v76, v75
	v_cvt_pk_bf16_f32 v67, v74, v73
	v_cvt_pk_bf16_f32 v66, v72, v71
	ds_read_u16 v71, v149 offset:12288
	ds_read_u16 v72, v149 offset:12544
	ds_read_u16 v73, v149 offset:12800
	ds_read_u16 v76, v149 offset:13056
	ds_read_u16 v74, v149 offset:13312
	ds_read_u16 v77, v149 offset:13568
	ds_read_u16 v75, v149 offset:13824
	ds_read_u16 v78, v149 offset:14080
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v73, v76, v73, s93
	v_perm_b32 v72, v72, v71, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v74, v77, v74, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v78, v75, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[2:17], v[72:75], v[66:69], v[2:17]
	ds_read_u16 v71, v149 offset:12352
	ds_read_u16 v72, v149 offset:12608
	ds_read_u16 v73, v149 offset:12864
	ds_read_u16 v76, v149 offset:13120
	ds_read_u16 v74, v149 offset:13376
	ds_read_u16 v77, v149 offset:13632
	ds_read_u16 v75, v149 offset:13888
	ds_read_u16 v78, v149 offset:14144
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v73, v76, v73, s93
	v_perm_b32 v72, v72, v71, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v74, v77, v74, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v78, v75, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[50:65], v[72:75], v[66:69], v[50:65]
	ds_read_u16 v71, v149 offset:12416
	ds_read_u16 v72, v149 offset:12672
	ds_read_u16 v73, v149 offset:12928
	ds_read_u16 v76, v149 offset:13184
	ds_read_u16 v74, v149 offset:13440
	ds_read_u16 v77, v149 offset:13696
	ds_read_u16 v75, v149 offset:13952
	ds_read_u16 v78, v149 offset:14208
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v73, v76, v73, s93
	v_perm_b32 v72, v72, v71, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v74, v77, v74, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v78, v75, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[34:49], v[72:75], v[66:69], v[34:49]
	ds_read_u16 v71, v149 offset:12480
	ds_read_u16 v72, v149 offset:12736
	ds_read_u16 v73, v149 offset:12992
	ds_read_u16 v76, v149 offset:13248
	ds_read_u16 v74, v149 offset:13504
	ds_read_u16 v77, v149 offset:13760
	ds_read_u16 v75, v149 offset:14016
	ds_read_u16 v78, v149 offset:14272
	s_waitcnt lgkmcnt(4)
	v_perm_b32 v73, v76, v73, s93
	v_perm_b32 v72, v72, v71, s93
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v74, v77, v74, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v78, v75, s93
	s_nop 1
	v_mfma_f32_32x32x16_bf16 v[18:33], v[72:75], v[66:69], v[18:33]
	s_cbranch_vccnz .LBB0_7
	v_mov_b32_e32 v118, v70
.LBB0_9:
	v_cmp_gt_i32_e32 vcc, s81, v115
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_12
	v_div_scale_f32 v0, s[6:7], v122, v122, 1.0
	v_rcp_f32_e32 v1, v0
	s_load_dwordx2 s[4:5], s[0:1], 0x90
	s_load_dword s2, s[0:1], 0xa8
	s_load_dword s8, s[0:1], 0xb0
	s_load_dword s9, s[0:1], 0xb8
	s_mov_b32 s7, 0x27000
	s_waitcnt lgkmcnt(0)
	s_and_b32 s5, s5, 0xffff
	v_fma_f32 v66, -v0, v1, 1.0
	v_fmac_f32_e32 v1, v66, v1
	v_div_scale_f32 v66, vcc, 1.0, v122, 1.0
	v_mul_f32_e32 v67, v66, v1
	v_fma_f32 v68, -v0, v67, v66
	v_fmac_f32_e32 v67, v68, v1
	v_fma_f32 v0, -v0, v67, v66
	v_div_fmas_f32 v0, v0, v1, v67
	v_div_fixup_f32 v0, v0, v122, 1.0
	v_cmp_lt_f32_e32 vcc, 0, v122
	s_mul_i32 s2, s2, s33
	s_mul_i32 s9, s9, s3
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_mul_lo_u32 v1, s8, v98
	s_add_i32 s2, s2, s9
	v_add_u32_e32 v1, s2, v1
	v_pk_mul_f32 v[2:3], v[2:3], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[0:1] op_sel_hi:[1,0]
	s_mov_b32 s6, -1
	v_pk_mul_f32 v[6:7], v[6:7], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[0:1] op_sel_hi:[1,0]
	v_cvt_pk_bf16_f32 v5, v4, v5
	v_cvt_pk_bf16_f32 v4, v2, v3
	v_lshl_add_u32 v2, v1, 1, v113
	v_pk_mul_f32 v[10:11], v[10:11], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[0:1] op_sel_hi:[1,0]
	buffer_store_dwordx2 v[4:5], v2, s[4:7], 0 offen
	v_cvt_pk_bf16_f32 v3, v8, v9
	v_cvt_pk_bf16_f32 v2, v6, v7
	v_add_lshl_u32 v66, v1, v100, 1
	v_pk_mul_f32 v[14:15], v[14:15], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[0:1] op_sel_hi:[1,0]
	buffer_store_dwordx2 v[2:3], v66, s[4:7], 0 offen offset:16
	v_cvt_pk_bf16_f32 v3, v12, v13
	v_cvt_pk_bf16_f32 v2, v10, v11
	buffer_store_dwordx2 v[2:3], v66, s[4:7], 0 offen offset:32
	v_cvt_pk_bf16_f32 v3, v16, v17
	v_cvt_pk_bf16_f32 v2, v14, v15
	buffer_store_dwordx2 v[2:3], v66, s[4:7], 0 offen offset:48
	v_pk_mul_f32 v[2:3], v[62:63], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[64:65], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[58:59], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[60:61], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[54:55], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[56:57], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[50:51], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[52:53], v[0:1] op_sel_hi:[1,0]
	v_cvt_pk_bf16_f32 v13, v12, v13
	v_cvt_pk_bf16_f32 v12, v10, v11
	v_cvt_pk_bf16_f32 v9, v8, v9
	v_cvt_pk_bf16_f32 v8, v6, v7
	v_cvt_pk_bf16_f32 v5, v4, v5
	v_cvt_pk_bf16_f32 v4, v2, v3
	v_cvt_pk_bf16_f32 v17, v16, v17
	v_cvt_pk_bf16_f32 v16, v14, v15
	buffer_store_dwordx2 v[12:13], v66, s[4:7], 0 offen offset:80
	buffer_store_dwordx2 v[8:9], v66, s[4:7], 0 offen offset:96
	buffer_store_dwordx2 v[4:5], v66, s[4:7], 0 offen offset:112
	v_pk_mul_f32 v[2:3], v[46:47], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[48:49], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[42:43], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[44:45], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[38:39], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[40:41], v[0:1] op_sel_hi:[1,0]
	buffer_store_dwordx2 v[16:17], v66, s[4:7], 0 offen offset:64
	v_pk_mul_f32 v[14:15], v[34:35], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[36:37], v[0:1] op_sel_hi:[1,0]
	v_cvt_pk_bf16_f32 v13, v12, v13
	v_cvt_pk_bf16_f32 v12, v10, v11
	v_cvt_pk_bf16_f32 v9, v8, v9
	v_cvt_pk_bf16_f32 v8, v6, v7
	v_cvt_pk_bf16_f32 v5, v4, v5
	v_cvt_pk_bf16_f32 v4, v2, v3
	v_cvt_pk_bf16_f32 v17, v16, v17
	v_cvt_pk_bf16_f32 v16, v14, v15
	buffer_store_dwordx2 v[12:13], v66, s[4:7], 0 offen offset:144
	buffer_store_dwordx2 v[8:9], v66, s[4:7], 0 offen offset:160
	buffer_store_dwordx2 v[4:5], v66, s[4:7], 0 offen offset:176
	v_pk_mul_f32 v[2:3], v[30:31], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[32:33], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[26:27], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[28:29], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[22:23], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[24:25], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[18:19], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[20:21], v[0:1] op_sel_hi:[1,0]
	buffer_store_dwordx2 v[16:17], v66, s[4:7], 0 offen offset:128
	v_cvt_pk_bf16_f32 v1, v0, v1
	v_cvt_pk_bf16_f32 v0, v14, v15
	buffer_store_dwordx2 v[0:1], v66, s[4:7], 0 offen offset:192
	v_cvt_pk_bf16_f32 v1, v12, v13
	v_cvt_pk_bf16_f32 v0, v10, v11
	buffer_store_dwordx2 v[0:1], v66, s[4:7], 0 offen offset:208
	v_cvt_pk_bf16_f32 v1, v8, v9
	v_cvt_pk_bf16_f32 v0, v6, v7
	buffer_store_dwordx2 v[0:1], v66, s[4:7], 0 offen offset:224
	v_cvt_pk_bf16_f32 v1, v4, v5
	v_cvt_pk_bf16_f32 v0, v2, v3
	buffer_store_dwordx2 v[0:1], v66, s[4:7], 0 offen offset:240
	v_cmp_gt_u32_e64 s[4:5], 32, v123
	s_and_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_12
	s_mov_b32 s2, 0x800000
	v_cmp_gt_f32_e64 s[4:5], s2, v122
	v_mov_b32_e32 v0, 0x42000000
	s_nop 0
	v_cndmask_b32_e64 v1, 0, 32, s[4:5]
	v_ldexp_f32 v1, v122, v1
	v_cndmask_b32_e64 v0, 0, v0, s[4:5]
	v_log_f32_e32 v1, v1
	s_load_dwordx2 s[4:5], s[0:1], 0xc0
	s_load_dword s2, s[0:1], 0xd4
	s_load_dword s8, s[0:1], 0xdc
	v_sub_f32_e32 v0, v1, v0
	v_add_f32_e32 v0, v118, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s2, s33
	s_mul_i32 s8, s8, s3
	v_mul_f32_e32 v0, 0x3f317218, v0
	v_mov_b32_e32 v1, 0xff800000
	s_add_i32 s0, s0, s8
	v_cndmask_b32_e32 v0, v1, v0, vcc
	s_and_b32 s5, s5, 0xffff
	v_add_lshl_u32 v1, v98, s0, 2
	buffer_store_dword v0, v1, s[4:7], 0 offen
.LBB0_12:
	s_endpgm
.Lfunc_end0:
	.size	kernel_0, .Lfunc_end0-kernel_0
	.section	.rodata,"a",@progbits
	.p2align	6, 0x0
	.amdhsa_kernel kernel_0
		.amdhsa_group_segment_fixed_size 32768
		.amdhsa_private_segment_fixed_size 0
		.amdhsa_kernarg_size 936
		.amdhsa_user_sgpr_count 2
		.amdhsa_user_sgpr_dispatch_ptr 0
		.amdhsa_user_sgpr_queue_ptr 0
		.amdhsa_user_sgpr_kernarg_segment_ptr 1
		.amdhsa_user_sgpr_dispatch_id 0
		.amdhsa_user_sgpr_kernarg_preload_length 0
		.amdhsa_user_sgpr_kernarg_preload_offset 0
		.amdhsa_user_sgpr_private_segment_size 0
		.amdhsa_uses_dynamic_stack 0
		.amdhsa_enable_private_segment 0
		.amdhsa_system_sgpr_workgroup_id_x 1
		.amdhsa_system_sgpr_workgroup_id_y 1
		.amdhsa_system_sgpr_workgroup_id_z 1
		.amdhsa_system_sgpr_workgroup_info 0
		.amdhsa_system_vgpr_workitem_id 0
		.amdhsa_next_free_vgpr 212
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 212
		.amdhsa_reserve_vcc 1
		.amdhsa_float_round_mode_32 0
		.amdhsa_float_round_mode_16_64 0
		.amdhsa_float_denorm_mode_32 3
		.amdhsa_float_denorm_mode_16_64 3
		.amdhsa_dx10_clamp 1
		.amdhsa_ieee_mode 1
		.amdhsa_fp16_overflow 0
		.amdhsa_tg_split 0
		.amdhsa_exception_fp_ieee_invalid_op 0
		.amdhsa_exception_fp_denorm_src 0
		.amdhsa_exception_fp_ieee_div_zero 0
		.amdhsa_exception_fp_ieee_overflow 0
		.amdhsa_exception_fp_ieee_underflow 0
		.amdhsa_exception_fp_ieee_inexact 0
		.amdhsa_exception_int_div_zero 0
	.end_amdhsa_kernel
	.text

	.set .Lkernel_0.num_vgpr, 212
	.set .Lkernel_0.num_agpr, 0
	.set .Lkernel_0.numbered_sgpr, 96
	.set .Lkernel_0.num_named_barrier, 0
	.set .Lkernel_0.private_seg_size, 0
	.set .Lkernel_0.uses_vcc, 1
	.set .Lkernel_0.uses_flat_scratch, 0
	.set .Lkernel_0.has_dyn_sized_stack, 0
	.set .Lkernel_0.has_recursion, 0
	.set .Lkernel_0.has_indirect_call, 0
	.p2alignl 6, 3212836864
	.fill 256, 4, 3212836864
	.section	.AMDGPU.gpr_maximums,"",@progbits
	.set amdgpu.max_num_vgpr, 0
	.set amdgpu.max_num_agpr, 0
	.set amdgpu.max_num_sgpr, 0
	.set amdgpu.max_num_named_barrier, 0
	.text
	.section	".note.GNU-stack","",@progbits
	.amdgpu_metadata
---
amdhsa.kernels:
  - .agpr_count:     0
    .args:
      - .address_space:  global
        .offset:         0
        .size:           8
        .value_kind:     global_buffer
      - .offset:         8
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         48
        .size:           8
        .value_kind:     global_buffer
      - .offset:         56
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         96
        .size:           8
        .value_kind:     global_buffer
      - .offset:         104
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         144
        .size:           8
        .value_kind:     global_buffer
      - .offset:         152
        .size:           40
        .value_kind:     by_value
      - .address_space:  global
        .offset:         192
        .size:           8
        .value_kind:     global_buffer
      - .offset:         200
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         232
        .size:           8
        .value_kind:     global_buffer
      - .offset:         240
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         272
        .size:           8
        .value_kind:     global_buffer
      - .offset:         280
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         312
        .size:           8
        .value_kind:     global_buffer
      - .offset:         320
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         352
        .size:           8
        .value_kind:     global_buffer
      - .offset:         360
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         392
        .size:           8
        .value_kind:     global_buffer
      - .offset:         400
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         432
        .size:           8
        .value_kind:     global_buffer
      - .offset:         440
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         472
        .size:           8
        .value_kind:     global_buffer
      - .offset:         480
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         512
        .size:           8
        .value_kind:     global_buffer
      - .offset:         520
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         552
        .size:           8
        .value_kind:     global_buffer
      - .offset:         560
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         592
        .size:           8
        .value_kind:     global_buffer
      - .offset:         600
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         632
        .size:           8
        .value_kind:     global_buffer
      - .offset:         640
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         672
        .size:           8
        .value_kind:     global_buffer
      - .offset:         680
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         712
        .size:           8
        .value_kind:     global_buffer
      - .offset:         720
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         752
        .size:           8
        .value_kind:     global_buffer
      - .offset:         760
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         792
        .size:           8
        .value_kind:     global_buffer
      - .offset:         800
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         832
        .size:           8
        .value_kind:     global_buffer
      - .offset:         840
        .size:           28
        .value_kind:     by_value
      - .address_space:  global
        .offset:         872
        .size:           8
        .value_kind:     global_buffer
      - .offset:         880
        .size:           28
        .value_kind:     by_value
      - .offset:         908
        .size:           4
        .value_kind:     by_value
      - .offset:         912
        .size:           4
        .value_kind:     by_value
      - .offset:         916
        .size:           4
        .value_kind:     by_value
      - .offset:         920
        .size:           4
        .value_kind:     by_value
      - .offset:         924
        .size:           4
        .value_kind:     by_value
      - .offset:         928
        .size:           4
        .value_kind:     by_value
      - .offset:         932
        .size:           4
        .value_kind:     by_value
    .group_segment_fixed_size: 32768
    .kernarg_segment_align: 8
    .kernarg_segment_size: 936
    .max_flat_workgroup_size: 256
    .name:           kernel_0
    .private_segment_fixed_size: 0
    .reqd_workgroup_size:
      - 256
      - 1
      - 1
    .sgpr_count:     102
    .sgpr_spill_count: 0
    .symbol:         kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     212
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata

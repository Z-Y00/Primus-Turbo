	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx950"
	.amdhsa_code_object_version 6
	.text
	.globl	kernel_0
	.p2align	8
	.type	kernel_0,@function
kernel_0:
	s_load_dwordx4 s[76:79], s[0:1], 0x390
	s_lshl_b32 s2, s2, 7
	s_waitcnt lgkmcnt(0)
	s_cmp_ge_i32 s2, s77
	s_cbranch_scc1 .LBB0_12
	s_ashr_i32 s5, s3, 31
	s_lshr_b32 s5, s5, 29
	s_add_i32 s5, s3, s5
	s_ashr_i32 s12, s5, 3
	s_and_b32 s5, s5, -8
	s_cmp_lg_u32 s3, s5
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s3, 0
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[6:7], s[10:11], s[6:7]
	s_subb_u32 s17, s12, 0
	s_abs_i32 s5, s76
	v_cvt_f32_u32_e32 v2, s5
	s_sub_i32 s13, 0, s5
	s_load_dwordx8 s[68:75], s[0:1], 0x48
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s14, s[0:1], 0x18
	s_load_dword s15, s[0:1], 0x20
	s_load_dword s16, s[0:1], 0x28
	s_load_dwordx2 s[80:81], s[0:1], 0x30
	s_abs_i32 s7, s4
	v_rcp_f32_e32 v2, v2
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[84:85], s[74:75]
	s_xor_b32 s6, s76, s4
	s_and_b32 s81, s81, 0xffff
	v_mul_f32_e32 v2, 0x4f7ffffe, v2
	v_cvt_u32_f32_e32 v2, v2
	s_and_b32 s85, s85, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_ashr_i32 s12, s6, 31
	v_readfirstlane_b32 s18, v2
	s_mul_i32 s13, s13, s18
	s_mul_hi_u32 s13, s18, s13
	s_add_i32 s18, s18, s13
	s_mul_hi_u32 s13, s7, s18
	s_mul_i32 s18, s13, s5
	s_sub_i32 s7, s7, s18
	s_add_i32 s18, s13, 1
	s_sub_i32 s19, s7, s5
	s_cmp_ge_u32 s7, s5
	s_cselect_b32 s13, s18, s13
	s_cselect_b32 s7, s19, s7
	s_add_i32 s18, s13, 1
	s_cmp_ge_u32 s7, s5
	s_cselect_b32 s5, s18, s13
	s_xor_b32 s13, s5, s12
	s_sub_i32 s5, s13, s12
	s_mul_i32 s5, s5, s76
	s_cmp_lg_u32 s4, s5
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[4:5], s[6:7], s[4:5]
	s_subb_u32 s33, s13, s12
	s_add_i32 s6, s78, 63
	s_ashr_i32 s4, s6, 31
	s_lshr_b32 s4, s4, 26
	s_add_i32 s4, s6, s4
	s_ashr_i32 s12, s4, 6
	s_andn2_b32 s4, s4, 63
	s_cmp_lg_u32 s6, s4
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s6, 0
	s_cselect_b64 s[6:7], -1, 0
	s_and_b64 s[4:5], s[6:7], s[4:5]
	s_subb_u32 s6, s12, 0
	s_add_i32 s4, s2, 0x80
	s_min_i32 s4, s4, s77
	s_sub_i32 s21, s78, s77
	s_add_i32 s4, s21, s4
	s_max_i32 s4, s4, 0
	s_add_i32 s7, s4, 63
	s_ashr_i32 s4, s7, 31
	s_lshr_b32 s4, s4, 26
	s_add_i32 s4, s7, s4
	s_ashr_i32 s18, s4, 6
	s_andn2_b32 s4, s4, 63
	s_cmp_lg_u32 s7, s4
	s_cselect_b64 s[4:5], -1, 0
	s_cmp_lt_i32 s7, 0
	s_cselect_b64 s[12:13], -1, 0
	v_lshrrev_b32_e32 v4, 1, v0
	v_and_b32_e32 v3, 31, v0
	s_and_b64 s[4:5], s[12:13], s[4:5]
	v_and_b32_e32 v2, 0x60, v4
	s_subb_u32 s12, s18, 0
	v_or3_b32 v122, s2, v2, v3
	s_add_i32 s4, s77, -1
	v_min_i32_e32 v98, s4, v122
	s_mul_i32 s4, s14, s33
	s_mul_i32 s16, s16, s3
	v_bfe_u32 v1, v0, 5, 1
	v_mul_lo_u32 v2, s15, v98
	s_add_i32 s4, s4, s16
	s_mov_b32 s87, 0x27000
	s_mov_b32 s86, -1
	v_add_u32_e32 v2, s4, v2
	v_lshlrev_b32_e32 v5, 4, v1
	v_lshlrev_b32_e32 v99, 3, v1
	s_mov_b32 s10, s86
	s_mov_b32 s11, s87
	v_lshl_add_u32 v5, v2, 1, v5
	v_add_lshl_u32 v2, v2, v99, 1
	buffer_load_dwordx4 v[160:163], v5, s[8:11], 0 offen
	buffer_load_dwordx4 v[164:167], v2, s[8:11], 0 offen offset:32
	buffer_load_dwordx4 v[168:171], v2, s[8:11], 0 offen offset:64
	buffer_load_dwordx4 v[172:175], v2, s[8:11], 0 offen offset:96
	buffer_load_dwordx4 v[176:179], v2, s[8:11], 0 offen offset:128
	buffer_load_dwordx4 v[180:183], v2, s[8:11], 0 offen offset:160
	buffer_load_dwordx4 v[184:187], v2, s[8:11], 0 offen offset:192
	buffer_load_dwordx4 v[188:191], v2, s[8:11], 0 offen offset:224
	s_ashr_i32 s5, s78, 31
	s_lshr_b32 s5, s5, 26
	s_add_i32 s5, s78, s5
	s_min_i32 s8, s6, s12
	s_ashr_i32 s20, s5, 6
	s_andn2_b32 s5, s5, 63
	s_cmp_lg_u32 s78, s5
	s_cselect_b64 s[10:11], -1, 0
	s_cmp_lt_i32 s78, 0
	s_cselect_b64 s[14:15], -1, 0
	s_and_b64 s[14:15], s[14:15], s[10:11]
	s_subb_u32 s5, s20, 0
	s_add_i32 s2, s21, s2
	s_add_i32 s2, s2, 1
	s_max_i32 s2, s2, 0
	s_load_dwordx4 s[88:91], s[0:1], 0x78
	s_load_dwordx2 s[18:19], s[0:1], 0x88
	s_lshr_b32 s10, s2, 6
	v_mov_b32_e32 v8, s10
	v_mov_b32_e32 v9, s8
	v_min3_i32 v8, s5, v8, v9
	v_and_b32_e32 v2, 16, v0
	v_lshlrev_b32_e32 v5, 2, v0
	s_min_i32 s16, s8, 0
	v_readfirstlane_b32 s2, v8
	v_and_or_b32 v6, v5, 12, v2
	v_bfe_u32 v7, v0, 2, 2
	s_max_i32 s74, s2, s16
	v_cmp_gt_i32_e32 vcc, 1, v8
	v_or_b32_e32 v102, v99, v7
	s_movk_i32 s4, 0x60
	v_mov_b32_e32 v2, 0
	s_ashr_i32 s75, s74, 31
	s_and_b64 vcc, exec, vcc
	v_lshrrev_b32_e32 v123, 4, v0
	s_mul_i32 s23, s68, s33
	s_mul_i32 s24, s72, s17
	v_and_b32_e32 v108, 15, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s11, s88, s33
	s_mul_i32 s22, s18, s17
	v_and_b32_e32 v109, 64, v4
	v_and_b32_e32 v111, 64, v0
	v_lshrrev_b32_e32 v110, 3, v0
	v_lshlrev_b32_e32 v106, 7, v3
	v_lshlrev_b32_e32 v107, 3, v0
	v_lshrrev_b32_e32 v103, 3, v6
	v_lshlrev_b32_e32 v104, 1, v7
	v_and_b32_e32 v105, 4, v5
	s_cbranch_vccnz .LBB0_4
	s_movk_i32 s2, 0x1f0
	v_mov_b32_e32 v6, 0x100
	v_bitop3_b32 v6, v0, s2, v6 bitop3:0xc8
	s_movk_i32 s2, 0x2f0
	v_mov_b32_e32 v8, 0x200
	v_bitop3_b32 v8, v0, s2, v8 bitop3:0xc8
	s_movk_i32 s2, 0x3f0
	v_mov_b32_e32 v10, 0x300
	v_and_b32_e32 v3, 0xf0, v0
	v_bitop3_b32 v4, v123, v108, 7 bitop3:0x6c
	v_bitop3_b32 v10, v0, s2, v10 bitop3:0xc8
	v_sub_u32_e32 v11, v111, v109
	v_or_b32_e32 v5, v4, v3
	v_or_b32_e32 v7, v4, v6
	v_or_b32_e32 v9, v4, v8
	v_or_b32_e32 v4, v4, v10
	v_add_u32_e32 v3, v11, v3
	v_and_b32_e32 v12, 6, v110
	v_bitop3_b32 v3, v3, v12, v108 bitop3:0xf6
	v_lshlrev_b32_e32 v116, 4, v4
	v_and_b32_e32 v4, 56, v107
	v_lshlrev_b32_e32 v113, 4, v5
	v_lshlrev_b32_e32 v117, 4, v3
	v_or_b32_e32 v3, v99, v106
	v_bitop3_b32 v5, v99, v4, v106 bitop3:0x36
	v_lshlrev_b32_e32 v121, 1, v5
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
	v_bitop3_b32 v3, v3, v4, s2 bitop3:0x36
	v_lshlrev_b32_e32 v138, 1, v3
	v_xor_b32_e32 v3, v103, v104
	v_mov_b32_e32 v4, 0x4000
	v_lshlrev_b32_e32 v137, 1, v5
	v_lshl_or_b32 v4, v102, 8, v4
	v_lshlrev_b32_e32 v3, 4, v3
	v_lshlrev_b32_e32 v5, 1, v105
	v_or3_b32 v139, v4, v3, v5
	v_bitop3_b32 v3, v103, v104, 4 bitop3:0x36
	v_lshlrev_b32_e32 v3, 4, v3
	v_or3_b32 v140, v4, v3, v5
	v_bitop3_b32 v3, v103, v104, 8 bitop3:0x36
	v_lshlrev_b32_e32 v3, 4, v3
	v_or3_b32 v141, v4, v3, v5
	v_bitop3_b32 v3, v103, v104, 12 bitop3:0x36
	v_lshlrev_b32_e32 v3, 4, v3
	s_ashr_i32 s7, s6, 31
	v_or3_b32 v142, v4, v3, v5
	s_ashr_i32 s13, s12, 31
	v_mov_b64_e32 v[4:5], s[6:7]
	s_ashr_i32 s17, s16, 31
	s_add_i32 s9, s78, -1
	s_add_u32 s25, s23, s24
	s_add_u32 s26, s11, s22
	v_cmp_lt_i64_e32 vcc, s[12:13], v[4:5]
	s_and_b64 s[4:5], vcc, exec
	s_cselect_b32 s2, s13, s7
	s_cselect_b32 s4, s12, s6
	v_add_u32_e32 v6, v11, v6
	v_add_u32_e32 v8, v11, v8
	v_add_u32_e32 v10, v11, v10
	s_and_b32 s2, s4, s2
	v_bitop3_b32 v6, v12, v6, v108 bitop3:0xde
	v_bitop3_b32 v8, v12, v8, v108 bitop3:0xde
	v_bitop3_b32 v10, v12, v10, v108 bitop3:0xde
	v_lshl_or_b32 v143, s2, 6, v123
	v_lshlrev_b32_e32 v112, 3, v108
	v_lshlrev_b32_e32 v114, 4, v7
	v_lshlrev_b32_e32 v115, 4, v9
	v_lshlrev_b32_e32 v118, 4, v6
	v_lshlrev_b32_e32 v119, 4, v8
	v_lshlrev_b32_e32 v120, 4, v10
	s_mov_b32 s18, s79
	s_mov_b32 s19, s79
	v_or_b32_e32 v144, 48, v143
	v_or_b32_e32 v145, 32, v143
	v_or_b32_e32 v146, 16, v143
	v_mov_b32_e32 v124, 0
	v_mov_b32_e32 v147, 0xf149f2ca
	s_mov_b32 s2, 0x3fb8aa3b
	v_mov_b64_e32 v[100:101], s[74:75]
	s_mov_b32 s82, s86
	s_mov_b32 s83, s87
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
	v_min_i32_e32 v66, s9, v143
	v_min_i32_e32 v67, s9, v146
	v_min_i32_e32 v68, s9, v145
	v_min_i32_e32 v69, s9, v144
	v_mul_lo_u32 v70, s70, v66
	v_mul_lo_u32 v71, s70, v67
	v_mul_lo_u32 v72, s70, v68
	v_mul_lo_u32 v73, s70, v69
	v_mul_lo_u32 v66, s90, v66
	v_mul_lo_u32 v67, s90, v67
	v_mul_lo_u32 v68, s90, v68
	v_mul_lo_u32 v69, s90, v69
	v_add_u32_e32 v70, s25, v70
	v_add_u32_e32 v71, s25, v71
	v_add_u32_e32 v72, s25, v72
	v_add_u32_e32 v73, s25, v73
	v_add_u32_e32 v66, s26, v66
	v_add_u32_e32 v67, s26, v67
	v_add_u32_e32 v68, s26, v68
	v_add_u32_e32 v69, s26, v69
	v_add_lshl_u32 v70, v112, v70, 1
	v_add_lshl_u32 v71, v112, v71, 1
	v_add_lshl_u32 v72, v112, v72, 1
	v_add_lshl_u32 v73, v112, v73, 1
	v_add_lshl_u32 v66, v112, v66, 1
	v_add_lshl_u32 v67, v112, v67, 1
	v_add_lshl_u32 v68, v112, v68, 1
	v_add_lshl_u32 v69, v112, v69, 1
	s_barrier
	buffer_load_dwordx4 v[74:77], v70, s[80:83], 0 offen
	buffer_load_dwordx4 v[78:81], v71, s[80:83], 0 offen
	buffer_load_dwordx4 v[82:85], v72, s[80:83], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[70:73], v73, s[80:83], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[86:89], v66, s[84:87], 0 offen
	buffer_load_dwordx4 v[90:93], v67, s[84:87], 0 offen
	buffer_load_dwordx4 v[94:97], v68, s[84:87], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[66:69], v69, s[84:87], 0 offen
	s_add_u32 s16, s16, 1
	s_addc_u32 s17, s17, 0
	v_cmp_lt_i64_e32 vcc, s[16:17], v[100:101]
	v_add_u32_e32 v144, 64, v144
	v_add_u32_e32 v145, 64, v145
	v_add_u32_e32 v146, 64, v146
	v_add_u32_e32 v143, 64, v143
	s_and_b64 vcc, exec, vcc
	s_waitcnt vmcnt(7)
	ds_write_b128 v113, v[74:77]
	s_waitcnt vmcnt(6)
	ds_write_b128 v114, v[78:81]
	s_waitcnt vmcnt(5)
	ds_write_b128 v115, v[82:85]
	s_waitcnt vmcnt(4)
	ds_write_b128 v116, v[70:73]
	s_waitcnt vmcnt(3)
	ds_write_b128 v117, v[86:89] offset:16384
	s_waitcnt vmcnt(2)
	ds_write_b128 v118, v[90:93] offset:16384
	s_waitcnt vmcnt(1)
	ds_write_b128 v119, v[94:97] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v120, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[66:69], v121
	ds_read_b128 v[148:151], v121 offset:8192
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[66:69], v[160:163], 0
	ds_read_b64_tr_b16 v[198:199], v141 offset:1024
	ds_read_b64_tr_b16 v[212:213], v141 offset:4096
	ds_read_b64_tr_b16 v[214:215], v141 offset:5120
	ds_read_b64_tr_b16 v[216:217], v142
	ds_read_b64_tr_b16 v[218:219], v142 offset:1024
	ds_read_b64_tr_b16 v[220:221], v142 offset:4096
	ds_read_b64_tr_b16 v[222:223], v142 offset:5120
	s_waitcnt lgkmcnt(7)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[148:151], v[160:163], 0
	ds_read_b128 v[148:151], v125
	ds_read_b128 v[152:155], v126
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[148:151], v[164:167], v[82:97]
	ds_read_b128 v[148:151], v132
	ds_read_b128 v[156:159], v131
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[148:151], v[164:167], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[152:155], v[168:171], v[82:97]
	ds_read_b128 v[148:151], v133
	ds_read_b128 v[152:155], v134
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[148:151], v[168:171], v[66:81]
	ds_read_b128 v[148:151], v127
	ds_read_b128 v[192:195], v128
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[148:151], v[172:175], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[152:155], v[172:175], v[66:81]
	ds_read_b128 v[148:151], v135
	ds_read_b128 v[152:155], v136
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[192:195], v[176:179], v[82:97]
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[148:151], v[176:179], v[66:81]
	ds_read_b128 v[148:151], v129
	ds_read_b128 v[192:195], v130
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[148:151], v[180:183], v[82:97]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[152:155], v[180:183], v[66:81]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[82:97], v[192:195], v[184:187], v[82:97]
	ds_read_b128 v[148:151], v137
	ds_read_b128 v[152:155], v138
	ds_read_b64_tr_b16 v[192:193], v139
	ds_read_b64_tr_b16 v[196:197], v141
	ds_read_b64_tr_b16 v[194:195], v139 offset:1024
	ds_read_b64_tr_b16 v[200:201], v139 offset:4096
	ds_read_b64_tr_b16 v[202:203], v139 offset:5120
	ds_read_b64_tr_b16 v[204:205], v140
	ds_read_b64_tr_b16 v[206:207], v140 offset:1024
	ds_read_b64_tr_b16 v[208:209], v140 offset:4096
	ds_read_b64_tr_b16 v[210:211], v140 offset:5120
	s_waitcnt lgkmcnt(10)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[148:151], v[184:187], v[66:81]
	v_mfma_f32_32x32x16_bf16 v[82:97], v[156:159], v[188:191], v[82:97]
	s_waitcnt lgkmcnt(9)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[152:155], v[188:191], v[66:81]
	s_nop 9
	v_mul_f32_e64 v82, s18, v82
	v_mul_f32_e64 v83, s19, v83
	v_mul_f32_e64 v84, s18, v84
	v_mul_f32_e64 v85, s19, v85
	v_mul_f32_e64 v148, v82, s2
	v_mul_f32_e64 v149, v83, s2
	v_pk_mul_f32 v[84:85], v[84:85], s[2:3] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[4:5], v148, v149
	v_pk_mul_f32 v[86:87], s[18:19], v[86:87]
	v_pk_mul_f32 v[88:89], s[18:19], v[88:89]
	v_pk_mul_f32 v[86:87], v[86:87], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[66:67], s[18:19], v[66:67]
	v_pk_mul_f32 v[88:89], v[88:89], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[150:151], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v149, v148, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v84
	v_pk_mul_f32 v[90:91], s[18:19], v[90:91]
	v_pk_mul_f32 v[92:93], s[18:19], v[92:93]
	v_cndmask_b32_e64 v66, v84, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v85
	v_pk_mul_f32 v[90:91], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[92:93], v[92:93], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v85, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v86
	v_pk_mul_f32 v[94:95], s[18:19], v[94:95]
	v_pk_mul_f32 v[96:97], s[18:19], v[96:97]
	v_cndmask_b32_e64 v66, v86, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v87
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[96:97], v[96:97], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v87, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v88
	v_pk_mul_f32 v[68:69], s[18:19], v[68:69]
	v_pk_mul_f32 v[70:71], s[18:19], v[70:71]
	v_cndmask_b32_e64 v66, v88, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v89
	v_pk_mul_f32 v[152:153], v[68:69], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[70:71], v[70:71], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v89, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v90
	v_pk_mul_f32 v[72:73], s[18:19], v[72:73]
	v_pk_mul_f32 v[74:75], s[18:19], v[74:75]
	v_cndmask_b32_e64 v66, v90, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v91
	v_pk_mul_f32 v[72:73], v[72:73], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[74:75], v[74:75], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v91, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v92
	v_pk_mul_f32 v[76:77], s[18:19], v[76:77]
	v_pk_mul_f32 v[78:79], s[18:19], v[78:79]
	v_cndmask_b32_e64 v66, v92, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v93
	v_pk_mul_f32 v[76:77], v[76:77], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[78:79], v[78:79], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v93, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v94
	v_pk_mul_f32 v[80:81], s[18:19], v[80:81]
	s_nop 0
	v_cndmask_b32_e64 v66, v94, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v95
	v_pk_mul_f32 v[80:81], v[80:81], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v66, v95, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v96
	s_nop 1
	v_cndmask_b32_e64 v66, v96, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v97
	s_nop 1
	v_cndmask_b32_e64 v66, v97, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v150
	s_nop 1
	v_cndmask_b32_e64 v66, v150, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v151
	s_nop 1
	v_cndmask_b32_e64 v66, v151, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v152
	s_nop 1
	v_cndmask_b32_e64 v66, v152, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v153
	s_nop 1
	v_cndmask_b32_e64 v66, v153, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v70
	s_nop 1
	v_cndmask_b32_e64 v66, v70, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v71
	s_nop 1
	v_cndmask_b32_e64 v66, v71, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v72
	s_nop 1
	v_cndmask_b32_e64 v66, v72, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v73
	s_nop 1
	v_cndmask_b32_e64 v66, v73, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v74
	s_nop 1
	v_cndmask_b32_e64 v66, v74, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v75
	s_nop 1
	v_cndmask_b32_e64 v66, v75, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v76
	s_nop 1
	v_cndmask_b32_e64 v66, v76, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v77
	s_nop 1
	v_cndmask_b32_e64 v66, v77, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v78
	s_nop 1
	v_cndmask_b32_e64 v66, v78, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v79
	s_nop 1
	v_cndmask_b32_e64 v66, v79, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v80
	s_nop 1
	v_cndmask_b32_e64 v66, v80, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v81
	s_nop 1
	v_cndmask_b32_e64 v66, v81, v66, s[4:5]
	v_mov_b32_e32 v67, v66
	v_mov_b32_e32 v68, v66
	s_nop 1
	v_permlane32_swap_b32_e32 v67, v68
	v_cmp_eq_u32_e64 s[4:5], v67, v66
	s_nop 1
	v_cndmask_b32_e64 v67, v67, v68, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v66, v67
	s_nop 1
	v_cndmask_b32_e64 v66, v67, v66, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], v147, v66
	s_nop 1
	v_cndmask_b32_e64 v82, v66, v147, s[4:5]
	v_sub_f32_e32 v83, v147, v82
	v_pk_add_f32 v[66:67], v[148:149], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[68:69], v[84:85], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[84:85], v[86:87], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[86:87], v[88:89], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[88:89], v[90:91], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[90:91], v[92:93], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[92:93], v[94:95], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[94:95], v[96:97], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_exp_f32_e32 v96, v83
	v_exp_f32_e32 v83, v66
	v_exp_f32_e32 v97, v67
	v_exp_f32_e32 v148, v68
	v_exp_f32_e32 v149, v69
	v_exp_f32_e32 v154, v84
	v_exp_f32_e32 v155, v85
	v_exp_f32_e32 v156, v86
	v_exp_f32_e32 v157, v87
	v_pk_mul_f32 v[16:17], v[16:17], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[96:97] op_sel_hi:[1,0]
	v_cvt_pk_bf16_f32 v69, v156, v157
	v_cvt_pk_bf16_f32 v68, v154, v155
	v_cvt_pk_bf16_f32 v67, v148, v149
	v_cvt_pk_bf16_f32 v66, v83, v97
	v_pk_mul_f32 v[64:65], v[64:65], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[62:63], v[62:63], v[96:97] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[192:195], v[66:69], v[2:17]
	v_mul_f32_e64 v60, v60, v96
	v_mul_f32_e64 v61, v61, v96
	v_mul_f32_e64 v58, v58, v96
	v_mul_f32_e64 v59, v59, v96
	v_mul_f32_e64 v56, v56, v96
	v_mul_f32_e64 v57, v57, v96
	v_pk_mul_f32 v[54:55], v[54:55], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[52:53], v[52:53], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[50:51], v[50:51], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[48:49], v[48:49], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[46:47], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[42:43], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[40:41], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[38:39], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[36:37], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[96:97] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[96:97] op_sel_hi:[1,0]
	v_exp_f32_e32 v88, v88
	v_exp_f32_e32 v90, v90
	v_exp_f32_e32 v92, v92
	v_exp_f32_e32 v94, v94
	v_exp_f32_e32 v95, v95
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[204:207], v[66:69], v[50:65]
	v_exp_f32_e32 v93, v93
	v_exp_f32_e32 v91, v91
	v_exp_f32_e32 v89, v89
	v_pk_add_f32 v[84:85], v[150:151], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[86:87], v[152:153], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[70:71], v[70:71], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[72:73], v[72:73], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[196:199], v[66:69], v[34:49]
	v_exp_f32_e32 v84, v84
	v_exp_f32_e32 v86, v86
	v_exp_f32_e32 v150, v70
	v_exp_f32_e32 v151, v72
	v_exp_f32_e32 v152, v73
	v_exp_f32_e32 v153, v71
	v_exp_f32_e32 v87, v87
	v_mfma_f32_32x32x16_bf16 v[18:33], v[216:219], v[66:69], v[18:33]
	v_cvt_pk_bf16_f32 v69, v94, v95
	v_cvt_pk_bf16_f32 v68, v92, v93
	v_cvt_pk_bf16_f32 v67, v90, v91
	v_cvt_pk_bf16_f32 v66, v88, v89
	v_exp_f32_e32 v85, v85
	v_pk_add_f32 v[72:73], v[76:77], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[76:77], v[80:81], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[200:203], v[66:69], v[2:17]
	ds_read_b64_tr_b16 v[192:193], v140 offset:8192
	ds_read_b64_tr_b16 v[194:195], v140 offset:9216
	ds_read_b64_tr_b16 v[196:197], v139 offset:8192
	ds_read_b64_tr_b16 v[198:199], v139 offset:9216
	ds_read_b64_tr_b16 v[200:201], v139 offset:12288
	ds_read_b64_tr_b16 v[202:203], v139 offset:13312
	v_add_f32_e32 v80, v83, v97
	v_pk_add_f32 v[70:71], v[74:75], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[74:75], v[78:79], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_exp_f32_e32 v78, v70
	v_exp_f32_e32 v79, v71
	v_exp_f32_e32 v72, v72
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[208:211], v[66:69], v[50:65]
	ds_read_b64_tr_b16 v[204:205], v140 offset:12288
	ds_read_b64_tr_b16 v[206:207], v140 offset:13312
	ds_read_b64_tr_b16 v[208:209], v141 offset:8192
	ds_read_b64_tr_b16 v[210:211], v141 offset:9216
	ds_read_b64_tr_b16 v[216:217], v141 offset:12288
	v_exp_f32_e32 v73, v73
	v_exp_f32_e32 v74, v74
	v_exp_f32_e32 v76, v76
	v_exp_f32_e32 v77, v77
	v_exp_f32_e32 v75, v75
	v_mul_f32_e32 v81, v124, v96
	v_mfma_f32_32x32x16_bf16 v[34:49], v[212:215], v[66:69], v[34:49]
	v_cvt_pk_bf16_f32 v71, v76, v77
	v_cvt_pk_bf16_f32 v70, v74, v75
	v_mov_b32_e32 v147, v82
	v_mfma_f32_32x32x16_bf16 v[18:33], v[220:223], v[66:69], v[18:33]
	v_cvt_pk_bf16_f32 v69, v151, v152
	v_cvt_pk_bf16_f32 v68, v150, v153
	v_cvt_pk_bf16_f32 v67, v86, v87
	v_cvt_pk_bf16_f32 v66, v84, v85
	s_waitcnt lgkmcnt(7)
	s_nop 0
	v_mfma_f32_32x32x16_bf16 v[2:17], v[196:199], v[66:69], v[2:17]
	ds_read_b64_tr_b16 v[218:219], v141 offset:13312
	ds_read_b64_tr_b16 v[196:197], v142 offset:8192
	ds_read_b64_tr_b16 v[198:199], v142 offset:9216
	ds_read_b64_tr_b16 v[212:213], v142 offset:12288
	ds_read_b64_tr_b16 v[214:215], v142 offset:13312
	v_mfma_f32_32x32x16_bf16 v[50:65], v[192:195], v[66:69], v[50:65]
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[208:211], v[66:69], v[34:49]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[196:199], v[66:69], v[18:33]
	v_add_f32_e32 v66, v148, v80
	v_add_f32_e32 v66, v149, v66
	v_add_f32_e32 v66, v154, v66
	v_add_f32_e32 v66, v155, v66
	v_add_f32_e32 v66, v156, v66
	v_add_f32_e32 v66, v157, v66
	v_add_f32_e32 v66, v88, v66
	v_add_f32_e32 v66, v89, v66
	v_add_f32_e32 v66, v90, v66
	v_add_f32_e32 v66, v91, v66
	v_add_f32_e32 v66, v92, v66
	v_add_f32_e32 v66, v93, v66
	v_add_f32_e32 v66, v94, v66
	v_add_f32_e32 v66, v95, v66
	v_add_f32_e32 v66, v84, v66
	v_add_f32_e32 v66, v85, v66
	v_add_f32_e32 v66, v86, v66
	v_add_f32_e32 v66, v87, v66
	v_add_f32_e32 v66, v150, v66
	v_add_f32_e32 v66, v153, v66
	v_add_f32_e32 v66, v151, v66
	v_add_f32_e32 v66, v152, v66
	v_add_f32_e32 v66, v78, v66
	v_add_f32_e32 v66, v79, v66
	v_add_f32_e32 v66, v72, v66
	v_add_f32_e32 v66, v73, v66
	v_add_f32_e32 v66, v74, v66
	v_cvt_pk_bf16_f32 v69, v72, v73
	v_cvt_pk_bf16_f32 v68, v78, v79
	v_add_f32_e32 v66, v75, v66
	v_add_f32_e32 v66, v76, v66
	v_mfma_f32_32x32x16_bf16 v[2:17], v[200:203], v[68:71], v[2:17]
	v_add_f32_e32 v66, v77, v66
	v_mov_b32_e32 v67, v66
	v_mfma_f32_32x32x16_bf16 v[50:65], v[204:207], v[68:71], v[50:65]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[216:219], v[68:71], v[34:49]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[212:215], v[68:71], v[18:33]
	v_mov_b32_e32 v68, v66
	s_nop 1
	v_permlane32_swap_b32_e32 v67, v68
	v_cmp_eq_u32_e64 s[4:5], v67, v66
	s_nop 1
	v_cndmask_b32_e64 v67, v67, v68, s[4:5]
	v_add_f32_e32 v66, v66, v67
	v_add_f32_e32 v124, v81, v66
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
	v_mov_b32_e32 v82, 0xf149f2ca
	v_mov_b32_e32 v124, 0
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
	v_and_b32_e32 v69, 63, v0
	s_cmp_ge_i32 s74, s8
	v_lshlrev_b32_e32 v84, 2, v1
	s_cbranch_scc1 .LBB0_9
	s_movk_i32 s2, 0x1f0
	v_mov_b32_e32 v68, 0x100
	v_bitop3_b32 v68, v0, s2, v68 bitop3:0xc8
	s_movk_i32 s2, 0x2f0
	v_mov_b32_e32 v70, 0x200
	v_bitop3_b32 v70, v0, s2, v70 bitop3:0xc8
	s_movk_i32 s2, 0x3f0
	v_mov_b32_e32 v72, 0x300
	v_and_b32_e32 v1, 0xf0, v0
	v_bitop3_b32 v66, v123, v108, 7 bitop3:0x6c
	v_bitop3_b32 v0, v0, s2, v72 bitop3:0xc8
	v_sub_u32_e32 v72, v111, v109
	v_accvgpr_write_b32 a1, v69
	v_or_b32_e32 v67, v66, v1
	v_or_b32_e32 v69, v66, v68
	v_or_b32_e32 v71, v66, v70
	v_or_b32_e32 v66, v66, v0
	v_and_b32_e32 v73, 6, v110
	v_add_u32_e32 v0, v72, v0
	v_bitop3_b32 v0, v73, v0, v108 bitop3:0xde
	v_lshlrev_b32_e32 v125, 4, v67
	v_and_b32_e32 v67, 56, v107
	v_lshlrev_b32_e32 v128, 4, v66
	v_lshlrev_b32_e32 v132, 4, v0
	v_or_b32_e32 v66, v99, v106
	v_bitop3_b32 v0, v99, v67, v106 bitop3:0x36
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
	v_add_u32_e32 v68, v72, v68
	v_lshlrev_b32_e32 v138, 1, v0
	v_bitop3_b32 v0, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x70
	v_bitop3_b32 v68, v73, v68, v108 bitop3:0xde
	v_lshlrev_b32_e32 v139, 1, v0
	v_bitop3_b32 v0, v66, v67, s2 bitop3:0x36
	s_movk_i32 s2, 0x1010
	v_lshlrev_b32_e32 v130, 4, v68
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
	v_lshlrev_b32_e32 v148, 1, v66
	v_xor_b32_e32 v66, v103, v104
	v_mov_b32_e32 v67, 0x4000
	v_lshlrev_b32_e32 v147, 1, v68
	v_lshl_or_b32 v67, v102, 8, v67
	v_lshlrev_b32_e32 v66, 4, v66
	v_lshlrev_b32_e32 v68, 1, v105
	v_or3_b32 v149, v67, v66, v68
	v_bitop3_b32 v66, v103, v104, 4 bitop3:0x36
	s_ashr_i32 s9, s8, 31
	s_add_i32 s71, s78, -1
	s_add_u32 s72, s23, s24
	s_add_u32 s73, s11, s22
	v_lshlrev_b32_e32 v66, 4, v66
	s_ashr_i32 s2, s20, 31
	v_or3_b32 v150, v67, v66, v68
	v_bitop3_b32 v66, v103, v104, 8 bitop3:0x36
	s_and_b64 s[4:5], s[14:15], exec
	v_lshlrev_b32_e32 v66, 4, v66
	s_cselect_b64 s[4:5], 1, 0
	v_or3_b32 v151, v67, v66, v68
	v_bitop3_b32 v66, v103, v104, 12 bitop3:0x36
	s_sub_u32 s4, s20, s4
	v_lshlrev_b32_e32 v66, 4, v66
	s_subb_u32 s5, s2, s5
	v_or3_b32 v152, v67, v66, v68
	s_mov_b32 s11, 0
	v_mov_b64_e32 v[66:67], s[4:5]
	v_cmp_lt_i64_e32 vcc, s[10:11], v[66:67]
	s_and_b64 s[14:15], vcc, exec
	s_cselect_b32 s2, 0, s5
	s_cselect_b32 s10, s10, s4
	s_ashr_i32 s7, s6, 31
	v_lshlrev_b32_e32 v126, 4, v69
	s_ashr_i32 s13, s12, 31
	v_mov_b64_e32 v[68:69], s[6:7]
	v_cmp_lt_i64_e32 vcc, s[12:13], v[68:69]
	s_and_b64 s[4:5], vcc, exec
	v_mov_b32_e32 v66, s10
	v_mov_b32_e32 v67, s2
	s_cselect_b32 s5, s13, s7
	s_cselect_b32 s4, s12, s6
	v_cmp_lt_i64_e32 vcc, s[4:5], v[66:67]
	s_and_b64 s[6:7], vcc, exec
	s_cselect_b32 s6, s4, s10
	s_mov_b32 s10, s5
	s_mov_b32 s11, s5
	s_cselect_b32 s7, s5, s2
	s_and_b64 s[4:5], s[4:5], s[10:11]
	v_mov_b64_e32 v[66:67], s[4:5]
	v_cmp_gt_i64_e32 vcc, s[6:7], v[66:67]
	v_add_u32_e32 v1, v72, v1
	v_add_u32_e32 v70, v72, v70
	s_and_b64 s[10:11], vcc, exec
	v_bitop3_b32 v1, v1, v73, v108 bitop3:0xf6
	v_bitop3_b32 v70, v73, v70, v108 bitop3:0xde
	v_lshlrev_b32_e32 v140, 1, v0
	v_add_u32_e32 v0, s21, v122
	s_cselect_b32 s2, s6, s4
	v_accvgpr_write_b32 a0, v98
	v_lshlrev_b32_e32 v101, 3, v108
	v_lshlrev_b32_e32 v127, 4, v71
	v_lshlrev_b32_e32 v129, 4, v1
	v_lshlrev_b32_e32 v131, 4, v70
	v_or_b32_e32 v141, 1, v84
	v_or_b32_e32 v1, 3, v84
	v_or_b32_e32 v86, 2, v84
	v_or_b32_e32 v83, 9, v84
	v_or_b32_e32 v88, 8, v84
	v_or_b32_e32 v85, 11, v84
	v_or_b32_e32 v90, 10, v84
	v_or_b32_e32 v87, 17, v84
	v_or_b32_e32 v92, 16, v84
	v_or_b32_e32 v89, 19, v84
	v_or_b32_e32 v94, 18, v84
	v_or_b32_e32 v91, 25, v84
	v_or_b32_e32 v96, 24, v84
	v_or_b32_e32 v93, 27, v84
	v_or_b32_e32 v100, 26, v84
	s_mov_b32 s76, s78
	s_mov_b32 s88, s78
	v_mov_b32_e32 v95, v0
	s_mov_b32 s78, s79
	s_lshl_b32 s89, s2, 6
	v_or_b32_e32 v153, 48, v123
	v_or_b32_e32 v154, 32, v123
	v_or_b32_e32 v155, 16, v123
	s_mov_b32 s2, 0x3fb8aa3b
	v_mov_b32_e32 v156, 0xf149f2ca
	v_mov_b64_e32 v[102:103], s[8:9]
	s_mov_b32 s82, s86
	s_mov_b32 s83, s87
.LBB0_7:
	v_or_b32_e32 v68, s89, v1
	s_add_i32 s91, s89, 32
	v_or_b32_e32 v66, s89, v141
	v_or_b32_e32 v67, s89, v84
	v_or_b32_e32 v69, s89, v86
	v_or_b32_e32 v73, s89, v90
	v_or_b32_e32 v80, s89, v93
	v_cmp_gt_i32_e64 s[6:7], s88, v68
	v_sub_u32_e32 v68, v68, v95
	v_or_b32_e32 v70, s89, v83
	v_or_b32_e32 v72, s89, v85
	v_or_b32_e32 v74, s89, v87
	v_or_b32_e32 v76, s89, v89
	v_cmp_gt_i32_e32 vcc, s88, v66
	v_cmp_gt_i32_e64 s[4:5], s76, v67
	v_sub_u32_e32 v67, v67, v0
	v_sub_u32_e32 v66, v66, v95
	v_cmp_gt_i32_e64 s[8:9], s76, v69
	v_sub_u32_e32 v69, v69, v0
	v_cmp_gt_i32_e64 s[16:17], s76, v73
	v_sub_u32_e32 v73, v73, v0
	v_cmp_gt_i32_e64 s[30:31], s88, v80
	v_sub_u32_e32 v80, v80, v95
	v_or_b32_e32 v105, s91, v84
	v_cmp_gt_i32_e64 s[40:41], 1, v68
	v_or_b32_e32 v71, s89, v88
	v_or_b32_e32 v75, s89, v92
	v_or_b32_e32 v77, s89, v94
	v_cmp_gt_i32_e64 s[10:11], s88, v70
	v_sub_u32_e32 v70, v70, v95
	v_cmp_gt_i32_e64 s[14:15], s88, v72
	v_sub_u32_e32 v72, v72, v95
	v_cmp_gt_i32_e64 s[18:19], s88, v74
	v_sub_u32_e32 v74, v74, v95
	v_cmp_gt_i32_e64 s[22:23], s88, v76
	v_sub_u32_e32 v76, v76, v95
	v_or_b32_e32 v104, s91, v141
	v_cmp_gt_i32_e64 s[34:35], 1, v66
	v_cmp_gt_i32_e64 s[38:39], 1, v67
	v_cmp_gt_i32_e64 s[42:43], 1, v69
	v_cmp_gt_i32_e64 s[50:51], 1, v73
	s_and_b64 s[60:61], s[6:7], s[40:41]
	v_cmp_gt_i32_e64 s[6:7], 1, v80
	v_sub_u32_e32 v66, v105, v0
	v_or_b32_e32 v78, s89, v91
	v_cmp_gt_i32_e64 s[12:13], s76, v71
	v_sub_u32_e32 v71, v71, v0
	v_cmp_gt_i32_e64 s[20:21], s76, v75
	v_sub_u32_e32 v75, v75, v0
	v_cmp_gt_i32_e64 s[24:25], s76, v77
	v_sub_u32_e32 v77, v77, v0
	v_or_b32_e32 v107, s91, v86
	v_cmp_gt_i32_e64 s[44:45], 1, v70
	v_cmp_gt_i32_e64 s[48:49], 1, v72
	v_cmp_gt_i32_e64 s[52:53], 1, v74
	v_cmp_gt_i32_e64 s[66:67], 1, v76
	s_and_b64 s[62:63], s[4:5], s[38:39]
	s_and_b64 s[58:59], s[8:9], s[42:43]
	s_and_b64 s[42:43], s[16:17], s[50:51]
	v_cmp_gt_i32_e64 s[16:17], s76, v105
	v_sub_u32_e32 v67, v104, v95
	s_and_b64 s[38:39], s[30:31], s[6:7]
	v_cmp_gt_i32_e64 s[6:7], 1, v66
	v_or_b32_e32 v79, s89, v96
	v_cmp_gt_i32_e64 s[26:27], s88, v78
	v_sub_u32_e32 v78, v78, v95
	v_or_b32_e32 v106, s91, v1
	v_cmp_gt_i32_e64 s[46:47], 1, v71
	v_cmp_gt_i32_e64 s[54:55], 1, v75
	v_cmp_gt_i32_e64 s[4:5], 1, v77
	s_and_b64 s[40:41], s[10:11], s[44:45]
	v_cmp_gt_i32_e64 s[10:11], s88, v104
	s_and_b64 s[44:45], s[14:15], s[48:49]
	v_sub_u32_e32 v68, v107, v0
	s_and_b64 s[48:49], s[18:19], s[52:53]
	s_and_b64 s[52:53], s[22:23], s[66:67]
	s_and_b64 s[22:23], s[16:17], s[6:7]
	v_cmp_gt_i32_e64 s[6:7], 1, v67
	v_cmp_gt_i32_e64 s[28:29], s76, v79
	v_sub_u32_e32 v79, v79, v0
	v_or_b32_e32 v109, s91, v88
	s_and_b64 s[64:65], vcc, s[34:35]
	v_cmp_gt_i32_e32 vcc, 1, v78
	s_and_b64 s[56:57], s[12:13], s[46:47]
	s_and_b64 s[46:47], s[20:21], s[54:55]
	v_cmp_gt_i32_e64 s[20:21], s76, v107
	v_sub_u32_e32 v69, v106, v95
	s_and_b64 s[50:51], s[24:25], s[4:5]
	s_and_b64 s[24:25], s[10:11], s[6:7]
	v_cmp_gt_i32_e64 s[6:7], 1, v68
	v_or_b32_e32 v108, s91, v83
	v_cmp_gt_i32_e64 s[8:9], 1, v79
	v_cmp_gt_i32_e64 s[14:15], s88, v106
	v_sub_u32_e32 v70, v109, v0
	s_and_b64 s[34:35], s[26:27], vcc
	s_and_b64 s[26:27], s[20:21], s[6:7]
	v_cmp_gt_i32_e64 s[6:7], 1, v69
	v_or_b32_e32 v111, s91, v90
	v_cmp_gt_i32_e64 s[4:5], s76, v109
	v_sub_u32_e32 v71, v108, v95
	s_and_b64 s[54:55], s[28:29], s[8:9]
	s_and_b64 s[28:29], s[14:15], s[6:7]
	v_cmp_gt_i32_e64 s[6:7], 1, v70
	v_or_b32_e32 v114, s91, v94
	v_cmp_gt_i32_e64 s[18:19], s88, v108
	v_sub_u32_e32 v72, v111, v0
	s_and_b64 s[30:31], s[4:5], s[6:7]
	v_cmp_gt_i32_e64 s[4:5], 1, v71
	v_cmp_gt_i32_e64 s[8:9], s76, v111
	s_and_b64 s[16:17], s[18:19], s[4:5]
	v_cmp_gt_i32_e64 s[4:5], 1, v72
	v_sub_u32_e32 v66, v114, v0
	s_and_b64 s[18:19], s[8:9], s[4:5]
	v_cmp_gt_i32_e64 s[8:9], 1, v66
	v_or_b32_e32 v66, s91, v89
	v_or_b32_e32 v81, s89, v100
	v_cmp_gt_i32_e64 s[6:7], s76, v114
	v_sub_u32_e32 v67, v66, v95
	v_cmp_gt_i32_e64 s[36:37], s76, v81
	v_sub_u32_e32 v81, v81, v0
	v_or_b32_e32 v110, s91, v85
	s_and_b64 s[6:7], s[6:7], s[8:9]
	v_cmp_gt_i32_e64 s[8:9], s88, v66
	v_cmp_gt_i32_e64 s[10:11], 1, v67
	v_or_b32_e32 v66, s91, v96
	v_cmp_gt_i32_e64 s[12:13], 1, v81
	v_sub_u32_e32 v73, v110, v95
	s_and_b64 s[10:11], s[8:9], s[10:11]
	v_sub_u32_e32 v67, v66, v0
	v_cmp_gt_i32_e64 s[8:9], s76, v66
	v_or_b32_e32 v66, s91, v91
	v_or_b32_e32 v113, s91, v92
	v_cmp_gt_i32_e64 s[66:67], s88, v110
	s_and_b64 s[36:37], s[36:37], s[12:13]
	v_cmp_gt_i32_e64 s[4:5], 1, v73
	v_cmp_gt_i32_e64 s[12:13], 1, v67
	v_sub_u32_e32 v67, v66, v95
	v_or_b32_e32 v112, s91, v87
	v_sub_u32_e32 v74, v113, v0
	s_and_b64 s[20:21], s[66:67], s[4:5]
	s_and_b64 s[66:67], s[8:9], s[12:13]
	v_cmp_gt_i32_e64 s[8:9], s88, v66
	v_cmp_gt_i32_e64 s[12:13], 1, v67
	v_or_b32_e32 v66, s91, v100
	v_cmp_gt_i32_e32 vcc, s76, v113
	v_sub_u32_e32 v75, v112, v95
	v_cmp_gt_i32_e64 s[4:5], 1, v74
	s_and_b64 s[8:9], s[8:9], s[12:13]
	v_sub_u32_e32 v67, v66, v0
	v_cmp_gt_i32_e64 s[12:13], s76, v66
	v_or_b32_e32 v66, s91, v93
	v_cmp_gt_i32_e64 s[68:69], s88, v112
	s_and_b64 vcc, vcc, s[4:5]
	v_cmp_gt_i32_e64 s[4:5], 1, v75
	v_cmp_gt_i32_e64 s[14:15], 1, v67
	v_sub_u32_e32 v67, v66, v95
	s_and_b64 s[4:5], s[68:69], s[4:5]
	s_and_b64 s[12:13], s[12:13], s[14:15]
	v_cmp_gt_i32_e64 s[14:15], s88, v66
	v_cmp_gt_i32_e64 s[68:69], 1, v67
	v_add_u32_e32 v66, s89, v123
	v_add_u32_e32 v67, s89, v155
	v_add_u32_e32 v68, s89, v154
	v_add_u32_e32 v69, s89, v153
	v_min_i32_e32 v66, s71, v66
	v_min_i32_e32 v67, s71, v67
	v_min_i32_e32 v68, s71, v68
	v_min_i32_e32 v69, s71, v69
	v_mul_lo_u32 v70, s70, v66
	v_mul_lo_u32 v71, s70, v67
	v_mul_lo_u32 v72, s70, v68
	v_mul_lo_u32 v73, s70, v69
	v_mul_lo_u32 v66, s90, v66
	v_mul_lo_u32 v67, s90, v67
	v_mul_lo_u32 v68, s90, v68
	v_mul_lo_u32 v69, s90, v69
	v_add_u32_e32 v70, s72, v70
	v_add_u32_e32 v71, s72, v71
	v_add_u32_e32 v72, s72, v72
	v_add_u32_e32 v73, s72, v73
	v_add_u32_e32 v74, s73, v66
	v_add_u32_e32 v75, s73, v67
	v_add_u32_e32 v76, s73, v68
	v_add_u32_e32 v77, s73, v69
	v_add_lshl_u32 v66, v101, v70, 1
	v_add_lshl_u32 v67, v101, v71, 1
	v_add_lshl_u32 v68, v101, v72, 1
	v_add_lshl_u32 v69, v101, v73, 1
	v_add_lshl_u32 v70, v101, v74, 1
	v_add_lshl_u32 v71, v101, v75, 1
	v_add_lshl_u32 v72, v101, v76, 1
	v_add_lshl_u32 v73, v101, v77, 1
	s_barrier
	buffer_load_dwordx4 v[74:77], v66, s[80:83], 0 offen
	buffer_load_dwordx4 v[78:81], v67, s[80:83], 0 offen
	buffer_load_dwordx4 v[104:107], v68, s[80:83], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[66:69], v69, s[80:83], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[108:111], v70, s[84:87], 0 offen
	buffer_load_dwordx4 v[112:115], v71, s[84:87], 0 offen
	buffer_load_dwordx4 v[116:119], v72, s[84:87], 0 offen
	s_nop 0
	buffer_load_dwordx4 v[70:73], v73, s[84:87], 0 offen
	s_waitcnt vmcnt(7)
	ds_write_b128 v125, v[74:77]
	s_waitcnt vmcnt(6)
	ds_write_b128 v126, v[78:81]
	s_waitcnt vmcnt(5)
	ds_write_b128 v127, v[104:107]
	s_waitcnt vmcnt(4)
	ds_write_b128 v128, v[66:69]
	s_waitcnt vmcnt(3)
	ds_write_b128 v129, v[108:111] offset:16384
	s_waitcnt vmcnt(2)
	ds_write_b128 v130, v[112:115] offset:16384
	s_waitcnt vmcnt(1)
	ds_write_b128 v131, v[116:119] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v132, v[70:73] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read_b128 v[104:107], v133
	ds_read_b128 v[192:195], v133 offset:8192
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[160:163], 0
	ds_read_b128 v[104:107], v134
	s_and_b64 s[14:15], s[14:15], s[68:69]
	s_add_u32 s74, s74, 1
	s_addc_u32 s75, s75, 0
	s_add_i32 s89, s89, 64
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[164:167], v[66:81]
	ds_read_b128 v[104:107], v135
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[168:171], v[66:81]
	ds_read_b128 v[104:107], v136
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[172:175], v[66:81]
	ds_read_b128 v[104:107], v137
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[176:179], v[66:81]
	ds_read_b128 v[104:107], v138
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[180:183], v[66:81]
	ds_read_b128 v[104:107], v139
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[184:187], v[66:81]
	ds_read_b128 v[104:107], v140
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[104:107], v[188:191], v[66:81]
	s_nop 11
	v_pk_mul_f32 v[66:67], s[78:79], v[66:67]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v117, v156, v67, s[64:65]
	v_cndmask_b32_e64 v116, v156, v66, s[62:63]
	v_pk_mul_f32 v[66:67], s[78:79], v[68:69]
	v_cmp_gt_f32_e64 s[68:69], v116, v117
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v104, v117, v116, s[68:69]
	v_cndmask_b32_e64 v118, v156, v66, s[58:59]
	v_cmp_gt_f32_e64 s[68:69], v104, v118
	v_cndmask_b32_e64 v119, v156, v67, s[60:61]
	s_nop 0
	v_cndmask_b32_e64 v66, v118, v104, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v119
	s_nop 1
	v_cndmask_b32_e64 v68, v119, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[70:71]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v120, v156, v66, s[56:57]
	v_cmp_gt_f32_e64 s[68:69], v68, v120
	v_cndmask_b32_e64 v121, v156, v67, s[40:41]
	s_nop 0
	v_cndmask_b32_e64 v66, v120, v68, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v121
	s_nop 1
	v_cndmask_b32_e64 v68, v121, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[72:73]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v104, v156, v66, s[42:43]
	v_cmp_gt_f32_e64 s[68:69], v68, v104
	v_cndmask_b32_e64 v105, v156, v67, s[44:45]
	s_nop 0
	v_cndmask_b32_e64 v66, v104, v68, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v105
	s_nop 1
	v_cndmask_b32_e64 v68, v105, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[74:75]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v106, v156, v66, s[46:47]
	v_cmp_gt_f32_e64 s[68:69], v68, v106
	v_cndmask_b32_e64 v107, v156, v67, s[48:49]
	s_nop 0
	v_cndmask_b32_e64 v66, v106, v68, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v107
	s_nop 1
	v_cndmask_b32_e64 v68, v107, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[76:77]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v108, v156, v66, s[50:51]
	v_cmp_gt_f32_e64 s[68:69], v68, v108
	v_cndmask_b32_e64 v109, v156, v67, s[52:53]
	s_nop 0
	v_cndmask_b32_e64 v66, v108, v68, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v109
	s_nop 1
	v_cndmask_b32_e64 v68, v109, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[78:79]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v110, v156, v66, s[54:55]
	v_cmp_gt_f32_e64 s[68:69], v68, v110
	v_cndmask_b32_e64 v111, v156, v67, s[34:35]
	s_nop 0
	v_cndmask_b32_e64 v66, v110, v68, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v111
	s_nop 1
	v_cndmask_b32_e64 v68, v111, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[80:81]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v112, v156, v66, s[36:37]
	v_cmp_gt_f32_e64 s[68:69], v68, v112
	v_cndmask_b32_e64 v113, v156, v67, s[38:39]
	s_nop 0
	v_cndmask_b32_e64 v66, v112, v68, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v113
	s_nop 1
	v_cndmask_b32_e64 v115, v113, v66, s[68:69]
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[160:163], 0
	ds_read_b128 v[192:195], v142
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[164:167], v[66:81]
	ds_read_b128 v[192:195], v143
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[168:171], v[66:81]
	ds_read_b128 v[192:195], v144
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[172:175], v[66:81]
	ds_read_b128 v[192:195], v145
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[176:179], v[66:81]
	ds_read_b128 v[192:195], v146
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[180:183], v[66:81]
	ds_read_b128 v[192:195], v147
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[184:187], v[66:81]
	ds_read_b128 v[192:195], v148
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[66:81], v[192:195], v[188:191], v[66:81]
	ds_read_b64_tr_b16 v[252:253], v149
	ds_read_b64_tr_b16 v[254:255], v149 offset:1024
	ds_read_b64_tr_b16 v[248:249], v150
	ds_read_b64_tr_b16 v[250:251], v150 offset:1024
	ds_read_b64_tr_b16 v[244:245], v151
	ds_read_b64_tr_b16 v[246:247], v151 offset:1024
	ds_read_b64_tr_b16 v[240:241], v152
	ds_read_b64_tr_b16 v[242:243], v152 offset:1024
	ds_read_b64_tr_b16 v[236:237], v149 offset:4096
	ds_read_b64_tr_b16 v[238:239], v149 offset:5120
	ds_read_b64_tr_b16 v[232:233], v150 offset:4096
	ds_read_b64_tr_b16 v[234:235], v150 offset:5120
	ds_read_b64_tr_b16 v[228:229], v151 offset:4096
	ds_read_b64_tr_b16 v[230:231], v151 offset:5120
	ds_read_b64_tr_b16 v[224:225], v152 offset:4096
	ds_read_b64_tr_b16 v[226:227], v152 offset:5120
	ds_read_b64_tr_b16 v[220:221], v149 offset:8192
	ds_read_b64_tr_b16 v[222:223], v149 offset:9216
	ds_read_b64_tr_b16 v[216:217], v150 offset:8192
	ds_read_b64_tr_b16 v[218:219], v150 offset:9216
	ds_read_b64_tr_b16 v[212:213], v151 offset:8192
	ds_read_b64_tr_b16 v[214:215], v151 offset:9216
	ds_read_b64_tr_b16 v[208:209], v152 offset:8192
	ds_read_b64_tr_b16 v[210:211], v152 offset:9216
	ds_read_b64_tr_b16 v[204:205], v149 offset:12288
	ds_read_b64_tr_b16 v[206:207], v149 offset:13312
	ds_read_b64_tr_b16 v[200:201], v150 offset:12288
	ds_read_b64_tr_b16 v[202:203], v150 offset:13312
	ds_read_b64_tr_b16 v[196:197], v151 offset:12288
	ds_read_b64_tr_b16 v[198:199], v151 offset:13312
	ds_read_b64_tr_b16 v[192:193], v152 offset:12288
	ds_read_b64_tr_b16 v[194:195], v152 offset:13312
	v_pk_mul_f32 v[66:67], s[78:79], v[66:67]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v114, v156, v66, s[22:23]
	v_cmp_gt_f32_e64 s[68:69], v115, v114
	s_nop 1
	v_cndmask_b32_e64 v66, v114, v115, s[68:69]
	v_cndmask_b32_e64 v115, v156, v67, s[24:25]
	v_cmp_gt_f32_e64 s[68:69], v66, v115
	s_nop 1
	v_cndmask_b32_e64 v157, v115, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[68:69]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v68, v156, v66, s[26:27]
	v_cmp_gt_f32_e64 s[68:69], v157, v68
	v_cndmask_b32_e64 v69, v156, v67, s[28:29]
	s_nop 0
	v_cndmask_b32_e64 v66, v68, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v69
	s_nop 1
	v_cndmask_b32_e64 v157, v69, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[70:71]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v70, v156, v66, s[30:31]
	v_cmp_gt_f32_e64 s[68:69], v157, v70
	v_cndmask_b32_e64 v71, v156, v67, s[16:17]
	s_nop 0
	v_cndmask_b32_e64 v66, v70, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v71
	s_nop 1
	v_cndmask_b32_e64 v157, v71, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[72:73]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v72, v156, v66, s[18:19]
	v_cmp_gt_f32_e64 s[68:69], v157, v72
	v_cndmask_b32_e64 v73, v156, v67, s[20:21]
	s_nop 0
	v_cndmask_b32_e64 v66, v72, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v73
	s_nop 1
	v_cndmask_b32_e64 v157, v73, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[74:75]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e32 v74, v156, v66, vcc
	v_cmp_gt_f32_e64 s[68:69], v157, v74
	v_cndmask_b32_e64 v75, v156, v67, s[4:5]
	s_nop 0
	v_cndmask_b32_e64 v66, v74, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v75
	s_nop 1
	v_cndmask_b32_e64 v157, v75, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[76:77]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v76, v156, v66, s[6:7]
	v_cmp_gt_f32_e64 s[68:69], v157, v76
	v_cndmask_b32_e64 v77, v156, v67, s[10:11]
	s_nop 0
	v_cndmask_b32_e64 v66, v76, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v77
	s_nop 1
	v_cndmask_b32_e64 v157, v77, v66, s[68:69]
	v_pk_mul_f32 v[66:67], s[78:79], v[78:79]
	s_nop 0
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v66, v156, v66, s[66:67]
	v_cmp_gt_f32_e64 s[68:69], v157, v66
	v_cndmask_b32_e64 v67, v156, v67, s[8:9]
	s_nop 0
	v_cndmask_b32_e64 v78, v66, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v78, v67
	s_nop 1
	v_cndmask_b32_e64 v157, v67, v78, s[68:69]
	v_pk_mul_f32 v[78:79], s[78:79], v[80:81]
	s_nop 0
	v_pk_mul_f32 v[78:79], v[78:79], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v80, v156, v78, s[12:13]
	v_cmp_gt_f32_e64 s[68:69], v157, v80
	v_cndmask_b32_e64 v81, v156, v79, s[14:15]
	s_nop 0
	v_cndmask_b32_e64 v78, v80, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v78, v81
	s_nop 1
	v_cndmask_b32_e64 v78, v81, v78, s[68:69]
	v_mov_b32_e32 v79, v78
	v_mov_b32_e32 v157, v78
	s_nop 1
	v_permlane32_swap_b32_e32 v79, v157
	v_cmp_eq_u32_e64 s[68:69], v79, v78
	s_nop 1
	v_cndmask_b32_e64 v79, v79, v157, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v78, v79
	s_nop 1
	v_cndmask_b32_e64 v78, v79, v78, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v82, v78
	s_nop 1
	v_cndmask_b32_e64 v78, v78, v82, s[68:69]
	v_pk_add_f32 v[116:117], v[116:117], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_sub_f32_e32 v82, v82, v78
	v_exp_f32_e32 v79, v116
	s_nop 0
	v_cndmask_b32_e64 v157, 0, v79, s[62:63]
	v_exp_f32_e32 v79, v117
	s_nop 0
	v_pk_add_f32 v[116:117], v[118:119], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v158, 0, v79, s[64:65]
	v_exp_f32_e32 v79, v116
	s_nop 0
	v_cndmask_b32_e64 v118, 0, v79, s[58:59]
	v_exp_f32_e32 v79, v117
	s_nop 0
	v_cndmask_b32_e64 v79, 0, v79, s[60:61]
	v_pk_add_f32 v[116:117], v[120:121], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[120:121], v[104:105], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_exp_f32_e32 v116, v116
	v_pk_add_f32 v[106:107], v[106:107], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[108:109], v[108:109], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_exp_f32_e32 v104, v82
	v_exp_f32_e32 v82, v117
	v_exp_f32_e32 v105, v120
	v_exp_f32_e32 v117, v121
	v_exp_f32_e32 v106, v106
	v_exp_f32_e32 v107, v107
	v_exp_f32_e32 v108, v108
	v_exp_f32_e32 v109, v109
	v_cndmask_b32_e64 v116, 0, v116, s[56:57]
	v_cndmask_b32_e64 v119, 0, v82, s[40:41]
	v_cndmask_b32_e64 v105, 0, v105, s[42:43]
	v_cndmask_b32_e64 v117, 0, v117, s[44:45]
	v_cndmask_b32_e64 v120, 0, v106, s[46:47]
	v_cndmask_b32_e64 v121, 0, v107, s[48:49]
	v_cndmask_b32_e64 v159, 0, v108, s[50:51]
	v_cndmask_b32_e64 v97, 0, v109, s[52:53]
	v_pk_mul_f32 v[16:17], v[16:17], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[64:65], v[64:65], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[62:63], v[62:63], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[60:61], v[60:61], v[104:105] op_sel_hi:[1,0]
	v_cvt_pk_bf16_f32 v109, v105, v117
	v_cvt_pk_bf16_f32 v108, v116, v119
	v_cvt_pk_bf16_f32 v107, v118, v79
	v_cvt_pk_bf16_f32 v106, v157, v158
	v_pk_mul_f32 v[58:59], v[58:59], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[56:57], v[56:57], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[54:55], v[54:55], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[52:53], v[52:53], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[50:51], v[50:51], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[48:49], v[48:49], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[46:47], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[42:43], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[40:41], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[38:39], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[36:37], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[104:105] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[104:105] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(14)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[252:255], v[106:109], v[2:17]
	v_add_f32_e64 v110, v110, -v78
	v_add_f32_e64 v111, v111, -v78
	v_add_f32_e64 v112, v112, -v78
	v_add_f32_e64 v113, v113, -v78
	v_exp_f32_e32 v110, v110
	v_exp_f32_e32 v111, v111
	v_exp_f32_e32 v112, v112
	v_exp_f32_e32 v113, v113
	v_cndmask_b32_e64 v98, 0, v110, s[54:55]
	v_mfma_f32_32x32x16_bf16 v[50:65], v[248:251], v[106:109], v[50:65]
	v_add_f32_e64 v68, v68, -v78
	v_add_f32_e64 v69, v69, -v78
	v_add_f32_e64 v70, v70, -v78
	v_add_f32_e64 v71, v71, -v78
	v_add_f32_e64 v72, v72, -v78
	v_add_f32_e64 v73, v73, -v78
	v_exp_f32_e32 v68, v68
	v_exp_f32_e32 v69, v69
	v_exp_f32_e32 v70, v70
	v_exp_f32_e32 v71, v71
	v_mfma_f32_32x32x16_bf16 v[34:49], v[244:247], v[106:109], v[34:49]
	v_exp_f32_e32 v72, v72
	v_exp_f32_e32 v73, v73
	v_pk_add_f32 v[74:75], v[74:75], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[76:77], v[76:77], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v72, 0, v72, s[18:19]
	v_cndmask_b32_e64 v73, 0, v73, s[20:21]
	v_exp_f32_e32 v74, v74
	v_mfma_f32_32x32x16_bf16 v[18:33], v[240:243], v[106:109], v[18:33]
	v_cndmask_b32_e64 v240, 0, v111, s[34:35]
	v_cndmask_b32_e64 v241, 0, v112, s[36:37]
	v_cndmask_b32_e64 v242, 0, v113, s[38:39]
	v_cvt_pk_bf16_f32 v109, v241, v242
	v_cvt_pk_bf16_f32 v108, v98, v240
	v_cvt_pk_bf16_f32 v107, v159, v97
	v_cvt_pk_bf16_f32 v106, v120, v121
	v_pk_add_f32 v[110:111], v[114:115], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_add_f32 v[112:113], v[66:67], v[78:79] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_mfma_f32_32x32x16_bf16 v[2:17], v[236:239], v[106:109], v[2:17]
	v_exp_f32_e32 v66, v110
	v_exp_f32_e32 v67, v111
	v_cndmask_b32_e64 v114, 0, v68, s[26:27]
	v_cndmask_b32_e64 v115, 0, v69, s[28:29]
	v_cndmask_b32_e64 v110, 0, v66, s[22:23]
	v_cndmask_b32_e64 v111, 0, v67, s[24:25]
	v_cvt_pk_bf16_f32 v69, v72, v73
	v_mfma_f32_32x32x16_bf16 v[50:65], v[232:235], v[106:109], v[50:65]
	v_cvt_pk_bf16_f32 v67, v114, v115
	v_cvt_pk_bf16_f32 v66, v110, v111
	v_exp_f32_e32 v75, v75
	v_exp_f32_e32 v76, v76
	v_exp_f32_e32 v77, v77
	v_cndmask_b32_e32 v74, 0, v74, vcc
	v_cndmask_b32_e64 v75, 0, v75, s[4:5]
	v_mfma_f32_32x32x16_bf16 v[34:49], v[228:231], v[106:109], v[34:49]
	v_cndmask_b32_e64 v228, 0, v70, s[30:31]
	v_cndmask_b32_e64 v76, 0, v76, s[6:7]
	v_cndmask_b32_e64 v77, 0, v77, s[10:11]
	v_cmp_lt_i64_e64 s[56:57], s[74:75], v[102:103]
	s_and_b64 s[56:57], exec, s[56:57]
	v_mul_f32_e32 v104, v124, v104
	v_mov_b32_e32 v82, v78
	v_mfma_f32_32x32x16_bf16 v[18:33], v[224:227], v[106:109], v[18:33]
	v_cndmask_b32_e64 v106, 0, v71, s[16:17]
	v_cvt_pk_bf16_f32 v68, v228, v106
	v_add_f32_e32 v109, v157, v158
	v_add_f32_e64 v70, v80, -v78
	v_add_f32_e64 v71, v81, -v78
	v_exp_f32_e32 v80, v112
	v_exp_f32_e32 v81, v113
	v_exp_f32_e32 v70, v70
	v_mfma_f32_32x32x16_bf16 v[2:17], v[220:223], v[66:69], v[2:17]
	v_exp_f32_e32 v71, v71
	v_cndmask_b32_e64 v80, 0, v80, s[66:67]
	v_cndmask_b32_e64 v81, 0, v81, s[8:9]
	v_cndmask_b32_e64 v107, 0, v70, s[12:13]
	v_cndmask_b32_e64 v108, 0, v71, s[14:15]
	v_cvt_pk_bf16_f32 v71, v107, v108
	v_cvt_pk_bf16_f32 v70, v80, v81
	s_waitcnt lgkmcnt(12)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[216:219], v[66:69], v[50:65]
	s_waitcnt lgkmcnt(10)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[212:215], v[66:69], v[34:49]
	s_waitcnt lgkmcnt(8)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[208:211], v[66:69], v[18:33]
	v_add_f32_e32 v66, v118, v109
	v_add_f32_e32 v66, v79, v66
	v_add_f32_e32 v66, v116, v66
	v_add_f32_e32 v66, v119, v66
	v_add_f32_e32 v66, v105, v66
	v_add_f32_e32 v66, v117, v66
	v_add_f32_e32 v66, v120, v66
	v_add_f32_e32 v66, v121, v66
	v_add_f32_e32 v66, v159, v66
	v_add_f32_e32 v66, v97, v66
	v_add_f32_e32 v66, v98, v66
	v_add_f32_e32 v66, v240, v66
	v_add_f32_e32 v66, v241, v66
	v_add_f32_e32 v66, v242, v66
	v_add_f32_e32 v66, v110, v66
	v_add_f32_e32 v66, v111, v66
	v_add_f32_e32 v66, v114, v66
	v_add_f32_e32 v66, v115, v66
	v_add_f32_e32 v66, v228, v66
	v_add_f32_e32 v66, v106, v66
	v_add_f32_e32 v66, v72, v66
	v_add_f32_e32 v66, v73, v66
	v_add_f32_e32 v66, v74, v66
	v_add_f32_e32 v66, v75, v66
	v_add_f32_e32 v66, v76, v66
	v_add_f32_e32 v66, v77, v66
	v_add_f32_e32 v66, v80, v66
	v_cvt_pk_bf16_f32 v69, v76, v77
	v_cvt_pk_bf16_f32 v68, v74, v75
	v_add_f32_e32 v66, v81, v66
	v_add_f32_e32 v66, v107, v66
	s_waitcnt lgkmcnt(6)
	v_mfma_f32_32x32x16_bf16 v[2:17], v[204:207], v[68:71], v[2:17]
	v_add_f32_e32 v66, v108, v66
	v_mov_b32_e32 v67, v66
	s_waitcnt lgkmcnt(4)
	v_mfma_f32_32x32x16_bf16 v[50:65], v[200:203], v[68:71], v[50:65]
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x16_bf16 v[34:49], v[196:199], v[68:71], v[34:49]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x16_bf16 v[18:33], v[192:195], v[68:71], v[18:33]
	v_mov_b32_e32 v68, v66
	s_nop 1
	v_permlane32_swap_b32_e32 v67, v68
	v_cmp_eq_u32_e32 vcc, v67, v66
	s_nop 1
	v_cndmask_b32_e32 v67, v67, v68, vcc
	v_add_f32_e32 v66, v66, v67
	v_add_f32_e32 v124, v104, v66
	s_mov_b64 vcc, s[56:57]
	s_cbranch_vccnz .LBB0_7
	v_mov_b32_e32 v82, v78
	v_accvgpr_read_b32 v98, a0
	v_accvgpr_read_b32 v69, a1
.LBB0_9:
	v_cmp_gt_i32_e32 vcc, s77, v122
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_12
	v_div_scale_f32 v0, s[6:7], v124, v124, 1.0
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
	v_div_scale_f32 v66, vcc, 1.0, v124, 1.0
	v_mul_f32_e32 v67, v66, v1
	v_fma_f32 v68, -v0, v67, v66
	v_fmac_f32_e32 v67, v68, v1
	v_fma_f32 v0, -v0, v67, v66
	v_div_fmas_f32 v0, v0, v1, v67
	v_div_fixup_f32 v0, v0, v124, 1.0
	v_cmp_lt_f32_e32 vcc, 0, v124
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
	v_lshl_add_u32 v2, v1, 1, v99
	v_pk_mul_f32 v[10:11], v[10:11], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[0:1] op_sel_hi:[1,0]
	buffer_store_dwordx2 v[4:5], v2, s[4:7], 0 offen
	v_cvt_pk_bf16_f32 v3, v8, v9
	v_cvt_pk_bf16_f32 v2, v6, v7
	v_add_lshl_u32 v66, v1, v84, 1
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
	v_cmp_gt_u32_e64 s[4:5], 32, v69
	s_and_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_12
	s_mov_b32 s2, 0x800000
	v_cmp_gt_f32_e64 s[4:5], s2, v124
	v_mov_b32_e32 v0, 0x42000000
	s_nop 0
	v_cndmask_b32_e64 v1, 0, 32, s[4:5]
	v_ldexp_f32 v1, v124, v1
	v_cndmask_b32_e64 v0, 0, v0, s[4:5]
	v_log_f32_e32 v1, v1
	s_load_dwordx2 s[4:5], s[0:1], 0xc0
	s_load_dword s2, s[0:1], 0xd4
	s_load_dword s8, s[0:1], 0xdc
	v_sub_f32_e32 v0, v1, v0
	v_add_f32_e32 v0, v82, v0
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
		.amdhsa_next_free_vgpr 258
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 256
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

	.set .Lkernel_0.num_vgpr, 256
	.set .Lkernel_0.num_agpr, 2
	.set .Lkernel_0.numbered_sgpr, 92
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
  - .agpr_count:     2
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
    .sgpr_count:     98
    .sgpr_spill_count: 0
    .symbol:         kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     258
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx950
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata

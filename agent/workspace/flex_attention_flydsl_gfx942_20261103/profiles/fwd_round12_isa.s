	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx942"
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
	s_ashr_i32 s12, s5, 3
	s_and_b32 s5, s5, -8
	s_cmp_lg_u32 s3, s5
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s3, 0
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[6:7], s[10:11], s[6:7]
	s_subb_u32 s5, s12, 0
	s_abs_i32 s6, s80
	v_cvt_f32_u32_e32 v1, s6
	s_sub_i32 s13, 0, s6
	s_load_dwordx8 s[72:79], s[0:1], 0x48
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s14, s[0:1], 0x18
	s_load_dword s15, s[0:1], 0x20
	s_load_dword s16, s[0:1], 0x28
	s_load_dwordx2 s[84:85], s[0:1], 0x30
	s_abs_i32 s7, s4
	v_rcp_f32_e32 v1, v1
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[88:89], s[78:79]
	s_xor_b32 s12, s80, s4
	s_and_b32 s85, s85, 0xffff
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	s_and_b32 s89, s89, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_ashr_i32 s17, s12, 31
	v_readfirstlane_b32 s18, v1
	s_mul_i32 s13, s13, s18
	s_mul_hi_u32 s13, s18, s13
	s_add_i32 s18, s18, s13
	s_mul_hi_u32 s13, s7, s18
	s_mul_i32 s18, s13, s6
	s_sub_i32 s7, s7, s18
	s_add_i32 s18, s13, 1
	s_sub_i32 s19, s7, s6
	s_cmp_ge_u32 s7, s6
	s_cselect_b32 s13, s18, s13
	s_cselect_b32 s7, s19, s7
	s_add_i32 s18, s13, 1
	s_cmp_ge_u32 s7, s6
	s_cselect_b32 s6, s18, s13
	s_xor_b32 s18, s6, s17
	s_sub_i32 s6, s18, s17
	s_mul_i32 s6, s6, s80
	s_cmp_lg_u32 s4, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s12, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[6:7], s[12:13], s[6:7]
	s_subb_u32 s33, s18, s17
	s_add_i32 s4, s82, 63
	s_ashr_i32 s6, s4, 31
	s_lshr_b32 s6, s6, 26
	s_add_i32 s6, s4, s6
	s_ashr_i32 s17, s6, 6
	s_andn2_b32 s6, s6, 63
	s_cmp_lg_u32 s4, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s4, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[6:7], s[12:13], s[6:7]
	s_subb_u32 s4, s17, 0
	s_add_i32 s6, s2, 0x80
	s_min_i32 s6, s6, s81
	s_sub_i32 s18, s82, s81
	s_add_i32 s6, s18, s6
	s_max_i32 s6, s6, 0
	s_add_i32 s12, s6, 63
	s_ashr_i32 s6, s12, 31
	s_lshr_b32 s6, s6, 26
	s_add_i32 s6, s12, s6
	s_ashr_i32 s17, s6, 6
	s_andn2_b32 s6, s6, 63
	s_cmp_lg_u32 s12, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s12, 0
	s_cselect_b64 s[12:13], -1, 0
	v_lshrrev_b32_e32 v1, 1, v0
	v_and_b32_e32 v2, 31, v0
	s_and_b64 s[6:7], s[12:13], s[6:7]
	v_and_b32_e32 v1, 0x60, v1
	s_subb_u32 s6, s17, 0
	v_or3_b32 v135, s2, v1, v2
	s_add_i32 s7, s81, -1
	v_min_i32_e32 v98, s7, v135
	s_mul_i32 s7, s14, s33
	s_mul_i32 s16, s16, s3
	v_bfe_u32 v3, v0, 5, 1
	v_mul_lo_u32 v1, s15, v98
	s_add_i32 s7, s7, s16
	v_lshlrev_b32_e32 v106, 2, v3
	s_mov_b32 s87, 0x27000
	s_mov_b32 s86, -1
	v_add_u32_e32 v1, s7, v1
	v_lshlrev_b32_e32 v134, 3, v3
	s_mov_b32 s10, s86
	s_mov_b32 s11, s87
	v_lshl_add_u32 v4, v1, 1, v134
	v_or_b32_e32 v104, 8, v106
	v_or_b32_e32 v102, 16, v106
	v_or_b32_e32 v100, 24, v106
	v_or_b32_e32 v133, 32, v106
	v_add_lshl_u32 v5, v104, v1, 1
	v_add_lshl_u32 v6, v102, v1, 1
	v_add_lshl_u32 v7, v100, v1, 1
	buffer_load_dwordx2 v[198:199], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[200:201], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[202:203], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[204:205], v7, s[8:11], 0 offen
	v_add_lshl_u32 v4, v133, v1, 1
	v_or_b32_e32 v132, 40, v106
	v_or_b32_e32 v131, 48, v106
	v_or_b32_e32 v130, 56, v106
	v_or_b32_e32 v128, 64, v106
	v_add_lshl_u32 v5, v132, v1, 1
	v_add_lshl_u32 v6, v131, v1, 1
	v_add_lshl_u32 v7, v130, v1, 1
	buffer_load_dwordx2 v[206:207], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[208:209], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[210:211], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[212:213], v7, s[8:11], 0 offen
	v_add_lshl_u32 v4, v128, v1, 1
	v_or_b32_e32 v127, 0x48, v106
	v_or_b32_e32 v126, 0x50, v106
	v_or_b32_e32 v125, 0x58, v106
	v_or_b32_e32 v124, 0x60, v106
	v_add_lshl_u32 v5, v127, v1, 1
	v_add_lshl_u32 v6, v126, v1, 1
	v_add_lshl_u32 v7, v125, v1, 1
	buffer_load_dwordx2 v[214:215], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[216:217], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[218:219], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[220:221], v7, s[8:11], 0 offen
	v_add_lshl_u32 v4, v124, v1, 1
	v_or_b32_e32 v123, 0x68, v106
	v_or_b32_e32 v122, 0x70, v106
	v_or_b32_e32 v115, 0x78, v106
	v_add_lshl_u32 v5, v123, v1, 1
	v_add_lshl_u32 v6, v122, v1, 1
	v_add_lshl_u32 v1, v115, v1, 1
	buffer_load_dwordx2 v[222:223], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[224:225], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[226:227], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[228:229], v1, s[8:11], 0 offen
	s_ashr_i32 s7, s82, 31
	s_lshr_b32 s7, s7, 26
	s_add_i32 s7, s82, s7
	s_min_i32 s8, s4, s6
	s_ashr_i32 s19, s7, 6
	s_andn2_b32 s7, s7, 63
	s_cmp_lg_u32 s82, s7
	s_cselect_b64 s[10:11], -1, 0
	s_cmp_lt_i32 s82, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[12:13], s[12:13], s[10:11]
	s_subb_u32 s7, s19, 0
	s_add_i32 s2, s18, s2
	s_add_i32 s2, s2, 1
	s_max_i32 s2, s2, 0
	s_load_dwordx4 s[92:95], s[0:1], 0x78
	s_load_dwordx2 s[16:17], s[0:1], 0x88
	s_lshr_b32 s10, s2, 6
	v_mov_b32_e32 v1, s10
	v_mov_b32_e32 v4, s8
	v_min3_i32 v1, s7, v1, v4
	s_min_i32 s14, s8, 0
	v_readfirstlane_b32 s2, v1
	s_max_i32 s78, s2, s14
	v_cmp_gt_i32_e32 vcc, 1, v1
	v_and_b32_e32 v117, 63, v0
	v_mov_b32_e32 v34, 0
	s_ashr_i32 s79, s78, 31
	s_and_b64 vcc, exec, vcc
	v_bfe_u32 v99, v0, 4, 3
	v_lshrrev_b32_e32 v136, 4, v0
	s_mul_i32 s21, s72, s33
	s_mul_i32 s22, s76, s5
	v_and_b32_e32 v101, 15, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s11, s92, s33
	s_mul_i32 s20, s16, s5
	v_lshlrev_b32_e32 v137, 4, v0
	v_lshl_or_b32 v120, v2, 7, v106
	v_lshlrev_b32_e32 v1, 3, v0
	v_lshlrev_b32_e32 v118, 1, v2
	v_lshlrev_b32_e32 v119, 10, v3
	s_cbranch_vccnz .LBB0_5
	v_xor_b32_e32 v2, v99, v101
	s_movk_i32 s2, 0xf0
	v_and_or_b32 v3, v0, s2, v2
	v_lshlrev_b32_e32 v105, 4, v3
	v_or_b32_e32 v3, 0x100, v0
	s_movk_i32 s2, 0x1f0
	v_and_or_b32 v4, v3, s2, v2
	v_lshlrev_b32_e32 v107, 4, v4
	v_or_b32_e32 v4, 0x200, v0
	s_movk_i32 s2, 0x2f0
	v_and_or_b32 v5, v4, s2, v2
	v_lshlrev_b32_e32 v109, 4, v5
	v_or_b32_e32 v5, 0x300, v0
	s_movk_i32 s2, 0x3f0
	v_and_or_b32 v2, v5, s2, v2
	v_lshlrev_b32_e32 v114, 4, v2
	v_and_b32_e32 v2, 56, v1
	v_lshlrev_b32_e32 v116, 4, v3
	v_or_b32_e32 v3, v120, v2
	v_lshlrev_b32_e32 v139, 1, v3
	v_or_b32_e32 v3, 8, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v140, 1, v3
	v_or_b32_e32 v3, 16, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v141, 1, v3
	v_or_b32_e32 v3, 24, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v142, 1, v3
	v_or_b32_e32 v3, 32, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v143, 1, v3
	v_or_b32_e32 v3, 40, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v144, 1, v3
	v_or_b32_e32 v3, 48, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v145, 1, v3
	v_or_b32_e32 v3, 56, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v146, 1, v3
	v_or_b32_e32 v3, 0x48, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v147, 1, v3
	v_or_b32_e32 v3, 0x50, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v148, 1, v3
	v_or_b32_e32 v3, 0x58, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v149, 1, v3
	v_or_b32_e32 v3, 0x60, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v150, 1, v3
	v_or_b32_e32 v3, 0x68, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v151, 1, v3
	v_or_b32_e32 v3, 0x70, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v152, 1, v3
	v_or_b32_e32 v3, 0x78, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v153, 1, v3
	v_or_b32_e32 v3, 0x1008, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v154, 1, v3
	v_or_b32_e32 v3, 0x1010, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v155, 1, v3
	v_or_b32_e32 v3, 0x1018, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v156, 1, v3
	v_or_b32_e32 v3, 0x1020, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v157, 1, v3
	v_or_b32_e32 v3, 0x1028, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v158, 1, v3
	v_or_b32_e32 v3, 0x1030, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v159, 1, v3
	v_or_b32_e32 v3, 0x1038, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v160, 1, v3
	v_or_b32_e32 v3, 0x1048, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v161, 1, v3
	v_or_b32_e32 v3, 0x1050, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v162, 1, v3
	v_or_b32_e32 v3, 0x1058, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v163, 1, v3
	v_or_b32_e32 v3, 0x1060, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v164, 1, v3
	v_or_b32_e32 v3, 0x1068, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v165, 1, v3
	v_or_b32_e32 v3, 0x1070, v120
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v166, 1, v3
	v_or_b32_e32 v3, 0x1078, v120
	v_xor_b32_e32 v2, v3, v2
	v_lshlrev_b32_e32 v167, 1, v2
	v_lshlrev_b32_e32 v2, 2, v117
	s_ashr_i32 s5, s4, 31
	v_xor_b32_e32 v168, 0x80, v2
	s_ashr_i32 s7, s6, 31
	v_mov_b64_e32 v[2:3], s[4:5]
	s_ashr_i32 s15, s14, 31
	s_add_i32 s9, s82, -1
	s_add_u32 s23, s21, s22
	s_add_u32 s24, s11, s20
	v_cmp_lt_i64_e32 vcc, s[6:7], v[2:3]
	s_movk_i32 s2, 0x4000
	s_and_b64 s[26:27], vcc, exec
	v_or3_b32 v169, v118, v119, s2
	s_cselect_b32 s2, s7, s5
	s_cselect_b32 s5, s6, s4
	s_and_b32 s2, s5, s2
	v_lshl_or_b32 v170, s2, 6, v136
	v_lshlrev_b32_e32 v103, 3, v101
	v_lshlrev_b32_e32 v121, 4, v4
	v_lshlrev_b32_e32 v138, 4, v5
	s_mov_b32 s16, s83
	s_mov_b32 s17, s83
	v_or_b32_e32 v171, 48, v170
	v_or_b32_e32 v172, 32, v170
	v_or_b32_e32 v173, 16, v170
	v_mov_b32_e32 v129, 0
	v_mov_b32_e32 v112, 0xf149f2ca
	s_mov_b32 s2, 0x3fb8aa3b
	s_mov_b32 s5, 0xc2fc0000
	v_mov_b32_e32 v174, 0x42800000
	v_not_b32_e32 v175, 63
	s_movk_i32 s7, 0x7fff
	s_mov_b32 s25, 0x5040100
	s_mov_b32 s26, 0x7060302
	v_mov_b64_e32 v[110:111], s[78:79]
	v_add_u32_e32 v176, 0x2000, v139
	v_mov_b32_e32 v35, v34
	v_mov_b32_e32 v36, v34
	v_mov_b32_e32 v37, v34
	v_mov_b32_e32 v38, v34
	v_mov_b32_e32 v39, v34
	v_mov_b32_e32 v40, v34
	v_mov_b32_e32 v41, v34
	v_mov_b32_e32 v42, v34
	v_mov_b32_e32 v43, v34
	v_mov_b32_e32 v44, v34
	v_mov_b32_e32 v45, v34
	v_mov_b32_e32 v46, v34
	v_mov_b32_e32 v47, v34
	v_mov_b32_e32 v48, v34
	v_mov_b32_e32 v49, v34
	v_mov_b32_e32 v50, v34
	v_mov_b32_e32 v51, v34
	v_mov_b32_e32 v52, v34
	v_mov_b32_e32 v53, v34
	v_mov_b32_e32 v54, v34
	v_mov_b32_e32 v55, v34
	v_mov_b32_e32 v56, v34
	v_mov_b32_e32 v57, v34
	v_mov_b32_e32 v58, v34
	v_mov_b32_e32 v59, v34
	v_mov_b32_e32 v60, v34
	v_mov_b32_e32 v61, v34
	v_mov_b32_e32 v62, v34
	v_mov_b32_e32 v63, v34
	v_mov_b32_e32 v64, v34
	v_mov_b32_e32 v65, v34
	v_mov_b32_e32 v18, v34
	v_mov_b32_e32 v19, v34
	v_mov_b32_e32 v20, v34
	v_mov_b32_e32 v21, v34
	v_mov_b32_e32 v22, v34
	v_mov_b32_e32 v23, v34
	v_mov_b32_e32 v24, v34
	v_mov_b32_e32 v25, v34
	v_mov_b32_e32 v26, v34
	v_mov_b32_e32 v27, v34
	v_mov_b32_e32 v28, v34
	v_mov_b32_e32 v29, v34
	v_mov_b32_e32 v30, v34
	v_mov_b32_e32 v31, v34
	v_mov_b32_e32 v32, v34
	v_mov_b32_e32 v33, v34
	v_mov_b32_e32 v2, v34
	v_mov_b32_e32 v3, v34
	v_mov_b32_e32 v4, v34
	v_mov_b32_e32 v5, v34
	v_mov_b32_e32 v6, v34
	v_mov_b32_e32 v7, v34
	v_mov_b32_e32 v8, v34
	v_mov_b32_e32 v9, v34
	v_mov_b32_e32 v10, v34
	v_mov_b32_e32 v11, v34
	v_mov_b32_e32 v12, v34
	v_mov_b32_e32 v13, v34
	v_mov_b32_e32 v14, v34
	v_mov_b32_e32 v15, v34
	v_mov_b32_e32 v16, v34
	v_mov_b32_e32 v17, v34
.LBB0_3:
	v_min_i32_e32 v66, s9, v170
	v_mul_lo_u32 v67, s74, v66
	v_add_u32_e32 v67, s23, v67
	v_add_lshl_u32 v67, v103, v67, 1
	s_barrier
	buffer_load_dwordx4 v[68:71], v67, s[84:87], 0 offen
	v_min_i32_e32 v67, s9, v173
	v_mul_lo_u32 v66, s94, v66
	v_add_u32_e32 v66, s24, v66
	v_add_lshl_u32 v66, v103, v66, 1
	s_mov_b32 s90, s86
	s_mov_b32 s91, s87
	s_add_u32 s14, s14, 1
	s_addc_u32 s15, s15, 0
	v_add_u32_e32 v173, 64, v173
	v_add_u32_e32 v170, 64, v170
	s_waitcnt vmcnt(0)
	ds_write_b128 v105, v[68:71]
	v_mul_lo_u32 v68, s74, v67
	v_add_u32_e32 v68, s23, v68
	v_add_lshl_u32 v68, v103, v68, 1
	buffer_load_dwordx4 v[68:71], v68, s[84:87], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v107, v[68:71]
	v_min_i32_e32 v68, s9, v172
	v_mul_lo_u32 v69, s74, v68
	v_add_u32_e32 v69, s23, v69
	v_add_lshl_u32 v69, v103, v69, 1
	buffer_load_dwordx4 v[70:73], v69, s[84:87], 0 offen
	v_min_i32_e32 v69, s9, v171
	v_add_u32_e32 v171, 64, v171
	v_add_u32_e32 v172, 64, v172
	s_waitcnt vmcnt(0)
	ds_write_b128 v109, v[70:73]
	v_mul_lo_u32 v70, s74, v69
	v_add_u32_e32 v70, s23, v70
	v_add_lshl_u32 v70, v103, v70, 1
	buffer_load_dwordx4 v[70:73], v70, s[84:87], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v114, v[70:73]
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v67
	v_add_u32_e32 v66, s24, v66
	v_add_lshl_u32 v66, v103, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v137, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v68
	v_add_u32_e32 v66, s24, v66
	v_add_lshl_u32 v66, v103, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v116, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v69
	v_add_u32_e32 v66, s24, v66
	v_add_lshl_u32 v66, v103, v66, 1
	buffer_load_dwordx4 v[66:69], v66, s[88:91], 0 offen
	s_waitcnt vmcnt(1)
	ds_write_b128 v121, v[70:73] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v138, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[82:85], v139 offset1:16
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[198:199], 0
	ds_read_b64 v[82:83], v140
	ds_read2_b64 v[178:181], v176 offset1:16
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[200:201], v[66:81]
	ds_read_b64 v[82:83], v141
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[202:203], v[66:81]
	ds_read_b64 v[82:83], v142
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[204:205], v[66:81]
	ds_read_b64 v[82:83], v143
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[206:207], v[66:81]
	ds_read_b64 v[82:83], v144
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[208:209], v[66:81]
	ds_read_b64 v[82:83], v145
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[210:211], v[66:81]
	ds_read_b64 v[82:83], v146
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[212:213], v[66:81]
	ds_read_b64 v[82:83], v147
	v_mfma_f32_32x32x8_bf16 v[66:81], v[84:85], v[214:215], v[66:81]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[216:217], v[66:81]
	ds_read_b64 v[82:83], v148
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[218:219], v[66:81]
	ds_read_b64 v[82:83], v149
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[220:221], v[66:81]
	ds_read_b64 v[82:83], v150
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[222:223], v[66:81]
	ds_read_b64 v[82:83], v151
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[224:225], v[66:81]
	ds_read_b64 v[82:83], v152
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[226:227], v[66:81]
	ds_read_b64 v[82:83], v153
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[228:229], v[66:81]
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[198:199], 0
	ds_read_b64 v[178:179], v154
	s_nop 8
	v_mul_f32_e64 v66, s16, v66
	v_mul_f32_e64 v67, s17, v67
	v_mul_f32_e64 v68, s16, v68
	v_mul_f32_e64 v69, s17, v69
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[68:69], v[68:69], s[2:3] op_sel_hi:[1,0]
	v_cmp_gt_f32_e32 vcc, v66, v67
	v_pk_mul_f32 v[70:71], s[16:17], v[70:71]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[200:201], v[82:97]
	ds_read_b64 v[178:179], v155
	v_mul_f32_e64 v70, v70, s2
	v_mul_f32_e64 v71, v71, s2
	v_mul_f32_e64 v72, s16, v72
	v_mul_f32_e64 v73, s17, v73
	v_pk_mul_f32 v[74:75], s[16:17], v[74:75]
	v_pk_mul_f32 v[72:73], v[72:73], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[74:75], v[74:75], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[76:77], s[16:17], v[76:77]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[202:203], v[82:97]
	ds_read_b64 v[178:179], v156
	v_mul_f32_e64 v76, v76, s2
	v_mul_f32_e64 v77, v77, s2
	v_mul_f32_e64 v78, s16, v78
	v_mul_f32_e64 v79, s17, v79
	v_pk_mul_f32 v[80:81], s[16:17], v[80:81]
	v_pk_mul_f32 v[78:79], v[78:79], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[80:81], v[80:81], s[2:3] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[204:205], v[82:97]
	ds_read_b64 v[178:179], v157
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[206:207], v[82:97]
	ds_read_b64 v[178:179], v158
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[208:209], v[82:97]
	ds_read_b64 v[178:179], v159
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[210:211], v[82:97]
	ds_read_b64 v[178:179], v160
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[212:213], v[82:97]
	ds_read_b64 v[178:179], v161
	v_mfma_f32_32x32x8_bf16 v[82:97], v[180:181], v[214:215], v[82:97]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[216:217], v[82:97]
	ds_read_b64 v[178:179], v162
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[218:219], v[82:97]
	ds_read_b64 v[178:179], v163
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[220:221], v[82:97]
	ds_read_b64 v[178:179], v164
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[222:223], v[82:97]
	ds_read_b64 v[178:179], v165
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[224:225], v[82:97]
	ds_read_b64 v[178:179], v166
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[226:227], v[82:97]
	ds_read_b64 v[178:179], v167
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[228:229], v[82:97]
	s_nop 10
	v_mul_f32_e32 v96, s83, v96
	v_mul_f32_e32 v177, 0x3fb8aa3b, v96
	v_mul_f32_e32 v96, s83, v97
	v_pk_mul_f32 v[90:91], s[16:17], v[90:91]
	v_mul_f32_e32 v113, 0x3fb8aa3b, v96
	v_pk_mul_f32 v[96:97], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[90:91], s[16:17], v[92:93]
	v_cndmask_b32_e32 v92, v67, v66, vcc
	v_cmp_gt_f32_e32 vcc, v92, v68
	v_pk_mul_f32 v[82:83], s[16:17], v[82:83]
	v_pk_mul_f32 v[84:85], s[16:17], v[84:85]
	v_cndmask_b32_e32 v92, v68, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v69
	v_pk_mul_f32 v[82:83], v[82:83], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[84:85], v[84:85], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v92, v69, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v70
	v_pk_mul_f32 v[86:87], s[16:17], v[86:87]
	v_pk_mul_f32 v[88:89], s[16:17], v[88:89]
	v_cndmask_b32_e32 v92, v70, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v71
	v_pk_mul_f32 v[86:87], v[86:87], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[88:89], v[88:89], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e32 v92, v71, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v72
	v_pk_mul_f32 v[90:91], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[94:95], s[16:17], v[94:95]
	v_cndmask_b32_e32 v92, v72, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v73
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e32 v92, v73, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v74
	s_nop 1
	v_cndmask_b32_e32 v92, v74, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v75
	s_nop 1
	v_cndmask_b32_e32 v92, v75, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v76
	s_nop 1
	v_cndmask_b32_e32 v92, v76, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v77
	s_nop 1
	v_cndmask_b32_e32 v92, v77, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v78
	s_nop 1
	v_cndmask_b32_e32 v92, v78, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v79
	s_nop 1
	v_cndmask_b32_e32 v92, v79, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v80
	s_nop 1
	v_cndmask_b32_e32 v92, v80, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v81
	s_nop 1
	v_cndmask_b32_e32 v92, v81, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v82
	s_nop 1
	v_cndmask_b32_e32 v92, v82, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v83
	s_nop 1
	v_cndmask_b32_e32 v92, v83, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v84
	s_nop 1
	v_cndmask_b32_e32 v92, v84, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v85
	s_nop 1
	v_cndmask_b32_e32 v92, v85, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v86
	s_nop 1
	v_cndmask_b32_e32 v92, v86, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v87
	s_nop 1
	v_cndmask_b32_e32 v92, v87, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v88
	s_nop 1
	v_cndmask_b32_e32 v92, v88, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v89
	s_nop 1
	v_cndmask_b32_e32 v92, v89, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v96
	s_nop 1
	v_cndmask_b32_e32 v92, v96, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v97
	s_nop 1
	v_cndmask_b32_e32 v92, v97, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v90
	s_nop 1
	v_cndmask_b32_e32 v92, v90, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v91
	s_nop 1
	v_cndmask_b32_e32 v92, v91, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v94
	s_nop 1
	v_cndmask_b32_e32 v92, v94, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v95
	s_nop 1
	v_cndmask_b32_e32 v92, v95, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v177
	s_nop 1
	v_cndmask_b32_e32 v92, v177, v92, vcc
	v_cmp_gt_f32_e32 vcc, v92, v113
	s_nop 1
	v_cndmask_b32_e32 v92, v113, v92, vcc
	ds_bpermute_b32 v93, v168, v92
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e32 vcc, v92, v93
	s_nop 1
	v_cndmask_b32_e32 v92, v93, v92, vcc
	v_cmp_gt_f32_e32 vcc, v112, v92
	s_nop 1
	v_cndmask_b32_e32 v108, v92, v112, vcc
	v_pk_add_f32 v[66:67], v[66:67], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v92, 0, v174, vcc
	v_add_f32_e32 v67, v67, v92
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v92, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v92, v67, v92
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v93, v66, v67
	v_pk_add_f32 v[66:67], v[68:69], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v68, 0, v174, vcc
	v_add_f32_e32 v67, v67, v68
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v68, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v68, v67, v68
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v69, v66, v67
	v_pk_add_f32 v[66:67], v[70:71], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v70, 0, v174, vcc
	v_add_f32_e32 v67, v67, v70
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v70, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v70, v67, v70
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v71, v66, v67
	v_pk_add_f32 v[66:67], v[72:73], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v72, 0, v174, vcc
	v_add_f32_e32 v67, v67, v72
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v72, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v72, v67, v72
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v73, v66, v67
	v_pk_add_f32 v[66:67], v[74:75], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v74, 0, v174, vcc
	v_add_f32_e32 v67, v67, v74
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v74, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v74, v67, v74
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v75, v66, v67
	v_pk_add_f32 v[66:67], v[76:77], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v76, 0, v174, vcc
	v_add_f32_e32 v67, v67, v76
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v76, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v76, v67, v76
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v77, v66, v67
	v_pk_add_f32 v[66:67], v[78:79], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v78, 0, v174, vcc
	v_add_f32_e32 v67, v67, v78
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v78, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v78, v67, v78
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v79, v66, v67
	v_pk_add_f32 v[66:67], v[80:81], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v80, 0, v174, vcc
	v_add_f32_e32 v67, v67, v80
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v80, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v80, v67, v80
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v81, v66, v67
	v_pk_add_f32 v[66:67], v[82:83], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v82, 0, v174, vcc
	v_add_f32_e32 v67, v67, v82
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v82, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v82, v67, v82
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v83, v66, v67
	v_pk_add_f32 v[66:67], v[84:85], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v84, 0, v174, vcc
	v_add_f32_e32 v67, v67, v84
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v84, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v84, v67, v84
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v85, v66, v67
	v_pk_add_f32 v[66:67], v[86:87], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v86, 0, v174, vcc
	v_add_f32_e32 v67, v67, v86
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v86, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v86, v67, v86
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v87, v66, v67
	v_pk_add_f32 v[66:67], v[88:89], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v88, 0, v174, vcc
	v_add_f32_e32 v67, v67, v88
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v88, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v88, v67, v88
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v89, v66, v67
	v_pk_add_f32 v[66:67], v[96:97], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v96, 0, v174, vcc
	v_add_f32_e32 v67, v67, v96
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v96, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v96, v67, v96
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v97, v66, v67
	v_pk_add_f32 v[66:67], v[90:91], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v90, 0, v174, vcc
	v_add_f32_e32 v67, v67, v90
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v90, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v90, v67, v90
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v91, v66, v67
	v_pk_add_f32 v[66:67], v[94:95], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v67
	s_nop 1
	v_cndmask_b32_e32 v94, 0, v174, vcc
	v_add_f32_e32 v67, v67, v94
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v94, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v66
	v_ldexp_f32 v94, v67, v94
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v95, v66, v67
	v_sub_f32_e32 v66, v177, v108
	v_cmp_gt_f32_e32 vcc, s5, v66
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v175, vcc
	v_ldexp_f32 v177, v66, v67
	v_add_f32_e32 v66, v93, v92
	v_add_f32_e32 v66, v69, v66
	v_add_f32_e32 v66, v68, v66
	v_add_f32_e32 v66, v71, v66
	v_add_f32_e32 v66, v70, v66
	v_add_f32_e32 v66, v73, v66
	v_add_f32_e32 v66, v72, v66
	v_add_f32_e32 v66, v75, v66
	v_add_f32_e32 v66, v74, v66
	v_add_f32_e32 v66, v77, v66
	v_add_f32_e32 v66, v76, v66
	v_add_f32_e32 v66, v79, v66
	v_add_f32_e32 v66, v78, v66
	v_add_f32_e32 v66, v81, v66
	v_add_f32_e32 v66, v80, v66
	v_add_f32_e32 v66, v83, v66
	v_add_f32_e32 v66, v82, v66
	v_add_f32_e32 v66, v85, v66
	v_add_f32_e32 v66, v84, v66
	v_add_f32_e32 v66, v87, v66
	v_add_f32_e32 v66, v86, v66
	v_add_f32_e32 v66, v89, v66
	v_add_f32_e32 v66, v88, v66
	v_add_f32_e32 v66, v97, v66
	v_add_f32_e32 v66, v96, v66
	v_add_f32_e32 v66, v91, v66
	v_add_f32_e32 v66, v90, v66
	v_add_f32_e32 v66, v95, v66
	v_add_f32_e32 v66, v94, v66
	v_add_f32_e32 v178, v177, v66
	v_pk_add_f32 v[66:67], v[112:113], v[108:109] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s5, v66
	s_nop 1
	v_cndmask_b32_e32 v112, 0, v174, vcc
	v_add_f32_e32 v66, v66, v112
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v112, 0, v175, vcc
	v_cmp_gt_f32_e32 vcc, s5, v67
	v_ldexp_f32 v66, v66, v112
	s_nop 0
	v_cndmask_b32_e32 v112, 0, v174, vcc
	v_add_f32_e32 v67, v67, v112
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v112, 0, v175, vcc
	v_cmp_u_f32_e32 vcc, v93, v93
	v_ldexp_f32 v112, v67, v112
	v_add_f32_e32 v67, v178, v112
	ds_bpermute_b32 v113, v168, v67
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v67, v67, v113
	v_mul_f32_e32 v113, v129, v66
	v_pk_mul_f32 v[48:49], v[48:49], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[46:47], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[42:43], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[40:41], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[38:39], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[36:37], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[64:65], v[64:65], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[62:63], v[62:63], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[60:61], v[60:61], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[58:59], v[58:59], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[56:57], v[56:57], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[54:55], v[54:55], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[52:53], v[52:53], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[50:51], v[50:51], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[66:67] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[66:67] op_sel_hi:[1,0]
	v_bfe_u32 v66, v93, 16, 1
	v_add_f32_e32 v129, v113, v67
	v_add3_u32 v66, v66, v93, s7
	v_or_b32_e32 v67, 0x400000, v93
	v_cndmask_b32_e32 v93, v66, v67, vcc
	v_bfe_u32 v66, v92, 16, 1
	v_add3_u32 v66, v66, v92, s7
	v_or_b32_e32 v67, 0x400000, v92
	v_cmp_u_f32_e32 vcc, v92, v92
	s_nop 1
	v_cndmask_b32_e32 v92, v66, v67, vcc
	v_bfe_u32 v66, v69, 16, 1
	v_add3_u32 v66, v66, v69, s7
	v_or_b32_e32 v67, 0x400000, v69
	v_cmp_u_f32_e32 vcc, v69, v69
	s_nop 1
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v68, 16, 1
	v_add3_u32 v66, v66, v68, s7
	v_or_b32_e32 v67, 0x400000, v68
	v_cmp_u_f32_e32 vcc, v68, v68
	s_nop 1
	v_cndmask_b32_e32 v68, v66, v67, vcc
	ds_read_u16 v66, v169
	ds_read_u16 v113, v169 offset:256
	ds_read_u16 v67, v169 offset:512
	ds_read_u16 v178, v169 offset:768
	v_perm_b32 v69, v68, v69, s26
	v_perm_b32 v68, v92, v93, s26
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v113, v66, s25
	v_cmp_u_f32_e32 vcc, v71, v71
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v178, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:64
	ds_read_u16 v92, v169 offset:320
	ds_read_u16 v67, v169 offset:576
	ds_read_u16 v93, v169 offset:832
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v92, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v93, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:128
	ds_read_u16 v92, v169 offset:384
	ds_read_u16 v67, v169 offset:640
	ds_read_u16 v93, v169 offset:896
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v92, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v93, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:192
	ds_read_u16 v92, v169 offset:448
	ds_read_u16 v67, v169 offset:704
	ds_read_u16 v93, v169 offset:960
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v92, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v93, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v71, 16, 1
	v_add3_u32 v66, v66, v71, s7
	v_or_b32_e32 v67, 0x400000, v71
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v70, 16, 1
	v_add3_u32 v66, v66, v70, s7
	v_or_b32_e32 v67, 0x400000, v70
	v_cmp_u_f32_e32 vcc, v70, v70
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v73, 16, 1
	v_add3_u32 v66, v66, v73, s7
	v_or_b32_e32 v67, 0x400000, v73
	v_cmp_u_f32_e32 vcc, v73, v73
	v_perm_b32 v68, v70, v68, s26
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v72, 16, 1
	v_add3_u32 v66, v66, v72, s7
	v_or_b32_e32 v67, 0x400000, v72
	v_cmp_u_f32_e32 vcc, v72, v72
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v169 offset:2048
	ds_read_u16 v72, v169 offset:2304
	ds_read_u16 v67, v169 offset:2560
	ds_read_u16 v73, v169 offset:2816
	v_perm_b32 v69, v71, v69, s26
	v_cmp_u_f32_e32 vcc, v75, v75
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:2112
	ds_read_u16 v70, v169 offset:2368
	ds_read_u16 v67, v169 offset:2624
	ds_read_u16 v71, v169 offset:2880
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:2176
	ds_read_u16 v70, v169 offset:2432
	ds_read_u16 v67, v169 offset:2688
	ds_read_u16 v71, v169 offset:2944
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:2240
	ds_read_u16 v70, v169 offset:2496
	ds_read_u16 v67, v169 offset:2752
	ds_read_u16 v71, v169 offset:3008
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v75, 16, 1
	v_add3_u32 v66, v66, v75, s7
	v_or_b32_e32 v67, 0x400000, v75
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v74, 16, 1
	v_add3_u32 v66, v66, v74, s7
	v_or_b32_e32 v67, 0x400000, v74
	v_cmp_u_f32_e32 vcc, v74, v74
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v77, 16, 1
	v_add3_u32 v66, v66, v77, s7
	v_or_b32_e32 v67, 0x400000, v77
	v_cmp_u_f32_e32 vcc, v77, v77
	v_perm_b32 v68, v70, v68, s26
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v76, 16, 1
	v_add3_u32 v66, v66, v76, s7
	v_or_b32_e32 v67, 0x400000, v76
	v_cmp_u_f32_e32 vcc, v76, v76
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v169 offset:4096
	ds_read_u16 v72, v169 offset:4352
	ds_read_u16 v67, v169 offset:4608
	ds_read_u16 v73, v169 offset:4864
	v_perm_b32 v69, v71, v69, s26
	v_cmp_u_f32_e32 vcc, v79, v79
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:4160
	ds_read_u16 v70, v169 offset:4416
	ds_read_u16 v67, v169 offset:4672
	ds_read_u16 v71, v169 offset:4928
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:4224
	ds_read_u16 v70, v169 offset:4480
	ds_read_u16 v67, v169 offset:4736
	ds_read_u16 v71, v169 offset:4992
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:4288
	ds_read_u16 v70, v169 offset:4544
	ds_read_u16 v67, v169 offset:4800
	ds_read_u16 v71, v169 offset:5056
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v79, 16, 1
	v_add3_u32 v66, v66, v79, s7
	v_or_b32_e32 v67, 0x400000, v79
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v78, 16, 1
	v_add3_u32 v66, v66, v78, s7
	v_or_b32_e32 v67, 0x400000, v78
	v_cmp_u_f32_e32 vcc, v78, v78
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v81, 16, 1
	v_add3_u32 v66, v66, v81, s7
	v_or_b32_e32 v67, 0x400000, v81
	v_cmp_u_f32_e32 vcc, v81, v81
	v_perm_b32 v68, v70, v68, s26
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v80, 16, 1
	v_add3_u32 v66, v66, v80, s7
	v_or_b32_e32 v67, 0x400000, v80
	v_cmp_u_f32_e32 vcc, v80, v80
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v169 offset:6144
	ds_read_u16 v72, v169 offset:6400
	ds_read_u16 v67, v169 offset:6656
	ds_read_u16 v73, v169 offset:6912
	v_perm_b32 v69, v71, v69, s26
	v_cmp_u_f32_e32 vcc, v83, v83
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:6208
	ds_read_u16 v70, v169 offset:6464
	ds_read_u16 v67, v169 offset:6720
	ds_read_u16 v71, v169 offset:6976
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:6272
	ds_read_u16 v70, v169 offset:6528
	ds_read_u16 v67, v169 offset:6784
	ds_read_u16 v71, v169 offset:7040
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:6336
	ds_read_u16 v70, v169 offset:6592
	ds_read_u16 v67, v169 offset:6848
	ds_read_u16 v71, v169 offset:7104
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v83, 16, 1
	v_add3_u32 v66, v66, v83, s7
	v_or_b32_e32 v67, 0x400000, v83
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v82, 16, 1
	v_add3_u32 v66, v66, v82, s7
	v_or_b32_e32 v67, 0x400000, v82
	v_cmp_u_f32_e32 vcc, v82, v82
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v85, 16, 1
	v_add3_u32 v66, v66, v85, s7
	v_or_b32_e32 v67, 0x400000, v85
	v_cmp_u_f32_e32 vcc, v85, v85
	v_perm_b32 v68, v70, v68, s26
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v84, 16, 1
	v_add3_u32 v66, v66, v84, s7
	v_or_b32_e32 v67, 0x400000, v84
	v_cmp_u_f32_e32 vcc, v84, v84
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v169 offset:8192
	ds_read_u16 v72, v169 offset:8448
	ds_read_u16 v67, v169 offset:8704
	ds_read_u16 v73, v169 offset:8960
	v_perm_b32 v69, v71, v69, s26
	v_cmp_u_f32_e32 vcc, v87, v87
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:8256
	ds_read_u16 v70, v169 offset:8512
	ds_read_u16 v67, v169 offset:8768
	ds_read_u16 v71, v169 offset:9024
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:8320
	ds_read_u16 v70, v169 offset:8576
	ds_read_u16 v67, v169 offset:8832
	ds_read_u16 v71, v169 offset:9088
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:8384
	ds_read_u16 v70, v169 offset:8640
	ds_read_u16 v67, v169 offset:8896
	ds_read_u16 v71, v169 offset:9152
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v87, 16, 1
	v_add3_u32 v66, v66, v87, s7
	v_or_b32_e32 v67, 0x400000, v87
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v86, 16, 1
	v_add3_u32 v66, v66, v86, s7
	v_or_b32_e32 v67, 0x400000, v86
	v_cmp_u_f32_e32 vcc, v86, v86
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v89, 16, 1
	v_add3_u32 v66, v66, v89, s7
	v_or_b32_e32 v67, 0x400000, v89
	v_cmp_u_f32_e32 vcc, v89, v89
	v_perm_b32 v68, v70, v68, s26
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v88, 16, 1
	v_add3_u32 v66, v66, v88, s7
	v_or_b32_e32 v67, 0x400000, v88
	v_cmp_u_f32_e32 vcc, v88, v88
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v169 offset:10240
	ds_read_u16 v72, v169 offset:10496
	ds_read_u16 v67, v169 offset:10752
	ds_read_u16 v73, v169 offset:11008
	v_perm_b32 v69, v71, v69, s26
	v_cmp_u_f32_e32 vcc, v97, v97
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:10304
	ds_read_u16 v70, v169 offset:10560
	ds_read_u16 v67, v169 offset:10816
	ds_read_u16 v71, v169 offset:11072
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:10368
	ds_read_u16 v70, v169 offset:10624
	ds_read_u16 v67, v169 offset:10880
	ds_read_u16 v71, v169 offset:11136
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:10432
	ds_read_u16 v70, v169 offset:10688
	ds_read_u16 v67, v169 offset:10944
	ds_read_u16 v71, v169 offset:11200
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v97, 16, 1
	v_add3_u32 v66, v66, v97, s7
	v_or_b32_e32 v67, 0x400000, v97
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v96, 16, 1
	v_add3_u32 v66, v66, v96, s7
	v_or_b32_e32 v67, 0x400000, v96
	v_cmp_u_f32_e32 vcc, v96, v96
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v91, 16, 1
	v_add3_u32 v66, v66, v91, s7
	v_or_b32_e32 v67, 0x400000, v91
	v_cmp_u_f32_e32 vcc, v91, v91
	v_perm_b32 v68, v70, v68, s26
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v90, 16, 1
	v_add3_u32 v66, v66, v90, s7
	v_or_b32_e32 v67, 0x400000, v90
	v_cmp_u_f32_e32 vcc, v90, v90
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v169 offset:12288
	ds_read_u16 v72, v169 offset:12544
	ds_read_u16 v67, v169 offset:12800
	ds_read_u16 v73, v169 offset:13056
	v_perm_b32 v69, v71, v69, s26
	v_cmp_u_f32_e32 vcc, v95, v95
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:12352
	ds_read_u16 v70, v169 offset:12608
	ds_read_u16 v67, v169 offset:12864
	ds_read_u16 v71, v169 offset:13120
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:12416
	ds_read_u16 v70, v169 offset:12672
	ds_read_u16 v67, v169 offset:12928
	ds_read_u16 v71, v169 offset:13184
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:12480
	ds_read_u16 v70, v169 offset:12736
	ds_read_u16 v67, v169 offset:12992
	ds_read_u16 v71, v169 offset:13248
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v95, 16, 1
	v_add3_u32 v66, v66, v95, s7
	v_or_b32_e32 v67, 0x400000, v95
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v94, 16, 1
	v_add3_u32 v66, v66, v94, s7
	v_or_b32_e32 v67, 0x400000, v94
	v_cmp_u_f32_e32 vcc, v94, v94
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v177, 16, 1
	v_add3_u32 v66, v66, v177, s7
	v_or_b32_e32 v67, 0x400000, v177
	v_cmp_u_f32_e32 vcc, v177, v177
	v_perm_b32 v68, v70, v68, s26
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v112, 16, 1
	v_add3_u32 v66, v66, v112, s7
	v_or_b32_e32 v67, 0x400000, v112
	v_cmp_u_f32_e32 vcc, v112, v112
	v_mov_b32_e32 v112, v108
	s_nop 0
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v169 offset:14336
	ds_read_u16 v72, v169 offset:14592
	ds_read_u16 v67, v169 offset:14848
	ds_read_u16 v73, v169 offset:15104
	v_perm_b32 v69, v71, v69, s26
	v_cmp_lt_i64_e32 vcc, s[14:15], v[110:111]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s25
	s_and_b64 vcc, exec, vcc
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v169 offset:14400
	ds_read_u16 v70, v169 offset:14656
	ds_read_u16 v67, v169 offset:14912
	ds_read_u16 v71, v169 offset:15168
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v169 offset:14464
	ds_read_u16 v70, v169 offset:14720
	ds_read_u16 v67, v169 offset:14976
	ds_read_u16 v71, v169 offset:15232
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v169 offset:14528
	ds_read_u16 v70, v169 offset:14784
	ds_read_u16 v67, v169 offset:15040
	ds_read_u16 v71, v169 offset:15296
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s25
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s25
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	s_cbranch_vccnz .LBB0_3
	s_cmp_ge_i32 s78, s8
	s_cbranch_scc0 .LBB0_6
	s_branch .LBB0_9
.LBB0_5:
	v_mov_b32_e32 v35, v34
	v_mov_b32_e32 v36, v34
	v_mov_b32_e32 v37, v34
	v_mov_b32_e32 v38, v34
	v_mov_b32_e32 v39, v34
	v_mov_b32_e32 v40, v34
	v_mov_b32_e32 v41, v34
	v_mov_b32_e32 v42, v34
	v_mov_b32_e32 v43, v34
	v_mov_b32_e32 v44, v34
	v_mov_b32_e32 v45, v34
	v_mov_b32_e32 v46, v34
	v_mov_b32_e32 v47, v34
	v_mov_b32_e32 v48, v34
	v_mov_b32_e32 v49, v34
	v_mov_b32_e32 v108, 0xf149f2ca
	v_mov_b32_e32 v129, 0
	v_mov_b64_e32 v[2:3], v[34:35]
	v_mov_b64_e32 v[4:5], v[36:37]
	v_mov_b64_e32 v[6:7], v[38:39]
	v_mov_b64_e32 v[8:9], v[40:41]
	v_mov_b64_e32 v[10:11], v[42:43]
	v_mov_b64_e32 v[12:13], v[44:45]
	v_mov_b64_e32 v[14:15], v[46:47]
	v_mov_b64_e32 v[16:17], v[48:49]
	v_mov_b64_e32 v[18:19], v[34:35]
	v_mov_b64_e32 v[20:21], v[36:37]
	v_mov_b64_e32 v[22:23], v[38:39]
	v_mov_b64_e32 v[24:25], v[40:41]
	v_mov_b64_e32 v[26:27], v[42:43]
	v_mov_b64_e32 v[28:29], v[44:45]
	v_mov_b64_e32 v[30:31], v[46:47]
	v_mov_b64_e32 v[32:33], v[48:49]
	v_mov_b64_e32 v[64:65], v[48:49]
	v_mov_b64_e32 v[62:63], v[46:47]
	v_mov_b64_e32 v[60:61], v[44:45]
	v_mov_b64_e32 v[58:59], v[42:43]
	v_mov_b64_e32 v[56:57], v[40:41]
	v_mov_b64_e32 v[54:55], v[38:39]
	v_mov_b64_e32 v[52:53], v[36:37]
	v_mov_b64_e32 v[50:51], v[34:35]
	s_cmp_ge_i32 s78, s8
	s_cbranch_scc1 .LBB0_9
.LBB0_6:
	v_xor_b32_e32 v66, v99, v101
	s_movk_i32 s2, 0xf0
	v_and_or_b32 v67, v0, s2, v66
	v_lshlrev_b32_e32 v138, 4, v67
	v_or_b32_e32 v67, 0x100, v0
	s_movk_i32 s2, 0x1f0
	v_and_or_b32 v68, v67, s2, v66
	v_lshlrev_b32_e32 v139, 4, v68
	v_or_b32_e32 v68, 0x200, v0
	s_movk_i32 s2, 0x2f0
	v_and_or_b32 v69, v68, s2, v66
	v_or_b32_e32 v0, 0x300, v0
	s_movk_i32 s2, 0x3f0
	v_and_or_b32 v66, v0, s2, v66
	v_lshlrev_b32_e32 v141, 4, v66
	v_and_b32_e32 v66, 56, v1
	v_lshlrev_b32_e32 v144, 4, v0
	v_or_b32_e32 v0, v120, v66
	v_lshlrev_b32_e32 v142, 4, v67
	v_lshlrev_b32_e32 v145, 1, v0
	v_or_b32_e32 v0, 8, v120
	v_or_b32_e32 v67, 0x1008, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v146, 1, v0
	v_or_b32_e32 v0, 16, v120
	v_lshlrev_b32_e32 v161, 1, v67
	v_or_b32_e32 v67, 0x1010, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v147, 1, v0
	v_or_b32_e32 v0, 24, v120
	v_lshlrev_b32_e32 v162, 1, v67
	v_or_b32_e32 v67, 0x1018, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v148, 1, v0
	v_or_b32_e32 v0, 32, v120
	v_lshlrev_b32_e32 v163, 1, v67
	v_or_b32_e32 v67, 0x1020, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v149, 1, v0
	v_or_b32_e32 v0, 40, v120
	v_lshlrev_b32_e32 v164, 1, v67
	v_or_b32_e32 v67, 0x1028, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v150, 1, v0
	v_or_b32_e32 v0, 48, v120
	v_lshlrev_b32_e32 v165, 1, v67
	v_or_b32_e32 v67, 0x1030, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v151, 1, v0
	v_or_b32_e32 v0, 56, v120
	v_lshlrev_b32_e32 v166, 1, v67
	v_or_b32_e32 v67, 0x1038, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v152, 1, v0
	v_or_b32_e32 v0, 0x48, v120
	v_lshlrev_b32_e32 v167, 1, v67
	v_or_b32_e32 v67, 0x1048, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v153, 1, v0
	v_or_b32_e32 v0, 0x50, v120
	v_lshlrev_b32_e32 v168, 1, v67
	v_or_b32_e32 v67, 0x1050, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v154, 1, v0
	v_or_b32_e32 v0, 0x58, v120
	v_lshlrev_b32_e32 v169, 1, v67
	v_or_b32_e32 v67, 0x1058, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v155, 1, v0
	v_or_b32_e32 v0, 0x60, v120
	v_lshlrev_b32_e32 v170, 1, v67
	v_or_b32_e32 v67, 0x1060, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	v_lshlrev_b32_e32 v156, 1, v0
	v_or_b32_e32 v0, 0x68, v120
	v_lshlrev_b32_e32 v171, 1, v67
	v_or_b32_e32 v67, 0x1068, v120
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	s_movk_i32 s2, 0x4000
	s_ashr_i32 s9, s8, 31
	s_add_i32 s72, s82, -1
	s_add_u32 s73, s21, s22
	s_add_u32 s75, s11, s20
	v_lshlrev_b32_e32 v157, 1, v0
	v_or_b32_e32 v0, 0x70, v120
	v_lshlrev_b32_e32 v172, 1, v67
	v_or_b32_e32 v67, 0x1070, v120
	v_or3_b32 v176, v118, v119, s2
	s_ashr_i32 s2, s19, 31
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v67, v67, v66
	s_and_b64 s[12:13], s[12:13], exec
	v_lshlrev_b32_e32 v158, 1, v0
	v_or_b32_e32 v0, 0x78, v120
	v_lshlrev_b32_e32 v173, 1, v67
	v_or_b32_e32 v67, 0x1078, v120
	s_cselect_b64 s[12:13], 1, 0
	v_xor_b32_e32 v0, v0, v66
	v_xor_b32_e32 v66, v67, v66
	s_sub_u32 s12, s19, s12
	v_lshlrev_b32_e32 v174, 1, v66
	v_lshlrev_b32_e32 v66, 2, v117
	s_subb_u32 s13, s2, s13
	v_xor_b32_e32 v175, 0x80, v66
	s_mov_b32 s11, 0
	v_mov_b64_e32 v[66:67], s[12:13]
	v_cmp_lt_i64_e32 vcc, s[10:11], v[66:67]
	s_and_b64 s[14:15], vcc, exec
	s_cselect_b32 s2, 0, s13
	s_cselect_b32 s12, s10, s12
	s_ashr_i32 s5, s4, 31
	v_lshlrev_b32_e32 v140, 4, v69
	v_lshlrev_b32_e32 v143, 4, v68
	s_ashr_i32 s7, s6, 31
	v_mov_b64_e32 v[68:69], s[4:5]
	v_cmp_lt_i64_e32 vcc, s[6:7], v[68:69]
	s_and_b64 s[10:11], vcc, exec
	v_mov_b32_e32 v66, s12
	v_mov_b32_e32 v67, s2
	s_cselect_b32 s5, s7, s5
	s_cselect_b32 s4, s6, s4
	v_cmp_lt_i64_e32 vcc, s[4:5], v[66:67]
	s_and_b64 s[6:7], vcc, exec
	s_mov_b32 s10, s5
	s_mov_b32 s11, s5
	s_cselect_b32 s7, s5, s2
	s_cselect_b32 s6, s4, s12
	s_and_b64 s[4:5], s[4:5], s[10:11]
	v_mov_b64_e32 v[66:67], s[4:5]
	v_cmp_gt_i64_e32 vcc, s[6:7], v[66:67]
	s_and_b64 s[10:11], vcc, exec
	v_lshlrev_b32_e32 v159, 1, v0
	v_add_u32_e32 v0, s18, v135
	s_cselect_b32 s2, s6, s4
	v_lshlrev_b32_e32 v113, 3, v101
	v_or_b32_e32 v160, 1, v106
	v_or_b32_e32 v1, 3, v106
	v_or_b32_e32 v110, 2, v106
	v_or_b32_e32 v99, 9, v106
	v_or_b32_e32 v101, 11, v106
	v_or_b32_e32 v112, 10, v106
	v_or_b32_e32 v103, 17, v106
	v_or_b32_e32 v105, 19, v106
	v_or_b32_e32 v114, 18, v106
	v_or_b32_e32 v107, 25, v106
	v_or_b32_e32 v109, 27, v106
	v_or_b32_e32 v116, 26, v106
	s_mov_b32 s76, s82
	s_mov_b32 s77, s82
	v_mov_b32_e32 v111, v0
	s_mov_b32 s82, s83
	s_lshl_b32 s80, s2, 6
	v_or_b32_e32 v177, 48, v136
	v_or_b32_e32 v178, 32, v136
	v_or_b32_e32 v179, 16, v136
	s_mov_b32 s2, 0x3fb8aa3b
	v_mov_b32_e32 v180, 0xf149f2ca
	s_mov_b32 s92, 0xc2fc0000
	v_mov_b32_e32 v181, 0x42800000
	v_not_b32_e32 v182, 63
	s_movk_i32 s93, 0x7fff
	s_mov_b32 s95, 0x5040100
	s_mov_b32 s96, 0x7060302
	v_mov_b64_e32 v[118:119], s[8:9]
	s_mov_b32 s90, s86
	s_mov_b32 s91, s87
	v_add_u32_e32 v183, 0x2000, v145
.LBB0_7:
	v_add_u32_e32 v66, s80, v136
	v_min_i32_e32 v66, s72, v66
	v_mul_lo_u32 v67, s74, v66
	v_add_u32_e32 v67, s73, v67
	v_add_lshl_u32 v67, v113, v67, 1
	s_barrier
	buffer_load_dwordx4 v[68:71], v67, s[84:87], 0 offen
	v_add_u32_e32 v67, s80, v179
	v_min_i32_e32 v67, s72, v67
	v_mul_lo_u32 v66, s94, v66
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v113, v66, 1
	s_add_i32 s34, s80, 32
	s_waitcnt vmcnt(0)
	ds_write_b128 v138, v[68:71]
	v_mul_lo_u32 v68, s74, v67
	v_add_u32_e32 v68, s73, v68
	v_add_lshl_u32 v68, v113, v68, 1
	buffer_load_dwordx4 v[68:71], v68, s[84:87], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v139, v[68:71]
	v_add_u32_e32 v68, s80, v178
	v_min_i32_e32 v68, s72, v68
	v_mul_lo_u32 v69, s74, v68
	v_add_u32_e32 v69, s73, v69
	v_add_lshl_u32 v69, v113, v69, 1
	buffer_load_dwordx4 v[70:73], v69, s[84:87], 0 offen
	v_add_u32_e32 v69, s80, v177
	v_min_i32_e32 v69, s72, v69
	s_waitcnt vmcnt(0)
	ds_write_b128 v140, v[70:73]
	v_mul_lo_u32 v70, s74, v69
	v_add_u32_e32 v70, s73, v70
	v_add_lshl_u32 v70, v113, v70, 1
	buffer_load_dwordx4 v[70:73], v70, s[84:87], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v141, v[70:73]
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v67
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v113, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v137, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v68
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v113, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v142, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[88:91], 0 offen
	v_mul_lo_u32 v66, s94, v69
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v113, v66, 1
	buffer_load_dwordx4 v[66:69], v66, s[88:91], 0 offen
	s_waitcnt vmcnt(1)
	ds_write_b128 v143, v[70:73] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v144, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[82:85], v145 offset1:16
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[198:199], 0
	ds_read_b64 v[82:83], v146
	ds_read_b64 v[120:121], v161
	ds_read2_b64 v[184:187], v183 offset1:16
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[200:201], v[66:81]
	ds_read_b64 v[82:83], v147
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[202:203], v[66:81]
	ds_read_b64 v[82:83], v148
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[204:205], v[66:81]
	ds_read_b64 v[82:83], v149
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[206:207], v[66:81]
	ds_read_b64 v[82:83], v150
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[208:209], v[66:81]
	ds_read_b64 v[82:83], v151
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[210:211], v[66:81]
	ds_read_b64 v[82:83], v152
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[212:213], v[66:81]
	ds_read_b64 v[82:83], v153
	v_mfma_f32_32x32x8_bf16 v[66:81], v[84:85], v[214:215], v[66:81]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[216:217], v[66:81]
	ds_read_b64 v[82:83], v154
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[218:219], v[66:81]
	ds_read_b64 v[82:83], v155
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[220:221], v[66:81]
	ds_read_b64 v[82:83], v156
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[222:223], v[66:81]
	ds_read_b64 v[82:83], v157
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[224:225], v[66:81]
	ds_read_b64 v[82:83], v158
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[226:227], v[66:81]
	ds_read_b64 v[82:83], v159
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[228:229], v[66:81]
	v_mfma_f32_32x32x8_bf16 v[82:97], v[184:185], v[198:199], 0
	v_or_b32_e32 v184, s34, v109
	v_or_b32_e32 v185, s34, v116
	s_nop 7
	v_mul_f32_e64 v66, s82, v66
	v_mul_f32_e64 v67, s83, v67
	v_mul_f32_e64 v70, s82, v70
	v_mul_f32_e64 v71, s83, v71
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[70:71], v[70:71], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[72:73], s[82:83], v[72:73]
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[200:201], v[82:97]
	ds_read_b64 v[120:121], v162
	v_mul_f32_e64 v72, v72, s2
	v_mul_f32_e64 v73, v73, s2
	v_mul_f32_e64 v74, s82, v74
	v_mul_f32_e64 v75, s83, v75
	v_pk_mul_f32 v[76:77], s[82:83], v[76:77]
	v_pk_mul_f32 v[74:75], v[74:75], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[76:77], v[76:77], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[78:79], s[82:83], v[78:79]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[202:203], v[82:97]
	ds_read_b64 v[120:121], v163
	v_mul_f32_e64 v78, v78, s2
	v_mul_f32_e64 v79, v79, s2
	v_mul_f32_e64 v80, s82, v80
	v_mul_f32_e64 v81, s83, v81
	v_pk_mul_f32 v[80:81], v[80:81], s[2:3] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[204:205], v[82:97]
	ds_read_b64 v[120:121], v164
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[206:207], v[82:97]
	ds_read_b64 v[120:121], v165
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[208:209], v[82:97]
	ds_read_b64 v[120:121], v166
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[210:211], v[82:97]
	ds_read_b64 v[120:121], v167
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[212:213], v[82:97]
	ds_read_b64 v[120:121], v168
	v_mfma_f32_32x32x8_bf16 v[82:97], v[186:187], v[214:215], v[82:97]
	v_or_b32_e32 v186, s80, v110
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[216:217], v[82:97]
	ds_read_b64 v[120:121], v169
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[218:219], v[82:97]
	ds_read_b64 v[120:121], v170
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[220:221], v[82:97]
	ds_read_b64 v[120:121], v171
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[222:223], v[82:97]
	ds_read_b64 v[120:121], v172
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[224:225], v[82:97]
	ds_read_b64 v[120:121], v173
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[226:227], v[82:97]
	ds_read_b64 v[120:121], v174
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[120:121], v[228:229], v[82:97]
	v_or_b32_e32 v120, s34, v107
	v_or_b32_e32 v121, s34, v100
	v_cmp_gt_i32_e32 vcc, s77, v120
	v_cmp_gt_i32_e64 s[4:5], s76, v121
	v_sub_u32_e32 v121, v121, v0
	v_sub_u32_e32 v120, v120, v111
	v_cmp_gt_i32_e64 s[6:7], 1, v120
	s_nop 3
	v_pk_mul_f32 v[94:95], s[82:83], v[94:95]
	v_cmp_gt_i32_e64 s[8:9], 1, v121
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	s_and_b64 s[66:67], s[4:5], s[8:9]
	s_and_b64 s[6:7], vcc, s[6:7]
	v_cndmask_b32_e64 v121, v180, v95, s[6:7]
	v_cndmask_b32_e64 v120, v180, v94, s[66:67]
	v_pk_mul_f32 v[94:95], s[82:83], v[96:97]
	v_sub_u32_e32 v96, v185, v0
	v_sub_u32_e32 v97, v184, v111
	v_cmp_gt_i32_e64 s[4:5], s77, v184
	v_cmp_gt_i32_e32 vcc, s76, v185
	v_cmp_gt_i32_e64 s[8:9], 1, v97
	v_cmp_gt_i32_e64 s[10:11], 1, v96
	v_or_b32_e32 v96, s34, v103
	v_or_b32_e32 v97, s34, v102
	s_and_b64 vcc, vcc, s[10:11]
	s_and_b64 s[4:5], s[4:5], s[8:9]
	v_cmp_gt_i32_e64 s[8:9], s77, v96
	v_cmp_gt_i32_e64 s[10:11], s76, v97
	v_sub_u32_e32 v97, v97, v0
	v_sub_u32_e32 v96, v96, v111
	v_pk_mul_f32 v[90:91], s[82:83], v[90:91]
	v_cmp_gt_i32_e64 s[12:13], 1, v96
	v_cmp_gt_i32_e64 s[14:15], 1, v97
	v_pk_mul_f32 v[90:91], v[90:91], s[2:3] op_sel_hi:[1,0]
	s_and_b64 s[10:11], s[10:11], s[14:15]
	s_and_b64 s[14:15], s[8:9], s[12:13]
	v_or_b32_e32 v184, s34, v105
	v_or_b32_e32 v185, s34, v114
	v_cndmask_b32_e64 v97, v180, v91, s[14:15]
	v_cndmask_b32_e64 v96, v180, v90, s[10:11]
	v_pk_mul_f32 v[90:91], s[82:83], v[92:93]
	v_sub_u32_e32 v92, v185, v0
	v_sub_u32_e32 v93, v184, v111
	v_cmp_gt_i32_e64 s[12:13], s77, v184
	v_cmp_gt_i32_e64 s[8:9], s76, v185
	v_cmp_gt_i32_e64 s[16:17], 1, v93
	v_cmp_gt_i32_e64 s[18:19], 1, v92
	v_or_b32_e32 v92, s34, v99
	v_or_b32_e32 v93, s34, v104
	s_and_b64 s[8:9], s[8:9], s[18:19]
	s_and_b64 s[12:13], s[12:13], s[16:17]
	v_cmp_gt_i32_e64 s[16:17], s77, v92
	v_cmp_gt_i32_e64 s[18:19], s76, v93
	v_sub_u32_e32 v93, v93, v0
	v_sub_u32_e32 v92, v92, v111
	v_pk_mul_f32 v[86:87], s[82:83], v[86:87]
	v_cmp_gt_i32_e64 s[20:21], 1, v92
	v_cmp_gt_i32_e64 s[22:23], 1, v93
	v_pk_mul_f32 v[86:87], v[86:87], s[2:3] op_sel_hi:[1,0]
	s_and_b64 s[18:19], s[18:19], s[22:23]
	s_and_b64 s[22:23], s[16:17], s[20:21]
	v_or_b32_e32 v184, s34, v101
	v_or_b32_e32 v185, s34, v112
	v_cndmask_b32_e64 v93, v180, v87, s[22:23]
	v_cndmask_b32_e64 v92, v180, v86, s[18:19]
	v_pk_mul_f32 v[86:87], s[82:83], v[88:89]
	v_sub_u32_e32 v88, v185, v0
	v_sub_u32_e32 v89, v184, v111
	v_cmp_gt_i32_e64 s[20:21], s77, v184
	v_cmp_gt_i32_e64 s[16:17], s76, v185
	v_cmp_gt_i32_e64 s[24:25], 1, v89
	v_cmp_gt_i32_e64 s[26:27], 1, v88
	v_or_b32_e32 v88, s34, v160
	v_or_b32_e32 v89, s34, v106
	s_and_b64 s[16:17], s[16:17], s[26:27]
	s_and_b64 s[20:21], s[20:21], s[24:25]
	v_cmp_gt_i32_e64 s[24:25], s77, v88
	v_cmp_gt_i32_e64 s[26:27], s76, v89
	v_sub_u32_e32 v89, v89, v0
	v_sub_u32_e32 v88, v88, v111
	v_pk_mul_f32 v[82:83], s[82:83], v[82:83]
	v_cmp_gt_i32_e64 s[28:29], 1, v88
	v_cmp_gt_i32_e64 s[30:31], 1, v89
	v_pk_mul_f32 v[82:83], v[82:83], s[2:3] op_sel_hi:[1,0]
	s_and_b64 s[26:27], s[26:27], s[30:31]
	s_and_b64 s[30:31], s[24:25], s[28:29]
	v_or_b32_e32 v184, s34, v1
	v_or_b32_e32 v185, s34, v110
	v_cndmask_b32_e64 v89, v180, v83, s[30:31]
	v_cndmask_b32_e64 v88, v180, v82, s[26:27]
	v_pk_mul_f32 v[82:83], s[82:83], v[84:85]
	v_sub_u32_e32 v84, v185, v0
	v_sub_u32_e32 v85, v184, v111
	v_cmp_gt_i32_e64 s[28:29], s77, v184
	v_cmp_gt_i32_e64 s[24:25], s76, v185
	v_cmp_gt_i32_e64 s[34:35], 1, v85
	v_cmp_gt_i32_e64 s[36:37], 1, v84
	v_or_b32_e32 v84, s80, v107
	v_or_b32_e32 v85, s80, v100
	s_and_b64 s[24:25], s[24:25], s[36:37]
	s_and_b64 s[28:29], s[28:29], s[34:35]
	v_cmp_gt_i32_e64 s[36:37], s77, v84
	v_cmp_gt_i32_e64 s[34:35], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[38:39], 1, v84
	v_cmp_gt_i32_e64 s[40:41], 1, v85
	v_or_b32_e32 v84, s80, v109
	v_or_b32_e32 v85, s80, v116
	s_and_b64 s[34:35], s[34:35], s[40:41]
	s_and_b64 s[36:37], s[36:37], s[38:39]
	v_cmp_gt_i32_e64 s[40:41], s77, v84
	v_cmp_gt_i32_e64 s[38:39], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[42:43], 1, v84
	v_cmp_gt_i32_e64 s[44:45], 1, v85
	v_or_b32_e32 v84, s80, v103
	v_or_b32_e32 v85, s80, v102
	s_and_b64 s[38:39], s[38:39], s[44:45]
	s_and_b64 s[40:41], s[40:41], s[42:43]
	v_cmp_gt_i32_e64 s[44:45], s77, v84
	v_cmp_gt_i32_e64 s[42:43], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[46:47], 1, v84
	v_cmp_gt_i32_e64 s[48:49], 1, v85
	v_or_b32_e32 v84, s80, v105
	v_or_b32_e32 v85, s80, v114
	s_and_b64 s[42:43], s[42:43], s[48:49]
	s_and_b64 s[44:45], s[44:45], s[46:47]
	v_cmp_gt_i32_e64 s[48:49], s77, v84
	v_cmp_gt_i32_e64 s[46:47], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[50:51], 1, v84
	v_cmp_gt_i32_e64 s[52:53], 1, v85
	v_or_b32_e32 v84, s80, v99
	v_or_b32_e32 v85, s80, v104
	s_and_b64 s[46:47], s[46:47], s[52:53]
	s_and_b64 s[48:49], s[48:49], s[50:51]
	v_cmp_gt_i32_e64 s[52:53], s77, v84
	v_cmp_gt_i32_e64 s[50:51], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[54:55], 1, v84
	v_cmp_gt_i32_e64 s[56:57], 1, v85
	v_or_b32_e32 v84, s80, v101
	v_or_b32_e32 v85, s80, v112
	s_and_b64 s[50:51], s[50:51], s[56:57]
	s_and_b64 s[52:53], s[52:53], s[54:55]
	v_cmp_gt_i32_e64 s[56:57], s77, v84
	v_cmp_gt_i32_e64 s[54:55], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[58:59], 1, v84
	v_cmp_gt_i32_e64 s[60:61], 1, v85
	v_or_b32_e32 v84, s80, v160
	v_or_b32_e32 v85, s80, v106
	s_and_b64 s[54:55], s[54:55], s[60:61]
	s_and_b64 s[56:57], s[56:57], s[58:59]
	v_cmp_gt_i32_e64 s[60:61], s77, v84
	v_cmp_gt_i32_e64 s[58:59], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[62:63], 1, v84
	v_cmp_gt_i32_e64 s[64:65], 1, v85
	s_and_b64 s[58:59], s[58:59], s[64:65]
	s_and_b64 s[60:61], s[60:61], s[62:63]
	v_cndmask_b32_e64 v85, v180, v67, s[60:61]
	v_cndmask_b32_e64 v84, v180, v66, s[58:59]
	v_cmp_gt_f32_e64 s[62:63], v84, v85
	v_pk_mul_f32 v[66:67], s[82:83], v[68:69]
	v_sub_u32_e32 v68, v186, v0
	v_cndmask_b32_e64 v184, v85, v84, s[62:63]
	v_or_b32_e32 v185, s80, v1
	v_cmp_gt_i32_e64 s[62:63], s76, v186
	v_cmp_gt_i32_e64 s[70:71], 1, v68
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_sub_u32_e32 v69, v185, v111
	s_and_b64 s[62:63], s[62:63], s[70:71]
	v_cmp_gt_i32_e64 s[64:65], s77, v185
	v_cmp_gt_i32_e64 s[68:69], 1, v69
	v_cndmask_b32_e64 v68, v180, v66, s[62:63]
	s_and_b64 s[64:65], s[64:65], s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v184, v68
	v_cndmask_b32_e64 v69, v180, v67, s[64:65]
	v_cndmask_b32_e64 v70, v180, v70, s[50:51]
	v_cndmask_b32_e64 v66, v68, v184, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v69
	v_cndmask_b32_e64 v71, v180, v71, s[52:53]
	v_cndmask_b32_e64 v72, v180, v72, s[54:55]
	v_cndmask_b32_e64 v66, v69, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v70
	v_cndmask_b32_e64 v73, v180, v73, s[56:57]
	v_cndmask_b32_e64 v74, v180, v74, s[42:43]
	v_cndmask_b32_e64 v66, v70, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v71
	v_cndmask_b32_e64 v75, v180, v75, s[44:45]
	v_cndmask_b32_e64 v76, v180, v76, s[46:47]
	v_cndmask_b32_e64 v66, v71, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v72
	v_cndmask_b32_e64 v77, v180, v77, s[48:49]
	v_cndmask_b32_e64 v78, v180, v78, s[34:35]
	v_cndmask_b32_e64 v66, v72, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v73
	v_cndmask_b32_e64 v79, v180, v79, s[36:37]
	v_cndmask_b32_e64 v80, v180, v80, s[38:39]
	v_cndmask_b32_e64 v66, v73, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v74
	v_cndmask_b32_e64 v81, v180, v81, s[40:41]
	v_pk_mul_f32 v[82:83], v[82:83], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v74, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v75
	v_cndmask_b32_e64 v82, v180, v82, s[24:25]
	v_cndmask_b32_e64 v83, v180, v83, s[28:29]
	v_cndmask_b32_e64 v66, v75, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v76
	v_pk_mul_f32 v[86:87], v[86:87], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[90:91], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v76, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v77
	v_cndmask_b32_e64 v86, v180, v86, s[16:17]
	v_cndmask_b32_e64 v87, v180, v87, s[20:21]
	v_cndmask_b32_e64 v66, v77, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v78
	v_cndmask_b32_e64 v90, v180, v90, s[8:9]
	v_cndmask_b32_e64 v91, v180, v91, s[12:13]
	v_cndmask_b32_e64 v66, v78, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v79
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	s_add_u32 s78, s78, 1
	v_cndmask_b32_e64 v66, v79, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v80
	v_cndmask_b32_e32 v94, v180, v94, vcc
	v_cndmask_b32_e64 v95, v180, v95, s[4:5]
	v_cndmask_b32_e64 v66, v80, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v81
	s_addc_u32 s79, s79, 0
	s_add_i32 s80, s80, 64
	v_cndmask_b32_e64 v66, v81, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v88
	s_nop 1
	v_cndmask_b32_e64 v66, v88, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v89
	s_nop 1
	v_cndmask_b32_e64 v66, v89, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v82
	s_nop 1
	v_cndmask_b32_e64 v66, v82, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v83
	s_nop 1
	v_cndmask_b32_e64 v66, v83, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v92
	s_nop 1
	v_cndmask_b32_e64 v66, v92, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v93
	s_nop 1
	v_cndmask_b32_e64 v66, v93, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v86
	s_nop 1
	v_cndmask_b32_e64 v66, v86, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v87
	s_nop 1
	v_cndmask_b32_e64 v66, v87, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v96
	s_nop 1
	v_cndmask_b32_e64 v66, v96, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v97
	s_nop 1
	v_cndmask_b32_e64 v66, v97, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v90
	s_nop 1
	v_cndmask_b32_e64 v66, v90, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v91
	s_nop 1
	v_cndmask_b32_e64 v66, v91, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v120
	s_nop 1
	v_cndmask_b32_e64 v66, v120, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v121
	s_nop 1
	v_cndmask_b32_e64 v66, v121, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v94
	s_nop 1
	v_cndmask_b32_e64 v66, v94, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v95
	s_nop 1
	v_cndmask_b32_e64 v66, v95, v66, s[68:69]
	ds_bpermute_b32 v67, v175, v66
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e64 s[68:69], v66, v67
	s_nop 1
	v_cndmask_b32_e64 v66, v67, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v108, v66
	s_nop 1
	v_cndmask_b32_e64 v66, v66, v108, s[68:69]
	v_sub_f32_e32 v67, v108, v66
	v_cmp_gt_f32_e64 s[68:69], s92, v67
	s_nop 1
	v_cndmask_b32_e64 v108, 0, v181, s[68:69]
	v_add_f32_e32 v67, v67, v108
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v108, 0, v182, s[68:69]
	v_pk_add_f32 v[84:85], v[84:85], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_ldexp_f32 v108, v67, v108
	v_cmp_gt_f32_e64 s[68:69], s92, v84
	v_pk_mul_f32 v[48:49], v[48:49], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[46:47], v[108:109] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v181, s[68:69]
	v_add_f32_e32 v67, v84, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v84, 0, v182, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], s92, v85
	v_pk_mul_f32 v[44:45], v[44:45], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v84
	v_pk_add_f32 v[68:69], v[68:69], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v194, 0, v67, s[58:59]
	v_cmp_gt_f32_e64 s[58:59], s92, v68
	v_cndmask_b32_e64 v84, 0, v181, s[68:69]
	v_add_f32_e32 v84, v85, v84
	v_cndmask_b32_e64 v67, 0, v181, s[58:59]
	v_add_f32_e32 v67, v68, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v182, s[58:59]
	v_cmp_gt_f32_e64 s[58:59], s92, v69
	v_exp_f32_e32 v84, v84
	v_ldexp_f32 v67, v67, v68
	v_cndmask_b32_e64 v68, 0, v181, s[58:59]
	v_add_f32_e32 v68, v69, v68
	v_exp_f32_e32 v68, v68
	v_cndmask_b32_e64 v69, 0, v182, s[58:59]
	v_cndmask_b32_e64 v196, 0, v67, s[62:63]
	v_cndmask_b32_e64 v85, 0, v182, s[68:69]
	v_ldexp_f32 v68, v68, v69
	v_cndmask_b32_e64 v195, 0, v68, s[64:65]
	v_pk_add_f32 v[68:69], v[70:71], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_ldexp_f32 v84, v84, v85
	v_cmp_gt_f32_e64 s[58:59], s92, v68
	v_cndmask_b32_e64 v193, 0, v84, s[60:61]
	v_pk_mul_f32 v[42:43], v[42:43], v[108:109] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v181, s[58:59]
	v_add_f32_e32 v67, v68, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v182, s[58:59]
	v_cmp_gt_f32_e64 s[58:59], s92, v69
	v_pk_mul_f32 v[40:41], v[40:41], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v68
	v_cndmask_b32_e64 v68, 0, v181, s[58:59]
	v_add_f32_e32 v68, v69, v68
	v_exp_f32_e32 v68, v68
	v_cndmask_b32_e64 v69, 0, v182, s[58:59]
	v_cndmask_b32_e64 v191, 0, v67, s[50:51]
	v_pk_mul_f32 v[38:39], v[38:39], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v68, v68, v69
	v_cndmask_b32_e64 v189, 0, v68, s[52:53]
	v_pk_add_f32 v[68:69], v[72:73], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[36:37], v[36:37], v[108:109] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[50:51], s92, v68
	v_pk_mul_f32 v[34:35], v[34:35], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[64:65], v[64:65], v[108:109] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v181, s[50:51]
	v_add_f32_e32 v67, v68, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v182, s[50:51]
	v_cmp_gt_f32_e64 s[50:51], s92, v69
	v_pk_mul_f32 v[62:63], v[62:63], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v68
	v_cndmask_b32_e64 v68, 0, v181, s[50:51]
	v_add_f32_e32 v68, v69, v68
	v_exp_f32_e32 v68, v68
	v_cndmask_b32_e64 v69, 0, v182, s[50:51]
	v_cndmask_b32_e64 v192, 0, v67, s[54:55]
	v_pk_mul_f32 v[60:61], v[60:61], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v68, v68, v69
	v_cndmask_b32_e64 v190, 0, v68, s[56:57]
	v_pk_add_f32 v[68:69], v[74:75], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[58:59], v[108:109] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[50:51], s92, v68
	v_pk_mul_f32 v[56:57], v[56:57], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[54:55], v[54:55], v[108:109] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v181, s[50:51]
	v_add_f32_e32 v67, v68, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v182, s[50:51]
	v_cmp_gt_f32_e64 s[50:51], s92, v69
	v_pk_mul_f32 v[52:53], v[52:53], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v68
	v_cndmask_b32_e64 v68, 0, v181, s[50:51]
	v_add_f32_e32 v68, v69, v68
	v_exp_f32_e32 v68, v68
	v_cndmask_b32_e64 v69, 0, v182, s[50:51]
	v_cndmask_b32_e64 v187, 0, v67, s[42:43]
	v_pk_mul_f32 v[50:51], v[50:51], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v68, v68, v69
	v_cndmask_b32_e64 v185, 0, v68, s[44:45]
	v_pk_add_f32 v[68:69], v[76:77], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[32:33], v[32:33], v[108:109] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[42:43], s92, v68
	v_pk_mul_f32 v[30:31], v[30:31], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[108:109] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v181, s[42:43]
	v_add_f32_e32 v67, v68, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v182, s[42:43]
	v_cmp_gt_f32_e64 s[42:43], s92, v69
	v_pk_mul_f32 v[26:27], v[26:27], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v68
	v_cndmask_b32_e64 v68, 0, v181, s[42:43]
	v_add_f32_e32 v68, v69, v68
	v_exp_f32_e32 v68, v68
	v_cndmask_b32_e64 v69, 0, v182, s[42:43]
	v_cndmask_b32_e64 v188, 0, v67, s[46:47]
	v_pk_mul_f32 v[24:25], v[24:25], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v68, v68, v69
	v_cndmask_b32_e64 v186, 0, v68, s[48:49]
	v_pk_add_f32 v[68:69], v[78:79], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[22:23], v[22:23], v[108:109] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[42:43], s92, v68
	v_pk_mul_f32 v[20:21], v[20:21], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[108:109] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v181, s[42:43]
	v_add_f32_e32 v67, v68, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v182, s[42:43]
	v_cmp_gt_f32_e64 s[42:43], s92, v69
	v_pk_mul_f32 v[16:17], v[16:17], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v68
	v_pk_add_f32 v[70:71], v[80:81], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v68, 0, v181, s[42:43]
	v_cndmask_b32_e64 v85, 0, v67, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s92, v70
	v_add_f32_e32 v68, v69, v68
	v_exp_f32_e32 v68, v68
	v_cndmask_b32_e64 v67, 0, v181, s[34:35]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v69, 0, v182, s[42:43]
	v_ldexp_f32 v68, v68, v69
	v_cndmask_b32_e64 v69, 0, v182, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s92, v71
	v_ldexp_f32 v67, v67, v69
	v_cndmask_b32_e64 v184, 0, v67, s[38:39]
	v_cndmask_b32_e64 v69, 0, v181, s[34:35]
	v_add_f32_e32 v69, v71, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v70, 0, v182, s[34:35]
	v_cndmask_b32_e64 v68, 0, v68, s[36:37]
	v_pk_mul_f32 v[14:15], v[14:15], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v69, v69, v70
	v_pk_add_f32 v[70:71], v[88:89], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v69, 0, v69, s[40:41]
	v_cmp_gt_f32_e64 s[34:35], s92, v70
	v_pk_mul_f32 v[12:13], v[12:13], v[108:109] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[108:109] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v181, s[34:35]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v182, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s92, v71
	v_pk_mul_f32 v[8:9], v[8:9], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v181, s[34:35]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v182, s[34:35]
	v_cndmask_b32_e64 v84, 0, v67, s[26:27]
	v_pk_mul_f32 v[6:7], v[6:7], v[108:109] op_sel_hi:[1,0]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v81, 0, v70, s[30:31]
	v_pk_add_f32 v[70:71], v[82:83], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[4:5], v[4:5], v[108:109] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[26:27], s92, v70
	v_pk_mul_f32 v[2:3], v[2:3], v[108:109] op_sel_hi:[1,0]
	s_nop 0
	v_cndmask_b32_e64 v67, 0, v181, s[26:27]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v182, s[26:27]
	v_cmp_gt_f32_e64 s[26:27], s92, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v181, s[26:27]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v182, s[26:27]
	v_cndmask_b32_e64 v83, 0, v67, s[24:25]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v82, 0, v70, s[28:29]
	v_pk_add_f32 v[70:71], v[92:93], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[24:25], s92, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v181, s[24:25]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v182, s[24:25]
	v_cmp_gt_f32_e64 s[24:25], s92, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v181, s[24:25]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v182, s[24:25]
	v_cndmask_b32_e64 v79, 0, v67, s[18:19]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v77, 0, v70, s[22:23]
	v_pk_add_f32 v[70:71], v[86:87], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[18:19], s92, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v181, s[18:19]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v182, s[18:19]
	v_cmp_gt_f32_e64 s[18:19], s92, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v181, s[18:19]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v182, s[18:19]
	v_cndmask_b32_e64 v80, 0, v67, s[16:17]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v78, 0, v70, s[20:21]
	v_pk_add_f32 v[70:71], v[96:97], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[16:17], s92, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v181, s[16:17]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v182, s[16:17]
	v_cmp_gt_f32_e64 s[16:17], s92, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v181, s[16:17]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v182, s[16:17]
	v_cndmask_b32_e64 v75, 0, v67, s[10:11]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v73, 0, v70, s[14:15]
	v_pk_add_f32 v[70:71], v[90:91], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[10:11], s92, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v181, s[10:11]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v182, s[10:11]
	v_cmp_gt_f32_e64 s[10:11], s92, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v181, s[10:11]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v182, s[10:11]
	v_cndmask_b32_e64 v76, 0, v67, s[8:9]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v74, 0, v70, s[12:13]
	v_pk_add_f32 v[70:71], v[120:121], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[8:9], s92, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v181, s[8:9]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v182, s[8:9]
	v_cmp_gt_f32_e64 s[8:9], s92, v71
	v_ldexp_f32 v70, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v67, 0, v181, s[8:9]
	v_add_f32_e32 v67, v71, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v182, s[8:9]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v67, 0, v67, s[6:7]
	v_pk_add_f32 v[86:87], v[94:95], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v71, 0, v70, s[66:67]
	v_cmp_gt_f32_e64 s[6:7], s92, v86
	s_nop 1
	v_cndmask_b32_e64 v70, 0, v181, s[6:7]
	v_add_f32_e32 v70, v86, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v72, 0, v182, s[6:7]
	v_cmp_gt_f32_e64 s[6:7], s92, v87
	v_ldexp_f32 v72, v70, v72
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v181, s[6:7]
	v_add_f32_e32 v70, v87, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v86, 0, v182, s[6:7]
	v_cndmask_b32_e32 v72, 0, v72, vcc
	v_cmp_u_f32_e32 vcc, v194, v194
	v_ldexp_f32 v70, v70, v86
	v_add_f32_e32 v86, v194, v193
	v_add_f32_e32 v86, v196, v86
	v_add_f32_e32 v86, v195, v86
	v_add_f32_e32 v86, v191, v86
	v_add_f32_e32 v86, v189, v86
	v_add_f32_e32 v86, v192, v86
	v_add_f32_e32 v86, v190, v86
	v_add_f32_e32 v86, v187, v86
	v_add_f32_e32 v86, v185, v86
	v_add_f32_e32 v86, v188, v86
	v_add_f32_e32 v86, v186, v86
	v_add_f32_e32 v86, v85, v86
	v_add_f32_e32 v86, v68, v86
	v_add_f32_e32 v86, v184, v86
	v_add_f32_e32 v86, v69, v86
	v_add_f32_e32 v86, v84, v86
	v_add_f32_e32 v86, v81, v86
	v_add_f32_e32 v86, v83, v86
	v_add_f32_e32 v86, v82, v86
	v_add_f32_e32 v86, v79, v86
	v_add_f32_e32 v86, v77, v86
	v_add_f32_e32 v86, v80, v86
	v_add_f32_e32 v86, v78, v86
	v_add_f32_e32 v86, v75, v86
	v_add_f32_e32 v86, v73, v86
	v_add_f32_e32 v86, v76, v86
	v_add_f32_e32 v86, v74, v86
	v_add_f32_e32 v86, v71, v86
	v_add_f32_e32 v86, v67, v86
	v_cndmask_b32_e64 v70, 0, v70, s[4:5]
	v_add_f32_e32 v86, v72, v86
	v_add_f32_e32 v86, v70, v86
	ds_bpermute_b32 v87, v175, v86
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v86, v86, v87
	v_mul_f32_e32 v87, v129, v108
	v_add_f32_e32 v129, v87, v86
	v_bfe_u32 v86, v194, 16, 1
	v_add3_u32 v86, v86, v194, s93
	v_or_b32_e32 v87, 0x400000, v194
	v_cndmask_b32_e32 v88, v86, v87, vcc
	v_bfe_u32 v86, v193, 16, 1
	v_add3_u32 v86, v86, v193, s93
	v_or_b32_e32 v87, 0x400000, v193
	v_cmp_u_f32_e32 vcc, v193, v193
	v_mov_b32_e32 v108, v66
	s_nop 0
	v_cndmask_b32_e32 v90, v86, v87, vcc
	v_bfe_u32 v86, v196, 16, 1
	v_add3_u32 v86, v86, v196, s93
	v_or_b32_e32 v87, 0x400000, v196
	v_cmp_u_f32_e32 vcc, v196, v196
	v_perm_b32 v88, v90, v88, s96
	s_nop 0
	v_cndmask_b32_e32 v89, v86, v87, vcc
	v_bfe_u32 v86, v195, 16, 1
	v_add3_u32 v86, v86, v195, s93
	v_or_b32_e32 v87, 0x400000, v195
	v_cmp_u_f32_e32 vcc, v195, v195
	s_nop 1
	v_cndmask_b32_e32 v91, v86, v87, vcc
	ds_read_u16 v86, v176
	ds_read_u16 v92, v176 offset:256
	ds_read_u16 v87, v176 offset:512
	ds_read_u16 v93, v176 offset:768
	v_perm_b32 v89, v91, v89, s96
	v_cmp_u_f32_e32 vcc, v191, v191
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v92, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v93, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[86:87], v[88:89], v[34:49]
	ds_read_u16 v86, v176 offset:64
	ds_read_u16 v90, v176 offset:320
	ds_read_u16 v87, v176 offset:576
	ds_read_u16 v91, v176 offset:832
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[86:87], v[88:89], v[50:65]
	ds_read_u16 v86, v176 offset:128
	ds_read_u16 v90, v176 offset:384
	ds_read_u16 v87, v176 offset:640
	ds_read_u16 v91, v176 offset:896
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[86:87], v[88:89], v[18:33]
	ds_read_u16 v86, v176 offset:192
	ds_read_u16 v90, v176 offset:448
	ds_read_u16 v87, v176 offset:704
	ds_read_u16 v91, v176 offset:960
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[86:87], v[88:89], v[2:17]
	v_bfe_u32 v86, v191, 16, 1
	v_add3_u32 v86, v86, v191, s93
	v_or_b32_e32 v87, 0x400000, v191
	v_cndmask_b32_e32 v88, v86, v87, vcc
	v_bfe_u32 v86, v189, 16, 1
	v_add3_u32 v86, v86, v189, s93
	v_or_b32_e32 v87, 0x400000, v189
	v_cmp_u_f32_e32 vcc, v189, v189
	s_nop 1
	v_cndmask_b32_e32 v90, v86, v87, vcc
	v_bfe_u32 v86, v192, 16, 1
	v_add3_u32 v86, v86, v192, s93
	v_or_b32_e32 v87, 0x400000, v192
	v_cmp_u_f32_e32 vcc, v192, v192
	v_perm_b32 v88, v90, v88, s96
	s_nop 0
	v_cndmask_b32_e32 v89, v86, v87, vcc
	v_bfe_u32 v86, v190, 16, 1
	v_add3_u32 v86, v86, v190, s93
	v_or_b32_e32 v87, 0x400000, v190
	v_cmp_u_f32_e32 vcc, v190, v190
	s_nop 1
	v_cndmask_b32_e32 v91, v86, v87, vcc
	ds_read_u16 v86, v176 offset:2048
	ds_read_u16 v92, v176 offset:2304
	ds_read_u16 v87, v176 offset:2560
	ds_read_u16 v93, v176 offset:2816
	v_perm_b32 v89, v91, v89, s96
	v_cmp_u_f32_e32 vcc, v187, v187
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v92, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v93, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[86:87], v[88:89], v[34:49]
	ds_read_u16 v86, v176 offset:2112
	ds_read_u16 v90, v176 offset:2368
	ds_read_u16 v87, v176 offset:2624
	ds_read_u16 v91, v176 offset:2880
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[86:87], v[88:89], v[50:65]
	ds_read_u16 v86, v176 offset:2176
	ds_read_u16 v90, v176 offset:2432
	ds_read_u16 v87, v176 offset:2688
	ds_read_u16 v91, v176 offset:2944
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[86:87], v[88:89], v[18:33]
	ds_read_u16 v86, v176 offset:2240
	ds_read_u16 v90, v176 offset:2496
	ds_read_u16 v87, v176 offset:2752
	ds_read_u16 v91, v176 offset:3008
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[86:87], v[88:89], v[2:17]
	v_bfe_u32 v86, v187, 16, 1
	v_add3_u32 v86, v86, v187, s93
	v_or_b32_e32 v87, 0x400000, v187
	v_cndmask_b32_e32 v88, v86, v87, vcc
	v_bfe_u32 v86, v185, 16, 1
	v_add3_u32 v86, v86, v185, s93
	v_or_b32_e32 v87, 0x400000, v185
	v_cmp_u_f32_e32 vcc, v185, v185
	s_nop 1
	v_cndmask_b32_e32 v90, v86, v87, vcc
	v_bfe_u32 v86, v188, 16, 1
	v_add3_u32 v86, v86, v188, s93
	v_or_b32_e32 v87, 0x400000, v188
	v_cmp_u_f32_e32 vcc, v188, v188
	v_perm_b32 v88, v90, v88, s96
	s_nop 0
	v_cndmask_b32_e32 v89, v86, v87, vcc
	v_bfe_u32 v86, v186, 16, 1
	v_add3_u32 v86, v86, v186, s93
	v_or_b32_e32 v87, 0x400000, v186
	v_cmp_u_f32_e32 vcc, v186, v186
	s_nop 1
	v_cndmask_b32_e32 v91, v86, v87, vcc
	ds_read_u16 v86, v176 offset:4096
	ds_read_u16 v92, v176 offset:4352
	ds_read_u16 v87, v176 offset:4608
	ds_read_u16 v93, v176 offset:4864
	v_perm_b32 v89, v91, v89, s96
	v_cmp_u_f32_e32 vcc, v85, v85
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v92, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v93, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[86:87], v[88:89], v[34:49]
	ds_read_u16 v86, v176 offset:4160
	ds_read_u16 v90, v176 offset:4416
	ds_read_u16 v87, v176 offset:4672
	ds_read_u16 v91, v176 offset:4928
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[86:87], v[88:89], v[50:65]
	ds_read_u16 v86, v176 offset:4224
	ds_read_u16 v90, v176 offset:4480
	ds_read_u16 v87, v176 offset:4736
	ds_read_u16 v91, v176 offset:4992
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[86:87], v[88:89], v[18:33]
	ds_read_u16 v86, v176 offset:4288
	ds_read_u16 v90, v176 offset:4544
	ds_read_u16 v87, v176 offset:4800
	ds_read_u16 v91, v176 offset:5056
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v90, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v91, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[86:87], v[88:89], v[2:17]
	v_bfe_u32 v86, v85, 16, 1
	v_add3_u32 v86, v86, v85, s93
	v_or_b32_e32 v87, 0x400000, v85
	v_cndmask_b32_e32 v85, v86, v87, vcc
	v_bfe_u32 v86, v68, 16, 1
	v_add3_u32 v86, v86, v68, s93
	v_or_b32_e32 v87, 0x400000, v68
	v_cmp_u_f32_e32 vcc, v68, v68
	s_nop 1
	v_cndmask_b32_e32 v68, v86, v87, vcc
	v_bfe_u32 v86, v184, 16, 1
	v_add3_u32 v86, v86, v184, s93
	v_or_b32_e32 v87, 0x400000, v184
	v_cmp_u_f32_e32 vcc, v184, v184
	v_perm_b32 v68, v68, v85, s96
	s_nop 0
	v_cndmask_b32_e32 v88, v86, v87, vcc
	v_bfe_u32 v86, v69, 16, 1
	v_add3_u32 v86, v86, v69, s93
	v_or_b32_e32 v87, 0x400000, v69
	v_cmp_u_f32_e32 vcc, v69, v69
	s_nop 1
	v_cndmask_b32_e32 v69, v86, v87, vcc
	ds_read_u16 v86, v176 offset:6144
	ds_read_u16 v89, v176 offset:6400
	ds_read_u16 v87, v176 offset:6656
	ds_read_u16 v90, v176 offset:6912
	v_perm_b32 v69, v69, v88, s96
	v_cmp_u_f32_e32 vcc, v84, v84
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v89, v86, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v90, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[86:87], v[68:69], v[34:49]
	ds_read_u16 v85, v176 offset:6208
	ds_read_u16 v86, v176 offset:6464
	ds_read_u16 v87, v176 offset:6720
	ds_read_u16 v88, v176 offset:6976
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v86, v85, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v88, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[86:87], v[68:69], v[50:65]
	ds_read_u16 v85, v176 offset:6272
	ds_read_u16 v86, v176 offset:6528
	ds_read_u16 v87, v176 offset:6784
	ds_read_u16 v88, v176 offset:7040
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v86, v85, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v88, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[86:87], v[68:69], v[18:33]
	ds_read_u16 v85, v176 offset:6336
	ds_read_u16 v86, v176 offset:6592
	ds_read_u16 v87, v176 offset:6848
	ds_read_u16 v88, v176 offset:7104
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v86, v85, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v88, v87, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[86:87], v[68:69], v[2:17]
	v_bfe_u32 v68, v84, 16, 1
	v_add3_u32 v68, v68, v84, s93
	v_or_b32_e32 v69, 0x400000, v84
	v_cndmask_b32_e32 v84, v68, v69, vcc
	v_bfe_u32 v68, v81, 16, 1
	v_add3_u32 v68, v68, v81, s93
	v_or_b32_e32 v69, 0x400000, v81
	v_cmp_u_f32_e32 vcc, v81, v81
	s_nop 1
	v_cndmask_b32_e32 v81, v68, v69, vcc
	v_bfe_u32 v68, v83, 16, 1
	v_add3_u32 v68, v68, v83, s93
	v_or_b32_e32 v69, 0x400000, v83
	v_cmp_u_f32_e32 vcc, v83, v83
	s_nop 1
	v_cndmask_b32_e32 v83, v68, v69, vcc
	v_bfe_u32 v68, v82, 16, 1
	v_add3_u32 v68, v68, v82, s93
	v_or_b32_e32 v69, 0x400000, v82
	v_cmp_u_f32_e32 vcc, v82, v82
	s_nop 1
	v_cndmask_b32_e32 v82, v68, v69, vcc
	ds_read_u16 v68, v176 offset:8192
	ds_read_u16 v85, v176 offset:8448
	ds_read_u16 v69, v176 offset:8704
	ds_read_u16 v86, v176 offset:8960
	v_perm_b32 v83, v82, v83, s96
	v_perm_b32 v82, v81, v84, s96
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v85, v68, s95
	v_cmp_u_f32_e32 vcc, v79, v79
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v86, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[82:83], v[34:49]
	ds_read_u16 v68, v176 offset:8256
	ds_read_u16 v81, v176 offset:8512
	ds_read_u16 v69, v176 offset:8768
	ds_read_u16 v84, v176 offset:9024
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v81, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v84, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[82:83], v[50:65]
	ds_read_u16 v68, v176 offset:8320
	ds_read_u16 v81, v176 offset:8576
	ds_read_u16 v69, v176 offset:8832
	ds_read_u16 v84, v176 offset:9088
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v81, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v84, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[82:83], v[18:33]
	ds_read_u16 v68, v176 offset:8384
	ds_read_u16 v81, v176 offset:8640
	ds_read_u16 v69, v176 offset:8896
	ds_read_u16 v84, v176 offset:9152
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v81, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v84, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[82:83], v[2:17]
	v_bfe_u32 v68, v79, 16, 1
	v_add3_u32 v68, v68, v79, s93
	v_or_b32_e32 v69, 0x400000, v79
	v_cndmask_b32_e32 v81, v68, v69, vcc
	v_bfe_u32 v68, v77, 16, 1
	v_add3_u32 v68, v68, v77, s93
	v_or_b32_e32 v69, 0x400000, v77
	v_cmp_u_f32_e32 vcc, v77, v77
	s_nop 1
	v_cndmask_b32_e32 v77, v68, v69, vcc
	v_bfe_u32 v68, v80, 16, 1
	v_add3_u32 v68, v68, v80, s93
	v_or_b32_e32 v69, 0x400000, v80
	v_cmp_u_f32_e32 vcc, v80, v80
	s_nop 1
	v_cndmask_b32_e32 v79, v68, v69, vcc
	v_bfe_u32 v68, v78, 16, 1
	v_add3_u32 v68, v68, v78, s93
	v_or_b32_e32 v69, 0x400000, v78
	v_cmp_u_f32_e32 vcc, v78, v78
	s_nop 1
	v_cndmask_b32_e32 v78, v68, v69, vcc
	ds_read_u16 v68, v176 offset:10240
	ds_read_u16 v80, v176 offset:10496
	ds_read_u16 v69, v176 offset:10752
	ds_read_u16 v82, v176 offset:11008
	v_perm_b32 v79, v78, v79, s96
	v_perm_b32 v78, v77, v81, s96
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v80, v68, s95
	v_cmp_u_f32_e32 vcc, v75, v75
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v82, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[78:79], v[34:49]
	ds_read_u16 v68, v176 offset:10304
	ds_read_u16 v77, v176 offset:10560
	ds_read_u16 v69, v176 offset:10816
	ds_read_u16 v80, v176 offset:11072
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v77, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v80, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[78:79], v[50:65]
	ds_read_u16 v68, v176 offset:10368
	ds_read_u16 v77, v176 offset:10624
	ds_read_u16 v69, v176 offset:10880
	ds_read_u16 v80, v176 offset:11136
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v77, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v80, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[78:79], v[18:33]
	ds_read_u16 v68, v176 offset:10432
	ds_read_u16 v77, v176 offset:10688
	ds_read_u16 v69, v176 offset:10944
	ds_read_u16 v80, v176 offset:11200
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v77, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v80, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[78:79], v[2:17]
	v_bfe_u32 v68, v75, 16, 1
	v_add3_u32 v68, v68, v75, s93
	v_or_b32_e32 v69, 0x400000, v75
	v_cndmask_b32_e32 v77, v68, v69, vcc
	v_bfe_u32 v68, v73, 16, 1
	v_add3_u32 v68, v68, v73, s93
	v_or_b32_e32 v69, 0x400000, v73
	v_cmp_u_f32_e32 vcc, v73, v73
	s_nop 1
	v_cndmask_b32_e32 v73, v68, v69, vcc
	v_bfe_u32 v68, v76, 16, 1
	v_add3_u32 v68, v68, v76, s93
	v_or_b32_e32 v69, 0x400000, v76
	v_cmp_u_f32_e32 vcc, v76, v76
	s_nop 1
	v_cndmask_b32_e32 v75, v68, v69, vcc
	v_bfe_u32 v68, v74, 16, 1
	v_add3_u32 v68, v68, v74, s93
	v_or_b32_e32 v69, 0x400000, v74
	v_cmp_u_f32_e32 vcc, v74, v74
	s_nop 1
	v_cndmask_b32_e32 v74, v68, v69, vcc
	ds_read_u16 v68, v176 offset:12288
	ds_read_u16 v76, v176 offset:12544
	ds_read_u16 v69, v176 offset:12800
	ds_read_u16 v78, v176 offset:13056
	v_perm_b32 v75, v74, v75, s96
	v_perm_b32 v74, v73, v77, s96
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v76, v68, s95
	v_cmp_u_f32_e32 vcc, v71, v71
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v78, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[74:75], v[34:49]
	ds_read_u16 v68, v176 offset:12352
	ds_read_u16 v73, v176 offset:12608
	ds_read_u16 v69, v176 offset:12864
	ds_read_u16 v76, v176 offset:13120
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v73, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v76, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[74:75], v[50:65]
	ds_read_u16 v68, v176 offset:12416
	ds_read_u16 v73, v176 offset:12672
	ds_read_u16 v69, v176 offset:12928
	ds_read_u16 v76, v176 offset:13184
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v73, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v76, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[74:75], v[18:33]
	ds_read_u16 v68, v176 offset:12480
	ds_read_u16 v73, v176 offset:12736
	ds_read_u16 v69, v176 offset:12992
	ds_read_u16 v76, v176 offset:13248
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v73, v68, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v76, v69, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[74:75], v[2:17]
	v_bfe_u32 v68, v71, 16, 1
	v_add3_u32 v68, v68, v71, s93
	v_or_b32_e32 v69, 0x400000, v71
	v_cndmask_b32_e32 v68, v68, v69, vcc
	v_bfe_u32 v69, v67, 16, 1
	v_add3_u32 v69, v69, v67, s93
	v_or_b32_e32 v71, 0x400000, v67
	v_cmp_u_f32_e32 vcc, v67, v67
	s_nop 1
	v_cndmask_b32_e32 v67, v69, v71, vcc
	v_bfe_u32 v69, v72, 16, 1
	v_add3_u32 v69, v69, v72, s93
	v_or_b32_e32 v71, 0x400000, v72
	v_cmp_u_f32_e32 vcc, v72, v72
	v_or_b32_e32 v72, 0x400000, v70
	v_perm_b32 v68, v67, v68, s96
	v_cndmask_b32_e32 v69, v69, v71, vcc
	v_bfe_u32 v71, v70, 16, 1
	v_add3_u32 v71, v71, v70, s93
	v_cmp_u_f32_e32 vcc, v70, v70
	s_nop 1
	v_cndmask_b32_e32 v72, v71, v72, vcc
	ds_read_u16 v70, v176 offset:14336
	ds_read_u16 v73, v176 offset:14592
	ds_read_u16 v71, v176 offset:14848
	ds_read_u16 v74, v176 offset:15104
	v_perm_b32 v69, v72, v69, s96
	v_cmp_lt_i64_e32 vcc, s[78:79], v[118:119]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v73, v70, s95
	s_and_b64 vcc, exec, vcc
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v74, v71, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[70:71], v[68:69], v[34:49]
	ds_read_u16 v67, v176 offset:14400
	ds_read_u16 v70, v176 offset:14656
	ds_read_u16 v71, v176 offset:14912
	ds_read_u16 v72, v176 offset:15168
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v70, v67, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v72, v71, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[70:71], v[68:69], v[50:65]
	ds_read_u16 v67, v176 offset:14464
	ds_read_u16 v70, v176 offset:14720
	ds_read_u16 v71, v176 offset:14976
	ds_read_u16 v72, v176 offset:15232
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v70, v67, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v72, v71, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[70:71], v[68:69], v[18:33]
	ds_read_u16 v67, v176 offset:14528
	ds_read_u16 v70, v176 offset:14784
	ds_read_u16 v71, v176 offset:15040
	ds_read_u16 v72, v176 offset:15296
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v70, v67, s95
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v72, v71, s95
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[70:71], v[68:69], v[2:17]
	s_cbranch_vccnz .LBB0_7
	v_mov_b32_e32 v108, v66
.LBB0_9:
	v_cmp_gt_i32_e32 vcc, s81, v135
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_12
	v_div_scale_f32 v0, s[4:5], v129, v129, 1.0
	v_rcp_f32_e32 v1, v0
	s_load_dwordx2 s[8:9], s[0:1], 0x90
	s_load_dword s2, s[0:1], 0xa8
	s_load_dword s6, s[0:1], 0xb0
	s_load_dword s7, s[0:1], 0xb8
	s_mov_b32 s11, 0x27000
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	v_fma_f32 v66, -v0, v1, 1.0
	v_fmac_f32_e32 v1, v66, v1
	v_div_scale_f32 v66, vcc, 1.0, v129, 1.0
	v_mul_f32_e32 v67, v66, v1
	v_fma_f32 v68, -v0, v67, v66
	v_fmac_f32_e32 v67, v68, v1
	v_fma_f32 v0, -v0, v67, v66
	v_div_fmas_f32 v0, v0, v1, v67
	v_div_fixup_f32 v0, v0, v129, 1.0
	v_cmp_lt_f32_e32 vcc, 0, v129
	s_mul_i32 s2, s2, s33
	s_mul_i32 s7, s7, s3
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_mul_lo_u32 v1, s6, v98
	s_add_i32 s2, s2, s7
	v_pk_mul_f32 v[36:37], v[36:37], v[0:1] op_sel_hi:[1,0]
	v_add_u32_e32 v66, s2, v1
	v_pk_mul_f32 v[46:47], v[46:47], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[48:49], v[48:49], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[42:43], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[38:39], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[40:41], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[0:1] op_sel_hi:[1,0]
	v_bfe_u32 v1, v36, 16, 1
	s_movk_i32 s2, 0x7fff
	v_add3_u32 v1, v1, v36, s2
	v_or_b32_e32 v67, 0x400000, v36
	v_cmp_u_f32_e64 s[4:5], v36, v36
	v_bfe_u32 v36, v37, 16, 1
	v_add3_u32 v36, v36, v37, s2
	v_cndmask_b32_e64 v1, v1, v67, s[4:5]
	v_or_b32_e32 v67, 0x400000, v37
	v_cmp_u_f32_e64 s[4:5], v37, v37
	s_mov_b32 s6, 0x7060302
	s_mov_b32 s10, -1
	v_cndmask_b32_e64 v36, v36, v67, s[4:5]
	v_perm_b32 v37, v36, v1, s6
	v_bfe_u32 v1, v34, 16, 1
	v_add3_u32 v1, v1, v34, s2
	v_or_b32_e32 v36, 0x400000, v34
	v_cmp_u_f32_e64 s[4:5], v34, v34
	v_bfe_u32 v34, v35, 16, 1
	v_add3_u32 v34, v34, v35, s2
	v_cndmask_b32_e64 v1, v1, v36, s[4:5]
	v_or_b32_e32 v36, 0x400000, v35
	v_cmp_u_f32_e64 s[4:5], v35, v35
	v_or_b32_e32 v35, 0x400000, v41
	s_nop 0
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_perm_b32 v36, v34, v1, s6
	v_lshl_add_u32 v1, v66, 1, v134
	buffer_store_dwordx2 v[36:37], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v40, 16, 1
	v_add3_u32 v1, v1, v40, s2
	v_or_b32_e32 v34, 0x400000, v40
	v_cmp_u_f32_e64 s[4:5], v40, v40
	v_or_b32_e32 v36, 0x400000, v39
	s_nop 0
	v_cndmask_b32_e64 v1, v1, v34, s[4:5]
	v_bfe_u32 v34, v41, 16, 1
	v_add3_u32 v34, v34, v41, s2
	v_cmp_u_f32_e64 s[4:5], v41, v41
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v35, s[4:5]
	v_perm_b32 v35, v34, v1, s6
	v_bfe_u32 v1, v38, 16, 1
	v_add3_u32 v1, v1, v38, s2
	v_or_b32_e32 v34, 0x400000, v38
	v_cmp_u_f32_e64 s[4:5], v38, v38
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v34, s[4:5]
	v_bfe_u32 v34, v39, 16, 1
	v_add3_u32 v34, v34, v39, s2
	v_cmp_u_f32_e64 s[4:5], v39, v39
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_perm_b32 v34, v34, v1, s6
	v_add_lshl_u32 v1, v104, v66, 1
	buffer_store_dwordx2 v[34:35], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v44, 16, 1
	v_add3_u32 v1, v1, v44, s2
	v_or_b32_e32 v34, 0x400000, v44
	v_cmp_u_f32_e64 s[4:5], v44, v44
	v_or_b32_e32 v35, 0x400000, v45
	v_or_b32_e32 v36, 0x400000, v43
	v_cndmask_b32_e64 v1, v1, v34, s[4:5]
	v_bfe_u32 v34, v45, 16, 1
	v_add3_u32 v34, v34, v45, s2
	v_cmp_u_f32_e64 s[4:5], v45, v45
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v35, s[4:5]
	v_perm_b32 v35, v34, v1, s6
	v_bfe_u32 v1, v42, 16, 1
	v_add3_u32 v1, v1, v42, s2
	v_or_b32_e32 v34, 0x400000, v42
	v_cmp_u_f32_e64 s[4:5], v42, v42
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v34, s[4:5]
	v_bfe_u32 v34, v43, 16, 1
	v_add3_u32 v34, v34, v43, s2
	v_cmp_u_f32_e64 s[4:5], v43, v43
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_perm_b32 v34, v34, v1, s6
	v_add_lshl_u32 v1, v102, v66, 1
	buffer_store_dwordx2 v[34:35], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v48, 16, 1
	v_add3_u32 v1, v1, v48, s2
	v_or_b32_e32 v34, 0x400000, v48
	v_cmp_u_f32_e64 s[4:5], v48, v48
	v_or_b32_e32 v35, 0x400000, v49
	v_or_b32_e32 v36, 0x400000, v47
	v_cndmask_b32_e64 v1, v1, v34, s[4:5]
	v_bfe_u32 v34, v49, 16, 1
	v_add3_u32 v34, v34, v49, s2
	v_cmp_u_f32_e64 s[4:5], v49, v49
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v35, s[4:5]
	v_perm_b32 v35, v34, v1, s6
	v_bfe_u32 v1, v46, 16, 1
	v_add3_u32 v1, v1, v46, s2
	v_or_b32_e32 v34, 0x400000, v46
	v_cmp_u_f32_e64 s[4:5], v46, v46
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v34, s[4:5]
	v_bfe_u32 v34, v47, 16, 1
	v_add3_u32 v34, v34, v47, s2
	v_cmp_u_f32_e64 s[4:5], v47, v47
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_perm_b32 v34, v34, v1, s6
	v_add_lshl_u32 v1, v100, v66, 1
	v_pk_mul_f32 v[48:49], v[52:53], v[0:1] op_sel_hi:[1,0]
	buffer_store_dwordx2 v[34:35], v1, s[8:11], 0 offen
	v_pk_mul_f32 v[34:35], v[62:63], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[64:65], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[58:59], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[60:61], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[54:55], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[56:57], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[50:51], v[0:1] op_sel_hi:[1,0]
	v_bfe_u32 v1, v48, 16, 1
	v_add3_u32 v1, v1, v48, s2
	v_or_b32_e32 v50, 0x400000, v48
	v_cmp_u_f32_e64 s[4:5], v48, v48
	v_bfe_u32 v48, v49, 16, 1
	v_add3_u32 v48, v48, v49, s2
	v_cndmask_b32_e64 v1, v1, v50, s[4:5]
	v_or_b32_e32 v50, 0x400000, v49
	v_cmp_u_f32_e64 s[4:5], v49, v49
	s_nop 1
	v_cndmask_b32_e64 v48, v48, v50, s[4:5]
	v_perm_b32 v49, v48, v1, s6
	v_bfe_u32 v1, v46, 16, 1
	v_add3_u32 v1, v1, v46, s2
	v_or_b32_e32 v48, 0x400000, v46
	v_cmp_u_f32_e64 s[4:5], v46, v46
	v_bfe_u32 v46, v47, 16, 1
	v_add3_u32 v46, v46, v47, s2
	v_cndmask_b32_e64 v1, v1, v48, s[4:5]
	v_or_b32_e32 v48, 0x400000, v47
	v_cmp_u_f32_e64 s[4:5], v47, v47
	s_nop 1
	v_cndmask_b32_e64 v46, v46, v48, s[4:5]
	v_perm_b32 v48, v46, v1, s6
	v_add_lshl_u32 v1, v133, v66, 1
	buffer_store_dwordx2 v[48:49], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v44, 16, 1
	v_add3_u32 v1, v1, v44, s2
	v_or_b32_e32 v46, 0x400000, v44
	v_cmp_u_f32_e64 s[4:5], v44, v44
	v_bfe_u32 v44, v45, 16, 1
	v_add3_u32 v44, v44, v45, s2
	v_cndmask_b32_e64 v1, v1, v46, s[4:5]
	v_or_b32_e32 v46, 0x400000, v45
	v_cmp_u_f32_e64 s[4:5], v45, v45
	s_nop 1
	v_cndmask_b32_e64 v44, v44, v46, s[4:5]
	v_perm_b32 v45, v44, v1, s6
	v_bfe_u32 v1, v42, 16, 1
	v_add3_u32 v1, v1, v42, s2
	v_or_b32_e32 v44, 0x400000, v42
	v_cmp_u_f32_e64 s[4:5], v42, v42
	v_bfe_u32 v42, v43, 16, 1
	v_add3_u32 v42, v42, v43, s2
	v_cndmask_b32_e64 v1, v1, v44, s[4:5]
	v_or_b32_e32 v44, 0x400000, v43
	v_cmp_u_f32_e64 s[4:5], v43, v43
	s_nop 1
	v_cndmask_b32_e64 v42, v42, v44, s[4:5]
	v_perm_b32 v44, v42, v1, s6
	v_add_lshl_u32 v1, v132, v66, 1
	buffer_store_dwordx2 v[44:45], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v40, 16, 1
	v_add3_u32 v1, v1, v40, s2
	v_or_b32_e32 v42, 0x400000, v40
	v_cmp_u_f32_e64 s[4:5], v40, v40
	v_bfe_u32 v40, v41, 16, 1
	v_add3_u32 v40, v40, v41, s2
	v_cndmask_b32_e64 v1, v1, v42, s[4:5]
	v_or_b32_e32 v42, 0x400000, v41
	v_cmp_u_f32_e64 s[4:5], v41, v41
	s_nop 1
	v_cndmask_b32_e64 v40, v40, v42, s[4:5]
	v_perm_b32 v41, v40, v1, s6
	v_bfe_u32 v1, v38, 16, 1
	v_add3_u32 v1, v1, v38, s2
	v_or_b32_e32 v40, 0x400000, v38
	v_cmp_u_f32_e64 s[4:5], v38, v38
	v_bfe_u32 v38, v39, 16, 1
	v_add3_u32 v38, v38, v39, s2
	v_cndmask_b32_e64 v1, v1, v40, s[4:5]
	v_or_b32_e32 v40, 0x400000, v39
	v_cmp_u_f32_e64 s[4:5], v39, v39
	s_nop 1
	v_cndmask_b32_e64 v38, v38, v40, s[4:5]
	v_perm_b32 v40, v38, v1, s6
	v_add_lshl_u32 v1, v131, v66, 1
	buffer_store_dwordx2 v[40:41], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v36, 16, 1
	v_add3_u32 v1, v1, v36, s2
	v_or_b32_e32 v38, 0x400000, v36
	v_cmp_u_f32_e64 s[4:5], v36, v36
	v_bfe_u32 v36, v37, 16, 1
	v_add3_u32 v36, v36, v37, s2
	v_cndmask_b32_e64 v1, v1, v38, s[4:5]
	v_or_b32_e32 v38, 0x400000, v37
	v_cmp_u_f32_e64 s[4:5], v37, v37
	s_nop 1
	v_cndmask_b32_e64 v36, v36, v38, s[4:5]
	v_perm_b32 v37, v36, v1, s6
	v_bfe_u32 v1, v34, 16, 1
	v_add3_u32 v1, v1, v34, s2
	v_or_b32_e32 v36, 0x400000, v34
	v_cmp_u_f32_e64 s[4:5], v34, v34
	v_bfe_u32 v34, v35, 16, 1
	v_add3_u32 v34, v34, v35, s2
	v_cndmask_b32_e64 v1, v1, v36, s[4:5]
	v_or_b32_e32 v36, 0x400000, v35
	v_cmp_u_f32_e64 s[4:5], v35, v35
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_perm_b32 v36, v34, v1, s6
	v_add_lshl_u32 v1, v130, v66, 1
	v_pk_mul_f32 v[20:21], v[20:21], v[0:1] op_sel_hi:[1,0]
	buffer_store_dwordx2 v[36:37], v1, s[8:11], 0 offen
	v_pk_mul_f32 v[30:31], v[30:31], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[0:1] op_sel_hi:[1,0]
	v_bfe_u32 v1, v20, 16, 1
	v_add3_u32 v1, v1, v20, s2
	v_or_b32_e32 v34, 0x400000, v20
	v_cmp_u_f32_e64 s[4:5], v20, v20
	v_bfe_u32 v20, v21, 16, 1
	v_add3_u32 v20, v20, v21, s2
	v_cndmask_b32_e64 v1, v1, v34, s[4:5]
	v_or_b32_e32 v34, 0x400000, v21
	v_cmp_u_f32_e64 s[4:5], v21, v21
	s_nop 1
	v_cndmask_b32_e64 v20, v20, v34, s[4:5]
	v_perm_b32 v21, v20, v1, s6
	v_bfe_u32 v1, v18, 16, 1
	v_add3_u32 v1, v1, v18, s2
	v_or_b32_e32 v20, 0x400000, v18
	v_cmp_u_f32_e64 s[4:5], v18, v18
	v_bfe_u32 v18, v19, 16, 1
	v_add3_u32 v18, v18, v19, s2
	v_cndmask_b32_e64 v1, v1, v20, s[4:5]
	v_or_b32_e32 v20, 0x400000, v19
	v_cmp_u_f32_e64 s[4:5], v19, v19
	v_or_b32_e32 v19, 0x400000, v25
	s_nop 0
	v_cndmask_b32_e64 v18, v18, v20, s[4:5]
	v_perm_b32 v20, v18, v1, s6
	v_add_lshl_u32 v1, v128, v66, 1
	buffer_store_dwordx2 v[20:21], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v24, 16, 1
	v_add3_u32 v1, v1, v24, s2
	v_or_b32_e32 v18, 0x400000, v24
	v_cmp_u_f32_e64 s[4:5], v24, v24
	v_or_b32_e32 v20, 0x400000, v23
	s_nop 0
	v_cndmask_b32_e64 v1, v1, v18, s[4:5]
	v_bfe_u32 v18, v25, 16, 1
	v_add3_u32 v18, v18, v25, s2
	v_cmp_u_f32_e64 s[4:5], v25, v25
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v19, s[4:5]
	v_perm_b32 v19, v18, v1, s6
	v_bfe_u32 v1, v22, 16, 1
	v_add3_u32 v1, v1, v22, s2
	v_or_b32_e32 v18, 0x400000, v22
	v_cmp_u_f32_e64 s[4:5], v22, v22
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v18, s[4:5]
	v_bfe_u32 v18, v23, 16, 1
	v_add3_u32 v18, v18, v23, s2
	v_cmp_u_f32_e64 s[4:5], v23, v23
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v20, s[4:5]
	v_perm_b32 v18, v18, v1, s6
	v_add_lshl_u32 v1, v127, v66, 1
	buffer_store_dwordx2 v[18:19], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v28, 16, 1
	v_add3_u32 v1, v1, v28, s2
	v_or_b32_e32 v18, 0x400000, v28
	v_cmp_u_f32_e64 s[4:5], v28, v28
	v_or_b32_e32 v19, 0x400000, v29
	v_or_b32_e32 v20, 0x400000, v27
	v_cndmask_b32_e64 v1, v1, v18, s[4:5]
	v_bfe_u32 v18, v29, 16, 1
	v_add3_u32 v18, v18, v29, s2
	v_cmp_u_f32_e64 s[4:5], v29, v29
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v19, s[4:5]
	v_perm_b32 v19, v18, v1, s6
	v_bfe_u32 v1, v26, 16, 1
	v_add3_u32 v1, v1, v26, s2
	v_or_b32_e32 v18, 0x400000, v26
	v_cmp_u_f32_e64 s[4:5], v26, v26
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v18, s[4:5]
	v_bfe_u32 v18, v27, 16, 1
	v_add3_u32 v18, v18, v27, s2
	v_cmp_u_f32_e64 s[4:5], v27, v27
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v20, s[4:5]
	v_perm_b32 v18, v18, v1, s6
	v_add_lshl_u32 v1, v126, v66, 1
	buffer_store_dwordx2 v[18:19], v1, s[8:11], 0 offen
	v_bfe_u32 v1, v32, 16, 1
	v_add3_u32 v1, v1, v32, s2
	v_or_b32_e32 v18, 0x400000, v32
	v_cmp_u_f32_e64 s[4:5], v32, v32
	v_or_b32_e32 v19, 0x400000, v33
	v_or_b32_e32 v20, 0x400000, v31
	v_cndmask_b32_e64 v1, v1, v18, s[4:5]
	v_bfe_u32 v18, v33, 16, 1
	v_add3_u32 v18, v18, v33, s2
	v_cmp_u_f32_e64 s[4:5], v33, v33
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v19, s[4:5]
	v_perm_b32 v19, v18, v1, s6
	v_bfe_u32 v1, v30, 16, 1
	v_add3_u32 v1, v1, v30, s2
	v_or_b32_e32 v18, 0x400000, v30
	v_cmp_u_f32_e64 s[4:5], v30, v30
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v18, s[4:5]
	v_bfe_u32 v18, v31, 16, 1
	v_add3_u32 v18, v18, v31, s2
	v_cmp_u_f32_e64 s[4:5], v31, v31
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v20, s[4:5]
	v_perm_b32 v18, v18, v1, s6
	v_add_lshl_u32 v1, v125, v66, 1
	buffer_store_dwordx2 v[18:19], v1, s[8:11], 0 offen
	v_pk_mul_f32 v[14:15], v[14:15], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[0:1], v[4:5], v[0:1] op_sel_hi:[1,0]
	s_nop 0
	v_bfe_u32 v4, v0, 16, 1
	v_add3_u32 v4, v4, v0, s2
	v_or_b32_e32 v5, 0x400000, v0
	v_cmp_u_f32_e64 s[4:5], v0, v0
	s_nop 1
	v_cndmask_b32_e64 v0, v4, v5, s[4:5]
	v_bfe_u32 v4, v1, 16, 1
	v_add3_u32 v4, v4, v1, s2
	v_or_b32_e32 v5, 0x400000, v1
	v_cmp_u_f32_e64 s[4:5], v1, v1
	s_nop 1
	v_cndmask_b32_e64 v1, v4, v5, s[4:5]
	v_perm_b32 v1, v1, v0, s6
	v_bfe_u32 v0, v2, 16, 1
	v_add3_u32 v0, v0, v2, s2
	v_or_b32_e32 v4, 0x400000, v2
	v_cmp_u_f32_e64 s[4:5], v2, v2
	v_bfe_u32 v2, v3, 16, 1
	v_add3_u32 v2, v2, v3, s2
	v_cndmask_b32_e64 v0, v0, v4, s[4:5]
	v_or_b32_e32 v4, 0x400000, v3
	v_cmp_u_f32_e64 s[4:5], v3, v3
	v_or_b32_e32 v3, 0x400000, v7
	s_nop 0
	v_cndmask_b32_e64 v2, v2, v4, s[4:5]
	v_perm_b32 v0, v2, v0, s6
	v_add_lshl_u32 v2, v124, v66, 1
	buffer_store_dwordx2 v[0:1], v2, s[8:11], 0 offen
	v_bfe_u32 v0, v8, 16, 1
	v_add3_u32 v0, v0, v8, s2
	v_or_b32_e32 v1, 0x400000, v8
	v_cmp_u_f32_e64 s[4:5], v8, v8
	v_or_b32_e32 v2, 0x400000, v9
	s_nop 0
	v_cndmask_b32_e64 v0, v0, v1, s[4:5]
	v_bfe_u32 v1, v9, 16, 1
	v_add3_u32 v1, v1, v9, s2
	v_cmp_u_f32_e64 s[4:5], v9, v9
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v2, s[4:5]
	v_perm_b32 v1, v1, v0, s6
	v_bfe_u32 v0, v6, 16, 1
	v_add3_u32 v0, v0, v6, s2
	v_or_b32_e32 v2, 0x400000, v6
	v_cmp_u_f32_e64 s[4:5], v6, v6
	s_nop 1
	v_cndmask_b32_e64 v0, v0, v2, s[4:5]
	v_bfe_u32 v2, v7, 16, 1
	v_add3_u32 v2, v2, v7, s2
	v_cmp_u_f32_e64 s[4:5], v7, v7
	s_nop 1
	v_cndmask_b32_e64 v2, v2, v3, s[4:5]
	v_perm_b32 v0, v2, v0, s6
	v_add_lshl_u32 v2, v123, v66, 1
	buffer_store_dwordx2 v[0:1], v2, s[8:11], 0 offen
	v_bfe_u32 v0, v12, 16, 1
	v_add3_u32 v0, v0, v12, s2
	v_or_b32_e32 v1, 0x400000, v12
	v_cmp_u_f32_e64 s[4:5], v12, v12
	v_or_b32_e32 v2, 0x400000, v13
	v_or_b32_e32 v3, 0x400000, v11
	v_cndmask_b32_e64 v0, v0, v1, s[4:5]
	v_bfe_u32 v1, v13, 16, 1
	v_add3_u32 v1, v1, v13, s2
	v_cmp_u_f32_e64 s[4:5], v13, v13
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v2, s[4:5]
	v_perm_b32 v1, v1, v0, s6
	v_bfe_u32 v0, v10, 16, 1
	v_add3_u32 v0, v0, v10, s2
	v_or_b32_e32 v2, 0x400000, v10
	v_cmp_u_f32_e64 s[4:5], v10, v10
	s_nop 1
	v_cndmask_b32_e64 v0, v0, v2, s[4:5]
	v_bfe_u32 v2, v11, 16, 1
	v_add3_u32 v2, v2, v11, s2
	v_cmp_u_f32_e64 s[4:5], v11, v11
	s_nop 1
	v_cndmask_b32_e64 v2, v2, v3, s[4:5]
	v_perm_b32 v0, v2, v0, s6
	v_add_lshl_u32 v2, v122, v66, 1
	buffer_store_dwordx2 v[0:1], v2, s[8:11], 0 offen
	v_bfe_u32 v0, v16, 16, 1
	v_add3_u32 v0, v0, v16, s2
	v_or_b32_e32 v1, 0x400000, v16
	v_cmp_u_f32_e64 s[4:5], v16, v16
	v_or_b32_e32 v2, 0x400000, v17
	v_or_b32_e32 v3, 0x400000, v15
	v_cndmask_b32_e64 v0, v0, v1, s[4:5]
	v_bfe_u32 v1, v17, 16, 1
	v_add3_u32 v1, v1, v17, s2
	v_cmp_u_f32_e64 s[4:5], v17, v17
	s_nop 1
	v_cndmask_b32_e64 v1, v1, v2, s[4:5]
	v_perm_b32 v1, v1, v0, s6
	v_bfe_u32 v0, v14, 16, 1
	v_add3_u32 v0, v0, v14, s2
	v_or_b32_e32 v2, 0x400000, v14
	v_cmp_u_f32_e64 s[4:5], v14, v14
	s_nop 1
	v_cndmask_b32_e64 v0, v0, v2, s[4:5]
	v_bfe_u32 v2, v15, 16, 1
	v_add3_u32 v2, v2, v15, s2
	v_cmp_u_f32_e64 s[4:5], v15, v15
	s_nop 1
	v_cndmask_b32_e64 v2, v2, v3, s[4:5]
	v_perm_b32 v0, v2, v0, s6
	v_add_lshl_u32 v2, v115, v66, 1
	v_cmp_gt_u32_e64 s[4:5], 32, v117
	buffer_store_dwordx2 v[0:1], v2, s[8:11], 0 offen
	s_and_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_12
	s_mov_b32 s2, 0x800000
	v_cmp_gt_f32_e64 s[4:5], s2, v129
	v_mov_b32_e32 v0, 0x42000000
	s_nop 0
	v_cndmask_b32_e64 v1, 0, 32, s[4:5]
	v_ldexp_f32 v1, v129, v1
	v_cndmask_b32_e64 v0, 0, v0, s[4:5]
	v_log_f32_e32 v1, v1
	s_load_dwordx2 s[8:9], s[0:1], 0xc0
	s_load_dword s2, s[0:1], 0xd4
	s_load_dword s4, s[0:1], 0xdc
	v_sub_f32_e32 v0, v1, v0
	v_add_f32_e32 v0, v108, v0
	s_waitcnt lgkmcnt(0)
	s_mul_i32 s0, s2, s33
	s_mul_i32 s4, s4, s3
	v_mul_f32_e32 v0, 0x3f317218, v0
	v_mov_b32_e32 v1, 0xff800000
	s_add_i32 s0, s0, s4
	v_cndmask_b32_e32 v0, v1, v0, vcc
	s_and_b32 s9, s9, 0xffff
	v_add_lshl_u32 v1, v98, s0, 2
	buffer_store_dword v0, v1, s[8:11], 0 offen
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
		.amdhsa_next_free_vgpr 230
		.amdhsa_next_free_sgpr 97
		.amdhsa_accum_offset 232
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

	.set .Lkernel_0.num_vgpr, 230
	.set .Lkernel_0.num_agpr, 0
	.set .Lkernel_0.numbered_sgpr, 97
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
    .sgpr_count:     103
    .sgpr_spill_count: 0
    .symbol:         kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     230
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx942
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata

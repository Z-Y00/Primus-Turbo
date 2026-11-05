	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx942"
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
	s_subb_u32 s5, s12, 0
	s_abs_i32 s6, s76
	v_cvt_f32_u32_e32 v3, s6
	s_sub_i32 s13, 0, s6
	s_load_dwordx8 s[68:75], s[0:1], 0x48
	s_load_dwordx2 s[8:9], s[0:1], 0x0
	s_load_dword s17, s[0:1], 0x18
	s_load_dword s18, s[0:1], 0x20
	s_load_dword s19, s[0:1], 0x28
	s_load_dwordx2 s[80:81], s[0:1], 0x30
	s_abs_i32 s7, s4
	v_rcp_f32_e32 v3, v3
	s_waitcnt lgkmcnt(0)
	s_mov_b64 s[84:85], s[74:75]
	s_xor_b32 s12, s76, s4
	s_and_b32 s81, s81, 0xffff
	v_mul_f32_e32 v3, 0x4f7ffffe, v3
	v_cvt_u32_f32_e32 v3, v3
	s_and_b32 s85, s85, 0xffff
	s_and_b32 s9, s9, 0xffff
	s_ashr_i32 s14, s12, 31
	v_readfirstlane_b32 s15, v3
	s_mul_i32 s13, s13, s15
	s_mul_hi_u32 s13, s15, s13
	s_add_i32 s15, s15, s13
	s_mul_hi_u32 s13, s7, s15
	s_mul_i32 s15, s13, s6
	s_sub_i32 s7, s7, s15
	s_add_i32 s15, s13, 1
	s_sub_i32 s16, s7, s6
	s_cmp_ge_u32 s7, s6
	s_cselect_b32 s13, s15, s13
	s_cselect_b32 s7, s16, s7
	s_add_i32 s15, s13, 1
	s_cmp_ge_u32 s7, s6
	s_cselect_b32 s6, s15, s13
	s_xor_b32 s15, s6, s14
	s_sub_i32 s6, s15, s14
	s_mul_i32 s6, s6, s76
	s_cmp_lg_u32 s4, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s12, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[6:7], s[12:13], s[6:7]
	s_subb_u32 s33, s15, s14
	s_add_i32 s4, s78, 63
	s_ashr_i32 s6, s4, 31
	s_lshr_b32 s6, s6, 26
	s_add_i32 s6, s4, s6
	s_ashr_i32 s14, s6, 6
	s_andn2_b32 s6, s6, 63
	s_cmp_lg_u32 s4, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s4, 0
	s_cselect_b64 s[12:13], -1, 0
	s_and_b64 s[6:7], s[12:13], s[6:7]
	s_subb_u32 s12, s14, 0
	s_add_i32 s4, s2, 0x80
	s_min_i32 s4, s4, s77
	s_sub_i32 s16, s78, s77
	s_add_i32 s4, s16, s4
	s_max_i32 s4, s4, 0
	s_add_i32 s4, s4, 63
	s_ashr_i32 s6, s4, 31
	s_lshr_b32 s6, s6, 26
	s_add_i32 s6, s4, s6
	s_ashr_i32 s13, s6, 6
	s_andn2_b32 s6, s6, 63
	s_cmp_lg_u32 s4, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s4, 0
	s_cselect_b64 s[14:15], -1, 0
	v_lshrrev_b32_e32 v3, 1, v0
	v_and_b32_e32 v1, 31, v0
	s_and_b64 s[6:7], s[14:15], s[6:7]
	v_and_b32_e32 v3, 0x60, v3
	s_subb_u32 s14, s13, 0
	v_or3_b32 v122, s2, v3, v1
	s_add_i32 s4, s77, -1
	v_min_i32_e32 v98, s4, v122
	s_mul_i32 s4, s17, s33
	s_mul_i32 s19, s19, s3
	v_bfe_u32 v2, v0, 5, 1
	v_mul_lo_u32 v3, s18, v98
	s_add_i32 s4, s4, s19
	v_lshlrev_b32_e32 v121, 2, v2
	s_mov_b32 s83, 0x27000
	s_mov_b32 s82, -1
	v_add_u32_e32 v3, s4, v3
	v_lshlrev_b32_e32 v120, 3, v2
	s_mov_b32 s10, s82
	s_mov_b32 s11, s83
	v_lshl_add_u32 v4, v3, 1, v120
	v_or_b32_e32 v119, 8, v121
	v_or_b32_e32 v118, 16, v121
	v_or_b32_e32 v117, 24, v121
	v_or_b32_e32 v116, 32, v121
	v_add_lshl_u32 v5, v119, v3, 1
	v_add_lshl_u32 v6, v118, v3, 1
	v_add_lshl_u32 v7, v117, v3, 1
	buffer_load_dwordx2 v[182:183], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[184:185], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[186:187], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[188:189], v7, s[8:11], 0 offen
	v_add_lshl_u32 v4, v116, v3, 1
	v_or_b32_e32 v115, 40, v121
	v_or_b32_e32 v114, 48, v121
	v_or_b32_e32 v113, 56, v121
	v_or_b32_e32 v111, 64, v121
	v_add_lshl_u32 v5, v115, v3, 1
	v_add_lshl_u32 v6, v114, v3, 1
	v_add_lshl_u32 v7, v113, v3, 1
	buffer_load_dwordx2 v[190:191], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[192:193], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[194:195], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[196:197], v7, s[8:11], 0 offen
	v_add_lshl_u32 v4, v111, v3, 1
	v_or_b32_e32 v110, 0x48, v121
	v_or_b32_e32 v109, 0x50, v121
	v_or_b32_e32 v108, 0x58, v121
	v_or_b32_e32 v107, 0x60, v121
	v_add_lshl_u32 v5, v110, v3, 1
	v_add_lshl_u32 v6, v109, v3, 1
	v_add_lshl_u32 v7, v108, v3, 1
	buffer_load_dwordx2 v[198:199], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[200:201], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[202:203], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[204:205], v7, s[8:11], 0 offen
	v_add_lshl_u32 v4, v107, v3, 1
	v_or_b32_e32 v106, 0x68, v121
	v_or_b32_e32 v105, 0x70, v121
	v_or_b32_e32 v99, 0x78, v121
	v_add_lshl_u32 v5, v106, v3, 1
	v_add_lshl_u32 v6, v105, v3, 1
	v_add_lshl_u32 v3, v99, v3, 1
	buffer_load_dwordx2 v[206:207], v4, s[8:11], 0 offen
	buffer_load_dwordx2 v[208:209], v5, s[8:11], 0 offen
	buffer_load_dwordx2 v[210:211], v6, s[8:11], 0 offen
	buffer_load_dwordx2 v[212:213], v3, s[8:11], 0 offen
	s_ashr_i32 s6, s78, 31
	s_lshr_b32 s6, s6, 26
	s_load_dwordx4 s[88:91], s[0:1], 0x78
	s_load_dwordx2 s[8:9], s[0:1], 0x88
	s_add_i32 s6, s78, s6
	s_min_i32 s4, s12, s14
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s9, s6, 6
	s_andn2_b32 s6, s6, 63
	s_cmp_lg_u32 s78, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s78, 0
	s_cselect_b64 s[10:11], -1, 0
	s_and_b64 s[6:7], s[10:11], s[6:7]
	s_subb_u32 s7, s9, 0
	s_add_i32 s2, s16, s2
	s_add_i32 s2, s2, 1
	s_max_i32 s2, s2, 0
	s_lshr_b32 s2, s2, 6
	v_mov_b32_e32 v3, s2
	v_mov_b32_e32 v4, s4
	v_min3_i32 v3, s7, v3, v4
	s_min_i32 s6, s4, 0
	v_readfirstlane_b32 s2, v3
	s_max_i32 s74, s2, s6
	v_cmp_gt_i32_e32 vcc, 1, v3
	v_and_b32_e32 v104, 63, v0
	v_mov_b32_e32 v34, 0
	s_ashr_i32 s75, s74, 31
	s_and_b64 vcc, exec, vcc
	v_bfe_u32 v129, v0, 4, 3
	v_lshrrev_b32_e32 v123, 4, v0
	s_mul_i32 s17, s68, s33
	s_mul_i32 s18, s72, s5
	v_and_b32_e32 v128, 15, v0
	s_mul_i32 s10, s88, s33
	s_mul_i32 s11, s8, s5
	v_lshlrev_b32_e32 v124, 4, v0
	v_lshl_or_b32 v126, v1, 7, v121
	v_lshlrev_b32_e32 v127, 3, v0
	v_lshlrev_b32_e32 v1, 1, v1
	v_lshlrev_b32_e32 v125, 10, v2
	s_cbranch_vccnz .LBB0_5
	v_xor_b32_e32 v2, v129, v128
	s_movk_i32 s2, 0xf0
	v_and_or_b32 v3, v0, s2, v2
	v_lshlrev_b32_e32 v131, 4, v3
	v_or_b32_e32 v3, 0x100, v0
	s_movk_i32 s2, 0x1f0
	v_and_or_b32 v4, v3, s2, v2
	v_lshlrev_b32_e32 v132, 4, v4
	v_or_b32_e32 v4, 0x200, v0
	s_movk_i32 s2, 0x2f0
	v_and_or_b32 v5, v4, s2, v2
	v_lshlrev_b32_e32 v133, 4, v5
	v_or_b32_e32 v5, 0x300, v0
	s_movk_i32 s2, 0x3f0
	v_and_or_b32 v2, v5, s2, v2
	v_lshlrev_b32_e32 v134, 4, v2
	v_and_b32_e32 v2, 56, v127
	v_lshlrev_b32_e32 v135, 4, v3
	v_or_b32_e32 v3, v126, v2
	v_lshlrev_b32_e32 v138, 1, v3
	v_or_b32_e32 v3, 8, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v139, 1, v3
	v_or_b32_e32 v3, 16, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v140, 1, v3
	v_or_b32_e32 v3, 24, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v141, 1, v3
	v_or_b32_e32 v3, 32, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v142, 1, v3
	v_or_b32_e32 v3, 40, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v143, 1, v3
	v_or_b32_e32 v3, 48, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v144, 1, v3
	v_or_b32_e32 v3, 56, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v145, 1, v3
	v_or_b32_e32 v3, 0x48, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v146, 1, v3
	v_or_b32_e32 v3, 0x50, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v147, 1, v3
	v_or_b32_e32 v3, 0x58, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v148, 1, v3
	v_or_b32_e32 v3, 0x60, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v149, 1, v3
	v_or_b32_e32 v3, 0x68, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v150, 1, v3
	v_or_b32_e32 v3, 0x70, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v151, 1, v3
	v_or_b32_e32 v3, 0x78, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v152, 1, v3
	v_or_b32_e32 v3, 0x1008, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v153, 1, v3
	v_or_b32_e32 v3, 0x1010, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v154, 1, v3
	v_or_b32_e32 v3, 0x1018, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v155, 1, v3
	v_or_b32_e32 v3, 0x1020, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v156, 1, v3
	v_or_b32_e32 v3, 0x1028, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v157, 1, v3
	v_or_b32_e32 v3, 0x1030, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v158, 1, v3
	v_or_b32_e32 v3, 0x1038, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v159, 1, v3
	v_or_b32_e32 v3, 0x1048, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v160, 1, v3
	v_or_b32_e32 v3, 0x1050, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v161, 1, v3
	v_or_b32_e32 v3, 0x1058, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v162, 1, v3
	v_or_b32_e32 v3, 0x1060, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v163, 1, v3
	v_or_b32_e32 v3, 0x1068, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v164, 1, v3
	v_or_b32_e32 v3, 0x1070, v126
	v_xor_b32_e32 v3, v3, v2
	v_lshlrev_b32_e32 v165, 1, v3
	v_or_b32_e32 v3, 0x1078, v126
	v_xor_b32_e32 v2, v3, v2
	v_lshlrev_b32_e32 v166, 1, v2
	v_lshlrev_b32_e32 v2, 2, v104
	s_ashr_i32 s13, s12, 31
	v_xor_b32_e32 v167, 0x80, v2
	s_ashr_i32 s15, s14, 31
	v_mov_b64_e32 v[2:3], s[12:13]
	s_ashr_i32 s7, s6, 31
	s_add_i32 s5, s78, -1
	s_add_u32 s19, s17, s18
	s_add_u32 s20, s10, s11
	v_cmp_lt_i64_e32 vcc, s[14:15], v[2:3]
	s_movk_i32 s2, 0x4000
	s_and_b64 s[22:23], vcc, exec
	v_or3_b32 v168, v1, v125, s2
	s_cselect_b32 s2, s15, s13
	s_cselect_b32 s12, s14, s12
	s_and_b32 s2, s12, s2
	v_lshl_or_b32 v169, s2, 6, v123
	v_lshlrev_b32_e32 v130, 3, v128
	v_lshlrev_b32_e32 v136, 4, v4
	v_lshlrev_b32_e32 v137, 4, v5
	s_mov_b32 s8, s79
	s_mov_b32 s9, s79
	v_or_b32_e32 v170, 48, v169
	v_or_b32_e32 v171, 32, v169
	v_or_b32_e32 v172, 16, v169
	v_mov_b32_e32 v112, 0
	v_mov_b32_e32 v102, 0xf149f2ca
	s_mov_b32 s2, 0x3fb8aa3b
	s_mov_b32 s12, 0xc2fc0000
	v_mov_b32_e32 v173, 0x42800000
	v_not_b32_e32 v174, 63
	s_movk_i32 s13, 0x7fff
	s_mov_b32 s14, 0x5040100
	s_mov_b32 s15, 0x7060302
	v_mov_b64_e32 v[100:101], s[74:75]
	v_add_u32_e32 v175, 0x2000, v138
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
	v_min_i32_e32 v66, s5, v169
	v_mul_lo_u32 v67, s70, v66
	v_add_u32_e32 v67, s19, v67
	v_add_lshl_u32 v67, v130, v67, 1
	s_barrier
	buffer_load_dwordx4 v[68:71], v67, s[80:83], 0 offen
	v_min_i32_e32 v67, s5, v172
	v_mul_lo_u32 v66, s90, v66
	v_add_u32_e32 v66, s20, v66
	v_add_lshl_u32 v66, v130, v66, 1
	s_mov_b32 s86, s82
	s_mov_b32 s87, s83
	s_add_u32 s6, s6, 1
	s_addc_u32 s7, s7, 0
	v_add_u32_e32 v172, 64, v172
	v_add_u32_e32 v169, 64, v169
	s_waitcnt vmcnt(0)
	ds_write_b128 v131, v[68:71]
	v_mul_lo_u32 v68, s70, v67
	v_add_u32_e32 v68, s19, v68
	v_add_lshl_u32 v68, v130, v68, 1
	buffer_load_dwordx4 v[68:71], v68, s[80:83], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v132, v[68:71]
	v_min_i32_e32 v68, s5, v171
	v_mul_lo_u32 v69, s70, v68
	v_add_u32_e32 v69, s19, v69
	v_add_lshl_u32 v69, v130, v69, 1
	buffer_load_dwordx4 v[70:73], v69, s[80:83], 0 offen
	v_min_i32_e32 v69, s5, v170
	v_add_u32_e32 v170, 64, v170
	v_add_u32_e32 v171, 64, v171
	s_waitcnt vmcnt(0)
	ds_write_b128 v133, v[70:73]
	v_mul_lo_u32 v70, s70, v69
	v_add_u32_e32 v70, s19, v70
	v_add_lshl_u32 v70, v130, v70, 1
	buffer_load_dwordx4 v[70:73], v70, s[80:83], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v134, v[70:73]
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s90, v67
	v_add_u32_e32 v66, s20, v66
	v_add_lshl_u32 v66, v130, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v124, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s90, v68
	v_add_u32_e32 v66, s20, v66
	v_add_lshl_u32 v66, v130, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v135, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s90, v69
	v_add_u32_e32 v66, s20, v66
	v_add_lshl_u32 v66, v130, v66, 1
	buffer_load_dwordx4 v[66:69], v66, s[84:87], 0 offen
	s_waitcnt vmcnt(1)
	ds_write_b128 v136, v[70:73] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v137, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[82:85], v138 offset1:16
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[182:183], 0
	ds_read_b64 v[82:83], v139
	ds_read2_b64 v[176:179], v175 offset1:16
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[184:185], v[66:81]
	ds_read_b64 v[82:83], v140
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[186:187], v[66:81]
	ds_read_b64 v[82:83], v141
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[188:189], v[66:81]
	ds_read_b64 v[82:83], v142
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[190:191], v[66:81]
	ds_read_b64 v[82:83], v143
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[192:193], v[66:81]
	ds_read_b64 v[82:83], v144
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[194:195], v[66:81]
	ds_read_b64 v[82:83], v145
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[196:197], v[66:81]
	ds_read_b64 v[82:83], v146
	v_mfma_f32_32x32x8_bf16 v[66:81], v[84:85], v[198:199], v[66:81]
	s_waitcnt lgkmcnt(0)
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
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[182:183], 0
	ds_read_b64 v[176:177], v153
	s_nop 8
	v_mul_f32_e64 v66, s8, v66
	v_mul_f32_e64 v67, s9, v67
	v_mul_f32_e64 v68, s8, v68
	v_mul_f32_e64 v69, s9, v69
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[70:71], s[8:9], v[70:71]
	v_pk_mul_f32 v[68:69], v[68:69], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[70:71], v[70:71], s[2:3] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[184:185], v[82:97]
	ds_read_b64 v[176:177], v154
	v_mul_f32_e64 v72, s8, v72
	v_mul_f32_e64 v73, s9, v73
	v_mul_f32_e64 v74, s8, v74
	v_mul_f32_e64 v75, s9, v75
	v_pk_mul_f32 v[72:73], v[72:73], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[74:75], v[74:75], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[76:77], s[8:9], v[76:77]
	v_pk_mul_f32 v[78:79], s[8:9], v[78:79]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[186:187], v[82:97]
	ds_read_b64 v[176:177], v155
	v_mul_f32_e64 v76, v76, s2
	v_mul_f32_e64 v77, v77, s2
	v_mul_f32_e64 v78, v78, s2
	v_mul_f32_e64 v79, v79, s2
	v_pk_mul_f32 v[80:81], s[8:9], v[80:81]
	s_nop 0
	v_pk_mul_f32 v[80:81], v[80:81], s[2:3] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[188:189], v[82:97]
	ds_read_b64 v[176:177], v156
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[190:191], v[82:97]
	ds_read_b64 v[176:177], v157
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[192:193], v[82:97]
	ds_read_b64 v[176:177], v158
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[194:195], v[82:97]
	ds_read_b64 v[176:177], v159
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[196:197], v[82:97]
	ds_read_b64 v[176:177], v160
	v_mfma_f32_32x32x8_bf16 v[82:97], v[178:179], v[198:199], v[82:97]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[200:201], v[82:97]
	ds_read_b64 v[176:177], v161
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[202:203], v[82:97]
	ds_read_b64 v[176:177], v162
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[204:205], v[82:97]
	ds_read_b64 v[176:177], v163
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[206:207], v[82:97]
	ds_read_b64 v[176:177], v164
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[208:209], v[82:97]
	ds_read_b64 v[176:177], v165
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[210:211], v[82:97]
	ds_read_b64 v[176:177], v166
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[176:177], v[212:213], v[82:97]
	s_nop 10
	v_mul_f32_e32 v96, s79, v96
	v_mul_f32_e32 v176, 0x3fb8aa3b, v96
	v_mul_f32_e32 v96, s79, v97
	v_pk_mul_f32 v[82:83], s[8:9], v[82:83]
	v_mul_f32_e32 v103, 0x3fb8aa3b, v96
	v_pk_mul_f32 v[96:97], v[82:83], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[82:83], s[8:9], v[84:85]
	v_pk_mul_f32 v[86:87], s[8:9], v[86:87]
	v_pk_mul_f32 v[84:85], v[82:83], s[2:3] op_sel_hi:[1,0]
	v_max_f32_e32 v82, v66, v67
	v_max3_f32 v82, v82, v68, v69
	v_max3_f32 v82, v82, v70, v71
	v_max3_f32 v82, v82, v72, v73
	v_max3_f32 v82, v82, v74, v75
	v_max3_f32 v82, v82, v76, v77
	v_max3_f32 v82, v82, v78, v79
	v_max3_f32 v82, v82, v80, v81
	v_max3_f32 v82, v82, v96, v97
	v_pk_mul_f32 v[86:87], v[86:87], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[88:89], s[8:9], v[88:89]
	v_max3_f32 v82, v82, v84, v85
	v_pk_mul_f32 v[90:91], s[8:9], v[90:91]
	v_pk_mul_f32 v[88:89], v[88:89], s[2:3] op_sel_hi:[1,0]
	v_max3_f32 v82, v82, v86, v87
	v_pk_mul_f32 v[90:91], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[92:93], s[8:9], v[92:93]
	v_max3_f32 v82, v82, v88, v89
	v_pk_mul_f32 v[94:95], s[8:9], v[94:95]
	v_pk_mul_f32 v[92:93], v[92:93], s[2:3] op_sel_hi:[1,0]
	v_max3_f32 v82, v82, v90, v91
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	v_max3_f32 v82, v82, v92, v93
	v_max3_f32 v82, v82, v94, v95
	v_max3_f32 v82, v82, v176, v103
	ds_bpermute_b32 v83, v167, v82
	s_waitcnt lgkmcnt(0)
	v_max3_f32 v82, v102, v82, v83
	v_pk_add_f32 v[66:67], v[66:67], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v83, 0, v173, vcc
	v_add_f32_e32 v67, v67, v83
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v83, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v83, v67, v83
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v177, v66, v67
	v_pk_add_f32 v[66:67], v[68:69], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v68, 0, v173, vcc
	v_add_f32_e32 v67, v67, v68
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v68, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v68, v67, v68
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v69, v66, v67
	v_pk_add_f32 v[66:67], v[70:71], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v70, 0, v173, vcc
	v_add_f32_e32 v67, v67, v70
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v70, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v70, v67, v70
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v71, v66, v67
	v_pk_add_f32 v[66:67], v[72:73], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v72, 0, v173, vcc
	v_add_f32_e32 v67, v67, v72
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v72, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v72, v67, v72
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v73, v66, v67
	v_pk_add_f32 v[66:67], v[74:75], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v74, 0, v173, vcc
	v_add_f32_e32 v67, v67, v74
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v74, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v74, v67, v74
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v75, v66, v67
	v_pk_add_f32 v[66:67], v[76:77], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v76, 0, v173, vcc
	v_add_f32_e32 v67, v67, v76
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v76, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v76, v67, v76
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v77, v66, v67
	v_pk_add_f32 v[66:67], v[78:79], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v78, 0, v173, vcc
	v_add_f32_e32 v67, v67, v78
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v78, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v78, v67, v78
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v79, v66, v67
	v_pk_add_f32 v[66:67], v[80:81], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v80, 0, v173, vcc
	v_add_f32_e32 v67, v67, v80
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v80, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v80, v67, v80
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v81, v66, v67
	v_pk_add_f32 v[66:67], v[96:97], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v96, 0, v173, vcc
	v_add_f32_e32 v67, v67, v96
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v96, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v96, v67, v96
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v97, v66, v67
	v_pk_add_f32 v[66:67], v[84:85], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v84, 0, v173, vcc
	v_add_f32_e32 v67, v67, v84
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v84, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v84, v67, v84
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v85, v66, v67
	v_pk_add_f32 v[66:67], v[86:87], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v86, 0, v173, vcc
	v_add_f32_e32 v67, v67, v86
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v86, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v86, v67, v86
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v87, v66, v67
	v_pk_add_f32 v[66:67], v[88:89], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v88, 0, v173, vcc
	v_add_f32_e32 v67, v67, v88
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v88, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v88, v67, v88
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v89, v66, v67
	v_pk_add_f32 v[66:67], v[90:91], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v90, 0, v173, vcc
	v_add_f32_e32 v67, v67, v90
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v90, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v90, v67, v90
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v91, v66, v67
	v_pk_add_f32 v[66:67], v[92:93], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v92, 0, v173, vcc
	v_add_f32_e32 v67, v67, v92
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v92, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v92, v67, v92
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v93, v66, v67
	v_pk_add_f32 v[66:67], v[94:95], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v67
	s_nop 1
	v_cndmask_b32_e32 v94, 0, v173, vcc
	v_add_f32_e32 v67, v67, v94
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v94, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v66
	v_ldexp_f32 v94, v67, v94
	s_nop 0
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v95, v66, v67
	v_sub_f32_e32 v66, v176, v82
	v_cmp_gt_f32_e32 vcc, s12, v66
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v173, vcc
	v_add_f32_e32 v66, v66, v67
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v67, 0, v174, vcc
	v_ldexp_f32 v176, v66, v67
	v_add_f32_e32 v66, v177, v83
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
	v_add_f32_e32 v66, v97, v66
	v_add_f32_e32 v66, v96, v66
	v_add_f32_e32 v66, v85, v66
	v_add_f32_e32 v66, v84, v66
	v_add_f32_e32 v66, v87, v66
	v_add_f32_e32 v66, v86, v66
	v_add_f32_e32 v66, v89, v66
	v_add_f32_e32 v66, v88, v66
	v_add_f32_e32 v66, v91, v66
	v_add_f32_e32 v66, v90, v66
	v_add_f32_e32 v66, v93, v66
	v_add_f32_e32 v66, v92, v66
	v_add_f32_e32 v66, v95, v66
	v_add_f32_e32 v66, v94, v66
	v_add_f32_e32 v178, v176, v66
	v_pk_add_f32 v[66:67], v[102:103], v[82:83] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e32 vcc, s12, v66
	s_nop 1
	v_cndmask_b32_e32 v102, 0, v173, vcc
	v_add_f32_e32 v66, v66, v102
	v_exp_f32_e32 v66, v66
	v_cndmask_b32_e32 v102, 0, v174, vcc
	v_cmp_gt_f32_e32 vcc, s12, v67
	v_ldexp_f32 v66, v66, v102
	s_nop 0
	v_cndmask_b32_e32 v102, 0, v173, vcc
	v_add_f32_e32 v67, v67, v102
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v102, 0, v174, vcc
	v_cmp_u_f32_e32 vcc, v177, v177
	v_ldexp_f32 v102, v67, v102
	v_add_f32_e32 v67, v178, v102
	ds_bpermute_b32 v103, v167, v67
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v67, v67, v103
	v_mul_f32_e32 v103, v112, v66
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
	v_bfe_u32 v66, v177, 16, 1
	v_add_f32_e32 v112, v103, v67
	v_add3_u32 v66, v66, v177, s13
	v_or_b32_e32 v67, 0x400000, v177
	v_cndmask_b32_e32 v103, v66, v67, vcc
	v_bfe_u32 v66, v83, 16, 1
	v_add3_u32 v66, v66, v83, s13
	v_or_b32_e32 v67, 0x400000, v83
	v_cmp_u_f32_e32 vcc, v83, v83
	s_nop 1
	v_cndmask_b32_e32 v83, v66, v67, vcc
	v_bfe_u32 v66, v69, 16, 1
	v_add3_u32 v66, v66, v69, s13
	v_or_b32_e32 v67, 0x400000, v69
	v_cmp_u_f32_e32 vcc, v69, v69
	s_nop 1
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v68, 16, 1
	v_add3_u32 v66, v66, v68, s13
	v_or_b32_e32 v67, 0x400000, v68
	v_cmp_u_f32_e32 vcc, v68, v68
	s_nop 1
	v_cndmask_b32_e32 v68, v66, v67, vcc
	ds_read_u16 v66, v168
	ds_read_u16 v177, v168 offset:256
	ds_read_u16 v67, v168 offset:512
	ds_read_u16 v178, v168 offset:768
	v_perm_b32 v69, v68, v69, s15
	v_perm_b32 v68, v83, v103, s15
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v177, v66, s14
	v_cmp_u_f32_e32 vcc, v71, v71
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v178, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:64
	ds_read_u16 v83, v168 offset:320
	ds_read_u16 v67, v168 offset:576
	ds_read_u16 v103, v168 offset:832
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v83, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v103, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:128
	ds_read_u16 v83, v168 offset:384
	ds_read_u16 v67, v168 offset:640
	ds_read_u16 v103, v168 offset:896
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v83, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v103, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:192
	ds_read_u16 v83, v168 offset:448
	ds_read_u16 v67, v168 offset:704
	ds_read_u16 v103, v168 offset:960
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v83, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v103, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v71, 16, 1
	v_add3_u32 v66, v66, v71, s13
	v_or_b32_e32 v67, 0x400000, v71
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v70, 16, 1
	v_add3_u32 v66, v66, v70, s13
	v_or_b32_e32 v67, 0x400000, v70
	v_cmp_u_f32_e32 vcc, v70, v70
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v73, 16, 1
	v_add3_u32 v66, v66, v73, s13
	v_or_b32_e32 v67, 0x400000, v73
	v_cmp_u_f32_e32 vcc, v73, v73
	v_perm_b32 v68, v70, v68, s15
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v72, 16, 1
	v_add3_u32 v66, v66, v72, s13
	v_or_b32_e32 v67, 0x400000, v72
	v_cmp_u_f32_e32 vcc, v72, v72
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v168 offset:2048
	ds_read_u16 v72, v168 offset:2304
	ds_read_u16 v67, v168 offset:2560
	ds_read_u16 v73, v168 offset:2816
	v_perm_b32 v69, v71, v69, s15
	v_cmp_u_f32_e32 vcc, v75, v75
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:2112
	ds_read_u16 v70, v168 offset:2368
	ds_read_u16 v67, v168 offset:2624
	ds_read_u16 v71, v168 offset:2880
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:2176
	ds_read_u16 v70, v168 offset:2432
	ds_read_u16 v67, v168 offset:2688
	ds_read_u16 v71, v168 offset:2944
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:2240
	ds_read_u16 v70, v168 offset:2496
	ds_read_u16 v67, v168 offset:2752
	ds_read_u16 v71, v168 offset:3008
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v75, 16, 1
	v_add3_u32 v66, v66, v75, s13
	v_or_b32_e32 v67, 0x400000, v75
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v74, 16, 1
	v_add3_u32 v66, v66, v74, s13
	v_or_b32_e32 v67, 0x400000, v74
	v_cmp_u_f32_e32 vcc, v74, v74
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v77, 16, 1
	v_add3_u32 v66, v66, v77, s13
	v_or_b32_e32 v67, 0x400000, v77
	v_cmp_u_f32_e32 vcc, v77, v77
	v_perm_b32 v68, v70, v68, s15
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v76, 16, 1
	v_add3_u32 v66, v66, v76, s13
	v_or_b32_e32 v67, 0x400000, v76
	v_cmp_u_f32_e32 vcc, v76, v76
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v168 offset:4096
	ds_read_u16 v72, v168 offset:4352
	ds_read_u16 v67, v168 offset:4608
	ds_read_u16 v73, v168 offset:4864
	v_perm_b32 v69, v71, v69, s15
	v_cmp_u_f32_e32 vcc, v79, v79
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:4160
	ds_read_u16 v70, v168 offset:4416
	ds_read_u16 v67, v168 offset:4672
	ds_read_u16 v71, v168 offset:4928
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:4224
	ds_read_u16 v70, v168 offset:4480
	ds_read_u16 v67, v168 offset:4736
	ds_read_u16 v71, v168 offset:4992
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:4288
	ds_read_u16 v70, v168 offset:4544
	ds_read_u16 v67, v168 offset:4800
	ds_read_u16 v71, v168 offset:5056
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v79, 16, 1
	v_add3_u32 v66, v66, v79, s13
	v_or_b32_e32 v67, 0x400000, v79
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v78, 16, 1
	v_add3_u32 v66, v66, v78, s13
	v_or_b32_e32 v67, 0x400000, v78
	v_cmp_u_f32_e32 vcc, v78, v78
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v81, 16, 1
	v_add3_u32 v66, v66, v81, s13
	v_or_b32_e32 v67, 0x400000, v81
	v_cmp_u_f32_e32 vcc, v81, v81
	v_perm_b32 v68, v70, v68, s15
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v80, 16, 1
	v_add3_u32 v66, v66, v80, s13
	v_or_b32_e32 v67, 0x400000, v80
	v_cmp_u_f32_e32 vcc, v80, v80
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v168 offset:6144
	ds_read_u16 v72, v168 offset:6400
	ds_read_u16 v67, v168 offset:6656
	ds_read_u16 v73, v168 offset:6912
	v_perm_b32 v69, v71, v69, s15
	v_cmp_u_f32_e32 vcc, v97, v97
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:6208
	ds_read_u16 v70, v168 offset:6464
	ds_read_u16 v67, v168 offset:6720
	ds_read_u16 v71, v168 offset:6976
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:6272
	ds_read_u16 v70, v168 offset:6528
	ds_read_u16 v67, v168 offset:6784
	ds_read_u16 v71, v168 offset:7040
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:6336
	ds_read_u16 v70, v168 offset:6592
	ds_read_u16 v67, v168 offset:6848
	ds_read_u16 v71, v168 offset:7104
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v97, 16, 1
	v_add3_u32 v66, v66, v97, s13
	v_or_b32_e32 v67, 0x400000, v97
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v96, 16, 1
	v_add3_u32 v66, v66, v96, s13
	v_or_b32_e32 v67, 0x400000, v96
	v_cmp_u_f32_e32 vcc, v96, v96
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v85, 16, 1
	v_add3_u32 v66, v66, v85, s13
	v_or_b32_e32 v67, 0x400000, v85
	v_cmp_u_f32_e32 vcc, v85, v85
	v_perm_b32 v68, v70, v68, s15
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v84, 16, 1
	v_add3_u32 v66, v66, v84, s13
	v_or_b32_e32 v67, 0x400000, v84
	v_cmp_u_f32_e32 vcc, v84, v84
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v168 offset:8192
	ds_read_u16 v72, v168 offset:8448
	ds_read_u16 v67, v168 offset:8704
	ds_read_u16 v73, v168 offset:8960
	v_perm_b32 v69, v71, v69, s15
	v_cmp_u_f32_e32 vcc, v87, v87
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:8256
	ds_read_u16 v70, v168 offset:8512
	ds_read_u16 v67, v168 offset:8768
	ds_read_u16 v71, v168 offset:9024
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:8320
	ds_read_u16 v70, v168 offset:8576
	ds_read_u16 v67, v168 offset:8832
	ds_read_u16 v71, v168 offset:9088
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:8384
	ds_read_u16 v70, v168 offset:8640
	ds_read_u16 v67, v168 offset:8896
	ds_read_u16 v71, v168 offset:9152
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v87, 16, 1
	v_add3_u32 v66, v66, v87, s13
	v_or_b32_e32 v67, 0x400000, v87
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v86, 16, 1
	v_add3_u32 v66, v66, v86, s13
	v_or_b32_e32 v67, 0x400000, v86
	v_cmp_u_f32_e32 vcc, v86, v86
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v89, 16, 1
	v_add3_u32 v66, v66, v89, s13
	v_or_b32_e32 v67, 0x400000, v89
	v_cmp_u_f32_e32 vcc, v89, v89
	v_perm_b32 v68, v70, v68, s15
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v88, 16, 1
	v_add3_u32 v66, v66, v88, s13
	v_or_b32_e32 v67, 0x400000, v88
	v_cmp_u_f32_e32 vcc, v88, v88
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v168 offset:10240
	ds_read_u16 v72, v168 offset:10496
	ds_read_u16 v67, v168 offset:10752
	ds_read_u16 v73, v168 offset:11008
	v_perm_b32 v69, v71, v69, s15
	v_cmp_u_f32_e32 vcc, v91, v91
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:10304
	ds_read_u16 v70, v168 offset:10560
	ds_read_u16 v67, v168 offset:10816
	ds_read_u16 v71, v168 offset:11072
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:10368
	ds_read_u16 v70, v168 offset:10624
	ds_read_u16 v67, v168 offset:10880
	ds_read_u16 v71, v168 offset:11136
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:10432
	ds_read_u16 v70, v168 offset:10688
	ds_read_u16 v67, v168 offset:10944
	ds_read_u16 v71, v168 offset:11200
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v91, 16, 1
	v_add3_u32 v66, v66, v91, s13
	v_or_b32_e32 v67, 0x400000, v91
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v90, 16, 1
	v_add3_u32 v66, v66, v90, s13
	v_or_b32_e32 v67, 0x400000, v90
	v_cmp_u_f32_e32 vcc, v90, v90
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v93, 16, 1
	v_add3_u32 v66, v66, v93, s13
	v_or_b32_e32 v67, 0x400000, v93
	v_cmp_u_f32_e32 vcc, v93, v93
	v_perm_b32 v68, v70, v68, s15
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v92, 16, 1
	v_add3_u32 v66, v66, v92, s13
	v_or_b32_e32 v67, 0x400000, v92
	v_cmp_u_f32_e32 vcc, v92, v92
	s_nop 1
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v168 offset:12288
	ds_read_u16 v72, v168 offset:12544
	ds_read_u16 v67, v168 offset:12800
	ds_read_u16 v73, v168 offset:13056
	v_perm_b32 v69, v71, v69, s15
	v_cmp_u_f32_e32 vcc, v95, v95
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:12352
	ds_read_u16 v70, v168 offset:12608
	ds_read_u16 v67, v168 offset:12864
	ds_read_u16 v71, v168 offset:13120
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:12416
	ds_read_u16 v70, v168 offset:12672
	ds_read_u16 v67, v168 offset:12928
	ds_read_u16 v71, v168 offset:13184
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:12480
	ds_read_u16 v70, v168 offset:12736
	ds_read_u16 v67, v168 offset:12992
	ds_read_u16 v71, v168 offset:13248
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	v_bfe_u32 v66, v95, 16, 1
	v_add3_u32 v66, v66, v95, s13
	v_or_b32_e32 v67, 0x400000, v95
	v_cndmask_b32_e32 v68, v66, v67, vcc
	v_bfe_u32 v66, v94, 16, 1
	v_add3_u32 v66, v66, v94, s13
	v_or_b32_e32 v67, 0x400000, v94
	v_cmp_u_f32_e32 vcc, v94, v94
	s_nop 1
	v_cndmask_b32_e32 v70, v66, v67, vcc
	v_bfe_u32 v66, v176, 16, 1
	v_add3_u32 v66, v66, v176, s13
	v_or_b32_e32 v67, 0x400000, v176
	v_cmp_u_f32_e32 vcc, v176, v176
	v_perm_b32 v68, v70, v68, s15
	s_nop 0
	v_cndmask_b32_e32 v69, v66, v67, vcc
	v_bfe_u32 v66, v102, 16, 1
	v_add3_u32 v66, v66, v102, s13
	v_or_b32_e32 v67, 0x400000, v102
	v_cmp_u_f32_e32 vcc, v102, v102
	v_mov_b32_e32 v102, v82
	s_nop 0
	v_cndmask_b32_e32 v71, v66, v67, vcc
	ds_read_u16 v66, v168 offset:14336
	ds_read_u16 v72, v168 offset:14592
	ds_read_u16 v67, v168 offset:14848
	ds_read_u16 v73, v168 offset:15104
	v_perm_b32 v69, v71, v69, s15
	v_cmp_lt_i64_e32 vcc, s[6:7], v[100:101]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v72, v66, s14
	s_and_b64 vcc, exec, vcc
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v73, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[66:67], v[68:69], v[34:49]
	ds_read_u16 v66, v168 offset:14400
	ds_read_u16 v70, v168 offset:14656
	ds_read_u16 v67, v168 offset:14912
	ds_read_u16 v71, v168 offset:15168
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[66:67], v[68:69], v[50:65]
	ds_read_u16 v66, v168 offset:14464
	ds_read_u16 v70, v168 offset:14720
	ds_read_u16 v67, v168 offset:14976
	ds_read_u16 v71, v168 offset:15232
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[66:67], v[68:69], v[18:33]
	ds_read_u16 v66, v168 offset:14528
	ds_read_u16 v70, v168 offset:14784
	ds_read_u16 v67, v168 offset:15040
	ds_read_u16 v71, v168 offset:15296
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v66, v70, v66, s14
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v67, v71, v67, s14
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[66:67], v[68:69], v[2:17]
	s_cbranch_vccnz .LBB0_3
	s_cmp_ge_i32 s74, s4
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
	v_mov_b32_e32 v82, 0xf149f2ca
	v_mov_b32_e32 v112, 0
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
	s_cmp_ge_i32 s74, s4
	s_cbranch_scc1 .LBB0_9
.LBB0_6:
	v_xor_b32_e32 v66, v129, v128
	s_movk_i32 s6, 0xf0
	v_and_or_b32 v66, v0, s6, v66
	v_lshlrev_b32_e32 v84, 4, v66
	v_or_b32_e32 v66, 0x100, v0
	v_bfe_u32 v67, v66, 4, 3
	v_xor_b32_e32 v67, v67, v128
	s_movk_i32 s6, 0x1f0
	v_and_or_b32 v67, v66, s6, v67
	v_lshlrev_b32_e32 v86, 4, v67
	v_or_b32_e32 v67, 0x200, v0
	v_bfe_u32 v68, v67, 4, 3
	v_xor_b32_e32 v68, v68, v128
	s_movk_i32 s6, 0x2f0
	v_and_or_b32 v68, v67, s6, v68
	v_or_b32_e32 v0, 0x300, v0
	v_lshlrev_b32_e32 v88, 4, v68
	v_bfe_u32 v68, v0, 4, 3
	v_xor_b32_e32 v68, v68, v128
	s_movk_i32 s6, 0x3f0
	v_lshrrev_b32_e32 v89, 4, v0
	v_and_or_b32 v68, v0, s6, v68
	v_lshlrev_b32_e32 v93, 4, v0
	v_and_b32_e32 v0, 56, v127
	v_lshrrev_b32_e32 v85, 4, v66
	v_lshlrev_b32_e32 v91, 4, v66
	v_or_b32_e32 v66, v126, v0
	v_lshlrev_b32_e32 v94, 1, v66
	v_or_b32_e32 v66, 8, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v95, 1, v66
	v_or_b32_e32 v66, 16, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v96, 1, v66
	v_or_b32_e32 v66, 24, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v97, 1, v66
	v_or_b32_e32 v66, 32, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v100, 1, v66
	v_or_b32_e32 v66, 40, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v101, 1, v66
	v_or_b32_e32 v66, 48, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v102, 1, v66
	v_or_b32_e32 v66, 56, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v103, 1, v66
	v_or_b32_e32 v66, 0x48, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v127, 1, v66
	v_or_b32_e32 v66, 0x50, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v83, 3, v128
	v_lshlrev_b32_e32 v128, 1, v66
	v_or_b32_e32 v66, 0x58, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v129, 1, v66
	v_or_b32_e32 v66, 0x60, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v130, 1, v66
	v_or_b32_e32 v66, 0x68, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v131, 1, v66
	v_or_b32_e32 v66, 0x70, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v132, 1, v66
	v_or_b32_e32 v66, 0x78, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v133, 1, v66
	v_or_b32_e32 v66, 0x1008, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v147, 1, v66
	v_or_b32_e32 v66, 0x1010, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v148, 1, v66
	v_or_b32_e32 v66, 0x1018, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v149, 1, v66
	v_or_b32_e32 v66, 0x1020, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v150, 1, v66
	v_or_b32_e32 v66, 0x1028, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v151, 1, v66
	v_or_b32_e32 v66, 0x1030, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v152, 1, v66
	v_or_b32_e32 v66, 0x1038, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v153, 1, v66
	v_or_b32_e32 v66, 0x1048, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v154, 1, v66
	v_or_b32_e32 v66, 0x1050, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v155, 1, v66
	v_or_b32_e32 v66, 0x1058, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v156, 1, v66
	v_or_b32_e32 v66, 0x1060, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v157, 1, v66
	v_or_b32_e32 v66, 0x1068, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v158, 1, v66
	v_or_b32_e32 v66, 0x1070, v126
	v_xor_b32_e32 v66, v66, v0
	v_lshlrev_b32_e32 v159, 1, v66
	v_or_b32_e32 v66, 0x1078, v126
	v_xor_b32_e32 v0, v66, v0
	s_ashr_i32 s5, s4, 31
	v_lshlrev_b32_e32 v126, 1, v0
	v_lshlrev_b32_e32 v0, 2, v104
	s_movk_i32 s6, 0x4000
	s_add_i32 s2, s78, -1
	s_add_u32 s71, s17, s18
	v_lshrrev_b32_e32 v87, 4, v67
	v_lshlrev_b32_e32 v90, 4, v68
	s_add_u32 s72, s10, s11
	v_lshlrev_b32_e32 v92, 4, v67
	v_add_u32_e32 v134, s16, v122
	v_or_b32_e32 v135, 1, v121
	v_or_b32_e32 v136, 2, v121
	v_or_b32_e32 v137, 3, v121
	v_or_b32_e32 v138, 9, v121
	v_or_b32_e32 v139, 10, v121
	v_or_b32_e32 v140, 11, v121
	v_or_b32_e32 v141, 17, v121
	v_or_b32_e32 v142, 18, v121
	v_or_b32_e32 v143, 19, v121
	v_or_b32_e32 v144, 25, v121
	v_or_b32_e32 v145, 26, v121
	v_or_b32_e32 v146, 27, v121
	v_xor_b32_e32 v160, 0x80, v0
	v_or3_b32 v125, v1, v125, s6
	s_mov_b32 s86, s82
	s_mov_b32 s87, s83
	v_mov_b32_e32 v161, 0xf149f2ca
	s_mov_b32 s73, 0xc2fc0000
	v_mov_b32_e32 v162, 0x42800000
	v_not_b32_e32 v163, 63
	s_movk_i32 s76, 0x7fff
	s_mov_b32 s88, 0x5040100
	s_mov_b32 s89, 0x7060302
	v_mov_b64_e32 v[0:1], s[4:5]
	v_add_u32_e32 v164, 0x2000, v94
.LBB0_7:
	s_lshl_b32 s36, s74, 6
	v_or_b32_e32 v66, s36, v123
	v_min_i32_e32 v66, s2, v66
	v_mul_lo_u32 v67, s70, v66
	v_add_u32_e32 v67, s71, v67
	v_add_lshl_u32 v67, v83, v67, 1
	s_barrier
	buffer_load_dwordx4 v[68:71], v67, s[80:83], 0 offen
	v_or_b32_e32 v67, s36, v85
	v_min_i32_e32 v67, s2, v67
	v_mul_lo_u32 v66, s90, v66
	v_add_u32_e32 v66, s72, v66
	v_add_lshl_u32 v66, v83, v66, 1
	s_or_b32 s68, s36, 32
	v_or_b32_e32 v181, s68, v121
	s_waitcnt vmcnt(0)
	ds_write_b128 v84, v[68:71]
	v_mul_lo_u32 v68, s70, v67
	v_add_u32_e32 v68, s71, v68
	v_add_lshl_u32 v68, v83, v68, 1
	buffer_load_dwordx4 v[68:71], v68, s[80:83], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v86, v[68:71]
	v_or_b32_e32 v68, s36, v87
	v_min_i32_e32 v68, s2, v68
	v_mul_lo_u32 v69, s70, v68
	v_add_u32_e32 v69, s71, v69
	v_add_lshl_u32 v69, v83, v69, 1
	buffer_load_dwordx4 v[70:73], v69, s[80:83], 0 offen
	v_or_b32_e32 v69, s36, v89
	v_min_i32_e32 v69, s2, v69
	s_waitcnt vmcnt(0)
	ds_write_b128 v88, v[70:73]
	v_mul_lo_u32 v70, s70, v69
	v_add_u32_e32 v70, s71, v70
	v_add_lshl_u32 v70, v83, v70, 1
	buffer_load_dwordx4 v[70:73], v70, s[80:83], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v90, v[70:73]
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s90, v67
	v_add_u32_e32 v66, s72, v66
	v_add_lshl_u32 v66, v83, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v124, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s90, v68
	v_add_u32_e32 v66, s72, v66
	v_add_lshl_u32 v66, v83, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v91, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s90, v69
	v_add_u32_e32 v66, s72, v66
	v_add_lshl_u32 v66, v83, v66, 1
	buffer_load_dwordx4 v[66:69], v66, s[84:87], 0 offen
	s_waitcnt vmcnt(1)
	ds_write_b128 v92, v[70:73] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v93, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[166:169], v94 offset1:16
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[182:183], 0
	ds_read_b64 v[166:167], v95
	ds_read2_b64 v[214:217], v164 offset1:16
	s_waitcnt lgkmcnt(1)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[184:185], v[66:81]
	ds_read_b64 v[166:167], v96
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[186:187], v[66:81]
	ds_read_b64 v[166:167], v97
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[188:189], v[66:81]
	ds_read_b64 v[166:167], v100
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[190:191], v[66:81]
	ds_read_b64 v[166:167], v101
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[192:193], v[66:81]
	ds_read_b64 v[166:167], v102
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[194:195], v[66:81]
	ds_read_b64 v[166:167], v103
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[196:197], v[66:81]
	ds_read_b64 v[166:167], v127
	v_mfma_f32_32x32x8_bf16 v[66:81], v[168:169], v[198:199], v[66:81]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[200:201], v[66:81]
	ds_read_b64 v[166:167], v128
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[202:203], v[66:81]
	ds_read_b64 v[166:167], v129
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[204:205], v[66:81]
	ds_read_b64 v[166:167], v130
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[206:207], v[66:81]
	ds_read_b64 v[166:167], v131
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[208:209], v[66:81]
	ds_read_b64 v[166:167], v132
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[210:211], v[66:81]
	ds_read_b64 v[166:167], v133
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[166:167], v[212:213], v[66:81]
	v_or_b32_e32 v166, s36, v121
	v_cmp_gt_i32_e32 vcc, s78, v166
	s_nop 8
	v_mul_f32_e32 v66, s79, v66
	v_mul_f32_e32 v165, 0x3fb8aa3b, v66
	v_sub_u32_e32 v66, v166, v134
	v_cmp_gt_i32_e64 s[4:5], 1, v66
	v_or_b32_e32 v66, s36, v135
	s_and_b64 s[4:5], vcc, s[4:5]
	v_cmp_gt_i32_e32 vcc, s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_cmp_gt_i32_e64 s[6:7], 1, v66
	v_or_b32_e32 v66, s36, v136
	s_and_b64 s[12:13], vcc, s[6:7]
	v_cmp_gt_i32_e32 vcc, s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_cmp_gt_i32_e64 s[6:7], 1, v66
	v_or_b32_e32 v66, s36, v137
	s_and_b64 s[66:67], vcc, s[6:7]
	v_cmp_gt_i32_e32 vcc, s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_cmp_gt_i32_e64 s[6:7], 1, v66
	v_or_b32_e32 v66, s36, v119
	s_and_b64 s[10:11], vcc, s[6:7]
	v_cmp_gt_i32_e32 vcc, s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_cmp_gt_i32_e64 s[6:7], 1, v66
	v_or_b32_e32 v66, s36, v138
	s_and_b64 vcc, vcc, s[6:7]
	v_cmp_gt_i32_e64 s[6:7], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_cmp_gt_i32_e64 s[8:9], 1, v66
	v_or_b32_e32 v66, s36, v139
	s_and_b64 s[8:9], s[6:7], s[8:9]
	v_cmp_gt_i32_e64 s[6:7], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_cmp_gt_i32_e64 s[14:15], 1, v66
	v_or_b32_e32 v66, s36, v140
	s_and_b64 s[6:7], s[6:7], s[14:15]
	v_cmp_gt_i32_e64 s[14:15], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_cmp_gt_i32_e64 s[16:17], 1, v66
	v_or_b32_e32 v66, s36, v118
	v_mul_f32_e32 v67, s79, v67
	s_and_b64 s[16:17], s[14:15], s[16:17]
	v_cmp_gt_i32_e64 s[14:15], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v166, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v68
	v_cmp_gt_i32_e64 s[18:19], 1, v66
	v_or_b32_e32 v66, s36, v141
	v_mul_f32_e32 v167, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v69
	s_and_b64 s[14:15], s[14:15], s[18:19]
	v_cmp_gt_i32_e64 s[18:19], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v168, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v70
	v_cmp_gt_i32_e64 s[20:21], 1, v66
	v_or_b32_e32 v66, s36, v142
	v_mul_f32_e32 v169, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v71
	s_and_b64 s[20:21], s[18:19], s[20:21]
	v_cmp_gt_i32_e64 s[18:19], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v170, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v72
	v_cmp_gt_i32_e64 s[22:23], 1, v66
	v_or_b32_e32 v66, s36, v143
	v_mul_f32_e32 v171, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v73
	s_and_b64 s[18:19], s[18:19], s[22:23]
	v_cmp_gt_i32_e64 s[22:23], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v172, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v74
	v_cmp_gt_i32_e64 s[24:25], 1, v66
	v_or_b32_e32 v66, s36, v117
	v_mul_f32_e32 v173, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v75
	s_and_b64 s[24:25], s[22:23], s[24:25]
	v_cmp_gt_i32_e64 s[22:23], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v174, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v76
	v_cmp_gt_i32_e64 s[26:27], 1, v66
	v_or_b32_e32 v66, s36, v144
	v_mul_f32_e32 v175, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v77
	s_and_b64 s[22:23], s[22:23], s[26:27]
	v_cmp_gt_i32_e64 s[26:27], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v176, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v78
	v_cmp_gt_i32_e64 s[28:29], 1, v66
	v_or_b32_e32 v66, s36, v145
	v_mul_f32_e32 v177, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v79
	s_and_b64 s[28:29], s[26:27], s[28:29]
	v_cmp_gt_i32_e64 s[26:27], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v178, 0x3fb8aa3b, v67
	v_mul_f32_e32 v67, s79, v80
	v_cmp_gt_i32_e64 s[30:31], 1, v66
	v_or_b32_e32 v66, s36, v146
	v_mul_f32_e32 v179, 0x3fb8aa3b, v67
	s_and_b64 s[26:27], s[26:27], s[30:31]
	v_mul_f32_e32 v67, s79, v81
	v_cmp_gt_i32_e64 s[30:31], s78, v66
	v_sub_u32_e32 v66, v66, v134
	v_mul_f32_e32 v180, 0x3fb8aa3b, v67
	v_cmp_gt_i32_e64 s[34:35], 1, v66
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[182:183], 0
	ds_read_b64 v[214:215], v147
	s_and_b64 s[30:31], s[30:31], s[34:35]
	v_cmp_gt_i32_e64 s[34:35], s78, v181
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[36:37], 1, v181
	v_or_b32_e32 v181, s68, v135
	s_and_b64 s[34:35], s[34:35], s[36:37]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[184:185], v[66:81]
	ds_read_b64 v[214:215], v148
	v_cmp_gt_i32_e64 s[36:37], s78, v181
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[38:39], 1, v181
	v_or_b32_e32 v181, s68, v136
	s_and_b64 s[36:37], s[36:37], s[38:39]
	v_cmp_gt_i32_e64 s[38:39], s78, v181
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[186:187], v[66:81]
	ds_read_b64 v[214:215], v149
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[40:41], 1, v181
	v_or_b32_e32 v181, s68, v137
	s_and_b64 s[38:39], s[38:39], s[40:41]
	v_cmp_gt_i32_e64 s[40:41], s78, v181
	v_sub_u32_e32 v181, v181, v134
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[188:189], v[66:81]
	ds_read_b64 v[214:215], v150
	v_cmp_gt_i32_e64 s[42:43], 1, v181
	v_or_b32_e32 v181, s68, v119
	s_and_b64 s[40:41], s[40:41], s[42:43]
	v_cmp_gt_i32_e64 s[42:43], s78, v181
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[44:45], 1, v181
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[190:191], v[66:81]
	ds_read_b64 v[214:215], v151
	v_or_b32_e32 v181, s68, v138
	s_and_b64 s[42:43], s[42:43], s[44:45]
	v_cmp_gt_i32_e64 s[44:45], s78, v181
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[46:47], 1, v181
	v_or_b32_e32 v181, s68, v139
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[192:193], v[66:81]
	ds_read_b64 v[214:215], v152
	s_and_b64 s[44:45], s[44:45], s[46:47]
	v_cmp_gt_i32_e64 s[46:47], s78, v181
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[48:49], 1, v181
	v_or_b32_e32 v181, s68, v140
	s_and_b64 s[46:47], s[46:47], s[48:49]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[194:195], v[66:81]
	ds_read_b64 v[214:215], v153
	v_cmp_gt_i32_e64 s[48:49], s78, v181
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[50:51], 1, v181
	v_or_b32_e32 v181, s68, v118
	s_and_b64 s[48:49], s[48:49], s[50:51]
	v_cmp_gt_i32_e64 s[50:51], s78, v181
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[196:197], v[66:81]
	ds_read_b64 v[214:215], v154
	v_sub_u32_e32 v181, v181, v134
	v_cmp_gt_i32_e64 s[52:53], 1, v181
	v_or_b32_e32 v181, s68, v141
	s_and_b64 s[50:51], s[50:51], s[52:53]
	v_cmp_gt_i32_e64 s[52:53], s78, v181
	v_sub_u32_e32 v181, v181, v134
	v_mfma_f32_32x32x8_bf16 v[66:81], v[216:217], v[198:199], v[66:81]
	v_cmp_gt_i32_e64 s[54:55], 1, v181
	s_and_b64 s[52:53], s[52:53], s[54:55]
	v_cndmask_b32_e64 v216, v161, v177, s[22:23]
	v_cndmask_b32_e64 v217, v161, v178, s[28:29]
	v_cndmask_b32_e64 v218, v161, v179, s[26:27]
	v_cndmask_b32_e64 v219, v161, v180, s[30:31]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[200:201], v[66:81]
	ds_read_b64 v[214:215], v155
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[202:203], v[66:81]
	ds_read_b64 v[214:215], v156
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[204:205], v[66:81]
	ds_read_b64 v[214:215], v157
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[206:207], v[66:81]
	ds_read_b64 v[214:215], v158
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[208:209], v[66:81]
	ds_read_b64 v[214:215], v159
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[210:211], v[66:81]
	ds_read_b64 v[214:215], v126
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[214:215], v[212:213], v[66:81]
	v_or_b32_e32 v214, s68, v142
	v_cmp_gt_i32_e64 s[54:55], s78, v214
	v_cndmask_b32_e64 v215, v161, v176, s[24:25]
	s_nop 7
	v_mul_f32_e32 v77, s79, v77
	v_mul_f32_e32 v228, 0x3fb8aa3b, v77
	v_mul_f32_e32 v77, s79, v78
	v_mul_f32_e32 v66, s79, v66
	v_mul_f32_e32 v229, 0x3fb8aa3b, v77
	v_mul_f32_e32 v77, s79, v79
	v_mul_f32_e32 v66, 0x3fb8aa3b, v66
	v_mul_f32_e32 v76, s79, v76
	v_mul_f32_e32 v230, 0x3fb8aa3b, v77
	v_mul_f32_e32 v77, s79, v80
	v_cndmask_b32_e64 v78, v161, v165, s[4:5]
	v_cndmask_b32_e64 v79, v161, v166, s[12:13]
	v_mul_f32_e32 v181, 0x3fb8aa3b, v76
	v_sub_u32_e32 v76, v214, v134
	v_mul_f32_e32 v231, 0x3fb8aa3b, v77
	v_mul_f32_e32 v77, s79, v81
	v_cndmask_b32_e64 v80, v161, v167, s[66:67]
	v_cndmask_b32_e64 v81, v161, v168, s[10:11]
	v_cndmask_b32_e64 v220, v161, v66, s[34:35]
	v_max_f32_e32 v66, v78, v79
	v_cmp_gt_i32_e64 s[56:57], 1, v76
	v_or_b32_e32 v76, s68, v143
	v_cndmask_b32_e32 v166, v161, v169, vcc
	v_cndmask_b32_e64 v167, v161, v170, s[8:9]
	v_max3_f32 v66, v66, v80, v81
	s_and_b64 s[54:55], s[54:55], s[56:57]
	v_cmp_gt_i32_e64 s[56:57], s78, v76
	v_sub_u32_e32 v76, v76, v134
	v_cndmask_b32_e64 v168, v161, v171, s[6:7]
	v_cndmask_b32_e64 v169, v161, v172, s[16:17]
	v_max3_f32 v66, v66, v166, v167
	v_cmp_gt_i32_e64 s[58:59], 1, v76
	v_or_b32_e32 v76, s68, v117
	v_cndmask_b32_e64 v170, v161, v173, s[14:15]
	v_cndmask_b32_e64 v171, v161, v174, s[20:21]
	v_max3_f32 v66, v66, v168, v169
	s_and_b64 s[56:57], s[56:57], s[58:59]
	v_cmp_gt_i32_e64 s[58:59], s78, v76
	v_sub_u32_e32 v76, v76, v134
	v_cndmask_b32_e64 v214, v161, v175, s[18:19]
	v_max3_f32 v66, v66, v170, v171
	v_mul_f32_e32 v67, s79, v67
	v_cmp_gt_i32_e64 s[60:61], 1, v76
	v_or_b32_e32 v76, s68, v144
	v_max3_f32 v66, v66, v214, v215
	v_mul_f32_e32 v67, 0x3fb8aa3b, v67
	v_mul_f32_e32 v68, s79, v68
	v_mul_f32_e32 v69, s79, v69
	s_and_b64 s[58:59], s[58:59], s[60:61]
	v_cmp_gt_i32_e64 s[60:61], s78, v76
	v_sub_u32_e32 v76, v76, v134
	v_max3_f32 v66, v66, v216, v217
	v_mul_f32_e32 v68, 0x3fb8aa3b, v68
	v_mul_f32_e32 v69, 0x3fb8aa3b, v69
	v_mul_f32_e32 v70, s79, v70
	v_mul_f32_e32 v71, s79, v71
	v_cmp_gt_i32_e64 s[62:63], 1, v76
	v_or_b32_e32 v76, s68, v145
	v_cndmask_b32_e64 v221, v161, v67, s[36:37]
	v_max3_f32 v66, v66, v218, v219
	v_mul_f32_e32 v70, 0x3fb8aa3b, v70
	v_mul_f32_e32 v71, 0x3fb8aa3b, v71
	v_mul_f32_e32 v72, s79, v72
	v_mul_f32_e32 v73, s79, v73
	s_and_b64 s[60:61], s[60:61], s[62:63]
	v_cmp_gt_i32_e64 s[62:63], s78, v76
	v_sub_u32_e32 v76, v76, v134
	v_cndmask_b32_e64 v222, v161, v68, s[38:39]
	v_cndmask_b32_e64 v223, v161, v69, s[40:41]
	v_max3_f32 v66, v66, v220, v221
	v_mul_f32_e32 v72, 0x3fb8aa3b, v72
	v_mul_f32_e32 v73, 0x3fb8aa3b, v73
	v_mul_f32_e32 v74, s79, v74
	v_mul_f32_e32 v75, s79, v75
	v_cmp_gt_i32_e64 s[64:65], 1, v76
	v_or_b32_e32 v76, s68, v146
	v_cndmask_b32_e64 v224, v161, v70, s[42:43]
	v_cndmask_b32_e64 v225, v161, v71, s[44:45]
	v_max3_f32 v66, v66, v222, v223
	v_mul_f32_e32 v74, 0x3fb8aa3b, v74
	v_mul_f32_e32 v75, 0x3fb8aa3b, v75
	s_and_b64 s[62:63], s[62:63], s[64:65]
	v_cmp_gt_i32_e64 s[64:65], s78, v76
	v_sub_u32_e32 v76, v76, v134
	v_cndmask_b32_e64 v226, v161, v72, s[46:47]
	v_cndmask_b32_e64 v227, v161, v73, s[48:49]
	v_max3_f32 v66, v66, v224, v225
	v_mul_f32_e32 v232, 0x3fb8aa3b, v77
	v_cmp_gt_i32_e64 s[68:69], 1, v76
	v_cndmask_b32_e64 v76, v161, v74, s[50:51]
	v_cndmask_b32_e64 v77, v161, v75, s[52:53]
	v_max3_f32 v66, v66, v226, v227
	v_cndmask_b32_e64 v74, v161, v181, s[54:55]
	v_cndmask_b32_e64 v75, v161, v228, s[56:57]
	v_max3_f32 v66, v66, v76, v77
	s_and_b64 s[64:65], s[64:65], s[68:69]
	v_cndmask_b32_e64 v72, v161, v229, s[58:59]
	v_cndmask_b32_e64 v73, v161, v230, s[60:61]
	v_max3_f32 v66, v66, v74, v75
	v_cndmask_b32_e64 v70, v161, v231, s[62:63]
	v_cndmask_b32_e64 v71, v161, v232, s[64:65]
	v_max3_f32 v66, v66, v72, v73
	v_max3_f32 v66, v66, v70, v71
	ds_bpermute_b32 v67, v160, v66
	s_add_u32 s74, s74, 1
	s_addc_u32 s75, s75, 0
	s_waitcnt lgkmcnt(0)
	v_max3_f32 v66, v82, v66, v67
	v_sub_f32_e32 v67, v82, v66
	v_cmp_gt_f32_e64 s[68:69], s73, v67
	s_nop 1
	v_cndmask_b32_e64 v68, 0, v162, s[68:69]
	v_add_f32_e32 v67, v67, v68
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v163, s[68:69]
	v_pk_add_f32 v[78:79], v[78:79], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_ldexp_f32 v68, v67, v68
	v_cmp_gt_f32_e64 s[68:69], s73, v78
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v162, s[68:69]
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v69, 0, v163, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e64 v69, 0, v162, s[68:69]
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v78, 0, v163, s[68:69]
	v_cndmask_b32_e64 v229, 0, v67, s[4:5]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[80:81], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v228, 0, v69, s[12:13]
	v_cmp_gt_f32_e64 s[4:5], s73, v78
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v162, s[4:5]
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v69, 0, v163, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e64 v69, 0, v162, s[4:5]
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v78, 0, v163, s[4:5]
	v_cndmask_b32_e64 v231, 0, v67, s[66:67]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[166:167], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v230, 0, v69, s[10:11]
	v_cmp_gt_f32_e64 s[4:5], s73, v78
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v162, s[4:5]
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v69, 0, v163, s[4:5]
	v_cmp_gt_f32_e64 s[4:5], s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e64 v69, 0, v162, s[4:5]
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v78, 0, v163, s[4:5]
	v_cndmask_b32_e32 v178, 0, v67, vcc
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[168:169], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v176, 0, v69, s[8:9]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cndmask_b32_e64 v179, 0, v67, s[6:7]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[170:171], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v177, 0, v69, s[16:17]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cndmask_b32_e64 v174, 0, v67, s[14:15]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[214:215], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v172, 0, v69, s[20:21]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cndmask_b32_e64 v175, 0, v67, s[18:19]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[216:217], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v173, 0, v69, s[24:25]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cndmask_b32_e64 v170, 0, v67, s[22:23]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[218:219], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v168, 0, v69, s[28:29]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cndmask_b32_e64 v171, 0, v67, s[26:27]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[220:221], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v169, 0, v69, s[30:31]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cndmask_b32_e64 v166, 0, v67, s[34:35]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[222:223], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v82, 0, v69, s[36:37]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v79, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cndmask_b32_e64 v167, 0, v67, s[38:39]
	v_ldexp_f32 v69, v69, v78
	v_pk_add_f32 v[78:79], v[224:225], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v165, 0, v69, s[40:41]
	v_cmp_gt_f32_e32 vcc, s73, v78
	s_nop 1
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v78, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v79
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_pk_add_f32 v[180:181], v[226:227], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_add_f32_e32 v69, v79, v69
	v_cndmask_b32_e32 v78, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v180
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v80, 0, v67, s[42:43]
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v180, v67
	v_exp_f32_e32 v67, v67
	v_ldexp_f32 v69, v69, v78
	v_cndmask_b32_e64 v78, 0, v69, s[44:45]
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v181
	v_ldexp_f32 v67, v67, v69
	v_pk_add_f32 v[76:77], v[76:77], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v181, v69
	v_cndmask_b32_e32 v79, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v76
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v81, 0, v67, s[46:47]
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v76, v67
	v_exp_f32_e32 v67, v67
	v_ldexp_f32 v69, v69, v79
	v_cndmask_b32_e64 v79, 0, v69, s[48:49]
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v77
	v_ldexp_f32 v67, v67, v69
	v_pk_add_f32 v[74:75], v[74:75], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v77, v69
	v_cndmask_b32_e32 v76, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v74
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v77, 0, v67, s[50:51]
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v74, v67
	v_exp_f32_e32 v67, v67
	v_ldexp_f32 v69, v69, v76
	v_cndmask_b32_e64 v76, 0, v69, s[52:53]
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v75
	v_ldexp_f32 v67, v67, v69
	v_pk_add_f32 v[72:73], v[72:73], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v75, v69
	v_cndmask_b32_e32 v74, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v72
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v75, 0, v67, s[54:55]
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v72, v67
	v_exp_f32_e32 v67, v67
	v_ldexp_f32 v69, v69, v74
	v_cndmask_b32_e64 v74, 0, v69, s[56:57]
	v_cndmask_b32_e32 v69, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v73
	v_ldexp_f32 v69, v67, v69
	v_or_b32_e32 v180, 0x400000, v231
	v_cndmask_b32_e32 v67, 0, v162, vcc
	v_add_f32_e32 v67, v73, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e32 v72, 0, v163, vcc
	v_or_b32_e32 v181, 0x400000, v230
	v_ldexp_f32 v67, v67, v72
	v_cndmask_b32_e64 v67, 0, v67, s[60:61]
	v_pk_add_f32 v[70:71], v[70:71], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v72, 0, v69, s[58:59]
	v_cmp_gt_f32_e32 vcc, s73, v70
	s_nop 1
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v70, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v70, 0, v163, vcc
	v_cmp_gt_f32_e32 vcc, s73, v71
	v_ldexp_f32 v70, v69, v70
	s_nop 0
	v_cndmask_b32_e32 v69, 0, v162, vcc
	v_add_f32_e32 v69, v71, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e32 v71, 0, v163, vcc
	v_cndmask_b32_e64 v70, 0, v70, s[62:63]
	v_cmp_u_f32_e32 vcc, v229, v229
	v_ldexp_f32 v69, v69, v71
	v_add_f32_e32 v71, v229, v228
	v_add_f32_e32 v71, v231, v71
	v_add_f32_e32 v71, v230, v71
	v_add_f32_e32 v71, v178, v71
	v_add_f32_e32 v71, v176, v71
	v_add_f32_e32 v71, v179, v71
	v_add_f32_e32 v71, v177, v71
	v_add_f32_e32 v71, v174, v71
	v_add_f32_e32 v71, v172, v71
	v_add_f32_e32 v71, v175, v71
	v_add_f32_e32 v71, v173, v71
	v_add_f32_e32 v71, v170, v71
	v_add_f32_e32 v71, v168, v71
	v_add_f32_e32 v71, v171, v71
	v_add_f32_e32 v71, v169, v71
	v_add_f32_e32 v71, v166, v71
	v_add_f32_e32 v71, v82, v71
	v_add_f32_e32 v71, v167, v71
	v_add_f32_e32 v71, v165, v71
	v_add_f32_e32 v71, v80, v71
	v_add_f32_e32 v71, v78, v71
	v_add_f32_e32 v71, v81, v71
	v_add_f32_e32 v71, v79, v71
	v_add_f32_e32 v71, v77, v71
	v_add_f32_e32 v71, v76, v71
	v_add_f32_e32 v71, v75, v71
	v_add_f32_e32 v71, v74, v71
	v_add_f32_e32 v71, v72, v71
	v_add_f32_e32 v71, v67, v71
	v_cndmask_b32_e64 v69, 0, v69, s[64:65]
	v_add_f32_e32 v71, v70, v71
	v_add_f32_e32 v71, v69, v71
	ds_bpermute_b32 v73, v160, v71
	v_pk_mul_f32 v[48:49], v[48:49], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[46:47], v[46:47], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[42:43], v[42:43], v[68:69] op_sel_hi:[1,0]
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v71, v71, v73
	v_mul_f32_e32 v73, v112, v68
	v_pk_mul_f32 v[40:41], v[40:41], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[38:39], v[38:39], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[36:37], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[64:65], v[64:65], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[62:63], v[62:63], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[60:61], v[60:61], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[58:59], v[58:59], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[56:57], v[56:57], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[54:55], v[54:55], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[52:53], v[52:53], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[50:51], v[50:51], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[30:31], v[30:31], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[26:27], v[26:27], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[22:23], v[22:23], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[18:19], v[18:19], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[10:11], v[10:11], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[6:7], v[6:7], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[2:3], v[2:3], v[68:69] op_sel_hi:[1,0]
	v_bfe_u32 v68, v229, 16, 1
	v_add_f32_e32 v112, v73, v71
	v_add3_u32 v68, v68, v229, s76
	v_or_b32_e32 v71, 0x400000, v229
	v_cndmask_b32_e32 v68, v68, v71, vcc
	v_bfe_u32 v71, v228, 16, 1
	v_add3_u32 v71, v71, v228, s76
	v_or_b32_e32 v73, 0x400000, v228
	v_cmp_u_f32_e32 vcc, v228, v228
	s_nop 1
	v_cndmask_b32_e32 v71, v71, v73, vcc
	v_bfe_u32 v73, v231, 16, 1
	v_add3_u32 v73, v73, v231, s76
	v_cmp_u_f32_e32 vcc, v231, v231
	s_nop 1
	v_cndmask_b32_e32 v73, v73, v180, vcc
	v_bfe_u32 v180, v230, 16, 1
	v_add3_u32 v180, v180, v230, s76
	v_cmp_u_f32_e32 vcc, v230, v230
	s_nop 1
	v_cndmask_b32_e32 v180, v180, v181, vcc
	ds_read_u16 v181, v125
	ds_read_u16 v214, v125 offset:256
	ds_read_u16 v215, v125 offset:512
	ds_read_u16 v216, v125 offset:768
	v_cmp_u_f32_e32 vcc, v178, v178
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v214, v214, v181, s88
	v_perm_b32 v181, v180, v73, s89
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v215, v216, v215, s88
	v_perm_b32 v180, v71, v68, s89
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[214:215], v[180:181], v[34:49]
	ds_read_u16 v68, v125 offset:64
	ds_read_u16 v71, v125 offset:320
	ds_read_u16 v73, v125 offset:576
	ds_read_u16 v214, v125 offset:832
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v215, v214, v73, s88
	v_perm_b32 v214, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[214:215], v[180:181], v[50:65]
	ds_read_u16 v68, v125 offset:128
	ds_read_u16 v71, v125 offset:384
	ds_read_u16 v73, v125 offset:640
	ds_read_u16 v214, v125 offset:896
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v215, v214, v73, s88
	v_perm_b32 v214, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[214:215], v[180:181], v[18:33]
	ds_read_u16 v68, v125 offset:192
	ds_read_u16 v71, v125 offset:448
	ds_read_u16 v73, v125 offset:704
	ds_read_u16 v214, v125 offset:960
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v215, v214, v73, s88
	v_perm_b32 v214, v71, v68, s88
	v_bfe_u32 v68, v178, 16, 1
	v_add3_u32 v68, v68, v178, s76
	v_or_b32_e32 v71, 0x400000, v178
	v_cndmask_b32_e32 v68, v68, v71, vcc
	v_bfe_u32 v71, v176, 16, 1
	v_add3_u32 v71, v71, v176, s76
	v_or_b32_e32 v73, 0x400000, v176
	v_cmp_u_f32_e32 vcc, v176, v176
	v_or_b32_e32 v176, 0x400000, v179
	v_or_b32_e32 v178, 0x400000, v177
	v_cndmask_b32_e32 v71, v71, v73, vcc
	v_bfe_u32 v73, v179, 16, 1
	v_add3_u32 v73, v73, v179, s76
	v_cmp_u_f32_e32 vcc, v179, v179
	v_mfma_f32_32x32x8_bf16 v[2:17], v[214:215], v[180:181], v[2:17]
	s_nop 0
	v_cndmask_b32_e32 v73, v73, v176, vcc
	v_bfe_u32 v176, v177, 16, 1
	v_add3_u32 v176, v176, v177, s76
	v_cmp_u_f32_e32 vcc, v177, v177
	s_nop 1
	v_cndmask_b32_e32 v178, v176, v178, vcc
	ds_read_u16 v176, v125 offset:2048
	ds_read_u16 v179, v125 offset:2304
	ds_read_u16 v177, v125 offset:2560
	ds_read_u16 v180, v125 offset:2816
	v_cmp_u_f32_e32 vcc, v174, v174
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v176, v179, v176, s88
	v_perm_b32 v179, v178, v73, s89
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v177, v180, v177, s88
	v_perm_b32 v178, v71, v68, s89
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[176:177], v[178:179], v[34:49]
	ds_read_u16 v68, v125 offset:2112
	ds_read_u16 v71, v125 offset:2368
	ds_read_u16 v73, v125 offset:2624
	ds_read_u16 v176, v125 offset:2880
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v177, v176, v73, s88
	v_perm_b32 v176, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[176:177], v[178:179], v[50:65]
	ds_read_u16 v68, v125 offset:2176
	ds_read_u16 v71, v125 offset:2432
	ds_read_u16 v73, v125 offset:2688
	ds_read_u16 v176, v125 offset:2944
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v177, v176, v73, s88
	v_perm_b32 v176, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[176:177], v[178:179], v[18:33]
	ds_read_u16 v68, v125 offset:2240
	ds_read_u16 v71, v125 offset:2496
	ds_read_u16 v73, v125 offset:2752
	ds_read_u16 v176, v125 offset:3008
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v177, v176, v73, s88
	v_perm_b32 v176, v71, v68, s88
	v_bfe_u32 v68, v174, 16, 1
	v_add3_u32 v68, v68, v174, s76
	v_or_b32_e32 v71, 0x400000, v174
	v_cndmask_b32_e32 v68, v68, v71, vcc
	v_bfe_u32 v71, v172, 16, 1
	v_add3_u32 v71, v71, v172, s76
	v_or_b32_e32 v73, 0x400000, v172
	v_cmp_u_f32_e32 vcc, v172, v172
	v_or_b32_e32 v172, 0x400000, v175
	v_or_b32_e32 v174, 0x400000, v173
	v_cndmask_b32_e32 v71, v71, v73, vcc
	v_bfe_u32 v73, v175, 16, 1
	v_add3_u32 v73, v73, v175, s76
	v_cmp_u_f32_e32 vcc, v175, v175
	v_mfma_f32_32x32x8_bf16 v[2:17], v[176:177], v[178:179], v[2:17]
	s_nop 0
	v_cndmask_b32_e32 v73, v73, v172, vcc
	v_bfe_u32 v172, v173, 16, 1
	v_add3_u32 v172, v172, v173, s76
	v_cmp_u_f32_e32 vcc, v173, v173
	s_nop 1
	v_cndmask_b32_e32 v174, v172, v174, vcc
	ds_read_u16 v172, v125 offset:4096
	ds_read_u16 v175, v125 offset:4352
	ds_read_u16 v173, v125 offset:4608
	ds_read_u16 v176, v125 offset:4864
	v_cmp_u_f32_e32 vcc, v170, v170
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v172, v175, v172, s88
	v_perm_b32 v175, v174, v73, s89
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v173, v176, v173, s88
	v_perm_b32 v174, v71, v68, s89
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[172:173], v[174:175], v[34:49]
	ds_read_u16 v68, v125 offset:4160
	ds_read_u16 v71, v125 offset:4416
	ds_read_u16 v73, v125 offset:4672
	ds_read_u16 v172, v125 offset:4928
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v173, v172, v73, s88
	v_perm_b32 v172, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[172:173], v[174:175], v[50:65]
	ds_read_u16 v68, v125 offset:4224
	ds_read_u16 v71, v125 offset:4480
	ds_read_u16 v73, v125 offset:4736
	ds_read_u16 v172, v125 offset:4992
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v173, v172, v73, s88
	v_perm_b32 v172, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[172:173], v[174:175], v[18:33]
	ds_read_u16 v68, v125 offset:4288
	ds_read_u16 v71, v125 offset:4544
	ds_read_u16 v73, v125 offset:4800
	ds_read_u16 v172, v125 offset:5056
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v173, v172, v73, s88
	v_perm_b32 v172, v71, v68, s88
	v_bfe_u32 v68, v170, 16, 1
	v_add3_u32 v68, v68, v170, s76
	v_or_b32_e32 v71, 0x400000, v170
	v_cndmask_b32_e32 v68, v68, v71, vcc
	v_bfe_u32 v71, v168, 16, 1
	v_add3_u32 v71, v71, v168, s76
	v_or_b32_e32 v73, 0x400000, v168
	v_cmp_u_f32_e32 vcc, v168, v168
	v_or_b32_e32 v168, 0x400000, v171
	v_or_b32_e32 v170, 0x400000, v169
	v_cndmask_b32_e32 v71, v71, v73, vcc
	v_bfe_u32 v73, v171, 16, 1
	v_add3_u32 v73, v73, v171, s76
	v_cmp_u_f32_e32 vcc, v171, v171
	v_mfma_f32_32x32x8_bf16 v[2:17], v[172:173], v[174:175], v[2:17]
	s_nop 0
	v_cndmask_b32_e32 v73, v73, v168, vcc
	v_bfe_u32 v168, v169, 16, 1
	v_add3_u32 v168, v168, v169, s76
	v_cmp_u_f32_e32 vcc, v169, v169
	s_nop 1
	v_cndmask_b32_e32 v170, v168, v170, vcc
	ds_read_u16 v168, v125 offset:6144
	ds_read_u16 v171, v125 offset:6400
	ds_read_u16 v169, v125 offset:6656
	ds_read_u16 v172, v125 offset:6912
	v_cmp_u_f32_e32 vcc, v166, v166
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v168, v171, v168, s88
	v_perm_b32 v171, v170, v73, s89
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v169, v172, v169, s88
	v_perm_b32 v170, v71, v68, s89
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[168:169], v[170:171], v[34:49]
	ds_read_u16 v68, v125 offset:6208
	ds_read_u16 v71, v125 offset:6464
	ds_read_u16 v73, v125 offset:6720
	ds_read_u16 v168, v125 offset:6976
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v169, v168, v73, s88
	v_perm_b32 v168, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[168:169], v[170:171], v[50:65]
	ds_read_u16 v68, v125 offset:6272
	ds_read_u16 v71, v125 offset:6528
	ds_read_u16 v73, v125 offset:6784
	ds_read_u16 v168, v125 offset:7040
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v169, v168, v73, s88
	v_perm_b32 v168, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[168:169], v[170:171], v[18:33]
	ds_read_u16 v68, v125 offset:6336
	ds_read_u16 v71, v125 offset:6592
	ds_read_u16 v73, v125 offset:6848
	ds_read_u16 v168, v125 offset:7104
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v169, v168, v73, s88
	v_perm_b32 v168, v71, v68, s88
	v_bfe_u32 v68, v166, 16, 1
	v_add3_u32 v68, v68, v166, s76
	v_or_b32_e32 v71, 0x400000, v166
	v_cndmask_b32_e32 v68, v68, v71, vcc
	v_bfe_u32 v71, v82, 16, 1
	v_add3_u32 v71, v71, v82, s76
	v_or_b32_e32 v73, 0x400000, v82
	v_cmp_u_f32_e32 vcc, v82, v82
	v_or_b32_e32 v82, 0x400000, v167
	v_or_b32_e32 v166, 0x400000, v165
	v_cndmask_b32_e32 v71, v71, v73, vcc
	v_bfe_u32 v73, v167, 16, 1
	v_add3_u32 v73, v73, v167, s76
	v_cmp_u_f32_e32 vcc, v167, v167
	v_mfma_f32_32x32x8_bf16 v[2:17], v[168:169], v[170:171], v[2:17]
	s_nop 0
	v_cndmask_b32_e32 v73, v73, v82, vcc
	v_bfe_u32 v82, v165, 16, 1
	v_add3_u32 v82, v82, v165, s76
	v_cmp_u_f32_e32 vcc, v165, v165
	s_nop 1
	v_cndmask_b32_e32 v82, v82, v166, vcc
	ds_read_u16 v165, v125 offset:8192
	ds_read_u16 v166, v125 offset:8448
	ds_read_u16 v167, v125 offset:8704
	ds_read_u16 v168, v125 offset:8960
	v_perm_b32 v169, v82, v73, s89
	v_cmp_u_f32_e32 vcc, v80, v80
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v166, v166, v165, s88
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v167, v168, v167, s88
	v_perm_b32 v168, v71, v68, s89
	ds_read_u16 v68, v125 offset:8256
	ds_read_u16 v71, v125 offset:8512
	ds_read_u16 v73, v125 offset:8768
	ds_read_u16 v82, v125 offset:9024
	v_mfma_f32_32x32x8_bf16 v[34:49], v[166:167], v[168:169], v[34:49]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v166, v71, v68, s88
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v167, v82, v73, s88
	ds_read_u16 v68, v125 offset:8320
	ds_read_u16 v71, v125 offset:8576
	ds_read_u16 v73, v125 offset:8832
	ds_read_u16 v82, v125 offset:9088
	v_mfma_f32_32x32x8_bf16 v[50:65], v[166:167], v[168:169], v[50:65]
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v167, v82, v73, s88
	v_perm_b32 v166, v71, v68, s88
	ds_read_u16 v68, v125 offset:8384
	ds_read_u16 v71, v125 offset:8640
	ds_read_u16 v73, v125 offset:8896
	ds_read_u16 v82, v125 offset:9152
	v_mfma_f32_32x32x8_bf16 v[18:33], v[166:167], v[168:169], v[18:33]
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v166, v71, v68, s88
	v_bfe_u32 v68, v80, 16, 1
	v_add3_u32 v68, v68, v80, s76
	v_or_b32_e32 v71, 0x400000, v80
	v_cndmask_b32_e32 v68, v68, v71, vcc
	v_bfe_u32 v71, v78, 16, 1
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v167, v82, v73, s88
	v_add3_u32 v71, v71, v78, s76
	v_or_b32_e32 v73, 0x400000, v78
	v_cmp_u_f32_e32 vcc, v78, v78
	v_or_b32_e32 v78, 0x400000, v81
	v_or_b32_e32 v80, 0x400000, v79
	v_cndmask_b32_e32 v71, v71, v73, vcc
	v_bfe_u32 v73, v81, 16, 1
	v_add3_u32 v73, v73, v81, s76
	v_cmp_u_f32_e32 vcc, v81, v81
	v_mfma_f32_32x32x8_bf16 v[2:17], v[166:167], v[168:169], v[2:17]
	s_nop 0
	v_cndmask_b32_e32 v73, v73, v78, vcc
	v_bfe_u32 v78, v79, 16, 1
	v_add3_u32 v78, v78, v79, s76
	v_cmp_u_f32_e32 vcc, v79, v79
	s_nop 1
	v_cndmask_b32_e32 v80, v78, v80, vcc
	ds_read_u16 v78, v125 offset:10240
	ds_read_u16 v81, v125 offset:10496
	ds_read_u16 v79, v125 offset:10752
	ds_read_u16 v82, v125 offset:11008
	v_cmp_u_f32_e32 vcc, v77, v77
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v78, v81, v78, s88
	v_perm_b32 v81, v80, v73, s89
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v79, v82, v79, s88
	v_perm_b32 v80, v71, v68, s89
	v_mov_b32_e32 v82, v66
	s_nop 0
	v_mfma_f32_32x32x8_bf16 v[34:49], v[78:79], v[80:81], v[34:49]
	ds_read_u16 v68, v125 offset:10304
	ds_read_u16 v71, v125 offset:10560
	ds_read_u16 v73, v125 offset:10816
	ds_read_u16 v78, v125 offset:11072
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v79, v78, v73, s88
	v_perm_b32 v78, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[78:79], v[80:81], v[50:65]
	ds_read_u16 v68, v125 offset:10368
	ds_read_u16 v71, v125 offset:10624
	ds_read_u16 v73, v125 offset:10880
	ds_read_u16 v78, v125 offset:11136
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v79, v78, v73, s88
	v_perm_b32 v78, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[78:79], v[80:81], v[18:33]
	ds_read_u16 v68, v125 offset:10432
	ds_read_u16 v71, v125 offset:10688
	ds_read_u16 v73, v125 offset:10944
	ds_read_u16 v78, v125 offset:11200
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v79, v78, v73, s88
	v_perm_b32 v78, v71, v68, s88
	v_bfe_u32 v68, v77, 16, 1
	v_add3_u32 v68, v68, v77, s76
	v_or_b32_e32 v71, 0x400000, v77
	v_cndmask_b32_e32 v68, v68, v71, vcc
	v_bfe_u32 v71, v76, 16, 1
	v_add3_u32 v71, v71, v76, s76
	v_or_b32_e32 v73, 0x400000, v76
	v_cmp_u_f32_e32 vcc, v76, v76
	v_or_b32_e32 v76, 0x400000, v75
	v_mfma_f32_32x32x8_bf16 v[2:17], v[78:79], v[80:81], v[2:17]
	v_cndmask_b32_e32 v71, v71, v73, vcc
	v_bfe_u32 v73, v75, 16, 1
	v_add3_u32 v73, v73, v75, s76
	v_cmp_u_f32_e32 vcc, v75, v75
	v_bfe_u32 v75, v74, 16, 1
	v_add3_u32 v75, v75, v74, s76
	v_cndmask_b32_e32 v73, v73, v76, vcc
	v_or_b32_e32 v76, 0x400000, v74
	v_cmp_u_f32_e32 vcc, v74, v74
	s_nop 1
	v_cndmask_b32_e32 v76, v75, v76, vcc
	ds_read_u16 v74, v125 offset:12288
	ds_read_u16 v77, v125 offset:12544
	ds_read_u16 v75, v125 offset:12800
	ds_read_u16 v78, v125 offset:13056
	v_cmp_u_f32_e32 vcc, v72, v72
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v74, v77, v74, s88
	v_perm_b32 v77, v76, v73, s89
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v78, v75, s88
	v_perm_b32 v76, v71, v68, s89
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[74:75], v[76:77], v[34:49]
	ds_read_u16 v68, v125 offset:12352
	ds_read_u16 v71, v125 offset:12608
	ds_read_u16 v73, v125 offset:12864
	ds_read_u16 v74, v125 offset:13120
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v74, v73, s88
	v_perm_b32 v74, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[74:75], v[76:77], v[50:65]
	ds_read_u16 v68, v125 offset:12416
	ds_read_u16 v71, v125 offset:12672
	ds_read_u16 v73, v125 offset:12928
	ds_read_u16 v74, v125 offset:13184
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v74, v73, s88
	v_perm_b32 v74, v71, v68, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[74:75], v[76:77], v[18:33]
	ds_read_u16 v68, v125 offset:12480
	ds_read_u16 v71, v125 offset:12736
	ds_read_u16 v73, v125 offset:12992
	ds_read_u16 v74, v125 offset:13248
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v75, v74, v73, s88
	v_perm_b32 v74, v71, v68, s88
	v_bfe_u32 v68, v72, 16, 1
	v_add3_u32 v68, v68, v72, s76
	v_or_b32_e32 v71, 0x400000, v72
	v_cndmask_b32_e32 v72, v68, v71, vcc
	v_bfe_u32 v68, v67, 16, 1
	v_add3_u32 v68, v68, v67, s76
	v_or_b32_e32 v71, 0x400000, v67
	v_cmp_u_f32_e32 vcc, v67, v67
	v_mfma_f32_32x32x8_bf16 v[2:17], v[74:75], v[76:77], v[2:17]
	s_nop 0
	v_cndmask_b32_e32 v67, v68, v71, vcc
	v_bfe_u32 v68, v70, 16, 1
	v_add3_u32 v68, v68, v70, s76
	v_or_b32_e32 v71, 0x400000, v70
	v_cmp_u_f32_e32 vcc, v70, v70
	s_nop 1
	v_cndmask_b32_e32 v70, v68, v71, vcc
	v_bfe_u32 v68, v69, 16, 1
	v_add3_u32 v68, v68, v69, s76
	v_or_b32_e32 v71, 0x400000, v69
	v_cmp_u_f32_e32 vcc, v69, v69
	s_nop 1
	v_cndmask_b32_e32 v71, v68, v71, vcc
	ds_read_u16 v68, v125 offset:14336
	ds_read_u16 v73, v125 offset:14592
	ds_read_u16 v69, v125 offset:14848
	ds_read_u16 v74, v125 offset:15104
	v_perm_b32 v71, v71, v70, s89
	v_perm_b32 v70, v67, v72, s89
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v73, v68, s88
	v_cmp_lt_i64_e32 vcc, s[74:75], v[0:1]
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v74, v69, s88
	s_and_b64 vcc, exec, vcc
	s_nop 0
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[70:71], v[34:49]
	ds_read_u16 v67, v125 offset:14400
	ds_read_u16 v68, v125 offset:14656
	ds_read_u16 v69, v125 offset:14912
	ds_read_u16 v72, v125 offset:15168
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v68, v67, s88
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v72, v69, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[70:71], v[50:65]
	ds_read_u16 v67, v125 offset:14464
	ds_read_u16 v68, v125 offset:14720
	ds_read_u16 v69, v125 offset:14976
	ds_read_u16 v72, v125 offset:15232
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v68, v67, s88
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v72, v69, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[70:71], v[18:33]
	ds_read_u16 v67, v125 offset:14528
	ds_read_u16 v68, v125 offset:14784
	ds_read_u16 v69, v125 offset:15040
	ds_read_u16 v72, v125 offset:15296
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v68, v67, s88
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v72, v69, s88
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[70:71], v[2:17]
	s_cbranch_vccnz .LBB0_7
	v_mov_b32_e32 v82, v66
.LBB0_9:
	v_cmp_gt_i32_e32 vcc, s77, v122
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_12
	v_div_scale_f32 v0, s[4:5], v112, v112, 1.0
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
	v_div_scale_f32 v66, vcc, 1.0, v112, 1.0
	v_mul_f32_e32 v67, v66, v1
	v_fma_f32 v68, -v0, v67, v66
	v_fmac_f32_e32 v67, v68, v1
	v_fma_f32 v0, -v0, v67, v66
	v_div_fmas_f32 v0, v0, v1, v67
	v_div_fixup_f32 v0, v0, v112, 1.0
	v_cmp_lt_f32_e32 vcc, 0, v112
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
	v_lshl_add_u32 v1, v66, 1, v120
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
	v_add_lshl_u32 v1, v119, v66, 1
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
	v_add_lshl_u32 v1, v118, v66, 1
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
	v_add_lshl_u32 v1, v117, v66, 1
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
	v_add_lshl_u32 v1, v116, v66, 1
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
	v_add_lshl_u32 v1, v115, v66, 1
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
	v_add_lshl_u32 v1, v114, v66, 1
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
	v_add_lshl_u32 v1, v113, v66, 1
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
	v_add_lshl_u32 v1, v111, v66, 1
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
	v_add_lshl_u32 v1, v110, v66, 1
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
	v_add_lshl_u32 v1, v109, v66, 1
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
	v_add_lshl_u32 v1, v108, v66, 1
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
	v_add_lshl_u32 v2, v107, v66, 1
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
	v_add_lshl_u32 v2, v106, v66, 1
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
	v_add_lshl_u32 v2, v105, v66, 1
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
	v_add_lshl_u32 v2, v99, v66, 1
	v_cmp_gt_u32_e64 s[4:5], 32, v104
	buffer_store_dwordx2 v[0:1], v2, s[8:11], 0 offen
	s_and_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_12
	s_mov_b32 s2, 0x800000
	v_cmp_gt_f32_e64 s[4:5], s2, v112
	v_mov_b32_e32 v0, 0x42000000
	s_nop 0
	v_cndmask_b32_e64 v1, 0, 32, s[4:5]
	v_ldexp_f32 v1, v112, v1
	v_cndmask_b32_e64 v0, 0, v0, s[4:5]
	v_log_f32_e32 v1, v1
	s_load_dwordx2 s[8:9], s[0:1], 0xc0
	s_load_dword s2, s[0:1], 0xd4
	s_load_dword s4, s[0:1], 0xdc
	v_sub_f32_e32 v0, v1, v0
	v_add_f32_e32 v0, v82, v0
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
		.amdhsa_next_free_vgpr 233
		.amdhsa_next_free_sgpr 96
		.amdhsa_accum_offset 236
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

	.set .Lkernel_0.num_vgpr, 233
	.set .Lkernel_0.num_agpr, 0
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
    .sgpr_count:     98
    .sgpr_spill_count: 0
    .symbol:         kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     233
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx942
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata

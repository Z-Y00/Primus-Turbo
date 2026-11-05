	.amdgcn_target "amdgcn-amd-amdhsa-unknown-gfx942"
	.amdhsa_code_object_version 6
	.text
	.globl	kernel_0
	.p2align	8
	.type	kernel_0,@function
kernel_0:
	s_load_dwordx4 s[80:83], s[0:1], 0x390
	s_lshl_b32 s5, s2, 7
	s_waitcnt lgkmcnt(0)
	s_cmp_ge_i32 s5, s81
	s_cbranch_scc1 .LBB0_7
	s_abs_i32 s2, s80
	v_cvt_f32_u32_e32 v1, s2
	s_sub_i32 s7, 0, s2
	s_abs_i32 s6, s4
	s_xor_b32 s8, s80, s4
	v_rcp_f32_e32 v1, v1
	s_ashr_i32 s10, s8, 31
	v_and_b32_e32 v67, 31, v0
	v_bfe_u32 v68, v0, 5, 1
	v_mul_f32_e32 v1, 0x4f7ffffe, v1
	v_cvt_u32_f32_e32 v1, v1
	v_lshlrev_b32_e32 v106, 2, v68
	v_mov_b32_e32 v65, 0
	v_and_b32_e32 v113, 63, v0
	v_readfirstlane_b32 s9, v1
	s_mul_i32 s7, s7, s9
	s_mul_hi_u32 s7, s9, s7
	s_add_i32 s9, s9, s7
	s_mul_hi_u32 s7, s6, s9
	s_mul_i32 s9, s7, s2
	s_sub_i32 s6, s6, s9
	s_add_i32 s9, s7, 1
	s_sub_i32 s11, s6, s2
	s_cmp_ge_u32 s6, s2
	s_cselect_b32 s7, s9, s7
	s_cselect_b32 s6, s11, s6
	s_add_i32 s9, s7, 1
	s_cmp_ge_u32 s6, s2
	s_cselect_b32 s2, s9, s7
	s_xor_b32 s2, s2, s10
	s_sub_i32 s6, s2, s10
	s_mul_i32 s6, s6, s80
	s_cmp_lg_u32 s4, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s8, 0
	s_cselect_b64 s[8:9], -1, 0
	s_and_b64 s[6:7], s[8:9], s[6:7]
	s_subb_u32 s33, s2, s10
	s_add_i32 s2, s82, 63
	s_ashr_i32 s4, s2, 31
	s_lshr_b32 s4, s4, 26
	s_add_i32 s4, s2, s4
	s_ashr_i32 s10, s4, 6
	s_andn2_b32 s4, s4, 63
	s_cmp_lg_u32 s2, s4
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s2, 0
	s_cselect_b64 s[8:9], -1, 0
	s_and_b64 s[6:7], s[8:9], s[6:7]
	s_subb_u32 s4, s10, 0
	s_add_i32 s2, s5, 0x80
	s_min_i32 s6, s2, s81
	s_sub_i32 s2, s82, s81
	s_add_i32 s6, s2, s6
	s_max_i32 s6, s6, 0
	s_add_i32 s8, s6, 63
	s_ashr_i32 s6, s8, 31
	s_lshr_b32 s6, s6, 26
	s_add_i32 s6, s8, s6
	s_ashr_i32 s10, s6, 6
	s_andn2_b32 s6, s6, 63
	s_cmp_lg_u32 s8, s6
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s8, 0
	s_cselect_b64 s[8:9], -1, 0
	s_and_b64 s[6:7], s[8:9], s[6:7]
	v_lshrrev_b32_e32 v1, 1, v0
	s_subb_u32 s6, s10, 0
	v_and_b32_e32 v1, 0x60, v1
	s_min_i32 s96, s4, s6
	v_or3_b32 v131, s5, v1, v67
	s_add_i32 s4, s81, -1
	s_mov_b32 s98, 0
	s_mov_b32 s86, -1
	v_min_i32_e32 v98, s4, v131
	v_lshlrev_b32_e32 v130, 3, v68
	v_or_b32_e32 v104, 8, v106
	v_or_b32_e32 v102, 16, v106
	v_or_b32_e32 v100, 24, v106
	v_or_b32_e32 v129, 32, v106
	v_or_b32_e32 v128, 40, v106
	v_or_b32_e32 v127, 48, v106
	v_or_b32_e32 v125, 56, v106
	v_or_b32_e32 v124, 64, v106
	v_or_b32_e32 v123, 0x48, v106
	v_or_b32_e32 v122, 0x50, v106
	v_or_b32_e32 v121, 0x58, v106
	v_or_b32_e32 v120, 0x60, v106
	v_or_b32_e32 v119, 0x68, v106
	v_or_b32_e32 v118, 0x70, v106
	v_or_b32_e32 v115, 0x78, v106
	s_cmp_lt_i32 s96, 1
	v_mov_b32_e32 v126, 0
	v_mov_b32_e32 v66, 0xf149f2ca
	v_mov_b32_e32 v64, v65
	v_mov_b32_e32 v63, v65
	v_mov_b32_e32 v62, v65
	v_mov_b32_e32 v61, v65
	v_mov_b32_e32 v60, v65
	v_mov_b32_e32 v59, v65
	v_mov_b32_e32 v58, v65
	v_mov_b32_e32 v57, v65
	v_mov_b32_e32 v56, v65
	v_mov_b32_e32 v55, v65
	v_mov_b32_e32 v54, v65
	v_mov_b32_e32 v53, v65
	v_mov_b32_e32 v52, v65
	v_mov_b32_e32 v51, v65
	v_mov_b32_e32 v50, v65
	v_mov_b32_e32 v49, v65
	v_mov_b32_e32 v48, v65
	v_mov_b32_e32 v47, v65
	v_mov_b32_e32 v46, v65
	v_mov_b32_e32 v45, v65
	v_mov_b32_e32 v44, v65
	v_mov_b32_e32 v43, v65
	v_mov_b32_e32 v42, v65
	v_mov_b32_e32 v41, v65
	v_mov_b32_e32 v40, v65
	v_mov_b32_e32 v39, v65
	v_mov_b32_e32 v38, v65
	v_mov_b32_e32 v37, v65
	v_mov_b32_e32 v36, v65
	v_mov_b32_e32 v35, v65
	v_mov_b32_e32 v34, v65
	v_mov_b32_e32 v33, v65
	v_mov_b32_e32 v32, v65
	v_mov_b32_e32 v31, v65
	v_mov_b32_e32 v30, v65
	v_mov_b32_e32 v29, v65
	v_mov_b32_e32 v28, v65
	v_mov_b32_e32 v27, v65
	v_mov_b32_e32 v26, v65
	v_mov_b32_e32 v25, v65
	v_mov_b32_e32 v24, v65
	v_mov_b32_e32 v23, v65
	v_mov_b32_e32 v22, v65
	v_mov_b32_e32 v21, v65
	v_mov_b32_e32 v20, v65
	v_mov_b32_e32 v19, v65
	v_mov_b32_e32 v18, v65
	v_mov_b32_e32 v17, v65
	v_mov_b32_e32 v16, v65
	v_mov_b32_e32 v15, v65
	v_mov_b32_e32 v14, v65
	v_mov_b32_e32 v13, v65
	v_mov_b32_e32 v12, v65
	v_mov_b32_e32 v11, v65
	v_mov_b32_e32 v10, v65
	v_mov_b32_e32 v9, v65
	v_mov_b32_e32 v8, v65
	v_mov_b32_e32 v7, v65
	v_mov_b32_e32 v6, v65
	v_mov_b32_e32 v5, v65
	v_mov_b32_e32 v4, v65
	v_mov_b32_e32 v3, v65
	v_mov_b32_e32 v2, v65
	s_cbranch_scc1 .LBB0_4
	s_load_dwordx2 s[84:85], s[0:1], 0x0
	s_load_dword s10, s[0:1], 0x18
	s_load_dword s11, s[0:1], 0x20
	s_load_dword s12, s[0:1], 0x28
	s_load_dwordx2 s[88:89], s[0:1], 0x30
	s_load_dwordx8 s[72:79], s[0:1], 0x48
	s_load_dwordx4 s[92:95], s[0:1], 0x78
	s_load_dwordx2 s[4:5], s[0:1], 0x88
	s_waitcnt lgkmcnt(0)
	s_ashr_i32 s5, s3, 31
	s_lshr_b32 s5, s5, 29
	s_add_i32 s5, s3, s5
	s_ashr_i32 s97, s96, 31
	s_ashr_i32 s13, s5, 3
	s_and_b32 s5, s5, -8
	s_cmp_lg_u32 s3, s5
	s_cselect_b64 s[6:7], -1, 0
	s_cmp_lt_i32 s3, 0
	s_cselect_b64 s[8:9], -1, 0
	s_and_b64 s[6:7], s[8:9], s[6:7]
	s_mul_i32 s6, s10, s33
	s_mul_i32 s12, s12, s3
	s_subb_u32 s5, s13, 0
	s_add_i32 s6, s6, s12
	v_mul_lo_u32 v1, s11, v98
	v_add_u32_e32 v1, s6, v1
	s_mov_b32 s87, 0x27000
	s_and_b32 s85, s85, 0xffff
	v_add_lshl_u32 v2, v115, v1, 1
	v_add_lshl_u32 v3, v118, v1, 1
	v_add_lshl_u32 v4, v119, v1, 1
	v_add_lshl_u32 v5, v120, v1, 1
	buffer_load_dwordx2 v[182:183], v2, s[84:87], 0 offen
	buffer_load_dwordx2 v[184:185], v3, s[84:87], 0 offen
	buffer_load_dwordx2 v[186:187], v4, s[84:87], 0 offen
	buffer_load_dwordx2 v[188:189], v5, s[84:87], 0 offen
	v_add_lshl_u32 v2, v121, v1, 1
	v_add_lshl_u32 v3, v122, v1, 1
	v_add_lshl_u32 v4, v123, v1, 1
	v_add_lshl_u32 v5, v124, v1, 1
	buffer_load_dwordx2 v[190:191], v2, s[84:87], 0 offen
	buffer_load_dwordx2 v[192:193], v3, s[84:87], 0 offen
	buffer_load_dwordx2 v[194:195], v4, s[84:87], 0 offen
	buffer_load_dwordx2 v[196:197], v5, s[84:87], 0 offen
	v_add_lshl_u32 v2, v125, v1, 1
	v_add_lshl_u32 v3, v127, v1, 1
	v_add_lshl_u32 v4, v128, v1, 1
	v_add_lshl_u32 v5, v129, v1, 1
	buffer_load_dwordx2 v[198:199], v2, s[84:87], 0 offen
	buffer_load_dwordx2 v[200:201], v3, s[84:87], 0 offen
	buffer_load_dwordx2 v[202:203], v4, s[84:87], 0 offen
	buffer_load_dwordx2 v[204:205], v5, s[84:87], 0 offen
	v_add_lshl_u32 v2, v100, v1, 1
	v_add_lshl_u32 v3, v102, v1, 1
	v_add_lshl_u32 v4, v104, v1, 1
	v_lshl_add_u32 v1, v1, 1, v130
	buffer_load_dwordx2 v[206:207], v2, s[84:87], 0 offen
	buffer_load_dwordx2 v[208:209], v3, s[84:87], 0 offen
	buffer_load_dwordx2 v[210:211], v4, s[84:87], 0 offen
	buffer_load_dwordx2 v[212:213], v1, s[84:87], 0 offen
	s_mul_i32 s6, s72, s33
	s_mul_i32 s7, s76, s5
	v_and_b32_e32 v1, 15, v0
	v_bfe_u32 v2, v0, 4, 3
	s_add_u32 s72, s6, s7
	v_lshlrev_b32_e32 v133, 3, v1
	v_xor_b32_e32 v1, v2, v1
	s_movk_i32 s6, 0xf0
	v_and_or_b32 v2, v0, s6, v1
	v_lshlrev_b32_e32 v134, 4, v2
	v_or_b32_e32 v2, 0x100, v0
	s_movk_i32 s6, 0x1f0
	v_and_or_b32 v3, v2, s6, v1
	v_lshlrev_b32_e32 v135, 4, v3
	v_or_b32_e32 v3, 0x200, v0
	s_movk_i32 s6, 0x2f0
	v_and_or_b32 v4, v3, s6, v1
	v_lshrrev_b32_e32 v132, 4, v0
	v_lshlrev_b32_e32 v136, 4, v4
	v_or_b32_e32 v4, 0x300, v0
	v_lshlrev_b32_e32 v138, 4, v0
	v_lshlrev_b32_e32 v0, 3, v0
	v_lshlrev_b32_e32 v139, 4, v2
	v_lshlrev_b32_e32 v140, 4, v3
	v_lshl_or_b32 v2, v67, 7, v106
	v_and_b32_e32 v3, 56, v0
	v_or_b32_e32 v0, v2, v3
	v_lshlrev_b32_e32 v142, 1, v0
	v_or_b32_e32 v0, 8, v2
	s_movk_i32 s6, 0x3f0
	v_xor_b32_e32 v0, v0, v3
	v_and_or_b32 v1, v4, s6, v1
	v_lshlrev_b32_e32 v141, 4, v4
	v_lshlrev_b32_e32 v143, 1, v0
	v_or_b32_e32 v0, 16, v2
	v_or_b32_e32 v4, 0x1008, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v144, 1, v0
	v_or_b32_e32 v0, 24, v2
	v_lshlrev_b32_e32 v158, 1, v4
	v_or_b32_e32 v4, 0x1010, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v145, 1, v0
	v_or_b32_e32 v0, 32, v2
	v_lshlrev_b32_e32 v159, 1, v4
	v_or_b32_e32 v4, 0x1018, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v146, 1, v0
	v_or_b32_e32 v0, 40, v2
	v_lshlrev_b32_e32 v160, 1, v4
	v_or_b32_e32 v4, 0x1020, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v147, 1, v0
	v_or_b32_e32 v0, 48, v2
	v_lshlrev_b32_e32 v161, 1, v4
	v_or_b32_e32 v4, 0x1028, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v148, 1, v0
	v_or_b32_e32 v0, 56, v2
	v_lshlrev_b32_e32 v162, 1, v4
	v_or_b32_e32 v4, 0x1030, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v149, 1, v0
	v_or_b32_e32 v0, 0x48, v2
	v_lshlrev_b32_e32 v163, 1, v4
	v_or_b32_e32 v4, 0x1038, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v150, 1, v0
	v_or_b32_e32 v0, 0x50, v2
	v_lshlrev_b32_e32 v164, 1, v4
	v_or_b32_e32 v4, 0x1048, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v151, 1, v0
	v_or_b32_e32 v0, 0x58, v2
	v_lshlrev_b32_e32 v165, 1, v4
	v_or_b32_e32 v4, 0x1050, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v152, 1, v0
	v_or_b32_e32 v0, 0x60, v2
	v_lshlrev_b32_e32 v166, 1, v4
	v_or_b32_e32 v4, 0x1058, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v153, 1, v0
	v_or_b32_e32 v0, 0x68, v2
	v_lshlrev_b32_e32 v167, 1, v4
	v_or_b32_e32 v4, 0x1060, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v154, 1, v0
	v_or_b32_e32 v0, 0x70, v2
	v_lshlrev_b32_e32 v168, 1, v4
	v_or_b32_e32 v4, 0x1068, v2
	v_xor_b32_e32 v0, v0, v3
	v_xor_b32_e32 v4, v4, v3
	v_lshlrev_b32_e32 v155, 1, v0
	v_or_b32_e32 v0, 0x78, v2
	v_lshlrev_b32_e32 v169, 1, v4
	v_or_b32_e32 v4, 0x1070, v2
	v_or_b32_e32 v2, 0x1078, v2
	v_xor_b32_e32 v2, v2, v3
	v_xor_b32_e32 v0, v0, v3
	v_lshlrev_b32_e32 v171, 1, v2
	v_lshlrev_b32_e32 v2, 2, v113
	s_and_b32 s79, s79, 0xffff
	s_mul_i32 s6, s92, s33
	s_mul_i32 s4, s4, s5
	v_lshlrev_b32_e32 v156, 1, v0
	v_add_u32_e32 v0, s2, v131
	v_xor_b32_e32 v4, v4, v3
	v_xor_b32_e32 v172, 0x80, v2
	v_lshlrev_b32_e32 v2, 1, v67
	v_lshlrev_b32_e32 v3, 10, v68
	s_movk_i32 s2, 0x4000
	v_mov_b32_e32 v50, 0
	s_and_b32 s89, s89, 0xffff
	s_add_i32 s73, s82, -1
	v_lshlrev_b32_e32 v137, 4, v1
	s_add_u32 s75, s6, s4
	v_or_b32_e32 v157, 1, v106
	v_or_b32_e32 v1, 3, v106
	v_or_b32_e32 v108, 2, v106
	v_or_b32_e32 v99, 9, v106
	v_or_b32_e32 v101, 11, v106
	v_or_b32_e32 v110, 10, v106
	v_or_b32_e32 v103, 17, v106
	v_or_b32_e32 v105, 19, v106
	v_or_b32_e32 v112, 18, v106
	v_or_b32_e32 v107, 25, v106
	v_or_b32_e32 v109, 27, v106
	v_or_b32_e32 v114, 26, v106
	v_lshlrev_b32_e32 v170, 1, v4
	v_or3_b32 v173, v2, v3, s2
	s_mov_b32 s76, s82
	s_mov_b32 s77, s82
	v_mov_b32_e32 v111, v0
	s_mov_b32 s82, s83
	v_or_b32_e32 v174, 48, v132
	v_or_b32_e32 v175, 32, v132
	v_or_b32_e32 v176, 16, v132
	v_mov_b32_e32 v126, 0
	v_mov_b32_e32 v181, 0xf149f2ca
	s_mov_b32 s2, 0x3fb8aa3b
	v_mov_b32_e32 v177, 0xf149f2ca
	s_mov_b32 s80, 0xc2fc0000
	v_mov_b32_e32 v178, 0x42800000
	v_not_b32_e32 v179, 63
	s_movk_i32 s92, 0x7fff
	s_mov_b32 s93, 0x5040100
	s_mov_b32 s95, 0x7060302
	s_mov_b32 s90, s86
	s_mov_b32 s91, s87
	s_mov_b32 s84, s78
	s_mov_b32 s85, s79
	v_add_u32_e32 v180, 0x2000, v142
	v_mov_b32_e32 v51, v50
	v_mov_b32_e32 v52, v50
	v_mov_b32_e32 v53, v50
	v_mov_b32_e32 v54, v50
	v_mov_b32_e32 v55, v50
	v_mov_b32_e32 v56, v50
	v_mov_b32_e32 v57, v50
	v_mov_b32_e32 v58, v50
	v_mov_b32_e32 v59, v50
	v_mov_b32_e32 v60, v50
	v_mov_b32_e32 v61, v50
	v_mov_b32_e32 v62, v50
	v_mov_b32_e32 v63, v50
	v_mov_b32_e32 v64, v50
	v_mov_b32_e32 v65, v50
	v_mov_b32_e32 v34, v50
	v_mov_b32_e32 v35, v50
	v_mov_b32_e32 v36, v50
	v_mov_b32_e32 v37, v50
	v_mov_b32_e32 v38, v50
	v_mov_b32_e32 v39, v50
	v_mov_b32_e32 v40, v50
	v_mov_b32_e32 v41, v50
	v_mov_b32_e32 v42, v50
	v_mov_b32_e32 v43, v50
	v_mov_b32_e32 v44, v50
	v_mov_b32_e32 v45, v50
	v_mov_b32_e32 v46, v50
	v_mov_b32_e32 v47, v50
	v_mov_b32_e32 v48, v50
	v_mov_b32_e32 v49, v50
	v_mov_b32_e32 v18, v50
	v_mov_b32_e32 v19, v50
	v_mov_b32_e32 v20, v50
	v_mov_b32_e32 v21, v50
	v_mov_b32_e32 v22, v50
	v_mov_b32_e32 v23, v50
	v_mov_b32_e32 v24, v50
	v_mov_b32_e32 v25, v50
	v_mov_b32_e32 v26, v50
	v_mov_b32_e32 v27, v50
	v_mov_b32_e32 v28, v50
	v_mov_b32_e32 v29, v50
	v_mov_b32_e32 v30, v50
	v_mov_b32_e32 v31, v50
	v_mov_b32_e32 v32, v50
	v_mov_b32_e32 v33, v50
	v_mov_b32_e32 v2, v50
	v_mov_b32_e32 v3, v50
	v_mov_b32_e32 v4, v50
	v_mov_b32_e32 v5, v50
	v_mov_b32_e32 v6, v50
	v_mov_b32_e32 v7, v50
	v_mov_b32_e32 v8, v50
	v_mov_b32_e32 v9, v50
	v_mov_b32_e32 v10, v50
	v_mov_b32_e32 v11, v50
	v_mov_b32_e32 v12, v50
	v_mov_b32_e32 v13, v50
	v_mov_b32_e32 v14, v50
	v_mov_b32_e32 v15, v50
	v_mov_b32_e32 v16, v50
	v_mov_b32_e32 v17, v50
.LBB0_3:
	v_add_u32_e32 v66, s98, v132
	v_min_i32_e32 v66, s73, v66
	v_mul_lo_u32 v67, s74, v66
	v_add_u32_e32 v67, s72, v67
	v_add_lshl_u32 v67, v133, v67, 1
	s_barrier
	buffer_load_dwordx4 v[68:71], v67, s[88:91], 0 offen
	v_add_u32_e32 v67, s98, v176
	v_min_i32_e32 v67, s73, v67
	v_mul_lo_u32 v66, s94, v66
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v133, v66, 1
	s_add_i32 s34, s98, 32
	s_waitcnt vmcnt(0)
	ds_write_b128 v134, v[68:71]
	v_mul_lo_u32 v68, s74, v67
	v_add_u32_e32 v68, s72, v68
	v_add_lshl_u32 v68, v133, v68, 1
	buffer_load_dwordx4 v[68:71], v68, s[88:91], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v135, v[68:71]
	v_add_u32_e32 v68, s98, v175
	v_min_i32_e32 v68, s73, v68
	v_mul_lo_u32 v69, s74, v68
	v_add_u32_e32 v69, s72, v69
	v_add_lshl_u32 v69, v133, v69, 1
	buffer_load_dwordx4 v[70:73], v69, s[88:91], 0 offen
	v_add_u32_e32 v69, s98, v174
	v_min_i32_e32 v69, s73, v69
	s_waitcnt vmcnt(0)
	ds_write_b128 v136, v[70:73]
	v_mul_lo_u32 v70, s74, v69
	v_add_u32_e32 v70, s72, v70
	v_add_lshl_u32 v70, v133, v70, 1
	buffer_load_dwordx4 v[70:73], v70, s[88:91], 0 offen
	s_waitcnt vmcnt(0)
	ds_write_b128 v137, v[70:73]
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s94, v67
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v133, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v138, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s94, v68
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v133, v66, 1
	s_waitcnt vmcnt(0)
	ds_write_b128 v139, v[70:73] offset:16384
	buffer_load_dwordx4 v[70:73], v66, s[84:87], 0 offen
	v_mul_lo_u32 v66, s94, v69
	v_add_u32_e32 v66, s75, v66
	v_add_lshl_u32 v66, v133, v66, 1
	buffer_load_dwordx4 v[66:69], v66, s[84:87], 0 offen
	s_waitcnt vmcnt(1)
	ds_write_b128 v140, v[70:73] offset:16384
	s_waitcnt vmcnt(0)
	ds_write_b128 v141, v[66:69] offset:16384
	s_waitcnt lgkmcnt(0)
	s_barrier
	ds_read2_b64 v[82:85], v142 offset1:16
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[212:213], 0
	ds_read_b64 v[82:83], v143
	ds_read_b64 v[116:117], v158
	ds_read2_b64 v[214:217], v180 offset1:16
	s_waitcnt lgkmcnt(2)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[210:211], v[66:81]
	ds_read_b64 v[82:83], v144
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[208:209], v[66:81]
	ds_read_b64 v[82:83], v145
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[206:207], v[66:81]
	ds_read_b64 v[82:83], v146
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[204:205], v[66:81]
	ds_read_b64 v[82:83], v147
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[202:203], v[66:81]
	ds_read_b64 v[82:83], v148
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[200:201], v[66:81]
	ds_read_b64 v[82:83], v149
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[198:199], v[66:81]
	ds_read_b64 v[82:83], v150
	v_mfma_f32_32x32x8_bf16 v[66:81], v[84:85], v[196:197], v[66:81]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[194:195], v[66:81]
	ds_read_b64 v[82:83], v151
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[192:193], v[66:81]
	ds_read_b64 v[82:83], v152
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[190:191], v[66:81]
	ds_read_b64 v[82:83], v153
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[188:189], v[66:81]
	ds_read_b64 v[82:83], v154
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[186:187], v[66:81]
	ds_read_b64 v[82:83], v155
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[184:185], v[66:81]
	ds_read_b64 v[82:83], v156
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[66:81], v[82:83], v[182:183], v[66:81]
	v_mfma_f32_32x32x8_bf16 v[82:97], v[214:215], v[212:213], 0
	v_or_b32_e32 v214, s34, v109
	v_or_b32_e32 v215, s34, v114
	s_nop 7
	v_mul_f32_e64 v78, s82, v78
	v_mul_f32_e64 v79, s83, v79
	v_mul_f32_e64 v66, s82, v66
	v_mul_f32_e64 v67, s83, v67
	v_pk_mul_f32 v[78:79], v[78:79], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[70:71], s[82:83], v[70:71]
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[210:211], v[82:97]
	ds_read_b64 v[116:117], v159
	v_mul_f32_e64 v70, v70, s2
	v_mul_f32_e64 v71, v71, s2
	v_mul_f32_e64 v72, s82, v72
	v_mul_f32_e64 v73, s83, v73
	v_pk_mul_f32 v[74:75], s[82:83], v[74:75]
	v_pk_mul_f32 v[72:73], v[72:73], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[74:75], v[74:75], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[76:77], s[82:83], v[76:77]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[208:209], v[82:97]
	ds_read_b64 v[116:117], v160
	v_mul_f32_e64 v76, v76, s2
	v_mul_f32_e64 v77, v77, s2
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[206:207], v[82:97]
	ds_read_b64 v[116:117], v161
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[204:205], v[82:97]
	ds_read_b64 v[116:117], v162
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[202:203], v[82:97]
	ds_read_b64 v[116:117], v163
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[200:201], v[82:97]
	ds_read_b64 v[116:117], v164
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[198:199], v[82:97]
	ds_read_b64 v[116:117], v165
	v_mfma_f32_32x32x8_bf16 v[82:97], v[216:217], v[196:197], v[82:97]
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[194:195], v[82:97]
	ds_read_b64 v[116:117], v166
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[192:193], v[82:97]
	ds_read_b64 v[116:117], v167
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[190:191], v[82:97]
	ds_read_b64 v[116:117], v168
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[188:189], v[82:97]
	ds_read_b64 v[116:117], v169
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[186:187], v[82:97]
	ds_read_b64 v[116:117], v170
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[184:185], v[82:97]
	ds_read_b64 v[116:117], v171
	s_waitcnt lgkmcnt(0)
	v_mfma_f32_32x32x8_bf16 v[82:97], v[116:117], v[182:183], v[82:97]
	v_or_b32_e32 v116, s34, v107
	v_or_b32_e32 v117, s34, v100
	v_cmp_gt_i32_e32 vcc, s77, v116
	v_cmp_gt_i32_e64 s[4:5], s76, v117
	v_sub_u32_e32 v117, v117, v0
	v_sub_u32_e32 v116, v116, v111
	v_cmp_gt_i32_e64 s[6:7], 1, v116
	s_nop 3
	v_pk_mul_f32 v[94:95], s[82:83], v[94:95]
	v_cmp_gt_i32_e64 s[8:9], 1, v117
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	s_and_b64 s[66:67], s[4:5], s[8:9]
	s_and_b64 s[6:7], vcc, s[6:7]
	v_cndmask_b32_e64 v117, v177, v95, s[6:7]
	v_cndmask_b32_e64 v116, v177, v94, s[66:67]
	v_pk_mul_f32 v[94:95], s[82:83], v[96:97]
	v_sub_u32_e32 v96, v215, v0
	v_sub_u32_e32 v97, v214, v111
	v_cmp_gt_i32_e64 s[4:5], s77, v214
	v_cmp_gt_i32_e32 vcc, s76, v215
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
	v_or_b32_e32 v214, s34, v105
	v_or_b32_e32 v215, s34, v112
	v_cndmask_b32_e64 v97, v177, v91, s[14:15]
	v_cndmask_b32_e64 v96, v177, v90, s[10:11]
	v_pk_mul_f32 v[90:91], s[82:83], v[92:93]
	v_sub_u32_e32 v92, v215, v0
	v_sub_u32_e32 v93, v214, v111
	v_cmp_gt_i32_e64 s[12:13], s77, v214
	v_cmp_gt_i32_e64 s[8:9], s76, v215
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
	v_or_b32_e32 v214, s34, v101
	v_or_b32_e32 v215, s34, v110
	v_cndmask_b32_e64 v93, v177, v87, s[22:23]
	v_cndmask_b32_e64 v92, v177, v86, s[18:19]
	v_pk_mul_f32 v[86:87], s[82:83], v[88:89]
	v_sub_u32_e32 v88, v215, v0
	v_sub_u32_e32 v89, v214, v111
	v_cmp_gt_i32_e64 s[20:21], s77, v214
	v_cmp_gt_i32_e64 s[16:17], s76, v215
	v_cmp_gt_i32_e64 s[24:25], 1, v89
	v_cmp_gt_i32_e64 s[26:27], 1, v88
	v_or_b32_e32 v88, s34, v157
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
	v_or_b32_e32 v214, s34, v1
	v_or_b32_e32 v215, s34, v108
	v_cndmask_b32_e64 v89, v177, v83, s[30:31]
	v_cndmask_b32_e64 v88, v177, v82, s[26:27]
	v_pk_mul_f32 v[82:83], s[82:83], v[84:85]
	v_sub_u32_e32 v84, v215, v0
	v_sub_u32_e32 v85, v214, v111
	v_cmp_gt_i32_e64 s[28:29], s77, v214
	v_cmp_gt_i32_e64 s[24:25], s76, v215
	v_cmp_gt_i32_e64 s[34:35], 1, v85
	v_cmp_gt_i32_e64 s[36:37], 1, v84
	v_or_b32_e32 v84, s98, v107
	v_or_b32_e32 v85, s98, v100
	s_and_b64 s[24:25], s[24:25], s[36:37]
	s_and_b64 s[28:29], s[28:29], s[34:35]
	v_cmp_gt_i32_e64 s[34:35], s77, v84
	v_cmp_gt_i32_e64 s[36:37], s76, v85
	v_sub_u32_e32 v85, v85, v0
	v_sub_u32_e32 v84, v84, v111
	v_cmp_gt_i32_e64 s[38:39], 1, v84
	v_cmp_gt_i32_e64 s[40:41], 1, v85
	s_and_b64 s[36:37], s[36:37], s[40:41]
	s_and_b64 s[40:41], s[34:35], s[38:39]
	v_or_b32_e32 v214, s98, v109
	v_or_b32_e32 v215, s98, v114
	v_cndmask_b32_e64 v85, v177, v79, s[40:41]
	v_cndmask_b32_e64 v84, v177, v78, s[36:37]
	v_pk_mul_f32 v[78:79], s[82:83], v[80:81]
	v_sub_u32_e32 v80, v215, v0
	v_sub_u32_e32 v81, v214, v111
	v_cmp_gt_i32_e64 s[38:39], s77, v214
	v_cmp_gt_i32_e64 s[34:35], s76, v215
	v_cmp_gt_i32_e64 s[42:43], 1, v81
	v_cmp_gt_i32_e64 s[44:45], 1, v80
	v_or_b32_e32 v80, s98, v103
	v_or_b32_e32 v81, s98, v102
	s_and_b64 s[34:35], s[34:35], s[44:45]
	s_and_b64 s[38:39], s[38:39], s[42:43]
	v_cmp_gt_i32_e64 s[42:43], s77, v80
	v_cmp_gt_i32_e64 s[44:45], s76, v81
	v_sub_u32_e32 v81, v81, v0
	v_sub_u32_e32 v80, v80, v111
	v_cmp_gt_i32_e64 s[46:47], 1, v80
	v_cmp_gt_i32_e64 s[48:49], 1, v81
	v_or_b32_e32 v80, s98, v105
	v_or_b32_e32 v81, s98, v112
	s_and_b64 s[44:45], s[44:45], s[48:49]
	s_and_b64 s[48:49], s[42:43], s[46:47]
	v_cmp_gt_i32_e64 s[46:47], s77, v80
	v_cmp_gt_i32_e64 s[42:43], s76, v81
	v_sub_u32_e32 v81, v81, v0
	v_sub_u32_e32 v80, v80, v111
	v_cmp_gt_i32_e64 s[50:51], 1, v80
	v_cmp_gt_i32_e64 s[52:53], 1, v81
	v_or_b32_e32 v80, s98, v99
	v_or_b32_e32 v81, s98, v104
	s_and_b64 s[42:43], s[42:43], s[52:53]
	s_and_b64 s[46:47], s[46:47], s[50:51]
	v_cmp_gt_i32_e64 s[50:51], s77, v80
	v_cmp_gt_i32_e64 s[52:53], s76, v81
	v_sub_u32_e32 v81, v81, v0
	v_sub_u32_e32 v80, v80, v111
	v_cmp_gt_i32_e64 s[54:55], 1, v80
	v_cmp_gt_i32_e64 s[56:57], 1, v81
	v_or_b32_e32 v80, s98, v101
	v_or_b32_e32 v81, s98, v110
	s_and_b64 s[52:53], s[52:53], s[56:57]
	s_and_b64 s[56:57], s[50:51], s[54:55]
	v_cmp_gt_i32_e64 s[54:55], s77, v80
	v_cmp_gt_i32_e64 s[50:51], s76, v81
	v_sub_u32_e32 v81, v81, v0
	v_sub_u32_e32 v80, v80, v111
	v_cmp_gt_i32_e64 s[58:59], 1, v80
	v_cmp_gt_i32_e64 s[60:61], 1, v81
	v_or_b32_e32 v80, s98, v157
	v_or_b32_e32 v81, s98, v106
	s_and_b64 s[50:51], s[50:51], s[60:61]
	s_and_b64 s[54:55], s[54:55], s[58:59]
	v_cmp_gt_i32_e64 s[60:61], s77, v80
	v_cmp_gt_i32_e64 s[58:59], s76, v81
	v_sub_u32_e32 v81, v81, v0
	v_sub_u32_e32 v80, v80, v111
	v_cmp_gt_i32_e64 s[62:63], 1, v80
	v_cmp_gt_i32_e64 s[64:65], 1, v81
	s_and_b64 s[58:59], s[58:59], s[64:65]
	s_and_b64 s[62:63], s[60:61], s[62:63]
	v_cndmask_b32_e64 v81, v177, v67, s[62:63]
	v_cndmask_b32_e64 v80, v177, v66, s[58:59]
	v_or_b32_e32 v215, s98, v108
	v_cmp_gt_f32_e64 s[60:61], v80, v81
	v_pk_mul_f32 v[66:67], s[82:83], v[68:69]
	v_sub_u32_e32 v68, v215, v0
	v_cndmask_b32_e64 v216, v81, v80, s[60:61]
	v_or_b32_e32 v214, s98, v1
	v_cmp_gt_i32_e64 s[60:61], s76, v215
	v_cmp_gt_i32_e64 s[70:71], 1, v68
	v_pk_mul_f32 v[66:67], v[66:67], s[2:3] op_sel_hi:[1,0]
	v_sub_u32_e32 v69, v214, v111
	s_and_b64 s[60:61], s[60:61], s[70:71]
	v_cmp_gt_i32_e64 s[64:65], s77, v214
	v_cmp_gt_i32_e64 s[68:69], 1, v69
	v_cndmask_b32_e64 v214, v177, v66, s[60:61]
	s_and_b64 s[64:65], s[64:65], s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v216, v214
	v_cndmask_b32_e64 v215, v177, v67, s[64:65]
	v_cndmask_b32_e64 v70, v177, v70, s[52:53]
	v_cndmask_b32_e64 v66, v214, v216, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v215
	v_cndmask_b32_e64 v71, v177, v71, s[56:57]
	v_cndmask_b32_e64 v72, v177, v72, s[50:51]
	v_cndmask_b32_e64 v66, v215, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v70
	v_cndmask_b32_e64 v73, v177, v73, s[54:55]
	v_cndmask_b32_e64 v74, v177, v74, s[44:45]
	v_cndmask_b32_e64 v66, v70, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v71
	v_cndmask_b32_e64 v75, v177, v75, s[48:49]
	v_cndmask_b32_e64 v76, v177, v76, s[42:43]
	v_cndmask_b32_e64 v66, v71, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v72
	v_cndmask_b32_e64 v77, v177, v77, s[46:47]
	v_pk_mul_f32 v[78:79], v[78:79], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v72, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v73
	v_cndmask_b32_e64 v78, v177, v78, s[34:35]
	v_cndmask_b32_e64 v79, v177, v79, s[38:39]
	v_cndmask_b32_e64 v66, v73, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v74
	v_pk_mul_f32 v[82:83], v[82:83], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[86:87], v[86:87], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v74, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v75
	v_cndmask_b32_e64 v82, v177, v82, s[24:25]
	v_cndmask_b32_e64 v83, v177, v83, s[28:29]
	v_cndmask_b32_e64 v66, v75, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v76
	v_cndmask_b32_e64 v86, v177, v86, s[16:17]
	v_cndmask_b32_e64 v87, v177, v87, s[20:21]
	v_cndmask_b32_e64 v66, v76, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v77
	v_pk_mul_f32 v[90:91], v[90:91], s[2:3] op_sel_hi:[1,0]
	v_pk_mul_f32 v[94:95], v[94:95], s[2:3] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v66, v77, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v84
	v_cndmask_b32_e64 v90, v177, v90, s[8:9]
	v_cndmask_b32_e64 v91, v177, v91, s[12:13]
	v_cndmask_b32_e64 v66, v84, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v85
	v_cndmask_b32_e32 v94, v177, v94, vcc
	v_cndmask_b32_e64 v95, v177, v95, s[4:5]
	v_cndmask_b32_e64 v66, v85, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v78
	s_add_u32 s96, s96, -1
	s_addc_u32 s97, s97, -1
	v_cndmask_b32_e64 v66, v78, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v79
	s_add_i32 s98, s98, 64
	s_cmp_lg_u64 s[96:97], 0
	v_cndmask_b32_e64 v66, v79, v66, s[68:69]
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
	v_cmp_gt_f32_e64 s[68:69], v66, v116
	s_nop 1
	v_cndmask_b32_e64 v66, v116, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v117
	s_nop 1
	v_cndmask_b32_e64 v66, v117, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v94
	s_nop 1
	v_cndmask_b32_e64 v66, v94, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v66, v95
	s_nop 1
	v_cndmask_b32_e64 v66, v95, v66, s[68:69]
	ds_bpermute_b32 v67, v172, v66
	s_waitcnt lgkmcnt(0)
	v_cmp_gt_f32_e64 s[68:69], v66, v67
	s_nop 1
	v_cndmask_b32_e64 v66, v67, v66, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], v181, v66
	s_nop 1
	v_cndmask_b32_e64 v66, v66, v181, s[68:69]
	v_sub_f32_e32 v67, v181, v66
	v_cmp_gt_f32_e64 s[68:69], s80, v67
	s_nop 1
	v_cndmask_b32_e64 v68, 0, v178, s[68:69]
	v_add_f32_e32 v67, v67, v68
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v68, 0, v179, s[68:69]
	v_pk_add_f32 v[80:81], v[80:81], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_ldexp_f32 v68, v67, v68
	v_cmp_gt_f32_e64 s[68:69], s80, v80
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v178, s[68:69]
	v_add_f32_e32 v67, v80, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v69, 0, v179, s[68:69]
	v_cmp_gt_f32_e64 s[68:69], s80, v81
	v_ldexp_f32 v67, v67, v69
	s_nop 0
	v_cndmask_b32_e64 v69, 0, v178, s[68:69]
	v_add_f32_e32 v69, v81, v69
	v_exp_f32_e32 v69, v69
	v_cndmask_b32_e64 v80, 0, v179, s[68:69]
	v_cndmask_b32_e64 v181, 0, v67, s[58:59]
	v_ldexp_f32 v69, v69, v80
	v_pk_add_f32 v[80:81], v[214:215], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v69, 0, v69, s[62:63]
	v_cmp_gt_f32_e64 s[58:59], s80, v80
	v_pk_mul_f32 v[64:65], v[64:65], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[62:63], v[62:63], v[68:69] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v178, s[58:59]
	v_add_f32_e32 v67, v80, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v80, 0, v179, s[58:59]
	v_cmp_gt_f32_e64 s[58:59], s80, v81
	v_pk_mul_f32 v[60:61], v[60:61], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v80
	v_cndmask_b32_e64 v80, 0, v178, s[58:59]
	v_pk_add_f32 v[70:71], v[70:71], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_add_f32_e32 v80, v81, v80
	v_cndmask_b32_e64 v81, 0, v179, s[58:59]
	v_cmp_gt_f32_e64 s[58:59], s80, v70
	v_cndmask_b32_e64 v215, 0, v67, s[60:61]
	v_exp_f32_e32 v80, v80
	v_cndmask_b32_e64 v67, 0, v178, s[58:59]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[58:59]
	v_cmp_gt_f32_e64 s[58:59], s80, v71
	v_ldexp_f32 v80, v80, v81
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v178, s[58:59]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[58:59]
	v_cndmask_b32_e64 v217, 0, v67, s[52:53]
	v_cndmask_b32_e64 v214, 0, v80, s[64:65]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v216, 0, v70, s[56:57]
	v_pk_add_f32 v[70:71], v[72:73], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[58:59], v[58:59], v[68:69] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[52:53], s80, v70
	v_pk_mul_f32 v[56:57], v[56:57], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[54:55], v[54:55], v[68:69] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v178, s[52:53]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[52:53]
	v_cmp_gt_f32_e64 s[52:53], s80, v71
	v_pk_mul_f32 v[52:53], v[52:53], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v178, s[52:53]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[52:53]
	v_cndmask_b32_e64 v219, 0, v67, s[50:51]
	v_pk_mul_f32 v[50:51], v[50:51], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v218, 0, v70, s[54:55]
	v_pk_add_f32 v[70:71], v[74:75], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[48:49], v[48:49], v[68:69] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[50:51], s80, v70
	v_pk_mul_f32 v[46:47], v[46:47], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[68:69] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v178, s[50:51]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[50:51]
	v_cmp_gt_f32_e64 s[50:51], s80, v71
	v_pk_mul_f32 v[42:43], v[42:43], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v178, s[50:51]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[50:51]
	v_cndmask_b32_e64 v221, 0, v67, s[44:45]
	v_pk_mul_f32 v[40:41], v[40:41], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v220, 0, v70, s[48:49]
	v_pk_add_f32 v[70:71], v[76:77], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[38:39], v[38:39], v[68:69] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[44:45], s80, v70
	v_pk_mul_f32 v[36:37], v[36:37], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[34:35], v[34:35], v[68:69] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v178, s[44:45]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[44:45]
	v_cmp_gt_f32_e64 s[44:45], s80, v71
	v_pk_mul_f32 v[32:33], v[32:33], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v178, s[44:45]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[44:45]
	v_cndmask_b32_e64 v223, 0, v67, s[42:43]
	v_pk_mul_f32 v[30:31], v[30:31], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v222, 0, v70, s[46:47]
	v_pk_add_f32 v[70:71], v[84:85], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[28:29], v[28:29], v[68:69] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[42:43], s80, v70
	v_pk_mul_f32 v[26:27], v[26:27], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[68:69] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v178, s[42:43]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[42:43]
	v_cmp_gt_f32_e64 s[42:43], s80, v71
	v_pk_mul_f32 v[22:23], v[22:23], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v178, s[42:43]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[42:43]
	v_cndmask_b32_e64 v224, 0, v67, s[36:37]
	v_pk_mul_f32 v[20:21], v[20:21], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v85, 0, v70, s[40:41]
	v_pk_add_f32 v[70:71], v[78:79], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[18:19], v[18:19], v[68:69] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[36:37], s80, v70
	v_pk_mul_f32 v[16:17], v[16:17], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[14:15], v[14:15], v[68:69] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v178, s[36:37]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[36:37]
	v_cmp_gt_f32_e64 s[36:37], s80, v71
	v_pk_mul_f32 v[12:13], v[12:13], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v178, s[36:37]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[36:37]
	v_cndmask_b32_e64 v226, 0, v67, s[34:35]
	v_pk_mul_f32 v[10:11], v[10:11], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v225, 0, v70, s[38:39]
	v_pk_add_f32 v[70:71], v[88:89], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_pk_mul_f32 v[8:9], v[8:9], v[68:69] op_sel_hi:[1,0]
	v_cmp_gt_f32_e64 s[34:35], s80, v70
	v_pk_mul_f32 v[6:7], v[6:7], v[68:69] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[68:69] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v67, 0, v178, s[34:35]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[34:35]
	v_cmp_gt_f32_e64 s[34:35], s80, v71
	v_pk_mul_f32 v[2:3], v[2:3], v[68:69] op_sel_hi:[1,0]
	v_ldexp_f32 v67, v67, v70
	v_cndmask_b32_e64 v70, 0, v178, s[34:35]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[34:35]
	v_cndmask_b32_e64 v84, 0, v67, s[26:27]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v81, 0, v70, s[30:31]
	v_pk_add_f32 v[70:71], v[82:83], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[26:27], s80, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v178, s[26:27]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[26:27]
	v_cmp_gt_f32_e64 s[26:27], s80, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v178, s[26:27]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[26:27]
	v_cndmask_b32_e64 v83, 0, v67, s[24:25]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v82, 0, v70, s[28:29]
	v_pk_add_f32 v[70:71], v[92:93], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[24:25], s80, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v178, s[24:25]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[24:25]
	v_cmp_gt_f32_e64 s[24:25], s80, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v178, s[24:25]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[24:25]
	v_cndmask_b32_e64 v79, 0, v67, s[18:19]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v77, 0, v70, s[22:23]
	v_pk_add_f32 v[70:71], v[86:87], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[18:19], s80, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v178, s[18:19]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[18:19]
	v_cmp_gt_f32_e64 s[18:19], s80, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v178, s[18:19]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[18:19]
	v_cndmask_b32_e64 v80, 0, v67, s[16:17]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v78, 0, v70, s[20:21]
	v_pk_add_f32 v[70:71], v[96:97], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[16:17], s80, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v178, s[16:17]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[16:17]
	v_cmp_gt_f32_e64 s[16:17], s80, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v178, s[16:17]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[16:17]
	v_cndmask_b32_e64 v75, 0, v67, s[10:11]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v73, 0, v70, s[14:15]
	v_pk_add_f32 v[70:71], v[90:91], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[10:11], s80, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v178, s[10:11]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[10:11]
	v_cmp_gt_f32_e64 s[10:11], s80, v71
	v_ldexp_f32 v67, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v178, s[10:11]
	v_add_f32_e32 v70, v71, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v71, 0, v179, s[10:11]
	v_cndmask_b32_e64 v76, 0, v67, s[8:9]
	v_ldexp_f32 v70, v70, v71
	v_cndmask_b32_e64 v74, 0, v70, s[12:13]
	v_pk_add_f32 v[70:71], v[116:117], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	s_nop 0
	v_cmp_gt_f32_e64 s[8:9], s80, v70
	s_nop 1
	v_cndmask_b32_e64 v67, 0, v178, s[8:9]
	v_add_f32_e32 v67, v70, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v70, 0, v179, s[8:9]
	v_cmp_gt_f32_e64 s[8:9], s80, v71
	v_ldexp_f32 v70, v67, v70
	s_nop 0
	v_cndmask_b32_e64 v67, 0, v178, s[8:9]
	v_add_f32_e32 v67, v71, v67
	v_exp_f32_e32 v67, v67
	v_cndmask_b32_e64 v71, 0, v179, s[8:9]
	v_ldexp_f32 v67, v67, v71
	v_cndmask_b32_e64 v67, 0, v67, s[6:7]
	v_pk_add_f32 v[86:87], v[94:95], v[66:67] op_sel_hi:[1,0] neg_lo:[0,1] neg_hi:[0,1]
	v_cndmask_b32_e64 v71, 0, v70, s[66:67]
	v_cmp_gt_f32_e64 s[6:7], s80, v86
	s_nop 1
	v_cndmask_b32_e64 v70, 0, v178, s[6:7]
	v_add_f32_e32 v70, v86, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v72, 0, v179, s[6:7]
	v_cmp_gt_f32_e64 s[6:7], s80, v87
	v_ldexp_f32 v72, v70, v72
	s_nop 0
	v_cndmask_b32_e64 v70, 0, v178, s[6:7]
	v_add_f32_e32 v70, v87, v70
	v_exp_f32_e32 v70, v70
	v_cndmask_b32_e64 v86, 0, v179, s[6:7]
	v_cndmask_b32_e32 v72, 0, v72, vcc
	v_cmp_u_f32_e32 vcc, v181, v181
	v_ldexp_f32 v70, v70, v86
	v_add_f32_e32 v86, v181, v69
	v_add_f32_e32 v86, v215, v86
	v_add_f32_e32 v86, v214, v86
	v_add_f32_e32 v86, v217, v86
	v_add_f32_e32 v86, v216, v86
	v_add_f32_e32 v86, v219, v86
	v_add_f32_e32 v86, v218, v86
	v_add_f32_e32 v86, v221, v86
	v_add_f32_e32 v86, v220, v86
	v_add_f32_e32 v86, v223, v86
	v_add_f32_e32 v86, v222, v86
	v_add_f32_e32 v86, v224, v86
	v_add_f32_e32 v86, v85, v86
	v_add_f32_e32 v86, v226, v86
	v_add_f32_e32 v86, v225, v86
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
	ds_bpermute_b32 v87, v172, v86
	s_waitcnt lgkmcnt(0)
	v_add_f32_e32 v86, v86, v87
	v_mul_f32_e32 v87, v126, v68
	v_bfe_u32 v68, v181, 16, 1
	v_add_f32_e32 v126, v87, v86
	v_add3_u32 v68, v68, v181, s92
	v_or_b32_e32 v86, 0x400000, v181
	v_cndmask_b32_e32 v86, v68, v86, vcc
	v_bfe_u32 v68, v69, 16, 1
	v_add3_u32 v68, v68, v69, s92
	v_or_b32_e32 v87, 0x400000, v69
	v_cmp_u_f32_e32 vcc, v69, v69
	v_or_b32_e32 v69, 0x400000, v215
	v_mov_b32_e32 v181, v66
	v_cndmask_b32_e32 v88, v68, v87, vcc
	v_bfe_u32 v68, v215, 16, 1
	v_add3_u32 v68, v68, v215, s92
	v_cmp_u_f32_e32 vcc, v215, v215
	v_perm_b32 v86, v88, v86, s95
	s_nop 0
	v_cndmask_b32_e32 v87, v68, v69, vcc
	v_bfe_u32 v68, v214, 16, 1
	v_add3_u32 v68, v68, v214, s92
	v_or_b32_e32 v69, 0x400000, v214
	v_cmp_u_f32_e32 vcc, v214, v214
	s_nop 1
	v_cndmask_b32_e32 v89, v68, v69, vcc
	ds_read_u16 v68, v173
	ds_read_u16 v90, v173 offset:256
	ds_read_u16 v69, v173 offset:512
	ds_read_u16 v91, v173 offset:768
	v_perm_b32 v87, v89, v87, s95
	v_cmp_u_f32_e32 vcc, v217, v217
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v90, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v91, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[86:87], v[50:65]
	ds_read_u16 v68, v173 offset:64
	ds_read_u16 v88, v173 offset:320
	ds_read_u16 v69, v173 offset:576
	ds_read_u16 v89, v173 offset:832
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[86:87], v[34:49]
	ds_read_u16 v68, v173 offset:128
	ds_read_u16 v88, v173 offset:384
	ds_read_u16 v69, v173 offset:640
	ds_read_u16 v89, v173 offset:896
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[86:87], v[18:33]
	ds_read_u16 v68, v173 offset:192
	ds_read_u16 v88, v173 offset:448
	ds_read_u16 v69, v173 offset:704
	ds_read_u16 v89, v173 offset:960
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[86:87], v[2:17]
	v_bfe_u32 v68, v217, 16, 1
	v_add3_u32 v68, v68, v217, s92
	v_or_b32_e32 v69, 0x400000, v217
	v_cndmask_b32_e32 v86, v68, v69, vcc
	v_bfe_u32 v68, v216, 16, 1
	v_add3_u32 v68, v68, v216, s92
	v_or_b32_e32 v69, 0x400000, v216
	v_cmp_u_f32_e32 vcc, v216, v216
	s_nop 1
	v_cndmask_b32_e32 v88, v68, v69, vcc
	v_bfe_u32 v68, v219, 16, 1
	v_add3_u32 v68, v68, v219, s92
	v_or_b32_e32 v69, 0x400000, v219
	v_cmp_u_f32_e32 vcc, v219, v219
	v_perm_b32 v86, v88, v86, s95
	s_nop 0
	v_cndmask_b32_e32 v87, v68, v69, vcc
	v_bfe_u32 v68, v218, 16, 1
	v_add3_u32 v68, v68, v218, s92
	v_or_b32_e32 v69, 0x400000, v218
	v_cmp_u_f32_e32 vcc, v218, v218
	s_nop 1
	v_cndmask_b32_e32 v89, v68, v69, vcc
	ds_read_u16 v68, v173 offset:2048
	ds_read_u16 v90, v173 offset:2304
	ds_read_u16 v69, v173 offset:2560
	ds_read_u16 v91, v173 offset:2816
	v_perm_b32 v87, v89, v87, s95
	v_cmp_u_f32_e32 vcc, v221, v221
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v90, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v91, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[86:87], v[50:65]
	ds_read_u16 v68, v173 offset:2112
	ds_read_u16 v88, v173 offset:2368
	ds_read_u16 v69, v173 offset:2624
	ds_read_u16 v89, v173 offset:2880
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[86:87], v[34:49]
	ds_read_u16 v68, v173 offset:2176
	ds_read_u16 v88, v173 offset:2432
	ds_read_u16 v69, v173 offset:2688
	ds_read_u16 v89, v173 offset:2944
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[86:87], v[18:33]
	ds_read_u16 v68, v173 offset:2240
	ds_read_u16 v88, v173 offset:2496
	ds_read_u16 v69, v173 offset:2752
	ds_read_u16 v89, v173 offset:3008
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[86:87], v[2:17]
	v_bfe_u32 v68, v221, 16, 1
	v_add3_u32 v68, v68, v221, s92
	v_or_b32_e32 v69, 0x400000, v221
	v_cndmask_b32_e32 v86, v68, v69, vcc
	v_bfe_u32 v68, v220, 16, 1
	v_add3_u32 v68, v68, v220, s92
	v_or_b32_e32 v69, 0x400000, v220
	v_cmp_u_f32_e32 vcc, v220, v220
	s_nop 1
	v_cndmask_b32_e32 v88, v68, v69, vcc
	v_bfe_u32 v68, v223, 16, 1
	v_add3_u32 v68, v68, v223, s92
	v_or_b32_e32 v69, 0x400000, v223
	v_cmp_u_f32_e32 vcc, v223, v223
	v_perm_b32 v86, v88, v86, s95
	s_nop 0
	v_cndmask_b32_e32 v87, v68, v69, vcc
	v_bfe_u32 v68, v222, 16, 1
	v_add3_u32 v68, v68, v222, s92
	v_or_b32_e32 v69, 0x400000, v222
	v_cmp_u_f32_e32 vcc, v222, v222
	s_nop 1
	v_cndmask_b32_e32 v89, v68, v69, vcc
	ds_read_u16 v68, v173 offset:4096
	ds_read_u16 v90, v173 offset:4352
	ds_read_u16 v69, v173 offset:4608
	ds_read_u16 v91, v173 offset:4864
	v_perm_b32 v87, v89, v87, s95
	v_cmp_u_f32_e32 vcc, v224, v224
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v90, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v91, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[86:87], v[50:65]
	ds_read_u16 v68, v173 offset:4160
	ds_read_u16 v88, v173 offset:4416
	ds_read_u16 v69, v173 offset:4672
	ds_read_u16 v89, v173 offset:4928
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[86:87], v[34:49]
	ds_read_u16 v68, v173 offset:4224
	ds_read_u16 v88, v173 offset:4480
	ds_read_u16 v69, v173 offset:4736
	ds_read_u16 v89, v173 offset:4992
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[86:87], v[18:33]
	ds_read_u16 v68, v173 offset:4288
	ds_read_u16 v88, v173 offset:4544
	ds_read_u16 v69, v173 offset:4800
	ds_read_u16 v89, v173 offset:5056
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v88, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v89, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[86:87], v[2:17]
	v_bfe_u32 v68, v224, 16, 1
	v_add3_u32 v68, v68, v224, s92
	v_or_b32_e32 v69, 0x400000, v224
	v_cndmask_b32_e32 v68, v68, v69, vcc
	v_bfe_u32 v69, v85, 16, 1
	v_add3_u32 v69, v69, v85, s92
	v_or_b32_e32 v86, 0x400000, v85
	v_cmp_u_f32_e32 vcc, v85, v85
	v_or_b32_e32 v87, 0x400000, v225
	s_nop 0
	v_cndmask_b32_e32 v85, v69, v86, vcc
	v_bfe_u32 v69, v226, 16, 1
	v_add3_u32 v69, v69, v226, s92
	v_or_b32_e32 v86, 0x400000, v226
	v_cmp_u_f32_e32 vcc, v226, v226
	v_perm_b32 v68, v85, v68, s95
	s_nop 0
	v_cndmask_b32_e32 v69, v69, v86, vcc
	v_bfe_u32 v86, v225, 16, 1
	v_add3_u32 v86, v86, v225, s92
	v_cmp_u_f32_e32 vcc, v225, v225
	s_nop 1
	v_cndmask_b32_e32 v86, v86, v87, vcc
	ds_read_u16 v87, v173 offset:6144
	ds_read_u16 v88, v173 offset:6400
	ds_read_u16 v89, v173 offset:6656
	ds_read_u16 v90, v173 offset:6912
	v_perm_b32 v69, v86, v69, s95
	v_cmp_u_f32_e32 vcc, v84, v84
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v88, v88, v87, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v89, v90, v89, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[88:89], v[68:69], v[50:65]
	ds_read_u16 v85, v173 offset:6208
	ds_read_u16 v86, v173 offset:6464
	ds_read_u16 v87, v173 offset:6720
	ds_read_u16 v88, v173 offset:6976
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v86, v85, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v88, v87, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[86:87], v[68:69], v[34:49]
	ds_read_u16 v85, v173 offset:6272
	ds_read_u16 v86, v173 offset:6528
	ds_read_u16 v87, v173 offset:6784
	ds_read_u16 v88, v173 offset:7040
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v86, v85, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v88, v87, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[86:87], v[68:69], v[18:33]
	ds_read_u16 v85, v173 offset:6336
	ds_read_u16 v86, v173 offset:6592
	ds_read_u16 v87, v173 offset:6848
	ds_read_u16 v88, v173 offset:7104
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v86, v86, v85, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v87, v88, v87, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[86:87], v[68:69], v[2:17]
	v_bfe_u32 v68, v84, 16, 1
	v_add3_u32 v68, v68, v84, s92
	v_or_b32_e32 v69, 0x400000, v84
	v_cndmask_b32_e32 v84, v68, v69, vcc
	v_bfe_u32 v68, v81, 16, 1
	v_add3_u32 v68, v68, v81, s92
	v_or_b32_e32 v69, 0x400000, v81
	v_cmp_u_f32_e32 vcc, v81, v81
	s_nop 1
	v_cndmask_b32_e32 v81, v68, v69, vcc
	v_bfe_u32 v68, v83, 16, 1
	v_add3_u32 v68, v68, v83, s92
	v_or_b32_e32 v69, 0x400000, v83
	v_cmp_u_f32_e32 vcc, v83, v83
	s_nop 1
	v_cndmask_b32_e32 v83, v68, v69, vcc
	v_bfe_u32 v68, v82, 16, 1
	v_add3_u32 v68, v68, v82, s92
	v_or_b32_e32 v69, 0x400000, v82
	v_cmp_u_f32_e32 vcc, v82, v82
	s_nop 1
	v_cndmask_b32_e32 v82, v68, v69, vcc
	ds_read_u16 v68, v173 offset:8192
	ds_read_u16 v85, v173 offset:8448
	ds_read_u16 v69, v173 offset:8704
	ds_read_u16 v86, v173 offset:8960
	v_perm_b32 v83, v82, v83, s95
	v_perm_b32 v82, v81, v84, s95
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v85, v68, s93
	v_cmp_u_f32_e32 vcc, v79, v79
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v86, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[82:83], v[50:65]
	ds_read_u16 v68, v173 offset:8256
	ds_read_u16 v81, v173 offset:8512
	ds_read_u16 v69, v173 offset:8768
	ds_read_u16 v84, v173 offset:9024
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v81, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v84, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[82:83], v[34:49]
	ds_read_u16 v68, v173 offset:8320
	ds_read_u16 v81, v173 offset:8576
	ds_read_u16 v69, v173 offset:8832
	ds_read_u16 v84, v173 offset:9088
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v81, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v84, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[82:83], v[18:33]
	ds_read_u16 v68, v173 offset:8384
	ds_read_u16 v81, v173 offset:8640
	ds_read_u16 v69, v173 offset:8896
	ds_read_u16 v84, v173 offset:9152
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v81, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v84, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[82:83], v[2:17]
	v_bfe_u32 v68, v79, 16, 1
	v_add3_u32 v68, v68, v79, s92
	v_or_b32_e32 v69, 0x400000, v79
	v_cndmask_b32_e32 v81, v68, v69, vcc
	v_bfe_u32 v68, v77, 16, 1
	v_add3_u32 v68, v68, v77, s92
	v_or_b32_e32 v69, 0x400000, v77
	v_cmp_u_f32_e32 vcc, v77, v77
	s_nop 1
	v_cndmask_b32_e32 v77, v68, v69, vcc
	v_bfe_u32 v68, v80, 16, 1
	v_add3_u32 v68, v68, v80, s92
	v_or_b32_e32 v69, 0x400000, v80
	v_cmp_u_f32_e32 vcc, v80, v80
	s_nop 1
	v_cndmask_b32_e32 v79, v68, v69, vcc
	v_bfe_u32 v68, v78, 16, 1
	v_add3_u32 v68, v68, v78, s92
	v_or_b32_e32 v69, 0x400000, v78
	v_cmp_u_f32_e32 vcc, v78, v78
	s_nop 1
	v_cndmask_b32_e32 v78, v68, v69, vcc
	ds_read_u16 v68, v173 offset:10240
	ds_read_u16 v80, v173 offset:10496
	ds_read_u16 v69, v173 offset:10752
	ds_read_u16 v82, v173 offset:11008
	v_perm_b32 v79, v78, v79, s95
	v_perm_b32 v78, v77, v81, s95
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v80, v68, s93
	v_cmp_u_f32_e32 vcc, v75, v75
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v82, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[78:79], v[50:65]
	ds_read_u16 v68, v173 offset:10304
	ds_read_u16 v77, v173 offset:10560
	ds_read_u16 v69, v173 offset:10816
	ds_read_u16 v80, v173 offset:11072
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v77, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v80, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[78:79], v[34:49]
	ds_read_u16 v68, v173 offset:10368
	ds_read_u16 v77, v173 offset:10624
	ds_read_u16 v69, v173 offset:10880
	ds_read_u16 v80, v173 offset:11136
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v77, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v80, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[78:79], v[18:33]
	ds_read_u16 v68, v173 offset:10432
	ds_read_u16 v77, v173 offset:10688
	ds_read_u16 v69, v173 offset:10944
	ds_read_u16 v80, v173 offset:11200
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v77, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v80, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[78:79], v[2:17]
	v_bfe_u32 v68, v75, 16, 1
	v_add3_u32 v68, v68, v75, s92
	v_or_b32_e32 v69, 0x400000, v75
	v_cndmask_b32_e32 v77, v68, v69, vcc
	v_bfe_u32 v68, v73, 16, 1
	v_add3_u32 v68, v68, v73, s92
	v_or_b32_e32 v69, 0x400000, v73
	v_cmp_u_f32_e32 vcc, v73, v73
	s_nop 1
	v_cndmask_b32_e32 v73, v68, v69, vcc
	v_bfe_u32 v68, v76, 16, 1
	v_add3_u32 v68, v68, v76, s92
	v_or_b32_e32 v69, 0x400000, v76
	v_cmp_u_f32_e32 vcc, v76, v76
	s_nop 1
	v_cndmask_b32_e32 v75, v68, v69, vcc
	v_bfe_u32 v68, v74, 16, 1
	v_add3_u32 v68, v68, v74, s92
	v_or_b32_e32 v69, 0x400000, v74
	v_cmp_u_f32_e32 vcc, v74, v74
	s_nop 1
	v_cndmask_b32_e32 v74, v68, v69, vcc
	ds_read_u16 v68, v173 offset:12288
	ds_read_u16 v76, v173 offset:12544
	ds_read_u16 v69, v173 offset:12800
	ds_read_u16 v78, v173 offset:13056
	v_perm_b32 v75, v74, v75, s95
	v_perm_b32 v74, v73, v77, s95
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v76, v68, s93
	v_cmp_u_f32_e32 vcc, v71, v71
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v78, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[68:69], v[74:75], v[50:65]
	ds_read_u16 v68, v173 offset:12352
	ds_read_u16 v73, v173 offset:12608
	ds_read_u16 v69, v173 offset:12864
	ds_read_u16 v76, v173 offset:13120
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v73, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v76, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[68:69], v[74:75], v[34:49]
	ds_read_u16 v68, v173 offset:12416
	ds_read_u16 v73, v173 offset:12672
	ds_read_u16 v69, v173 offset:12928
	ds_read_u16 v76, v173 offset:13184
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v73, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v76, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[68:69], v[74:75], v[18:33]
	ds_read_u16 v68, v173 offset:12480
	ds_read_u16 v73, v173 offset:12736
	ds_read_u16 v69, v173 offset:12992
	ds_read_u16 v76, v173 offset:13248
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v68, v73, v68, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v69, v76, v69, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[68:69], v[74:75], v[2:17]
	v_bfe_u32 v68, v71, 16, 1
	v_add3_u32 v68, v68, v71, s92
	v_or_b32_e32 v69, 0x400000, v71
	v_cndmask_b32_e32 v68, v68, v69, vcc
	v_bfe_u32 v69, v67, 16, 1
	v_add3_u32 v69, v69, v67, s92
	v_or_b32_e32 v71, 0x400000, v67
	v_cmp_u_f32_e32 vcc, v67, v67
	s_nop 1
	v_cndmask_b32_e32 v67, v69, v71, vcc
	v_bfe_u32 v69, v72, 16, 1
	v_add3_u32 v69, v69, v72, s92
	v_or_b32_e32 v71, 0x400000, v72
	v_cmp_u_f32_e32 vcc, v72, v72
	v_or_b32_e32 v72, 0x400000, v70
	v_perm_b32 v68, v67, v68, s95
	v_cndmask_b32_e32 v69, v69, v71, vcc
	v_bfe_u32 v71, v70, 16, 1
	v_add3_u32 v71, v71, v70, s92
	v_cmp_u_f32_e32 vcc, v70, v70
	s_nop 1
	v_cndmask_b32_e32 v72, v71, v72, vcc
	ds_read_u16 v70, v173 offset:14336
	ds_read_u16 v73, v173 offset:14592
	ds_read_u16 v71, v173 offset:14848
	ds_read_u16 v74, v173 offset:15104
	v_perm_b32 v69, v72, v69, s95
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v73, v70, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v74, v71, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[50:65], v[70:71], v[68:69], v[50:65]
	ds_read_u16 v67, v173 offset:14400
	ds_read_u16 v70, v173 offset:14656
	ds_read_u16 v71, v173 offset:14912
	ds_read_u16 v72, v173 offset:15168
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v70, v67, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v72, v71, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[34:49], v[70:71], v[68:69], v[34:49]
	ds_read_u16 v67, v173 offset:14464
	ds_read_u16 v70, v173 offset:14720
	ds_read_u16 v71, v173 offset:14976
	ds_read_u16 v72, v173 offset:15232
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v70, v67, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v72, v71, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[18:33], v[70:71], v[68:69], v[18:33]
	ds_read_u16 v67, v173 offset:14528
	ds_read_u16 v70, v173 offset:14784
	ds_read_u16 v71, v173 offset:15040
	ds_read_u16 v72, v173 offset:15296
	s_waitcnt lgkmcnt(2)
	v_perm_b32 v70, v70, v67, s93
	s_waitcnt lgkmcnt(0)
	v_perm_b32 v71, v72, v71, s93
	s_nop 1
	v_mfma_f32_32x32x8_bf16 v[2:17], v[70:71], v[68:69], v[2:17]
	s_cbranch_scc1 .LBB0_3
.LBB0_4:
	v_cmp_gt_i32_e32 vcc, s81, v131
	s_and_saveexec_b64 s[4:5], vcc
	s_cbranch_execz .LBB0_7
	v_div_scale_f32 v0, s[4:5], v126, v126, 1.0
	v_rcp_f32_e32 v1, v0
	s_load_dwordx2 s[8:9], s[0:1], 0x90
	s_load_dword s2, s[0:1], 0xa8
	s_load_dword s6, s[0:1], 0xb0
	s_load_dword s7, s[0:1], 0xb8
	s_mov_b32 s11, 0x27000
	s_waitcnt lgkmcnt(0)
	s_and_b32 s9, s9, 0xffff
	v_fma_f32 v67, -v0, v1, 1.0
	v_fmac_f32_e32 v1, v67, v1
	v_div_scale_f32 v67, vcc, 1.0, v126, 1.0
	v_mul_f32_e32 v68, v67, v1
	v_fma_f32 v69, -v0, v68, v67
	v_fmac_f32_e32 v68, v69, v1
	v_fma_f32 v0, -v0, v68, v67
	v_div_fmas_f32 v0, v0, v1, v68
	v_div_fixup_f32 v0, v0, v126, 1.0
	v_cmp_lt_f32_e32 vcc, 0, v126
	s_mul_i32 s2, s2, s33
	s_mul_i32 s7, s7, s3
	v_cndmask_b32_e32 v0, 0, v0, vcc
	v_mul_lo_u32 v1, s6, v98
	s_add_i32 s2, s2, s7
	v_add_u32_e32 v1, s2, v1
	v_pk_mul_f32 v[52:53], v[52:53], v[0:1] op_sel_hi:[1,0]
	s_movk_i32 s2, 0x7fff
	v_bfe_u32 v67, v52, 16, 1
	v_add3_u32 v67, v67, v52, s2
	v_or_b32_e32 v68, 0x400000, v52
	v_cmp_u_f32_e64 s[4:5], v52, v52
	v_pk_mul_f32 v[50:51], v[50:51], v[0:1] op_sel_hi:[1,0]
	s_mov_b32 s6, 0x7060302
	v_cndmask_b32_e64 v52, v67, v68, s[4:5]
	v_bfe_u32 v67, v53, 16, 1
	v_add3_u32 v67, v67, v53, s2
	v_or_b32_e32 v68, 0x400000, v53
	v_cmp_u_f32_e64 s[4:5], v53, v53
	s_mov_b32 s10, -1
	v_pk_mul_f32 v[56:57], v[56:57], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v53, v67, v68, s[4:5]
	v_perm_b32 v53, v53, v52, s6
	v_bfe_u32 v52, v50, 16, 1
	v_add3_u32 v52, v52, v50, s2
	v_or_b32_e32 v67, 0x400000, v50
	v_cmp_u_f32_e64 s[4:5], v50, v50
	v_pk_mul_f32 v[54:55], v[54:55], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[60:61], v[60:61], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v50, v52, v67, s[4:5]
	v_bfe_u32 v52, v51, 16, 1
	v_add3_u32 v52, v52, v51, s2
	v_or_b32_e32 v67, 0x400000, v51
	v_cmp_u_f32_e64 s[4:5], v51, v51
	v_pk_mul_f32 v[58:59], v[58:59], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[64:65], v[64:65], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v51, v52, v67, s[4:5]
	v_perm_b32 v52, v51, v50, s6
	v_lshl_add_u32 v50, v1, 1, v130
	buffer_store_dwordx2 v[52:53], v50, s[8:11], 0 offen
	v_bfe_u32 v50, v56, 16, 1
	v_add3_u32 v50, v50, v56, s2
	v_or_b32_e32 v51, 0x400000, v56
	v_cmp_u_f32_e64 s[4:5], v56, v56
	v_or_b32_e32 v52, 0x400000, v57
	v_or_b32_e32 v53, 0x400000, v55
	v_cndmask_b32_e64 v50, v50, v51, s[4:5]
	v_bfe_u32 v51, v57, 16, 1
	v_add3_u32 v51, v51, v57, s2
	v_cmp_u_f32_e64 s[4:5], v57, v57
	v_pk_mul_f32 v[62:63], v[62:63], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[36:37], v[36:37], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v51, v51, v52, s[4:5]
	v_perm_b32 v51, v51, v50, s6
	v_bfe_u32 v50, v54, 16, 1
	v_add3_u32 v50, v50, v54, s2
	v_or_b32_e32 v52, 0x400000, v54
	v_cmp_u_f32_e64 s[4:5], v54, v54
	v_pk_mul_f32 v[34:35], v[34:35], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[40:41], v[40:41], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v50, v50, v52, s[4:5]
	v_bfe_u32 v52, v55, 16, 1
	v_add3_u32 v52, v52, v55, s2
	v_cmp_u_f32_e64 s[4:5], v55, v55
	v_pk_mul_f32 v[38:39], v[38:39], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[44:45], v[44:45], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v52, v52, v53, s[4:5]
	v_perm_b32 v50, v52, v50, s6
	v_add_lshl_u32 v52, v104, v1, 1
	buffer_store_dwordx2 v[50:51], v52, s[8:11], 0 offen
	v_bfe_u32 v50, v60, 16, 1
	v_add3_u32 v50, v50, v60, s2
	v_or_b32_e32 v51, 0x400000, v60
	v_cmp_u_f32_e64 s[4:5], v60, v60
	v_or_b32_e32 v52, 0x400000, v61
	v_or_b32_e32 v53, 0x400000, v59
	v_cndmask_b32_e64 v50, v50, v51, s[4:5]
	v_bfe_u32 v51, v61, 16, 1
	v_add3_u32 v51, v51, v61, s2
	v_cmp_u_f32_e64 s[4:5], v61, v61
	v_pk_mul_f32 v[42:43], v[42:43], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[48:49], v[48:49], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v51, v51, v52, s[4:5]
	v_perm_b32 v51, v51, v50, s6
	v_bfe_u32 v50, v58, 16, 1
	v_add3_u32 v50, v50, v58, s2
	v_or_b32_e32 v52, 0x400000, v58
	v_cmp_u_f32_e64 s[4:5], v58, v58
	v_pk_mul_f32 v[46:47], v[46:47], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[20:21], v[20:21], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v50, v50, v52, s[4:5]
	v_bfe_u32 v52, v59, 16, 1
	v_add3_u32 v52, v52, v59, s2
	v_cmp_u_f32_e64 s[4:5], v59, v59
	v_pk_mul_f32 v[18:19], v[18:19], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[24:25], v[24:25], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v52, v52, v53, s[4:5]
	v_perm_b32 v50, v52, v50, s6
	v_add_lshl_u32 v52, v102, v1, 1
	buffer_store_dwordx2 v[50:51], v52, s[8:11], 0 offen
	v_bfe_u32 v50, v64, 16, 1
	v_add3_u32 v50, v50, v64, s2
	v_or_b32_e32 v51, 0x400000, v64
	v_cmp_u_f32_e64 s[4:5], v64, v64
	v_or_b32_e32 v52, 0x400000, v65
	v_or_b32_e32 v53, 0x400000, v63
	v_cndmask_b32_e64 v50, v50, v51, s[4:5]
	v_bfe_u32 v51, v65, 16, 1
	v_add3_u32 v51, v51, v65, s2
	v_cmp_u_f32_e64 s[4:5], v65, v65
	v_pk_mul_f32 v[22:23], v[22:23], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[28:29], v[28:29], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v51, v51, v52, s[4:5]
	v_perm_b32 v51, v51, v50, s6
	v_bfe_u32 v50, v62, 16, 1
	v_add3_u32 v50, v50, v62, s2
	v_or_b32_e32 v52, 0x400000, v62
	v_cmp_u_f32_e64 s[4:5], v62, v62
	v_pk_mul_f32 v[26:27], v[26:27], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[32:33], v[32:33], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v50, v50, v52, s[4:5]
	v_bfe_u32 v52, v63, 16, 1
	v_add3_u32 v52, v52, v63, s2
	v_cmp_u_f32_e64 s[4:5], v63, v63
	v_pk_mul_f32 v[30:31], v[30:31], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[4:5], v[4:5], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v52, v52, v53, s[4:5]
	v_perm_b32 v50, v52, v50, s6
	v_add_lshl_u32 v52, v100, v1, 1
	buffer_store_dwordx2 v[50:51], v52, s[8:11], 0 offen
	v_bfe_u32 v50, v36, 16, 1
	v_add3_u32 v50, v50, v36, s2
	v_or_b32_e32 v51, 0x400000, v36
	v_cmp_u_f32_e64 s[4:5], v36, v36
	v_pk_mul_f32 v[14:15], v[14:15], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[16:17], v[16:17], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v36, v50, v51, s[4:5]
	v_bfe_u32 v50, v37, 16, 1
	v_add3_u32 v50, v50, v37, s2
	v_or_b32_e32 v51, 0x400000, v37
	v_cmp_u_f32_e64 s[4:5], v37, v37
	v_pk_mul_f32 v[10:11], v[10:11], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[12:13], v[12:13], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v37, v50, v51, s[4:5]
	v_perm_b32 v37, v37, v36, s6
	v_bfe_u32 v36, v34, 16, 1
	v_add3_u32 v36, v36, v34, s2
	v_or_b32_e32 v50, 0x400000, v34
	v_cmp_u_f32_e64 s[4:5], v34, v34
	v_pk_mul_f32 v[6:7], v[6:7], v[0:1] op_sel_hi:[1,0]
	v_pk_mul_f32 v[8:9], v[8:9], v[0:1] op_sel_hi:[1,0]
	v_cndmask_b32_e64 v34, v36, v50, s[4:5]
	v_bfe_u32 v36, v35, 16, 1
	v_add3_u32 v36, v36, v35, s2
	v_or_b32_e32 v50, 0x400000, v35
	v_cmp_u_f32_e64 s[4:5], v35, v35
	v_pk_mul_f32 v[2:3], v[2:3], v[0:1] op_sel_hi:[1,0]
	v_bfe_u32 v0, v4, 16, 1
	v_cndmask_b32_e64 v35, v36, v50, s[4:5]
	v_perm_b32 v36, v35, v34, s6
	v_add_lshl_u32 v34, v129, v1, 1
	buffer_store_dwordx2 v[36:37], v34, s[8:11], 0 offen
	v_bfe_u32 v34, v40, 16, 1
	v_add3_u32 v34, v34, v40, s2
	v_or_b32_e32 v35, 0x400000, v40
	v_cmp_u_f32_e64 s[4:5], v40, v40
	v_or_b32_e32 v36, 0x400000, v41
	v_or_b32_e32 v37, 0x400000, v39
	v_cndmask_b32_e64 v34, v34, v35, s[4:5]
	v_bfe_u32 v35, v41, 16, 1
	v_add3_u32 v35, v35, v41, s2
	v_cmp_u_f32_e64 s[4:5], v41, v41
	v_add3_u32 v0, v0, v4, s2
	s_nop 0
	v_cndmask_b32_e64 v35, v35, v36, s[4:5]
	v_perm_b32 v35, v35, v34, s6
	v_bfe_u32 v34, v38, 16, 1
	v_add3_u32 v34, v34, v38, s2
	v_or_b32_e32 v36, 0x400000, v38
	v_cmp_u_f32_e64 s[4:5], v38, v38
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_bfe_u32 v36, v39, 16, 1
	v_add3_u32 v36, v36, v39, s2
	v_cmp_u_f32_e64 s[4:5], v39, v39
	s_nop 1
	v_cndmask_b32_e64 v36, v36, v37, s[4:5]
	v_perm_b32 v34, v36, v34, s6
	v_add_lshl_u32 v36, v128, v1, 1
	buffer_store_dwordx2 v[34:35], v36, s[8:11], 0 offen
	v_bfe_u32 v34, v44, 16, 1
	v_add3_u32 v34, v34, v44, s2
	v_or_b32_e32 v35, 0x400000, v44
	v_cmp_u_f32_e64 s[4:5], v44, v44
	v_or_b32_e32 v36, 0x400000, v45
	v_or_b32_e32 v37, 0x400000, v43
	v_cndmask_b32_e64 v34, v34, v35, s[4:5]
	v_bfe_u32 v35, v45, 16, 1
	v_add3_u32 v35, v35, v45, s2
	v_cmp_u_f32_e64 s[4:5], v45, v45
	s_nop 1
	v_cndmask_b32_e64 v35, v35, v36, s[4:5]
	v_perm_b32 v35, v35, v34, s6
	v_bfe_u32 v34, v42, 16, 1
	v_add3_u32 v34, v34, v42, s2
	v_or_b32_e32 v36, 0x400000, v42
	v_cmp_u_f32_e64 s[4:5], v42, v42
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_bfe_u32 v36, v43, 16, 1
	v_add3_u32 v36, v36, v43, s2
	v_cmp_u_f32_e64 s[4:5], v43, v43
	s_nop 1
	v_cndmask_b32_e64 v36, v36, v37, s[4:5]
	v_perm_b32 v34, v36, v34, s6
	v_add_lshl_u32 v36, v127, v1, 1
	buffer_store_dwordx2 v[34:35], v36, s[8:11], 0 offen
	v_bfe_u32 v34, v48, 16, 1
	v_add3_u32 v34, v34, v48, s2
	v_or_b32_e32 v35, 0x400000, v48
	v_cmp_u_f32_e64 s[4:5], v48, v48
	v_or_b32_e32 v36, 0x400000, v49
	v_or_b32_e32 v37, 0x400000, v47
	v_cndmask_b32_e64 v34, v34, v35, s[4:5]
	v_bfe_u32 v35, v49, 16, 1
	v_add3_u32 v35, v35, v49, s2
	v_cmp_u_f32_e64 s[4:5], v49, v49
	s_nop 1
	v_cndmask_b32_e64 v35, v35, v36, s[4:5]
	v_perm_b32 v35, v35, v34, s6
	v_bfe_u32 v34, v46, 16, 1
	v_add3_u32 v34, v34, v46, s2
	v_or_b32_e32 v36, 0x400000, v46
	v_cmp_u_f32_e64 s[4:5], v46, v46
	s_nop 1
	v_cndmask_b32_e64 v34, v34, v36, s[4:5]
	v_bfe_u32 v36, v47, 16, 1
	v_add3_u32 v36, v36, v47, s2
	v_cmp_u_f32_e64 s[4:5], v47, v47
	s_nop 1
	v_cndmask_b32_e64 v36, v36, v37, s[4:5]
	v_perm_b32 v34, v36, v34, s6
	v_add_lshl_u32 v36, v125, v1, 1
	buffer_store_dwordx2 v[34:35], v36, s[8:11], 0 offen
	v_bfe_u32 v34, v20, 16, 1
	v_add3_u32 v34, v34, v20, s2
	v_or_b32_e32 v35, 0x400000, v20
	v_cmp_u_f32_e64 s[4:5], v20, v20
	s_nop 1
	v_cndmask_b32_e64 v20, v34, v35, s[4:5]
	v_bfe_u32 v34, v21, 16, 1
	v_add3_u32 v34, v34, v21, s2
	v_or_b32_e32 v35, 0x400000, v21
	v_cmp_u_f32_e64 s[4:5], v21, v21
	s_nop 1
	v_cndmask_b32_e64 v21, v34, v35, s[4:5]
	v_perm_b32 v21, v21, v20, s6
	v_bfe_u32 v20, v18, 16, 1
	v_add3_u32 v20, v20, v18, s2
	v_or_b32_e32 v34, 0x400000, v18
	v_cmp_u_f32_e64 s[4:5], v18, v18
	s_nop 1
	v_cndmask_b32_e64 v18, v20, v34, s[4:5]
	v_bfe_u32 v20, v19, 16, 1
	v_add3_u32 v20, v20, v19, s2
	v_or_b32_e32 v34, 0x400000, v19
	v_cmp_u_f32_e64 s[4:5], v19, v19
	s_nop 1
	v_cndmask_b32_e64 v19, v20, v34, s[4:5]
	v_perm_b32 v20, v19, v18, s6
	v_add_lshl_u32 v18, v124, v1, 1
	buffer_store_dwordx2 v[20:21], v18, s[8:11], 0 offen
	v_bfe_u32 v18, v24, 16, 1
	v_add3_u32 v18, v18, v24, s2
	v_or_b32_e32 v19, 0x400000, v24
	v_cmp_u_f32_e64 s[4:5], v24, v24
	v_or_b32_e32 v20, 0x400000, v25
	v_or_b32_e32 v21, 0x400000, v23
	v_cndmask_b32_e64 v18, v18, v19, s[4:5]
	v_bfe_u32 v19, v25, 16, 1
	v_add3_u32 v19, v19, v25, s2
	v_cmp_u_f32_e64 s[4:5], v25, v25
	s_nop 1
	v_cndmask_b32_e64 v19, v19, v20, s[4:5]
	v_perm_b32 v19, v19, v18, s6
	v_bfe_u32 v18, v22, 16, 1
	v_add3_u32 v18, v18, v22, s2
	v_or_b32_e32 v20, 0x400000, v22
	v_cmp_u_f32_e64 s[4:5], v22, v22
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v20, s[4:5]
	v_bfe_u32 v20, v23, 16, 1
	v_add3_u32 v20, v20, v23, s2
	v_cmp_u_f32_e64 s[4:5], v23, v23
	s_nop 1
	v_cndmask_b32_e64 v20, v20, v21, s[4:5]
	v_perm_b32 v18, v20, v18, s6
	v_add_lshl_u32 v20, v123, v1, 1
	buffer_store_dwordx2 v[18:19], v20, s[8:11], 0 offen
	v_bfe_u32 v18, v28, 16, 1
	v_add3_u32 v18, v18, v28, s2
	v_or_b32_e32 v19, 0x400000, v28
	v_cmp_u_f32_e64 s[4:5], v28, v28
	v_or_b32_e32 v20, 0x400000, v29
	v_or_b32_e32 v21, 0x400000, v27
	v_cndmask_b32_e64 v18, v18, v19, s[4:5]
	v_bfe_u32 v19, v29, 16, 1
	v_add3_u32 v19, v19, v29, s2
	v_cmp_u_f32_e64 s[4:5], v29, v29
	s_nop 1
	v_cndmask_b32_e64 v19, v19, v20, s[4:5]
	v_perm_b32 v19, v19, v18, s6
	v_bfe_u32 v18, v26, 16, 1
	v_add3_u32 v18, v18, v26, s2
	v_or_b32_e32 v20, 0x400000, v26
	v_cmp_u_f32_e64 s[4:5], v26, v26
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v20, s[4:5]
	v_bfe_u32 v20, v27, 16, 1
	v_add3_u32 v20, v20, v27, s2
	v_cmp_u_f32_e64 s[4:5], v27, v27
	s_nop 1
	v_cndmask_b32_e64 v20, v20, v21, s[4:5]
	v_perm_b32 v18, v20, v18, s6
	v_add_lshl_u32 v20, v122, v1, 1
	buffer_store_dwordx2 v[18:19], v20, s[8:11], 0 offen
	v_bfe_u32 v18, v32, 16, 1
	v_add3_u32 v18, v18, v32, s2
	v_or_b32_e32 v19, 0x400000, v32
	v_cmp_u_f32_e64 s[4:5], v32, v32
	v_or_b32_e32 v20, 0x400000, v33
	v_or_b32_e32 v21, 0x400000, v31
	v_cndmask_b32_e64 v18, v18, v19, s[4:5]
	v_bfe_u32 v19, v33, 16, 1
	v_add3_u32 v19, v19, v33, s2
	v_cmp_u_f32_e64 s[4:5], v33, v33
	s_nop 1
	v_cndmask_b32_e64 v19, v19, v20, s[4:5]
	v_perm_b32 v19, v19, v18, s6
	v_bfe_u32 v18, v30, 16, 1
	v_add3_u32 v18, v18, v30, s2
	v_or_b32_e32 v20, 0x400000, v30
	v_cmp_u_f32_e64 s[4:5], v30, v30
	s_nop 1
	v_cndmask_b32_e64 v18, v18, v20, s[4:5]
	v_bfe_u32 v20, v31, 16, 1
	v_add3_u32 v20, v20, v31, s2
	v_cmp_u_f32_e64 s[4:5], v31, v31
	s_nop 1
	v_cndmask_b32_e64 v20, v20, v21, s[4:5]
	v_perm_b32 v18, v20, v18, s6
	v_add_lshl_u32 v20, v121, v1, 1
	buffer_store_dwordx2 v[18:19], v20, s[8:11], 0 offen
	v_or_b32_e32 v18, 0x400000, v4
	v_cmp_u_f32_e64 s[4:5], v4, v4
	v_bfe_u32 v4, v5, 16, 1
	v_add3_u32 v4, v4, v5, s2
	v_cndmask_b32_e64 v0, v0, v18, s[4:5]
	v_or_b32_e32 v18, 0x400000, v5
	v_cmp_u_f32_e64 s[4:5], v5, v5
	s_nop 1
	v_cndmask_b32_e64 v4, v4, v18, s[4:5]
	v_perm_b32 v5, v4, v0, s6
	v_bfe_u32 v0, v2, 16, 1
	v_add3_u32 v0, v0, v2, s2
	v_or_b32_e32 v4, 0x400000, v2
	v_cmp_u_f32_e64 s[4:5], v2, v2
	v_bfe_u32 v2, v3, 16, 1
	v_add3_u32 v2, v2, v3, s2
	v_cndmask_b32_e64 v0, v0, v4, s[4:5]
	v_or_b32_e32 v4, 0x400000, v3
	v_cmp_u_f32_e64 s[4:5], v3, v3
	v_or_b32_e32 v3, 0x400000, v9
	s_nop 0
	v_cndmask_b32_e64 v2, v2, v4, s[4:5]
	v_perm_b32 v4, v2, v0, s6
	v_add_lshl_u32 v0, v120, v1, 1
	buffer_store_dwordx2 v[4:5], v0, s[8:11], 0 offen
	v_bfe_u32 v0, v8, 16, 1
	v_add3_u32 v0, v0, v8, s2
	v_or_b32_e32 v2, 0x400000, v8
	v_cmp_u_f32_e64 s[4:5], v8, v8
	v_or_b32_e32 v4, 0x400000, v7
	s_nop 0
	v_cndmask_b32_e64 v0, v0, v2, s[4:5]
	v_bfe_u32 v2, v9, 16, 1
	v_add3_u32 v2, v2, v9, s2
	v_cmp_u_f32_e64 s[4:5], v9, v9
	s_nop 1
	v_cndmask_b32_e64 v2, v2, v3, s[4:5]
	v_perm_b32 v3, v2, v0, s6
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
	v_cndmask_b32_e64 v2, v2, v4, s[4:5]
	v_perm_b32 v2, v2, v0, s6
	v_add_lshl_u32 v0, v119, v1, 1
	buffer_store_dwordx2 v[2:3], v0, s[8:11], 0 offen
	v_bfe_u32 v0, v12, 16, 1
	v_add3_u32 v0, v0, v12, s2
	v_or_b32_e32 v2, 0x400000, v12
	v_cmp_u_f32_e64 s[4:5], v12, v12
	v_or_b32_e32 v3, 0x400000, v13
	v_or_b32_e32 v4, 0x400000, v11
	v_cndmask_b32_e64 v0, v0, v2, s[4:5]
	v_bfe_u32 v2, v13, 16, 1
	v_add3_u32 v2, v2, v13, s2
	v_cmp_u_f32_e64 s[4:5], v13, v13
	s_nop 1
	v_cndmask_b32_e64 v2, v2, v3, s[4:5]
	v_perm_b32 v3, v2, v0, s6
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
	v_cndmask_b32_e64 v2, v2, v4, s[4:5]
	v_perm_b32 v2, v2, v0, s6
	v_add_lshl_u32 v0, v118, v1, 1
	buffer_store_dwordx2 v[2:3], v0, s[8:11], 0 offen
	v_bfe_u32 v0, v16, 16, 1
	v_add3_u32 v0, v0, v16, s2
	v_or_b32_e32 v2, 0x400000, v16
	v_cmp_u_f32_e64 s[4:5], v16, v16
	v_or_b32_e32 v3, 0x400000, v17
	v_or_b32_e32 v4, 0x400000, v15
	v_cndmask_b32_e64 v0, v0, v2, s[4:5]
	v_bfe_u32 v2, v17, 16, 1
	v_add3_u32 v2, v2, v17, s2
	v_cmp_u_f32_e64 s[4:5], v17, v17
	s_nop 1
	v_cndmask_b32_e64 v2, v2, v3, s[4:5]
	v_perm_b32 v3, v2, v0, s6
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
	v_cndmask_b32_e64 v2, v2, v4, s[4:5]
	v_perm_b32 v2, v2, v0, s6
	v_add_lshl_u32 v0, v115, v1, 1
	v_cmp_gt_u32_e64 s[4:5], 32, v113
	buffer_store_dwordx2 v[2:3], v0, s[8:11], 0 offen
	s_and_b64 exec, exec, s[4:5]
	s_cbranch_execz .LBB0_7
	s_mov_b32 s2, 0x800000
	v_cmp_gt_f32_e64 s[4:5], s2, v126
	v_mov_b32_e32 v0, 0x42000000
	s_nop 0
	v_cndmask_b32_e64 v1, 0, 32, s[4:5]
	v_ldexp_f32 v1, v126, v1
	v_cndmask_b32_e64 v0, 0, v0, s[4:5]
	v_log_f32_e32 v1, v1
	s_load_dwordx2 s[8:9], s[0:1], 0xc0
	s_load_dword s2, s[0:1], 0xd4
	s_load_dword s4, s[0:1], 0xdc
	v_sub_f32_e32 v0, v1, v0
	v_add_f32_e32 v0, v66, v0
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
.LBB0_7:
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
		.amdhsa_next_free_vgpr 227
		.amdhsa_next_free_sgpr 99
		.amdhsa_accum_offset 228
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

	.set .Lkernel_0.num_vgpr, 227
	.set .Lkernel_0.num_agpr, 0
	.set .Lkernel_0.numbered_sgpr, 99
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
    .sgpr_count:     105
    .sgpr_spill_count: 0
    .symbol:         kernel_0.kd
    .uniform_work_group_size: 1
    .uses_dynamic_stack: false
    .vgpr_count:     227
    .vgpr_spill_count: 0
    .wavefront_size: 64
amdhsa.target:   amdgcn-amd-amdhsa-unknown-gfx942
amdhsa.version:
  - 1
  - 2
...

	.end_amdgpu_metadata

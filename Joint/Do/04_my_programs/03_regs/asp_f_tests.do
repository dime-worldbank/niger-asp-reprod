/*
This program runs a joint F test and cross phase tests

Joint p-value 
capture p-value for model F-test

add p-value for joint test comparing coefficients 1 & 2 (C and P)
H3: Capital – Psychosocial

add p-value for joint test comparing coefficients 1 & 3 (C and F)
H2: Full - Capital (Psychosocial comp. gross ME)

add p-value for joint test comparing coefficients 2 & 3 (P and F)
H1: Full - Psychosocial (Cash grant gross ME)

across phases (FU2 only + crosstest option)


*/


capture prog drop asp_f_tests
program define asp_f_tests, rclass
	syntax, var(string) ///
			treatvar(string) ///
			strata_var(string) ///
			cluster_var(string) ///
			var_count(integer) ///
		   [interactions(string) ///
			bl_ctrl_var(string) ///
			bl_ctrl_dum(string) ///
			ctrl(string) ///
			QUIetly ///
			crosstest]
	
	nois dis as text "	- Running do-file: asp_f_tests"

	`quietly' {
	
		//-------------------------------------
		// within phase
		// capture p-value for model F-test
		qui test i1.`treatvar' = i2.`treatvar' = i3.`treatvar' = 0
			local F_test_joint : di %15.3fc `r(p)'
			qui estadd local p_val_joint = "`F_test_joint'", replace
			return local p_val_joint = "`F_test_joint'"
		
		//-------------------------------------
		// add p-value for joint test comparing coefficients 1 & 2 (C and P)
		// H3: Capital – Psychosocial
		qui lincom i1.`treatvar' - i2.`treatvar'
			local p_test_1_ph${phase_num}  : di %15.3fc `r(p)'
			local se_test_1_ph${phase_num} : di %15.2fc `r(se)'
			local b_test_1_ph${phase_num}  : di %15.2fc `r(estimate)'
			if 		`r(p)' < 0.01 local symbol "\sym{***}"
			else if `r(p)' < 0.05 local symbol "\sym{**}"
			else if `r(p)' < 0.10 local symbol "\sym{*}"
			else 				  local symbol ""
			qui estadd local b_val_1 = "`b_test_1_ph${phase_num}'`symbol'", replace
			return local b_val_1 = "`b_test_1_ph${phase_num}'`symbol'"
		
		//-------------------------------------
		// add p-value for joint test comparing coefficients 1 & 3 (C and F)
		// H2: Full - Capital (Psychosocial comp. gross ME)
		qui lincom i3.`treatvar' - i1.`treatvar'
			local p_test_2_ph${phase_num}  : di %15.3fc `r(p)'
			local se_test_2_ph${phase_num} : di %15.2fc `r(se)'
			local b_test_2_ph${phase_num}  : di %15.2fc `r(estimate)'
			if 		`r(p)' < 0.01 local symbol "\sym{***}"
			else if `r(p)' < 0.05 local symbol "\sym{**}"
			else if `r(p)' < 0.10 local symbol "\sym{*}"
			else 				  local symbol ""
			qui estadd local b_val_2 = "`b_test_2_ph${phase_num}'`symbol'", replace
			return local b_val_2 = "`b_test_2_ph${phase_num}'`symbol'"
		
		//-------------------------------------
		// add p-value for joint test comparing coefficients 2 & 3 (P and F)
		// H1: Full - Psychosocial (Cash grant gross ME)
		qui lincom i3.`treatvar' -  i2.`treatvar'
			local p_test_3_ph${phase_num}  : di %15.3fc `r(p)'
			local se_test_3_ph${phase_num} : di %15.2fc `r(se)'
			local b_test_3_ph${phase_num}  : di %15.2fc `r(estimate)'
			if 		`r(p)' < 0.01 local symbol "\sym{***}"
			else if `r(p)' < 0.05 local symbol "\sym{**}"
			else if `r(p)' < 0.10 local symbol "\sym{*}"
			else 				  local symbol ""
			qui estadd local b_val_3 = "`b_test_3_ph${phase_num}'`symbol'", replace
			return local b_val_3 = "`b_test_3_ph${phase_num}'`symbol'"
			
		forval i = 1/3 {
			foreach j in b se p {
				return local `j'_test_`i'_ph${phase_num} ``j'_test_`i'_ph${phase_num}'
			}
		}
		
		//-------------------------------------
		// across phases (FU2 only)
		if "$ph" == "fu2" & "`crosstest'" != "" {
	
			// loop again on phases to store without clustering
			foreach ph_sub_loop in 1 2 {
				qui reg `var' i.`treatvar' 	 			/// factorized treatment 
							  `interactions'   		  	/// interactions (hetero and late specs only)
							  `bl_ctrl_var'    		  	/// bl controls (wherever available)
							  `bl_ctrl_dum'    		    /// bl control dummy (ditto)
							  `ctrl'			 		/// extra controls for certain variables in main spec
							  i.`strata_var' 			/// strata F.E.
							  if phase == `ph_sub_loop' 

				estimates store est_phase`ph_sub_loop'
			}
			
			****  4.1.5a 
			// generate t-tests across phases for each treatment arm (FU2 - FU1)
			suest est_phase1 est_phase2, vce(cluster `cluster_var')
			foreach t in 1 2 3 {
				qui lincom [est_phase2_mean]i`t'.`treatvar' - [est_phase1_mean]i`t'.`treatvar'
				local p_cross_`t' : di %15.3fc `r(p)'
				qui estadd local p_cross_`t' = "`p_cross_`t''", replace : est`var_count'
				
				local b_cross_`t'  : di %15.2fc `r(estimate)'
				local se_cross_`t' : di %15.2fc `r(se)'
				
			}
						
			estimates drop est_phase1 est_phase2
			
			// return
			foreach t in 1 2 3 {
				foreach j in b se p {
					return local `j'_cross_`t' = "``j'_cross_`t''"
				}
			}
			
		}
			
	}
	
end

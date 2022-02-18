/*
This program runs F tests if the specification includes a heterogeneity dimension

*/


capture prog drop asp_f_tests_hte
program define asp_f_tests_hte, rclass
	syntax, var(string) ///
			treatvar(string) ///
			strata_var(string) ///
			cluster_var(string) ///
			var_count(integer) ///
			het_var_reg(string) ///
		   [bl_ctrl_var(string) ///
			bl_ctrl_dum(string) ///
			ctrl(string) ///
			QUIetly]
	
	nois dis as text "	- Running do-file: asp_f_tests_hte"

	`quietly' {

				// recapture p-value for model F-test
				test i1.`treatvar' = i2.`treatvar' = i3.`treatvar' = /// 
						 `het_var_reg' = ///
						 i1.treatment#`het_var_reg' = ///
						 i2.treatment#`het_var_reg' = ///
						 i3.treatment#`het_var_reg' = 0
					local F_test_joint : di %15.3fc `r(p)'
					qui estadd local p_val_joint = "`F_test_joint'", replace
				// treatment arm 1
				test i1.`treatvar' = -i1.`treatvar'#`het_var_reg'
					local F_test_1_int : di %15.3fc `r(p)'
					qui estadd local p_val_1_int = "`F_test_1_int'", replace
					return local p_val_1_int = "`F_test_1_int'"
				// treatment arm 2
				test i2.`treatvar' = -i2.`treatvar'#`het_var_reg'
					local F_test_2_int : di %15.3fc `r(p)'
					qui estadd local p_val_2_int = "`F_test_2_int'", replace
					return local p_val_2_int = "`F_test_2_int'"
				// treatment arm 3
				test i3.`treatvar' = -i3.`treatvar'#`het_var_reg'
					local F_test_3_int : di %15.3fc `r(p)'
					qui estadd local p_val_3_int = "`F_test_3_int'", replace
					return local p_val_3_int = "`F_test_3_int'"
					
					
				************* (HTE 04/07/2021) ***************
				
				// add p-value for joint test comparing coefficients 1 & 2 (C and P)
				test i1.`treatvar' + i1.`treatvar'#`het_var_reg' = i2.`treatvar' + i2.`treatvar'#`het_var_reg'
					local F_test_1_inth : di %15.3fc `r(p)'
					qui estadd local p_val_1_inth = "`F_test_1_inth'", replace
					return local p_val_1_inth = "`F_test_1_inth'"
				// add p-value for joint test comparing coefficients 1 & 3 (C and F)
				test i1.`treatvar' + i1.`treatvar'#`het_var_reg' = i3.`treatvar' + i3.`treatvar'#`het_var_reg'
					local F_test_2_inth : di %15.3fc `r(p)'
					qui estadd local p_val_2_inth = "`F_test_2_inth'", replace
					return local p_val_2_inth = "`F_test_2_inth'"
				// add p-value for joint test comparing coefficients 2 & 3 (P and F)
				test i2.`treatvar' + i2.`treatvar'#`het_var_reg' = i3.`treatvar' + i3.`treatvar'#`het_var_reg'
					local F_test_3_inth : di %15.3fc `r(p)'
					qui estadd local p_val_3_inth = "`F_test_3_inth'", replace
					return local p_val_3_inth = "`F_test_3_inth'"
					
				************* (HTE 04/07/2021) ***************
				
				
	}
	
end

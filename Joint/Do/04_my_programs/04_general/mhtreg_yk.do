/*
this program runs mhtreg regardless of size of family
created on 9/5/2020
seed currently set at 123 in master file for all regressions (9/5/2020)
maximum number of variables in family currently set at 15. Can add more if needed

Outline:
	// 1 prepare controls (treatment)
	// 2 capture family size
	// 3.1 loop through variables and assign them to locals 1 thru j
	// 3.2 and assign variable-specific controls 
	// 4 run mhtreg on three treatments 
	// 4.1 run mhtreg for each treament 
	// 4.2 collect results for each treament 
	// 4.3 concatenate results across treatments for this family

*/

pause on

capture prog drop mhtreg_yk
prog define mhtreg_yk
	syntax varlist , fam_name(string) cluster_var(string) bootstrap_loops(string)
	
	
	// 1 prepare controls (treatment)
	local do_t1 treat_1 treat_2 treat_3 i.strata
	local do_t2 treat_2 treat_3 treat_1 i.strata
	local do_t3 treat_3 treat_1 treat_2 i.strata
	
	
	// 2 capture family size
	local fam_size : word count `varlist' // get var count no quotes here
	dis as result "`fam_size' vars in `fam_name': `varlist'"
	
	
	// 3.1 loop through variables and assign them to locals 1 thru j
	// 3.2 and assign variable-specific controls 
	forval j = 1/`fam_size' { // foreach var
	
		// 3.1
		local var_`j' : word `j' of `varlist' // capture var as var_j
		
		// 3.2
		capture confirm variable `var_`j''_bl
		if _rc != 0 {
			capture confirm variable `var_`j''_trim_bl
			if (_rc != 0) local ctrls_var_`j'
			if (_rc == 0) local ctrls_var_`j' `var_`j''_trim_bl `var_`j''_trim_bl_bd
		}
		else if _rc == 0 {
			local ctrls_var_`j' `var_`j''_bl `var_`j''_bl_bd
		}
		dis as error "For `var_`j'', BL controls are: `ctrls_var_`j''"
	}
	
	// 4 run mhtreg on three treatments 
	// depending on no. of vars present
	// could be done more efficiently without capping at 15 variables
	foreach i in 1 2 3 {
	    
		// 4.1 run mhtreg for each treament 
		if `fam_size' == 1 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		if `fam_size' == 2 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2' 	`do_t`i'' 	`ctrls_var_2'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 3 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3' 	`do_t`i'' 	`ctrls_var_3'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 4 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4' 	`do_t`i'' 	`ctrls_var_4'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 5 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5' 	`do_t`i'' 	`ctrls_var_5'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 6 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6' 	`do_t`i'' 	`ctrls_var_6'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 7 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7' 	`do_t`i'' 	`ctrls_var_7'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 8 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8' 	`do_t`i'' 	`ctrls_var_8'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 9 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8'     `do_t`i'' 	`ctrls_var_8')  ///
				   (`var_9' 	`do_t`i'' 	`ctrls_var_9'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 10 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8'     `do_t`i'' 	`ctrls_var_8')  ///
				   (`var_9'     `do_t`i'' 	`ctrls_var_9')  ///
				   (`var_10' 	`do_t`i'' 	`ctrls_var_10'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 11 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8'     `do_t`i'' 	`ctrls_var_8')  ///
				   (`var_9'     `do_t`i'' 	`ctrls_var_9')  ///
				   (`var_10'    `do_t`i'' 	`ctrls_var_10')  ///
				   (`var_11' 	`do_t`i'' 	`ctrls_var_11'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 12 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8'     `do_t`i'' 	`ctrls_var_8')  ///
				   (`var_9'     `do_t`i'' 	`ctrls_var_9')  ///
				   (`var_10'    `do_t`i'' 	`ctrls_var_10')  ///
				   (`var_11'    `do_t`i'' 	`ctrls_var_11')  ///
				   (`var_12' 	`do_t`i'' 	`ctrls_var_12'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 13 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8'     `do_t`i'' 	`ctrls_var_8')  ///
				   (`var_9'     `do_t`i'' 	`ctrls_var_9')  ///
				   (`var_10'    `do_t`i'' 	`ctrls_var_10')  ///
				   (`var_11'    `do_t`i'' 	`ctrls_var_11')  ///
				   (`var_12'    `do_t`i'' 	`ctrls_var_12')  ///
				   (`var_13' 	`do_t`i'' 	`ctrls_var_13'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 14 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8'     `do_t`i'' 	`ctrls_var_8')  ///
				   (`var_9'     `do_t`i'' 	`ctrls_var_9')  ///
				   (`var_10'    `do_t`i'' 	`ctrls_var_10')  ///
				   (`var_11'    `do_t`i'' 	`ctrls_var_11')  ///
				   (`var_12'    `do_t`i'' 	`ctrls_var_12')  ///
				   (`var_13'    `do_t`i'' 	`ctrls_var_13')  ///
				   (`var_14' 	`do_t`i'' 	`ctrls_var_14'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		else if `fam_size' == 15 {
			mhtreg (`var_1' 	`do_t`i'' 	`ctrls_var_1')  ///
				   (`var_2'     `do_t`i'' 	`ctrls_var_2')  ///
				   (`var_3'     `do_t`i'' 	`ctrls_var_3')  ///
				   (`var_4'     `do_t`i'' 	`ctrls_var_4')  ///
				   (`var_5'     `do_t`i'' 	`ctrls_var_5')  ///
				   (`var_6'     `do_t`i'' 	`ctrls_var_6')  ///
				   (`var_7'     `do_t`i'' 	`ctrls_var_7')  ///
				   (`var_8'     `do_t`i'' 	`ctrls_var_8')  ///
				   (`var_9'     `do_t`i'' 	`ctrls_var_9')  ///
				   (`var_10'    `do_t`i'' 	`ctrls_var_10')  ///
				   (`var_11'    `do_t`i'' 	`ctrls_var_11')  ///
				   (`var_12'    `do_t`i'' 	`ctrls_var_12')  ///
				   (`var_13'    `do_t`i'' 	`ctrls_var_13')  ///
				   (`var_14'    `do_t`i'' 	`ctrls_var_14')  ///
				   (`var_15' 	`do_t`i'' 	`ctrls_var_15'), ///
					cluster(`cluster_var') robust bootstrap(`bootstrap_loops') seed(123)
		}
		
		// 4.2 collect results for each treament 
		mat my_res = r(results)
		mat pthm3_1_t`i' = my_res[1..`fam_size',4] // rows = fam_size, columns = 1 for thm3_1 
		mat list pthm3_1_t`i'
		matrix colnames pthm3_1_t`i' = thm3_1_t`i'

		// 4.3 concatenate results across treatments for this family
		if (`i' == 1) mat mat_`fam_name' = pthm3_1_t`i'
		if (`i' > 1)  mat mat_`fam_name' = mat_`fam_name', pthm3_1_t`i'
	}

	
end





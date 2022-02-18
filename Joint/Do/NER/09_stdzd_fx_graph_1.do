/****************************************
Household effect sizes - Figure 1
Dofile #1 in sequence

This do-file estimates effects on standardized household-level outcome variables.
This do-file is adapted from the scripts used in 
	Banerjee, et al. (2015). A multifaceted program causes lasting progress for 
	the very poor: Evidence from six countries. Science, 348(6236), 1260799.

Stata version: 15.1
Date: 11/1/2021

Outline: 
** 1) Table names
** 2) Empty matrices 
** 3) Regressions
** 4) Create dataset

*****************************************/

foreach ph in 1 2 {

	use "${joint_fold}/Data/allrounds_NER_hh.dta", clear
	keep if phase == `ph'

	** 1) Table names
	local all__std1 consum_2_day_eq_ppp_std FIES_rvrs_raw_std ///
					revs_sum_hh_wempl_std revs_sum_ben_wempl_std ///
					ment_hlth_index gse_index soc_cohsn_index ///
					ctrl_hh_index ctrl_earn_index
						
	local tables 		all__std1
	local outcomevars  `all__std1'

	keep hhid treatment strata cluster `outcomevars' *_bl *_bl_bd



	** 2) Creating empty matrices where the family-grouped standard effects will be stored for graphs
	loc matrix_count: word count `outcomevars'
	matrix hh = J(`matrix_count', 12, .)


	** 3) Regressions
	local treatvar treatment
	local cluster_var cluster
	local strata_var strata
	local strata_in_reg "i.`strata_var'"
	local special_condition ""


	loc tablecount: word count `tables'
	loc count = 1

	forvalues i = 1/`tablecount' {
		
		local table: word `i' of `tables'
		global table_name "`table'_table.txt"
		foreach var in ``table'' {

			// BL
			capture confirm variable `var'_trim_bl
			if _rc == 0 {
				local bl_ctrl_var `var'_trim_bl    
				local bl_ctrl_dum `var'_trim_bl_bd 
			}
			else if _rc != 0 {
				capture confirm variable `var'_bl
				if _rc == 0 {
					local bl_ctrl_var `var'_bl
					local bl_ctrl_dum `var'_bl_bd 
				}
			}
			else if _rc != 0 {
				local bl_ctrl_var
				local bl_ctrl_dum 
			}
			
		
			qui sum `var' if treatment==0
			loc control_mean `r(mean)'
			loc control_sd `r(sd)'
			
			qui sum `bl_ctrl_var'
			loc baseline_mean `r(mean)'
			
			qui reg `var' i.`treatvar' 	 		   /// treatment 
							`bl_ctrl_var'    	   /// bl controls (wherever available)
							`bl_ctrl_dum'    	   /// bl control dummy (ditto)
							`strata_in_reg' 	   ///
							`special_condition',   /// special condition for MRT, main
							cluster(`cluster_var') // 
			
			matrix V = e(V)
			matrix b = e(b)
			foreach t in c p f {
			
				if "`t'" == "c" local j = 2
				if "`t'" == "p" local j = 3
				if "`t'" == "f" local j = 4
				
				loc itt_`t' = b[1,`j']
				loc sd_`t' = sqrt(V[`j',`j'])
				
				loc tstat_`t' = `itt_`t''/`sd_`t''
				loc pvalue_`t' = 2*ttail(`e(df_r)', abs(`tstat_`t''))
			}
			
			loc df = `e(df_r)'
			
			mat hh[`count', 1]=`control_mean' // storing control mean
			mat hh[`count', 2]=`control_sd' // storing control standard deviation
			
			mat hh[`count', 3]=`itt_c' // storing itt_c coefficient
			mat hh[`count', 4]=`sd_c'  // storing itt_c se
			mat hh[`count', 5]=`pvalue_c' // storing p-value
			
			mat hh[`count', 6]=`itt_p' // storing itt_c coefficient
			mat hh[`count', 7]=`sd_p'  // storing itt_c se
			mat hh[`count', 8]=`pvalue_p' // storing p-value
			
			mat hh[`count', 9]=`itt_f' // storing itt_c coefficient
			mat hh[`count', 10]=`sd_f'  // storing itt_c se
			mat hh[`count', 11]=`pvalue_f' // storing p-value
			
			mat hh[`count', 12]=`df' // storing degrees of freedom
			loc ++count
		}
	}

	matrix list hh

	
	** 4) Create dataset
	gen varname = ""
	forvalues i = 1/`count' {
		loc value: word `i' of `outcomevars'
		replace varname = "`value'" if _n==`i'
	}

	svmat hh
	rename hh1 controlmean
	rename hh2 controlsd
	rename hh3 B_Treatment_c
	rename hh4 SE_Treatment_c
	rename hh5 p_value_Treatment_c
	rename hh6 B_Treatment_p
	rename hh7 SE_Treatment_p
	rename hh8 p_value_Treatment_p
	rename hh9 B_Treatment_f
	rename hh10 SE_Treatment_f
	rename hh11 p_value_Treatment_f
	rename hh12 DF

	
	keep varname controlmean controlsd B_Treatment* SE_Treatment* p_value_Treatment* DF
	keep if !mi(controlmean)
	
	
	if `ph' == 1 local longph Followup
	if `ph' == 2 local longph Followup_2
	save "${regstats_`longph'_${cty}}\outcome_matrix_hh_ner_fu`ph'.dta", replace

}







/*
This script creates matrix stat_collect that brings together regression stats:
	- pt_est
	- grp_avg
	- std_err
	- error_bar_95
	- p_val
	- fam

*/

capture prog drop asp_summary_matrix
program define asp_summary_matrix, rclass
	args my_reg fu_mat var df pap_section_n row_n_long
	
	nois dis "	- Running do-file: asp_summary_matrix"
	
	quietly {
		
		// B
		matrix pt_est = my_reg[1,1..4]
		matrix colnames pt_est = b0 b1 b2 b3
		
		// group averages
		matrix grp_avg = my_reg[1,1..4] + fu_mat // collect and adjust point estimates
		matrix colnames grp_avg = avg0 avg1 avg2 avg3
		
		// SE
		matrix std_err = (0, my_reg[2,2..4] ) // collect standard errors on 3 treatment arms only
		matrix colnames std_err = se0 se1 se2 se3
		
		// CI
		foreach i in 90 95 99 {
			
			local alpha = (1 - 0.`i') / 2		// take two-tailed probability
			local z_`i' = -invt(`df', `alpha')
			
			matrix z_`i'_mat = (`z_`i'', `z_`i'', `z_`i'', `z_`i'')
			
			matrix error_bar_`i' = z_`i'_mat' * std_err
			matrix error_bar_`i' = error_bar_`i'[1,1..4] // prepare error bars for excel plots
			matrix colnames error_bar_`i' = ci95_0 ci95_1 ci95_2 ci95_3
		}
		
		// P
		matrix p_val = (0, my_reg[4,2..4] ) // p-values
		matrix colnames p_val = p0 p1 p2 p3
		
		// MHT Family
		matrix fam = (`pap_section_n') // assign pap_section counter as family no.
		matrix colnames fam = fam
		
		
		// variable row (point estimtes, error bars)
		matrix mat_row = (pt_est, grp_avg, std_err, error_bar_95, p_val, fam)
		matrix rownames mat_row = "`var'"
				
		// prepare aggregated point estimates within each section
		if (`row_n_long' == 0) matrix stat_collect = mat_row // start matrix 
		if (`row_n_long' >  0) matrix stat_collect = stat_collect\mat_row // append 
		return matrix stat_collect = stat_collect
		
	}
	
end


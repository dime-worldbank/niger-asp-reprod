
/*
This program generates locals and adds to stored estimates (estadd)
- control mean
- control SD
- share of zeros in control (returns % as string with 0 d.p.)

BL control var is optional.


*/

capture prog drop asp_control_stats
program define asp_control_stats, rclass
	syntax varlist(max=3 numeric), [bl_ctrl_var(string) ///
									hetvar1(string) ///
									hetvar2(string) ///
									QUIetly]
	
	nois dis as text "	- Running do-file: asp_control_stats"

	`quietly' {
	
		local var `1'
		local treatvar `2'
		local reg_obs = subinstr("`3'", ",","",.) // remove comma

		
		//---------------------------------
		// control mean and SD (BL optional)
		if "`hetvar1'" == "" local ctrl_cond 
		
		qui sum `var' if `treatvar' == 0 & `reg_obs' == 1
		qui loc ctrl_mean `r(mean)'
		qui loc ctrl_sd `r(sd)'

		matrix fu_mat = (`ctrl_mean', `ctrl_mean', `ctrl_mean', `ctrl_mean')
		return mat fu_mat = fu_mat
		
		if abs(`ctrl_mean') < 0.00001 local ctrl_mean = abs(`ctrl_mean') // abs if practically zero

		foreach stat in mean sd { // round and store mean and sd
			qui loc round_`stat' : di %15.2f `ctrl_`stat''
			return loc control_`stat' `round_`stat''
			qui estadd local control_`stat' "`round_`stat''", replace
		}
		
		//---------------------------------
		// BL control mean
		if "`bl_ctrl_var'" != "" {
			qui sum `bl_ctrl_var' if `treatvar' == 0 & `reg_obs' == 1, detail
			qui loc blctrl_mean `r(mean)'
			if abs(`blctrl_mean') < 0.00001 local blctrl_mean = abs(`blctrl_mean') // abs if practically zero
			loc round_mean_bl : di %15.2f `blctrl_mean'
			qui estadd local control_mean_bl "`round_mean_bl'", replace
		}
		else {
			qui estadd local control_mean_bl " ", replace
		}
		return loc control_mean_bl `round_mean_bl'
		
		
		//---------------------------------
		// add BL control mean mark
		capture confirm variable `var'_trim_bl
		if _rc == 0 {
			 local markhere "$\approx$" // similar
		}
		else if _rc != 0 {   
			capture confirm variable `var'_bl
			if _rc == 0 {
				local markhere "\checkmark" // exact
			}
			else if _rc != 0 {
				local markhere "$\times$" // dne
			}
		}
		qui estadd local control_mean_mark "`markhere'", replace
		return loc control_mean_mark "`markhere'"
		
		
		//---------------------------------	
		// share of zeros in the control group 			
		qui count if `treatvar' == 0 & `reg_obs' == 1
		dis "`r(N)': control group size"
		local ctrl_n = "`r(N)'"

		qui count if `treatvar' == 0 & `var' == 0 & `reg_obs' == 1
		dis "`r(N)': zeros in control"
		local ctrl_zeros = "`r(N)'"

		if `ctrl_n' != 0 {
			local zero_share : di %5.0fc `ctrl_zeros'/`ctrl_n' * 100
			qui estadd local ctrl_0_share = "`zero_share'\%", replace
			return local ctrl_0_share "`zero_share'\%"
		}
		else if `ctrl_n' == 0 {
			local zero_share : di %5.0fc `ctrl_zeros'/`ctrl_n' // inf.
			qui estadd local ctrl_0_share = "`zero_share'", replace
			return local ctrl_0_share "`zero_share'"
		}
			
		
		
	}
	
end

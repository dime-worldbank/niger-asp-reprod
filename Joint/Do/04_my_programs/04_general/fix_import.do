// This program stacks latex file into single column after tex file is 
// read in using import delimited

capture prog drop fix_import 
prog define fix_import

		// but first change numerics to strings
		quietly ds, not(type string)
		foreach var in `r(varlist)' {
			tostring `var', replace
			// clear out missings
			replace `var' = "" if `var' == "." 
		}
		
		quietly ds
		local var_count : word count `r(varlist)'
		qui gen text = v1
		forval i = 2/`var_count' {
			replace text = text + "," + v`i' if v`i' != "" 
		}
		keep text
end

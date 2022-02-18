// this program runs qqvalue corrections and stacks vars appropriately


capture prog drop qqval_yk 
prog define qqval_yk
	syntax varlist, methods(string)
	
	confirm variable `1'
	dis "`1'"
	confirm variable `2'
	dis "`2'"
	dis "`methods'"
	
	// compute corrections
	levelsof `2', local(fams)
	foreach fam in `fams' {
		foreach method in `methods' {
			qqvalue `1' if `2' == `fam', method(`method') qvalue(`method'_`fam'_q) 
		}
	}
	// stack corrections
	foreach method in `methods' {
		gen `1'_`method'_q = .
	}
	foreach method in `methods' {
		ds `method'_*_q
		foreach var in `r(varlist)' {
			replace `1'_`method'_q = `var' if missing(`1'_`method'_q)		
			assert round(`1'_`method'_q, 0.0001) == round(`var', 0.0001) if !missing(`var')
		}
		drop `r(varlist)'
	}

end

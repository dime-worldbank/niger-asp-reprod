/*

This script adds MHT-corrected p-values to existing regression tables as new row

Outline:
** 1) Import MHT results	
** 2) define tables to be updated 
** 3) save p-values from mht results in locals
** 4) read latex tables generated in 06_asp_regs_new
** 5) bring in first MHT pvalue for FU1
** 6) bring in first MHT pvalue for FU2
** 7) bring back all end tabulars, adjust footnote, and save
** 8) repeat for special tables 3a and 3b

*/


pause on 
	

** 1) Import MHT results	
if 		$hpc_switch == 0 local filesuffix _testrun // bootstrap != 3000
else if $hpc_switch == 1 local filesuffix 		  // bootstrap == 3000

use rank fam_name var_name using "${regstats_Followup_2_${cty}}/mht/mht_fdr_simes.dta", clear

merge 1:1 fam_name var_name using "${regstats_Followup_2_${cty}}/mht/mht_fwer_thm3_1`filesuffix'.dta"
assert _m == 3
drop _m
merge m:1 var_name using "${regstats_Followup_2_${cty}}/mht/varnamesandlabs.dta"
assert _m == 3
drop _m

tempfile mhtresults
save 	`mhtresults' // read back in below


** 2) define tables to be updated 
local tables table_ed1 table_ed2a table_ed2b ///
			 table_ed4 table_ed5  table_ed6


foreach table in `tables' {

	if "`table'" == "table_ed1" local faminloop "fam_a1"     // 1
	if "`table'" == "table_ed2a" local faminloop "fam_b2_sethh" // 2a
	if "`table'" == "table_ed2b" local faminloop "fam_b2_setben" // 2b
// 	if "`table'" == "table_ed3" local faminloop "fam_d3_new" // 3 (see next step)
	if "`table'" == "table_ed4" local faminloop "fam_b4z"    // 4
	if "`table'" == "table_ed5" local faminloop "fam_c2z"    // 5
	if "`table'" == "table_ed6" local faminloop "fam_b10z"   // 6
	
// 	if "`table'" == "table_si6" local faminloop "fam_b8_hh"   // a6		
// 	if "`table'" == "table_si7" local faminloop "fam_d4"      // a7
// 	if "`table'" == "table_si8" local faminloop "fam_d5"      // a8
// 	if "`table'" == "table_si9a" local faminloop "fam_d3_days" // a9
// 	if "`table'" == "table_si9b" local faminloop "fam_d3_days" // a9
// 	if "`table'" == "table_si10a" local faminloop "fam_b6"    // a10a
// 	if "`table'" == "table_si10b" local faminloop "fam_b6_suppl" // a10b
// 	if "`table'" == "table_si11" local faminloop  "fam_b5"    // a11
// 	if "`table'" == "table_si12" local faminloop "fam_b4_1"   // mental health
// 	if "`table'" == "table_si13" local faminloop "fam_b4_2a"  // self-efficacy
// 	if "`table'" == "table_si14" local faminloop "fam_b4_3_1" // future expectations
// 	if "`table'" == "table_si15" local faminloop "fam_c2_2"   // financial support
// 	if "`table'" == "table_si16" local faminloop "fam_c2_1"   // social support
// 	if "`table'" == "table_si17" local faminloop "fam_b4_2b"  // social standing
// 	if "`table'" == "table_si18" local faminloop "fam_c2_5"   // social norms
// 	if "`table'" == "table_si19" local faminloop "fam_c2_3_b" // social cohesion
// 	if "`table'" == "table_si20" local faminloop "fam_c2_4"   // collective action		
// 	if "`table'" == "table_si21" local faminloop "fam_b10_5"  // controls earnings
// 	if "`table'" == "table_si22" local faminloop "fam_b10_6"  // controls resources
// 	if "`table'" == "table_si23" local faminloop "fam_c2_3_a" // intra-hh dynamics
// 	if "`table'" == "table_si24" local faminloop "fam_c1_2"   // violence perceptions


	** 3) save p-values from mht results in locals
	preserve
		use `mhtresults', clear
		keep if inlist(fam_name, "`faminloop'")
		sort rank
		
		local famname `=fam_name[1]'
		local famname = subinstr("`famname'", "fam_", "", .)
		local firstn  `=rank[1]'
		
		// collect pvalues in locals
		levelsof rank, local(vars)
		foreach var in `vars' { // rows
			local var = `var' - (`firstn' - 1)
			dis "`var'"
			foreach t in 1 2 3 { // ts
				foreach ph in fu fu2 {
					local pmht_`ph'_t`t'_var`var'_`famname' = `=p_thm3_1_`ph'_t`t'[`var']'
					local pmht_`ph'_t`t'_var`var'_`famname' : di %15.3fc `pmht_`ph'_t`t'_var`var'_`famname''
					local pmht_`ph'_t`t'_var`var'_`famname' =trim("`pmht_`ph'_t`t'_var`var'_`famname''")
					dis "pmht_`ph'_t`t'_var`var'_`famname' = `pmht_`ph'_t`t'_var`var'_`famname''"
				}
			}
		}

	restore

	
	** 4) read latex tables generated in 06_asp_regs_new
	import delimited "${joint_output_${cty}}/report_tables/vertical/interim/`table'.tex", clear	
	// concatenate tex info into one column keeping commas intact since -import- parses at commas
	fix_import	
	replace text = trim(itrim(text))

	local fu1marker "6m"
	local fu2marker "18m"
	
	
	** 5) bring in first MHT pvalue for FU1
	// remove first end tabular temporarily
	// MHT p-value will come where second end tabular is
	replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if ///
						strpos(text, "`fu1marker'") > 0 & strpos(text, "`fu2marker'") == 0 // excluding the title
	gen rank = _n
	gen fu1_vars = 1 if strpos(text, "`fu1marker'") > 0 & strpos(text, "`fu2marker'") == 0
	byso fu1_vars : egen rankfu1_vars = rank(rank) if fu1_vars != .
	sort rank
	levelsof rankfu1_vars, local(vars_n)
	foreach var in `vars_n' {
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu_t1_var`var'_`famname''{]} \end{tabular}", 1) if rankfu1_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu1marker'") > 0 & rankfu1_vars == `var'

		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu_t2_var`var'_`famname''{]} \end{tabular}", 1) if rankfu1_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu1marker'") > 0 & rankfu1_vars == `var'
		
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu_t3_var`var'_`famname''{]} \end{tabular}", 1) if rankfu1_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu1marker'") > 0 & rankfu1_vars == `var'
	}
	drop fu1_vars rankfu1_vars

	** 6) bring in first MHT pvalue for FU2
	// remove first end tabular temporarily
	// MHT p-value will come where second end tabular is
	replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if ///
						strpos(text, "`fu2marker'") > 0 & strpos(text, "`fu1marker'") == 0
	gen fu2_vars = 1 if strpos(text, "`fu2marker'") > 0 & strpos(text, "`fu1marker'") == 0
	byso fu2_vars : egen rankfu2_vars = rank(rank) if fu2_vars != .
	sort rank
	
	levelsof rankfu2_vars, local(vars_n)
	foreach var in `vars_n' {
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu2_t1_var`var'_`famname''{]} \end{tabular}", 1) if rankfu2_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu2marker'") > 0 & rankfu2_vars == `var'

		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu2_t2_var`var'_`famname''{]} \end{tabular}", 1) if rankfu2_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu2marker'") > 0 & rankfu2_vars == `var'
		
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu2_t3_var`var'_`famname''{]} \end{tabular}", 1) if rankfu2_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu2marker'") > 0 & rankfu2_vars == `var'
	}
	drop fu2_vars rankfu2_vars


	** 7) bring back all end tabulars, adjust footnote, and save
	replace text = subinstr(text, "sillytemp", "end{tabular}", .) 
	
	local mhtnote "Two-tailed p-values are also shown in parentheses, followed by MHT-adjusted p-values shown in square brackets (see table SI.5 for correction details)."
	
	// add new MHT footnote (econ outcomes)
	replace text = subinstr(text, "All monetary amounts", ///
			"`mhtnote' All monetary amounts", ///
			1) // one instance
			
	// add new MHT footnote (indices)
	replace text = subinstr(text, "All indices are standardized", ///
			"`mhtnote' All indices are standardized", ///
			1) // one instance
	
	keep text
	outfile using "${joint_output_${cty}}/report_tables/vertical/`table'_mht.tex", noquote wide replace

}




****************************************
** 8) repeat for special tables 3a and 3b
// similar process as above

foreach l in a b { // newa and newb

	import delimited "${joint_output_${cty}}/report_tables/vertical/interim/table_ed3`l'.tex", clear	
	// concatenate tex info into one column keeping commas intact since -import- parses at commas
	fix_import	
	replace text = trim(itrim(text))
	
	// get var names. ps to be imported from mhtresults
	gen varcount = _n if strpos(text, "multirow[t]") > 0 // varnames contain "multirow[t]"
	levelsof varcount, local(varlocs)
	qui count if varcount != .
	local varcount `r(N)'
	forval i = 1/`varcount' {
		local j : word `i' of `varlocs'
		local texthere = text in `j'
		local starthere = strlen("\multirow[t]{2}{4em}{") + 1
		local endhere = strpos("`texthere'", "&") - 2
		local varlab_`i' = substr(text, `starthere', `endhere' - `starthere') in `j'
// 		dis "varlab_`i' = `varlab_`i''"
		local varlist `varlist' varlab_`i'
	}
	dis "`varlist'"
	drop varcount

	preserve

		use `mhtresults', clear
		gen keep = .
		foreach var in `varlist' {
			dis "``var''"
			replace keep = 1 if strpos(var_lab, "``var''") > 0
			replace keep = . if strpos(var_lab, "(HH)") > 0
		}
		count if keep == 1
		assert `r(N)' == `varcount'

		keep if keep == 1
		sort rank
		
		// rank vars by order of varlab_`i'
		drop rank 
		gen rank = .
		local i 1
		foreach var in `varlist' {
			gen thisvar = _n if strpos(var_lab, "``var''") > 0
			levelsof thisvar, local(adjustrankhere)
			replace rank = `i' in `adjustrankhere'
			local i = `i' + 1
			drop thisvar
		}
		sort rank
		
		replace fam_name = "fam_d3_new`l'"
		local famname `=fam_name[1]'
		local famname = subinstr("`famname'", "fam_", "", .)
		local firstn  `=rank[1]'

		// collect pvalues in locals
		levelsof rank, local(vars)
		foreach var in `vars' { // rows
			local var = `var' - (`firstn' - 1)
			dis "`var'"
			foreach t in 1 2 3 { // ts
				foreach ph in fu fu2 {
					local pmht_`ph'_t`t'_var`var'_`famname' = `=p_thm3_1_`ph'_t`t'[`var']'
					local pmht_`ph'_t`t'_var`var'_`famname' : di %15.3fc `pmht_`ph'_t`t'_var`var'_`famname''
					local pmht_`ph'_t`t'_var`var'_`famname' =trim("`pmht_`ph'_t`t'_var`var'_`famname''")
					dis "pmht_`ph'_t`t'_var`var'_`famname' = `pmht_`ph'_t`t'_var`var'_`famname''"
				}
			}
		}

	restore

	
	// bring in first MHT pvalue for FU1
	// remove first end tabular temporarily
	// MHT p-value will come where second end tabular is
	replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if ///
						strpos(text, "`fu1marker'") > 0 & strpos(text, "`fu2marker'") == 0
	gen rank = _n
	gen fu1_vars = 1 if strpos(text, "`fu1marker'") > 0 & strpos(text, "`fu2marker'") == 0
	byso fu1_vars : egen rankfu1_vars = rank(rank) if fu1_vars != .
	sort rank
	levelsof rankfu1_vars, local(vars_n)
	foreach var in `vars_n' {
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu_t1_var`var'_`famname''{]} \end{tabular}", 1) if rankfu1_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu1marker'") > 0 & rankfu1_vars == `var'

		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu_t2_var`var'_`famname''{]} \end{tabular}", 1) if rankfu1_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu1marker'") > 0 & rankfu1_vars == `var'
		
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu_t3_var`var'_`famname''{]} \end{tabular}", 1) if rankfu1_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu1marker'") > 0 & rankfu1_vars == `var'
	}
	drop fu1_vars rankfu1_vars

	
	// bring in first MHT pvalue for FU2
	// remove first end tabular temporarily
	// MHT p-value will come where second end tabular is
	replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if ///
						strpos(text, "`fu2marker'") > 0 & strpos(text, "`fu1marker'") == 0
	gen fu2_vars = 1 if strpos(text, "`fu2marker'") > 0 & strpos(text, "`fu1marker'") == 0
	byso fu2_vars : egen rankfu2_vars = rank(rank) if fu2_vars != .
	sort rank
	
	levelsof rankfu2_vars, local(vars_n)
	foreach var in `vars_n' {
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu2_t1_var`var'_`famname''{]} \end{tabular}", 1) if rankfu2_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu2marker'") > 0 & rankfu2_vars == `var'

		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu2_t2_var`var'_`famname''{]} \end{tabular}", 1) if rankfu2_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu2marker'") > 0 & rankfu2_vars == `var'
		
		replace text = subinstr(text, "\end{tabular}", "\\ {[}`pmht_fu2_t3_var`var'_`famname''{]} \end{tabular}", 1) if rankfu2_vars == `var'
		replace text = subinstr(text, "end{tabular}", "sillytemp", 1) if strpos(text, "`fu2marker'") > 0 & rankfu2_vars == `var'
	}
	drop fu2_vars rankfu2_vars
	

	// bring back all end tabulars
	replace text = subinstr(text, "sillytemp", "end{tabular}", .) 
	
	// add new MHT footnote
	replace text = subinstr(text, "All monetary amounts", ///
			"`mhtnote' All monetary amounts", ///
			1) // one instance

	keep text
	outfile using "${joint_output_${cty}}/report_tables/vertical/table_ed3`l'_mht.tex", noquote wide replace

}

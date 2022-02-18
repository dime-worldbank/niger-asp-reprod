/* 11_cba_plot

This script generates "fig2_asp_avgs_irr" a bar plot showing IRR numbers that 
are also shown in table ed7.

Outline: 
** 1) set up space
** 2) import CBA treatment effects from cba stats 
** 3) import stats from "report_stats/cba_teststats.tex"
** 4) update space
** 5) list variables to be plotted
** 6) plot options
** 6.1) colors (RGB) 
** 6.2) footnote 
** 6.3) override some options
** 7) plot and export 
** 7.1) tif, png
** 7.2) EPS without footnote

*/

clear

** -----------------------------------------------------------------------------
** 1) set up space
foreach var in var_lab var_name section {
	gen `var' = ""
}
foreach var in avg ci95_ p {
    forval i = 0/3 {
		gen `var'`i' = .
	}
}


** -----------------------------------------------------------------------------
** 2) import CBA treatment effects from cba stats 
local pos = _N
insobs 1
replace var_lab = "Benefit/cost ratio\n (observed impact after 18 months,\n 100% dissipation thereafter)" if _n == `pos' + 1
replace var_name = "cba1" if _n == `pos' + 1

local pos = _N
insobs 1
replace var_lab = "Benefit/cost ratio\n (observed impact after 18 months,\n 50% dissipation thereafter)" if _n == `pos' + 1
replace var_name = "cba2" if _n == `pos' + 1

// local pos = _N
// insobs 1
// replace var_lab = "Benefit/cost ratio\n (observed impact after 18 months,\n 25% dissipation thereafter)" if _n == `pos' + 1
// replace var_name = "cba3" if _n == `pos' + 1

replace section = "g35_cba"  if strpos(var_lab, "Benefit/cost ratio") > 0


// bring in IRR treatment effects
local pos = _N
insobs 1
replace var_lab = "Assuming dissipation of\n 100% after endline" if _n == `pos' + 1
replace var_name = "irr1" if _n == `pos' + 1
local pos = _N
insobs 1
replace var_lab = "Assuming dissipation of\n 50% after endline" if _n == `pos' + 1
replace var_name = "irr2" if _n == `pos' + 1
// 	local pos = _N
// 	insobs 1
// 	replace var_lab = "Assuming dissipation of\n 25% after endline" if _n == `pos' + 1
// 	replace var_name = "irr3" if _n == `pos' + 1
replace section = "g36_irr"  if strpos(var_lab, "Assuming dissipation") > 0


gen rank = _n, before(var_lab)
byso section : egen varcount = count(rank)
order varcount, after (section)
sort rank


** -----------------------------------------------------------------------------
** 3) import stats from "report_stats/cba_teststats.tex"
preserve
	import delimited "${joint_output_${cty}}/report_stats/cba_teststats.tex", clear
	keep if strpos(v1, "\mu") > 0 | 	  /// keep averages
			strpos(v1, "\p") > 0 | 		  /// keep pvalues
			strpos(v1, "\lbnf") > 0 | 	  /// keep lowerbounds
			strpos(v1, "\irr") > 0 	   	  //  keep irr
	keep if strpos(v1, "Year")     > 0 |  /// keep yearly assmptn
			strpos(v1, "Yrffty")   > 0 |  /// keep yearly assmptn w/ 50% dissipation
			strpos(v1, "Yrtwtyfv") > 0    //  keep yearly assmptn w/ 25% dissipation
	drop if strpos(v1, "JYear")     > 0 | /// drop joint stuff
			strpos(v1, "JYrffty")   > 0 | ///
			strpos(v1, "JYrtwtyfv") > 0

	split v1, parse ("{")
	drop v1
	replace v12 = subinstr(v12, "}", "", .)
	replace v11 = subinstr(v11, "\newcommand\", "", .)
	gen v13 = v12 if strpos(v12, "\%") > 0
	replace v13 = subinstr(v13, "\%", "", .)
	destring v13, replace 
	replace v13 = v13/100
	replace v12 = "" if strpos(v12, "\%") > 0
	destring v12, replace 
	replace v12 = v13 if v12 == .
	drop v13
	replace v11 = subinstr(v11, "C", "1", .)
	replace v11 = subinstr(v11, "P", "2", .)
	replace v11 = subinstr(v11, "F", "3", .)
	replace v11 = subinstr(v11, "mu", "avg", .)
	
	
// 		dis ""
	forval i = 1/`=_N' { 
		local name `"`=v11[`i']'"'
		local val  `"`=v12[`i']'"'
		local `name' = `val'
		dis "`name' = ``name''"
	}
restore


** -----------------------------------------------------------------------------
** 4) update space
// fill in control group
foreach var in avg ci95_ p {
	replace `var'0 = 0 if `var'0 == .
}
// fill in treatment groups
foreach t in 1 2 3 {
	foreach var in avg ci95_ p {
		foreach stub in Year Yrffty { // Yrtwtyfv
			if 		"`stub'" == "Year"     local stubtext "100"
			else if "`stub'" == "Yrffty"   local stubtext "50"
			else if "`stub'" == "Yrtwtyfv" local stubtext "25"

			if "`var'" == "ci95_" {
				local ci95_`t' =  `avg`t'`stub'' - `lbnf`t'`stub'' // ci95_ = avg - lower bd
				replace ci95_`t' = `ci95_`t'' if ci95_`t' == . & strpos(var_lab, "`stubtext'") > 0 & ///
												strpos(var_lab, "Assuming dissipation") == 0
				
// 				dis "irr`t'`stub' = `irr`t'`stub''"
// 				dis "irr_ll`t'`stub' = `irr_ll`t'`stub''"

				local ci95_`t' // no SE for now
// 				local ci95_`t' =  `irr`t'`stub'' - `irrll`t'`stub'' // ci95_ = avg - lower bd
// 				replace ci95_`t' = `ci95_`t'' if ci95_`t' == . & strpos(var_lab, "`stubtext'") > 0
			}
			else if "`var'" == "avg" {
				replace avg`t' = `avg`t'`stub'' if avg`t' == . & ///
												strpos(var_lab, "`stubtext'") > 0 & ///
												strpos(var_lab, "Assuming dissipation") == 0
												
				replace avg`t' = `irr`t'`stub'' if avg`t' == . & strpos(var_lab, "`stubtext'") > 0 & ///
												strpos(var_lab, "Assuming dissipation") > 0
			}
			else if "`var'" == "p" {
				replace p`t' = `p`t'`stub''     if p`t' == . & ///
												strpos(var_lab, "`stubtext'") > 0 & ///
												strpos(var_lab, "Assuming dissipation") == 0
												
// 				replace p`t' = `irrp`t'`stub'' if p`t' == . & strpos(var_lab, "`stubtext'") > 0 & ///
// 				 								  strpos(var_lab, "Internal rate of return") > 0
			}
		}
	}
}

// scale up to get %
foreach var of varlist avg* {
	replace `var' = `var' * 100 if strpos(var_name, "irr") > 0
}



** ---------------------------------------------------------------------------
** 5) list variables to be plotted
local g36_irr irr1 irr2



** ---------------------------------------------------------------------------
** 6) plot options

** 6.1) colors (RGB) 
local dark 0


if `dark' == 1 {
	// dark background following ASP theme
	local color_bkgrd "76 77 76" 			// grey background in example graph
	local color_t0    `" "147 149 147" "'	// grey bar: control
	local color_t1    `" "0 112 192" "' 	// blue bar: capital
	local color_t2    `" "0 176 80" "' 		// green bar: psychosocial
	local color_t3    `" "255 214 53" "' 	// yellow bar: full
	local treatcolors `" `color_t0' `color_t1' `color_t2' `color_t3' "' // must match no. of treatments
}
else {
	// bright background: monochrome
	local color_bkgrd "255 255 255" // platinum background in example graph
	local color_t0    `" "228 228 228" "'	// light gray bar: control
	local color_t1    `" "189 189 189" "' 	// smoke bar: capital
	local color_t2    `" "69 69 69" "' 		// charcoal bar: psychosocial
	local color_t3    `" "10 10 10" "' 	//  bar: Full
	local treatcolors `" `color_t0' `color_t1' `color_t2' `color_t3' "' // must match no. of treatments
}


** 6.2) footnote 
// This note is too long and leaves the page
#d ;
loc gr_note "
	  "Notes: We calculate internal rates of return using the annual cost and benefit data shown in Extended Data"
	  "Table 7."
";
#d cr
foreach lcl in gr_note {
	mata: st_local("`lcl'", stritrim(st_local("`lcl'")))
}



** 6.3) override some options
local ytitle "Internal Rate of Return (%)"
local new_range_high "5 percent over avg" // add % to range for nice spacing
local override_stars_offset "10" // % of range
local leg `"`" 2 "Capital" 3 "Psychosocial" 4 "Full" "'"'




** -----------------------------------------------------------------------------
** 7) plot and export 
** 7.1) tif, png
local count_graphs 0

plot_avgs, papsec(g36_irr) ///
		   papsecvars(`g36_irr') ///
		   count(`count_graphs') ///
		   bkgcolor(`color_bkgrd') /// 
		   tcolors(`"`treatcolors'"') ///
		   darktheme(`dark') ///
		   my_ytitle("`ytitle'") ///
		   override_ygrid("`override_ygrid'") ///
		   override_stars_offset("`override_stars_offset'") ///
		   override_xrows("3") ///
		   d_drop("`drop_d_here'") ///
		   my_title("`title'") ///
		   combine_phases /// this option combines graphs and aligns y-axis ranges across phases
		   barlabels barpercent /// barpercent converts bar labels to percentage points
		   leg(`leg') ///
		   gr_note(`"`gr_note'"') ///
		   percent_changes /// {1,2,3} against zero
			   percent_change_base(avg) ///
			   percent_change_not("index Indice") ///
		   savefilename("asp_avgs_`list'") ///
		   qui

local grphsz 5 6 // -gtstyle-
foreach fmt in tif png {
	qui graph export "${joint_output_${cty}}/report_graphs/fig2_asp_avgs_irr.`fmt'", ///
		as(`fmt') height(1500) width(1875) replace	
}



** 7.2) EPS without footnote
local count_graphs 0
plot_avgs, papsec(g36_irr) ///
		   papsecvars(`g36_irr') ///
		   count(`count_graphs') ///
		   bkgcolor(`color_bkgrd') /// 
		   tcolors(`"`treatcolors'"') ///
		   darktheme(`dark') ///
		   my_ytitle("`ytitle'") ///
		   override_ygrid("`override_ygrid'") ///
		   override_stars_offset("`override_stars_offset'") ///
		   override_xrows("3") ///
		   d_drop("`drop_d_here'") ///
		   my_title("`title'") ///
		   combine_phases /// this option combines graphs and aligns y-axis ranges across phases
		   barlabels barpercent /// barpercent converts bar labels to percentage points
		   leg(`leg') ///
		   percent_changes /// {1,2,3} against zero
			   percent_change_base(avg) ///
			   percent_change_not("index Indice") ///
		   savefilename("asp_avgs_`list'") ///
		   qui

foreach fmt in eps {
	qui graph export "${joint_output_${cty}}/report_graphs/fig2_asp_avgs_irr.`fmt'", ///
		as(`fmt') replace mag(800)
}



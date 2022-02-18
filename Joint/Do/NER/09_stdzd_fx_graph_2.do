/****************************************
Household effect size graphs - Figure 1
Dofile #2 in sequence

This do-file creates the effect-size graph for Figure 1.
This do-file is adapted from the scripts used in 
	Banerjee, et al. (2015). A multifaceted program causes lasting progress for 
	the very poor: Evidence from six countries. Science, 348(6236), 1260799.

Stata version: 15.1
Household-level variables
Stata version: 15.1
Date: 11/1/2021

Outline: 
** 1) variable descriptions 
** 2) import and reshape outcomes dta 
** 3) Set dimensions and order of variables
** 3.1) export table in excel for reference
** 4) prepare eclplot options
** 5) run eclplot (tif and png)
** 5.1) run eclplot (EPS without footnote)

*****************************************/
set graphics on // must be "on" to export in high-res .tif format



** 1) collect variable descriptions from asp_013_label_vars_ner.do
use "${regstats_${phase}_${cty}}\outcome_matrix_hh_ner_fu2.dta", clear
local varnames // initiate empty var
forval i = 1/`=_N' {
	local varname
	local varname `"`=varname[`i']'"'
	local varnames : list varnames | varname
}

clear
insobs 1
foreach var in `varnames' {
	gen `var' = . // create empty vars just to label them
}
asp_013_label_vars_ner, section("mht") // label vars
asp_013_label_vars_ner, section("fx_graph") // label vars


foreach var in `varnames' {
	local lab : var label `var' // dep var label
	local varname "`var'"
	preserve
		clear
		insobs 1
		qui gen varname = "`varname'"
		qui gen var_lab = "`lab'"
	
		tempfile `var'_names
		save 	``var'_names'
		dis "varnames = ``var'_names'"
	restore
}
// start with some var and append others to create datset of labels
local first_var : word 1 of `varnames'
dis "`first_var'"
use "``first_var'_names'", clear 
foreach var in `varnames' {
	append using "``var'_names'"
}
duplicates drop
replace var_lab = subinstr(var_lab, "\n", "", .)

tempfile varnamesandlabs
save `varnamesandlabs', replace



** 2) import and reshape data
use "${regstats_${phase}_${cty}}\outcome_matrix_hh_ner_fu2.dta", clear
append using "${regstats_Followup_${cty}}\outcome_matrix_hh_ner_fu1.dta", gen(ph)
replace ph = 2 if ph == 0
label define phase 1 "FU 1" 2 "FU 2"
label values ph phase 

gen rank = _n
merge m:1 varname using `varnamesandlabs', gen(_mvarnamlab)
asser _mvarnamlab == 3
drop _mvarnamlab
order var_lab, first
sort rank
drop rank


// Create varnames equal to the family of outcome in which each variable belongs

local primary consum_2_day_eq_ppp_std FIES_rvrs_raw_std ///
			  revs_sum_hh_wempl_std revs_sum_ben_wempl_std
local psych   ment_hlth_index ///
			  gse_index /// future_expct_30_index
			  soc_cohsn_index /// fin_supp_index_2 social_support_index soc_stand_index soc_norms_index collective_action_index  ///
			  ctrl_earn_index ///
			  ctrl_hh_index // revs_sum_bohh_wempl intrahh_vars_index dom_relation_index

loc section_names ""Economic Outcomes" "Psychosocial and Women's Empowerment Outcomes""
loc sections  primary psych //  



// reshape to stack capital, psych, full
rename *_c *_1
rename *_p *_2
rename *_f *_3
gen varname_ph = varname + "_" + string(ph)
reshape long B_Treatment_ SE_Treatment_ p_value_Treatment_, i(varname_ph) j(treat)
label define t 1 "Capital arm" 2 "Psychosocial arm" 3 "Full arm"
label values t t
order t, after(controlsd)
rename *_ *

levelsof treat, local(ts)

gen area = ""


** 3) Set dimensions and order of variables
gen area_num = .
gen order = .
gen outcome_order = .
gen t_num = .

loc area_order 1
loc var_order 1
loc areacount: word count `sections'
forvalues i = 1/`areacount' {
	
	loc outcome_order 1
	
	loc area_num `i'
	loc name: word `i' of `section_names'
	loc section: word `i' of `sections'
	
	foreach var in ``section'' {
		loc t_order 1
		
		replace area = "`name'" if varname=="`var'" // area of graph name
		replace area_num = `area_num' if varname=="`var'" // area of graph number
		replace order = `var_order' if varname=="`var'" // order overall
		replace outcome_order = `outcome_order' if varname=="`var'" // order within area
		
		loc ++var_order
		loc ++outcome_order
		foreach t in `ts' {
			dis "`t'"
			replace t_num = `t_order' if varname=="`var'" & treat==`t'
			loc ++t_order
		}
	}
}
drop if area == ""

assert treat == t_num 
drop t_num
sort order treat ph
replace order = order * 3




** 3.1) export table in excel for reference
export excel var_lab varname controlmean controlsd treat B_Treatment ///
			 SE_Treatment p_value_Treatment DF ph area ///
			 using "${joint_output_${cty}}/report_stats/standardized_fx_ner2.xls", ///
			 firstrow(variables) replace




* Create horizontal lines between sections
isid area_num outcome_order treat ph // must be unique ID, code will break if this is not the case
# de ;
lab de area_num 
1 "Economic Outcomes" 
2 "Psychosocial and Women's Empowerment Outcomes" 
;
# de cr
lab values area_num area_num

// create space between sections
loc add_n 1
loc n 0
loc i 0
while `++i' <= _N {
dis "i = `i'"
	if area[`i'] != area[`i' - 1] {
		loc ++n
		
		if `add_n' == 1 {
			local neworder1 `=order[`i']'

			set obs `=_N + 1'
			replace order = order + 1 if _n >= `i'
			replace order = `neworder1' in L
		
			// horizontal line location
			loc line_move_up 1.5
// 			loc ln`n' = cond(`i' == 1, 1.2, order[`i']) - `line_move_up'
			loc ln`n' = order[`i'] - `line_move_up'
			
			loc i = `i' + 1
		}
		local neworder1 `=order[`i']'
		local neworder2 `=order[`i']' + 1

		if `add_n' == 2 {
			set obs `=_N + 2'
			replace order = order + 2 if _n >= `i'
			replace order = `neworder1'	in `=_N - 1'
			replace order = `neworder2' in L
		
			// horizontal line location
			loc line_move_up 1.5
			loc ln`n' = cond(`i' == 1, 2.2, order[`i'] - 0.7) - `line_move_up'
			
			loc i = `i' + 2
		}

		loc add_n = `add_n' + 1
		sort order

	}
}

dis "`ln1'"
dis "`ln2'"
assert `n'==`areacount'



** 4) prepare eclplot options
foreach clear in lxs rxs textadd yline posclr negclr nsclr color msymbol estopts ciopts ///
	compltext comprtext inf opts labelstext_lu labelstext_ld labelstext_ln labelstext_ru ///
	labelstext_rd labelstext_rn rangel ranger midpoint outliervar {
	loc `clear'
}
loc areacount: word count `sections'
* Generating upper and lower confidence intervals for each outcome variable
gen norm_CL_Treatment = B_Treatment - invttail(DF, .05) * SE_Treatment
gen norm_CU_Treatment = B_Treatment + invttail(DF, .05) * SE_Treatment

* Interpretation of significance (to be used for color-coding graph)
gen inference = ""
replace inference = "Positive impact" if B_Treatment > 0 & ///
	p_value_Treatment < .1
replace inference = "Negative impact" if B_Treatment < 0 & ///
	p_value_Treatment < .1
replace inference = "Not significant" if p_value_Treatment >= .1
encode inference, gen(inference_num)

* Creating scale for x-axis, width based on upper and lower bounds of min and max
sum norm_CL_Treatment
loc lxs = min(r(min), -0.3)
sum norm_CU_Treatment
loc rxs = max(r(max), .45)

* Area titles (-text()-)
loc textadd text(
forv i = 1/`areacount' {
	loc text_move_down -0.2
	loc p = `ln`i'' + `line_move_up' + `text_move_down' // text comes just below line
	loc textadd `textadd' `p' `lxs' "`:lab area_num `i''"
}
loc textadd `textadd', margin(small) place(1) just(left) color(black))

* Horizontal lines (-yline()-)
loc yline yline(
forv i = 1/`areacount' {
	loc yline `yline' `ln`i''
}
loc yline `yline', lcolor(gs4) lpattern(solid))

* patterns for significance
loc posclr solid
loc negclr solid
loc nsclr dashed // "ns" for "not significant"


* Assigning patterns to treatment-phase group
sort order treat ph
egen treat_phase = group(treat ph)
tab treat_phase
* -estopts#()- and -ciopts#()-
forv i = 1/`r(r)' {
	loc lab`i' : lab treat_phase `i'
	
	if `lab`i'' == 1 {
		loc color gs12 // capital FU1
		loc patt dot
		loc symbol Oh
	}
	else if `lab`i'' == 2 {
		loc color gs12 // capital FU2
		loc patt solid
		loc symbol O
	}
	else if `lab`i'' == 3 {
		loc color gs7 // psych FU1
		loc patt dot
		loc symbol Oh
	}
	else if `lab`i'' == 4 {
		loc color gs7 // psych FU2
		loc patt solid
		loc symbol O
	}
	else if `lab`i'' == 5 {
		loc color gs0 // full FU1
		loc patt dot
		loc symbol Oh
	}
	else if `lab`i'' == 6 {
		loc color gs0 // full FU2
		loc patt solid
		loc symbol O
	}
	else {
		di as err "invalid inference_num value label"
		ex 9
	}

	loc ciopts  `ciopts' ciopts`i'(msymbol(i) lpattern(`patt') lcolor(`color')) // lwidth(thick)
	loc estopts `estopts' estopts`i'(msymbol(`symbol') mcolor(`color') msize(small))
}


// dis `"`estopts'"'
// dis `"`ciopts'"'


* Added text
// get lowest bound from 3 treatments
byso var_lab : egen norm_CL_Treatment_min = min(norm_CL_Treatment)
// stop //
replace var_lab = "" if inlist(treat, 1, 3) | ph == 2

loc compltext " "
loc comprtext " "
forv j = 1/`=_N' {
	if var_lab[`j'] != "" {
		loc d = cond(norm_CL_Treatment[`j'] - ///
			length(var_lab[`j']) / 140 > `lxs', "l", "r")
	dis "for j = `j', `=var_lab[`j']' d = `d'"

		#d ;
		loc inf =
			cond(inference[`j'] == "Positive impact",  "u",
			cond(inference[`j'] == "Negative impact",  "d",
			cond(inference[`j'] == "Not significant",  "n", "")))
		;
		#d cr
		assert "`inf'" != ""
		if `=norm_CL_Treatment_min[`j']' < 0 {		
			loc labelstext_`d'`inf' `labelstext_`d'`inf'' ///
						`=order[`j'] + 0.1' /// y position of text (order 1 = top)
						`=norm_CL_Treatment_min[`j']' /// x position of text (lower bound)
						"`=var_lab[`j']'"
		}
		else {
			loc labelstext_`d'`inf' `labelstext_`d'`inf'' ///
						`=order[`j'] + 0.1' /// y position of text (order 1 = top)
						-0.02 /// x position of text (lower bound)
						"`=var_lab[`j']'"
		}
		
		
	}
}
local textsize small

* `labelstext_l?'
loc opts margin(right) place(9) just(right) align(bottom) size(`textsize')
loc labelstext_lu `labelstext_lu', color(black) `opts'
loc labelstext_ld `labelstext_ld', color(black) `opts'
loc labelstext_ln `labelstext_ln', color(black) `opts'

dis "compltext = `compltext'"
dis "opts = `opts'"
dis `"`labelstext_lu'"'
dis `"`labelstext_ld'"'
dis `"`labelstext_ln'"'

* `labelstext_r?'
loc opts margin(left) place(9) just(left) align(bottom) size(`textsize')
loc labelstext_ru `labelstext_ru', color(black) `opts'
loc labelstext_rd `labelstext_rd', color(black) `opts'
loc labelstext_rn `labelstext_rn', color(black) `opts'

dis "comprtext = `comprtext'"
dis "opts = `opts'"
dis `"`labelstext_ru'"'
dis `"`labelstext_rd'"'
dis `"`labelstext_rn'"'



loc num = 2 // figure 2

loc gtitle // Figure `num': Intent-to-Treat Estimates for Main Outcomes

#d ;
loc caption "
	"Notes: This figure summarizes treatment effects presented in Extended Data 
	 Tables. It shows treatment effects on main outcomes," 
	 "standardized with respect to the control group for ease of interpretation. Results presented 
	 are OLS estimates that include controls for" 
	 "randomization strata and, where possible, baseline outcomes. Each line shows the OLS point
	 estimate and 95% confidence intervals"
	 "corresponding to standard errors clustered at the village-level. Dotted lines show results 6 months 
	 post-intervention. Solid lines show"
	 "results 18 months post-intervention."
	 ";
#d cr
foreach lcl in gtitle caption {
	mata: st_local("`lcl'", stritrim(st_local("`lcl'")))
}
// dis "`caption'"
// stop
graph drop _all
sort order treat ph

// adjust order variable to stack vars by 
// byso varname treat : egen rank = rank(ph)
// sort order treat ph
// forval i = 1/`=_N' {
// 	insobs
// }
// separate treatment arms by
local septreat 0.2
replace order = order + 1 * `septreat' if treat == 2
replace order = order + 2 * `septreat' if treat == 3


** 5) run eclplot (tif and png)
eclplot B_Treatment norm_CL_Treatment norm_CU_Treatment order, /// order is parmid var
	supby(treat_phase, spaceby(0.3)) ///  super-impose by cat: inference_num 
	`estopts' /// symbol and color for pt est (must follow supby)
	`ciopts'  /// pattern and color for CIs (must follow supby)
	horizontal /// plot horizontal
	rplottype(rcapsym) /// appearance of CI
	plotregion(style(none) color(white)) /// plot deets
	graphregion(style(none) color(white)) /// graph deets
	scale(0.7) ///
	caption(`caption', size(small)) /// caption align(top) 
	legend(off) /// leg
	ytitle("") yscale(noline) ylab(none, noticks) /// y-axis
	xtitle("Effect size in standard deviations of the control group", ///
		margin(small) color(gs3)) /// x-axis
	xscale(range(`lxs'/`rxs') lcolor(gs3)) ///
	xlab(#15, labcolor(gs3) format(%9.2f) nogrid) ///
	`yline' /// vline
	xline(0 `midpoint', /// hline
			lpattern(dash) ///
			lwidth(vthin) ///
			lcolor(gs8*1.2)) /// 
	`textadd' /// added text (area titles)
	text(`labelstext_lu') text(`labelstext_ld') ///
	text(`labelstext_ln') text(`labelstext_ru') /// 
	text(`labelstext_rd') text(`labelstext_rn') ///
	text(5 0.39 "midline", color(black) place(3) size(small)) ///
	text(5 0.44 "endline", color(black) place(3) size(small)) ///
	text(6 0.485 "Capital arm", color(black) place(3) size(small)) ///
	text(6 0.415  "o", color(gs12) size(small)) ///
	text(6 0.46 "{&bull}", color(gs12) size(large)) ///
	text(7 0.485 "Psychosocial arm", color(black) place(3) size(small)) ///
	text(7 0.415  "o", color(gs7) size(small)) ///
	text(7 0.46 "{&bull}", color(gs7) size(large)) ///
	text(8 0.485 "Full arm", color(black) place(3) size(small)) ///
	text(8 0.415  "o", color(gs0) size(small)) ///
	text(8 0.46 "{&bull}", color(gs0) size(large)) //


foreach fmt in tif png {
	qui graph export "${joint_output_${cty}}/report_graphs/fig1_stdzd_fx.`fmt'", ///
		as(`fmt') replace	 height(1300) width(1600)
}
graph close



** 5.1) run eclplot (EPS without footnote)
eclplot B_Treatment norm_CL_Treatment norm_CU_Treatment order, /// order is parmid var
	supby(treat_phase, spaceby(0.3)) ///  super-impose by cat: inference_num 
	`estopts' /// symbol and color for pt est (must follow supby)
	`ciopts'  /// pattern and color for CIs (must follow supby)
	horizontal /// plot horizontal
	rplottype(rcapsym) /// appearance of CI
	plotregion(style(none) color(white)) /// plot deets
	graphregion(style(none) color(white)) /// graph deets
	scale(0.7) ///
	legend(off) /// leg
	ytitle("") yscale(noline) ylab(none, noticks) /// y-axis
	xtitle("Effect size in standard deviations of the control group", ///
		margin(small) color(gs3)) /// x-axis
	xscale(range(`lxs'/`rxs') lcolor(gs3)) ///
	xlab(#15, labcolor(gs3) format(%9.2f) nogrid) ///
	`yline' /// vline
	xline(0 `midpoint', /// hline
			lpattern(dash) ///
			lwidth(vthin) ///
			lcolor(gs8*1.2)) /// 
	`textadd' /// added text (area titles)
	text(`labelstext_lu') text(`labelstext_ld') ///
	text(`labelstext_ln') text(`labelstext_ru') /// 
	text(`labelstext_rd') text(`labelstext_rn') ///
	text(5 0.39 "midline", color(black) place(3) size(small)) ///
	text(5 0.44 "endline", color(black) place(3) size(small)) ///
	text(6 0.485 "Capital arm", color(black) place(3) size(small)) ///
	text(6 0.415  "o", color(gs12) size(small)) ///
	text(6 0.46 "{&bull}", color(gs12) size(large)) ///
	text(7 0.485 "Psychosocial arm", color(black) place(3) size(small)) ///
	text(7 0.415  "o", color(gs7) size(small)) ///
	text(7 0.46 "{&bull}", color(gs7) size(large)) ///
	text(8 0.485 "Full arm", color(black) place(3) size(small)) ///
	text(8 0.415  "o", color(gs0) size(small)) ///
	text(8 0.46 "{&bull}", color(gs0) size(large)) //


foreach fmt in eps {
	qui graph export "${joint_output_${cty}}/report_graphs/fig1_stdzd_fx.`fmt'", ///
		as(`fmt') replace mag(1000) // height(1300) width(1600)
}
graph close


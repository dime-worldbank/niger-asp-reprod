/*

This script prepares table SI 28 showing psychosocial effects and costs
created: 11/19/2021
version 15.1

Outline: 
** 1) import costs from cost-benefit table
** 2) calculate cost per case of depression averted
** 2.1) get treatment effect on percent of depression cases averted within group
** 2.2) total cases averted across phases and cost effectiveness
** 3) DALYs averted
** 4) Treatment effect on SD life satisfaction
** 5) generate latex output

*/

** 1) import costs from cost-benefit table
import excel "${git_dir}/Baseline/cost_benefit/NER/ASPP_Productive_costing_Niger_2020.xlsx", ///
	sheet("4.1 CBA (ed7)") cellrange(C5:G16) firstrow clear

rename Programadministration text	
rename D control
rename E C
rename F P
rename G F

// COSTS (treatment-specific) from ASPP excel sheet
gen rank = _n if strpos(text, "Total costs") > 0 & strpos(text, "year 0") > 0
levelsof rank, local(here)
foreach t in C P F {
	
	if "`t'" == "C" loc num 1
	if "`t'" == "P" loc num 2
	if "`t'" == "F" loc num 3
	
	// value at year 0
	local c`num'_0  = `=`t'[`here']'
	dis `c`num'_0'
	
	// present value at year 2
	local c`num' = `c`num'_0' * (1.05)^2 
}

	// depressed_11 depressed_13 // (scenarios)
	local var depressed_13

		
local keepvars `var'* strata cluster hhid phase treatment stair_satis_today*
use `keepvars' using "${joint_fold}/Data/allrounds_NER_hh.dta", clear
rename phase ph


** 2) calculate cost per case of depression averted
foreach ph in 1 2 {

	** 2.1) get treatment effect on percent of depression cases averted within group
	reg `var' i.treatment `var'_bl `var'_bl_bd i.strata if ph == `ph'

	estimates store estim_`ph'

	matrix my_reg = r(table)
	matrix pt_est = my_reg[1,1..4]
	local b_1_`ph' = pt_est[1,2] // capital
	local b_2_`ph' = pt_est[1,3] // psych
	local b_3_`ph' = pt_est[1,4] // full
	
	foreach t in 1 2 3 {
		qui count if treatment == `t' & e(sample) == 1
		local n_`t' = `r(N)'
		local casesaverted_`t'_`ph' : di %9.0fc -`b_`t'_`ph'' * `n_`t''
		dis "Cases averted = `casesaverted_`t'_`ph''" // lower than quick estimate
	}
}
qui suest estim_1 estim_2, cluster(cluster)

** 2.2) total cases averted across phases and cost effectiveness
foreach t in 1 2 3 {
	if "`t'" == "1" loc text Capital
	if "`t'" == "2" loc text Psychosocial
	if "`t'" == "3" loc text Full

	local tot_averted_`t' : di %9.0fc `casesaverted_`t'_1' + `casesaverted_`t'_2'	
	local tot_b = `b_`t'_1' + `b_`t'_2'
// 	dis "tot_b = `tot_b' = `b_`t'_1' + `b_`t'_2'"
	
	local costpercase_`t' : di %9.0fc `c`t'_0' / -`tot_b' // `tot_averted'
	
	local c`t'_0dis : di %9.2fc `c`t'_0'
	
// 	if `t' == 1 dis "Treatment*costs*cases averted*Cost per case"
	dis "tot_averted = `tot_averted_`t''"
	dis "costpercase = `costpercase_`t''"
	

}

  
** 3) DALYs averted
foreach t in 1 2 3 {
	dis ""
	foreach ph in 1 2 {
		local yld_`t'_`ph' = `casesaverted_`t'_`ph''*0.145*0.5 
		local yld_`t'_`ph'_share = `casesaverted_`t'_`ph''*0.145*0.5 / `n_`t''
	}
	
	// cost of aggregate YLD
	local cost_p_yld_`t' = `c`t'_0' / (`yld_`t'_1_share' + `yld_`t'_2_share')
	dis "cost_p_yld_`t' = `cost_p_yld_`t''"

	local yld_`t' : dis %9.2fc `yld_`t'_1' + `yld_`t'_2'
	local cost_p_yld_`t' : di %9.0fc `cost_p_yld_`t''
	
}


drop if ph == 1 // get rid of phase 


** 4) Treatment effect on SD life satisfaction
qui {
local var stair_satis_today

// FU2
qui sum `var' if treatment==0
replace `var' = (`var' - `r(mean)')/`r(sd)'

// BL
capture confirm variable `var'_trim_bl
if _rc == 0 {
	qui sum `var'_trim_bl if treatment==0
	replace `var'_trim_bl = (`var'_trim_bl - `r(mean)')/`r(sd)'
	local bl_ctrl_var `var'_trim_bl    
	local bl_ctrl_dum `var'_trim_bl_bd 
}
else if _rc != 0 {
	capture confirm variable `var'_bl
	if _rc == 0 {
		qui sum `var'_bl if treatment==0
		replace `var'_bl = (`var'_bl - `r(mean)')/`r(sd)'
		local bl_ctrl_var `var'_bl    
		local bl_ctrl_dum `var'_bl_bd 
	}
}
else if _rc != 0 {
	local bl_ctrl_var     
	local bl_ctrl_dum 
}
}

areg stair_satis_today i.treatment ///
	stair_satis_today_bl stair_satis_today_bl_bd ///
	if ph == 2, ///
	absorb(strata) cluster(cluster)
	
foreach t in 1 2 3 {
	local b_ls`t' = _b[i`t'.treatment]
	local c_bls`t' = `c`t'_0' / `b_ls`t'' * 0.1
	
	local b_ls`t' : di %9.3fc `b_ls`t''
	local c_bls`t' : di %9.0fc `c_bls`t''
	local c`t'_0 : di %9.0fc `c`t'_0'
	
	dis "b_ls`t' = `b_ls`t''"
	dis "c_bls`t' = `c_bls`t''"
}

nlcom `c3_0' / _b[i3.treatment] * 0.1 - /// full
	  `c2_0' / _b[i2.treatment] * 0.1 // psych

nlcom `c3_0' / _b[i3.treatment] * 0.1 - /// full
	  `c1_0' / _b[i1.treatment] * 0.1 // capital

nlcom `c1_0' / _b[i1.treatment] * 0.1 - /// capital
	  `c2_0' / _b[i2.treatment] * 0.1 // psych


** 5) generate latex output

local line1  "\begin{table}[htbp]\centering"
local line2  "\fontsize{8}{10}\selectfont"
local line3  "\caption{Supplementary Table SI.28: Costs and Psychosocial Effects}"
local line4  "\label{tab:table_si28}"
local line5  "\begin{tabular}{lrrr}"
local line6     "\hline\hline"
local line7     "Treatment group & Capital & Psychosocial & Full \\ \cmidrule(lr){2-4}"
local line8     "Year 0 cost per beneficiary (USD 2016) 						& `c1_0' & `c2_0'  & `c3_0' \\ [1ex]"
local line9     "Life satisfaction (year 2)	 								& & & \\ "
local line10 	"\hspace{0.25cm} Treatment effect in standard deviations 		& `b_ls1' & `b_ls2' & `b_ls3' \\ "
local line11 	"\hspace{0.25cm} Cost per 0.1 standard deviations (USD 2016) 	& `c_bls1' & `c_bls2' & `c_bls3' \\ [1ex]"
local line12    "Depression (years 1 \& 2) 										& & & \\ "
local line13 	"\hspace{0.25cm} No. of depression cases averted 	 			& `tot_averted_1' & `tot_averted_2' & `tot_averted_3' \\ "
local line14 	"\hspace{0.25cm} Cost per case of depression averted (USD 2016) & `costpercase_1' & `costpercase_2' & `costpercase_3' \\ [1ex]"
local line15    "\hline \hline"
local line16 "\end{tabular}"
local line17 "\addvbuffer[3pt 0pt]{"
local line18    "\begin{tabular}{p{0.75\textwidth}}"
local line19        "\footnotesize \textit{Notes:}  "   
#delimit ;
local line20         "Depressive symptoms were assessed with the CES-D-10 
					  screening tool \parencite{radloff1977ces} and a score of 13 or more on 
					  a 0-30 point scale was considered high risk for depression 
					  \parencite{baron2017validation}. We use the 
					  benchmark of 0.10 SD given it is the meta-analytic effect 
					  of economic interventions on psychological well-being 
					  \parencite{romeroeffect2021}."
					  ;
#delimit cr
local line21     "\end{tabular}"
local line22 "}"
local line23 "\end{table}"

clear
gen text = ""
forval i = 1/23 {
	insobs 1
	local line`i' = trim(itrim("`line`i''"))
	local line`i' = subinstr("`line`i''", "$", "\\$", .)
	replace text = "`line`i''" if text == ""
}

outfile using "${joint_output_${cty}}/report_tables/table_si28.tex", noquote wide replace		




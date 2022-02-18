/* 
This script prepares benefit/cost ratios following tables ED7 and SI27.
This script also generates two tex files: one to hold latex variables 
	and another representing table 28x (not presented anywhere).

Outline
** 1) import cost data from Excel
** 2) linearly transform the treatment effect on consumption into benefit/cost ratio
** 2.1) export stats for use in Excel
** 2.2) calculate weights in B/C linear transformation
** 2.3) run tests to calculate B/C ratio
** 2.3.1) bring in IRR data from Excel
** 2.4) test for equivalence in consumption TE between arms
** 2.5) prepare tex file of variables
** 3) Repeat for pooled treatment 
** 3.1) update tex file of variables
** 4) Export texfile
** 5) Export equivalence tests

*/


pause on
	
** -----------------------------------------------------------------------------
** 1) import cost data from Excel
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
	
	// value at year 0
	local c`t'_0 = `=`t'[`here']'
	dis `c`t'_0'
	
	// present value at year 2
	local c`t' = `c`t'_0' * (1.05)^2 
}


	
** -----------------------------------------------------------------------------
** 2) linearly transform the treatment effect on consumption into benefit/cost ratio
local assumptions yearly yrlyd monthly monthlyd yrly_dissp50 yrly_dissp25

foreach assume in `assumptions' { // tables ED7 and SI27 respectively
	
	if "`assume'" == "yearly"  	 	local asm Year
	if "`assume'" == "yrlyd"  	 	local asm Yeard
	if "`assume'" == "monthly" 		local asm Mnth
	if "`assume'" == "monthlyd"  	local asm Mnthd
	if "`assume'" == "yrly_dissp50" local asm Yrffty // because can't use numeric in latex variable name
	if "`assume'" == "yrly_dissp25" local asm Yrtwtyfv
	
cls
local keepvars hhid treatment cluster strata equiv_n ///
	consum_2_day_eq_??? consum_2_day_eq_???_trim_bl consum_2_day_eq_???_trim_bl_bd ///
	consum_2_year_ppp consum_2_year_ppp_trim_bl consum_2_year_ppp_trim_bl_bd 
	
use phase `keepvars' using "${joint_fold}/Data/allrounds_NER_hh.dta", clear


** ----------------------------------
** 2.1) export stats for use in Excel
foreach ph in 1 2 {
	
	qui reg consum_2_day_eq_xof i.treatment ///
							consum_2_day_eq_xof_trim_bl ///
							consum_2_day_eq_xof_trim_bl_bd ///
							i.strata ///
							if phase == `ph'
	foreach t in 1 2 3 {
		local b`t'_ph`ph'_xof = _b[i`t'.treatment]
	}
}



local regvar consum_2_day_eq_ppp
local bl_controls consum_2_day_eq_ppp_trim_bl consum_2_day_eq_ppp_trim_bl_bd
// only for this assumption, change the regression
if "`assume'" == "yrlyd" | "`assume'" == "monthlyd" { 
	local regvar consum_2_year_ppp 
	local bl_controls consum_2_year_ppp_trim_bl consum_2_year_ppp_trim_bl_bd
}

// run regressions again at each phase this time
// storing covariance b/n fu1 & 2. cluster comes later
foreach ph in 1 2 {
	
	qui reg `regvar' i.treatment ///
							`bl_controls' ///
							i.strata ///
							if phase == `ph'
							
	estimates store estim_`ph'
}
qui suest estim_1 estim_2, cluster(cluster)


// collect 95% conf. bounds on treatment coefs.
mat sueststats = r(table)
foreach ph in 1 2 {
	foreach t in 1 2 3 {
		if `t' == 1 local tr "C"
		if `t' == 2 local tr "P"
		if `t' == 3 local tr "F"
		foreach cb in ll ul {	
			mat `cb'_`tr'_`ph' = sueststats["`cb'", "estim_`ph'_mean:`t'.treatment"]
			local `cb'_`tr'_`ph' = `cb'_`tr'_`ph'[1,1]
			dis "At phase `ph', `cb' for t = `tr' --> `cb'_`tr'_`ph' = ``cb'_`tr'_`ph''"
		}
		if `ph' == 2 {
			mat   b_`tr'_`ph' = sueststats["b", "estim_`ph'_mean:`t'.treatment"]
			local b_`tr'_`ph' = b_`tr'_`ph'[1,1]
			dis "beta at phase `ph', treatment `t' = `b_`tr'_`ph''"
		}
	}
}

// test equivalence on linear combination of the betas 
// using treatment-specific costs and phase-specific demographics below

// export stats for use in Excel
if "`assume'" == "yearly" {
	sum equiv_n if phase == 1
	local adulteq_1 `r(mean)'
	sum equiv_n if phase == 2
	local adulteq_2 `r(mean)'

	putexcel set "${git_dir}/Baseline/cost_benefit/NER/cba_stats", replace

		putexcel A1 = "Stata output. See explore_cba_new.do for code"
		
		putexcel A3 = "FU1"
		putexcel B3 = "FU2"

		putexcel A4 = `adulteq_1'
		putexcel B4 = `adulteq_2'
		putexcel C4 = "Adult equivalents"
		
		// USD
		putexcel A5 = [estim_1_mean]i1.treatment
		putexcel B5 = [estim_2_mean]i1.treatment
		putexcel C5 = "Capital treatment effect on consumption per adult eq. per day (USD 2016 PPP)"

		putexcel A6 = [estim_1_mean]i2.treatment
		putexcel B6 = [estim_2_mean]i2.treatment
		putexcel C6 = "Psychosocial treatment effect on consumption per adult eq. per day (USD 2016 PPP)"

		putexcel A7 = [estim_1_mean]i3.treatment
		putexcel B7 = [estim_2_mean]i3.treatment
		putexcel C7 = "Full treatment effect on consumption per adult eq. per day (USD 2016 PPP)"
		
		// XOF
		putexcel A9 = `b1_ph1_xof'
		putexcel B9 = `b1_ph2_xof'
		putexcel C9 = "Capital treatment effect on consumption per adult eq. per day (FCFA 2016 PPP)"

		putexcel A10 = `b2_ph1_xof'
		putexcel B10 = `b2_ph2_xof'
		putexcel C10 = "Psychosocial treatment effect on consumption per adult eq. per day (FCFA 2016 PPP)"

		putexcel A11 = `b3_ph1_xof'
		putexcel B11 = `b3_ph2_xof'
		putexcel C11 = "Full treatment effect on consumption per adult eq. per day (FCFA 2016 PPP)"
		
	putexcel close
}
if "`assume'" == "yrlyd" { 

	putexcel set "${git_dir}/Baseline/cost_benefit/NER/cba_stats", modify
		
		// USD
		// pooled outputs in row 13
		putexcel A15 = [estim_1_mean]i1.treatment
		putexcel B15 = [estim_2_mean]i1.treatment
		putexcel C15 = "Capital treatment effect on consumption HH yearly (USD 2016 PPP)"

		putexcel A16 = [estim_1_mean]i2.treatment
		putexcel B16 = [estim_2_mean]i2.treatment
		putexcel C16 = "Psychosocial treatment effect on consumption HH yearly  (USD 2016 PPP)"

		putexcel A17 = [estim_1_mean]i3.treatment
		putexcel B17 = [estim_2_mean]i3.treatment
		putexcel C17 = "Full treatment effect on consumption HH yearly  (USD 2016 PPP)"

	putexcel close
}



** ----------------------------------
** 2.2) calculate weights in B/C linear transformation
if "`assume'" == "yearly" {
	// these weights translate daily benefits per beneficiary to
	// yearly benefits per household in net present value at year 2
	foreach t in C P F {
		//             (phase-specific demographics)
		//             adult/hh * days/yr* 0.5 (b/c @ month 6) * 1+discount rate
		local w1_`t' = `adulteq_1' * 365 * 0.5 * 1.05 / `c`t'' // 2019
		local w2_`t' = `adulteq_2' * 365 / `c`t'' 			  // 2020
		dis "weights = `w1_`t'' & `w2_`t''"
		
		// IRR weights
		local w1_`t'_irr = `adulteq_1' * 365 * 0.5 // 2019
		local w2_`t'_irr = `adulteq_2' * 365 	  // 2020
		dis "IRR weights = `w1_`t'_irr' & `w2_`t'_irr'"
	}
}
else if "`assume'" == "yrlyd" { 

	foreach t in C P F {
		// already at yearly HH level
		local w1_`t' = 1 * 0.5 * 1.05 / `c`t'' // 2019 
		local w2_`t' = 1 / `c`t'' 			  // 2020
	}
}
else if "`assume'" == "monthly" {
	// these weights translate daily benefits per beneficiary to
	// monthly benefits per household in net present value at year 2

	local L1 = 0 // initiate vars here and below because they are cumulative
	local L2 = 0 
	local L3 = 0 

	// But first, calculate NPVs as linear tranformation, L1, L2, and L3 (see intro)
	local rate = 0.05 / 12 // month discount factor at 5% yearly
	forval i = 1/6 {
		local L1 = `L1' + `i'/(6*(1+`rate')^`i') // scalarized NPV calc for yr1
	}
	forval i = 7/18 {
		local l2_sum = (1-(`i'-6)/12)/((1+`rate')^`i') // scalarized NPV. yr2 part 1
		local l3_sum =   ((`i'-6)/12)/((1+`rate')^`i') // scalarized NPV. yr2 part 2
		local L2 = `L2' + `l2_sum' 
		local L3 = `L3' + `l3_sum' 
	}

	foreach t in C P F {
		// (1) scale L-weights to year 2 to match year costs are in
		// (2) multiply by no. of adult eqs (FCFA/day/adult eq -> FCFA/day)
		// (3) multiply by days/month    	(FCFA/day          -> FCFA/month)
		// (4) divide by costs to get single scalar value (wi)
		
		//							   (1)      (2)      (3)      (4)
		local w1_`t' = (`L1' + `L2') *1.05^2 * `adulteq_1' * 30.4167 / `c`t''  
		local w2_`t' =        (`L3') *1.05^2 * `adulteq_2' * 30.4167 / `c`t'' 
		dis "weights = `w1_`t'' & `w2_`t''"
	}
}
else if "`assume'" == "monthlyd" {
	// calcalate weights in B/C linear transformation
	// these weights translate daily benefits per beneficiary to
	// monthly benefits per household in net present value at year 2

	local L1 = 0 // initiate vars here and below because they are cumulative
	local L2 = 0 
	local L3 = 0 

	// But first, calculate NPVs as linear tranformation, L1, L2, and L3 (see intro)
	local rate = 0.05 / 12 // month discount factor at 5% yearly
	forval i = 1/6 {
		local L1 = `L1' + `i'/(6*(1+`rate')^`i') // scalarized NPV calc for yr1
	}
	forval i = 7/18 {
		local l2_sum = (1-(`i'-6)/12)/((1+`rate')^`i') // scalarized NPV. yr2 part 1
		local l3_sum =   ((`i'-6)/12)/((1+`rate')^`i') // scalarized NPV. yr2 part 2
		local L2 = `L2' + `l2_sum' 
		local L3 = `L3' + `l3_sum' 
	}

	foreach t in C P F {
		// (1) scale L-weights to year 2 to match year costs are in
		// (2) multiply by 1/12 (FCFA/year -> FCFA/month)
		// (3) divide by costs to get single scalar value (wi)
		
		//							   (1)      (2)      (3)      (4)
		local w1_`t' = (`L1' + `L2') *1.05^2 / (12 *`c`t'' ) 
		local w2_`t' =        (`L3') *1.05^2 / (12 *`c`t'' ) 
		dis "weights = `w1_`t'' & `w2_`t''"
	}

}
else if "`assume'" == "yrly_dissp50" | "`assume'" == "yrly_dissp25" {
	// calcalate weights in B/C linear transformation
	// these weights translate daily benefits per beneficiary to
	// yearly benefits per household in net present value at year 2
	// including dissipation effects 
	local A1 = `adulteq_1' * 365 * 0.5 * 1.05 
	local A2 = `adulteq_2' * 365
		
	// set summation limit as point where incremental diff becomes negligible
	foreach t in C P F {

		// initiate values
		local bA_`t' = `b_`t'_2' * `A2' // HH level TE at year 2
		local n = 1 // sum limit. Increase this until diff is negligible
		if 		"`assume'" == "yrly_dissp50" local dssp = 0.5 // dissipation rate
		else if "`assume'" == "yrly_dissp25" local dssp = 0.25 // dissipation rate
		local diff = 1 // diff
		local Ldssp = 0 // reset this as it updates for each treatment arm

		while `diff' > 0.0001 { // when diff falls below 1 ten thousandth of 1 USD
			local diff = `bA_`t''*((1-`dssp')^`n'-(1-`dssp')^(`n'+1))
			dis "still in loop because diff = `diff', n = `n'"
			dis `bA_`t''*(1-`dssp')^`n' // nominal cash flow at t=n 
			dis `bA_`t''*(1-`dssp')^(`n'+1) // nominal cash flow at t=n+1
			local n = `n'+1 // increment n
		}
		dis "left loop. n is now `n' (time periods before diff is negligible)"

		// calculate NPV for dissipation series using the n determined above
		local rate_yrly = 0.05 // 5% yearly discount factor
		forval i = 1/`n' {
			// scalarized NPV calc for dissipation after yr2
			local Ltemp = ((1-`dssp')^`i')/((1+`rate_yrly')^`i')
			local Ldssp = `Ldssp' + `Ltemp'
		}

		// (1) scale L-weights to year 2 to match year costs are in
		// (2) multiply by no. of adults (FCFA/day/adult -> FCFA/day)
		// (3) multiply by days/month    (FCFA/day       -> FCFA/month)
		// (4) divide by costs to get single scalar value (wi)
		
		//             (phase-specific demographics)
		//             adult/hh * days/yr* 0.5 (b/c @ month 6) * 1+discount rate
		local w1_`t' =  `A1' / `c`t'' // 2019
		local w2_`t' = (`A2' / `c`t'') * (1 + `Ldssp') // 2020
		dis "weights = `w1_`t'' & `w2_`t''"
	}
}


** 2.3) run tests to calculate B/C ratio
foreach t in C P F {
	if "`t'" == "C" local i 1
	if "`t'" == "P" local i 2
	if "`t'" == "F" local i 3

	// 	lincom [estim_1_mean]i`i'.treatment + [estim_2_mean]i`i'.treatment 
	** -----> 1: CI on B/C ratio for each treatment 
	lincom `w1_`t''*[estim_1_mean]i`i'.treatment + `w2_`t''*[estim_2_mean]i`i'.treatment - 1 // H0: B/C ratio == 1
	
	qui loc mu`t'`asm'_orig : di %5.3fc `r(estimate)'
	qui loc se`t'`asm'_orig : di %5.3fc `r(se)'
	qui loc z`t'`asm'_orig : di %5.3fc `r(z)'
	qui loc p`t'`asm'_orig : di %5.3fc `r(p)'
	
	
	
	lincom `w1_`t''*[estim_1_mean]i`i'.treatment + `w2_`t''*[estim_2_mean]i`i'.treatment      // H0: B/C ratio == 0
	
	qui loc mu`t'`asm' : di %5.2fc `r(estimate)'
	qui loc se`t'`asm' : di %5.2fc `r(se)'
	qui loc z`t'`asm' : di %5.2fc `r(z)'
	qui loc p`t'`asm' : di %5.3fc `r(p)' // added on 3/4/2021
		
	qui loc lbnf`t'`asm' : di %5.2fc `r(lb)'
	qui loc ubnf`t'`asm' : di %5.2fc `r(ub)'
// 	dis as error "95% CI for `t' treatment = (`lbnf`t'`asm'', `ubnf`t'`asm'')"
	local lbn`t'`asm' : di %5.2fc `r(estimate)'- 1.645*`r(se)'
	local ubn`t'`asm' : di %5.2fc `r(estimate)'+ 1.645*`r(se)'
// 	dis as error "90% CI for `t' treatment = (`lbn`t'', `ubn`t'')"
	
	foreach stat in mu se p lbn ubn lbnf ubnf {
		if 		"`stat'" != "p"  qui loc `stat'`t'`asm' = ``stat'`t'`asm'' * 100
		
		if      "`stat'" == "se" qui loc `stat'`t'`asm' : di %5.1fc ``stat'`t'`asm''
		else if "`stat'" == "p"  qui loc `stat'`t'`asm' : di %5.4fc ``stat'`t'`asm''
		else 					 qui loc `stat'`t'`asm' : di %5.0fc ``stat'`t'`asm''
	}	
	dis "for treatment `t', mean = `mu`t'`asm''%, se = `se`t'`asm''%, p = `p`t'`asm''%, lb = `lbnf`t'`asm''%, ub = `ubnf`t'`asm''%"
	
	** linearly extrapolated bounds based on CI bounds on beta
	foreach stat in ll ul {
		local `stat'`t'`asm' = `w1_`t'' * ``stat'_`t'_1' + `w2_`t'' * ``stat'_`t'_2'
		local `stat'`t'`asm' = 100 * ``stat'`t'`asm''
		local `stat'`t'`asm' : di %5.0fc ``stat'`t'`asm''
	}
	
}


		** -----------------------------------
		** 2.3.1) bring in IRR data from Excel
		import excel "${git_dir}/Baseline/cost_benefit/NER/ASPP_Productive_costing_Niger_2020.xlsx", ///
			sheet("4.1 CBA (ed7)") cellrange(C64:G69) firstrow clear

		rename InternalrateofreturnIRR text	
		rename D control
		rename E C
		rename F P
		rename G F
		
		
		if "`asm'" == "Year" local dissrate 100 
		if "`asm'" == "Yrffty" local dissrate 50 
		if "`asm'" == "Yrtwtyfv" local dissrate 25
		gen rank = _n if strpos(text, "`dissrate'%") > 0
		levelsof rank, local(here)
		foreach t in C P F {
			loc irr`t'`asm' = `=`t'[`here']'
			loc irr`t'`asm' = `irr`t'`asm'' * 100
			loc irr`t'`asm' : di %5.3fc `irr`t'`asm''
// 			dis "irr`t'`asm' = `irr`t'`asm''"
		}
		drop rank

		
** 2.4) test for equivalence in consumption TE between arms
** -----> test for whether w1_c*b1_c + w2_c*b2_c = w1_p*b1_p+ w2_p*b2_p
// 							      B/C ratio capital = B/C ratio psycho

	lincom (`w1_C'*[estim_1_mean]i1.treatment + `w2_C'*[estim_2_mean]i1.treatment) - /// capital B/C ratio
		   (`w1_P'*[estim_1_mean]i2.treatment + `w2_P'*[estim_2_mean]i2.treatment)    // psycho  B/C ratio
	
	if      `r(p)' < 0.01 dis as error "p(B/C ratio for Capital = Psychosocial) = `r(p)' ***"
	else if `r(p)' < 0.05 dis as error "p(B/C ratio for Capital = Psychosocial) = `r(p)' **"
	else if `r(p)' < 0.1  dis as error "p(B/C ratio for Capital = Psychosocial) = `r(p)' *"
	
	local lincom_CP_b`asm' : di %5.3fc `r(estimate)'
	local lincom_CP_se`asm' : di %5.3fc `r(se)'
	local lincom_CP_z`asm' : di %5.3fc `r(z)'
	local lincom_CP_`asm' : di %5.3fc `r(p)'


** -----> test for whether w1_c*b1_c + w2_c*b2_c = w1_f*b1_f+ w2_f*b2_f
// 							   B/C ratio capital = B/C ratio full
	lincom (`w1_F'*[estim_1_mean]i3.treatment + `w2_F'*[estim_2_mean]i3.treatment) - /// full    B/C ratio
		   (`w1_C'*[estim_1_mean]i1.treatment + `w2_C'*[estim_2_mean]i1.treatment)    // capital B/C ratio

	if      `r(p)' < 0.01 dis as error "p(B/C ratio for Capital = Full) = `r(p)' ***"
	else if `r(p)' < 0.05 dis as error "p(B/C ratio for Capital = Full) = `r(p)' **"
	else if `r(p)' < 0.1  dis as error "p(B/C ratio for Capital = Full) = `r(p)' *"

	local lincom_CF_b`asm' : di %5.3fc `r(estimate)'
	local lincom_CF_se`asm' : di %5.3fc `r(se)'
	local lincom_CF_z`asm' : di %5.3fc `r(z)'
	local lincom_CF_`asm' : di %5.3fc `r(p)'

** -----> test for whether w1_p*b1_p + w2_p*b2_p = w1_f*b1_f+ w2_f*b2_f
// 							   B/C ratio psycho  = B/C ratio full
	lincom (`w1_F'*[estim_1_mean]i3.treatment + `w2_F'*[estim_2_mean]i3.treatment) - /// full   B/C ratio
		   (`w1_P'*[estim_1_mean]i2.treatment + `w2_P'*[estim_2_mean]i2.treatment)    // psycho B/C ratio

	if      `r(p)' < 0.01 dis as error "p(B/C ratio for Psychosocial = Full) = `r(p)' ***"
	else if `r(p)' < 0.05 dis as error "p(B/C ratio for Psychosocial = Full) = `r(p)' **"
	else if `r(p)' < 0.1  dis as error "p(B/C ratio for Psychosocial = Full) = `r(p)' *"

	local lincom_PF_b`asm' : di %5.3fc `r(estimate)'
	local lincom_PF_se`asm' : di %5.3fc `r(se)'
	local lincom_PF_z`asm' : di %5.3fc `r(z)'
	local lincom_PF_`asm' : di %5.3fc `r(p)'

	
dis as error "pause here to display CI and t-tests for each treatment arm. Type q to continue to the pooled results"
dis as error "`assume'"


** 2.5) prepare tex file of variables
preserve
	clear
	qui gen text = ""
	** general stats
	qui insobs 1 
	qui replace text = "% ---------------------------------------" if text == ""
	qui insobs 1 
	qui replace text = "% CBA equivalence test stats and p-values" if text == ""
	qui insobs 1 
	qui replace text = "% (latex vars) under `assume' assumption" if text == ""
	foreach stat in mu se p lbn ubn lbnf ubnf ll ul irr {
	
		// add percentage sign for all stats except for p-values
		if inlist("`stat'", "p", "irrp") local perc ""
		else local perc "\%"
		
		qui insobs 1 
		qui replace text = " " if text == ""
		qui insobs 1
		qui replace text = "% List of stats: `stat'" if text == ""
		foreach t in C P F {
			local this = trim(itrim("``stat'`t'`asm''"))
// 			dis "this = `this'"
			qui insobs 1
			qui replace text = "\newcommand\\`stat'`t'`asm'{`this'`perc'}" if text == ""
		}
	}
	** equivalence tests
	qui insobs 1 
	qui replace text = " " if text == ""
	qui insobs 1 
	qui replace text = "% lincom p-values for treatment equivalence tests" if text == ""
	foreach lincom_test in CP CF PF {
		local this = trim(itrim("`lincom_`lincom_test'_`asm''"))
		qui insobs 1
		qui replace text = "\newcommand\lincom`lincom_test'`asm'{`this'}" if text == ""
	}
	
	tempfile cba_treatments
	save 	`cba_treatments'

restore

** table ED7 LB
// B/C ratio =  w1_C * ll_C_1 + w2_C * ll_C_2
// B/C ratio =  w1_P * ll_P_1 + w2_P * ll_P_2
// B/C ratio =  w1_F * ll_F_1 + w2_F * ll_F_2
* UB
// B/C ratio =  w1_C * ul_C_1 + w2_C * ul_C_2
// B/C ratio =  w1_P * ul_P_1 + w2_P * ul_P_2
// B/C ratio =  w1_F * ul_F_1 + w2_F * ul_F_2





** -----------------------------------------------------------------------------
** 3) Repeat for pooled treatment 

clear
use phase `keepvars' using "${joint_fold}/Data/allrounds_NER_hh.dta", clear

gen treat_dum = 1 if (treatment == 1 | treatment == 2 | treatment == 3)
replace treat_dum = 0 if treatment == 0
label define ttt 0 "Control" 1 "Treatment effect"
label values treat_dum ttt 


foreach ph in 1 2 {

	// run regressions at each phase
	qui reg `regvar' treat_dum ///
							`bl_controls' ///
							i.strata ///
							if phase == `ph'
	estimates store estimpool_`ph'	
}


qui suest estimpool_1 estimpool_2, cluster (cluster)

// collect 95% conf. bounds on treatment coefs.
mat sueststats = r(table)
foreach ph in 1 2 {
	foreach tr in J {
		foreach cb in ll ul {	
			mat `cb'_`tr'_`ph' = sueststats["`cb'", "estimpool_`ph'_mean:treat_dum"]
			local `cb'_`tr'_`ph' = `cb'_`tr'_`ph'[1,1]
			dis "At phase `ph', `cb' for t = `tr' --> `cb'_`tr'_`ph' = ``cb'_`tr'_`ph''"
		}
		if `ph' == 2 {
			mat   b_`tr'_`ph' = sueststats["b", "estimpool_`ph'_mean:treat_dum"]
			local b_`tr'_`ph' = b_`tr'_`ph'[1,1]
			dis "beta at phase `ph', treatment `t' = `b_`tr'_`ph''"
		}
	}
}

if "`assume'" == "yearly" {
	putexcel set "${git_dir}/Baseline/cost_benefit/NER/cba_stats", modify

		// USD
		putexcel A13 = [estimpool_1_mean]treat_dum
		putexcel B13 = [estimpool_2_mean]treat_dum
		putexcel C13 = "Pooled treatment effect on consumption per adult eq. per day (USD 2016 PPP)"
		
	putexcel close
}
else if "`assume'" == "yrlyd" { 
	putexcel set "${git_dir}/Baseline/cost_benefit/NER/cba_stats", modify

		// USD
		putexcel A19 = [estimpool_1_mean]treat_dum
		putexcel B19 = [estimpool_2_mean]treat_dum
		putexcel C19 = "Pooled treatment effect on consumption HH yearly (USD 2016 PPP)"
		
	putexcel close

}

local cJ_0 = (`cC_0' + `cP_0' + `cF_0') / 3 // average cost (joint)
local cJ = `cJ_0' * 1.05^2

if "`assume'" == "yearly" {
	// COSTS from ASPP excel sheet
	foreach t in J {
		local w1_`t' = `adulteq_1' * 365 * 0.5 * 1.05 / `c`t''
		local w2_`t' = `adulteq_2' * 365 / `c`t''
		dis "weights = `w1_`t'' & `w2_`t''"
	}
}
else if "`assume'" == "yrlyd" { 

	foreach t in J {
		// already at yearly HH level
		local w1_`t' = 1 * 0.5 * 1.05 / `c`t'' // 2019 
		local w2_`t' = 1 / `c`t'' 			  // 2020
	}
}
else if "`assume'" == "monthly" {

	// COSTS from ASPP excel sheet
	// But first, calculate NPVs as linear tranformation, L1, L2, and L3 (see intro)
	local rate = 0.05 / 12 // month discount factor at 5% yearly
	//refresh Ls
	local L1 = 0
	local L2 = 0
	local L3 = 0

	forval i = 1/6 {
		local L1 = `L1' + `i'/(6*(1+`rate')^`i')
	}
	forval i = 7/18 {
		local l2_stuff = (1-(`i'-6)/12)/((1+`rate')^`i')
		local l3_stuff =   ((`i'-6)/12)/((1+`rate')^`i')
		local L2 = `L2' + `l2_stuff' 
		local L3 = `L3' + `l3_stuff' 
	}

	foreach t in J {
		local w1_`t' = (`L1' + `L2') *1.05^2 * `adulteq_1' * 30.4167 / `c`t''  
		local w2_`t' =        (`L3') *1.05^2 * `adulteq_2' * 30.4167 / `c`t'' 
		dis "weights = `w1_`t'' & `w2_`t''"
	}
}
else if "`assume'" == "monthlyd" {

	// COSTS from ASPP excel sheet
	// But first, calculate NPVs as linear tranformation, L1, L2, and L3 (see intro)
	local rate = 0.05 / 12 // month discount factor at 5% yearly
	//refresh Ls
	local L1 = 0
	local L2 = 0
	local L3 = 0

	forval i = 1/6 {
		local L1 = `L1' + `i'/(6*(1+`rate')^`i')
	}
	forval i = 7/18 {
		local l2_stuff = (1-(`i'-6)/12)/((1+`rate')^`i')
		local l3_stuff =   ((`i'-6)/12)/((1+`rate')^`i')
		local L2 = `L2' + `l2_stuff' 
		local L3 = `L3' + `l3_stuff' 
	}

	foreach t in J {
		local w1_`t' = (`L1' + `L2') *1.05^2 / (12 * `c`t'' )
		local w2_`t' =        (`L3') *1.05^2 / (12 * `c`t'' ) 
		dis "weights = `w1_`t'' & `w2_`t''"
	}
}
else if "`assume'" == "yrly_dissp50" | "`assume'" == "yrly_dissp25" {
	// calcalate weights in B/C linear transformation
	// these weights translate daily benefits per beneficiary to
	// yearly benefits per household in net present value at year 2
	// including dissipation effects 
	local A1 = 3.8958 * 365 * 0.5 * 1.05 
	local A2 = 4.6637 * 365
		
	// set summation limit as point where incremental diff becomes negligible
	foreach t in J {

		// initiate values
		local bA_`t' = `b_`t'_2' * `A2' // HH level TE at year 2
		local n = 1 // sum limit. Increase this until diff is negligible
		if 		"`assume'" == "yrly_dissp50" local dssp = 0.5 // dissipation rate
		else if "`assume'" == "yrly_dissp25" local dssp = 0.25 // dissipation rate
		local diff = 1 // diff
		local Ldssp = 0 // reset this as it updates for each treatment arm

		while `diff' > 0.0001 { // when diff falls below 1 ten thousandth of 1 USD
			local diff = `bA_`t''*((1-`dssp')^`n'-(1-`dssp')^(`n'+1))
			dis "still in loop because diff = `diff', n = `n'"
			dis `bA_`t''*(1-`dssp')^`n' // nominal cash flow at t=n 
			dis `bA_`t''*(1-`dssp')^(`n'+1) // nominal cash flow at t=n+1
			local n = `n'+1 // increment n
		}
		dis "left loop. n is now `n' (time periods before diff is negligible)"

		// calculate NPV for dissipation series using the n determined above
		local rate_yrly = 0.05 // 5% yearly discount factor
		forval i = 1/`n' {
			// scalarized NPV calc for dissipation after yr2
			local Ltemp = ((1-`dssp')^`i')/((1+`rate_yrly')^`i')
			local Ldssp = `Ldssp' + `Ltemp'
		}

		// (1) scale L-weights to year 2 to match year costs are in
		// (2) multiply by no. of adults (FCFA/day/adult -> FCFA/day)
		// (3) multiply by days/month    (FCFA/day       -> FCFA/month)
		// (4) divide by costs to get single scalar value (wi)
		
		//             (phase-specific demographics)
		//             adult/hh * days/yr* 0.5 (b/c @ month 6) * 1+discount rate
		local w1_`t' = `A1' / `c`t'' // 2019
		local w2_`t' = (`A2' / `c`t'') * (1 + `Ldssp') // 2020
		dis "weights = `w1_`t'' & `w2_`t''"
	}
}


// CI on B/C ratio for pooled treatment
lincom `w1_J'*[estimpool_1_mean]treat_dum + `w2_J'*[estimpool_2_mean]treat_dum

qui loc muJ`asm' : di %5.2fc `r(estimate)'
qui loc seJ`asm' : di %5.3fc `r(se)'
qui loc lbnfJ`asm' : di %5.2fc `r(lb)'
qui loc ubnfJ`asm' : di %5.2fc `r(ub)'
dis as error "95% CI for J treatment = (`lbnfJ`asm'', `ubnfJ`asm'')"
local lbnJ`asm' : di %5.2fc `r(estimate)'- 1.645*`r(se)'
local ubnJ`asm' : di %5.2fc `r(estimate)'+ 1.645*`r(se)'
dis as error "90% CI for J treatment = (`lbnJ`asm'', `ubnJ`asm'')"




foreach stat in mu se lbn ubn lbnf ubnf {
	qui loc `stat'J`asm' = ``stat'J`asm'' * 100
	if "`stat'" != "se" qui loc `stat'J`asm' : di %5.0fc ``stat'J`asm''
	else 				qui loc `stat'J`asm' : di %5.1fc ``stat'J`asm''
}
dis "for treatment `t', mean = `muJ`asm''%, se = `seJ`asm''%, lb = `lbnfJ`asm''%, ub = `ubnfJ`asm''%"

** linearly extrapolated bounds based on CI bounds on beta
foreach stat in ll ul {
	local `stat'J`asm' = `w1_J' * ``stat'_J_1' + `w2_J' * ``stat'_J_2'
	local `stat'J`asm' = 100 * ``stat'J`asm''
	local `stat'J`asm' : di %5.0fc ``stat'J`asm''
}


// test whether B/C ratio for pooled treatment == 1
lincom `w1_J'*[estimpool_1_mean]treat_dum + `w2_J'*[estimpool_2_mean]treat_dum - 1
local lincom_JOne_`asm' : di %5.3fc `r(p)'


** 3.1) update tex file of variables
preserve
	use `cba_treatments', clear
	
	qui insobs 1 
	qui replace text = " " if text == ""
	qui insobs 1
	qui replace text = "% List of stats for pooled treatment" if text == ""	
	foreach stat in mu se lbn ubn lbnf ubnf ll ul {
		foreach t in J {
			local this = trim(itrim("``stat'`t'`asm''"))
			qui insobs 1
			qui replace text = "\newcommand\\`stat'`t'`asm'{`this'\%}" if text == ""
		}
	}
	** equivalence tests
	qui insobs 1 
	qui replace text = " " if text == ""
	qui insobs 1 
	qui replace text = "% lincom p-value for test of joint B/C == 1" if text == ""
	foreach lincom_test in JOne {
		local this = trim(itrim("`lincom_`lincom_test'_`asm''"))
		qui insobs 1
		qui replace text = "\newcommand\lincom`lincom_test'`asm'{`this'}" if text == ""
	}

	tempfile stats_`assume'
	save 	`stats_`assume''
restore

}



** -----------------------------------------------------------------------------
** 4) Export texfile
local omit : word 1 of `assumptions'
local mergeasms : list assumptions - omit
use `stats_`omit'', clear
foreach asm in `mergeasms' {
	qui insobs 2 
	append using `stats_`asm''
}

drop if strpos(text, "{\%}") > 0
drop if strpos(text, "{}") > 0


outfile using "${joint_output_${cty}}/report_stats/cba_teststats.tex", noquote wide replace		





	** -------------------------------------------------------------------------
	** 5) Export equivalence tests ---------------------------------------------
	foreach asm in Year Mnth Yrffty {
		foreach test in CF PF CP {
			foreach stat in b se z "" {
// 				dis "lincom_`test'_`stat'`asm' = `lincom_`test'_`stat'`asm''"
				local lincom_`test'_`stat'`asm' = trim(itrim("`lincom_`test'_`stat'`asm''"))
			}			
		}
		foreach t in C P F {
			foreach stat in mu se z p {
// 				dis "`stat'`t'`asm' = ``stat'`t'`asm'_orig'"
				local `stat'`t'`asm'_orig = trim(itrim("``stat'`t'`asm'_orig'"))
			}
		}
	}
	
	
	// latex output

	local line1  "\begin{table}[htbp]\centering"
	local line2  "\fontsize{8}{10}\selectfont"
	local line3  "\caption{Supplementary Table SI.28x: Cost-Benefit Ratio Equivalence Tests}"
	local line4  "\label{tab:table_si28x}"
	local line5  "\begin{tabular}{lcccccc}"
	local line6  	"\hline\hline" 
	local line7  	" & (1) & (2) & (3) & (4) & (5) & (6)  \\" 
	#delimit ; 
	local line8 " & 
		\begin{tabular}[b]{@{}c@{}} Capital \\ (Full w/o \\ Psych.) \end{tabular} & 
		\begin{tabular}[b]{@{}c@{}} Psych. \\ (Full w/o \\ Capital) \end{tabular} & 
		\begin{tabular}[b]{@{}c@{}} Full \\ \textcolor{white}{.} \\ \textcolor{white}{.} \end{tabular} & 
		\begin{tabular}[b]{@{}c@{}} Full - Psych. \\ (Cash grant \\ gross ME) \end{tabular} & 
		\begin{tabular}[b]{@{}c@{}} Full - Capital \\ (Psych. comp. \\ gross ME) \end{tabular} & 
		\begin{tabular}[b]{@{}c@{}} Capital - \\ Psych. \\ \textcolor{white}{.} \end{tabular} \\
		\cmidrule(lr){2-4} \cmidrule(lr){5-7} 
		";
	local line9 " 
		& \multicolumn{3}{c}{coef/se/z/p} & \multicolumn{3}{c}{coef/se/z/p} \\ 
		";
	local line10 "\hline";
	local line11 "
		\multirow[t]{4}{11em}{Cost/benefit ratio (Extended Data Table 7)} & 
		\begin{tabular}[t]{@{}c@{}} `muCYear_orig'    \\ (`seCYear_orig') 	  \\ `zCYear_orig'     \\ (`pCYear_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `muPYear_orig'    \\ (`sePYear_orig') 	  \\ `zPYear_orig'     \\ (`pPYear_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `muFYear_orig' 	  \\ (`seFYear_orig') 	  \\ `zFYear_orig' 	   \\ (`pFYear_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `lincom_PF_bYear' \\ (`lincom_PF_seYear') \\ `lincom_PF_zYear' \\ (`lincom_PF_Year') \end{tabular} &
		\begin{tabular}[t]{@{}c@{}} `lincom_CF_bYear' \\ (`lincom_CF_seYear') \\ `lincom_CF_zYear' \\ (`lincom_CF_Year') \end{tabular} &
		\begin{tabular}[t]{@{}c@{}} `lincom_CP_bYear' \\ (`lincom_CP_seYear') \\ `lincom_CP_zYear' \\ (`lincom_CP_Year') \end{tabular} \\
		";
	local line12 "\arrayrulecolor{gray}\hline";
	local line13 "
		\multirow[t]{4}{11em}{Cost/benefit ratio (Extended Data Table 7, 50\% annual dissipation)} & 
		\begin{tabular}[t]{@{}c@{}} `muCYrffty_orig'    \\ (`seCYrffty_orig') 	  \\ `zCYrffty_orig'     \\ (`pCYrffty_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `muPYrffty_orig'    \\ (`sePYrffty_orig') 	  \\ `zPYrffty_orig'     \\ (`pPYrffty_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `muFYrffty_orig' 	\\ (`seFYrffty_orig') 	  \\ `zFYrffty_orig' 	 \\ (`pFYrffty_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `lincom_PF_bYrffty' \\ (`lincom_PF_seYrffty') \\ `lincom_PF_zYrffty' \\ (`lincom_PF_Yrffty') \end{tabular} &
		\begin{tabular}[t]{@{}c@{}} `lincom_CF_bYrffty' \\ (`lincom_CF_seYrffty') \\ `lincom_CF_zYrffty' \\ (`lincom_CF_Yrffty') \end{tabular} &
		\begin{tabular}[t]{@{}c@{}} `lincom_CP_bYrffty' \\ (`lincom_CP_seYrffty') \\ `lincom_CP_zYrffty' \\ (`lincom_CP_Yrffty') \end{tabular} \\
		";
	local line14 "\arrayrulecolor{gray}\hline";
	local line15 "
		\multirow[t]{4}{11em}{Cost/benefit ratio (Supplementary Info Table SI.27)} & 
		\begin{tabular}[t]{@{}c@{}} `muCMnth_orig'    \\ (`seCMnth_orig') 	  \\ `zCMnth_orig'     \\ (`pCMnth_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `muPMnth_orig'    \\ (`sePMnth_orig') 	  \\ `zPMnth_orig'     \\ (`pPMnth_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `muFMnth_orig' 	  \\ (`seFMnth_orig') 	  \\ `zFMnth_orig' 	   \\ (`pFMnth_orig')    \end{tabular} & 
		\begin{tabular}[t]{@{}c@{}} `lincom_PF_bMnth' \\ (`lincom_PF_seMnth') \\ `lincom_PF_zMnth' \\ (`lincom_PF_Mnth') \end{tabular} &
		\begin{tabular}[t]{@{}c@{}} `lincom_CF_bMnth' \\ (`lincom_CF_seMnth') \\ `lincom_CF_zMnth' \\ (`lincom_CF_Mnth') \end{tabular} &
		\begin{tabular}[t]{@{}c@{}} `lincom_CP_bMnth' \\ (`lincom_CP_seMnth') \\ `lincom_CP_zMnth' \\ (`lincom_CP_Mnth') \end{tabular} \\
		";
	#delimit cr
	local line16     "\hline \hline"
	local line17 "\end{tabular}"
	local line18 "\addvbuffer[3pt 0pt]{"
	local line19     "\begin{tabular}{p{0.75\textwidth}}"
	local line20         "\footnotesize \textit{Notes:}  "   
	#delimit ;
	local line21         "We test whether cost/benefit = 1 for each treatment arm
						  (columns 1-3), and we test for equivalence between arms
						  (columns 4-6). A detailed breakdown of costs and benefits 
						  is shown in Extended Data Table 7 assuming yearly benefits 
						  and in Supplementary Information Table SI.27 assuming 
						  benefits grow linearly post-intervention.
						  ";
	#delimit cr
	local line22     "\end{tabular}"
	local line23 "}"
	local line24 "\end{table}"

	clear
	gen text = ""
	forval i = 1/24 {
		insobs 1
		local line`i' = trim(itrim("`line`i''"))
		local line`i' = subinstr("`line`i''", "$", "\\$", .)
		replace text = "`line`i''" if text == ""
	}

	outfile using "${joint_output_${cty}}/report_tables/table_si28x.tex", noquote wide replace		
	
	** -------------------------------------------------------------------------





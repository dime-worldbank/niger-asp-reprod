/*
Title: 07_balance_and_attrition.do
This script prepares the baseline balance table, si1 
  
  Outline:
	** -----| 1) import baseline balance variables
	** -----| 2) Attirition at each phase
	** -----| 3.a) Collect variables
	** -----| 3.b) Label variables
	** -----| 3.c) Footnotes
	** -----| 4) Run balance code
*/
  
  
// Version
version 15.0
assert "$cty" == "NER"


use "${joint_fold}/Data/baseline_NER_hh.dta", clear


// confirm variables DNE if consent == 0
ds hhid consent strata cluster treatment treat_dum, not
foreach var in `r(varlist)' {
	assert `var' == . if consent == 0
}

// make hhh and pben varnames consistent
rename phy_*_hhh hhh_phy_*
rename phy_*_pben pben_phy_*
count if hhh_phy_lift == . & consent == 1 // 1 obs: consenting by no health

// impute strata means
	ds hhh_phy_* pben_phy_*
	foreach var in `r(varlist)' {
		byso strata : egen `var'_sm = mean(`var') // strata means
		byso strata : replace `var' = `var'_sm if `var' == . & consent == 1
		drop `var'_sm
	}

// generate z-index using daily living activities:
foreach stub in pben hhh {
	ds `stub'_phy_*
	zindex `r(varlist)', gen(`stub'_health_index)  condition(treatment == 0)
}




** -----| 2) Attirition at each phase
// BL
rename consent consent_bl

** Attrition using consent (completed survey variable)
foreach ph in 1 2 {
    preserve
		use "${joint_fold}/Data/allrounds_NER_hh.dta", clear
		keep if phase == `ph'
		rename consent consent_fu`ph'
		
		tempfile phase`ph'_consent
		save 	`phase`ph'_consent'
	restore
	
	mmerge hhid using "`phase`ph'_consent'", ///
		_merge(_fu`ph'_merge) ukeep(consent_fu`ph')
	
}


sum hhid consent*


// consent at FU1 (consent_fu1_cond) & FU2 (consent_fu2_cond)
// pre-baseline sample (N = 4,712)
foreach var of varlist consent* {
	replace `var' = 0 if missing(`var')
}
// actual baseline sample (N = 4,608 in NER)
foreach var of varlist consent_fu* { // fu1 and fu2
	gen `var'_cond = `var'
	replace `var'_cond = . if consent_bl == 0
}
sum hhid strata cluster consent*

// foreach var in hou_room hou_hea_min hou_mar_min hou_wat_min km_to_com ///
//  consent_bl consent_fu1 consent_fu2 consent_fu1_cond consent_fu2_cond {
// 	tab treatment, sum(`var')
// }


** -----| 3.a) Collect variables for iebaltab
// 1 balance
local seg1 same_cb /// 1 
		   pben_handicap /// 2 
		   hhh_fem  	 pben_fem /// 3+
		   hhh_poly 	 pben_poly ///
		   hhh_age 	 	 pben_age ///
		   hhh_edu 	 	 pben_edu ///
		   hhh_prim 	 pben_prim ///
		   hhh_lit 	 	 pben_lit ///
		   hhh_health_index pben_health_index ///
		   hou_room /// 1
		   hou_hea_min /// 2
		   hou_mar_min /// 2
		   hou_wat_min /// 2
		   km_to_com ///
		   
local seg2 consent_fu1_cond ///
		   consent_fu2_cond
		   		   


** -----| 3.b)  label variables 
// label var no_reg_info   	""
// label var R_FCS 		   	""
// label var R_PMT 		 	""
// label var R_r_CBT  		""
// balance

label var same_cb 			 "Beneficiary is HH head"
label var pben_handicap 	 "Beneficiary is handicapped"
label var hhh_fem  	 		 "Female (HH head)"
label var pben_fem  		 "Female (beneficiary)"
label var hhh_poly 	 		 "Polygamy (HH head)"
label var pben_poly 		 "Polygamy (beneficiary)"
label var hhh_age 	 	 	 "Age (HH head)"
label var pben_age 			 "Age (beneficiary)"
label var hhh_edu 	 	 	 "Education (years, HH head)"
label var pben_edu 			 "Education (years, beneficiary)"
label var hhh_prim 	 		 "Primary education (0/1, HH head)"
label var pben_prim 		 "Primary education (0/1, beneficiary)"
label var hhh_lit 	 	 	 "Literate (HH head)"
label var pben_lit 		 	 "Literate (beneficiary)"
label var hhh_health_index   "Health index (HH head)"
label var pben_health_index  "Health index (beneficiary)"
label var hou_room 		 	 "No. of rooms in house"
label var hou_hea_min 		 "Minutes to health center"
label var hou_mar_min 		 "Minutes to market"
label var hou_wat_min 		 "Minutes to water source"
label var km_to_com 		 "Distance to capital of commune (km)"

// attrition
label var consent_fu1_cond   "Follow-up 1"
label var consent_fu2_cond   "Follow-up 2"


** -----| 3.c) Footnotes
#delimit ;
local table_note1 "Standard errors for all tests are clustered at 
					the village level." ;
local table_note2 "Fixed effects using randomization strata are 
					included in all estimation regressions." ;
local table_note3 "The joint F-test in column 5 shows the p-value 
					from a test of equality of treatment arms." ;
local table_note4 "while the pooled F-test in column 6 shows the 
					p-value from a test of pooled treatment (i.e., 
					a regression with a dummy for any treatment arm). " ;
local table_note5 "The health index variable is a z-score index 
					standardized against the control group and 
					generated using three physical activity variables: 
					the reported difficulty of (1) lifting a 10 kg bag, 
					(2) walking 4 hours, and (3) working all day in the 
					field. The three components range from 1 to 4." ;
local table_note6 "In calculating distance-to-commune, we assign 
					commune centroids to households located more than 
					30 km away from a centroid that excludes those 
					outlying households in each commune." ;
local table_note7 "*** p $<$ 0.01, ** p $<$ 0.05, * p $<$ 0.1." ;
#delimit cr
foreach note in table_note1 table_note2 table_note3 ///
	table_note4 table_note5 table_note6 table_note7 {
	
	local `note' = trim("``note''")
}


** -----| 4) Run balance code (stacks iebaltab segments)
tex_stack_iebaltab, /// only works on two segments for now
	seg1(`seg1') ///
	seg2(`seg2') /// remaining locals are optional
	seg2_header("Response rate in baseline sample") /// 
	table_note1(`table_note1') /// 
	table_note2(`table_note2') /// 
	table_note3(`table_note3') /// 
	table_note4(`table_note4') /// 
	table_note5(`table_note5') /// 
	table_note6(`table_note6') /// 
	table_note7(`table_note7') /// 
	indentthese(`""Follow-up 1" "Follow-up 2""') ///
	qui
	
	
	
	
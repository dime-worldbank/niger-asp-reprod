/*
This script labels variables by section.
Labels should not exceed three lines. Separate lines with \n. Spaces OK within line.

Note that I "set varabbrev off" and then "on" before and after the main chunk of
this script.

*/

pause on 

capture prog drop asp_013_label_vars_ner
program define asp_013_label_vars_ner
	syntax, section(string) [stack_opt(string)]

	
	nois dis "	- Running do-file: asp_013_label_vars_ner.do"
	
set varabbrev off
{	// turn this on because baseline vars are named similarly and they're omitted by label

**------------------- PAP section: PRIMARY
* label primary vars
if "`section'" == "pap__a1" | "`section'" == "all__a1" | /// 
	strpos("`section'", "__a1_hte") | ///
	"`section'" == "mht" {
	capture label var  consum_2_day_eq_ppp 	"Gross\n consumption\n (daily, USD/adult eq.)"	// currency
	capture label var  mycons2_ihs   		"IHS Gross\n consumption\n (daily, USD/adult eq.)"
	capture label var  mycons2_log   		"Log Gross\n consumption\n (daily, USD/adult eq.)"
	capture label var  consum_2_day_eq_xof 	"Gross\n consumption\n (daily, FCFA/adult eq.)"	// currency
	capture label var  consum_1_day_eq_ppp 	"Gross\n consumption\n (medians only)"		// currency
	capture label var  consum_1_day_eq_xof 	"Gross\n consumption\n (medians only)"		// currency
	capture label var  consum_2_year_ppp	"Gross\n consumption\n (yearly, USD)"		// currency
	capture label var  consum_2_year_xof	"Gross\n consumption\n (yearly, FCFA)"		// currency
	capture label var  FIES_rvrs_raw		"Food\n security"
	capture label var  FIES_rvrs_latent 	"Food\n security\n (Rasch, latent)"
	capture label var  FIES_rvrs_gsem  		"Food\n security\n (Rasch-std index)"
	capture label var  FCS					"Dietary\n diversity"
}
if "`section'" == "all__a2" {
	capture label var hunger_rvrs1 	"Worried\n about no food\n (reversed)"
	capture label var hunger_rvrs2 	"Not eaten\n nutritious\n (reversed)"
	capture label var hunger_rvrs3 	"Eaten little\n variety\n (reversed)"
	capture label var hunger_rvrs4 	"Skipped\n meals\n (reversed)"
	capture label var hunger_rvrs5 	"Eat less\n than should\n (reversed)"
	capture label var hunger_rvrs6 	"No food\n at all\n (reversed)"
	capture label var hunger_rvrs7 	"Hungry,\n have not eaten\n (reversed)"
	capture label var hunger_rvrs8 	"Full day\n without eating\n (reversed)"
}
if "`section'" == "all__a1_time" {
	* special temporary vars
	capture label var consum_2_erly_ppp 	"Pre-planting\n gross\n consumption"	// currency
	capture label var consum_2_erly_xof 	"Pre-planting\n gross\n consumption"	// currency
	capture label var FIES_rvrs_raw_erly 	"Pre-planting\n food security"
	capture label var FCS_erly 			    "Pre-planting\n dietary\n diversity"
	capture label var consum_2_late_ppp 	"Post-harvest\n gross\n consumption"	// currency
	capture label var consum_2_late_xof 	"Post-harvest\n gross\n consumption"	// currency
	capture label var FIES_rvrs_raw_late 	"Post-harvest\n food security"
	capture label var FCS_late				"Post-harvest\n dietary\n diversity"
}
if "`section'" == "all__a1_year" {
	* label consumption component variables (respective table includes Gross consumption)
	capture label var food_2_year_ppp  "Food\n consumption"		// currency
	capture label var nonfood_year_ppp "Non-food\n consumption"	// currency
	capture label var edu_year_ppp     "Education\n expenditure"	// currency
	capture label var health_year_ppp  "Health\n expenditure"		// currency
	capture label var cel_year_ppp 	"Celebration\n expenditure"	// currency
	capture label var repairs_year_ppp "Household\n repair\n expenditure"	// currency

		capture label var food_2_year_xof  "Food\n consumption"		// currency
		capture label var nonfood_year_xof "Non-food\n consumption"	// currency
		capture label var edu_year_xof     "Education\n expenditure"	// currency
		capture label var health_year_xof  "Health\n expenditure"		// currency
		capture label var cel_year_xof 	"Celebration\n expenditure"	// currency
		capture label var repairs_year_xof "Household\n repair\n expenditure"	// currency
}
if "`section'" == "all__a1_split" {
	* primary_consum_split 
	capture label var consum_2_day_eq_ppp 	"Gross\n consumption"	// currency
	capture label var food_2_day_eq_ppp  "Food\n consumption"		// currency
	capture label var nonfood_day_eq_ppp "Non-food\n consumption" // currency
	capture label var edu_day_eq_ppp 	  "Education\n expenditure"	// currency
	capture label var health_day_eq_ppp  "Health\n expenditure"	// currency
	capture label var cel_day_eq_ppp 	  "Celebration\n expenditure" // currency
	capture label var repairs_day_eq_ppp "Household\n repair\n expenditure" // currency
	capture label var eatout_day_eq_ppp  "Eating\n out\n expenditure" // currency
	
	capture label var food_2_day_eq_xof  "Food\n consumption"		// currency
	capture label var nonfood_day_eq_xof "Non-food\n consumption"	// currency
	capture label var edu_day_eq_xof 	  "Education\n expenditure"	// currency
	capture label var health_day_eq_xof  "Health\n expenditure"	// currency
	capture label var cel_day_eq_xof 	  "Celebration\n expenditure"	// currency
	capture label var repairs_day_eq_xof "Household\n repair\n expenditure"	// currency
	capture label var eatout_day_eq_xof  "Eating\n out\n expenditure" // currency
}
if "`section'" == "all__a1_sen" | "`section'" == "bargraph" {
	capture label var consum_2_day_ppp    	"Gross\n consumption\n (daily, USD)"
	capture label var consum_2_day_eq_ppp 	"Gross\n consumption\n (daily, USD/adult eq.)"
	capture label var food_2_day_ppp 	   	"Food\n consumption\n (daily, USD)"
	capture label var food_2_day_eq_ppp   	"Food\n consumption\n (daily, USD/adult eq.)"
	capture label var  FIES_rvrs_raw		"Food\n security"
	capture label var  FCS					"Dietary\n diversity"
}

**------------------- PAP section: SECONDARY
* label secondary_2_ben vars
if "`section'" == "pap__b2_ben" | "`section'" == "all__b2_ben" {
	capture label var  tot_ben_rev30_ppp			"Business\n revenue\n (monthly, USD)"	// currency
	capture label var  tot_empl_rev12_ben_ppp 		"Wage\n earnings\n (yearly, USD)"		// currency
	capture label var  ag_harvest_12_ben_ppp_imp	"Harvest\n value\n (yearly, USD)"		// currency
	capture label var  tot_ani_ben_contr_ppp		"Livestock\n revenue\n (yearly, USD)"	// currency

	capture label var  tot_ben_rev30_xof			"Business\n revenue\n (monthly, FCFA)"	// currency
	capture label var  tot_empl_rev12_ben_xof 		"Wage\n earnings\n (yearly, FCFA)"		// currency
	capture label var  ag_harvest_12_ben_xof_imp	"Harvest\n value\n (yearly, FCFA)"		// currency
	capture label var  tot_ani_ben_contr_xof		"Livestock\n revenue\n (yearly, FCFA)"	// currency
}
if "`section'" == "all__b2_hh" | "`section'" == "outliers" {
	* label secondary_2_hh vars
	capture label var tot_hh_rev30_ppp			"Business\n revenue\n (monthly, USD)"	// currency
	capture label var tot_empl_rev12_hh_ppp	"Wage\n earnings\n (yearly, USD)"		// currency
	capture label var ag_harvest_12_ppp_imp	"Harvest\n value\n (yearly, USD)"		// currency
	capture label var tot_ani_hh_contr_ppp		"Livestock\n revenue\n (yearly, USD)"	// currency

	capture label var tot_hh_rev30_xof			"Business\n revenue\n (monthly, FCFA)"	// currency
	capture label var tot_empl_rev12_hh_xof	"Wage\n earnings\n (yearly, FCFA)"		// currency
	capture label var ag_harvest_12_xof_imp	"Harvest\n value\n (yearly, FCFA)"		// currency
	capture label var tot_ani_hh_contr_xof		"Livestock\n revenue\n (yearly, FCFA)"	// currency
}
if "`section'" == "pap__b2_set" | "`section'" == "all__b2_set" {
	if "`stack_opt'" == "horizontal" {
		* NER paper b2_set
		// business
		capture label var tot_ben_rev12_ppp		"Benef."
		capture label var tot_hh_rev12_ppp			"HH"
// 		capture label var tot_hhlb_rev12_ppp 		"HH less benef."   
// 		capture label var tot_bohh_rev12 			"Business rev.\n (benef. share\n over HH total)"
		
		// ag
		capture label var ag_harvest_12_ben_ppp_imp  "Benef."
		capture label var ag_harvest_12_ppp_imp_98   "HH"
// 		capture label var ag_harvest_12_hhlb_ppp_imp "HH less benef."   
// 		capture label var ag_harvest_12_bohh_xof_imp "Harvest value\n (benef. share\n over HH total)"

		// livestock
		capture label var tot_ani_ben_contr_ppp 	"Benef."
		capture label var tot_ani_hh_contr_ppp  	"HH"
// 		capture label var tot_ani_hhlb_contr_ppp 	"HH less benef."  	
// 		capture label var tot_ani_bohh_contr  		"Livestock rev.\n (benef. share\n over HH total)"
		
		// wages
		capture label var tot_empl_2rev12_ben_ppp  "Benef."		
		capture label var tot_empl_2rev12_hh_ppp   "HH"			 
// 		capture label var tot_empl_2rev12_hhlb_ppp "HH less benef."   
// 		capture label var tot_empl_2rev12_bohh_xof "Wage\n revenues (benef. share\n over HH total)"
		
		// sum
		capture label var revs_sum_ben_wempl 		"Benef."
		capture label var revs_sum_hh_wempl  		"HH"
// 		capture label var revs_sum_hhlb_wempl  	"Total\n revenues\n (HH less benef)"
// 		capture label var revs_sum_bohh_wempl 		"Benef. share\n of total HH\n revenues" // relabelled after listing this in intra-hh dynamics table
	}
}

if "`section'" == "pap__b2_setben" | "`section'" == "pap__b2_sethh" | ///
   "`section'" == "mht" {
		// bus
		capture label var tot_ben_rev12_ppp			 "Business revenue (yearly, USD, benef.)"
		capture label var tot_hh_rev12_ppp			 "Business revenue (yearly, USD, HH)"
		// ag
		capture label var ag_harvest_12_ben_ppp_imp  "Harvest value (yearly, USD, benef.)"
		capture label var ag_harvest_12_ppp_imp_98   "Harvest value (yearly, USD, HH)"
		// livestock
		capture label var tot_ani_ben_contr_ppp 	 "Livestock revenue (yearly, USD, benef.)"
		capture label var tot_ani_hh_contr_ppp  	 "Livestock revenue (yearly, USD, HH)"
		// wages
		capture label var tot_empl_2rev12_ben_ppp    "Wage revenue (yearly, USD, benef.)"		
		capture label var tot_empl_2rev12_hh_ppp     "Wage revenue (yearly, USD, HH)"			 
		// sum
		capture label var revs_sum_ben_wempl 		 "Total revenue (yearly, USD, benef.)"
		capture label var revs_sum_hh_wempl  		 "Total revenue (yearly, USD, HH)"
}
if "`section'" == "pap__b2_set_ihs" {
        
	capture label var mysumrev12_ben_ihs "Benef."
	capture label var mysumrev12_hh_ihs  "HH"
	
	capture label var mybusrev12_ben_ihs "Benef."
	capture label var mybusrev12_hh_ihs  "HH"
	
	capture label var myagrev12_ben_ihs  "Benef."
	capture label var myagrev12_hh_ihs   "HH"
	
	capture label var myanirev12_ben_ihs "Benef." 
	capture label var myanirev12_hh_ihs  "HH"
	
	capture label var myemplrev12_ben_ihs "Benef."
	capture label var myemplrev12_hh_ihs  "HH"

}
if "`section'" == "pap__b2_set_log" {
        
	capture label var mysumrev12_ben_log "Benef."
	capture label var mysumrev12_hh_log  "HH"
	
	capture label var mybusrev12_ben_log "Benef."
	capture label var mybusrev12_hh_log  "HH"
	
	capture label var myagrev12_ben_log  "Benef."
	capture label var myagrev12_hh_log   "HH"
	
	capture label var myanirev12_ben_log "Benef." 
	capture label var myanirev12_hh_log  "HH"
	
	capture label var myemplrev12_ben_log "Benef."
	capture label var myemplrev12_hh_log  "HH"

}

if "`section'" == "fx_graph" | "`section'" == "all__std1" {

	capture label var consum_2_day_eq_ppp_std "Daily consumption/adult eq."
	capture label var FIES_rvrs_raw_std 	  "Food security"
	capture label var revs_sum_hh_wempl_std   "Household total revenue"
	capture label var revs_sum_ben_wempl_std  "Beneficiary total revenue"
	
	capture label var soc_cohsn_index 		"Social cohesion and community closeness"
	capture label var ctrl_hh_index 		"Control over household resources"
	capture label var ctrl_earn_index 		"Control over earnings" 
	capture label var ment_hlth_index 		"Mental health"
	capture label var gse_index  			"Self efficacy"

}

if "`section'" == "pap__a1b2" { // HTE set
	capture label var consum_2_day_eq_ppp 			"Gross\n consumption\n (daily, USD/adult eq.)"	// currency
	capture label var FIES_rvrs_raw				"Food\n security"
	capture label var tot_ben_rev12_ppp 			"Business\n revenue\n (yearly, USD)"	// currency
	capture label var ag_harvest_12_ben_ppp_imp	"Harvest\n value\n (yearly, USD)"		// currency
	capture label var tot_ani_ben_contr_ppp		"Livestock\n revenue\n (yearly, USD)"	// currency
	capture label var tot_hhlb_rev12_ppp 			"Business rev.\n HH less benef.\n (yearly, USD)"   // currency
	capture label var ag_harvest_12_hhlb_ppp_imp 	"Harvest value\n HH less benef.\n (yearly, USD)"  // currency
	capture label var tot_ani_hhlb_contr_ppp 		"Livestock rev.\n HH less benef.\n (yearly, USD)"	// currency
}
if "`section'" == "pap__a2_foot" { // footnote
	capture label var tot_ben_pro12_ppp "Business\n profits\n (benef., yearly, USD)"
	capture label var tot_hh_pro12_ppp  "Business\n profits\n (HH, yearly, USD)"
}

		
* label secondary_3 vars
if "`section'" == "all__b3" | "`section'" == "pap__b3" | /// 
		"`section'" == "mht" { // 
	capture label var  all_income_div		"No. of\n income\n sources"
	capture label var  div_crop_types   	"Crop\n types"
	capture label var  div_n_na_12 		"Off-farm\n business\n types"
	capture label var  div_ani 			"Livestock\n types"
	capture label var  div_empl12_n  		"Wage\n types"
	capture label var  act_main_nonag		"Beneficiary's\n main activity\n is off-farm \{0,1\}"
}

// moved b4 to index condition below

* label secondary_5 vars
// 95 p same label. Changing table title below
if "`section'" == "pap__b5" | "`section'" == "all__b5" | /// 
		"`section'" == "mht"  { // 
	capture label var ag_val_98_ppp    	"Agricultural\n asset\n value (USD)" // currency
	capture label var bus_assval_98_ppp	"Business\n asset\n value (USD)" 	 // currency
	capture label var ani_val_98_ppp  		"Livestock\n asset\n value (USD)"  	 // currency
	capture label var hh_ass_index 	  	"Household\n asset\n index" // anywhere, same label
}
if "`section'" == "all__b5_95p" { // 
	capture label var ag_val_95_ppp  		"Agrigultural\n asset\n value (USD)" // currency
	capture label var ani_val_95_ppp		"Livestock\n asset\n value (USD)" 	 // currency
	capture label var bus_assval_95_ppp	"Business\n asset\n value (USD)" 	 // currency
}
if "`section'" == "all__b6_ass_1" { // 
	capture label var hh_ass_count_ben_98    "Benef."
	capture label var hh_ass_count_hh_98     "Household"
	capture label var hh_ass_count_hhlb_98   "Household\n less benef."
	capture label var tot_ani_count_tlu_ben  "Benef."
	capture label var tot_ani_count_tlu 	  "Household"
	capture label var tot_ani_count_tlu_hhlb "Household\n less benef."
}
if "`section'" == "all__b6_brk" | ///
	"`section'" == "commsupport"  { // 
	capture label var hh_ass_count_hh_98    "Total\n asset\n count"
	capture label var hh_ass_count_hh_98_1  "Furniture\n count"
	capture label var hh_ass_count_hh_98_2  "Mobility\n asset\n count"
	capture label var hh_ass_count_hh_98_3  "Cooking\n asset\n count"
	capture label var hh_ass_count_hh_98_4  "Appliance\n count"
	capture label var hh_ass_count_hh_98_5  "Other\n asset\n count"
}

* label secondary_6 vars
if "`section'" == "all__b6" 	  | ///
   "`section'" == "all__b6_ext"   | ///
   "`section'" == "all__b6_enum"  | ///
   "`section'" == "pap__b6" 	  | ///
   "`section'" == "pap__b6_annex" | ///
   "`section'" == "pap__b6_suppl" | /// 
   "`section'" == "mht" {
   
   	* pap__b6_suppl
	if "`section'" == "pap__b6_suppl" | /// 
		"`section'" == "mht" {
		capture label var ton_or_avec_hh_fe "Takes part in\n tontine/AVEC\n (enumerator F.E.)"
	}
      
	capture label var  ton_or_avec_hh    "Takes part in\n tontine/AVEC\n \{0,1\}"
	capture label var  ton_hh 		  	  "Takes part in\n tontine\n \{0,1\}"
	capture label var  avec_hh		  	  "Takes part in\n AVEC\n \{0,1\}"
	
	capture label var  tot_sav3_ppp   	  "Tontine/AVEC\n savings\n (3 months, USD)" // currency
	capture label var  tot_dep_out_ppp   "Other\n savings\n (3 months, USD)"		 // currency
	capture label var  tot_cred_out_ppp  "Total\n borrowed\n (yearly, USD)"			 // currency
	capture label var  loan_out_ppp	  "Total\n lent out\n (yearly, USD)"			 // currency
	capture label var  gross_trans_ppp   "Gross\n transfers\n (yearly, USD)"			 // currency
	capture label var  tot_trans_in_ppp  "Household\n transfers in\n (yearly, USD)" 	 // currency
	capture label var  tot_trans_out_ppp "Household\n transfers out\n (yearly, USD)" 	 // currency

	capture label var  tot_sav3_xof   	  "Tontine/AVEC\n savings\n (3 months, FCFA)" // currency
	capture label var  tot_dep_out_xof   "Other\n savings\n (3 months, FCFA)"		 // currency
	capture label var  tot_cred_out_xof  "Total\n borrowed\n (yearly, FCFA)"		 	// currency
	capture label var  loan_out_xof	  "Total\n lent out\n (yearly, FCFA)"		 	// currency
	capture label var  gross_trans_xof   "Gross\n transfers\n (yearly, FCFA)"			 // currency
	capture label var  tot_trans_in_xof  "Household\n transfers in\n (yearly, FCFA)" 	 // currency
	capture label var  tot_trans_out_xof "Household\n transfers out\n (yearly, FCFA)" 	 // currency
	capture label var hh_ass_index 	  "Household\n asset\n index" // anywhere, same label
}
	

	
if "`section'" == "all__b7"   | ///
   "`section'" == "all__b7_1" | ///
   "`section'" == "pap__b7"   | /// 
   "`section'" == "mht" { // 

	* label secondary_7 vars
	capture label var  save_share_d		"Husband's\n financial\n involvement \{0,1\}"
	capture label var  save_goal 		 	"Savings\n goal\n \{0,1\}"
	capture label var  save_goal_ppp 	 	"Savings\n goal\n (USD)" 			 // currency
	capture label var  save_goal_xof 	 	"Savings\n goal\n (FCFA)" 			 // currency
	capture label var  save_goal_specific 	"Savings\n item\n \{0,1\}"
	capture label var  save_productive 	"Savings\n item\n productive \{0,1\}"
	
	* label secondary_7_1 vars
	capture label var save_productive_1 	"Purpose:\n tuition\n fees \{0,1\}"
	capture label var save_productive_2 	"Purpose:\n off-farm\n investment \{0,1\}"
	capture label var save_productive_3 	"Purpose:\n ag\n investment \{0,1\}"
	capture label var save_productive_4 	"Purpose:\n home\n improvement \{0,1\}"
	capture label var save_productive_5 	"Purpose:\n durable\n goods \{0,1\}"
	capture label var save_productive_6 	"Purpose:\n future\n consumption \{0,1\}"
	capture label var save_productive_7 	"Purpose:\n current\n consumption \{0,1\}"
	capture label var save_productive_8 	"Purpose:\n emergencies \{0,1\}"
	capture label var save_productive_9 	"Purpose:\n other\n savings \{0,1\}"
	capture label var save_productive_10	"Purpose:\n celebrations \{0,1\}"
}

if "`section'" == "pap__b8_hh" | /// 
	"`section'" == "mht" {
	* label secondary_8 vars HH
	capture label var  bus2_dum			"Household\n has a\n business \{0,1\}"
	capture label var  act_main_nonag		"Beneficiary's\n main activity\n is off-farm \{0,1\}"
	capture label var  na_bus2_op_wn_12 	"No. of\n household\n businesses"
	capture label var  bus2_invest_ppp		"Beneficiary's\n investments\n (yearly, USD)" // currency
	capture label var  tot_hh_rev30_ppp	"Business\n revenue\n (monthly, USD)" 		// currency
	capture label var  tot_hh_pro30_ppp 	"Business\n profits\n (monthly, USD)" 		// currency
	capture label var  health_bus_ind 		"Beneficiary's\n healthy business\n practices index"

	capture label var  bus2_invest_xof		"Beneficiary's\n investments\n (yearly, FCFA)" // currency
	capture label var  tot_hh_rev30_xof	"Business\n revenue\n (monthly, FCFA)" 		// currency // labelled above
	capture label var  tot_hh_pro30_xof 	"Business\n profits\n (monthly, FCFA)" 		// currency
	capture label var  bus2_profits_hh_xof "Business\n profits\n (yearly average, FCFA)" // currency
	
	capture label var  bus2_ben_dum 		 "Beneficiary\n has a\n business \{0,1\}"
	capture label var  na_bus2_op_wn_12_ben "No. of\n beneficiary\n businesses"
	capture label var  tot_ben_rev30_ppp  	 "Beneficiary\n revenues\n (monthly, USD)"
	capture label var  tot_ben_pro30_ppp 	 "Beneficiary\n profits\n (monthly, USD)"
	
	capture label var tot_bus2_ppl_uniq 	 "No. of\n workers in\ HH businesses"
	capture label var tot_busmths_uniq 	 "No. of\n months worked\n last year"
}
if "`section'" == "all__b8_hh" | ///
	"`section'" == "commsupport" | ///
	"`section'" == "bargraph" {
	capture label var na_bus2_op_wn_12 	"No. of\n household\n businesses"
	capture label var act_main_nonag		"Beneficiary's\n main activity\n is off-farm \{0,1\}"
	capture label var bus2_dum  		 	"Household\n has a\n business \{0,1\}"
	capture label var bus2_within_12_dum 	"Household\n launched a\n business \{0,1\}"
	capture label var bus2_abandon_24_dum	"Household\n abandoned a\n business \{0,1\}"
	capture label var bus2_invest_ppp 	    "Beneficiary's\n investments\n (yearly, USD)" // currency
	capture label var tot_cost_all_ppp 	"Total\n costs\n (monthly, USD)"
	capture label var tot_hh_rev12_ppp 	"Business\n revenues\n (yearly, USD)"
	capture label var tot_hh_pro12_ppp 	"Business\n profits\n (yearly, USD)"
	capture label var tot_bus_least_ppp 	"Business\n profits\n (monthly low, USD)"
	capture label var tot_bus_most_ppp 	"Business\n profits\n (monthly high, USD)"
	capture label var bus2_profits_hh_ppp  "Business\n profits\n (yearly estimate, USD)" // currency
	capture label var bus2_profits_btm_ppp "Business\n profits\n (rev-cost, USD)"
	capture label var tot_bus2_ppl_uniq    "Size of\n workforce"
	capture label var tot_busmths_uniq 	"No. of\n months worked\n last year"
	capture label var bus_assval_98_ppp	"Business\n asset\n value (USD)" 	 // currency
	capture label var bus2_divrse 			"Business\n type\n diversity"
	capture label var div_n_na_12 			"Off-farm\n business\n types"
	
	capture label var bus2_invest_xof		"Beneficiary's\n investments\n (yearly, FCFA)" // currency
	capture label var tot_hh_rev30_xof		"Business\n revenue\n (monthly, FCFA)" 		// currency // labelled above
	capture label var tot_hh_pro30_xof 	"Business\n profits\n (monthly, FCFA)" 		// currency
	capture label var bus2_profits_hh_xof 	"Business\n profits\n (yearly estimate, FCFA)" // currency
}
if "`section'" == "all__b8_ben" | ///
	"`section'" == "bargraph" {
	capture label var bus2_ben_dum 		 "Beneficiary\n has a\n business \{0,1\}"
	capture label var na_bus2_op_wn_12_ben  "No. of\n beneficiary\n businesses"
	capture label var tot_busmths_uniq_ben  "No. of months\n benef worked\n last year"
	capture label var bus2_invest_ppp 	     "Beneficiary's\n investments\n (yearly, USD)" // currency
	capture label var tot_cost_all_ppp 	 "Total\n costs\n (monthly, USD)"
	capture label var tot_ben_rev12_ppp 	 "Business\n revenues\n (yearly, USD)"
	capture label var tot_ben_pro12_ppp 	 "Business\n profits\n (yearly, USD)"
	capture label var bus_assval_98_ben_ppp "Business\n asset\n value (USD)" 	 // currency
	capture label var div_n_na_12_ben 		 "Off-farm\n business\n types"
}
if "`section'" == "all__b8_ben_split" {
	capture label var bus_rev12_ben_1_ppp "Food\n processing"
	capture label var bus_rev12_ben_2_ppp "Tailoring"
	capture label var bus_rev12_ben_3_ppp "Construction"
	capture label var bus_rev12_ben_4_ppp "Commerce"
	capture label var bus_rev12_ben_5_ppp "Professions"
	capture label var bus_rev12_ben_6_ppp "Service"
	capture label var bus_rev12_ben_7_ppp "Transportation"
	capture label var bus_rev12_ben_8_ppp "Artisanship"
	capture label var bus_rev12_ben_9_ppp "Other"
}
if "`section'" == "all__b8_costs" {
	capture label var tot_cost_all_ppp 	  "Total\n costs"
	capture label var tot_cost_inputs_ppp 	  "Input\n costs"
	capture label var tot_cost_energy_ppp 	  "Utilities\n costs"
	capture label var tot_cost_loan_ppp 	  "Loan\n costs"
	capture label var tot_cost_tech_ppp 	  "Connectivity\n costs"
	capture label var tot_cost_transport_ppp "Transport\n costs"
	capture label var tot_cost_eqrent_ppp    "Equipment\n rent"
	capture label var tot_cost_rent_ppp 	  "Real\n estate\n rent"
	capture label var tot_cost_main_ppp  	  "Maintenance\n costs"
	capture label var tot_cost_tax_ppp 	  "Taxes"
	capture label var tot_cost_bribe_ppp 	  "Bribes"
	capture label var tot_cost_sal_ppp 	  "Salaries"
}
if "`section'" == "all__b8_descr" {
	
	capture label var bus1_food_d   "Food\n processing"
	capture label var bus1_tail_d   "Tailoring"
	capture label var bus1_constr_d "Construction"
	capture label var bus1_comm_d   "Commerce"
	capture label var bus1_prof_d   "Liberal\n profession"
	capture label var bus1_serv_d   "Other\n services"
	capture label var bus1_trans_d  "Transport"
	capture label var bus1_art_d    "Artisanship"
	capture label var bus1_extra_d  "Other"
	
}
if "`section'" == "all__b8_descr_ben" {

	capture label var bus1_ben_1_d "Food\n processing"
	capture label var bus1_ben_2_d "Tailoring"
	capture label var bus1_ben_3_d "Construction"
	capture label var bus1_ben_4_d "Commerce"
	capture label var bus1_ben_5_d "Professions"
	capture label var bus1_ben_6_d "Service"
	capture label var bus1_ben_7_d "Transportation"
	capture label var bus1_ben_8_d "Artisanship"
	capture label var bus1_ben_9_d "Other"
	
	
}

* label secondary_9 vars
if "`section'" == "all__b9" | "`section'" == "all__b9_1" {
	capture label var  health_bus			"Beneficiary's\n healthy business\n practices \{0-10\}"
	capture label var  health_bus_ind 		"Beneficiary's\n healthy business\n practices index"
		capture label var prac_inp_know 		"Knows\n production\n cost \{0,1\}"
		capture label var prac_best_know 		"Knows\n profitability\n \{0,1\}"
		capture label var prac_goal 			"Has sales\n target\n \{0,1\}"
		capture label var prac_sup_chang 		"Changed\n supplier\n \{0,1\}"
		capture label var prac_sup_neg 		"Negotiates\n supply\n \{0,1\}"
		capture label var prac_sup_comp		"Studies\n suppliers\n \{0,1\}"
		capture label var prac_comp1 			"Studies\n competition\n \{0,1\}"
		capture label var prac_cust 			"Studies\n customers\n \{0,1\}"
		capture label var prac_credit_record_d "Records\n credit\n sales \{0,1\}"
		capture label var prac_freq_pub_d 		"Advertises\n products\n \{0,1\}"
}

// moved b10 to index condition below
	
* label secondary_11_1_1 vars
if "`section'" == "all__b11_1_1" {
	capture label var shock_covar 	 "Climatic shocks:\n droughts, irregular rains,\n or floods \{0,1\}"
	capture label var shock_aglivdis "Ag/livestock shocks:\n culture, animal\n diseases \{0,1\}"
	capture label var shock_price 	 "Price shocks:\n food, ag Inputs,\n ag sales \{0,1\}"
	capture label var shock_idio 	 "Idiosyncratic shocks:\n sickness, death,\n divorce, theft \{0,1\}"
	capture label var shock_other	 "Other shocks:\n incl. off-farm\n income \{0,1\}"
}

* label secondary_11_1_2 vars
if "`section'" == "all__b11_1_2" | "`section'" == "all__b11_1_descr" {
	capture label var shock1  "Irregular\n rains\n \{0,1\}"
	capture label var shock2  "Floods\n \{0,1\}"
	capture label var shock3  "Cultures\n disease\n \{0,1\}"
	capture label var shock4  "Animal\n disease\n \{0,1\}"
	capture label var shock5  "Inc. ag\n input costs\n \{0,1\}"
	capture label var shock6  "Dec. ag\n sale prices\n \{0,1\}"
	capture label var shock7  "Inc. food\n prices\n \{0,1\}"
	capture label var shock8  "Off-farm HH\n income loss\n \{0,1\}"
	capture label var shock9  "HH Mem. Ill\n or accident\n \{0,1\}"
	capture label var shock10 "HH Mem.\n death\n \{0,1\}"
	capture label var shock11 "Divorce or\n separation\n \{0,1\}"
	capture label var shock12 "Theft\n \{0,1\}"
	capture label var shock13 "Other\n \{0,1\}"
}

* label secondary_11_2_1 vars
if "`section'" == "all__b11_2_1" {
	capture label var shock_worst_covar 		"Climatic shocks:\n droughts, irregular rains,\n or floods \{0,1\}"
	capture label var shock_worst_aglivdis 	"Ag/livestock shocks:\n culture, animal\n diseases \{0,1\}"
	capture label var shock_worst_price 		"Price shocks:\n food, ag inputs,\n ag sales \{0,1\}"
	capture label var shock_worst_idio 	 	"Idiosyncratic shocks:\n sickness, death,\n divorce, theft \{0,1\}"
	capture label var shock_worst_other	 	"Other shocks:\n incl. off-farm\n income \{0,1\}"
}
if "`section'" == "all__b11_2_2" | "`section'" == "all__b11_2_descr" {
	* label secondary_11_2_2 vars
	capture label var shock_worst1  "Irregular\n rains\n \{0,1\}"
	capture label var shock_worst2  "Floods\n \{0,1\}"
	capture label var shock_worst3  "Cultures\n disease\n \{0,1\}"
	capture label var shock_worst4  "Animal\n disease\n \{0,1\}"
	capture label var shock_worst5  "Inc. ag\n input costs\n \{0,1\}"
	capture label var shock_worst6  "Dec. ag\n sale prices\n \{0,1\}"
	capture label var shock_worst7  "Inc. food\n prices\n \{0,1\}"
	capture label var shock_worst8  "Off-farm HH\n income loss\n \{0,1\}"
	capture label var shock_worst9  "HH mem. ill\n or accident\n \{0,1\}"
	capture label var shock_worst10 "HH mem.\n death\n \{0,1\}"
	capture label var shock_worst11 "Divorce or\n separation\n \{0,1\}"
	capture label var shock_worst12 "Theft\n \{0,1\}"
	capture label var shock_worst13 "Other\n \{0,1\}"
}
* label secondary_11_3_a vars
if "`section'" == "all__b11_3_a" | ///
	"`section'" == "pap__b11_3_a" | /// 
	"`section'" == "mht" { // 
	capture label var  ever_rev		"Lost\n income\n \{0,1\}"
	capture label var  ever_live		"Sold\n livestock\n \{0,1\}"
	capture label var  ever_stock		"Sold\n foodstock\n \{0,1\}"
	capture label var  ever_save		"Used\n savings\n \{0,1\}"
	capture label var  ever_consum		"Reduced\n food expenses\n \{0,1\}"
	capture label var  ever_asset 		"Sold\n productive\n assets \{0,1\}"
	capture label var  ever_educ  		"Reduced\n educ./health\n expenses \{0,1\}"
}
* label secondary_11_4 vars
if "`section'" == "all__b11_4" {
	capture label var ynot_rev_prefer_o 	"Lost\n income\n \{0,1\}"
	capture label var ynot_live_prefer_o 	"Sold\n livestock\n \{0,1\}"
	capture label var ynot_stock_prefer_o 	"Sold\n foodstock\n \{0,1\}"
	capture label var ynot_save_prefer_o 	"Used\n savings\n \{0,1\}"
	capture label var ynot_consum_prefer_o "Reduced\n food expenses\n \{0,1\}"
	capture label var ynot_asset_prefer_o 	"Sold\n productive\n assets \{0,1\}"
	capture label var ynot_educ_prefer_o 	"Reduced\n educ./health\n expenses \{0,1\}"
}
	* label secondary_11_3_b vars (conditional on B.11.4 != 1)
if "`section'" == "all__b11_3_b" {
	capture label var ever_rev_cond	"Lost\n income\n \{0,1\}"
	capture label var ever_live_cond  	"Sold\n livestock\n \{0,1\}"
	capture label var ever_stock_cond 	"Sold\n foodstock\n \{0,1\}"
	capture label var ever_save_cond  	"Used\n savings\n \{0,1\}"
	capture label var ever_consum_cond "Reduced\n food expenses\n \{0,1\}"
	capture label var ever_asset_cond 	"Sold\n productive\n assets \{0,1\}"
	capture label var ever_educ_cond  	"Reduced\n educ./health\n expenses \{0,1\}"
}
if "`section'" == "all__b11_5_1" {
* label secondary_11_5_1 vars
	capture label var strat_o_income 	"Lost\n income\n \{0,1\}"
	capture label var strat_o_assets 	"Sold\n assets\n \{0,1\}"
	capture label var strat_o_savings 	"Used\n savings\n \{0,1\}"
	capture label var strat_o_food 	"Sold/reduced\n food\n \{0,1\}"
	capture label var strat_o_nonfood 	"Reduced\n expenses\n \{0,1\}"
	capture label var strat_o_migrate 	"Migrated\n \{0,1\}"
	capture label var strat_o_aid_frm 	"Received\n gov./NGO aid\n \{0,1\}"
	capture label var strat_o_aid_inf 	"Received\n community aid\n \{0,1\}"
	capture label var strat_o_god 		"Invoked\n god\n \{0,1\}"
	capture label var strat_o_none 	"Did\n nothing\n \{0,1\}"
	capture label var strat_o_other 	"Other\n strategies\n \{0,1\}"
}
	* label secondary_11_5_2 vars
if "`section'" == "all__b11_5_2" {
	capture label var other_strat0 "Did\n nothing\n \{0,1\}"
	capture label var other_strat7 "Reduced\n non-food\n expenses \{0,1\}"
	capture label var other_strat8 "Sale of\n HH durable\n goods \{0,1\}"
	capture label var other_strat9 "Credit\n \{0,1\}"
	capture label var other_strat10 "HH members\n did addtnl\n activities \{0,1\}"
	capture label var other_strat11 "Migrated\n \{0,1\}"
	capture label var other_strat12 "Help from\n relatives or\n friends \{0,1\}"
	capture label var other_strat13 "Gov/state\n support\n \{0,1\}"
	capture label var other_strat14 "NGO\n support\n \{0,1\}"
	capture label var other_strat15 "Religious\n orgs. support\n \{0,1\}"
	capture label var other_strat16 "Invoked\n god\n \{0,1\}"
	capture label var other_strat17 "Other\n \{0,1\}"
}

* label secondary_11_6_1 vars
if "`section'" == "all__b11_6_1" {
	capture label var strat_b_income 	"Lost\n income\n \{0,1\}"
	capture label var strat_b_assets 	"Sold\n assets\n \{0,1\}"
	capture label var strat_b_savings 	"Used\n savings\n \{0,1\}"
	capture label var strat_b_food 	"Sold/reduced\n food\n \{0,1\}"
	capture label var strat_b_nonfood 	"Reduced\n expenses\n \{0,1\}"
	capture label var strat_b_migrate 	"Migrated\n \{0,1\}"
	capture label var strat_b_aid_frm 	"Received\n gov./NGO aid\n \{0,1\}"
	capture label var strat_b_aid_inf 	"Received\n community aid\n \{0,1\}"
	capture label var strat_b_god 		"Invoked\n god\n \{0,1\}"
	capture label var strat_b_none 	"Did\n nothing\n \{0,1\}"
	capture label var strat_b_other 	"Other\n strategies\n \{0,1\}"
}
	* label secondary_11_6_2 vars
if "`section'" == "all__b11_6_1" {
	capture label var other_best0 "Did\n nothing\n \{0,1\}"
	capture label var other_best1 "Sold\n livestock\n \{0,1\}"
	capture label var other_best2 "Sold\n foodstock\n \{0,1\}"
	capture label var other_best3 "Used\n savings\n \{0,1\}"
	capture label var other_best4 "Reduced\n food expenses\n \{0,1\}"
	capture label var other_best5 "Sold\n productive\n assets \{0,1\}"
	capture label var other_best6 "Reduced\n educ./health\n expenses \{0,1\}"
	capture label var other_best7 "Reduced\n non-food\n expenses \{0,1\}"
	capture label var other_best8 "Sale of\n HH durable\n goods \{0,1\}"
	capture label var other_best9 "Credit\n \{0,1\}"
	capture label var other_best10 "HH members\n did addtnl\n activities \{0,1\}"
	capture label var other_best11 "Migrated\n \{0,1\}"
	capture label var other_best12 "Help from\n relatives or\n friends \{0,1\}"
	capture label var other_best13 "Gov/State\n support\n \{0,1\}"
	capture label var other_best14 "NGO\n support\n \{0,1\}"
	capture label var other_best15 "Religious\n orgs. support\n \{0,1\}"
	capture label var other_best16 "Invoked\n god\n \{0,1\}"
	capture label var other_best17 "Other\n \{0,1\}"
}

if "`section'" == "all__b11_7" {

	capture label var telsho_cons  	"Reduced\n food\n consumption"
	capture label var telsho_nonalim 	"Reduced\n non-food\n expenditure"
	capture label var telsho_healedu 	"Reduced\n edu and health\n expenditure"
	capture label var telsho_cred 		"Borrowed\n money"
	capture label var telsho_save_all 	"Used up\n all savings"
}

** indices -------------------------------------------------------
if  strpos("`section'", "__b4") > 0  	| /// 
	strpos("`section'", "__b10") > 0 	| /// 
	strpos("`section'", "__c1") > 0  	| ///
	strpos("`section'", "__c2") > 0  	| ///
	strpos("`section'", "__a1_hte") > 0 | ///
	"`section'" == "mht" { // if section is b4, b10, c1, c2 or mht table

	* label secondary_4 vars
	capture label var ment_hlth_index 			"Mental\n health\n index"
	capture label var social_worth_index 		"Social\n worth\n index"
	capture label var future_expct_30_index 	"Future\n expectations\n index"
	* label secondary_4_1 vars
	capture label var less_depressed 		"Less\n depression\n \{0-70\}"
	capture label var less_disability 		"Less\n disability\n \{0-28\}"
	capture label var stair_satis_today 	"Life\n satisfaction\n \{1-10\}"
	capture label var stairs_peace 		"Inner\n peace\n \{1-10\}"
	capture label var health_ment_z		"Self-reported\n mental\n health"

	* label secondary_4_2 vars
	capture label var gse_sum  			"Self\n efficacy\n \{7-32\}"
	capture label var social_stand_sum 	"Social\n standing\n \{4-40\}"
	capture label var gse_index  			"Self\n efficacy\n index" // created 5/12/2021
		capture label var gse1 			"You put effort\n to solve\n problems \{1-4\}"
		capture label var gse2 			"You do what\n you want\n anyway \{1-4\}"
		capture label var gse3 			"You stay on\n your plan and\n achieve goals \{1-4\}"
		capture label var gse4 			"You cope with\n contigencies\n \{1-4\}"
		capture label var gse7 			"You adapt and\n handle difficulties\n \{1-4\}"
		capture label var gse8 			"You find\n multiple\n solutions \{1-4\}"
		capture label var gse9 			"You usually\n find\n solutions \{1-4\}"
		capture label var ros4 			"You do as\n well as\n others \{1-4\}"
	capture label var soc_stand_index 		  "Social\n standing\n index" // created 5/12/2021
		capture label var stair_good_today   "Good\n person\n \{1-10\}"
		capture label var stair_respect_new  "Respected\n person\n \{1-10\}"
		capture label var stair_opinion_new  "Opinion\n followed\n \{1-10\}"
		capture label var stair_status_today "Social\n position\n \{1-10\}"
		
	* label secondary_4_3 vars
	capture label var stair_status_future 		"Expected\n social\n status"
	capture label var stair_satis_future 		"Expected\n life\n satisfaction"
	capture label var stair_status_child_30	"Expected\n child status\n (kids under 30)" 


	* label secondary_10 vars
	capture label var  dec_weight_index		"Decision\n weight\n index"
	capture label var  dec_psblty_index		"Decision\n possibility\n index"
	capture label var  prod_agency_index		"Productive\n agency\n index" 
	capture label var  rltn_quality_cond_index	"Relationship\n quality\n index" 

	capture label var  ctrl_earn_index 		"Controls\n earnings\n index" 
	capture label var  ctrl_hh_index 			"Controls\n HH resources\n index"
	capture label var  revs_sum_bohh_wempl 	"Benef. share\n of total HH\n revenues" // relabelled after listing this in intra-hh dynamics table

	capture label var  dec_weight_index_d		"Decision\n weight\n index"
	capture label var  dec_psblty_index_d		"Decision\n possibility\n index"
	capture label var  prod_agency_index_d		"Productive\n agency\n index" 
	capture label var  rltn_quality_index_d	"Relationship\n quality\n index" 
	
	// generate var if it doesn't exist
	capture gen filler = 1
	if _rc == 0 capture label var filler "Filler\n Column"

	* label secondary_10_1 subvars
	foreach var in dw_sin_0_ind dw_sin_1_ind dw_wid_0_ind dw_fam_1_ind ///
				   dw_age_1_ind dw_age_2_ind dw_age_3_ind  ///
				   dw_ind_7_0_bus dw_ind_7_1_bus  dw_ind_7_2_bus ///
								  dw_ind_7_1_bus2 dw_ind_7_2_bus2 ///
								  dw_ind_7_1_bus3 dw_ind_7_2_bus3 ///
				   dw_ind_7_0_ani dw_ind_7_1_ani  dw_ind_7_2_ani   ///
								  dw_ind_7_1_ani2 dw_ind_7_2_ani2 ///
								  dw_ind_7_1_ani3 dw_ind_7_2_ani3 { 
		capture label var `var'		"Decision\n weight\n index"
	}
	foreach var in dw_sin_0_ind_7 dw_sin_1_ind_7 dw_wid_0_ind_7 dw_age_1_ind_7 dw_age_2_ind_7 dw_age_3_ind_7 dw_fam_1_ind_7 { 
		capture label var `var'		"Decision\n index\n (vars 2-8)"
	}
	capture confirm variable dec_pow_earn // must always run original B.10.1 when running subtables
	if _rc == 0 {

		cap ds dec_pow_earn*
		if _rc == 0 {
			local labelthese `r(varlist)' 
			cap ds dec_pow_earn*_bl dec_pow_earn*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Own\n earnings\n influence \{1-3\}" 
			}
		}
		cap ds dec_pow_his_earn*
		if _rc == 0 {
			local labelthese `r(varlist)' 
			cap ds dec_pow_his_earn*_bl dec_pow_his_earn*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Partner's\n earnings\n influence \{1-3\}"
			} 
		}
		cap ds dec_pow_spend*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_spend*_bl dec_pow_spend*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Daily\n spending\n influence \{1-3\}"
			} 
		}
		cap ds dec_pow_large*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_large*_bl dec_pow_large*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Large\n purchases\n influence \{1-3\}"
			} 
		}
		cap ds dec_pow_fert*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_fert*_bl dec_pow_fert*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Family\n planning\n influence \{1-3\}"
			} 
		}
		cap ds dec_pow_care*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_care*_bl dec_pow_care*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Own\n healthcare\n influence \{1-3\}"
			}
		}
		cap ds dec_pow_edu*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_edu*_bl dec_pow_edu*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Child\n education\n influence \{1-3\}"
			}
		}
		cap ds dec_pow_ag*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_ag*_bl dec_pow_ag*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Agriculture\n influence \{1-3\}"
			}
		}
		cap ds dec_pow_liv*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_liv*_bl dec_pow_liv*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Livestock\n influence \{1-3\}"
			} 
		}
		cap ds dec_pow_bus*
		if _rc == 0 {	
			local labelthese `r(varlist)' 
			cap ds dec_pow_bus*_bl dec_pow_bus*_bd
			local butnotthese `r(varlist)'
			local labelthese : list labelthese - butnotthese
			foreach var in `labelthese' { 
				capture label var `var' 		"Off-farm\n business\n influence \{1-3\}"
			}
		}
	}
		* label secondary_10_1_2_1 vars
		capture label var dec_weight_index_1  		"Decision\n weight index\n approach 1"
		// same sub variables as before

		* label secondary_10_1_2_2 vars
		capture label var dec_weight_index_2_1 		"Decision\n weight index\n approach 2"
		*capture label var dec_weight_index_2_2		"Decision\n weight index\n approach 2.2"

	* label secondary_10_2 subvars
	capture label var dec_could_earn 	"Own\n earnings\n unil. power \{1-3\}"
	capture label var dec_could_spend 	"Daily\n spending\n unil. power \{1-3\}"
	capture label var dec_could_large 	"Large\n purchases\n unil. power \{1-3\}"
	capture label var dec_could_fert 	"Family\n planning\n unil. power \{1-3\}"
	capture label var dec_could_care 	"Own\n healthcare\n unil. power \{1-3\}"
		capture label var dec_could_earn_d 	"Own\n earnings\n unil. power \{1-3\}"
		capture label var dec_could_spend_d 	"Daily\n spending\n unil. power \{1-3\}"
		capture label var dec_could_large_d 	"Large\n purchases\n unil. power \{1-3\}"
		capture label var dec_could_fert_d 	"Family\n planning\n unil. power \{1-3\}"
		capture label var dec_could_care_d 	"Own\n healthcare\n unil. power \{1-3\}"
  	* label secondary_10_3 subvars
	capture label var emp_work 		"Benef. free\n to work\n \{0,1\}"
	capture label var crop_ctrl_dum 	"Benef. controls\n crop\n revenue \{0,1\}"
	capture label var bus2_ben_dum	 	"Beneficiary\n has a\n business \{0,1\}"
	capture label var ani_ben_dum 		"Benef. owns\n livestock\n \{0,1\}"
	capture label var ani_contr_ben_dum "Benef. controls\n livestock\n revenue \{0,1\}"
	capture label var sleep_prod_dum	"Benef. traveled\n for work\n \{0,1\}"
		capture label var emp_work_d 		"Benef. free\n to work\n \{0,1\}"
		capture label var crop_ctrl_dum_d 	"Benef. controls\n crop\n revenue \{0,1\}"
		capture label var bus2_ben_dum_d	"Benef. has\n a\n business \{0,1\}" // labelled in B8
		capture label var ani_ben_dum_d 	"Benef. owns\n livestock\n \{0,1\}"
		capture label var ani_contr_ben_dum_d 	"Benef. controls\n livestock\n revenue \{0,1\}"
		capture label var sleep_prod_dum_d	"Benef. travelled\n for work\n \{0,1\}"
	* label secondary_10_4_1 subvars
	capture label var rel_interest 	"Trusts\n partner\n \{1-4\}"
	capture label var rel_disagree	 	"Comfortable\n disagreeing with\n partner \{1-4\}"
	capture label var rel_disagree_cut "Disagrees with\n partner \{1-4\}\n cond. on (2)"
	capture label var emp_move 		"Household allows\n family visits\n \{0,1\}"
	capture label var emp_move_cut		"Household allows\n family visits \{0,1\}\n cond. on (2)"
		capture label var rel_interest_d 	"Trusts\n partner\n \{1-4\}"
		capture label var rel_disagree_d 	"Disagrees with\n partner \{1-4\}\n cond. on (2)"
		capture label var emp_move_d		"Household allows\n family visits \{0,1\}\n cond. on (2)"



* label downstream_1 vars

capture label var  dom_relation_index 		"Violence\n perceptions\n index"
capture label var  gender_attitudes_index	"Gender\n attitudes\n index"
capture label var  prod_act_index			"Activity\n perceptions\n index"

  	* label downstream_1_1 vars
	capture label var dom_burn_rvrs 	"Food violence\n is NOT OK\n \{0,1\}"
	capture label var dom_kids_rvrs 	"Children violence\n is NOT OK\n \{0,1\}"
	capture label var ten_violen_rvrs 	"Should NOT\n tolerate\n violence \{1-4\}"
	capture label var ten_men_rvrs 	"NOT only\n men should\n work \{1-4\}"
	capture label var ten_boys			"Should\n school\n girls \{1-4\}"

  	* label downstream_1_2 vars
	capture label var ten_tension "Know women\n with HH-tension\n \{0-10\}"
	capture label var vill_burn   "Women beaten\n for burning\n food \{1-4\}"
	capture label var vill_kids   "Women beaten\n for neglecting\n children \{1-4\}"

* label downstream_2 vars
capture label var  social_support_index	"Social\n support\n index" // C.2.1
capture label var  fin_supp_index_2 		"Financial\n support\n index" // C.2.2
capture label var  intrahh_vars_index 		"Intra-household\n dynamics\n index" // C.2.3a
	capture label var  partner_vars_index  "Partner\n dynamics\n index"
	capture label var  hh_vars_index 		"Household\n dynamics\n index" 
capture label var  soc_cohsn_index 		"Social cohesion\n and community\n closeness index" // C.2.3b
capture label var  collective_action_index "Collective\n action\n index" // C.2.4
  	* label downstream_2_1 vars
	capture label var role 				"No. of\n role\n models"
	capture label var soc_tips 			"No. of\n activity\n advisors"
	capture label var soc_tips_in 			"No. of\n activity\n mentees"
	capture label var soc_confl 			"No. of\n conflict\n advisors"
	capture label var soc_confl_in 		"No. of\n conflict\n mentees"
	capture label var other_market			"No. of\n market\n intermediaries"
  	* label downstream_2_2_1 and downstream_2_2_2 vars
	capture label var ce3_new 				"Village\n financial\n support \{1-4\}"
	capture label var ask_sum1_w 			"No. of\n financial\n supporters (1)" // winsorize siblings first
	capture label var ask_sum2_w 			"No. of\n financial\n supporters" // winsorize all
	capture label var accesstofunds_rvrs	"Fundraising\n probability\n \{1-4\}"
  	* label downstream_2_3 vars
	capture label var aff_ieff 			"Trusts\n village\n women \{1-4\}"
	capture label var for_trust_1 			"No. of\n trusted\n villagers \{1-10\}"
	capture label var enemy_rvrs  			"Don't\n have\n enemies \{1-4\}"
	capture label var tens_house_rvrs  	"Household\n tensions\n infrequent \{1-4\}"
	capture label var tens_comm_rvrs 		"Community\n tensions\n infrequent \{1-4\}"
	capture label var los1 				"Household\n inclusiveness\n \{1-4\}"
	capture label var los2 				"Community\n inclusiveness\n \{1-4\}"
	capture label var los3					"Partner\n inclusiveness\n \{1-4\}"

	* label psychosocial vars not in PAP
	capture label var scs3_new 			"Consider\n community opinions\n \{1-4\}"
	capture label var scs5_new_rvrs 		"Prefer to be\n diff. from community\n (reversed) \{1-4\}"
	capture label var tg1_new  			"Selflessly\n care for\n village \{1-4\}"
	capture label var tg4_new2 			"Respect\n household\n decisions \{1-4\}"
	capture label var interdependence_sum 	"Community\n interdependence\n (sum)"
	capture label var interdependence_index "Community\n interdependence\n (zscore)"
  	
	* label downstream_2_4 vars
	capture label var partic 				"No. of\n associations\n where member"
	capture label var soc_post 			"No. of\n association\n responsibilities"
	capture label var aut_fond_ppp_w 		"Community\n project\n donations (USD)"
	capture label var aut_fond_xof_w 		"Community\n project\n donations (FCFA)"
	capture label var aut_volu 			"Volunteering\n days"
	capture label var worktogether_new		"Works with\n community\n \{1-4\}"
	* label 2_5 vars
	capture label var soc_norms_index 		"Social\n norms\n index"
	capture label var dscrptv_norms_index  "Descriptive\n norms\n index"
	capture label var ten_travel 			"Know women\n travel freely\n \{0-10\}"
	capture label var ten_support 			"Know\n women\n vendors \{0-10\}"
	capture label var ten_loan 			"Know\n women\n with loans \{0-10\}"
	capture label var ten_new				"Know women\n who started\n activities \{0-10\}"
	capture label var prscrptv_norms_index "Prescriptive\n norms\n index"
	capture label var ten_mentravel_rvrs   "No. men who think\n women shd travel\n freely \{0-10\}"
	capture label var ten_menown_rvrs 		"No. men who think\n women shd have\n own work \{0-10\}"
	capture label var ten_womentravel_rvrs "No. women who think\n women shd travel\n freely \{0-10\}"
	capture label var ten_womenown_rvrs 	"No. women who think\n women shd have\n own work \{0-10\}"
}

if strpos("`section'", "__c3") > 0 | /// 
		 "`section'" == "mht" { // 
	
* label downstream_3_child vars (see reg_tables_other)
	foreach var in child_schl_d tag_child_school tag_girl_school tag_boy_school tag_yngkid_school tag_oldkid_school {
		capture label var `var' "Child\n attended\n school \{0,1\}"
	}
	foreach var in child_lab_index child_lev_lab_index child_lev_girl_index child_lev_boy_index child_lev_yng_index child_lev_old_index {
		capture label var `var' "Child\n labor\n index"
	}
	foreach var in child_days_bus tot_busdays_child tot_busdays_girl tot_busdays_boy tot_busdays_yng tot_busdays_old {
		capture label var `var' "Days\n spent in\n business"
	}
	foreach var in child_days_ag tot_agdays_child tot_agdays_girl tot_agdays_boy tot_agdays_yng tot_agdays_old {
		capture label var `var' "Days\n spent in\n agriculture"
	}
	foreach var in child_days_ani tot_livdays_child tot_livdays_girl tot_livdays_boy tot_livdays_yng tot_livdays_old {
		capture label var `var' "Days\n spent on\n livestock"
	}
	foreach var in child_hh_lab_index child_c_hh_lab_index child_c_hh_girl_index child_c_hh_boy_index child_c_hh_yng_index child_c_hh_old_index {
		capture label var `var' "Child\n chores\n index"
	}
	foreach var in child_laundry_d_hh child_laundry_d child_laundry_girl_d child_laundry_boy_d child_laundry_yng_d child_laundry_old_d {
		capture label var `var' "Child\n helped in\n washing \{0,1\}"
	}
	foreach var in child_shop_d_hh child_shop_d child_shop_girl_d child_shop_boy_d child_shop_yng_d child_shop_old_d {
		capture label var `var' "Child\n helped in\n shopping \{0,1\}"
	}
	foreach var in child_water_fire_d_hh child_waterfire_d child_waterfire_girl_d child_waterfire_boy_d child_waterfire_yng_d child_waterfire_old_d {
		capture label var `var' "Child got\n water or\n firewood \{0,1\}"
	}
	
* label all__c3_*z vars

	capture label var whz06_imp 		"Weight/ \n height\n z-score"
	capture label var whz06_imp_d  	"W/H\n index\n (1 if $<$ -2)"
	capture label var whz06_imp_m 		"W/H\n index\n (male)"
	capture label var whz06_imp_f 		"W/H\n index\n (female)"
	capture label var whz06_b1_imp 	"W/H\n index\n (6-18 months)"
	capture label var whz06_b2_imp 	"W/H\n index\n (18-30 months)"
	capture label var whz06_b3_imp 	"W/H\n index\n (30-42 months)"
	capture label var whz06_b4_imp 	"W/H\n index\n (42-59 months)"
	capture label var whz06_2017_imp 	"W/H\n index\n (panel children)"

	capture label var waz06_imp 		"Weight/age\n z-score\n (All FU children)"
	capture label var waz06_imp_d 	 	"W/A\n index\n (1 if $<$ -2)"
	capture label var waz06_imp_m  	"W/A\n index\n (male)"
	capture label var waz06_imp_f 		"W/A\n index\n (female)"
	capture label var waz06_b1_imp 	"W/A\n index\n (6-18 months)"
	capture label var waz06_b2_imp 	"W/A\n index\n (18-30 months)"
	capture label var waz06_b3_imp 	"W/A\n index\n (30-42 months)"
	capture label var waz06_b4_imp 	"W/A\n index\n (42-59 months)"
	capture label var waz06_2017_imp 	"W/A\n index\n (panel children)"

	capture label var haz06_imp 		"Height/age\n z-score\n (All FU children)"
	capture label var haz06_imp_d 		"H/A\n index\n (1 if $<$ -2)"
	capture label var haz06_imp_m  	"H/A\n index\n (male)"
	capture label var haz06_imp_f 		"H/A\n index\n (female)"
	capture label var haz06_b1_imp 	"H/A\n index\n (6-18 months)"
	capture label var haz06_b2_imp 	"H/A\n index\n (18-30 months)"
	capture label var haz06_b3_imp 	"H/A\n index\n (30-42 months)"
	capture label var haz06_b4_imp 	"H/A\n index\n (42-59 months)"
	capture label var haz06_2017_imp 	"H/A\n index\n (panel children)"
}

**------------------- PAP section: DESCRIPTIVE 
* label descriptive_1 vars	
if "`section'" == "all__d1" | ///
	"`section'" == "pap__d1" | /// 
	"`section'" == "mht" { // 
	capture label var  mem_n	 		"Number\n of household\n members"
	capture label var  equiv_n			"Number\n of adult\n equivalents"
	capture label var  depend_ratio	"Dependency\n ratio"
	capture label var  extend_ratio	"Extended\n family\n ratio"
	capture label var  baby_n			"Number\n of\n births"
	capture label var  earlychild_n 	"Number\n of kids\n age 0-5"
	capture label var  olderchild_n		"Number\n of kids\n age 6-14"
	capture label var  sleep_days_ben	"Nights\n spent outside\n home (benef.)"
	capture label var  sleep_days_chef	"Nights\n spent outside\n home (HH-head)"
}
* label descriptive_2 vars	
if "`section'" == "all__d2" | ///
	"`section'" == "pap__d2" | /// 
	"`section'" == "mht" { // 
	capture label var  time_wk_ben_nonag 		"Mins/week in\n off-farm\n business"
	capture label var  time_wk_ben_ag 			"Mins/week in\n agriculture"
	capture label var  time_wk_ben_study_coran "Mins/week\n studying for\n Koranic school"
	capture label var  time_wk_ben_study_trad 	"Mins/week\n studying for\n traditional school"
	capture label var  time_wk_ben_water 		"Mins/week spent\n retrieving\n water"
	capture label var  time_wk_ben_firewood 	"Mins/week spent\n gathering\n firewood"
	capture label var  time_wk_ben_laundry 	"Mins/week spent\n doing\n laundry"
	capture label var  time_wk_ben_shop		"Mins/week spent\n shopping"
}
if "`section'" == "all__d2_ext" {
	* label descriptive_2_ext vars	
	capture label var time_ben_nonag_d 		"Mins/week in\n off-farm\n business"
	capture label var time_ben_ag_d 			"Mins/week in\n agriculture"
	capture label var time_ben_study_coran_d 	"Mins/week\n studying for\n koranic school"
	capture label var time_ben_study_trad_d 	"Mins/week\n studying for\n traditional school"
	capture label var time_ben_water_d 		"Mins/week spent\n retrieving\n water"
	capture label var time_ben_firewood_d 		"Mins/week spent\n gathering\n firewood"
	capture label var time_ben_laundry_d 		"Mins/week spent\n doing\n laundry"
	capture label var time_ben_shop_d			"Mins/week spent\n shopping"
}
	
* label descriptive_3 vars
if "`section'" == "all__d3" | "`section'" == "pap__d3" {
	capture label var tot_ben_bus_days  	"Days spent\n in off-farm\n business"
	capture label var tot_ben_ag_days   	"Days spent\n in\n agriculture"
	capture label var tot_benchef_emp_days "Days spent\n in salaried\n employment"
	capture label var tot_ben_liv_days  	"Days spent\n raising\n livestock" 
}
if strpos("`section'", "pap__d3_new") > 0 | /// nothing different except for ag input index
	"`section'" == "mht" {
	capture label var na_bus2_op_wn_12 	"No. of\n household\n businesses"
	capture label var bus_assval_98_ppp	"Business\n asset\n value (USD)" 	 // currency
	capture label var tot_ben_bus_days  	"Days spent\n in off-farm\n business (Benef.)"
	capture label var ag_plot_ha			"Area of\n cultivated\n crops (ha)"
	capture label var ag_input_index 		"Agricultural\n inputs\n index"
	capture label var ag_sale_ppp_imp_98	"Sale\n value\n (yearly, USD)"
	capture label var tot_ben_ag_days   	"Days spent\n in\n agriculture (Benef.)"
	capture label var ani_val_98_ppp  		"Livestock\n asset\n value (USD)"  	 // currency
	capture label var tot_ben_liv_days  	"Days spent\n raising\n livestock (Benef.)" 
}
if "`section'" == "pap__d3_days" {
	// these will get two column headers in pap__d3_days
	capture label var tot_ben_bus_days  "Benef."
	capture label var tot_hh_bus_days   "Household" 
	capture label var tot_hhlb_bus_days "Household\n less benef."
	capture label var tot_bohh_bus_days "Benef./\n household"

	capture label var tot_ben_ag_days   "Benef."
	capture label var tot_hh_ag_days    "Household"
	capture label var tot_hhlb_ag_days  "Household\n less benef."
	capture label var tot_bohh_ag_days  "Benef./\n household"

	capture label var tot_benchef_emp_days "Benef.\n and HH head"
	capture label var tot_ben_emp_days     "Benef."
	capture label var tot_hhlb_emp_days    "Household\n less benef."
	capture label var tot_bohh_emp_days    "Benef./\n household"

	capture label var tot_ben_liv_days  "Benef."
	capture label var tot_hh_liv_days   "Household"
	capture label var tot_hhlb_liv_days "Household\n less benef."
	capture label var tot_bohh_liv_days "Benef./\n household"
}
if "`section'" == "pap__d3_daysa" { // HH
	capture label var tot_hh_bus_days		"Days spent in off-farm business (HH)"
	capture label var tot_hh_ag_days   	"Days spent in agriculture (HH)"
	capture label var tot_hh_liv_days  	"Days spent raising livestock (HH)"
	capture label var tot_benchef_emp_days "Days spent in salaried employment (HH)"			 
}
if "`section'" == "pap__d3_daysb" { // benef
	capture label var tot_ben_bus_days		"Days spent in off-farm business (Benef.)"
	capture label var tot_ben_ag_days  	"Days spent in agriculture (Benef.)"
	capture label var tot_ben_liv_days 	"Days spent raising livestock (Benef.)"
	capture label var tot_ben_emp_days 	"Days spent in salaried employment (Benef.)"		
}
if "`section'" == "mht" { // no need for line breaks, \n
	capture label var tot_ben_bus_days		"Days spent in off-farm business (Benef.)"
	capture label var tot_hh_bus_days		"Days spent in off-farm business (HH)"
	capture label var tot_ben_ag_days  	"Days spent in agriculture (Benef.)"
	capture label var tot_hh_ag_days   	"Days spent in agriculture (HH)"
	capture label var tot_ben_liv_days 	"Days spent raising livestock (Benef.)"
	capture label var tot_hh_liv_days 		"Days spent raising livestock (HH)"
	capture label var tot_ben_emp_days  	"Days spent in salaried employment (Benef.)"		
	capture label var tot_benchef_emp_days "Days spent in salaried employment (HH)"			 
}


if "`section'" == "all__d4" | "`section'" == "pap__d4" | /// 
	"`section'" == "mht"  {
	* label descriptive_4 vars
	capture label var ag_any					"Cultivated\n any crop\n \{0,1\}"
	// capture label var ag_r_harv 			"Harvested\n annual\n crop \{0,1\}"
	capture label var ag_plot_ha				"Area of\n cultivated\n crops (ha)"
	capture label var ag_harvest_12_ppp_imp_98 "Harvest\n value\n (yearly, USD)"
	capture label var ag_harvest_12_xof_imp_98 "Harvest\n value\n (yearly, FCFA)"
	capture label var ag_plot_ha_diff 			"Change in\n area cultivated\n from baseline"
	capture label var ag_r_lost				"Lost\n annual\n crop \{0,1\}"
	capture label var ag_r_fert_d				"Used\n chemical\n fertilizer \{0,1\}"
	capture label var ag_r_pest_d				"Used\n pytosanitary\n products \{0,1\}"
	capture label var ag_r_paidlab_d			"Used\n paid\n labor \{0,1\}"
	capture label var ag_r_seeds_d				"Purchased\n seeds \{0,1\}"
	capture label var ag_input_index 			"Agricultural\n inputs\n index"
	capture label var ag_r_sold				"Sold\n annual\n crop \{0,1\}"
	capture label var ag_sale_ppp_imp_98		"Sale\n value\n (yearly, USD)"
	capture label var ag_sale_xof_imp_98		"Sale\n value\n (yearly, FCFA)"
	capture label var ag_r_comm				"Commercial-\n ization \%\n (10)/(3)=(11)"
	if "`stack_opt'" == "vertical" 	capture label var ag_r_comm	"Commercial-\n ization \%"
	if 	"`section'" == "mht" {
		capture label var ag_r_comm				"Commercialization \%"
	}
}

	* label descriptive_4_1_1 and descriptive_4_1_2 vars
if "`section'" == "all__d4_1" | "`section'" == "all__d4_2" | ///
   "`section'" == "all__d4_2d1_descr" | "`section'" == "all__d4_2d2_descr" {

	capture confirm variable ag_c1_harvest_imp_ppp
	if _rc == 0 {
	
		qui ds ag_c*_harvest_imp_ppp
		local mylist `r(varlist)'

		local max_num 0 // initiate max_num to collect max crop num
		local remove ag_cother_harvest_imp_ppp
		local mylist : list mylist - remove
		foreach var in `mylist' {
			local stub = substr("`var'", 5, strlen("`var'")-5+1)	
			local num = substr("`stub'", 1, strlen("`stub'")-16)
			dis "`num'"
			if (`num' > `max_num') local max_num `num' // collect max num
		}
		dis "`max_num'"

	
		// 47 categories straight from the survey
		foreach var of varlist ag_c1_harvest_imp_ppp - ag_c`max_num'_harvest_imp_ppp { 
			local stub = substr("`var'", 5, strlen("`var'")-5+1)	
			local stub = substr("`stub'", 1, strlen("`stub'")-16)
			
			if 		("`stub'" == "1") local crop_name Mil
			else if ("`stub'" == "2") local crop_name Sorghum 
			else if ("`stub'" == "3") local crop_name Rice-Paddy
			else if ("`stub'" == "4") local crop_name Corn
			else if ("`stub'" == "5") local crop_name Nutsedge
			else if ("`stub'" == "6") local crop_name Wheat
			else if ("`stub'" == "7") local crop_name Fonio
			else if ("`stub'" == "8") local crop_name Cowpea
			else if ("`stub'" == "9") local crop_name Groundnut
			else if ("`stub'" == "10") local crop_name Peanut
			else if ("`stub'" == "11") local crop_name Okra
			else if ("`stub'" == "12") local crop_name Waraw
			else if ("`stub'" == "13") local crop_name Sesame
			else if ("`stub'" == "14") local crop_name Cassava
			else if ("`stub'" == "15") local crop_name Sweet Potato
			else if ("`stub'" == "16") local crop_name Potato
			else if ("`stub'" == "17") local crop_name Pepper
			else if ("`stub'" == "18") local crop_name Ginger
			else if ("`stub'" == "19") local crop_name Clove
			else if ("`stub'" == "20") local crop_name Mint
			else if ("`stub'" == "21") local crop_name Spinach
			else if ("`stub'" == "22") local crop_name Celery
			else if ("`stub'" == "23") local crop_name Parsley
			else if ("`stub'" == "24") local crop_name Chili
			else if ("`stub'" == "25") local crop_name Melon
			else if ("`stub'" == "26") local crop_name Watermelon
			else if ("`stub'" == "27") local crop_name Lettuce
			else if ("`stub'" == "28") local crop_name Cabbage
			else if ("`stub'" == "29") local crop_name Tomato
			else if ("`stub'" == "30") local crop_name Carrot
			else if ("`stub'" == "31") local crop_name Jaxatu
			else if ("`stub'" == "32") local crop_name Eggplant
			else if ("`stub'" == "33") local crop_name Onion
			else if ("`stub'" == "34") local crop_name Cucumber
			else if ("`stub'" == "35") local crop_name Squash
			else if ("`stub'" == "36") local crop_name Garlic
			else if ("`stub'" == "37") local crop_name Green Beans
			else if ("`stub'" == "38") local crop_name Calabash
			else if ("`stub'" == "39") local crop_name Radish
			else if ("`stub'" == "40") local crop_name Turnip
			else if ("`stub'" == "41") local crop_name Leeks
			else if ("`stub'" == "42") local crop_name Amaranth
			else if ("`stub'" == "43") local crop_name Cotton
			else if ("`stub'" == "44") local crop_name Beets
			else if ("`stub'" == "45") local crop_name Peas
			else if ("`stub'" == "46") local crop_name Taro
			else if ("`stub'" == "47") local crop_name Yam

			capture label var  `var' "`crop_name'"
		}
	}
	capture label var  ag_cother_harvest_imp_ppp "Other"
	
	capture confirm var ag_*_c?_d
	if _rc == 0 {
		qui ds ag_*_c?_d ag_*_c??_d
		foreach var in `r(varlist)' { 
			local i = strlen("`var'")
			local stub = substr("`var'", 7, strlen("`var'")-8)

				if 		("`stub'" == "1") local crop_name Mil
				else if ("`stub'" == "2") local crop_name Sorghum 
				else if ("`stub'" == "3") local crop_name Rice-\n Paddy
				else if ("`stub'" == "4") local crop_name Corn
				else if ("`stub'" == "5") local crop_name Nutsedge
				else if ("`stub'" == "6") local crop_name Wheat
				else if ("`stub'" == "7") local crop_name Fonio
				else if ("`stub'" == "8") local crop_name Cowpea
				else if ("`stub'" == "9") local crop_name Groundnut
				else if ("`stub'" == "10") local crop_name Peanut
				else if ("`stub'" == "11") local crop_name Okra
				else if ("`stub'" == "12") local crop_name Waraw
				else if ("`stub'" == "13") local crop_name Sesame
				else if ("`stub'" == "14") local crop_name Cassava
				else if ("`stub'" == "15") local crop_name Sweet\n Potato
				else if ("`stub'" == "16") local crop_name Potato
				else if ("`stub'" == "17") local crop_name Pepper
				else if ("`stub'" == "18") local crop_name Ginger
				else if ("`stub'" == "19") local crop_name Clove
				else if ("`stub'" == "20") local crop_name Mint
				else if ("`stub'" == "21") local crop_name Spinach
				else if ("`stub'" == "22") local crop_name Celery
				else if ("`stub'" == "23") local crop_name Parsley
				else if ("`stub'" == "24") local crop_name Chili
				else if ("`stub'" == "25") local crop_name Melon
				else if ("`stub'" == "26") local crop_name Watermelon
				else if ("`stub'" == "27") local crop_name Lettuce
				else if ("`stub'" == "28") local crop_name Cabbage
				else if ("`stub'" == "29") local crop_name Tomato
				else if ("`stub'" == "30") local crop_name Carrot
				else if ("`stub'" == "31") local crop_name Jaxatu
				else if ("`stub'" == "32") local crop_name Eggplant
				else if ("`stub'" == "33") local crop_name Onion
				else if ("`stub'" == "34") local crop_name Cucumber
				else if ("`stub'" == "35") local crop_name Squash
				else if ("`stub'" == "36") local crop_name Garlic
				else if ("`stub'" == "37") local crop_name Green\n Beans
				else if ("`stub'" == "38") local crop_name Calabash
				else if ("`stub'" == "39") local crop_name Radish
				else if ("`stub'" == "40") local crop_name Turnip
				else if ("`stub'" == "41") local crop_name Leeks
				else if ("`stub'" == "42") local crop_name Amaranth
				else if ("`stub'" == "43") local crop_name Cotton
				else if ("`stub'" == "44") local crop_name Beets
				else if ("`stub'" == "45") local crop_name Peas
				else if ("`stub'" == "46") local crop_name Taro
				else if ("`stub'" == "47") local crop_name Yam

				capture label var  `var' "`crop_name'"
		}
	}
}
	
if "`section'" == "all__d4_3" {
	* label descriptive_4_3 vars
/* commented out 6/11/2021. Was interfering with MHT labeling script
	capture label var ag_harvest_12_ppp_imp 	"Harvest\n value\n (meth1: no wins.)"
	capture label var ag_harvest_12_ppp_imp_95 "Harvest\n value\n (meth1: 95p)"
// 	capture label var ag_harvest_12_ppp_imp_98 "Harvest\n value\n (yearly, USD)" // labelled above
	capture label var ag_harvest_12_ppp_imp_99 "Harvest\n value\n (meth1: 99p)"
	capture label var ag_harvest_12_ppp 		"Harvest\n value\n (method 2)"
	capture label var ag_harvest_12_ppp_95 	"Harvest\n value\n (meth2: 95p)"
	capture label var ag_harvest_12_ppp_98 	"Harvest\n value\n (meth2: 98p)"
	capture label var ag_harvest_12_ppp_99 	"Harvest\n value\n (meth2: 99p)"
*/
}

* label descriptive_5 vars
if "`section'" == "all__d5" | "`section'" == "pap__d5" | /// 
	"`section'" == "mht" | "`section'" == "commsupport" {
	capture label var  tot_ani_count_tlu	   "Livestock\n count\n (TLU)"
	capture label var  ani_val_98_ppp  	   	   "Livestock\n asset\n value (USD)"  	 // currency
	capture label var  tot_ani_n_diff_tlu	   "Change\n in livestock\n count (yearly, TLU)"
	capture label var  tot_ani_botval_ppp 	   "Livestock\n purchase\n value (yearly, USD)"
	capture label var  tot_ani_botval_xof 	   "Livestock\n purchase\n value (yearly, FCFA)"
	capture label var  tot_ani_hh_contr_ppp   "Livestock\n revenue\n (yearly, USD)"	// currency
}
	// hh shares
if "`section'" == "all__d5_descr" {
	capture label var ani_1 "Bulls"
	capture label var ani_2 "Cows or\n Heifers"
	capture label var ani_3 "Calves"
	capture label var ani_4 "Muttons"
	capture label var ani_5 "Sheep"
	capture label var ani_6 "Goats"
	capture label var ani_7 "Camels"
	capture label var ani_8 "Donkeys"
	capture label var ani_9 "Horses\n or Mares"
	capture label var ani_10 "Hens or\n Chickens"
	capture label var ani_11 "Guinea\n Fowls"
}
* label descriptive_6 vars
if "`section'" == "all__d6" | ///
	"`section'" == "pap__d6" | /// 
	"`section'" == "mht" { // 
	capture label var  lend_mem_times 	"Intra-household\n lending\n frequency"
	capture label var  lend_still_ppp	"Intra-household\n lending\n outstanding debt (USD)"
	capture label var  lend_still_xof	"Intra-household\n lending\n outstanding debt (FCFA)"
}
* b12 measures 		
if strpos("`section'", "all__b12") > 0  {
	capture label var tontineacec 		"Member in\n savings group\n \{0,1\}"
	capture label var ton_hh 			"Savings group:\n tontine\n \{0,1\}" // labelled in b6 as well
	capture label var avec_hh 			"Savings group:\n AVEC\n \{0,1\}" 	 // labelled in b6 as well
	capture label var othersave_hh 	"Savings\n group:\n other\n \{0,1\}"
	
	capture label var got_vid 			"ADMIN:\n Saw video\n \{0,1\}"
	capture label var mes_video_d 				 "Saw video\n \{0,1\}"
	
	capture label var mes_avec_d 		"Participated\n in AVEC group\n \{0,1\}"

	capture label var got_acv 			"ADMIN:\n Life skills\n training \{0,1\}"
	capture label var mes_acv_d 				 "Life skills\n training \{0,1\}"
	capture label var mes_acv_days 	"Life skills\n training\n days"
	
	capture label var mes_germe_d 		"Business skills\n training\n \{0,1\}"
	capture label var mes_germe_days 	"Business skills\n training\n days"
	capture label var mes_coach_d 		"Coach\n visit\n \{0,1\}"
	capture label var mes_coach_n 		"No. of\n coach\n visits"
	
	capture label var got_bourse 		"ADMIN:\n Received\n subsidy \{0,1\}"
	capture label var mes_bourse_d 			 "Received\n subsidy \{0,1\}"
	capture label var got_bourse_amt   "ADMIN:\n Subsidy\n amount (USD)"
	capture label var mes_bourse_ppp 			 "Subsidy\n amount (USD)"
	
}
// programs
if "`section'" == "all__b13"  {
	capture label var prog_1 "Cereal\n aid" 
	capture label var prog_2 "Food or\n cash for\n work" 
	capture label var prog_3 "Child\n food aid"
	capture label var prog_4 "Cash transfers/\n saftey net" 
	capture label var prog_5 "Cash transfers\n excluding\n safety net" 
	capture label var prog_6 "Entrepreneurship\n support\n program" 
	capture label var prog_7 "Rainfall\n insurance" 
	capture label var prog_8 "Health\n program" 
	capture label var prog_9 "Health\n insurance"
	capture label var prog_10 "Savings and\n banking\n assistance"
	capture label var prog_11 "Nutrition\n program"
	capture label var prog_12 "Other\n aid"
}
if "`section'" == "all__b13_2"  {
	capture label var prog_1_ppp "Cereal\n aid" 
	capture label var prog_2_ppp "Food or\n cash for\n work" 
	capture label var prog_3_ppp "Child\n food aid"
	capture label var prog_4_ppp "Cash transfers/\n saftey net" 
	capture label var prog_5_ppp "Cash transfers\n excluding\n safety net" 
	capture label var prog_6_ppp "Entrepreneurship\n support\n program" 
	capture label var prog_7_ppp "Rainfall\n insurance" 
	capture label var prog_8_ppp "Health\n program" 
	capture label var prog_9_ppp "Health\n insurance"
	capture label var prog_10_ppp "Savings and\n banking\n assistance"
	capture label var prog_11_ppp "Nutrition\n program"
	capture label var prog_12_ppp "Other\n aid"
}
if "`section'" == "all__b14"  {
	capture label var ctrans_times   	"Number of\n transfers\n received (3 years)"
	capture label var ctrans_total_ppp "Value of\n tranfsers\n (3 years, USD)"
}

* label migration vars 1
if "`section'" == "all__migrate" {
	capture label var d_moved_wpar 	"Moved\n village w. \n parents (ext.)"
	capture label var tot_moved_wpar 	"Moved\n village w. \n parents (int.)"
	capture label var d_moved_other 	"Moved\n village other\n reason (ext.)"
	capture label var tot_moved_other  "Moved\n village other\n reason (int.)"
	capture label var d_moved_migr 	"Moved\n country\n (ext.)"
	capture label var tot_moved_migr 	"Moved\n country\n (int.)"
	capture label var d_moved_any 		"Moved\n village or\n country (ext.)"
	capture label var tot_moved_any 	"Moved\n village or\n country (int.)"
}
* label migration vars 2
if "`section'" == "all__migrate2" {
	capture label var hh_has_migration  "Intl.\n migration\n (entire household)"
	capture label var hh_benef_migrated "Intl.\n migration\n (beneficiary)"
	capture label var has_exode 		 "Temporary\n exodus"
}

if "`section'" == "all__fish" {
	capture label var fish_eatval_ppp   "Fish\n consumed\n (yearly, USD)"
	capture label var fish_sellval_ppp  "Fish\n sold\n (yearly, USD)"
	capture label var fish_expndval_ppp "Fishing\n expenses\n (yearly, USD)"
}

* label extras vars
capture label var married_ben		"Beneficiary\n is\n married"
capture label var child_n  	"No. of\n children\n (ages 0-14)"
capture label var girl_n_child "No. of\n girls\n (ages 0-14)"
capture label var workage_n 	"No. of\n working-age \n adults (ages 15-65)"
capture label var pben_edu 	"Beneficiary\n education\n (0-12 years)"
capture label var hh_any_tel	"Anyone in\n HH has\n telephone"
capture label var tot_hh_pro_day_eq_ppp	"Business\n profits\n (daily, USD/capita)"
capture label var tot_hh_pro_day_eq_xof	"Business\n profits\n (daily, FCFA/capita)"


if "`section'" == "commsupport" {
	capture label var consum_2_day_eq_ppp_trim "Gross\n consumption\n (daily, USD/adult eq.)"
	capture label var FIES_rvrs_raw		"Food\n security"
	capture label var hh_ass_count_ovr_98  "Total\n asset\n count (overlapping assets)"
	capture label var hh_ass_count_tv_98   "TV\n count"
	capture label var all_income_div		"No. of\n income\n sources"
	capture label var ment_hlth_index_trim "Mental\n health\n index"
	capture label var less_depressed 		"Non-depressed\n days in last week 10 Qs {0-70}"
	
	capture label var pben_edu 			"Beneficiary\n education\n (0-12 years)"
	capture label var tot_ani_count_tlu	"Livestock\n count\n (TLU)"
	capture label var na_bus2_op_wn_12 	"No. of\n household off-farm\n businesses"
	capture label var hou_mar_min 			"Minutes to market"
}

if "`section'" == "icc" {
	capture label var consum_2_day_eq_ppp 	"Gross\n consumption\n (daily, USD/adult eq.)"	// currency
	capture label var FIES_rvrs_raw		"Food\n security"
	capture label var na_bus2_op_wn_12 	"No. of\n household off-farm\n businesses"
	capture label var tot_ben_rev30_ppp 	"Business\n revenue\n (monthly, USD)"	// currency
	capture label var bus_assval_98_ppp	"Business\n asset\n value (USD)" 	 // currency
	capture label var tot_ben_bus_days  	"Days spent\n in off-farm\n business"
	capture label var ag_plot_ha			"Area of\n cultivated\n crops (ha)"
	capture label var ag_harvest_12_ben_ppp_imp "Harvest\n value\n (yearly, USD)"		// currency
	capture label var ag_sale_ppp_imp_98	"Crop sale\n value\n (yearly, USD)"
	capture label var tot_ben_ag_days   	"Days spent\n in\n agriculture"
	capture label var tot_empl_rev12_ben_ppp 	 "Wage\n earnings\n (yearly, USD)"		// currency
	capture label var ton_saving_ppp  	    "Tontine\n savings\n (yearly, USD)" // currency
}
if "`section'" == "outliers" {
	capture label var consum_2_day_eq_ppp 	   		"Consumption yrly USD"
	capture label var consum_2_day_eq_ppp_out 		"Consumption PCTILE"
	capture label var tot_hh_rev12_ppp 			"Bus rev yrly USD"
	capture label var tot_hh_rev12_ppp_out 		"Bus rev PCTILE"
	capture label var tot_hh_pro12_ppp 			"Bus pro yrly USD"
	capture label var tot_hh_pro12_ppp_out 		"Bus pro PCTILE"
	capture label var bus2_invest_ppp 				"Bus invst yrly USD"
	capture label var bus2_invest_ppp_out 			"Bus invst PCTILE"
	capture label var tot_cost_all_ppp 			"Bus cost yrly USD"
	capture label var tot_cost_all_ppp_out 		"Bus cost PCTILE"
	capture label var bus_assval_98_ppp 			"Bus assets USD"
	capture label var bus_assval_98_ppp_out 		"Bus assets PCTILE"
	capture label var ag_harvest_12_ppp_imp_98 	"Harvest val yrly USD"
	capture label var ag_harvest_12_ppp_imp_98_out "Harvest val PCTILE"
	capture label var ag_val_98_ppp 				"Ag assets USD"
	capture label var ag_val_98_ppp_out 			"Ag assets PCTILE"
	capture label var tot_ani_hh_contr_ppp 		"Livestock rev yrly USD"
	capture label var tot_ani_hh_contr_ppp_out 	"Livestock rev PCTILE"
	capture label var tot_ani_botval_ppp 			"Livestock purchase val USD"
	capture label var tot_ani_botval_ppp_out 		"Livestock purchase val PCTILE"
	capture label var ani_val_98_ppp 				"Livestock assets yrly USD"
	capture label var ani_val_98_ppp_out 			"Livestock assets PCTILE"
	capture label var tot_empl_2rev12_hh_ppp 		"HH Wage earnings yrly USD"
	capture label var tot_empl_2rev12_hh_ppp_out 	"HH Wage earnings PCTILE"
	capture label var hh_ass_count_hh_98 			"HH asset ct"
	capture label var hh_ass_count_hh_98_out 		"HH asset ct PCTILE"
	capture label var tot_sav3_ppp 				"Savings"
	capture label var tot_sav3_ppp_out 			"Savings PCTILE"
	capture label var tot_cred_out_ppp 			"HH brrwing yrly USD"
	capture label var tot_cred_out_ppp_out 		"HH brrwing PCTILE"
	capture label var tot_trans_in_ppp 			"HH transfers in yrly USD"
	capture label var tot_trans_in_ppp_out 		"HH transfers in PCTILE"
	capture label var ctrans_total_xof 			"Cash transfers yrly USD"
	capture label var ctrans_total_xof_out 		"Cash transfers PCTILE"
	capture label var prog_total_xof 				"Other programs yrly USD"
	capture label var prog_total_xof_out 			"Other programs PCTILE"

}
if "`section'" == "pap__acts" {
	capture label var ag_r_entraide_d 	"Used group labor on farm"
	capture label var ag_r_paidlab_d   	"Used hired labor on farm"
	capture label var hh_has_bus_empl  	"Has employees in off-farm activity"
	capture label var ag_plotnotown 	"Cultivated a plot not owned by household"
	capture label var trans_fam  		"Household received private money"
	capture label var trans_fam_send 	"Household sent private money"
	capture label var tens_comm_rvrs 	"Community\n tensions\n infrequent \{1-4\}"

} 
if "`section'" == "pap__shocks" {
	capture label var shock5  "Rising prices\n of agricultural\n inputs \{0,1\}"
	capture label var shock6  "Fall in the price\n of agricultural\n products \{0,1\}"
	capture label var shock7  "Rising food\n prices\n \{0,1\}"
}

} // end novarabbrev
set varabbrev on, permanently

end



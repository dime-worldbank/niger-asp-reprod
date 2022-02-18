/*
This script computes the alphas shown in Niger's Supplementary Info

Date created: 12/13/2021
Version 15.1

Outline:
** 1) list vargroups mentioned in SI section 3
** 2) calculate alphas using -alpha- command			   


*/
pause on
use "${joint_fold}/Data/allrounds_NER_hh.dta", clear
keep if phase == 1 // FU1


** 1) list vargroups mentioned in SI section 3
local id hh
asp_012_list_vars_ner_usd, id(`id')  // Niger tables (usd)

// extract locals from r(.)
local tables_in_asp_012 `r(all_sections)'
foreach section in `tables_in_asp_012' {
	local `section' `r(`section')'	// copy old components
}

// Psychological well-being indices
local mental_health cd1_good cd2_good cd3_new_good cd4_good cd5 ///
				   cd6_new_good cd7_good cd8 cd9_good cd10_new_good ///
				   srq1_good srq3_good srq4_good srq5_good ///
				   stair_satis_today stairs_peace health_ment_z
					  
local self_efficacy gse1 gse2 gse3 gse4 gse7 gse8 gse9 ros4

local future_expcttns stair_status_future stair_satis_future stair_status_child_30
local social_stand stair_good_today stair_respect_new stair_opinion_new stair_status_today

// Social well-being indices
local fin_support ce3_new ask_sum2_w accesstofunds_rvrs
local soc_support role soc_tips soc_tips_in soc_confl soc_confl_in other_market
local decrptv_norms ten_support ten_loan ten_new ten_travel
	local prescrp_norms ten_mentravel_rvrs ten_menown_rvrs ///
						ten_womentravel_rvrs ten_womenown_rvrs
	local soc_norms 	ten_support ten_loan ten_new ten_travel ///
						ten_mentravel_rvrs ten_menown_rvrs ///
						ten_womentravel_rvrs ten_womenown_rvrs
local social_cohes aff_ieff for_trust_1 enemy_rvrs tens_comm_rvrs los2 /// old
					 scs3_new scs5_new_rvrs tg1_new tg4_new2
local collective_act partic soc_post aut_fond_ppp_w aut_volu worktogether_new					 
					 

// collect sections
local sections mental_health self_efficacy future_expcttns ///
			   fin_support soc_support ///
			   social_stand soc_norms decrptv_norms prescrp_norms ///
			   social_cohes collective_act
			   
			   
** 2) calculate alphas using -alpha- command			   
foreach varset in `sections' {
	local thislist ``varset''
	qui alpha `thislist' if treatment == 0
	dis "`varset' section"
	dis "	`: word count `thislist'' variables, alpha = `: di %9.2fc `r(alpha)''"
}





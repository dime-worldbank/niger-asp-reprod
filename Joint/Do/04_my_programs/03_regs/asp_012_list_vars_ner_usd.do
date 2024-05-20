/* This program generates lists of variables to be shown in tables.
Individual lists are returned but a list of lists (all_sections) is also returned.
*/


capture prog drop asp_012_list_vars_ner_usd
program define asp_012_list_vars_ner_usd, rclass

	nois dis "	- Running do-file: asp_012_list_vars_ner_usd"

 * Standardized variables and indices
 return local all__std1 consum_2_day_eq_ppp_std FIES_rvrs_raw_std ///
						revs_sum_hh_wempl_std revs_sum_ben_wempl_std ///
						ment_hlth_index gse_index soc_cohsn_index ///
						ctrl_earn_index ctrl_hh_index
 
 * Primary variables and FCS from secondary 1.2
 return local all__a1 consum_2_day_eq_ppp FIES_rvrs_raw fcs
 return local pap__a1 consum_2_day_eq_ppp FIES_rvrs_raw fcs

	 * Primary variables and FCS from secondary 1.2
	 return local pap__a1b2 consum_2_day_eq_ppp ///
							FIES_rvrs_raw ///
							tot_ben_rev12_ppp ///
							ag_harvest_12_ben_ppp_imp ///
							tot_ani_ben_contr_ppp ///
							tot_hhlb_rev12_ppp ///
							ag_harvest_12_hhlb_ppp_imp ///
							tot_ani_hhlb_contr_ppp
	 
	 return local all__a1_time 	consum_2_erly_ppp 	FIES_rvrs_raw_erly 	FCS_erly ///
								consum_2_late_ppp 	FIES_rvrs_raw_late 	FCS_late //
	 return local all__a1_hte  	consum_2_day_eq_ppp ment_hlth_index	  
								   		  
	 * Primary variable: yearly consumption breakdown
	 return local all__a1_year  consum_2_year_ppp /// breakdown is only for mixed method
								 food_2_year_ppp ///
								 nonfood_year_ppp ///
								 edu_year_ppp health_year_ppp ///
								 cel_year_ppp repairs_year_ppp
	 return local all__a2   FIES_rvrs_raw FIES_rvrs_latent FIES_rvrs_gsem ///
							hunger_rvrs1 hunger_rvrs2 hunger_rvrs3 hunger_rvrs4 hunger_rvrs5 hunger_rvrs6 hunger_rvrs7 hunger_rvrs8
							
 * Secondary 2 Beneficiary productive revenue 
 return local all__b2_ben 	tot_ben_rev30_ppp 		  ag_harvest_12_ben_ppp_imp ///
							tot_empl_rev12_ben_ppp    tot_ani_ben_contr_ppp 

	 * Secondary 2.2 Beneficiary productive revenue 
	 return local all__b2_hh 	tot_hh_rev30_ppp	  ag_harvest_12_ppp_imp_98 ///
								tot_empl_rev12_hh_ppp tot_ani_hh_contr_ppp
	 * supplementary table on revenues
	 return local pap__b2_set   revs_sum_ben_wempl /// sum of beneficiary revs
								revs_sum_hh_wempl /// sum
								tot_ben_rev12_ppp /// off-farm bus
								tot_hh_rev12_ppp /// off-farm bus
								ag_harvest_12_ben_ppp_imp /// agriculture
								ag_harvest_12_ppp_imp_98 /// agriculture
								tot_ani_ben_contr_ppp /// livestock
								tot_ani_hh_contr_ppp /// livestock
								tot_empl_2rev12_ben_ppp /// scaled wages
								tot_empl_2rev12_hh_ppp // scaled wages
								
	 return local pap__b2_sethh revs_sum_hh_wempl /// sum
								tot_hh_rev12_ppp /// off-farm bus
								ag_harvest_12_ppp_imp_98 /// agriculture
								tot_ani_hh_contr_ppp /// livestock
								tot_empl_2rev12_hh_ppp // scaled wages
	 return local pap__b2_setben revs_sum_ben_wempl /// sum of beneficiary revs
								tot_ben_rev12_ppp /// off-farm bus
								ag_harvest_12_ben_ppp_imp /// agriculture
								tot_ani_ben_contr_ppp /// livestock
								tot_empl_2rev12_ben_ppp // scaled wages								
								
	 return local all__b2_set   revs_sum_ben_wempl /// sum of beneficiary revs
								revs_sum_hh_wempl /// same for HH
								tot_ben_rev12_ppp /// off-farm bus
								tot_hh_rev12_ppp /// same for HH
								tot_empl_2rev12_ben_ppp /// scaled wages
								tot_empl_2rev12_hh_ppp  // same for HH
								
	return local pap__a2_foot tot_ben_pro12_ppp tot_hh_pro12_ppp // yearly profits for footnote 49
								

 * Secnd 3. Household income diversification
 return local all__b3 all_income_div div_n_na_12 div_crop_types div_empl12_n div_ani act_main_nonag
 return local pap__b3 all_income_div div_n_na_12 div_crop_types div_empl12_n div_ani

 * Sec 4Z. Psychological well-being Zindex
 return local all__b4z ment_hlth_index social_worth_index future_expct_30_index 
 return local pap__b4z ment_hlth_index gse_index 		  future_expct_30_index
 
	* Sec 4 Psychological well-being components
	return local all__b4_1 ment_hlth_index less_depressed less_disability stair_satis_today stairs_peace health_ment_z
	return local pap__b4_1 ment_hlth_index less_depressed less_disability stair_satis_today stairs_peace health_ment_z
	return local all__b4_2 social_worth_index gse_sum social_stand_sum
// 	return local pap__b4_2  // see pap__b4_2a below
	return local all__b4_3_1 future_expct_30_index stair_status_future stair_satis_future stair_status_child_30
	return local pap__b4_3_1 future_expct_30_index stair_status_future stair_satis_future stair_status_child_30

		// stand_sum moved to C2 on 5/12/2021 (Catherine request)
		return local pap__b4_2a gse_index 		gse1 gse2 gse3 gse4 gse7 gse8 gse9 ros4
		return local pap__b4_2b soc_stand_index stair_good_today stair_respect_new stair_opinion_new stair_status_today

 
 * Sec 5. Assets 98 p
 return local all__b5 ag_val_98_ppp bus_assval_98_ppp ani_val_98_ppp hh_ass_index // (WP + PP request to remove ani_val_98_ppp: 9/21/2020)
 return local pap__b5 ag_val_98_ppp bus_assval_98_ppp // moved hh_ass_index to b6 on 5/13/2021
	* sec 5. Assets 95 p 
	return local all__b5_95p ag_val_95_ppp ani_val_95_ppp bus_assval_95_ppp hh_ass_count_hh_95 

 * Sec 6. Financial Engagement 
 return local all__b6 ton_or_avec_hh tot_sav3_ppp tot_dep_out_ppp ///
					  tot_cred_out_ppp loan_out_ppp ///
					  tot_trans_in_ppp tot_trans_out_ppp 
 return local all__b6_ext ton_or_avec_hh ton_hh avec_hh // same as b6 but w/ enum controls (see spec later)
 return local all__b6_enum ton_or_avec_hh tot_sav3_ppp tot_dep_out_ppp tot_cred_out_ppp loan_out_ppp ///
						   tot_trans_in_ppp tot_trans_out_ppp
 
 return local pap__b6 		ton_or_avec_hh tot_sav3_ppp tot_dep_out_ppp hh_ass_index // moved hh_ass_index here on 5/13/2021
 return local pap__b6_annex tot_cred_out_ppp loan_out_ppp /// loans
							tot_trans_in_ppp tot_trans_out_ppp // transfers
 return local pap__b6_suppl ton_or_avec_hh ton_or_avec_hh_fe ton_hh avec_hh // supplementary material

 return local all__b6_ass_1 hh_ass_count_ben_98  hh_ass_count_hh_98 hh_ass_count_hhlb_98 /// hh assets
							tot_ani_count_tlu_ben tot_ani_count_tlu tot_ani_count_tlu_hhlb // livestock
 
											
							
	
 * Sec 7. Savings goals and behavior 
 return local all__b7 save_share_d save_goal save_goal_ppp save_goal_specific save_productive
 return local pap__b7 save_share_d save_goal save_goal_ppp save_goal_specific save_productive
	 * Sec 7_1 productive savings broken down 
	 return local all__b7_1 save_productive ///
					 save_productive_1 save_productive_2 save_productive_3 save_productive_4 save_productive_5 ///
					 save_productive_6 save_productive_7 save_productive_8 save_productive_9 save_productive_10
					 
 * Sec 8. Non-Agricultural Activities
 return local pap__b8_hh	bus2_dum 	///
							act_main_nonag 		///
							na_bus2_op_wn_12  	///
							bus2_invest_ppp 	///
							tot_hh_rev30_ppp 	/// beneficiary investments only as in PAP
							tot_hh_pro30_ppp 	///
							health_bus_ind 		//  includes tot_hh_rev and profits not from PAP
					
 return local all__b8_hh 	bus2_dum  		 	///
							na_bus2_op_wn_12 	///
							tot_busmths_uniq    ///
							div_n_na_12 		///
							bus2_invest_ppp 	///
							tot_hh_rev12_ppp    /// yearly instead
							tot_hh_pro12_ppp 	/// yearly
							bus_assval_98_ppp   
							
 return local all__b8_ben   bus2_ben_dum 		 ///
							na_bus2_op_wn_12_ben /// 							
							tot_busmths_uniq_ben /// months
							div_n_na_12_ben 	 ///
							bus2_invest_ppp 	 /// already ben
							tot_ben_rev12_ppp 	 /// yearly rev
							tot_ben_pro12_ppp 	 /// yearly pro
							bus_assval_98_ben_ppp // assets ben
							
// 							act_main_nonag 		///
// 							bus2_within_12_dum 	///
// 							bus2_abandon_24_dum ///
// 							bus2_profits_btm_ppp ///
// 							tot_bus_least_ppp 	///
// 							tot_bus_most_ppp 	///
// 							tot_bus2_ppl_uniq   ///

									

 * Sec 9. Healthy Activity Practices
 return local all__b9 health_bus

 * Sec 9.2 Healthy Activity Practices broken down
 return local all__b9_1 health_bus prac_inp_know prac_best_know prac_goal ///
				 prac_sup_chang prac_sup_neg prac_sup_comp prac_comp1 prac_cust ///
				 prac_credit_record_d prac_freq_pub_d
						   
 * Sec 10 Decision making Z-index
 return local all__b10z ctrl_earn_index ctrl_hh_index
 return local pap__b10z intrahh_vars_index dom_relation_index ctrl_earn_index revs_sum_bohh_wempl ctrl_hh_index 
 
	 * Sec 10.1 Decision making Components
	 return local all__b10_1 dec_weight_index ///
					  dec_pow_earn dec_pow_his_earn dec_pow_spend dec_pow_large ///
					  dec_pow_fert dec_pow_care dec_pow_edu dec_pow_ag dec_pow_liv dec_pow_bus
	 * Sec 10.2 Decision making Components
	 return local all__b10_2 dec_psblty_index ///
					  dec_could_earn dec_could_spend dec_could_large ///
					  dec_could_fert dec_could_care
	 * Sec 10.3 Decision making Components
	 return local all__b10_3 prod_agency_index ///
					  emp_work crop_ctrl_dum bus2_ben_dum ani_ben_dum ani_contr_ben_dum sleep_prod_dum
	 * Sec 10.4 Decision making Components
	 return local all__b10_4 rltn_quality_cond_index ///
						rel_interest rel_disagree_cut emp_move_cut

	 * Sec 10.5 
	 local b105_holder ctrl_earn_index 								  ///
					   dec_pow_earn dec_could_earn dec_pow_ag dec_pow_liv dec_pow_bus /// B.10.1 + B.10.2
					   emp_work crop_ctrl_dum bus2_ben_dum ani_ben_dum ani_contr_ben_dum sleep_prod_dum // B.10.3
						
		// variable not collected in MRT
		if "$ph" == "fu2" & "$cty" == "MRT" {
			local omit emp_work emp_work_d
			local b105_holder : list b105_holder - omit
		}
		return local all__b10_5 `b105_holder'
		return local pap__b10_5 `b105_holder'
	 
	 * Sec 10.6
	 return local all__b10_6 ctrl_hh_index ///
					  dec_pow_spend dec_could_spend ///
					  dec_pow_large dec_could_large ///
					  dec_pow_fert  dec_could_fert  ///
					  dec_pow_care  dec_could_care  ///
					  dec_pow_his_earn 				///
					  dec_pow_edu 					//  B.10.1 + B.10.2
	 return local pap__b10_6 ctrl_hh_index ///
					  dec_pow_spend dec_could_spend ///
					  dec_pow_large dec_could_large ///
					  dec_pow_fert  dec_could_fert  ///
					  dec_pow_care  dec_could_care  ///
					  dec_pow_his_earn 				///
					  dec_pow_edu 					//  B.10.1 + B.10.2
					  
						
		// table B10 subcomponent extensive margins
		 return local all__b10_1_d dec_weight_index_d ///
							dec_pow_earn_d dec_pow_his_earn_d ///
							dec_pow_spend_d dec_pow_large_d ///
							dec_pow_fert_d dec_pow_care_d ///
							dec_pow_edu_d dec_pow_ag_d dec_pow_liv_d dec_pow_bus_d						   
		 return local all__b10_2_d dec_psblty_index_d ///
							dec_could_earn_d dec_could_spend_d dec_could_large_d ///
							dec_could_fert_d dec_could_care_d
		 return local all__b10_3_d prod_agency_index_d ///
							emp_work_d crop_ctrl_dum_d bus2_ben_dum_d ///
							ani_ben_dum_d ani_contr_ben_dum_d sleep_prod_dum_d
		 return local all__b10_4_d rltn_quality_index_d ///
							rel_disagree_d rel_interest_d emp_move_d


		 
 * Sec 11 Coping strategies  
 return local all__b11_1_1 shock_covar shock_aglivdis shock_price shock_idio shock_other
 
 return local all__b11_1_2 shock1 shock3 shock7 shock9 shock4 shock2 shock10 shock13 ///
						   shock5 shock8 shock12 shock6 shock11
 return local all__b11_1_descr shock1 shock3 shock7 shock9 shock4 shock2 shock10 shock13 ///
							   shock5 shock8 shock12 shock6 shock11

							   
 return local all__b11_2_1	shock_worst_covar shock_worst_aglivdis shock_worst_price shock_worst_idio shock_worst_other

 return local all__b11_2_2 	shock_worst1 shock_worst7 shock_worst3 shock_worst9 shock_worst4 ///
							shock_worst2 shock_worst10 shock_worst13 shock_worst8 ///
							shock_worst12 shock_worst5 shock_worst6 shock_worst11
 return local all__b11_2_descr shock_worst1 shock_worst7 shock_worst3 shock_worst9 shock_worst4 ///
							shock_worst2 shock_worst10 shock_worst13 shock_worst8 ///
							shock_worst12 shock_worst5 shock_worst6 shock_worst11
 
 return local all__b11_3_a ever_rev ever_live ever_stock ever_save ever_consum ever_asset ever_educ 
 return local pap__b11_3_a ever_rev ever_live ever_stock ever_save ever_consum ever_asset ever_educ
 return local all__b11_4 	ynot_rev_prefer_o ynot_live_prefer_o ynot_stock_prefer_o ///
						ynot_save_prefer_o ynot_consum_prefer_o ynot_asset_prefer_o ynot_educ_prefer_o 
 return local all__b11_3_b ever_rev_cond ever_live_cond ever_stock_cond ever_save_cond ///
						ever_consum_cond ever_asset_cond ever_educ_cond // conditional on B.11.4 != 1
 
 return local all__b11_5_1 strat_o_income strat_o_assets strat_o_food strat_o_savings ///
						strat_o_nonfood strat_o_migrate strat_o_aid_frm strat_o_aid_inf ///
						strat_o_god strat_o_none strat_o_other
 return local all__b11_5_2 ever_rev ever_save ever_consum ever_live other_strat14 /// reordered from highest "==1" to lowest
						ever_stock other_strat11 ever_educ other_strat7 other_strat16 /// includes addtnl strat_other entries
						other_strat10 other_strat12 other_strat9 ever_asset other_strat13 ///
						other_strat8 other_strat0 other_strat17 other_strat15
						
 return local all__b11_6_1 strat_b_income strat_b_assets strat_b_food strat_b_savings ///
						strat_b_nonfood strat_b_migrate strat_b_aid_frm strat_b_aid_inf ///
						strat_b_god strat_b_none strat_b_other
 return local all__b11_6_2 other_best0 other_best1 other_best2 other_best3 other_best4 ///
						other_best5 other_best6 other_best7 other_best8 other_best9 ///
						other_best10 other_best11 other_best12 other_best13 ///
						other_best14 other_best15 other_best16 other_best17
						
 // telephone coping
 return local all__b11_7 telsho_cons telsho_nonalim telsho_healedu telsho_cred telsho_save_all						
						
 return local all__b12 	mes_avec_d /// savings
						got_vid /// admin video
						mes_video_d /// video
						got_acv /// admin LCA training
						mes_acv_d 	 mes_acv_days /// LCA trai
						mes_germe_d  mes_germe_days /// IGA training
						mes_coach_d  mes_coach_n /// coach visits
						got_bourse mes_bourse_d /// admin subsidy dummy
						got_bourse_amt  mes_bourse_ppp // subsidy amt
						 						
						
						
 * Down 1 Gender perceptions and norms  
 return local all__c1z gender_attitudes_index dom_relation_index  
 // no pap__c1z because only c1_1 component remains
	 * Down 1.2 Gender perceptions and norms  
	 return local all__c1_1 gender_attitudes_index ///
							dom_burn_rvrs dom_kids_rvrs ten_violen_rvrs ten_men_rvrs ten_boys
	 return local pap__c1_1 gender_attitudes_index ///
							dom_burn_rvrs dom_kids_rvrs ten_violen_rvrs ten_men_rvrs ten_boys
	 return local all__c1_2 dom_relation_index ///
							ten_tension_rvrs vill_burn_rvrs vill_kids_rvrs // moved travel to c.2.5 (04/07/2021)
	 return local pap__c1_2 dom_relation_index ///
							ten_tension vill_burn vill_kids // moved travel to c.2.5 (04/07/2021) & items reversed on 5/13/2021
							
	// moved travel to c.1.3 to c.2.5 (04/07/2021)
 
 * Down 2 Social well-being  
 return local all__c2z  social_support_index ///
						fin_supp_index_2 /// 
						intrahh_vars_index ///
						soc_cohsn_index ///
						collective_action_index ///
						soc_norms_index
 return local pap__c2z  fin_supp_index_2 /// 
						social_support_index ///
						soc_stand_index  ///
						soc_norms_index ///
						soc_cohsn_index ///
						collective_action_index //
						
	 * Down 2 Social well-being  
	 return local all__c2_1 social_support_index ///
					role soc_tips soc_tips_in soc_confl soc_confl_in other_market
	 return local all__c2_2 fin_supp_index_2 ce3_new ask_sum2_w accesstofunds_rvrs // fin_supp_f_index_2
	 
// 	 return local all__c2_3 social_cohesion_index ///
// 					   aff_ieff for_trust_1 enemy_rvrs tens_house_rvrs tens_comm_rvrs los1 los2 los3
	        local c2_3_a_holder intrahh_vars_index ///
					   partner_vars_index rel_disagree rel_interest los3 /// partner vars
					   hh_vars_index 	  emp_move tens_house_rvrs los1 // hh vars
	 return local all__c2_3_b soc_cohsn_index ///
					   aff_ieff for_trust_1 enemy_rvrs tens_comm_rvrs los2  /// c.2.3b
					   scs3_new scs5_new_rvrs tg1_new tg4_new2
	 return local all__c2_4 collective_action_index ///
					   partic soc_post aut_fond_ppp_w aut_volu worktogether_new
					
	 // appendix copies
	 return local pap__c2_1 social_support_index ///
							role soc_tips soc_tips_in soc_confl soc_confl_in other_market
	 return local pap__c2_2 fin_supp_index_2 ce3_new ask_sum2_w accesstofunds_rvrs // fin_supp_f_index_2

	 return local pap__c2_3_b soc_cohsn_index ///
						    aff_ieff for_trust_1 enemy_rvrs tens_comm_rvrs los2  /// c.2.3b
						    scs3_new scs5_new_rvrs tg1_new tg4_new2
	 return local pap__c2_4 collective_action_index ///
							partic soc_post aut_fond_ppp_w aut_volu worktogether_new
	 return local pap__c2_5 soc_norms_index ///
							dscrptv_norms_index ///
							ten_support ten_loan ten_new ten_travel ///
							prscrptv_norms_index ///
							ten_mentravel_rvrs ten_menown_rvrs ten_womentravel_rvrs ten_womenown_rvrs

		// variable not collected in MRT
		if "$ph" == "fu2" & "$cty" == "MRT" {
			local omit emp_move
			local c2_3_a_holder : list c2_3_a_holder - omit
		}
		return local all__c2_3_a `c2_3_a_holder'
		return local pap__c2_3_a `c2_3_a_holder'

 * Down 3 Child Labor // bring in downstream_3_child from reg_tables child
	 return local pap__c3_child tag_child_school ///
								 child_lev_lab_index ///
								 child_c_hh_lab_index ///
								 whz06_imp
							
		 * children breakdown
		 return local pap__c3_deets tot_busdays_child tot_agdays_child tot_livdays_child ///
							 child_waterfire_d child_laundry_d child_shop_d
		 return local all__c3_hh 	  child_schl_d ///
							  child_lab_index child_days_bus child_days_ag child_days_ani ///
							  child_hh_lab_index child_water_fire_d_hh child_laundry_d_hh child_shop_d_hh 
		 return local all__c3_child   tag_child_school ///
							  child_lev_lab_index tot_busdays_child tot_agdays_child tot_livdays_child ///
							  child_c_hh_lab_index child_waterfire_d child_shop_d child_laundry_d
		 return local all__c3_girl    tag_girl_school ///
							  child_lev_girl_index tot_busdays_girl tot_agdays_girl	tot_livdays_girl ///
							  child_c_hh_girl_index child_waterfire_girl_d child_shop_girl_d child_laundry_girl_d
		 return local all__c3_boy	  tag_boy_school ///
							  child_lev_boy_index tot_busdays_boy tot_agdays_boy tot_livdays_boy ///
							  child_c_hh_boy_index child_waterfire_boy_d child_shop_boy_d child_laundry_boy_d
		 return local all__c3_yng	  tag_yngkid_school ///
							  child_lev_yng_index tot_busdays_yng tot_agdays_yng tot_livdays_yng ///
							  child_c_hh_yng_index child_waterfire_yng_d child_shop_yng_d child_laundry_yng_d
		 return local all__c3_old	  tag_oldkid_school ///
							  child_lev_old_index tot_busdays_old tot_agdays_old tot_livdays_old ///
							  child_c_hh_old_index child_waterfire_old_d child_shop_old_d child_laundry_old_d
 
 
		* child wasting breakdown
		 //				   everyone  dummy <-2   males		 females	 agegroup1    agegroup2    agegroup3    agegroup4    panel kids    
		 return local all__c3_whz whz06_imp whz06_imp_d whz06_imp_m whz06_imp_f whz06_b1_imp whz06_b2_imp whz06_b3_imp whz06_b4_imp whz06_2017_imp
		 return local all__c3_waz waz06_imp waz06_imp_d waz06_imp_m waz06_imp_f waz06_b1_imp waz06_b2_imp waz06_b3_imp waz06_b4_imp waz06_2017_imp
		 return local all__c3_haz haz06_imp haz06_imp_d haz06_imp_m haz06_imp_f haz06_b1_imp haz06_b2_imp haz06_b3_imp haz06_b4_imp haz06_2017_imp

		 
 * descriptive_1 HH Structure
 return local all__d1 mem_n equiv_n depend_ratio extend_ratio baby_n sleep_days_ben sleep_days_chef
 return local pap__d1 mem_n equiv_n depend_ratio extend_ratio baby_n sleep_days_ben sleep_days_chef
 * Descr 2 Beneficiary Time Use
 return local all__d2 time_wk_ben_nonag time_wk_ben_ag time_wk_ben_study_coran ///
					 time_wk_ben_study_trad time_wk_ben_water time_wk_ben_firewood ///
					 time_wk_ben_laundry time_wk_ben_shop
 return local pap__d2 time_wk_ben_nonag time_wk_ben_ag time_wk_ben_study_coran ///
					 time_wk_ben_study_trad time_wk_ben_water time_wk_ben_firewood ///
					 time_wk_ben_laundry time_wk_ben_shop

	 * Descr 2 Beneficiary Time Use (Extensive Margins)
	 return local all__d2_ext time_ben_nonag_d time_ben_ag_d time_ben_study_coran_d ///
							 time_ben_study_trad_d time_ben_water_d time_ben_firewood_d ///
							 time_ben_laundry_d time_ben_shop_d

 * descriptive_3 Beneficiary Labor Participation
 return local all__d3 tot_ben_bus_days tot_ben_ag_days tot_benchef_emp_days tot_ben_liv_days
 * descriptive_3 Beneficiary Labor Participation
 return local pap__d3 tot_ben_bus_days tot_ben_ag_days tot_benchef_emp_days tot_ben_liv_days // changed on 5/11/2021 after Patrick's email
 return local pap__d3_new 	na_bus2_op_wn_12 	/// bus final ordering determined 5/13/2021 morning call with Patrick
							bus_assval_98_ppp 	///
							tot_ben_bus_days 	/// 
							ag_plot_ha 			/// ag
							ag_input_index 		///
							ag_sale_ppp_imp_98 	/// 
							tot_ben_ag_days 	/// 
							ani_val_98_ppp 		/// liv
							tot_ben_liv_days 	//
							
 return local pap__d3_newa 	na_bus2_op_wn_12 	/// bus final ordering determined 5/13/2021 morning call with Patrick
							bus_assval_98_ppp 	///
							tot_ben_bus_days 	//
 return local pap__d3_newb  ag_plot_ha 			/// ag
							ag_input_index 		///
							ag_sale_ppp_imp_98 	/// 
							tot_ben_ag_days 	/// 
							ani_val_98_ppp 		/// liv
							tot_ben_liv_days 	//

 return local pap__d3_days 	tot_ben_bus_days tot_hh_bus_days 	  /// days benef and hh
							tot_ben_ag_days  tot_hh_ag_days  	  /// 
							tot_ben_liv_days tot_hh_liv_days      /// 
							tot_ben_emp_days tot_benchef_emp_days 
 return local pap__d3_daysa tot_hh_bus_days /// days  hh
							tot_hh_ag_days  /// 
							tot_hh_liv_days /// 
							tot_benchef_emp_days 
 return local pap__d3_daysb tot_ben_bus_days /// days benef
							tot_ben_ag_days  /// 
							tot_ben_liv_days /// 
							tot_ben_emp_days 
 
 * Descr 4 Agriculture
 return local all__d4 ag_any 	/// 1 Production removed ag_r_harv
					   ag_plot_ha /// 2
					   ag_harvest_12_ppp_imp_98 /// 4
					   ag_r_lost /// 7
					   ag_r_seeds_d /// 13 Input use
					   ag_r_fert_d /// 10 
					   ag_r_pest_d /// 11
					   ag_r_paidlab_d /// 12
					   ag_r_sold /// 8 Output commercialization
					   ag_sale_ppp_imp_98 /// 5 
					   ag_r_comm // 9
 return local pap__d4  ag_any 	/// 1 Production removed ag_r_harv
					   ag_plot_ha /// 2
					   ag_harvest_12_ppp_imp_98 /// 4
					   ag_r_lost /// 7
					   ag_r_seeds_d /// 13 Input use
					   ag_r_fert_d /// 10 
					   ag_r_pest_d /// 11
					   ag_r_paidlab_d /// 12
					   ag_input_index ///
					   ag_r_sold /// 8 Output commercialization
					   ag_sale_ppp_imp_98 /// 5 
					   ag_r_comm // 9


 * Descr 4 Agriculture
 return local all__d4_3 ag_harvest_12_ppp_imp ///
						 ag_harvest_12_ppp_imp_99 ///
						 ag_harvest_12_ppp_imp_98 ///
						 ag_harvest_12_ppp_imp_95 ///
						 ag_harvest_12_ppp ///
						 ag_harvest_12_ppp_99 ///
						 ag_harvest_12_ppp_98 ///
						 ag_harvest_12_ppp_95

 * Descr 5 Livestock 
 return local all__d5 tot_ani_count_tlu ani_val_98_ppp	  	/// stock D5.3 B5.2 (WP + PP request to remove div_ani: 9/21/2020)
			   tot_ani_n_diff_tlu tot_ani_botval_ppp  /// flow D5.1 D5.2
			   tot_ani_hh_contr_ppp //  revenues B2.4
 return local pap__d5 tot_ani_count_tlu ani_val_98_ppp	  	/// stock D5.3 B5.2 (WP + PP request to remove div_ani: 9/21/2020)
			   tot_ani_n_diff_tlu tot_ani_botval_ppp  /// flow D5.1 D5.2
			   tot_ani_hh_contr_ppp //  revenues B2.4
	// hh shares (livestock)
	return local all__d5_descr ani12_1 ani12_2 ani12_3 ani12_4 ani12_5 ani12_6 ///
							   ani12_7 ani12_8 ani12_9 ani12_10 ani12_11
	return local all__d5_ihs ihs_tot_ani_botval_ppp ///
							ihs_tot_ani_ben_contr_ppp ///
							ihs_tot_ani_hh_contr_ppp


 * Descr 6 Inter-HH Lending
 return local all__d6 lend_mem_times lend_still_ppp
 return local pap__d6 lend_mem_times lend_still_ppp


 return local all__migrate  d_moved_wpar tot_moved_wpar d_moved_other ///
							tot_moved_other d_moved_migr tot_moved_migr ///
							d_moved_any tot_moved_any
 return local all__migrate2 hh_has_migration hh_benef_migrated has_exode


 * spillovers
 return local pap__acts ag_r_entraide_d ag_r_paidlab_d ///
						hh_has_bus_empl ag_plotnotown ///
						trans_fam trans_fam_send ///
						tens_comm_rvrs

 return local pap__shocks shock5 shock6 shock7
 
 

	return local all_sections   all__a1 ///
								all__std1 ///
								pap__a1 ///
								pap__a1b2 ///
								all__a1_time ///
								all__a1_qtile ///
								all__a1_year ///
								all__a1_sen ///
								all__a1_hte ///
								all__a2 ///
								all__b2_ben ///
								pap__b2_ben ///
								all__b2_set ///
								pap__b2_set ///
								pap__b2_setben ///
								pap__b2_sethh ///
								all__b2_hh ///
								all__b3 ///
								pap__b3 ///
								all__b4z ///
								pap__b4z ///
								all__b4_1 ///
								pap__b4_1 ///
								all__b4_2 ///
								pap__b4_2a ///
								pap__b4_2b ///
								all__b4_3_1 ///
								pap__b4_3_1 ///
								all__b5 ///
								pap__b5 ///
								all__b5_95p ///
								all__b6 ///
								pap__b6 ///
								all__b6_ext ///
								all__b6_enum ///
								pap__b6_suppl ///
								pap__b6_annex ///
								all__b6_ass_1 ///
								all__b6_brk ///
								all__b7 ///
								pap__b7 ///
								all__b7_1 ///
								pap__b8_hh ///
								all__b8_hh ///
								all__b8_ben ///
								all__b8_hh_cond ///
								all__b8_ben_cond ///
								all__b9 ///
								all__b9_1 ///
								all__b10z ///
								pap__b10z ///
								all__b10_1 ///
								all__b10_2 ///
								all__b10_3 ///
								all__b10_4 ///
								all__b10_5 ///
								pap__b10_5 ///
								all__b10_6 ///
								pap__b10_6 ///
								all__b10_1_d ///
								all__b10_2_d ///
								all__b10_3_d ///
								all__b10_4_d ///
								all__b10_1_2_1 ///
								all__b10_1_2_2 ///
								all__b10_1_3 ///
								all__b10_1_4 ///
								all__b10_1_s0 ///
								all__b10_1_s1 ///
								all__b10_1_w0 ///
								all__b10_1_w1 ///
								all__b10_1_f1 ///
								all__b10_1_a1 ///
								all__b10_1_a2 ///
								all__b10_1_a3 ///
								all__b10_1_7_0b ///
								all__b10_1_7_1b ///
								all__b10_1_7_1b2 ///
								all__b10_1_7_1b3 ///
								all__b10_1_7_2b ///
								all__b10_1_7_2b2 ///
								all__b10_1_7_2b3 ///
								all__b10_1_7_0a ///
								all__b10_1_7_1a ///
								all__b10_1_7_1a2 ///
								all__b10_1_7_1a3 ///
								all__b10_1_7_2a ///
								all__b10_1_7_2a2 ///
								all__b10_1_7_2a3 ///
								all__b11_1_1 ///
								all__b11_1_2 ///
								all__b11_1_descr ///
								all__b11_2_1 ///
								all__b11_2_2 ///
								all__b11_2_descr ///
								all__b11_3_a ///
								pap__b11_3_a ///
								all__b11_4 ///
								all__b11_3_b ///
								all__b11_5_1 ///
								all__b11_5_2 ///
								all__b11_6_1 ///
								all__b11_6_2 ///
								all__b11_7 ///
								all__b12 ///
								all__c1z ///
								pap__c1z ///
								all__c1_1 ///
								pap__c1_1 ///
								all__c1_2 ///
								pap__c1_2 ///
								all__c1_3 ///
								pap__c1_3 ///
								all__c2z ///
								pap__c2z ///
								all__c2_1 ///
								all__c2_2 ///
								all__c2_3_a ///
								all__c2_3_b ///
								all__c2_4 ///
								pap__c2_1 ///
								pap__c2_2 ///
								pap__c2_3_a ///
								pap__c2_3_b ///
								pap__c2_4 ///
								pap__c2_5 ///
								pap__c3_child ///
								pap__c3_deets ///
								all__c3_hh ///
								all__c3_child ///
								all__c3_girl ///
								all__c3_boy ///
								all__c3_yng ///
								all__c3_old ///
								all__c3_whz ///
								all__c3_waz ///
								all__c3_haz ///
								all__d1 ///
								pap__d1 ///
								all__d2 ///
								pap__d2 ///
								all__d2_ext ///
								all__d3 ///
								pap__d3 ///
								pap__d3_new ///
								pap__d3_newa ///
								pap__d3_newb ///
								pap__d3_days ///
								pap__d3_daysa ///
								pap__d3_daysb ///
								all__d4 ///
								pap__d4 ///
								all__d4_3 ///
								all__d5 ///
								pap__d5 ///
								all__d5_descr ///
								all__d5_ihs ///
								all__d6 ///
								pap__d6 ///
								all__migrate ///
								all__migrate2 ///
								pap__a2_foot ///
								pap__acts ///
								pap__shocks



end

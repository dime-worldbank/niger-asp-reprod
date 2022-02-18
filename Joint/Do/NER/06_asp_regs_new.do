/*

Niger main tables
This script produces
	Tables 1-6
	Tables SI.6 - SI.12
	Tables SI.14 - SI.26

****  1. Import data
****  2. Collect variables in sections
****  2.1 collect all locals from above in different sections. Each of these produces a table
****  3 Label Baseline Outcomes	

****  4. Run Regressions and generate output 
****  4.1 Define table specific var labels, titles, and footnotes
****  4.2 Extract variable labels, run regressions, and store statistics
****  4.2.1 Extract variable labels
****  4.2.2 Run regressions
****  4.2.3 Store group averages and error bars
****  4.2.4 Manual output: send stats to asp_050_PAP_tables
****  4.2.5 Export stats as dta when all sections done


*/	

pause on 
local currency usd 
matrix drop _all

nois dis "Running do-file: asp_regs_new.do"



********************************************************************************
****  1. Import data
use "${joint_fold}/Data/allrounds_NER_hh.dta", clear
local id hh // used to export stats

	
********************************************************************************
****  2. Collect variables in sections

asp_012_list_vars_ner_usd // return list: r(all_sections), r(section)

// extract locals from r(.)
local tables_in_asp_012 `r(all_sections)'
foreach section in `tables_in_asp_012' {
	local `section' `r(`section')'	// copy old components
}


********************************************************************************
****  2.1 collect all locals from above in different sections. Each of these produces a table

local PAP_index_list   pap__b4z  pap__c2z pap__b10z /// ED tables
					   pap__b4_1 pap__b4_2a pap__b4_3_1 /// SI tables 
					   pap__c2_2 pap__c2_1 pap__b4_2b pap__c2_5 pap__c2_3_b pap__c2_4 /// SI tables 
					   pap__b10_5 pap__b10_6 pap__c2_3_a pap__c1_2 // SI tables 
					   /**/

local PAP_continuous_list   all__std1 /// main tables  
							pap__a1 /// ED tables ----
							pap__b2_setben /// ED tables
							pap__b2_sethh /// ED tables
							pap__d3_newa /// ED tables
							pap__d3_newb /// ED tables
							pap__b8_hh /// SI tables ----
							pap__d4 /// SI tables 
							pap__d5 /// SI tables 
							pap__d3_daysa /// SI tables 
							pap__d3_daysb /// SI tables 
							pap__b6 /// SI tables 
							pap__b6_suppl /// SI tables 
							pap__b5 /// SI tables 
							pap__acts //
							/**/
							

local lists `PAP_continuous_list' `PAP_index_list'

// assert table is actually listed in asp_012_list_vars
local listsmissing : list lists - tables_in_asp_012
if "`listsmissing'" != "" {
	dis as error "Tables I want to produce but that aren't yet listed in local all_sections in asp_012_list_vars.do: "
	foreach thistable in `listsmissing' {
		nois dis as error " - `thistable'"
	}
	stop // go to asp_012_list_vars and add `listsmissing' to local all_sections"
}



********************************************************************************
****  3 Label Baseline Outcomes	
	
* label BL outcomes 
qui ds *_bl *_bd
foreach var in `r(varlist)' {
	capture label var `var' "variable @ Baseline"
}



********************************************************************************
****  4. Run Regressions and generate output 

	eststo clear 		 	// for estout 
	local row_n_long = 0 	
	local pap_section_n = 1 // for est_collect_long
	local fam = 1 			// for p_collect_long
	
	
	* loop on each variable within each section, saving a table for each section
	foreach pap_section in `lists' {

		eststo clear 				  // for estout
		local var_count = 1 		  // for suest estadd command
		local var_count_tot : word count ``pap_section''
		local no_of_sections : word count `lists' // for est_collect_long

		// sanity check
		if "``pap_section''" == "" {
			nois dis as error "Table `pap_section' is not defined in asp_012"
			stop 
		}
		
		
		************************************************************************
		****  4.1 Define table specific var labels, titles, and footnotes

		//---------------------------------
		// label variables conditional on section
		qui asp_013_label_vars_ner, section("`pap_section'") stack_opt(vertical)
		
			
		//---------------------------------
		// Label tables based on subset and PAP section. Used in title() in esttab below

		// main table
		if 		("`pap_section'" == "all__std1") 		local table_title "Table 2: Intent-to-Treat Estimates for Main Outcomes (Standardized Effects)"
		
		// Primary outcomes
		if 		("`pap_section'" == "pap__a1") 			local table_title "Extended Data Table 1: Consumption and Food Security"
		
		// Income-generating activities and diversification
		else if ("`pap_section'" == "pap__b2_sethh")	local table_title "Extended Data Table 2a: Household Revenues"
		else if ("`pap_section'" == "pap__b2_setben")	local table_title "Extended Data Table 2b: Beneficiary Revenues"
		else if ("`pap_section'" == "pap__d3_newa")		local table_title "Extended Data Table 3a: Off-Farm Businesses"			
		else if ("`pap_section'" == "pap__d3_newb")		local table_title "Extended Data Table 3b: Agriculture and Livestock Activities"			
		else if ("`pap_section'" == "pap__b4z")			local table_title "Extended Data Table 4: Psychological Well-Being"
		else if ("`pap_section'" == "pap__c2z")			local table_title "Extended Data Table 5: Social Well-Being"				
		else if ("`pap_section'" == "pap__b10z")		local table_title "Extended Data Table 6: Women's Control Over Earnings and Household Decision-Making"
		
		// Supplement
		else if ("`pap_section'" == "pap__b8_hh")		local table_title "Supplementary Table SI.6: Off-Farm Activities (Household)"
		else if ("`pap_section'" == "pap__d4")			local table_title "Supplementary Table SI.7: Agriculture (Household)"
		else if ("`pap_section'" == "pap__d5")			local table_title "Supplementary Table SI.8: Livestock (Household)"
		else if ("`pap_section'" == "pap__d3_daysa")	local table_title "Supplementary Table SI.9a: Labor Participation (Household)"
		else if ("`pap_section'" == "pap__d3_daysb")	local table_title "Supplementary Table SI.9b: Labor Participation (Beneficiary)"
		else if ("`pap_section'" == "pap__b6")			local table_title "Supplementary Table SI.10a: Financial Engagement"
		else if ("`pap_section'" == "pap__b6_suppl")	local table_title "Supplementary Table SI.10b: Financial Engagement (Extensive Margins)"
		else if ("`pap_section'" == "pap__b5") 			local table_title "Supplementary Table SI.11: Assets (Household)"

		// spillovers
		else if "`pap_section'" == "pap__acts"  		local table_title "Supplementary Table SI.12: Potential Mediators of Spill-Over Effects"

		// pap__b4z
		else if ("`pap_section'" == "pap__b4_1")		local table_title "Supplementary Table SI.14: Mental Health Index Components"
		else if ("`pap_section'" == "pap__b4_2a")		local table_title "Supplementary Table SI.15: Self-Efficacy Index Components"
		else if ("`pap_section'" == "pap__b4_3_1")		local table_title "Supplementary Table SI.16: Future Expectation Index Components (kids under 30)"

		// pap__c2z
		else if ("`pap_section'" == "pap__c2_2")		local table_title "Supplementary Table SI.17: Financial Support Index Components"
		else if ("`pap_section'" == "pap__c2_1")		local table_title "Supplementary Table SI.18: Social Support Index Components"
		else if ("`pap_section'" == "pap__b4_2b")		local table_title "Supplementary Table SI.19: Social Standing Index Components"
		else if ("`pap_section'" == "pap__c2_5")		local table_title "Supplementary Table SI.20: Social Norms Index Components"
		else if ("`pap_section'" == "pap__c2_3_b")		local table_title "Supplementary Table SI.21: Social Cohesion and Community Closeness Index Components"
		else if ("`pap_section'" == "pap__c2_4")		local table_title "Supplementary Table SI.22: Collective Action Index Components"
		
		// pap__b10z
		else if ("`pap_section'" == "pap__c2_3_a")		local table_title "Supplementary Table SI.23: Intra-Household Dynamics Index Components"
		else if ("`pap_section'" == "pap__c1_2")		local table_title "Supplementary Table SI.24: Violence Perceptions Index Components"
		else if ("`pap_section'" == "pap__b10_5")		local table_title "Supplementary Table SI.25: Control Over Earnings and Productive Agency Index Components"
		else if ("`pap_section'" == "pap__b10_6")		local table_title "Supplementary Table SI.26: Control Over Household Resources Index Components"

		
		//---------------------------------
		// tex output
		
		if 		("`pap_section'" == "all__std1") 		local final_table_name table_2
		else if ("`pap_section'" == "pap__a1")			local final_table_name table_ed1
		else if ("`pap_section'" == "pap__b2_sethh")	local final_table_name table_ed2a
		else if ("`pap_section'" == "pap__b2_setben")	local final_table_name table_ed2b
		else if ("`pap_section'" == "pap__d3_newa")		local final_table_name table_ed3a			
		else if ("`pap_section'" == "pap__d3_newb")		local final_table_name table_ed3b			
		else if ("`pap_section'" == "pap__b4z")			local final_table_name table_ed4
		else if ("`pap_section'" == "pap__c2z")			local final_table_name table_ed5				
		else if ("`pap_section'" == "pap__b10z")		local final_table_name table_ed6
		
		else if "`pap_section'" == "pap__b8_hh"    	local final_table_name table_si6    	
		else if "`pap_section'" == "pap__d4"    	local final_table_name table_si7   
		else if "`pap_section'" == "pap__d5"       	local final_table_name table_si8   
		else if "`pap_section'" == "pap__d3_daysa"  local final_table_name table_si9a   
		else if "`pap_section'" == "pap__d3_daysb"  local final_table_name table_si9b   
		else if "`pap_section'" == "pap__b6"       	local final_table_name table_si10a 
		else if "`pap_section'" == "pap__b6_suppl" 	local final_table_name table_si10b  
		else if "`pap_section'" == "pap__b5"       	local final_table_name table_si11   

		else if "`pap_section'" == "pap__acts"     	local final_table_name table_si12  

		else if "`pap_section'" == "pap__b4_1"     	local final_table_name table_si14 // mental health
		else if "`pap_section'" == "pap__b4_2a"    	local final_table_name table_si15 // self-efficacy
		else if "`pap_section'" == "pap__b4_3_1"   	local final_table_name table_si16 // future expectations

		else if "`pap_section'" == "pap__c2_2" 	 	local final_table_name table_si17 // financial support
		else if "`pap_section'" == "pap__c2_1" 	 	local final_table_name table_si18 // social support
		else if "`pap_section'" == "pap__b4_2b"  	local final_table_name table_si19 // social standing
		else if "`pap_section'" == "pap__c2_5"   	local final_table_name table_si20 // social norms
		else if "`pap_section'" == "pap__c2_3_b" 	local final_table_name table_si21 // social cohesion
		else if "`pap_section'" == "pap__c2_4"   	local final_table_name table_si22 // collective action

		else if "`pap_section'" == "pap__c2_3_a" 	local final_table_name table_si23 // intra-hh dynamics
		else if "`pap_section'" == "pap__c1_2"  	local final_table_name table_si24 // violence perceptions
		else if "`pap_section'" == "pap__b10_5"  	local final_table_name table_si25 // controls earnings
																					  // benef share of hh revenues (no components)
		else if "`pap_section'" == "pap__b10_6"  	local final_table_name table_si26 // controls resources
		
		
		//---------------------------------
		** 4.1.0 General FOOTNOTES: abbreviated for long deck
		#delimit ;
			local controls_note 
				`"Results presented are OLS estimates that include controls for 
				randomization strata and, where possible, baseline outcomes."' ;
			local controls_note2 
				`"We assign baseline strata means to households 
				surveyed at midline or endline but not at baseline and we control for 
				such missing values with an indicator."' ;
		#delimit cr
		
		if strpos("`pap_section'", "pap__a1") > 0 | /// ED tables ----
		   strpos("`pap_section'", "pap__b2_setben") > 0 |  /// ED tables
		   strpos("`pap_section'", "pap__b2_sethh") > 0 |  /// ED tables
		   strpos("`pap_section'", "pap__d3_newa") > 0 |  /// ED tables
		   strpos("`pap_section'", "pap__d3_newb") > 0 |  /// ED tables
		   strpos("`pap_section'", "pap__b4z") > 0 |  /// ED tables
		   strpos("`pap_section'", "pap__c2z") > 0 |  /// ED tables
		   strpos("`pap_section'", "pap__b10z") > 0 {
		   	
			#delimit ;
			local se_note 
				`"Robust standard errors are shown in parentheses, 
				  clustered at the ${cluster_level} level."' ;			
			#delimit cr
		}
		else {
			#delimit ;
			local se_note 
				`"Robust standard errors, clustered at the village level, 
				and two-tailed p-values are shown in parentheses."' ;			
			#delimit cr
		}

		
		if strpos("`pap_section'", "pap__b4") > 0 | ///
		   strpos("`pap_section'", "pap__c2") > 0 | ///
		   strpos("`pap_section'", "pap__b10") > 0 | ///
		   strpos("`pap_section'", "pap__c1_2") > 0 { //
			
			local def_note "See Table SI.4 for details on variable construction."	
		}
		else if strpos("`pap_section'", "all__std1") > 0 {
			#delimit ;
			local def_note 
				`"All outcomes in this table are standardized against the control group. 
				See Extended Data Tables 1-6 for the impacts on outcomes in our pre-specified 
				units and multiple hypothesis test corrections. See Tables SI.3 and SI.4 for details 
				on variable construction."' ;
			#delimit cr
		}
		else { // main vars
			local def_note "See Table SI.3 for details on variable construction."
		}
		
		
		
		//---------------------------------
		** 4.1.1 FOOTNOTES: monetary values
		// any table with monetary values
		if strpos("`pap_section'", "__a1") > 0 | /// 
		   strpos("`pap_section'", "__b2_set") > 0 |  ///
		   strpos("`pap_section'", "__d3_new") > 0 |  ///
		   strpos("`pap_section'", "__b2_ben") > 0 |  ///
		   strpos("`pap_section'", "__b2_hh") > 0 |  ///
		   strpos("`pap_section'", "__b5") > 0 |  ///
		   strpos("`pap_section'", "__b5_95p") > 0 |  ///
		   strpos("`pap_section'", "__b6") > 0 | ///
		   strpos("`pap_section'", "__b7") > 0 | ///
		   strpos("`pap_section'", "__b7_1") > 0 | ///
		   strpos("`pap_section'", "__b8_hh") > 0 | ///
		   strpos("`pap_section'", "__b8_ben") > 0 | ///
		   strpos("`pap_section'", "__c2_4") > 0 | /// donations
		   strpos("`pap_section'", "__d4") > 0 | ///
		   strpos("`pap_section'", "__d4_1") > 0 | ///
		   strpos("`pap_section'", "__d4_2") > 0 | ///
		   strpos("`pap_section'", "__d5") > 0 | ///
		   strpos("`pap_section'", "__d6") > 0 {
		
		   // any of the tables with monetary values
			#delimit ;
			local money_units_footnote 
				`"All monetary amounts are PPP-adjusted USD terms, 
					set at 2016 prices and deflated using ${country} 
					CPI published by the World Bank. In 2016, 1 USD 
					= ${conv_ppp_2016_${cty}} ${lcu_${cty}} PPP."';
			#delimit cr

			if (strpos("`pap_section'", "__a1") > 0) ///
				local money_units_footnote = subinstr("`money_units_footnote'", ///
					"1,000 ${lcu_${cty}}", "${lcu_${cty}}", .)
					
			#delimit ;
			local wins_footnote 
				`"All continuous variables are winsorized at the 98th 
					and 2th percentiles at the most disaggregated 
					level feasible."';
			#delimit cr
		}
		else {
			local money_units_footnote "DELETE SINGLE"
			local wins_footnote "DELETE SINGLE"
		}
		
		
		//---------------------------------
		** 4.1.2 FOOTNOTES: Index footnotes 
		if  strpos("`pap_section'", "__b4z") | ///
			strpos("`pap_section'", "__b10z") | /// 
			strpos("`pap_section'", "__c1z") | /// 
			strpos("`pap_section'", "__c2z") {
			
			#delimit ;
			local index_footnote 
				`"All indices are standardized with respect to the 
					control group in that survey round."'; 
			#delimit cr
		}
		else {
			local index_footnote "DELETE SINGLE"
		} 

		
		//---------------------------------
		** 4.1.3 FOOTNOTES: section- or table-specific footnotes 
		if "`pap_section'" == "pap__b6" {		
			#delimit ;
			local section_footnote   
				`"Results from the 2nd follow-up are more reliable due to measurement 
				 issues with savings outcomes in the 1st follow-up. In the 1st follow-up survey, 
				 our data show that most of the respondents in the control group (93\%) 
				 declared that they participated in a VSLA/tontine in the 1st follow-up, 
				 compared to only 53\% in the 2nd follow-up. Disaggregating the participation 
				 in saving groups by tontine and VSLA (Supplementary Table SI.10b) shows that 
				 84\% of the control declare that they participated in a VSLA and 23\% in a tontine 
				 in the 1st follow-up. This level of participation in a VSLA in the control at 1st 
				 follow-up appears very unlikely. It may come from the way the question was phrased 
				 in the 1st follow-up. For instance, it is possible that respondents included 
				 in this response their participation in beneficiary groups established for 
				 the parenting and child development promotion activities as part of the cash 
				 transfer program \parencite{premand2020behavioral}. These activities were 
				 implemented consistently across all treatment and control villages in the 
				 sample we analyze in this paper. As part of these groups, beneficiaries met
				 to discuss topics related to child nutrition and development. The activities 
				 did not cover savings or productive activities, although beneficiaries sometimes 
				 made small contributions for cooking demonstrations. The difference in results 
				 between the 1st and 2nd follow-up survey may also have been influenced by the 
				 recall period, which was 24 months in the 1st follow-up but 12 months in the 
				 2nd follow-up, or some misunderstanding on the question during the training 
				 of surveyors, although results remain unchanged when we control for surveyor 
				 fixed effects (Supplementary Table SI.10b)."' ;
			#delimit cr
		}
		else if "`pap_section'" == "pap__d5" {
			local section_footnote "TLU represents Tropical Livestock Units."
		}
		else if "`pap_section'" == "pap__b2_setben" | "`pap_section'" == "pap__b2_sethh" {
			#delimit ;
			local section_footnote 
				`"Wage revenues are wage earnings scaled up by the median monthly 
				  profit margin of household businesses."' ;
			#delimit cr
		}
		else {
			local section_footnote  "DELETE SINGLE"
		}
		
		//---------------------------------
		** 4.1.4 FOOTNOTES: section-specific components note 
		if "`pap_section'" == "pap__b4z" {
			#delimit ;
			local components_note 
				`"Results from components of each index are provided in 
				Table SI.14 (mental health index components), 
				Table SI.15 (self-efficacy index components), and 
				Table SI.16 (future expectation index components)."' ;
			#delimit cr
		}
		else if "`pap_section'" == "pap__c2z" {
			#delimit ;
			local components_note 
				`"Results from components of each index are provided in 
				Table SI.17 (financial support index), 
				Table SI.18 (social support index), 
				Table SI.19 (social standing index), 
				Table SI.20 (social norms index), 
				Table SI.21 (social cohesion and community closeness), and
				Table SI.22 (collective action index)."' ;
			#delimit cr
		}
		else if "`pap_section'" == "pap__b10z" {
			#delimit ;
			local components_note 
				`"Results from components of each index can be found in 
				Table SI.23 (intra-household dynamics), 
				Table SI.24 (violence perceptions), 
				Table SI.25 (control over earnings and productive agency), and
				Table SI.26 (control over household resources)."' ;
			#delimit cr
		}
		else {
			local components_note "DELETE SINGLE"
		}

		// trim multiline footnotes
		foreach notehere in controls_note ///
							controls_note2 ///
							def_note ///
							se_note ///
							money_units_footnote ///
							wins_footnote ///
							index_footnote ///
							section_footnote ///
							components_note {
							
			local `notehere' = trim(itrim("``notehere''"))
		}
		
		
			
		************************************************************************
		****  4.2 Extract variable labels, run regressions, and store statistics
		dis "ASP tables, step 4: Running regs for `pap_section' table in main spec at FU $phase_num in $cty"

		foreach var in ``pap_section'' { 
			
			dis "Variable: `var'"

			****----------------------------------------------------------------
			****  4.2.1 Extract variable labels
			
			// collect variable labels in Tex friendly format
			// this program returns r(mylabels) and r(returnlocal)
			stack_concat_varlabs, lab("`: var label `var''") ///
								  pap_section("`pap_section'") ///
								  var_count(`var_count') ///
								  var_count_tot(`var_count_tot') ///
								  returnlocal("titles_`pap_section'") ///
								  recurstitles("`titles_`pap_section''") 

			local titles_`pap_section' = "`r(titles_`pap_section')'"
			local mylabels = "`r(mylabels)'"
			// dis "titles = `titles_`pap_section''"
			// dis "mylabels = `mylabels'"

			
			****----------------------------------------------------------------
			****  4.2.2 run regressions
			
			
			** Regression treatment, cluster, and strata
				local treatvar 		treatment
				local cluster_var 	cluster
				local strata_var 	strata
				
			** Regression extras: ctrl 
				if "`var'" == "ton_or_avec_hh_fe" local ctrl i.surveyor
				else 							  local ctrl
								
			** Regression extras: bl_ctrl_var bl_ctrl_dum 
				// check if trimmed version exists
				// if the trimmed bl outcome exists, use it.
				// else if the exact same bl outcome exists, use that instead.
				// else if no bl outcome exists, can't control for bl (no ancova)
				capture confirm variable `var'_trim_bl
				if _rc == 0 {
					local bl_ctrl_var `var'_trim_bl    
					local bl_ctrl_dum `var'_trim_bl_bd 
				}
				else if _rc != 0 {
					capture confirm variable `var'_bl
					if _rc == 0 {
						local bl_ctrl_var `var'_bl    
						local bl_ctrl_dum `var'_bl_bd 
					}
					else if _rc != 0 {
						local bl_ctrl_var     
						local bl_ctrl_dum 
					}
				}
				
			** Run Regression
				qui eststo :  reg `var' i.`treatvar' 	 		   /// treatment 
										`interactions'   		   /// interactions (hetero spec only)
										`bl_ctrl_var'    		   /// bl controls (wherever available)
										`bl_ctrl_dum'    		   /// bl control dummy (ditto)
										`ctrl' 					   /// extra controls for certain variables in main spec
										i.`strata_var' 		   	   ///
										`weights' 				   ///
										if phase == ${phase_num}   /// phase condition
										`special_condition', 	   /// 
										cluster(`cluster_var') 	   // 

			** Collect main items from return list for later use 
				qui gen reg_obs = e(sample) // used within each var loop and dropped at the end of the loop
				matrix my_reg = r(table) // collect results
				
				
			****----------------------------------------------------------------
			****  4.2.3 store group averages and error bars
				
			//---------------------------------
			// Sample size
				local n_reg       		`e(N)'
				local df = `e(df_r)' // number of clusters - 1 
									 // t-test DoF for clustered s.e.

			//---------------------------------
			// control mean and SD (BL optional) & share of zeros
			asp_control_stats `var' `treatvar' reg_obs, bl_ctrl_var(`bl_ctrl_var') qui
			
				matrix fu_mat = 		 r(fu_mat)

				// esttab stats
				local ctrl_meanbl 	"`r(control_mean_bl)'"
				local ctrl_mean   	"`r(control_mean)'"
				local ctrl_sd     	"`r(control_sd)'"
				local ctrl_0_share 	"`r(ctrl_0_share)'"

				// esttab labels
				local ctrl_meanbllab `""Control mean @ baseline""'
				local ctrl_meanlab   `""Control mean @ followup""' 
				local ctrl_sdlab     `""Control SD @ followup""'
				
				
			// --------------------------------
			// Joint F test and tests across groups and (at FU2) phases
			asp_f_tests, var(`var') 		 		treatvar(`treatvar') 	   /// 
					 	 bl_ctrl_var(`bl_ctrl_var') bl_ctrl_dum(`bl_ctrl_dum') /// 
						 strata_var(`strata_var')  	cluster_var(`cluster_var') /// 
						 var_count(`var_count') 	ctrl(`ctrl') ///
						 crosstest /// gives back b/se/p_cross_1/2/3
						 quietly

				forval i = 1/3 {
					foreach j in b se p {
						local `j'_test_`i'_ph${phase_num}     = "`r(`j'_test_`i'_ph${phase_num})'"
						if "$ph" == "fu2" local `j'_cross_`i' = "`r(`j'_cross_`i')'"
					}
				}

				// esttab stats
				local mgnfx 	 b_val_3 	b_val_2    b_val_1
				local crossph 	 p_cross_1 p_cross_2 p_cross_3

				// esttab labels
				#delimit ;
				local mgnfxlab `""Full - Psychosocial (Cash grant gross ME)"
								 "Full - Capital (Psychosocial comp. gross ME)"
								 "Capital - Psychosocial""' ;
								 
				local crossphlab `""p (Followup 2 - Followup 1 for Capital)"
								   "p (Followup 2 - Followup 1 for Psychosocial)"
								   "p (Followup 2 - Followup 1 for Full)""';
				#delimit cr

				
				
				
			//---------------------------------
			// MATRIX
			asp_summary_matrix my_reg fu_mat "`var'" `df' `pap_section_n' `row_n_long'
			
				matrix stat_collect = r(stat_collect)
				local row_n_long = `row_n_long' + 1	// increment counter
				
				
			// for vertical setup
			foreach t in 1 2 3 {
				local pos_in_mat `t' + 1
				
				local mainb_`t'_ph${phase_num} =  pt_est[1,`pos_in_mat']
				local mainse_`t'_ph${phase_num} = std_err[1,`pos_in_mat'] 
				local mainp_`t'_ph${phase_num} = p_val[1,`pos_in_mat'] 
				
				local mainb_`t'_ph${phase_num}  : di %15.2fc `mainb_`t'_ph${phase_num}'
				local mainse_`t'_ph${phase_num} : di %15.2fc `mainse_`t'_ph${phase_num}'
				local mainp_`t'_ph${phase_num}  : di %15.3fc `mainp_`t'_ph${phase_num}'
				
			}
			
			
			
			****----------------------------------------------------------------
			****  4.2.4 Manual output: send stats to asp_050_PAP_tables
			
			// collect stats from sections above
			foreach stat in mainb mainse mainp b_test se_test p_test {
				foreach t in 1 2 3 {
					local stats_names `stats_names' `stat'_`t'_ph${phase_num}
					local stats_list `stats_list' ``stat'_`t'_ph${phase_num}'
// 					dis "`stat'_`t'_ph${phase_num} = ``stat'_`t'_ph${phase_num}'"
				}
			}
			
			local stats_names `stats_names' N ctrl_mean ctrl_sd df
			local stats_list `stats_list' `n_reg' `ctrl_mean' `ctrl_sd' `df'
			
			if "$ph" == "fu2" {
				// fu1=fu2
				foreach stat in b_cross se_cross p_cross {
					foreach t in 1 2 3 {
						local stats_names `stats_names' `stat'_`t'
						local stats_list  `stats_list' ``stat'_`t''
						
					}
				}
			}
			
			// assert that all required stats have been assigned a value
			assert `: word count `stats_names'' == `: word count `stats_list''
			
// 			dis `"`stats_names'"'
// 			dis `"`stats_list'"'
// 		pause
			
			asp_050_PAP_tables, stats_names(`stats_names') ///
								stats_list(`stats_list') ///
								phase(${phase_num}) ///
								varlab("`mylabels'") ///
								var_insection(`row_n_long') ///
								var_count(`var_count') ///
								var_count_tot(`var_count_tot') ///
								pap_section("`pap_section'") ///
								title("`table_title'") ///
								controls_note("`controls_note'") ///
								controls_note2("`controls_note2'") ///
								def_note("`def_note'") ///
								se_note("`se_note'") ///
								money_units_footnote("`money_units_footnote'") ///
								wins_footnote("`wins_footnote'") ///
								index_footnote("`index_footnote'") ///
								section_footnote("`section_footnote'") ///
								components_note("`components_note'") ///
								final_table_name("`final_table_name'") ///
								recurs_dta("stacked_test_`id'")
								
								
								
			****----------------------------------------------------------------
			****  4.2.5 Export stats as dta when all sections done
			// dis "`pap_section_n' == `no_of_sections' & `var_count' == `var_count_tot'"
			if `pap_section_n' == `no_of_sections' & `var_count' == `var_count_tot' { // use pap section counter
				preserve

					clear
					svmat2 stat_collect, rnames(var_name)
					order var_name, first

					rename stat_collect1  b0 // label stats
					rename stat_collect2  b1
					rename stat_collect3  b2
					rename stat_collect4  b3
					rename stat_collect5  avg0 
					rename stat_collect6  avg1 
					rename stat_collect7  avg2 
					rename stat_collect8  avg3 
					rename stat_collect9  se0
					rename stat_collect10 se1
					rename stat_collect11 se2
					rename stat_collect12 se3
					rename stat_collect13 ci95_0 
					rename stat_collect14 ci95_1
					rename stat_collect15 ci95_2
					rename stat_collect16 ci95_3
					rename stat_collect17 p0
					rename stat_collect18 p1
					rename stat_collect19 p2
					rename stat_collect20 p3
					rename stat_collect21 mht_family
					
					label var ci95_0 
					label var ci95_1 "Half of the 95% confidence interval"
					label var ci95_2 "Half of the 95% confidence interval"
					label var ci95_3 "Half of the 95% confidence interval"
										
					save "${regstats_${phase}_${cty}}/${ph}_${cty}_regstats_`id'.dta", replace
					
				restore
			}
			
			
			drop reg_obs  // drop e(sample) var generated for each var in step 4.1.2
			local var_count = `var_count' + 1
			
		} // close var loop


	
		local pap_section_n = `pap_section_n' + 1 // needed for 4.2.5 to work
		
	} // close foreach `pap_section' loop



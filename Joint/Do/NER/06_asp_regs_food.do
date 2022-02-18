/*
Niger main tables
This script produces table si13 showing effects on log food prices

****  1. Import data
****  2. Collect variables in sections
****  2.1 Collect all locals from above in different sections. Each of these produces a table
****  3 Label Baseline Outcomes	

****  4. Run Regressions and generate output 
****  4.1 Define table specific var labels, titles, and footnotes
****  4.2 Extract variable labels, run regressions, and store statistics
****  4.2.1 Extract variable labels
****  4.2.2 Run regressions
****  4.2.3 Store group averages and error bars
****  4.4 Manual output: send stats to asp_050_PAP_tables
****  4.2.5 Export stats as dta when all sections done
****  4.3 system output


*/	

pause on 
local currency usd 
matrix drop _all

nois dis "Running do-file: asp_regs_food.do"




		******************************************
		// for a quick regression with system 
		// rather than tex output,
		// enter list of dependent vars here:
		
		local pap__price   grains_price veg_price
		local choose_phase Followup_2  // Followup or Followup_2
		
		local suppress_tex 0 // turn on to show results as system output
		
		if `suppress_tex' == 1 {
			global phase "`choose_phase'"
			do "${joint_do}/01_GLOBAL_JOINT.do"
		}
		******************************************


		
		

********************************************************************************
****  1. Import data
use "${joint_fold}/Data/allrounds_NER_food.dta", clear
local id food // used to export stats
local spec "Food level"

********************************************************************************
****  2. Collect variables in sections

// assign vars to tables in locals
if `suppress_tex' == 0 local pap__price grains_price tuber_price veg_price meat_price


********************************************************************************
****  2.1 collect all locals from above in different sections. Each of these produces a table

local lists pap__price

********************************************************************************
****  3 Label Baseline Outcomes	
	
* label BL outcomes 
local bl_vars // no baseline controls


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
	
		************************************************************************
		****  4.1 Define table specific var labels, titles, and footnotes

		//---------------------------------
		// label variables conditional on section
		label var grains_price 		"Log grain prices"
		label var tuber_price 		"Log tuber prices"
		label var veg_price 		"Log vegetable prices"
		label var meat_price 		"Log meat prices"
		
		//---------------------------------
		// Label tables based on subset and PAP section. Used in title() in esttab below
		#delimit ;
		if "`pap_section'" == "pap__price" 	local table_title 
			`"Supplementary Table SI.13: Food Prices 
			(Log Median Village Price, Weighted by Purchase Frequency)"' ;
		#delimit cr
		local table_title = trim(itrim("`table_title'"))
		if "`pap_section'" == "pap__price"  local final_table_name table_si13

		//---------------------------------
		** 4.1.0 General FOOTNOTES
		#delimit ;
		local controls_note 
			`"Observations are log median village-level prices for food and unit, 
			as observed in the household surveys. Results presented are OLS 
			estimates that include controls for randomization strata and the 
			specific type and unit of food, weighted by the number of households 
			that report the food/unit combination in each village."' ;
		#delimit cr
		local controls_note2 "DELETE SINGLE"
		local se_note "Robust standard errors, clustered at the village level, and two-tailed p-values are shown in parentheses."
		local def_note "DELETE SINGLE"
		
		//---------------------------------
		** 4.1.1 FOOTNOTES: monetary values
		// any table with monetary values
		local money_units_footnote 	 "DELETE SINGLE"
		local wins_footnote "DELETE SINGLE"
		
		//---------------------------------
		** 4.1.2 FOOTNOTES: Index footnotes 
		local index_footnote "DELETE SINGLE"

		//---------------------------------
		** 4.1.3 FOOTNOTES: section- or table-specific footnotes 
		local section_footnote  "DELETE SINGLE"
		
		//---------------------------------
		** 4.1.4 FOOTNOTES: section-specific components note 
		local components_note "DELETE SINGLE"

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
		dis as text "ASP tables, step 4: Running regs for `pap_section' table in food spec at FU $phase_num in $cty"
		
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
						
			** Regression treatment
				local treatvar treatment
				local cluster_var cluster
				local strata_var strata
							
			** Regression extras: ctrl 
				local ctrl i.group // extra controls
	
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
	
			** Regression extras: interactions
				local interactions
				
			** small adjustment to base level in one table with very small sample size
			**  and base category conflict in strata variable in suest
				if "`var'" == "grains_price" fvset base 137 group
				else 						 fvset clear group	
	
			** Regression weights
				if "`pap_section'" == "pap__price" ///
					local weights "[aweight=bot_mp_village_n]"
			
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
						 crosstest quietly

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
			
			if `suppress_tex' == 0 {
				// collect stats from sections above
				foreach stat in mainb mainse mainp b_test se_test p_test {
					foreach t in 1 2 3 {
						local stats_names `stats_names' `stat'_`t'_ph${phase_num}
						local stats_list `stats_list' ``stat'_`t'_ph${phase_num}'
					}
				}
				
				local stats_names `stats_names' N ctrl_mean ctrl_sd
				local stats_list `stats_list' `n_reg' `ctrl_mean' `ctrl_sd'
				
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
// 			forval i = 1/`: word count `stats_names'' {
// 			    dis "`: word `i' of `stats_names'': `: word `i' of `stats_list''"
// 			}
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
			}						
								
								
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
			
			****----------------------------------------------------------------
			****  4.3 system output
			if `suppress_tex' == 1 {
							
				foreach t in 1 2 3 {
					foreach stat in b se p {
						local main`stat'_`t'_ph${phase_num} = trim("`main`stat'_`t'_ph${phase_num}'")
					}
				}
				local ctrl_0_share = trim("`ctrl_0_share'")
				

				dis as text ""
				dis as error "   - Displaying results as system output"
				dis as error "   -------------------------------------------------"
				dis as error "   ---- BEGIN: Results for `spec' specification ----"
				dis as error "   ---- Variable: `: var label `var''"
				
				dis as text ""	
				foreach t in 1 2 3 {
					dis as text "   `mainb_`t'_ph${phase_num}'    = beta `t' at ph ${phase_num}"
					dis as text "   (`mainse_`t'_ph${phase_num}')  = se `t'"
					dis as text "   (`mainp_`t'_ph${phase_num}') = se `t'"
				}
				
				dis as text "   ---------------------"
				dis as text "   `n_reg'    = Observations"
				dis as text "   `ctrl_0_share'    = Share of zeros in control"
				
				if "`ctrl_mean_bl'" == "" dis as text "   DNE     = control mean @ BL"
				else dis as text "   `ctrl_mean_bl'  = control mean @ BL"
				dis as text "   `ctrl_mean'    = control mean @ FU"
				dis as text "   `ctrl_sd'    = control SD @ FU"
				dis as text "   ---------------------"
				dis as text "   `p_test_3_ph${phase_num}'   = p (Psychosocial = Full)"
				dis as text "   `p_test_2_ph${phase_num}'   = p (Capital = Full)"
				dis as text "   `p_test_1_ph${phase_num}'   = p (Capital = Psychosocial)"
				
				dis as error " "
				dis as error "   ----- END: Results for `spec' specification -----"
				dis as error "   -------------------------------------------------"
				dis as text ""
				dis as text ""	
				
			}
				
			drop reg_obs  // drop e(sample) var generated for each var in step 4.1.2
			local var_count = `var_count' + 1
			
		} // close var loop
	} // close foreach `pap_section' loop

	
	
	
	
	
	
	
	
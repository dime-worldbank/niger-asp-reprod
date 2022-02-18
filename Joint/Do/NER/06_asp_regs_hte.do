/*


Niger main tables
This script produces
	Tables SI.29 & SI.30

****  1. Import data and choose phases and specs
****  2. Collect variables in sections
****  2.1 collect all locals from above in different sections. Each of these produces a table
****  3 Label Baseline Outcomes	

****  4. Run Regressions and generate output 
****  4.1 Define table specific var labels, titles, and footnotes
****  4.2 Extract variable labels, run regressions, and store statistics
****  4.2.1 Extract variable labels
****  4.2.2 run regressions
****  4.2.3 store group averages and error bars (for ppt) main spec only
****  4.3 system output
****  4.4 Output


*/	

pause on 
matrix drop _all

nois dis "Running do-file: asp_regs_hte.do"






		******************************************
		// for a quick regression with system 
		// rather than tex output,
		// enter list of dependent vars here:
		
		local quickvars__a1_hte    consum_2_day_eq_ppp ment_hlth_index
		local suppress_tex 0 // turn on to show results as system output
		
		******************************************






********************************************************************************
****  1. Import data and choose phases and specs
use "${joint_fold}/Data/allrounds_NER_hh.dta", clear
local id hh // used to export stats

local phases 2 // only show endline
local specs hetero1 hetero4 


********************************************************************************
****  2. Collect variables in sections

local all__a1_hte consum_2_day_eq_ppp ment_hlth_index

********************************************************************************
****  2.1 collect all locals from above in different sections. Each of these produces a table

local lists all__a1_hte
if `suppress_tex' == 1 local lists quickvars__a1_hte


********************************************************************************
****  3 Label Outcomes	
	
* label BL outcomes 
qui ds *_bl *_bd
foreach var in `r(varlist)' {
	capture label var `var' "variable @ Baseline"
}

* label strata
label var strata "strata"

label define treat 0 "Control" ///
				   1 "Capital" ///
				   2 "Psychosocial" ///
				   3 "Full", modify
label values treatment treat

********************************************************************************
****  4. Run Regressions and generate output
foreach spec in `specs' {

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
		qui asp_013_label_vars_ner, section("`pap_section'") stack_opt(horizontal)
		
		//---------------------------------
		// Label tables based on subset and PAP section. Used in title() in esttab below
		if "`spec'" == "hetero1" local table_title "Supplementary Table SI.29: Heterogeneity by Baseline Consumption"
		if "`spec'" == "hetero4" local table_title "Supplementary Table SI.30: Heterogeneity by Baseline Mental Health Index"
		
		//---------------------------------
		// tex output
		if "`spec'" == "hetero1" local final_table_name table_si29 // het: consum
		if "`spec'" == "hetero4" local final_table_name table_si30 // het: mental health
		
		
		//---------------------------------
		** 4.1.0 General FOOTNOTES: abbreviated for long deck
		local controls_note "Results presented are OLS estimates that include controls for randomization strata and, where possible, baseline outcomes." 
		local controls_note2 "We assign baseline strata means to households surveyed at endline but not at baseline and we control for such missing values with an indicator." 
		local se_note "Robust standard errors, clustered at the village level, and two-tailed p-values are shown in parentheses."
		local def_note "See Tables SI.3 and SI.4 for details on variable construction."
	
		//---------------------------------
		** 4.1.1 FOOTNOTES: monetary values
		// any table with monetary values		
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
		
		
		//---------------------------------
		** 4.1.2 FOOTNOTES: Index footnotes 
		local index_footnote "DELETE SINGLE"
		
		//---------------------------------
		** 4.1.3 FOOTNOTES: section- or table-specific footnotes 
		local section_footnote  "DELETE SINGLE"
		
		//---------------------------------
		** 4.1.4 FOOTNOTES: section-specific components note 
		local components_note "DELETE SINGLE"

		#delimit ;
		local allnotes 
			`"`controls_note' `controls_note2' `se_note'
			*** p $<$ 0.01, ** p $<$ 0.05, * p $<$ 0.1.
			`money_units_footnote' `wins_footnote' `section_footnote'
			`index_footnote' `def_note' `components_note'"' ;
		#delimit cr

		// trim multiline footnotes
		foreach notehere in controls_note ///
							controls_note2 ///
							def_note ///
							se_note ///
							money_units_footnote ///
							wins_footnote ///
							index_footnote ///
							section_footnote ///
							components_note ///
							allnotes {
							
			local `notehere' = trim(itrim("``notehere''"))
			local `notehere' = subinstr("``notehere''", "DELETE SINGLE", "", .)
		}
		
		
		************************************************************************
		****  4.2 Extract variable labels, run regressions, and store statistics
		dis as result "ASP tables, step 4: Running regs for `pap_section' table in main spec at FU $phase_num in $cty"

		foreach ph in `phases' {
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
				local templab = subinstr("`r(mylabels)'", "&", "", .)
				
				// concatenate varlabels
				if strlen("`mylabels'") == 0 local mylabels `" "`templab'" "'
				else 						 local mylabels `" `mylabels' "`templab'" "'
				
			
			****----------------------------------------------------------------
			****  4.2.2 run regressions
			
			
			** Regression treatment, cluster, and strata
				local treatvar 		treatment
				local cluster_var 	cluster
				local strata_var 	strata
				
			** Regression extras: ctrl 
				local ctrl
								
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
				
			** Regression extras: het_var_reg 
				if 		"`spec'" == "hetero1" local het_var_reg i1.med_consum_dum_het 
				else if "`spec'" == "hetero4" local het_var_reg i1.med_mh_ind_dum_het 
				
			** Regression extras: interactions
				assert "`treatvar'" == "treatment"
				local interactions `het_var_reg' ///
									i1.`treatvar'#`het_var_reg' ///
									i2.`treatvar'#`het_var_reg' ///
									i3.`treatvar'#`het_var_reg'
				
				
			** Run Regression
				qui eststo : reg `var' i.`treatvar' 	 		   /// treatment 
										`interactions'   		   /// interactions (hetero spec only)
										`bl_ctrl_var'    		   /// bl controls (wherever available)
										`bl_ctrl_dum'    		   /// bl control dummy (ditto)
										`ctrl' 					   /// extra controls for certain variables in main spec
										i.`strata_var' 		   	   ///
										`weights' 				   ///
										if phase == `ph'   		   /// phase condition
										`special_condition', 	   /// 
										cluster(`cluster_var') 	   // 

			** Collect main items from return list for later use 
				qui gen reg_obs = e(sample) // used within each var loop and dropped at the end of the loop
				matrix my_reg = r(table) // collect results
			
			
			****----------------------------------------------------------------
			****  4.2.3 store group averages and error bars (for ppt) main spec only
				
			//---------------------------------
			// Sample size
				local n_reg       		`e(N)'
				local df = `e(df_r)' // number of clusters - 1 
									 // t-test DoF for clustered s.e.

			//---------------------------------
			// control mean and SD (BL optional) & share of zeros
				
				// HTE var == 0
				qui sum `var' if `treatvar' == 0 & `het_var_reg' == 0 & reg_obs == 1, detail
				loc ctrl_mean_good `r(mean)'
				loc round_mean_good : di %15.2fc `ctrl_mean_good'
				qui estadd local ctrl_mean_good = "`round_mean_good'", replace
				local ctrl_mean_good = "`round_mean_good'"
					
				// HTE var == 1
				qui sum `var' if `treatvar' == 0 & `het_var_reg' == 1 & reg_obs == 1, detail
				loc ctrl_mean_bad `r(mean)'
				loc round_mean_bad : di %15.2fc `ctrl_mean_bad'
				qui estadd local ctrl_mean_bad = "`round_mean_bad'", replace
				local ctrl_mean_bad = "`round_mean_bad'"
				
				
			// --------------------------------
			// Joint F tests HTE-specific
				asp_f_tests_hte, var(`var') 		 		treatvar(`treatvar') 	   /// 
								 bl_ctrl_var(`bl_ctrl_var') bl_ctrl_dum(`bl_ctrl_dum') /// 
								 strata_var(`strata_var')  	cluster_var(`cluster_var') /// 
								 var_count(`var_count') 	ctrl(`ctrl') 			   ///
								 het_var_reg("`het_var_reg'") quietly
					
					forval i = 1/3 {
						local p_val_`i'_int  = "`r(p_val_`i'_int)'"
						local p_val_`i'_inth = "`r(p_val_`i'_inth)'"
					}
					
					// esttab stats
					local withinhet 	p_val_1_int p_val_2_int p_val_3_int
					local fullhet 	 p_val_1_inth p_val_2_inth p_val_3_inth
					// esttab labels
					#delimit ;
					local withinhetlab	`""p (Capital*(1 + het var) = 0)"
										  "p (Psychosocial*(1 + het var) = 0)"
										  "p (Full*(1 + het var) = 0)""';
					local fullhetlab `""p (Capital*(1 + het var) = Psychosocial*(1 + het var))"
									   "p (Capital*(1 + het var) = Full*(1 + het var))"
									   "p (Psychosocial*(1 + het var) = Full*(1 + het var))""';
					#delimit cr

					
			// --------------------------------
			// Joint F test and tests across groups and (at FU2) phases
				asp_f_tests, var(`var') 		 		treatvar(`treatvar') 	   /// 
							 bl_ctrl_var(`bl_ctrl_var') bl_ctrl_dum(`bl_ctrl_dum') /// 
							 strata_var(`strata_var')  	cluster_var(`cluster_var') /// 
							 var_count(`var_count') 	ctrl(`ctrl') quietly

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
				
			
											

				****----------------------------------------------------------------
				****  4.3 system output
				if `suppress_tex' == 1 {
								
					foreach t in 1 2 3 {
						foreach stat in b se p {
							local main`stat'_`t'_ph`ph' = trim("`main`stat'_`t'_ph`ph''")
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
						dis as text "   `mainb_`t'_ph`ph''    = beta `t' at ph `ph'"
						dis as text "   (`mainse_`t'_ph`ph'')  = se `t'"
						dis as text "   (`mainp_`t'_ph`ph'') = se `t'"
					}
					
					dis as text "   ---------------------"
					dis as text "   `n_reg'    = Observations"
					dis as text "   `ctrl_0_share'    = Share of zeros in control"
					if "`ctrl_mean_bl'" == "" dis as text "   DNE     = control mean @ BL"
					else dis as text "   `ctrl_mean_bl'  = control mean @ BL"
					dis as text "   `ctrl_mean'    = control mean @ FU"
					dis as text "   `ctrl_sd'    = control SD @ FU"
					
					dis as text "   ---------------------"
					dis as text "   `p_test_1_ph`ph''   = p (Psychosocial = Full)"
					dis as text "   `p_test_2_ph`ph''   = p (Capital = Full)"
					dis as text "   `p_test_3_ph`ph''   = p (Capital = Psychosocial)"
					
					dis as error " "
					dis as error "   ----- END: Results for `spec' specification -----"
					dis as error "   -------------------------------------------------"
					dis as text ""
					dis as text ""	
					
				}
				
				drop reg_obs  // drop e(sample) var generated for each var in step 4.1.2
				local var_count = `var_count' + 1
			
			}
			
			
			
		} // close ph loop
		
		if 		"`phases'" == "1" local groupheader `" "6 months later" "'
		else if "`phases'" == "2" local groupheader `" "18 months later" "'
		else if "`phases'" == "1 2" local groupheader `" "6 months later" "18 months later" "'

		****----------------------------------------------------------------
		****  4.4 Output:
		// For hetero, not running vertical output via asp_050_PAP_tables
		if `suppress_tex' == 0 {
			esttab using "${joint_output_${cty}}/report_tables/`final_table_name'.tex",   ///
				style(tex)											///
				title("`table_title'") 	 							///
				nogaps												///
				nobaselevels 										///
				noconstant											///
				label            									///
				varwidth(50)										///
				wrap 												///
				mlabels(`mylabels')									///
				mgroups(`groupheader',	        					///
						pattern(1 0 1 0) 							///
						prefix(\multicolumn{@span}{c}{) 			///
						suffix(})   								///
						span 										/// 
						erepeat(\cmidrule(lr){@span}))         		///
				cells (b(fmt(2)) se(fmt(2) par) p(fmt(3) par))		///
				stats(N 											///
					  ctrl_mean_good								///
					  ctrl_mean_bad, 								///
					  fmt(%9.0f %9.2f %9.2f)						///
					  labels("Observations"					 		///
							 "Control mean @ followup above median" ///
							 "Control mean @ followup below median")) ///
				drop(_cons *_bl *_bl_bd *.strata)					///
				postfoot("\hline\hline" ///
						 "\multicolumn{@span}{p{0.85\textwidth}}{\footnotesize \textit{Notes:} `allnotes'}" ///
						 "\end{tabular}" ///
						 "\end{table}" ) ///
				replace
		}
	
		local pap_section_n = `pap_section_n' + 1 
		
	} // close foreach `pap_section' loop
}




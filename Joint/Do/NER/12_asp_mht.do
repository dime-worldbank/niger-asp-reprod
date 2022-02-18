/*

This scripts corrects p-values for multiple hypothesis testing using two methods:
1) False discovery rate (qqvalue command)
2) Family-wise error rate (mhtreg command)

date created: 07/22/2021

Outline:
** 1) FDR + varnames
	** 1.1) import p-value
	** 1.2) merge p-values from FU1 and FU2
	** 1.3) categorize vars by MHT family
	** 1.4) handle exceptions
	** 1.5) FDR corrections
	** 1.6.1) collect mht varnames from fdr dataset
	** 1.6.2) collect variable descriptions from asp_013_label_vars_ner.do
	
** 2) FWER
	** 2.1) copy families from asp_regs 
	** 2.2) set up treatment dummies for mhtreg (used inside -mhtreg_yk-)
	** 2.3) run mht reg 
	** 2.4) stack all results
	** 2.5) clear and print table of corrected p-values with column and row labels
	** 2.6) merge survey rounds
	
** 3) merge tables and add latex header and footer
	** 3) Prepare table si5 
	** 3.1) bring together FDR and FWER results
	** 3.2) generate family order var
	** 3.3) order variables by phase --> treatment --> actual, fdr, fwer
	** 3.4) prepare latex space
	** 3.5) save latex file 

*/

pause on 



		local fam_n 0 // re-initiate this for each fam_set (used for fwer below)

		*******************************************************************************
		** 1) False Discovery Rate corrections


		dis "Prepping FDR-pvalues for ${cty}"

		** 1.1) import p-values
		foreach ph in fu fu2 {
		    
			// define where pvals live
			if "`ph'" == "fu"  local pvals "${regstats_Followup_${cty}}"
			if "`ph'" == "fu2" local pvals "${regstats_Followup_2_${cty}}"

			// import p-values from FU1 or FU2
			use "`pvals'/`ph'_NER_regstats_hh", clear
			qui sum mht_family, d 
			local max_fams `r(max)'

			capture append using "`pvals'/`ph'_NER_regstats_child", gen(obs_level)
			if _rc == 0 { // if append works
				// adjust family numbers 
				replace mht_family = mht_family + `max_fams' if obs_level == 1
				drop obs_level			
			}
			
			gen rank = _n
			
			tempfile `ph'_pvals
			save 	``ph'_pvals'
		}
		
		
		** 1.2) merge p-values from FU1 and FU2
		use "`fu_pvals'", clear
		rename p? p_t?_fu1
		merge 1:1 var_name mht_family using "`fu2_pvals'", nogen keepusing(p*)
		rename p? p_t?_fu2
		sort rank
		order rank mht_family
		
		
		** 1.3) categorize vars by MHT family
		// copy families from asp_regs
		foreach id in hh child {
			qui asp_012_list_vars_ner_usd, id(`id')
		}
		
		
		// collect all families in desired order in final table
		local fam_a1 		`r(pap__a1)' // table 1
		local fam_b2_sethh 	`r(pap__b2_sethh)' // table 2a
		local fam_b2_setben	`r(pap__b2_setben)' // table 2b
		local fam_b4z   	`r(pap__b4z)' // table 4 
		local fam_c2z     	`r(pap__c2z)' // table 5
		local fam_b10z   	`r(pap__b10z)' // table 6
		local fam_b8_hh 	`r(pap__b8_hh)' // a6
		local fam_d4 		`r(pap__d4)' // a7
		local fam_d5 		`r(pap__d5)' // a8
		local fam_d3_daysa 	`r(pap__d3_daysa)' // a9
		local fam_d3_daysb 	`r(pap__d3_daysb)' // a9
		local fam_b6 		`r(pap__b6)' // a10a. a10b omitted
		local fam_b5    	`r(pap__b5)' // a11
		
		
		local fams  fam_a1 ///
					fam_b2_sethh ///
					fam_b2_setben ///
					fam_b4z ///
					fam_c2z ///
					fam_b10z ///
					fam_b8_hh ///
					fam_d4 ///
					fam_d5 ///
					fam_d3_daysa ///
					fam_d3_daysb ///
					fam_b6 ///
					fam_b5

		gen fam_name = "", after(mht_family)
		forval i = 1/`=_N' { // loop thru the obs (vars)
			foreach fam in `fams' { // foreach family
				local varname
				local varname `"`=var_name[`i']'"'
				local thisvar `varname' // collect local inside another local to use in list
				local thistest : list thisvar in `fam' // test list overlap
				if `thistest' == 1 {
					replace fam_name = "`fam'" in `i' if fam_name == ""
				}
			}
		}
		sort mht_family rank 
		
		
		** 1.4) handle exceptions
		// irritating manual step: delete this mix of vars (bringing in MHT ps later)
		// 9 redundant vars collected here from other families. 
		drop if inlist(mht_family, 5, 6) // d3_newa/b
		
		// remove component groups
		gen dropvars = fam_name == ""
		byso mht_family : egen dropfams = max(dropvars)
		drop if dropfams == 1
		drop drop*
		
		// 2 redundancies will keep
		byso var_name : egen dups = rank(rank)
		sort mht_family rank 
		replace fam_name = fam_name[_n-1] if dups == 2 // 

		// There are 2 redundant variables in the b2sethh family
		// I'll correct these twice. Once for b2sethh and another time in 
		// their respective families where the correction should be more conservative
		
		
		
		** 1.5) FDR corrections
		// keep main tables only (if count of varname != count of famname, then dup.
		byso mht_family : egen tot_fam = count(fam_name)
		byso mht_family : egen tot_var = count(var_name)
		drop if tot_fam != tot_var // drops unwanted families (where some varnames are missing)
		isid var_name fam_name // ensure no duplicated variables
		
		ds p_t* // run through treatment arms and followup phases (6 values for each reg)
		foreach var in `r(varlist)' {
			qqval_yk `var' mht_family , methods(simes) // generate two corrections (6*2 +6 = 18 p-values!)
		}
		foreach phase in fu1 fu2 {
			gen `phase' = "__fdr_`phase'__", before(p_t1_`phase'_simes_q)
		}

		// save outcomes for both phases in regstats
		save "${regstats_Followup_2_${cty}}/mht/mht_fdr_simes", replace 
		
		
		
		
		**------------------------------
		// using same vars, create dataset with variable descriptions and var_name
		
		** 1.6.1) collect mht varnames from fdr dataset		
		local varnames // initiate empty var
		forval i = 1/`=_N' {
			local varname
			local varname `"`=var_name[`i']'"'
			local varnames : list varnames | varname
		}

		dis "`varnames'"

		** 1.6.2) collect variable descriptions from asp_013_label_vars_ner.do
		clear
		insobs 1
		foreach var in `varnames' {
			gen `var' = . // create empty vars just to label them
		}
		asp_013_label_vars_ner, section("mht") stack_opt("vertical") // label vars

		
		foreach var in `varnames' {
			local lab : var label `var' // dep var label
			local varname "`var'"
			preserve
				clear
				insobs 1
				qui gen var_name = "`varname'"
				qui gen var_lab = "`lab'"
			
				tempfile `var'_names
				save 	``var'_names'
				dis "var_names = ``var'_names'"
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

		// again, save in same FU2 folder
		save "${regstats_Followup_2_${cty}}/mht/varnamesandlabs", replace 
		
		

		
		*******************************************************************************
		** 2) Family-wise Error Rate Corrections 
		
		** 2.1) copy families from asp_regs 
		foreach id in hh child {
			qui asp_012_list_vars_ner_usd, id(`id')
		}

		foreach ph in fu fu2 { //

			foreach fam in `fams' {
			
				if "`ph'" == "fu"  local phasenum 1
				if "`ph'" == "fu2" local phasenum 2
								
				use "${joint_fold}/Data/allrounds_NER_hh.dta", clear
				keep if phase == `phasenum'	
				dis as error "prep `fam' at phase `ph'"

				** 2.2) set up treatment dummies for mhtreg (used inside -mhtreg_yk-)
				tab treatment, gen(treat_)
				rename treat_1 treat_0
				rename treat_2 treat_1
				rename treat_3 treat_2
				rename treat_4 treat_3
				
				// clear varnames foreach family used to name rows in matrix
				local varnames 
				foreach var in ``fam'' {
					local varname "`var'"
					local varnames : list varnames | varname
				}
				dis "`fam' = `varnames'"

				// used in mhtreg_yk options 
				dis as error "`fam'"
				foreach var in ``fam'' {
					dis as result "  `var'"
				}
				
				
				** 2.3) run mht reg 
				// control bootstrap settings from master file
				if 		$hpc_switch == 0 local bootloops 2
				else if $hpc_switch == 1 local bootloops 3000
				
				noisily mhtreg_yk ``fam'' , fam_name(`fam') cluster_var(cluster) bootstrap_loops(`bootloops')
				
				// save results in matrix
				mat rownames mat_`fam' = `varnames'
				mat colnames mat_`fam' = p_thm3_1_`ph'_t1 p_thm3_1_`ph'_t2 p_thm3_1_`ph'_t3
				mat list mat_`fam'
			}
			
			** 2.4) stack all results
			local fam_n 1
			foreach fam in `fams' {
				if (`fam_n' == 1) matrix thm3_1_collect = mat_`fam'  // start matrix for 1st fam
				if (`fam_n' >  1) matrix thm3_1_collect = thm3_1_collect \ mat_`fam'  // then append other fams
				local fam_n = `fam_n' + 1
			}

			
			** 2.5) clear and print table of corrected p-values with column and row labels
			clear 
			svmat2 thm3_1_collect, names(col) rnames(var_name)
			order var_name, first

			gen rank = _n
			gen fam_name = "", before(var_name)
			foreach fam in `fams' { // foreach family
				forval i = 1/`=_N' { // loop thru the obs (vars)
					local varname
					local varname `"`=var_name[`i']'"'
					local thisvar `varname' // collect local inside another local to use in list
					local thistest : list thisvar in `fam' // test list overlap
					if `thistest' == 1 {
						replace fam_name = "`fam'" in `i' if fam_name == ""
					}
				}
			}
			// 2 redundancies will keep
			byso var_name : egen dups = rank(rank)
			sort rank 
			replace fam_name = fam_name[_n-1] if dups == 2 // 
			

			isid var_name fam_name // ensure no duplicated variables
			drop rank


			tempfile `ph'_fwer
			save 	``ph'_fwer', replace
		}

		** 2.6) merge survey rounds
		use `fu_fwer', clear
		merge 1:1 fam_name var_name using `fu2_fwer', gen(_mthm3_1_fu2)
		assert _mthm3_1_fu2 == 3
		drop _mthm3_1_fu2
		
		// save in FU2 folder
		if 		$hpc_switch == 0 local filesuffix _testrun // bootstrap != 3000
		else if $hpc_switch == 1 local filesuffix 		  // bootstrap == 3000
		save "${regstats_Followup_2_${cty}}/mht/mht_fwer_thm3_1`filesuffix'", replace 
		
		
		
		
		*******************************************************************************
		** 3) Prepare table si5 
		/*
		merge - mht_fdr_simes 
			  - mht_fwer_thm3_1_fu1
			  - mht_fwer_thm3_1_fu2
			  - varnamesandlabs
		*/


		** 3.1) bring together FDR and FWER results
		use "${regstats_Followup_2_${cty}}/mht/mht_fdr_simes", clear
		merge 1:1 fam_name var_name using "${regstats_Followup_2_${cty}}/mht/mht_fwer_thm3_1`filesuffix'", gen(_mthm3_1)
		merge m:1 var_name using "${regstats_Followup_2_${cty}}/mht/varnamesandlabs", gen(_mvarnamlab)
		
		
		// make sure all vars are labelled here
		sort rank
		
		assert _mthm3_1 == 3
		assert _mvarnamlab == 3
		order var_lab, after(var_name)
		drop _mthm3_1 _mvarnamlab
		gen fu1_fwer = "__fwer_fu__", before(p_thm3_1_fu_t1)
		gen fu2_fwer = "__fwer_fu2__", before(p_thm3_1_fu2_t1)
		sort rank
		isid var_name fam_name
		
		
		** 3.2) generate family order var
		local countfams 1
		gen appendix_order = .
		foreach fam in `fams' { // foreach family
			replace appendix_order = `countfams' if fam_name == "`fam'"
			local countfams = `countfams' + 1
		}
		
		
		sort appendix_order rank
		
		** 3.3) order variables by phase --> treatment --> actual, fdr, fwer
		rename p_thm3_1_fu_t*  p_t*_fu1_thm3_1
		rename p_thm3_1_fu2_t* p_t*_fu2_thm3_1
		// actual: p_ti_fux
		// fdr-q:  p_ti_fux_simes_q
		// fwer-p: p_ti_fux_thm3_1
		
		order p_t1_fu1 	p_t1_fu1_simes_q 	p_t1_fu1_thm3_1 /// FU1: T1
			  p_t2_fu1 	p_t2_fu1_simes_q 	p_t2_fu1_thm3_1 /// FU1: T2
			  p_t3_fu1 	p_t3_fu1_simes_q 	p_t3_fu1_thm3_1 /// FU1: T3
			  p_t1_fu2 	p_t1_fu2_simes_q 	p_t1_fu2_thm3_1 /// FU2: T1
			  p_t2_fu2 	p_t2_fu2_simes_q 	p_t2_fu2_thm3_1 /// FU2: T2
			  p_t3_fu2 	p_t3_fu2_simes_q 	p_t3_fu2_thm3_1, ///  FU2: T3
				after(var_lab)
		drop fu1 fu2 fu1_fwer fu2_fwer
		
		
		local table_title "Supplementary Table SI.5: Multiple Hypothesis Test Corrections"
		
		
		** 3.4) prepare latex space
		insobs 35, before(1)
		gen header_rank = _n if var_lab == ""
		// fill in latex header for longtable
		gen latex_text = "" if header_rank == 1
		replace latex_text = "\begin{longtable}{p{.00001\textwidth} >{\raggedright}p{.2\textwidth} cccccccccccccccccc} % 20 total (18 p-values)"  if header_rank == 2
		replace latex_text = "" if header_rank == 3
		replace latex_text = "\caption{`table_title'}        \label{tab:mht_corrections} \\"  if header_rank == 4
		replace latex_text = "" if header_rank == 5
		replace latex_text = "%\centering"  if header_rank == 6 //6
		replace latex_text = "\hline \hline"  if header_rank == 7 // 7
		replace latex_text = "& & \multicolumn{9}{c}{6 months post-intervention} \multicolumn{9}{c}{18 months post-intervention} \\ \cmidrule(lr){3-11} \cmidrule(lr){12-20}   "  if header_rank == 8 //8
		replace latex_text = "" if header_rank == 9        
		replace latex_text = "\multicolumn{2}{l}{\textbf{MHT family}} & \multicolumn{3}{c}{Capital Arm} & \multicolumn{3}{c}{Psychosocial Arm} & \multicolumn{3}{c}{Full Arm} & \multicolumn{3}{c}{Capital Arm} & \multicolumn{3}{c}{Psychosocial Arm} & \multicolumn{3}{c}{Full Arm} \\ \cmidrule(lr){3-5} \cmidrule(lr){6-8} \cmidrule(lr){9-11} \cmidrule(lr){12-14} \cmidrule(lr){15-17} \cmidrule(lr){18-20} "  if header_rank == 10 // 10
		replace latex_text = "" if header_rank == 11
		replace latex_text = "& Variable & Actual & FDR$^\dag$ & FWER$^\ddag$ & Actual & FDR & FWER & Actual & FDR & FWER & Actual & FDR & FWER & Actual & FDR & FWER & Actual & FDR & FWER \\ \hline  "  if header_rank == 12 // 12
		replace latex_text = "\endfirsthead"  if header_rank == 13 // 13
		replace latex_text = "" if header_rank == 14 // 14
		replace latex_text = "\multicolumn{20}{c}{{\bfseries `table_title'  -- continued from previous page}} \\ \hline "  if header_rank == 15 //15
		replace latex_text = "& & \multicolumn{9}{c}{6 months post-intervention} \multicolumn{9}{c}{18 months post-intervention} \\ \cmidrule(lr){3-11} \cmidrule(lr){12-20}   "  if header_rank == 16 // 16
		replace latex_text = "" if header_rank == 17 //17
		replace latex_text = "\multicolumn{2}{l}{\textbf{MHT family}} & \multicolumn{3}{c}{Capital Arm} & \multicolumn{3}{c}{Psychosocial Arm} & \multicolumn{3}{c}{Full Arm} & \multicolumn{3}{c}{Capital Arm} & \multicolumn{3}{c}{Psychosocial Arm} & \multicolumn{3}{c}{Full Arm} \\ \cmidrule(lr){3-5} \cmidrule(lr){6-8} \cmidrule(lr){9-11} \cmidrule(lr){12-14} \cmidrule(lr){15-17} \cmidrule(lr){18-20} "  if header_rank == 18 //18
		replace latex_text = "" if header_rank == 19 // 19
		replace latex_text = "& Variable & Actual & FDR$^\dag$ & FWER$^\ddag$ & Actual & FDR & FWER & Actual & FDR & FWER & Actual & FDR & FWER & Actual & FDR & FWER & Actual & FDR & FWER \\ \hline"  if header_rank == 20 // 20
		replace latex_text = "" if header_rank == 21 //21
		replace latex_text = "\endhead"  if header_rank == 22 // 22
		replace latex_text = "" if header_rank == 23 // 23
		replace latex_text = "\\"  if header_rank == 24 // 24
		replace latex_text = "\multicolumn{20}{c}{{Continued on next page}} \\ \hline"  if header_rank == 25 // 25
		replace latex_text = "\endfoot"  if header_rank == 26 // 26
		replace latex_text = "" if header_rank == 28 //27
		replace latex_text = "\hline \hline"  if header_rank == 28 // 28
		replace latex_text = "\multicolumn{20}{p{1.25\textwidth}}{{Notes: For variables in Extended Data Table 3, see Supplementary Tables SI.6-SI.8. At each survey phase and within each treatment arm, we correct p-values for multiple hypothesis testing within each family of variables. Columns labeled \textit{actual} show the p-values used in the main tables. Italics: p $<$ 0.1. Bold: p $<$ 0.05. Bold and underlined: p $<$ 0.01. }} \\ "  if header_rank == 29 // 29
		replace latex_text = "\multicolumn{20}{p{1.25\textwidth}}{{\dag: Columns labeled FDR show False Discovery Rate-adjusted q-values following the step-up approach of \textcite{benjamini1995controlling} which assumes that the p-values within a family are positively correlated.}} \\ "  if header_rank == 30 // 30 
		replace latex_text = "\multicolumn{20}{p{1.25\textwidth}}{{\ddag: Columns labeled FWER show Family-Wise Error Rate-corrected p-values following the procedure outlined by \textcite{barsbai2020information} that captures the existing correlation between p-values by exploiting treatment randomization and runing a bootstrap resampling procedure.}} \\ "  if header_rank == 31 // 31
		replace latex_text = "\multicolumn{20}{p{1.25\textwidth}}{{In the pre-analysis plan, we indicate we would apply multiple hypothesis corrections on the set of tests that include all individual arm treatment effects on each outcome within an outcome family.  Here we instead only correct for multiple hypotheses \textit{within} each treatment arm across the outcomes in each family.  We now believe this is sufficient because treatment arms were pre-defined. }} \\ "  if header_rank == 32 // 32
		replace latex_text = "\multicolumn{20}{p{1.25\textwidth}}{{Changes to the pre-specified outcomes families were only made only for ease of display, interpretability, and comparisons. For the avoidance of doubt, the multi-hypothesis tests are shown for the originally defined outcome families. }} \\ "  if header_rank == 33 // 33
		replace latex_text = "\endlastfoot"  if header_rank == 34 // 34
		replace latex_text = "" if header_rank == 35 // 35
			   
		insobs 1, after(_N)
		replace latex_text = "\end{longtable}" if header_rank == . & var_lab == "" // close table off
		// new rank after header and footer
		gen new_rank = _n
		order *rank*

		// insert family dividers within table
		byso appendix_order : egen first_var_in_grp = rank(rank), track
		order first_var_in_grp, after(mht_family)
		sort new_rank rank
		replace first_var_in_grp = . if first_var_in_grp > 1 // keep first var in group
		// insert two obs before each first var (for family title and line break)
		expand 3 if first_var_in_grp == 1, gen(this_is_fam_title)
		sort new_rank rank this_is_fam_title // bring copies near sister observation
		order this_is_fam_title
		replace this_is_fam_title = . if first_var_in_grp == .
		byso appendix_order this_is_fam_title : gen within_title_rank = _n
		replace within_title_rank = . if this_is_fam_title != 1
		order within_title_rank
		sort new_rank rank within_title_rank // bring copies near sister observation

		// insert family group line break
		replace latex_text = "\\" if within_title_rank == 1

		// insert family title in latex_text variable
		foreach fam in `fams' { // foreach family
			
			// main tables
			if "`fam'" == "fam_a1"    	local section_title "\hyperref[tab:a1_main]{Extended Data Table 1} Consumption and Food Security"
			if "`fam'" == "fam_b2_sethh"  local section_title "\hyperref[tab:b2_sethh_main]{Extended Data Table 2a} Household Revenues"
			if "`fam'" == "fam_b2_setben" local section_title "\hyperref[tab:b2_setben_main]{Extended Data Table 2b} Beneficiary Revenues"
			if "`fam'" == "fam_b4z"   	local section_title "\hyperref[tab:b4z_main]{Extended Data Table 4} Psychological Well-Being"
			if "`fam'" == "fam_c2z"   	local section_title "\hyperref[tab:c2z_main]{Extended Data Table 5} Social Well-Being"
			if "`fam'" == "fam_b10z"  	local section_title "\hyperref[tab:b10z_main]{Extended Data Table 6} Women's control over earnings and household decision-making"
			
			// annex tables		
			if "`fam'" == "fam_b8_hh" 	local section_title "\hyperref[tab:b8_hh_main]{Supplementary Table SI.6} Off-Farm Activities (Household)"
			if "`fam'" == "fam_d4"    	local section_title "\hyperref[tab:d4_main]{Supplementary Table SI.7} Agriculture (Household)"
			if "`fam'" == "fam_d5"    	local section_title "\hyperref[tab:d5_main]{Supplementary Table SI.8} Livestock (Household)"
			if "`fam'" == "fam_d3_daysa" local section_title "\hyperref[tab:d3_days_maina]{Supplementary Table SI.9a} Labor Participation (Household)"
			if "`fam'" == "fam_d3_daysb" local section_title "\hyperref[tab:d3_days_mainb]{Supplementary Table SI.9b} Labor Participation (Beneficiary)"
			if "`fam'" == "fam_b6"    	local section_title "\hyperref[tab:b6_main]{Supplementary Table SI.10a} Financial Engagement"
			if "`fam'" == "fam_b5"    	local section_title "\hyperref[tab:b5_main]{Supplementary Table SI.11} Assets (Household)"

			
			replace latex_text = "\multicolumn{20}{l}{\textbf{`section_title'}} \\" if ///
					within_title_rank == 2 & ///
					fam_name == "`fam'"		
		}	

		// round up all p-values to 2 dp for size
		gen zeros = "0"
		ds p_*
		foreach var in `r(varlist)' {
			// clear these foreach var
			gen prefix = "", after(`var')
			gen suffix = "", after(prefix)
			
			// mark values by size to format font below
			forval i = 1/`=_N' {
				local value
				local value `"`=`var'[`i']'"'
				if 		(`value' < 0.01) local prefix "\textbf{\underline{"
				else if (`value' < 0.05) local prefix "\textbf{"
				else if (`value' < 0.1)  local prefix "\textit{"
				else if (`value' >= 0.1) local prefix ""
				
				if 		(`value' < 0.01) local suffix "}}"
				else if (`value' < 0.05) local suffix "}"
				else if (`value' < 0.1)  local suffix "}"
				else if (`value' >= 0.1) local suffix ""
				
				replace prefix = "`prefix'" in `i'
				replace suffix = "`suffix'" in `i'
			}
			replace `var' = round(`var', 0.001)
			egen `var'_txt = concat(zeros `var') if rank != .
			order `var'_txt, after(`var')
			replace `var'_txt = "0" if `var'_txt == "00"
			replace `var'_txt = `var'_txt + "0" if strlen(`var'_txt) == 4
			replace `var'_txt = `var'_txt + "00" if strlen(`var'_txt) == 3
		// 	replace `var'_txt = "0" if `var'_txt == "01"
			
			egen `var'_txt2 = concat(prefix `var'_txt suffix) if rank != .
			order `var'_txt2, after(`var'_txt)

			drop prefix suffix `var'_txt `var'
			rename `var'_txt2 `var'
		}


				
		// bring it all together
		gen space = " ", before(var_lab)
		ds space var_lab p_* // list vars to concatenate with & (20 items in total: table width)
		egen latex_temp = concat(`r(varlist)') ///
			if rank != . & ///
			this_is_fam_title != 1 , ///
				punct(" & ") // bring all vars and estimates together
		replace latex_temp = latex_temp + " \\"  ///
			if rank != . & ///
			this_is_fam_title != 1

		replace latex_text = latex_temp if latex_temp != ""

		gsort new_rank within_title_rank // seal the deal

		keep latex_text


		// fix variable labels
		replace latex_text = subinstr(latex_text, "Business revenues (benef., yearly, USD)", "Business revenues (benef.)", .)
		replace latex_text = subinstr(latex_text, "Business revenue (yearly, USD)", "Business revenue (benef.)", .)
		replace latex_text = subinstr(latex_text, "Business revenue (yearly, USD)", "Business revenue (benef.)", .)
		// 
		// Harvest value (yearly, USD)
		// Livestock revenue (yearly, USD)
		// Wage revenue (yearly, USD)
		// Benef. HH


		keep latex_text
		
		** 3.5) save latex file 
		outfile using "${joint_output_${cty}}/report_tables/table_si5.tex", noquote wide replace
		

	
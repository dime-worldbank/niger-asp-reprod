/*
Define program that prepares the standard iebaltab balance table 
but adds to it columns for additional tests beyond just the joint F.
It also changes the table to tabular format in latex.
It takes into account two sections and stacks the second as a new panel.

Outline:
** 1) variable names 
** 2) F-tests
** 3) t-tests
** 4) postprocess balance table

*/

pause on

capture prog drop tex_stack_iebaltab
prog define tex_stack_iebaltab
	syntax,  seg1(string) ///
			[table_note1(string) table_note2(string) table_note3(string) ///
			 table_note4(string) table_note5(string) table_note6(string) ///
			 table_note7(string) ///
			 seg1_header(string) ///
			 seg2(string) ///
			 seg2_header(string) ///
			 indentthese(string) ///
			 QUIetly]
	
	
	nois dis as text "	- Running do-file: tex_stack_iebaltab"

`quietly' {

	if "`seg1'" != "" local segs `segs' seg1
	if "`seg2'" != "" local segs `segs' seg2
	
	local seg_n : word count `segs'

	** 1) variable names 
	// generate dataset with variable names and labels to match in merge later
	foreach segment in `segs' {
		local i 1
		foreach var in ``segment'' {
			local var_`i' "`var'"
			local lab_`i' : var label `var'
			local i = `i' + 1
		}
		preserve // branch off and generate new dataset with these locals
			clear
			local var_n : word count ``segment''
			set obs `var_n'
			gen varname = ""
			gen varlab = ""
			forval i = 1/`var_n' {
				replace varname = "`var_`i''" in `i'
				replace varlab = "`lab_`i''" in `i'
			}
			tempfile var_names_and_labs_`segment'
			save 	`var_names_and_labs_`segment''
		restore
	}

		
	foreach segment in `segs' {

		local within_seg_n 0
		
		** 2) F-tests
		foreach var in ``segment'' {
		
			** -----| 2.1)  run regression 1 for special stats
			qui areg `var' i.treatment, cluster(cluster) absorb(strata)

			// capture p-value for model F-test
			qui test i1.treatment = i2.treatment = i3.treatment
			local F_test_joint : di %15.3fc `r(p)'

			** -----| 2.2)  run regression 2 for special stats
			qui areg `var' treat_dum, cluster(cluster) absorb(strata)
			mat my_reg = r(table)
			local F_test_tdum = my_reg[4,1]
			local F_test_tdum : di %15.3fc `F_test_tdum'
			
			mat other_tests = (`F_test_joint', `F_test_tdum')
			matrix colnames other_tests = joint_f pooled_f
			matrix rownames other_tests = "`var'"
			
			// Concatenate p-vals within each SPEC
			if (`within_seg_n' == 0) matrix other_tests_long = other_tests  // start matrix for 1st var in section 
			if (`within_seg_n' >  0) matrix other_tests_long = other_tests_long \ other_tests  // then append to p_collect

			local within_seg_n = `within_seg_n' + 1
		}
		preserve
			clear
			svmat2 other_tests_long, rnames(varname) names(col)
			order varname, first
			
			tempfile var_names_and_tests_`segment'
			save 	`var_names_and_tests_`segment''
		restore

		
		// define local for footnote resizing and use below for small edit
		local footnote_resize 1.325
		
		
		** 3) t-tests: run iebaltab for pair-wise stats
		iebaltab ``segment'', 						/// 						
			grpvar(treatment) 						///
			savetex(${git_dir}/Baseline/Output/${cty}/balance/balancetable_`segment') ///
			fixedeffect(strata)    					///
			vce(cluster cluster)  					///
			pttest									/// show p-values instead of t-test diffs
			tblnote("`table_note1'" 				///
					"`table_note2'" 				///
					"`table_note3'"   				///
					"`table_note4'"   				///
					"`table_note5'"   				///
					"`table_note6'"   				///
					"`table_note7'") 				///
			tblnonote 								/// 
			texnotewidth(`footnote_resize') 		///	
			rowvarlabels 							/// use variable labels
			onerow 									///
			replace 
	}
	//  }


	local seg_ct 0
	
	** 4)  postprocess balance table
	foreach segment in `segs' {
	
		local seg_ct = `seg_ct' + 1

		import delimited "${git_dir}/Baseline/Output/${cty}/balance/balancetable_`segment'.tex", clear

		// concatenate tex info into one column keeping commas intact since -import- parses at commas
		fix_import

		gen rank = _n
		
		// remove backslash before $
		// need double slash "\\" inside stata to catch single \
		replace text = subinstr(text, "\\$", "$", .) if strpos(text, "\\$") > 0 
		
		// merge in additional stats
		split text, parse("&")
		gen varlab = strtrim(text1)
		merge m:1 varlab  using "`var_names_and_labs_`segment''", gen(_mnames)
		sort rank 
		
		merge m:1 varname using "`var_names_and_tests_`segment''", gen(_mstats)
		sort rank 
		
		// fix decimal places on new f-tests

		foreach var in joint_f pooled_f {
			gen `var'_txt = string(`var')
			replace `var'_txt = `var'_txt + "0" if strlen(`var'_txt) == 3 // if dp = 2
			replace `var'_txt = `var'_txt + "*" if `var' < 0.1  // give it a star
			replace `var'_txt = `var'_txt + "*" if `var' < 0.05 // give it another
			replace `var'_txt = `var'_txt + "*" if `var' < 0.01 // and another
			replace `var'_txt = "" if `var'_txt == "." // clear empty cells
			replace `var'_txt = " 0" + `var'_txt if `var'_txt != "" // add "ones" zero
			drop `var'
		}
		
		drop varlab varname _mnames _mstats // drop variables used in merge
		ds text*
		local varneeded : word count `r(varlist)'
		local varneeded = `varneeded' - 1
		split text`varneeded', parse(" ")
		replace text`varneeded' = text`varneeded'1
		drop text`varneeded'1

		// adjust column headers for new and old stats
		replace joint_f_txt  = "(5)" if text`varneeded'3 != ""
		replace pooled_f_txt = "(6)" if text`varneeded'3 != ""

		forval i = 1/`=_N' { 
			// new stats
			local joint_entry
			local joint_entry `"`=joint_f_txt[`i']'"'
			local change_i2 = `i' - 2
			local change_i1 = `i' - 1
			if strpos("`joint_entry'", "(5)") > 0 {
				replace joint_f_txt  = " Joint F-test " in `change_i2'
				replace joint_f_txt  = " p-value " in `change_i1'
				replace pooled_f_txt  = " Pooled F-test \\" in `change_i2'
				replace pooled_f_txt  = " p-value \\" in `change_i1'
			}		
			
			// old stats
			qui ds text? text?? // list parsed vars
			local words : word count `r(varlist)'
			forval j = 1/`words' { // foreach var 
				local entry
				local entry `"`=text`j'[`i']'"'
				local this "text`j'"
				if (strpos("`entry'", "Mean/SE") > 0) local swaplist : list swaplist | this
			}
			foreach var in `swaplist' {
				local entry
				local entry `"`=`var'[`i']'"'
				local entry1
				local entry1 `"`=`var'[`i'-1]'"'
				local entry2
				local entry2 `"`=`var'[`i'-2]'"'
				
				if strpos("`entry'", "Mean/SE") > 0 {
					dis "`entry1'"
					dis "`entry'"
					dis "`entry2'"
					
					replace `var' = "`entry1'" in `change_i2'
					replace `var' = "`entry'" in `change_i1'
					replace `var' = "`entry2'" in `i'
				}
			}
		}
		
		ds text`varneeded'?
		egen conc_text_needed = concat(`r(varlist)'), punct(" ")
		replace pooled_f_txt = pooled_f_txt + " " + conc_text_needed
		drop text`varneeded'?

		// remove line ending from old column header list and add it to 
		local varneeded_new = `varneeded' - 5
		replace text`varneeded_new' = subinstr(text`varneeded_new', "  \\", " ", .)
		
		// change table settings to accomodate 2 new columns
		replace text1 = subinstr(text1, "lcccccccccc", "lcccccccccccc", 1) // add two c's

		// insert line under p-value row
		replace text = subinstr(text, "P-value", "p-value", .)
		replace text = text + "\cmidrule(lr){6-11}" if strpos(text, "\multicolumn{6}{c}{p-value}") > 0 

		// bring it all together
		sort rank
		drop rank conc_text_needed
		gen text_new = text1
		ds text text1 text_new, not
		foreach var in `r(varlist)' {
			replace text_new = text_new + "&" + `var' if strtrim(`var') != ""
		}
		
		// make footnote wider (13 instead of 11 because 1 var, 4 Ts, 6  T-tests, and 2 new F-tests)
		replace text_new = subinstr(text_new, "\multicolumn{11}{@{} p{`footnote_resize'\textwidth}}", ///
											  "\multicolumn{13}{@{} p{`footnote_resize'\textwidth}}", .)
		
		// change format from tabular to longtable
		replace text_new = subinstr(text_new, "\begin{tabular}{@{\extracolsep{5pt}}", ///
											  "\begin{longtable}{", .)
		
		// indent rows that need to be indented
		foreach lab in `indentthese' {
			replace text_new = subinstr(text_new, "`lab' &", "\hspace{0.25cm} `lab' &", .) 
		}
		
		keep text_new
		rename text_new text
		
		// stack other segments below seg1
		if "`segment'" == "seg1" {	
			
			// opening and closing
			gen rank = _n
			replace text = subinstr(text, "\end{tabular}", "\end{longtable}", .) if rank == _N
			insobs 1, before(2) // second obs
			replace text = "\caption{Supplementary Table SI.1: Balance and Attrition}        \label{tab:bal_attr} \\" if text == ""
			insobs 1, before(7) // second obs
			replace text = "\endfirsthead" if text == ""
			drop rank
			gen rank = _n
			gen dup_rows = 1 if strpos(text, "Joint F-test") > 0 | ///
								strpos(text, "Mean/SE") > 0 | ///
								strpos(text, "Variable &") > 0 
			expand 2 if dup_rows == 1, gen(dup_these)
			qui sum rank if strpos(text, "endfirsthead")
			local under_here `r(mean)'
			replace rank = `r(mean)' + rank / 100 if dup_these == 1
			sort rank
			insobs 1, after(10)
			replace text = "\endhead" if text == ""
			insobs 1, before(8)
			replace text = "\multicolumn{13}{c}{{\bfseries Supplementary Table SI.1: Balance and Attrition -- continued from previous page}} \\ \hline" if text == ""
			insobs 1, after(12)
			replace text = "\\" if text == ""
			insobs 1, after(13)
			replace text = "\multicolumn{13}{c}{{Continued on next page}} \\ \hline" if text == ""
			insobs 1, after(14)
			replace text = "\endfoot" if text == ""
			
			// pull up note
			gen move_note = 1 if strpos(text, "This is the note") > 0
			qui sum rank if move_note == 1
			local note_n `r(mean)'
			replace move_note = 1 if rank == `note_n' - 1
			replace move_note = 1 if rank == `note_n' + 1
			replace move_note = 1 if rank == `note_n' + 2
		
			// capture location to which to move
			drop rank dup_*
			gen rank = _n
			qui sum rank if strpos(text, "\endfoot") > 0
			replace rank = `r(mean)' + rank/100 if move_note == 1
			sort rank

			drop rank move_note
			gen rank = _n
			qui sum rank if strpos(text, "textit{Notes") > 0
			local here = `r(mean)'
			insobs 1, after(`here')
			replace text = "\endlastfoot" if text == ""
			local new = `here' + 1
			insobs 1, after(`new')
			replace text = "\\" if text == ""
			
			replace text = trim(itrim(text))
			
			keep text
		}
		else {
		
			// stack under seg1
			
			keep if strpos(text, "begin{tabular") > 0 | /// stats
					strpos(text, "N &") > 0 | 			/// sample size
					strpos(text, "Clusters") > 0 		// no. of clusters
					
			insobs 1, before(1) // insert a panel header for new segment 
			replace text = "\multicolumn{13}{l}{`seg`seg_ct'_header'} \\" in 1
			insobs 1, before(1) // insert a panel header for new segment 
			replace text = "\\" in 1

			tempfile seg_stats
			save 	`seg_stats'
			
			
			// import seg1
			import delimited "${git_dir}/Baseline/Output/${cty}/balance/balancetable_seg1_fixed.tex", clear
			fix_import
			
			append using `seg_stats'
			replace text = trim(itrim(text))
			
			// move end{logntable} to new bottom
			drop if strpos(text, "\end{longtable}")
			insobs 1
			replace text = "\end{longtable}" in `=_N'
			
			// drop first set of "N" and "clusters" if they are duplicated
			egen dup = tag(text) 
			gen rank = _n
			byso text : egen drophigh = rank(rank), field
			levelsof drophigh
			sort rank
			drop if drophigh == 2 & (strpos(text, "N &") > 0 | 	/// sample size
									 strpos(text, "Clusters") > 0) // clusters
									 
			keep text
			
		}
		
		
		// save
		
		outfile using "${git_dir}/Baseline/Output/${cty}/balance/balancetable_`segment'_fixed.tex", noquote wide replace
				
		if `seg_ct' == `seg_n' { 
			
			outfile using "${git_dir}/Baseline/Output/${cty}/balance/balancetable_allsegments_final.tex", noquote wide replace
			
			// also save in reproducibility folder
			outfile using "${joint_output_${cty}}/report_tables/table_si1.tex", noquote wide replace
			
		}	
	}
} // end quietly

end

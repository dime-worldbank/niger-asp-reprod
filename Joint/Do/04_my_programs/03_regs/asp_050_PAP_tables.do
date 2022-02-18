/*
This program generates stacked FU1+FU2 tables showing more stats from tests

Date created: 11/10/2021
version 15.1

Outline:
	** 1) format reg stats: mean, SD, N
	** 2) define table locals
	** 3) save latex text incrementally as dta
	** 4) call final dta and sort
	** 5) insert gray hlines between each pair
	** 6) define header and footnotes
	** 7) generate latex text and save as text file

*/

capture prog drop asp_050_PAP_tables
program define asp_050_PAP_tables
	syntax, stats_names(string) ///
			stats_list(string) ///
			phase(integer) ///
			varlab(string) ///
			var_insection(integer) ///
			var_count(integer) ///
			var_count_tot(integer) ///
			pap_section(string) ///
			title(string) /// 
			controls_note(string) ///
			controls_note2(string) ///
			def_note(string) ///
			se_note(string) ///
			money_units_footnote(string) ///
			wins_footnote(string) ///
			index_footnote(string) ///
			section_footnote(string) ///
			components_note(string) ///
			final_table_name(string) ///
			recurs_dta(string)

			
	nois dis "	- Running do-file: asp_050_PAP_tables"

qui {
	
	** 1) format reg stats: mean, SD, N
// 	dis "`stats_names'"
// 	dis `stats_list'
	local stats_n : word count `stats_names'
	forval i = 1/`stats_n' {
		local word : word `i' of `stats_names'
		local num : word `i' of `stats_list'
		
		// round
		if "`word'" == "ctrl_mean" local num  : di %15.2fc `num'
		if "`word'" == "ctrl_sd" local num  : di %15.2fc `num'
		if "`word'" == "N" local num  : di %15.0fc `num'
		if "`word'" == "N" local num = subinstr("`num'", " ", "", .)
		local `word' `num'
		
// 		dis "`word' = ``word''"
	}
	
	local varlab = subinstr("`varlab'", "&", "", .) // drop ampersand
// 	local varlab = subinstr("`varlab'", "@{}c@{}", "@{}l@{}", .) // drop ampersand
	
	local varlab = subinstr("`varlab'", "\begin{tabular}[b]{@{}c@{}}", "", .)
	local varlab = subinstr("`varlab'", "\end{tabular}", "", .)
	local varlab = subinstr("`varlab'", "\\", " ", .)
	local varlab = strtrim("`varlab'")

	** 2) define table locals
	// col1_stretch, colhead, colstats, newrow1, newrow2, newrow1_part2

/*
	Three table set-ups are possible:
	
	  				  N/DoF (table 2)
	Ctrl mean/Ctrl SD/N/DoF (ED tables)
	Ctrl mean/Ctrl SD/N     (SI tables)
	
	I'll define:
		- the width of column1 		as `col1_stretch' to go into `newrow1/2'
		- regression stat subheader as `stathead' 	  to go into `head2'
		- column header 			as `colhead' 	  to go into `head1'
		- column stats 				as `colstats' 	  to go into `newrow1/2'
*/
	if  "`pap_section'" == "all__std1" {
		local col1_stretch 4em
		local stathead "coef/se/p"
		
		// show N/DoF (shift up with vmove=18, chosen by trial and error)
		local colhead  "\multirow{2}{*}[18]{\begin{tabular}[b]{@{}c@{}}  N/ \\  DoF \end{tabular}} & "
		local colstats 					   "\begin{tabular}[t]{@{}c@{}} `N' \\ `df' \end{tabular} & " 
	}
	else if  "`pap_section'" == "pap__a1" | /// 		ED tables
			 "`pap_section'" == "pap__b2_setben" | ///
			 "`pap_section'" == "pap__b2_sethh" | ///
			 "`pap_section'" == "pap__d3_newa" | ///
			 "`pap_section'" == "pap__d3_newb" | ///
			 "`pap_section'" == "pap__b4z" | ///
			 "`pap_section'" == "pap__c2z" | ///
			 "`pap_section'" == "pap__b10z" {
		
		local col1_stretch 4em // larger font in Extended Data
		local stathead "coef/se/p/p_{mht}" // MHT pvals to be added later for ED tables
		
		// add DoF details only in ED tables (shift up with vmove=22, trial and error)
		local colhead  "\multirow{2}{*}[22]{\begin{tabular}[b]{@{}c@{}}  Ctrl mean/ \\  Ctrl SD/ \\  N/ \\  DoF \end{tabular}} & "
		local colstats 					   "\begin{tabular}[t]{@{}c@{}} `ctrl_mean' \\ `ctrl_sd' \\ `N' \\ `df' \end{tabular} & " 
		
	}
	else {
		local col1_stretch 7em // small font in SI
		local stathead "coef/se/p" // no MHT pvals in SI
		
		local colhead  "\begin{tabular}[b]{@{}c@{}}  Ctrl mean/ \\  Ctrl SD/ \\  N  \end{tabular} & "
		local colstats "\begin{tabular}[t]{@{}c@{}} `ctrl_mean' \\ `ctrl_sd' \\ `N' \end{tabular} & " 
	}
	
	// generate row FU1
	if $phase_num == 1 {
		#delimit ;
		local newrow1 "
			\multirow[t]{2}{`col1_stretch'}{`varlab'} & \begin{tabular}[t]{@{}l@{}}6m \end{tabular} &
			\begin{tabular}[t]{@{}c@{}} `mainb_1_ph1' \\ (`mainse_1_ph1') \\ (`mainp_1_ph1') \end{tabular} & 
			\begin{tabular}[t]{@{}c@{}} `mainb_2_ph1' \\ (`mainse_2_ph1') \\ (`mainp_2_ph1') \end{tabular} & 
			\begin{tabular}[t]{@{}c@{}} `mainb_3_ph1' \\ (`mainse_3_ph1') \\ (`mainp_3_ph1') \end{tabular} & 
			`colstats'
			\begin{tabular}[t]{@{}c@{}} `b_test_3_ph1' \\ (`se_test_3_ph1') \\ (`p_test_3_ph1') \end{tabular} &
			\begin{tabular}[t]{@{}c@{}} `b_test_2_ph1' \\ (`se_test_2_ph1') \\ (`p_test_2_ph1') \end{tabular} &
			\begin{tabular}[t]{@{}c@{}} `b_test_1_ph1' \\ (`se_test_1_ph1') \\ (`p_test_1_ph1') \end{tabular}
			";
		#delimit cr
	}
	if $phase_num == 2 {
		#delimit ;
		local newrow2 "
			&  \begin{tabular}[t]{@{}l@{}}18m \end{tabular} &
			\begin{tabular}[t]{@{}c@{}} `mainb_1_ph2' \\ (`mainse_1_ph2') \\ (`mainp_1_ph2') \end{tabular} & 
			\begin{tabular}[t]{@{}c@{}} `mainb_2_ph2' \\ (`mainse_2_ph2') \\ (`mainp_2_ph2') \end{tabular} & 
			\begin{tabular}[t]{@{}c@{}} `mainb_3_ph2' \\ (`mainse_3_ph2') \\ (`mainp_3_ph2') \end{tabular} & 
			`colstats'
			\begin{tabular}[t]{@{}c@{}} `b_test_3_ph2' \\ (`se_test_3_ph2') \\ (`p_test_3_ph2') \end{tabular} &
			\begin{tabular}[t]{@{}c@{}} `b_test_2_ph2' \\ (`se_test_2_ph2') \\ (`p_test_2_ph2') \end{tabular} &
			\begin{tabular}[t]{@{}c@{}} `b_test_1_ph2' \\ (`se_test_1_ph2') \\ (`p_test_1_ph2') \end{tabular} & & & \\
			";
		local newrow1_part2 "
			\begin{tabular}[t]{@{}c@{}} `b_cross_1' \\ (`se_cross_1') \\ (`p_cross_1') \end{tabular} & 
			\begin{tabular}[t]{@{}c@{}} `b_cross_2' \\ (`se_cross_2') \\ (`p_cross_2') \end{tabular} & 
			\begin{tabular}[t]{@{}c@{}} `b_cross_3' \\ (`se_cross_3') \\ (`p_cross_3') \end{tabular} \\ %%seal
			";
		#delimit cr
	}
	local newrow1 = trim(itrim("`newrow1'"))
	local newrow2 = trim(itrim("`newrow2'"))
	local newrow1_part2 = trim(itrim("`newrow1_part2'"))

// 	foreach line in newrow1 newrow2 newrow1_part2 {
// 		nois dis "`line': "
// 		nois dis "	``line''"
// 	}
// nois dis "$ph"
// nois dis "$phase_num"
// pause	


	
	** 3) save latex text incrementally as dta
	if $phase_num == 1 {	
		preserve
			if `var_insection' == 1 {
				clear
				qui insobs 1		
				qui gen text = "`newrow1'"
				qui gen sec = "`pap_section'"
				
				sleep 1000
				save "${regstats_${phase}_${cty}}/`recurs_dta'.dta", replace
			}
			else { // not first var
				
				use "${regstats_${phase}_${cty}}/`recurs_dta'.dta", clear
				
				qui insobs 1		
				qui replace text = "`newrow1'" if text == "" // add new row with new var
				qui replace sec = "`pap_section'" if sec == ""
				
				sleep 1000
				save "${regstats_${phase}_${cty}}/`recurs_dta'.dta", replace
			}
		restore
	}
	if $phase_num == 2 {
		preserve
			use "${regstats_Followup_${cty}}/`recurs_dta'.dta", clear // fetch FU1 tests
			
			qui insobs 1		
			// add cross tests to first line

// 			dis as error "`varlab'"
// 			dis as error "`newrow1_part2'"

			replace sec = "`pap_section'" if sec == ""
			replace text = text + " & " + "`newrow1_part2'" if ///
				strpos(text, strtrim("`varlab'")) > 0 & /// same var at FU1
				sec == "`pap_section'" & /// same section (in case var labels are same in diff sections)
				strpos(text, "\\ %%seal") == 0 // and no seal yet
			replace text = "`newrow2'" if text == "" // add new row with FU2

			sleep 1000
			qui save "${regstats_Followup_${cty}}/`recurs_dta'.dta", replace
		restore
	}

			
			
	if $phase_num == 2 {
// 		local var_counthere = `var_count' - 1
// 		nois dis "`var_count' == `var_count_tot'"
		
		if `var_count' == `var_count_tot' { // when section is done, wrap up & save table
			preserve
			
				** 4) call final dta and sort
				use "${regstats_Followup_${cty}}/`recurs_dta'.dta", clear // fetch FU1 tests
				
				keep if sec == "`pap_section'" 
				
				// sort by var and phase
				gen rankall = _n
				gen phase = (_n > `var_count_tot') // rank get FU2 vars
				byso phase : egen rankph = rank(rankall)
				sort rankph phase
				keep text
				
				** 5) insert gray hlines between each pair
				local k = 0
				forval i = 1/`=`=_N'-2' {
					local rev_i = `=`=_N'-2' -`i' + 1 - `k'
					dis `rev_i'
					if mod(`rev_i',2) == 0 { // dis "`rev_i' is even"
						insobs 1, after(`rev_i')
						replace text = "\arrayrulecolor{gray}\hline" if text == ""
						local k = `k' + 1
					}
				}
				
		
				** 6) define header and footnotes
				insobs 1, before(1)
				#delimit ;
				local head1 " & & 
					\begin{tabular}[b]{@{}c@{}} Capital \\ (Full w/o \\ Psych.) \end{tabular} & 
					\begin{tabular}[b]{@{}c@{}} Psych. \\ (Full w/o \\ Capital) \end{tabular} & 
					\begin{tabular}[b]{@{}c@{}} Full \\ \textcolor{white}{.} \\ \textcolor{white}{.} \end{tabular}&
					`colhead'
					\begin{tabular}[b]{@{}c@{}} Full - Psych. \\ (Cash grant \\ gross ME) \end{tabular} & 
					\begin{tabular}[b]{@{}c@{}} Full - Capital \\ (Psych. comp. \\ gross ME) \end{tabular} & 
					\begin{tabular}[b]{@{}c@{}} Capital - \\ Psych. \\ \textcolor{white}{.} \end{tabular}& 
					\begin{tabular}[b]{@{}c@{}} 18m - \\ 6m for \\ Capital \end{tabular}& 
					\begin{tabular}[b]{@{}c@{}} 18m - \\ 6m for \\ Psych. \end{tabular}& 
					\begin{tabular}[b]{@{}c@{}} 18m - \\ 6m for \\ Full \end{tabular}\\	
					\cmidrule(lr){3-5} \cmidrule(lr){7-9} \cmidrule(lr){10-12}				
					";
				local head2 " 
					& & \multicolumn{3}{c}{`stathead'} & & \multicolumn{3}{c}{coef/se/p} 
					& \multicolumn{3}{c}{coef/se/p} \\ 
					";
				local note1 "
					Notes: `controls_note'
							`controls_note2'
							`def_note'
							`se_note'
							`money_units_footnote'
							`wins_footnote'
							`index_footnote'
							`section_footnote'
							`components_note'
					";
				local note2 "
					";
				#delimit cr
				
				local head1 = trim(itrim("`head1'"))
				local head2 = trim(itrim("`head2'"))
				local note1 = trim(itrim("`note1'"))
				local note2 = trim(itrim("`note2'"))
				local note1 = subinstr("`note1'", "DELETE SINGLE", "", .)
				local note2 = subinstr("`note2'", "DELETE SINGLE", "", .)
				

				** 7) generate latex text and save as text file
				insobs 25, before(1)
				gen header_rank = _n if text == ""
				// fill in latex header for longtable
				replace text = "" if header_rank == 1
// 				>{\raggedright}p{.1\textwidth} >{\raggedright}p{.1\textwidth} 
				replace text = "\begin{longtable}{llcccccccccc} % 12 total"  if header_rank == 2
				replace text = "\caption{`title'}        \label{tab:`pap_section'} \\"  if header_rank == 4
				replace text = "%\centering"  if header_rank == 5
				replace text = "\hline \hline"  if header_rank == 6
				replace text = "" if header_rank == 7 
				replace text = "`head1'"  if header_rank == 8
				replace text = "" if header_rank == 9
				replace text = "`head2' \hline "  if header_rank == 10
				replace text = "\endfirsthead"  if header_rank == 11
				replace text = "" if header_rank == 12
				replace text = "\multicolumn{12}{c}{{\bfseries `title'  -- continued from previous page}} \\ \hline "  if header_rank == 13
				replace text = "`head1'" if header_rank == 14
				replace text = "" if header_rank == 15
				replace text = "`head2' \hline "  if header_rank == 16
				replace text = "\endhead"  if header_rank == 17
				replace text = "\\"  if header_rank == 18
				replace text = "\multicolumn{12}{c}{{Continued on next page}} \\ \hline"  if header_rank == 19
				replace text = "\endfoot"  if header_rank == 20
				replace text = "\hline \hline"  if header_rank == 21
				replace text = "\multicolumn{12}{p{\textwidth}}{{`note1'}} \\ "  if header_rank == 22
				replace text = "\multicolumn{12}{p{\textwidth}}{{`note2'}} \\ "  if header_rank == 23 
				replace text = "\endlastfoot"  if header_rank == 24
				replace text = "" if header_rank == 25
				
				insobs 1, after(_N)
				qui replace text = "\end{longtable}" in `=_N' // close table off
				qui keep text

				// manual fixes
				replace text = subinstr(text, "AVEC", " AVEC", .)				
				replace text = subinstr(text, "adult", " adult", .)				
				replace text = trim(itrim(text))
				
				
				if "`final_table_name'" != "" {
					outfile using "${joint_output_${cty}}/report_tables/vertical/interim/`final_table_name'.tex", noquote wide replace
				}
				
			restore
			
		} // close wrap-up
	} // close fu2 condition
} // end quietly





end

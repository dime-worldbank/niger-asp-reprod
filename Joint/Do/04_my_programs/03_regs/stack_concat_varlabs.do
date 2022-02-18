/*
This script stacks and concatenates variable labels inside a latex tabular space.
Return: mylabels

*/


capture prog drop stack_concat_varlabs
program define stack_concat_varlabs, rclass
	syntax, lab(string) ///
			pap_section(string) ///
			var_count(string) ///
			var_count_tot(string) ///
			returnlocal(string) ///
			[recurstitles(string)]

// 			dis "start"
// 			dis "returnlocal"
// 			dis "`returnlocal'"
// 			dis "``returnlocal''"
// 			dis "recurstitles = `recurstitles'"

	nois dis as text "	- Running do-file: stack_concat_varlabs"
	
			if `var_count' == 1 { // first var initiate return local
				// dis "reset titles_pap"
				local `returnlocal' "" // create a macro for titles
			}
			
			
			local lab_trim = subinstr("`lab'", "\n", "", .) 
			local lab_trim = subinstr("`lab_trim'", "\", "", .) 
			
			// if there is NOT a line break (line breaks entered in reg_tables_lab_vars.do)
			if strpos("`lab'","\n ") == 0 {
				// just assign a one-line label
				local mylabels = "&\begin{tabular}[b]{@{}c@{}} `lab' \end{tabular} " 
				
				local `returnlocal' = "`recurstitles'" + "`mylabels'" // concatenate titles list

			}			
			// if there is one line break
			else if strpos("`lab'","\n ") > 0 {
				// extract the first line
				local first_line = substr("`lab'", 1, strpos("`lab'","\n ")-1)
				// and save other words in the remaining line(s)
				local other_words = substr("`lab'", strpos("`lab'","\n ")+3, strlen("`lab'"))
				
				// if there is NOT a second line break in the other words,
				if strpos("`other_words'","\n ") == 0 {
					local mylabels = "&\begin{tabular}[b]{@{}c@{}} `first_line'" + "\\" + "`other_words' \end{tabular} " 
 
					local `returnlocal' = "`recurstitles'" + "`mylabels'" // concatenate titles list
				}
				// if there is another line break
				else if strpos("`other_words'","\n ") > 0 {
					// extract second line
					local second_line = substr("`other_words'", 1, strpos("`other_words'", "\n ")-1) 
					
					//and save other words in final line. Lines capped at three in reg_table instructions
					local third_line  = substr("`other_words'", strpos("`other_words'", "\n ")+3, strlen("`other_words'"))
					
					local mylabels = "&\begin{tabular}[b]{@{}c@{}} `first_line'" + "\\" + "`second_line'"+ "\\" + "`third_line' \end{tabular} "
					local `returnlocal' = "`recurstitles'" + "`mylabels'" // concatenate titles list
				}
			}
			
// 			dis "finish"
// 			dis "returnlocal"
// 			dis "`returnlocal'"
// 			dis "``returnlocal''"
			if `var_count' == `var_count_tot' { // close line if last var in group
				return local `returnlocal' = "``returnlocal''" + " \\"
			}
			else {
				return local `returnlocal' = "``returnlocal''"
			}
			
			return local mylabels = "`mylabels'"

	
end

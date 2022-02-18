
capture prog drop tex_add_hyperlink 
prog define tex_add_hyperlink
	// tex_file_name is new name for local outside the program (`file')
	syntax, file(string) pap_section(string) [QUIetly]
	
	nois dis as text "	- Running do-file: tex_add_hyperlink"
	
`quietly' {	
	preserve
		import delimited "`file'", clear
	
		// concatenate tex info into one column keeping commas intact since -import- parses at commas
		fix_import
		
		// add row right after caption that labels table for latex hyperlink
		gen rank = _n
		gen add_below = 1 if strpos(text, "caption") > 0
		expand 2 if add_below == 1, gen(label_changer)
		replace text = "\label{tab:`pap_section'}" if label_changer == 1
		replace rank = rank + 0.5 if label_changer == 1
		sort rank
		keep text
		
		outfile using "`file'", noquote wide replace
		
	restore
}

end

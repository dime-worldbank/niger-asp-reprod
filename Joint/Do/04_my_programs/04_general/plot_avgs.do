/* 
program expects dataset with vars: 
	- var_lab: variable label (string)
	- avg*: treatment group averages (numeric)
	- se?: treatment group standard errors (numeric, 0 for control)
	- p*: treatment group p-values (numeric, 0 for control)
	- d*: treatment group percentage changes relative to control (string eg "50%" or "N/A")
	
where * or ? identifies treatment dummies 0, 1, 2, etc

Last edited: 1/21/2021
Stata version: 15.1

Outline: 

** 1) summarize percent changes in text format
** 2) keep important variables
** 3) extract colors
** 4) create new rank variable 
** 5) Prepare x-axis labels
** 6) reshape data and drop numbers ~ 0
** 7) generate x-axis, asterisks, and confidence bounds 
** 8) adjust table range
** 9) positions of asterisks (see text_str)
** 10) position of x-axis labels
** 11) set grstyle and miscellaneous plot details
** 12) graph formatting
** 13) title options
** 14) ytitle options
** 15) horizontal line and its textbox
** 16) options: footnote, barlabel, asterisks, and error bars
** 17) assertions 
** 18) plot: twoway


*/


pause on 

capture prog drop plot_avgs 
program define plot_avgs, rclass
	syntax, papsec(string) 					///
			papsecvars(string)  			///
			count(string) 					///
			bkgcolor(string) 				///
			tcolors(string) 				///
			darktheme(integer) 				///
			[	error_bars 					///
				barlabels 					///
				barpercent 					///
				my_ytitle(string) 			///
				d_drop(string) 				///
				my_title(string) 			///
				combine_phases 				///
				override_range_low(string) 	///
				override_range_low(string) 	///
				new_range_high(string) 		///
				override_ygrid(string) 		///
				leg(string) 				///
				savefilename(string) 		///
				override_xrows(string) 		///
				override_grphsz(string) 	///
				override_grphaspct_h(string) ///
				override_grphaspct_w(string) ///
				override_stars_offset(string) ///
				override_blab_offset(string) ///
				text_sz(string) 			///
				xfontsize(string) 			///
				yfontsize(string) 			///
				ttl_size(string) 			///
				yttl_size(string) 			///
	   			gr_note(string) 			///
				yline_opt(string) 			///
				blog_txt_opt 				///
				asterisks 					///
			    my_h(string) 				///
				PERCENT_changes 			///
				percent_change_base(string) ///
				percent_change_not(string) 	///
				QUIetly 					///
			]

	nois dis "Running -plot_avgs- program on variables in section `papsec'."

`quietly' {	// start quiet 1
	preserve

	
	** 1) summarize percent changes in text format
	if "`percent_changes'" != "" {

		forval j = 1/3 {
		    
			gen delta`j' = (`percent_change_base'`j' - `percent_change_base'0)/`percent_change_base'0 * 100 ///
				if round(`percent_change_base'0, 0.00001) != 0
				
			replace delta`j' = 99999 if missing(delta`j')
			gen d_`j'_tx = string(round(delta`j', 1))
			gen d_`j'_txt = d_`j'_tx + "%"
			replace d_`j'_txt = "N/A" if delta`j' == 99999
			drop delta`j' d_`j'_tx
			rename d_`j'_txt d`j'
			replace d`j' = "" if d`j' == "N/A"
			
			// drop percentage changes for chosen outcomes
			if "`percent_change_not'" != "" {
				foreach string in `percent_change_not' {
					replace d`j' = "" if strpos(var_lab, "`string'") > 0 
				}
			}
		}
		
		capture drop d0
		gen d0 = "", before(d1)		
	}
	
	
	
	** 2) keep important variables
	keep if section == "`papsec'"
	

	** 3) extract colors
	qui ds avg*
	local vars `r(varlist)'
	local count_t : word count `vars'
	forval color = 1/`count_t' {
		dis `color'
		local col_`color' : word `color' of `tcolors'
	}

	** 4) create new rank variable 
	// based on variables in `list'
	gen var = ., after(rank)
	forval i = 1/`: word count `papsecvars'' {
	    dis `i'
		local var`i' : word `i' of `papsecvars'
		forval j = 1/`=_N' {
		    dis `j'
		    if "`=var_name[`j']'" == "`var`i''" replace var = `i' in `j'
		}
	}

	// needed stuff: var label, averages, ci95_s, %changes, and p-values
	keep var var_lab avg* ci95_? d* p* 
	sort var
	
	
	
	
	** 5) Prepare x-axis labels
	// lab`xrows'_`i'' (used below to define `xtitle_str')
	
	// xrows
	local varcount = `=_N'
	if 		`varcount' >= 5 local xrows 3 
	else if `varcount' >= 4 local xrows 2 
	else if `varcount' >= 1 local xrows 1 
		
	if !missing(`"`override_xrows'"') local xrows = `override_xrows'
	
// 	nois dis "xrows = `xrows'"
// 	stop
	
	// cutoffs (formal)
	local lnbrk "\n "
	local lnbrk_len = strlen("\n ")
	// cutoffs (additional)
// 	local lnbrks `" " {" "daily," "months," "monthly," "yearly," "'
	local lnbrks `" "ssss" "'
	local lnbrks_ct : word count `lnbrks'
	
	
	// apply line breaks to var labels
	forval i = 1/`=_N' {
		local lab`i' `"`=var_lab[`i']'"'

		
		
		local all_breaks `" `lnbrk' `lnbrks' "'
		local allbrks_ct : word count `all_breaks'
// 		dis `"`all_breaks'"'
	
		// count no. of linebreaks
		local lnbrk_ct_tot 0 // INITIATE accumulate linebreak count for ith var
		local actual_lnbrks // INITIATE concat actual breaks for ith var
		
		forval k = 1/`allbrks_ct' {
			local str : word `k' of `all_breaks'
// 			dis "`str'"
		
			if strpos("`lab`i''", "`str'") > 0 { // if line break is found, count it
				// count no. of linebreaks
				local str_`k' = "`str'"
				local lnbrk_len_`k' = strlen("`str'")
				local lnbrk_ct_`k' = (length("`lab`i''") - length(subinstr("`lab`i''", "`str'", "", .)))/`lnbrk_len_`k''
				dis "We have `lnbrk_ct_`k'' of the `k'th line break, `str'"
				
				local index "`k'"
				local indices : list indices | index
				
				local lnbrk_ct_tot = `lnbrk_ct_tot' + `lnbrk_ct_`k'' // accumulate linebreak count for ith var
				local actual_lnbrks `" `"`actual_lnbrks'"' "`str'" "' // concat actual breaks for ith var
			}
		}

		dis "total = `lnbrk_ct_tot'"
		dis `"`actual_lnbrks'"'
		dis "`indices'"

		// get the indices and positions of all the linebreaks
		local counter 0
		foreach k in `indices' { // 1 3
			forval inst = 1/`lnbrk_ct_`k'' { // 2 1
				local counter = `counter' + 1
				if `k' == 1 & `inst' == 1 local temp_lab = "`lab`i''"
				local brk_pos_`k'_`inst' = strpos("`temp_lab'", "`str_`k''") 
				local fill = `lnbrk_len_`k''*"x"
				local temp_lab = subinstr("`temp_lab'", "`str_`k''", "`fill'", 1) // remove that first instance
				dis "break `counter'. `k'_`inst' = `brk_pos_`k'_`inst'' (`str_`k'')"
				local brk_pos_`counter' = `brk_pos_`k'_`inst'' // assign break position to incremental counter
			}
		}

		dis " "
		dis " "
		// chop it up
		if `lnbrk_ct_tot' == 0 local linenew1_`i' "`lab`i''"
		else {
			forval j = 1/`=`lnbrk_ct_tot'+1' {
				
				// start position
				local jless = `j' - 1
				if `j' == 1 local start_`j' = 1 
				else 	    local start_`j' = `brk_pos_`jless'' + `lnbrk_len'
				
				 // calculate length to end position or . for whole thing
				if `j' == `=`lnbrk_ct_tot'+1' local lentoend_`j' = .
				else {
					local end_`j' = `brk_pos_`j''
					local lentoend_`j' = `end_`j'' - `start_`j''
				}
				
				// new jth line
				local linenew`j'_`i' = substr("`lab`i''", `start_`j'', `lentoend_`j'')
// 				dis "lnbrkct_tot = `lnbrk_ct_tot'"
// 				dis "new line `j' = `linenew`j'_`i''"
// 				dis "j = `j', lab = `lab`i''"
			}
		}

// 		// `" "line1" "line2" "line3" "'
		// disable 1st TWO line breaks
		if 		`xrows' == 1 {
			local lab`xrows'_`i' "`linenew1_`i'' `linenew2_`i'' `linenew3_`i''"
			if `lnbrk_ct_tot' >= 3 { // for linebreaks after the second one
				forval j = 4/`=`lnbrk_ct_tot'+1' {
					dis "j: `j', `i: i'"
					dis "`linenew`j'_`i''"
					local lab`xrows'_`i' `" "`lab`xrows'_`i''" "`linenew`j'_`i''" "'
					local lab`xrows'_`i' = trim(itrim(`"`lab`xrows'_`i''"'))
				}
			}
		}
		else if `xrows' == 2 {
			// disable 1st line break
			local lab`xrows'_`i' "`linenew1_`i'' `linenew2_`i''"
			if `lnbrk_ct_tot' >= 2 { // for linebreaks after the first one
				forval j = 3/`=`lnbrk_ct_tot'+1' {
					dis "j: `j', `i: i'"
					dis "`linenew`j'_`i''"
					local lab`xrows'_`i' `" "`lab`xrows'_`i''" "`linenew`j'_`i''" "'
					local lab`xrows'_`i' = trim(itrim(`"`lab`xrows'_`i''"'))
				}
			}
		}
		else if `xrows' == 3 {
			// disable no line breaks
			local lab`xrows'_`i' 
			forval j = 1/`=`lnbrk_ct_tot'+1' {
				dis "j: `j', `i: i'"
				dis "`linenew`j'_`i''"
				local lab`xrows'_`i' `" `lab`xrows'_`i'' "`linenew`j'_`i''" "'
				local lab`xrows'_`i' = trim(itrim(`"`lab`xrows'_`i''"'))
			}
		}
	}
// 	nois dis "xrows = `xrows'"
// 	nois dis `"`lab`xrows'_1'"'
// 	nois dis `"`lab`xrows'_2'"'
// 	nois dis `"`lab`xrows'_3'"'
// 	nois dis `"`lab`xrows'_4'"'
// 	nois dis `"`lab`xrows'_5'"'
// pause



	** 6) reshape data and drop numbers ~ 0
	capture assert _N > 0 // assert some variable made it this far
	if _rc != 0 nois dis as error "problem here. Probably need to fix: keep if section == `papsec'"
	
	// reshape wide to long
	reshape long avg ci95_ d p, i(var) j(treat)
	
	// drop practically-zero averages
	replace avg = 0 if abs(avg) < 0.00001
	
	
	
	** 7) generate x-axis, asterisks, and confidence boudns 
	// generate x-axis (index variable)
	gen index = .
	order index, first
	dis "varct = `varcount'"
	forval i = 1/`varcount' {
		local j = (`i'-1)*5
		dis "`j'"
		replace index = treat + `j' + 1 if var == `i'
	}
	
	// generate stars based on p-values
	replace p = . if treat == 0
	gen 	stars = "*"   if p <= 0.1
	replace stars = "**"  if p <= 0.05
	replace stars = "***" if p <= 0.01
			
	// generate 95% Conf bounds (input avg and se)
	count if ci95_ != . & inrange(treat, 1, 3) // check if we have bounds
	if `r(N)' == 0 { // if no bounds, use averages as limits
		gen ub95 = avg
		gen lb95 = avg
	}
	else { 
		gen ub95 = avg + ci95_
		gen lb95 = avg - ci95_
	}
	
	
	** 8) adjust table range

	// generate star positions (input: lb95, ub95, and stars)
	qui sum ub95
	local range_high `r(max)'
	local range_high = `range_high' *1.05 // add 5% to range for nice spacing
	qui sum lb95
	local range_low `r(min)'
	if `r(min)' <= 0 local range = `range_high' - `range_low'
	else if `r(min)' > 0 local range = `range_high' - 0
	
	// customize yrange and grid spacing based on number of vars
	// mostly because I want to start at y = zero
	if 		`range' > 1000 				    local ygrid = 500
	else if `range' > 400 & `range' <= 1000 local ygrid = 100
	else if `range' > 200 & `range' <=  400 local ygrid =  50
	else if `range' >  75 & `range' <=  200 local ygrid =  20
	else if `range' >  40 & `range' <=   75 local ygrid =  10
	else if `range' >  20 & `range' <=   40 local ygrid =   5
	else if `range' >   6 & `range' <=   20 local ygrid =   2
	else if `range' > 2.5 & `range' <=    6 local ygrid =   1
	else if `range' >   1 & `range' <=  2.5 local ygrid = 0.5
	else if                 `range' <=    1 local ygrid = 0.1
	

	// if range_low is negative, adjust it based on grid spacing
	if `range_low' < 0 local range_low = -((`ygrid'-abs(`range_low'))+abs(`range_low'))*(floor(abs(`range_low')/`ygrid')+1)
	else if `range_low' >= 0 local range_low 0
		
	// overrides
	if !missing(`"`override_range_high'"') & !missing(`"`new_range_high'"') {
	    dis as error " chose only one of overriderange_high OR new_range_high."
		stop
	}
	
	if !missing(`"`new_range_high'"') {
		local scalefactor : word 1 of `new_range_high'
		local basevar 	  : word 4 of `new_range_high'
		dis "`scalefactor'"
		dis "`basevar'"
		qui sum `basevar' // no confidence intervals here
		local range_high `r(max)'
		local range_high = `range_high' * (1 + `scalefactor'/100) // add % to range for nice spacing
		
	}
	
	if !missing(`"`override_range_low'"') 	local range_low = `override_range_low'
	if !missing(`"`override_range_high'"')  local range_high = `override_range_high'
	if !missing(`"`override_ygrid'"') 		local ygrid = `override_ygrid'
		
		
		
	** 9) positions of asterisks (see text_str)

	// star_pos
	if missing(`"`override_stars_offset'"') gen star_pos = ub95 + `range' * 0.04 if stars != "" // shift stars up 4% of range
	else 									gen star_pos = ub95 + `range' * `override_stars_offset'/100 if stars != "" //
	
	// blab_pos
	if missing(`"`override_blab_offset'"')  gen blab_pos = ub95 + `range' * 0.04 // shift blabs down 4% of range
	else 									gen blab_pos = ub95 + `range' * `override_stars_offset'/100 
	
	// use larger range when combine option is set to yes
// 	if "`combine_phases'" != "" {
// 		local range_high = `my_max_comb_high' // maximum combined high (y-axis max)
// 		local range_low  = `my_max_comb_low' // maximum combined low (y-axis min)
// 	}

	// asterisks: text() argument: generate text as local text_str
	qui count if stars != ""
	forval i = 1/`=_N' {
		local stars`i' `"`=stars[`i']'"' // stars as text
		local y`i' `"`=star_pos[`i']'"' // y position
		local y`i' : di %9.5fc `y`i''
		local x`i' `"`=index[`i']'"' // x position
		local d`i' = d in `i'	
		if `"`=stars[`i']'"' != "" { // significant effects only (<=10% level)
			dis "index `x`i'' = `d`i''"
			local text_str `"`text_str' `y`i'' `x`i'' "`d`i'' " "`stars`i'' " "'
		}
	}
// 	nois dis `text_str'
// 	pause
	
	// barlabs: text() argument: generate text as local barlab_str
	forval i = 1/`=_N' {
		local y`i' `"`=blab_pos[`i']'"' // y position
		local y`i' : di %9.5fc `y`i''
		local x`i' `"`=index[`i']'"' // x position
		local x`i' = `x`i'' - 0.15 // shift 1% to the left
		
		
		if !missing(`"`barpercent'"') local percsymbol "%"
		
		local barval`i' = avg in `i'	
		local barval`i' : di %9.0fc `barval`i''
		if `barval`i'' != 0 { // nonzero averages only
			local barlab_str `"`barlab_str' `y`i'' `x`i'' "`barval`i''`percsymbol' " "'
		}
	}
// 	nois dis "`barlab_str'"
// 	pause
	
	

	** 10) position of x-axis labels
	
	// twoway xlabel() argument: generate text as local xtitle_str
	local pos = -2.5
	
	forval i = 1/`varcount' {
		local pos = `pos' + 5 // 2.5, 7.5, 12.5 etc.
		local xtitle_str = `" `xtitle_str' `pos' `"`lab`xrows'_`i''"' "'
	}
	local xtitle_str = trim(itrim(`"`xtitle_str'"'))



	** 11) set grstyle and miscellaneous plot details
	
	// depending on number of variables in plot	
	// font-sizes
	if `varcount' < 3 {
		* -twoway, text()-
		local text_sz small
		* - twoway xlabel(labsize())-
		local xfontsize "medium"
		local yfontsize "medium"
		local ttl_size "medium"
		local yttl_size "medium"
	}
	else if `varcount' >= 3 {
		local text_sz small
		local xfontsize "medsmall"
		local yfontsize "medsmall"
		local ttl_size "medsmall"
		local yttl_size "medsmall"
	}
// 	foreach stat in xfontsize yfontsize ttl_size yttl_size {
// 		nois dis "`stat' = ``stat''"
// 	}
// 	pause
	
// 	if "`combine_phases'" != "" {
// 		if `varcount' == 1 {
// 			local text_sz medsmall
// 			local xfontsize "medlarge"
// 			local yfontsize "medlarge"
// 			local ttl_size "medlarge"
// 			local yttl_size "medlarge"
// 		}
// 		else if `varcount' >= 2 {
// 			local text_sz medium
// 			local xfontsize "large"
// 			local yfontsize "large"
// 			local ttl_size  "large"
// 			local yttl_size "large"
// 		}
// 	}
	
	
	** 12) graph formatting
	local bkgrd_opp "0 0 0"
	if `darktheme' == 1 local gridandaxis "white"
	else 				local gridandaxis "`bkgrd_opp'"
	
	set scheme plotplain
	grstyle init
	grstyle color background "`bkgcolor'"
	grstyle color major_grid "`gridandaxis'"
	grstyle color axisline "`gridandaxis'"
	grstyle set graphsize `grphsz' 
	grstyle set margin "0pt 0pt 0pt 0pt": axis_title // move ytitle closer to graph
// 	if "`combine_phases'" != "" grstyle set margin "0pt 10pt 0pt 0pt": axis_title // move ytitle away from graph
// 	grstyle gridringstyle title_ring 10

	local my_white "245 245 245" // not-so-white white
	if `darktheme' == 1 local txtcol "`my_white'"
	else 				local txtcol "`bkgrd_opp'"
	
	
	** 13) title options
	if !missing(`"`my_title'"') {
		if `darktheme' == 1 local title_opt `"title(`my_title', color("`bkgcolor'") box bcolor(`txtcol') size(`ttl_size') )"' // margin(l=1.5 r=1.5) 
		else 				local title_opt `"title(`my_title', color("10 10 10")   box 				 size(`ttl_size') )"' // margin(l=1.5 r=1.5) 
	}
	
	** 14) ytitle options
	if !missing(`"`my_ytitle'"') {
		
		if !missing(`"`my_h'"') local my_h `my_h'
		else 					local my_h 0
		
		if 	 "`my_ytitle'" == "*b*" local my_col `bkgcolor'
		else  					    local my_col `txtcol'
		
		local y_title_opt `"ytitle(`my_ytitle', color(`my_col') height(`my_h') size(`yttl_size'))"'
	}
	
	** 15) horizontal line and its textbox
	if !missing(`"`yline_opt'"') 	local yline_opt "`yline_opt'"
	else 				   	  		local yline_opt // empty
	if !missing(`"`blog_txt_opt'"') local blog_txt_opt "`blog_txt_opt'"
	else 				   	  		local blog_txt_opt // empty
	
	
	** 16) options: footnote, barlabel, asterisks, and error bars
	if !missing(`"`gr_note'"')    local footnote    `"note(`gr_note', size(vsmall) color(`gridandaxis'))"'
	if !missing(`"`barlabels'"')  local barlabs     `"text(`barlab_str', size(`text_sz') color(`gridandaxis'))"'
	if !missing(`"`asterisks'"')  local asterisks   `"text(`text_str', size(`text_sz') color(`gridandaxis'))"'
	if !missing(`"`error_bars'"') local errorbaropt `"(rcap ub95 lb95 index if treat != 0, color("`txtcol'"))"'
	
} // end quiet 1


** 17) assertions 
assert `range_low' != `range_high'
assert !(!missing(`"`asterisks'"') & !missing(`"`barlabels'"')) // assert not both are defined


`quietly' { // quiet 2

	** -----------------------------------------------------------------------
	** 18) plot: twoway
	
	twoway (bar avg index if treat==0, color("`col_1'") barwidth(0.85)) /// bars for each treatment arm y=avg, x=index
		   (bar avg index if treat==1, color("`col_2'") barwidth(0.85)) /// 
		   (bar avg index if treat==2, color("`col_3'") barwidth(0.85)) ///
		   (bar avg index if treat==3, color("`col_4'") barwidth(0.85)) ///
		   `errorbaropt', /// error bars
			   legend(order(`leg') /// legend
					  row(1) /// spread horizontally
					  position(6) /// 6 o'clock
					  region(fcolor("`bkgcolor'")) /// color ASP grey
					  color(`txtcol') /// color white
					  size(medsmall)) /// 
			   xlabel(`xtitle_str', nogrid /// remove vertical grid
					  labcolor(`txtcol') /// color white
					  labsize(`xfontsize')) /// determine size of x-axis labels
			   ylabel(`range_low'(`ygrid')`range_high', /// determine yrange
					  labcolor(`txtcol') /// color white
					  labsize(`yfontsize')) /// determine size of y-axis labels (same as x)
			   xtitle("") /// no x-axis label
			   `y_title_opt' /// this will need to change by table (see above)
			   yline(0, lpattern(l) lcolor(`gridandaxis') lwidth(medthin)) /// add white y=0 line
			   `yline_opt' /// add horizontal line (CBA == 1)
			   `asterisks' /// add significance and stars
			   `barlabs'   /// add bar labels
			   `blog_txt_opt' /// add text for breakeven (CBA)
			   `title_opt' /// this will need to change by table (see above)
			   plotr(m(t=5)) /// add 5 percent to top for spacing below title 
			   `footnote' ///
			   `footnote2' ///
			   saving(`savefilename', replace)
			   	
}

	restore
	
end


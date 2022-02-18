/*******************************************************************************
Title: 01_PROGRAMS.do
This do-file installs the programs used to replicate results for Sahel work

Date Created: Nov 29 2020

*******************************************************************************/

** ssc packages
local ssc_packages carryforward grqreg geonear geodist zscore06 revrs ///
		qqvalue mhtexp mhtreg mkcorr cndnmb3 coldiag coldiag2 mmerge ///
		winsor2 estout grstyle qreg2 cfout ihstrans vioplot eclplot iefieldkit
if $reviewer == 1 { // instal heavy packages only when reviewing
	local addpack  moremata //
	local ssc_packages : list ssc_packages | addpack
}
foreach pack in `ssc_packages' {
	capture which `pack'
	if _rc != 0 {
		dis as error "need to install `pack'"
		ssc install `pack'
	}
	else if _rc == 0 {
		dis as result "`pack' already installed"	
	}
}
** user-built packages 
local net_packages zindex readreplace ietoolkit bcstats
if $reviewer == 1 { // instal heavy packages only when reviewing
	local addpack gr0070 // dm79
	local net_packages : list net_packages | addpack
}
foreach pack in `net_packages' {

	// for svmat2 (used for qtile reg plot)
	if ("`pack'" == "dm79") 	   local link http://www.stata.com/stb/stb56 
	// for command labmask
	if ("`pack'" == "labutil")     local link http://fmwww.bc.edu/RePEc/bocode/l/
	// all index calculations 
	if ("`pack'" == "zindex")      local link https://raw.githubusercontent.com/PovertyAction/zindex/master
	if ("`pack'" == "readreplace") local link http://fmwww.bc.edu/RePEc/bocode/r
	if ("`pack'" == "ietoolkit")   local link http://fmwww.bc.edu/RePEc/bocode/i
	if ("`pack'" == "gr0070")      local link http://www.stata-journal.com/software/sj17-3
	if ("`pack'" == "bcstats") 	   local link https://raw.githubusercontent.com/PovertyAction/bcstats/master/ado

	capture which `pack'
	if _rc != 0 {
		net install `pack',	from("`link'") 
	}
}

/* Small adjustment to lmhtreg.mlib (library of functions used in mhtreg)
 The mata library installed from SSC is compiled using Stata 16 and thus is not
 recognized by my version of Stata (V15). -mhtreg- author, Professor Andreas Steinmayr 
 has kindly provided an older version of this mata library that was compiled using 
 Stata 14. I replace the new version with the old so that my code can run in older
 Stata versions. I invoke this library in "${joint_do}/12_asp_mht.do" */

** 1) fetch old version of mhtreg mata library
local mhtreg_mlib_stata14 "${joint_do}/04_my_programs/04_general/lmhtreg.mlib"

** 2) fetch location of new mhtreg mata library to be replaced with old
local mhtreg_newloc : sysdir PLUS // default destination for SSC
local mhtreg_newloc = subinstr("`mhtreg_newloc'", "\", "/", .) // replace backslashes
copy "`mhtreg_mlib_stata14'" "`mhtreg_newloc'/l/lmhtreg.mlib", replace // replace new file with old


/*
ssc program versions
 - carryforward: version 4.5 2016jan15
 - grqreg: version 2.1  (17 March 2011) Joao Pedro Azevedo
 - geonear: version 2.0.3  04sep2019 Robert Picard, robertpicard@gmail.com
 - geodist: version 1.1.0  18jun2019 Robert Picard, picard@netbox.com
 - zscore06: v1.1 July 2011
 - qqvalue: 08 August 2010
 - mhtexp: no version provided (likely first)
 - mhtreg: no version provided (likely first)
 - winsro2: 1.1 2014.12.16
 - revrs: v1.0.1 12apr2007
 - grstyle: version 1.1.1  15sep2020  Ben Jann
 - cfout: version 2.0.0 Matthew White 26aug2014


net programs versions
 - svmat2: 1.2.2 NJC 10 May 1999   (STB-56: dm79)
 - labmask: *! NJC 1.0.0 20 August 2002 (labutil)
 - zindex: version 1.0.2 Caton Brewster 6.10.2019
 - readreplace: version 2.0.0 Matthew White 26aug2014
 - bcstats: version 2.1 Christopher Boyer 28oct2017
*/


** Personal programs
	
// 03_regs
foreach prog in ///
	asp_012_list_vars_ner_usd /// 012) run asp_012_list_vars_*. Used in step 2 to collect variables by PAP Section
	asp_012_list_vars_sen_usd ///
	asp_012_list_vars_mrt_usd ///
	asp_012_list_vars_ner_fcfa ///
	asp_012_list_vars_tel_fcfa ///
	asp_013_label_vars_ner /// 013) run asp_label_vars_*. Used in step 3 to label variables
	asp_013_label_vars_tel ///
	asp_050_PAP_tables /// stack tables showing more stats
	stack_concat_varlabs /// stack var labels
	asp_control_stats ///
	asp_f_tests ///
	asp_f_tests_hte ///
	asp_summary_matrix ///
	{

	capture do "${joint_do}/04_my_programs/03_regs/`prog'" 
	
}

// 04_general
foreach prog in ///
	plot_avgs /// 050) run plot_avgs. Used to plot ASP WB bar graphs
	qqval_yk /// run qqval_yk. Used to prep and organize q-values using qqvalue
	mhtreg_yk /// run mhtreg_yk. Used to run mhtreg regardless of fam size
	translate_livestock /// run translate_livestock program. Used before converting livestock counts to TLU clean_livestock_joint.do
	translate_food	/// run translate_food program. Used in clean_consumption_joint.do
	translate_nonfood /// run translate_nonfood program. Used in clean_consumption_joint.do
	translate_vars /// 050) run translate_vars. Used to translate variables in data (variable called var_lab)	
	translate_tex /// reg tables. Used to translate post-processed tables
	translate_balance /// table a1. Used to translate post-processed tables
	translate_compliance /// table a2. Used to translate post-processed tables
	tex_move_combos_up /// edit latex output
	tex_resize /// edit latex output
	tex_add_hyperlink ///
	fix_import /// edit latex output
	tex_stack_iebaltab ///
	{
	
	capture do "${joint_do}/04_my_programs/04_general/`prog'" 
	
}


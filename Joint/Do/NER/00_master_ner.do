/* 
00_master_ner.do

This script replicates results included in the working paper:
	"Tackling Psychosocial and Capital Constraints
	 Opens Pathways out of Poverty"

Stata Version 15

Outline:
** 06) regressions
** 07-08) Baseline balance and compliance
** 09) Figure 2 
** 10-11) Figure 3
** 12-13) Table SI.5: MHT 
** 14) Figure SI.1: BL sample map
** 15) Table SI.27: Psych cost
** 16) SI Section 3

Notes on runtime using an Intel Core i7 processor:
- step 6 takes around 14 minutes
- step 12 takes > 24 hours


*/


*------------------------| Header
pause on
clear all
set more off
set varabbrev on, permanently
macro drop _all
set seed 2 // for -mhtreg-
version 15.0
set matsize 500 // for large tables

timer clear
timer on 1



*------------------------|  Set filepaths

** 1) Set working directory

// If you are a reviewer, please set ${reviewer} to 1 and change the first two paths below
global reviewer 0
global hpc_switch 1 // this switches the bootstrap repetitions in "${joint_do}/NER/12_asp_mht.do"
					// from 5 to the default 3000. This is always turned OFF if reviewer == 0.
					// It should be ON to get accurate corrected p-values.

if $reviewer == 1 {

	// DATA 
	global dir ".." 		// Enter here the path to your local folder 
							// where the "Sahel_analysis" subdirectory exists.
										   
	// DO FILES and OUTPUT (GitHub)
	global git_dir	".." 	// Enter here the path to your local or GitHub folder 
							// where the subfolder "Joint" exists.
								
}
else {
	
	if "`c(username)'" == "YKashlan" {	// C:GitHub
		global dir 		"X:/Dropbox" 		  		  			// DATA (Dropbox)
		global git_dir	"C:/GitHub/sahel-asp/niger-asp-reprod"  // DO FILES and OUTPUT (GitHub)
	}
	else {
		display in red "change global file paths for this user"
	}
	
	global hpc_switch 0 // see above
	
}



*------------------------| Globals and Programs
global cty NER
global joint_do	"${git_dir}/Joint/Do" // DO FILES (GitHub)

** Run programs (SSC, net, and local)
do "${joint_do}/01_PROGRAMS.do"



*------------------------| ANALYSIS 

// define baseline globals
global phase Baseline
do "${joint_do}/01_GLOBAL_JOINT.do"

** 06) regressions
foreach ph in Followup Followup_2 {
	global phase `ph'
	do "${joint_do}/01_GLOBAL_JOINT.do"
	
// 	do "${joint_do}/NER/06_asp_regs_new.do" // regs
// 	do "${joint_do}/NER/06_asp_regs_food.do" // regs	
}
// do "${joint_do}/NER/06_asp_regs_hte.do" // regs


** 07-08) Baseline balance and compliance
// do "${joint_do}/NER/07_balance_and_attrition.do" // table SI.1
// do "${joint_do}/NER/08_compliance_fu1.do" // table SI.2

** 09) Figure 2 
// do "${joint_do}/NER/09_stdzd_fx_graph_1.do" 
// do "${joint_do}/NER/09_stdzd_fx_graph_2.do" // fig.2

** 10-11) Figure 3
// do "${joint_do}/NER/10_cba.do"         // Cost-benefit calcs
// do "${joint_do}/NER/11_cba_plot.do"    // fig.3

** 12-13) Table SI.5: MHT 
// do "${joint_do}/NER/12_asp_mht" // table SI.5 (requires all sections to be run in 06..._new.do)
// do "${joint_do}/NER/13_asp_mht_add.do" // add p-values to tables ED.1-6

** 14) Figure SI.1: BL sample map
// do "${joint_do}/NER/14_NER_communes_map.do"

** 15) Table SI.27: Psych cost
// do "${joint_do}/NER/15_explore_psych_cost.do"

** 16) SI Section 3
// do "${joint_do}/NER/16_alphas.do"



timer off 1
timer list 1 // display timer 1


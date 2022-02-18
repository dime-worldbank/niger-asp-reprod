/*******************************************************************************
Title: 01_JOINT_GLOBAL
This do-file sets the project WORKING DIRECTORY and GLOBALS for the 
joint cleaning files. It requires two globals to run: $cty and $phase

Date Created: January 7 2020

Data Used: data in ${survey_cto} folder
Data Created: data in ${deduplicated}, ${intermediate}, and ${constructed} folder


*******************************************************************************/

********************************************************************************
* GLOBALS																	   *
********************************************************************************
pause on
// extra globals used in file names and table titles
* PHASES -----------------------------------------------------------------------
if 		"$phase" == "Baseline"   global ph bl
else if "$phase" == "Followup"   global ph fu
else if "$phase" == "Followup_2" global ph fu2

if 		"$phase" == "Followup"   global phase_num 1
else if "$phase" == "Followup_2" global phase_num 2

* PHASEYEAR
if 		"$cty" == "NER" {
	if 		"$phase" == "Baseline"   global phase_yr 2017
	else if "$phase" == "Followup"   global phase_yr 2019
	else if "$phase" == "Followup_2" global phase_yr 2020
}
else if "$cty" == "BFA" {
	if 		"$phase" == "Baseline"   global phase_yr 2018
}
else if "$cty" == "SEN"   {
	if 		"$phase" == "Baseline"   global phase_yr 2018
	else if "$phase" == "Followup"   global phase_yr 2020
	else if "$phase" == "Followup_2" global phase_yr 2021	
}
else if "$cty" == "MRT"  {
	if 		"$phase" == "Baseline"   global phase_yr 2018 // 2% of hhs in very late 2017
	else if "$phase" == "Followup"   global phase_yr 2020
	else if "$phase" == "Followup_2" global phase_yr 2021
}
* BASELINEYEAR
if 		"$cty" == "NER" 			 global bl_${cty}_yr 2017
else if "$cty" == "BFA" 			 global bl_${cty}_yr 2018
else if "$cty" == "SEN" 			 global bl_${cty}_yr 2018
else if "$cty" == "MRT" 			 global bl_${cty}_yr 2018


* Survey type ------------------------------------------------------------------
if "$ph" == "fu" & ("$cty" == "SEN" | "$cty" == "MRT") global ss 1 
else global ss 0 // short survey (telephone due to COVID)

* COUNTRIES --------------------------------------------------------------------
if 		"$cty" == "NER" 		 global country Niger
else if "$cty" == "BFA" 		 global country Burkina Faso
else if "$cty" == "SEN" 		 global country Senegal
else if "$cty" == "MRT" 		 global country Mauritania

* main file abbreviations ------------------------------------------------------
if 		"$cty" == "NER" 		 global mainname niger
else if "$cty" == "BFA" 		 global mainname bf
else if "$cty" == "SEN" 		 global mainname senegal
else if "$cty" == "MRT" 		 global mainname mauritania

* COUNTRY CLUSTERs -------------------------------------------------------------
if 		"$cty" == "NER" 		 global cluster_level village
else if "$cty" == "SEN" 		 global cluster_level quarter
else if "$cty" == "MRT"   		 global cluster_level "village proxy"

// else if "$cty" == "BFA" 		 // stop // define cluster level


* EXCHANGE RATES (across surveys, to PPP) --------------------------------------
/* Source for 2016 USD PPP conversion factor: World Bank’s International 
   Comparison Program database. Private consumption (LCU per international $)
   WB (LCU / USD) Private consumption
   
   Sources:
   https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?locations=NE
   https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?locations=MR
   https://data.worldbank.org/indicator/PA.NUS.PRVT.PP?locations=SN
	*/
   
	 if "$cty" == "NER" global conv_ppp_2016_${cty} 242.553 // Date collected: Feb 2020
else if "$cty" == "MRT" global conv_ppp_2016_${cty}  12.282 // Date collected: 7/7/2021
else if "$cty" == "SEN" global conv_ppp_2016_${cty} 237.026 // Date collected: 7/7/2021
// else if "$cty" == "BFA" // stop // enter conversion rate

* LOCAL CURRENCY UNITS ---------------------------------------------------------
	 if "$cty" == "NER" global lcu_${cty} "XOF" 
else if "$cty" == "MRT" global lcu_${cty} "MRU" 
else if "$cty" == "SEN" global lcu_${cty} "XOF" 
// else if "$cty" == "BFA" // stop // enter LCU label


** FOLDERS

* MAPS data global (BL) --------------------------------------------------------
if "$phase" == "Baseline" global ${cty}_maps "${dir}/Sahel_analysis/Baseline/Maps/shape_files/${cty}"

* DATA globals -----------------------------------------------------------------
global joint_fold						"${dir}/Sahel_analysis/Joint"
global data_${phase}_${cty} 			"${dir}/Sahel_analysis/${phase}/Data/${cty}"
global intermediate_${phase}_${cty}		"${dir}/Sahel_analysis/${phase}/Data/${cty}/03_Intermediate_anon"
global constructed_${phase}_${cty}		"${dir}/Sahel_analysis/${phase}/Data/${cty}/04_Constructed"
global regstats_${phase}_${cty}			"${dir}/Sahel_analysis/${phase}/Data/${cty}/05_Regstats"

* OUTPUT globals (ph-cty-specific and joint) -----------------------------------
global output_${phase}_${cty}			"${git_dir}/${phase}/Output/${cty}" // regs output
global joint_output_${cty} 				"${git_dir}/Joint/Output/${cty}"    // postproc output
global joint_output_combo 				"${git_dir}/Joint/Output/combo"    	// multicountry output

* SURVEY xlsx form LOCATION globals
global ctofolder_${phase}_${cty} "${dir}/Sahel_analysis/${phase}/HFC/${cty}/01_instruments/03_xls"


* DATETIME global for use in diagnostic report --------------------------------
global datetime "${S_DATE}_${S_TIME}"
global datetime = subinstr("${datetime}", " ", "", .) // remove spaces
global datetime = subinstr("${datetime}", ":", "", .) // remove :


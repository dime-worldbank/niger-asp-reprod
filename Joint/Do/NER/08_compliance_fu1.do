/*******************************************************************************
Title: 08_compliance_fu1.do
This do-file prepares take-up rates using the administrative data in Niger at FU1.
Generates table si2.
									
// Administrative data from WB team. Document Rapport M&E Sahel v6.5				

Outline:
** 1) collect locals 
** 2) prepare latex file

*******************************************************************************/

pause on

use "${joint_fold}/Data/allrounds_NER_hh.dta", clear
keep if phase == 1 // FU1


** 1) collect locals for latex file below
foreach stub in	coach  	 /// coach visits
				avec 	 /// vsla
				video  	 /// video (sensitization)
				germe  	 /// IGA (entrepreneurship) training
				acv 	 /// LCA (life skills) training
				bourse { // subsidy (cash grant)
	// depending on the variable, condition on treatment group that recieved said measure
	if "`stub'" == "coach" | "`stub'" == "avec" | "`stub'" == "germe" {
		qui sum mes_`stub'_d if inlist(treatment, 1, 2, 3) // all treatment arms
	}
	else if "`stub'" == "video" | "`stub'" == "acv" {
		qui sum mes_`stub'_d if inlist(treatment, 1, 3) // social and full
	}
	else if "`stub'" == "bourse" {
		qui sum mes_`stub'_d if inlist(treatment, 2, 3) // capital and full
	}
	local `stub'perc = `r(mean)' * 100
	local `stub'perc : di %15.1fc ``stub'perc'
	local `stub'perc = strtrim("``stub'perc'") // remove whitespace
	dis "`stub' conditional: ``stub'perc'"
	// repeat for each treatment arm
	forval i = 1/3 {
		qui sum mes_`stub'_d if treatment == `i'
		local `stub'perct`i' = `r(mean)' * 100
		local `stub'perct`i' : di %15.1fc ``stub'perct`i''
		local `stub'perct`i' = strtrim("``stub'perct`i''") // remove whitespace
		dis "t`i': ``stub'perct`i''"
	}
}

** 2) prepare latex file
local admin_only 1

if `admin_only' == 0 {
clear
insobs 22
gen header_rank = _n

// header 
gen     latex_text = "\begin{table}[htbp]\centering"  if header_rank == 1
replace latex_text = "\fontsize{11}{15}\selectfont\caption{Supplementary Table SI.2: Compliance}" if header_rank == 2
replace latex_text = "\label{tab:0_1_compliance}"  if header_rank == 3
replace latex_text = "\resizebox{0.85\textwidth}{!}{\begin{tabular}{l *{5}{c}}" if header_rank == 4
replace latex_text = "\hline\hline"  if header_rank == 5
replace latex_text = "& Administrative data & \multicolumn{4}{c}{Survey Data} \\ \cmidrule(lr){3-6}"  if header_rank == 6
replace latex_text = "& & Targeted & Social & Capital & Full \\"  if header_rank == 7
replace latex_text = "\hline" if header_rank == 8

// body
replace latex_text = "Percentage of targeted beneficiaries who received individual coaching each month 				& 52.2\% & `coachperc'\% & `coachperct1'\% & `coachperct2'\% & `coachperct3'\% \\ [1.5ex]" if header_rank == 9
replace latex_text = "Attendance rates at community savings and loan groups  										& 92.0\% & `avecperc'\% & `avecperct1'\% & `avecperct2'\% & `avecperct3'\%  \\ [1.5ex]" if header_rank == 10
replace latex_text = "Attendance rates of beneficiaries at community sensitization on aspirations and social norms 	& 89.3\% & `videoperc'\% & `videoperct1'\% & `videoperct2'\% & `videoperct3'\%   \\ [1.5ex]" if header_rank == 11
replace latex_text = "Attendance rates at micro-entrepreneurship training 											& 95.0\% & `germeperc'\% & `germeperct1'\% & `germeperct2'\% & `germeperct3'\%   \\ [1.5ex]" if header_rank == 12
replace latex_text = "Attendance rates at life skills training 														& 93.8\% & `acvperc'\% & `acvperct1'\% & `acvperct2'\% & `acvperct3'\%   \\ [1.5ex]" if header_rank == 13
replace latex_text = "Percentage of targeted beneficiaries who received their cash grant 							& In progress & `bourseperc'\% & `bourseperct1'\% & `bourseperct2'\% & `bourseperct3'\%  \\" if header_rank == 14

// footer
replace latex_text = "\\" if header_rank == 15
replace latex_text = "\hline\hline" if header_rank == 16
replace latex_text = "\end{tabular}} %firsttabular" if header_rank == 17
replace latex_text = "\addvbuffer[3pt 0pt]{" if header_rank == 18
replace latex_text = "\begin{tabular}{p{0.85\textwidth}}" if header_rank == 19
replace latex_text = "\footnotesize \textit{Notes: }" if header_rank == 20
replace latex_text = "\end{tabular}}" if header_rank == 21
replace latex_text = "\end{table}" if header_rank == 22


}
else if `admin_only' == 1 {

clear
insobs 23
gen header_rank = _n


// header 
gen     latex_text = "\begin{table}[htbp]\centering"  if header_rank == 1
replace latex_text = "\fontsize{11}{15}\selectfont\caption{Supplementary Table SI.2: Compliance Based on Administrative Data}" if header_rank == 2
replace latex_text = "\label{tab:0_1_compliance}"  if header_rank == 3
replace latex_text = "\resizebox{1.15\textwidth}{!}{\begin{tabular}{l *{4}{c}}" if header_rank == 4
replace latex_text = "\hline\hline"  if header_rank == 5
replace latex_text = " "  if header_rank == 6
replace latex_text = " & \multicolumn{4}{c}{Treatment Arm} \\ \cmidrule(lr){2-5}"  if header_rank == 7
replace latex_text = " & Pooled & Capital & Psychosocial & Full \\"  if header_rank == 8
replace latex_text = "\hline" if header_rank == 9

// body
#delimit ;
	replace latex_text = "1. Attendance rates of beneficiaries at community savings
						  and loan groups 
						  & 92.0\% & 92.8\% & 91.7\% & 91.5\% \\ [1.5ex]" 
						  if header_rank == 10
						  ;
	replace latex_text = "2. Percentage of targeted beneficiaries who received 
						  individual coaching each month 
						  & 52.2\% & 51.9\% & 50.5\% & 54.1\% \\ [1.5ex]" 
						  if header_rank == 11 
						  ;
	replace latex_text = "3. Attendance rates of beneficiaries at micro-entrepreneurship training  
						  & 95.0\% & 96.4\% & 94.9\% & 93.6\% \\ [1.5ex]" 
						  if header_rank == 12
						  ;
	replace latex_text = "4. Attendance rates of beneficiaries at community 
						  sensitization on aspirations and social norms 
						  & 89.3\% & 	  -    & 89.0\% & 89.8\% \\ [1.5ex]" 
						  if header_rank == 13
						  ;
	replace latex_text = "5. Attendance rates of beneficiaries at life skills training 
						  & 93.8\% &   -   & 94.0\% & 93.5\% \\ [1.5ex]" 
						  if header_rank == 14
						  ;
	replace latex_text = "6. Percentage of targeted beneficiaries who received their cash grant 
						  & 99.9\% & 99.7\% &   -   & 100\% \\" 
						  if header_rank == 15
						  ;
#delimit cr

// footer
replace latex_text = "\\" if header_rank == 16
replace latex_text = "\hline\hline" if header_rank == 17
replace latex_text = "\end{tabular}} %firsttabular" if header_rank == 18
replace latex_text = "\addvbuffer[3pt 0pt]{" if header_rank == 19
replace latex_text = "\begin{tabular}{p{1.15\textwidth}}" if header_rank == 20

#delimit ;
	replace latex_text = `"\footnotesize \textit{Notes: } 
	We show compliance data collected by the program's administrators. 
	Participation in savings groups 
	and coaching sessions is measured at the group level. 
	The individual coaching visits were not designed to reach all 
	households each month.
	Participation in the community sensitization 
	session (video screening) is measured at the village level. 
	The cash grant provision and participation in training sessions
	are measured at the individual level. 
	"'  
	if header_rank == 21 ;
#delimit cr

replace latex_text = "\end{tabular}}" if header_rank == 22
replace latex_text = "\end{table}" if header_rank == 23

}
keep latex_text

// save latex file in report_final folder
outfile using "${joint_output_${cty}}/report_tables/table_si2.tex", noquote wide replace



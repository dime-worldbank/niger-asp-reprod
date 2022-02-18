/* 14_NER_communes_map.do
This script prepares the Niger map showing communes

Outline:
** 1) generate dta from shp files: regions (adm01)
** 2) define arrow for Naimey
** 3) generate dta from shp files: departments (adm02)
** 4) generate dta from shp files: commune (adm03)
** 5) keep wanted communes
** 6) generate and export map: spmap

*/

// Version
version 15.0


clear
set more off
set graphics off

// location of map data
local bl_data  "${${cty}_maps}"

** 1) generate dta from shp files: regions (adm01)
shp2dta using "`bl_data'/NER_adm01_feb2018", ///
				database("`bl_data'/NER_adm01_feb2018") ///
				coordinates("`bl_data'/NER_region") ///
				genid(id) gencentroids(c) replace 
				
use "`bl_data'/NER_adm01_feb2018", clear
spmap using "`bl_data'/NER_region.dta", id(id)  mfcolor(white) 

	use "`bl_data'/NER_adm01_feb2018", clear
	replace y_c = y_c + 0.5 if inlist(adm_01, "Tillabéri")
	replace y_c = y_c - 0.4 if inlist(adm_01, "Dosso", "Maradi", "Niamey")
	replace x_c = x_c - 0.2 if inlist(adm_01, "Dosso", "Niamey")
	replace y_c = y_c - 0.1 if inlist(adm_01, "Niamey")
	save "`bl_data'/NER_adm01_feb2018_shift", replace

	** 2) define arrow for Naimey
	clear
	set obs 1
	gen _ID = 1
	gen byvar_ar = 2
	gen _X1 = 2.10605
	gen _Y1 = 13.52834
	gen _X2 = _X1 - 0.2 + 0.05
	gen _Y2 = _Y1 - 0.5 + 0.05
	save "`bl_data'/naimey_arrow.dta", replace

** 3) generate dta from shp files: departments (adm02)
shp2dta using "`bl_data'/NER_adm02_feb2018", ///
			database("`bl_data'/NER_adm02_feb2018") ///
			coordinates("`bl_data'/NER_department") ///
			genid(id) gencentroids(c) replace 
use "`bl_data'/NER_adm02_feb2018", clear
spmap  using "`bl_data'/NER_department.dta", id(id) mfcolor(white) 

** 4) generate dta from shp files: commune (adm03)
shp2dta using "`bl_data'/NER_adm03_feb2018", ///
			database("`bl_data'/NER_adm03_feb2018") ///
			coordinates("`bl_data'/NER_commune") ///
			genid(id) gencentroids(c) replace 
			

** 5) keep wanted communes
use  "`bl_data'/NER_adm03_feb2018.dta", clear
gen is_commune = 0 
replace is_commune = 1 if NOM_COM == "DAN KASSARI"
replace is_commune = 1 if NOM_COM == "MATANKARI"
replace is_commune = 1 if NOM_COM == "TOMBOKOIREY 2"
replace is_commune = 2 if NOM_COM == "KORNAKA"
replace is_commune = 2 if NOM_COM == "GABI"
replace is_commune = 2 if NOM_COM == "SAFO"
replace is_commune = 2 if NOM_COM == "GUIDAN AMOUMOUNE"
replace is_commune = 3 if NOM_COM == "KOURFEYE CENTRE"
replace is_commune = 3 if NOM_COM == "HAMDALLAYE"
replace is_commune = 3 if NOM_COM == "KARMA"
replace is_commune = 3 if NOM_COM == "NAMARO"
replace is_commune = 4 if NOM_COM == "AKOUBOUNOU"
replace is_commune = 4 if NOM_COM == "KAROFANE"
replace is_commune = 4 if NOM_COM == "BAMBEYE"
replace is_commune = 5 if NOM_COM == "OLLELEWA"
replace is_commune = 5 if NOM_COM == "DUNGASS"
replace is_commune = 5 if NOM_COM == "KANTCHE"

// keep wanted departments
gen is_department = 0 
replace is_department = 1 if  adm_02 == "Dogondoutchi"
replace is_department = 1 if  adm_02 == "Dosso"
replace is_department = 1 if  adm_02 == "Dakoro"
replace is_department = 1 if  adm_02 == "Madarounfa"
replace is_department = 1 if  adm_02 == "Mayahi"
replace is_department = 1 if  adm_02 == "Filingué"
replace is_department = 1 if  adm_02 == "Kollo"
replace is_department = 1 if  adm_02 == "Abalak"
replace is_department = 1 if  adm_02 == "Bouza"
replace is_department = 1 if  adm_02 == "Tahoua"
replace is_department = 1 if  adm_02 == "Tanout"
replace is_department = 1 if  adm_02 == "Dungass"
replace is_department = 1 if  adm_02 == "Kantché"

keep if is_commune != 0  

** 6) generate and export map: spmap
spmap is_commune using "`bl_data'/NER_commune.dta", ///
		id(id) ///
		polygon(data("`bl_data'/NER_region.dta")) ///
		ocolor(black) ///
		fcolor(Blues) ///
		legenda(off) ///
		label(data("`bl_data'/NER_adm01_feb2018_shift.dta") ///
			  xcoord(x_c) ycoord(y_c) ///
			  label(adm_01)) ///
		note(" "             ///
			 "Notes: Authors' creation; boundaries from OCHA Common Operational Data.", ///
			 size(*0.75)) ///
		arrow(data("`bl_data'/naimey_arrow.dta"))
		
		
// export graph as png to output folder
graph export "${joint_output_${cty}}/report_graphs/figure_0_${cty}_communes_map.png", as(png) replace

set graphics on


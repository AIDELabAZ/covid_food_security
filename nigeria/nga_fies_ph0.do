* Project: COVID Food Security
* Created on: 7 September 2021
* Created by: lirr
* Edited by: lirr
* Last edited: 13 Sep 2021
* Stata v.17

* does
	* reads in baseline Nigeria data
	* pulls FIES data questions

* assumes
	* raw nigeria data 

* TO DO:
	* merge in HoH data
	* check if other vars need relabel


************************************************************************
**# 0 - setup
************************************************************************

* define
	global	root	=	"$data/nigeria/raw"
	global	export	=	"$data/nigeria/refined"
	global	logout	=	"$data/nigeria/logs"

* open log
	cap log 		close
	log using		"$logout/nga_fies", append

	
*************************************************************************
**# 1 - FIES data
*************************************************************************
		
* load data
	use 			"$root/wave_00/sect12_harvestw4", clear

* replace counts with binary indicators	
	lab def 		yesno 1 "Yes" 0 "No" 
	foreach 		x in a b c d e f g h i j {
		replace 		s12q8`x' = 0 if s12q8`x' == 2
		lab val 		s12q8`x' yesno
	}
* generates fies_2 variable	
	gen 			fies_2 = 1 if s12q8g == 1 | s12q8i == 1
	replace			fies_2 = 0 if fies_2 > 1
	lab val 		fies_2 yesno
	
* rename variables
	rename 			s12q8a fies_4
	rename 			s12q8b fies_5
	rename 			s12q8e fies_8
	rename 			s12q8d fies_7
	rename 			s12q8f fies_1
	rename 			s12q8j fies_9
	rename 			s12q8h fies_3
	rename 			s12q8c fies_6
	rename			zone   region_broad
	rename			state  region
	rename			lga	   postal_id
	
* keep relevant
	keep 			ea hhid fies_* region_broad region /// 
					postal_id sector



************************************************************************
**# 2 - merge in hh data and HOH gender
************************************************************************

preserve

* load data
	use				"$root/wave_00/sect1_harvestw4", clear

* identify head of household and gender
	rename			s1q2 sexhh
	keep			if s1q3 == 1
	
* keep relevant variable
	keep			ea hhid indiv sexhh

* save temp file
	tempfile		temp1
	save			`temp1'

restore

* merge with fies data
	merge 			1:1 hhid using "`temp1'", nogen

	
************************************************************************
**# 3 - merge in panel weight data
************************************************************************

preserve

* load data
	use				"$root/wave_00/secta_harvestw4", clear
	
* get panel weights
	rename			wt_wave4 phw
	keep			hhid ea phw

* save temp file
	tempfile		temp2
	save			`temp2'

restore

* merge with fies data
	merge			1:1 hhid using "`temp2'", nogen
	order			hhid ea phw region sector sexhh ///
					fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 ///
					fies_7 fies_8 fies_9		
		
************************************************************************
**# 4 - end matter, clean up to save
************************************************************************
	
	compress
	
* close the log
	log	close
	
	
* save 
	save			"$export/wave_00/r0_fies", replace	
	
	
/* END */	
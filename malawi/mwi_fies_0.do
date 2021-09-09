* Project: WB COVID
* Created on: Aug 2021
* Created by: amf
* Edited by: lirr
* Last edited: 2 Sep 2021
* Stata v.17

* does
	* reads in baseline Malawi data
	* pulls FIES data questions

* assumes
	* raw malawi data 

* TO DO:
	* complete


************************************************************************
**# setup
************************************************************************

* define
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"

* open log
	cap log 		close
	log using		"$logout/mal_fies", append

	
*************************************************************************
**# FIES data
*************************************************************************
		
* load data
	use 			"$root/wave_00/HH_MOD_H", clear

* replace counts with binary indicators	
	lab def 		yesno 1 "Yes" 0 "No" 
	foreach 		x in a b c d e {
		replace 		hh_h02`x' = 1 if hh_h02`x' > 1 & hh_h02`x' < .
		lab val 		hh_h02`x' yesno
	}
	replace 		hh_h01 = 0 if hh_h01 == 2
	lab val 		hh_h01 yesno
	
* rename variables
	rename 			hh_h01 fies_4
	rename 			hh_h02a fies_5
	rename 			hh_h02b fies_8
	rename 			hh_h02c fies_7
	rename 			hh_h02d fies_2
	rename 			hh_h02e fies_9

* keep relevant
	keep 			y4_ HHID* fies_* 

	
*************************************************************************
**# merge in hh data
*************************************************************************	

preserve 
	
* load data
	use 			"$root/wave_00/HH_MOD_A", clear

* keep relevant variables
	keep 			y4_hhid y3_hhid ihs_region hh_a01 reside panelweight_2019

* save tempfile
	tempfile 		temp1
	save 			`temp1'

restore 

* merge with fies data	
	merge 			1:1 y4_hhid using "`temp1'", assert(3) nogen
	rename 			ihs_region region_broad
	rename 			hh_a01 region
	rename 			reside sector
	rename 			panelweight_2019 phw_pnl

	
*************************************************************************
**# merge in HOH gender 
*************************************************************************

preserve 
		
* load data
	use 			"$root/wave_00/HH_MOD_B", clear
	
* get HOH gender
	rename 			hh_b03 sexhh 
	keep 			if hh_b04 == 1
	keep 			sexhh y4 HHID*

* save tempfile
	tempfile 		temp2
	save 			`temp2'

restore 

* merge with master fies data	
	merge 			1:1 y4_hhid using "`temp2'", assert(3) nogen
	
	order 			y4 y3 HHID* phw region* sector* sexhh fies_2 ///
						fies_4 fies_5 fies_7 fies_8 fies_9
	

************************************************************************
**# 2 - end matter, clean up to save
************************************************************************
	
	compress
	
* close the log
	log	close
	
	
* save 
	save			"$export/wave_00/r0_fies", replace	
	
	
/* END */	
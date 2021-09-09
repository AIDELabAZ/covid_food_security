* Project: COVID Food Security
* Created on: 2 September 2021
* Created by: lirr
* Edited by: lirr
* Last edited: 7 September 2021
* Stata v.17

* does
	* reads in baseline ethiopia data
	* pulls FIES data questions

* assumes
	* raw ethiopia data 

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define
	global	root	=	"$data/ethiopia/raw"
	global	export	=	"$data/ethiopia/refined"
	global	logout	=	"$data/ethiopia/logs"

* open log
	cap log 		close
	log using		"$logout/eth_fies", append

	
*************************************************************************
**#  1 - FIES data
*************************************************************************
		
* load data
	use 			"$root/wave_00/HH/sect8_hh_w4", clear

* replace counts with binary indicators	
	lab def 		yesno 1 "Yes" 0 "No" 
	foreach 		x in a b c d e f g h{
		replace 		s8q02`x' = 1 if s8q02`x' > 1 & s8q02`x' < .
		lab val 		s8q02`x' yesno
	}
	
	replace 		s8q01 = 0 if s8q01 == 2
	lab val 		s8q01 yesno
	
	
* rename variables
	rename 			s8q01 	fies_4
	rename 			s8q02a 	fies_5
	rename			s8q02b 	fies_6
	rename 			s8q02c 	fies_8
	rename 			s8q02d 	fies_7
	rename 			s8q02e 	fies_2
	rename 			s8q02f  fies_9
	rename			s8q02g	fies_1
	rename			s8q02h	fies_3

* keep relevant
	keep 			ea_ household_ fies_* 

************************************************************************
**# 2 - end matter, clean up to save
************************************************************************
	
	compress
	
* save 
	save			"$export/wave_00/r0_fies", replace

* close the log
	log	close
	
	
/* END */	
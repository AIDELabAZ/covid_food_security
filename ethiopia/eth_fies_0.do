* Project: COVID Food Security
* Created on: 2 September 2021
* Created by: lirr
* Edited by: lirr
* Last edited: 9 September 2021
* Stata v.17

* does
	* reads in baseline ethiopia data
	* pulls FIES data questions

* assumes
	* raw ethiopia data 

* TO DO:
	* merge household data
	* merge panel weight


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
	rename 			 s8q01 	fies_4
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

	
*************************************************************************
**# 2 - merge in hh data
*************************************************************************	

preserve

* load data
	use				"$root/wave_00/HH/sect1_hh_w4", clear

* identify head of household
	keep			if s1q01 == 1

* keep relevant variable
	keep			ea_ household_ saq01 saq14 s1q02


* save temp file
	tempfile		temp1
	save			`temp1'

restore

* merge with fies data
	merge 			1:1 household_id using "`temp1'", assert(3) nogen
	rename			saq14 sector
	rename			saq01 region
	rename			s1q02 sexhh
	

*************************************************************************
**# 3 - merge in panel weight data
*************************************************************************	

preserve

* load data
	use				"$root/wave_00/HH/sect_cover_hh_w4", clear
	
* get panel weights
	rename			pw_w4 phw
	keep			household_id ea_id phw

* save temp file
	tempfile		temp2
	save			`temp2'

restore

* merge with fies data
	merge			1:1 household_id using "`temp2'", assert(3) nogen
	order			household_id ea_id phw region sector sexhh ///
					fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 ///
					fies_7 fies_8 fies_9

************************************************************************
**# 4 - end matter, clean up to save
************************************************************************
	
	compress
	
* save 
	save			"$export/wave_00/r0_fies", replace

* close the log
	log	close
	
	
/* END */	
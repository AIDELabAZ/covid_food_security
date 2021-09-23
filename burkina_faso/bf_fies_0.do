* Project: COVID Food Security
* Created on: 22 September 2021
* Created by: lirr
* Edited by: jdm
* Last edited: 23 September 2021
* Stata v.17.0

* does
	* reads in baseline burkina faso data
	* pulls FIES data questions

* assumes
	* raw burkina faso data 

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define
	global	root	=	"$data/burkina_faso/raw"
	global	export	=	"$data/burkina_faso/refined"
	global	logout	=	"$data/burkina_faso/logs"

* open log
	cap log 		close
	log using		"$logout/bf_fies", append


*************************************************************************
**#  1 - FIES data
*************************************************************************
		
* load data
	use 			"$root/wave_00/menage/s08a_me_BFA2018", clear
	
* check for unique identifier
	isid			grappe menage

* replace counts with binary indicators	
	lab def 		yesno 1 "Yes" 0 "No" 
	foreach 		x in 1 2 3 4 5 6 7 8{
		replace 		s08aq0`x' = 0 if s08aq0`x' > 1 & s08aq0`x' < .
		lab val 		s08aq0`x' yesno
	}
	
* rename variables
	rename 			s08aq01 	fies_4
	rename 			s08aq02 	fies_5
	rename			s08aq03 	fies_6
	rename 			s08aq04 	fies_7
	rename 			s08aq05 	fies_8
	rename 			s08aq06 	fies_1
	rename 			s08aq07  	fies_2
	rename			s08aq08 	fies_3

* keep relevant
	keep 			vague grappe menage fies_* 

	
*************************************************************************
**# 2 - merge in hh data and panel weight data
*************************************************************************	

preserve

* load data
	use				"$root/wave_00/menage/ehcvm_welfare_BFA2018", clear

* check for unique identifier
	isid			grappe menage
	
* keep relevant variable
	keep			hhid zae menage grappe region milieu hgender hhweight

* save temp file
	tempfile		temp1
	save			`temp1'

restore

* merge with fies data
	merge 			1:1 grappe menage using "`temp1'"
	
* check to ensure merge is stable and drop unmatched
	count if		_merge == 3
	
	if 				r(N) != 7010 {
		display			"number of unmatched observations changed!"
						this isn't a command - it will throw an error to get ///
							your attention!!!
	}
	
	drop if			_merge != 3
	drop			_merge
	
* rename variables
	rename			milieu   sector
	rename			region   region
	rename			hgender  sexhh
	rename			hhweight phw
	rename			zae 	 region_broad
	
* create wave indicator	
	gen				wave = 0
	lab var			wave "wave number"

	order			hhid vague grappe menage wave phw region sector ///
					sexhh fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 ///
					fies_7 fies_8
	

************************************************************************
**# 3 - end matter, clean up to save
************************************************************************
	
* identify unique identifier and describe data
	isid			grappe menage
	sort			grappe menage
	compress
	summarize
	describe
	
* save 
	save			"$export/wave_00/r0_fies", replace

* close the log
	log	close
	
	
/* END */	
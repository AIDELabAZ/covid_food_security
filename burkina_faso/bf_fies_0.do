* Project: COVID Food Security
* Created on: 22 September 2021
* Created by: lirr
* Edited by: lirr
* Last edited: 4 October 2021
* Stata v.17.0

* does
	* reads in baseline burkina faso data
	* pulls FIES data questions

* assumes
	* raw burkina faso data 

* TO DO:
	* head of household identifier


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
	isid			hhid
	
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
	rename			milieu		sector
	rename			region		region
	rename			hgender		sexhh
	rename			hhweight	phw_cs
	rename			zae			region_broad
	
* create wave indicator	
	gen				wave = 0
	lab var			wave "Wave number"

* generate country variable
	gen				country = 5

	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda" 5 "Burkina Faso", replace
	lab val			country country
	lab var			country "Country"	
	
* select target variables and reorder
	keep			country hhid wave phw_cs region sector ///
					sexhh fies_*
	
	order			country hhid wave phw_cs region sector ///
					sexhh fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 ///
					fies_7 fies_8 
					
************************************************************************
**# 3 - clean to match lsms panel
************************************************************************

* rename regions
	replace			region = 5001 if region == 1
	replace			region = 5002 if region == 2
	replace			region = 5003 if region == 3
	replace			region = 5004 if region == 4
	replace			region = 5005 if region == 5
	replace			region = 5006 if region == 6
	replace			region = 5007 if region == 7
	replace			region = 5008 if region == 8
	replace			region = 5009 if region == 9
	replace			region = 5010 if region == 10
	replace			region = 5011 if region == 11
	replace			region = 5012 if region == 12
	replace			region = 5013 if region == 13
	
	lab def			region 5001 "Boucle du Mouhoun" 5002 "Cascades" ///
						5003 "Centre" 5004 "Centre-Est" 5005 "Centre-Nord" ///
						5006 "Centre-Ouste" 5007 "Centre-Sur" 5008 "Est" ///
						5009 "Hauts Bassins" 5010 "Nord" 5011 "Plateu-Central" ///
						5012 "Sahel" 5013 "Sud-Ouest"
	
	lab val			region region

*  rename sector
	replace			sector = 0 if sector == 1
	replace			sector = 1 if sector == 2
	replace			sector = 2 if sector == 0

	lab def			sector 1 "Rural" 2 "Urban"
	
	lab val			sector sector

* relabel sexhh
	lab def			sexhh 1 "Male" 2 "Female"
	
	lab val			sexhh sexhh

* rename hhid
	rename 			hhid hhid_bf
	
	lab var			hhid_bf "household id unique - Burkina Faso"
	
* relabel variables	
	lab var			sexhh		"(max) sexhh"
	lab var			region 		"CS1: Region"
	lab var			sector		"CS4: Sector"
	lab var			phw_cs		"Population weight- cs"
	

************************************************************************
**# 4 - end matter, clean up to save
************************************************************************
	
* identify unique identifier and describe data
	isid			hhid_bf
	sort			hhid_bf
	compress
	summarize
	describe
	
* save 
	save			"$export/wave_00/r0_fies", replace

* close the log
	log	close
	
	
/* END */	
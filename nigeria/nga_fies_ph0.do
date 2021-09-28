* Project: COVID Food Security
* Created on: 7 September 2021
* Created by: lirr
* Edited by: jdm
* Last edited: 23 Sep 2021
* Stata v.17.0

* does
	* reads in baseline nigeria post-harvest data
	* pulls FIES data questions
	* outputs nigeria post-harvest fies and household data

* assumes
	* raw nigeria post-harvest data 

* TO DO:
	* complete


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

* check for unique identifier
	isid			hhid
	
* replace counts with binary indicators	
	lab def 		yesno 1 "Yes" 0 "No" 
	foreach 		x in a b c d e f g h i j {
		replace 		s12q8`x' = 0 if s12q8`x' == 2
		lab val 		s12q8`x' yesno
	}
	
	
* rename variables
	rename 			s12q8a fies_4
	rename 			s12q8b fies_5
	rename 			s12q8e fies_8
	rename 			s12q8d fies_7
	rename 			s12q8f fies_1
	rename			s12q8g fies_2
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

* check for unique identifier
	isid			hhid indiv
	
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
	merge 			1:1 hhid using "`temp1'"
	
* check to ensure merge is stable and drop unmatched
	count if		_merge == 3
	
	if 				r(N) != 4979 {
		display			"number of unmatched observations changed!"
						this isn't a command - it will throw an error to get ///
							your attention!!!
	}
	
	drop if			_merge != 3
	drop			_merge
	
	
************************************************************************
**# 3 - merge in panel weight data
************************************************************************

preserve

* load data
	use				"$root/wave_00/secta_harvestw4", clear
	
* check for unique identifier
	isid			hhid
	
* get panel weights
	rename			wt_wave4 phw
	keep			hhid ea phw

* save temp file
	tempfile		temp2
	save			`temp2'

restore

* merge with fies data
	merge			1:1 hhid using "`temp2'"
	
* check to ensure merge is stable and drop unmatched
	count if		_merge == 3
	
	if 				r(N) != 4979 {
		display			"number of unmatched observations changed!"
						this isn't a command - it will throw an error to get ///
							your attention!!!
	}
	
	drop if			_merge != 3
	drop			_merge

* rename panelweights
	rename phw		phw_cs
	
* generate wave variable and reorder 	
	gen				wave = 0
	lab	var			wave "wave number"			
	
* generate country variable
	gen				country = 3

	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda" 5 "Burkina Faso", replace
	lab val			country country
	lab var			country "Country"	

* keep variables and order
	keep			country hhid ea wave phw_cs region sector sexhh ///
					fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 ///
					fies_7 fies_8 fies_9		

	order			country hhid ea wave phw_cs region sector sexhh ///
					fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 ///
					fies_7 fies_8 fies_9		

					
************************************************************************
**# 4 - clean to match lsms panel
************************************************************************

* rename regions
	replace			region = 3001 if region == 1
	replace			region = 3002 if region == 2
	replace			region = 3003 if region == 3
	replace			region = 3004 if region == 4
	replace			region = 3005 if region == 5
	replace			region = 3006 if region == 6
	replace			region = 3007 if region == 7
	replace			region = 3008 if region == 8
	replace			region = 3009 if region == 9
	replace			region = 3010 if region == 10
	replace			region = 3011 if region == 11
	replace			region = 3012 if region == 12
	replace			region = 3013 if region == 13
	replace			region = 3014 if region == 14
	replace			region = 3015 if region == 15
	replace			region = 3016 if region == 16
	replace			region = 3017 if region == 17
	replace			region = 3018 if region == 18
	replace			region = 3019 if region == 19
	replace			region = 3020 if region == 20
	replace			region = 3021 if region == 21
	replace			region = 3022 if region == 22
	replace			region = 3023 if region == 23
	replace			region = 3024 if region == 24
	replace			region = 3025 if region == 25
	replace			region = 3026 if region == 26
	replace			region = 3027 if region == 27
	replace			region = 3028 if region == 28
	replace			region = 3029 if region == 29
	replace			region = 3030 if region == 30
	replace			region = 3031 if region == 31
	replace			region = 3032 if region == 32
	replace			region = 3033 if region == 33
	replace			region = 3034 if region == 34
	replace			region = 3035 if region == 35
	replace			region = 3036 if region == 36
	replace			region = 3037 if region == 37
	
	lab def			region 3001 "Abia" 3002 "Adamawa" 3003 "Akwa Ibom" ///
						3004 "Anambra" 3005 "Bauchi" 3006 "Bayelsa" ///
						3007 "Benue" 3008 "Borno" 3009 "Cross River" ///
						3010 "Delta" 3011 "Ebonyi" 3012 "Edo" 3013 "Ekiti" ///
						3014 "Enugu" 3015 "Gombe" 3016 "Imo" 3017 "Jigawa" ///
						3018 "Kaduna" 3019 "Kano" 3020 "Katsina" ///
						3021 "Kebbi" 3022 "Kogi" 3023 "Kwara" 3024 "Lagos" ///
						3025 "Nasarawa" 3026 "Niger" 3027 "Ogun" 3028 "Ondo" ///
						3029 "Osun" 3030 "Oyo" 3031 "Plateau" 3032 "Rivers" ///
						3033 "Sokoto"3034 "Taraba" 3035 "Yobe" ///
						3036 "Zamfara" 3037 "FCT"
	
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

/* rename hhid
	rename 			hhid hhid_nga
	replace 		hhid_nga = "n" + hhid_nga if hhid_nga != "."
	replace			hhid_nga = "" if hhid_nga == "."

					
		
************************************************************************
**# 5 - end matter, clean up to save
************************************************************************
	
* identify unique identifier and describe data
	isid			hhid
	sort			hhid
	compress
	summarize
	describe
	
* close the log
	log	close
	
	
* save 
	save			"$export/wave_00/r0_fies", replace	
	
	
/* END */	
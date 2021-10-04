* Project: COVID Food Security
* Created on: Aug 2021
* Created by: amf
* Edited by: lirr
* Last edited: 30 Sep 2021
* Stata v.17.0

* does
	* reads in baseline Malawi data
	* pulls FIES data questions

* assumes
	* raw malawi data 

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"

* open log
	cap log 		close
	log using		"$logout/mal_fies", append

	
*************************************************************************
**# 1 - FIES data
*************************************************************************
		
* load data
	use 			"$root/wave_00/hh_mod_h_19", clear

* check for unique identifier
	isid			y4_hhid
	
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
	keep 			y4_ fies_* 

	
*************************************************************************
**# 2 - merge in hh data
*************************************************************************	

preserve 
	
* load data
	use 			"$root/wave_00/hh_mod_a_filt_19", clear

* check for unique identifier
	isid			y4_hhid

* keep relevant variables
	keep 			y4_hhid y3_hhid region district reside panelweight_2019 hh_wgt

* save tempfile
	tempfile 		temp1
	save 			`temp1'

restore 

* merge with fies data	
	merge 			1:1 y4_hhid using "`temp1'", assert(3)
	
* check to ensure merge is stable and drop unmatched
	count if		_merge == 3
	
	if 				r(N) != 3178 {
		display			"number of unmatched observations changed!"
						this isn't a command - it will throw an error to get ///
							your attention!!!
	}
	
	drop if			_merge != 3
	drop			_merge
	
* rename variables
	rename 			reside sector
	rename 			panelweight_2019 phw_cs
	rename 			hh_wgt hhw
	rename			region region_broad
	rename			district region
	
	
*************************************************************************
**# 3 - merge in HOH gender 
*************************************************************************

preserve 
		
* load data
	use 			"$root/wave_00/hh_mod_b_19", clear
	
* check for unique identifier
	isid			y4_hhid id_code
	
* get HOH gender
	rename 			hh_b03 sexhh 
	keep 			if hh_b04 == 1
	keep 			sexhh y4_hhid

* save tempfile
	tempfile 		temp2
	save 			`temp2'

restore 

* merge with master fies data	
	merge 			1:1 y4_hhid using "`temp2'", assert(3)
	
* check to ensure merge is stable and drop unmatched
	count if		_merge == 3
	
	if 				r(N) != 3178 {
		display			"number of unmatched observations changed!"
						this isn't a command - it will throw an error to get ///
							your attention!!!
	}
	
	drop if			_merge != 3
	drop			_merge

* create wave indicator	
	gen				wave = 0
	lab var			wave "Wave number"

* generate country variable
	gen				country = 2

	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda" 5 "Burkina Faso", replace
	lab val			country country
	lab var			country "Country"	
	
	keep			country y4_hhid wave phw_cs region sector sexhh fies_2 ///
						fies_4 fies_5 fies_7 fies_8 fies_9
	
	order 			country y4_hhid wave phw_cs region sector sexhh fies_2 ///
						fies_4 fies_5 fies_7 fies_8 fies_9


************************************************************************
**# 4 - clean to match lsms_panel
************************************************************************

* rename regions
	replace 		region = 2101 if region == 101
	replace 		region = 2102 if region == 102
	replace 		region = 2103 if region == 103
	replace 		region = 2104 if region == 104
	replace 		region = 2105 if region == 105
	replace 		region = 2107 if region == 107
	replace 		region = 2201 if region == 201
	replace 		region = 2202 if region == 202
	replace			region = 2203 if region == 203
	replace			region = 2204 if region == 204
	replace			region = 2205 if region == 205
	replace			region = 2206 if region == 206
	replace			region = 2207 if region == 207
	replace			region = 2208 if region == 208
	replace			region = 2209 if region == 209
	replace			region = 2210 if region == 210
	replace			region = 2301 if region == 301
	replace			region = 2302 if region == 302
	replace			region = 2303 if region == 303
	replace			region = 2304 if region == 304
	replace			region = 2305 if region == 305
	replace			region = 2306 if region == 306
	replace			region = 2307 if region == 307
	replace			region = 2308 if region == 308
	replace			region = 2309 if region == 309
	replace			region = 2310 if region == 310
	replace			region = 2311 if region == 311
	replace			region = 2312 if region == 312
	replace			region = 2313 if region == 313
	replace			region = 2314 if region == 314
	replace			region = 2315 if region == 315
	
	
	lab def			region 2101 "Chitipa" 2102 "Karonga" 2103 "Nkhata Bay" ///
						2104 "Rumphi" 2105 "Mzimba" 2107 "Mzuzu City" ///
						2201 "Kasungu" 2202 "Nkhotakota" 2203 "Ntchisi" ///
						2204 "Dowa" 2205 "Salima" 2206 "Lilongwe" ///
						2207 "Mchinji" 2208 "Dedza" 2209 "Ntcheu" ///
						2210 "Lilongwe City" 2301 "Mangochi" 2302 "Machinga" ///
						2303 "Zomba" 2304 "Chiradzulu" 2305 "Blantyre" ///
						2306 "Mwanza" 2307 "Thyolo" 2308 "Mulanje" ///
						2309 "Phalombe" 2310 "Chikwawa" 2311 "Nsanje" ///
						2312 "Balaka" 2313 "Neno" 2314 "Zomba City" ///
						2315 "Blantyre City"
	
	lab val			region region
	
	lab var			region "CS1: Region"
	
* relabel sector
	replace			sector = 0 if sector == 1
	replace			sector = 1 if sector == 2
	replace			sector = 2 if sector == 0

	lab def			sector 1 "Rural" 2 "Urban"
	
	lab val			sector sector
	
	lab var			sector "CS4: Sector"

* relabel sexhh
	lab def			sexhh 1 "Male" 2 "Female"
	
	lab val			sexhh sexhh
	
	lab var			sexhh "(max) sexhh"

* relabel phw_cs
	lab var			phw_cs "Population weight- cs"

* rename hhid
	rename 			y4_hhid hhid_mwi
	lab var			hhid_mwi "household ID malawi"					
						
						
************************************************************************
**# 5 - end matter, clean up to save
************************************************************************
	
* identify unique identifier and describe data
	isid			hhid_mwi
	sort			hhid_mwi
	compress
	summarize
	describe
	
* save 
	save			"$export/wave_00/r0_fies", replace	

* close the log
	log	close
	
	
/* END */	
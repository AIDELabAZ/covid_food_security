* Project: WB COVID
* Created on: Oct 2020
* Created by: jdm
* Edited by: amf
* Last edit: Nov 2020 
* Stata v.16.1

* does
	* reads in fifth round of Ethiopia data
	* builds round 5
	* outputs round 5

* assumes
	* raw Ethiopia data
	* xfill.ado

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/ethiopia/raw"
	global	export	=	"$data/ethiopia/refined"
	global	logout	=	"$data/ethiopia/logs"
	global  fies 	= 	"$data/analysis/raw/Ethiopia"

* open log
	cap log 		close
	log using		"$logout/eth_build", append

* set local wave number & file number
	local			w = 5	
	local 			f = 929
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 
	

* ***********************************************************************
*  1 - roster data - get household size and gender of household head  
* ***********************************************************************

* load roster data
	use				"$root/wave_0`w'/200`f'_WB_LSMS_HFPM_HH_Survey_Roster-Round`w'_Clean-Public", clear
	
* rename other variables 
	rename 			individual_id ind_id 
	rename 			bi2_hhm_new new_mem
	rename 			bi3_hhm_stillm curr_mem
	rename 			bi4_hhm_gender sex_mem
	rename 			bi5_hhm_age age_mem
	rename 			bi5_hhm_age_months age_month_mem
	rename 			bi6_hhm_relhhh relat_mem

* generate counting variables
	gen				hhsize = 1 if curr_mem == 1
	gen 			hhsize_adult = 1 if curr_mem == 1 & age_mem > 18 & age_mem < .
	gen				hhsize_child = 1 if curr_mem == 1 & age_mem < 19 & age_mem != . 
	gen 			hhsize_schchild = 1 if curr_mem == 1 & age_mem > 4 & age_mem < 19 
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data
	collapse		(sum) hhsize hhsize_adult hhsize_child hhsize_schchild new_mem ///
						(max) sexhh, by(household_id)	
	replace 		new_mem = 1 if new_mem > 0 & new_mem < .
	lab var			hhsize "Household size"
	lab var 		hhsize_adult "Household size - only adults"
	lab var 		hhsize_child "Household size - children 0 - 18"
	lab var 		hhsize_schchild "Household size - school-age children 5 - 18"

* save temp file
	tempfile 		temp_hhsize
	save 			`temp_hhsize'	
	
	
* ***********************************************************************
* 2 - format microdata
* ***********************************************************************

* load microdata
	use				"$root/wave_0`w'/200`f'_WB_LSMS_HFPM_HH_Survey-Round`w'_Clean-Public_Microdata", clear

* generate round variable
	gen				wave = `w'
	lab var			wave "Wave number"

* save temp file
	tempfile 		temp_micro
	save 			`temp_micro'	
	
	
* ***********************************************************************
* 3 - FIES score
* ***********************************************************************	
	
* load FIES score data
	use				"$fies/ET_FIES_round`w'.dta", clear
	
* format variables
	drop 			country round 
	rename 			HHID household_id
	
* save temp file	
	tempfile 		temp_fies
	save 			`temp_fies'
	
	
* ***********************************************************************
* 4 - merge to build complete dataset for the round 
* ***********************************************************************	
	
* merge household size, microdata, and FIES
	use 			`temp_hhsize', clear
	merge 			1:1 household_id using `temp_micro', assert(3) nogen
	merge 			1:1 household_id using `temp_fies', nogen

* rename variables inconsistent with other rounds	
	* livestock 
		drop 			ls2_type ls4_covid_impact ls4_covid_impact__96 ls4_covid_impact_other ///
						ls12_sell_notable ls12_sell_notable__96 ls12_sell_notable_other 
		rename 			ls1_livestock ag_live
		rename 			ls2_type* ag_live*
		rename 			ls3_covid ag_live_affect
		rename 			ls4_covid_impact_1 ag_live_affect_1
		rename 			ls4_covid_impact_2 ag_live_affect_3
		rename 			ls4_covid_impact_3 ag_live_affect_4
		rename 			ls4_covid_impact_4 ag_live_affect_7
		rename 			ls5_usual ag_live_sell
		rename 			ls6_revenue_chg ag_live_sell_chg
		rename 			ls7_since_covid ag_live_sell_want
		rename 			ls8_because_covid ag_live_sell_why
		rename 			ls9_sell_able ag_live_sell_able
		rename 			ls10* ag_live* 
		rename 			ls11_ ag_live_sell_pr
		rename 			ls12_sell_notable* ag_live_sell_nowhy*	
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace		
	
	
/* END */
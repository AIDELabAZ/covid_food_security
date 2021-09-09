* Project: WB COVID
* Created on: Oct 2020
* Created by: jdm
* Edited by: amf
* Last edit: October 2020 
* Stata v.16.1

* does
	* reads in fourth round of Ethiopia data
	* builds round 4
	* outputs round 4

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

* set local wave number
	local			w = 4	
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 
	

* ***********************************************************************
*  1 - roster data - get household size and gender of household head  
* ***********************************************************************

* load roster data
	use				"$root/wave_0`w'/R`w'_WB_LSMS_HFPM_HH_Survey_Public_Roster", clear	
	
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
	use				"$root/wave_0`w'/R`w'_WB_LSMS_HFPM_HH_Survey_Public_Microdata", clear

* generate round variable
	gen				wave = `w'
	lab var			wave "Wave number"
	
* drop merge variable
	drop 			_merge

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
	merge 			1:1 household_id using `temp_fies', assert(3) nogen

* save round file
	save			"$export/wave_0`w'/r`w'", replace		
	
	
/* END */
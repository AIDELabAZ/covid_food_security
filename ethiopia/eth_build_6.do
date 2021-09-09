* Project: WB COVID
* Created on: Oct 2020
* Created by: jdm
* Edited by: amf
* Last edit: Nov 2020 
* Stata v.16.1

* does
	* reads in sixth round of Ethiopia data
	* builds round 6
	* outputs round 6

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
	local			w = 6	
	local 			f = 1022
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 
	

* ***********************************************************************
*  1 - roster data - get household size and gender of household head  
* ***********************************************************************

* load roster data
	use				"$root/wave_0`w'/20`f'_WB_LSMS_HFPM_HH_Survey_Roster-Round`w'_Clean-Public", clear
	
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
	use				"$root/wave_0`w'/20`f'_WB_LSMS_HFPM_HH_Survey-Round`w'_Clean-Public_Microdata", clear

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
	merge 			1:1 household_id using `temp_micro'
	keep 			if _m > 1 // more observations in roster than microdata
	drop 			_m
	merge 			1:1 household_id using `temp_fies', nogen
	
* drop vars
	drop 			ac2_atb_med_why_other ac2_atb_teff_why_other ///
						ac2_atb_wheat_why_other ac2_atb_maize_why_other ///
						ac2_atb_oil_why_other ac8_med_access_reas_other ///
						em14_work_cur_notable_why_other em22_farm_norm_why_other ///
						lc4_total_chg_cope_other as4_food_source_other ///
						as4_forwork_source_other as4_cash_source_other ///
						as4_other_source_other ag4_crops_reas_fert_other ///
						ag5_crops_reas_seeds_other ir1_whyendearly_other

* rename vars inconsistent with other rounds
	* behavior 	
		rename			bh1_handwash bh_1
		rename			bh2_handwash_freq bh_freq_wash
		rename			bh3_handshake bh_2
		rename			bh4_gatherings bh_3
		rename 			bh5_mask bh_freq_mask 
		rename 			bh6_cov_fear concern_1 
		rename 			bh7_cov_fin concern_2 						
						
* save round file
	save			"$export/wave_0`w'/r`w'", replace		
	
	
/* END */
* Project: WB COVID
* Created on: June 2021
* Created by: amf
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* reads in baseline Malawi data
	* builds data for LD 
	* outputs HH income dataset

* assumes
	* raw malawi data 

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"
	global  fies 	= 	"$data/analysis/raw/Malawi"

* open log
	cap log 		close
	log using		"$logout/mal_build", append
	
* set local wave number & file number
	local			w = 0
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	
	
* ***********************************************************************
*  household data
* ***********************************************************************
	
* load data
	use 			"$root/wave_0`w'/HH_MOD_B", clear

* rename other variables 
	rename 			PID ind_id 
	rename 			hh_b03 sex_mem
	rename 			hh_b05a age_mem
	rename 			hh_b04 relat_mem	
	gen 			curr_mem = 0 if hh_b06_2 == 3 | hh_b06_2 == 4
	replace 		curr_mem = 1 if hh_b06_2 < 3
	replace 		curr_mem = 1 if hh_b06_2 == .
	gen 			new_mem = 0 if hh_b06_2 != 2 & hh_b06_2 < .
	replace 		new_mem = 1 if hh_b06_2 == 2
	gen 			mem_left = 0 if hh_b06_2  != 3 & hh_b06_2  < .
	replace 		mem_left = 1 if hh_b06_2 == 3
	
* generate counting variables
	drop 			hhsize 
	gen				hhsize = 1 if curr_mem == 1
	gen 			hhsize_adult = 1 if curr_mem == 1 & age_mem > 18 & age_mem < .
	gen				hhsize_child = 1 if curr_mem == 1 & age_mem < 19 & age_mem != . 
	gen 			hhsize_schchild = 1 if curr_mem == 1 & age_mem > 4 & age_mem < 19	

* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data to hh level and merge in why vars
	collapse		(sum) hhsize hhsize_adult hhsize_child hhsize_schchild new_mem ///
					mem_left (max) sexhh, by(y4)	

* save tempfile 
	tempfile 		temp0
	save 			`temp0'
	
	
* ***********************************************************************
*  labor & time use  
* ***********************************************************************	
	
* load data
	use 			"$root/wave_0`w'/HH_MOD_E", clear

* generate epmloyment vars based on hours
	gen 			farm_emp = 0 if hh_e07a == 0 | hh_e07b == 0 | hh_e07c == 0 
	replace 		farm_emp = 1 if (hh_e07a > 0 & hh_e07a < .) | ///
						(hh_e07b > 0 & hh_e07b < .) | (hh_e07c > 0 & hh_e07c < .)
	
	gen 			bus_emp = 0 if hh_e08 == 0 | hh_e09 == 0
	replace 		bus_emp = 1 if (hh_e08 > 0 & hh_e08 < .) | ///
						(hh_e09 > 0 & hh_e09 < .) 
	
	gen 			casual_emp = 0 if hh_e10 == 0
	replace 		casual_emp = 1 if hh_e10 > 0 & hh_e10 < .
	
	gen 			wage_emp = 0 if hh_e11 == 0
	replace 		wage_emp = 1 if hh_e11 > 0 & hh_e11 < .	
	
* collapse to hh level
	collapse 		(max) farm_emp bus_emp casual_emp wage_emp, by(y4)	

* save tempfile 
	tempfile 		temp1
	save 			`temp1'	

	
* ***********************************************************************
*  other income  
* ***********************************************************************
		
* load data
	use 			"$root/wave_0`w'/HH_MOD_P", clear	
	
* rename variables
	rename 			hh_p01 inc_
	replace 		hh_p0a = hh_p0a - 100
	keep 			y4 HHID* inc_ hh_p0a
	
* reshape data and rename/generate inc vars
	reshape 		wide inc_, i(y4) j(hh_p0a)

	rename 			inc_1 remit_inc
	replace 		remit_inc = 0 if remit_inc == 2
	gen 			asst_inc = 0 if inc_2 == 2 | inc_3 == 2
	replace			asst_inc = 1 if inc_2 == 1 | inc_3 == 1	
	gen 			pen_inc = 0 if inc_5 == 2 | inc_5 == 2
	replace			pen_inc = 1 if inc_16 == 1 | inc_16 == 1	
	gen 			isp_inc = 0 if inc_4 == 2 | inc_6 ==2 | inc_7 == 2 | ///
						inc_8 == 2 | inc_9 == 2 | inc_10 == 2
	replace			isp_inc = 1 if inc_4 == 1 | inc_6 == 1 | inc_7 == 1 | ///
						inc_8 == 1 | inc_9 == 1 | inc_10 == 1
	gen 			oth_inc = 0 if inc_11 == 2 | inc_12 == 2 | inc_13 == 2 | ///
						inc_14 == 2 
	replace			oth_inc = 1 if inc_11 == 1 | inc_12 == 1 | inc_13 == 1 | ///
						inc_14 == 1
						
	keep 			y4 *_inc	

* save tempfile 
	tempfile 		temp2
	save 			`temp2'

	
* ***********************************************************************
* merge  
* ***********************************************************************	
	
* combine dataset 
	use 			`temp0', clear
	merge 			1:1 y4 using `temp1', assert(3) nogen
	merge 			1:1 y4 using `temp2', assert(3) nogen
	lab def 		yesno 1 "Yes" 0 "No"
	ds *_inc *_emp
	foreach 		var in `r(varlist)' {
		lab val 	`var' yesno
	}
	
* add country & wave 
	gen 			wave = 0
	gen 			country = 2
	rename 			y4_hhid hhid_mwi
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		
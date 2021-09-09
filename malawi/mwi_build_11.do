* Project: WB COVID
* Created on: Aug 2021
* Created by: amf
* Edited by: amf
* Last edited: Aug 2021
* Stata v.16.1

* does
	* merges together each section of malawi data
	* builds round 11
	* outputs round 11

* assumes
	* raw malawi data 

* TO DO:
	* ADD FIES DATA


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
	local			w = 11
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_`w'" 	
	
	
* ***********************************************************************
* 1c - get respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_`w'/sect12_Interview_Result_r`w'", clear

* drop all but household respondant
	keep			HHID s12q9
	rename			s12q9 PID
	isid			HHID

* merge in household roster
	merge 1:1		HHID PID using "$root/wave_`w'/sect2_Household_Roster_r`w'.dta"
	keep if			_merge == 3
	drop			_merge

* drop all but gender and relation to HoH
	keep			HHID PID s2q5 s2q6 s2q7 s2q9

* save temp file
	tempfile		tempc
	save			`tempc'
		
	
* ***********************************************************************
* 1d - get household size and gender of HOH
* ***********************************************************************

* load data
	use			"$root/wave_`w'/sect2_Household_Roster_r`w'.dta", clear

* rename other variables 
	rename 			PID ind_id 
	rename 			s2q3 curr_mem
	replace 		curr_mem = 1 if s2q2 == 1
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem	
	
* generate counting variables
	gen				hhsize = 1 if curr_mem == 1
	gen 			hhsize_adult = 1 if curr_mem == 1 & age_mem > 18 & age_mem < .
	gen				hhsize_child = 1 if curr_mem == 1 & age_mem < 19 & age_mem != . 
	gen 			hhsize_schchild = 1 if curr_mem == 1 & age_mem > 4 & age_mem < 19 
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* generate migration vars
	rename 			s2q2 new_mem
	replace 		new_mem = 0 if s2q8 == 10
	replace 		s2q8 = . if s2q8 == 10
	gen 			mem_left = 1 if curr_mem == 2
	replace 		new_mem = 0 if new_mem == 2
	replace 		mem_left = 0 if mem_left == 2
	
	* why member left
		preserve
			keep 		y4 s2q4 ind_id
			keep 		if s2q4 != .
			duplicates 	drop y4 s2q4, force
			reshape 	wide ind_id, i(y4) j(s2q4)
			ds 			ind_id*
			foreach 	var in `r(varlist)' {
				replace 	`var' = 1 if `var' != .
			}
			rename 		ind_id* mem_left_why_*
			tempfile 	mem_left
			save 		`mem_left'
		restore
	
	* why new member 
		preserve
			keep 		y4 s2q8 ind_id
			keep 		if s2q8 < .
			duplicates 	drop y4 s2q8, force
			reshape 	wide ind_id, i(y4) j(s2q8)
			ds 			ind_id*
			foreach 	var in `r(varlist)' {
				replace 	`var' = 1 if `var' != .
			}
			rename 		ind_id* new_mem_why_*
			tempfile 	new_mem
			save 		`new_mem'
		restore
	
* collapse data to hh level and merge in why vars
	collapse	(sum) hhsize hhsize_adult hhsize_child hhsize_schchild new_mem mem_left ///
				(max) sexhh, by(HHID y4)
	replace 	new_mem = 1 if new_mem > 0 & new_mem < .
	replace 	mem_left = 1 if mem_left > 0 & new_mem < .	
	merge 		1:1 y4 using `new_mem', nogen
	merge 		1:1 y4 using `mem_left', nogen
	ds 			new_mem_why_* 
	foreach		var in `r(varlist)' {
		replace 	`var' = 0 if `var' >= . & new_mem == 1
	}
	ds 			mem_left_why_* 
	foreach		var in `r(varlist)' {
		replace 	`var' = 0 if `var' >= . & mem_left == 1
	}
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"
	lab var 	mem_left "Member of household left since last call"
	lab var 	new_mem "Member of household joined since last call"
	drop 		y4

* save temp file
	tempfile		tempa
	save			`tempa'

	
* ***********************************************************************
* 1a - reshape section on income loss wide data
* ***********************************************************************

* load income_loss data
	use				"$root/wave_`w'/sect7_Income_Loss_r`w'", clear

*reshape data
	reshape 		wide s7q1 s7q2, i(y4_hhid HHID) j(income_source)

* save temp file
	tempfile		tempb
	save			`tempb'
	
	
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_`w'/secta_Cover_Page_r`w'", clear
	
* merge formatted sections
	foreach 		x in a b c {
	    merge 		1:1 HHID using `temp`x'', nogen
	}

* merge in other sections
	merge 1:1 		HHID using "$root/wave_`w'/sect4_behavior_r`w'.dta", nogen	
	merge 1:1 		HHID using "$root/wave_`w'/sect5_access_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_`w'/sect6a_employment2_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_`w'/sect6b_nfe_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_`w'/sect6e_agriculture_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_`w'/sect8_food_security_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_`w'/sect9_Concerns_r`w'.dta", nogen
	
* rename variables inconsistent with other waves	
	
	* behavior
		rename 			s4q7 bh_freq_wash
		rename 			s4q8 bh_freq_mask
	
	* employment 
		rename 			s6q3a emp_search
		rename 			s6q3b emp_search_how		
		rename 			s6q5 emp_act
		replace 		emp_act = 100 if emp_act == 13
		replace 		emp_act = 13 if emp_act == 8
		replace 		emp_act = 8 if emp_act == 6
		replace 		emp_act = 6 if emp_act == 100
		replace 		emp_act = 14 if emp_act == 9
		replace 		emp_act = 9 if emp_act == 11 | emp_act == 12
		replace 		emp_act = 11 if emp_act == 4
		replace 		emp_act = 12 if emp_act == 5
		replace 		emp_act = 4 if emp_act == 7
		replace 		emp_act = 7 if emp_act == 10
		replace 		emp_act = 16 if emp_act == 15
		replace 		emp_act = -96 if emp_act == 96
		rename			s6bq11 bus_emp
	
	* agriculture 
		rename 			s6eq1 ag_crop
		replace 		ag_crop = s6eq2 if ag_crop >= .
		replace 		ag_crop = . if ag_crop == 4
		rename 			s6eq3__1 ag_crop_who		
		rename 			s6eq5 ag_main
		rename 			s6eq6 ag_main_plots
		rename 			s6eq7 ag_main_area
		rename 			s6eq7_units ag_main_area_unit
		rename 			s6eq8 ag_main_harv
		rename 			s6eq10 ag_main_sell
		gen				ag_main_sell_per = s6eq11/s6eq9a
		rename 			s6eq12 ag_main_rev
		rename 			s6eq13 harv_sell_rev
		rename 			s6eq14 ag_main_sell_plan
		rename 			s6eq15 harv_sell_rev_exp
		rename 			s6eq16 ag_main_harv_comp
		rename 			s6eq17a ag_main_more
		rename 			s6eq17b ag_main_more_unit
		rename 			s6eq18a ag_use_infert
		rename 			s6eq18b ag_use_orfert
		rename 			s6eq18c ag_use_pest
		rename 			s6eq18d ag_use_lab
		rename 			s6eq18e ag_use_anim
		rename 			s6eq19a__* ag_ac_infert_why_*
		rename 			s6eq19b__* ag_ac_orfert_why_*
		rename 			s6eq19c__* ag_ac_pest_why_*
		rename 			s6eq19d__* ag_ac_lab_why_*
		rename 			s6eq19e__1 ag_ac_anim_why_1
		rename 			s6eq19e__2 ag_ac_anim_why_2
		rename 			s6eq19e__3 ag_ac_anim_why_4
		rename 			s6eq19e__4 ag_ac_anim_why_5
		rename 			s6eq19e__5 ag_ac_anim_why_3
		rename 			s6eq19e__6 ag_ac_anim_why_6
		rename 			s6eq19e__7 ag_ac_anim_why_7
		
		drop 			s6eq3a s6eq4 s6eq7_units_ot s6eq5_ot s6eq5_ot2 ///
							s6eq9a s6eq9b s6eq9b_ot s6eq9c s6eq17c *_96 *_ot ///
							s6eq2 s6eq3__2 s6eq11

* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename			wt_round`w' phw_cs
	label var		phw "sampling weights - cross section"
	
* save round file
	save			"$export/wave_`w'/r`w'", replace

/* END */		
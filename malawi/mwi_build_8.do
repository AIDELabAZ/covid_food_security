* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* builds round 8
	* outputs round 8

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
	local			w = 8
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	
	
* ***********************************************************************
* 1a - reshape section on income loss wide data
* ***********************************************************************

* no data 

	
* ***********************************************************************
* 1b - reshape section on safety nets wide data
* ***********************************************************************

* load safety_net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/sect11_Safety_Nets_r`w'", clear

* drop other
	drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b 

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safety)
 
* collapse cash options into 1 to match round 1 
	rename 			s11q12 temp
	gen 			s11q12 = 1 if temp == 1 | s11q13 == 1 | s11q14 == 1
	replace 		s11q12 = 2 if s11q12 == .
	drop 			s11q13 s11q14  temp
	rename 			s11q15 s11q13

* save temp file
	tempfile		tempb
	save			`tempb'


* ***********************************************************************
* 1c - get respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/sect12_Interview_Result_r`w'", clear

* drop all but household respondant
	keep			HHID s12q9
	rename			s12q9 PID
	isid			HHID

* merge in household roster
	merge 1:1		HHID PID using "$root/wave_0`w'/sect2_Household_Roster_r`w'.dta"
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
	use			"$root/wave_0`w'/sect2_Household_Roster_r`w'.dta", clear

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
	tempfile		tempd
	save			`tempd'
	
	
* ***********************************************************************
* 1e - FIES score
* ***********************************************************************
/*
* load data
	use				"$fies/MW_FIES_round`w'.dta", clear
	drop 			country round 

* merge in other data to get HHID to match 
	rename 			HHID y4_hhid 
	merge 			1:1 y4_hhid using "$root/wave_0`w'/secta_Cover_Page_r`w'"
	keep 			HHID hhsize wt_hh p_mod urban weight Above_18 wt_18 p_sev

* save temp file
	tempfile		tempe
	save			`tempe'

*/
* ***********************************************************************
* 1f - reshape section on coping wide data
* ***********************************************************************

* not available for round

	
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/secta_Cover_Page_r`w'", clear
	
* merge formatted sections
	foreach 		x in b c d {
	    merge 		1:1 HHID using `temp`x'', nogen
	}

* merge in other sections
	merge 1:1 		HHID using "$root/wave_0`w'/sect4_Behavior_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect5_Access_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6b_NFE_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6a_Employment2_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6d_Credit_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect8_food_security_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect9_Concerns_r`w'.dta", nogen

* rename variables inconsistent with other waves
	
	* behavior
		rename 			s4q7 bh_freq_wash
		rename 			s4q8 bh_freq_mask
	
	* access
		rename 			s5q1a1 ac_soap
		* shops
		rename 			s5q6 ac_shops_need
		rename 			s5q6a ac_shops_mask
		rename 			s5q5b ac_shops_wash
		rename 			s5q5c ac_shops_san
		rename 			s5q5d ac_shops_line
		
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
	
	* rename access credit variables inconsistent with wave 3 
		rename 			s6dq1 ac_cr_loan
		gen 			ac_cr_need = 1 if ac_cr_loan == 1 | ac_cr_loan == 2
		replace 		ac_cr_need = 0 if ac_cr_loan == 3
		replace 		ac_cr_loan = 0 if ac_cr_loan == 3
		lab def 		ac_cr_loan 1 "Yes" 2 "Unable or did not try" 
		lab val 		ac_cr_loan ac_cr_loan 
		rename 			s6dq2 ac_cr_lend
		forval 			x = 1/8 {
			gen 		ac_cr_lend_`x' = 1 if ac_cr_lend == `x' // cleaned for consistency in master
		}
		drop 			ac_cr_lend
		rename 			s6dq3 ac_cr_lend_att
		forval 			x = 1/12 {
			rename 		s6dq4__`x' ac_cr_why_`x'
			replace 	ac_cr_why_`x' = 0 if ac_cr_why_`x' == . & s6dq5 == 0 
			replace 	ac_cr_why_`x' = 1 if s6dq5 == `x' 
		}
		drop 			s6dq5
		rename 			s6dq6__0 ac_cr_who_1
		rename 			s6dq6__1 ac_cr_who_2
		rename 			s6dq7__0 ac_cr_att_who_1
		rename 			s6dq7__1 ac_cr_att_who_2
		rename 			s6dq8 ac_cr_due
		rename 			s6dq9 ac_cr_worry
		rename 			s6dq10 ac_cr_bef
		replace 		ac_cr_bef = previous_loanfilter if ///
							ac_cr_bef == . & previous_loanfilter != .
		rename 			s6dq10a ac_cr_prev_repay
		forval 			x = 1/12 {
			gen 			ac_cr_bef_why_`x' = 0
			replace 		ac_cr_bef_why_`x' =	. if s6dq11 == .
			replace 		ac_cr_bef_why_`x' = 1 if s6dq11 == `x'
		}
		drop 			s6dq11
		rename 			s6dq12__0 ac_cr_bef_who_1
		rename 			s6dq12__1 ac_cr_bef_who_2
		rename 			s6dq13 ac_cr_bef_worry
		rename 			s6dq14 ac_cr_bef_miss
		rename 			s6dq15 ac_cr_bef_delay		
		
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			wt_round`w' phw_cs
	label var		phw "sampling weights - cross section"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		
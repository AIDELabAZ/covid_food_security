* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* builds round 1
	* outputs round 1

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
	local			w = 1
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	
	
* ***********************************************************************
* 1a - reshape section on income loss wide data
* ***********************************************************************

* load income_loss data
	use				"$root/wave_0`w'/sect7_Income_Loss_r`w'", clear

* drop other source
	drop 			income_source_os
	
*reshape data
	reshape 		wide s7q1 s7q2, i(y4_hhid HHID) j(income_source)

* save temp file
	tempfile		tempa
	save			`tempa'

	
* ***********************************************************************
* 1b - reshape section on safety nets wide data
* ***********************************************************************

* load safety_net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/sect11_Safety_Nets_r`w'", clear

* drop other
	drop 			s11q2 s11q3 s11q3_os

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safetyid)

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
	rename 			new_mem new_mem
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
			keep 		if s2q8 != .
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

* load data
	use				"$fies/MW_FIES_round`w'.dta", clear
	rename 			HHID y4_hhid
	drop 			country round

* save temp file
	tempfile		tempe
	save			`tempe'
	
		
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/secta_Cover_Page_r`w'", clear
	
* merge formatted sections
	foreach 		x in a b c d {
	    merge 		1:1 HHID using `temp`x'', nogen
	}
	merge 			1:1 y4_hhid using `tempe', nogen
	
* merge in other sections
	merge 1:1 		HHID using "$root/wave_0`w'/sect3_Knowledge_r`w'.dta",nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect4_Behavior_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect5_Access_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6_Employment_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect8_food_security_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect9_Concerns_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect13_Agriculture_r`w'.dta", nogen

* rename variables inconsistent with other waves
	* education
	rename 			s5q6d edu_act
	rename 			s5q6__1 edu_1
	rename 			s5q6__2 edu_2
	rename 			s5q6__3 edu_3
	rename 			s5q6__4 edu_4
	rename 			s5q6__5 edu_5
	rename 			s5q6__96 edu_other
	rename 			s5q7 edu_cont
	rename			s5q8__1 edu_cont_1
	rename 			s5q8__2 edu_cont_2
	rename 			s5q8__3 edu_cont_3
	rename 			s5q8__4 edu_cont_4
	rename 			s5q8__5 edu_cont_5
	rename 			s5q8__6 edu_cont_6
	rename 			s5q8__7 edu_cont_7
	rename 			s5q6a sch_child
	
	* employment
	rename			s6q2 emp_pre
	rename			s6q3a emp_pre_why	
	rename 			s6q3b emp_nowork_pay
	rename			s6q4a emp_same
	rename			s6q4b emp_chg_why
	replace 		emp_chg_why = 96 if emp_chg_why == 13
	rename			s6q4c emp_pre_act
	rename			s6q6 emp_stat
	rename			s6q7 emp_able
	rename			s6q8 emp_unable
	rename			s6q8a emp_unable_why
	rename			s6q8b__1 emp_cont_1
	rename			s6q8b__2 emp_cont_2
	rename			s6q8b__3 emp_cont_3
	rename			s6q8b__4 emp_cont_4
	
	rename			s6q8c__1 contrct
	replace 		s6q8c__2 = 7 if s6q8c__2 == 1
	replace 		s6q8c__2 = 1 if s6q8c__2  == 0
	replace 		s6q8c__2  = 0 if s6q8c__2 == 1
	replace 		contrct = s6q8c__2 if contrct == .
	
	rename			s6q9 emp_hh
	rename			s6q11 bus_emp
	rename			s6q12 bus_sect
	rename			s6q13 bus_emp_inc
	rename			s6q14 bus_why
	rename			s6q15 farm_emp
	rename			s6q16 farm_norm
	rename			s6q17__1 farm_why_1
	rename			s6q17__2 farm_why_2
	rename			s6q17__3 farm_why_3
	rename			s6q17__4 farm_why_4
	rename			s6q17__5 farm_why_5
	rename			s6q17__6 farm_why_6
	drop			s6q17__7 
	
	* ag
	rename			s13q1 ag_crop
	rename			s13q13 harv_sell_need
	rename			s13q14 harv_sell
	
	* access
	rename 			s5q1a1 ac_soap_need
	rename 			s5q1b1 ac_soap
	rename			s3q1a ac_internet
	
	* satisfaction 
	rename 			s3q6 satis
	rename 			s3q7__1 satis_1
	rename			s3q7__2 satis_2
	rename 			s3q7__3 satis_3
	rename 			s3q7__4 satis_4
	rename 			s3q7__5 satis_5
	rename 			s3q7__6 satis_6
	rename 			s3q7__96 satis_7
	drop 			s3q7_os 
	
	* behavior
	rename			s4q1 bh_1
	rename			s4q2a bh_2
	replace 		bh_2 = 0 if bh_2 < 3
	replace 		bh_2 = 1 if bh_2 > 0 & bh_2 != .
	rename			s4q3a bh_3
	replace 		bh_3 = 0 if bh_3 == 1
	replace 		bh_3 = 1 if bh_3 > 1 & bh_3 != .
	rename			s4q3b bh_nogath
	drop 			s4q4 //questions inconsistent from survey to data, usually go with data but this one seems incompatible with other responses
	rename			s4q5 bh_4
	rename			s4q6 bh_5
	
	* edit employment activity	
	rename			s6q1a edu
	rename			s6q5 emp_act
	replace 		emp_act = -96 if emp_act == 16
	replace 		emp_act = 16 if emp_act == 15
	replace 		emp_act = 15 if emp_act == 14
	replace 		emp_act = 14 if emp_act == 9
	replace 		emp_act = 9 if emp_act == 11 | emp_act == 12
	replace 		emp_act = 11 if emp_act == 4
	replace 		emp_act = 12 if emp_act == 5
	replace 		emp_act = 4 if emp_act == 7
	replace 		emp_act = 7 if emp_act == 10
	replace 		emp_act = 10 if emp_act == 2
	replace 		emp_act = 2 if emp_act == 3
	replace 		emp_act = 0 if emp_act == 8
	replace 		emp_act = 8 if emp_act == 6
	replace 		emp_act = 6 if emp_act == 13
	replace 		emp_act = 13 if emp_act == 0
	
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
		
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			wt_baseline phw_cs
	label var		phw "sampling weights - cross section"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		
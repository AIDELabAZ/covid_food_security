* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* builds round 5
	* outputs round 5

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
	local			w = 5
	
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
	drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b s11q5 s11q6__1 ///
						s11q6__2 s11q6__3 s11q6__4 s11q6__5 s11q6__6 ///
						s11q6__7 s11q7__1 s11q7__2 s11q7__3 s11q7__4 ///
						s11q7__5 s11q7__6 s11q7__7 s11q7_os 

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safety)
 
* collapse cash options into 1 to match round 1 
	rename 			s11q12 temp
	gen 			s11q12 = 1 if temp == 1 | s11q13 == 1 | s11q14 == 1
	replace 		s11q12 = 2 if s11q12 == .
	drop 			s11q13 s11q14 temp
	rename 			s11q15 s11q13

* save temp file
	tempfile		tempb
	save			`tempb'

* isolate government assistance for LD index 
	* load safety_net data - updated via convo with Talip 9/1
		use				"$root/wave_0`w'/sect11_Safety_Nets_r`w'", clear	

	* keep only if govt source of asst
		replace 		s11q1 = 2 if s11q3 != 1
	
	* drop other
		drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b s11q5 s11q6__1 ///
							s11q6__2 s11q6__3 s11q6__4 s11q6__5 s11q6__6 ///
							s11q6__7 s11q7__1 s11q7__2 s11q7__3 s11q7__4 ///
							s11q7__5 s11q7__6 s11q7__7 s11q7_os 

	* reshape
		reshape 		wide s11q1, i(y4_hhid HHID) j(social_safety)
	 
	* collapse cash options into 1 to match round 1 
		rename 			s11q12 temp
		gen 			s11q12 = 1 if temp == 1 | s11q13 == 1 | s11q14 == 1
		drop 			s11q13 s11q14 temp
		rename 			s11q15 s11q13
		
		rename 			s11q11 asst_food
		replace			asst_food = 0 if asst_food == .
		rename 			s11q12 asst_cash
		replace			asst_cash = 0 if asst_cash == .
		rename 			s11q13 asst_kind 
		replace			asst_kind = 0 if asst_kind == .
		gen				gov_inc_sec = 1 if asst_food == 1 | asst_cash == 1 | ///
							asst_kind == 1
		replace			gov_inc_sec = 0 if gov_inc_sec == .
		keep 			HHID gov_inc_sec
		
	* save temp file
		tempfile		tempb1
		save			`tempb1'
		
* isolate assistance other than gov for LD index 
	* load safety_net data - updated via convo with Talip 9/1
		use				"$root/wave_0`w'/sect11_Safety_Nets_r`w'", clear	

	* keep only if govt NOT source of asst
		replace 		s11q1 = 2 if s11q3 == 1
	
	* drop other
		drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b s11q5 s11q6__1 ///
							s11q6__2 s11q6__3 s11q6__4 s11q6__5 s11q6__6 ///
							s11q6__7 s11q7__1 s11q7__2 s11q7__3 s11q7__4 ///
							s11q7__5 s11q7__6 s11q7__7 s11q7_os 

	* reshape
		reshape 		wide s11q1, i(y4_hhid HHID) j(social_safety)
	 
	* collapse cash options into 1 to match round 1 
		rename 			s11q12 temp
		gen 			s11q12 = 1 if temp == 1 | s11q13 == 1 | s11q14 == 1
		drop 			s11q13 s11q14 temp
		rename 			s11q15 s11q13
		
		rename 			s11q11 asst_food
		replace			asst_food = 0 if asst_food == .
		rename 			s11q12 asst_cash
		replace			asst_cash = 0 if asst_cash == .
		rename 			s11q13 asst_kind 
		replace			asst_kind = 0 if asst_kind == .
		gen				oth_inc2_sec = 1 if asst_food == 1 | asst_cash == 1 | ///
							asst_kind == 1
		replace			oth_inc2_sec = 0 if oth_inc2_sec == .
		keep 			HHID oth_inc2_sec
	
	* save temp file
		tempfile		tempb2
		save			`tempb2'	
		
	
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
	drop 			country round 

* merge in other data to get HHID to match 
	rename 			HHID y4_hhid 
	merge 			1:1 y4_hhid using "$root/wave_0`w'/secta_Cover_Page_r`w'"
	keep 			HHID hhsize wt_hh p_mod urban weight Above_18 wt_18 p_sev

* save temp file
	tempfile		tempe
	save			`tempe'


* ***********************************************************************
* 1f - reshape section on coping wide data
* ***********************************************************************

* not available for round


* ***********************************************************************
* 1g - reshape section on livestock
* ***********************************************************************	

* load data
	use				"$root/wave_0`w'/sect6e_Livestock_Products_r`w'", clear

	drop 			interview__key
	
* reshape wide
	gen 			product = cond(LivestockPr == 555, "other", cond(LivestockPr == 1, ///
					"milk",cond(LivestockPr == 2, "eggs",cond(LivestockPr == 3, "meat","manure"))))
	drop 			Livestock
	reshape 		wide s6qe*, i(HHID y4_hhid) j(product) string

* save temp file part 1
	tempfile		tempg
	save			`tempg'

	
* ***********************************************************************
* 1h - reshape section on employment
* ***********************************************************************	
	
* load data
	use				"$root/wave_0`w'/sect6_Employment_Other_r`w'", clear

* generate secondary income variables for index
	gen 			wage_inc_ind = 1 if s6q6_1 == 4 | s6q6_1 == 5
	replace 		wage_inc_ind = 0 if s6q6_1 < 4	
	gen 			farm_inc_ind = 1 if s6q6_1 == 3
	replace 		farm_inc_ind = 0 if s6q6_1 != 3 & s6q6_1 < .
	gen 			bus_inc_ind = 1 if s6q6_1 < 3
	replace 		bus_inc_ind = 0 if s6q6_1 >= 3 & s6q6_1 < .
	
* collapse to hh level 
	collapse 		(sum) *_inc_ind, by(HHID)
	replace 		wage = 1 if wage > 1
	replace 		farm = 1 if farm > 1
	replace 		bus = 1 if bus > 1
	
* save temp file part 1
	tempfile		temph
	save			`temph'
	
	
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/secta_Cover_Page_r`w'", clear
	
* merge formatted sections
	foreach 		x in b b1 b2 c d e g h {
	    merge 		1:1 HHID using `temp`x'', nogen
	}
	
* merge in other sections
	merge 1:1 		HHID using "$root/wave_0`w'/sect4_Behavior_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect5_Access_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect5c_Education_r`w'", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6a_Employment2_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6b_NFE_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6c_OtherIncome_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6e_Agriculture_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect8_food_security_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect9_Concerns_r`w'.dta", nogen

*rename variables inconsistent with other waves

	* behavior
		rename			s4q1 bh_1
		rename			s4q2a bh_2
		rename 			s4q3a bh_3
		replace 		bh_2 = . if bh_2 == 3 
		replace 		bh_3 = . if bh_3 == 3
		rename 			s4q3b bh_freq_gath
		rename 			s4q5 bh_4
		rename 			s4q6 bh_5
		rename 			s4q7 bh_freq_wash
		rename 			s4q8 bh_freq_mask
		
	* education 
		rename 			s5cq1 sch_att
		forval 			x = 1/14 {
			rename 			s5cq2__`x' sch_att_why_`x'
		}
		rename 			s5cq3 sch_prec
		forval 			x = 1/11 {
			rename 		s5cq4__`x' sch_prec_`x'
		}
		rename 			s5cq4__99 sch_prec_none
		rename 			s5cq5a sch_prec_sat
		rename 			s5cq6 edu_act
		forval 			x = 1/4 {
		    rename 		s5cq7__`x' edu_`x'
		}
		rename 			s5cq7__5 edu_6
		rename 			s5cq7__6 edu_7
		rename 			s5cq7__7 edu_5
		drop 			s5cq2__96 s5cq7__96 s5cq5b s5cq4__98 s5cq7_os
		
		rename 			s5cq8 edu_cont
		forval 			x = 1/7 {
			rename 		s5cq9__`x' edu_cont_`x'
		}
		rename 			s5cq10 sch_msk_sens
		
	* employment 
		rename 			s6q3a emp_search
		rename 			s6q3b emp_search_how
		rename 			s6q5 emp_act
		replace 		emp_act = 2 if emp_act == 3
		replace 		emp_act = 14 if emp_act == 9 
		replace 		emp_act = 9 if emp_act == 11 | emp_act == 12
		replace 		emp_act = 11 if emp_act == 4
		replace 		emp_act = 4 if emp_act == 7
		replace 		emp_act = 7 if emp_act == 10
		replace 		emp_act = 100 if emp_act == 8
		replace 		emp_act = 8 if emp_act == 6
		replace 		emp_act = 6 if emp_act == 13
		replace 		emp_act = 13 if emp_act == 100
		replace 		emp_act = 16 if emp_act == 15
		replace 		emp_act = -96 if emp_act == 96
		rename			s6bq11 bus_emp	
		
	* agriculture 
		rename 			s6qe1 harv_sell_need
		rename 			s6qe1a harv_sell
	
	* concerns
		rename 			s9q7 concern_8
		
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			wt_round`w' phw_cs
	label var		phw "sampling weights - cross section"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		
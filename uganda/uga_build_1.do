* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by : amf
* Last edited: December 2020
* Stata v.16.1

* does
	* reads in first round of Uganda data
	* builds round 1
	* outputs round 1

* assumes
	* raw Uganda data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	root	=	"$data/uganda/raw"
	global	fies	=	"$data/analysis/raw/Uganda"
	global	export	=	"$data/uganda/refined"
	global	logout	=	"$data/uganda/logs"

* open log
	cap log 		close
	log using		"$logout/uga_build", append
	
* set local wave number & file number
	local			w = 1
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	
	
* ***********************************************************************
* 1 - reshape section 6 wide data
* ***********************************************************************

* load income data
	use				"$root/wave_0`w'/SEC6", clear

* reformat HHID
	format 			%12.0f HHID

* drop other source
	drop			s6q01_Other

* replace value for "other"
	replace			income_loss__id = 96 if income_loss__id == -96

* reshape data
	reshape 		wide s6q01 s6q02, i(HHID) j(income_loss__id)

* save temp file
	tempfile		temp1
	save			`temp1'


* ***********************************************************************
* 2 - reshape section 9 wide data
* ***********************************************************************

* load income data
	use				"$root/wave_0`w'/SEC9", clear

* reformat HHID
	format 			%12.0f HHID

* drop other shock
	drop			s9q01_Other

* replace value for "other"
	replace			shocks__id = 96 if shocks__id == -96

* generate shock variables
	forval i = 1/13 {
		gen				shock_`i' = 0 if s9q01 == 2 & shocks__id == `i'
		replace			shock_`i' = 1 if s9q01 == 1 & shocks__id == `i'
		}

	gen				shock_14 = 0 if s9q01 == 2 & shocks__id == 96
	replace			shock_14 = 1 if s9q01 == 1 & shocks__id == 96

* format shock variables
	lab var			shock_1 "Death or disability of an adult working member of the household"
	lab var			shock_2 "Death of someone who sends remittances to the household"
	lab var			shock_3 "Illness of income earning member of the household"
	lab var			shock_4 "Loss of an important contact"
	lab var			shock_5 "Job loss"
	lab var			shock_6 "Non-farm business failure"
	lab var			shock_7 "Theft of crops, cash, livestock or other property"
	lab var			shock_8 "Destruction of harvest by insufficient labor"
	lab var			shock_9 "Disease/Pest invasion that caused harvest failure or storage loss"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items consumed"
	lab var			shock_13 "Floods"
	lab var			shock_14 "Other shock"

* rename cope variables
	rename			s9q03__1 cope_1
	rename			s9q03__2 cope_2
	rename			s9q03__3 cope_3
	rename			s9q03__4 cope_4
	rename			s9q03__5 cope_5
	rename			s9q03__6 cope_6
	rename			s9q03__7 cope_7
	rename			s9q03__8 cope_8
	rename			s9q03__9 cope_9
	rename			s9q03__10 cope_10
	rename			s9q03__11 cope_11
	rename			s9q03__12 cope_12
	rename			s9q03__13 cope_13
	rename			s9q03__14 cope_14
	rename			s9q03__15 cope_15
	rename			s9q03__16 cope_16
	rename			s9q03__n96 cope_17

* drop unnecessary variables
	drop	shocks__id s9q01 s9q02 s9q03_Other

* collapse to household level
	collapse (max) cope_1- shock_14, by(HHID)
	
* generate any shock variable
	gen				shock_any = 1 if shock_1 == 1 | shock_2 == 1 | ///
						shock_3 == 1 | shock_4 == 1 | shock_5 == 1 | ///
						shock_6 == 1 | shock_7 == 1 | shock_8 == 1 | ///
						shock_9 == 1 | shock_10 == 1 | shock_11 == 1 | ///
						shock_12 == 1 | shock_13 == 1 | shock_14== 1
	replace			shock_any = 0 if shock_any == .
	lab var			shock_any "Experience some shock"
* save temp file
	tempfile		temp2
	save			`temp2'


* ***********************************************************************
* 3 - reshape section 10 wide data
* ***********************************************************************

* load safety net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/SEC10", clear

* reformat HHID
	format 			%12.0f HHID

* drop other safety nets and missing values
	drop			s10q02 s10q04 other_nets

* reshape data
	reshape 		wide s10q01 s10q03, i(HHID) j(safety_net__id)
	*** note that cash = 101, food = 102, in-kind = 103 (unlike wave 2)

* rename variables
	gen				asst_food = 1 if s10q01102 == 1 | s10q03102 == 1
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s10q01101 == 1 | s10q03101 ==1
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s10q01103 == 1 | s10q03103 == 1
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s10q01101 s10q03101 s10q01102 s10q03102 s10q01103 s10q03103
	
* save temp file
* save temp file
	tempfile		temp3
	save			`temp3'


* ***********************************************************************
* 4 - get respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/interview_result", clear

* drop all but household respondant
	keep			HHID Rq09

	rename			Rq09 hh_roster__id

	isid			HHID

* merge in household roster
	merge 1:1		HHID hh_roster__id using "$root/wave_0`w'/SEC1.dta"

	keep if			_merge == 3

* rename variables and fill in missing values
	rename			hh_roster__id PID
	rename			s1q05 sex
	rename			s1q06 age
	rename			s1q07 relate_hoh
	drop if			PID == .

* drop all but gender and relation to HoH
	keep			HHID PID sex age relate_hoh

* save temp file
	tempfile		temp4
	save			`temp4'

	
* ***********************************************************************
* 5 - get household size and gender of HOH
* ***********************************************************************

* load data 
	use				"$root/wave_0`w'/SEC1.dta", clear

* rename other variables 
	rename 			hh_roster__id ind_id 
	rename 			s1q03 curr_mem
	replace 		curr_mem = 1 if s1q02 == 1
	rename 			s1q05 sex_mem
	rename 			s1q06 age_mem
	rename 			s1q07 relat_mem
	
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
	rename 			s1q02 new_mem
	replace 		new_mem = 0 if s1q08 == 10
	replace 		s1q08 = . if s1q08 == 10
	gen 			mem_left = 1 if curr_mem == 2
	replace 		new_mem = 0 if new_mem == 2
	replace 		mem_left = 0 if mem_left == 2
	
	* why member left
		preserve
			keep 		HHID s1q04 ind_id
			keep 		if s1q04 < .
			duplicates 	drop HHID s1q04, force
			reshape 	wide ind_id, i(HHID) j(s1q04)
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
			keep 		HHID s1q08 ind_id
			keep 		if s1q08 < .
			duplicates 	drop HHID s1q08, force
			replace 	s1q08 = 96 if s1q08 == -96
			reshape 	wide ind_id, i(HHID) j(s1q08)
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
				(max) sexhh, by(HHID)
	replace 	new_mem = 1 if new_mem > 0 & new_mem < .
	replace 	mem_left = 1 if mem_left > 0 & new_mem < .	
	merge 		1:1 HHID using `new_mem', nogen
	merge 		1:1 HHID using `mem_left', nogen
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
	
* save temp file
	tempfile		temp5
	save			`temp5'
	

* ***********************************************************************
* 6 - FIES 
* ***********************************************************************

* load data
	use				"$fies/UG_FIES_round`w'.dta", clear

	drop 			country round
	destring 		HHID, replace

* save temp file
	tempfile		temp6
	save			`temp6'


* ***********************************************************************
* 7 - build uganda cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/Cover", clear
	
* merge in other sections
	forval x = 1/6 {
	    merge 1:1 HHID using `temp`x'', nogen
	}
	merge 1:1 		HHID using "$root/wave_0`w'/SEC2.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC3.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC4.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5A.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC7.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC8.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC9A.dta", nogen
	merge 1:1 		HHID using "$export/wave_0`w'/fies_r1.dta", nogen
 
* rename variables inconsistent with other waves
	* rename behavioral changes
		rename			s3q01 bh_1
		rename			s3q02 bh_2
		rename			s3q03 bh_3
		rename			s3q05 bh_4
		rename			s3q06 bh_5	
	* rename employment
		rename			s5q01a edu
		rename			s5q01 emp
		rename			s5q02 emp_pre
		rename			s5q03 emp_pre_why
		rename			s504 emp_pre_act
		replace 		emp_pre_act = s504c if s504c != . & emp_pre_act == .
		drop 			s504c
		rename			s5q04a emp_same
		rename			s5q04b emp_chg_why
		rename			s5q05 emp_act
		rename			s5q06 emp_stat
		rename			s5q07 emp_able
		rename			s5q08 emp_unable
		rename			s5q08a emp_unable_why
		rename			s5q08b__1 emp_cont_1
		rename			s5q08b__2 emp_cont_2
		rename			s5q08b__3 emp_cont_3
		rename			s5q08b__4 emp_cont_4
		rename			s5q08c contrct
		rename			s5q09 emp_hh
		rename			s5q11 bus_emp
		rename			s5q12 bus_sect
		rename			s5q13 bus_emp_inc
		rename			s5q14 bus_why
	* rename food security
		rename			s7q01 fies_4
		lab var			fies_4 "Worried about not having enough food to eat"
		rename			s7q02 fies_5
		lab var			fies_5 "Unable to eat healthy and nutritious/preferred foods"
		rename			s7q03 fies_6
		lab var			fies_6 "Ate only a few kinds of food"
		rename			s7q04 fies_7
		lab var			fies_7 "Skipped a meal"
		rename			s7q05 fies_8
		lab var			fies_8 "Ate less than you thought you should"
		rename			s7q06 fies_1
		lab var			fies_1 "Ran out of food"
		rename			s7q07 fies_2
		lab var			fies_2 "Hungry but did not eat"
		rename			s7q08 fies_3
		lab var			fies_3 "Went without eating for a whole day"
	* rename concerns
		rename			s8q01 concern_1
		rename			a8q02 concern_2
	* rename coping
		rename			s9q04 meal
		rename			s9q05 meal_source
	* rename education 
		rename 			s4q012 children318
		rename 			s4q013 sch_child
		rename 			s4q014 edu_act
		rename 			s4q15__1 edu_1
		rename 			s4q15__2 edu_2
		rename 			s4q15__3 edu_3
		rename 			s4q15__4 edu_4
		rename 			s4q15__5 edu_5
		rename 			s4q15__6 edu_8
		lab var 		edu_8 "Used reading materials provided by government"
		rename 			s4q15__n96 edu_other	
	* rename agriculture
		rename 			s5aq26 ag_live
		rename			s5aq16 ag_crop
		rename			s5aq17 ag_plan
		gen 			ag_nocrop_1 = 1 if s5qaq17_1 == 1
		gen 			ag_nocrop_2 = 1 if s5qaq17_1 == 2
		gen 			ag_nocrop_3 = 1 if s5qaq17_1 == 3
		gen 			ag_nocrop_4 = 1 if s5qaq17_1 == 4
		gen 			ag_nocrop_10 = 1 if s5qaq17_1 == 5
		gen 			ag_nocrop_5 = 1 if s5qaq17_1 == 6
		gen 			ag_nocrop_6 = 1 if s5qaq17_1 == 7
		gen 			ag_nocrop_7 = 1 if s5qaq17_1 == 8
		gen 			ag_nocrop_9 = 1 if s5qaq17_1 == -96
		rename 			s5aq18__0 ag_crop_1
		rename 			s5aq18__1 ag_crop_2
		rename 			s5aq18__2 ag_crop_3
		rename			s5aq19 ag_chg
		rename			s5aq20__1 ag_chg_1
		rename			s5aq20__2 ag_chg_2
		rename			s5aq20__3 ag_chg_3
		rename			s5aq20__4 ag_chg_4
		rename			s5aq20__5 ag_chg_5
		rename			s5aq20__6 ag_chg_6
		rename			s5aq20__7 ag_chg_7
		rename			s5aq21__1 ag_covid_1
		rename			s5aq21__2 ag_covid_2
		rename			s5aq21__3 ag_covid_3
		rename			s5aq21__4 ag_covid_4
		rename			s5aq21__5 ag_covid_5
		rename			s5aq21__6 ag_covid_6
		rename			s5aq21__7 ag_covid_7
		rename			s5aq21__8 ag_covid_8
		rename			s5aq21__9 ag_covid_9
		rename			s5aq22__1 ag_ac_seed_why_1
		rename			s5aq22__2 ag_ac_seed_why_2
		rename			s5aq22__3 ag_ac_seed_why_3
		rename			s5aq22__4 ag_ac_seed_why_4
		rename			s5aq22__5 ag_ac_seed_why_5
		rename			s5aq22__6 ag_ac_seed_why_6
		forval 			x = 1/6 {
			gen 		ag_ac_fert_why_`x' = .
			replace 	ag_ac_fert_why_`x' = 0 if s5aq23 != .
			replace 	ag_ac_fert_why_`x' = 1 if s5aq23 == `x'
			gen 		ag_ac_oth_why_`x' = .
			replace 	ag_ac_oth_why_`x' = 0 if s5aq24 != .
			replace 	ag_ac_oth_why_`x' = 1 if s5aq24 == `x'
		}
		drop			s5aq23 s5aq24 
		rename			s5aq25 ag_crop_lost
		rename			s5aq27 ag_live_chg
		rename			s5aq28__1 ag_live_chg_1
		rename			s5aq28__2 ag_live_chg_2
		rename			s5aq28__3 ag_live_chg_3
		rename			s5aq28__4 ag_live_chg_4
		rename			s5aq28__5 ag_live_chg_5
		rename			s5aq28__6 ag_live_chg_6
		rename			s5aq28__7 ag_live_chg_7
		rename			s5aq29 ag_live_loc
		rename			s5aq30 harv_sell_need
* save panel
	* gen wave data
		rename			wfinal phw_cs
		lab var			phw "sampling weights - cross section"
		gen				wave = `w'
		lab var			wave "Wave number"
		order			baseline_hhid wave phw, after(HHID)	
	
	* save file
		save			"$export/wave_0`w'/r`w'", replace

/* END */
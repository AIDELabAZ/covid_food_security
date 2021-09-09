* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by : amf
* Last edited: December 2020
* Stata v.16.1

* does
	* reads in third round of Uganda data
	* builds round 3
	* outputs round 3

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
	local			w = 3
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	

* ***********************************************************************
* 1 - reshape section 6 wide data
* ***********************************************************************

* load income data
	use				"$root/wave_0`w'/SEC6", clear

* reformat HHID
	format 			%12.0f HHID

* replace value for "other"
	replace			income_loss__id = 96 if income_loss__id == -96

* reshape data
	reshape 		wide s6q01 s6q02, i(HHID) j(income_loss__id)

* save temp file
	tempfile		temp1
	save			`temp1'


* ***********************************************************************
* 2 - reshape section 10 wide data 
* ***********************************************************************

* load safety net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/SEC10", clear

* reformat HHID
	format 			%12.0f HHID

* drop other safety nets and missing values
	drop			s10q02 s10q03__1 s10q03__2 s10q03__3 s10q03__4 ///
						s10q03__5 s10q03__6 s10q03__n96 s10q05 s10q06__1 ///
						s10q06__2 s10q06__3 s10q06__4 s10q06__6 s10q06__7 ///
						s10q06__8 s10q06__n96 other_nets 

* reshape data
	reshape 		wide s10q01, i(HHID) j(safety_net__id)
	*** note that cash = 102, food = 101, in-kind = 103 (unlike wave 1)

* rename variables
	gen				asst_food = 1 if s10q01101 == 1
	replace			asst_food = 0 if s10q01101 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s10q01102 == 1
	replace			asst_cash = 0 if s10q01102 == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s10q01103 == 1
	replace			asst_kind = 0 if s10q01103 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
					asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s10q01101 s10q01102 s10q01103
	
* save temp file
	tempfile		temp2
	save			`temp2'


* ***********************************************************************
* 3 - get respondant gender
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
	tempfile		temp3
	save			`temp3'

	
* ***********************************************************************
* 4 - get household size and gender of HOH
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
	replace 		new_mem = 0 if new_mem >= .
	replace 		new_mem = 0 if s1q08 == 10
	replace 		s1q08 = . if s1q08 == 10
	replace 		curr_mem = 2 if curr_mem >= .
	gen 			mem_left = 1 if curr_mem == 2
	replace 		new_mem = 0 if new_mem == 2
	replace 		mem_left = 0 if mem_left == 2
	
	* why member left
		* no observations
	
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
	ds 			new_mem_why_* 
	foreach		var in `r(varlist)' {
		replace 	`var' = 0 if `var' >= . & new_mem == 1
	}
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"
	lab var 	mem_left "Member of household left since last call"
	lab var 	new_mem "Member of household joined since last call"

* save temp file
	tempfile		temp4
	save			`temp4'

	
* ***********************************************************************
* 5 - livestock
* ***********************************************************************

* load data		
	use 			"$root/wave_0`w'/SEC5D.dta", clear

* rename vars to match r2
	forval 			x = 1/6 {
		rename 		s5cq14__`x' s5cq14_1__`x'
		rename 		s5cq14a__`x' s5cq14_2__`x'
	}
	
* reshape wide
	gen 			product = cond(livestock == -96, "other", cond(livestock == 1, ///
					"milk",cond(livestock == 2, "eggs","meat")))
	drop 			livestock
	reshape 		wide s5cq*, i(HHID) j(product) string

* save temp file part 1
	tempfile		templs1
	save			`templs1'
	
* load data		
	use 			"$root/wave_0`w'/SEC5D.dta", clear

* reshape wide
	keep 			livestock HHID
	gen 			product = cond(livestock == -96, "other", cond(livestock == 1, ///
					"milk",cond(livestock == 2, "eggs","meat")))
	reshape 		wide livestock, i(HHID) j(product) string
	collapse 		(sum) livestock*, by (HHID)
	replace 		livestock_products__ideggs = 1 if livestock_products__ideggs != 0
	replace 		livestock_products__idmeat = 1 if livestock_products__idmeat != 0
	replace 		livestock_products__idmilk = 1 if livestock_products__idmilk != 0	
	
* save temp file
	merge			1:1 HHID using `templs1', nogen
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
* 7 - credit
* ***********************************************************************	

* load data since last interview
	use 			"$root/wave_0`w'/SEC7A_2.dta", clear	
 
* reshape wide
	reshape 		wide s7aq*, i(HHID) j(loan_roster)
	rename 			*101 *_l1
	rename 			*102 *_l2
	drop 			*96*
 
* save temp file
	tempfile		temp7
	save			`temp7'
	
* load data since march	
	use 			"$root/wave_0`w'/SEC7B_2.dta", clear

* reshape wide
	reshape 		wide s7bq*, i(HHID) j(loan_roster)
	rename 			*201 *_l1
	rename 			*202 *_l2
	drop 			*96*
	
* save temp file
	tempfile		temp8
	save			`temp8'
	
* load data before march	
	use 			"$root/wave_0`w'/SEC7C_2.dta", clear
	
* reshape wide
	reshape 		wide s7cq*, i(HHID) j(loan_roster)
	rename 			*301 *_l1
	rename 			*302 *_l2
	drop 			*96*
	
* save temp file
	tempfile		temp9
	save			`temp9'
	
	
* ***********************************************************************
* 8 - education 
* ***********************************************************************
 
* generate edu_act = 1 if any child engaged in learning activities
	use				"$root/wave_0`w'/SEC1.dta", clear
	keep 			if s1q09 == 1
	replace 		s1q10 = 0 if s1q10 == 2
	collapse		(sum) s1q10, by(HHID)
	gen 			edu_act = 1 if s1q10 > 0 
	replace 		edu_act = 0 if edu_act == .
	keep 			HHID edu_act
	tempfile 		tempany
	save 			`tempany'

* rename other variables 
	* edu_act_why
	use				"$root/wave_0`w'/SEC1.dta", clear
	keep 			if s1q10 == 2
	keep 			HHID hh_roster__id s1q11__* 
	forval 			x = 1/11 {
	    replace 	s1q11__`x' = 0 if s1q11__`x' == 2
	    rename 		s1q11__`x' edu_act_why_`x'
	}
	drop 			*__n96
	collapse 		(sum) edu_act*, by(HHID)	
	forval 			x = 1/11 {
	    replace 	edu_act_why_`x' = 1 if edu_act_why_`x' >= 1
	}
	tempfile 		tempactwhy
	save 			`tempactwhy'
	
	* edu_chal
	use				"$root/wave_0`w'/SEC1.dta", clear
	keep 			if s1q10 == 1
	keep 			HHID hh_roster__id s1q13__*
	forval 			x = 1/13 {
	    replace 	s1q13__`x' = 0 if s1q13__`x' == 2
	    rename 		s1q13__`x' edu_chal_`x'
	}
	drop 			*__n96
	collapse 		(sum) edu_chal*, by(HHID)
	forval 			x = 1/13 {
	    replace 	edu_chal_`x' = 1 if edu_chal_`x' >= 1
	}
	tempfile 		tempchal
	save 			`tempchal'
	
* generate educational engagement type variables  
	use				"$root/wave_0`w'/SEC1.dta", clear
	keep 			if s1q10 == 1
	forval 			x = 1/11 {
		replace 	s1q12__`x' = 0 if s1q12__`x' == 2
	}
	collapse 		(sum) s1q12*, by(HHID)
	forval 			x = 1/11 {
		replace 	s1q12__`x' = 1 if s1q12__`x' > 1
	}
	replace 		s1q12__n96 = 1 if s1q12__n96 > 1
	forval 			x = 1/5 {
		rename 		s1q12__`x' edu_`x'
	}
	rename			s1q12__6 edu_8 
	rename 			s1q12__7 edu_9 
	lab var 		edu_9 "Private tutor"
	rename	 		s1q12__8 edu_10
	lab var 		edu_10 "Home school"
	rename	 		s1q12__9 edu_11
	lab var 		edu_11 "Revisions of textbooks/notes from past classes"
	rename	 		s1q12__10 edu_12 
	lab var 		edu_12 "Newspaper"
	rename	 		s1q12__11 edu_7
	rename 	 		s1q12__n96 edu_other

* merge data together 
	merge 			1:1 HHID using `tempany', nogen
	merge 			1:1 HHID using `tempactwhy', nogen
	merge 			1:1 HHID using `tempchal', nogen

* save temp file
	tempfile		temp10
	save			`temp10'

		
* ***********************************************************************
* 9 - build uganda cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/Cover", clear
	
* merge in other sections	
	forval 			x = 1/10 {
	    merge 		1:1 HHID using `temp`x'', nogen
	}
	merge 1:1 		HHID using "$root/wave_0`w'/SEC2.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC3.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC4.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5A.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5B.dta", nogen 
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5C.dta", nogen 
	merge 1:1 		HHID using "$root/wave_0`w'/SEC7A_1.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC7B_1.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC7C_1.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC8.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC9.dta", nogen	
	
* reformat HHID
	format 			%12.0f HHID

* rename variables inconsistent with other waves
	* rename govt actions 
		rename 			s2gq01 cvd_lockdwn
		rename 			s2gq02 cvd_sch
		rename 			s2gq03 cvd_church
		rename 			s2gq05 mask 
	* rename behavioral changes
		rename			s3q01 bh_1
		rename			s3q02 bh_2
		rename			s3q03 bh_3
		rename			s3q04 bh_4
		rename			s3q05 bh_5
		rename			s3q06 bh_freq_wash
		rename			s3q07 bh_freq_mask
		rename			s3q07_1 bh_freq_mask_oth
		rename 			s3q08 bh_freq_gath
	* rename employment
		rename			s5q01 emp
		rename			s5q01a rtrn_emp
		rename			s5q01b rtrn_emp_when
		rename			s5q01c emp_why
		rename 			s5q03 emp_pre_why
		rename			s5q03a emp_search
		rename			s5q03b emp_search_how
		rename			s5q04a_1 emp_same
		rename			s5q04b emp_chg_why
		rename			s5q05 emp_act
		rename			s5q06 emp_stat
		rename			s5q07 emp_able
		rename			s5q08 emp_unable
		rename			s5q08a emp_unable_why
		rename			s5q08b emp_hrs
		rename			s5q08c emp_hrs_chg
		rename			s5q08f_* emp_saf*
		rename 			emp_saf_n96 emp_saf_96	
		rename 			s5q08g emp_saf_fol
		rename 			s5q08g_1 emp_saf_fol_per
		rename			s5q09 emp_hh
	* non-farm income
		rename			s5aq11 bus_emp
		* reshape reason bus closed to match other rounds 
			gen 			temp = s5aq11b
			replace 		s5aq11b = 1 if s5aq11b != .
			lab def			yes 1 "Yes" 
			lab val			s5aq11b yes
			replace 		temp = 0 if temp == . | temp == -96
			reshape 		wide s5aq11b, i(HHID) j(temp)
			rename 			s5aq11b* s5aq11b_* 
		rename			s5aq11a bus_stat
		rename 			s5aq11b_* s5aq11b__* // to match other round, guessing the coding is the same but cannot confirm
		rename			s5aq12 bus_sect
		rename			s5aq13 bus_emp_inc
		rename			s5aq14_1 bus_why	
		rename 			s5q15a bus_other
		rename 			s5q15b bus_num
	* rename food security
		rename			s8q01 fies_4
		lab var			fies_4 "Worried about not having enough food to eat"
		rename			s8q02 fies_5
		lab var			fies_5 "Unable to eat healthy and nutritious/preferred foods"
		rename			s8q03 fies_6
		lab var			fies_6 "Ate only a few kinds of food"
		rename			s8q04 fies_7
		lab var			fies_7 "Skipped a meal"
		rename			s8q05 fies_8
		lab var			fies_8 "Ate less than you thought you should"
		rename			s8q06 fies_1
		lab var			fies_1 "Ran out of food"
		rename			s8q07 fies_2
		lab var			fies_2 "Hungry but did not eat"
		rename			s8q08 fies_3
		lab var			fies_3 "Went without eating for a whole day"	
	* rename concerns
		rename			s9q01 concern_1
		rename			s9q02 concern_2
		gen				have_symp = 1 if s9q03__1 == 1 | s9q03__2 == 1 | s9q03__3 == 1 | ///
							s9q03__4 == 1 | s9q03__5 == 1 | s9q03__6 == 1 | ///
							s9q03__7 == 1 | s9q03__8 == 1
		replace			have_symp = 2 if have_symp == .
		lab var			have_symp "Has anyone in your hh experienced covid symptoms?:cough/shortness of breath etc."
		order			have_symp, after(concern_2)
		rename 			s9q04 have_test
		rename 			s9q05 concern_3
		rename			s9q06 concern_4
		lab var			concern_4 "Response to the COVID-19 emergency will limit my rights and freedoms"
		rename			s9q07 concern_5
		lab var			concern_5 "Money and supplies allocated for the COVID-19 response will be misused and captured by powerful people in the country"
		rename			s9q08 concern_6
		lab var			concern_6 "Corruption in the government has lowered the quality of medical supplies and care"
		rename			s9q09 concern_7
	* rename agriculture
		rename 			s5cq01 ag_live
		rename			s5bq16 ag_crop
		rename 			s5bq18_1 ag_crop_1
		rename 			s5bq18_2 ag_crop_2
		rename 			s5bq18_3 ag_crop_3
		rename 			s5bq19 ag_expect
		rename 			s5bq20 ag_quant
		rename 			s5bq20b ag_quant_unit
		rename 			s5bq20c ag_quant_kgcon
		rename 			s5bq21_1 ag_pr_ban_s
		rename 			s5bq21_2 ag_pr_ban_m
		rename 			s5bq21_3 ag_pr_ban_l
		rename 			s5bq21_4 ag_pr_cass_bag
		rename 			s5bq21_5 ag_pr_cass_chip
		replace 		ag_pr_cass_chip = "" if ag_pr_cass_chip == "##N/A##" | ///
							ag_pr_cass_chip == "-98"
		replace 		ag_pr_cass_chip = subinstr(ag_pr_cass_chip,",", "",.)
		destring 		ag_pr_cass_chip, replace
		rename 			s5bq21_6 ag_pr_cass_flr
		rename 			s5bq21_7 ag_pr_bean_dry
		rename 			s5bq21_9 ag_pr_bean_fr
		rename 			s5bq21_8 ag_pr_maize
		rename 			s5bq23 ag_sell_norm
		rename 			s5bq24 ag_sell_rev_exp
		
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
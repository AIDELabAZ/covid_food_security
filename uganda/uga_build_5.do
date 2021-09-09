* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by : amf
* Last edited: December 2020
* Stata v.16.1

* does
	* reads in fifth round of Uganda data
	* builds round 5
	* outputs round 5

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
	local			w = 5
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	

* ***********************************************************************
* 1 - reshape section 6 wide data
* ***********************************************************************

* load income data
	use				"$root/wave_0`w'/sec6", clear
	
* reformat HHID
	format 			%12.0f hhid

* replace value for "other"
	replace			income_loss__id = 96 if income_loss__id == -96

* reshape data
	reshape 		wide s6q01 s6q02 s6q03, i(hhid) j(income_loss__id)

* save temp file
	tempfile		temp1
	save			`temp1'


* ***********************************************************************
* 2 - reshape section 10 wide data 
* ***********************************************************************

* load safety net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/sec10", clear

* reformat HHID
	format 			%12.0f hhid

* drop other safety nets and missing values
	drop			s10q02 s10q03__1 s10q03__2 s10q03__3 s10q03__4 ///
						s10q03__5 s10q03__6 s10q03__n96 

* reshape data
	reshape 		wide s10q01, i(hhid) j(safety_net__id)
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
	replace 		asst_cash = 1 if s10q01104 == 1
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
	drop			s10q01101 s10q01102 s10q01103 s10q01104

* save temp file
	tempfile		temp2
	save			`temp2'


* ***********************************************************************
* 3 - get respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/interview_result", clear

* drop all but household respondant
	keep			hhid Rq09

	rename			Rq09 hh_roster__id

	isid			hhid

* merge in household roster
	merge 1:1		hhid hh_roster__id using "$root/wave_0`w'/sec1.dta"

	keep if			_merge == 3

* rename variables and fill in missing values
	rename			hh_roster__id PID
	rename			s1q05 sex
	rename			s1q06 age
	rename			s1q07 relate_hoh
	drop if			PID == .

* drop all but gender and relation to HoH
	keep			hhid PID sex age relate_hoh

* save temp file
	tempfile		temp3
	save			`temp3'

	
* ***********************************************************************
* 4 - get household size and gender of HOH
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/sec1.dta", clear

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
			keep 		hhid s1q08 ind_id
			keep 		if s1q08 < .
			duplicates 	drop hhid s1q08, force
			replace 	s1q08 = 96 if s1q08 == -96
			reshape 	wide ind_id, i(hhid) j(s1q08)
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
				(max) sexhh, by(hhid)
	replace 	new_mem = 1 if new_mem > 0 & new_mem < .
	replace 	mem_left = 1 if mem_left > 0 & new_mem < .	
	merge 		1:1 hhid using `new_mem', nogen
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
* 5 - FIES
* ***********************************************************************

* load data
	use				"$fies/UG_FIES_round`w'.dta", clear

	drop 			country round
	destring 		HHID, replace

* save temp file
	tempfile		temp5
	save			`temp5'

	
* ***********************************************************************
* 6 - education 
* ***********************************************************************
	
* generate edu_act = 1 if any child engaged in learning activities
	use				"$root/wave_0`w'/sec1c.dta", clear
	keep 			if s1cq09 != .
	replace 		s1cq09  = 0 if s1cq09  == 2
	collapse		(sum) s1cq09, by(hhid)
	gen 			edu_act = 1 if s1cq09 > 0 
	replace 		edu_act = 0 if edu_act == .
	keep 			hhid edu_act
	tempfile 		tempany
	save 			`tempany'

* rename other variables 	
	* edu_act_why
	use				"$root/wave_0`w'/sec1c.dta", clear
	keep 			if s1cq09 == 2
	forval 			x = 1/11 {
		rename 		s1cq10__`x' edu_act_why_`x'
	}
	collapse 		(sum) edu* , by(hhid)
	forval 			x = 1/11 {
		replace 		edu_act_why_`x' = 1 if edu_act_why_`x' >= 1
	}
	tempfile 		tempactwhy
	save 			`tempactwhy'
		
	* edu & edu_chal
	use				"$root/wave_0`w'/sec1c.dta", clear
	keep 			if s1cq09 == 1
	rename 			s1cq11__1 edu_1
	rename 			s1cq11__2 edu_2
	replace 		edu_2 = 1 if s1cq11__3 == 1 | s1cq11__4 == 1 | ///
						s1cq11__5 == 1 | s1cq11__6 == 1
	rename 			s1cq11__7 edu_3
	rename 			s1cq11__8 edu_4
	rename 			s1cq11__9 edu_5
	rename 			s1cq11__10 edu_8
	rename 			s1cq11__11 edu_9
	rename 			s1cq11__12 edu_10
	rename 			s1cq11__13 edu_11
	rename 			s1cq11__14 edu_12
	rename 			s1cq11__15 edu_7
	rename 	 		s1cq11__n96 edu_other
	forval 			x = 1/13 {
	    replace 	s1cq12__`x' = 0 if s1cq12__`x' == 2
	    rename 		s1cq12__`x' edu_chal_`x'
	}
	collapse 		(sum) edu* , by(hhid)
	ds edu* 
	foreach 		var in `r(varlist)' {
	    replace 		`var' = 1 if `var' >= 1
	}
	tempfile 		tempedu
	save 			`tempedu'
	
* merge data together 
	use				"$root/wave_0`w'/sec1c.dta", clear
	keep 			hhid 
	duplicates 		drop
	merge 			1:1 hhid using `tempany', nogen
	merge 			1:1 hhid using `tempactwhy', nogen
	merge 			1:1 hhid using `tempedu', nogen

* save temp file
	tempfile		temp5
	save			`temp5'

	
* ***********************************************************************
* 7 - livestock
* ***********************************************************************

* load  data
	use				"$root/wave_0`w'/sec5d.dta", clear
	drop 			if s5dq12 == 2
	drop 			s5dq12 	

* rename vars 
	forval 			x = 1/5 {
		rename 		s5dq14_1__`x' s5cq14_2__`x'
		rename 		s5dq14__`x' s5cq14_1__`x'
	}
	rename 			s5dq14_1__6 s5cq14_2__6
	rename 			s5d* s5c* 
	
* reshape wide
	gen 			product = cond(livestock == -96, "other", cond(livestock == 1, ///
					"milk",cond(livestock == 2, "eggs","meat")))
	drop 			livestock
	reshape 		wide s5cq*, i(hhid) j(product) string

* save temp file part 1
	tempfile		templs1
	save			`templs1'
	
* load data		
	use 			"$root/wave_0`w'/sec5d.dta", clear
	drop 			if s5dq12 == 2
	drop 			s5dq12 	

* reshape wide
	keep 			livestock hhid
	gen 			product = cond(livestock == -96, "other", cond(livestock == 1, ///
					"milk",cond(livestock == 2, "eggs","meat")))
	reshape 		wide livestock, i(hhid) j(product) string
	collapse 		(sum) livestock*, by (hhid)
	replace 		livestock_products__ideggs = 1 if livestock_products__ideggs != 0
	replace 		livestock_products__idmeat = 1 if livestock_products__idmeat != 0
	replace 		livestock_products__idmilk = 1 if livestock_products__idmilk != 0	

* save temp file
	merge			1:1 hhid using `templs1', nogen
	tempfile		temp6
	save			`temp6'
	
	
* ***********************************************************************
* 8 - build uganda cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/Cover", clear
	
* merge in other sections	
	forval 			x = 1/6 {
	    merge 		1:1 hhid using `temp`x'', nogen
	}
	merge 1:1 		hhid using"$root/wave_0`w'/sec1d.dta", nogen
	merge 1:1 		hhid using"$root/wave_0`w'/sec1e.dta", nogen
	merge 1:1 		hhid using"$root/wave_0`w'/sec1f.dta", nogen
	merge 1:1 		hhid using "$root/wave_0`w'/SEC3.dta", nogen
	merge 1:1 		hhid using "$root/wave_0`w'/SEC4.dta", nogen
	merge 1:1 		hhid using "$root/wave_0`w'/SEC4A.dta", nogen
	merge 1:1 		hhid using "$root/wave_0`w'/SEC5.dta", nogen
	merge 1:1 		hhid using "$root/wave_0`w'/SEC5A.dta", nogen
	merge 1:1 		hhid using "$root/wave_0`w'/SEC5B.dta", nogen 
	merge 1:1 		hhid using "$root/wave_0`w'/SEC8.dta", nogen
	merge 1:1 		hhid using "$root/wave_0`w'/SEC9.dta", nogen	
	
* reformat HHID
	format 			%12.0f hhid

* rename variables inconsistent with other waves
	* rename behavioral changes
		rename			s3q01 bh_1
		rename			s3q02 bh_2
		rename			s3q03 bh_3
		rename			s3q04 bh_4
		rename			s3q05 bh_5
		rename			s3q06 bh_freq_wash
		rename			s3q07_1 bh_freq_mask_oth
		rename			s3q07_2 mask
		rename 			s3q08 bh_freq_gath	
	* vaccines	
		rename 			s4q15 cov_test_pay
		rename 			s4q15_1 cov_test_pay_amnt
		rename 			s4q16 cov_vac
		rename 			s4q17__1 cov_vac_no_why_1
		rename 			s4q17__2 cov_vac_no_why_2
		rename 			s4q17__3 cov_vac_no_why_3
		rename 			s4q17__4 cov_vac_no_why_6
		rename 			s4q17__5 cov_vac_no_why_4
		rename 			s4q17__6 cov_vac_no_why_5			
		rename 			s4q18__1 cov_vac_dk_why_1
		rename 			s4q18__2 cov_vac_dk_why_2
		rename 			s4q18__3 cov_vac_dk_why_3
		rename 			s4q18__4 cov_vac_dk_why_6
		rename 			s4q18__5 cov_vac_dk_why_4
		rename 			s4q18__6 cov_vac_dk_why_5
	* rename employment
		rename			s5q01 emp
		rename			s5q01a rtrn_emp
		rename			s5q01b rtrn_emp_when
		rename			s5q01c emp_why
		rename 			s5q03 emp_pre_why
		rename			s5q03a emp_search
		rename			s5q03b emp_search_how
		rename			s5q04a emp_same
		rename			s5q04b emp_chg_why
		rename			s5q05 emp_act
		rename			s5q06 emp_stat
		replace 		emp_stat = 6 if emp_stat == 5
		rename 			s5q06a emp_purp
	* non-farm income
		rename			s5aq11 bus_emp
		rename			s5aq11a bus_stat
		rename 			s5aq11b_1 bus_other
		rename			s5aq12 bus_sect
		rename			s5aq12_1 bus_sect_oth
		rename			s5aq13 bus_emp_inc
		rename			s5aq14_1 bus_why
	* rename agriculture
		rename			s5bq16 ag_crop
		rename 			s5bq18_1 ag_crop_1
		rename 			s5bq18_2 ag_crop_2
		rename 			s5bq18_3 ag_crop_3
		rename 			s5bq19 ag_chg
		rename			s5bq20__1 ag_chg_1
		rename			s5bq20__2 ag_chg_2
		rename			s5bq20__3 ag_chg_3
		rename			s5bq20__4 ag_chg_4
		rename			s5bq20__5 ag_chg_5
		rename			s5bq20__6 ag_chg_6
		rename			s5bq20__7 ag_chg_7
		rename			s5bq21__1 ag_covid_1
		rename			s5bq21__3 ag_covid_3
		rename			s5bq21__4 ag_covid_4
		rename			s5bq21__5 ag_covid_5
		rename			s5bq21__6 ag_covid_6
		rename			s5bq21__7 ag_covid_7
		rename			s5bq21__8 ag_covid_8
		rename			s5bq21__9 ag_covid_9
		rename 			s5bq21a ag_main
		rename 			s5bq21b ag_main_plant_comp
		rename 			s5bq21c ag_main_area
		rename 			s5bq21d ag_expect
		rename 			s5bq23 ag_sell_norm
		rename 			s5bq24 ag_sell_rev_exp 
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
		rename 			s9q03a have_cov_oth
		rename 			s9q03b have_cov_self
		gen				have_symp = 1 if s9q03__1 == 1 | s9q03__2 == 1 | s9q03__3 == 1 | ///
							s9q03__4 == 1 | s9q03__5 == 1 | s9q03__6 == 1 | ///
							s9q03__7 == 1 | s9q03__8 == 1
		replace			have_symp = 2 if have_symp == .
		order			have_symp, after(concern_2)	
		rename 			s9q04 have_test
		rename 			s9q05 concern_3
		rename			s9q06 concern_4
		rename			s9q07 concern_5
		rename			s9q08 concern_6
		rename			s9q09 concern_7
	* rename mental health
		forval 			x = 1/8 {
			rename 			s9q10_`x' mh_`x'
		}	
		
* save panel		
	* gen wave data
		rename			wfinal phw_cs
		lab var			phw "sampling weights - cross section"	
		gen				wave = `w'
		lab var			wave "Wave number"
		order			baseline_hhid wave phw, after(hhid)
		rename 			hhid HHID
		
	* save file
		save			"$export/wave_0`w'/r`w'", replace

/* END */	
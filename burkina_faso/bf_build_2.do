* Project: WB COVID
* Created on: April 2021
* Created by: amf
* Edited by: amf
* Last edit: April 2021 
* Stata v.16.1

* does
	* reads in second round of BF data
	* builds round 2
	* outputs round 2

* assumes
	* raw BF data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/burkina_faso/raw"
	global	export	=	"$data/burkina_faso/refined"
	global	logout	=	"$data/burkina_faso/logs"
	global  fies 	= 	"$data/analysis/raw/Burkina_Faso"

* open log
	cap log 		close
	log using		"$logout/bf_build", append

* set local wave number & file number
	local			w = 2
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir 	"$export/wave_0`w'" 

	
* ***********************************************************************
* 1a - get respondent data
* ***********************************************************************	

* load respondant id data	
	use 			"$root/wave_0`w'/r`w'_sec1a_info_entretien_tentative", clear
	keep 			if s01aq08 == 1
	rename 			s01aq09 membres__id
	duplicates 		drop hhid membres__id, force
	duplicates		tag hhid, gen(dups)
	replace 		membres__id = -96 if dups > 0
	duplicates 		drop hhid membres__id, force
	lab def 		mem -96 "multiple respondents"
	lab val 		membres__id mem
	keep 			hhid membres__id

* load roster data with gender
	merge 1:1		hhid membres__id using "$root/wave_0`w'/r`w'_sec2_liste_membre_menage"
	keep 			if _m == 1 | _m == 3
	keep 			hhid s02q05 membres__id s02q07 s02q06
	rename 			membres__id resp_id
	rename 			s02q05 sex
	rename 			s02q06 age
	rename 			s02q07 relate_hoh

* save temp file
	tempfile		tempa
	save			`tempa'
	

* ***********************************************************************
* 1b - get household size and gender of HOH
* ***********************************************************************	

* load roster data	
	use 			"$root/wave_0`w'/r`w'_sec2_liste_membre_menage", clear
	
* rename other variables 
	rename 			membres__id ind_id 
	rename 			s02q03 curr_mem
	replace 		curr_mem = 1 if s02q02 == 1
	rename 			s02q05 sex_mem
	rename 			s02q06 age_mem
	rename 			s02q07 relat_mem
	
* generate counting variables
	gen				hhsize = 1 if curr_mem == 1
	gen 			hhsize_adult = 1 if curr_mem == 1 & age_mem > 18 & age_mem < .
	gen				hhsize_child = 1 if curr_mem == 1 & age_mem < 19 & age_mem != . 
	gen 			hhsize_schchild = 1 if curr_mem == 1 & age_mem > 4 & age_mem < 19 
	
* generate hh head gender variable
	gen 			sexhh = .
	replace 		sexhh = sex_mem if relat_mem== 1
	lab var 		sexhh "Sex of household head"
	
* generate migration vars
	rename 			s02q02 new_mem
	replace 		new_mem = 0 if s02q08 == 10
	replace 		s02q08 = . if s02q08 == 10
	gen 			mem_left = 1 if curr_mem == 2
	replace 		new_mem = 0 if new_mem == 2
	replace 		mem_left = 0 if mem_left == 2
	
	replace 		s02q04 = 123 if s02q04 == 2
	replace 		s02q04 = 2 if s02q04 == 3
	replace 		s02q04 = 3 if s02q04 == 123
		
	* why member left
		preserve
			keep 		hhid s02q04 ind_id
			keep 		if s02q04 != .
			duplicates 	drop hhid s02q04, force
			reshape 	wide ind_id, i(hhid) j(s02q04)
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
			keep 		hhid s02q08 ind_id
			keep 		if s02q08 != .
			duplicates 	drop hhid s02q08, force
			reshape 	wide ind_id, i(hhid) j(s02q08)
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
	merge 		1:1 hhid using `mem_left', nogen
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
	tempfile		tempb
	save			`tempb'
	
	
* ***********************************************************************
*  2 - shocks
* ***********************************************************************		

* load data
	use 			"$root/wave_0`w'/r`w'_sec9_Chocs", clear

* drop other shock
	drop			s09q03_autre
	
* generate shock variables
	forval 			x = 1/13 {
		gen 		shock_`x' = s09q01 if chocs__id == `x'
	}

* collapse to household level	
	collapse 		(max) s09q03__1-shock_13, by(hhid)
	
* save temp file
	tempfile		tempc
	save			`tempc'	
	

* ***********************************************************************
*  3 - FIES
* ***********************************************************************	

* load data
	use 			"$fies/BFA_FIES_round`w'", clear
	
* format hhid & vars
	destring 		HHID, gen(hhid)
	drop 			country round HHID
	
* save temp file
	tempfile		tempd
	save			`tempd'	
	
	
* ***********************************************************************
*  4 - merge
* ***********************************************************************

* load cover data
	use 		"$root/wave_0`w'/r`w'_sec0_cover", clear
	
* merge formatted sections
	foreach 		x in a b c d {
	    merge 		1:1 hhid using `temp`x'', nogen
	}

* merge in other sections
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec5_acces_service_base", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6a_emplrev_general", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6b_emplrev_travailsalarie", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6c_emplrev_nonagr", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6d_emplrev_agr", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6e_emplrev_transferts", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec7_securite_alimentaire", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec11_frag_confl_violence", nogen

* clean variables inconsistent with other rounds
	* ac_med
	rename 			s05q01a ac_med	
	replace 		ac_med = 1 if ac_med == 2 | ac_med == 3
	replace 		ac_med = 2 if ac_med == 4
	replace 		ac_med = 3 if ac_med == 5
	
	rename 			s05q03e ac_medserv_why
	replace 		ac_medserv_why = . if ac_medserv_why == 4
	rename 			s05q03d ac_medserv_oth
	
	* employment 
	rename 			s06q05a emp_chg_why
	drop 			s06q05a_autre 
	replace 		emp_chg_why = 96 if emp_chg_why == 13
	
	* farming
	rename 			s06q16__1 farm_why_1
	rename 			s06q16__2 farm_why_2
	rename 			s06q16__3 farm_why_3
	rename 			s06q16__4 farm_why_4
	replace 		farm_why_4 = 1 if s06q16__6 == 1
	rename 			s06q16__7 farm_why_5
	rename 			s06q16__8 farm_why_6
	rename 			s06q16__9 farm_why_8
	rename 			s06q16__11 farm_why_7
	drop 			s06q16__6 s06q16__10 s06q16_autre
	rename 			s06q14 farm_emp
	
	* asst
	rename 			s06q23 asst_any
	rename 			s06q24 asst_amt
	rename 			s06q25 asst_freq
	drop			s06q26
	
	* education 
	rename 			s05q05 sch_child
	rename 			s05q06__1 edu_1
	replace 		edu_1 = 1 if s05q06__7 == 1	
	rename 			s05q06__2 edu_other 
	replace 		edu_other = 1 if s05q06__8 == 1
	rename 			s05q06__3 edu_13
	rename 			s05q06__4 edu_14
	rename 			s05q06__5 edu_2
	rename 			s05q06__6 edu_3
	rename 			s05q06__9 edu_15
	rename 			s05q06__10 edu_4
	rename 			s05q06__11 edu_16
	rename 			s05q06__12 edu_9
	rename 			s05q06__13 edu_7
	rename 			s05q06__15 edu_17	
	gen 			edu_act = 1 if s05q06__14 == 0
	replace 		edu_act = 0 if s05q06__14 == 1	
	drop 			s05q06__7 s05q06__8 s05q06__14 	
	rename 			s05q07 edu_cont	
	forval 			x = 1/8 {
		rename 		s05q08__`x' edu_cont_`x'
	}
	drop 			s05q08__9 s05q08_autre
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			hhwcovid_r`w'_s1s2 phw_cs
	rename 			hhwcovid_r`w'_s1 phw_pnl
	label var		phw_cs "sampling weights- cross section"
	label var		phw_pnl "sampling weights- panel"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		
* Project: WB COVID
* Created on: April 2021
* Created by: amf
* Edited by: amf
* Last edit: April 2021 
* Stata v.16.1

* does
	* reads in third round of BF data
	* builds round 3
	* outputs round 3

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
	local			w = 3
	
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
* 2 - other revenues
* ***********************************************************************		
	
* load data	
	use 		"$root/wave_0`w'/r`w'_sec8_autres_revenu",clear
	
* drop other vars
	keep 		hhid revenu__id s08q0*
	
* reshape 
	reshape 	wide s08q0*, i(hhid) j(revenu__id)
	
* format vars
	rename 		s08q011 oth_inc_1
	rename 		s08q012 oth_inc_2
	rename 		s08q013 oth_inc_3
	rename 		s08q014 oth_inc_4
	rename 		s08q015 oth_inc_5
	
	rename 		s08q021 oth_inc_chg_1
	rename 		s08q022 oth_inc_chg_2
	rename 		s08q023 oth_inc_chg_3
	rename 		s08q024 oth_inc_chg_4
	rename 		s08q025 oth_inc_chg_5
	
* save temp file
	tempfile		tempc
	save			`tempc'
	
	
* ***********************************************************************
* 3 - assistance
* ***********************************************************************	

* load data	
	use 		"$root/wave_0`w'/r`w'_sec10_protection_sociale", clear
	
* drop other vars
	keep 		hhid assistance__id s10q01
	
* reshape 
	reshape 	wide s10q01, i(hhid) j(assistance__id)

* format vars
	rename 		s10q01101 asst_food
	rename 		s10q01102 asst_cash
	rename 		s10q01103 asst_kind
	
	replace 	asst_food = 0 if asst_food == 2
	replace 	asst_cash = 0 if asst_cash == 2
	replace 	asst_kind = 0 if asst_kind == 2
	
	gen				asst_any = 0 if asst_food == 0 | asst_cash == 0 | ///
						asst_kind == 0
	replace 		asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1

* save temp file
	tempfile		tempd
	save			`tempd'
	

* ***********************************************************************
*  4 - FIES
* ***********************************************************************	

* load data
	use 			"$fies/BF_FIES_round`w'", clear
	
* format hhid & vars
	destring 		HHID, gen(hhid)
	drop 			country round HHID
	
* save temp file
	tempfile		tempe
	save			`tempe'	
	

* ***********************************************************************
*  5 - merge
* ***********************************************************************

* load cover data
	use 		"$root/wave_0`w'/r`w'_sec0_cover", clear
	
* merge formatted sections
	foreach 		x in a b c d e {
	    merge 		1:1 hhid using `temp`x'', nogen
	}

* merge in other sections
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec3_connaisance_covid19", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec4_comportaments", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec5_acces_service_base", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6a_emplrev_general", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6b_emplrev_travailsalarie", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6c_emplrev_nonagr", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6d_emplrev_agr", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec7_securite_alimentaire", nogen

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
	rename 			s06q04_0 emp_chg_why
	replace 		emp_chg_why = 96 if emp_chg_why == 13
	
	* agriculture
	rename 			s06q23 ag_crop_lost
	rename 			s06q24 ag_live
	rename 			s06q25 ag_live_chg
	forval 			x = 1/7 {
		rename 		s06q26__`x' ag_live_chg_`x'
	}
	rename 			s06q27 ag_live_loc
	rename 			s06q14 ag_crop
	
* drop 55 variables re main type of crop grown
	drop 			s06q16_*
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			hhwcovid_r`w'_cs phw_cs
	rename 			hhwcovid_r`w'_pnl phw_pnl
	label var		phw_cs "sampling weights- cross section"
	label var		phw_pnl "sampling weights- panel"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		
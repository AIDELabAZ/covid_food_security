* Project: WB COVID
* Created on: Aug 2021
* Created by: amf
* Edited by: amf
* Last edit: Aug 2021 
* Stata v.16.1

* does
	* reads in tenth round of BF data
	* builds round 10
	* outputs round 10

* assumes
	* raw BF data

* TO DO:
	* GET FIES DATA
	
	
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
	local			w = 10
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir 	"$export/wave_`w'" 


* ***********************************************************************
* 1a - get respondent data
* ***********************************************************************	

* load respondant id data	
	use 			"$root/wave_`w'/r`w'_sec1a_info_entretien_tentative", clear
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
	merge 1:1		hhid membres__id using "$root/wave_`w'/r`w'_sec2_liste_membre_menage"
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
	use 			"$root/wave_`w'/r`w'_sec2_liste_membre_menage", clear
	
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
	use 		"$root/wave_`w'/r`w'_sec8_autres_revenu",clear
	
* drop other vars
	keep 		hhid revenu__id s08q0*
	
* reshape 
	reshape 	wide s08q0*, i(hhid) j(revenu__id)
	
* format vars
	rename 		s08q011 rem_for
	rename 		s08q012 rem_dom
	rename 		s08q013 asst_inc
	rename 		s08q014 isp_inc
	rename 		s08q015 pen_inc
	rename 		s08q016 farm_inc
	rename 		s08q017 bus_inc
	rename 		s08q018 wage_inc
	
	rename 		s08q021 rem_for_chg
	rename 		s08q022 rem_dom_chg
	rename 		s08q023 asst_chg
	rename 		s08q024 isp_chg
	rename 		s08q025 pen_chg
	rename 		s08q026 farm_chg
	rename 		s08q027 bus_chg
	rename 		s08q028 wage_chg
	
	rename 		s08q031 rem_for_chg_cov
	rename 		s08q032 rem_dom_chg_cov
	rename 		s08q033 asst_chg_cov
	rename 		s08q034 isp_chg_cov
	rename 		s08q035 pen_chg_cov
	rename 		s08q036 farm_chg_cov
	rename 		s08q037 bus_chg_cov
	rename 		s08q038 wage_chg_cov
	
* save temp file
	tempfile		tempc
	save			`tempc'
		
	
* ***********************************************************************
*  3 - shocks
* ***********************************************************************		

* load data
	use 			"$root/wave_`w'/r`w'_sec9_chocs", clear

* drop other shock
	drop			s09q03_autre
	
* generate shock variables
	forval 			x = 1/13 {
		gen 		shock_`x' = s09q01 if chocs__id == `x'
	}

* collapse to household level	
	collapse 		(max) s09q03__1-shock_13, by(hhid)
	
* save temp file
	tempfile		tempd
	save			`tempd'	
	

* ***********************************************************************
*  4 - FIES
* ***********************************************************************	
/*
* load data
	use 			"$fies/BFA_FIES_round`w'", clear
	
* format hhid & vars
	destring 		HHID, gen(hhid)
	drop 			country round HHID
	
* save temp file
	tempfile		tempe
	save			`tempe'	

*/	


* ***********************************************************************
*  6 - merge
* ***********************************************************************

* load cover data
	use 		"$root/wave_`w'/r`w'_sec0_cover", clear
	
* merge formatted sections
	foreach 		x in a b c d {
	    merge 		1:1 hhid using `temp`x'', nogen
	}

* merge in other sections
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec2b_sante_mentale", nogen			
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec3_connaisance_covid19", nogen	
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec4_comportaments", nogen	
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec4b_vaccination_covid19", nogen	
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec5_acces_service_base", nogen
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec5b_credit", nogen	
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec6a_emplrev_general", nogen
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec6db_emplrev_elevage", nogen
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec7_securite_alimentaire", nogen
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec9b_inquietudes", nogen
	merge 1:1 	hhid using "$root/wave_`w'/r`w'_sec11_frag_confl_violence", nogen
	
* clean variables inconsistent with other rounds

	* vaccine 
	rename 			s04bq02 cov_vac_know
	rename 			s04bq04 have_vac
	rename 			s04bq06 cov_vac 
	rename 			s04bq07 s04bq03 // make this match round 5
	rename 			s04bq08 s04bq04 // make this match round 5
	
	* ac_med
	rename 			s05q01a ac_med
	replace 		ac_med = 1 if ac_med == 2 | ac_med == 3 | ac_med == 4
	replace 		ac_med = 2 if ac_med == 5
	replace 		ac_med = 3 if ac_med == 6
	
	* medserv
	rename 			s05q03d_1 ac_medserv_why 
	replace 		ac_medserv_why = 8 if ac_medserv_why == 7 
	
	* education 
	rename 			s05q05 sch_child
	rename 			s05q06a sch_boy
	rename 			s05q06b sch_girl
	replace 		sch_girl = . if sch_girl == 5000
	rename 			s05q07 sch_reopen 
	replace 		sch_reopen  = sch_reopen  - 1 if sch_reopen  > 1
	rename 			s05q08a sch_reopen_boy
	rename 			s05q08b sch_reopen_girl
	rename 			s05q09__* sch_att_why_*
	drop 			s05q09_autre sch_att_why_96
	
	* employment 
	rename 			s06q04_0 emp_chg_why
	drop 			s06q04_0_autre
	replace 		emp_chg_why = 96 if emp_chg_why == 13
	
	* livestock 
	rename 			s06dbq01 ag_live
	forval 			x = 1/4 {
		rename 			s06dbq02__`x' ag_live_`x'
	}
	rename 			s06dbq02__5 ag_live_7
	rename 			s06dbq03__1 ag_live_affect_1
	rename 			s06dbq03__2 ag_live_affect_3
	rename 			s06dbq03__3 ag_live_affect_4
	rename 			s06dbq03__4 ag_live_affect_7
	rename 			s06dbq04 ag_live_sell_able	
	rename 			s06dbq05 ag_live_sell_why
	rename 			s06dbq06 ag_live_sell_21
	rename 			s06dbq07 ag_live_sell_pr
	rename 			s06dbq08__* ag_live_sell_nowhy_*
	drop 			ag_live_sell_nowhy_7
	
	drop 			s06dbq03__96 s06dbq03_autre
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			hhwcovid_r`w'_cs phw_cs
	rename 			hhwcovid_r`w'_pnl phw_pnl
	label var		phw_cs "sampling weights- cross section"
	label var		phw_pnl "sampling weights- panel"
	
* save round file
	save			"$export/wave_`w'/r`w'", replace

/* END */		
* Project: WB COVID
* Created on: August 2020
* Created by: jdm
* Edited by: amf
* Last edited: Nov 2020 
* Stata v.16.1

* does
	* reads in third round of Nigeria data
	* reshapes and builds panel
	* outputs panel data 

* assumes
	* raw Nigeria data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/nigeria/raw"
	global	export	=	"$data/nigeria/refined"
	global	logout	=	"$data/nigeria/logs"
	global  fies 	= 	"$data/analysis/raw/Nigeria"

* open log
	cap log 		close
	log using		"$logout/nga_reshape", append

* set local wave number & file number
	local			w = 3
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 
		
		
* ***********************************************************************
* 1 - format secitons and save tempfiles
* ***********************************************************************


* ***********************************************************************
* 1a - section 2: household size and gender of HOH
* ***********************************************************************
	
* load data
	use				"$root/wave_0`w'/r`w'_sect_2.dta", clear

* rename other variables 
	rename 			indiv ind_id 
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
			keep 		hhid s2q4 ind_id
			keep 		if s2q4 != .
			duplicates 	drop hhid s2q4, force
			reshape 	wide ind_id, i(hhid) j(s2q4)
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
			keep 		hhid s2q8 ind_id
			keep 		if s2q8 != .
			duplicates 	drop hhid s2q8, force
			reshape 	wide ind_id, i(hhid) j(s2q8)
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
	tempfile		tempa
	save			`tempa'
	

* ***********************************************************************
* 1b - sections 2, 5-6, 12: respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_a_2_5_5a_6_12", clear
	
* drop all but household respondant
	keep			hhid s12q9
	rename			s12q9 indiv
	isid			hhid
	
* merge in household roster
	merge 			1:1	hhid indiv using "$root/wave_0`w'/r`w'_sect_2.dta"
	keep 			if _merge == 3
	drop 			_merge
	
* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .
	rename			indiv PID
	
* drop all but gender and relation to HoH
	keep			hhid PID sex age relate_hoh

* save temp file
	tempfile		tempb
	save			`tempb'
		
	
* ***********************************************************************
* 1c - section 7: income
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_7", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other source
	drop			zone state lga sector ea
	
* reshape data	
	reshape 		wide s7q1, i(hhid) j(source_cd)

	rename			s7q14 oth_inc_1
	lab var 		oth_inc_1 "Other Income: Remittances from abroad"
	rename			s7q15 oth_inc_2
	lab var 		oth_inc_2 "Other Income: Remittances from family in the country"
	rename			s7q16 oth_inc_3
	lab var 		oth_inc_3 "Other Income: Assistance from non-family"
	rename			s7q17 oth_inc_4
	lab var 		oth_inc_4 "Other Income: Income from properties, investments, or savings"
	rename			s7q18 oth_inc_5
	lab var 		oth_inc_5 "Other Income: Pension"	
	
* save temp file
	tempfile		tempc
	save			`tempc'	
	

* ***********************************************************************
* 1d - section 11: assistance
* ***********************************************************************

* load data  - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/r`w'_sect_11", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other 
	drop 			zone state lga sector ea s11q2 s11q3__1 s11q3__2 ///
						s11q3__3 s11q3__4 s11q3__5 s11q3__6 s11q3__7 ///
						s11q3__96 s11q3_os s11q5 s11q6__1 s11q6__2 ///
						s11q6__3 s11q6__4 s11q6__6 s11q6__7 s11q6__96 s11q6_os

* reshape 
	reshape 		wide s11q1, i(hhid) j(assistance_cd)

* save temp file
	tempfile		tempd
	save			`tempd'					
		
		
* ***********************************************************************
* 1e - section 10: shocks
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_10", clear

* reformat HHID
	format 			%5.0f hhid

* drop other shock
	drop			shock_cd_os s10q3_os
	
* generate shock variables
	levelsof(shock_cd), local(id)
	foreach 			i in `id' {
		gen				shock_`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_`i' = 0 if s10q1 == 2 & shock_cd == `i'
		}

* collapse to household level
	collapse 		(max) s10q3__1- shock_96, by(hhid)	
	
* save temp file
	tempfile		tempe
	save			`tempe'
	
	
* ***********************************************************************
* 2 - FIES score
* ***********************************************************************

* not available for round

		
* ***********************************************************************
* 3 - merge sections into panel and save
* ***********************************************************************

* merge sections based on hhid
	use				"$root/wave_0`w'/r`w'_sect_a_2_5_5a_6_12", clear
	foreach 		s in a b c d e {
	    merge		1:1 hhid using `temp`s'', nogen
	}
	
* generate round variable
	gen				wave = `w'
	lab var			wave "Wave number"	
	
* clean variables inconsistent with other rounds	
	* agriculture
	rename 			s6aq1 ag_crop
	drop			s6q16a 
	rename 			s6q15a bus_other
	rename 			s6aq1b ag_crop_who
	rename 			s6q2a ag_use_infert
	rename 			s6q2b ag_use_orfert
	rename 			s6q2c ag_use_pest
	rename 			s6q2d ag_use_lab
	rename 			s6q2e ag_use_anim
	rename 			s6aq3a ag_ac_infert
	rename 			s6aq3b ag_ac_orfert
	rename 			s6aq3c ag_ac_pest
	rename 			s6aq3d ag_ac_lab
	rename 			s6aq3e ag_ac_anim
	forval 			x = 1/6 {
	    rename 		s6aq4__`x' ag_ac_infert_why_`x'
		rename 		s6aq5__`x' ag_ac_orfert_why_`x'
		rename 		s6aq6__`x' ag_ac_pest_why_`x'		
	}
	forval 			x = 1/5 {
	    rename 		s6aq7__`x' ag_ac_lab_why_`x'
		rename 		s6aq8__`x' ag_ac_anim_why_`x'
	}
	
  * access
	* rice
	rename 			s5q1a4 ac_rice_need
	rename 			s5q1b4 ac_rice
	gen 			ac_rice_why = . 
	replace			ac_rice_why = 1 if s5q1c4__1 == 1 
	replace 		ac_rice_why = 2 if s5q1c4__2 == 1
	replace 		ac_rice_why = 3 if s5q1c4__3 == 1 
	replace 		ac_rice_why = 4 if s5q1c4__4 == 1 
	replace 		ac_rice_why = 5 if s5q1c4__5 == 1 
	replace 		ac_rice_why = 6 if s5q1c4__6 == 1 
	label var 		ac_rice_why "reason unable to purchase rice"
	* beans 	
	rename 			s5q1a5 ac_beans_need
	rename 			s5q1b5 ac_beans
	gen 			ac_beans_why = . 
	replace			ac_beans_why = 1 if s5q1c5__1 == 1 
	replace 		ac_beans_why = 2 if s5q1c5__2 == 1
	replace 		ac_beans_why = 3 if s5q1c5__3 == 1 
	replace 		ac_beans_why = 4 if s5q1c5__4 == 1 
	replace 		ac_beans_why = 5 if s5q1c5__5 == 1 
	replace 		ac_beans_why = 6 if s5q1c5__6 == 1 
	label var 		ac_beans_why "reason unable to purchase beans"
	* cassava 		
	rename 			s5q1a6 ac_cass_need
	rename 			s5q1b6 ac_cass
	gen 			ac_cass_why = . 
	replace			ac_cass_why = 1 if s5q1c6__1 == 1 
	replace 		ac_cass_why = 2 if s5q1c6__2 == 1
	replace 		ac_cass_why = 3 if s5q1c6__3 == 1 
	replace 		ac_cass_why = 4 if s5q1c6__4 == 1 
	replace 		ac_cass_why = 5 if s5q1c6__5 == 1 
	replace 		ac_cass_why = 6 if s5q1c6__6 == 1 
	label var 		ac_cass_why "reason unable to purchase cassava"
	* yam	
	rename 			s5q1a7 ac_yam_need
	rename 			s5q1b7 ac_yam
	gen 			ac_yam_why = . 
	replace			ac_yam_why = 1 if s5q1c7__1 == 1 
	replace 		ac_yam_why = 2 if s5q1c7__2 == 1
	replace 		ac_yam_why = 3 if s5q1c7__3 == 1 
	replace 		ac_yam_why = 4 if s5q1c7__4 == 1 
	replace 		ac_yam_why = 5 if s5q1c7__5 == 1 
	replace 		ac_yam_why = 6 if s5q1c7__6 == 1 
	label var 		ac_yam_why "reason unable to purchase yam"
	* sorghum 	
	rename 			s5q1a8 ac_sorg_need
	rename 			s5q1b8 ac_sorg
	gen 			ac_sorg_why = . 
	replace			ac_sorg_why = 1 if s5q1c8__1 == 1 
	replace 		ac_sorg_why = 2 if s5q1c8__2 == 1
	replace 		ac_sorg_why = 3 if s5q1c8__3 == 1 
	replace 		ac_sorg_why = 4 if s5q1c8__4 == 1 
	replace 		ac_sorg_why = 5 if s5q1c8__5 == 1 
	replace 		ac_sorg_why = 6 if s5q1c8__6 == 1 
	label var 		ac_sorg_why "reason unable to purchase sorghum"
	* vaccine
	rename 			s5q3a ac_vac_need
	replace 		ac_vac_need = . if ac_vac_need == 98
	rename 			s5q3b ac_vac
	rename 			s5q3c__* ac_vac_why_*
	drop 			ac_vac_why_96
	* medical service	
	rename 			s5q2 ac_medserv_need
	rename 			s5q3 ac_medserv
	rename 			s5q4 ac_medserv_why 
	replace 		ac_medserv_why = 7 if ac_medserv_why == 4
	replace 		ac_medserv_why = 9 if ac_medserv_why == 5
	replace 		ac_medserv_why = 10 if ac_medserv_why == 6
	replace 		ac_medserv_why = . if ac_medserv_why == 96 
	* ncdc hotline
	rename 			s5q3d ncdc
	rename 			s5q3e hotline
	rename 			s5q3f__* hotline_why_*
	drop 			hotline_why_96
	* education 
	rename 			s5q4b edu_act
	rename 			s5q5__1 edu_1 
	rename 			s5q5__2 edu_2  
	rename 			s5q5__3 edu_3 
	rename 			s5q5__4 edu_4 
	rename 			s5q5__7 edu_5 
	rename 			s5q5__5 edu_6 
	rename 			s5q5__6 edu_7 	
	rename 			s5q5__96 edu_other 	
	* public transport & travel
	rename 			s5q11 ac_pubtr_need
	rename 			s5q12 ac_pubtr
	rename 			s5q13__* ac_pubtr_why_*
	drop 			ac_pubtr_why_96
	rename 			s5q13a ac_pubtr_dif
	rename 			s5q13b__* ac_pubtr_dif_*
	drop 			ac_pubtr_dif_96
	rename 			s5q14 bh_trav
	rename 			s5q15 bh_trav_why
	rename 			s5q16 bh_trav_how 
	rename 			s5q17__1 bh_trav_morn
	rename 			s5q17__2 bh_trav_aft
	rename 			s5q17__3 bh_trav_night

	
	//ADD HOUSING SECTION

* save round file
	save			"$export/wave_0`w'/r`w'", replace

* close the log
	log	close
	
	
/* END */	
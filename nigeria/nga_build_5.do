* Project: WB COVID
* Created on: August 2020
* Created by: jdm
* Edited by: amf
* Last edited: Nov 2020 
* Stata v.16.1

* does
	* reads in fifth round of Nigeria data
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
	local			w = 5
	
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
* 1b - sections 3-6, 8-9, 12: respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_a_2_5c_6_12", clear
	
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
	
* not avaiable for round 
	
		
* ***********************************************************************
* 1e - section 10: shocks
* ***********************************************************************

* not avaiable for round


* ***********************************************************************
* 1f - Employment
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_6b", clear

* generate secondary income variables for index
	gen 			wage_inc_ind = 1 if s6q6_1 == 4 | s6q6_1 == 5 | s6q6_1 == 6
	replace 		wage_inc_ind = 0 if s6q6_1 < 4	
	gen 			farm_inc_ind = 1 if s6q6_1 == 3
	replace 		farm_inc_ind = 0 if s6q6_1 != 3 & s6q6_1 < .
	gen 			bus_inc_ind = 1 if s6q6_1 < 3
	replace 		bus_inc_ind = 0 if s6q6_1 >= 3 & s6q6_1 < .
	
* collapse to hh level 
	collapse 		(sum) *_inc_ind, by(hhid)
	replace 		wage = 1 if wage > 1
	replace 		farm = 1 if farm > 1
	replace 		bus = 1 if bus > 1
	
* save temp file part 1
	tempfile		tempf
	save			`tempf'
		
		
* ***********************************************************************
* 2 - FIES score
* ***********************************************************************

* not available for round 


* ***********************************************************************
* 4 - merge sections into panel and save
* ***********************************************************************

* merge sections based on hhid
	use				"$root/wave_0`w'/r`w'_sect_a_2_5c_6_12", clear
	foreach 		s in a b c f {
	    merge		1:1 hhid using `temp`s'', nogen
	}
	
* generate round variable
	gen				wave = `w'
	lab var			wave "Wave number"	

* clean variables inconsistent with other rounds	
	* agriculture
	rename			s6q16 ag_crop
	rename 			s6bq1 ag_live
 	rename 			s6q11b1 bus_other
	replace 		s6q1c = s6q4b if s6q1c == .
	drop 			s6q4b*
	rename 			s6aq9 ag_harv_exp
	rename 			s6aq10 harv_sell_norm
	replace 		harv_sell_norm = crop_filter2 if harv_sell_norm == .
	replace 		harv_sell_norm = . if harv_sell_norm > 2
	drop 			crop_filter2
	rename 			s6aq11 harv_sell_rev_exp
	rename 			s6aq12 harv_sell
		
	* education
	rename 			s5cq1 sch_att
	forval 			x = 1/14 {
	    rename 		s5cq2__`x' sch_att_why_`x'
	}
	rename 			s5cq3 sch_prec
	forval 			x = 1/11 {
	    rename 		s5cq4__`x' sch_prec_`x'
	}
	rename 			s5cq4__99 sch_prec_none
	rename 			s5cq5 sch_prec_sat
	rename 			s5cq6 edu_act 
	rename 			s5cq7__1 edu_1 
	rename 			s5cq7__2 edu_2  
	rename 			s5cq7__3 edu_3 
	rename 			s5cq7__4 edu_4 
	rename 			s5cq7__7 edu_5 
	rename 			s5cq7__5 edu_6 
	rename 			s5cq7__6 edu_7 	
	rename 			s5cq7__96 edu_other 
	rename 			s5cq8 edu_cont
	rename 			s5cq9__1 edu_cont_1
	rename 			s5cq9__2 edu_cont_2
	rename 			s5cq9__3 edu_cont_3
	rename 			s5cq9__4 edu_cont_5
	rename 			s5cq9__5 edu_cont_6
	rename 			s5cq9__6 edu_cont_7
	rename 			s5cq9__7 edu_cont_8
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

* close the log
	log	close
	
	
/* END */	
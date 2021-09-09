* Project: WB COVID
* Created on: August 2020
* Created by: jdm
* Edited by: amf
* Last edited: Dec 2020 
* Stata v.16.1

* does
	* reads in sixth round of Nigeria data
	* reshapes and builds panel
	* outputs panel data 

* assumes
	* raw Nigeria data

* TO DO:
	* add sections, pull together, waiting on questionaire 

	
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
	local			w = 6
	
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
* 1b - respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_a_2_3a_6_9a_12", clear
	
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
* 1e - section 5c: education
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_5c.dta", clear	

	drop 			if s5cq10 == 2 | s5cq10a == 2
	rename 			s5cq11 sch_att
	replace 		sch_att = 0 if sch_att == 2
	forval 			x = 1/14 {
	    gen 		sch_att_why_`x' = 0 if sch_att == 0
		replace 	sch_att_why_`x' = 1 if s5cq12 == `x'
	}		
	rename 			s5cq12a sch_open 
	replace 		sch_open = 0 if sch_open == 2
	
	rename 			s5cq15 sch_onsite
	replace 		sch_onsite = 1 if sch_onsite == 2
	replace 		sch_onsite = 0 if sch_onsite == 3
	
	rename 			s5cq17 sch_online
	replace 		sch_online = 0 if sch_online == 2
	
	rename 			s5cq18 sch_child
	replace 		sch_child = 0 if sch_child == 2
	
	rename 			s5cq21 edu_act 
	replace 		edu_act = 0 if edu_act == 2

	collapse 		(max) edu* sch*, by (hhid)
	
	lab	def			yesno 0 "No" 1 "Yes", replace
	tostring 		hhid, replace
	ds,				has(type numeric)
	foreach 		var in `r(varlist)' {
		lab val 	`var' yesno
	}
	destring 		hhid, replace 

* save temp file
	tempfile	tempd
	save		`tempd'
	
	
* ***********************************************************************
* 2 - FIES score
* ***********************************************************************

* not available for round 
	

* ***********************************************************************
* 3 - merge sections into panel and save
* ***********************************************************************

* merge sections based on hhid
	use				"$root/wave_0`w'/r`w'_sect_a_2_3a_6_9a_12", clear
	foreach 		s in a b c d {
	    merge		1:1 hhid using `temp`s'', nogen
	}
	
* generate round variable
	gen				wave = `w'
	lab var			wave "Wave number"	
	
* clean variables inconsistent with other rounds	
	* education
	forval 			x = 1/11 {
	    rename 		s5cq4__`x' sch_prec_`x'
	}
	rename 			s5cq4__99 sch_prec_none
	
	* business
	rename 			s6q11b1 bus_other
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

* close the log
	log	close
	
	
/* END */		
	
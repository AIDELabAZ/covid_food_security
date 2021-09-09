* Project: COVID Food Security
* Created on: August 2020
* Created by: jdm
* Edited by: jdm
* Last edited: 25 September 2020 
* Stata v.16.1

* does
	* reshapes raw Nigeria data
	* outputs multiple wide data for mergiing

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


* ***********************************************************************
* 1 - reshape section 7 wide data
* ***********************************************************************


* ***********************************************************************
* 1a - section 7 - wave 1
* ***********************************************************************

* read in section 7, wave 1
	use				"$root/wave_01/r1_sect_7", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other source
	drop			source_cd_os zone state lga sector ea
	
* reshape data	
	reshape 		wide s7q1 s7q2, i(hhid) j(source_cd)

* rename variables	
	rename 			s7q11 farm_inc
	lab	var			farm_inc "Income from farming, fishing, livestock in last 12 months"
	rename			s7q21 farm_chg
	lab var			farm_chg "Change in income from farming since covid"
	rename 			s7q12 bus_inc
	lab var			bus_inc "Income from non-farm family business in last 12 months"
	rename			s7q22 bus_chg
	lab var			bus_chg "Change in income from non-farm family business since covid"	
	rename 			s7q13 wage_inc
	lab var			wage_inc "Income from wage employment in last 12 months"
	rename			s7q23 wage_chg
	lab var			wage_chg "Change in income from wage employment since covid"	
	rename 			s7q14 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename			s7q24 rem_for_chg
	label 			var rem_for_chg "Change in income from remittances abroad since covid"	
	rename 			s7q15 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename			s7q25 rem_dom_chg
	label 			var rem_dom_chg "Change in income from remittances domestic since covid"	
	rename 			s7q16 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename			s7q26 asst_chg
	label 			var asst_chg "Change in income from assistance from non-family since covid"
	rename 			s7q17 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename			s7q27 isp_chg
	label 			var isp_chg "Change in income from properties, investment since covid"
	rename 			s7q18 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"
	rename			s7q28 pen_chg
	label 			var pen_chg "Change in income from pension since covid"
	rename 			s7q19 gov_inc
	label 			var gov_inc "Income from government assistance in last 12 months"
	rename			s7q29 gov_chg
	label 			var gov_chg "Change in income from government assistance since covid"	
	rename 			s7q110 ngo_inc
	label 			var ngo_inc "Income from NGO assistance in last 12 months"
	rename			s7q210 ngo_chg
	label 			var ngo_chg "Change in income from NGO assistance since covid"
	rename 			s7q196 oth_inc
	label 			var oth_inc "Income from other source in last 12 months"
	rename			s7q296 oth_chg
	label 			var oth_chg "Change in income from other source since covid"	
	rename			s7q299 tot_inc_chg
	label 			var tot_inc_chg "Change in income from other source since covid"	

	drop			s7q199
	
* save temp file
	save			"$export/wave_01/r1_sect_7w", replace
	

* ***********************************************************************
* 1b - section 7 - wave 2
* ***********************************************************************

* read in section 7, wave 2
	use				"$root/wave_02/r2_sect_7", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other source
	drop			zone state lga sector ea
	
* reshape data	
	reshape 		wide s7q1, i(hhid) j(source_cd)

* rename variables	
	
	rename 			s7q14 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename 			s7q15 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename 			s7q16 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename 			s7q17 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename 			s7q18 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"

* save temp file
	save			"$export/wave_02/r2_sect_7w", replace


* ***********************************************************************
* 1c - section 7 - wave 3
* ***********************************************************************

* read in section 7, wave 2
	use				"$root/wave_03/r3_sect_7", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other source
	drop			zone state lga sector ea
	
* reshape data	
	reshape 		wide s7q1, i(hhid) j(source_cd)

* rename variables	
	
	rename 			s7q14 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename 			s7q15 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename 			s7q16 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename 			s7q17 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename 			s7q18 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"

* save temp file
	save			"$export/wave_03/r3_sect_7w", replace	
	

* ***********************************************************************
* 2 - reshape section 10 wide data
* ***********************************************************************


* ***********************************************************************
* 2a - section 10 - wave 1
* ***********************************************************************

* read in section 10, wave 1
	use				"$root/wave_01/r1_sect_10", clear

* reformat HHID
	format 			%5.0f hhid

* drop other shock
	drop			shock_cd_os s10q3_os
	
* generate shock variables
	forval i = 1/9 {
		gen				shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		}
	
* need to make shock variables match uganda 
* shock 2 - 9 need to be change
* shock 1 is okay
	rename 			shock_08 shock_12 
	rename 			shock_09 shock_14 
	rename 			shock_05 shock_08 
	rename			shock_06 shock_10
	rename 			shock_07 shock_11 
	rename 			shock_02 shock_05
	rename			shock_03 shock_06
	rename 			shock_04 shock_07
	
* rename cope variables
	rename			s10q3__1 cope_01
	rename			s10q3__6 cope_02
	rename			s10q3__7 cope_03
	rename			s10q3__8 cope_04
	rename			s10q3__9 cope_05
	rename			s10q3__11 cope_06
	rename			s10q3__12 cope_07
	rename			s10q3__13 cope_08
	rename			s10q3__14 cope_09
	rename			s10q3__15 cope_10
	rename			s10q3__16 cope_11
	rename			s10q3__17 cope_12
	rename			s10q3__18 cope_13
	rename			s10q3__19 cope_14
	rename			s10q3__20 cope_15
	rename			s10q3__21 cope_16
	rename			s10q3__96 cope_17
	
* drop unnecessary variables
	drop	shock_cd s10q1 zone state lga sector ea 	

* collapse to household level
	collapse (max) cope_01- shock_14, by(hhid)
	
* label variables
	lab var			shock_01 "Death of disability of an adult working member of the household"
	lab var			shock_05 "Job loss"
	lab var			shock_06 "Non-farm business failure"
	lab var			shock_07 "Theft of crops, cash, livestock or other property"
	lab var			shock_08 "Destruction of harvest by insufficient labor"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items c"
	lab var			shock_14 "Other shock"
	* differs from uganda (other country with shock questions) - asked binary here
	
	foreach var of varlist shock_01-shock_14 {
		lab val		`var' shock 
		}
		
* generate any shock variable
	gen				shock_any = 1 if shock_01 == 1 | shock_05 == 1 | ///
						shock_06 == 1 | shock_07 == 1 | shock_08 == 1 | ///
						shock_10 == 1 | shock_11 == 1 | shock_12 == 1 | ///
						shock_14 == 1
	replace			shock_any = 0 if shock_any == .
	lab var			shock_any "Experience some shock"
	
	lab var			cope_01 "Sale of assets (Agricultural and Non_agricultural)"
	lab var			cope_02 "Engaged in additional income generating activities"
	lab var			cope_03 "Received assistance from friends & family"
	lab var			cope_04 "Borrowed from friends & family"
	lab var			cope_05 "Took a loan from a financial institution"
	lab var			cope_06 "Credited purchases"
	lab var			cope_07 "Delayed payment obligations"
	lab var			cope_08 "Sold harvest in advance"
	lab var			cope_09 "Reduced food consumption"
	lab var			cope_10 "Reduced non_food consumption"
	lab var			cope_11 "Relied on savings"
	lab var			cope_12 "Received assistance from NGO"
	lab var			cope_13 "Took advanced payment from employer"
	lab var			cope_14 "Received assistance from government"
	lab var			cope_15 "Was covered by insurance policy"
	lab var			cope_16 "Did nothing"
	lab var			cope_17 "Other"

* save temp file
	save			"$export/wave_01/r1_sect_10w", replace


* ***********************************************************************
* 2b - section 10 - wave 3
* ***********************************************************************

* read in section 10, wave 1
	use				"$root/wave_03/r3_sect_10", clear

* reformat HHID
	format 			%5.0f hhid

* drop other shock
	drop			shock_cd_os s10q3_os
	
* generate shock variables
	forval i = 1/9 {
		gen				shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		}
	
* need to make shock variables match uganda 
* shock 2 - 9 need to be change
* shock 1 is okay
	rename 			shock_08 shock_12 
	rename 			shock_09 shock_14 
	rename 			shock_05 shock_08 
	rename			shock_06 shock_10
	rename 			shock_07 shock_11 
	rename 			shock_02 shock_05
	rename			shock_03 shock_06
	rename 			shock_04 shock_07
	
* rename cope variables
	rename			s10q3__1 cope_01
	rename			s10q3__6 cope_02
	rename			s10q3__7 cope_03
	rename			s10q3__8 cope_04
	rename			s10q3__9 cope_05
	rename			s10q3__11 cope_06
	rename			s10q3__12 cope_07
	rename			s10q3__13 cope_08
	rename			s10q3__14 cope_09
	rename			s10q3__15 cope_10
	rename			s10q3__16 cope_11
	rename			s10q3__17 cope_12
	rename			s10q3__18 cope_13
	rename			s10q3__19 cope_14
	rename			s10q3__20 cope_15
	rename			s10q3__21 cope_16
	rename			s10q3__96 cope_17
	
* drop unnecessary variables
	drop	shock_cd s10q1 zone state lga sector ea 	

* collapse to household level
	collapse (max) cope_01- shock_14, by(hhid)
	
* label variables
	lab var			shock_01 "Death of disability of an adult working member of the household"
	lab var			shock_05 "Job loss"
	lab var			shock_06 "Non-farm business failure"
	lab var			shock_07 "Theft of crops, cash, livestock or other property"
	lab var			shock_08 "Destruction of harvest by insufficient labor"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items c"
	lab var			shock_14 "Other shock"
	* differs from uganda (other country with shock questions) - asked binary here
	
	foreach var of varlist shock_01-shock_14 {
		lab val		`var' shock 
		}
		
* generate any shock variable
	gen				shock_any = 1 if shock_01 == 1 | shock_05 == 1 | ///
						shock_06 == 1 | shock_07 == 1 | shock_08 == 1 | ///
						shock_10 == 1 | shock_11 == 1 | shock_12 == 1 | ///
						shock_14 == 1
	replace			shock_any = 0 if shock_any == .
	lab var			shock_any "Experience some shock"
	
	lab var			cope_01 "Sale of assets (Agricultural and Non_agricultural)"
	lab var			cope_02 "Engaged in additional income generating activities"
	lab var			cope_03 "Received assistance from friends & family"
	lab var			cope_04 "Borrowed from friends & family"
	lab var			cope_05 "Took a loan from a financial institution"
	lab var			cope_06 "Credited purchases"
	lab var			cope_07 "Delayed payment obligations"
	lab var			cope_08 "Sold harvest in advance"
	lab var			cope_09 "Reduced food consumption"
	lab var			cope_10 "Reduced non_food consumption"
	lab var			cope_11 "Relied on savings"
	lab var			cope_12 "Received assistance from NGO"
	lab var			cope_13 "Took advanced payment from employer"
	lab var			cope_14 "Received assistance from government"
	lab var			cope_15 "Was covered by insurance policy"
	lab var			cope_16 "Did nothing"
	lab var			cope_17 "Other"

* save temp file
	save			"$export/wave_03/r3_sect_10w", replace

	
* ***********************************************************************
* 3 - reshape section 11 wide data
* ***********************************************************************


* ***********************************************************************
* 3a - section 11 - wave 1
* ***********************************************************************

* read in section 11, wave 1 - updated via convo with Talip 9/1
	use				"$root/wave_01/r1_sect_11", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other 
	drop 			zone state lga sector ea s11q2 s11q3 s11q3_os

* reshape 
	reshape 		wide s11q1, i(hhid) j(assistance_cd)

* rename variables
	gen				asst_food = 1 if s11q11 == 1
	replace			asst_food = 0 if s11q11 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s11q12 == 1
	replace			asst_cash = 0 if s11q12 == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s11q13 == 1
	replace			asst_kind = 0 if s11q13 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s11q11 s11q12 s11q13

* save temp file
	save			"$export/wave_01/r1_sect_11w", replace
	
	
* ***********************************************************************
* 3b - section 11 - wave 2
* ***********************************************************************

* read in section 11, wave 2 - updated via convo with Talip 9/1
	use				"$root/wave_02/r2_sect_11", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other 
	drop 			zone state lga sector ea s11q2 s11q3__1 s11q3__2 ///
						s11q3__3 s11q3__4 s11q3__5 s11q3__6 s11q3__7 ///
						s11q3__96 s11q3_os s11q5 s11q6__1 s11q6__2 ///
						s11q6__3 s11q6__4 s11q6__6 s11q6__7 s11q6__96 s11q6_os
	
* reshape 
	reshape 		wide s11q1, i(hhid) j(assistance_cd)

* rename variables
	gen				asst_food = 1 if s11q11 == 1
	replace			asst_food = 0 if s11q11 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s11q12 == 1
	replace			asst_cash = 0 if s11q12 == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s11q13 == 1
	replace			asst_kind = 0 if s11q13 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s11q11 s11q12 s11q13

* save temp file
	save			"$export/wave_02/r2_sect_11w", replace				


* ***********************************************************************
* 3c - section 11 - wave 3
* ***********************************************************************

* read in section 11, wave 3 - updated via convo with Talip 9/1
	use				"$root/wave_03/r3_sect_11", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other 
	drop 			zone state lga sector ea s11q2 s11q3__1 s11q3__2 ///
						s11q3__3 s11q3__4 s11q3__5 s11q3__6 s11q3__7 ///
						s11q3__96 s11q3_os s11q5 s11q6__1 s11q6__2 ///
						s11q6__3 s11q6__4 s11q6__6 s11q6__7 s11q6__96 s11q6_os

* reshape 
	reshape 		wide s11q1, i(hhid) j(assistance_cd)

* rename variables
	gen				asst_food = 1 if s11q11 == 1
	replace			asst_food = 0 if s11q11 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s11q12 == 1
	replace			asst_cash = 0 if s11q12 == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s11q13 == 1
	replace			asst_kind = 0 if s11q13 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s11q11 s11q12 s11q13

* save temp file
	save			"$export/wave_03/r3_sect_11w", replace					
	

* ***********************************************************************
* 4 - get respondant gender
* ***********************************************************************

	
* ***********************************************************************
* 4a - respondant gender - wave 1
* ***********************************************************************

* load data
	use				"$root/wave_01/r1_sect_a_3_4_5_6_8_9_12", clear
	
* drop all but household respondant
	keep			hhid s12q9
	
	rename			s12q9 indiv
	
	isid			hhid
	
* merge in household roster
	merge 1:1		hhid indiv using "$root/wave_01/r1_sect_2.dta"
	
	keep if			_merge == 3
	
* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .
	rename			indiv PID
	
* drop all but gender and relation to HoH
	keep			hhid PID sex age relate_hoh

* save temp file
	save			"$export/wave_01/respond_r1", replace

	
* ***********************************************************************
* 4b - respondant gender - wave 2
* ***********************************************************************

* load data
	use				"$root/wave_02/r2_sect_a_2_5_6_8_12", clear
	
* drop all but household respondant
	keep			hhid s12q9
	
	rename			s12q9 indiv
	
	isid			hhid
	
* merge in household roster
	merge 1:1		hhid indiv using "$root/wave_02/r2_sect_2.dta"
	
	keep if			_merge == 3
	
* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .
	rename			indiv PID
	
* drop all but gender and relation to HoH
	keep			hhid PID sex age relate_hoh

* save temp file
	save			"$export/wave_02/respond_r2", replace	
	

* ***********************************************************************
* 4c - respondant gender - wave 3
* ***********************************************************************

* load data
	use				"$root/wave_03/r3_sect_a_2_5_5a_6_12", clear
	
* drop all but household respondant
	keep			hhid s12q9
	
	rename			s12q9 indiv
	
	isid			hhid
	
* merge in household roster
	merge 1:1		hhid indiv using "$root/wave_03/r3_sect_2.dta"
	
	keep if			_merge == 3
	
* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .
	rename			indiv PID
	
* drop all but gender and relation to HoH
	keep			hhid PID sex age relate_hoh

* save temp file
	save			"$export/wave_03/respond_r3", replace
	

* ***********************************************************************
* 5 - get household size
* ***********************************************************************

	
* ***********************************************************************
* 4a - household size and gender of HOH - wave 1
* ***********************************************************************
	
* load data
	use			"$root/wave_01/r1_sect_2.dta", clear

* rename other variables 
	rename 			indiv ind_id 
	rename 			s2q2 new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem
	
* generate counting variables
	gen			hhsize = 1
	gen 		hhsize_adult = 1 if age_mem > 18 & age_mem < .
	gen			hhsize_child = 1 if age_mem < 19 & age_mem != . 
	gen 		hhsize_schchild = 1 if age_mem > 4 & age_mem < 19 
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data
	collapse	(sum) hhsize hhsize_adult hhsize_child hhsize_schchild (max) sexhh, by(hhid)
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"

* save temp file
	save			"$export/wave_01/hhsize_r1", replace

	
* ***********************************************************************
* 4b - household size and gender of HOH - wave 2
* ***********************************************************************
	
* load data
	use			"$root/wave_02/r2_sect_2.dta", clear

* rename other variables 
	rename 			indiv ind_id 
	rename 			s2q2 new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem	
	
* generate counting variables
	gen			hhsize = 1
	gen 		hhsize_adult = 1 if age_mem > 18 & age_mem < .
	gen			hhsize_child = 1 if age_mem < 19 & age_mem != . 
	gen 		hhsize_schchild = 1 if age_mem > 4 & age_mem < 19 

* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data
	collapse	(sum) hhsize hhsize_adult hhsize_child hhsize_schchild (max) sexhh, by(hhid)
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"

* save temp file
	save			"$export/wave_02/hhsize_r2", replace
	
	
* ***********************************************************************
* 4c - household size and gender of HOH - wave 3
* ***********************************************************************
	
* load data
	use			"$root/wave_03/r3_sect_2.dta", clear

* rename other variables 
	rename 			indiv ind_id 
	rename 			s2q2 new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem	
	
* generate counting variables
	gen			hhsize = 1
	gen 		hhsize_adult = 1 if age_mem > 18 & age_mem < .
	gen			hhsize_child = 1 if age_mem < 19 & age_mem != . 
	gen 		hhsize_schchild = 1 if age_mem > 4 & age_mem < 19 

* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data
	collapse	(sum) hhsize hhsize_adult hhsize_child hhsize_schchild (max) sexhh, by(hhid)
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"

* save temp file
	save			"$export/wave_03/hhsize_r3", replace

* ***********************************************************************
* 4d - FIES score - R2
* ***********************************************************************

* load data
	use				"$fies/NG_FIES_round2.dta", clear

	drop 			country round
	rename 			HHID hhid 
	destring 		hhid, replace

* save temp file
	save			"$export/wave_02/fies_r2", replace
		
* **********************************************************************
* 6 - end matter - nothing to save
* **********************************************************************

* close the log
	log	close

/* END */	
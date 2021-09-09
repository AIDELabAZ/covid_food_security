* Project: WB COVID
* Created on: Feb 2021
* Created by: amf
* Edited by: amf
* Last edit: 16 Feb 2021
* Stata v.16.1

* does
	* generates data subset per Talip request 2.15.21 (below)
	/* Can you prepare a dataset for Malawi, Nigeria, Ethiopia that 
	includes these variables [vars in G:\My Drive\wb_covid\data\
	analysis\cleaning_notes\selected variable notes 2.9.21.xlsx] 
	for the rounds that have informed the e-book chapter? */

* assumes
	* cleaned country data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	ans		=	"$data/analysis"
	global	output	=	"$data/analysis"

* open log
	cap log 			close
	log using			"$logout/analysis_graphs", append

* read in data
	use					"$ans/lsms_panel", clear

	
* **********************************************************************
* 1 - keep requested variables, countries, and waves
* **********************************************************************

* keep Ethiopia, Malawi, and Nigeria
	drop 				if country == 4

* keep waves in book chapter
	keep 				if ((country == 1 | country == 3 ) & wave < 6) | ///
							(country == 2 & wave < 5) 
							
* waves to months 
	gen 				wave_orig = wave
	replace 			wave = 9 if wave == 5 & (country == 3 | country == 1)
	replace 			wave = 8 if wave == 4 & (country == 3 | country == 1)
	replace 			wave = 6 if wave == 3 & country == 1
	replace 			wave = 5 if wave == 2 & country == 1
	replace 			wave = 4 if wave == 1 & country == 1
	replace 			wave = 7 if wave == 3 & country == 3
	replace 			wave = 6 if wave == 2 & country == 3
	replace 			wave = 5 if wave == 1 & country == 3
	replace 			wave = 9 if wave == 4 & country == 2
	replace 			wave = 8 if wave == 3 & country == 2 
	replace 			wave = 7 if wave == 2 & country == 2
	replace 			wave = 6 if wave == 1 & country == 2

	lab def 			months 4 "April" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sept"
	lab val				wave months
	lab var 			wave_orig "Original wave number"
	lab var 			wave "Month"
	
* keep requested variables	
	keep 				country wave wave_orig hhid wt* emp emp_act emp_stat emp_able ///
							bus_emp farm_emp farm_norm *_inc ag_crop ag_live
	drop 				bus_emp_inc
							
* **********************************************************************
* 2 - format and save data subset
* **********************************************************************

* format
	order 				country wave* hhid

* variable summary
	preserve 
		drop hhid wt*
		ds 
		foreach var in `r(varlist)' {
			tab `var' country
		}
	restore
	
* save	
	save 				"$export/lsms_panel_subset", replace

* Project: WB COVID
* Created on: September 2020
* Created by: amf
* Edited by: jdm
* Last edit: 19 November 2020
* Stata v.16.1

* does
	* runs regressions and produces tables for supplemental material

* assumes
	* cleaned country data (lsms_panel) & pre/post covid FIES data
	* palettes and colrspace installed

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global					ans		=	"$data/analysis"
	global					output	=	"$data/analysis/tables"
	global					figure	=	"$data/analysis/figures"
	global					logout	=	"$data/analysis/logs"
	local 					tabnum  =   1

* open log
	cap 					log close
	log 					using "$logout/supp_mat", append

* read in data
	use						"$ans/lsms_panel", clear

* drop new waves not used in nhb
	keep 					if ((country == 1 | country == 3) & (wave == 1 | wave == 2 | wave == 3)) | ///
							((country == 2 | country == 4) & (wave == 1 | wave == 2))


* **********************************************************************
* 1 - create tables for Fig. 1
* **********************************************************************


* **********************************************************************
* 1a - create Table S1 for Fig. 1A
* **********************************************************************

* regressions for advised citizens to stay at home
	local 					counter = 1
		reg 				gov_01 ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							replace excel dec(3) ctitle(S`tabnum' gov_01) label noas stats(coef pval ci) ///
							drop (gov_1)

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = .
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore

* regressions for restricted travel within country/area, closure of schools,
	* curfew/lockdown, closure of non-essential businesses, stopping or limiting social gatherings

	foreach 				var in 2 4 5 6 10 {
		reg 				gov_`var' ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' gov_0`var') label noas stats(coef pval ci) ///
							drop (gov_`var')

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = .
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore
	}

* merge	all test tables into one and export
	preserve
		clear
		use 				`temp1'
		forval 				x = 2/6 {
			merge 			1:1 merger using `temp`x'', assert(3) nogen
		}
		format				testgrp* %10.3f
		drop 				merger
		gen 				testcountries = ""
		replace 			testcountries = "Ethiopia-Nigeria" in 1
		replace 			testcountries = "Ethiopia-Uganda" in 2
		replace 			testcountries = "Nigeria-Uganda" in 3
		order 				testc *
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							replace sheet(testresultsS`tabnum') first(var)
	restore


* **********************************************************************
* 1b - create table S2 for Fig. 1B
* **********************************************************************

local tabnum = `tabnum' + 1

* regressions for handwashing with Soap Reduces Risk of Coronavirus Contraction,
	* avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract,
	* using Masks or Gloves Reduces Risk of Coronavirus Contraction,
	* staying at Home Reduces Risk of Coronavirus Contraction,
	* avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction,
	* mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Common
	local 					counter = 1
	foreach 				var in 1 2 3 5 6 7 {
		reg 				know_`var' ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' know_0`var') label noas stats(coef pval ci) ///
							drop (know_`var')

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore

	}

* merge	all test tables into one and export
	preserve
		clear
		use 				`temp1'
		forval 				x = 2/6 {
			merge 			1:1 merger using `temp`x'', assert(3) nogen
		}
		format				testgrp* %10.3f
		drop 				merger
		gen 				testcountries = ""
		replace 			testcountries = "Ethiopia-Nigeria" in 1
		replace 			testcountries = "Ethiopia-Uganda" in 2
		replace 			testcountries = "Nigeria-Uganda" in 3
		order 				testc *
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
	restore


* **********************************************************************
* 1c - create tables S3-S4 for Fig. 1C
* **********************************************************************

*** table S3 ***

local tabnum = `tabnum' + 1

* handwashed with Soap More Often Since Outbreak
	reg 					bh_01 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Handwashed with soap more often) ///
							label noas stats(coef pval ci) drop (bh_1)

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		local 				counter = 1
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore

* avoided Handshakes/Physical Greetings Since Outbreak
	reg 					bh_02 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Avoided physical greetings) label ///
							noas stats(coef pval ci) drop (bh_2)

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore

* avoided Crowds and Gatherings Since Outbreak
	reg 					bh_03 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Avoided crowds) label noas stats(coef pval ci) ///
							drop (bh_3)

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore

* make table of test values
	preserve
	clear
	use 					`temp1'
	forval 					x = 2/3 {
		merge 				1:1 merger using `temp`x'', assert(3) nogen
	}
	format					testgrp* %10.3f
	drop 					merger

	gen 					testcountries = ""
	replace 				testcountries = "Ethiopia-Nigeria" in 1
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	order 					testc *
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
	restore

*** table S4 ***

local tabnum = `tabnum' + 1

* regressions of behavior on waves in Malawi
	reg						bh_01 i.wave [pweight = phw] if country == 2, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Malawi Behavior 1) label ///
							noas stats(coef pval ci) drop (bh_1)

	reg						bh_02 i.wave [pweight = phw] if country == 2, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Malawi Behavior 2) label ///
							noas stats(coef pval ci) drop (bh_2)

	reg						bh_3 i.wave [pweight = phw] if country == 2, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Malawi Behavior 3) label ///
							noas stats(coef pval ci) drop (bh_3)

* regressions of behavior on waves in Uganda
	reg						bh_01 i.wave [pweight = phw] if country == 4, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Uganda Behavior 1) label ///
							noas stats(coef pval ci) drop (bh_1)

	reg						bh_02 i.wave [pweight = phw] if country == 4, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Uganda Behavior 2) label ///
							noas stats(coef pval ci) drop (bh_2)

	reg						bh_03 i.wave [pweight = phw] if country == 4, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Uganda Behavior 3) label ///
							noas stats(coef pval ci) drop (bh_3)


* **********************************************************************
* 1d - create tables S5-S6 for Fig. 1D
* **********************************************************************

preserve

	local 					myth myth_02 myth_03 myth_04 myth_05
	foreach 				v in `myth' {
	    replace 			`v' = . if `v' == 3
	}

*** table S5 ***

local tabnum = `tabnum' + 1

* africans are immune to corona virus
	reg 					myth_02 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Africans immune) label noas stats(coef pval ci) ///
							drop (myth_2)

* corona virus does not affect children
	reg 					myth_03 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Not affect children) label noas stats(coef pval ci) ///
							drop (myth_3)

* corona virus cannot survive in warm weather
	reg 					myth_04 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Survive warm weather) label noas stats(coef pval ci) ///
							drop (myth_4)

* corona virus is just common flu
	reg 					myth_05 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Common flu) label noas stats(coef pval ci) ///
							drop (myth_5)
restore

*** table S6 ***

local tabnum = `tabnum' + 1

* totals by myths
	forval 					x = 2/5 {
	    gen 				myth_0`x'y = cond(myth_0`x' == 1,1,cond(myth_01 == 0 | myth_01 == 3, 0,.))
	    gen 				myth_0`x'n = cond(myth_0`x' == 0,1,cond(myth_01 == 1 | myth_01 == 3, 0,.))
	    gen 				myth_0`x'k = cond(myth_0`x' == 3,1,cond(myth_01 == 0 | myth_01 == 1, 0,.))
	}

	forval 					m = 2/5 {
		total 				myth_0`m'y myth_0`m'n myth_0`m'k [pweight = phw], over(country)
			local 			ytot_c2m`m' = el(e(b),1,1)
			local 			ytot_c4m`m' = el(e(b),1,2)
			local 			ntot_c2m`m' = el(e(b),1,3)
			local 			ntot_c4m`m' = el(e(b),1,4)
			local 			ktot_c2m`m' = el(e(b),1,5)
			local 			ktot_c4m`m' = el(e(b),1,6)
			local			yse_c2m`m' = sqrt(el(e(V),1,1))
			local			yse_c4m`m' = sqrt(el(e(V),2,2))
			local			nse_c2m`m' = sqrt(el(e(V),3,3))
			local			nse_c4m`m' = sqrt(el(e(V),4,4))
			local			kse_c2m`m' = sqrt(el(e(V),5,5))
			local			kse_c4m`m' = sqrt(el(e(V),6,6))
	}

	forval 					m = 2/5 {
		total 				myth_0`m'y myth_0`m'n myth_0`m'k [pweight = phw] if country == 2
		local				c2_n_m`m' = e(N)
		total 				myth_0`m'y myth_0`m'n myth_0`m'k [pweight = phw] if country == 4
		local				c4_n_m`m' = e(N)
	}

	* format table
		preserve
			clear
			set 			obs 7
			gen 			response = cond(_n<3,"y",cond(_n>2 & _n<5,"n",cond(_n>4 & _n<7,"k","")))
			gen 			stat = cond(mod(_n,2)==0,"se","tot")
			replace 		stat = "Observations" in 7
			expand 			2
			gen 			country = cond(_n<8,2,4)
			forval 			x = 2/5 {
							gen myth_0`x' = .
			}

		* replace values with stored locals
			foreach 		c in 2 4 {
				forval 		m = 2/5 {
					foreach s in tot se {
						foreach r in y n k {
							replace myth_0`m' = ``r'`s'_c`c'm`m'' if response == "`r'" & stat == "`s'" & country == `c'
						}
					}
				}
			}
			foreach c in 2 4 {
				forval 			x = 2/5 {
					replace 	myth_0`x' = `c`c'_n_m`x'' if stat == "Observations" & country == `c'
				}
			}
			export 			excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)
		restore


* **********************************************************************
* 3 - create tables for Fig. 2
* **********************************************************************

* **********************************************************************
* 2a - create Table S7-S9 for Fig. 2A
* **********************************************************************

*** table S7 ***

local tabnum = `tabnum' + 1

* mean and total (with std errors) for all countries for the income receipt variable for each country

	foreach 				var in farm_inc bus_inc wage_inc remit_inc other_inc {
		mean 				`var' [pweight = hhw] if wave == 1
			local 			n_`var'_call = e(N)
			local 			mean_`var'_call = el(e(b),1,1)
			local 			msd_`var'_call = sqrt(el(e(V),1,1))
		total 				`var' [pweight = hhw] if wave == 1
			local 			tot_`var'_call = el(e(b),1,1)
			local 			tsd_`var'_call = sqrt(el(e(V),1,1))
	}

	forval c = 1/4 {
		foreach 				var in farm_inc bus_inc wage_inc remit_inc other_inc {
			mean 				`var' [pweight = hhw] if wave == 1 & country == `c'
				local 			n_`var'_c`c' = e(N)
				local 			mean_`var'_c`c' = el(e(b),1,1)
				local 			msd_`var'_c`c' = sqrt(el(e(V),1,1))
			total 				`var' [pweight = hhw] if wave == 1 & country == `c'
				local 			tot_`var'_c`c' = el(e(b),1,1)
				local 			tsd_`var'_c`c' = sqrt(el(e(V),1,1))
		}
	}

* create table from stored results
	preserve
		clear
		set 				obs 5
		gen 				c = _n
		tostring 			c, replace
		replace 			c = "all" in 5
		expand 				5
		sort 				c
		gen 				stat = ""
		local 				q = 1
		foreach c in 1 2 3 4 all {
			replace 		stat = cond(_n==`q',"tot",cond(_n==`q'+1,"tsd",cond(_n==`q'+2,"mean",cond(_n==`q'+3,"msd", ///
			cond(_n==`q'+4,"n",""))))) if c == "`c'"
			local 			q = `q' + 5
		}
		foreach 			var in farm_inc bus_inc wage_inc remit_inc other_inc {
			gen 			`var' = .
			foreach c in 1 2 3 4 all {
				foreach 		s in tot tsd mean msd n {
					replace 	`var' = ``s'_`var'_c`c'' if stat == "`s'" & c == "`c'"
				}
			}
		}

		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(varlabels)
	restore

*** table S8 ***

local tabnum = `tabnum' + 1

* summary statistics on losses of income
	foreach 				var in dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
		mean 				`var' [pweight = phw] if wave == 1
			local 			n_`var' = e(N)
			local 			mean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
		total 				`var' [pweight = phw] if wave == 1
			local 			tot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
	}
	* format table
		preserve
			keep 			dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn
			drop 			if dwn < 2 //drop all observations
			label 			variable dwn "Any type of income loss"
			label 			variable remit_dwn "Remittances reduced"
			label 			variable other_dwn "Other income sources reduced"
			set 			obs 5
			gen 			stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
			order 			stat dwn *
			foreach 		var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
				decode 		`var', gen(`var'_de)
				destring 	`var'_de, replace
				drop 		`var'
			}
	* populate table with stored results
			foreach 		var in dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
			    foreach 	s in n mean msd tot tsd {
					replace `var' = ``s'_`var'' if stat == "`s'"
				}
			}

		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(varlabels)
		restore

*** table S9 ***

local tabnum = `tabnum' + 1

* regressions for cross-country comparisons

* regressions for income loss: farm
	reg 					farm_dwn ib(2).country [pweight = hhw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							replace excel dec(3) ctitle(S`tabnum' farm_dwn) noas stats(coef pval ci) ///
							drop (farm_dwn)

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				t1_farm_dwn = r(p)
		test				1.country = 4.country
		local 				t2_farm_dwn = r(p)
		test				3.country = 4.country
		local 				t3_farm_dwn = r(p)

* regressions for income loss: business, wage, remittances, other
	foreach 				var in bus_dwn wage_dwn remit_dwn other_dwn {
		reg 				`var' ib(2).country [pweight = hhw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' `var') noas stats(coef pval ci) ///
							drop (`var')

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				t1_`var' = r(p)
		test				1.country = 4.country
		local 				t2_`var' = r(p)
		test				3.country = 4.country
		local 				t3_`var' = r(p)
	}

	preserve
		clear
		set obs 3
		gen 				testcountries =  "Ethiopia-Nigeria"
		replace 			testcountries = "Ethiopia-Uganda" in 2
		replace 			testcountries = "Nigeria-Uganda" in 3
		foreach 			var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
							gen `var' = cond(_n == 1, `t1_`var'', cond(_n == 2, `t2_`var'',`t3_`var''))
		}

		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
	restore

*** table s10 ***

local tabnum = `tabnum' + 1

* regressions comparing rural urban, controlling for country

* regressions for income loss: farm, business, wage, remittances, other
	foreach 				var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
		reg 				`var' i.sector ib(2).country [pweight = hhw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' `var') noas stats(coef pval ci) ///
							drop (`var')
	}


* **********************************************************************
* 2b - create Table S11 for Fig. 2B
* **********************************************************************

*** table s11 ***

local tabnum = `tabnum' + 1

preserve

	drop 					if bus_emp_inc == -99
	drop 					if bus_emp_inc == -98

* regression for business revenue loss - by country and wave
	ologit 					bus_emp_inc i.wave ib(2).country [pweight = phw]
	local 					pr2 = e(r2_p)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' bus rev loss) noas stats(coef pval ci) ///
							drop (bus_emp_inc)

* Wald test for differences between other countries
	test					1.country = 3.country
	local 					ct1 = r(p)
	test					1.country = 4.country
	local 					ct2 = r(p)
	test					3.country = 4.country
	local 					ct3 = r(p)

* Wald test for differences between other wave
	test 					2.wave = 3.wave
	local 					wt = r(p)

* create table using stored test results
	clear
	set 					obs 5
	gen 					test =  "Ethiopia-Nigeria"
	replace 				test = "Ethiopia-Uganda" in 2
	replace 				test = "Nigeria-Uganda" in 3
	replace 				test = "Wave 2-Wave 3" in 4
	replace 				test = "Pseudo R-Squared" in 5
	gen 					result = cond(_n == 1, `ct1', cond(_n == 2, `ct2',cond(_n == 3, `ct3',`wt')))
	replace 				result = `pr2' in 5
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore


* **********************************************************************
* 2c - create Table S12-S13 for Fig. 2C
* **********************************************************************

*** table s12 ***

local tabnum = `tabnum' + 1

* summary statistics on moderate and severe food insecurity: means and totals

preserve
	drop					if country == 1 & wave == 2
	drop 					if country == 2 & wave == 1
	drop 					if country == 4 & wave == 1

* means of food insecurity status
	foreach 				var in p_mod p_sev {
		mean				`var' [pweight = wt_18]
			local 			mmean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
	}
	foreach 				var in p_mod p_sev {
		forval 				c= 1/4 {
			mean 			`var' [pweight = wt_18] if country == `c'
				local 		mmean_`var'_c`c' = el(e(b),1,1)
				local		msd_`var'_c`c' = sqrt(el(e(V),1,1))
		}
	}

* totals of food insecurity status
	foreach 				var in p_mod p_sev {
		total				`var' [pweight = wt_18]
			local			tn_`var' = e(N)
			local 			ttot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
	}
	foreach 				var in p_mod p_sev {
		forval 				c= 1/4 {
			total 			`var' [pweight = wt_18] if country == `c'
				local		tn_`var'_c`c' = e(N)
				local 		ttot_`var'_c`c' = el(e(b),1,1)
				local		tsd_`var'_c`c' = sqrt(el(e(V),1,1))
		}
	}

* create table of stored results
	clear
	set 					obs 9
	gen 					func = cond(_n<5,"m",cond(_n==9,"","t"))
	gen 					var = cond(_n ==1|_n==2|_n==5|_n==6,"p_mod",cond(_n==9,"","p_sev"))
	gen 					stat = cond(mod(_n,2)!=0,"mean","sd")
	replace 				stat = "tot" if _n == 5 | _n == 7
	replace 				stat = "Observations" in 9
	gen 					all_countries = .
	foreach 				stat in mean sd {
		foreach 			var in p_mod p_sev {
			replace			all_countries = `m`stat'_`var'' if var=="`var'" &stat=="`stat'" &func=="m"
		}
	}
	foreach					stat in tot sd {
		foreach 			var in p_mod p_sev {
			replace 		all_countries = `t`stat'_`var'' if var=="`var'" &stat=="`stat'" &func=="t"
		}
	}
	replace 				all_countries = `tn_p_mod' if stat == "Observations"
	forval 					c = 1/4 {
	    gen 				c`c' = .
		foreach 			stat in mean sd {
			foreach 		var in p_mod p_sev {
				replace		c`c' = `m`stat'_`var'_c`c'' if var=="`var'" &stat=="`stat'" &func=="m"
			}
		}
		foreach				stat in tot sd {
			foreach 		var in p_mod p_sev {
				replace 	c`c' = `t`stat'_`var'_c`c'' if var=="`var'" &stat=="`stat'" &func=="t"
			}
		}
		replace 			c`c' = `tn_p_mod_c`c'' if stat == "Observations"
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)
restore

*** table s12 ***

local tabnum = `tabnum' + 1

preserve

	drop 					if country == 1 & wave == 2
	drop 					if country == 2 & wave == 1
	drop 					if country == 4 & wave == 1

* regression for moderate food insecurity
	reg 					p_mod ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' mod food insecurity) noas stats(coef pval ci) ///
							drop (p_mod)

* Wald test for differences between other countries
		test				1.country = 3.country
		local 				tm1 = r(p)
		test				1.country = 4.country
		local 				tm2 = r(p)
		test				3.country = 4.country
		local 				tm3 = r(p)

* regression for severe food insecurity
	reg 					p_sev ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' sev food insecurity) noas stats(coef pval ci) ///
							drop (p_sev)

* Wald test for differences between other countries
		test				1.country = 3.country
		local 				ts1 = r(p)
		test				1.country = 4.country
		local 				ts2 = r(p)
		test				3.country = 4.country
		local 				ts3 = r(p)

* create table of stored test results
	clear
	set obs 3
	gen 					testcountries =  "Ethiopia-Nigeria"
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	gen 					modresult = .
	forval 					x = 1/3 {
		replace 			modresult = `tm`x'' if _n == `x'
	}
	gen 					sevresult = .
	forval 					x = 1/3 {
		replace 			sevresult = `ts`x'' if _n == `x'
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore


* **********************************************************************
* 2d - create Table S14 for Fig. 2D
* **********************************************************************

*** table s14 ***

local tabnum = `tabnum' + 1

preserve

	* precovid Nigeria
		use				"$ans/raw/FIES/FIES_PreCOVID.dta", clear
		keep 		if country=="Nigeria"
		keep 		if sample=="Planting Post-COVID"
		keep 		HHID p_mod p_sev
		gen 		time = 0

		tempfile precovid
		save `precovid'

	* post-covid Nigeria
		use			"$ans/raw/FIES/FIES_PostCOVID.dta", clear
		keep 		if country=="Nigeria" & round==2

	* merge in pre to post
		merge 		1:1 HHID using `precovid'
		keep 		if _merge==3
		drop 		_merge

		tempfile covid
		save `covid'

		keep 		HHID urban popweight_adult

		tempfile analysis
		save `analysis'

	* combine
		use 		`precovid', clear
		merge 		1:1 HHID using `analysis'
		assert 		_merge==3
		drop 		_merge

		tempfile precovid
		save `precovid'

		use 		`covid', clear
		keep 		HHID urban popweight_adult p_mod p_sev
		gen 		time = 1
		append 		using `precovid'
		encode 		HHID, gen(hhid)

	* determine statistical differences - regressions
		xtset 			hhid time
		xtreg 			p_mod i.time [pweight=popweight_adult], fe
		outreg2 		using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' mod food insecurity) ///
							label noas stats(coef pval ci) ///

		xtreg			p_sev i.time [pweight=popweight_adult], fe
		outreg2 		using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' sev food insecurity) ///
							label noas stats(coef pval ci) ///

restore


*** table s15 ***

local tabnum = `tabnum' + 1

preserve

	rename 					concern_1 concern_01
	rename 					concern_2 concern_02

	drop if 				country == 1 & wave == 2
	drop if 				country == 2 & wave == 1
	drop if 				country == 4 & wave == 1

* summary statistics for concerns
	foreach 				var in concern_01 concern_02 {
	    total 				`var' [pweight = phw]
			local			tn_`var'_ca = e(N)
			local 			ttot_`var'_ca = el(e(b),1,1)
			local 			tsd_`var'_ca = sqrt(el(e(V),1,1))
	}
	foreach 				var in concern_01 concern_02 {
	    foreach 			c in 1 2 3 4 {
		    total 			`var' [pweight = phw] if country == `c'
				local		tn_`var'_c`c' = e(N)
				local 		ttot_`var'_c`c' = el(e(b),1,1)
				local		tsd_`var'_c`c' = sqrt(el(e(V),1,1))
		}
	}

	foreach 				var in concern_01 concern_02 {
		mean				`var' [pweight = phw]
			local 			mmean_`var'_ca = el(e(b),1,1)
			local 			msd_`var'_ca = sqrt(el(e(V),1,1))
	}
	foreach 				var in concern_01 concern_02 {
		forval 				c= 1/4 {
			mean 			`var' [pweight = phw] if country == `c'
				local 		mmean_`var'_c`c' = el(e(b),1,1)
				local		msd_`var'_c`c' = sqrt(el(e(V),1,1))
		}
	}

* create table of stored results
	clear
	set 					obs 5
	gen 					stat = cond(mod(_n,2)!=0,"mean","sd")
	replace 				stat = "n" if _n == 5
	expand 					2
	replace 				stat = "tot" if _n == 3 | _n == 8
	gen 					concern = cond(_n<6,"concern_01","concern_02")
	gen 					func = substr(stat,1,1)
	replace 				func = func[_n-1] if func == "s"
	replace 				func = "t" if func == "n"

	foreach 				c in a 1 2 3 4 {
		gen 				c`c' = .
	}
	foreach 				c in a 1 2 3 4 {
	    foreach 			stat in tot sd n {
			foreach 		con in concern_01 concern_02 {
				replace 	c`c' = `t`stat'_`con'_c`c'' if concern == "`con'" & stat == "`stat'" & func == "t"
			}
		}
	}
	foreach 				c in a 1 2 3 4 {
	    foreach 			stat in mean sd {
			foreach 		con in concern_01 concern_02 {
				replace 	c`c' = `m`stat'_`con'_c`c'' if concern == "`con'" & stat == "`stat'" & func == "m"
			}
		}
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)
restore

*** table s16 ***

local tabnum = `tabnum' + 1

* regression for concerns and food insecurity: moderate

preserve

	rename 					concern_1 concern_01
	rename 					concern_2 concern_02

	drop if 				country == 1 & wave == 2
	drop if 				country == 2 & wave == 1
	drop if 				country == 4 & wave == 1

	reg 					p_mod concern_01 concern_02 ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' concerns & food insec mod) noas stats(coef pval ci) ///
							drop (p_mod)

* Wald test for differences between other countries
	test					1.country = 4.country
	local 					t_mod = r(p)

* regression for concerns and food insecurity: severe

	reg 					p_sev concern_01 concern_02 ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' concerns & food insec sev)	noas stats(coef pval ci) ///
							drop (p_sev)

* Wald test for differences between other countries
	test					1.country = 4.country
	local 					t_sev = r(p)

* create table of stored test results
	clear
	set 					obs 1
	gen 					test = "Ethiopia-Uganda"
	gen 					result_mod = `t_mod'
	gen 					result_sev = `t_sev'
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore

*** table s17 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

* total and mean for any shock 1) for all countries and 2) by country/area
	total					shock_any [pweight = hhw]
		local 				tot_call = el(e(b),1,1)
		local 				tsd_call = sqrt(el(e(V),1,1))
	mean					shock_any [pweight = hhw]
		local 				n_call = e(N)
		local 				mean_call = el(e(b),1,1)
		local 				msd_call = sqrt(el(e(V),1,1))

	forval 					c = 1/4 {
		total					shock_any [pweight = hhw] if country == `c'
			local 				tot_c`c' = el(e(b),1,1)
			local 				tsd_c`c' = sqrt(el(e(V),1,1))
		mean					shock_any [pweight = hhw] if country == `c'
			local 			n_c`c' = e(N)
			local 			mean_c`c' = el(e(b),1,1)
			local 			msd_c`c' = sqrt(el(e(V),1,1))
	}

* create table of stored results
	clear
	set 					obs 5
	gen 					stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
	foreach 				c in 1 2 3 4 all {
		gen 				c`c' = .
		foreach 			s in tot tsd mean msd n {
			replace 			c`c' = ``s'_c`c'' if stat == "`s'"
		}
	}

	export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
						sheetreplace sheet(sumstatsS`tabnum') first(varlabels)
restore


*** table s18 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace					cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1

* total and mean for any, relied on savings, sale of assets, reduced food consumption
  * reduced non_food consumption, assistance from friends & family, any assistance
	foreach 				var in cope_any cope_11 cope_01 cope_09 cope_10 cope_03 asst_any {
	    total 				`var' [pweight = hhw]
			local 			n_`var' = e(N)
			local 			tot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
		mean 				`var' [pweight = hhw]
			local 			mean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
	}

* create table of stored results
	clear
	set 					obs 5
	gen 					stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
	foreach 				var in cope_any cope_11 cope_10 asst_any {
	    gen 				`var' = .
		foreach 			s in tot tsd mean msd n {
			replace 		`var' = ``s'_`var'' if stat == "`s'"
		}
	}
	foreach 				var in 1 9 3 {
	    gen 				cope_0`var' = .
		foreach 			s in tot tsd mean msd n {
			replace 		cope_0`var' = ``s'_cope_`var'' if stat == "`s'"
		}
	}
export 						excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)
restore

*** table S19 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace					cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1

* regressions for cross-country comparisons

* regressions for  relied on savings, sale of assets, reduced food consumption
  * reduced non_food consumption, assistance from friends & family, any assistance
	reg 					cope_10 ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							replace excel dec(3) ctitle(S`tabnum'_cope_10 ) noas stats(coef pval ci) ///
							drop (cope_10)

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				cope_10_t1 = r(p)
		test				1.country = 4.country
		local 				cope_10_t2 = r(p)
		test				3.country = 4.country
		local 				cope_10_t3 = r(p)

	foreach 				var in cope_11 asst_any {
		reg 					`var' ib(2).country [pweight = hhw], vce(robust)
		outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
								append excel dec(3) ctitle(S`tabnum'_`var' ) noas stats(coef pval ci) ///
								drop (`var')

		* Wald test for differences between other countries
			test				1.country = 3.country
			local 				`var'_t1 = r(p)
			test				1.country = 4.country
			local 				`var'_t2 = r(p)
			test				3.country = 4.country
			local 				`var'_t3 = r(p)
	}

	foreach 				var in 1 9 3 {
		reg 				cope_`var' ib(2).country [pweight = hhw], vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum'_cope_0`var') noas stats(coef pval ci) ///
							drop (cope_`var')

		* Wald test for differences between other countries
			test			1.country = 3.country
			local 			cope_`var'_t1 = r(p)
			test			1.country = 4.country
			local 			cope_`var'_t2 = r(p)
			test			3.country = 4.country
			local 			cope_`var'_t3 = r(p)
	}

* create table of stored results
	clear
	set 					obs 3
	gen 					testcountries =  "Ethiopia-Nigeria"
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	foreach					var in cope_11 cope_10 asst_any {
	    gen 				`var' = .
		forval 				t = 1/3 {
		    replace 		`var' = ``var'_t`t'' in `t'
		}
	}
	foreach					var in 1 9 3 {
	    gen 				cope_0`var' = .
		forval 				t = 1/3 {
		    replace 		cope_0`var' = `cope_`var'_t`t'' in `t'
		}
	}
export 						excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore

*** table s20 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace					cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1

* regressions comparing rural urban

* regressions for relied on savings, sale of assets,reduced food consumption, reduced non_food consumption
	* received assistance from friends & family, recieved any assistance
	foreach 				var in cope_11 cope_10 asst_any {
	reg 					`var' i.sector ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum'_`var') noas stats(coef pval ci) ///
							drop (`var')
	}

	foreach 				var in 1 9 3 {
	reg 					cope_`var' i.sector ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum'_cope_0`var') noas stats(coef pval ci) ///
							drop (cope_`var')
	}

restore


* **********************************************************************
* 3b - create Table S21-S22 for Fig. 3B
* **********************************************************************

*** table s21 ***

local tabnum = `tabnum' + 1

* table of means and totals

* total and mean for access to medicine, staple, soap
	foreach 				var in ac_med ac_staple ac_soap {
	    total 				`var' [pweight = hhw] if wave == 1
			local 			n_`var' = e(N)
			local 			tot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
		mean 				`var' [pweight = hhw] if wave == 1
			local 			mean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
	}

* create table of stored results
	preserve
		clear
		set 				obs 5
		gen 				stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
		foreach 			var in ac_med ac_staple ac_soap {
			gen 			`var' = .
			foreach 		s in tot tsd mean msd n {
				replace 	`var' = ``s'_`var'' if stat == "`s'"
			}
		}

		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)

	restore

*** table s22 ***

local tabnum = `tabnum' + 1

* regressions across quintiles

* regression on access to medicine
	reg						ac_med i.quint [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' access to medicine) noas stats(coef pval ci) ///
							drop (ac_med)

	* Wald test for differences between other quintiles
		test				1.quint = 2.quint
		local 				med_t1 = r(p)
		test				1.quint = 3.quint
		local 				med_t2 = r(p)
		test				1.quint = 4.quint
		local 				med_t3 = r(p)
		test				1.quint = 5.quint
		local 				med_t4 = r(p)
		test				2.quint = 3.quint
		local 				med_t5 = r(p)
		test				2.quint = 4.quint
		local 				med_t6 = r(p)
		test				2.quint = 5.quint
		local 				med_t7 = r(p)
		test				3.quint = 4.quint
		local 				med_t8 = r(p)
		test				3.quint =5.quint
		local 				med_t9 = r(p)
		test				4.quint = 5.quint
		local 				med_t10 = r(p)

* regression on access to staple
	reg						ac_staple i.quint [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' access to staple) noas stats(coef pval ci) ///
							drop (ac_staple)

	* Wald test for differences between other quintiles
		test				1.quint = 2.quint
		local 				stap_t1 = r(p)
		test				1.quint = 3.quint
		local 				stap_t2 = r(p)
		test				1.quint = 4.quint
		local 				stap_t3 = r(p)
		test				1.quint = 5.quint
		local 				stap_t4 = r(p)
		test				2.quint = 3.quint
		local 				stap_t5 = r(p)
		test				2.quint = 4.quint
		local 				stap_t6 = r(p)
		test				2.quint = 5.quint
		local 				stap_t7 = r(p)
		test				3.quint = 4.quint
		local 				stap_t8 = r(p)
		test				3.quint =5.quint
		local 				stap_t9 = r(p)
		test				4.quint = 5.quint
		local 				stap_t10 = r(p)

* regression on access to soap
	reg						ac_soap i.quint [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' access to soap) noas stats(coef pval ci) ///
							drop (ac_soap)

	* Wald test for differences between other quintiles
		test				1.quint = 2.quint
		local 				soap_t1 = r(p)
		test				1.quint = 3.quint
		local 				soap_t2 = r(p)
		test				1.quint = 4.quint
		local 				soap_t3 = r(p)
		test				1.quint = 5.quint
		local 				soap_t4 = r(p)
		test				2.quint = 3.quint
		local 				soap_t5 = r(p)
		test				2.quint = 4.quint
		local 				soap_t6 = r(p)
		test				2.quint = 5.quint
		local 				soap_t7 = r(p)
		test				3.quint = 4.quint
		local 				soap_t8 = r(p)
		test				3.quint =5.quint
		local 				soap_t9 = r(p)
		test				4.quint = 5.quint
		local 				soap_t10 = r(p)

* create table of stored results
preserve
	clear
	set 					obs 10
	gen 					testcountries =  cond(_n==1,"Quintiles 1-2","")
	replace 				testcountries = "Quintiles 1-3" in 2
	replace 				testcountries = "Quintiles 1-4" in 3
	replace 				testcountries = "Quintiles 1-5" in 4
	replace 				testcountries = "Quintiles 2-3" in 5
	replace 				testcountries = "Quintiles 2-4" in 6
	replace 				testcountries = "Quintiles 2-5" in 7
	replace 				testcountries = "Quintiles 3-4" in 8
	replace 				testcountries = "Quintiles 3-5" in 9
	replace 				testcountries = "Quintiles 4-5" in 10
	foreach					var in med stap soap {
	    gen 				`var' = .
		forval 				t = 1/10 {
		    replace 		`var' = ``var'_t`t'' in `t'
		}
	}

	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore


* **********************************************************************
* 3c - create Table S23-S24 for Fig. 3A
* **********************************************************************

*** table s23 ***

local tabnum = `tabnum' + 1

* total number of children NOT engaged in Learning Activities After Outbreakover all four countries
	total 					edu_none [pweight = shw] if wave == 1
		local 				n_all = e(N)
		local 				tot_all = el(e(b),1,1)
		local 				tsd_all = sqrt(el(e(V),1,1))

* by country
	forval 					c = 1/4 {
		total 				edu_none [pweight = shw] if wave == 1 & country == `c'
			local 			n_c`c' = e(N)
			local 			tot_c`c' = el(e(b),1,1)
			local 			tsd_c`c' = sqrt(el(e(V),1,1))
	}

* create table of stored results
	preserve
		clear
		set 					obs 3
		gen 					stat = cond(_n==1,"tot",cond(_n==2,"tsd","n"))
		foreach 				var in all c1 c2 c3 c4 {
			gen 				`var' = .
			foreach 			stat in tot tsd n {
				replace 		`var' = ``stat'_`var'' if stat == "`stat'"
			}
		}
		export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
								sheetreplace sheet(sumstatsS`tabnum') first(var)
	restore

*** table s24 ***

local tabnum = `tabnum' + 1

* regression of educational activity on quintile
	reg						edu_act i.quint [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' edu act on quint) noas stats(coef pval ci) ///
							drop (edu_act)

	* Wald test for differences between other quintiles
		test				1.quint = 2.quint
		local 				t1 = r(p)
		test				1.quint = 3.quint
		local 				t2 = r(p)
		test				1.quint = 4.quint
		local 				t3 = r(p)
		test				1.quint = 5.quint
		local 				t4 = r(p)
		test				2.quint = 3.quint
		local 				t5 = r(p)
		test				2.quint = 4.quint
		local 				t6 = r(p)
		test				2.quint = 5.quint
		local 				t7 = r(p)
		test				3.quint = 4.quint
		local 				t8 = r(p)
		test				3.quint =5.quint
		local 				t9 = r(p)
		test				4.quint = 5.quint
		local 				t10 = r(p)

* create table of stored results
preserve
	clear
	set 					obs 10
	gen 					testcountries =  cond(_n==1,"Quintiles 1-2","")
	replace 				testcountries = "Quintiles 1-3" in 2
	replace 				testcountries = "Quintiles 1-4" in 3
	replace 				testcountries = "Quintiles 1-5" in 4
	replace 				testcountries = "Quintiles 2-3" in 5
	replace 				testcountries = "Quintiles 2-4" in 6
	replace 				testcountries = "Quintiles 2-5" in 7
	replace 				testcountries = "Quintiles 3-4" in 8
	replace 				testcountries = "Quintiles 3-5" in 9
	replace 				testcountries = "Quintiles 4-5" in 10
	gen 					pval = .
	forval 					t = 1/10 {
		replace 			pval = `t`t'' in `t'
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore


* **********************************************************************
* 3d - create Figure S3 and Table S25 for Fig. 3D
* **********************************************************************

*** table s25 ***

local tabnum = `tabnum' + 1

* changes in educational activity over time by country
	forval 					c = 1/3 {
		reg					edu_act i.wave [pweight = shw] if country == `c', vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' edu_act country `c') noas stats(coef pval ci) ///
							drop (edu_act)
	}
	foreach 				var in  4 2 3 5 {
	    forval 				c = 1/3 {
			reg				edu_`var' i.wave [pweight = shw] if country == `c', vce(robust)
			outreg2 		using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' edu_0`var' country `c') noas stats(coef pval ci) ///
							drop (edu_`var')
		}
	}


* **********************************************************************
* 7 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */

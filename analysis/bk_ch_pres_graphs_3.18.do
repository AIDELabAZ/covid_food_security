* Project: WB COVID
* Created on: Mar 2020
* Created by: amf
* Edited by: 
* Last edit: Mar 2020
* Stata v.16.1

* does
	* produces supplemental graphs for presentation
	
* assumes
	* cleaned country data
	* catplot
	* grc1leg2
	* palettes
	* colrspace

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	ans		=	"$data/analysis"
	global	output	=	"$output_f/presentation/bkch_update_pres_3.18.21"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/presentation_graphs", append

* read in data
	use				"$ans/lsms_panel", clear

* keep waves included in book chapter 
	keep 				if ((country == 1 | country == 3 ) & wave < 6) | ///
							(country == 2 & wave < 5) | (country == 4 & wave < 4)
							
* waves to month number	
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
	replace 			wave = 6 if wave == 1 & (country == 2 | country == 4)
	replace 			wave = 8 if wave == 2 & country == 4
	replace 			wave = 9 if wave == 3 & country == 4

	lab def 			months 4 "April" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sept"
	lab val				wave months
	lab var 			wave_orig "Original wave number"
	lab var 			wave "Month"

* **********************************************************************
* 1 - current employment
* **********************************************************************

	preserve
		egen 			temp = total(emp), by (country wave)
		keep if 		temp != 0 & country == 1
		graph bar 		(mean) emp [pweight = hhw], ///
							over(wave, gap(10) label(labsize(medlarge))) asyvars bar(1, color(navy*2)) ///
							bar(2, color(brown*1.3)) bar(3, color(maroon*4))  ///
							bar(4, color(stone*2)) bar(5, color(eltgreen*3)) title("Ethiopia", size(medlarge)) ///
							ytitle("Percent generated income in last week", size(small)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6)) name("em1", replace)
	restore
	
	preserve
		egen 			temp = total(emp), by (country wave)
		keep if 		temp != 0 & country == 2
		graph bar 		(mean) emp [pweight = hhw], ///
							over(wave, gap(35) label(labsize(medlarge))) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(cranberry*3)) ///
							title("Malawi", size(medlarge)) outergap(100) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							ytitle("", size(med)) legend(col(4) margin(-1.5 0 0 0) pos(6)) ///
							name("em2", replace)
	restore
	
	preserve
		egen 			temp = total(emp), by (country wave)
		keep if 		temp != 0 & country == 3
		graph bar 		(mean) emp [pweight = hhw], ///
							over(wave, gap(20) label(labsize(medlarge))) asyvars  ///
							bar(1, color(brown*1.3)) bar(2, color(maroon*4)) bar(3, color(cranberry*3)) ///
							bar(4, color(stone*2)) title("Nigeria", size(medlarge)) ///
							ytitle("Percent generated income in last week", size(small)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6)) ///
							name("em3", replace)
	restore
	
	preserve
		egen 			temp = total(emp), by (country wave)
		keep if 		temp != 0 & country == 4
		graph bar 		(mean) emp [pweight = hhw], ///
							over(wave, gap(50) label(labsize(medlarge))) asyvars  ///
							bar(1, color(maroon*4)) bar(2, color(stone*2))  ///
							bar(3, color(eltgreen*3)) title("Uganda", size(medlarge)) outergap(70) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							ytitle("", size(med)) legend(col(3) margin(-1.5 0 0 0) pos(6)) ///
							name("em4", replace)
	restore
	
	
	gr combine			em1 em2 em3 em4, col(2) commonscheme title("")
 								
	graph export 		"$output/cur_emp.png", as(png) replace
	graph export 		"$output/cur_emp.emf", as(emf) replace
	
	mean 				emp [pweight = hhw] if country == 1 & wave == 4
		local 			c1w4 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 1 & wave == 5
		local 			c1w5 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 1 & wave == 6
		local 			c1w6 = el(e(b),1,1)
		local 			c1w7 = 0
	mean 				emp [pweight = hhw] if country == 1 & wave == 8
		local 			c1w8 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 1 & wave == 9
		local 			c1w9 = el(e(b),1,1)
	
		local 			c2w4 = 0
		local 			c2w5 = 0
	mean 				emp [pweight = hhw] if country == 2 & wave == 6
		local 			c2w6 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 2 & wave == 7
		local 			c2w7 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 2 & wave == 8
		local 			c2w8 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 2 & wave == 9
		local 			c2w9 = el(e(b),1,1)
		
		local 			c3w4 = 0
	mean 				emp [pweight = hhw] if country == 3 & wave == 5
		local 			c3w5 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 3 & wave == 6
		local 			c3w6 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 3 & wave == 7
		local 			c3w7 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 3 & wave == 8
		local 			c3w8 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 3 & wave == 9
		local 			c3w9 = el(e(b),1,1)
		
		local 			c4w4 = 0
		local 			c4w5 = 0
	mean 				emp [pweight = hhw] if country == 4 & wave == 6
		local 			c4w6 = el(e(b),1,1)
		local 			c4w7 = 0
	mean 				emp [pweight = hhw] if country == 4 & wave == 8
		local 			c4w8 = el(e(b),1,1)
	mean 				emp [pweight = hhw] if country == 4 & wave == 9
		local 			c4w9 = el(e(b),1,1)
		
	//preserve
		clear
		set obs 9
		gen month = _n
		drop in 1/3
		foreach c in c1 c2 c3 c4{
			gen `c' = .
		}
		forval c = 1/4 {
			forval m = 4/9 {
				replace c`c' = `c`c'w`m'' if month == `m'
			}
		}
		
	
* **********************************************************************
* Employed before outbreak but not working in round 1
* **********************************************************************

	graph bar 			(mean) emp_pre if wave_orig == 1 [pweight = hhw], ///
							over(country, lab(labs(vlarge))) title("", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							name("emp_pre", replace)	
		
	gr combine  		emp_pre, iscale(.5) commonscheme imargin(0 0 0 0)
					
	graph export 		"$output/emp_pre.png", as(png) replace	
	graph export 		"$output/emp_pre.emf", as(emf) replace

	mean 				emp_pre [pweight = hhw] if country == 1 & wave_orig == 1
	mean 				emp_pre [pweight = hhw] if country == 2 & wave_orig == 1
	mean 				emp_pre [pweight = hhw] if country == 3 & wave_orig == 1
	mean 				emp_pre [pweight = hhw] if country == 4 & wave_orig == 1

	
* **********************************************************************
* Same employment 
* **********************************************************************

	preserve
		egen 			temp = total(emp_same), by (country wave)
		keep if 		temp != 0 & country == 1
		graph bar 		(mean) emp_same [pweight = hhw], ///
							over(wave, gap(10) label(labsize(medlarge))) asyvars bar(1, color(navy*2)) ///
							bar(2, color(brown*1.3)) bar(3, color(maroon*4))  ///
							bar(4, color(stone*2)) bar(5, color(eltgreen*3)) title("Ethiopia", size(medlarge)) ///
							ytitle("Percent of employed individuals with same job", size(small)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6)) name("em_same1", replace)
	restore
	
	preserve
		egen 			temp = total(emp_same), by (country wave)
		keep if 		temp != 0 & country == 2
		graph bar 		(mean) emp_same [pweight = hhw], ///
							over(wave, gap(35) label(labsize(medlarge))) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(cranberry*3)) ///
							title("Malawi", size(medlarge)) outergap(100) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							ytitle("", size(med)) legend(col(4) margin(-1.5 0 0 0) pos(6)) ///
							name("em_same2", replace)
	restore
	
	preserve
		egen 			temp = total(emp_same), by (country wave)
		keep if 		temp != 0 & country == 3
		graph bar 		(mean) emp_same [pweight = hhw], ///
							over(wave, gap(20) label(labsize(medlarge))) asyvars  ///
							bar(1, color(brown*1.3)) bar(2, color(maroon*4)) bar(3, color(cranberry*3)) ///
							bar(4, color(stone*2)) title("Nigeria", size(medlarge)) ///
							ytitle("Percent of employed individuals  with same job", size(small)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6)) ///
							name("em_same3", replace)
	restore
	
	preserve
		egen 			temp = total(emp_same), by (country wave)
		keep if 		temp != 0 & country == 4
		graph bar 		(mean) emp_same [pweight = hhw], ///
							over(wave, gap(50) label(labsize(medlarge))) asyvars  ///
							bar(1, color(maroon*4)) bar(2, color(stone*2))  ///
							bar(3, color(eltgreen*3)) title("Uganda", size(medlarge)) outergap(70) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							ytitle("", size(med)) legend(col(3) margin(-1.5 0 0 0) pos(6)) ///
							name("em_same4", replace)
	restore
	
	
	gr combine			em_same1 em_same2 em_same3 em_same4, col(2) commonscheme title("")
 								
	graph export 		"$output/emp_same.png", as(png) replace
	graph export 		"$output/emp_same.emf", as(emf) replace




















	
	
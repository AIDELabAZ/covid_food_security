* Project: WB COVID
* Created on: Jan 2020
* Created by: amf
* Edited by: 
* Last edit: January 2020
* Stata v.16.1

* does
	* produces graphs for paper chapter
	
* assumes
	* cleaned country data
	* catplot
	* grc1leg2
	* palettes
	* colrspace

* TO DO:
	* done


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	ans		=	"$data/analysis"
	global	output	=	"$output_f/book_chapter/figures/updated_July21"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/presentation_graphs", append

* read in data
	use				"$ans/lsms_panel", clear

* waves to month number	
	drop 				if wave == 0
	gen 				wave_orig = wave

	replace 			wave = 14 if wave_orig == 10 & country == 1
	replace 			wave = 13 if wave_orig == 9 & country == 1
	replace 			wave = 12 if wave_orig == 8 & country == 1
	replace 			wave = 11 if wave_orig == 7 & country == 1
	replace 			wave = 10 if wave_orig == 6 & country == 1
	replace 			wave = 9 if wave_orig == 5 & country == 1
	replace 			wave = 8 if wave_orig == 4 &  country == 1
	replace 			wave = 6 if wave_orig == 3 & country == 1
	replace 			wave = 5 if wave_orig == 2 & country == 1
	replace 			wave = 4 if wave_orig == 1 & country == 1
	
	replace 			wave = 18 if wave_orig == 11 & country == 2
	replace 			wave = 17 if wave_orig == 10 & country == 2
	replace 			wave = 16 if wave_orig == 9 & country == 2
	replace 			wave = 15 if wave_orig == 8 & country == 2
	replace 			wave = 13 if wave_orig == 7 & country == 2
	replace 			wave = 12 if wave_orig == 6 & country == 2
	replace 			wave = 11 if wave_orig == 5 & country == 2
	replace 			wave = 9 if wave_orig == 4 & country == 2
	replace 			wave = 8 if wave_orig == 3 & country == 2 
	replace 			wave = 7 if wave_orig == 2 & country == 2
	replace 			wave = 6 if wave_orig == 1 & country == 2 
	
	replace 			wave = 14 if wave_orig == 10 & country == 3 
	replace 			wave = 13 if wave_orig == 9 & country == 3 
	replace 			wave = 12 if wave_orig == 8 & country == 3 
	replace 			wave = 11 if wave_orig == 7 & country == 3 
	replace 			wave = 10 if wave_orig == 6 & country == 3 
	replace 			wave = 9 if wave_orig == 5 & country == 3 
	replace 			wave = 8 if wave_orig == 4 & country == 3 
	replace 			wave = 7 if wave_orig == 3 & country == 3
	replace 			wave = 6 if wave_orig == 2 & country == 3
	replace 			wave = 5 if wave_orig == 1 & country == 3
	
	replace 			wave = 14 if wave_orig == 5 & country == 4	
	replace 			wave = 11 if wave_orig == 4 & country == 4
	replace 			wave = 9 if wave_orig == 3 & country == 4
	replace 			wave = 8 if wave_orig == 2 & country == 4
	replace 			wave = 6 if wave_orig == 1 & country == 4
	
	replace 			wave = 19 if wave_orig == 10 & country == 5
	replace 			wave = 16 if wave_orig == 9 & country == 5
	replace 			wave = 15 if wave_orig == 8 & country == 5 
	replace 			wave = 14 if wave_orig == 7 & country == 5 
	replace 			wave = 13 if wave_orig == 6 & country == 5 
	replace 			wave = 12 if wave_orig == 5 & country == 5	
	replace 			wave = 11 if wave_orig == 4 & country == 5
	replace 			wave = 10 if wave_orig == 3 & country == 5
	replace 			wave = 8 if wave_orig == 2 & country == 5
	replace 			wave = 6 if wave_orig == 1 & country == 5
	
	lab def 			months 4 "Apr20" 5 "May20" 6 "Jun20" 7 "Jul20" 8 "Aug20" 9 "Sep20" 10 "Oct20" ///
							11 "Nov20" 12 "Dec20" 13 "Jan21" 14 "Feb21" 15 "Mar21" 16 "Apr21" ///
							17 "May21" 18 "May21" 19 "Jun21"
	lab val				wave months
	lab var 			wave_orig "Original wave number"
	lab var 			wave "Month"

	
* **********************************************************************
* 1 - behavior
* **********************************************************************

* wave 1 all countries 
	graph bar 			(mean) bh_3 bh_1 bh_2 if wave_orig == 1 [pweight = phw_cs], ///
							over(country, lab(labs(vlarge))) title("", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") pos(6) col(3) ///
							size(medsmall) margin(-1.5 0 0 0)) name(bh_w1, replace)
		
	grc1leg2   			bh_w1, iscale(.5) commonscheme imargin(0 0 0 0) legend()
					
	graph export 		"$output/behavior_w1.png", as(png) replace	
	graph export 		"$output/behavior_w1.emf", as(emf) replace
		
	
* over waves in mwi, uga, & bf
	preserve
	gen 				temp = 1 if bh_1 < . | bh_2 < . | bh_3 < . | bh_8 < . 
	egen 				temp1 = max(temp), by(country wave) 
	keep 				if temp1 == 1
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 1 [pweight = phw_cs], ///
							over(wave, lab(labs(medlarge)) gap(250))  title("Ethiopia", size(vlarge)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5)) outergap(650) ///
							ytitle("Percent of individuals", margin(0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(4) ///
							size(vsmall) margin(-1.5 0 0 0)) name(bh1, replace)
	restore

	preserve
	gen 				temp = 1 if bh_1 < . | bh_2 < . | bh_3 < . | bh_8 < . 
	egen 				temp1 = max(temp), by(country wave) 
	keep 				if temp1 == 1
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 2 [pweight = phw_cs], ///
							over(wave, lab(labs(med)))  title("Malawi", size(vlarge)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5)) outergap(50) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(4) ///
							size(vsmall) margin(-1.5 0 0 0)) name(bh2, replace)
	restore 
	
	preserve
	gen 				temp = 1 if bh_1 < . | bh_2 < . | bh_3 < . | bh_8 < . 
	egen 				temp1 = max(temp), by(country wave) 
	keep 				if temp1 == 1
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 4 [pweight = phw_cs], ///
							over(wave, lab(labs(medlarge))) title("Uganda", size(vlarge)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5)) outergap(450) ///
							ytitle("Percent of individuals", margin(0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(4) ///
							size(vsmall) margin(-1.5 0 0 0)) name(bh4, replace)
	restore 
	
	preserve 
	gen 				temp = 1 if bh_1 < . | bh_2 < . | bh_3 < . | bh_8 < . 
	egen 				temp1 = max(temp), by(country wave) 
	keep 				if temp1 == 1
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 5 [pweight = phw_cs], ///
							over(wave, lab(labs(medlarge))) title("Burkina Faso", size(vlarge)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5))  outergap(650) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(4) ///
							size(vsmall) margin(-1.5 0 0 0)) name(bh5, replace)
	restore 
	
	grc1leg2   			bh1 bh2 bh4 bh5, col(2) iscale(.5) commonscheme imargin(0 0 0 0) legend()
		
	graph export 		"$output/behavior_waves.png", as(png) replace
	graph export 		"$output/behavior_waves.emf", as(emf) replace

			
* **********************************************************************
* 2 - myths (wave 1 only)
* **********************************************************************

	preserve

	drop if				country == 1 | country == 3 | country == 5
	keep 				myth_2 myth_3 myth_4 myth_5 country phw_cs
	gen 				id=_n
	ren 				(myth_2 myth_3 myth_4 myth_5) (size=)
	reshape long 		size, i(id) j(myth) string
	drop if 			size == .
	drop if				size == 3

	catplot 			size country myth [aweight = phw_cs], percent(country myth) stack ///
							ytitle("Percent", size(vlarge)) var1opts(label(labsize(vlarge))) ///
							var2opts(label(labsize(vlarge))) var3opts(label(labsize(large)) ///
							relabel (1 `""Africans are immune" "to coronavirus"""' ///
							2 `""Coronavirus does not" "affect children"""' ///
							3 `""Coronavirus cannot survive" "warm weather""' ///
							4 `""Coronavirus is just" "common flu""'))  ///
							ylabel(, labs(vlarge)) bar(1, color(khaki*1.5) ) ///
							bar(2, color(emerald*1.5) ) legend(label (2 "True") ///
							label (1 "False") pos(6) col(2) margin(-1.5 0 0 0) ///
							size(medsmall)) name(myth, replace)

	restore
	
	grc1leg2  		 	myth, col(3) iscale(.5) commonscheme ///
							imargin(0 0 0 0) legend()	
			
	graph export 		"$output/myth.png", as(png) replace
	graph export 		"$output/myth.emf", as(emf) replace
	
	
* **********************************************************************
* 3 - income 
* **********************************************************************

* generate means by country and wave for each income source
	egen 				cw = group(country wave)
	egen 				temp = max(farm_dwn), by(cw)
	levelsof 			cw if temp != ., local(cw) 
	foreach 			var in  farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
		gen 				`var'_mean = .
	}	
	foreach 			x in `cw' {
		foreach 			var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {  
			quietly: mean 		`var' [pweight = hhw_cs] if cw == `x'
			replace 			`var'_mean = el(e(b),1,1) if cw == `x' 
		}
		}
	
	
	preserve
	keep 				if country == 1
	keep 				if temp != .
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 1, sort(wave) title("Ethiopia", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("")  legend( label (1 "Farm income") ///
							label (2 "Business income") label (3 "Wage income") label (4 "Remittances") ///
							label (5 "All else") pos(6) col(3) size(medsmall) margin(-1.5 0 0 0)) ///
							xlabel(4 "Apr20" 5 "May20" 6 "Jun20" 7 "Jul20" 8 "Aug20" 9 "Sep20" 10 "Oct20" , ///
							nogrid labs(med)) name(inc1, replace)
	restore			
	
	preserve
	keep 				if country == 2
	keep 				if temp != .
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 2, sort(wave) title("Malawi", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) xtitle("") ///
							xlabel(6 "Jun20" 7 "Jul20" 8 "Aug20" 9 "Sep20" 10 "Oct20" 11 "Nov20" 12 "Dec20" 13 "Jan21" ///
							14 "Feb21" 15 "Mar21" 16 "Apr21" 17 "May21" 18 "May21", nogrid labs(small)) name(inc2, replace)
	restore			
	
	preserve
	keep 				if country == 3
	keep 				if temp != .
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 3, sort(wave) title("Nigeria", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(5 "May20" 6 "Jun20" 7 "Jul20" 8 "Aug20"9 "Sep20" 10 "Oct20" 11 "Nov20" 12 ///
							"Dec20" 13 "Jan21", nogrid labs(med)) name(inc3, replace)
	restore			
	
	preserve
	keep 				if country == 4	
	keep 				if temp != .
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 4, sort(wave) title("Uganda", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) xtitle("") ///
							xlabel(6 "Jun20" 7 "Jul20" 8 "Aug20" 9 "Sep20"  10 "Oct20" 11 "Nov20" 12 "Dec20" ///
							13 "Jan21" 14 "Feb21", nogrid labs(med)) name(inc4, replace)
	restore 
	
	drop 				temp
	
	grc1leg2 			inc1 inc2 inc3 inc4, col(2) iscale(.5) commonscheme 
	
	graph export 		"$output/income_all_line.png", as(png) replace
	graph export 		"$output/income_all_line.emf", as(emf) replace

	
* **********************************************************************
* 4 - business revenue
* **********************************************************************

	preserve

	keep 				bus_emp_inc country wave hhw_cs
	replace				bus_emp_inc = 3 if bus_emp_inc == 4
	gen 				id=_n
	ren 				(bus_emp_inc) (size=)
	reshape long 		size, i(id) j(bus_emp_inc) string
	drop if 			size == .

	* reverse order of vars
	replace 			size = 4 if size == 1
	replace 			size = 1 if size == 3
	replace 			size = 3 if size == 4

	catplot 			size wave country [aweight = hhw] if country == 1, percent(country wave) stack ///
							var1opts(label(labsize(medsmall))) var3opts(label(labsize(medsmall))) ///
							var2opts(label(labsize(vsmall)))  ///
							ytitle("", size(vlarge)) bar(3, color(sandb*1.3)) ///
							bar(2, color(dkorange*1.2)) bar(1, color(red*1.7)) ///
							ylabel(, labs(medsmall)) legend(label (3 "Higher than before") label (2 "Same as before") ///
							label (1 "Less than before") pos(6) col(3) ///
							size(vsmall) margin(-1.5 0 0 0)) name(bus1, replace)

	catplot 			size wave country [aweight = hhw] if country == 2, percent(country wave) stack ///
							var1opts(label(labsize(medsmall))) var3opts(label(labsize(medsmall))) ///
							var2opts(label(labsize(vsmall))) ///
							ytitle("", size(vlarge)) bar(3, color(sandb*1.3)) ///
							bar(2, color(dkorange*1.2)) bar(1, color(red*1.7)) ///
							ylabel(, labs(medsmall)) legend(off) name(bus2, replace)

	catplot 			size wave country [aweight = hhw] if country == 3, percent(country wave) stack ///
							var1opts(label(labsize(medsmall))) var3opts(label(labsize(medsmall))) ///
							var2opts(label(labsize(vsmall))) ///
							ytitle("", size(vlarge)) bar(3, color(sandb*1.3)) ///
							bar(2, color(dkorange*1.2)) bar(1, color(red*1.7)) ///
							ylabel(, labs(medsmall)) legend(off) name(bus3, replace)

	catplot 			size wave country [aweight = hhw] if country == 4, percent(country wave) stack ///
							var1opts(label(labsize(medsmall))) var3opts(label(labsize(medsmall))) ///
							var2opts(label(labsize(vsmall))) ///
							ytitle("", size(huge)) bar(3, color(sandb*1.3)) ///
							bar(2, color(dkorange*1.2)) bar(1, color(red*1.7)) ///
							ylabel(, labs(medsmall)) legend(off) name(bus4, replace)

	catplot 			size wave country [aweight = hhw] if country == 5, percent(country wave) stack ///
							var1opts(label(labsize(medsmall))) var3opts(label(labsize(small))) ///
							var2opts(label(labsize(vsmall))) ///
							ytitle("", size(huge)) bar(3, color(sandb*1.3)) ///
							bar(2, color(dkorange*1.2)) bar(1, color(red*1.7)) ///
							ylabel(, labs(medsmall)) legend(off) name(bus5, replace)
							
	restore

	grc1leg2 			bus1 bus2 bus3 bus4 bus5, col(1) iscale(.5) commonscheme imargin(0 0 0 0) 
						
	graph export 		"$output/bus_emp_inc.png", as(png) replace
	graph export 		"$output/bus_emp_inc.emf", as(emf) replace
	
	
* **********************************************************************
* 4 - current employment of respondent
* **********************************************************************

	graph bar 			(mean) emp [pweight = ahw_cs] if country == 1, over(wave, gap(50)) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(stone*2)) bar(3, color(eltgreen*2)) ///
							bar(4, color(teal*5)) bar(5, color(khaki*3)) bar(6, color(cranberry*4)) ///
							bar(7, color(purple*4)) bar(8, color(brown*3)) bar(9, color(emerald*4)) ///
							title("Ethiopia", size(vlarge)) outergap(70) ///
							ytitle("Percent generated income last week", size(medlarge) margin(-12 0 0 0)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", ///
							labs(medlarge)) legend(col(10) margin(-1.5 0 0 0) pos(6) size(small)) ///
							name(cur_emp1, replace)			
		
	graph bar 			(mean) emp [pweight = ahw_cs] if country == 2, over(wave, gap(50)) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(navy*3)) bar(3, color(teal*5)) ///
							bar(4, color(khaki*3)) bar(5, color(purple*4)) bar(6, color(brown*3)) ///
							bar(7, color(emerald*4)) bar(8, color(erose*4)) bar(9, color(maroon*2.5)) ///
							bar(10, color(dknavy*3)) title("Malawi", size(vlarge)) outergap(70) ///
							ytitle("", size(med)) ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", ///
							labs(medlarge)) legend(col(10) margin(-1.5 0 0 0) pos(6) size(small)) ///
							name(cur_emp2, replace)	
	
	graph bar 			(mean) emp [pweight = ahw_cs] if country == 3, over(wave, gap(50)) asyvars ///
							bar(1, color(stone*2)) bar(2, color(eltgreen*2)) bar(3, color(navy*3)) ///
							bar(4, color(teal*5)) bar(5, color(khaki*3)) bar(6, color(cranberry*4)) ///
							bar(7, color(purple*4)) bar(8, color(brown*3)) bar(9, color(emerald*4)) ///
							bar(10, color(emidblue*4)) title("Nigeria", size(vlarge)) outergap(70) ///
							ytitle("", size(med)) ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", ///
							labs(medlarge)) legend(col(10) margin(-1.5 0 0 0) pos(6) size(small)) ///
							name(cur_emp3, replace)	
					
	graph bar 			(mean) emp [pweight = ahw_cs] if country == 4, over(wave, gap(70)) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(teal*5)) bar(3, color(khaki*3))  ///
							bar(4, color(purple*4)) bar(5, color(emidblue*4)) /// 
							title("Uganda", size(vlarge)) outergap(150) ///
							ytitle("Percent generated income last week", size(medlarge) margin(-5 0 0 0)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", ///
							labs(medlarge)) legend(col(10) margin(-1.5 0 0 0) pos(6) size(small)) ///
							name(cur_emp4, replace)	graphregion(margin(l 70))

	graph bar 			(mean) emp [pweight = ahw_cs] if country == 5, over(wave, gap(40)) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(teal*5)) bar(3, color(cranberry*4)) ///
							bar(4, color(purple*4)) bar(5, color(brown*3)) bar(6, color(emerald*4)) ///
							bar(7, color(emidblue*4)) bar(8, color(erose*4)) bar(9, color(maroon*2.5)) ///
							bar(10, color(edkblue*2)) title("Burkina Faso", size(vlarge)) outergap(70) ///
							ytitle("", size(med)) ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", ///
							labs(medlarge)) legend(col(10) margin(-1.5 0 0 0) pos(6) size(small)) ///
							name(cur_emp5, replace)	graphregion(margin(r 70))
	
	graph combine 			cur_emp1 cur_emp2 cur_emp3, name(row1x, replace) row(1) 
	graph combine 			cur_emp4 cur_emp5, name(row2x, replace) row(1) 
	graph combine 			row1x row2x, cols(1) iscale(.5) commonscheme 		
					
	graph export 		"$output/cur_emp.png", as(png) replace
	graph export 		"$output/cur_emp.emf", as(emf) replace
	
	
* **********************************************************************
* 4 - food insecurity 
* **********************************************************************
		
	forval 				w = 5/11 {
		gen 			p_mod_`w' = p_mod if wave == `w'
	}

	
	graph bar 			(mean) p_mod_5 p_mod_6 p_mod_7 p_mod_8 p_mod_9 p_mod_10 p_mod_11  ///
							[pweight = wt_18], over(country, gap(*7) lab(labs(vlarge)))  ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							ytitle("Prevalence", size(vlarge)) bar(1, color(navy*1.5))  ///
							bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) bar(4, color(brown*2.3)) ///
							 bar(5, color(eltgreen*5)) bar(6, color(maroon*3)) bar(7, color(erose*2)) ///
							legend(label (1 "May20") label (2 "Jun20") label (3 "Jul20") label (4 "Aug20") ///
							label (5 "Sep20") label (6 "Oct20") label (7 "Nov20") col(7) margin(-1.5 0 0 0)) ///
							name(fies, replace)

	grc1leg2 			fies, iscale(.5) pos(6) commonscheme 

	graph export 		"$output/fies.png", as(png) replace
	graph export 		"$output/fies.emf", as(emf) replace
	
	* sig tests
	reg					p_mod i.wave [pweight = wt_18] if country == 2
		test 			6.wave = 8.wave
	reg					p_mod i.wave [pweight = wt_18] if country == 4
		test 			6.wave = 8.wave
	
	mean 				p_mod [pweight = wt_18] if wave == 6
	mean 				p_mod [pweight = wt_18] if wave == 8
	total 				p_mod [pweight = wt_18] if wave == 6
	di					%18.3fc _b[p_mod]
	total 				p_mod [pweight = wt_18] if wave == 8 
	di					%18.3fc _b[p_mod]
	
	
* **********************************************************************
* 5 - concerns 
* **********************************************************************

* first wave with data available
	preserve 
	keep 				if (country == 1 & wave == 6) | (country == 2 & wave == 6) | ///
							(country == 3 & wave == 5) | (country == 4 & wave == 6)
	
	replace 			wave = 1
								
	catplot 			concern_1 wave [aweight = hhw_cs], over(country) percent(country wave) stack ///
							title("Concerned that family or self will fall ill with COVID-19 (%)", size(large)) ///
							var1opts(label(labsize(large)) sort(1) descending) ///
							legend(col(2) margin(-1.5 0 0 0) order(2 "Yes" 1 "No")) var2opts(label(nolab)) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc1, replace)
							
	catplot 			concern_2 wave [aweight = hhw_cs], over(country) percent(country wave) stack ///
							title("Concerned about the financial threat of COVID-19 (%)", size(large)) ///
							var1opts(label(labsize(large)) sort(1) descending) ///
							legend(col(2) margin(-1.5 0 0 0)) var2opts(label(nolab)) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc2, replace)					

	restore 
	
	grc1leg2 			conc1 conc2, col(1) iscale(.5) commonscheme imargin(0 0 0 0)
														
	graph export 		"$output/concerns_w1.png", as(png) replace
	graph export 		"$output/concerns_w1.emf", as(emf) replace

* over waves in mwi, nga, uga 
	catplot 			concern_1 wave country [aweight = hhw_cs] if country == 2, percent(country wave) stack ///
							var1opts(label(labsize(large)) sort(1) descending) var3opts(label(labsize(large))) ///
							legend(col(2) margin(-1.5 0 0 0) order(2 "Yes" 1 "No")) var2opts(label(labsize(med))) ///
							title("Concerned that family or self will fall ill with COVID-19 (%)", size(large)) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc1_mwi, replace)	
							
	catplot 			concern_1 wave country [aweight = hhw_cs] if country == 3, percent(country wave) stack ///
							var1opts(label(labsize(large)) sort(1) descending) var3opts(label(labsize(large))) ///
							legend(col(2) margin(-1.5 0 0 0)) var2opts(label(labsize(med))) outergap(250) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc1_nga, replace)	
	
	catplot 			concern_1 wave country [aweight = hhw_cs] if country == 4, percent(country wave) stack ///
							var1opts(label(labsize(large)) sort(1) descending) var3opts(label(labsize(large))) ///
							legend(col(2) margin(-1.5 0 0 0)) var2opts(label(labsize(med))) outergap(150) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc1_uga, replace)	

	grc1leg2 			conc1_mwi conc1_nga conc1_uga, col(1) iscale(.5) commonscheme imargin(0 0 0 0)
							
	graph export 		"$output/concern1_waves.png", as(png) replace
	graph export 		"$output/concern1_waves.emf", as(emf) replace

	catplot 			concern_2 wave country [aweight = hhw_cs] if country == 2, percent(country wave) stack ///
							var1opts(label(labsize(large)) sort(1) descending) var3opts(label(labsize(large))) ///
							legend(col(2) margin(-1.5 0 0 0) order(2 "Yes" 1 "No")) var2opts(label(labsize(med))) ///
							title("Concerned about the financial threat of COVID-19 (%)", size(large)) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc2_mwi, replace)	
							
	catplot 			concern_2 wave country [aweight = hhw_cs] if country == 3, percent(country wave) stack ///
							var1opts(label(labsize(large)) sort(1) descending) var3opts(label(labsize(large))) ///
							legend(col(2) margin(-1.5 0 0 0)) var2opts(label(labsize(med))) outergap(250) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc2_nga, replace)	
	
	catplot 			concern_2 wave country [aweight = hhw_cs] if country == 4, percent(country wave) stack ///
							var1opts(label(labsize(large)) sort(1) descending) var3opts(label(labsize(large))) ///
							legend(col(2) margin(-1.5 0 0 0)) var2opts(label(labsize(med))) outergap(150) ///
							ytitle("", size(vlarge)) bar(2, color(maroon*1.5)) bar(1, color(stone*1.3)) ///
							ylabel(, labs(large)) name(conc2_uga, replace)

	grc1leg2 			conc2_mwi conc2_nga conc2_uga, col(1) iscale(.5) commonscheme imargin(0 0 0 0)
								
	graph export 		"$output/concern2_waves.png", as(png) replace
	graph export 		"$output/concern2_waves.emf", as(emf) replace
						

* **********************************************************************
* 6 - coping
* **********************************************************************
	
	preserve 
	egen 				temp = total(cope_none), by (country wave)
	keep if 			temp != 0 & country == 1
	graph bar			(mean) cope_11 cope_9 cope_10 cope_3 cope_1 cope_none [pweight = hhw_cs] ///
							if country == 1, over(wave, label(labsize(medlarge))) ///
							title("Ethiopia", size(vlarge)) ///
							bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
							bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
							bar(5, color(erose*1.5)) bar(6, color(eltgreen*5))  ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							ytitle("Percent of households", size(large)) ///
							legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
							label (3 "Reduced non-food cons.") label (4 "Help from family") ///
							label (5 "Sale of asset") label (6 "Did nothing") /// 
							size(small) pos(6) col(2) margin(-1.5 0 0 0)) name(cope1, replace)
	restore
	
	preserve 
	egen 				temp = total(cope_none), by (country wave)
	keep if 			temp != 0 & country == 2
	graph bar			(mean) cope_11 cope_9 cope_10 cope_3 cope_1 cope_none [pweight = hhw_cs] ///
						if country == 2, over(wave, label(labsize(medlarge))) ///
						title("Malawi", size(vlarge)) outergap(200) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(eltgreen*5))  ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("", size(large)) ///
						legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
						label (3 "Reduced non-food cons.") label (4 "Help from family") ///
						label (5 "Sale of asset") label (6 "Did nothing") /// 
						size(small) pos(6) col(2) margin(-1.5 0 0 0)) name(cope2, replace)
	restore
	
	preserve 
	egen 				temp = total(cope_none), by (country wave)
	keep if 			temp != 0 & country == 3
	graph bar			(mean) cope_11 cope_9 cope_10 cope_3 cope_1 cope_none [pweight = hhw_cs] ///
						if country == 3, over(wave, label(labsize(medlarge))) ///
						title("Nigeria", size(vlarge)) outergap(200) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(eltgreen*5))  ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Percent of households", size(large)) ///
						legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
						label (3 "Reduced non-food cons.") label (4 "Help from family") ///
						label (5 "Sale of asset") label (6 "Did nothing") /// 
						size(small) pos(6) col(2) margin(-1.5 0 0 0)) name(cope3, replace)
	restore
	
	preserve 
	egen 				temp = total(cope_none), by (country wave)
	keep if 			temp != 0 & country == 4
	graph bar			(mean) cope_11 cope_9 cope_10 cope_3 cope_1 cope_none [pweight = hhw_cs] ///
						if country == 4, over(wave, label(labsize(medlarge))) ///
						title("Uganda", size(vlarge)) outergap(700) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(eltgreen*5))  ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("", size(large)) ///
						legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
						label (3 "Reduced non-food cons.") label (4 "Help from family") ///
						label (5 "Sale of asset") label (6 "Did nothing") /// 
						size(small) pos(6) col(2) margin(-1.5 0 0 0)) name(cope4, replace)
	restore
	
	preserve 
	egen 				temp = total(cope_none), by (country wave)
	keep if 			temp != 0 & country == 5
	graph bar			(mean) cope_11 cope_9 cope_10 cope_3 cope_1 cope_none [pweight = hhw_cs] ///
						if country == 5, over(wave, label(labsize(medlarge))) ///
						title("Burkina Faso", size(vlarge)) outergap(100) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(eltgreen*5))  ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Percent of households", size(large)) ///
						legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
						label (3 "Reduced non-food cons.") label (4 "Help from family") ///
						label (5 "Sale of asset") label (6 "Did nothing") /// 
						size(small) pos(6) col(2) margin(-1.5 0 0 0)) name(cope5, replace)
	restore 
	
	grc1leg 			cope1 cope2 cope3 cope4 cope5, hole(6) col(2) iscale(.5) commonscheme
	gr_edit 			.legend.DragBy 19 39
						
	graph export 		"$output/cope.png", as(png) replace
	graph export 		"$output/cope.emf", as(emf) replace
	
					
* **********************************************************************
* 7 - assistance
* **********************************************************************
		
	forval 					c = 1/5 {
	    preserve 
		* excluding months with no data 
		egen 				temp = total(asst_any), by (country wave)
		keep if 			temp != 0 & country == `c'
		if 					`c' == 1 {
			local 			country = "Ethiopia"
			local 			ytitle = "Percent of households"
		} 
		else if 			`c' == 2 {
			local 			country = "Malawi"
			local 			ytitle = ""
		}
		else if 			`c' == 3 {
			local 			country = "Nigeria"
			local 			ytitle = "Percent of households"
		} 
		else 				if `c' == 4 {
			local 			country = "Uganda"
			local 			ytitle = ""
		}
		else 				if `c' == 5 {
			local 			country = "Burkina Faso"
			local 			ytitle = "Percent of households"
		}
		drop 			if country == 5 & wave_orig == 2
	graph bar			(mean) asst_cash asst_food asst_kind asst_any [pweight = hhw_cs] ///
							if country == `c', over(wave, label(labsize(medlarge))) ///
							title("`country'", size(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							ytitle("`ytitle'", size(large)) ///
							legend(label (1 "Cash") label (2 "Food") label (3 "In-kind") ///
							label (4 "Any assistance") size(medsmall) pos(6) col(2) ///
							margin(-1.5 0 0 0)) name(asst_`c', replace)
		restore 
	}
	grc1leg2 			asst_1 asst_2 asst_3 asst_4 asst_5, col(2) iscale(.5) commonscheme
	gr_edit 			.legend.DragBy 20 35
	
	graph export 		"$output/asst.png", as(png) replace
	graph export 		"$output/asst.emf", as(emf) replace
	
	reg 				asst_any i.wave [pweight = hhw_cs] if country == 4
		test 			6.wave = 9.wave
		test 			6.wave = 8.wave
	
	
* **********************************************************************
* 8 - access to staple foods and medical services
* **********************************************************************

* medical services 
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 1
		graph bar 		(mean) ac_medserv [pweight = phw_cs], ///
							over(wave, gap(10) label(labsize(vlarge))) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(stone*2)) bar(3, color(eltgreen*2)) ///
							bar(4, color(teal*5)) bar(5, color(khaki*3)) bar(6, color(cranberry*4)) ///
							title("Ethiopia", size(vlarge)) ///
							ytitle("Percent unable to access", size(large) margin(-7 0 0 0)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(6) margin(-1.5 0 0 0) pos(6) size(medlarge)) name(ac_medserv1, replace)
	restore
	
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 2
		graph bar 		(mean) ac_medserv [pweight = phw_cs], ///
							over(wave, gap(10) label(labsize(vlarge))) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(navy*3)) ///
							bar(3, color(purple*4)) bar(4, color(brown*3)) ///
							bar(5, color(emerald*4)) bar(6, color(erose*4)) ///
							title("Malawi", size(vlarge))  ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							ytitle("", size(med)) legend(col(8) margin(-1.5 0 0 0) pos(6) size(med)) ///
							name(ac_medserv2, replace)
	restore
	
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 3
		graph bar 		(mean) ac_medserv [pweight = phw_cs], outergap(100) ///
							over(wave, gap(40) label(labsize(vlarge))) asyvars  ///
							bar(1, color(stone*2)) bar(2, color(eltgreen*2)) bar(3, color(navy*3)) ///
							bar(4, color(teal*5)) title("Nigeria", size(vlarge)) ///
							ytitle("", size(med)) ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(4) margin(-1.5 0 0 0) pos(6) size(medlarge)) name(ac_medserv3, replace)
	restore
	
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 4
		graph bar 		(mean) ac_medserv [pweight = phw_cs], ///
							over(wave, gap(20) label(labsize(vlarge))) asyvars  ///
							bar(1, color(eltgreen*2)) bar(2, color(teal*5)) bar(3, color(khaki*3))  ///
							bar(4, color(purple*4)) bar(5, color(emidblue*4)) ///
							title("Uganda", size(vlarge)) outergap(50) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							ytitle("Percent unable to access", size(large)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6) size(medlarge)) ///
							name(ac_medserv4, replace) graphregion(margin(70 1))
	restore
	
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 5
		graph bar 		(mean) ac_medserv [pweight = phw_cs],  ///
							over(wave, gap(60) label(labsize(vlarge))) asyvars ///
							bar(1, color(brown*3)) bar(2, color(emerald*4)) ///
							bar(3, color(emidblue*4)) title("Burkina Faso", size(vlarge)) outergap(70) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							ytitle("", size(med)) legend(col(5) margin(-1.5 0 0 0) pos(6) size(medlarge)) ///
							name(ac_medserv5, replace) graphregion(margin(r 70))
	restore
	
	graph combine 			ac_medserv1 ac_medserv2 ac_medserv3, name(row1, replace) row(1) 
	graph combine 			ac_medserv4 ac_medserv5, name(row2, replace) row(1) 
	graph combine 			row1 row2, cols(1) iscale(.5) commonscheme 
								
	graph export 		"$output/ac_medserv.png", as(png) replace
	graph export 		"$output/ac_medserv.emf", as(emf) replace
	
* staple foods
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 1
		graph bar 		(mean) ac_staple [pweight = phw_cs], ///
							over(wave, gap(10) label(labsize(large))) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(stone*2)) bar(3, color(eltgreen*2)) ///
							bar(4, color(teal*5)) bar(5, color(khaki*3)) bar(6, color(cranberry*4)) ///
							bar(7, color(purple*4)) title("Ethiopia", size(vlarge)) ///
							ytitle("Percent unable to purchase", size(large) margin(-10 0 0 0)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(7) margin(-1.5 0 0 0) pos(6) size(med)) name(ac_staple1, replace)
	restore
	
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 2
		graph bar 		(mean) ac_staple [pweight = phw_cs], ///
							over(wave, gap(70) label(labsize(large))) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(navy*3)) bar(3, color(purple*4)) ///
							title("Malawi", size(vlarge)) outergap(200) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(4) margin(-1.5 0 0 0) pos(6) size(medlarge)) name(ac_staple2, replace)
	restore 
	
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 3
		graph bar 		(mean) ac_staple [pweight = phw_cs], ///
							over(wave, gap(70) label(labsize(large))) asyvars  ///
							bar(1, color(stone*2))  bar(2, color(navy*3)) bar(3, color(emerald*4)) ///
							title("Nigeria", size(vlarge)) outergap(200) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(3) margin(-1.5 0 0 0) pos(6) size(medlarge)) name(ac_staple3, replace)
	restore
	
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 4
		graph bar 		(mean) ac_staple [pweight = phw_cs], ///
							over(wave, gap(70) label(labsize(large))) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(khaki*3)) bar(3, color(emidblue*4)) ///
							title("Uganda", size(vlarge)) outergap(200) ///
							ytitle("Percent unable to purchase", size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(3) margin(-1.5 0 0 0) pos(6) size(large)) name(ac_staple4, replace) ///
							graphregion(margin(70 1))
	restore
	
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 5
		graph bar 		(mean) ac_staple [pweight = phw_cs], ///
							over(wave, gap(10) label(labsize(large))) asyvars  ///
							bar(1, color(eltgreen*2)) bar(2, color(teal*5)) bar(3, color(cranberry*4)) ///
							bar(4, color(purple*4)) bar(5, color(brown*3)) bar(6, color(emerald*4)) ///
							bar(7, color(emidblue*4)) bar(8, color(erose*4)) ///
							title("Burkina Faso", size(vlarge)) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(10) margin(-1.5 0 0 0) pos(6) size(med)) name(ac_staple5, replace) ///
							graphregion(margin(r 70))
	restore
	
	graph combine 			ac_staple1 ac_staple2 ac_staple3, name(row1, replace) row(1) 
	graph combine 			ac_staple4 ac_staple5, name(row2, replace) row(1) 
	graph combine 			row1 row2, cols(1) iscale(.5) commonscheme 
	
	graph export 			"$output/ac_staple.png", as(png) replace
	graph export 			"$output/ac_staple.emf", as(emf) replace
		
	
* **********************************************************************
* 9 - educational engagement
* **********************************************************************

	preserve 
	keep 				if country == 1
	keep 				if edu_act < .
	graph bar 			(mean) edu_act [pweight = hhw_cs], over(wave, gap(10) label(labsize(large))) ///
							ytitle("Percent of households", size(large) margin(-10 0 0 0)) ///
							title("Ethiopia", size(vlarge)) asyvars bar(1, color(maroon*4)) ///
							bar(2, color(stone*2)) bar(3, color(eltgreen*2)) ///
							bar(4, color(teal*5)) bar(5, color(khaki*3)) bar(6, color(brown*3)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(6) margin(-1.5 0 0 0) pos(6) size(large)) ///
							name(edu_eng1, replace)
	restore 
	
	preserve 
	keep 				if country == 2
	keep 				if edu_act < .
	graph bar 			(mean) edu_act [pweight = hhw_cs], over(wave, gap(50) label(labsize(large))) ///
							asyvars bar(1, color(eltgreen*2)) bar(2, color(navy*3)) bar(3, color(purple*4)) ///
							title("Malawi", size(vlarge)) outergap(120) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(3) margin(-1.5 0 0 0) pos(6) size(large)) ///
							name(edu_eng2, replace)
	restore 
	
	preserve 
	keep 				if country == 3
	keep 				if edu_act < .
	graph bar 			(mean) edu_act [pweight = hhw_cs], over(wave, gap(10) label(labsize(large))) ///
							ytitle("", size(vlarge)) title("Nigeria", size(vlarge)) ///
							asyvars bar(1, color(stone*2)) bar(2, color(eltgreen*2)) bar(3, color(navy*3)) ///
							bar(4, color(teal*5)) bar(5, color(khaki*3)) bar(6, color(cranberry*4)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(6) margin(-1.5 0 0 0) pos(6) size(large)) ///
							name(edu_eng3, replace)
	restore 
	
	preserve 
	keep 				if country == 4
	keep 				if edu_act < .
	graph bar 			(mean) edu_act [pweight = hhw_cs], over(wave, gap(20) label(labsize(large))) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(teal*5)) bar(3, color(khaki*3))  ///
							bar(4, color(purple*4)) bar(5, color(emidblue*4)) ///
							title("Uganda", size(vlarge)) outergap(50) ///
							ytitle("Percent of households", size(large) margin(-10 0 0 0)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6) size(large)) ///
							name(edu_eng4, replace) graphregion(margin(70 1))
	restore 
	
	preserve 
	keep 				if country == 5
	keep 				if edu_act < .
	graph bar 			(mean) edu_act [pweight = hhw_cs], over(wave, gap(50) label(labsize(large))) asyvars ///
							bar(1, color(eltgreen*2)) bar(2, color(teal*5)) bar(3, color(brown*3)) ///
							title("Burkina Faso", size(vlarge)) outergap(120) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(medlarge)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6) size(large)) ///
							name(edu_eng5, replace) graphregion(margin(r 70))
	restore 
	
	graph combine 			edu_eng1 edu_eng2 edu_eng3, name(row1, replace) row(1) 
	graph combine 			edu_eng4 edu_eng5, name(row2, replace) row(1) 
	graph combine 			row1 row2, cols(1) iscale(.5) commonscheme 
	
	graph export 		"$output/edu_eng.png", as(png) replace
	graph export 		"$output/edu_eng.emf", as(emf) replace
				

* **********************************************************************
* 10 - how engaged in educational activities
* **********************************************************************

	preserve
	keep 				if wave < 10
	graph bar			edu_1 edu_4 edu_5 edu_6 edu_7 edu_11 edu_17 [pweight = hhw_cs] if country == 1 ///
							, over(wave, label(labsize(vlarge))) title("Ethiopia", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(purple*4)) bar(6, color(maroon*2.3)) ///
							bar(7, color(emerald*3)) legend(size(vsmall) margin(-2 0 0 0) ///
							label (1 "Assignments from teacher") ///
							label (2 "Educational programs on radio") ///
							label (3 "Session with teacher") ///
							label (4 "Studying/reading on their own") ///
							label (5 "Taught by household member") ///
							label (6 "Reviewed textbooks and notes") ///
							label (7 "Resumed school") pos(6) col(2)) ///
							ytitle("Percent of households", size(medlarge)) name(educont_eth, replace)
	restore 
	
	preserve 
	keep 				if wave == 6 | wave == 7
	graph bar		 	edu_1 edu_4 edu_5 edu_6 edu_7 edu_11 edu_17 [pweight = hhw_cs] if country == 2 ///
							, over(wave, label(labsize(vlarge))) title("Malawi", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(purple*4)) bar(6, color(maroon*2.3)) ///
							bar(7, color(emerald*3)) ytitle("", size(med)) ///
							legend(off) outergap(450) name(educont_mwi, replace)
	restore 
	
	preserve
	keep 				if wave < 10
	graph bar		 	edu_1 edu_4 edu_5 edu_6 edu_7 edu_11 edu_17 [pweight = hhw_cs] if country == 3 ///
							, over(wave, label(labsize(vlarge))) title("Nigeria", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(purple*4)) bar(6, color(maroon*2.3)) ///
							bar(7, color(emerald*3)) ytitle("Percent of households", size(medlarge))  ///
							legend(off) name(educont_nga, replace)
	restore 
	
	graph bar			edu_1 edu_4 edu_5 edu_6 edu_7 edu_11 edu_17 [pweight = hhw_cs] if country == 4 ///
							, over(wave, label(labsize(vlarge))) title("Uganda",size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(purple*4)) bar(6, color(maroon*2.3)) ///
							bar(7, color(navy*2)) ytitle("", size(med)) legend(off) name(educont_uga, replace)
		
	preserve
	keep 				if wave == 6 | wave == 8
	graph bar			edu_1 edu_4 edu_5 edu_6 edu_7 edu_11 edu_17 [pweight = hhw_cs] if country == 5 ///
							, over(wave, label(labsize(vlarge))) title("Burkina Faso",size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(purple*4)) bar(6, color(maroon*2.3)) ///
							bar(7, color(emerald*3)) ytitle("Percent of households", size(medlarge)) ///
							legend(off) outergap(450) name(educont_bf, replace)
	restore 
	
	grc1leg2  		 	educont_eth  educont_mwi educont_nga educont_uga educont_bf, ///
							col(2) iscale(.5) commonscheme imargin(0 0 0 0) legend() 
	gr_edit 			.legend.DragBy 20 37
		
	graph export 		"$output/edu_how.png", as(png) replace
	graph export 		"$output/edu_how.emf", as(emf) replace


* **********************************************************************
* 11 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */
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
	global	output	=	"$output_f/book_chapter/figures"
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
* 1 - behavior
* **********************************************************************

* wave 1 all countries 
	graph bar 			(mean) bh_3 bh_1 bh_2 if wave_orig == 1 [pweight = phw], ///
							over(country, lab(labs(vlarge))) title("", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") pos(6) col(3) ///
							size(medsmall) margin(-1.5 0 0 0)) saving("$output/stata_graphs/behavior_w1", replace)	
		
	grc1leg2   			"$output/stata_graphs/behavior_w1.gph", iscale(.5) commonscheme ///
							 imargin(0 0 0 0) legend()
					
	graph export 		"$output/behavior_w1.png", as(png) replace	
	graph export 		"$output/behavior_w1.emf", as(emf) replace
	
	* sig tests
		reg 			bh_3 i.country [pweight = phw] if wave_orig == 1 
			test 			2.country = 1.country
			test 			2.country = 3.country
			test 			2.country = 4.country
		reg 			bh_1 i.country [pweight = phw] if wave_orig == 1 
			test 			2.country = 1.country
			test 			2.country = 3.country
			test 			2.country = 4.country
		reg 			bh_2 i.country [pweight = phw] if wave_orig == 1 
			test 			2.country = 1.country
			test 			2.country = 3.country
			test 			2.country = 4.country
 			
* over waves in mwi and uga 	
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 2 [pweight = phw], ///
							over(wave, lab(labs(vlarge)))  title("Malawi", size(large)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5)) ///
							ytitle("Percent of individuals", margin(0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-1.5 0 0 0)) saving("$output/stata_graphs/behavior_mwi", replace)
	
		
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 4 [pweight = phw], ///
							over(wave, lab(labs(vlarge))) title("Uganda", size(large)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-1.5 0 0 0)) saving("$output/stata_graphs/behavior_uga", replace)

	grc1leg2   			"$output/stata_graphs/behavior_mwi.gph" "$output/stata_graphs/behavior_uga.gph", ///
							col(2) iscale(.5) commonscheme imargin(0 0 0 0) legend()
					
	graph export 		"$output/behavior_waves.png", as(png) replace
	graph export 		"$output/behavior_waves.emf", as(emf) replace
	
	* sig tests 
		reg 			bh_3 i.wave [pweight = phw] if country == 2
			test 			6.wave = 7.wave
		reg 			bh_3 i.wave [pweight = phw] if country == 4
			test 			6.wave = 9.wave
		reg 			bh_1 i.wave [pweight = phw] if country == 2
			test 			6.wave = 9.wave
		reg 			bh_1 i.wave [pweight = phw] if country == 4
			test 			6.wave = 9.wave
		reg 			bh_2 i.wave [pweight = phw] if country == 4
			test 			6.wave = 9.wave
		reg 			bh_8 i.wave [pweight = phw] if country == 2
			test 			7.wave = 9.wave
		reg 			bh_8 i.wave [pweight = phw] if country == 4
			test 			8.wave = 9.wave
		
		
* **********************************************************************
* 2 - myths (wave 1 only)
* **********************************************************************

	preserve

	drop if				country == 1 | country == 3
	keep 				myth_2 myth_3 myth_4 myth_5 country phw
	gen 				id=_n
	ren 				(myth_2 myth_3 myth_4 myth_5) (size=)
	reshape long 		size, i(id) j(myth) string
	drop if 			size == .
	drop if				size == 3

	catplot 			size country myth [aweight = phw], percent(country myth) stack ///
							ytitle("Percent", size(vlarge)) var1opts(label(labsize(vlarge))) ///
							var2opts(label(labsize(vlarge))) var3opts(label(labsize(large)) ///
							relabel (1 `""Africans are immune" "to coronavirus"""' ///
							2 `""Coronavirus does not" "affect children"""' ///
							3 `""Coronavirus cannot survive" "warm weather""' ///
							4 `""Coronavirus is just" "common flu""'))  ///
							ylabel(, labs(vlarge)) bar(1, color(khaki*1.5) ) ///
							bar(2, color(emerald*1.5) ) legend(label (2 "True") ///
							label (1 "False") pos(6) col(2) margin(-1.5 0 0 0) ///
							size(medsmall)) saving("$output/stata_graphs/myth", replace)

	restore
	
	grc1leg2  		 	"$output/stata_graphs/myth.gph", col(3) iscale(.5) commonscheme ///
							imargin(0 0 0 0) legend()	
						
	graph export 		"$output/myth.png", as(png) replace
	graph export 		"$output/myth.emf", as(emf) replace
	
	
* **********************************************************************
* 3 - income 
* **********************************************************************

	foreach 			var in  farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
	    egen 				`var'_mean = mean(`var'), by(country wave)
	}

	preserve
	keep 				if country == 1
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 1, sort(wave) title("Ethiopia", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("")  legend( label (1 "Farm income") ///
							label (2 "Business income") label (3 "Wage income") label (4 "Remittances") ///
							label (5 "All else") pos(6) col(3) size(medsmall) margin(-1.5 0 0 0)) ///
							xlabel(4 "Apr" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sept", ///
							nogrid labs(large)) ///
							saving("$output/stata_graphs/income_eth_waves", replace)
	restore			
	
	preserve
	keep 				if country == 2
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 2, sort(wave) title("Malawi", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(6 "June" 7 "July" 8 "Aug" 9 "Sept", ///
							nogrid labs(large)) saving("$output/stata_graphs/income_mwi_waves", replace)
	restore			
	
	preserve
	keep 				if country == 3
	drop 				if wave == 9
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 3, sort(wave) title("Nigeria", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(5 "May" 6 "June" 7 "July" 8 "Aug", ///
							nogrid labs(large)) saving("$output/stata_graphs/income_nga_waves", replace)
	restore			
	
	preserve
	keep 				if country == 4						
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 4, sort(wave) title("Uganda", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(6 "June" 7 "July" 8 "Aug" 9 "Sept", ///
							nogrid labs(large)) saving("$output/stata_graphs/income_uga_waves", replace)
	restore 
	
	grc1leg2 			"$output/stata_graphs/income_eth_waves.gph" "$output/stata_graphs/income_mwi_waves.gph" ///
							"$output/stata_graphs/income_nga_waves.gph" "$output/stata_graphs/income_uga_waves.gph", ///
							col(2) iscale(.5) commonscheme 

	graph export 		"$output/income_all_line.png", as(png) replace
	graph export 		"$output/income_all_line.emf", as(emf) replace
	
	* means and sig tests
		mean 			farm_dwn [pweight = hhw] if country == 1 & wave == 4
		mean 			farm_dwn [pweight = hhw] if country == 1 & wave == 9
		reg 			farm_dwn i.wave [pweight = hhw] if country == 1
			test 			4.wave = 9.wave
	
		mean 			farm_dwn [pweight = hhw] if country == 4 & wave == 6
		mean 			farm_dwn [pweight = hhw] if country == 4 & wave == 9
		reg 			farm_dwn i.wave [pweight = hhw] if country == 4
			test 			6.wave = 9.wave
		
		mean 			bus_dwn [pweight = hhw] if country == 1 & wave == 4
		mean 			bus_dwn [pweight = hhw] if country == 1 & wave == 9
		reg 			bus_dwn i.wave [pweight = hhw] if country == 1
			test 			4.wave = 9.wave
		
		mean 			bus_dwn [pweight = hhw] if country == 4 & wave == 6
		mean 			bus_dwn [pweight = hhw] if country == 4 & wave == 9
		reg 			bus_dwn i.wave [pweight = hhw] if country == 4
			test 			6.wave = 9.wave
		
		mean 			remit_dwn [pweight = hhw] if country == 1 & wave == 4
		mean 			remit_dwn [pweight = hhw] if country == 1 & wave == 9
		reg 			remit_dwn i.wave [pweight = hhw] if country == 1
			test 			4.wave = 9.wave

	
* **********************************************************************
* 4 - business revenue
* **********************************************************************

	preserve

	keep 				bus_emp_inc country wave hhw
	replace				bus_emp_inc = 3 if bus_emp_inc == 4
	gen 				id=_n
	ren 				(bus_emp_inc) (size=)
	reshape long 		size, i(id) j(bus_emp_inc) string
	drop if 			size == .

	* reverse order of vars
	replace 			size = 4 if size == 1
	replace 			size = 1 if size == 3
	replace 			size = 3 if size == 4
	
	colorpalette 		stone maroon, ipolate(15, power(1)) locals

	catplot 			size wave country [aweight = hhw] if country == 1, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large)))  ///
							ytitle("", size(vlarge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none)) bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(label (3 "Higher than before") label (2 "Same as before") ///
							label (1 "Less than before") pos(6) col(3) ///
							size(medsmall) margin(-1.5 0 0 0)) saving("$output/stata_graphs/eth_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 2, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large))) ///
							ytitle("", size(vlarge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none)) bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(off) saving("$output/stata_graphs/mwi_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 3, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large))) ///
							ytitle("", size(vlarge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none)) bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(off) saving("$output/stata_graphs/nga_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 4, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large))) ///
							ytitle("", size(huge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none))  bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(off) saving("$output/stata_graphs/uga_bus_inc", replace)

	restore

	grc1leg2 			"$output/stata_graphs/eth_bus_inc.gph" "$output/stata_graphs/mwi_bus_inc.gph" ///
							"$output/stata_graphs/nga_bus_inc.gph" "$output/stata_graphs/uga_bus_inc.gph", ///
							col(1) iscale(.5) commonscheme imargin(0 0 0 0) 
						
	graph export 		"$output/bus_emp_inc.png", as(png) replace
	graph export 		"$output/bus_emp_inc.emf", as(emf) replace


* **********************************************************************
* 4 - food insecurity 
* **********************************************************************
		
	forval 				w = 5/9 {
		gen 			p_mod_`w' = p_mod if wave == `w'
	}

	
	graph bar 			(mean) p_mod_5 p_mod_6 p_mod_7 p_mod_8 p_mod_9 [pweight = wt_18], ///
							over(country, lab(labs(vlarge))) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							ytitle("Prevalence", size(vlarge))  ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) ///
							legend(label (1 "May") label (2 "June") label (3 "July") label (4 "Aug") ///
							label (5 "Sept") col(5) margin(-1.5 0 0 0)) saving("$output/stata_graphs/fies_modsev", replace)

	grc1leg2 			"$output/stata_graphs/fies_modsev.gph", iscale(.5) pos(6) commonscheme 
	
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
								
	catplot 			concern_1 wave [aweight = hhw], over(country) percent(country wave) stack ///
							title("Concerned that family or self will fall ill with COVID-19 (%)", size(large)) ///
							var1opts(label(labsize(large))) legend(col(2) margin(-1.5 0 0 0)) ///
							var2opts(label(nolab)) ///
							ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
							ylabel(, labs(large)) saving("$output/stata_graphs/conc1_w1", replace)
							
	catplot 			concern_2 wave [aweight = hhw], over(country) percent(country wave) stack ///
							title("Concerned about the financial threat of COVID-19 (%)", size(large)) ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							legend(col(2) margin(-1.5 0 0 0)) var2opts(label(nolab)) ///
							ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
							ylabel(, labs(large)) saving("$output/stata_graphs/conc2_w1", replace)						

	restore 
	
	grc1leg2 			"$output/stata_graphs/conc1_w1.gph" "$output/stata_graphs/conc2_w1.gph", ///
							col(1) iscale(.5) commonscheme imargin(0 0 0 0)
														
	graph export 		"$output/concerns_w1.png", as(png) replace
	graph export 		"$output/concerns_w1.emf", as(emf) replace

* over waves in mwi and uga 
	forval c = 1/2 {
		if `c' == 1 {
			local 			title = "Concerned that family or self will fall ill with COVID-19 (%)"
		}
		else {
			local 			title = "Concerned about the financial threat of COVID-19 (%)"
		}						
		catplot 			concern_`c' wave country [aweight = hhw] if country == 2, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2) margin(-1.5 0 0 0)) ///
								var2opts(label(labsize(large))) title("`title'", size(large)) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/mwi_conc`c'", replace)
								
		catplot 			concern_`c' wave country [aweight = hhw] if country == 4, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2) margin(-1.5 0 0 0)) ///
								var2opts(label(labsize(large))) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/uga_conc`c'", replace)	
	}
	
	
	grc1leg2 			"$output/stata_graphs/mwi_conc1.gph" "$output/stata_graphs/uga_conc1.gph" ///
							"$output/stata_graphs/mwi_conc2.gph" "$output/stata_graphs/uga_conc2.gph", ///
							col(1) iscale(.5) commonscheme imargin(0 0 0 0)
								
	graph export 		"$output/concern_waves.png", as(png) replace
	graph export 		"$output/concern_waves.emf", as(emf) replace
					

* sig tests 
	reg 				concern_1 i.wave [pweight = hhw] if country == 2
		test 				6.wave = 9.wave
	reg 				concern_1 i.wave [pweight = hhw] if country == 4
		test 				6.wave = 9.wave
	reg 				concern_2 i.wave [pweight = hhw] if country == 2
		test 				6.wave = 9.wave
	reg 				concern_2 i.wave [pweight = hhw] if country == 4
		test 			6.wave = 9.wave	
		
	mean				concern_1 [pweight = hhw] if country == 2 & wave == 6
	mean 				concern_1 [pweight = hhw] if country == 2 & wave == 7
	mean 				concern_1 [pweight = hhw] if country == 2 & wave == 8
	mean 				concern_1 [pweight = hhw] if country == 2 & wave == 9
	
	mean 				concern_2 [pweight = hhw] if country == 2 & wave == 6
	mean 				concern_1 [pweight = hhw] if country == 1 & wave == 6

		
	mean 				concern_1 [pweight = hhw] if country == 4 & wave == 6
	mean 				concern_1 [pweight = hhw] if country == 4 & wave == 8
	mean 				concern_1 [pweight = hhw] if country == 4 & wave == 9	
	
	mean 				concern_2 [pweight = hhw] if country == 4 & wave == 6
	mean 				concern_2 [pweight = hhw] if country == 4 & wave == 8
	mean 				concern_2 [pweight = hhw] if country == 4 & wave == 9	
	
	
* **********************************************************************
* 6 - coping
* **********************************************************************
	
	forval 					c = 1/4 {
	    preserve 
		* excluding months with no data 
		egen 				temp = total(cope_none), by (country wave)
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
	
	graph bar			(mean) cope_11 cope_9 cope_10 cope_3 cope_1 cope_none [pweight = hhw] ///
							if country == `c', over(wave, label(labsize(medlarge))) ///
							title("`country'", size(vlarge)) ///
							bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
							bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
							bar(5, color(erose*1.5)) bar(6, color(eltgreen*5))  ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							ytitle("`ytitle'", size(large)) ///
							legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
							label (3 "Reduced non-food cons.") label (4 "Help from family") ///
							label (5 "Sale of asset") label (6 "Did nothing") /// 
							size(medsmall) pos(6) col(3) margin(-1.5 0 0 0)) saving("$output/stata_graphs/cope_`c'.gph", replace)
		restore
	}
	grc1leg2 			"$output/stata_graphs/cope_1.gph" "$output/stata_graphs/cope_2.gph" ///
							"$output/stata_graphs/cope_3.gph" "$output/stata_graphs/cope_4.gph", ///
							col(2) iscale(.5) commonscheme 
						
	graph export 		"$output/cope.png", as(png) replace
	graph export 		"$output/cope.emf", as(emf) replace
	
					
* **********************************************************************
* 7 - assistance
* **********************************************************************
		
	forval 					c = 1/4 {
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
	graph bar			(mean) asst_cash asst_food asst_kind asst_any [pweight = hhw] ///
							if country == `c', over(wave, label(labsize(medlarge))) ///
							title("`country'", size(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							ytitle("`ytitle'", size(large)) ///
							legend(label (1 "Cash") label (2 "Food") label (3 "In-kind") ///
							label (4 "Any assistance") size(medsmall) pos(6) col(4) ///
							margin(-1.5 0 0 0)) saving("$output/stata_graphs/asst_`c'.gph", replace)
		restore 
	}
	grc1leg2 			"$output/stata_graphs/asst_1.gph" "$output/stata_graphs/asst_2.gph" ///
							"$output/stata_graphs/asst_3.gph" "$output/stata_graphs/asst_4.gph", ///
							col(2) iscale(.5) commonscheme
						
	graph export 		"$output/asst.png", as(png) replace
	graph export 		"$output/asst.emf", as(emf) replace
	
	reg 				asst_any i.wave [pweight = hhw] if country == 4
		test 			6.wave = 9.wave
		test 			6.wave = 8.wave
	
	
* **********************************************************************
* 8 - access to staple foods and medical services
* **********************************************************************

* medical services 
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 1
		graph bar 		(mean) ac_medserv [pweight = phw], ///
							over(wave, gap(10) label(labsize(medlarge))) asyvars bar(1, color(navy*2)) ///
							bar(2, color(brown*1.3)) bar(3, color(maroon*4))  ///
							bar(4, color(stone*2)) bar(5, color(eltgreen*3)) title("Ethiopia", size(medlarge)) ///
							ytitle("Percent unable to purchase", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_medserv1", replace)
	restore
	
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 2
		graph bar 		(mean) ac_medserv [pweight = phw], ///
							over(wave, gap(100) label(labsize(medlarge))) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(cranberry*3)) ///
							title("Malawi", size(medlarge)) outergap(100) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							ytitle("", size(med)) legend(col(2) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_medserv2", replace)
	restore
	
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 3
		graph bar 		(mean) ac_medserv [pweight = phw], ///
							over(wave, gap(20) label(labsize(medlarge))) asyvars  ///
							bar(1, color(brown*1.3)) bar(2, color(maroon*4)) bar(3, color(cranberry*3)) ///
							bar(4, color(stone*2)) title("Nigeria", size(medlarge)) ///
							ytitle("Percent unable to purchase", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(4) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_medserv3", replace)
	restore
	
	preserve
		egen 			temp = total(ac_medserv), by (country wave)
		keep if 		temp != 0 & country == 4
		graph bar 		(mean) ac_medserv [pweight = phw], ///
							over(wave, gap(50) label(labsize(medlarge))) asyvars  ///
							bar(1, color(maroon*4)) bar(2, color(stone*2))  ///
							bar(3, color(eltgreen*3)) title("Uganda", size(medlarge)) outergap(70) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							ytitle("", size(med)) legend(col(3) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_medserv4", replace)
	restore
	
	
	gr combine			"$output/stata_graphs/ac_medserv1" "$output/stata_graphs/ac_medserv2" ///
							"$output/stata_graphs/ac_medserv3" "$output/stata_graphs/ac_medserv4", ///
							col(2) commonscheme 
								
	graph export 		"$output/ac_medserv.png", as(png) replace
	graph export 		"$output/ac_medserv.emf", as(emf) replace
	
* medicine 
	mean 				ac_med [pweight = phw] if country == 1 & wave == 4
	mean 				ac_med [pweight = phw] if country == 4 & wave == 6
	
* staple foods
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 1
		graph bar 		(mean) ac_staple [pweight = phw], ///
							over(wave, gap(10) label(labsize(medlarge))) asyvars bar(1, color(navy*2)) ///
							bar(2, color(brown*1.3)) bar(3, color(maroon*4))  ///
							bar(4, color(stone*2)) bar(5, color(eltgreen*3)) title("Ethiopia", size(medlarge)) ///
							ytitle("Percent unable to purchase", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(5) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_staple1", replace)
	restore
	
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 2
		graph bar 		(mean) ac_staple [pweight = phw], ///
							over(wave, gap(100) label(labsize(medlarge))) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(cranberry*3)) ///
							title("Malawi", size(medlarge)) outergap(100) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(2) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_staple2", replace)
	restore
	
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 3
		graph bar 		(mean) ac_staple [pweight = phw], ///
							over(wave, gap(100) label(labsize(medlarge))) asyvars  ///
							bar(1, color(brown*1.3)) bar(2, color(cranberry*3)) ///
							title("Nigeria", size(medlarge)) outergap(100) ///
							ytitle("Percent unable to purchase", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(2) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_staple3", replace)
	restore
	
	preserve
		egen 				temp = total(ac_staple), by (country wave)
		keep if 			temp != 0 & country == 4
		graph bar 		(mean) ac_staple [pweight = phw], ///
							over(wave, gap(100) label(labsize(medlarge))) asyvars  ///
							bar(1, color(maroon*4))  bar(2, color(eltgreen*3)) ///
							title("Uganda", size(medlarge)) outergap(100) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(col(3) margin(-1.5 0 0 0) pos(6)) ///
							saving("$output/stata_graphs/ac_staple4", replace)
	restore
	
	
	gr combine			"$output/stata_graphs/ac_staple1" "$output/stata_graphs/ac_staple2" ///
							"$output/stata_graphs/ac_staple3" "$output/stata_graphs/ac_staple4", ///
							col(2) commonscheme 
								
	graph export 			"$output/ac_staple.png", as(png) replace
	graph export 			"$output/ac_staple.emf", as(emf) replace
	
	
* sig tests
	reg 				ac_medserv i.wave [pweight = phw] if country == 1
		test 				4.wave = 9.wave
	reg 				ac_medserv i.wave [pweight = phw] if country == 2
		test 				6.wave = 7.wave
	reg 				ac_medserv i.wave [pweight = phw] if country == 3
		test 				5.wave = 8.wave
	reg 				ac_medserv i.wave [pweight = phw] if country == 4
		test 				6.wave = 9.wave
		
	mean 				ac_medserv [pweight = phw] if country == 1 & wave == 8
	mean 				ac_medserv [pweight = phw] if country == 1 & wave == 9
	mean 				ac_medserv [pweight = phw] if country == 3 & wave == 5
	
	reg 				ac_staple i.wave [pweight = phw] if country == 1
		test 				4.wave = 9.wave
	reg 				ac_staple i.wave [pweight = phw] if country == 2
		test 				6.wave = 7.wave
	reg 				ac_staple i.wave [pweight = phw] if country == 3
		test 				5.wave = 7.wave
	reg 				ac_staple i.wave [pweight = phw] if country == 4
		test 			6.wave = 9.wave	
	
* Ethipia staple foods 
	graph bar 			(mean) ac_teff ac_oil  ac_wheat ac_maize [pweight = phw]  if country == 1, ///
							over(wave, label(labsize(large))) ///
							ytitle("Percent unable to purchase", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							bar(1, color(brown*1.3)) bar(2, color(maroon*4)) bar(3, color(cranberry*3)) ///
							bar(4, color(stone*2)) bar(5, color(eltgreen*5)) ///
							legend( label(1 "Teff") label(2 "Oil") ///
							label(3 "Wheat") label(4 "Maize") col(4)) ///
							saving("$output/stata_graphs/ac_staple_eth", replace)

	grc1leg2			"$output/stata_graphs/ac_staple_eth.gph", col(2) iscale(.5) pos(6) commonscheme 
	
	graph export 		"$output/ac_staple_eth.png", as(png) replace
	
	mean 				ac_teff [pweight =phw] if country == 1 & wave == 4
	mean 				ac_teff [pweight =phw] if country == 1 & wave == 6
	
	tab 				ac_teff_why
	
* nigeria staple foods
	preserve
	
	keep 				if wave == 5 | wave == 7
	
	
	graph bar 			(mean) ac_yam ac_rice ac_beans ac_cass  ac_sorg [pweight = phw]  if country == 3, ///
							over(wave, label(labsize(large))) ///
							ytitle("Percent unable to purchase", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							bar(1, color(brown*1.3)) bar(2, color(maroon*4)) bar(3, color(cranberry*3)) ///
							bar(4, color(stone*2)) bar(5, color(eltgreen*5)) legend( label(1 "Yams") label(2 "Rice") ///
							label(3 "Beans") label(4 "Cassava") label(5 "Sorghum") col(5)) ///
							saving("$output/stata_graphs/ac_staple_nga", replace)

	grc1leg2			"$output/stata_graphs/ac_staple_nga.gph", col(2) iscale(.5) pos(6) commonscheme 
	
	graph export 		"$output/ac_staple_nga.png", as(png) replace
	
	restore 

	tab 				ac_yam_why
	
* **********************************************************************
* 9 - educational engagement
* **********************************************************************

	preserve 
	keep 				if country == 1
	graph bar 			(mean) edu_act [pweight = hhw], over(wave, gap(10) label(labsize(large))) ///
							ytitle("Percent of households", size(vlarge)) ///
							title("Ethiopia", size(vlarge)) asyvars bar(1, color(navy*2)) ///
							bar(2, color(brown*1.3)) bar(3, color(maroon*4))  ///
							bar(4, color(stone*2)) bar(5, color(eltgreen*3)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) legend(col(5) margin(-1.5 0 0 0) pos(6) size(medlarge)) ///
							saving("$output/stata_graphs/edu_eng1", replace)
	restore 
	
	preserve 
	keep 				if country == 2
	keep 				if wave == 6 | wave == 7
	graph bar 			(mean) edu_act [pweight = hhw], over(wave, gap(100) label(labsize(large))) ///
							asyvars bar(1, color(maroon*4)) bar(2, color(cranberry*3)) ///
							title("Malawi", size(vlarge)) outergap(100) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) legend(col(2) margin(-1.5 0 0 0) pos(6) size(medlarge)) ///
							saving("$output/stata_graphs/edu_eng2", replace)
	restore 
	
	preserve 
	keep 				if country == 3
	graph bar 			(mean) edu_act [pweight = hhw], over(wave, gap(10) label(labsize(large))) ///
							ytitle("Percent of households", size(vlarge)) title("Nigeria", size(vlarge)) ///
							asyvars bar(1, color(brown*1.3)) bar(2, color(maroon*4)) ///
							bar(3, color(cranberry*3)) bar(4, color(stone*2)) bar(5, color(eltgreen*3)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) legend(col(5) margin(-1.5 0 0 0) pos(6) size(medlarge)) ///
							saving("$output/stata_graphs/edu_eng3", replace)
	restore 
	
	preserve 
	keep 				if country == 4
	graph bar 			(mean) edu_act [pweight = hhw], over(wave, gap(50) label(labsize(large))) asyvars ///
							bar(1, color(maroon*4)) bar(2, color(stone*2)) bar(3, color(eltgreen*3)) ///
							title("Uganda", size(vlarge)) outergap(70) ytitle("", size(med)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) legend(col(5) margin(-1.5 0 0 0) pos(6) size(medlarge)) ///
							saving("$output/stata_graphs/edu_eng4", replace)
	restore 
	
	graph combine  		"$output/stata_graphs/edu_eng1.gph" "$output/stata_graphs/edu_eng2.gph" ///
							"$output/stata_graphs/edu_eng3.gph" "$output/stata_graphs/edu_eng4.gph", ///
							iscale(.5) commonscheme 
						
	graph export 		"$output/edu_eng.png", as(png) replace
	graph export 		"$output/edu_eng.emf", as(emf) replace
				

* **********************************************************************
* 10 - educational contact 
* **********************************************************************

	graph bar			edu_4 edu_2 edu_3 edu_5 edu_8 edu_11 [pweight = hhw] if country == 1 ///
							, over(wave, label(labsize(vlarge))) title("Ethiopia", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) bar(6, color(maroon*2.3)) ///
							legend( size(medsmall) ///
							label (1 "Educational radio programs") ///
							label (2 "Used mobile learning apps") ///
							label (3 "Watched education television") ///
							label (4 "Session with teacher") ///
							label (5 "Read material from government") ///
							label (6 "Reviewed textbooks and notes") pos(6) col(2)) ///
							ytitle("Percent of households", size(vlarge))  ///
							saving("$output/stata_graphs/educont_eth", replace)
	
	preserve 
	keep 				if wave == 6 | wave == 7
	graph bar		 	edu_4 edu_2 edu_3 edu_5  edu_8 edu_11 [pweight = hhw] if country == 2 ///
							, over(wave, label(labsize(vlarge))) title("Malawi", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) ytitle("", size(med)) ///
							legend(off) saving("$output/stata_graphs/educont_mwi", replace)
	restore 
	
	graph bar		 	edu_4 edu_2 edu_3 edu_5  edu_8 edu_11  [pweight = hhw] if country == 3 ///
							, over(wave, label(labsize(vlarge))) title("Nigeria", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) ///
							ytitle("Percent of households", size(vlarge))  ///
							legend(off) saving("$output/stata_graphs/educont_nga", replace)

	graph bar			edu_4 edu_2 edu_3 edu_5  edu_8 edu_11  [pweight = hhw] if country == 4 ///
							, over(wave, label(labsize(vlarge))) title("Uganda",size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) bar(6, color(maroon*2.3)) ///
							ytitle("", size(med)) legend(off) saving("$output/stata_graphs/educont_uga", replace)

	grc1leg2  		 	"$output/stata_graphs/educont_eth.gph" "$output/stata_graphs/educont_mwi.gph" ///
							"$output/stata_graphs/educont_nga.gph" "$output/stata_graphs/educont_uga.gph", ///
							col(2) iscale(.5) commonscheme imargin(0 0 0 0) legend() 
						
	graph export 		"$output/edu_how.png", as(png) replace
	graph export 		"$output/edu_how.emf", as(emf) replace


* **********************************************************************
* 11 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */
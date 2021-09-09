* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: jdm
* Last edit: 19 November 2020
* Stata v.16.1

* does
	* produces graphs for paper

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
	global	output	=	"$output_f/nature_paper/nature_figures"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/analysis_graphs", append

* read in data
	use				"$ans/lsms_panel", clear

* drop new waves not used in nhb 
	keep 			if ((country == 1 | country == 3) & (wave == 1 | wave == 2 | wave == 3)) | ///
						((country == 2 | country == 4) & (wave == 1 | wave == 2))

* waves to month number
	gen 			wave_orig = wave
	replace 		wave = 6 if wave == 3 & country == 1
	replace 		wave = 5 if wave == 2 & country == 1
	replace 		wave = 4 if wave == 1 & country == 1
	replace 		wave = 7 if wave == 3 & country == 3
	replace 		wave = 6 if wave == 2 & country == 3
	replace 		wave = 5 if wave == 1 & country == 3
	replace 		wave = 7 if wave == 2 & country == 2
	replace 		wave = 6 if wave == 1 & (country == 2 | country == 4)
	replace 		wave = 8 if wave == 2 & country == 4

	lab def 		months 4 "April" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sept"
	lab val			wave months
	
	
* **********************************************************************
* 1 - knowledge of covid-19 restrictions, behaviours, and false beliefs
* **********************************************************************

* graph A - knowledge of government restrictions
	graph bar		(mean) gov_1 gov_2 gov_4 gov_5 gov_6 gov_10 [pweight = phw], ///
						over(country, lab(labs(vlarge))) ///
						bar(1, color(khaki*1.5)) ///
						bar(2, color(cranberry*1.5)) bar(3, color(teal*1.5)) ///
						bar(4, color(lavender*1.5)) bar(5, color(brown*1.5)) ///
						bar(6, color(maroon*1.5))  ///
						ytitle("Individual's Knowledge of government actions to curb spread (%)", size(large)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						legend(label (1 "Advised to stay home") ///
						label (2 "Restricted travel") ///
						label (3 "Closed schools") label (4 "Curfew/lockdown") ///
						label (5 "Closed businesses") label (6 "Stopped social gatherings") ///
						pos (6) col(3) size(medsmall)) saving("$output/restriction", replace)

	gen 			temp = 1 if gov_1 < . | gov_2 < . |gov_4 < . |gov_5 < . |gov_6 < . |gov_10 < . 
	preserve 
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs1a = `r(N)'
	restore
	drop 			temp
	
	grc1leg2  		"$output/restriction.gph", col(3) iscale(.5) commonscheme ///
						title("A", size(huge)) imargin(0 0 0 0) legend() name("g1a", replace)
					
	graph export 	"$output/restriction.eps", as(eps) replace


* graph B - knowledge of COVID-19
	graph bar		(mean) know_1 know_2 know_3 know_5 know_6 know_7 ///
						[pweight = phw], over(country, lab(labs(vlarge)))  ///
						bar(1, color(edkblue*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(eltblue*1.5)) bar(4, color(emerald*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						ytitle("Individual's knowledge of actions to reduce exposure (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						legend(label (1 "Handwash with soap") ///
						label (2 "Avoid physical contact") label (3 "Use masks/gloves") ///
						label (4 "Stay at home") label (5 "Avoid crowds") ///
						label (6 "Socially distance") pos (6) col(3) ///
						size(medsmall)) saving("$output/knowledge", replace)
	
	gen 			temp = 1 if know_1 < . | know_2 < . |know_3 < . |know_5 < . |know_6 < . |know_7 < . 
	preserve 
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs1b = `r(N)'
	restore
	drop 			temp
	
	grc1leg2		"$output/knowledge.gph", col(3) iscale(.5) commonscheme ///
						title("B", size(huge)) imargin(0 0 0 0) legend() name("g1b", replace)
						
	graph export	"$output/knowledge.eps", as(eps) replace
						

* graph C - changes in behaviour
	graph bar 		(mean) bh_1 bh_2 bh_3 if wave_orig == 1 [pweight = phw], ///
						over(country, lab(labs(vlarge)))  ///
						bar(1, color(maroon*1.5)) ///
						bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
						ytitle("Individual's change in behaviour to reduce exposure (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						legend(	label (1 "Increased hand washing") ///
						label (2 "Avoided physical contact") ///
						label (3 "Avoided crowds") pos(6) col(3) ///
						size(medsmall)) saving("$output/behavior", replace)

	gen 			temp = 1 if bh_1 < . | bh_2 < . |bh_3 < . 
	preserve 
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs1c = `r(N)'
	restore
	drop 			temp
	
	grc1leg2  		"$output/behavior.gph", col(3) iscale(.5) commonscheme ///
						title("C", size(huge)) imargin(0 0 0 0) legend() name("g1c", replace)	

	graph export 	"$output/behavior.eps", as(eps) replace
	

* graph D - false beliefs
	preserve

	drop if			country == 1 | country == 3
	keep 			myth_2 myth_3 myth_4 myth_5 country phw
	gen 			id=_n
	ren 			(myth_2 myth_3 myth_4 myth_5) (size=)
	reshape long 	size, i(id) j(myth) string
	drop if 		size == .
	drop if			size == 3

	catplot 		size country myth [aweight = phw], percent(country myth) stack ///
						ytitle("Percent", size(vlarge)) var1opts(label(labsize(vlarge))) ///
						var2opts(label(labsize(vlarge))) var3opts(label(labsize(large)) ///
						relabel (1 `""Africans are immune" "to coronavirus"""' ///
						2 `""Coronavirus does not" "affect children"""' ///
						3 `""Coronavirus cannot survive" "warm weather""' ///
						4 `""Coronavirus is just" "common flu""'))  ///
						ylabel(, labs(huge)) ///
						bar(1, color(khaki*1.5) ) ///
						bar(2, color(emerald*1.5) ) ///
						legend( label (2 "True") label (1 "False") pos(6) col(2) ///
						size(medsmall)) saving("$output/myth", replace)

	restore
	
	preserve 
		drop if			country == 1 | country == 3
		gen 			temp = 1 if myth_2 != . | myth_3 != . | myth_4 != . | myth_5 != .
		collapse 		(count) temp, by(hhid)
		count 			if temp
		local 			obs1d = `r(N)'	
	restore
	
	grc1leg2  		"$output/myth.gph", col(3) iscale(.7) commonscheme ///
						title("D", size(huge)) imargin(0 0 0 0) legend() name("g1d", replace)
						
	graph export 	"$output/myth.eps", as(eps) replace

	
* combine 4 graphs, export as eps	

	graph combine 	g1a g1b g1c g1d, col(2) iscale(.5) imargin(0 0 0 0) ///
						saving("$output/fig1.gph", replace)
						
	graph export 	"$output/fig1.eps", as(eps) replace


* **********************************************************************
* 2 - household income, food insecurity, and concerns about covid-19
* **********************************************************************

* graph A - income loss by sector
	preserve
	
	keep if			wave_orig == 1

	graph bar		(mean) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn [pweight = hhw] ///
						, over(sector, lab(labs(large))) ///
						over(country, lab(labs(vlarge)))  ///
						ytitle("Households reporting decrease in income (%)", size(vlarge) ) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
						pos(6) col(3) size(medsmall)) saving("$output/income_all", replace)
				
	restore
			
	preserve
		keep if			wave_orig == 1
		gen 			temp = 1 if farm_dwn < . |bus_dwn < . |wage_dwn  < . |remit_dwn < . |other_dwn < . 
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs2a = `r(N)'
	restore
	
	grc1leg2 		"$output/income_all.gph", col(3) iscale(.5) ///
						commonscheme title("A", size(huge)) name("g2a", replace)	
						
	graph export 	"$output/income_all.eps", as(eps) replace
						

* graph B - income loss by wave
	preserve

	keep 			bus_emp_inc country wave hhw
	replace			bus_emp_inc = 3 if bus_emp_inc == 4
	gen 			id=_n
	ren 			(bus_emp_inc) (size=)
	reshape long 	size, i(id) j(bus_emp_inc) string
	drop if 		size == .
	drop if			size == -98 | size == -99

	colorpalette 	stone maroon, ipolate(15, power(1)) locals

	catplot 		size wave country [aweight = hhw] if country == 1, percent(country wave) stack ///
						var1opts(label(labsize(large))) ///
						var3opts(label(labsize(large))) ///
						var2opts( label(labsize(large))) ///
						ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend( ///
						label (1 "Higher than before") ///
						label (2 "Same as before") ///
						label (3 "Less than before") pos(6) col(3) ///
						size(medsmall)) saving("$output/eth_bus_inc", replace)

	catplot 		size wave country [aweight = hhw] if country == 2, percent(country wave) stack	 ///
						var1opts(label(labsize(large))) ///
						var3opts(label(labsize(large))) ///
						var2opts( label(labsize(large))) ///
						ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
						saving("$output/mwi_bus_inc", replace)

	catplot 		size wave country [aweight = hhw] if country == 3, percent(country wave) stack	 ///
						var1opts(label(labsize(large))) ///
						var3opts(label(labsize(large))) ///
						var2opts( label(labsize(large))) ///
						ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
						saving("$output/nga_bus_inc", replace)

	catplot 		size wave country [aweight = hhw] if country == 4, percent(country wave) stack	 ///
						var1opts(label(labsize(large))) ///
						var3opts(label(labsize(large))) ///
						var2opts( label(labsize(large))) ///
						ytitle("Households reporting change in business revenue (%)", size(huge)) ///
						bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
						saving("$output/uga_bus_inc", replace)
	
	restore
	
	preserve 
		gen 			temp = 1 if bus_emp_inc != . & bus_emp_inc != .a
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs2b = `r(N)'				
	restore

	grc1leg2 		"$output/eth_bus_inc.gph" "$output/mwi_bus_inc.gph" ///
						"$output/nga_bus_inc.gph" "$output/uga_bus_inc.gph", col(1) iscale(.5) ///
						 commonscheme imargin(0 0 0 0) title("B", size(huge)) name("g2b", replace)	
						
	graph export 	"$output/bus_emp_inc.eps", as(eps) replace

	
* graph C - FIES score and consumption quntile
	preserve
	drop if 		country == 1 & wave_orig == 2
	drop if 		country == 2 & wave_orig == 1
	drop if 		country == 4 & wave_orig == 1

	gen				p_mod_1 = p_mod if quint == 1
	gen				p_mod_2 = p_mod if quint == 2
	gen				p_mod_3 = p_mod if quint == 3
	gen				p_mod_4 = p_mod if quint == 4
	gen				p_mod_5 = p_mod if quint == 5

	gen				p_sev_1 = p_sev if quint == 1
	gen				p_sev_2 = p_sev if quint == 2
	gen				p_sev_3 = p_sev if quint == 3
	gen				p_sev_4 = p_sev if quint == 4
	gen				p_sev_5 = p_sev if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_mod_1 p_mod_2 p_mod_3 p_mod_4 p_mod_5 ///
						[pweight = wt_18], over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						saving("$output/fies_modsev", replace)

	graph bar 		(mean) p_sev_1 p_sev_2 p_sev_3 p_sev_4 p_sev_5 ///
						[pweight = wt_18], over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/fies_sev", replace)

	restore					
	
	preserve 
		gen 			temp = 1 if p_mod < . & quint < .
		drop if 		country == 1 & wave_orig == 2
		drop if 		country == 2 & wave_orig == 1
		drop if 		country == 4 & wave_orig == 1
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs2c = `r(N)'	
	restore

	grc1leg2 		"$output/fies_modsev.gph" "$output/fies_sev.gph", ///
						col(3) iscale(.5) pos(6) commonscheme title("C", size(huge)) name("g2c", replace)
						
	graph export 	"$output/fies.eps", as(eps) replace


* graph D - concerns with FIES
	preserve
	drop if			country == 2 & wave_orig == 1
	drop if			country == 4 & wave_orig == 1

	graph hbar		(mean) p_mod p_sev [pweight = wt_18], over(concern_1, lab(labs(vlarge))) ///
						over(country, lab(labs(vlarge)))  ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
						.8 "80" 1 "100", labs(large)) ytitle("Prevalence of food insecurity", size(vlarge)) ///
						bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
						legend(label (1 "Moderate or severe")  ///
						label (2 "Severe") pos(6) col(2) size(medsmall)) ///
						title("Concerned that family or self will fall ill with COVID-19", size(huge)) ///
						saving("$output/concern_1", replace)

	graph hbar		(mean) p_mod p_sev [pweight = wt_18], over(concern_2, lab(labs(vlarge))) ///
						over(country, lab(labs(vlarge))) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
						.8 "80" 1 "100", labs(large)) ytitle("Prevalence of food insecurity", size(vlarge)) ///
						bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
						legend(off) ///
						title("Concerned about the financial threat of COVID-19", size(huge)) ///
						saving("$output/concern_2", replace)
	*** Nigeria has information on concerns in wave 1, but only FIES in wave 2

	restore
		
	preserve
		drop if			country == 2 & wave_orig == 1
		drop if			country == 4 & wave_orig == 1	
		gen 			temp = 1 if p_mod < . | p_sev < .
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs2d = `r(N)'	
	restore
	
	grc1leg2 		"$output/concern_1.gph" "$output/concern_2.gph", ///
						col(1) iscale(.5) pos(6) commonscheme title("D", size(huge) span) name("g2d", replace)
						
	graph export 	"$output/concerns.eps", as(eps) replace

	
* combine 4 graphs, export as eps	
	graph combine 	g2a g2b g2c g2d, col(2) iscale(.5) imargin(0 0 0 0) ///
						saving("$output/fig2.gph", replace)
				
	graph export 	"$output/fig2.eps", as(eps) replace	
	

* **********************************************************************
* 3 - household coping strategies and access to basics necessities
* **********************************************************************

* graph A - coping mechanisms
	preserve
	drop if 		country == 1 & wave_orig == 1
	drop if 		country == 1 & wave_orig == 2
	drop if 		country == 3 & wave_orig == 1
	
	replace			cope_3 = 1 if cope_3 == 1 | cope_4 == 1
	replace			cope_5 = 1 if cope_5 == 1 | cope_6 == 1 | cope_7 == 1
	
	graph bar		(mean) cope_11 cope_1 cope_9 cope_10 cope_3 asst_any cope_none ///
						[pweight = hhw], over(sector, ///
						label (labsize(large))) over(country, label (labsize(vlarge))) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) bar(7, color(purple*1.5)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Households reporting use of coping strategy (%)", size(vlarge)) ///
						legend( label (1 "Relied on savings") label (2 "Sale of asset") ///
						label (3 "Reduced food cons.") label (4 "Reduced non-food cons.") ///
						label (5 "Help from family") ///
						label (6 "Received assistance") /// 
						label (7 "Did nothing") size(medsmall) pos(6) col(3)) ///
						saving("$output/cope_all.gph", replace)
						
	restore
	
	preserve
		drop if 		country == 1 & wave_orig == 1
		drop if 		country == 1 & wave_orig == 2
		drop if 		country == 3 & wave_orig == 1
		replace			cope_3 = 1 if cope_3 == 1 | cope_4 == 1
		replace			cope_5 = 1 if cope_5 == 1 | cope_6 == 1 | cope_7 == 1
		gen  			temp = 1 if cope_11 < . | cope_1 < . | cope_9 < . | cope_10 < . | cope_3 < . | asst_any < . | cope_none < .
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs3a = `r(N)'	
	restore 
		
	grc1leg2 		"$output/cope_all.gph", col(4) iscale(.5) commonscheme ///
						title("A", size(huge)) name("g3a", replace)
						
	graph export 	"$output/cope.eps", as(eps) replace

	
* graph B - access to med, food, soap
	gen				ac_med_1 = 1 if quint == 1 & ac_med == 1
	gen				ac_med_2 = 1 if quint == 2 & ac_med == 1
	gen				ac_med_3 = 1 if quint == 3 & ac_med == 1
	gen				ac_med_4 = 1 if quint == 4 & ac_med == 1
	gen				ac_med_5 = 1 if quint == 5 & ac_med == 1

	gen				ac_staple_1 = 1 if quint == 1 & ac_staple == 1
	gen				ac_staple_2 = 1 if quint == 2 & ac_staple == 1
	gen				ac_staple_3 = 1 if quint == 3 & ac_staple == 1
	gen				ac_staple_4 = 1 if quint == 4 & ac_staple == 1
	gen				ac_staple_5 = 1 if quint == 5 & ac_staple == 1

	gen				ac_soap_1 = 1 if quint == 1 & ac_soap == 1
	gen				ac_soap_2 = 1 if quint == 2 & ac_soap == 1
	gen				ac_soap_3 = 1 if quint == 3 & ac_soap == 1
	gen				ac_soap_4 = 1 if quint == 4 & ac_soap == 1
	gen				ac_soap_5 = 1 if quint == 5 & ac_soap == 1

	replace			ac_med_1 = 0 if quint == 1 & ac_med == 0
	replace			ac_med_2 = 0 if quint == 2 & ac_med == 0
	replace			ac_med_3 = 0 if quint == 3 & ac_med == 0
	replace			ac_med_4 = 0 if quint == 4 & ac_med == 0
	replace			ac_med_5 = 0 if quint == 5 & ac_med == 0

	replace			ac_staple_1 = 0 if quint == 1 & ac_staple == 0
	replace			ac_staple_2 = 0 if quint == 2 & ac_staple == 0
	replace			ac_staple_3 = 0 if quint == 3 & ac_staple == 0
	replace			ac_staple_4 = 0 if quint == 4 & ac_staple == 0
	replace			ac_staple_5 = 0 if quint == 5 & ac_staple == 0

	replace			ac_soap_1 = 0 if quint == 1 & ac_soap == 0
	replace			ac_soap_2 = 0 if quint == 2 & ac_soap == 0
	replace			ac_soap_3 = 0 if quint == 3 & ac_soap == 0
	replace			ac_soap_4 = 0 if quint == 4 & ac_soap == 0
	replace			ac_soap_5 = 0 if quint == 5 & ac_soap == 0

	colorpalette edkblue khaki, ipolate(15, power(1)) locals


	graph bar 		(mean) ac_med_1 ac_med_2 ac_med_3 ac_med_4 ac_med_5 ///
						[pweight = phw] if wave_orig == 1, ///
						over(country, label(labsize(medlarge)))  ///
						ytitle("Prevalence of household's inability to buy medicine (%)", size(vlarge)) ///
						ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) 	///
						saving("$output/ac_med", replace)

	graph bar 		(mean) ac_staple_1 ac_staple_2 ac_staple_3 ac_staple_4 ac_staple_5 ///
						[pweight = phw] if wave_orig == 1,  ///
						over(country, label(labsize(medlarge)))   ///
						ytitle("Prevalence of household's inability to buy staple food (%)", size(vlarge)) ///
						ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_staple", replace)

	graph bar 		(mean) ac_soap_1 ac_soap_2 ac_soap_3 ac_soap_4 ac_soap_5 ///
						[pweight = phw] if wave_orig == 1 & country != 1,  ///
						over(country, label(labsize(medlarge)))   ///
						ytitle("Prevalence of household's inability to buy soap (%)", size(vlarge)) ///
						ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_soap", replace)
						
	preserve 
		gen 			temp = 1 if (ac_med < . & quint < .) | (ac_staple < . & quint < .)  | (ac_soap < . & quint < .)
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs3b = `r(N)'		
	restore
				
	grc1leg2		"$output/ac_med.gph" "$output/ac_staple.gph" "$output/ac_soap.gph", ///
						col(3) iscale(.5) pos(6) commonscheme title("B", size(huge)) name("g3b", replace)
						
	graph export 	"$output/access.eps", as(eps) replace

	
* graph C - education and quintiles
	gen				edu_act_1 = edu_act if quint == 1
	gen				edu_act_2 = edu_act if quint == 2
	gen				edu_act_3 = edu_act if quint == 3
	gen				edu_act_4 = edu_act if quint == 4
	gen				edu_act_5 = edu_act if quint == 5

	mean			sch_child [pweight = shw] if wave_orig == 1
	mean			edu_none [pweight = shw] if wave_orig == 1
	mean			edu_cont [pweight = shw] if wave_orig == 1
	
	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) edu_act_1 edu_act_2 edu_act_3 edu_act_4 edu_act_5 ///
						[pweight = hhw] if wave_orig == 1, over(country, label(labsize(vlarge)))  ///
						ytitle("Households with children engaged in learning activities (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						saving("$output/edu_quinta", replace)
						
	
	preserve 
		gen 			temp = 1 if (edu_act < . & quint < .)
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs3c = `r(N)'		
	restore
	
	grc1leg2  		 "$output/edu_quinta.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend() title("C", size(huge)) name("g3c", replace)
						
	graph export "$output/edu_quint.eps", as(eps) replace
						

* graph D - education activities
	graph bar		edu_4 edu_2 edu_3 edu_5 [pweight = hhw] if country == 1 ///
						, over(wave, label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(ebblue*4)) legend( size(medsmall) ///
						label (1 "Listened to educational radio programs") ///
						label (2 "Using mobile learning apps") ///
						label (3 "Watched education television") ///
						label (4 "Session with teacher") ///
						label (5 "Studying and reading on their own") pos(6) col(2)) ///
						ytitle("Households with children experiencing educational contact (%)", size(vlarge))  ///
						saving("$output/educont_eth", replace)

	graph bar		 edu_4 edu_2 edu_3 edu_5  [pweight = hhw] if country == 2 ///
						, over(wave, label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(ebblue*4)) legend(off) saving("$output/educont_mwi", replace)

	graph bar		 edu_4 edu_2 edu_3 edu_5  [pweight = hhw] if country == 3 ///
						, over(wave, label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(ebblue*4)) legend(off) saving("$output/educont_nga", replace)

	graph bar		edu_4 edu_2 edu_3 edu_5 [pweight = hhw] if country == 4  ///
						, over(wave, label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(ebblue*4)) legend(off) saving("$output/educont_uga", replace)

	preserve 
		gen 			temp = 1 if edu_4 < . | edu_2 < . | edu_3 < . | edu_5 < .
		collapse 		(count) temp, by(hhid)
		count 			if temp != 0 & temp != . & temp != .a
		local 			obs3d = `r(N)'		
	restore				
						
	grc1leg2  		 "$output/educont_eth.gph" "$output/educont_mwi.gph" ///
						"$output/educont_nga.gph" "$output/educont_uga.gph", ///
						col(4) iscale(.5) commonscheme imargin(0 0 0 0) ///
						legend() title("D", size(huge)) name("g3d", replace)
						
	graph export 	"$output/educont.eps", as(eps) replace

	
* combine 4 graphs, export as eps	
	graph combine 	g3a g3b g3c g3d, col(2) iscale(.5) imargin(0 0 0 0) ///
						saving("$output/fig3.gph", replace)
				
	graph export 	"$output/fig3.eps", as(eps) replace	
	
	
* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

* print observation counts
	forval x = 1/3 {
	    foreach l in a b c d {
		    di "`x' `l' observations"
			di `obs`x'`l''
		}
	}

* close the log
	log	close

/* END */
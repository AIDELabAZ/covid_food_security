* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* Last edit: 17 November 2020
* Stata v.16.1

* does
	* produces figures for paper

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
	global	output	=	"$data/analysis/figures"
	global	present =	"$output/presentation"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/analysis_graphs", append

* read in data
	use				"$ans/lsms_panel", clear
	
	
* **********************************************************************
* 1 - government restrictions and knowledge
* **********************************************************************


* graph A - knowledge of government restrictions
	graph bar		(mean) gov_01 gov_02 gov_04 gov_05 gov_06 gov_10 [pweight = phw], ///
						over(country, lab(labs(vlarge))) ///
						bar(1, color(khaki*1.5)) ///
						bar(2, color(cranberry*1.5)) bar(3, color(teal*1.5)) ///
						bar(4, color(lavender*1.5)) bar(5, color(brown*1.5)) ///
						bar(6, color(maroon*1.5))  ///
						ytitle("Individual's Knowledge of government actions to curb spread (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						legend(label (1 "Advised to stay home") ///
						label (2 "Restricted travel") ///
						label (3 "Closed schools") label (4 "Curfew/lockdown") ///
						label (5 "Closed businesses") label (6 "Stopped social gatherings") ///
						pos (6) col(3) size(medsmall)) saving("$output/restriction", replace)

	grc1leg2  		 "$output/restriction.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend()
						
	graph export 	"$present/restriction.eps", as(eps) replace


* graph B - knowledge of COVID-19
	graph bar		(mean) know_01 know_02 know_03 know_05 know_06 know_07 ///
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

	grc1leg2  		 "$output/knowledge.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend()
						
	graph export 	"$present/knowledge.eps", as(eps) replace


* **********************************************************************
* 2 - behavior and myths
* **********************************************************************

* graph A - changes in behavior
	graph bar 		(mean) bh_01 bh_02 bh_03 if wave == 1 [pweight = phw], ///
						over(country, lab(labs(vlarge)))  ///
						bar(1, color(maroon*1.5)) ///
						bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
						ytitle("Individual's change in behavior to reduce exposure (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						legend(	label (1 "Increased hand washing") ///
						label (2 "Avoided physical contact") ///
						label (3 "Avoided crowds") pos(6) col(3) ///
						size(medsmall)) saving("$output/behavior", replace)

	grc1leg2  		 "$output/behavior.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend()	
						
	graph export 	"$present/behavior.eps", as(eps) replace

* graph A1 - changes in behavior
	preserve
			
	lab def sex 1 "Male" 2 "Female"
	label val sex sex 	
	
	graph bar 		(mean) bh_01 bh_02 bh_03 if wave == 1 [pweight = phw], ///
						over(sex, lab(labs(large))) over(country, lab(labs(vlarge)))  ///
						bar(1, color(maroon*1.5)) ///
						bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
						ytitle("Individual's change in behavior to reduce exposure (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						legend(	label (1 "Increased hand washing") ///
						label (2 "Avoided physical contact") ///
						label (3 "Avoided crowds") pos(6) col(3) ///
						size(medsmall)) saving("$output/behavior_sex", replace)

	restore
	
	grc1leg2  		 "$output/behavior_sex.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend()	
						
	graph export 	"$present/behavior_sex.eps", as(eps) replace

* graph B - false beliefs
	preserve

	drop if			country == 1 | country == 3
	keep 			myth_02 myth_03 myth_04 myth_05 country phw
	gen 			id=_n
	ren 			(myth_02 myth_03 myth_04 myth_05) (size=)
	reshape long 	size, i(id) j(myth) string
	drop if 		size == .
	drop if			size == 3

	catplot 		size country myth [aweight = phw], percent(country myth) ///
						ytitle("Percent", size(vlarge)) var1opts(label(labsize(vlarge))) ///
						var2opts(label(labsize(vlarge))) var3opts(label(labsize(large)) ///
						relabel (1 `""Africans are immune" "to coronavirus"""' ///
						2 `""Coronavirus does not" "affect children"""' ///
						3 `""Coronavirus cannot survive" "warm weather""' ///
						4 `""Coronavirus is just" "common flu""'))  ///
						ylabel(, labs(vlarge)) ///
						bar(1, color(khaki*1.5) ) ///
						bar(2, color(emerald*1.5) ) ///
						legend( label (2 "True") label (1 "False") pos(6) col(2) ///
						size(medsmall)) saving("$output/myth", replace)

	restore
	
	grc1leg2  		 "$output/myth.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend()	
						
	graph export 	"$present/myth.eps", as(eps) replace


* **********************************************************************
* 3 - income and business revenue
* **********************************************************************

* graph A - income loss by sector
	preserve
	
	keep if			wave == 1

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
	
	grc1leg2 		"$output/income_all.gph", col(3) iscale(.5) ///
						commonscheme 
						
	graph export 	"$present/income_all.eps", as(eps) replace
						
						
* graph A1 - income loss by gender
	preserve
	
	keep if			wave == 1
	
	lab def sex 1 "Male" 2 "Female"
	label val sex sex 	
	
	graph bar		(mean) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn [pweight = hhw] ///
						, over(sex, lab(labs(large))) ///
						over(country, lab(labs(vlarge)))  ///
						ytitle("Households reporting decrease in income (%)", size(vlarge) ) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
						pos(6) col(3) size(medsmall)) saving("$output/income_allsex", replace)
				
	restore
	
	grc1leg2 		"$output/income_allsex.gph" , col(3) iscale(.5) ///
						commonscheme 
						
	graph export 	"$present/incomesex.eps", as(eps) replace
	
	
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
						var2opts( relabel (1 "May" 2 "June" 3 "July") label(labsize(large))) ///
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
						var2opts( relabel (1 "June" 2 "July") label(labsize(large))) ///
						ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
						saving("$output/mwi_bus_inc", replace)

	catplot 		size wave country [aweight = hhw] if country == 3, percent(country wave) stack	 ///
						var1opts(label(labsize(large))) ///
						var3opts(label(labsize(large))) ///
						var2opts( relabel (1 "May" 2 "June" 3 "July") label(labsize(large))) ///
						ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
						saving("$output/nga_bus_inc", replace)

	catplot 		size wave country [aweight = hhw] if country == 4, percent(country wave) stack	 ///
						var1opts(label(labsize(large))) ///
						var3opts(label(labsize(large))) ///
						var2opts( relabel (1 "June" 2 "July") label(labsize(large))) ///
						ytitle("Households reporting change in business revenue (%)", size(huge)) ///
						bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
						saving("$output/uga_bus_inc", replace)

	restore

	grc1leg2 		"$output/eth_bus_inc.gph" "$output/mwi_bus_inc.gph" ///
						"$output/nga_bus_inc.gph" "$output/uga_bus_inc.gph", ///
						col(1) iscale(.5) commonscheme imargin(0 0 0 0)
						
	graph export 	"$present/bus_emp_inc.eps", as(eps) replace


* **********************************************************************
* 4 - food insecurity and concerns
* **********************************************************************
	
* graph A - FIES score and consumption quntile
	preserve
	drop if 		country == 1 & wave == 2
	drop if 		country == 2 & wave == 1
	drop if 		country == 4 & wave == 1

	gen				p_mod_01 = p_mod if quint == 1
	gen				p_mod_02 = p_mod if quint == 2
	gen				p_mod_03 = p_mod if quint == 3
	gen				p_mod_04 = p_mod if quint == 4
	gen				p_mod_05 = p_mod if quint == 5

	gen				p_sev_01 = p_sev if quint == 1
	gen				p_sev_02 = p_sev if quint == 2
	gen				p_sev_03 = p_sev if quint == 3
	gen				p_sev_04 = p_sev if quint == 4
	gen				p_sev_05 = p_sev if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_mod_01 p_mod_02 p_mod_03 p_mod_04 p_mod_05 ///
						[pweight = wt_18], over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						saving("$output/fies_modsev", replace)

	graph bar 		(mean) p_sev_01 p_sev_02 p_sev_03 p_sev_04 p_sev_05 ///
						[pweight = wt_18], over(country, lab(labs(vlarge)))  ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/fies_sev", replace)

	restore

	grc1leg2 		"$output/fies_modsev.gph" "$output/fies_sev.gph", ///
						col(3) iscale(.5) pos(6) commonscheme
						
	graph export 	"$present/fies.eps", as(eps) replace

	
* graph A1 - FIES score and gender 
	preserve
	drop if 		country == 1 & wave == 2
	drop if 		country == 2 & wave == 1
	drop if 		country == 4 & wave == 1
	
	lab def sex 1 "Male" 2 "Female"
	label val sex sex 

	graph bar 		(mean) p_mod p_sev [pweight = wt_18], over(sex, lab(labs(vlarge))) ///
						over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, color(stone*1.5)) bar(2, color(ebblue*1.5))  ///
						legend(label (1 "Moderate or severe food insecurity")  ///
						label (2 "Severe food insecurity") order( 1 2) pos(6) col(3) size(medsmall)) ///
						saving("$output/fies_modsevsex", replace)

	reg				p_mod i.sex i.country [pweight = wt_18]
	reg				p_sev i.sex i.country [pweight = wt_18]
						
	restore

	grc1leg2 		"$output/fies_modsevsex.gph", col(3) iscale(.5) pos(6) ///
						commonscheme
						
	graph export 	"$present/fiessex.eps", as(eps) replace
	
	
* graph B - concerns with FIES
	preserve
	drop if			country == 2 & wave == 1
	drop if			country == 4 & wave == 1

	graph hbar		(mean) p_mod p_sev [pweight = wt_18], over(concern_01, lab(labs(vlarge))) ///
						over(country, lab(labs(vlarge))) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
						.8 "80" 1 "100", labs(large)) ytitle("Prevalence of food insecurity", size(large)) ///
						bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
						legend(label (1 "Moderate or severe")  ///
						label (2 "Severe") pos(6) col(2) size(medsmall)) ///
						title("Concerned that family or self will fall ill with COVID-19", size(vlarge)) ///
						saving("$output/concern_1", replace)

	graph hbar		(mean) p_mod p_sev [pweight = wt_18], over(concern_02, lab(labs(vlarge))) ///
						over(country, lab(labs(vlarge))) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
						.8 "80" 1 "100", labs(large)) ytitle("Prevalence of food insecurity", size(large)) ///
						bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
						legend(off) ///
						title("Concerned about the financial threat of COVID-19", size(vlarge)) ///
						saving("$output/concern_2", replace)
	*** Nigeria has information on concerns in wave 1, but only FIES in wave 2

	restore
	
	grc1leg2 		"$output/concern_1.gph" "$output/concern_2.gph", ///
						col(1) iscale(.5) pos(6) commonscheme
						
	graph export 	"$present/concerns.eps", as(eps) replace

	
* graph B1 - concerns with gender
	preserve
	drop if			country == 2 & wave == 1
	drop if			country == 4 & wave == 1
	
	lab def sex 1 "male" 2 "female"
	label val sex sex 
	
	graph hbar		(mean) concern_01 concern_02 [pweight = phw], over(sex, lab(labs(vlarge))) ///
						over(country, lab(labs(vlarge))) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
						.8 "80" 1 "100", labs(large)) ytitle("Percent of households reporting concern", size(large)) ///
						bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
						legend(label (1 "Concerned that family or self will fall ill with COVID-19")  ///
						label (2 "Concerned about the financial threat of COVID-19") ///
						pos(6) col(1) size(medsmall)) ///
						title("Concerns about COVID-19", size(vlarge)) ///
						saving("$output/concern_sex", replace)
		
	reg				concern_01 i.sex i.country [pweight = phw]
	reg				concern_02 i.sex i.country [pweight = phw]
	
	restore
	
	grc1leg2 		"$output/concern_sex.gph", col(1) iscale(.5) pos(6) ///
						commonscheme 
						
	graph export 	"$present/concernssex.eps", as(eps) replace

	
*** figure s2a - concerns and moderate fies ***

preserve

	drop if 			country == 1 & wave == 2
	drop if 			country == 2 & wave == 1
	drop if 			country == 4 & wave == 1

	gen					p_mod_01 = p_mod if quint == 1
	gen					p_mod_02 = p_mod if quint == 2
	gen					p_mod_03 = p_mod if quint == 3
	gen					p_mod_04 = p_mod if quint == 4
	gen					p_mod_05 = p_mod if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_mod_01 p_mod_02 p_mod_03 p_mod_04 p_mod_05 ///
						[pweight = wt_18], over(concern_01, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned that family/self will fall ill with COVID-19", size(vlarge)) ///
						saving("$output/fiesq1_modsev", replace)
						
	graph bar 		(mean) p_mod_01 p_mod_02 p_mod_03 p_mod_04 p_mod_05 ///
						[pweight = wt_18], over(concern_02, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned about the financial threat of COVID-19", size(vlarge)) ///
						saving("$output/fiesq2_modsev", replace)

	restore

	grc1leg2 		"$output/fiesq1_modsev.gph" "$figure/fiesq2_modsev.gph", ///
						col(3) iscale(.5) pos(6) commonscheme

	graph export 	"$present/fiesquintetc1.eps", as(eps) replace

	
*** figure s2b - concerns and severe fies ***
 
preserve

	drop if 			country == 1 & wave == 2
	drop if 			country == 2 & wave == 1
	drop if 			country == 4 & wave == 1

	gen				p_sev_01 = p_sev if quint == 1
	gen				p_sev_02 = p_sev if quint == 2
	gen				p_sev_03 = p_sev if quint == 3
	gen				p_sev_04 = p_sev if quint == 4
	gen				p_sev_05 = p_sev if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_sev_01 p_sev_02 p_sev_03 p_sev_04 p_sev_05 ///
						[pweight = wt_18], over(concern_01, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned that family/self will fall ill with COVID-19", size(vlarge)) ///
						saving("$output/fiesq1_sev", replace)
						
	graph bar 		(mean) p_sev_01 p_sev_02 p_sev_03 p_sev_04 p_sev_05 ///
						[pweight = wt_18], over(concern_02, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned about the financial threat of COVID-19", size(vlarge)) ///
						saving("$output/fiesq2_sev", replace)

	restore

	grc1leg2 		"$output/fiesq1_sev.gph" "$figure/fiesq2_sev.gph", ///
						col(3) iscale(.5) pos(6) commonscheme 

	graph export 	"$present/fiesquintetc12.eps", as(eps) replace
	
	
* **********************************************************************
* 5 - coping and access
* **********************************************************************

* graph A - coping mechanisms
	preserve
	drop if country == 1 & wave == 1
	drop if country == 1 & wave == 2
	drop if country == 3 & wave == 1
	
	
	replace			cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace			cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1
	
	total			cope_any [pweight = phw]
	mean			cope_any [pweight = phw]
	
	graph bar		(mean) cope_11 cope_01 cope_09 cope_10 cope_03 asst_any cope_none ///
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
						label (6 "Recieved assistance") /// 
						label (7 "Did nothing") size(medsmall) pos(6) col(3)) ///
						saving("$output/cope_all.gph", replace)

	restore

	grc1leg2 		"$output/cope_all.gph", col(4) iscale(.5) commonscheme
						
	graph export 	"$present/cope.eps", as(eps) replace
	
	
* graph A1 - coping mechanisms, by gender
	preserve
	drop if country == 1 & wave == 1
	drop if country == 1 & wave == 2
	drop if country == 3 & wave == 1
	
	lab def sex 1 "male" 2 "female"
	label val sex sex 

	replace			cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace			cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1
	
	graph bar		(mean) cope_11 cope_01 cope_09 cope_10 cope_03 asst_any  ///
						[pweight = hhw], over(sex, ///
						label (labsize(large))) over(country, label (labsize(vlarge))) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Households reporting use of coping strategy (%)", size(vlarge)) ///
						legend( label (1 "Relied on savings") label (2 "Sale of asset") ///
						label (3 "Reduced food cons.") label (4 "Reduced non-food cons.") ///
						label (5 "Help from family") ///
						label (6 "Recieved assistance") size(medsmall) pos(6) col(3)) ///
						saving("$output/cope_allsex.gph", replace)

	restore

	grc1leg2 		"$output/cope_allsex.gph", col(4) iscale(.5) ///
						commonscheme
						
	graph export 	"$present/copesex.eps", as(eps) replace
	
	
* graph B - access to med, food, soap
	gen				ac_med_01 = 1 if quint == 1 & ac_med == 1
	gen				ac_med_02 = 1 if quint == 2 & ac_med == 1
	gen				ac_med_03 = 1 if quint == 3 & ac_med == 1
	gen				ac_med_04 = 1 if quint == 4 & ac_med == 1
	gen				ac_med_05 = 1 if quint == 5 & ac_med == 1

	gen				ac_staple_01 = 1 if quint == 1 & ac_staple == 1
	gen				ac_staple_02 = 1 if quint == 2 & ac_staple == 1
	gen				ac_staple_03 = 1 if quint == 3 & ac_staple == 1
	gen				ac_staple_04 = 1 if quint == 4 & ac_staple == 1
	gen				ac_staple_05 = 1 if quint == 5 & ac_staple == 1

	gen				ac_soap_01 = 1 if quint == 1 & ac_soap == 1
	gen				ac_soap_02 = 1 if quint == 2 & ac_soap == 1
	gen				ac_soap_03 = 1 if quint == 3 & ac_soap == 1
	gen				ac_soap_04 = 1 if quint == 4 & ac_soap == 1
	gen				ac_soap_05 = 1 if quint == 5 & ac_soap == 1

	replace			ac_med_01 = 0 if quint == 1 & ac_med == 0
	replace			ac_med_02 = 0 if quint == 2 & ac_med == 0
	replace			ac_med_03 = 0 if quint == 3 & ac_med == 0
	replace			ac_med_04 = 0 if quint == 4 & ac_med == 0
	replace			ac_med_05 = 0 if quint == 5 & ac_med == 0

	replace			ac_staple_01 = 0 if quint == 1 & ac_staple == 0
	replace			ac_staple_02 = 0 if quint == 2 & ac_staple == 0
	replace			ac_staple_03 = 0 if quint == 3 & ac_staple == 0
	replace			ac_staple_04 = 0 if quint == 4 & ac_staple == 0
	replace			ac_staple_05 = 0 if quint == 5 & ac_staple == 0

	replace			ac_soap_01 = 0 if quint == 1 & ac_soap == 0
	replace			ac_soap_02 = 0 if quint == 2 & ac_soap == 0
	replace			ac_soap_03 = 0 if quint == 3 & ac_soap == 0
	replace			ac_soap_04 = 0 if quint == 4 & ac_soap == 0
	replace			ac_soap_05 = 0 if quint == 5 & ac_soap == 0

	colorpalette edkblue khaki, ipolate(15, power(1)) locals


	graph bar 		(mean) ac_med_01 ac_med_02 ac_med_03 ac_med_04 ac_med_05 ///
						[pweight = phw] if wave == 1, ///
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

	graph bar 		(mean) ac_staple_01 ac_staple_02 ac_staple_03 ac_staple_04 ac_staple_05 ///
						[pweight = phw] if wave == 1,  ///
						over(country, label(labsize(medlarge)))   ///
						ytitle("Prevalence of household's inability to buy staple food (%)", size(vlarge)) ///
						ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_staple", replace)

	graph bar 		(mean) ac_soap_01 ac_soap_02 ac_soap_03 ac_soap_04 ac_soap_05 ///
						[pweight = phw] if wave == 1 & country != 1,  ///
						over(country, label(labsize(medlarge)))   ///
						ytitle("Prevalence of household's inability to buy soap (%)", size(vlarge)) ///
						ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_soap", replace)

	grc1leg2		"$output/ac_med.gph" "$output/ac_staple.gph" "$output/ac_soap.gph", ///
						col(3) iscale(.5) pos(6) commonscheme
						
	graph export 	"$present/access.eps", as(eps) replace


* **********************************************************************
* 6 - create graphs on concerns and access and education
* **********************************************************************
	
* graph A - education and food
	gen				edu_act_01 = edu_act if quint == 1
	gen				edu_act_02 = edu_act if quint == 2
	gen				edu_act_03 = edu_act if quint == 3
	gen				edu_act_04 = edu_act if quint == 4
	gen				edu_act_05 = edu_act if quint == 5

	mean			sch_child [pweight = shw] if wave == 1
	mean			edu_none [pweight = shw] if wave == 1
	mean			edu_cont [pweight = shw] if wave == 1
	
	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) edu_act_01 edu_act_02 edu_act_03 edu_act_04 edu_act_05 ///
						[pweight = hhw] if wave == 1, over(country, label(labsize(vlarge)))  ///
						ytitle("Households with children engaged in learning activities (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						saving("$output/edu_quinta", replace)

	grc1leg2  		 "$output/edu_quinta.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend()
						
	graph export "$present/edu_quint.eps", as(eps) replace
						

* graph B - education activities
	graph bar		edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 1 ///
						, over(wave, relabel (1 "May" 2 "June" 3 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend( size(medsmall) ///
						label (1 "Listened to educational radio programs") ///
						label (2 "Using mobile learning apps") ///
						label (3 "Watched education television") ///
						label (4 "Session with teacher") pos(6) col(2)) ///
						ytitle("Households with children experiencing educational contact (%)", size(vlarge))  ///
						saving("$output/educont_eth", replace)

	graph bar		 edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 2 ///
						, over(wave, relabel (1 "June" 2 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_mwi", replace)

	graph bar		 edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 3 ///
						, over(wave, relabel (1 "May" 2 "June" 3 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_nga", replace)

	graph bar		edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 4 & wave == 1 ///
						, over(wave, relabel (1 "June" 2 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_uga", replace)

	grc1leg2  		 "$output/educont_eth.gph" "$output/educont_mwi.gph" ///
						"$output/educont_nga.gph" "$output/educont_uga.gph", ///
						col(4) iscale(.5) commonscheme imargin(0 0 0 0) legend()
						
	graph export 	"$present/educont.eps", as(eps) replace


* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */
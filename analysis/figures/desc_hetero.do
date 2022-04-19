* Project: food security
* Created on: Nov 2021
* Created by: jdm
* Edited by: jdm
* Last edited: 19 April 2022
* Stata v.17.0

* does
	* run from pnl_cleaning_fies.ado (not run on own)
	* uses data openned by pnl_cleaning_fies
	* generates figures for summary stats

* assumes
	* cleaned fies panel data
	* xfill.ado
	* catplot.ado
	* grc1leg2.ado (version 1.6)
	* palettes.ado
	* colrspace.ado

* TO DO:
	* complete


* **********************************************************************
**# 0 setup
* **********************************************************************
* define
	global	fig		=	"$output/figures"
	
* no need to define other globals since they are set in pnl_cleaning_fies
	preserve
	
************************************************************************
**# 1 - relabel vars and gen new vars
************************************************************************

* recode waves
	gen				nwave = wave if wave < 1
	
	* ethiopia
		replace			nwave = 1 if country == 1 & wave == 1
		replace			nwave = 2 if country == 1 & wave == 2
		replace			nwave = 3 if country == 1 & wave == 3
		replace			nwave = 5 if country == 1 & wave == 4
		replace			nwave = 6 if country == 1 & wave == 5
		replace			nwave = 7 if country == 1 & wave == 6
		replace			nwave = 8 if country == 1 & wave == 7
		replace			nwave = 9 if country == 1 & wave == 8
		replace			nwave = 10 if country == 1 & wave == 9
		replace			nwave = 11 if country == 1 & wave == 10
		replace			nwave = 13 if country == 1 & wave == 11
		replace			nwave = 15 if country == 1 & wave == 12
		
	* malawi
		replace			nwave = 3 if country == 2 & wave == 1
		replace			nwave = 4 if country == 2 & wave == 2
		replace			nwave = 5 if country == 2 & wave == 3
		replace			nwave = 6 if country == 2 & wave == 4
		replace			nwave = 8 if country == 2 & wave == 5
		replace			nwave = 9 if country == 2 & wave == 6
		replace			nwave = 10 if country == 2 & wave == 7
		replace			nwave = 12 if country == 2 & wave == 8
		replace			nwave = 13 if country == 2 & wave == 9
		replace			nwave = 14 if country == 2 & wave == 10
		replace			nwave = 15 if country == 2 & wave == 11
		replace			nwave = 16 if country == 2 & wave == 12
		
	* nigeria
		replace			nwave = 2 if country == 3 & wave == 1
		replace			nwave = 3 if country == 3 & wave == 2
		replace			nwave = 4 if country == 3 & wave == 3
		replace			nwave = 5 if country == 3 & wave == 4
		replace			nwave = 6 if country == 3 & wave == 5
		replace			nwave = 7 if country == 3 & wave == 6
		replace			nwave = 8 if country == 3 & wave == 7
		replace			nwave = 9 if country == 3 & wave == 8
		replace			nwave = 10 if country == 3 & wave == 9
		replace			nwave = 11 if country == 3 & wave == 10
		replace			nwave = 12 if country == 3 & wave == 11
		replace			nwave = 13 if country == 3 & wave == 12
		
	* burkina faso
		replace			nwave = 3 if country == 5 & wave == 1
		replace			nwave = 5 if country == 5 & wave == 2
		replace			nwave = 7 if country == 5 & wave == 3
		replace			nwave = 8 if country == 5 & wave == 4
		replace			nwave = 9 if country == 5 & wave == 5
		replace			nwave = 10 if country == 5 & wave == 6
		replace			nwave = 11 if country == 5 & wave == 7
		replace			nwave = 12 if country == 5 & wave == 8
		replace			nwave = 13 if country == 5 & wave == 9
		replace			nwave = 15 if country == 5 & wave == 10
		
* define labels for nwave
	lab def			nwave -1 "2018" 0 "2019" 1 "Apr '20" 2 "May '20" ///
						3 "Jun '20" 4 "Jul '20" 5 "Aug '20" ///
						6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" ///
						12 "Mar '21" 13 "Apr '21" 14 "May '21" ///
						15 "Jun '21" 16 "Jul '21"
	lab val			nwave nwave
	lab var			nwave "Survey Month"
	
* recode sector and sexhh
	replace			sector = 0 if sector == 1
	replace			sector = 1 if sector == 2
	lab def			sector 0 "Rural" 1 "Urban", replace
	lab val			sector sector	

	replace			sexhh = 0 if sexhh == 1
	replace			sexhh = 1 if sexhh == 2
	lab def			sexhh 0 "Male" 1 "Female", replace
	lab val			sexhh sexhh

* generate indicators for mild, mod, sev
	egen 			mean_sec = mean(sector), by(country wave)
	egen 			mean_sex = mean(sexhh), by(country wave)	

* create new weights
	egen			hhw_covid = mean(hhw_cs) if wave > 0, by(hhid)
	xtset			hhid
	xfill			hhw_covid, i(hhid)
	lab var			hhw_covid "Household sampling weight"
	order			hhw_covid, after(hhw_cs)
	drop			hhw_cs
	
* graph E - index sector
	sort			country wave
	twoway 			line mean_sec nwave [aweight = hhw_covid] if country == 5 ///
						, lcolor($edkblue) lw(*2) lpattern(solid) || ///
						line mean_sec nwave [aweight = hhw_covid] if country == 1 ///
						, lcolor($eltgreen) lw(*2) lpattern(dash) || ///
						line mean_sec nwave [aweight = hhw_covid] if country == 2 ///
						, lcolor($maroon) lw(*2) lpattern(dash_3dot) || ///
						line mean_sec nwave [aweight = hhw_covid] if country == 3 ///
						, lcolor($khaki) lw(*2) lpattern(vshortdash) title("") sort	 ///
						ytitle("Share of Urban Household") xtitle("Survey Month Year") ///
						ylabel(0 "0" .2 ".2" .4 ".4" .6 ".6" .8 ".8") ///
						xlabel(-1 "2018" 0 "2019" 1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
						4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
						13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
						legend(pos(6) col(4) label(1 "Burkina Faso") label(2 ///
						"Ethiopia") label(3 "Malawi") label(4 "Nigeria")) ///
						saving("$fig/sector", replace)	
			
	grc1leg2 		"$fig/sector.gph", col(1) pos(6) commonscheme
				
	graph export 	"$fig/sector.eps", as(eps) replace

* graph E - index sector
	sort			country wave
	twoway 			line mean_sex nwave [aweight = hhw_covid] if country == 5 ///
						, lcolor($edkblue) lw(*2) lpattern(solid) || ///
						line mean_sex nwave [aweight = hhw_covid] if country == 1 ///
						, lcolor($eltgreen) lw(*2) lpattern(dash) || ///
						line mean_sex nwave [aweight = hhw_covid] if country == 2 ///
						, lcolor($maroon) lw(*2) lpattern(dash_3dot) || ///
						line mean_sex nwave [aweight = hhw_covid] if country == 3 ///
						, lcolor($khaki) lw(*2) lpattern(vshortdash) title("") sort	 ///
						ytitle("Share of Female Headed Household") ///
						xtitle("Survey Month Year") ylabel(0 "0" .2 ".2" .4 ".4") ///
						xlabel(-1 "2018" 0 "2019" 1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
						4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
						13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
						legend(pos(6) col(4) label(1 "Burkina Faso") label(2 ///
						"Ethiopia") label(3 "Malawi") label(4 "Nigeria")) ///
						saving("$fig/sexhh", replace)		
			
	grc1leg2 		"$fig/sexhh.gph", col(1) pos(6) commonscheme
				
	graph export 	"$fig/sexhh.eps", as(eps) replace		
	
restore					
						
						
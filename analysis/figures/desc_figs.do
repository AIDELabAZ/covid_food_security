* Project: food security
* Created on: Oct 2021
* Created by: jdm
* Edited by: lirr
* Last edited: 19 April 2022
* Stata v.17.0

* does
	* reads in cleaned panel data
	* generates figures for summary statistics

* assumes
	* cleaned fies panel data
	* xfill.ado
	* grc1leg2.ado (version 1.6)
	* palettes.ado
	* colrspace.ado
	* blindschemes.ado

* TO DO:
	* complete


* **********************************************************************
**# 0 setup
* **********************************************************************

* define
	global  input   =   "$data/analysis/food_security"
	global	tab		=	"$output/tables"
	global	fig		=	"$output/figures"
	global	logout	=	"$data/analysis/food_security/logs"

* open log
	cap log 			close
	log using			"$logout/fies_figs", append
	
	
************************************************************************
**# 1 - relabel vars and gen new vars
************************************************************************

* read in data
	use				"$input/fies_reg_data", replace
	
* gen y0 and xfill by hhid
	gen 			std_fsi_y0 = std_fsi_wt if wave == 0
	xfill 			std_fsi_y0, i(hhid)

* relabel
	lab def			post 0 "pre-COVID" 1 "COVID", replace
	
* clear svyset and eststo
	svyset, clear
	svyset	[pweight = hhw_covid]

	eststo clear

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
	
* generate weighted mean values by country
	sort			country hhid nwave
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
		forvalues 		i = 0/16 {
			sum 			std_fsi_wt if nwave == `i' & country == `c' ///
							[aweight = hhw_covid]
			gen 			mean_fs_`c'_`i'  = r(mean) if nwave == `i' & country == `c'
		}
	}
	
* generate value for wave = -1
	sum 			std_fsi_wt if nwave == -1 & country == 3 ///
							[aweight = hhw_covid]
	gen 			mean_fs_3_n1  = r(mean) if nwave == -1 & country == 3

* copy country and pre/post values into single variable	
	gen 			mean_fsi = .
	lab var			mean_fsi "Standardized FIES Count"
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
		forvalues 		i = 0/16 {
			replace			mean_fsi = mean_fs_`c'_`i' if nwave == `i' & country == `c'
		}
	}

* generate value for wave = -1	
	replace			mean_fsi = mean_fs_3_n1  if nwave == -1 & country == 3

	drop			mean_fs_* 

* generate indicators for mild, mod, sev
	egen 			mean_mld = mean(mld_fs), by(country wave)
	egen 			mean_mod = mean(mod_fs), by(country wave)
	egen 			mean_sev = mean(sev_fs), by(country wave)

	
* generate color pallette
	colorpalette	economist
	colorpalette	economist, globals
	
	
************************************************************************
**# 2 - fies prevelance over time
************************************************************************

* graph - std_fsi_wt by country
	sort			country wave
	twoway 			line mean_fsi nwave [aweight = hhw_covid] if country == 5 ///
						& nwave > 0, lcolor($edkblue) lw(*2) lpattern(solid) || ///
						line mean_fsi nwave [aweight = hhw_covid] if country == 1 ///
						& nwave > 0, lcolor($eltgreen) lw(*2) lpattern(dash) || ///
						line mean_fsi nwave [aweight = hhw_covid] if country == 2 ///
						& nwave > 0, lcolor($maroon) lw(*2) lpattern(dash_3dot) || ///
						line mean_fsi nwave [aweight = hhw_covid] if country == 3 ///
						& nwave > 0, lcolor($khaki) lw(*2) lpattern(vshortdash) title("") sort ///
						ytitle("Standardized FIES Count") xtitle("Survey Month Year") ///
						xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
						4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
						13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
						legend(pos(6) col(4) label(1 "Burkina Faso") label(2 ///
						"Ethiopia") label(3 "Malawi") label(4 "Nigeria")) ///
						saving("$fig/mean_fsi", replace)	
			
	grc1leg2 		"$fig/mean_fsi.gph", col(1) pos(6) commonscheme
				
	graph export 	"$fig/mean_fsi.eps", as(eps) replace
						
						
* graph - ethiopia
	twoway 			line mean_mld mean_mod mean_sev nwave [aweight = hhw_covid] ///
						if country == 1 & nwave > 0, sort title("Ethiopia") lpattern(solid ///
						dash dash_3dot) lcolor($emerald $brown $lavender) lw(*2 *2 *2) ///
						ytitle("") xtitle("") xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
						4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
						13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
						ylabel(0 "0" .2 ".2" .4 ".4" .6 ".6" .8 ".8" 1 "1") legend(pos(6) ///
						col(1) label(1 "Mild Food Insecurity (Raw Score > 0)") label(2 ///
						"Moderate Food Insecurity (Raw Score > 3)") label(3 ///
						"Severe Food Insecurity (Raw Score > 7)")) ///
						saving("$fig/eth_fsi", replace)					
						
* graph - malawi
	twoway 			line mean_mld mean_mod mean_sev nwave [aweight = hhw_covid] ///
						if country == 2 & nwave > 0, sort title("Malawi") lpattern(solid ///
						dash dash_3dot) lcolor($emerald $brown $lavender) lw(*2 *2 *2) ///
						ytitle("% Reporting Food Insecurity") xtitle("Survey Month Year") ///
						xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
						4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
						13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
						ylabel(0 "0" .2 ".2" .4 ".4" .6 ".6" .8 ".8" 1 "1") legend(pos(6) ///
						col(1) label(1 "Mild Food Insecurity (Raw Score > 0)") label(2 ///
						"Moderate Food Insecurity (Raw Score > 3)") label(3 ///
						"Severe Food Insecurity (Raw Score > 7)")) ///
						saving("$fig/mwi_fsi", replace)							
						
* graph - nigeria
	twoway 			line mean_mld mean_mod mean_sev nwave [aweight = hhw_covid] ///
						if country == 3 & nwave > 0, sort title("Nigeria") lpattern(solid ///
						dash dash_3dot) lcolor($emerald $brown $lavender) lw(*2 *2 *2) ///
						ytitle("") xtitle("Survey Month Year") xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
						4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
						13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
						ylabel(0 "0" .2 ".2" .4 ".4" .6 ".6" .8 ".8" 1 "1") ///
						legend(pos(6) col(1) label(1 "Mild Food Insecurity (Raw Score > 0)") ///
						label(2 "Moderate Food Insecurity (Raw Score > 3)") label(3 ///
						"Severe Food Insecurity (Raw Score > 7)")) ///
						saving("$fig/nga_fsi", replace)							
						
* graph - burkina faso
	twoway 			line mean_mld mean_mod mean_sev nwave [aweight = hhw_covid] ///
						if country == 5 & nwave > 0, sort title("Burkina Faso") lpattern(solid ///
						dash dash_3dot) lcolor($emerald $brown $lavender) lw(*2 *2 *2) ///
						ytitle("% Reporting Food Insecurity") xtitle("") ///
						xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
						4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
						13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
						ylabel(0 "0" .2 ".2" .4 ".4" .6 ".6" .8 ".8" 1 "1") ///
						legend(pos(6) col(1) label(1 "Mild Food Insecurity (Raw Score > 0)") ///
						label(2 "Moderate Food Insecurity (Raw Score > 3)") label(3 ///
						"Severe Food Insecurity (Raw Score > 7)")) ///
						saving("$fig/bfo_fsi", replace)			
	
	
	grc1leg2 		"$fig/bfo_fsi.gph" "$fig/eth_fsi.gph" ///
						"$fig/mwi_fsi.gph" "$fig/nga_fsi.gph", ///
						col(2) pos(6) iscale(.5) commonscheme
				
	graph export 	"$fig/cty_fsi.eps", as(eps) replace
						
			
				
************************************************************************
**# 4 - end matter, clean up to save
************************************************************************
	

* close the log
	log	close
	
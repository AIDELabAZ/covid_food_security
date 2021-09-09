* Project: WB COVID
* Created on: November 2020
* Created by: alj
* Edited by: alj
* Last edit: 22 November 2020
* Stata v.16.1

* does
	* fies pre / post comparison for Nigeria only
	* uses only Nigeria data 

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
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/fies_pre-post", append

* read in data
	use				"$ans/raw/FIES/FIES_PreCOVID.dta", clear
	
* drop new waves not used in nhb 
	keep 					if ((country == 1 | country == 3) & (wave == 1 | wave == 2 | wave == 3)) | ///
							((country == 2 | country == 4) & (wave == 1 | wave == 2))
	
	
* **********************************************************************
* 1 - precovid 
* **********************************************************************

/*

NOTES ON POSSIBLE DATA USE 

In Nigeria LSMS-ISA, the FIES module was administered twice – once in post-planting visit (July 2019-September 2019), and once in post-harvest (January 2019-February 2020). 

Same as the FIES module include in the phone survey, the module had a reference period of last 30 days, and a reference population of adult household members. 

There are 4 samples for which FIES estimates could be derived from pre-COVID-19 Nigeria LSMS-ISA dataset, identified by the variable sample:

1.	Harvest Full – Entire Nigeria LSMS-ISA sample that received FIES module in the post-harvest visit

2.	Harvest Post-COVID – Portion of the Nigeria LSMS-ISA sample that received the FIES module in post-harvest visit and that were also interviewed by the phone survey (in Round 1)

3.	Planting Full – Entire Nigeria LSMS-ISA sample that received FIES module in the post-planting visit

4.	Planting Post-COVID – Portion of the Nigeria LSMS-ISA sample that received the FIES module in post-planting visit and that were also interviewed by the phone survey (in Round 1)

To compare pre- vs. post-COVID-levels and in view of the data collection period, use Planting pre-COVID sample. 
For weights, use a common weight for pre- and post-COVID FIES variable and take the popweight_adult included.

*/

* keep specific set of variables
* keep only Nigeria 	
	keep 		if country=="Nigeria"
	keep 		if sample=="Planting Post-COVID"
	keep 		HHID p_mod p_sev 
	gen 		time = 0

tempfile precovid
save `precovid'

* **********************************************************************
* 2 - post-covid 
* **********************************************************************

	use			"$ans/raw/FIES/FIES_PostCOVID.dta", clear
	keep 		if country=="Nigeria" & round==2
	*** Round 2 = June 2020 *

* merge in pre to post 	
	merge 		1:1 HHID using `precovid'
	keep 		if _merge==3
	drop 		_merge

tempfile covid
save `covid'

	keep 		HHID urban popweight_adult

tempfile analysis
save `analysis'

* **********************************************************************
* 3 - combination for comparison
* **********************************************************************

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

* graph change over time 

	lab def time 0 "Pre-COVID Food Insecurity Level" 1 "Post-COVID Food Insecurity Level"
	label val time time 

	graph bar 		(mean) p_mod p_sev [pweight = popweight_adult], over(time, lab(labs(vlarge))) ///
						 ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, color(stone*1.5)) bar(2, color(ebblue*1.5))  ///
						legend(label (1 "Moderate or severe food insecurity")  ///
						label (2 "Severe food insecurity") order( 1 2) pos(6) col(3) size(medsmall)) ///
						saving("$output/fies_time", replace)


	grc1leg2 		"$output/fies_time.gph", col(3) iscale(.5) pos(6) ///
						commonscheme
						
	graph export 	"$output/fies_time.eps", as(eps) replace
	
* determine statistical differences - regressions 
	
xtset hhid time

*national level 
	xtreg 			p_mod i.time [pweight=popweight_adult], fe
	xtreg			p_sev i.time [pweight=popweight_adult], fe

* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */
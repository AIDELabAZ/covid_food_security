* Project: COVID Food Security
* Created on: October 2020
* Created by: jdm
* Edited by: jdm
* Last edit: 7 October 2021
* Stata v.17.0

* does
	* reads in cleaned, regression ready data
	* conducts analysis

* assumes
	* cleaned fies data file


* TO DO:
	* copy over Bloem reg code
	* everything!!!


************************************************************************
**# 0 - setup
************************************************************************

* define
	global	tab		=	"$output/tables"
	global	fig		=	"$output/figures"
	global	logout	=	"$output/logs"

* open log
	cap log 			close
	log using			"$logout/fies_regs", append


************************************************************************
**# 1 - initial did analysis
************************************************************************

* read in data
	use				"$output/fies_reg_data", replace
	
	
* test regressions
	bys country: 	reg std_fsi_wt i.post##i.sector [aweight = hhw_covid], vce(cluster hhid)

* test regressions
	bys country: 	reg std_fsi_wt i.post##i.sexhh [aweight = hhw_covid], vce(cluster hhid)
	
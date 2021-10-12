* Project: COVID Food Security
* Created on: October 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 11 October 2021
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

* install ietoolkit
*ssc install ietoolkit

************************************************************************
**# 1 - initial did analysis
************************************************************************

* read in data
	use				"$output/fies_reg_data", replace
	
	
* test regressions
	bys country: 	reg std_fsi_wt i.post##i.sector [aweight = hhw_covid], vce(cluster hhid)

* test regressions
	bys country: 	reg std_fsi_wt i.post##i.sexhh [aweight = hhw_covid], vce(cluster hhid)



************************************************************************
**# 2 - econometric analysis
************************************************************************
	
* clear svyset and eststo
	svyset, clear
	svyset	[pweight = hhw_covid]

	eststo clear

* first-difference
	bys country:	reg std_fsi_wt i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
			eststo  std_fsi
			estadd loc FE  		"No"
			estadd loc Missing      "Yes"
					summ std_fsi_wt if post==0 [aweight = hhw_covid]
					estadd scalar C_mean = r(mean)

	bys country:	areg std_fsi_wt i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], absorb(hhid) ///
		cluster(hhid)
			eststo  std_fsi
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fsi_wt if post == 0 [aweight = hhw_covid]
					estadd scalar C_mean = r(mean)

* mild food insecurity
	eststo clear

* First-Difference	
	bys country:	reg mild_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
		eststo mild_fs_1
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

bys country:	reg mild_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mild_fs_1
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)



************************************************************************
**# 3 - descriptive analysis
************************************************************************

* first table
/*
bys country: iebaltab ///
				fs1_nr fs2_nr fs3_nr fs4_nr fs5_nr fs6_nr fs7_nr fs8_nr ///
				[pweight = hhw_covid] if post == 1, ///
				grpvar(urban) order(1 0) grplabels(1 "Urban" @ 0 "Rural")	///
				vce(cluster hhid) ///
				
	 
	 

	 
	 
	 
	 
	 
	 
	 
	 
	 
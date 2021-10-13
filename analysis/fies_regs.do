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
	* has ietoolkit


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
	ssc install ietoolkit

	
	
************************************************************************
**# 1 - initial did analysis
************************************************************************

* read in data
	use				"$output/fies_reg_data", replace
	
/*	
* test regressions
	bys country: 	reg std_fsi_wt i.post##i.sector [aweight = hhw_covid], vce(cluster hhid)

* test regressions
	bys country: 	reg std_fsi_wt i.post##i.sexhh [aweight = hhw_covid], vce(cluster hhid)
	

************************************************************************
**# 2 - raw fies index regression
************************************************************************
	
* clear svyset and eststo
	svyset, clear
	svyset	[pweight = hhw_covid]

	eststo clear

* first-difference
	bys country:	reg std_fsi_wt i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
			eststo  std_fsi_1
			estadd loc FE  		"No"
			estadd loc Missing      "Yes"
					summ std_fsi_wt if post==0 [aweight = hhw_covid]
					estadd scalar C_mean = r(mean)

	bys country:	areg std_fsi_wt i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], absorb(hhid) ///
		cluster(hhid)
			eststo  std_fsi_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fsi_wt if post == 0 [aweight = hhw_covid]
					estadd scalar C_mean = r(mean)
					
* did sector
	bys country:	reg std_fsi_wt i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], absorb(hhid) cluster(hhid)
			eststo  std_fsi_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ std_fsi_wt if post == 0  & sector == 0 ///
					[aweight = hhw_covid]
					estadd scalar C_mean = r(mean)
					
	bys country:	areg std_fsi_wt i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], absorb(hhid) cluster(hhid)
			eststo  std_fsi_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fsi_wt if post == 0  & sector == 0 ///
					[aweight = hhw_covid]
					estadd scalar C_mean = r(mean)

* did sexhh
	bys country:	reg std_fsi_wt i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], absorb(hhid) cluster(hhid)
			eststo  std_fsi_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ std_fsi_wt if post == 0  & sexhh == 0 ///
					[aweight = hhw_covid]
					estadd scalar C_mean = r(mean)
					
	bys country:	areg std_fsi_wt i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], absorb(hhid) cluster(hhid)
			eststo  std_fsi_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fsi_wt if post == 0  & sexhh == 0 ///
					[aweight = hhw_covid]
					estadd scalar C_mean = r(mean)
				
					
************************************************************************
**# 3 - mild fies index regression
************************************************************************

* first difference
	bys country:	reg mild_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
		eststo mild_fs_1
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mild_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mild_fs_2
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

* did sector
	bys country:	reg mild_fs i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo mild_fs_3
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mild_fs i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mild_fs_4
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

*did sexhh
	bys country:	reg mild_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo mild_fs_5
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mild_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mild_fs_6
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

									
************************************************************************
**# 4 - moderate fies index regression
************************************************************************

* first difference
	bys country:	reg mod_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
		eststo mod_fs_1
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mod_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mod_fs_2
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

* did sector
	bys country:	reg mod_fs i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo mod_fs_3
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mod_fs i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mod_fs_4
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

*did sexhh
	bys country:	reg mod_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo mod_fs_5
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mod_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mod_fs_6
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

				
************************************************************************
**# 5 - severe fies index regression
************************************************************************

* first difference
	bys country:	reg sev_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
		eststo sev_fs_1
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg sev_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo sev_fs_2
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

* did sector
	bys country:	reg sev_fs i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo sev_fs_3
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg sev_fs i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo sev_fs_4
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

*did sexhh
	bys country:	reg sev_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo sev_fs_5
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg sev_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo sev_fs_6
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

* without controlling for missing variables

* first difference
	bys country: reg std_fsi_wt i.post [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_1
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	
	bys country: areg std_fsi_wt i.post [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_2
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

*did sector
	bys country: reg std_fsi_wt i.post##i.urban [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_1
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	
	bys country: areg std_fsi_wt i.post [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_2
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)


				
************************************************************************
**# 6 - descriptive analysis
************************************************************************

* first table

bys country: iebaltab ///
				fs1_nr fs2_nr fs3_nr fs4_nr fs5_nr fs6_nr fs7_nr fs8_nr ///
				[pweight = hhw_covid] if post == 1, ///
				grpvar(urban) order(1 0) grplabels(1 "Urban" @ 0 "Rural")	///
				vce(cluster hhid) ///
				
	 
	*/			
************************************************************************
**# 7 - lorin's code testing section
************************************************************************ 

	levelsof country, local(levels)
	
/*	bys country: reg std_fsi_wt i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
			foreach l in local levels {
				eststo  std_fsi_1`l'
			}
				estadd loc FE  		"No"
				estadd loc Missing      "Yes"
					summ std_fsi_wt if post==0 [aweight = hhw_covid]
					estadd scalar C_mean = r(mean)	 
*/	 

	egen group = group(country)
	
	levelsof 		country, local(levels)
	foreach 		i of local levels {
	reg std_fsi_wt i.post [pweight = hhw_covid] if country == `i' , cluster(hhid)  
	eststo std_fsi_1`i'
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 & country == `i' [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}
	 
* Project: COVID Food Security
* Created on: November 2021
* Created by: jdm
* Edited by: lirr
* Last edit: 12 December 2021
* Stata v.17.0

* does
	* 

* assumes
	* cleaned fies data file
	* ietoolkit.ado

* TO DO:
	* organize regressions
	* start tables
	* start graphs
	* estouts etc.

************************************************************************
**# 0 - setup
************************************************************************

* define
	global  input   =   "$data/analysis/food_security"
	global	tab		=	"$output/tables"
	global	fig		=	"$output/figures"
	global	logout	=	"$data/analysis/food_security/logs"

* open log
	cap log 			close
	log using			"$logout/fies_lock_regs", append
	
	
************************************************************************
**# 1 - initial did analysis
************************************************************************

* read in data
	use				"$input/fies_reg_data", replace
	
* gen y0 and xfill by hhid
	gen 			std_fsi_y0 = std_fsi if wave == 0
	xfill 			std_fsi_y0, i(hhid)
	lab var			std_fsi_y0 "Standardized FIES at baseline"
	
	gen 			std_fsi_wt_y0 = std_fsi_wt if wave == 0
	xfill 			std_fsi_wt_y0, i(hhid)
	lab var			std_fsi_wt_y0 "Standardized FIES at baseline (weighted)"

	gen				mld_fsi_y0 = mld_fsi if wave == 0
	xfill			mld_fsi_y0, i(hhid)
	lab var			mld_fsi_y0 "Mild FIES at baseline"
	
	gen				mod_fsi_y0 = mod_fsi if wave == 0
	xfill			mod_fsi_y0, i(hhid)
	lab var			mod_fsi_y0 "Moderate FIES at baseline"

	gen				sev_fsi_y0 = sev_fsi if wave == 0
	xfill			sev_fsi_y0, i(hhid)
	lab var 		sev_fsi_y0 "Severe FIES at baseline"
	
	gen				anx_fsi_y0 = anx_fsi if wave == 0
	xfill			anx_fsi_y0, i(hhid)
	lab var 		anx_fsi_y0 "Anxious about food security at baseline"
	
	gen				mea_fsi_y0 = mea_fsi if wave == 0
	xfill			mea_fsi_y0, i(hhid)
	lab var 		mea_fsi_y0 "Reduced meals eaten at baseline"

	gen				hun_fsi_y0 = hun_fsi if wave == 0
	xfill			hun_fsi_y0, i(hhid)
	lab var 		hun_fsi_y0 "Reduced meals eaten at baseline"
	
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
	
* create lockdown indicator
	gen				lock = 1 if nwave > 0 & nwave < 6
	replace			lock = 0 if lock == .

************************************************************************
**# 2 - fixed effects "studies"
************************************************************************

*** address this at a later date
	drop if			nwave == -1

	xtset			hhid

* month study
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			std_fsi_wt i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			 mld_fsi i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			mod_fsi i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			sev_fsi i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			sev_fsi i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			anx_fsi i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			mea_fsi i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			hun_fsi i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}
	
* lockdown study
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			std_fsi_wt i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			 mld_fsi i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			mod_fsi i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			sev_fsi i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			sev_fsi i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			anx_fsi i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			mea_fsi i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		xtreg 			hun_fsi i.lock fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							fe vce(cluster hhid)
	}

************************************************************************
**# 3 - difference in difference
************************************************************************

* covid did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					

	
* covid did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}				

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}	
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	
* lockdown did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.lock##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.lock##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}	
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.lock##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.lock##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.lock##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.lock##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.lock##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	
* lockdown did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.lock##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}				
		
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.lock##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}	
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.lock##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.lock##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.lock##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.lock##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.lock##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.nwave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
	}		
		
* month did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.sector##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					

	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.sector##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					

		levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.sector##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.sector##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
		
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.sector##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.sector##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.sector##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
		
	
* month did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.sexhh##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}				
		
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.sexhh##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					

		levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.sexhh##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.sexhh##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
		
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.sexhh##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.sexhh##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}					
	
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.sexhh##i.nwave fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							nocons vce(cluster hhid)
	}							
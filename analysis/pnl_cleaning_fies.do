* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by: jdm
* Last edit: 20 April 2022
* Stata v.17.0

* does
	* merges together all countries
	* renames variables
	* output cleaned panel data

* assumes
	* cleaned baseline country data
	* cleaned lsms_panel from wb_covid repo
	* xfill.ado
	* carryforward.ado

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define
	global  root    =	"$data/analysis"
	global	eth		=	"$data/ethiopia/refined/wave_00"
	global	mwi		=	"$data/malawi/refined/wave_00"
	global	nga		=	"$data/nigeria/refined/wave_00"
	global	bf		=	"$data/burkina_faso/refined/wave_00"
	global  ans		=   "$data/analysis/food_security"
	global	logout	=	"$data/analysis/food_security/logs"

* open log
	cap log 			close
	log using			"$logout/pnl_cleaning_fies", append


************************************************************************
**# 1 - clean covid fies
************************************************************************

* read in data
	use				"$root/lsms_panel", replace

* tabulate fies responses
	foreach v of numlist 1/8 {
		tab 			fies_`v', mi
	}

* recode all -99 and -98 as missing and yes = 1, no = 0
	foreach v of numlist 1/8 {
		replace 		fies_`v' = . if fies_`v' < 0
		replace 		fies_`v' = 0 if fies_`v' == 2
		lab val			fies_`v' yesno
	}

* fill in missing sexhh values
	tsset				hhid wave
	bys hhid (wave): 	carryforward sexhh, replace
	
	gen					nwave = -wave
	tsset				hhid nwave
	bys hhid (nwave): 	carryforward sexhh, replace	
	drop				nwave
	drop if 			sexhh == .
	
	
************************************************************************
**# 2 - build data set
************************************************************************

* append baseline 
	append 			using "$eth/r0_fies"
	append 			using "$mwi/r0_fies"
	append 			using "$nga/r-1_fies"
	append 			using "$nga/r0_fies"
	append 			using "$bf/r0_fies"
	
* generate household id
	drop				hhid

	gen 				hhid_eth1 = "e" + hhid_eth if hhid_eth != ""
	gen					hhid_mwi1 = "m" + hhid_mwi if hhid_mwi != ""
	tostring			hhid_nga, gen(hhid_nga1)
	replace 			hhid_nga1 = "n" + hhid_nga1 if hhid_nga1 != "."
	replace				hhid_nga1 = "" if hhid_nga1 == "."
	tostring 			hhid_uga, gen(hhid_uga1) format("%12.0f")
	replace 			hhid_uga1 = "u" + hhid_uga1 if hhid_uga1 != "."
	replace				hhid_uga1 = "" if hhid_uga1 == "."
	tostring			hhid_bf, gen(hhid_bf1)
	replace 			hhid_bf1 = "b" + hhid_bf1 if hhid_bf1 != "."
	replace				hhid_bf1 = "" if hhid_bf1 == "."
	gen					HHID = hhid_eth1 if hhid_eth1 != ""
	replace				HHID = hhid_mwi1 if hhid_mwi1 != ""
	replace				HHID = hhid_nga1 if hhid_nga1 != ""
	replace				HHID = hhid_uga1 if hhid_uga1 != ""
	replace				HHID = hhid_bf1 if hhid_bf1 != ""
	sort				HHID
	egen				hhid = group(HHID)
	drop				HHID hhid_eth1 hhid_mwi1 hhid_nga1 hhid_uga1 hhid_bf1
	lab var				hhid "Unique household ID"
	order 				country wave hhid resp_id hhid*
	
* drop households only in the baseline
	duplicates 			tag hhid, generate(dup)
	drop if				dup == 0
	drop if				dup == 1 & country == 3
	drop				dup
	
* drop uganda since there is no pre-covid fies
	drop if				country == 4

* generate pre/post covid indicator
	gen 				post = 0 if wave < 1
	replace 			post = 1 if post == .
	lab def				post 0 "Pre-Covid" 1 "Covid", replace
	lab val				post post
	lab var				post "Pandemic indicator"

* keep only necessary variables
	keep				country wave hhid hhsize hhsize_adult hhsize_child ///
							hhsize_schchild sexhh sector region fies_1 fies_2 ///
							fies_3 fies_4 fies_5 fies_6 fies_7 fies_8 fies_9 ///
							post hhw_cs concern_1 concern_2
							
	order				country hhid wave post region sector hhw_cs sexhh hhsize ///
							hhsize_adult hhsize_child hhsize_schchild
	
	sort				country hhid wave
	lab var				sexhh "Sex of household head"
	lab var				region "Region"
	lab var				sector "Urban or rural household"

* run intermediate file to create descriptive graphs for sector and sexhh
	run				"$code/analysis/figures/desc_hetero"				
	
* drop waves where no fies data exists
	drop if				country == 1 & wave == 7 
	drop if				country == 1 & wave == 8
	drop if				country == 1 & wave == 9
	drop if				country == 2 & wave == 4
	drop if				country == 2 & wave == 10
	drop if				country == 3 & wave == 3
	drop if				country == 3 & wave == 3
	drop if				country == 3 & wave == 5
	drop if				country == 3 & wave == 6
	drop if				country == 3 & wave == 8
	drop if				country == 3 & wave == 9
	drop if				country == 3 & wave == 10
	drop if				country == 3 & wave == 11
	drop if				country == 5 & wave == 1
	drop if				country == 5 & wave == 8
	drop if				country == 5 & wave == 11

* create new weights
	egen			hhw_covid = mean(hhw_cs) if wave > 0, by(hhid)
	xtset			hhid
	xfill			hhw_covid, i(hhid)
	lab var			hhw_covid "Household sampling weight"
	order			hhw_covid, after(hhw_cs)
	drop			hhw_cs
	
************************************************************************
**# 3 - build fies variables
************************************************************************

* generate no loss variables
	foreach 		i of numlist 1/9 {
					gen 	fies_`i'_noreplace = fies_`i'
					lab val fies_`i'_noreplace yesno
	}

* generate missing flags
	sort			country wave
	foreach 		x of numlist 1/9 {
		egen 			fs_`x'_missing = count(fies_`x'), by(country wave)
		replace			fs_`x'_missing = 1 if fs_`x'_missing != 0
		*** =1 if NOT missing, =0 if missing
	}
	
* ensure fies variables are binary
	foreach 		x of numlist 1/9 {
		replace			fies_`x' = 0 if fies_`x' == . & fs_`x'_missing != 0
		lab val 		fies_`x' yesno
	}
	
	
* tabulate fies responses
	foreach v of numlist 1/9 {
		tab 			fies_`v'_noreplace, mi
	}
	
* rename variables to match Bloem variables
	rename 			fies_1 fs6
	rename 			fies_2 fs7
	rename 			fies_3 fs8
	rename 			fies_4 fs1
	rename 			fies_5 fs2
	rename			fies_6 fs3
	rename			fies_7 fs4
	rename			fies_8 fs5
	rename			fies_9 fs9
	
	rename 			fies_1_noreplace fs6_nr
	rename 			fies_2_noreplace fs7_nr
	rename 			fies_3_noreplace fs8_nr
	rename 			fies_4_noreplace fs1_nr
	rename 			fies_5_noreplace fs2_nr
	rename			fies_6_noreplace fs3_nr
	rename			fies_7_noreplace fs4_nr
	rename			fies_8_noreplace fs5_nr
	rename			fies_9_noreplace fs9_nr
	
	rename			fs_1_missing fs6_msng
	rename			fs_2_missing fs7_msng
	rename			fs_3_missing fs8_msng
	rename			fs_4_missing fs1_msng
	rename			fs_5_missing fs2_msng
	rename			fs_6_missing fs3_msng
	rename			fs_7_missing fs4_msng
	rename			fs_8_missing fs5_msng
	rename			fs_9_missing fs9_msng
		
	label var 		fs1 "FIES 1: Worried will not have enough to eat"
	label var 		fs2 "FIES 2: Worried will not eat nutritious food"
	label var 		fs3 "FIES 3: Always eat the same thing"
	label var 		fs4 "FIES 4: Had to skip a meal"
	label var 		fs5 "FIES 5: Had to eat less than they should"
	label var 		fs6 "FIES 6: Found nothing to eat at home"
	label var 		fs7 "FIES 7: Hungry but did not eat"
	label var 		fs8 "FIES 8: Have not eaten all day"
	label var 		fs9 "FIES 9: Borrowed food or relied on help"
	
		
	label var 		fs1_nr "FIES 1: Worried will not have enough to eat - without replacement"
	label var 		fs2_nr "FIES 2: Worried will not eat nutritious food - without replacement"
	label var 		fs3_nr "FIES 3: Always eat the same thing - without replacement"
	label var 		fs4_nr "FIES 4: Had to skip a meal - without replacement"
	label var 		fs5_nr "FIES 5: Had to eat less than they should - without replacement"
	label var 		fs6_nr "FIES 6: Found nothing to eat at home - without replacement"
	label var 		fs7_nr "FIES 7: Hungry but did not eat - without replacement"
	label var 		fs8_nr "FIES 8: Have not eaten all day"
	label var 		fs9_nr "FIES 9: Borrowed food or relied on help - without replacement"
	
* generate food security index
	egen 			fsi = rowtotal(fs1 fs2 fs3 fs4 fs5 fs6 fs7 fs8), missing
	lab var			fsi "Sum of 8 FIES questions"
	
	egen 			fsi2 = rowtotal(fs1_nr fs2_nr fs3_nr fs4_nr fs5_nr ///
						fs6_nr fs7_nr fs8_nr), missing
	lab var			fsi2 "Sum of 8 FIES questions without replacement"

* binary food security indicators (Smith et al. 2017)
	gen				mld_fsi = (fsi > 0)
	lab var			mld_fsi "Mild food insecurity"
	
	gen				mod_fsi = (fsi > 3)
	lab var			mod_fsi "Moderate food insecurity"
	
	gen				sev_fsi = (fsi > 7)
	lab var			sev_fsi "severe food insecurity"
	
			
	gen 			mld2_fsi = (fsi2 > 0) if fsi2 != .
	lab var			mld_fsi "Mild food insecurity - without replacement"
	
	gen 			mod2_fsi = (fsi2 > 3) if fsi2 != .
	lab var			mod_fsi "Moderate food insecurity - without replacement"
	
	gen 			sev2_fsi = (fsi2 > 7) if fsi2 != .	
	lab var			sev_fsi "severe food insecurity - without replacement"
			
* additional binary food security based on FIES domains
	egen 			anx_fsi = rowtotal(fs1_nr fs2_nr), missing
	replace 		anx_fsi = 1 if anx_fsi > 0 & anx_fsi != .
	lab var			anx_fsi "Anxious about food security"
			
	egen 			mea_fsi = rowtotal(fs3_nr fs4_nr fs5_nr), missing
	replace 		mea_fsi = 1 if mea_fsi > 0 & mea_fsi !=.
	lab var			mea_fsi "Reduced meals eaten"
			
	egen 			hun_fsi = rowtotal(fs6_nr fs7_nr fs8_nr), missing
	replace 		hun_fsi = 1 if hun_fsi > 0 & hun_fsi !=.
	lab var			hun_fsi "Went hungry"
	
* standardized outcomes by country and pre/post
	levelsof 		country, local(levels)
	foreach 		c of local levels {
		foreach 		i in 0 1 {
			egen 			std_fs_`c'_`i' = std(fsi) if post == `i' & country == `c'
		}
	}

* standardized outcomes only by country not pre/post
	levelsof 		country, local(levels)
	foreach 		c of local levels {
		egen 			std_fs_`c' = std(fsi) if country == `c'
	}
	
* copy country and pre/post values into single variable
	gen 			std_fsi = .
	lab var			std_fsi "Standardized sum of 8 FIES questions"
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
		foreach 		i in 0 1 {
			replace			std_fsi = std_fs_`c'_`i' if post == `i' & country == `c'
		}
	}

* copy country values into single variable
	gen 			std_fsi_c = .
	lab var			std_fsi_c "Standardized sum of 8 FIES questions"
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
			replace			std_fsi_c = std_fs_`c' if country == `c'
	}

	drop			std_fs_*
	
* standardized by country and pre/post values outcomes (taking into account the sampling weight)
 	scalar 			define mean_std = 0
	scalar 			define sd_std = 1
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
		foreach 		i in 0 1 {
			qui sum 		fsi [aweight = hhw_covid] if post == `i' & country == `c'
			gen 			sumwt =`r(sum_w)' if post == `i' & country == `c'
			gen 			wtmean =`r(mean)' if post == `i' & country == `c'
			egen double		CSS = total( hhw_covid * (fsi-wtmean)^2 ) if post == `i' & country == `c'
			gen double 		variance = CSS/sumwt if post == `i' & country == `c'
			gen double 		std_fsi_`c'_`i' = ( sd_std * (fsi-wtmean) / sqrt(variance) )  ///
								+ mean_std if post == `i' & country == `c'	
			drop 			sumwt wtmean CSS variance
		}
	}
	
* standardized by country outcomes (taking into account the sampling weight)
	scalar 			define mean_std = 0
	scalar 			define sd_std = 1
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
			qui sum 		fsi [aweight = hhw_covid] if country == `c'
			gen 			sumwt =`r(sum_w)' if country == `c'
			gen 			wtmean =`r(mean)' if country == `c'
			egen double		CSS = total( hhw_covid * (fsi-wtmean)^2 ) if country == `c'
			gen double 		variance = CSS/sumwt if country == `c'
			gen double 		std_fsi_`c' = ( sd_std * (fsi-wtmean) / sqrt(variance) )  ///
								+ mean_std if country == `c'
			drop 			sumwt wtmean CSS variance
	}

* copy country and pre/post values into single variable		
 	gen 			std_fsi_wt = .
	lab var			std_fsi_wt "Standardized sum of 8 FIES questions (weighted)"
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
		foreach 		i in 0 1 {
			replace			std_fsi_wt = std_fsi_`c'_`i' if post == `i' & country == `c'
		}
	}

* copy country values into single variable	removed pre/post values due to above changes		
	gen 			std_fsi_wt_c = .
	lab var			std_fsi_wt_c "Standardized sum of 8 FIES questions (weighted)"
	
	levelsof 		country, local(levels)
	foreach 		c of local levels {
			replace			std_fsi_wt_c = std_fsi_`c' if country == `c'
	}

	drop			std_fsi_1* std_fsi_2* std_fsi_3* std_fsi_5*

* summarize values
	bys 			country post: ///
						sum std_fsi std_fsi_wt [aweight = hhw_covid]
						
	bys 			country: ///
						sum std_fsi_c std_fsi_wt_c [aweight = hhw_covid]


************************************************************************
**# 3 - end matter, clean up to save
************************************************************************
	
* identify unique identifier and describe data
	isid			hhid wave
	sort			hhid wave
	compress
	
* save 
	save			"$ans/fies_reg_data", replace

* close the log
	log	close
	
/* END */

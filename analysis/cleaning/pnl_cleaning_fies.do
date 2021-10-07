* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 6 October 2021
* Stata v.17.0

* does
	* merges together all countries
	* renames variables
	* output cleaned panel data

* assumes
	* cleaned baseline country data
	* cleaned lsms_panel from wb_covid repo

* TO DO:
	* add new rounds


************************************************************************
**# 0 - setup
************************************************************************

* run do files for each country (takes a little while to run)
	run				"$code/ethiopia/eth_fies_0"
	run 			"$code/malawi/mwi_fies_0"
	run				"$code/nigeria/nga_fies_pp0"
	run				"$code/nigeria/nga_fies_ph0"
	run 			"$code/burkina_faso/bf_fies_0"

* define
	global  root    =	"$data/analysis"
	global	eth		=	"$data/ethiopia/refined/wave_00"
	global	mwi		=	"$data/malawi/refined/wave_00"
	global	nga		=	"$data/nigeria/refined/wave_00"
	global	bf		=	"$data/burkina_faso/refined/wave_00"
	global	export	=	"$data/analysis/food_security"
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
	lab var				post "pandemic indicator"

* keep only necessary variables
	keep				country wave hhid hhsize hhsize_adult hhsize_child ///
							hhsize_schchild sexhh sector region fies_1 fies_2 ///
							fies_3 fies_4 fies_5 fies_6 fies_7 fies_8 fies_9 ///
							post hhw_cs
	
	order				country hhid wave post region sector hhw_cs sexhh hhsize ///
							hhsize_adult hhsize_child hhsize_schchild
	
	sort				country hhid wave
	
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

* deal with missing sexhh
	egen 			max_sex = max(sexhh), by(hhid)
	egen 			min_sex = min(sexhh), by(hhid)
	gen 			dif_sex = max_sex - min_sex
	tab 			dif_sex
	sort 			dif_sex hhid wave

* create new weights
	egen			hhw_covid = mean(hhw_cs) if wave > 0, by(hhid)
	xtset			hhid
	xfill			hhw_covid, i(hhid)
	
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
	
	rename 			fies_1_noreplace fs6_noreplace
	rename 			fies_2_noreplace fs7_noreplace
	rename 			fies_3_noreplace fs8_noreplace
	rename 			fies_4_noreplace fs1_noreplace
	rename 			fies_5_noreplace fs2_noreplace
	rename			fies_6_noreplace fs3_noreplace
	rename			fies_7_noreplace fs4_noreplace
	rename			fies_8_noreplace fs5_noreplace
	
		
	label var 		fs1 "(FS1) ... have been woried that you will not have enough to eat?"
	label var 		fs2 "(FS2) ... have been woried that you could not eat nutritious foods?"
	label var 		fs3 "(FS3) ... had to eat always the same thing?"
	label var 		fs4 "(FS4) ... had to skip a meal?"
	label var 		fs5 "(FS5) ... had to eat less than they should?"
	label var 		fs6 "(FS6) ... found nothing to eat at home?"
	label var 		fs7 "(FS7) ... been hungy but did not eat?"
	label var 		fs8 "(FS8) ... not eaten all day?"

	gen 			fs_index = (fs1 + fs2 + fs3 + fs4 + fs5 + fs6 + fs7 + fs8)
			
	gen 			fs_index_2 = (fs1_noreplace + fs2_noreplace + fs3_noreplace ///
						+ fs4_noreplace + fs5_noreplace + fs6_noreplace ///
						+ fs7_noreplace + fs8_noreplace) 

			*Binary food security indicators (Smith et al. 2017)
			gen mild_fs = (fs_index>0)
			gen moderate_fs = (fs_index>3)
			gen severe_fs = (fs_index>7)
			
			gen mild2_fs = (fs_index_2>0) 		if fs_index_2!=.
			gen moderate2_fs = (fs_index_2>3) 	if fs_index_2!=.
			gen severe2_fs = (fs_index_2>7)		if fs_index_2!=.		
			
			* Additional binary food security base don FIES domains
			gen anxiety 		= (fs1_noreplace + fs2_noreplace)
			replace anxiety = 1 if anxiety > 0 & anxiety !=.
			
			gen meal_reduction 	= (fs3_noreplace + fs4_noreplace + fs5_noreplace ) 
			replace meal_reduction = 1 if meal_reduction > 0 & meal_reduction !=.
			
			gen hunger 			= (fs6_noreplace + fs7_noreplace + fs8_noreplace) 
			replace hunger = 1 if hunger > 0 & hunger !=.			
			

			*Standardized outcomes
			egen std_fs_index = std(fs_index) if post==0
			
			egen std_fs_index_post1 = std(fs_index) if post==1
			replace std_fs_index = std_fs_index_post1 if post==1
			
			egen std_fs_index_post2 = std(fs_index) if post==2
			replace std_fs_index = std_fs_index_post2 if post==2
			
			* Standardized outcomes (taking into account the sampling weight)
			summarize fs_index [aweight=hhweight_covid] if post==0
			gen fs_index_mean0 = r(mean)
			gen fs_index_sd0 = r(sd)
			
			summarize fs_index [aweight=hhweight_covid] if post==1
			gen fs_index_mean1 = r(mean)
			gen fs_index_sd1 = r(sd)
			
			gen std_fs_index_wt = (fs_index - fs_index_mean0)/fs_index_sd0 if post==0
			replace std_fs_index_wt = (fs_index - fs_index_mean1)/fs_index_sd1 if post==1
						
* test regressions
bys country: reg fies_2 i.post##i.sector, vce(cluster hhid)

	
/* END */

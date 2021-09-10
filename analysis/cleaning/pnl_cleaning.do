* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 2 September 2021
* Stata v.17.0

* does
	* merges together all countries
	* renames variables
	* output cleaned panel data

* assumes
	* cleaned country data

* TO DO:
	* add new rounds


************************************************************************
**# 0 - setup
************************************************************************

* run do files for each country (takes a little while to run)
	run				"$code/ethiopia/eth_build_master"
	run 			"$code/malawi/mwi_build_master"
	run				"$code/nigeria/nga_build_master"
	run 			"$code/uganda/uga_build_master"
	run 			"$code/burkina_faso/bf_build_master"

* define
	global	eth		=	"$data/ethiopia/refined"
	global	mwi		=	"$data/malawi/refined"
	global	nga		=	"$data/nigeria/refined"
	global	uga		=	"$data/uganda/refined"
	global	bf		=	"$data/burkina_faso/refined"
	global	export	=	"$data/analysis"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 			close
	log using			"$logout/analysis", append


************************************************************************
**# 1 - build data set
************************************************************************

* read in data
	use					"$eth/eth_panel", clear
	append using 		"$mwi/mwi_panel"
	append using 		"$nga/nga_panel"
	append using		"$uga/uga_panel"
	append using		"$bf/bf_panel"

	lab def				country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda" 5 "Burkina Faso", replace
	lab val				country country
	lab var				country "Country"

	lab def				region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
						"Oromia" 1005 "Somali" 1006 "Benishangul-Gumuz" 1007 ///
						"SNNPR" 1008 "Gambela" 1009 "Harar" 1010 ///
						"Addis Ababa" 1011 "Dire Dawa" 2101 "Chitipa" 2102 ///
						"Karonga" 2103 "Nkhata Bay" 2104 "Rumphi" 2105 ///
						"Mzimba" 2106 "Likoma" 2107 "Mzuzu City" 2201 ///
						"Kasungu" 2202 "Nkhotakota" 2203 "Ntchisi" 2204 ///
						"Dowa" 2205 "Salima" 2206 "Lilongwe" 2207 ///
						"Mchinji" 2208 "Dedza" 2209 "Ntcheu" 2210 ///
						"Lilongwe City" 2301 "Mangochi" 2302 "Machinga" 2303 ///
						"Zomba" 2304 "Chiradzulu" 2305 "Blantyre" 2306 ///
						"Mwanza" 2307 "Thyolo" 2308 "Mulanje" 2309 ///
						"Phalombe" 2310 "Chikwawa" 2311 "Nsanje" 2312 ///
						"Balaka" 2313 "Neno" 2314 "Zomba City" 2315 ///
						"Blantyre City" 3001 "Abia" 3002 "Adamawa" 3003 ///
						"Akwa Ibom" 3004 "Anambra" 3005 "Bauchi" 3006 ///
						"Bayelsa" 3007 "Benue" 3008 "Borno" 3009 ///
						"Cross River" 3010 "Delta" 3011 "Ebonyi" 3012 ///
						"Edo" 3013 "Ekiti" 3014 "Enugu" 3015 "Gombe" 3016 ///
						"Imo" 3017 "Jigawa" 3018 "Kaduna" 3019 "Kano" 3020 ///
						"Katsina" 3021 "Kebbi" 3022 "Kogi" 3023 "Kwara" 3024 ///
						"Lagos" 3025 "Nasarawa" 3026 "Niger" 3027 "Ogun" 3028 ///
						"Ondo" 3029 "Osun" 3030 "Oyo" 3031 "Plateau" 3032 ///
						"Rivers" 3033 "Sokoto" 3034 "Taraba" 3035 "Yobe" 3036 ///
						"Zamfara" 3037 "FCT" 4012 "Central" 4013 ///
						"Eastern" 4014 "Kampala" 4015 "Northern" 4016 ///
						"Western" 4017 "North" 4018 "Central" 4019 "South" ///
						5001 "Boucle du Mouhoun" 5002 "Cascades" 5003 "Centre" ///
						5004 "Centre-Est" 5005 "Centre-Nord" 5006 "Centre-Ouste" ///
						5007 "Centre-Sur" 5008 "Est" 5009 "Hauts Bassins" ///
						5010 "Nord" 5011 "Plateau-Central" 5012 "Sahel" ///
						5013 "Sud-Ouest", replace
	lab val				region region


************************************************************************
**# 2 - revise ID variables as needed
************************************************************************

* drop variables with open responses
	drop 				dis_gov* sup_cmpln_done sup_cmpln_who emp_safos

* destring string variables
	replace 			ag_quant_kgcon = "" if ag_quant_kgcon == "##N/A##" | ///
						ag_quant_kgcon  == "don't know  yet"
	replace 			ag_quant_kgcon = subinstr(ag_quant_kgcon, "kg","",.)
	replace 			ag_quant_kgcon = subinstr(ag_quant_kgcon, "KG SACK","",.)
	destring 			ag_quant_kgcon, replace

* drop if variable contains all missing values
	foreach 			var of varlist _all {
		 capture 		assert mi(`var')
		 if 			!_rc {
			drop 		`var'
		 }
	 }

* define yes/no label
	lab	def				yesno 0 "No" 1 "Yes", replace

* generate household id
	replace 			hhid_eth = "e" + hhid_eth if hhid_eth != ""
	replace 			hhid_mwi = "m" + hhid_mwi if hhid_mwi != ""
	tostring			hhid_nga, replace
	replace 			hhid_nga = "n" + hhid_nga if hhid_nga != "."
	replace				hhid_nga = "" if hhid_nga == "."
	rename 				hhid_uga hhid_uga1
	egen 				hhid_uga = group(hhid_uga1)
	tostring 			hhid_uga, replace
	replace 			hhid_uga = "" if country != 4
	replace 			hhid_uga = "u" + hhid_uga if hhid_uga != ""
	tostring			hhid_bf, replace
	replace 			hhid_bf = "b" + hhid_bf if hhid_bf != "."
	replace				hhid_bf = "" if hhid_bf == "."

	gen					HHID = hhid_eth if hhid_eth != ""
	replace				HHID = hhid_mwi if hhid_mwi != ""
	replace				HHID = hhid_nga if hhid_nga != ""
	replace				HHID = hhid_uga if hhid_uga != ""
	replace				HHID = hhid_bf if hhid_bf != ""
	sort				HHID
	egen				hhid = group(HHID)
	drop				HHID hhid_eth hhid_mwi hhid_nga hhid_uga* hhid_bf
	lab var				hhid "Unique household ID"
	order 				country hhid resp_id hhid*

* generate weights
	foreach x in cs pnl {
		rename				phw_`x' hhw_`x'
		lab var				hhw_`x' "Household sampling weight- `x'"
		gen					phw_`x' = hhw_`x' * hhsize
		lab var				phw_`x' "Population weight- `x'"
		gen 				ahw_`x' = hhw_`x' * hhsize_adult
		lab var 			ahw_`x' "Household adult sampling weight- `x'"
		gen 				chw_`x' = hhw_`x' * hhsize_child
		lab var 			chw_`x' "Household child sampling weight- `x'"
		gen 				shw_`x' = hhw_`x' * hhsize_schchild
		lab var 			shw_`x' "Household school child sampling weight- `x'"
	}
		order				hhw_pnl phw* ahw* chw* shw*, after(hhw_cs)

* admin/general
	replace 			relate_hoh = . if relate_hoh == -98 | relate_hoh == 98


************************************************************************
**# 3 - revise knowledge, myths, behavior, and coping variables
************************************************************************

* know
	replace 			know = 0 if know == 2
	forval 				x = 1/10 {
		replace 		know_`x' = 0 if know_`x' == 2
		lab val 		know_`x' yesno
	}

* myths
 	loc myth			myth_1 myth_2 myth_3 myth_4 myth_5
	foreach 			var of varlist `myth' {
		replace			`var' = 3 if `var' == -98
	}

* behavior
	replace 			bh_1 = 0 if bh_1 > 1 & bh_1 < .
	replace 			bh_2 = 0 if bh_2 == 2
	replace 			bh_2 = . if bh_2 == 3
	replace 			bh_3 = . if bh_3 == 3 | bh_3 < 0
	replace 			bh_3 = 0 if bh_3 == 2
	replace 			bh_4 = 0 if bh_4 == 2
	replace 			bh_5 = 0 if bh_5 == 2
	gen 				bh_8 = . if bh_freq_mask < 0 | bh_freq_mask == 6
	replace 			bh_8 = 0 if bh_freq_mask == 5
	replace				bh_8 = 1 if bh_freq_mask == 1 | bh_freq_mask == 2 | ///
							bh_freq_mask == 3 | bh_freq_mask == 4
	lab var 			bh_8 "Wore mask in public in last 7 days"
	lab val 			bh_8 yesno

	lab def 			bh_freq_gath 0 "none" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5 or more", replace
	lab val 			bh_freq_gath bh_freq_gath
	replace 			emp_saf_fol = . if emp_saf_fol == -97

* mental health
	lab def 			mh 0 "not at all" 1 "several days" 2 "more than half of the time" ///
							3 "almost every day"
	forval 				x = 1/8 {
		lab val 		mh_`x' mh
	}

* government
	lab def 			satis 1 "yes" 2 "no" 3 "neither satisfied nor unsatisfied"
	lab val 			satis satis

* coping (create cope_any = 1 if any coping used, 0 if not, . if no data for that wave)
	egen 				tempgrp = group(country wave)
	levelsof			(tempgrp), local(countrywave)
	foreach 			cw in `countrywave' {
		preserve
		keep 			if tempgrp == `cw'
		gen				cope_any = 1 if cope_1 == 1 | cope_2 == 1 | cope_3 == 1 | ///
						cope_4 == 1 | cope_5 == 1 | cope_6 == 1 | ///
						cope_7 == 1 | cope_8 == 1 | cope_9 == 1 | ///
						cope_10 == 1 | cope_11 == 1 | cope_12 == 1 | ///
						cope_13 == 1 | cope_14 == 1 | cope_15 == 1 | ///
						cope_17 == 1 | cope_18 == 1
		egen 			cope_tot = total(cope_any)
		replace 		cope_any = 0 if cope_any == . & cope_tot != 0
		tempfile 		temp`cw'
		save 			`temp`cw''
		restore
	}
	clear
	foreach 			cw in `countrywave' {
		append 			using `temp`cw''
	}
	drop 				tempgrp cope_tot cope_16
	lab var				cope_any "Adopted any coping strategy"
	lab val 			cope_any yesno

	gen					cope_none = 1 if cope_any == 0
	replace				cope_none = 0 if cope_any == 1
	lab var				cope_none "Did nothing"

	lab def				myth 0 "No" 1 "Yes" 3 "Don't Know"

	local myth			myth_1 myth_2 myth_3 myth_4 myth_5
	foreach 			v in `myth' {
	    replace 		`v' = 3 if `v' == -98
		replace 		`v' = 0 if `v' == 2
		lab val			`v' myth
	}


************************************************************************
**# 4 - revise access variables as needed
************************************************************************

* access to medicine
	replace				ac_med = . if ac_med < 0 & country == 1
	replace				ac_med = 0 if ac_med == 2
	replace				ac_med = . if ac_med == 3
	replace 			ac_med = 2 if ac_med == 0 & country == 4
	replace 			ac_med = 0 if ac_med == 1 & country == 4
	replace 			ac_med = 1 if ac_med == 2 & country == 4
	replace 			ac_med_why = . if ac_med_why < 0
	replace 			ac_med_need = 0 if ac_med_need == 2

	* note "decrease in reg income" and "no money" both coded as 6
 	lab def 			ac_med_why 1 "Shops have run out of stock" ///
							2 "Local markets not operating / closed" ///
							3 "Limited / no transportation" ///
							4 "Restriction to go outside" 5 "Increase in price" ///
							6 "Cannot afford"
	lab val 			ac_med_why ac_med_why

* access to medical services
	replace				ac_medserv_need = . if ac_medserv_need < 0 | ac_medserv_need == 99
	replace 			ac_medserv_need = 0 if ac_medserv_need == 2

	replace				ac_medserv = . if ac_medserv == 99
	replace 			ac_medserv = 0 if ac_medserv == 2

	replace 			ac_medserv_why = . if ac_medserv_why < 0
	lab def				ac_medserv_why 1 "lack of money" 2 "no med personnel" ///
								3 "facility full" 4 "facility closed" ///
								5 "not enough supplies" 6 "lack of transportation/too far" ///
								7 "restriction to go out" 8 "afraid to get virus" ///
								9 "on suspicion of having virus" 10 "refused treatment by facility" ///
								, replace
	lab val 			ac_medserv_why ac_medserv_why

	lab def 			ac_medserv_type_why 1 "lack of money" 2 "no med personnel" ///
							3 "facility full" 4 "facility closed" 5 "not enough supplies" ///
							6 "health facility is too far" 7 "fear of contracting virus" ///
							8 "lockdown/travel restrictions"
	forval 				x = 2/7 {
		lab val 		ac_medserv_type_`x'_why ac_medserv_type_why
		replace 		ac_medserv_type_`x' = 0 if ac_medserv_type_`x' == 2
		replace 		ac_medserv_type_`x' = . if ac_medserv_type_`x' == 99
	}

* access to pre-natal care
	replace 			ac_nat_filter = 0 if ac_nat_filter == 2
	replace 			ac_nat_need = 0 if ac_nat_need == 2
	replace 			ac_nat_need = . if ac_nat_need > 97
	replace 			ac_nat = 0 if ac_nat == 2

* access to preventative care
	replace 			ac_prev_app = 0 if ac_prev_app == 2
	replace 			ac_prev_canc = 1 if ac_prev_canc == 2

* access to vaccines
	replace 			ac_vac = 0 if ac_vac == 2
	replace 			ac_vac_need = 0 if ac_vac_need == 2
	replace 			cov_vac = 2 if cov_vac == 0
	lab def 			cov_vac 1 "Yes" 2 "No" 3 "Not sure"
	lab val 			cov_vac cov_vac

* access to soap
	replace 			ac_soap = 0 if ac_soap == 2
	replace 			ac_soap_why = . if ac_soap_why == 96
	lab def 			ac_soap_why 1 "shops out" 2 "markets closed" 3 "lack of transportation" ///
							4 "restriction to go out" 5 "increase in price" 6 "lack of money" ///
							7 "cannot afford" 8 "afraid to get virus" 9 "cannot talk about it", replace
	lab val 			ac_soap_why ac_soap_why

* access to staples
	lab def 			staple_def 1 "Maize" 2 "Rice" 3 "Matooke" 4 "Cassava" ///
							5 "Millet" 6 "Sorghum" 7 "Sweet Potatoes" 8 "Irish Potatoes"
	lab val 			ac_staple_def staple_def
	* Ethiopia
		foreach 		var in ac_oil ac_teff ac_wheat {
			replace 	`var' = . if `var' < 0
			gen 		`var'_need = 0 if country == 1 & `var' == .
			replace 	`var'_need = 1 if country == 1 & `var'_need == .
		}
		foreach 		var in ac_maize ac_med {
			replace 	`var' = . if `var' < 0
			replace 	`var'_need = 0 if country == 1 & `var' == .
			replace 	`var'_need = 1 if country == 1 & `var'_need == .
		}
		// change not applicable/did not need to buy to not needed (2)
		replace			ac_staple_need = 2 if country == 1 & (ac_oil == . & ac_teff == . & ///
						ac_wheat == . & ac_maize == .)
		// change missing ac_staple_need (needed to buy) to 1
		replace			ac_staple_need = 1 if ac_staple_need == . & country == 1
		replace			ac_staple = 1 if ac_staple_need == 1 & country == 1 & ///
						(ac_oil == 1 | ac_teff == 1 | ac_wheat == 1 | ac_maize == 1)
		replace			ac_staple = 0 if ac_staple == . & ac_staple_need == 1 & ///
						country == 1
	* Malawi
		replace 		ac_maize_why = . if ac_maize_why < 0 | ac_maize_why == 7
		replace 		ac_maize = 0 if ac_maize == 2
		replace 		ac_maize_need = 0 if ac_maize_need == 2
		replace 		ac_staple = 0 if ac_staple == 2 & country == 2
		replace 		ac_staple_need = 0 if ac_staple_need == 2
	* Nigeria
		foreach 		s in rice beans cass yam sorg onion {
			replace 	ac_`s' = 0 if ac_`s' == 2
			replace 	ac_`s'_need = 0 if ac_`s'_need == 2
		}
		replace 		ac_staple_need = 1 if country == 3 & (ac_rice_need == 1 | ///
						ac_beans_need == 1 | ac_cass_need == 1 | ac_yam_need == 1 | ///
						ac_sorg_need == 1 | ac_onion_need == 1)
		replace 		ac_staple_need = 0 if country == 3 & ac_rice_need == 0 & ///
						ac_beans_need == 0 & ac_cass_need == 0 & ac_yam_need == 0 & ///
						ac_sorg_need == 0 & (ac_onion_need == 0 | ac_onion_need == .)
		// Note: some rounds they don't ask about onion so allow that to be 0 or .
		replace 		ac_staple = 1 if country == 3 & (ac_rice == 1 | ac_beans == 1 | ///
						ac_cass == 1 | ac_yam == 1 | ac_sorg == 1 | ac_onion == 1)
		replace 		ac_staple = 0 if country == 3 & ((ac_rice == 0 & ac_rice_need == 1 ) ///
						| (ac_beans == 0 & ac_beans_need == 1) | (ac_cass == 0 & ac_cass_need == 1) ///
						| (ac_yam == 0 & ac_yam_need == 1)  | (ac_sorg == 0 & ac_sorg_need == 1) ///
						| (ac_onion == 0 & ac_onion_need == 1))
	* Uganda
		replace 		ac_staple_need = 0 if ac_staple == 3 & country == 4
		replace 		ac_staple_need = 1 if ac_staple == 1 | ac_staple == 2
		replace 		ac_staple = . if ac_staple == 3 & country == 4
		replace 		ac_staple = 0 if ac_staple == 1 & country == 4
		replace 		ac_staple = 1 if ac_staple == 2 & country == 4
		replace 		ac_sauce = . if ac_sauce == 3
		replace 		ac_sauce = 0 if ac_sauce == 2

	* Burkina Faso
		replace 		ac_staple = 1 if country == 5 & (ac_staple_1 == 1 | ///
							ac_staple_2 == 1 | ac_staple_3 == 1)
		replace 		ac_staple = 0 if country == 5 & ((ac_staple_1 == 2 & ac_staple_1_need == 1) | ///
							(ac_staple_2 == 2 & ac_staple_2_need == 1) | ///
							(ac_staple_3 == 2 & ac_staple_3_need == 1))
	* NOTE: does not include ac_staple_why for countries where ac_staple was generated

* access to drinking water
	replace 			ac_drink = . if ac_drink == 3 & country == 2
	replace 			ac_drink = 0 if ac_drink == 1 & (country == 2 | country == 4 | country == 5)
	replace 			ac_drink = 1 if ac_drink == 2 & (country == 2 | country == 4 | country == 5)
	replace 			ac_drink = 0 if ac_drink == 2 & country == 3
	replace 			ac_drink_why = . if (ac_drink_why == -96 | ac_drink_why > 94)
	lab def 			ac_drink_why 1 "water supply not available" 2 "water supply reduced" ///
							3 "unable to access communal supply" 4 "unable to access water tanks" ///
							5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
							8 "restriction to go out" 9 "increase in price" 10 "cannot afford" ///
							11 "unable to buy water" 12 "fear of catching the virus", replace
	lab val 			ac_drink_why ac_drink_why

* access to water for handwashing
	replace 			ac_water = 0 if ac_water == 2
	replace 			ac_water_why = . if (ac_water_why < 0 | ac_water_why > 94)
	lab def 			ac_water_why 1 "water supply not available" 2 "water supply reduced" ///
							3 "unable to access communal supply" 4 "unable to access water tanks" ///
							5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
							8 "restriction to go out" 9 "increase in price" 10 "cannot afford" ///
							11 "afraid to get viurs" 12 "water source too far" ///
							13 "too many people at water source" 14 "large household size" ///
							15 "lack of money/resources" 16 "cannot talk about it", replace
	lab val 			ac_water_why ac_water_why

* access to cleaning supllies
	replace 			ac_clean_need = 0 if ac_clean_need == 2
	replace 			ac_clean = 0 if ac_clean == 2

* access to bank
	replace 			ac_bank = 1 if ac_bank_need == 1 & country == 1
	replace 			ac_bank = 0 if ac_bank_need == 2 & country == 1
	replace 			ac_bank_need = 1 if country == 1 & (ac_bank_need == 1 | ac_bank_need == 2)
	replace 			ac_bank_need = 0 if ac_bank_need == 2
	replace 			ac_bank_need = . if ac_bank_need < 0
	lab val 			ac_bank_need yesno
	replace 			ac_bank = 0 if ac_bank == 2
	replace 			ac_bank_why = . if ac_bank_why < 0 | ac_bank_why > 95
	replace 			ac_bank_why = 4 if ac_bank_why == 3 & country == 4

* access to credit
	replace 			ac_cr_need = 0 if ac_cr_need == 2

	replace 			ac_cr_loan = . if ac_cr_loan < 0
	replace 			ac_cr_loan = 0 if ac_cr_loan == 2
	lab def 			ac_cr_loan 0 "Unable or did not try" 1 "Yes"
	lab val 			ac_cr_loan ac_cr_loan
	* NOTE: Uganda data seems off, missing instead of "no"

	lab var 			ac_cr_lend_1 "Lender: friend or relative"
	lab var 			ac_cr_lend_2 "Lender: neighbour"
	lab var 			ac_cr_lend_3 "Lender: local merchant"
	lab var 			ac_cr_lend_4 "Lender: money lender"
	lab var 			ac_cr_lend_5 "Lender: employer"
	lab var 			ac_cr_lend_6 "Lender: religious institution"
	lab var 			ac_cr_lend_7 "Lender: microfinance institution"
	lab var 			ac_cr_lend_8 "Lender: bank"
	lab var 			ac_cr_lend_9 "Lender: NGO"
	lab var 			ac_cr_lend_10 "Lender: saccos"
	lab var 			ac_cr_lend_11 "Lender: cooperative society"
	lab var 			ac_cr_lend_12 "Lender: saving association"
	lab var 			ac_cr_lend_13 "Lender: hire purchase"
	lab var 			ac_cr_lend_14 "Lender: womens group"
	lab var 			ac_cr_lend_15 "Lender: adashi/esusu/ajo"

	drop 				ac_cr_who* ac_cr_bef_who* ac_cr_att_who* ac_cr_slc_who*

	replace 			ac_cr_due = 7 if ac_cr_due == -97
	lab def 			ac_cr_due 1 "Already Due" 2 "Within One Month" ///
							3 "Within 2-3 Months" 4 "Within 4-6 Months" 5 "Within 7-12 Months" ///
							6 "More Than 12 Months" 7 "Already Repaid"
	lab val 			ac_cr_due ac_cr_due

	replace 			ac_cr_bef = . if ac_cr_bef < 0
	replace 			ac_cr_bef = 0 if ac_cr_bef ==2

	replace 			ac_cr_worry = . if ac_cr_worry == -99
	replace 			ac_cr_worry =  5 if ac_cr_worry == -97
	lab def 			ac_cr_worry 1 "very worried" 2 "somewhat worried" 3 "not too worried" ///
							4 "not worried at all" 5 "already repaid"
	lab val 			ac_cr_worry ac_cr_worry

	replace 			ac_cr_miss = . if ac_cr_miss < 0
	replace 			ac_cr_miss = 0 if ac_cr_miss == 2

	replace 			ac_cr_delay = . if ac_cr_delay < 0 | ac_cr_delay > 97
	replace 			ac_cr_delay = 0 if ac_cr_delay == 2

	replace 			ac_cr_att = 0 if ac_cr_att == 2
	replace 			ac_cr_slc = 0 if ac_cr_slc == 2

* negate questions (unable to access)
 /* note: cannot negate preventative care and credit (only mwi & nga ask if needed loan,
	others just ask if took out loan, not if able to access loan) */
	foreach 			var in ac_soap ac_med ac_medserv ac_nat ac_vac ac_oil ac_teff ///
						ac_wheat ac_maize ac_rice ac_beans ac_cass ac_yam ac_sorg ///
						ac_staple ac_clean ac_nat ac_bank ac_water ac_drink {
		replace 		`var' = 2 if `var' == 1
		replace 		`var' = 1 if `var' == 0
		replace 		`var' = 0 if `var' == 2
		lab val 		`var' yesno
	}

	replace				ac_med = . if ac_med == 3 & country == 4
	replace				ac_med = 0 if ac_med == 2 & country == 4

	lab val				ac_med yesno

* access to soap
	lab val				ac_soap .
	lab var				ac_soap "Unable to access soap"

	replace				ac_soap = 0 if ac_soap == 1
	replace				ac_soap = 1 if ac_soap == 2

	lab val				ac_soap yesno

* access oil/teff/wheat in Ethiopia
	replace				ac_oil = . if ac_oil == -97
	replace				ac_oil = . if ac_oil == -98
	replace				ac_oil = 2 if ac_oil == 1
	replace				ac_oil = 1 if ac_oil == 0
	replace				ac_oil = 0 if ac_oil == 2
	lab var				ac_oil "Unable to access oil"
	lab val				ac_oil yesno

	replace				ac_teff = . if ac_teff == -99
	replace				ac_teff = . if ac_teff == -97
	replace				ac_teff = . if ac_teff == -98
	replace				ac_teff = 2 if ac_teff == 1
	replace				ac_teff = 1 if ac_teff == 0
	replace				ac_teff = 0 if ac_teff == 2
	lab var				ac_teff "Unable to access teff"
	lab val				ac_teff yesno

	replace				ac_wheat = . if ac_wheat == -99
	replace				ac_wheat = . if ac_wheat == -97
	replace				ac_wheat = . if ac_wheat == -98
	replace				ac_wheat = 2 if ac_wheat == 1
	replace				ac_wheat = 1 if ac_wheat == 0
	replace				ac_wheat = 0 if ac_wheat == 2
	lab var				ac_wheat "Unable to access wheat"
	lab val				ac_wheat yesno

	replace				ac_maize = . if ac_maize == -99 & country == 1
	replace				ac_maize = . if ac_maize == -97 & country == 1
	replace				ac_maize = . if ac_maize == -98 & country == 1
	replace				ac_maize = 2 if ac_maize == 1 & country == 1
	replace				ac_maize = 1 if ac_maize == 0 & country == 1
	replace				ac_maize = 0 if ac_maize == 2 & country == 1
	lab var				ac_maize "Unable to access maize"
	lab val				ac_maize yesno

* access to maize/clean/water in Malawi
	replace				ac_maize = 0 if ac_maize == 1 & country == 2
	replace				ac_maize = 1 if ac_maize == 2 & country == 2

	lab val				ac_clean .
	replace				ac_clean = 0 if ac_clean == 1 & country == 2
	replace				ac_clean = 1 if ac_clean == 2 & country == 2
	lab val				ac_clean yesno

* access to staples in Nigeria
	replace				ac_rice = 0 if ac_rice == 1 & country == 3
	replace				ac_rice = 1 if ac_rice == 2 & country == 3
	lab var				ac_rice "Unable to access rice"
	lab val				ac_rice yesno

	replace				ac_beans = 0 if ac_beans == 1 & country == 3
	replace				ac_beans = 1 if ac_beans == 2 & country == 3
	lab var				ac_beans "Unable to access beans"
	lab val				ac_beans yesno

	replace				ac_cass = 0 if ac_cass == 1 & country == 3
	replace				ac_cass = 1 if ac_cass == 2 & country == 3
	lab var				ac_cass "Unable to access cassava"
	lab val				ac_cass yesno

	replace				ac_yam = 0 if ac_yam == 1 & country == 3
	replace				ac_yam = 1 if ac_yam == 2 & country == 3
	lab var				ac_yam "Unable to access yam"
	lab val				ac_yam yesno

	replace				ac_sorg = 0 if ac_sorg == 1 & country == 3
	replace				ac_sorg = 1 if ac_sorg == 2 & country == 3
	lab var				ac_sorg "Unable to access sorghum"
	lab val				ac_sorg yesno

	replace				ac_clean = 0 if ac_clean == 1 & country == 3
	replace				ac_clean = 1 if ac_clean == 2 & country == 3

* access to staple
	lab val				ac_staple .
	replace				ac_staple = 0 if ac_staple == 1 & country == 2
	replace				ac_staple = 1 if ac_staple == 2 & country == 2

	replace				ac_staple = . if ac_staple == 3 & country == 4
	replace				ac_staple = 0 if ac_staple == 2 & country == 4
	lab var				ac_staple "Unable to access staple"
	lab var				ac_sauce "Unable to access sauce"
	lab var				ac_clean "Unable to access cleaning supplies"
	lab var				ac_nat "Unable to access pre-natal care"
	lab var				ac_bank "Unable to access bank"
	lab var				ac_water "Unable to access water for handwashing"
	lab var				ac_drink "Unable to access drinking water"

 * access to masks (already asks "unable")
	replace 			ac_mask = . if ac_mask == 3
	replace 			ac_mask = 0 if ac_mask == 2
	lab val 			ac_mask yesno

	lab var 			ac_med_why "Reason unable to access medicine"
	lab var 			ac_medserv_why "Reason unable to access medical services"
	lab var 			ac_soap_why "Reason unable to purchase soap"
	lab var 			ac_bank_why "Reason unable to access bank"
	lab var 			ac_water_why "Reason unable to access water for washing hands"
	lab var 			ac_drink_why "Reason unable to access water for drinking"
	lab var 			ac_clean_why "Reason unable to access cleaning supplies"
	lab var 			ac_maize_why "Reason unable to purchase maize"
	lab var 			ac_oil_why "Reason unable to access oil"
	lab var 			ac_teff_why "Reason unable to access teff"
	lab var 			ac_wheat_why "Reason unable to access wheat"
	lab var 			ac_rice_why "Reason unable to access rice"
	lab var 			ac_beans_why "Reason unable to access beans"
	lab var 			ac_cass_why "Reason unable to access cassava"
	lab var 			ac_yam_why "Reason unable to access yam"
	lab var 			ac_sorg_why "Reason unable to access sorghum"
	lab var 			ac_staple_why "Reason unable to access staple foods"
	lab var 			ac_sauce_why "Reason unable to access sauce"


************************************************************************
**# 5 - clean concerns
************************************************************************

* turn concern into binary
	replace				concern_1 = 0 if concern_1 == 3 | concern_1 == 4
	replace				concern_1 = 1 if concern_1 == 2
	lab val				concern_1 yesno

	replace				concern_2 = 0 if concern_2 == 3 | concern_2 == 4
	replace				concern_2 = 1 if concern_2 == 2
	lab val				concern_2 yesno


************************************************************************
**# 6 - income changes
************************************************************************
	replace 			tot_inc_chg = . if tot_inc_chg == -98 | tot_inc_chg == -99
	loc inc				farm_inc bus_inc wage_inc isp_inc pen_inc gov_inc ngo_inc oth_inc asst_inc
	foreach 			var of varlist `inc' {
		replace			`var' = 0 if `var' == 2 | `var' == -98
		replace 		`var' = . if `var' == -99
		lab val			`var' yesno
	}
	gen 				other_inc = 0 if isp_inc == 0 | pen_inc == 0 | gov_inc == 0 | ///
							ngo_inc == 0 | oth_inc == 0 | asst_inc == 0
	replace				other_inc = 1 if isp_inc == 1 | pen_inc == 1 | gov_inc == 1 | ///
							ngo_inc == 1 | oth_inc == 1 | asst_inc == 1
	lab var 			other_inc "other income sources (isp, pen, gov, ngo, oth, asst)"
	lab val 			other_inc  yesno

	replace				farm_chg = . if farm_inc == 0
	replace				bus_chg = . if bus_inc == 0
	replace				wage_chg = . if wage_inc == 0
	replace				isp_chg = . if isp_inc == 0
	replace				pen_chg = . if pen_inc == 0
	replace				gov_chg  = . if gov_inc == 0
	replace				ngo_chg  = . if ngo_inc == 0
	replace				oth_chg  = . if oth_inc == 0
	replace				asst_chg  = . if asst_inc == 0

	lab def				change -1 "Reduce" 0 "Stayed the same" 1 "Increased"

	loc chg				farm_chg bus_chg wage_chg isp_chg pen_chg gov_chg ngo_chg ///
							oth_chg asst_chg rem_dom_chg rem_for_chg
	foreach 			var of varlist `chg' {
		replace				`var' = 0 if `var' == 2
		replace				`var' = 0 if `var' == -98
		replace				`var' = -1 if `var' == 3
		replace				`var' = -1 if `var' == 4
		lab val				`var' change
		}

	gen 				remit_chg = 1 if rem_dom_chg == 1 | rem_for_chg == 1
	replace 			remit_chg = 0 if remit_chg == .
	lab var 			remit_chg "change in remittances (foreign, domestic)"

	gen 				other_chg = 0 if isp_chg == 0 | pen_chg == 0 | ngo_chg == 0 | ///
						gov_chg == 0 | oth_chg == 0 | asst_chg == 0
	replace 				other_chg = 1 if isp_chg == 1 | pen_chg == 1 | ngo_chg == 1 | ///
						gov_chg == 1 | oth_chg == 1 | asst_chg == 1
	lab var 			other_chg "change in other income sources (isp, pen, gov, ngo, oth, asst)"

	gen					farm_dwn = 1 if farm_chg == -1
	replace				farm_dwn = 0 if farm_chg == 0 | farm_chg == 1
	gen					bus_dwn = 1 if bus_chg == -1
	replace				bus_dwn = 0 if bus_chg == 0 | bus_chg == 1
	gen					wage_dwn = 1 if wage_chg == -1
	replace				wage_dwn = 0 if wage_chg == 0 | wage_chg == 1
	gen					isp_dwn = 1 if isp_chg == -1
	replace				isp_dwn = 0 if isp_chg == 0 | isp_chg == 1
	gen					pen_dwn = 1 if pen_chg == -1
	replace				pen_dwn = 0 if pen_chg == 0 | pen_chg == 1
	gen					gov_dwn = 1 if gov_chg == -1
	replace				gov_dwn = 0 if gov_chg == 0 | gov_chg == 1
	gen					ngo_dwn = 1 if ngo_chg == -1
	replace				ngo_dwn = 0 if ngo_chg == 0 | ngo_chg == 1
	gen					rem_dom_dwn = 1 if rem_dom_chg == -1
	replace				rem_dom_dwn = 0 if rem_dom_chg == 0 | rem_dom_chg == 1
	gen					rem_for_dwn = 1 if rem_for_chg == -1
	replace				rem_for_dwn = 0 if rem_for_chg == 0 | rem_for_chg == 1

	lab var				farm_dwn "Farm income reduced"
	lab var				bus_dwn "Business income reduced"
	lab var				wage_dwn "Wage income reduced"
	lab var				isp_dwn "Investment income reduced"
	lab var				pen_dwn "Pension income reduced"
	lab var				gov_dwn "Gov. assistance reduced"
	lab var				ngo_dwn "NGO assistance reduced"
	lab var				rem_dom_dwn "Remittances (dom) reduced"
	lab var				rem_for_dwn "Remittances (for) reduced"

	egen 				dwn_count9 = rsum (farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn ///
							gov_dwn ngo_dwn rem_dom_dwn rem_for_dwn)
	lab var 			dwn_count9 "count of income sources which are down - total of nine"
	gen 				dwn_per9 = dwn_count9 / 9
	label var 			dwn_per9 "percent of income sources which had losses - total of nine"

	loc dwn				farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn gov_dwn ngo_dwn ///
							rem_dom_dwn rem_for_dwn
	foreach 			var of varlist `dwn' {
		lab val				`var' yesno
		}

	gen					work_dwn = 1 if farm_dwn == 1 | bus_dwn == 1
	replace				work_dwn = 0 if farm_dwn == 0 & work_dwn == .
	replace				work_dwn = 0 if bus_dwn == 0 & work_dwn == .
	lab var 			work_dwn "Farm/firm income reduced"
	lab val				work_dwn yesno

	gen 				remit_dwn = 1 if rem_for_dwn == 1 | rem_dom_dwn == 1
	replace 			remit_dwn = 0 if rem_for_dwn == 0 & remit_dwn == .
	replace				remit_dwn = 0 if rem_dom_dwn == 0 & remit_dwn == .
	lab var 			remit_dwn "Remittances (foreign, domestic) reduced"
	lab val				remit_dwn yesno

	gen 				other_dwn = 1 if isp_dwn == 1| pen_dwn == 1 | gov_dwn == 1 | ngo_dwn == 1
	replace				other_dwn = 0 if isp_dwn == 0 & other_dwn == .
	replace				other_dwn = 0 if pen_dwn == 0 & other_dwn == .
	replace				other_dwn = 0 if gov_dwn == 0 & other_dwn == .
	replace				other_dwn = 0 if ngo_dwn == 0 & other_dwn == .
	lab var 			other_dwn "Other income sources (isp, pen, gov, ngo) reduced"
	lab val				other_dwn yesno

	egen 				dwn_count = rsum(work_dwn wage_dwn remit_dwn other_dwn)
	lab var 			dwn_count "count of income sources which are down"
	replace				dwn_count = . if farm_dwn == . & bus_dwn == . & ///
							wage_dwn == . & remit_dwn == . & other_dwn == .

	gen 				dwn_percent = dwn_count / 4
	label var 			dwn_percent "percent of income sources which had losses"

	gen					dwn = 1 if dwn_count != 0 & dwn_count != .
	replace 			dwn = 0 if dwn_count == 0
	lab var 			dwn "=1 if household experience any type of income loss"

	order 				farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn gov_dwn ///
							ngo_dwn rem_dom_dwn rem_for_dwn remit_dwn other_dwn dwn dwn_count  ///
							 dwn_percent, after(rem_for_chg)


	* generate remittance income variable
	replace 			rem_dom = 2 if rem_dom == 0
	replace 			rem_for = 2 if rem_for == 0
	replace 			rem_dom = . if rem_dom <0
	replace 			rem_for = . if rem_for <0
	replace				remit_inc = 0 if rem_dom == 2 | rem_for == 2
	replace 			remit_inc = 1 if rem_dom == 1 | rem_for == 1
	lab val 			remit_inc yesno
	* others fine as is: bus_inc farm_inc wage_inc

	* business income
	replace 			bus_emp_inc = . if bus_emp_inc < 0
	replace 			bus_beh = 0 if bus_beh == 2


************************************************************************
**# 7 - clean food security information
************************************************************************

	loc fies				fies_01 fies_02 fies_03 fies_04 fies_05 fies_06 fies_07 fies_08

	egen 				fies_count = rsum(fies_1 fies_2 fies_3 fies_4 fies_5 ///
							fies_6 fies_7 fies_8)
	gen 				fies_percent = fies_count / 8


************************************************************************
**# 8 - clean education & early childhood development questions
************************************************************************

	replace 			sch_att = 0 if sch_att == 2
	replace				edu_cont = 0 if edu_cont == 2
	lab val				edu_cont yesno
	replace 			sch_open = 0 if sch_open == 2
	replace 			sch_open = . if sch_open == 3

	ds sch_prec_prac*
	foreach 			var in `r(varlist)' {
	    replace 			`var' = 0 if `var' == 2
	}

	replace 			sch_reopen = 0 if sch_reopen == 2
	replace 			sch_reopen = . if sch_reopen == -99

	lab var				edu_cont_9 "Going to school to pick holiday package"

	replace 			edu_act = 0 if edu_act == 2
	replace				edu_act = . if edu_act == -99 | edu_act == -98

	replace 				sch_child = 0 if sch_child == 2
	replace					sch_child = . if sch_child == -99

	replace 			sch_child = 0 if sch_child == 2
	replace				sch_child = . if sch_child == -99

	foreach 			x in 1 2 3 4 5 act {
		replace			edu_`x' = 0 if edu_`x'_prim == 0
		replace			edu_`x' = 0 if edu_`x'_sec == 0
		replace			edu_`x' = 1 if edu_`x'_prim == 1
		replace			edu_`x' = 1 if edu_`x'_sec == 1
	}

	lab var				edu_1 "Completed assignments provided by the teacher"
	lab var				edu_2 "Used mobile learning apps"
	lab var				edu_3 "Watched educational TV programs"
	lab var				edu_4 "Listened to educational programs & classroom teachings on radio"
	lab var				edu_5 "Session/meeting with lesson teacher (Tutor)"
	lab var				edu_6 "Studying/reading on their own"
	lab var				edu_7 "Taught by parent or other household member"
	lab var				edu_8 "Used reading materials provided by government"
	lab var				edu_9 "Private Tutor"
	lab var				edu_10 "Home school"
	lab var				edu_11 "Revisions of textbooks/notes from past classes"
	lab var				edu_12 "Newspaper"
	lab var				edu_13 "Participated in virtual classes with their teacher"
	lab var				edu_14 "Watched lessons pre-recorded by their online teacher"
	lab var				edu_15 "Watching classroom instruction via television"
	lab var				edu_16 "Continued to visit the Daara"
	lab var				edu_17 "Resumed school"

	lab def 			sch_prec_sat 1 "Not satisfied" 2 "Somewhat satisfied" ///
							3 "Satisfied"
	lab val 			sch_prec_sat sch_prec_sat

	* early childhood development
	lab def 			ecd_rel 1 "mother" 2 "father" 3 "sibling" 4 "grandparent" ///
							5 "other relative" 6 "non-relative/household worker", replace
	lab val 			ecd_pcg_relate ecd_resp_relate ecd_rel

	replace 			ecd_pcg = 96 if ecd_pcg == 2 | ecd_pcg == 77
	lab def 			ecd_pcg 1 "Person completing interview" 96 "Other"
	lab val 			ecd_pcg ecd_pcg

	foreach 			x in play read story song out ncd {
		replace 			ecd_`x' = . if ecd_`x' == 98 | ecd_`x' == 97 | ecd_`x' == 888 ///
								| ecd_`x' == -98
		replace 			ecd_`x' = 0 if ecd_`x' == 2
	}
	forval 				x = 1/8 {
		replace 			ecd_ed_`x' = . if ecd_ed_`x' == 888 | ecd_ed_`x' == 98
	}
	forval 				x = 1/6 {
		replace 			ecd_bh_`x' = . if ecd_bh_`x' == 888
		replace 			ecd_disc_`x' = . if ecd_disc_`x' == 888
	}
	replace 			ecd_disc = . if ecd_disc == 888
	replace 			ecd_hv_bks = . if ecd_hv_bks == 98


************************************************************************
**# 9 - clean agriculture and livestock variables
************************************************************************

	replace 			ag_crop = 0 if ag_crop == 2 | ag_crop == 3
	replace 			ag_crop = . if ag_crop < 0
	lab val 			ag_crop yesno

	replace 			ag_live_sell = . if ag_live_sell == 97
	replace 			ag_live_sell_chg = . if ag_live_sell_chg == 98 | ag_live_sell_chg == -98
	replace 			ag_live_sell_pr = . if ag_live_sell_pr == 98
	replace 			harv_sell = . if harv_sell == 3
	replace 			harv_sell_rev = . if harv_sell_rev == 99
	replace 			ag_ext = . if ag_ext < 0
	replace 			ag_ext_need = . if ag_ext_need < 0
	replace 			ag_plan = . if ag_plan < 0
	replace 			ag_sell_rev_exp = . if ag_sell_rev_exp == -97

	foreach var in 		ag_live ag_live_sell ag_live_sell_able ag_live_affect ag_live_sell_want ///
							harv_cov harv_sell ag_ext ag_ext_need ag_plan ag_main_harv_comp ///
							ag_sell_norm {
		replace 			`var' = 0 if `var' == 2
		lab val 			`var' yesno
	}

	ds 					ag_use_*
	foreach 			var  in `r(varlist)' {
	    replace 			`var' = . if `var' > 97
	}

	* ag_chg invert ethiopia, change other for consistency
		replace 		ag_chg = . if country == 1 & (ag_chg < 0 | ag_chg == 2)
		replace 		ag_chg = 0 if country == 1 & ag_chg == 1
		replace 		ag_chg = 1 if country == 1 & ag_chg == 3
		replace 		ag_chg = 0 if country > 1  & ag_chg == 3
		replace			ag_chg = . if country > 1  & ag_chg == 2
		lab val 		ag_chg yesno


************************************************************************
**# 10 - clean employment variables
************************************************************************

	foreach 			var in emp_pre emp emp_same contrct emp_cont_1 ///
							emp_cont_2 emp_cont_3 emp_cont_4 rtrn_emp wage_emp {
		replace 			`var' = . if `var' < 0
		replace 			`var' = 0 if `var' == 2
		lab val 			`var' yesno
	}

	replace 			emp_stat = 4 if country == 1 & (emp_stat == 2 | emp_stat == 3 ///
							| emp_stat == 5  | emp_stat == 6 | emp_stat == 12)
	replace 			emp_stat = 6 if emp_stat == 1 & country == 1
	replace 			emp_stat = 1 if emp_stat == 7 & country == 1
	replace 			emp_stat = -96 if country == 1 & (emp_stat == 8 | ///
							emp_stat == 9 | emp_stat == 10)
	replace 			emp_stat = 5 if country == 1 & emp_stat == 11
	replace 			emp_stat = 123 if country == 3 & emp_stat == 5
	replace 			emp_stat = 5 if country == 3 & emp_stat == 6
	replace 			emp_stat = 6 if country == 3 & emp_stat == 123
	replace 			emp_stat = . if emp_stat == -99
	lab def 			emp_stat 1 "Own business" 2 "Family business" ///
							3 "Family farm" 4 "Employee for someone else" ///
							5 "Apprentice, trainee, intern" ///
							6 "Employee for the government" -96 "Other"
	lab val 			emp_stat emp_stat

	foreach 			var in emp_able bus_emp farm_emp farm_norm {
		replace 			`var' = 0 if `var' == 2
		replace 			`var'= . if `var '< 0
	}
	replace 			bus_emp = . if bus_emp > 97

	replace 			emp_chg_why = 96 if emp_chg_why == -96
	lab def 			emp_chg_why 1 "Bus closed due to COVID restrictions" ///
							2 "Bus closed not due to COVID restrictions/another reason" ///
							3 "Laid off" 4 "Furlough" 5 "Vacation" 6 "Ill/quarentined" ///
							7 "Cared for ill relative" 8 "Seasonal worker" ///
							9 "Retired" 10 "Not able to farm due to movt restrictions" ///
							11 "Not able to farm due to lack of inputs" ///
							12 "Not farm season" 13 "Lack of transportation" ///
							14 "Do not want to be exposed to the virus" ///
							15 "focus on secondary activity" 16 "Better opportunity" ///
							17 "PREVIOUS BUSINESS/JOB CLOSED DUE TO ENDSARS PROTESTS" ///
							18 "Student" 96 "Other", replace
	lab val				emp_chg_why emp_chg_why

	replace 			emp_unable = . if emp_unable == 4 | emp_unable == -98
	replace 			emp_unable = 3 if emp_unable == 0
	lab def 			emp_unable 1 "Full normal payment" 2 "Partial payment" ///
							3 "No payment", replace
	lab val 			emp_unable emp_unable

	replace 			rtrn_emp_when = 0 if rtrn_emp_when > 97 & rtrn_emp_when < .
	replace 			rtrn_emp_when = 6 if rtrn_emp_when == 5 & country == 2
	* in mwi 4 there is a "just returned to job" option coded as 5 (inconsistent with nga) but no one selected it, this line included in case it is selected in future rounds
	lab def 			rtrn_emp_when 1 "Within one week" 2 "Within one month" ///
							3 "Within 3 months" 4 "More than 3 months" ///
							5 "When restrictions are lifted" 6 "Just returned to the job" ///
							0 "Don't know"
	lab val				rtrn_emp_when rtrn_emp_when

	lab def 			emp_search_how 1 "APPLY TO PROSPECTIVE EMPLOYERS" ///
							2 "PLACE OR ANSWER JOB ADVERTISEMENTS" ///
							3 "STUDY OR READ JOB ADVERTISEMENTS" ///
							4 "REGISTER WITH (EMPLOYMENT CENTER)" ///
							5 "REGISTER WITH PRIVATE RECRUITMENT OFFICES" ///
							6 "TAKE A TEST OR INTERVIEW" ///
							7 "SEEK HELP FROM RELATIVES, FRIENDS, OTHERS" ///
							8 "CHECK AT FACTORIES, WORK SITES" ///
							9 "WAIT ON THE STREET TO BE RECRUITED" ///
							10 "SEEK FINANCIAL HELP TO START A BUSINESS" ///
							11 "LOOK FOR LAND, BUILDING, EQUIPMENT, MATERIALS TO START A BUSINESS" ///
							12 "APPLY FOR PERMIT OR LICENSE TO START A BUSINESS" ///
							13 "developed a business plan" ///
							14 "Post/Update CV on professional social media sites" ///
							96 "Other"
	lab val 			emp_search_how emp_search_how

	replace 			emp_act = . if emp_act == -99
	lab def 			emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
							3 "Wholesale/retail" 4 "Transportation services" ///
							5 "Restaurants/hotels" 6 "Public Administration" ///
							7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
							10 "Mining" 11 "Professional/scientific/technical activities" ///
							12 "Electic/water/gas/waste" 13 "Buying/selling" ///
							14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing", replace
	lab val 			emp_act emp_act

	lab def 		clsd 1 "USUAL PLACE OF BUSINESS CLOSED DUE TO CORONAVIRUS LEGAL RESTRICTIONS" ///
						2 "USUAL PLACE OF BUSINESS CLOSED FOR ANOTHER REASON" ///
						3 "NO COSTUMERS / FEWER CUSTOMERS" 4 "CAN'T GET INPUTS" ///
						5 "CAN'T TRAVEL / TRANSPORT GOODS FOR TRADE" ///
						7 "ILLNESS IN THE HOUSEHOLD" 8 "NEED TO TAKE CARE OF A FAMILY MEMBER" ///
						9 "SEASONAL CLOSURE" 10 "VACATION" 11 "LACK OR LOSS OF CAPITAL" ///
						12 "USUAL PLACE OF BUSINESS CLOSED DUE TO ENDSARS PROTESTS" ///
						13 "INCREASE IN THE PRICE OF INPUTS", replace
	lab val 		bus_closed clsd


************************************************************************
**# 11 - shocks
************************************************************************

	lab var 		shock_1 "Death or disability of an adult working member of the household"
	lab var 		shock_2 "Death of someone who sends remittances to the household"
	lab var 		shock_3 "Illness of an earning household member"
	lab var 		shock_4 "Loss of important contact"
	lab var 		shock_5 "Job Loss"
	lab var 		shock_6 "Bankruptcy of a non-agricultural family business"
	lab var 		shock_7 "Theft of crops, money, livestock or other property"
	lab var 		shock_8 "Poor harvest due to lack of manpower"
	lab var 		shock_9 "Disease/Pest invasion that caused harvest failure or storage loss"
	lab var 		shock_10 "Increase in the price of inputs"
	lab var 		shock_11 "Decrease in the selling price of production"
	lab var 		shock_12 "Increase in the price of the main foods consumed"
	lab var 		shock_13 "Floods"
	lab var 		shock_14 "Other Shock"
	lab var 		shock_15 "Disruption of farming, livestock, fishing activities"


************************************************************************
**# 12 - end matter, clean up to save
************************************************************************

	order 				wave, after(hhid)
	order 				know* curb* gov* satis* info* bh* ac_cr* ac_*  sch* edu_c* edu* emp* ///
						bus* farm* wage* rem* *_inc *_chg *dwn cope* fies* ag* harv* ag_live* ///
						shock* concern* symp*, after(neighborhood_id) alpha
	order 				ac_cr_lend_10 ac_cr_lend_11 ac_cr_lend_12 ac_cr_lend_13 ac_cr_lend_14 ///
						ac_cr_lend_15, after(ac_cr_lend_9)
	order				ag_crop_pl_10 ag_crop_pl_11 ag_crop_pl_12, after(ag_crop_pl_9)
	order 				ag_sold_10 ag_sold_11 ag_sold_12, after(ag_sold_9)
	order 				cope_10 cope_11 cope_12 cope_13 cope_14 cope_15, after(cope_9)
	order				gov_10 gov_11 gov_12 gov_13 gov_14 gov_15 gov_16, after(gov_9)
	order 				info_10 info_11 info_12 info_13, after(info_9)
	order 				sch_att_why_10 sch_att_why_11 sch_att_why_12 sch_att_why_13 ///
						sch_att_why_14, after(sch_att_why_9)
	order 				sch_prec_10 sch_prec_11, after(sch_prec_9)
	order 				shock_10 shock_11 shock_12 shock_13 shock_14 shock_15, after(shock_9)
	order 				symp_10 symp_11 symp_12 symp_13 symp_14 symp_15, after(symp_9)
	order 				know_10, after(know_9)

* save file
	save			"$export/lsms_panel", replace

* close the log
	log	close

/*
************************************************************************
**# 13 - generate variable-country-wave crosswalk
************************************************************************
	preserve
	drop 				country wave baseline
	ds
	restore
	foreach 			var in `r(varlist)' {
		preserve
		keep 			country wave `var'
		collapse 		(sum) `var', by(country wave)
		replace 		`var' = 1 if `var' != 0
		gen 			country_s = cond(country == 1, "eth", cond(country == 2, ///
						"mwi", cond(country == 3, "nga", cond(country == 4, "uga","bf"))))
		drop 			country
		reshape 		wide `var', i(country) j(wave)
		gen 			variable = _n
		reshape 		wide `var'*, i(variable) j(country_s) string
		levelsof 		variable, local(t)
		* drop if variable contains all missing values
		foreach 			v of varlist _all {
			 capture 		assert mi(`v')
			 if 			!_rc {
				drop 		`v'
			 }
		 }
		tostring 		variable, replace
		replace 		variable = "`var'"
		collapse 		(sum) `var'*, by(variable)
		foreach 		c in eth mwi nga uga bf {
			rename 		`var'*`c' `c'*
		}
		tempfile 		temp`var'
		save 			`temp`var''
		restore
	}
	preserve
	drop 				country wave urban baseline
	ds
	clear
	foreach 			var in `r(varlist)' {
		append 			using `temp`var''
	}

	export 				excel "$output_f/variable_country_wave_crosswalk.xlsx", ///
							sheetreplace sheet(Vars_waves) first(var)
	restore

	
/* END */

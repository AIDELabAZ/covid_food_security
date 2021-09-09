* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: amf
* Last edited: Nov 2020 
* Stata v.16.1

* does
	* cleans Nigeria panel

* assumes
	* raw Nigeria data

* TO DO:
	* add round 6
	* figure out log close error
	* when new waves available:
		* create build for new wave based on previous ones
		* update global list of waves below
		* check variable crosswalk for differences/new variables & update code if needed
		* check QC flags for issues/discrepancies

		
* **********************************************************************
* 0 - setup
* **********************************************************************

* define list of waves
	global 			waves "1" "2" "3" "4" "5" "6" "7" "8" "9" "10" "11"
	
* define 
	global	root	=	"$data/nigeria/raw"
	global	export	=	"$data/nigeria/refined"
	global	logout	=	"$data/nigeria/logs"

* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

    if `"`c(username)'"' == "aljosephson" {
        global 		code  	"C:/Users/aljosephson/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

	if `"`c(username)'"' == "annfu" {
		global 		code  	"C:/Users/annfu/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
	}
	
* open log
	cap log 		close
	log using 		"$logout/nga_build", append

	
* **********************************************************************
* 1 - run do files for each round & generate variable comparison excel
* **********************************************************************

* run do files for all rounds and create crosswalk of variables by wave
	foreach 		r in "$waves" {
		do 			"$code/nigeria/nga_build_`r'"
	}
	do 				"$code/nigeria/nga_build_0"
	

* ***********************************************************************
* 2 - create nigeria panel 
* ***********************************************************************

* append round datasets to build master panel
	foreach 		r in "$waves" {
	    if 			`r' == 1 {
			use		"$export/wave_01/r1", clear
		}
		else if 			`r' > 1 & `r' < 10 {
		    append 	using "$export/wave_0`r'/r`r'"
		}
		else {
			append 	using "$export/wave_`r'/r`r'"
		}
	}
	compress 
	
* adjust household id
	recast 			long hhid
	format 			%12.0g hhid
	
* merge in baseline data 
	merge m:1		hhid using "$root/wave_00/Nigeria GHS-Panel 2018-19 Quintiles", nogen

* rename quintile variable
	rename 			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui	

* create country variable
	gen				country = 3		

* replace all missing values as . (not .a, .b, etc.)
	quietly: ds, has(type numeric)
	foreach var in `r(varlist)' {
		replace 		`var' = . if `var' > .
	} 
	
	
* ***********************************************************************
* 3 - clean nigeria panel
* ***********************************************************************	
	
* rationalize variables across waves
	gen				phw_cs = .
	rename 			wt_baseline wt_round1
	foreach 		r in "$waves" {
		replace		phw_cs = wt_round`r' if wt_round`r' != . & wave == `r'
	}	
	lab var			phw_cs "sampling weights - cross section"
	drop			wt_round* weight	
	gen 			phw_pnl = .
	foreach 		r in 3 4 5 {
		replace 	phw_pnl = wt_r`r'panel 
	}
	drop 			wt_r*panel
	lab var			phw_pnl "sampling weights - panel"
		
* administrative variables 	
	rename			sector urb_rural 
	gen				sector = 2 if urb_rural == 1
	replace			sector = 1 if urb_rural == 2
	lab var			sector "Sector"
	lab def			nga_sec 1 "Rural" 2 "Urban"
	lab val			sector nga_sec
	drop			urb_rural
	rename 			filter2 children05
	rename 			filter1 children520
	
* SWIFT
	rename 			s3aq1 swift_rice
	rename 			s3aq2 swift_chick
	rename 			s3aq3 swift_beef
	rename 			s3aq4 swift_milkp
	rename 			s3aq5 swift_card
	rename 			s3aq6__1 swift_cook_wood
	rename 			s3aq6__2 swift_cook_oth
	rename 			s3aq6__3 swift_cook_na
	rename 			s3aq7 swift_toilet
	rename 			s3aq8__1 swift_elec_gen
	rename 			s3aq8__2 swift_elec_oth
	rename 			s3aq8__3 swift_elec_na
	
* covid variables
 * know
	rename 			s3q1  know
	rename			s3q2__1 know_1
	lab var			know_1 "Handwashing with Soap Reduces Risk of Coronavirus Contraction"
	rename			s3q2__2 know_9
	lab var			know_9 "Use of Sanitizer Reduces Risk of Coronavirus Contraction" 
	rename			s3q2__3 know_2
	lab var			know_2 "Avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract"
	rename 			s3q2__4 know_3 
	replace 		know_3 = 1 if s3q2__5 == 1
	replace 		know_3 = 0 if s3q2__5 == 0 & know_3 == .
	lab var			know_3 "Using Masks and/or Gloves Reduces Risk of Coronavirus Contraction"
	rename			s3q2__6 know_4
	lab var			know_4 "Avoiding Travel Reduces Risk of Coronavirus Contraction"
	rename			s3q2__7 know_5
	lab var			know_5 "Staying at Home Reduces Risk of Coronavirus Contraction"
	rename			s3q2__8 know_6
	lab var			know_6 "Avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction"
	rename			s3q2__9 know_7
	lab var			know_7 "Mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Contraction"
	rename			s3q2__10 know_8
	lab var			know_8 "Avoiding Face Touching Reduces Risk of Coronavirus Contraction" 
	
 * gov
	rename 			s3q3__1 gov_1
	lab var 		gov_1 "government taken steps to advise citizens to stay home"
	rename 			s3q3__2 gov_10
	lab var 		gov_10 "government taken steps to advise to avoid social gatherings"
	rename 			s3q3__3 gov_2
	lab var 		gov_2 "government restricted travel within country"
	rename 			s3q3__4 gov_3
	lab var 		gov_3 "government restricted international travel"
	rename 			s3q3__5 gov_4
	lab var 		gov_4 "government closure of schools and universities"
	rename 			s3q3__6 gov_5
	lab var			gov_5 "government institute government / lockdown"
	rename 			s3q3__7 gov_6
	lab var 		gov_6 "government closure of non-essential businesses"
	rename 			s3q3__8 gov_11
	lab var 		gov_11 "government steps of sensitization / public awareness"
	rename			s3q3__9 gov_14
	lab var			gov_14 "government establish isolation centers"
	rename 			s3q3__10 gov_15
	lab var 		gov_15 "government disinfect public spaces"
	rename 			s3q3__96 gov_16
	lab var			gov_16 "government take other steps"
	rename 			s3q3__11 gov_none 
	lab var 		gov_none "government has taken no steps"
	rename 			s3q3__98 gov_dnk
	lab var 		gov_dnk "do not know steps government has taken"
	
* satisfaction + government perspectives 
	rename 			s3q4 satis 
	rename 			s3q5__1 satis_1
	rename			s3q5__2 satis_2 
	rename 			s3q5__3 satis_3
	rename 			s3q5__4 satis_4 
	rename 			s3q5__5 satis_5 
	rename 			s3q5__6 satis_6 
	rename 			s3q5__96 satis_7 
	
* behavior
	rename			s4q1 bh_1
	rename			s4q2 bh_2
	rename 			s4q3 bh_3
	rename			s4q4 bh_4

* access variables
 * define labels
	lab def 		ac_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
						4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
						7 "cannot afford" 8 "afraid to get virus" 
	lab val			ac_soap_why ac_med_why ac_clean_why ac_rice_why ac_beans_why ///
						ac_cass_why ac_yam_why ac_sorg_why ac_why
	lab def			yesno 1 "Yes" 2 "No", replace
						
 * format access variables
	rename 			s5q1c bh_freq_wash
	rename 			s5q1d bh_freq_mask
	rename 			s5q1e bh_freq_gath
	lab def			bh_freq_gath 1 "1" 2 "2" 3 "3" 4 "4" 5 "5 or more"
	lab val			bh_freq_gath bh_freq_gath

* housing 
	rename 			s5aq1 hh_move
	rename 			s5aq2 hh_move_from
	forval 			x = 1/12{
	    rename 		s5aq3__`x' hh_move_why_`x'
	}
	rename 			s5aq4 hh_own
	rename 			s5aq5 hh_rent_due
	rename 			s5aq6a hh_rent_pay
	rename 			s5aq6b hh_rent_able
	rename 			s5aq7__* hh_rent_why_*
	drop 			hh_rent_why_96
	
* credit	
	rename 			s5bq1 ac_cr_loan
	forval 			x = 1/9 {
		rename 		s5bq2__`x' ac_cr_lend_`x'
	}
	rename 			ac_cr_lend_1 ac_cr_lend_11
	rename 			ac_cr_lend_2 ac_cr_lend_12
	rename 			ac_cr_lend_6 ac_cr_lend_1
	rename 			ac_cr_lend_8 ac_cr_lend_13
	rename 			ac_cr_lend_4 ac_cr_lend_8
	rename 			ac_cr_lend_7 ac_cr_lend_4
	rename 			ac_cr_lend_3 ac_cr_lend_7
	rename 			ac_cr_lend_5 ac_cr_lend_15
	rename 			ac_cr_lend_9 ac_cr_lend_14
	drop 			s5bq2__96
	forval 			x = 1/13 {
		rename 		s5bq3__`x' ac_cr_why_`x'
	}
	drop 			s5bq3__96
	forval 			x = 1/4 {
	    rename 		s5bq4_`x' ac_cr_who_`x'
	}
	rename 			s5bq5 ac_cr_due
	rename 			s5bq6 ac_cr_bef
	forval 			x = 1/13 {
	    rename 		s5bq7__`x' ac_cr_bef_why_`x'
	}
	drop 			s5bq7__96 s5bq7_os
	forval 			x = 1/3 {
	    rename 		s5bq8_`x' ac_cr_bef_who_`x'
	}
	rename 			s5bq9 ac_cr_worry
	rename 			s5bq10 ac_cr_miss
	rename 			s5bq11 ac_cr_delay

* early childhood development 
	rename 			s5dq0 children210
	rename 			ch_name ecd_id
	rename 			cg_prim ecd_pcg 
	replace 		ecd_pcg = 1 if ecd_pcg == 3
	rename 			cg_primoth1 ecd_pcg_mem
	rename 			cg_primoth2 ecd_pcg_id
	rename 			cg_primoth3 ecd_pcg_relate
	
	rename 			hla_play ecd_play
	rename 			hla_read ecd_read
	rename 			hla_story ecd_story
	rename 			hla_sing ecd_song
	rename 			hla_outside ecd_out
	rename 			hla_count ecd_ncd
	rename 			hla_books ecd_hv_bks
	rename 			nbooks ecd_num_bks
	
	rename 			ed_radio ecd_ed_1
	rename 			ed_tv ecd_ed_2
	rename 			ed_comp ecd_ed_3
	rename 			ed_smart ecd_ed_5
	rename 			ed_print ecd_ed_7
	
	rename 			preschool_yn ecd_ed_pre
	rename 			preschool_lvl ecd_ed_pre_lvl
		
* employment variables 
	rename			s6q1 emp
	rename			s6q2 emp_pre
	rename			s6q3 emp_pre_why
	rename			s6q4 emp_pre_act
	rename			s6q5 emp_act
	replace 		emp_act = 12 if emp_act == 3
	replace 		emp_act = 13 if emp_act == 5
	replace 		emp_act = 11 if emp_act == 7
	replace 		emp_act = 7 if emp_act == 9
	replace 		emp_act = 0 if emp_act == 4
	replace 		emp_act = 4 if emp_act == 6
	replace 		emp_act = 6 if emp_act == 8
	replace 		emp_act = 8 if emp_act ==  0
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
	rename			s6q6 emp_stat
	rename 			s6q6a emp_purp
	replace 		emp_purp = s6bq6a if emp_purp == . & s6bq6a != .
	rename			s6q7 emp_able
	rename			s6q8 emp_unable	
	rename			s6q8a emp_unable_why
	rename			s6q9 emp_hh
	rename			s6q11 bus_emp
	rename			s6q12 bus_sect
	rename			s6q13 bus_emp_inc
	rename			s6q14 bus_why
	rename			s6q17__1 farm_why_1
	rename			s6q17__2 farm_why_2
	rename			s6q17__3 farm_why_3
	rename			s6q17__4 farm_why_4
	rename			s6q17__5 farm_why_5
	rename			s6q17__6 farm_why_6
	drop			s6q17__96  
	
	rename 			s6q1a rtrn_emp
	rename 			s6q1b rtrn_emp_when 
	rename 			s6q1c emp_why
	rename 			s6q3a emp_search
	rename 			s6q3b emp_search_how
	rename			s6q4a emp_same
	rename			s6q4b emp_chg_why 
	replace 		emp_chg_why = 18 if emp_chg_why == 16
	replace 		emp_chg_why = 17 if emp_chg_why == 15
	replace 		emp_chg_why = 15 if emp_chg_why == 13 
	replace 		emp_chg_why = 16 if emp_chg_why == 14 
	rename 			s6q8b emp_hrs
	replace 		emp_hrs = s6q8b1 if emp_hrs == . & s6q8b1 != .
	rename 			s6q8c1 emp_hrs_norm
	rename 			s6q8c emp_hrs_chg 
	rename			s6q8d__1 emp_cont_1
	rename			s6q8d__2 emp_cont_2
	rename			s6q8d__3 emp_cont_3
	rename			s6q8d__4 emp_cont_4
	rename			s6q8e contrct
	rename 			s6q8f_* emp_saf*
	rename 			s6q8g emp_saf_fol
	rename 			s6q11a bus_stat 
	rename 			s6q11b bus_closed 
	replace 		bus_closed = 7 if bus_closed == 6
	lab def 		clsd 1 "USUAL PLACE OF BUSINESS CLOSED DUE TO CORONAVIRUS LEGAL RESTRICTIONS" ///
						2 "USUAL PLACE OF BUSINESS CLOSED FOR ANOTHER REASON" ///
						3 "NO COSTUMERS / FEWER CUSTOMERS" 4 "CAN'T GET INPUTS" ///
						5 "CAN'T TRAVEL / TRANSPORT GOODS FOR TRADE" ///
						7 "ILLNESS IN THE HOUSEHOLD" 8 "NEED TO TAKE CARE OF A FAMILY MEMBER" ///
						9 "SEASONAL CLOSURE" 10 "VACATION" 11 "LACK OR LOSS OF CAPITAL"
	lab val 		bus_closed clsd
	forval 			x = 1/6 {
	  rename 			s6q15__`x' bus_chal_`x'
	  replace 			bus_chal_`x' = 0 if bus_chal_`x' == 2
	}
	rename 			s6q15__96 bus_chal_7 
	replace 		bus_chal_7 = 0 if bus_chal_7 == 2
	rename 			s6q15b bus_num
	rename 			s6q15b__1 bus_beh_1 
	rename 			s6q15b__2 bus_beh_2 
	rename 			s6q15b__3 bus_beh_3 
	rename 			s6q15b__4 bus_beh_4 
	rename 			s6q15b__5 bus_beh_5 
	rename 			s6q15b__6 bus_beh_6 
	rename 			s6q15b__96 bus_beh_7 

* agriculture
	replace 		crop_filter1 = . if crop_filter1 == 3
	replace 		ag_crop = crop_filter1 if ag_crop == .
	drop 			crop_filter1

* livestock 	
	replace 		ag_live = livest_filter3 if ag_live == .
	replace 		ag_live = . if ag_live == 3
	drop 			livest_filter3
	forval 			x = 1/4 {
	    rename 		s6bq2__`x' ag_live_`x'
	}
	rename 			s6bq2__5 ag_live_7
	rename 			s6bq3 ag_live_affect
	foreach 		x in 1 3 4 7 {
	    rename 		s6bq4__`x' ag_live_chg_`x'
	}
	rename 			s6bq6 ag_live_sell
	replace 		ag_live_sell = livest_filter4 if ag_live_sell == .
	replace 		ag_live_sell = . if ag_live_sell == 3
	drop 			livest_filter4
	rename 			s6bq7 ag_live_sell_chg
	rename 			s6bq8 ag_live_sell_want
	rename 			s6bq9 ag_live_sell_why
	rename 			s6bq10 ag_live_sell_able
	rename 			s6bq11 ag_live_sell_cond
	rename 			s6bq12 ag_live_sell_pr
	rename			s6bq13 ag_live_sell_nowhy_ 
	gen 			temp = ag_live_sell_nowhy_
	replace 		ag_live_sell_nowhy_ = 1 if ag_live_sell_nowhy_ != .
	replace 		temp = 0 if temp == .
	reshape 		wide ag_live_sell_nowhy_, i(hhid wave) j(temp)
	drop 			ag_live_sell_nowhy_0
	foreach 		x in 2 4 5 {
	    local 		z = `x' - 1
		rename 		ag_live_sell_nowhy_`x' ag_live_sell_nowhy_`z'
	}

* income variables	
	rename 			s7q11 farm_inc
	lab	var			farm_inc "Income from farming, fishing, livestock in last 12 months"
	rename			s7q21 farm_chg
	lab var			farm_chg "Change in income from farming since covid"
	rename 			s7q12 bus_inc
	lab var			bus_inc "Income from non-farm family business in last 12 months"
	rename			s7q22 bus_chg
	lab var			bus_chg "Change in income from non-farm family business since covid"	
	rename 			s7q13 wage_inc
	lab var			wage_inc "Income from wage employment in last 12 months"
	rename			s7q23 wage_chg
	lab var			wage_chg "Change in income from wage employment since covid"	
	rename 			s7q14 rem_for
	lab var 		rem_for "Income from remittances abroad in last 12 months"
	rename			s7q24 rem_for_chg
	lab var 		rem_for_chg "Change in income from remittances abroad since covid"	
	rename 			s7q15 rem_dom
	lab var 		rem_dom "Income from remittances domestic in last 12 months"
	rename			s7q25 rem_dom_chg
	lab	var 		rem_dom_chg "Change in income from remittances domestic since covid"	
	rename 			s7q16 asst_inc
	lab var			asst_inc "Income from assistance from non-family in last 12 months"
	rename			s7q26 asst_chg
	lab var 		asst_chg "Change in income from assistance from non-family since covid"
	rename 			s7q17 isp_inc
	lab var 		isp_inc "Income from properties, investment in last 12 months"
	rename			s7q27 isp_chg
	lab var 		isp_chg "Change in income from properties, investment since covid"
	rename 			s7q18 pen_inc
	lab var 		pen_inc "Income from pension in last 12 months"
	rename			s7q28 pen_chg
	lab var 		pen_chg "Change in income from pension since covid"
	rename 			s7q19 gov_inc
	lab	var 		gov_inc "Income from government assistance in last 12 months"
	rename			s7q29 gov_chg
	lab var 		gov_chg "Change in income from government assistance since covid"	
	rename 			s7q110 ngo_inc
	lab var 		ngo_inc "Income from NGO assistance in last 12 months"
	rename			s7q210 ngo_chg
	lab var 		ngo_chg "Change in income from NGO assistance since covid"
	rename 			s7q196 oth_inc
	lab var 		oth_inc "Income from other source in last 12 months"
	rename			s7q296 oth_chg
	lab var 		oth_chg "Change in income from other source since covid"	
	rename			s7q299 tot_inc_chg
	lab var 		tot_inc_chg "Change in income from other source since covid"	
	drop			s7q199
	
* fies
	rename			s8q4 fies_7
	lab var			fies_7 "Skipped a meal"
	rename			s8q6 fies_1
	lab var			fies_1 "Ran out of food"
	rename			s8q8 fies_3
	lab var			fies_3 "Went without eating for a whole day"	  
	rename			s8q1 fies_4
	lab var			fies_4 "Worried about not having enough food to eat"
	rename			s8q2 fies_5
	lab var			fies_5 "Unable to eat healthy and nutritious/preferred foods"
	rename			s8q3 fies_6
	lab var			fies_6 "Ate only a few kinds of food"
	rename			s8q5 fies_8
	lab var			fies_8 "Ate less than you thought you should"
	rename			s8q7 fies_2
	lab var			fies_2 "Hungry but did not eat"

* concerns
	rename			s9q1 concern_1
	forval 			x = 1/8 {
	    rename 		s9q3__`x' concern_1_why_`x'
	}
	rename			s9q2 concern_2
	rename 			s9q4 crime
	rename 			s9q5 crime_rep
	forval 			x = 1/6 {
		rename 			s9q6__`x' crime_rep_who_`x'
	}
	rename 			s9q7 ineq
	rename 			s9q8 ineq_cov
	
* COVID 
	rename 			s9aq1 cov_test
	rename 			s9aq2 cov_vac
	gen 			cov_vac_no_why_1 = s9aq3__1 if cov_vac == 2
	gen 			cov_vac_no_why_2 = s9aq3__2 if cov_vac == 2
	gen 			cov_vac_no_why_3 = s9aq3__3 if cov_vac == 2
	gen 			cov_vac_no_why_6 = s9aq3__4 if cov_vac == 2
	gen 			cov_vac_no_why_4 = s9aq3__5 if cov_vac == 2
	gen 			cov_vac_no_why_5 = s9aq3__6 if cov_vac == 2	
	gen 			cov_vac_dk_why_1 = s9aq3__1 if cov_vac == 3
	gen 			cov_vac_dk_why_2 = s9aq3__2 if cov_vac == 3
	gen 			cov_vac_dk_why_3 = s9aq3__3 if cov_vac == 3
	gen 			cov_vac_dk_why_6 = s9aq3__4 if cov_vac == 3
	gen 			cov_vac_dk_why_4 = s9aq3__5 if cov_vac == 3
	gen 			cov_vac_dk_why_5 = s9aq3__6 if cov_vac == 3
	
* assistance
	gen				asst_food = 1 if s11q11 == 1
	replace			asst_food = 0 if s11q11 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s11q12 == 1
	replace			asst_cash = 0 if s11q12 == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s11q13 == 1
	replace			asst_kind = 0 if s11q13 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist
	
* shocks
	rename 			shock_8 shock_15 
	rename 			shock_96 shock_14
	lab var			shock_1 "Death or disability of an adult working member of the household"
	lab var			shock_5 "Job loss"
	lab var			shock_6 "Non-farm business failure"
	lab var			shock_7 "Theft of crops, cash, livestock or other property"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items consumed"
	lab var			shock_14 "Other shock"
	lab var 		shock_15 "Disruption of farming, livestock, fishing activities"
	
* generate any shock variable
	gen				shock_any = 1 if shock_1 == 1 | shock_5 == 1 | ///
						shock_6 == 1 | shock_7 == 1 | shock_15 == 1 | ///
						shock_10 == 1 | shock_11 == 1 | shock_12 == 1 | ///
						shock_14 == 1
	replace			shock_any = 0 if shock_any == . & (wave == 1 | wave == 3)
	lab var			shock_any "Experience some shock"
	
* rename cope variables
	rename			s10q3__1 cope_1
	rename			s10q3__6 cope_2
	rename			s10q3__7 cope_3
	rename			s10q3__8 cope_4
	rename			s10q3__9 cope_5
	rename			s10q3__11 cope_6
	rename			s10q3__12 cope_7
	rename			s10q3__13 cope_8
	rename			s10q3__14 cope_9
	rename			s10q3__15 cope_10
	rename			s10q3__16 cope_11
	rename			s10q3__17 cope_12
	rename			s10q3__18 cope_13
	rename			s10q3__19 cope_14
	rename			s10q3__20 cope_15
	rename			s10q3__21 cope_16
	rename 			s10q3__22 cope_18
	rename			s10q3__96 cope_17

	lab var			cope_1 "Sale of assets (Agricultural and Non_agricultural)"
	lab var			cope_2 "Engaged in additional income generating activities"
	lab var			cope_3 "Received assistance from friends & family"
	lab var			cope_4 "Borrowed from friends & family"
	lab var			cope_5 "Took a loan from a financial institution"
	lab var			cope_6 "Credited purchases"
	lab var			cope_7 "Delayed payment obligations"
	lab var			cope_8 "Sold harvest in advance"
	lab var			cope_9 "Reduced food consumption"
	lab var			cope_10 "Reduced non_food consumption"
	lab var			cope_11 "Relied on savings"
	lab var			cope_12 "Received assistance from NGO"
	lab var			cope_13 "Took advanced payment from employer"
	lab var			cope_14 "Received assistance from government"
	lab var			cope_15 "Was covered by insurance policy"
	lab var			cope_16 "Did nothing"
	lab var			cope_17 "Other"

* drop variables
	drop			interviewer_id *_os  s6q10_* s12q3__* s12q4__* /// 
						s12q5 s12q9 s12q10 s12q10_os s12q11 s12q14 baseline_date ///
						s12q10a s6q11c s6bq4__96 s6aq8__96 s6aq7__96 s6aq6__96 ///
						s6aq5__96 s6aq4__96 s6q8b1 s6bq6a lga filter ///
						PID s2q0a s2q0b s12q4a s12q4b s9q3__96 ag_chg_13 ///
						s5q1a* s5q1b* s5q1c* s9q6__96 s9q6_os ///
						s11q11 s11q12 s11q13 s6q21a__96 s6q22__96 s3q2__5 ///
						s5aq3__96 s5cq2__96 s5cq4__98 s5q1h__96 s5q1i_96 ///
						s6q16_round5 s9aq3__* s9aq4__* sch_catchupos s5cq0 ///
						s12bq*
	drop if			wave ==  .		
	
* reorder variables
	order			fies_2 fies_3 fies_4 fies_5 fies_6 fies_7 fies_8, after(fies_1)
	
	gen 			region = 3000 + state

	lab def			region 3001 "Abia" 3002 "Adamawa" 3003 ///
						"Akwa Ibom" 3004 "Anambra" 3005 "Bauchi" 3006 ///
						"Bayelsa" 3007 "Benue" 3008 "Borno" 3009 ///
						"Cross River" 3010 "Delta" 3011 "Ebonyi" 3012 ///
						"Edo" 3013 "Ekiti" 3014 "Enugu" 3015 "Gombe" 3016 ///
						"Imo" 3017 "Jigawa" 3018 "Kaduna" 3019 "Kano" 3020 ///
						"Katsina" 3021 "Kebbi" 3022 "Kogi" 3023 "Kwara" 3024 ///
						"Lagos" 3025 "Nasarawa" 3026 "Niger" 3027 "Ogun" 3028 ///
						"Ondo" 3029 "Osun" 3030 "Oyo" 3031 "Plateau" 3032 ///
						"Rivers" 3033 "Sokoto" 3034 "Taraba" 3035 "Yobe" 3036 ///
						"Zamfara" 3037 "FCT", replace
						
	lab val 		region region
	drop			zone state
	order			region, after(sector)
	lab var			region "Region"	
	
	
/*
* **********************************************************************
* 4 - QC check (SEE NOTES IN OUTPUT EXCEL)
* **********************************************************************

* compare numerical variables to other rounds & flag if 25+ percentage points different
	tostring 		wave, replace
	ds, 			has(type numeric)
	foreach 		var in `r(varlist)' {
		preserve
		keep 		`var' wave
		destring 	wave, replace
		gen 		counter = 1
		collapse 	(sum) counter, by(`var' wave)
		reshape 	wide counter, i(`var') j(wave)
		drop 		if `var' == .
		foreach 	x in "$waves" {
			egen 	tot_`x' = total(counter`x')
			gen 	per_`x' = counter`x' / tot_`x'
		}
		keep 		per*
		foreach 	x in "$waves"  {
			foreach q in "$waves"  {
				gen flag_`var'_`q'`x' = 1 if per_`q' - per_`x' > .25 & per_`q' != . & per_`x' != .
			}
		}	
		keep 		*flag*

	* drop if all missing	
		foreach 	v of varlist _all {
			capture assert mi(`v')
			if 		!_rc {
				drop `v'
			}
		}
		gen 		n = _n
		tempfile 	temp`var'
		save 		`temp`var''
		restore   
	}
		
* create dataset of flags
	preserve
	ds, 			has(type numeric)
	clear
	set 			obs 15
	gen 			n = _n
	foreach 		var in `r(varlist)' {
		merge 		1:1 n using `temp`var'', nogen
	}
	reshape 		long flag_, i(n) j(variables) string 
	drop 			if flag_ == .
	drop 			n
	sort 			variable	
	export 			excel using "$export/nga_qc_flags.xlsx", first(var) sheetreplace sheet(flags)
	restore
	destring 		wave, replace
*/

* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************

* final clean 
	compress
	rename hhid hhid_nga 
	
* append baseline 
	append 			using "$export/wave_00/r0"

* save file
		customsave , idvar(hhid_nga) filename("nga_panel.dta") ///
			path("$export") dofile(nga_build) user($user)

* close the log
	//log	close

/* END */
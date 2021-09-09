* Project: COVID Food Security
* Created on: April 2021
* Created by: amf
* Edited by: amf
* Last edited: Nov 2021 
* Stata v.16.1

* does
	* cleans Burkina Faso panel

* assumes
	* raw Burkina Faso data

* TO DO:
	* CONSUMPTION AGGREGATES FROM TALIP & FIES FOR ROUNDS
	* add and check 9 when we get questionnaire

		
* **********************************************************************
* 0 - setup
* **********************************************************************

* define list of waves
	global 			waves "1" "2" "3" "4" "5" "6" "7" "8" "9" "10"
	
* define 
	global	root	=	"$data/burkina_faso/raw"
	global	export	=	"$data/burkina_faso/refined"
	global	logout	=	"$data/burkina_faso/logs"

* open log
	cap log 		close
	log using 		"$logout/bf_build", append

	
* **********************************************************************
* 1 - run do files for each round & generate variable comparison excel
* **********************************************************************

* run do files for all rounds and create crosswalk of variables by wave
	foreach 		r in "$waves" {
		do 			"$code/burkina_faso/bf_build_`r'"
	}


* ***********************************************************************
* 2 - create burkina faso panel 
* ***********************************************************************

* append round datasets to build master panel
	foreach 		r in "$waves" {
	    if 			`r' == 1 {
					use	"$export/wave_01/r1", clear
		}
		if 			`r' == 10  {
					append using "$export/wave_`r'/r`r'"
		}
		else {
					append using "$export/wave_0`r'/r`r'"
		}
	}
	compress

* adjust household id
	recast 			long hhid
	format 			%12.0g hhid

* merge in quintiles
	merge m:1		hhid using "$root/wave_00/Burkina Faso WAEMU 2018-19 Quintiles", nogen 
	
* rename quintile variable
	rename 			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui
	drop 			if wave == .

* create country variable
	gen				country = 5	
	
	replace 		region = 5001 if region == 1
	replace 		region = 5002 if region == 2
	replace 		region = 5003 if region == 3
	replace 		region = 5004 if region == 4
	replace 		region = 5005 if region == 5
	replace 		region = 5006 if region == 6
	replace 		region = 5007 if region == 7
	replace 		region = 5008 if region == 8
	replace 		region = 5009 if region == 9
	replace 		region = 5010 if region == 10
	replace 		region = 5011 if region == 11
	replace 		region = 5012 if region == 12
	replace			region = 5013 if region == 13
	
	rename 			commune zone_id 
	
	drop 			village b40 echantillon resultat weight ind_id_EHCVM ///
						membres__id zae vague menage

* replace all missing values as . (not .a, .b, etc.)
	quietly: ds, has(type numeric)
	foreach var in `r(varlist)' {
		replace 		`var' = . if `var' > .
	} 	

	
* ***********************************************************************
* 3 - clean bukina faso panel
* ***********************************************************************	

* mental health 
	forval 			x = 1/8 {
		rename 		s02bq0`x' mh_`x'
	}
	
* early childhood development 
	rename 			s02cq02 ecd_pcg
	rename 			s02cq03 ecd_pcg_mem
	rename 			s02cq03a ecd_pcg_gen
	replace 		ecd_pcg_gen = sex if ecd_pcg_gen == .
	rename 			s02cq04 ecd_pcg_id
	rename 			s02cq05 ecd_pcg_relate
	replace 		ecd_pcg_relate = 6 if ecd_pcg_relate == 5
	replace 		ecd_pcg_relate = 5 if ecd_pcg_relate == 4
	replace 		ecd_pcg_relate = 4 if ecd_pcg_relate == 3
	lab def 		ecd_rel 1 "mother" 2 "father" 3 "sibling" 4 "grandparent" ///
						5 "other relative" 6 "non-relative/household worker"
	lab val 		ecd_pcg_relate ecd_rel
	rename 			s02cq06 ecd_play
	rename 			s02cq07 ecd_read
	rename 			s02cq08 ecd_story
	rename 			s02cq09 ecd_song
	rename 			s02cq10 ecd_out
	rename 			s02cq11 ecd_ncd
	rename 			s02cq12 ecd_hv_bks
	rename 			s02cq13 ecd_num_bks
	rename 			s02cq14 ecd_ed_1
	rename 			s02cq15 ecd_ed_2
	rename 			s02cq16 ecd_ed_3
	rename 			s02cq17 ecd_ed_4
	rename 			s02cq18 ecd_ed_5
	rename 			s02cq19 ecd_ed_6
	rename 			s02cq20 ecd_ed_7
	rename 			s02cq21 ecd_ed_8
	rename 			s02cq22 ecd_ed_pre_lvl
	drop 			s02cq22_autre
	
* administrative variables 
	rename 			milieu sector
	drop 			langue strate grappe 
	
* knowledge & govt
	rename 			s03q01 know
	forval 			x = 1/8 {
		rename 		s03q02__`x' know_`x'
	}
	forval 			x = 1/6 {
		rename 		s03q03__`x' gov_`x'
	}
	replace 		gov_6 = 1 if s03q03__7 == 1
	drop 			s03q03__7 s03q03_autre
	rename 			s03q03__8 gov_17
	rename 			s03q03__9 gov_18
	rename 			s03q03__10 gov_19
	rename 			s03q03__11 gov_10
	rename 			s03q03__12 gov_16
	rename 			s03q04 mask
	
* behavior
	rename 			s04q01 bh_1	
	rename 			s04q02 bh_2
	rename 			s04q03 bh_3
	replace 		bh_3 = . if bh_3 == 3
	
* COVID 
	rename 			s04bq01 cov_test

	gen 			cov_vac_no_why_1 = 1 if s04bq03 == 1
	replace 		cov_vac_no_why_1 = 0 if s04bq03 != 1 & s04bq03 != .
	gen 			cov_vac_no_why_2 = 1 if s04bq03 == 2
	replace 		cov_vac_no_why_2 = 0 if s04bq03 != 2 & s04bq03 != .
	gen 			cov_vac_no_why_3 = 1 if s04bq03 == 3
	replace 		cov_vac_no_why_3 = 0 if s04bq03 != 3 & s04bq03 != .
	gen 			cov_vac_no_why_4 = 1 if s04bq03 == 6
	replace 		cov_vac_no_why_4 = 0 if s04bq03 != 6 & s04bq03 != .
	gen 			cov_vac_no_why_5 = 1 if s04bq03 == 4
	replace 		cov_vac_no_why_5 = 0 if s04bq03 != 4 & s04bq03 != .
	gen 			cov_vac_no_why_6 = 1 if s04bq03 == 5
	replace 		cov_vac_no_why_6 = 0 if s04bq03 != 5 & s04bq03 != .

	gen 			cov_vac_dk_why_1 = 1 if s04bq04 == 1
	replace 		cov_vac_dk_why_1 = 0 if s04bq04 != 1 & s04bq04 != .
	gen 			cov_vac_dk_why_2 = 1 if s04bq04 == 2
	replace 		cov_vac_dk_why_2 = 0 if s04bq04 != 2 & s04bq04 != .
	gen 			cov_vac_dk_why_3 = 1 if s04bq04 == 3
	replace 		cov_vac_dk_why_3 = 0 if s04bq04 != 3 & s04bq04 != .
	gen 			cov_vac_dk_why_4 = 1 if s04bq04 == 6
	replace 		cov_vac_dk_why_4 = 0 if s04bq04 != 6 & s04bq04 != .
	gen 			cov_vac_dk_why_5 = 1 if s04bq04 == 4
	replace 		cov_vac_dk_why_5 = 0 if s04bq04 != 4 & s04bq04 != .
	gen 			cov_vac_dk_why_6 = 1 if s04bq04 == 5
	replace 		cov_vac_dk_why_6 = 0 if s04bq04 != 5 & s04bq04 != .
	
	drop 			s04bq03 s04bq04 s04bq03_autre s04bq04_autre
	
	rename 			s04bq03__* know_vac_*
	rename 			s04bq05 vac_type 
	
	drop 			s04bq05_autre s04bq07_autre s04bq08_autre

* access
	gen 			ac_med_need = 0 if ac_med == 3
	replace 		ac_med_need = 1 if ac_med < 3
	replace 		ac_med = . if ac_med == 3
	rename 			s05q01b ac_med_why
	replace 		ac_med_why = 6 if ac_med_why == 7
	drop 			s05q01b_autre s05q02*_autre

	rename 			s05q02_1 ac_staple_1_need
	rename 			s05q02_2 ac_staple_2_need
	rename 			s05q02_3 ac_staple_3_need
	rename 			s05q02a ac_staple_1
	rename 			s05q02b ac_staple_1_why
	rename 			s05q02c ac_staple_2
	rename 			s05q02d ac_staple_2_why
	rename 			s05q02e ac_staple_3
	rename 			s05q02f ac_staple_3_why
	forval 			x = 1/3 {
		replace 		ac_staple_`x'_need = 2 if ac_staple_`x' == 3
		replace 		ac_staple_`x'_need = 1 if ac_staple_`x' < 3 & ac_staple_`x'_need == .
		replace 		ac_staple_`x' = . if ac_staple_`x' == 3
	}	
	
	gen 			staple_1 = 1 if AlimBase1 == "Maïs en grain"
	replace 		staple_1 = 2 if AlimBase1 == "Riz importé"
	gen 			staple_2 = 1 if AlimBase2 == "Maïs en grain"
	replace 		staple_2 = 2 if AlimBase2 == "Riz importé"
	replace 		staple_2 = 3 if AlimBase2 == "Sorgho"
	gen 			staple_3 = 1 if AlimBase3 == "Maïs en grain"
	replace  		staple_3 = 4 if AlimBase3 == "Farine de maïs"
	replace  		staple_3 = 5 if AlimBase3 == "Mil"
	replace  		staple_3 = 6 if AlimBase3 == "Riz local"
	
	lab def 		staple 1 "Maïs en grain" 2 "Riz importé" 3 "Sorgho" ///
						4 "Farine de maïs" 5 "Mil" 6 "Riz local"
	lab val 		staple_1 staple
	lab val 		staple_2 staple
	lab val 		staple_3 staple
	
	drop 			AlimBase* 
	
	rename 			s05q03a ac_medserv_need
	forval 			x = 1/7 {
	    rename 		s05q03a_1__`x' ac_medserv_need_type_`x'
	}
	drop 			s05q03a_1__96

	forval 			x = 1/11 {
		rename 		s05q03b__`x' ac_medserv_need_why_`x'
	}
	rename 			s05q03c ac_medserv_cvd
	rename 			s05q03c_1 ac_medserv_cvd_why
		
	rename 			s05q03d ac_medserv //for rounds 5+ when var not split by cvd & non-cvd
	replace 		ac_medserv = 0 if ac_medserv == . & (ac_medserv_cvd == 0 | ac_medserv_oth == 0)
	replace 		ac_medserv = 1 if ac_medserv == . & (ac_medserv_cvd == 1 | ac_medserv_oth == 1)
	
	forval			x = 1/7 { 			
		rename 			s05q03d_`x'a	ac_medserv_type_`x'
		rename 			s05q03d_`x'b	ac_medserv_type_`x'_why
		drop 			s05q03d_`x'b_autre
	}
	drop 			s05q03d_96* s05q03d_1
	
	rename 			s05q04 med_ins
	drop 			s05q03b_autre s05q03c_1_autre  s05q03e_autre s05q03d_1_autre ///
						s05q03_3__96 s05q03_6__96 s05q03_6_autre s05q03a_1_autre
	rename 			s05q09 ac_bank_need
	rename 			s05q11 ac_bank
	
	forval 			x = 1/5 {
	    rename 		s05q13__`x' exp_prob_`x'
	}
	rename 			s05q13__7 exp_prob_6
	rename 			s05q13__8 exp_prob_7
	drop 			s05q13__6 s05q13_autre
	
	rename 			s05q03_filtre ac_nat_filter
	rename 			s05q03_1 ac_nat_need
	rename 			s05q03_2 ac_nat
	rename 			s05q03_3__1 ac_nat_why_1
	rename 			s05q03_3__2 ac_nat_why_2
	rename 			s05q03_3__3 ac_nat_why_3
	rename 			s05q03_3__4 ac_nat_why_7
	rename 			s05q03_3__5 ac_nat_why_8
	rename 			s05q03_3__6 ac_nat_why_9
	rename 			s05q03_3__7 ac_nat_why_10
	drop 			s05q03_3_autre
	rename 			s05q03_4 ac_prev_app
	rename 			s05q03_5 ac_prev_canc
	replace 		ac_prev_canc = 1 if ac_prev_canc == 2
	replace 		ac_prev_canc = 0 if ac_prev_canc == 3
	rename 			s05q03_6__1 ac_prev_why_1
	rename 			s05q03_6__2 ac_prev_why_2
	rename 			s05q03_6__3 ac_prev_why_3
	rename 			s05q03_6__4 ac_prev_why_7
	rename 			s05q03_6__5 ac_prev_why_10
	rename 			s05q03_6__6 ac_prev_why_9
	rename 			s05q03_6__7 ac_prev_why_8
	
	rename 			s05q04_1 ac_drink
	rename 			s05q04_2 ac_drink_why
	replace 		ac_drink_why = 11 if ac_drink_why == 4 
	replace 		ac_drink_why = 12 if ac_drink_why == 5
	replace 		ac_drink_why = . if ac_drink_why == 6
	replace 		ac_drink_why = 15 if ac_drink_why == 10 & wave == 10
	drop 			s05q04_2_autre
	
	rename			s05q04_3 ac_water
	rename	 		s05q04_4 ac_water_why
	replace 		ac_water_why = . if ac_water_why == 12 | ac_water_why == 99
	replace 		ac_water_why = 15 if ac_water_why == 9
	replace 		ac_water_why = 9 if ac_water_why == 8
	replace 		ac_water_why = 8 if ac_water_why == 7
	replace 		ac_water_why = 7 if ac_water_why == 6
	replace 		ac_water_why = 6 if ac_water_why == 5
	replace 		ac_water_why = 5 if ac_water_why == 4
	replace 		ac_water_why = 16 if ac_water_why == 10
	drop 			s05q04_4_autre 
	
	rename 			s05q04_5 ac_soap 
	rename 			s05q04_6 ac_soap_why
	replace 		ac_soap_why = 6 if ac_soap_why == 7 & wave == 10
	replace 		ac_soap_why = 6 if ac_soap_why == 9
	replace 		ac_soap_why = 9 if ac_soap_why == 7
	replace 		ac_soap_why = . if ac_soap_why == 10
	rename 			s05q04_7 bh_freq_wash
	drop 			s05q04_6_autre
	
* credit
	rename 			s05bq01 ac_cr_loan
	rename 			s05bq02__1 ac_cr_lend_11
	rename 			s05bq02__2 ac_cr_lend_12
	rename 			s05bq02__3 ac_cr_lend_7
	rename 			s05bq02__4 ac_cr_lend_8
	rename 			s05bq02__5 ac_cr_lend_1
	rename 			s05bq02__6 ac_cr_lend_4
	rename 			s05bq02__7 ac_cr_lend_13
	rename 			s05bq02__8 ac_cr_lend_14
	drop 			s05bq02__96 s05bq02_autre
	forval 			x = 1/13 {
		rename 			s05bq03__`x' ac_cr_why_`x'
	}
	drop 			s05bq03__96 s05bq03_autre
	drop 			s05bq04__*
	rename 			s05bq05 ac_cr_due
	rename 			s05bq06 ac_cr_bef
	forval 			x = 1/13 {
		rename 			s05bq07__`x' ac_cr_bef_why_`x'
	}
	drop 			s05bq07__96 s05bq07_autre
	rename 			s05bq08__* ac_cr_who_*
	rename 			s05bq09 ac_cr_worry
	rename 			s05bq10 ac_cr_miss
	rename 			s05bq11 ac_cr_delay
	
* employment 
	drop 			sec6_rep // not sure what this is
	rename 			s06q01 emp
	rename 			s06q01a rtrn_emp
	rename 			s06q02 emp_pre
	rename 			s06q03 emp_pre_why
	replace 		emp_pre_why = s06q03_1 if emp_pre_why == . & s06q03_1 != .
	replace 		emp_pre_why = s06q03_2 if emp_pre_why == . & s06q03_2 != .
	drop 			s06q03_autre s06q03_1* s06q03_2* s06d_filtre
	rename 			s06q03a emp_search
	rename 			s06q03b emp_search_how
	replace 		emp_search_how = 6 if emp_search_how == 7
	forval 			x = 8/12 {
	    replace 	emp_search_how = `x' - 1 if emp_search_how == `x'
	}
	replace			emp_search_how = 12 if emp_search_how == 14
	replace 		emp_search_how = 14 if emp_search_how == 3
	replace 		emp_search_how = 96 if emp_search_how == 15
	rename 			s06q04a emp_act 
	replace 		emp_act = -96 if emp_act == 15
	replace 		emp_act = 15 if emp_act == 14
	replace 		emp_act = 14 if emp_act == 9
	replace 		emp_act = 9 if emp_act == 11 | emp_act == 12
	replace 		emp_act = 12 if emp_act == 5
	replace 		emp_act = 11 if emp_act == 10
	replace 		emp_act = 10 if emp_act == 2
	replace 		emp_act = 2 if emp_act == 3
	drop 			s06q04a_autre
	
	rename 			s06q04b emp_stat
	replace 		emp_stat = 100 if emp_stat == 5 & wave == 2
	replace 		emp_stat = 5 if emp_stat == 6 & wave == 2
	replace 		emp_stat = 6 if emp_stat == 100 & wave == 2
	lab def 		emp_stat 1 "Own business" 2 "Family business" ///
						3 "Family farm" 4 "Employee for someone else" ///
						5 "Apprentice, trainee, intern" ///
						6 "Employee for the government" -96 "Other"
	lab val 		emp_stat emp_stat	
	rename 			s06q04_1 emp_same
	replace 		emp_same = s06q04_2 if s06q04_2 != .
	replace 		emp_same = s06q05 if s06q05 != . & emp_same == .
	replace 		emp_same = s06q04 if s06q04 != . & emp_same == .
	drop 			s06q04_2 s06q05 s06q04
	
	gen 			emp_able = s06q06 if wave == 1
	replace 		s06q06 = . if wave == 1
	rename 			s06q06 emp_hrs_red
	
	rename 			s06q07a emp_unable
	rename 			s06q07b emp_unable_why
	drop 			s06q07b_autre
	rename 			s06q07c_* emp_cont*
	
	gen  			emp_able_hh = s06q08 if wave == 1
	replace 		s06q08 = . if wave == 1
	rename 			s06q08 emp_hrs_red_hh
	rename 			s06q08a emp_hrs_cov 
	
	forval 			x = 0/8 {
		replace 		s06q09__`x' = 1 if s06q09__`x' != .
	}
	egen 			emp_hrs_cov_num = rowtotal(s06q09__*)
	drop			s06q09*  				

* nfe
	rename 			s06q10 bus_emp
	rename 			s06q10a_1 bus_stat
	replace 		bus_stat = s06q10a_2 if s06q10a_2 != .
	replace 		bus_stat = s06q10a_3 if s06q10a_3 != .	
	replace 		bus_stat = s06q10a1 if s06q10a1 != .
	replace 		bus_stat = s06q10a2 if s06q10a2 != .
	replace 		bus_stat = s06q10a3 if s06q10a3 != .
	drop 			s06q10a*
	rename 			s06q10b bus_closed
	replace 		bus_closed = 7 if bus_closed == 6
	drop 			s06q10b_autre
	rename 			s06q11 bus_sect
	rename 			s06q12 bus_emp_inc
	replace 		bus_emp_inc = . if bus_emp_inc == 5
	rename 			s06q13 bus_why
	replace 		bus_why = s06q13_1 if bus_why == . & s06q13_1 != .
	replace 		bus_why = s06q13_2 if bus_why == . & s06q13_2 != .
	drop 			s06q13_autre s06q13_1 s06q13_2 
	
	rename 			s06q13a__1 bus_chal_1
	rename 			s06q13a__2 bus_chal_2
	rename 			s06q13a__3 bus_chal_3
	rename 			s06q13a__4 bus_chal_5
	rename 			s06q13a__5 bus_chal_6
	
	rename 			s06q13b bus_beh
	rename 			s06q13c__1 bus_beh_4
	replace 		bus_beh_4 = s06q13c__2 if (bus_beh_4 == . | bus_beh_4 == 0) 
	rename 			s06q13c__3 bus_beh_5
	rename 			s06q13c__4 bus_beh_6
	rename 			s06q13c__5 bus_beh_1
	rename 			s06q13c__7 bus_beh_2
	rename 			s06q13c__8 bus_beh_3
	rename 			s06q13c__9 bus_beh_7
	drop 			s06q13c_autre s06q13c__2
	
* agriculture 	
	rename 			s06q14_2 ag_harv_exp
	gen 			ag_plan = s06q15 if wave == 3
	replace 		s06q15 = . if wave == 3
	rename 			s06q15 farm_norm
	
	rename 			s06q15_1__1 ag_nocrop_1
	rename 			s06q15_1__2 ag_nocrop_2
	rename 			s06q15_1__3 ag_nocrop_3
	rename 			s06q15_1__4 ag_nocrop_4
	rename 			s06q15_1__5 ag_nocrop_10
	rename 			s06q15_1__6 ag_nocrop_5
	rename 			s06q15_1__7 ag_nocrop_6
	rename 			s06q15_1__8 ag_nocrop_7
	rename 			s06q15_1__9 ag_nocrop_8

	gen 			ag_chg = s06q17 if wave == 3
	replace 		s06q17 = . if wave == 3
	rename 			s06q17 harv_sell_need

	rename 			s06q18 harv_sell
	forval 			x = 1/7 {
		rename 		s06q18__`x' ag_chg_`x'
	}
	drop 			s06q18__96 s06q18_autre
	
	rename 			s06q19 ag_price
	forval 			x = 1/9 {
	    rename 		s06q19__`x' ag_covid_`x'
	}
	drop 			s06q19__10
	
	rename 			s06q20 fam_asst
	rename 			s06q21 fam_asst_amt
	rename 			s06q22 fam_asst_freq
	
	forval 			x = 1/6 {
	    rename 		s06q20__`x' ag_ac_seed_why_`x'
		rename 		s06q21__`x' ag_ac_fert_why_`x'
		rename 		s06q22__`x' ag_ac_oth_why_`x'
	}
	
	replace 		ag_ac_seed_why_6 = 1 if s06q16a == 1
	drop 			s06q16a s06q16a_autre	
	
	* round 6 ag vars
	rename 			s06dq01__0 ag_crop_who
	drop 			s06dq01__1
	drop  			s06a_filtre s06q03b_autre s06c_filtre s06q26_autre s06dq02 s06dq03
	rename 			s06dq04 ag_main
	drop	 		s06dq04_autre
	gen 			temp = cond(s06dq05b == 2, 10000, cond(s06dq05b == 1,1,.))
	gen 			ag_main_area = s06dq05a * temp
	drop 			temp s06dq05a s06dq05b 
	lab var 		ag_main_area "Area planted in main crop - Hectares"
	rename 			s06dq06 ag_main_harv
	rename 			s06dq08 ag_main_sell
	gen 			ag_main_sell_per = s06dq09 / s06dq07a if ag_main_sell == 1
	drop 			s06dq07* s06dq09
	rename 			s06dq10 ag_main_rev
	rename 			s06dq11 harv_sell_rev
	replace 		harv_sell_rev = . if harv_sell_rev == 99
	rename 			s06dq12 ag_main_sell_plan
	rename 			s06dq14 ag_main_harv_comp
	drop 			s06dq15*
	
	rename 			s06dq16a ag_use_infert
	rename 			s06dq16b ag_use_orfert
	rename 			s06dq16c ag_use_pest
	rename 			s06dq16d ag_use_lab
	rename 			s06dq16e ag_use_anim
	forval 			x = 1/7 {
	    rename 		s06dq17__`x' ag_ac_infert_why_`x'
	}
	
	forval 			x = 1/7 {
	    rename 		s06dq18__`x' ag_ac_orfert_why_`x'
	}
	
	forval 			x = 1/7 {
	    rename 		s06dq19__`x' ag_ac_pest_why_`x'
	}
	drop 			s06dq17_* s06dq18_* s06dq19_*	
 		
	rename 			s06dq20__6 ag_ac_lab_why_5
	rename 			s06dq20__7 ag_ac_lab_why_7
	rename 			s06dq21__6 ag_ac_anim_why_6
	rename 			s06dq21__7 ag_ac_anim_why_7
	drop 			s06dq20_* s06dq21_*

* FIES
	rename 			s07q01 fies_4
	rename 			s07q02 fies_5
	rename 			s07q03 fies_6
	rename 			s07q04 fies_7
	rename 			s07q05 fies_8
	rename 			s07q06 fies_1
	rename 			s07q07 fies_2
	rename 			s07q08 fies_3
	
	forval 			x = 1/8 {
		replace 	fies_`x' = . if fies_`x' > 97
	}

* coping
	rename 			s09q03__1 cope_1
	forval 			x = 6/9 {
		local 		z = `x' - 4
		rename 		s09q03__`x' cope_`z'
	}
	forval 			x = 11/20 {
		local 		z = `x' - 5
		rename 		s09q03__`x' cope_`z'
	}
	drop 			s09q03__21 s09q03__22 

* concerns 
	rename 			s09bq01 concern_1
	rename 			s09bq02 concern_2
	
* fragility conflict violence
	rename 			s11q01 security 
	rename 			s11q02 trust
	forval 			x = 1/7 {
		rename 		s11q03__`x' tension_`x'
	}
	rename 			s11q04 move
	rename 			s11q05 move_why
	rename 			s11q06 hh_needs_met
	drop 			s11q*_autre
	
	
* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

* final clean 
	compress	
	rename 			hhid hhid_bf 
	label 			var hhid_bf "household id unique - Burkina Faso"
	
* save file
	customsave, 	idvar(hhid_bf) filename("bf_panel.dta") ///
					path("$export") dofile(bf_build_master) user($user)

* close the log
	log	close

/* END */	
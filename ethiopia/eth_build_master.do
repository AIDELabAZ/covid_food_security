* Project: COVID Food Security
* Created on: Oct 2020
* Created by: jdm
* Edited by: lirr
* Last edit: Sep 2021
* Stata v.17.0

* does
	* appends rounds of Ethiopia data
	* formats and cleans master dataset 
	* outputs panel data

* assumes
	* raw Ethiopia data
	* xfill.ado

* TO DO:
	* complete
	* when new waves available:
		* create build for new wave based on previous ones
		* update global list of waves below
		* check variable crosswalk for differences/new variables & update code if needed
		* check QC flags for issues/discrepancies
		

*************************************************************************
**# 0 - setup
*************************************************************************

* define list of waves
	global 			waves "1" "2" "3" "4" "5" "6" "7" "8" "9"
	
* define 
	global			root	=	"$data/ethiopia/raw"
	global			export	=	"$data/ethiopia/refined"
	global			logout	=	"$data/ethiopia/logs"
	global  		fies 	= 	"$data/analysis/raw/Ethiopia"

* open log
	cap log 		close
	log using		"$logout/eth_build", append


*************************************************************************
**# 1 - run do files for each round & generate variable comparison excel
*************************************************************************

* run do files for all rounds and create crosswalk of variables by wave
	foreach 		r in "$waves" {
		do 			"$code/ethiopia/eth_build_`r'"
	}
		do			"$code/ethiopia/eth_fies_0"
	
*************************************************************************
**# 2 - create ethiopia panel 
*************************************************************************

* append round datasets to build master panel
	foreach 		r in "$waves" {
	    if 			`r' == 1 {
			use		"$export/wave_01/r1", clear
		}
		else {
			append 	using "$export/wave_0`r'/r`r'"
		}
	}
	compress 
	
* merge in consumption aggregate
	merge m:1		household_id using "$root/wave_00/Ethiopia ESS 2018-19 Quintiles.dta", nogenerate
	rename 			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui
	drop 			if wave == .
	
* create country variable
	gen				country = 1
	
* replace all missing values as . (not .a, .b, etc.)
	quietly: ds, has(type numeric)
	foreach var in `r(varlist)' {
		replace 		`var' = . if `var' > .
	} 
	

*************************************************************************
* 3 - clean ethiopia panel
*************************************************************************

* rationalize variables across waves
	gen 			phw_cs = .
	foreach 		r in "$waves" {
		replace 	phw_cs = phw`r' if phw`r' != . & wave == `r'
		drop 		phw`r'
	}
	lab var			phw_cs "sampling weights - cross section"

* administrative variables 	
	rename			ii4_resp_id resp_id
	rename			cs4_sector sector
	rename			cs5_eaid ea
	rename			cs6_hhid hh_id
	rename			cs7_hhh_id hhh_id
	rename			cs1_region region
	rename			cs2_zoneid zone_id
	rename			cs3_woredaid county_id
	rename			cs3c_cityid city_id
	rename			cs3c_subcityid subcity_id
	rename			cs3b_kebeleid neighborhood_id
	rename			cs_startdate start_date
	rename			cs_submissiondate submission_date
	rename			cs7a_hhh_gender hhh_gender
	rename			cs7a_hhh_age hhh_age
	rename			cs12_round round
	rename			ii1_attempt attempt
	rename			bi_locchange loc_chg
	rename			bi_same_hhh same_hhh
	rename			ii4_resp_same same
	rename			ii4_resp_gender sex
	rename			ii4_resp_age age	
	rename			ii4_resp_relhhh relate_hoh
	* replace missing round 1 values based on respondant id (NEW CODE - J&A TO CHECK)
	* round 1 did not report respondant age, sex, or relation to hhh
		egen 			unique = group(household_id resp_id)
		xtset 			wave
		xfill 			sex, i(unique)
		bysort 			unique: egen min_age = min(age)
		replace 		age = min_age if age == . & wave == 1
		gen 			relate_temp = relate_hoh if wave == 2
		xfill 			relate_temp, i(unique)
		replace 		relate_hoh = relate_temp if relate_hoh == . & wave == 1 
		drop 			min_age unique relate_temp
	
* covid variables (wave 1 only)
	rename			kn1_heard know
	rename			kn2_meas_handwash know_1
	rename			kn2_meas_handshake know_2
	rename			kn2_meas_maskglove know_3
	rename			kn2_meas_travel know_4
	rename			kn2_meas_stayhome know_5
	rename			kn2_meas_gatherings know_6
	rename			kn2_meas_distance know_7
	rename			kn2_meas_facetouch know_8
	rename			kn3_gov_1 gov_1
	rename			kn3_gov_2 gov_2
	rename			kn3_gov_3 gov_3
	rename			kn3_gov_4 gov_4
	rename			kn3_gov_5 gov_5
	rename			kn3_gov_6 gov_6
	rename			kn3_gov_7 gov_7
	rename			kn3_gov_8 gov_8
	rename			kn3_gov_9 gov_9
	rename			kn3_gov_10 gov_10
	rename			kn3_gov_11 gov_11
	rename			kn3_gov_12 gov_12

* access variables 
	* staples & medical care & bank
		rename			ac1_atb_med ac_med
		rename			ac2_atb_med_why ac_med_why
		rename			ac1_atb_teff ac_teff
		rename			ac2_atb_teff_why ac_teff_why
		rename			ac1_atb_wheat ac_wheat
		rename			ac2_atb_wheat_why ac_wheat_why
		rename			ac1_atb_maize ac_maize
		rename			ac2_atb_maize_why ac_maize_why
		rename			ac1_atb_oil ac_oil
		rename			ac2_atb_oil_why ac_oil_why
		rename			ac6_med ac_medserv_need
		replace 		ac_medserv_need = ac1_medtreat if ac_medserv_need == .		
		forval 			x = 1/7 {
			gen 			ac_medserv_need_type_`x' = .
			replace 		ac_medserv_need_type_`x' = 0 if ac2_medtreat_type != ""
		}	
		forval 			x = 1/7 {	
			replace 		ac_medserv_need_type_`x'= 1 if strpos(ac2_medtreat_type,"`x'")!=0
		}
		rename 			ac3_fp_access ac_medserv_type_1 
		rename 			ac3_vacc_access ac_medserv_type_2 
		rename 			ac3_mat_access ac_medserv_type_3 
		rename 			ac3_ch_access ac_medserv_type_4 
		rename 			ac3_ah_access ac_medserv_type_5 
		rename 			ac3_ec_access ac_medserv_type_6 
		rename 			ac3_pharm_access ac_medserv_type_7 
		
		rename 			ac4_fp_access_reason ac_medserv_type_1_why  
		rename 			ac4_vacc_access_reason ac_medserv_type_2_why
		rename 			ac4_mat_access_reason ac_medserv_type_3_why
		rename 			ac4_ch_access_reason ac_medserv_type_4_why
		rename 			ac4_ah_access_reason ac_medserv_type_5_why
		rename 			ac4_ec_access_reason ac_medserv_type_6_why
		rename 			ac4_pharm_access_reason ac_medserv_type_7_why	
		rename			ac7_med_access ac_medserv
		rename			ac8_med_access_reas ac_medserv_why
		rename			ac9_bank ac_bank_need
	
	* covid test & vaccine
		rename 			bh8_cov_test cov_test
		rename 			bh9_cov_vaccine cov_vac 
		rename 			bh10_cov_vaccine_why_1 cov_vac_no_why_2_3
		rename 			bh10_cov_vaccine_why_2 cov_vac_no_why_7
		rename 			bh10_cov_vaccine_why_3 cov_vac_no_why_8
		rename 			bh10_cov_vaccine_why_4 cov_vac_no_why_1
		rename 			bh10_cov_vaccine_why_5 cov_vac_no_why_9

	* education 
		rename			ac3_sch_child sch_child
		rename 		 	ac3a_pri_sch_child sch_child_prim
		rename 		 	ac3b_sec_sch_child sch_child_sec
		rename			ac4_sch_girls sch_girl
		rename			ac4_sch_boys sch_boy
		rename			ac4_2_edu edu_act
		rename 			ac4a_pri_child edu_act_prim
		rename			ac5_edu_type_1 edu_1
		rename			ac5_edu_type_2 edu_2
		rename			ac5_edu_type_3 edu_3
		rename			ac5_edu_type_4 edu_4
		rename			ac5_edu_type_5 edu_5
		rename 			ac5_edu_type__96 edu_other

		drop 			ac5a_pri_edu_type ac5a_pri_edu_type__98 ac5a_pri_edu_type__99 ///
							ac5a_pri_edu_type_other 
		rename 			ac5a_pri_edu_type_1 edu_1_prim 
		rename 			ac5a_pri_edu_type_2 edu_2_prim  
		rename 			ac5a_pri_edu_type_3 edu_3_prim 
		rename 			ac5a_pri_edu_type_4 edu_4_prim 
		rename 			ac5a_pri_edu_type_5 edu_5_prim 	

		rename 			ac4b_sec_child edu_act_sec 
		drop 			ac5b_sec_edu_type ac5b_sec_edu_type__98 ac5b_sec_edu_type__99 ///
							ac5b_sec_edu_type_other
		rename 			ac5b_sec_edu_type_1 edu_1_sec 
		rename 			ac5b_sec_edu_type_2 edu_2_sec  
		rename 			ac5b_sec_edu_type_3 edu_3_sec 
		rename 			ac5b_sec_edu_type_4 edu_4_sec 
		rename 			ac5b_sec_edu_type_5 edu_5_sec 

		drop 			ac5_edu_type__98 ac5_edu_type__99 ac5_edu_type_other ///
							 ac5a_pri_edu_type__96 ac5b_sec_edu_type__96
	
		rename 			ac3_sch_open sch_reopen
		rename 			ac3_* *	
		rename 			ac4_sch_reg_boys sch_reopen_boy
		rename 			ac4_sch_reg_girls sch_reopen_girl

		* individual education
			drop 			inded_index_hhm_name*
			forval 			x = 1/13 {
				replace 	sch_child = 0 if inded1_attend_school`x' == 0
				replace 	edu_act = 0 if inded4_attend_edclose`x' == 0
				replace 	sch_child_reg = 0 if inded5_register`x' == 0
				replace 	sch_reopen = 0 if inded7_reopen`x' == 0
				if 			`x' == 1 {
					gen			sch_att = 0 if inded8_attend_fourwks`x' == 0
				}
				else {
					replace		sch_att = 0 if inded8_attend_fourwks`x' == 0
				}
				if 			`x' == 1 {
					forval 			q = 1/8 {
						gen 		sch_child_reg_why_`q' = 0 if ///
										inded10_register_reason`x' != `q' & ///
										inded10_register_reason`x' != .
					}
				}
				else {
				    forval 			q = 1/8 {
						replace		sch_child_reg_why_`q' = 0 if ///
										inded10_register_reason`x' != `q' & ///
										inded10_register_reason`x' != .
					}
				}
				if 		`x' == 1 {
				    gen		sch_att_why_1 = 0 if inded11_attend_reason`x' != . ///
								& inded11_attend_reason`x' != 1
					gen 		sch_att_why_6 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 2
					gen 		sch_att_why_16 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 3
					gen 		sch_att_why_17 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 4
					gen 		sch_att_why_8 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 5
					gen 		sch_att_why_18 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 6
					gen 		sch_att_why_7 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 7
					gen 		sch_att_why_19 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 8
				}
				else {
				    replace		sch_att_why_1 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 1
					replace		sch_att_why_6 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 2
					replace 	sch_att_why_16 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 3
					replace		sch_att_why_17 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 4
					replace		sch_att_why_8 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 5
					replace		sch_att_why_18 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 6
					replace		sch_att_why_7 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 7
					replace		sch_att_why_19 = 0 if inded11_attend_reason`x' != . ///
									& inded11_attend_reason`x' != 8
				}
			}
			
			forval 			x = 1/13 {
				replace 	sch_child = 1 if inded1_attend_school`x' == 1
				replace 	edu_act = 1 if inded4_attend_edclose`x' == 1
				replace 	sch_child_reg = 1 if inded5_register`x' == 1
				replace 	sch_reopen = 1 if inded7_reopen`x' == 1
				replace 	sch_att = 1 if inded8_attend_fourwks`x' == 1
				forval 			q = 1/8 {
					replace 	sch_child_reg_why_`q' = 1 if ///
									inded10_register_reason`x' == `q'
				}
				replace		sch_att_why_1 = 1 if inded11_attend_reason`x' == 1	
				replace		sch_att_why_6 = 1 if inded11_attend_reason`x' == 2	
				replace		sch_att_why_16 = 1 if inded11_attend_reason`x' == 3	
				replace		sch_att_why_17 = 1 if inded11_attend_reason`x' == 4	
				replace		sch_att_why_8 = 1 if inded11_attend_reason`x' == 5
				replace		sch_att_why_18 = 1 if inded11_attend_reason`x' == 6	
				replace		sch_att_why_7 = 1 if inded11_attend_reason`x' == 7	
				replace		sch_att_why_19 = 1 if inded11_attend_reason`x' == 8	
			}	
			
	* water and soap
	 * only in round 4
		rename 			wa1_water_drink ac_drink
		replace 		ac_drink = ac_drink - 1 if wave == 9
		replace 		ac_drink = 1 if ac_drink == -1
		rename 			wa2_water_drink_why ac_drink_why
		lab def 		ac_drink_why 1 "water supply not available" 2 "water supply reduced" ///
						3 "unable to access communal supply" 4 "unable to access water tanks" ///
						5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
						8 "restriction to go out" 9 "increase in price" 10 "cannot afford"
		lab val 		ac_drink_why ac_drink_why
		lab var 		ac_drink "Had Enough Drinking Water in Last 7 Days"
		lab var 		ac_drink_why "Main Reason Not Enough Drinking Water in Last 7 Days"
		
		rename 			wa3_water_wash ac_water
		rename 			wa4_water_wash_why ac_water_why
		lab var 		ac_water "Had Enough Handwashing Water in Last 7 Days"
		lab var 		ac_water_why "Main Reason Not Enough Handwashing Water in Last 7 Days"

		rename 			wa5_soap_wash ac_soap		
		rename 			wa6_soap_wash_why ac_soap_why
		replace 		ac_soap_why = ac_soap_why - 4
		replace 		ac_soap_why = 8 if ac_soap_why == 7
		replace 		ac_soap_why = 7 if ac_soap_why == 6
		lab def 		ac_soap_why 1 "shops out" 2 "markets closed" 3 "lack of transportation" ///
						4 "restriction to go out" 5 "increase in price" 6 "lack of money" ///
						7 "cannot afford" 8 "afraid to get virus"
		lab val 		ac_soap_why ac_soap_why
		lab var 		ac_soap "Had Enough Handwashing Soap in Last 7 Day"
		lab var 		ac_soap_why "Main Reason Not Enough Handwashing Soap in Last 7 Days"
	
	* credit 
	 * first addition in R5
		rename 			cr1_since_loan ac_cr_loan 
		forval 			x = 1/11 {
			rename 		cr2_since_lender_`x' ac_cr_lend_`x'
		}
		replace 		ac_cr_lend_1 = 1 if ac_cr_lend_11 == 1
		drop 			ac_cr_lend_11
		lab var 		ac_cr_lend_1 "friend or relative"
		
		rename 			cr3_since_reas_1 ac_cr_why_1
		rename 			cr3_since_reas_2 ac_cr_why_4
		replace 		ac_cr_why_4 = 1 if cr3_since_reas_3 == 1
		rename 			cr3_since_reas_4 ac_cr_why_5
		replace 		ac_cr_why_5 = 1 if cr3_since_reas_5 == 1 | ///
							cr3_since_reas_6 == 1 |cr3_since_reas_7 == 1 ///
							| cr3_since_reas_8 == 1
		rename 			cr3_since_reas_9 ac_cr_why_7
		rename 			cr3_since_reas_10 ac_cr_why_13
		rename 			cr3_since_reas_11 ac_cr_why_9
		drop 			cr3_since_reas_3 cr3_since_reas_5 cr3_since_reas_6 ///
							cr3_since_reas_7 cr3_since_reas_8
		
		forval    		x = 1/12 {
			rename 		cr4_since_who_`x' ac_cr_who_`x'
		}
		rename 			cr5_since_duedate ac_cr_due
		rename 			cr6_before_loan ac_cr_bef
	
		rename 			cr7_before_reas_1 ac_cr_bef_why_1
		rename 			cr7_before_reas_2 ac_cr_bef_why_4
		replace 		ac_cr_bef_why_4 = 1 if cr7_before_reas_3 == 1
		rename 			cr7_before_reas_4 ac_cr_bef_why_5
		replace 		ac_cr_bef_why_5 = 1 if cr7_before_reas_5 == 1 | ///
							cr7_before_reas_6 == 1 |cr7_before_reas_7 == 1 ///
							| cr7_before_reas_8 == 1
		rename 			cr7_before_reas_9 ac_cr_bef_why_7
		rename 			cr7_before_reas_10 ac_cr_bef_why_13
		rename 			cr7_before_reas_11 ac_cr_bef_why_9
		drop 			cr7_before_reas_3 cr7_before_reas_5 cr7_before_reas_6 ///
							cr7_before_reas_7 cr7_before_reas_8
											
		forval 			x = 1/12 {
			rename		cr8_before_who_`x' ac_cr_bef_who_`x'
		}
		rename 			cr9_worry ac_cr_worry
		rename 			cr10_missed_pay ac_cr_miss
		rename 			cr11_delay_chg ac_cr_delay	
	
* employment variables 	
	rename			em1_work_cur emp
	rename			em6_work_cur_act emp_act
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
	rename			em6_work_cur_act_other emp_act_other
	rename			em7_work_cur_status emp_stat
	rename			em7_work_cur_status_other emp_stat_other
	rename			em8_work_cur_same emp_same
	rename			em9_work_change_why emp_chg_why_eth
	rename			em2_work_pre emp_pre
	rename			em3_work_no_why emp_pre_why
	rename			em4_work_pre_act emp_pre_act
	rename			em5_work_pre_status emp_pre_stat
	rename			em12_work_cur_able emp_able
	rename			em13_work_cur_notable_paid emp_unable
	rename			em14_work_cur_notable_why emp_unable_why
	rename			em15_bus bus_emp
	replace 		bus_emp = 1 if em15a_bus == 1
	rename			em15a_bus_prev bus_prev
	rename 			em15b_bus_prev_closed bus_closed
	replace 		bus_closed = 9 if bus_closed == 3
	replace 		bus_closed = 3 if bus_closed == 4
	replace 		bus_closed = 4 if bus_closed == 5
	replace 		bus_closed = 5 if bus_closed == 6
	replace 		bus_closed = . if bus_closed < 0
	lab def 		clsd 1 "USUAL PLACE OF BUSINESS CLOSED DUE TO CORONAVIRUS LEGAL RESTRICTIONS" ///
						2 "USUAL PLACE OF BUSINESS CLOSED FOR ANOTHER REASON" ///
						3 "NO COSTUMERS / FEWER CUSTOMERS" 4 "CAN'T GET INPUTS" ///
						5 "CAN'T TRAVEL / TRANSPORT GOODS FOR TRADE" ///
						7 "ILLNESS IN THE HOUSEHOLD" 8 "NEED TO TAKE CARE OF A FAMILY MEMBER" ///
						9 "SEASONAL CLOSURE" 10 "VACATION" 
	lab val 		bus_closed clsd
	rename			em15c_bus_new bus_new
	rename			em16_bus_sector bus_sect
	rename			em17_bus_inc bus_emp_inc
	rename			em18_bus_inc_low_amt bus_amt
	gen				bus_why = .
	replace 		bus_why = 1 if em19_bus_inc_low_why_1 == 1
	replace			bus_why = 2 if em19_bus_inc_low_why_2 == 1
	replace 		bus_why = 3 if em19_bus_inc_low_why_3 == 1
	replace			bus_why = 4 if em19_bus_inc_low_why_4 == 1
	replace 		bus_why = 5 if em19_bus_inc_low_why_5 == 1
	replace			bus_why = 6 if em19_bus_inc_low_why_6 == 1
	replace 		bus_why = 7 if em19_bus_inc_low_why_7 == 1
	replace			bus_why = 8 if em19_bus_inc_low_why__98 == 1
	replace 		bus_why = 9 if em19_bus_inc_low_why__96 == 1
	lab def			bus_why 1 "markets closed - covid" 2 "markets closed - other" 3 "seasonal closure" /// 
								4 "no customers" 5 "unable to get inputs" 6 "unable to sell output" ///
								7 "illness in household" 8 "do not know" 9 "other"
	lab val 		bus_why bus_why 
	lab var 		bus_why "reason for family business less than usual"
	
	rename 			em20a_bus_emp employ_hire
	rename 			em20b_bus_family_emp employ_fam
	rename 			em20c_bus_family_unpaid employ_fam_unpaid
	rename 			em20d_bus_emp_before employ_hire_prev
	
	rename 			em20e_bus_resp_1 bus_beh_4 
	rename 			em20e_bus_resp_2 bus_beh_8 
	rename 			em20e_bus_resp_3 bus_beh_6
	gen 			bus_beh = 0 if em20e_bus_resp_0 == 1
	replace 		bus_beh = 1 if bus_beh_4 == 1 | bus_beh_8 == 1 | bus_beh_6 == 1
	rename			em20_farm farm_emp
	replace 		farm_emp = 1 if em20a_farm == 1
	replace 		farm_emp = em21_farm if farm_emp == .	
	rename			em21_farm_norm farm_norm 
	replace 		farm_norm = em22_farm_norm if farm_norm == .
	forval 			x = 1/7 {
	    rename 		em22_farm_norm_why_`x' farm_why_`x'
	}
	rename			em23_we wage_emp
	replace 		wage_emp = em24_we if wage_emp == .
	rename			em24_we_layoff wage_off
	replace 		wage_off = em25_we_layoff if wage_off == .
	rename			em25_we_layoff_covid wage_off_covid
	replace 		wage_off_covid = em26_we_layoff_covid if wage_off_covid == .
 /* Change pre-COVID employment to "yes" if the respondent is currently employed - interviewers in rounds 4 and 5 
 asked every respondent question 2 from the employment section (em2_work_pre), regardless of their answer to question 1 
 (em1_work_cur), whereas in rounds 1-3, respondents were only asked question 2 if they responded "no" to question 1 */
	replace emp_pre = 1 if emp == 1 & emp_pre == .

* income variables 	
	rename			lc1_farm farm_inc
	rename			lc2_farm_chg farm_chg
	rename			lc1_bus bus_inc
	rename			lc2_bus_chg bus_chg
	rename			lc1_we wage_inc
	rename			lc2_we_chg wage_chg
	rename			lc1_rem_dom rem_dom
	rename			lc2_rem_dom_chg rem_dom_chg
	rename			lc1_rem_for rem_for
	rename			lc2_rem_for_chg rem_for_chg
	rename			lc1_isp isp_inc
	rename			lc2_isp_chg isp_chg
	rename			lc1_pen pen_inc
	rename			lc2_pen_chg pen_chg
	rename			lc1_gov gov_inc
	rename			lc2_gov_chg gov_chg
	rename			lc1_ngo ngo_inc
	rename			lc2_ngo_chg ngo_chg
	rename			lc1_other oth_inc
	rename			lc2_other_chg oth_chg
	rename			lc3_total_chg tot_inc_chg
	
* generate any shock variable
	gen				shock_any = 1 if farm_inc == 1 & (farm_chg == 3 | farm_chg == 4)
	replace			shock_any = 1 if bus_inc == 1 & (bus_chg == 3 | bus_chg == 4)
	replace			shock_any = 1 if wage_inc == 1 & (wage_chg == 3 | wage_chg == 4)
	replace			shock_any = 1 if rem_dom == 1 & (rem_dom_chg == 3 | rem_dom_chg == 4)
	replace			shock_any = 1 if rem_for == 1 & (rem_for_chg == 3 | rem_for_chg == 4)
	replace			shock_any = 1 if isp_inc == 1 & (isp_chg == 3 | isp_chg == 4)
	replace			shock_any = 1 if pen_inc == 1 & (pen_chg == 3 | pen_chg == 4)
	replace			shock_any = 1 if gov_inc == 1 & (gov_chg == 3 | gov_chg == 4)
	replace			shock_any = 1 if ngo_inc == 1 & (ngo_chg == 3 | ngo_chg == 4)
	replace			shock_any = 1 if oth_inc == 1 & (oth_chg == 3 | oth_chg == 4)
	replace			shock_any = 0 if shock_any == .
	lab var			shock_any "Experience some shock"

* coping variables 	
	forval 			x = 1/15 {
	    rename 		lc4_total_chg_cope_`x' cope_`x'
	}
	rename			lc4_total_chg_cope_0 cope_16
	rename			lc4_total_chg_cope__96 cope_17

* migration 
	rename 			mig1_hh mig
	rename 			mig2_num mig_num
	forval 			x = 1/4 {
		rename 			mig3_region`x' mig_where_mem`x'
		rename 			mig4_woreda_same`x' mig_where_same_mem`x'
		rename 			mig5_reason`x' mig_why_mem`x'
		rename 			mig6_work`x' mig_work_mem`x'
	}
	
	forval 			x = 2/12 {
		gen 			temp`x' = 0
		replace 		temp`x' = 1 if retmig_index_hhm_name`x' != ""
	}
	gen 			num_new_mems = temp2 + temp3 + temp4 + temp5 + temp6 + temp7 ///
						+ temp8 + temp9 + temp10 + temp11 + temp12 
	drop			temp*
	replace 		num_new_mems = . if wave != 8

	
	forval 			q = 1/5 {
		forval 			x = 2/12 {
			gen 			temp`q'_mem`x' = 1 if retmig5_join_reason`x' == `q'
		}
	}
	forval 			q = 1/5 {
		egen 			num_join_why_`q' = rowtotal(temp`q'_*)
	}
	drop 			temp*
	gen 			join_urb = 1 if retmig8_rural_urban2 == 1 | retmig8_rural_urban3 == 1 | ///
						retmig8_rural_urban4 == 1 | retmig8_rural_urban5 == 1 | ///
						retmig8_rural_urban6 == 1 | retmig8_rural_urban7 == 1 | ///
						retmig8_rural_urban8 == 1 | retmig8_rural_urban9 == 1 | ///
						retmig8_rural_urban10 == 1 | retmig8_rural_urban11 == 1 | ///
						retmig8_rural_urban12 == 1
	gen 			join_rur = 1 if retmig8_rural_urban2 == 3 | retmig8_rural_urban3 == 3 | ///
						retmig8_rural_urban4 == 3 | retmig8_rural_urban5 == 3 | ///
						retmig8_rural_urban6 == 3 | retmig8_rural_urban7 == 3 | ///
						retmig8_rural_urban8 == 3 | retmig8_rural_urban9 == 3 | ///
						retmig8_rural_urban10 == 3 | retmig8_rural_urban11 == 3 | ///
						retmig8_rural_urban12 == 3
	gen 			join_work_bef = 0 if retmig9_job2 == 0 | retmig9_job3 == 0 | ///
						retmig9_job4 == 0 | retmig9_job5 == 0 | retmig9_job6 == 0 | ///
						retmig9_job7 == 0 | retmig9_job8 == 0 | retmig9_job9 == 0 | ///
						retmig9_job10 == 0 | retmig9_job11 == 0 | retmig9_job12 == 0
	replace			join_work_bef = 1 if retmig9_job2 == 1 | retmig9_job3 == 1 | ///
						retmig9_job4 == 1 | retmig9_job5 == 1 | retmig9_job6 == 1 | ///
						retmig9_job7 == 1 | retmig9_job8 == 1 | retmig9_job9 == 1 | ///
						retmig9_job10 == 1 | retmig9_job11 == 1 | retmig9_job12	== 1
	gen 			join_ret = 0 if retmig11_return2 == 2 | retmig11_return2 == 3 | ///
						retmig11_return3 == 2 | retmig11_return3 == 3 | retmig11_return4 == 2 | ///
						retmig11_return4 == 3 | retmig11_return5 == 2 | retmig11_return5 == 3 | ///
						retmig11_return6 == 2 | retmig11_return6 == 3 | retmig11_return7 == 2 | ///
						retmig11_return7 == 3 | retmig11_return8 == 2 | retmig11_return8 == 3 | ///
						retmig11_return9 == 2 | retmig11_return9 == 3 | retmig11_return10 == 2 | ///
						retmig11_return10 == 3 | retmig11_return11 == 2 | retmig11_return11 == 3 | ///
						retmig11_return12 == 2 | retmig11_return12 == 3 
	replace 		join_ret = 1 if retmig11_return2 == 1 | retmig11_return3 == 1 | ///
						retmig11_return4 == 1 | retmig11_return5 == 1 | retmig11_return6 == 1 | ///
						retmig11_return7 == 1 | retmig11_return8 == 1 | retmig11_return9 == 1 | ///
						retmig11_return10 == 1 | retmig11_return11 == 1 | retmig11_return12
	forval 			x = 1/7 {
	    gen 			join_ret_why_`x' = 1 if retmig12_return_reason2 == `x' | ///
							retmig12_return_reason3 == `x' | retmig12_return_reason4 == `x' | ///
							retmig12_return_reason5 == `x' | retmig12_return_reason6 == `x' | ///
							retmig12_return_reason7 == `x' | retmig12_return_reason8 == `x' | ///
							retmig12_return_reason9 == `x' | retmig12_return_reason10 == `x' | ///
							retmig12_return_reason11 == `x' | retmig12_return_reason12 == `x' 
	}
	gen 			join_same_job = 0 if retmig13_job_same2 == 0 | retmig13_job_same3 == 0 | ///
						retmig13_job_same4 == 0 | retmig13_job_same5 == 0 | retmig13_job_same6 == 0 | ///
						retmig13_job_same7 == 0 | retmig13_job_same8 == 0 | retmig13_job_same9 == 0 | ///
						retmig13_job_same10 == 0 | retmig13_job_same11 == 0 | retmig13_job_same12 == 0 	
	replace			join_same_job = 1 if retmig13_job_same2 == 1 | retmig13_job_same3 == 1 | ///
						retmig13_job_same4 == 1 | retmig13_job_same5 == 1 | retmig13_job_same6 == 1 | ///
						retmig13_job_same7 == 1 | retmig13_job_same8 == 1 | retmig13_job_same9 == 1 | ///
						retmig13_job_same10 == 1 | retmig13_job_same11 == 1 | retmig13_job_same12 == 1 
	forval 			x = 1/5 {
	    gen 			join_left_why_`x' = 1 if retmig15_leave_reason2 == `x' | ///
							retmig15_leave_reason3 == `x' | retmig15_leave_reason4 == `x' | ///
							retmig15_leave_reason5 == `x' | retmig15_leave_reason6 == `x' | ///
							retmig15_leave_reason7 == `x' | retmig15_leave_reason7 == `x' | ///
							retmig15_leave_reason9 == `x' | retmig15_leave_reason10 == `x' | ///
							retmig15_leave_reason11 == `x' | retmig15_leave_reason12 == `x' 
	}
	gen 			join_left_same_job = 0 if retmig16_job_same2 == 0 | retmig16_job_same3 == 0 | ///
						retmig16_job_same4 == 0 | retmig16_job_same5 == 0 | retmig16_job_same6 == 0 | ///
						retmig16_job_same7 == 0 | retmig16_job_same8 == 0 | retmig16_job_same9 == 0 | ///
						retmig16_job_same10 == 0 | retmig16_job_same11 == 0 | retmig16_job_same12 == 0  
	replace 		join_left_same_job = 1 if retmig16_job_same2 == 1 | retmig16_job_same3 == 1 | ///
						retmig16_job_same4 == 1 | retmig16_job_same5 == 1 | retmig16_job_same6 == 1 | ///
						retmig16_job_same7 == 1 | retmig16_job_same8 == 1 | retmig16_job_same9 == 1 | ///
						retmig16_job_same10 == 1 | retmig16_job_same11 == 1 | retmig16_job_same12 == 1 

* assistance variables - updated via convo with Talip 9/1
	gen				asst_food = as1_assist_type_1
	replace			as3_forwork_value_food = . if as3_forwork_value_food < 0
	replace			asst_food = 1 if as1_assist_type_2 == 1 & as3_forwork_value_food > 0
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist

	gen				asst_cash = as1_assist_type_3
	replace			as3_forwork_value_cash = . if as3_forwork_value_cash < 0
	replace			asst_cash = 1 if as1_assist_type_2 == 1 & as3_forwork_value_cash > 0
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	rename			as1_assist_type__96 asst_kind 
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 0 if asst_food == 0 | asst_cash == 0 | ///
						asst_kind == 0
	replace 		asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist
	
	drop			as1_assist_type as1_assist_type_1 as1_assist_type_2 ///
						as1_assist_type_3 as1_assist_type_0 as1_assist_type__98 ///
						as1_assist_type__99 ///
						as1_assist_type_other as3_food_value as2_food_psnp ///
						as4_food_source as4_food_source_other ///
						as3_forwork_value_food as3_forwork_value_cash ///
						as2_forwork_psnp as4_forwork_source ///
						as4_forwork_source_other as3_cash_value as2_cash_psnp ///
						as4_cash_source as4_cash_source_other as3_other_value ///
						as2_other_psnp as4_other_source as4_other_source_other

* perceptions of distribution of aid etc. 
	rename 			as5_assist_fair perc_aidfair
	rename 			as6_assist_tension perc_aidten 
	
* agriculture 
	rename			ag1_crops ag_crop
	rename			ag1a_crops_plan ag_plan
	rename 			ag2_crops_able ag_chg	
	rename			ag3_crops_reas_1 ag_nocrop_1 
	rename 			ag3_crops_reas_2 ag_nocrop_2
	rename 			ag3_crops_reas_3 ag_nocrop_3
	rename			ag3_crops_reas_4 ag_nocrop_10
	rename			ag3_crops_reas_5 ag_nocrop_4	 
	rename 			ag3_crops_reas_6 ag_nocrop_5
	rename 			ag3_crops_reas_7 ag_nocrop_6
	rename 			ag3_crops_reas_8 ag_nocrop_7	
	rename 			ag3_crops_reas_9 ag_nocrop_11
	rename 			ag3_crops_reas__96 ag_nocrop_9 
	
	forval 			x = 1/6 {
	    gen 		ag_ac_seed_why_`x' = .
		replace 	ag_ac_seed_why_`x' = 0 if ag5_crops_reas_seeds != .	
		replace 	ag_ac_seed_why_`x' = 1 if ag5_crops_reas_seeds == `x'
	}

	forval 			x = 1/6 {
	    gen 		ag_ac_fert_why_`x' = .
		replace 	ag_ac_fert_why_`x' = 0 if ag4_crops_reas_fert != .	
		replace 	ag_ac_fert_why_`x' = 1 if ag4_crops_reas_fert == `x'
	}

	drop			ag4_crops_reas_fert
	rename 			ag6_ext_need ag_ext_need 
	rename 			ag7_ext_receive ag_ext
	rename 			ag8_travel_norm ag_trav_lab_norm
	rename 			ag9_travel_curr ag_trav_lab
  
	* post-harvest 
	replace 		ag_crop = ph1_crops if ph1_crops < .
	rename 			ph2_crops_main ag_main
	rename 			ph3_crops_area_q ag_main_area
	rename 			ph3_crops_area_u ag_main_area_unit
	rename 			ph4_crops_finish ag_main_harv_comp
	rename 			ph5_crops_harvest_q ag_quant
	rename 			ph5_crops_harvest_u ag_quant_unit
	rename 			ph6_crops_harvest_expect ag_expect
	rename 			ph7_crops_harvest_covid harv_cov
	rename 			ph8_crops_harvest_covid_how_1 harv_cov_why_2
	rename 			ph8_crops_harvest_covid_how_2 harv_cov_why_3
	rename 			ph8_crops_harvest_covid_how_3 harv_cov_why_4
	rename 			ph8_crops_harvest_covid_how_4 harv_cov_why_5
	
* locusts
 * first addition in R4 (only in r4)
	rename 			lo1_keb	loc_keb_any
	rename 			lo1b_keb loc_bef
	rename 			lo2_farm loc_farm_any
	rename			lo3_impact_1 loc_imp_1
	rename			lo3_impact_2 loc_imp_2
	rename			lo3_impact_3 loc_imp_3
	rename			lo3_impact_4 loc_imp_4
	rename 			lo4_destr loc_dam
	drop 			lo3_impact__99 
	rename 			lo5_sprayed	loc_sprayed
	rename 			lo5_protect_* loc_protect_*
	drop 			loc_protect__96 loc_protect_other
	rename 			lo5b_protect loc_protect_eff
	rename 			lo6_other_actions_* loc_prev_dam_*
	drop 			lo6_other_actions* loc_prev_dam_other loc_prev_dam__96
	rename 			lo7_support loc_supp

* SWIFT
	rename 			sw0_read swift_read
	rename 			sw1_account swift_bank
	rename 			sw2_light swift_light
	rename 			sw3_toilet swift_toilet
	replace 		swift_toilet = 2 if swift_toilet != 4 & swift_toilet != .
	replace 		swift_toilet = 1 if swift_toilet == 4
	lab def 		toilet 1 "No facility" 2 "Other"
	lab val 		swift_toilet toilet 
	rename 			sw4_floor swift_floor
	rename 			sw5_rooms swift_rooms
	rename 			sw6a_items_1 swift_milk
	rename 			sw6a_items_2 swift_tea
	rename 			sw6a_items_3 swift_tom
	rename 			sw6a_items_4 swift_chili
	rename 			sw6a_items_5 swift_gar
	rename 			sw6a_items_6 swift_shiro
	rename 			sw6a_items_7 swift_pot
	rename 			sw6a_items_8 swift_cof
	rename 			sw6a_items_9 swift_wheat
	rename 			sw6b_items_1 swift_urb_wheat
	rename 			sw6b_items_2 swift_urb_pasta
	rename 			sw6b_items_3 swift_urb_tom
	rename 			sw6b_items_4 swift_urb_sug
	rename 			sw6b_items_5 swift_urb_lent
	rename 			sw6b_items_6 swift_urb_ban
	rename 			sw7_purchase_1 swift_cand
	rename 			sw7_purchase_2 swift_laun
	rename 			sw7_purchase_3 swift_kero
	rename 			sw7_purchase_4 swift_batt
	rename 			sw8a_preferredfoods swift_pref
	rename 			sw8b_mealsreduced swift_num_meal
	
* fies variables 	
	rename			fi7_outoffood fies_1
	replace 		fies_1 = fi1_outoffood if fies_1 ==. & fi1_outoffood != . 
	rename			fi8_hungrynoteat fies_2
	replace 		fies_2 = fi2_hungrynoteat if fies_2 ==. & fi2_hungrynoteat != .
	rename			fi6_noteatfullday fies_3
	replace 		fies_3 = fi3_noteatfullday if fies_3 == . & fi3_noteatfullday != .
	rename			fi1_enough fies_4
	rename			fi2_healthy fies_5
	rename			fi3_fewkinds fies_6
	rename			fi4_skipmeal fies_7
	rename			fi5_ateless fies_8
	lab val			fies* yesno
	
* drop unnecessary variables
	drop			kn3_gov kn3_gov_0 kn3_gov__98 kn3_gov__99 kn3_gov__96 ///
						kn3_gov_other ac2_atb_med_why_other ac2_atb_teff_why_other ///
						ac2_atb_wheat_why_other ac2_atb_maize_why_other ///
						ac2_atb_oil_why_other ag3* ag5* ///
						ac8_med_access_reas_other em9_work_change_why_other ///
						em3_work_no_why_other em4_work_pre_act_other ///
						em5_work_pre_status_other em14_work_cur_notable_why_other ///
						em16_bus_sector_other em19_bus_inc_low_why ///
						em19_bus_inc_low_why__98 em19_bus_inc_low_why__99 ///
						em19_bus_inc_low_why__96 em19_bus_inc_low_why_other ///
						em22_farm_norm_why__98 em22_farm_norm_why__99 ///
						em22_farm_norm_why__96 em22_farm_norm_why_other ///
						lc1_other_source lc4_total_chg_cope lc4_total_chg_cope__98 ///
						lc4_total_chg_cope__99 lc4_total_chg_cope_other ///
						ir1_endearly ir1_whyendearly ir1_whyendearly_other ///
						ir_lang ir_understand ir_confident em15b_bus_prev_closed_other ///
						key em19_bus_inc_low_why__* em19_bus_inc_low_why hh_id hhh_id ///
						start_date hhh_gender hhh_age same loc_chg same_hhh ///			
						cr2_since_lender cr2_since_lender__96 cr2_since_lender_other ///
						cr3_since_reas cr3_since_reas__96 cr3_since_reas_other ///
						cr4_since_who cr4_since_who__96 cr4_since_who_other ///
						cr7_before_reas cr7_before_reas__96 cr7_before_reas_other ///
						cr8_before_who cr8_before_who__96 cr8_before_who_other ///
						fi1_outoffood fi2_hungrynoteat fi3_noteatfullday lo3_impact ///
						weight *why_other ea_id ac5_edu_type emp_act_other emp_stat_other ///
						em22_farm_norm_why ag_live_other submission_date round attempt em19_* ///
						ag_live__96 ac2_medtreat_type* ac1_medtreat em20e_bus_resp ///
						ac4_*_access_reason_other ac2_medtreat_type_other bh10_cov_vaccine_why ///
						bh10_cov_vaccine_why__96 bh10_cov_vaccine_why_other inded* ///
						em15a_bus em20e_bus_resp_0 em21_farm em23_farm_norm_why ///
						em23_farm_norm_why_other em26_we_layoff_covid em25_we_layoff ///
						em24_we em22_farm_norm mig3_region_other* retmig* ph1_crops ///
						ph8_crops_harvest_covid_how_* ph10_livestock_type ///
						ph12_livestock_covid_how sw2_light_other sw3_toilet_other ///
						sw4_floor_other sw6a_items sw6a_items_0 sw6b_items sw6b_items_0 ///
						sw7_purchase sw7_purchase_0 sw_duration roster_key lo5_protect ///
						mig_name* mig5_reason_other* ph3_crops_area_u_other ///
						ag4_crops_reas_fert_other lo7_support_other ph5_crops_harvest_u_other ///
						ph8_crops_harvest_covid_how ag_live_affect_other em20a_farm other_access ///
						submissiondate
						

************************************************************************
**# 4 - append baseline fies
************************************************************************
	
* append baseline 
	append 			using "$export/wave_00/r0_fies"
	
* rename regions
	replace 		region = 1001 if region == 1
	replace 		region = 1002 if region == 2
	replace 		region = 1003 if region == 3
	replace 		region = 1004 if region == 4
	replace 		region = 1005 if region == 5
	replace 		region = 1006 if region == 6
	replace 		region = 1007 if region == 7
	replace 		region = 1008 if region == 12
	replace			region = 1009 if region == 13
	replace			region = 1010 if region == 14
	replace			region = 1011 if region == 15
	
	lab def			region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
						"Oromia" 1005 "Somali" 1006 "Benishangul-Gumuz" 1007 ///
						"SNNPR" 1008 "Gambela" 1009 "Harar" 1010 ///
						"Addis Ababa" 1011 "Dire Dawa"
	lab val			region region
	
* assign value labels
	lab val			sexhh cs7a_hhh_gender
	forval 			x = 1/9 {
	    lab val			fies_`x' yesno
	}
	
/*
************************************************************************
**# 5 - QC check 
************************************************************************

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
	export 			excel using "$export/eth_qc_flags.xlsx", first(var) sheetreplace sheet(flags)
	restore
	destring 		wave, replace

*/
************************************************************************
**# 6 - end matter, clean up to save
************************************************************************

* final clean 
	rename 			household_id hhid_eth 
	label 			var hhid_eth "household id unique - ethiopia"
	
* identify unique identifier and describe data
	isid			hhid_eth wave
	sort			hhid_eth wave
	compress
	
* save file
	save 			"$export/eth_panel_fies.dta", replace

* close the log
	log	close

/* END */
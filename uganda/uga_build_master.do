* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by : jdm
* Last edited: 29 September 2020
* Stata v.16.1

* does
	* merges together each section of Uganda data
	* renames variables
	* outputs single cross section data

* assumes
	* raw Uganda data

* TO DO:
	* when new waves available:
		* create build for new wave based on previous ones
		* update global list of waves below
		* check variable crosswalk for differences/new variables & update code if needed
		* check QC flags for issues/discrepancies
		

* **********************************************************************
* 0 - setup
* **********************************************************************

* define list of waves
	global 			waves "1" "2" "3" "4" "5"
	
* define
	global	root	=	"$data/uganda/raw"
	global	fies	=	"$data/analysis/raw/Uganda"
	global	export	=	"$data/uganda/refined"
	global	logout	=	"$data/uganda/logs"

* open log
	cap log 		close
	log using		"$logout/uga_build", append

	
* ***********************************************************************
* 1 - run do files for each round & generate variable comparison excel
* ***********************************************************************

* run do files for all rounds and create crosswalk of variables by wave
	foreach 		r in "$waves" {
		do 			"$code/uganda/uga_build_`r'"
	}
	do 				"$code/uganda/uga_build_0"
	
	
* **********************************************************************
* 2 - create uganda panel
* **********************************************************************

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
	preserve
	* load data
		use				"$root/wave_00/Uganda UNPS 2019-20 Quintiles.dta", clear
		rename			hhid baseline_hhid
		rename 			quintile quints
		lab var			quints "Quintiles based on the national population"
		lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
							4 "Quintile 4" 5 "Quintile 5"
		lab val			quints lbqui	
		
	* save temp file
		tempfile 		pov_r0
		save			`pov_r0'
	restore
	
	*merge 
		merge m:1		baseline_hhid using `pov_r0', nogen
		drop 			if wave == .
		
* replace all missing values as . (not .a, .b, etc.)
	quietly: ds, has(type numeric)
	foreach var in `r(varlist)' {
		replace 		`var' = . if `var' > .
	} 
	
	
* ***********************************************************************
* 3 - clean uganda panel
* ***********************************************************************	

* education perceptions & early childhood development 
	rename 			s1dq01__* sch_catchup_*
	ds 				sch_catchup_*
	foreach 		var in `r(varlist)' {
		replace 		`var' = 1 if `var' >= 1 & `var' != .
	}
	rename 			s1dq02__* sch_prec_prac_*
	rename 			s1eq02 ecd_pcg
	rename 			s1eq2_1 ecd_pcg_relate
	replace 		ecd_pcg_relate = 6 if ecd_pcg_relate == 5
	replace 		ecd_pcg_relate = 5 if ecd_pcg_relate == 4
	replace 		ecd_pcg_relate = 4 if ecd_pcg_relate == 3
	rename 			s1eq03 ecd_pcg_gen
	rename 			s1eq04 ecd_resp_relate
	replace 		ecd_resp_relate = 6 if ecd_resp_relate == 5
	replace 		ecd_resp_relate = 5 if ecd_resp_relate == 4
	replace 		ecd_resp_relate = 4 if ecd_resp_relate == 3
	rename 			s1fq07 ecd_play 
	rename 			s1fq08 ecd_read
	rename 			s1fq09 ecd_story
	rename 			s1fq10 ecd_song 
	rename 			s1fq11 ecd_out 
	rename 			s1fq12 ecd_ncd 
	rename 			s1fq13 ecd_num_bks 
	
	
* rename symptoms
	rename			s2q01 know
	rename			s2q01b__1 symp_1
	rename			s2q01b__2 symp_2
	rename			s2q01b__3 symp_3
	rename			s2q01b__4 symp_4
	rename			s2q01b__5 symp_5
	rename			s2q01b__6 symp_6
	rename			s2q01b__7 symp_7
	rename			s2q01b__8 symp_8
	rename			s2q01b__9 symp_9
	rename			s2q01b__10 symp_10
	rename			s2q01b__11 symp_11
	rename			s2q01b__12 symp_12
	rename			s2q01b__13 symp_13
	rename			s2q01b__14 symp_14
	rename			s2q01b__n98 symp_15	
	
* rename knowledge
	rename			s2q02__1 know_1
	lab var			know_1 "Handwashing with Soap Reduces Risk of Coronavirus Contraction"
	rename			s2q02__2 know_9
	lab var			know_9 "Use of Sanitizer Reduces Risk of Coronavirus Contraction"
	rename			s2q02__3 know_2
	lab var			know_2 "Avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract"
	rename			s2q02__4 know_3
	replace 		know_3 = 1 if s2q02__5 == 1
	replace 		know_3 = 0 if s2q02__5 == 0 & know_3 == .
	lab var			know_3 "Using Masks and/or Gloves Reduces Risk of Coronavirus Contraction"
	rename			s2q02__6 know_4
	lab var			know_4 "Avoiding Travel Reduces Risk of Coronavirus Contraction"
	rename			s2q02__7 know_5
	lab var			know_5 "Staying at Home Reduces Risk of Coronavirus Contraction"
	rename			s2q02__8 know_6
	lab var			know_6 "Avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction"
	rename			s2q02__9 know_7
	lab var			know_7 "Mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Contraction"
	rename			s2q02__10 know_8
	lab var			know_8 "Avoiding Face Touching Reduces Risk of Coronavirus Contraction"	
	
* rename myths
	rename			s2q02a_1 myth_1
	rename			s2q02a_2 myth_2
	rename			s2q02a_3 myth_3
	rename			s2q02a_4 myth_4
	rename			s2q02a_5 myth_5
	rename			s2q02a_6 myth_6
	rename			s2q02a_7 myth_7	

* rename government actions
	rename			s2q03__1 gov_1
	lab var			gov_1 "Advised citizens to stay at home"
	rename			s2q03__2 gov_2
	lab var			gov_2 "Restricted travel within country/area"
	rename			s2q03__3 gov_3
	lab var			gov_3 "Restricted international travel"
	rename			s2q03__4 gov_4
	lab var			gov_4 "Closure of schools and universities"
	rename			s2q03__5 gov_5
	lab var			gov_5 "Curfew/lockdown"
	rename			s2q03__6 gov_6
	lab var			gov_6 "Closure of non essential businesses"
	rename			s2q03__7 gov_7
	lab var			gov_7 "Building more hospitals or renting hotels to accomodate patients"
	rename			s2q03__8 gov_8
	lab var			gov_8 "Provide food to needed"
	rename			s2q03__9 gov_9
	lab var			gov_9 "Open clinics and testing locations"
	rename			s2q03__10 gov_11
	lab var			gov_11 "Disseminate knowledge about the virus"
	rename			s2q03__11 gov_13
	lab var			gov_13 "Compulsary putting on masks in public"
	rename			s2q03__12 gov_10
	lab var			gov_10 "Stopping or limiting social gatherings / social distancing"

* rename government contribution to spread
	rename			s2gq01 revised
	rename			s2gq02__1 spread_1
	rename			s2gq02__2 spread_2
	rename			s2gq02__3 spread_3
	rename			s2gq02__4 spread_4
	rename			s2gq02__5 spread_5
	rename			s2gq02__6 spread_6

* rename access
 * drinking water 
	rename			s4q01e ac_drink
	replace 		ac_drink = s4q1e if ac_drink == .
	rename			s4q01f ac_drink_why
	replace 		ac_drink_why = s4q1f if ac_drink_why == .
	forval 			x = 4/8 {
	    local 			q = `x' + 1
	    replace 		ac_drink_why = `q' if ac_drink_why == `x'
	}	
	replace 		ac_drink_why = 12 if ac_drink_why == 11
	lab def 		ac_drink_why 1 "water supply not available" 2 "water supply reduced" ///
						3 "unable to access communal supply" 4 "unable to access water tanks" ///
						5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
						8 "restriction to go out" 9 "increase in price" 10 "cannot afford" ///
						11 "unable to buy water" 12 "fear of catching the virus", replace
	lab val 		ac_drink_why ac_drink_why
	rename 			s4q1g ac_drink_src
 * soap
	rename 			s4q01 ac_soap
	rename			s4q02 ac_soap_why
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "cannot afford it" 8 "afraid to go out" 
	replace 		ac_soap_why = . if ac_soap_why == -96 | ac_soap_why == 9 | ac_soap_why == 99
	lab var 		ac_soap_why "reason for unable to purchase soap"
 * water wash
	rename 			s4q03 ac_water
	rename 			s4q04 ac_water_why	
	replace 		ac_water_why = 15 if ac_water_why == 9
	forval 			x = 4/8 {
	    local 			q = `x' + 1
		replace 		ac_water_why = `q' if ac_water_why == `x'
	}		
	replace 		ac_water_why = ac_water_why + 1 if (ac_water_why > 5 & ac_water_why < 10)
	lab def 			ac_water_why 1 "water supply not available" 2 "water supply reduced" ///
						3 "unable to access communal supply" 4 "unable to access water tanks" ///
						5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
						8 "restriction to go out" 9 "increase in price" 10 "cannot afford" ///
						11 "afraid to get viurs" 12 "water source too far" ///
						13 "too many people at water source" 14 "large household size" ///
						15 "lack of money", replace
	lab val 			ac_water_why ac_water_why
 * staple	
	rename 			s4q05 ac_staple_def
	rename 			s4q06 ac_staple
	rename			s4q07 ac_staple_why
	replace			ac_staple_why = 7 if ac_staple_why == -96
	lab def			ac_staple_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	lab var 		ac_staple_why "reason for unable to purchase staple food"
 * sauce
	rename 			s4q07a ac_sauce_def
	rename 			s4q07b ac_sauce
	rename			s4q07c ac_sauce_why
	replace			ac_sauce_why = 7 if ac_sauce_why == -96
	lab def			ac_sauce_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	lab var 		ac_sauce_why "reason for unable to purchase staple food"
 * medicine
	rename 			s4q08 ac_med
 * medical services
	rename 			s4q09 ac_medserv_need
	rename 			s4q10 ac_medserv
	rename 			s4q11 ac_medserv_why
	replace 		ac_medserv_why = 8 if ac_medserv_why == 4
	replace			ac_medserv_why = 4 if ac_medserv_why == 5
	replace			ac_medserv_why = 5 if ac_medserv_why == 7
	replace			ac_medserv_why = 7 if ac_medserv_why == 6
	lab def			ac_medserv_why 1 "lack of money" 2 "no med personnel" 3 "facility full" ///
								4 "facility closed" 5 "not enough supplies" ///
								6 "lack of transportation" 7 "restriction to go out" ///
								8 "afraid to get virus"
	lab val 		ac_medserv_why ac_medserv_why 
	lab var 		ac_medserv_why "reason for unable to access medical services"
	rename 			s4q11a ac_medserv_pre_need
	rename 			s4q11b ac_medserv_pre
 * masks
	rename 			s4q12 ac_mask
	rename 			s4q13 ac_mask_why
	rename 			s4q14_* ac_mask_srce*
* rename assets 
	rename			s4q12__1 ac_radio
	rename			s4q12__2 ac_tv
	rename			s4q12__3 ac_elec
	rename			s4q12__4 ac_solar
	rename			s4q12__5 ac_solar_kit
* rename education & bank
	rename 			s4q16 edu_cont
	rename			s4q17__1 edu_cont_1
	rename 			s4q17__2 edu_cont_2
	rename 			s4q17__3 edu_cont_3
	rename 			s4q17__4 edu_cont_4
	rename 			s4q17__5 edu_cont_5
	rename 			s4q17__6 edu_cont_6
	rename 			s4q17__7 edu_cont_7
	rename 			s4q17__8 edu_cont_9
	rename 			s4q18 ac_bank_need 
	rename 			s4q19 ac_bank
	rename 			s4q20 ac_bank_why
	replace 		ac_bank_why = 3 if ac_bank_why == 2

* assets
	rename 			s4aq01_computer ac_comp
	replace 		ac_comp = 1 if ac_comp == 2 | ac_comp == 3
	replace 		ac_comp = 2 if ac_comp == 4
	replace 		s4aq01_tablet = 1 if s4aq01_tablet == 2 | s4aq01_tablet == 3
	replace 		ac_comp = 1 if s4aq01_tablet == 1
	rename 			s4aq01_smartphone ac_mobile
	replace 		ac_mobile = 1 if ac_mobile == 2 | ac_mobile == 3	
	replace 		ac_mobile  = 2 if ac_mobile  == 4
	
* clean employment
	replace 		emp_act = 1 if emp_act == 11111
	replace 		emp_act = 2 if emp_act == 31111
	replace 		emp_act = 3 if emp_act == 71111
	replace 		emp_act = 4 if emp_act == 81111
	replace 		emp_act = 5 if emp_act == 91111
	replace 		emp_act = 6 if emp_act == 151111  | emp_act == 141111
	replace 		emp_act = 8 if emp_act == 61111
	replace 		emp_act = 9 if emp_act == 161111 | emp_act == 171111
	replace 		emp_act = 10 if emp_act == 21111
	replace 		emp_act = 11 if emp_act == 131111
	replace 		emp_act = 12 if emp_act == 41111 | emp_act == 51111
	replace 		emp_act = 14 if emp_act == 111111 | emp_act == 121111
	replace 		emp_act = -96 if emp_act == 101111 | emp_act == 191111 ///
						| emp_act == 181111 | emp_act == 201111						
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
	
* rename business variables
	lab def			bus_emp_inc 1 "Higher" 2 "The same" 3 "Less" 4 "No Revenue"
	lab val			bus_emp_inc bus_emp_inc 
	gen				bus_closed  = 1 if s5aq11b__1 == 1
	forval 			x = 2/10 {
	    replace 	bus_closed = `x' if s5aq11b__`x' == 1
	}
	replace 		bus_closed = s5aq11b if bus_closed == .
	replace 		bus_closed = 7 if bus_closed == 6	
	lab def 		clsd 1 "USUAL PLACE OF BUSINESS CLOSED DUE TO CORONAVIRUS LEGAL RESTRICTIONS" ///
						2 "USUAL PLACE OF BUSINESS CLOSED FOR ANOTHER REASON" ///
						3 "NO COSTUMERS / FEWER CUSTOMERS" 4 "CAN'T GET INPUTS" ///
						5 "CAN'T TRAVEL / TRANSPORT GOODS FOR TRADE" ///
						7 "ILLNESS IN THE HOUSEHOLD" 8 "NEED TO TAKE CARE OF A FAMILY MEMBER" ///
						9 "SEASONAL CLOSURE" 10 "VACATION" 
	lab val 		bus_closed clsd
	replace			bus_why = s5aq14_2 if bus_why == .
	forval 			x = 1/6 {
		rename 			s5aq15__`x' bus_chal_`x'
	}
	rename 			s5aq15__n96 bus_chal_7
 	
	rename			s5aq15a bus_beh
	forval 			x = 1/6 {
		rename 			s5aq15b__`x' bus_beh_`x'
	}
	rename			s5aq15b__n96 bus_beh_7
	rename 			s5aq15 bus_inc_avg

* rename agriculture
	replace 		harv_sell_need = s5bq25 if harv_sell_need == .
	replace 		harv_sell_need = s5bq08 if harv_sell_need == .
	rename			s5aq31 harv_sell	
	replace			harv_sell = s5bq26 if harv_sell == .
	replace			harv_sell = s5bq09 if harv_sell == .
	rename 			s5bq27_* ag_sell_where*

* rename crop harvest (R2)
	rename 			s5bq03 harv_stat
	rename 			s5bq04 harv_cov
	rename 			s5bq05_* harv_cov_why*
	rename 			s5bq06_* harv_saf*
	rename 			s5bq07 harv_nohire_why

* rename livestock
	gen 			ag_live_1 = 0 if s5cq02__1 == 0 | s5cq02__2 == 0
	replace 		ag_live_1 = 1 if s5cq02__1 == 1 | s5cq02__2 == 1
	gen 			ag_live_2 = 0 if s5cq02__3 == 0 | s5cq02__4 == 0	
	replace 		ag_live_2 = 1 if s5cq02__3 == 1 | s5cq02__4 == 1	
	gen 			ag_live_3 = 0 if s5cq02__5 == 0 | s5cq02__6 == 0
	replace 		ag_live_3 = 1 if s5cq02__5 == 1 | s5cq02__6 == 1
	rename 			s5cq02__8 ag_live_4
	rename 			s5cq02__7 ag_live_7
	lab var			ag_live_1 "Large ruminants" 
	lab var			ag_live_2 "Small ruminants" 
	lab var			ag_live_3 "Poultry/birds"
	lab var 		ag_live_4 "Equines"
	lab var			ag_live_7 "Pigs"
	rename 			s5cq03 ag_live_affect
	rename 			s5cq04__* ag_live_affect_*
	rename 			ag_live_affect_7 temp
	rename 			ag_live_affect_5 ag_live_affect_7
	rename 			ag_live_affect_6 ag_live_affect_5
	rename 			temp ag_live_affect_6
	rename 			s5cq08 ag_live_sell_want
	rename 			s5cq09 ag_live_sell_able
	rename 			s5cq11_* ag_live_sell_nowhy*
	rename 			livestock_products__ideggs ag_live_eggs
	rename 			livestock_products__idmeat ag_live_meat
	rename 			livestock_products__idmilk ag_live_milk
	rename 			livestock_products__idoth ag_live_other
	rename 			s5cq13* ag_live_*_sales
	forval 			x = 1/6 {
		foreach 	p in eggs meat milk other {
			rename 	s5cq14_1__`x'`p' ag_live_`p'_dec_why_`x'
			lab var ag_live_`p'_dec_why_`x' "Why have the sales of [LIVESTOCK PRODUCT] declined?"
		}
	}
	forval 			x = 1/6 {
		foreach 	p in eggs meat milk other {
			rename 	s5cq14_2__`x'`p' ag_live_`p'_no_why_`x'
			lab var ag_live_`p'_no_why_`x' "Why there were no sales of [LIVESTOCK PRODUCT]?"
		}
	}
	foreach 		p in eggs meat milk other {
		rename 		s5cq15`p' ag_live_pr_`p'
		lab var 	ag_live_pr_`p' "Has the price of [LIVESTOCK PRODUCT]…"
	}

* rename income variables
	rename 			s6q011 farm_inc
	lab	var			farm_inc "Income from farming, fishing, livestock in last 12 months"
	rename			s6q021 farm_chg
	lab var			farm_chg "Change in income from farming since covid"
	rename			s6q031 farm_chg_avg
	rename 			s6q012 bus_inc
	lab var			bus_inc "Income from non-farm family business in last 12 months"
	rename			s6q022 bus_chg
	lab var			bus_chg "Change in income from non-farm family business since covid"
	rename			s6q032 bus_chg_avg
	rename 			s6q013 wage_inc
	lab var			wage_inc "Income from wage employment in last 12 months"
	rename			s6q023 wage_chg
	lab var			wage_chg "Change in income from wage employment since covid"
	rename			s6q033 wage_chg_avg
	rename			s6q014 unemp_inc
	lab var			unemp_inc "Income from unemployment benefits in the last 12 months"
	rename			s6q024 unemp_chg
	lab var			unemp_chg "Change in income from unemployment benefits since covid"
	rename			s6q034 unemp_chg_avg
	rename 			s6q015 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename			s6q025 rem_for_chg
	label 			var rem_for_chg "Change in income from remittances abroad since covid"
	rename			s6q035 rem_for_chg_avg
	rename 			s6q016 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename			s6q026 rem_dom_chg
	label 			var rem_dom_chg "Change in income from remittances domestic since covid"
	rename			s6q036 rem_dom_chg_avg
	rename 			s6q017 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename			s6q027 asst_chg
	label 			var asst_chg "Change in income from assistance from non-family since covid"
	rename			s6q037 asst_chg_avg
	rename 			s6q018 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename			s6q028 isp_chg
	label 			var isp_chg "Change in income from properties, investment since covid"
	rename			s6q038 isp_chg_avg
	rename 			s6q019 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"
	rename			s6q029 pen_chg
	label 			var pen_chg "Change in income from pension since covid"
	rename			s6q039 pen_chg_avg
	rename 			s6q0110 gov_inc
	label 			var gov_inc "Income from government assistance in last 12 months"
	rename			s6q0210 gov_chg
	label 			var gov_chg "Change in income from government assistance since covid"
	rename			s6q0310 gov_chg_avg
	rename 			s6q0111 ngo_inc
	label 			var ngo_inc "Income from NGO assistance in last 12 months"
	rename			s6q0211 ngo_chg
	label 			var ngo_chg "Change in income from NGO assistance since covid"
	rename			s6q0311 ngo_chg_avg
	rename 			s6q0196 oth_inc
	label 			var oth_inc "Income from other source in last 12 months"
	rename			s6q0296 oth_chg
	label 			var oth_chg "Change in income from other source since covid"
	rename			s6q0396 oth_chg_avg
	rename 			s6q0212 tot_inc_chg
	rename 			s6q0312 tot_inc_chg_avg
	
* credit
 * since last call (slc)
	rename 			s7aq01 ac_cr_slc
	rename 			s7aq02* ac_cr_slc_lend*
	forval 			x = 1/13 {
		rename 		s7aq03__`x'_* ac_cr_slc_why_*_`x'
	}	
	forval 			x = 1/2 {
	    forval 		l = 1/2 {
			rename 	s7aq04_`x'_l`l' ac_cr_slc_who_l`l'_`x'
		}
	}
	rename 			s7aq05* ac_cr_slc_due*
	rename 			s7aq06* ac_cr_slc_worry*
	rename 			s7aq07* ac_cr_slc_miss*
	rename 			s7aq08* ac_cr_slc_delay*
 
 * since march
	rename 			s7bq01 ac_cr_loan
	replace 		ac_cr_loan = 0 if ac_cr_loan == .
	rename 			s7bq02* ac_cr_lend*
	forval 			x = 1/13 {
		rename 		s7bq03__`x'_* ac_cr_why_*_`x'
	}	
	forval 			x = 1/2 {
	    forval 		l = 1/2 {
			rename 	s7bq04_`x'_l`l' ac_cr_who_l`l'_`x'
		}
	}
	rename 			s7bq05* ac_cr_due*
	rename 			s7bq06* ac_cr_worry*
	rename 			s7bq07* ac_cr_miss*
	rename 			s7bq08* ac_cr_delay*
 
 * before march
	rename 			s7cq01 ac_cr_bef
	rename 			s7cq02* ac_cr_bef_lend*
	forval 			x = 1/13 {
		rename 		s7cq03__`x'_* ac_cr_bef_why_*_`x'
	}	
	forval 			x = 1/2 {
	    forval 		l = 1/2 {
			rename 	s7cq04_`x'_l`l' ac_cr_bef_who_l`l'_`x'
		}
	}
	rename 			s7cq05* ac_cr_bef_due*
	rename 			s7cq06* ac_cr_bef_worry*
	rename 			s7cq07* ac_cr_bef_miss*
	rename 			s7cq08* ac_cr_bef_delay*

* collapse loans into one variable when possible
	foreach 		t in cr cr_bef cr_slc {
		forval 			x = 1/13 {
			gen 		ac_`t'_why_`x' = .
			replace 	ac_`t'_why_`x' = 0 if ac_`t'_why_l1_`x' == 0 | ac_`t'_why_l2_`x' == 0
			replace 	ac_`t'_why_`x' = 1 if ac_`t'_why_l1_`x' == 1 | ac_`t'_why_l2_`x' == 1 
			drop 		ac_`t'_why_l1_`x' ac_`t'_why_l2_`x'
		}
	}
	foreach 		t in cr cr_bef cr_slc {
		foreach 	v in miss delay {
			gen 			ac_`t'_`v' = .
			replace 		ac_`t'_`v' = 0 if ac_`t'_`v'_l1 == 2 | ac_`t'_`v'_l2 == 2
			replace 		ac_`t'_`v' = 1 if ac_`t'_`v'_l1 == 1 | ac_`t'_`v'_l2 == 1
			drop 			ac_`t'_`v'_l1 ac_`t'_`v'_l2
		}
	}

* label cope variabels	
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
		
* drop unnecessary variables
	drop			 BSEQNO DistrictName sec0_endtime	///
						CountyName SubcountyName ParishName ///
						subreg s2q01b__n96 s2q01b_Other s5qaq17_1_Other ///
						s5aq20__n96 s5aq20_Other s5aq21__n96 s5aq21_Other ///
						s5aq22__n96 s5aq22_Other s5aq23_Other s5aq24_Other ///
						s5q10__0 s5q10__1 s5q10__2 s5q10__3 s5q10__4 s5q10__5 ///
						s5q10__6 s5q10__7 s5q10__8 s5q10__9 *_Other	 ///
						s4* s6q0112 s7q04__1 s7q04__2 s7q04__3 s7q04__4 ///
						s7q04__5 s7q04__6 s7q04__7 s7q04__8 s7q04__9 ///
						s7q04__10 s7q04__11 s7q04__12 s7q04__13 s7q04__14 ///
						s7q04__15 s7q04__16 s7q04__n96 s7q04_Other s7q05_Other	///
						s9q03__1 s9q03__2 s9q03__3 s9q03__4 s9q03__5 s9q03__6 ///
						s9q03__7 s9q03__8 s5q04a_2 s5q10__0 s5q10__1 ///
						s5q10__2 s5q10__3 s5q10__4 s5q10__5 business_case_filter ///
						s5aq11b__1 s5aq11b__2 s5aq11b__3 s5aq11b__4 s5aq11b__5 ///
						s5aq11b__6 s5aq11b__7 s5aq11b__8 s5aq11b__9 s5aq11b__10 ///
						s5aq11b__n96 s5aq14_2 s4q01f_Other s4q02_Other s4q04_Other ///
						s4q11_Other case_filter CountyCode2 CountyName2 ///
						DistrictCode2 DistrictName2 ParishCode2 ParishName2 ///
						SubcountyCode2 SubcountyName2 VillageCode2 VillageName2 ///
						ac_mask_srce_n96 harv_cov_why_n96 Sq02 PID  ///
						s5bq25 s5bq26 ag_sell_where_n96 Sq01 s5aq11b__0 ///
						weight harv_saf_5 *_interview_ID *_hh_weight s5qaq17_1 ///
						s2q02__5 s5bq08	s5bq09 s5cq02__* s4q1e s4q1f s4aq01_tablet ///
						s4aq02_computer_1 s4aq02_computer_2 s4aq02_tablet_1 ///
						s4aq02_tablet_2 s4aq02_smartphone_1 s4aq02_smartphone_2 ///
						s5q05a s5a11c_1 s5a11c s5bq17_1__n96 ag_sell_where_3 ///
						s5aq11b s5bq20__n96 s5bq21__n96 operatingR3 bus_status_R3 ///
						work_status_R3 t0_Rq03 t0_Rq04 bseqno pid_ubos ///
						agic_case_filter hh_roster__id
						
* rename basic information
	gen				sector = 2 if urban == 1
	replace			sector = 1 if sector == .
	lab var			sector "Sector"
	lab def			sector 1 "Rural" 2 "Urban"
	lab val			sector sector
	drop			urban
	rename 			survey_respondent resp_id
	
	gen				Region = 4012 if region == "Central"
	replace			Region = 4013 if region == "Eastern"
	replace			Region = 4014 if region == "Kampala"
	replace			Region = 4015 if region == "Northern"
	replace			Region = 4016 if region == "Western"
	lab define		region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
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
						"Western" 4017 "North" 4018 "Central" 4019 "South", replace
	lab val			Region region
	drop			region
	rename			Region region
	order			region, after(sector)
	lab var			region "Region"
	
	rename			DistrictCode zone_id
	rename			CountyCode county_id
	rename			SubcountyCode city_id
	rename			ParishCode subcity_id
	
	* create country variables
	gen				country = 4
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country
	lab var			country "Country"

/*
* **********************************************************************
* 4 - QC check 
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
	export 			excel using "$export/uga_qc_flags.xlsx", first(var) sheetreplace sheet(flags)
	restore
	destring 		wave, replace
*/	
	
* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************

* final clean 
	compress
	rename HHID hhid_uga
	drop if hhid_uga == .

* append baseline 
	append 			using "$export/wave_00/r0"	
	
* save file
	customsave , idvar(baseline_hhid) filename("uga_panel.dta") ///
		path("$export") dofile(uga_build) user($user)

* close the log
	log	close

/* END */
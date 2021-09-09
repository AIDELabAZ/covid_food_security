


		************************************************
		*											   *
		*											   *
		*       COVID 19 DATA CONSTRUCT IN MALI 	   *
		*											   *
		*											   *
		************************************************






			* PART 1: DATA CONSTRUCT - LSMS AND COVID DATA MALI     
			***************************************************
		
	
		* Load cleaned LSMS data file (this one is section 8A on food security)
			use "$MaliEHCVM2018_dtInt/s08a_me_MLI2018_cleaned.dta", clear

		* Some re-labeleing (read: translating) by Jeff---some of this might need to go nito the data cleaning .do file later
			label var s08aq01 "Have household members been woried that you will not have enough to eat?"
			label var s08aq02 "Have household members been woried that you could not eat nutritious foods?"
			label var s08aq03 "Have household members had to eat always the same thing?"
			label var s08aq04 "Have household members had to skip a meal?"
			label var s08aq05 "Have household members had to eat less than they should?"
			label var s08aq06 "Have household members found nothing to eat at home?"
			label var s08aq07 "Have adult household members been hungy but did not eat?"
			label var s08aq08 "Have adult household members not eaten all day?"
			
		* Generate household has mobile phone number indicator variable
			gen has_phone = (s00q12 != "88 88 88 88") // 21.02 percent no phone
			replace has_phone = 1 if s00q14 != "88 88 88 88" & s00q14 != " " & s00q14 != "" // 15.02 percent no phone
			replace has_phone = 1 if s00q16 != "88 88 88 88" & s00q16 != " " & s00q16 != "" // 11.87 percent no phone
			replace has_phone = 1 if s00q18 != "88 88 88 88" & s00q18 != " " & s00q18 != "" // 11.65 percent no phone
			
		* Prepare variable names for reshape
			rename s08aq01 fs10
			rename s08aq02 fs20
			rename s08aq03 fs30
			rename s08aq04 fs40
			rename s08aq05 fs50
			rename s08aq06 fs60
			rename s08aq07 fs70
			rename s08aq08 fs80

			rename s00q04 ruralurban0
			rename s00q02 region0
			rename grappe cluster0


			save "$MaliEHCVM2018_dtInt/s08a_me_MLI2018_construct.dta", replace
			


		*  load cleaned MaliCOVID_Round1 data

			use "$MaliCOVID_R1_dtInt/COVID_19_Mali_cleaned.dta", clear
				

		* Some re-labeling (read: translating) by Jeff---some of this might need to go into the data cleaning .do file later
			label var s02q01 "Have you heard of coronavirus?"
			label var s02q04 "Have you received information about social distancing and self-isolation measures?"
			label var s02q06 "Are you satisfied with the government's response to the coronavirus?"
			label var s03q01 "Last week, did you wash your hands more often than usual?"
			label var s03q02 "Last week, did you avoid shaking hands or other greetings with physical contact?"
			label var s03q03 "Last week, did you avoid gatherings of more than 10 people?"
			label var s03q04 "Last week, did you cancel any travel plans?"
			label var s03q05 "Last week, did you stockpile more food than usual?"
			label var s03q06 "Last week, did you reduce the number of times you went to the market or grocerty store?"
			label var s03q07 "Last week, did you reduce the number of times you went to a place of worship?"

			label var s06q04 "Since the beginning of the crisis, has your household bought more food to store?"
			label var s06q05 "Have household members been worried that you will not have enough to eat?"
			label var s06q05a "Was this specifically due to the covid-19 crisis?"
			label var s06q06 "Have household members been worried that you could not eat nutritious foods?"
			label var s06q06a "Was this specifically due to the covid-19 crisis?"
			label var s06q07 "Have household members had to eat always the same thing?"
			label var s06q07a "Was this specifically due to the covid-19 crisis?"
			label var s06q08 "Have household members had to skip a meal?"
			label var s06q08a "Was this specifically due to the covid-19 crisis?"
			label var s06q09 "Have household members had to eat less than they should?"
			label var s06q09a "Was this specifically due to the covid-19 crisis?"
			label var s06q10 "Have household members found nothing to eat at home?"
			label var s06q10a "Was this specifically due to the covid-19 crisis?"
			label var s06q11 "Have adult household members been hungy but did not eat?"
			label var s06q11a "Was this specifically due to the covid-19 crisis?"
			label var s06q12 "Have adult household members not eaten all day?"
			label var s06q12a "Was this specifically due to the covid-19 crisis?"
			*label var s06q12b "How often does this happen?"


		* Prepare variable names for reshape
			rename s06q05 fs11
			rename s06q06 fs21
			rename s06q07 fs31
			rename s06q08 fs41
			rename s06q09 fs51
			rename s06q10 fs61
			rename s06q11 fs71
			rename s06q12 fs81

			rename s06q05a fs1_covid1
			rename s06q06a fs2_covid1
			rename s06q07a fs3_covid1
			rename s06q08a fs4_covid1
			rename s06q09a fs5_covid1
			rename s06q10a fs6_covid1
			rename s06q11a fs7_covid1
			rename s06q12a fs8_covid1

			rename s02q01 heard_cov1
			rename s02q04 rec_info1
			rename s02q06 sat_gov1
			rename s03q01 cov_11
			rename s03q02 cov_21
			rename s03q03 cov_31
			rename s03q04 cov_41
			rename s03q05 cov_51
			rename s03q06 cov_61
			rename s03q07 cov_71

			gen round1=1
			rename hhweight_covid hhweight_covid1
			
		* Pulling in some other variables
			rename s07q02 risk_lose_income1
			rename s07q04 lost_job_number1
			rename s07q05 lost_income_estimate1
			rename s07q06a covid_pay_rent1
			rename s07q06b covid_food1
			rename s07q06c covid_water_elec1
			rename s07q07 covid_save1
			rename s07q08 covid_invest1
			
			save "$MaliCOVID_R1_dtInt/COVID_19_Mali_R1_construct.dta", replace
			
			
			
			
		*  load cleaned MaliCOVID_Round2 data

			use "$MaliCOVID_R1_dtInt/COVID_19_Mali_R2_cleaned.dta", clear
				

		* Some re-labeling (read: translating) by Jeff---some of this might need to go into the data cleaning .do file later

			label var s02q06 "Are you satisfied with the government's response to the coronavirus?"
			
			label var s03q01 "Last week, did you wash your hands more often than usual?"
			label var s03q02 "Last week, did you avoid shaking hands or other greetings with physical contact?"
			label var s03q03 "Last week, did you avoid gatherings of more than 10 people?"
			label var s03q04 "Last week, did you cancel any travel plans?"
			label var s03q05 "Last week, did you stockpile more food than usual?"
			label var s03q06 "Last week, did you reduce the number of times you went to the market or grocerty store?"
			label var s03q07 "Last week, did you reduce the number of times you went to a place of worship?"

			label var s06q04 "Since the beginning of the crisis, has your household bought more food to store?"
			label var s06q05 "Have household members been worried that you will not have enough to eat?"
			label var s06q05a "Was this specifically due to the covid-19 crisis?"
			label var s06q06 "Have household members been worried that you could not eat nutritious foods?"
			label var s06q06a "Was this specifically due to the covid-19 crisis?"
			label var s06q07 "Have household members had to eat always the same thing?"
			label var s06q07a "Was this specifically due to the covid-19 crisis?"
			label var s06q08 "Have household members had to skip a meal?"
			label var s06q08a "Was this specifically due to the covid-19 crisis?"
			label var s06q09 "Have household members had to eat less than they should?"
			label var s06q09a "Was this specifically due to the covid-19 crisis?"
			label var s06q10 "Have household members found nothing to eat at home?"
			label var s06q10a "Was this specifically due to the covid-19 crisis?"
			label var s06q11 "Have adult household members been hungy but did not eat?"
			label var s06q11a "Was this specifically due to the covid-19 crisis?"
			label var s06q12 "Have adult household members not eaten all day?"
			label var s06q12a "Was this specifically due to the covid-19 crisis?"
			*label var s06q12b "How often does this happen?"


		* Prepare variable names for reshape
			rename s06q05 fs12
			rename s06q06 fs22
			rename s06q07 fs32
			rename s06q08 fs42
			rename s06q09 fs52
			rename s06q10 fs62
			rename s06q11 fs72
			rename s06q12 fs82

			rename s06q05a fs1_covid2
			rename s06q06a fs2_covid2
			rename s06q07a fs3_covid2
			rename s06q08a fs4_covid2
			rename s06q09a fs5_covid2
			rename s06q10a fs6_covid2
			rename s06q11a fs7_covid2
			rename s06q12a fs8_covid2

			rename s02q06 sat_gov2
			
			rename s03q01 cov_12
			rename s03q02 cov_22
			rename s03q03 cov_32
			rename s03q04 cov_42
			rename s03q05 cov_52
			rename s03q06 cov_62
			rename s03q07 cov_72

			gen round2=1
			rename hhweight_covid hhweight_covid2

			save "$MaliCOVID_R1_dtInt/COVID_19_Mali_R2_construct.dta", replace
			
			merge 1:1 hhid using "$MaliCOVID_R1_dtInt/COVID_19_Mali_R1_construct.dta"
			*keep if _merge==3		
			drop _merge

			save "$MaliCOVID_R1_dtInt/COVID_19_Mali_construct.dta", replace
			
			

	* Now merge both LSMS construct and MaliCOVID_Round1 (NOT ROUND 2 YET) construct data and reshape the data for analysis

		* Load LSMS data file (this one is section 8A on food security)
			use "$MaliEHCVM2018_dtInt/s08a_me_MLI2018_construct.dta", clear

		* Merge data
			merge 1:1 hhid using "$MaliCOVID_R1_dtInt/COVID_19_Mali_R1_construct.dta"
			keep if _merge==3
			drop _merge

			keep hhid fs* ruralurban0 region0 cluster0 heard_cov* ///
			rec_info* sat_gov1 cov_* hhweight_covid1 s00q06 p0 risk_lose_income1 ///
			lost_job_number1 lost_income_estimate1 covid_pay_rent1 covid_food1 ///
			covid_water_elec1 covid_save1 covid_invest1  ///
			GPS__Latitude GPS__Longitude GPS__Accuracy GPS__Altitude
			
			gen ruralurban1 = ruralurban0 // use baseline rural-urban status - 1=urban, 2=rural
			
			gen region1 = region0 // use baseline region of residence - 91=Bamako
			
			gen cluster1 = cluster0 // use baseline cluster
			
			gen hhweight_covid0 = hhweight_covid1 // Use COVID round 1 sampling weight in the baseline 

		* Reshape data from wide to long
			reshape long fs1 fs2 fs3 fs4 fs5 fs6 fs7 fs8 ruralurban region fs1_covid fs2_covid ///
			fs3_covid fs4_covid fs5_covid fs6_covid fs7_covid fs8_covid heard_cov rec_info ///
			sat_gov cov_1 cov_2 cov_3 cov_4 cov_5 cov_6 cov_7 hhweight_covid cluster risk_lose_income ///
			lost_job_number lost_income_estimate covid_pay_rent covid_food ///
			covid_water_elec covid_save covid_invest, i(hhid) j(post)

			label var fs1 "(FS1) ... have been woried that you will not have enough to eat?"
			label var fs2 "(FS2) ... have been woried that you could not eat nutritious foods?"
			label var fs3 "(FS3) ... had to eat always the same thing?"
			label var fs4 "(FS4) ... had to skip a meal?"
			label var fs5 "(FS5) ... had to eat less than they should?"
			label var fs6 "(FS6) ... found nothing to eat at home?"
			label var fs7 "(FS7) ... been hungy but did not eat?"
			label var fs8 "(FS8) ... not eaten all day?"

			label var heard_cov "Have you heard of coronavirus?"
			label var rec_info "Have you received information about social distancing and self-isolation measures?"
			label var sat_gov "Are you satisfied with the government's response to the coronavirus?"
			label var cov_1 "Last week, did you wash your hands more often than usual?"
			label var cov_2 "Last week, did you avoid shaking hands or other greetings with physical contact?"
			label var cov_3 "Last week, did you avoid gatherings of more than 10 people?"
			label var cov_4 "Last week, did you cancel any travel plans?"
			label var cov_5 "Last week, did you stockpile more food than usual?"
			label var cov_6 "Last week, did you reduce the number of times you went to the market or grocerty store?"
			label var cov_7 "Last week, did you reduce the number of times you went to a place of worship?"

			* recode
			replace heard_cov = 0 if heard_cov==2
			replace rec_info = 0 if rec_info==2
			replace sat_gov = 0 if sat_gov==2
			replace cov_1 = 0 if cov_1==2
			replace cov_2 = 0 if cov_2==2
			replace cov_3 = 0 if cov_3==2
			replace cov_4 = 0 if cov_4==2
			replace cov_5 = 0 if cov_5==2
			replace cov_6 = 0 if cov_6==2
			replace cov_7 = 0 if cov_7==2

			* relable
			forvalues i=1/8 {
			label var fs`i'_covid "...Was this specifically due to COVID-19?"
			}

			set matsize 800

			* generate variables that keep missings as missings (for descriptive results table)
			forvalues i = 1(1)8 {
				gen fs`i'_noreplace = fs`i'
				replace fs`i'_noreplace = 0 if fs`i'_noreplace==2
				replace fs`i'_noreplace = . if fs`i'_noreplace>2
			}
			*

			label var fs1_noreplace "(FS1) ... have been woried that you will not have enough to eat?"
			label var fs2_noreplace "(FS2) ... have been woried that you could not eat nutritious foods?"
			label var fs3_noreplace "(FS3) ... had to eat always the same thing?"
			label var fs4_noreplace "(FS4) ... had to skip a meal?"
			label var fs5_noreplace "(FS5) ... had to eat less than they should?"
			label var fs6_noreplace "(FS6) ... found nothing to eat at home?"
			label var fs7_noreplace "(FS7) ... been hungy but did not eat?"
			label var fs8_noreplace "(FS8) ... not eaten all day?"

			* replace missings with zero and generate missing flags
			forvalues i = 1(1)8	{
				replace fs`i' = 0 if fs`i'==2
				gen fs`i'_missing = (fs`i'>2)
				replace fs`i' = 0 if fs`i'>2
			}
			*

			* generate variables that keep missings as missings (for descriptive results table)
			forvalues i = 1(1)8	{
				gen fs`i'_covid_noreplace = fs`i'_covid
				replace fs`i'_covid_noreplace = 0 if fs`i'_covid_noreplace==2
				replace fs`i'_covid_noreplace = . if fs`i'_covid_noreplace>2
			}
			*

			forvalues i=1/8 {
			label var fs`i'_covid_noreplace "...Was this specifically due to COVID-19?"
			}

			* replace missings with zero and generate missing flags
			forvalues i = 1(1)8	{
				replace fs`i'_covid = 0 if fs`i'_covid==2
				gen fs`i'_covid_missing = (fs`i'_covid>2)
				replace fs`i'_covid = 0 if fs`i'_covid>2
			}
			*
			
			replace hhweight_covid = 0 if hhweight_covid==. // replace missing weights with value = zero

			gen urban = (ruralurban==1)
			gen bamako = (region==91)

			gen fs_index = (fs1 + fs2 + fs3 + fs4 + fs5 + fs6 + fs7 + fs8)
			
			gen fs_index_2 = (fs1_noreplace + fs2_noreplace + fs3_noreplace + fs4_noreplace + fs5_noreplace + fs6_noreplace + fs7_noreplace + fs8_noreplace) 

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
			
			
			gen did_urban = post*urban
			gen did_bamako = post*bamako

			* some more variables
			gen risk_lose_income_yn = 1 if risk_lose_income == 1 | risk_lose_income== 2
			replace risk_lose_income_yn = 0 if risk_lose_income == 3 | risk_lose_income == 4 | risk_lose_income == 5
			
			gen lost_job = (lost_job_number>0)
			gen lost_income = (lost_income_estimate>0)
			gen cov_impact_rent = (covid_pay_rent<4)
			gen cov_impact_food = (covid_food<4)
			gen cov_impact_wa_el = (covid_water_elec<4)
			gen cov_impact_save = (covid_save<3)
			gen cov_impact_invest = (covid_invest<3)
			
			label var risk_lose_income_yn "My household is at risk of losing income due to the pandemic."
			label var lost_job "A household member has lost a job due to the pandemic."
			label var lost_income "My household has lost income due to the pandemic."
			label var cov_impact_rent "My household struggles to pay rent due to the pandemic."
			label var cov_impact_food "My household struggles to buy food due to the pandemic."
			label var cov_impact_wa_el "My household stuggles to access water/electricity due to the pandemic."
			label var cov_impact_save "My household reduced saving due to the pandemic."
			label var cov_impact_invest "My household reduced investment due to the pandemic."
			

			* some more labelling

			label define urban 0"Rural" 1"Urban", replace
			label values urban urban

			label define bamako 0"Non Bamako" 1"Bamako", replace
			label values bamako bamako

			label define time 0"Before COVID" 1"After COVID started", replace
			label values post time


		* save this final file for analysis

			save "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", replace
			
			
			
		* EXPORT data to .csv fr mapping in ARCGIS

			use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear
			
			gen Latitude=GPS__Latitude 
			gen Longitude=GPS__Longitude
			
			keep if post==1
						
			export delimited "$dataWorkFolder/COVID and Food Security/COVID 19 DATA MALI_hhlevel.csv", replace

			
			collapse (median) Latitude Longitude ///
					 (mean) cov_impact_invest cov_impact_save ///
							cov_impact_wa_el cov_impact_food cov_impact_rent ///
							lost_income lost_job risk_lose_income_yn   ///
							heard_cov rec_info sat_gov cov_4 cov_6 ///
							fs1_covid_noreplace fs2_covid_noreplace ///
							fs3_covid_noreplace fs4_covid_noreplace ///
							fs5_covid_noreplace fs6_covid_noreplace ///
							fs7_covid_noreplace fs8_covid_noreplace fs1_covid_missing ///
							fs2_covid_missing fs3_covid_missing ///
							fs4_covid_missing fs5_covid_missing fs6_covid_missing ///
							fs7_covid_missing fs8_covid_missing, by(ruralurban region cluster)

			export delimited "$dataWorkFolder/COVID and Food Security/COVID 19 DATA MALI_clusterlevel.csv", replace


***********************************************************************************************************************




			* PART 2: IMPORTING AND CONSTRUCTING THE GOOGLE MOBILITY DATA   
			*************************************************************							

			** Google COVID-19 Community Mobility data -- Mali
			
			* Import data
			import delimited "$dataWorkFolder/COVID and Food Security/Google_Mobility_Report.csv", encoding(ISO-8859-1) clear
			split date, p("/")
			rename date1 month
			rename date2 day
			rename date3 year
			destring day, gen(day_nostring)
			gen str3 day_pad = string(day_nostring, "%02.0f")
			egen time = concat(month day_pad)
			encode time, gen(time_id)
			gen bamako = 1 if metro_area=="Bamako Metropolitan Area"
			replace bamako = 0 if metro_area==""
			* Rename
			rename retail_and_recreation_percent_ch retail_rec
			rename grocery_and_pharmacy_percent_cha grocery_phar
			rename parks_percent_change_from_baseli parks
			rename transit_stations_percent_change_ transit
			rename workplaces_percent_change_from_b workplaces
			rename residential_percent_change_from_ residential
			* Drop useless variables
			drop country_region_code country_region sub_region_1 sub_region_2 ///
			metro_area iso_3166_2_code census_fips_code date month day day_nostring year day_pad time
			* Reshape
			reshape wide retail_rec grocery_phar parks transit workplaces residential, i(time_id) j(bamako)
			* Rename
			rename retail_rec0 retail_rec
			rename grocery_phar0 grocery_phar
			rename parks0 parks
			rename transit0 transit
			rename workplaces0 workplaces
			rename residential0 residential
			* More renaming 
			rename retail_rec1 retail_rec_bamako
			rename grocery_phar1 grocery_phar_bamako
			rename parks1 parks_bamako
			rename transit1 transit_bamako
			rename workplaces1 workplaces_bamako
			rename residential1 residential_bamako
			
			save "$dataWorkFolder/COVID and Food Security/Google_Mobility_Report.dta", replace
			

			
			
***********************************************************************************************************************




			* PART 3: IMPORTING AND CONSTRUCTING THE COVID ADMIN DATA   
			*********************************************************			
			
			** Mali COVID data (via HDX)
			* Import data
			import delimited "$dataWorkFolder/COVID and Food Security/mli_covid-19_Data.xlsx - mli covid-19 data.csv", encoding(ISO-8859-1) clear
			drop sumofnombrecontact v7
			split date, p("-")
			rename date1 day
			rename date2 month
			replace month="03" if month=="mars"
			replace month="04" if month=="avr"
			replace month="05" if month=="mai"
			replace month="06" if month=="juin"
			replace month="07" if month=="juil"
			egen time = concat(month day)
			encode time, gen(time_id)
			* drop useless variables
			drop date admin2 day month time
			* collapse to duplicates
			collapse (sum) infected killed recovered, by(time_id admin1)
			* Reshape
			encode admin1, gen(admin_id) // Bamako==1 Sikasso==8 Segou==7
			drop admin1
			reshape wide infected killed recovered, i(time_id) j(admin_id) 
			* clean
			forvalues i = 1/9	{
			replace infected`i' = 0 if infected`i'==.
			replace killed`i' = 0 if killed`i'==.
			replace recovered`i' = 0 if recovered`i'==.
			}
			* generate Mali total variables
			gen infectedMali = infected1 + infected2 + infected3 + infected4 + infected5 + infected6 + infected7 + infected8 + infected8
			gen killedMali = killed1 + killed2 + killed3 + killed4 + killed5 + killed6 + killed7 + killed8 + killed9
			gen recoveredMali = recovered1 + recovered2 + recovered3 + recovered4 + recovered5 + recovered6 + recovered7 + recovered8 + recovered9
			
			tsset time_id
			gen infectedBamako_ma = (F3.infected1 + F2.infected1 + F1.infected1 + infected1 + L1.infected1 + L2.infected1 + L3.infected1) / 7
			gen infectedMali_ma = (F3.infectedMali + F2.infectedMali + F1.infectedMali + infectedMali + L1.infectedMali + L2.infectedMali + L3.infectedMali) / 7
			gen infectedSegou_ma = (F3.infected7 + F2.infected7 + F1.infected7 + infected7 + L1.infected7 + L2.infected7 + L3.infected7) / 7
			gen infectedSikasso_ma = (F3.infected8 + F2.infected8 + F1.infected8 + infected8 + L1.infected8 + L2.infected8 + L3.infected8) / 7
			
			
			gen killedBamako_ma = (F3.killed1 + F2.killed1 + F1.killed1 + killed1 + L1.killed1 + L2.killed1 + L3.killed1) / 7
			gen killedMali_ma = (F3.killedMali + F2.killedMali + F1.killedMali + killedMali + L1.killedMali + L2.killedMali + L3.killedMali) / 7
			gen killedSegou_ma = (F3.killed7 + F2.killed7 + F1.killed7 + killed7 + L1.killed7 + L2.killed7 + L3.killed7) / 7
			gen killedSikasso_ma = (F3.killed8 + F2.killed8 + F1.killed8 + killed8 + L1.killed8 + L2.killed8 + L3.killed8) / 7
			
			
			save "$dataWorkFolder/COVID and Food Security/mli_covid-19_Data.xlsx - mli covid-19 data.dta", replace
			
			
			

			
		

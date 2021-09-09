


		************************************************
		*											   *
		*											   *
		*       COVID 19 DATA ANALYSIS IN MALI 		   *
		*											   *
		*											   *
		************************************************





			* PART 1: DESCRIPTIVE ANALYSIS
			******************************

	clear all
			
		*** Mali ***
		
		use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear


		** Descriptive Results (Table A1)

	iebaltab ///
				fs1_noreplace fs1_covid_noreplace fs2_noreplace fs2_covid_noreplace ///
				fs3_noreplace fs3_covid_noreplace fs4_noreplace fs4_covid_noreplace  ///
				fs5_noreplace fs5_covid_noreplace fs6_noreplace fs6_covid_noreplace ///
				fs7_noreplace fs7_covid_noreplace fs8_noreplace fs8_covid_noreplace [pweight=hhweight_covid] if post==1,   ///
				grpvar(urban) order(1 0)   grplabels(1 "Urban" @ 0 "Rural")            ///
				vce(cluster cluster) 										///
				savetex("$dataWorkFolder/COVID and Food Security/Outputs/delete_me.tex")  ///
				texnotewidth(1.6)                         ///
				total rowvarlabels pftest     ///
				tblnonote ///
				tblnote("These descriptive statistics come from the World Banks's COVID-19 high frequency survey from Mali."  ///
				"Missing and refused responses are excluded from these statistics. Standard errors clustered at the sampling cluster level. ***, **, and * indicate statistical significance at the 1, 5, and 10 percent critical level.") ///
				replace

	filefilter "$dataWorkFolder/COVID and Food Security/Outputs/delete_me.tex"   ///
						 "$dataWorkFolder/COVID and Food Security/Outputs/foodsecurity_summarystats_R1.tex",  ///
						 from("/BShline") to("/BScline{1-8}") ///
						 replace
			
				

		** Descriptive Results (Figure 1)

		use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear		
		
		* Relabeling
			label var fs1_covid_noreplace "COVID-19?**"
			label var fs2_covid_noreplace "COVID-19?***"
			label var fs3_covid_noreplace "COVID-19?***"
			label var fs4_covid_noreplace "COVID-19?"
			label var fs5_covid_noreplace "COVID-19?**"
			label var fs6_covid_noreplace "COVID-19?"
			label var fs7_covid_noreplace "COVID-19?"
			label var fs8_covid_noreplace "COVID-19?"

		* More relabling
			label var fs1_noreplace "FS1"
			label var fs2_noreplace "FS2"
			label var fs3_noreplace "FS3"
			label var fs4_noreplace "FS4"
			label var fs5_noreplace "FS5"
			label var fs6_noreplace "FS6"
			label var fs7_noreplace "FS7"
			label var fs8_noreplace "FS8"

		* Generate graphs
		
				forvalues i=1/8 {
				betterbar fs`i'_covid_noreplace fs`i'_noreplace [pweight=hhweight_covid] if post==1, barlab over(urban) scheme(538bw) barcolor(black gray) vce(cluster cluster) vertical
					graph save "$dataWorkFolder/COVID and Food Security/Outputs/fs`i'1_bar", replace
	}
*
						
		* Combine graphs together
			grc1leg "$dataWorkFolder/COVID and Food Security/Outputs/fs11_bar" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/fs21_bar" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/fs31_bar" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/fs41_bar" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/fs51_bar" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/fs61_bar" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/fs71_bar" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/fs81_bar", cols(4) ycommon scheme(538bw)
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/descriptive_results_R1.png", replace
				

		*** ERS Chart of Note
		
		* Relabeling
			label var fs1_covid_noreplace "FIES 1: Was this due to COVID-19?"
			label var fs2_covid_noreplace "FIES 2: Was this due to COVID-19?"
			label var fs3_covid_noreplace "FIES 3: Was this due to COVID-19?"
			label var fs4_covid_noreplace "FIES 4: Was this due to COVID-19?"
			label var fs5_covid_noreplace "FIES 5: Was this due to COVID-19?"
			label var fs6_covid_noreplace "FIES 6: Was this due to COVID-19?"
			label var fs7_covid_noreplace "FIES 7: Was this due to COVID-19?"
			label var fs8_covid_noreplace "FIES 8: Was this due to COVID-19?"

		* More relabling
			label var fs1_noreplace "FIES 1: Worried will not have enough to eat"
			label var fs2_noreplace "FIES 2: Worried will not eat nutritious food"
			label var fs3_noreplace "FIES 3: Always eat the same thing"
			label var fs4_noreplace "FIES 4: Had to skip a meal"
			label var fs5_noreplace "FIES 5: Had to eat less than they should"
			label var fs6_noreplace "FIES 6: Found nothing to eat at home"
			label var fs7_noreplace "FIES 7: Hungry but did not eat"
			label var fs8_noreplace "FIES 8: Have not eaten all day"
			
			betterbar fs1_noreplace fs2_noreplace fs3_noreplace fs4_noreplace ///
			fs5_noreplace fs6_noreplace fs7_noreplace fs8_noreplace if post==1, ///
			scheme(538bw) barcolor(dkgreen) leg(off)
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/fies", replace
			
			betterbar fs1_covid_noreplace fs2_covid_noreplace fs3_covid_noreplace fs4_covid_noreplace ///
			fs5_covid_noreplace fs6_covid_noreplace fs7_covid_noreplace fs8_covid_noreplace if post==1, ///
			scheme(538bw) barcolor(dkgreen) leg(off)
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/fies_covid", replace
			
			graph combine "$dataWorkFolder/COVID and Food Security/Outputs/fies" ///
			"$dataWorkFolder/COVID and Food Security/Outputs/fies_covid", cols(2) scheme(538bw) xcommon
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/ers_con.png", replace
				
		* Changes in food security incidence before to after COVID-19 in CHAD
		
		use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear
		

		

		betterbar std_fs_index [pweight=hhweight_covid], over(urban) by(post) ci v barlab scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.2f) title (Food security in rural and urban areas of MALI before and after COVID-19)
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/Mali_fs_index_change.png", replace

		betterbar mild_fs [pweight=hhweight_covid], over(urban) by(post) ci v barlab scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.0gc) title (Food insecurity rates in rural and urban areas of MALI before and after COVID-19)

		betterbar moderate_fs [pweight=hhweight_covid], over(urban) by(post) ci v barlab scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.0gc)
		
		betterbar severe_fs [pweight=hhweight_covid], over(urban) by(post) ci v barlab scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.0gc)
			
			
		betterbar anxiety [pweight=hhweight_covid], over(urban) by(post) ci v barlab scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.2f)
								
		betterbar meal_reduction [pweight=hhweight_covid], over(urban) by(post) ci v barlab scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.2f)

		betterbar hunger [pweight=hhweight_covid], over(urban) by(post) ci v barlab scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.2f)
				
				
			** Google COVID-19 Community Mobility data -- Mali
			
			use "$dataWorkFolder/COVID and Food Security/Google_Mobility_Report.dta", clear
			
			* Generate graphs
			line grocery_phar_bamako grocery_phar time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Mali")) ///
				ytitle("Percent Change") ///
				title("Grocery and Pharmacy") ///
				xtitle("Date") xlabel(1 "2/15" 30 "3/15" 61 "4/15" 91 "5/15" 122 "6/16" 152 "7/15")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/google_grocery", replace
			
			line retail_rec_bamako retail_rec time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Mali")) ///
				ytitle("Percent Change") ///
				title("Retail and Recreation") ///
				xtitle("Date") xlabel(1 "2/15" 30 "3/15" 61 "4/15" 91 "5/15" 122 "6/16" 152 "7/15")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/google_retail", replace
			
			line parks_bamako parks time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Mali")) ///
				ytitle("Percent Change") ///
				title("Parks") ///
				xtitle("Date") xlabel(1 "2/15" 30 "3/15" 61 "4/15" 91 "5/15" 122 "6/16" 152 "7/15")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/google_parks", replace
			
			line transit_bamako transit time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Mali")) ///
				ytitle("Percent Change")  ///
				title("Transportation Stations") ///
				xtitle("Date") xlabel(1 "2/15" 30 "3/15" 61 "4/15" 91 "5/15" 122 "6/16" 152 "7/15")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/google_transit", replace
			
			line workplaces_bamako workplaces time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Mali")) ///
				ytitle("Percent Change")  ///
				title("Workplaces") ///
				xtitle("Date") xlabel(1 "2/15" 30 "3/15" 61 "4/15" 91 "5/15" 122 "6/16" 152 "7/15")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/google_workplaces", replace
			
			line residential_bamako residential time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Mali")) ///
				ytitle("Percent Change") ///
				title("Residential") ///
				xtitle("Date") xlabel(1 "2/15" 30 "3/15" 61 "4/15" 91 "5/15" 122 "6/16" 152 "7/15")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/google_residential", replace
			
			* Combine graphs together
			grc1leg "$dataWorkFolder/COVID and Food Security/Outputs/google_grocery" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/google_retail" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/google_parks" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/google_transit" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/google_workplaces" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/google_residential", cols(2) ycommon scheme(538bw)
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/google_mobility_results.png", replace

			
			
			
			
			
			
			** Mali COVID data (via HDX)
			* Import data

			use "$dataWorkFolder/COVID and Food Security/mli_covid-19_Data.xlsx - mli covid-19 data.dta", clear
			
			
			line infectedBamako_ma infectedSikasso_ma infectedSegou_ma infectedMali_ma time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Sikasso") label(3 "Segou") label(4 "Mali")) ///
				ytitle("Infection Count")  ///
				title("") ///
				xtitle("Date") xlabel(8 "4/1" 38 "5/1" 69 "6/1" 99 "7/1")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/covid_infections", replace
				
			line killedBamako_ma killedSikasso_ma killedSegou_ma killedMali_ma time_id, scheme(538bw) ///
				lcolor(black gray) legend(label(1 "Bamako") label(2 "Sikasso") label(3 "Segou") label(4 "Mali")) ///
				ytitle("Death Count")  ///
				title("") ///
				xtitle("Date") xlabel(8 "4/1" 38 "5/1" 69 "6/1" 99 "7/1")
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/covid_deaths", replace
			
			* Combine graphs together
			grc1leg "$dataWorkFolder/COVID and Food Security/Outputs/covid_infections" ///
				"$dataWorkFolder/COVID and Food Security/Outputs/covid_deaths", cols(2) scheme(538bw)
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/covid_trends.png", replace		
			
			
			

			

	** COVID Awareness, Beliefs, and Behaviors (Figure 3 and Table A3)
	
		use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear
	
		iebaltab ///
				heard_cov rec_info sat_gov cov_1 cov_2 cov_3 cov_4 cov_5 cov_6 cov_7 [pweight=hhweight_covid] if post==1,   ///
				grpvar(urban) order(1 0)   grplabels(1 "Urban" @ 0 "Rural")            ///
				vce(cluster cluster) 										///
				savetex("$dataWorkFolder/COVID and Food Security/Outputs/delete_me.tex")  ///
				texnotewidth(1.5)                         ///
				total rowvarlabels pftest     ///
				tblnonote ///
				tblnote("These descriptive statistics come from the World Banks's COVID-19 high frequency survey from Mali."  ///
				"Missing and refused responses are excluded from these statistics. Standard errors clustered at the sampling cluster level. ***, **, and * indicate statistical significance at the 1, 5, and 10 percent critical level.") ///
				replace

	filefilter "$dataWorkFolder/COVID and Food Security/Outputs/delete_me.tex"   ///
						 "$dataWorkFolder/COVID and Food Security/Outputs/covid_beliefs_behave.tex",  ///
						 from("/BShline") to("/BScline{1-8}") ///
						 replace
						 
		* some relabeling
			label var heard_cov "Have you heard of coronavirus?"
			label var rec_info "Have you received information about social distancing and self-isolation measures?"
			label var sat_gov "Are you satisfied with the government's response to the coronavirus?***"
			label var cov_1 "Last week, did you wash your hands more often than usual?***"
			label var cov_2 "Last week, did you avoid greetings with physical contact?***"
			label var cov_3 "Last week, did you avoid gatherings of more than 10 people?**"
			label var cov_4 "Last week, did you cancel any travel plans?"
			label var cov_5 "Last week, did you stockpile more food than usual?"
			label var cov_6 "Last week, did you reduce the number of times you went to the market or grocerty store?"
			label var cov_7 "Last week, did you reduce the number of times you went to a place of worship?"

		* Generate graph
			betterbar heard_cov rec_info sat_gov cov_1 cov_2 cov_3 cov_4 cov_5 cov_6 cov_7 [pweight=hhweight_covid], barlab over(urban) scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%4.0gc)
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/covid_beliefs_behave.png", replace

		** Self-reported COVID Impacts 
		
		iebaltab ///
			risk_lose_income_yn lost_job lost_income cov_impact_rent ///
			cov_impact_food cov_impact_wa_el cov_impact_save cov_impact_invest [pweight=hhweight_covid] if post==1, ///
			grpvar(urban) order(1 0)   grplabels(1 "Urban" @ 0 "Rural")            ///
				vce(cluster cluster) 										///
				savetex("$dataWorkFolder/COVID and Food Security/Outputs/delete_me.tex")  ///
				texnotewidth(1.33)                         ///
				total rowvarlabels pftest     ///
				tblnonote ///
				tblnote("These descriptive statistics come from the World Banks's COVID-19 high frequency survey from Mali."  ///
				"Missing and refused responses are excluded from these statistics. Standard errors clustered at the sampling cluster level. ***, **, and * indicate statistical significance at the 1, 5, and 10 percent critical level.") ///
				replace

	filefilter "$dataWorkFolder/COVID and Food Security/Outputs/delete_me.tex"   ///
						 "$dataWorkFolder/COVID and Food Security/Outputs/covid_impacts.tex",  ///
						 from("/BShline") to("/BScline{1-8}") ///
						 replace
			
		
		* some relabeling - "My household ... "
			label var risk_lose_income_yn "My household is at risk of losing income due to the pandemic."
			label var lost_job "A household member has lost a job due to the pandemic."
			label var lost_income "My household has lost income due to the pandemic."
			label var cov_impact_rent "My household struggles to pay rent due to the pandemic.***"
			label var cov_impact_food "My household struggles to buy food due to the pandemic."
			label var cov_impact_wa_el "My household stuggles to access water/electricity due to the pandemic.***"
			label var cov_impact_save "My household reduced saving due to the pandemic.**"
			label var cov_impact_invest "My household reduced investment due to the pandemic.*"
		
		* Generate graph
			betterbar risk_lose_income_yn lost_job lost_income cov_impact_rent ///
			cov_impact_food cov_impact_wa_el cov_impact_save cov_impact_invest [pweight=hhweight_covid], ///
			barlab over(urban) scheme(538bw) barcolor(black gray) vce(cluster cluster) legend(position(6)) format(%12.2f) 
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/covid_impacts.png", replace
			
		
		** Baseline outcomes
		
		use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear

		* some relabeling
		
			label var std_fs_index_wt "Standardized Raw FIES Score"
			label var mild_fs "Mild Food Insecurity"
			label var moderate_fs "Moderate Food Insecurity"
			label var severe_fs "Severe Food Insecurity"
		
		* Generate graph (baseline)
			betterbar severe_fs moderate_fs mild_fs if post==0 [pweight=hhweight_covid], ///
			barlab over(urban) scheme(538bw) vertical barcolor(black gray) ///
			vce(cluster cluster) legend(position(6)) format(%12.2f) ytitle(Percent) title(Pre-Pandemic, position(12))
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/baseline_means.gph", replace
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/baseline_means.png", replace
			
		* Generate graph (follow-up)
			betterbar severe_fs moderate_fs mild_fs if post==1 [pweight=hhweight_covid], ///
			barlab over(urban) scheme(538bw) vertical barcolor(black gray) ///
			vce(cluster cluster) legend(position(6)) format(%12.2f) ytitle(Percent) title(Three Months Post-Pandemic Onset, position(12))
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/followup_means.gph", replace
			graph export "$dataWorkFolder/COVID and Food Security/Outputs/followup_means.png", replace
			
			grc1leg "$dataWorkFolder/COVID and Food Security/Outputs/baseline_means.gph" ///
			"$dataWorkFolder/COVID and Food Security/Outputs/followup_means.gph", scheme(538bw) ycommon ///
			cols(1) 
			graph save "$dataWorkFolder/COVID and Food Security/Outputs/ERS_AW_figure.eps", replace
		
				
				
********************************************************************************************************************************************************************************				
				
				
	
				
			* PART 2: ECONOMETRIC ANALYSIS
			******************************							

	** Core results one table
			
			* Raw FIES Score
			
			use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear
	
			svyset, clear
			svyset s00q06 [pweight=hhweight_covid]
			
			eststo clear
			
			** First-Difference
			reg std_fs_index_wt i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index_wt i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg std_fs_index_wt i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index_wt i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg std_fs_index_wt i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_5
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index_wt i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_6
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			esttab  std_fs_index_1 std_fs_index_2 std_fs_index_3 std_fs_index_4 std_fs_index_5 std_fs_index_6 ///
					using "$dataWorkFolder/COVID and Food Security/Outputs/Core_results.tex", ///
					refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel A: Standardized Raw FIES Score}} \\ [-1ex] ", nolabel) ///
					prehead("\begin{tabular}{l*{7}{c}} \hline \hline \\"                ///
					"& \multicolumn{2}{c}{First-Difference} & \multicolumn{2}{c}{Urban-Rural DID} & \multicolumn{2}{c}{Bamako-Else DID} \\"   ///
					"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \\")  ///
					nomtitles nonumbers nolines noomit nobase drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01) ///
					scalars("C_mean Baseline Mean") sfmt(2) ///
					label se noobs  fragment            ///
					replace			
					

			* Mild food insecurity
			*eststo clear

			** First-Difference
			reg mild_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg mild_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg mild_fs i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_5
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_6
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			/* esttab  mild_fs_1 mild_fs_2 mild_fs_3 mild_fs_4 ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonbamako.tex", ///
			refcat(1.post "\\ \multicolumn{5}{c}{\textbf{Panel B: Mild Food Insecurity (Raw Score $>0$}} \\ [-1ex] ", nolabel) ///
			prehead("\begin{tabular}{l*{5}{c}} \hline \hline \\"                ///
			"& \multicolumn{2}{c}{First-Difference} & \multicolumn{2}{c}{Urban-Rural DID} \\"   ///
			"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \\")  ///
			nomtitles nonumbers nolines noomit nobase drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01) ///
			scalars("C_mean Baseline Mean") sfmt(2) ///
			label se noobs  fragment            ///
			replace	 */

			
			esttab  mild_fs_1 mild_fs_2 mild_fs_3 mild_fs_4 mild_fs_5 mild_fs_6 ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Core_results.tex", ///
			refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel B: Mild Food Insecurity (Raw Score $>0$)}} \\ [-1ex] ", nolabel) ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("C_mean Baseline Mean") sfmt(2) 
			*postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")			
						

			* Moderate food insecurity
			*eststo clear

			** First-Difference
			reg moderate_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg moderate_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg moderate_fs i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_5
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_6
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			esttab  moderate_fs_1 moderate_fs_2 moderate_fs_3 moderate_fs_4 moderate_fs_5 moderate_fs_6         ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Core_results.tex", ///
			refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel C: Moderate Food Insecurity (Raw Score $>3$)}} \\[-1ex] ", nolabel)  ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("C_mean Baseline Mean") sfmt(2) 
			*postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")
			
			
			
			* Severe food insecurity
			*eststo clear

			** First-Difference
			reg severe_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg severe_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg severe_fs i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_5
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_6
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			esttab  severe_fs_1 severe_fs_2 severe_fs_3 severe_fs_4 severe_fs_5 severe_fs_6          ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Core_results.tex", ///
			refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel D: Severe Food Insecurity (Raw Score $>7$)}} \\[-1ex] ", nolabel)  ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label   eqlabels(none)   ///
			drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("FE Household FEs" "Missing Missing Control" "C_mean Baseline Mean") sfmt(2) ///
			postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")
			

			
		***** Robustness checks
		
			** Raw Score NOT STANDARDIZED
		
			use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear
	
			svyset, clear
			svyset s00q06 [pweight=hhweight_covid]
			
			eststo clear

			** First-Difference
			reg fs_index i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pw=hhweight_covid], cluster(cluster)
			eststo  fs_index_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ fs_index if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg fs_index i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  fs_index_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ fs_index if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			** Difference-in-Difference (Post x Urban)
			reg fs_index i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  fs_index_3
			estadd local FE  		"No"
			estadd local Missing  	"Yes"
					summ fs_index if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg fs_index i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  fs_index_4
			estadd local FE  		"Yes"
			estadd local Missing    "Yes"
					summ fs_index if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg fs_index i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  fs_index_5
			estadd local FE  		"No"
			estadd local Missing    "Yes"
					summ fs_index if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			areg fs_index i.post##i.bamako fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  fs_index_6
			estadd local FE  		"Yes"
			estadd local Missing 	"Yes"
					summ fs_index if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
								
			esttab  ///
						using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonstd.tex", ///
						prehead("\begin{tabular}{l*{7}{c}} \hline \hline \\ & (1) & (2) & (3) & (4) & (5) & (6) \\ & \multicolumn{2}{c}{First-Difference} & \multicolumn{2}{c}{Urban-Rural DID} & \multicolumn{2}{c}{Bamako-Else DID} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \\")  ///
						nomtitles nonumbers noomit nonotes nobase drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01) ///
						scalars("FE Household FEs" "Missing Missing Control" "C_mean Baseline Mean") sfmt(2) ///
						label se r2 constant                        ///
						replace
						
						*addnotes("\textit{Notes:} The outcome variable is the raw score of the Food Insecurity Experience Scale (FIES)" "standardized to have a mean of zero and standard deviation of one in each period. Standard errors" "clustered at the sampling cluster level *** p$<$0.01, ** p$<$0.05, * p$<$0.1.")    ///

						
						
			** Urban defined not including Bamako (this excludes Bamako households from the analysis alltogether)
		
			* Raw FIES Score
			
			use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear
	
			svyset, clear
			svyset s00q06 [pweight=hhweight_covid]
			
			eststo clear
						
			drop if bamako==1

			** First-Difference
			reg std_fs_index i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ std_fs_index if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fs_index if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban not including Bamako)
			reg std_fs_index i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ std_fs_index if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ std_fs_index if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			esttab  std_fs_index_1 std_fs_index_2 std_fs_index_3 std_fs_index_4 ///
					using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonbamako.tex", ///
					refcat(1.post "\\ \multicolumn{5}{c}{\textbf{Panel A: Standardized Raw FIES Score}} \\ [-1ex] ", nolabel) ///
					prehead("\begin{tabular}{l*{5}{c}} \hline \hline \\"                ///
					"& \multicolumn{2}{c}{First-Difference} & \multicolumn{2}{c}{Urban-Rural DID} \\"   ///
					"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \\")  ///
					nomtitles nonumbers nolines noomit nobase drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01) ///
					scalars("C_mean Baseline Mean") sfmt(2) ///
					label se noobs  fragment            ///
					replace			
					

			* Mild food insecurity
			*eststo clear

			** First-Difference
			reg mild_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg mild_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ mild_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			/* esttab  mild_fs_1 mild_fs_2 mild_fs_3 mild_fs_4 ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonbamako.tex", ///
			refcat(1.post "\\ \multicolumn{5}{c}{\textbf{Panel B: Mild Food Insecurity (Raw Score $>0$}} \\ [-1ex] ", nolabel) ///
			prehead("\begin{tabular}{l*{5}{c}} \hline \hline \\"                ///
			"& \multicolumn{2}{c}{First-Difference} & \multicolumn{2}{c}{Urban-Rural DID} \\"   ///
			"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \\")  ///
			nomtitles nonumbers nolines noomit nobase drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01) ///
			scalars("C_mean Baseline Mean") sfmt(2) ///
			label se noobs  fragment            ///
			replace	 */

			
			esttab  mild_fs_1 mild_fs_2 mild_fs_3 mild_fs_4 ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonbamako.tex", ///
			refcat(1.post "\\ \multicolumn{5}{c}{\textbf{Panel B: Mild Food Insecurity (Raw Score $>0$)}} \\ [-1ex] ", nolabel) ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("C_mean Baseline Mean") sfmt(2) 
			*postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")			
						

			* Moderate food insecurity
			*eststo clear

			** First-Difference
			reg moderate_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg moderate_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ moderate_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			esttab  moderate_fs_1 moderate_fs_2 moderate_fs_3 moderate_fs_4          ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonbamako.tex", ///
			refcat(1.post "\\ \multicolumn{5}{c}{\textbf{Panel C: Moderate Food Insecurity (Raw Score $>3$)}} \\[-1ex] ", nolabel)  ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("C_mean Baseline Mean") sfmt(2) 
			*postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")
			
			
			
			* Severe food insecurity
			*eststo clear

			** First-Difference
			reg severe_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_1
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_2
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg severe_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_3
			estadd local FE  		"No"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post##i.urban fs1_missing fs2_missing fs3_missing fs4_missing fs5_missing ///
			fs6_missing fs7_missing fs8_missing if bamako==0 [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_4
			estadd local FE  		"Yes"
			estadd local Missing      "Yes"
					summ severe_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			esttab  severe_fs_1 severe_fs_2 severe_fs_3 severe_fs_4          ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonbamako.tex", ///
			refcat(1.post "\\ \multicolumn{5}{c}{\textbf{Panel D: Severe Food Insecurity (Raw Score $>7$)}} \\[-1ex] ", nolabel)  ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("FE Household FEs" "Missing Missing Control" "C_mean Baseline Mean") sfmt(2) ///
			postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")
			
			
		** Core results one table (not controlling for missings)
			
			
			use "$dataWorkFolder/COVID and Food Security/COVID 19 DATA ANALYSIS IN MALI_food security.dta", clear
	
			svyset, clear
			svyset s00q06 [pweight=hhweight_covid]
			
			eststo clear			
			
			* Raw FIES Score

			** First-Difference
			reg std_fs_index_wt i.post [pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_1
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index_wt i.post [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_2
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg std_fs_index_wt i.post##i.urban [pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_3
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index_wt i.post##i.urban [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_4
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg std_fs_index_wt i.post##i.bamako[pweight=hhweight_covid], cluster(cluster)
			eststo  std_fs_index_5
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg std_fs_index_wt i.post##i.bamako[pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  std_fs_index_6
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ std_fs_index_wt if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			esttab  std_fs_index_1 std_fs_index_2 std_fs_index_3 std_fs_index_4 std_fs_index_5 std_fs_index_6 ///
					using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nomissings.tex", ///
					refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel A: Standardized Raw FIES Score}} \\ [-1ex] ", nolabel) ///
					prehead("\begin{tabular}{l*{7}{c}} \hline \hline \\"                ///
					"& \multicolumn{2}{c}{First-Difference} & \multicolumn{2}{c}{Urban-Rural DID} & \multicolumn{2}{c}{Bamako-Else DID} \\"   ///
					"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \\")  ///
					nomtitles nonumbers nolines noomit nobase drop(_cons) star(* 0.10 ** 0.05 *** 0.01) ///
					scalars("C_mean Baseline Mean") sfmt(2) ///
					label se noobs  fragment            ///
					replace			
					

			* Mild food insecurity
			*eststo clear

			** First-Difference
			reg mild_fs i.post [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_1
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ mild_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_2
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ mild_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg mild_fs i.post##i.urban [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_3
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ mild_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post##i.urban  [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_4
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ mild_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg mild_fs i.post##i.bamako [pweight=hhweight_covid], cluster(cluster)
			eststo  mild_fs_5
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ mild_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg mild_fs i.post##i.bamako [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  mild_fs_6
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ mild_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			/* esttab  mild_fs_1 mild_fs_2 mild_fs_3 mild_fs_4 ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nonbamako.tex", ///
			refcat(1.post "\\ \multicolumn{5}{c}{\textbf{Panel B: Mild Food Insecurity (Raw Score $>0$}} \\ [-1ex] ", nolabel) ///
			prehead("\begin{tabular}{l*{5}{c}} \hline \hline \\"                ///
			"& \multicolumn{2}{c}{First-Difference} & \multicolumn{2}{c}{Urban-Rural DID} \\"   ///
			"\cmidrule(lr){2-3} \cmidrule(lr){4-5} \\")  ///
			nomtitles nonumbers nolines noomit nobase drop(_cons *_missing) star(* 0.10 ** 0.05 *** 0.01) ///
			scalars("C_mean Baseline Mean") sfmt(2) ///
			label se noobs  fragment            ///
			replace	 */

			
			esttab  mild_fs_1 mild_fs_2 mild_fs_3 mild_fs_4 mild_fs_5 mild_fs_6 ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nomissings.tex", ///
			refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel B: Mild Food Insecurity (Raw Score $>0$)}} \\ [-1ex] ", nolabel) ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("C_mean Baseline Mean") sfmt(2) 
			*postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")			
						

			* Moderate food insecurity
			*eststo clear

			** First-Difference
			reg moderate_fs i.post [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_1
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ moderate_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_2
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ moderate_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg moderate_fs i.post##i.urban [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_3
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ moderate_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post##i.urban  [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_4
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ moderate_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg moderate_fs i.post##i.bamako [pweight=hhweight_covid], cluster(cluster)
			eststo  moderate_fs_5
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ moderate_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg moderate_fs i.post##i.bamako [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  moderate_fs_6
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ moderate_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			esttab  moderate_fs_1 moderate_fs_2 moderate_fs_3 moderate_fs_4 moderate_fs_5 moderate_fs_6         ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nomissings.tex", ///
			refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel C: Moderate Food Insecurity (Raw Score $>3$)}} \\[-1ex] ", nolabel)  ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("C_mean Baseline Mean") sfmt(2) 
			*postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")
			
			
			
			* Severe food insecurity
			*eststo clear

			** First-Difference
			reg severe_fs i.post [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_1
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ severe_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_2
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ severe_fs if post==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)


			** Difference-in-Difference (Post x Urban)
			reg severe_fs i.post##i.urban [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_3
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ severe_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post##i.urban [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_4
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ severe_fs if post==0 & urban==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			** Difference-in-Difference (Post x Bamako)
			reg severe_fs i.post##i.bamako [pweight=hhweight_covid], cluster(cluster)
			eststo  severe_fs_5
			estadd local FE  		"No"
			*estadd local Missing      "Yes"
					summ severe_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)

			areg severe_fs i.post##i.bamako [pweight=hhweight_covid], absorb(hhid) cluster(cluster)
			eststo  severe_fs_6
			estadd local FE  		"Yes"
			*estadd local Missing      "Yes"
					summ severe_fs if post==0 & bamako==0 [aweight=hhweight_covid]
					estadd scalar C_mean = r(mean)
					
			esttab  severe_fs_1 severe_fs_2 severe_fs_3 severe_fs_4 severe_fs_5 severe_fs_6          ///
			using "$dataWorkFolder/COVID and Food Security/Outputs/Robustness_nomissings.tex", ///
			refcat(1.post "\\ \multicolumn{7}{c}{\textbf{Panel D: Severe Food Insecurity (Raw Score $>7$)}} \\[-1ex] ", nolabel)  ///
			fragment append  nomtitle nonumbers noomit nolines unstack se label  noobs eqlabels(none)   ///
			drop(_cons) star(* 0.10 ** 0.05 *** 0.01)  nobase ///
			scalars("FE Household FEs" "Missing Missing Control" "C_mean Baseline Mean") sfmt(2) ///
			postfoot("\\ \hline \hline \\[-1.8ex]	 \end{tabular}")
			
						


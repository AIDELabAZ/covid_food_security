


		************************************************
		*											   *
		*											   *
		*       COVID 19 DATA CLEANING IN MALI 		   *
		*											   *
		*											   *
		************************************************



			* PART 1: IMPORTING AND CLEANING THE LSMS AND THE COVID HIGH FREQUENCY SURVEY DATA   
			**********************************************************************************



	* MALI DATA CLEANING

	* First, open and run the Project MasterDofile.do then run the following 2 lines of codes



	* Calling for files from the latest 2018 Mali UEMOA survey round

		*  first run MaliEHCVM2018_MasterDofile.do then call for the file you want from the Deidentified data subfolder

				do "$MaliEHCVM2018/MaliEHCVM2018_MasterDofile.do"



		* Load LSMS data file (this one is section 8A on food security)
			use "$MaliEHCVM2018_dtDeID/s08a_me_MLI2018.dta", clear
			
			merge 1:1 hhid using "$MaliEHCVM2018_dtDeID/s00_me_MLI2018.dta"
			drop _merge

			save "$MaliEHCVM2018_dtInt/s08a_me_MLI2018_cleaned.dta", replace


		* Load LSMS data module on agricultural production and commercialization
			use "$MaliEHCVM2018_dtDeID/s16c_me_MLI2018.dta", clear
				gen s16aq02=s16cq02 
				gen s16aq03=s16cq03				
			merge m:1 hhid s16aq02 s16aq03 using "$MaliEHCVM2018_dtDeID/s16a_me_MLI2018.dta"			
			drop _merge	
			
			merge m:1 hhid using "$MaliEHCVM2018_dtInt/s08a_me_MLI2018_cleaned.dta", keepusing(hhid vague)
			generate FARMERS=_merge==3
			drop _merge	
			
			
			tab s16cq04, mis gen(CROP)
			
			collapse (max) CROP* ,  ///
			by (hhid grappe s00q00 s00q01 s00q02 s00q04 s00q06 s00q07 FARMERS)
			
			save "$MaliEHCVM2018_dtInt/s16c_me_MLI2018_cleaned.dta", replace


	* Calling for files from the COVID survey

		*  first run MaliCOVID_Round1_MasterDofile.do then call for the file you want from the Deidentified data subfolder

				do "$MaliCOVID_R1/MaliCOVID_Round1_MasterDofile.do"

		* load the Mali covid round1 data
		
			* Pull hh sampling weight from "new" data file
			use "$MaliCOVID_R1_dtDeID/New/round1_s02_connaissances_covid.dta", clear
			keep hhweight_covid hhid p0
			save "$MaliCOVID_R1_dtDeID/New/sampling_wieght.dta", replace
			
			* Use our full round 1 data set
			use "$MaliCOVID_R1_dtDeID/COVID_19_Mali.dta", clear

			duplicates tag hhid, gen(dup_hhid)
			drop if dup_hhid==1 & result!=1 // drop incomplete duplicates
			
			merge 1:1 hhid using "$MaliCOVID_R1_dtDeID/New/sampling_wieght.dta"
			drop _merge

			save "$MaliCOVID_R1_dtInt/COVID_19_Mali_cleaned.dta", replace
			
			
		* load the Mali covid round2 data			
			use "$MaliCOVID_R1_dtDeID/New/round2_s02_connaissances_covid.dta", clear
			merge 1:1 hhid using "$MaliCOVID_R1_dtDeID/New/round2_s03_comportements_covid.dta", gen(_merge1)
			merge 1:1 hhid using "$MaliCOVID_R1_dtDeID/New/round2_s06_insecu_alim.dta", gen(_merge2)
			drop _merge1 _merge2

			duplicates tag hhid, gen(dup_hhid)
			*drop if dup_hhid==1 & result!=1 // drop incomplete duplicates

			save "$MaliCOVID_R1_dtInt/COVID_19_Mali_R2_cleaned.dta", replace			
			

*



***********************************************************************************************************************


			

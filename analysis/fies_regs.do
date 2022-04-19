* Project: COVID Food Security
* Created on: October 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 19 April 2022
* Stata v.17.0

* does
	* reads in cleaned, regression ready data
	* conducts analysis
	* contains unused code for anxiety, hunger, and meals skipped
	* contains correlation checks for ancova

* assumes
	* cleaned fies data file
	* xfill.ado
	* palettes.ado
	* colrspace.ado
	* estout.ado
	* grc1leg2.ado (version 1.6)
	* blindschemes.ado

* TO DO:
	* complete


************************************************************************
**# 0 - setup
************************************************************************

* define
	global  input   =   "$data/analysis/food_security"
	global	tab		=	"$output/tables"
	global	fig		=	"$output/figures"
	global	logout	=	"$data/analysis/food_security/logs"

* open log
	cap log 			close
	log using			"$logout/fies_regs", append
	
	
************************************************************************
**# 1 - initial did analysis
************************************************************************

* read in data
	use				"$input/fies_reg_data", replace
	
* gen y0 and xfill by hhid
	gen 			std_fsi_y0 = std_fsi if wave == 0
	xfill 			std_fsi_y0, i(hhid)
	lab var			std_fsi_y0 "Standardized FIES at baseline"
	
	gen 			std_fsi_wt_y0 = std_fsi_wt if wave == 0
	xfill 			std_fsi_wt_y0, i(hhid)
	lab var			std_fsi_wt_y0 "Standardized FIES at baseline (weighted)"

	gen				mld_fsi_y0 = mld_fsi if wave == 0
	xfill			mld_fsi_y0, i(hhid)
	lab var			mld_fsi_y0 "Mild FIES at baseline"
	
	gen				mod_fsi_y0 = mod_fsi if wave == 0
	xfill			mod_fsi_y0, i(hhid)
	lab var			mod_fsi_y0 "Moderate FIES at baseline"

	gen				sev_fsi_y0 = sev_fsi if wave == 0
	xfill			sev_fsi_y0, i(hhid)
	lab var 		sev_fsi_y0 "Severe FIES at baseline"
	
	gen				anx_fsi_y0 = anx_fsi if wave == 0
	xfill			anx_fsi_y0, i(hhid)
	lab var 		anx_fsi_y0 "Anxious about food security at baseline"
	
	gen				mea_fsi_y0 = mea_fsi if wave == 0
	xfill			mea_fsi_y0, i(hhid)
	lab var 		mea_fsi_y0 "Reduced meals eaten at baseline"

	gen				hun_fsi_y0 = hun_fsi if wave == 0
	xfill			hun_fsi_y0, i(hhid)
	lab var 		hun_fsi_y0 "Reduced meals eaten at baseline"
	
* relabel
	lab def			post 0 "pre-COVID" 1 "COVID", replace
	
* clear svyset and eststo
	svyset, clear
	svyset	[pweight = hhw_covid]

	eststo clear

* recode waves
	gen				nwave = wave if wave < 1
	
	* ethiopia
		replace			nwave = 1 if country == 1 & wave == 1
		replace			nwave = 2 if country == 1 & wave == 2
		replace			nwave = 3 if country == 1 & wave == 3
		replace			nwave = 5 if country == 1 & wave == 4
		replace			nwave = 6 if country == 1 & wave == 5
		replace			nwave = 7 if country == 1 & wave == 6
		replace			nwave = 8 if country == 1 & wave == 7
		replace			nwave = 9 if country == 1 & wave == 8
		replace			nwave = 10 if country == 1 & wave == 9
		replace			nwave = 11 if country == 1 & wave == 10
		replace			nwave = 13 if country == 1 & wave == 11
		replace			nwave = 15 if country == 1 & wave == 12
		
	* malawi
		replace			nwave = 3 if country == 2 & wave == 1
		replace			nwave = 4 if country == 2 & wave == 2
		replace			nwave = 5 if country == 2 & wave == 3
		replace			nwave = 6 if country == 2 & wave == 4
		replace			nwave = 8 if country == 2 & wave == 5
		replace			nwave = 9 if country == 2 & wave == 6
		replace			nwave = 10 if country == 2 & wave == 7
		replace			nwave = 12 if country == 2 & wave == 8
		replace			nwave = 13 if country == 2 & wave == 9
		replace			nwave = 14 if country == 2 & wave == 10
		replace			nwave = 15 if country == 2 & wave == 11
		replace			nwave = 16 if country == 2 & wave == 12
		
	* nigeria
		replace			nwave = 2 if country == 3 & wave == 1
		replace			nwave = 3 if country == 3 & wave == 2
		replace			nwave = 4 if country == 3 & wave == 3
		replace			nwave = 5 if country == 3 & wave == 4
		replace			nwave = 6 if country == 3 & wave == 5
		replace			nwave = 7 if country == 3 & wave == 6
		replace			nwave = 8 if country == 3 & wave == 7
		replace			nwave = 9 if country == 3 & wave == 8
		replace			nwave = 10 if country == 3 & wave == 9
		replace			nwave = 11 if country == 3 & wave == 10
		replace			nwave = 12 if country == 3 & wave == 11
		replace			nwave = 13 if country == 3 & wave == 12
		
	* burkina faso
		replace			nwave = 3 if country == 5 & wave == 1
		replace			nwave = 5 if country == 5 & wave == 2
		replace			nwave = 7 if country == 5 & wave == 3
		replace			nwave = 8 if country == 5 & wave == 4
		replace			nwave = 9 if country == 5 & wave == 5
		replace			nwave = 10 if country == 5 & wave == 6
		replace			nwave = 11 if country == 5 & wave == 7
		replace			nwave = 12 if country == 5 & wave == 8
		replace			nwave = 13 if country == 5 & wave == 9
		replace			nwave = 15 if country == 5 & wave == 10
		
* define labels for nwave
	lab def			nwave -1 "2018" 0 "2019" 1 "Apr '20" 2 "May '20" ///
						3 "Jun '20" 4 "Jul '20" 5 "Aug '20" ///
						6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
						9 "Dec '20" 10 "Jan '21" 11 "Feb '21" ///
						12 "Mar '21" 13 "Apr '21" 14 "May '21" ///
						15 "Jun '21" 16 "Jul '21"
	lab val			nwave nwave
	lab var			nwave "Survey Month"
	
************************************************************************
**# 2 - raw fies index regression
************************************************************************

* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.post##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo  		std_fsi_2`i'
		sum 			std_fsi_wt if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar 	mu = r(mean)
		estadd loc 		missing "Yes" : std_fsi_2`i'
	}					

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.sector std_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo  		std_fsi_3`i'
		sum 			std_fsi_wt if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : std_fsi_3`i'
	}		
		
* did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo  		std_fsi_4`i'
		sum 			std_fsi_wt if post == 0 & country == `i' ///
							& sexhh == 1 [aweight = hhw_covid]
		estadd scalar 	mu = r(mean)
		estadd loc 		missing "Yes" : std_fsi_4`i'
	}					


* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.sexhh std_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo  		std_fsi_5`i'
		sum 			std_fsi_wt if post == 0 & country == `i' ///
							& sexhh == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : std_fsi_5`i'
	}		
			
* build table for standardized raw FIES score and sector					
	esttab 			std_fsi_25 std_fsi_45 ///
					using "$tab/std_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{2}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] & " ///
					"\multicolumn{1}{c}{Urban-Rural} & \multicolumn{1}{c}{Female-Male} \\ " ) ///
					drop(*msng _cons *.wave) ///
					fragment nogap replace 
		
	esttab 			std_fsi_21 std_fsi_41 ///
					using "$tab/std_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
					
	esttab 			std_fsi_22 std_fsi_42 ///
					using "$tab/std_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
		
	esttab 			std_fsi_23 std_fsi_43 ///
					using "$tab/std_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{3}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the first column and male headed households " ///
					"in the second column. Each regression includes round fixed effects " ///
					"and a set of indicator variables to control for when household " ///
					"skip or refuse to answer a specific FIES question. Robust standard errors " ///
					"clustered at the household-levle are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")
		
			
************************************************************************
**# 3 - mild fies index regression
************************************************************************
	
* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			mld_fsi_2`i'
		sum				mld_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mld_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mld_fsi i.sector mld_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo			mld_fsi_3`i'
		sum				mld_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mld_fsi_3`i'
	}
	
* did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			mld_fsi_4`i'
		summ			mld_fsi if post == 0 & country == `i' ///
							& sexhh == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mld_fsi_4`i'
	}

* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mld_fsi i.sexhh mld_fsi_y0 fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo			mld_fsi_5`i'
		sum				mld_fsi if post == 0 & country == `i' ///
							& sexhh == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mld_fsi_5`i'
	}

* build table for mild fies index
	esttab 			mld_fsi_25 mld_fsi_45 ///
					using "$tab/mld_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{2}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] & " ///
					"\multicolumn{1}{c}{Urban-Rural} & \multicolumn{1}{c}{Female-Male} \\ " ) ///
					drop(*msng _cons *.wave) ///
					fragment nogap replace 
		
	esttab 			mld_fsi_21 mld_fsi_41 ///
					using "$tab/mld_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
					
	esttab 			mld_fsi_22 mld_fsi_42 ///
					using "$tab/mld_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
		
	esttab 			mld_fsi_23 mld_fsi_43 ///
					using "$tab/mld_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{3}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is mild food insecurity weighted " ///
					"using household survey weights. Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the first column and male headed households " ///
					"in the second column. Each regression includes round fixed effects " ///
					"and a set of indicator variables to control for when household " ///
					"skip or refuse to answer a specific FIES question. Robust standard errors " ///
					"clustered at the household-levle are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")
		
									
************************************************************************
**# 4 - moderate fies index regression
************************************************************************

* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			mod_fsi_2`i'
		sum				mod_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mod_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mod_fsi i.sector mod_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo			mod_fsi_3`i'
		sum				mod_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mod_fsi_3`i'
	}
	
*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			mod_fsi_4`i'
		summ			mod_fsi if post == 0 & country == `i' ///
							& sexhh == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mod_fsi_4`i'
	}

* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mod_fsi i.sexhh mod_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo			mod_fsi_5`i'
		sum				mod_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mod_fsi_5`i'
	}

* build table for moderate fies index
	esttab 			mod_fsi_25 mod_fsi_45 ///
					using "$tab/mod_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{2}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] & " ///
					"\multicolumn{1}{c}{Urban-Rural} & \multicolumn{1}{c}{Female-Male} \\ " ) ///
					drop(*msng _cons *.wave) ///
					fragment nogap replace 
		
	esttab 			mod_fsi_21 mod_fsi_41 ///
					using "$tab/mod_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
					
	esttab 			mod_fsi_22 mod_fsi_42 ///
					using "$tab/mod_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
		
	esttab 			mod_fsi_23 mod_fsi_43 ///
					using "$tab/mod_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{3}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is moderate food insecurity weighted " ///
					"using household survey weights. Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the first column and male headed households " ///
					"in the second column. Each regression includes round fixed effects " ///
					"and a set of indicator variables to control for when household " ///
					"skip or refuse to answer a specific FIES question. Robust standard errors " ///
					"clustered at the household-levle are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")
	
					
************************************************************************
**# 5 - severe fies index regression
************************************************************************

* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			sev_fsi_2`i'
		sum				sev_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : sev_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				sev_fsi i.sector sev_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo			sev_fsi_3`i'
		sum				sev_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : sev_fsi_3`i'
	}
	
*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			sev_fsi_4`i'
		sum				sev_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : sev_fsi_4`i'
	}


* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				sev_fsi i.sexhh sev_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng i.wave ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo			sev_fsi_5`i'
		sum				sev_fsi if post == 0 & country == `i' ///
							& sector == 1 [aweight = hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : sev_fsi_5`i'
	}

* build table for severe fies index
	esttab 			sev_fsi_25 sev_fsi_45 ///
					using "$tab/sev_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{2}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] & " ///
					"\multicolumn{1}{c}{Urban-Rural} & \multicolumn{1}{c}{Female-Male} \\ " ) ///
					drop(*msng _cons *.wave) ///
					fragment nogap replace 
		
	esttab 			sev_fsi_21 sev_fsi_41 ///
					using "$tab/sev_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
					
	esttab 			sev_fsi_22 sev_fsi_42 ///
					using "$tab/sev_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append
		
	esttab 			sev_fsi_23 sev_fsi_43 ///
					using "$tab/sev_fsi_diff.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{2}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{3}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is severe food insecurity weighted " ///
					"using household survey weights. Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the first column and male headed households " ///
					"in the second column. Each regression includes round fixed effects " ///
					"and a set of indicator variables to control for when household " ///
					"skip or refuse to answer a specific FIES question. Robust standard errors " ///
					"clustered at the household-levle are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")
	
		
************************************************************************
**# 6 - event study regressions
************************************************************************

* index - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.nwave##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_fsi_sec`i'
		sum				std_fsi_wt if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_fsi_sec`i'
	}

* index - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			std_fsi_wt i.nwave##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_fsi_sex`i'
		sum				std_fsi_wt if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_fsi_sex`i'
	}

* mld - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.nwave##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_mld_sec`i'
		sum				std_fsi_wt if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_mld_sec`i'
	}

* mld - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mld_fsi i.nwave##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_mld_sex`i'
		sum				std_fsi_wt if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_mld_sex`i'
	}

* mod - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.nwave##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_mod_sec`i'
		sum				std_fsi_wt if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_mod_sec`i'
	}

* mod - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mod_fsi i.nwave##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_mod_sex`i'
		sum				std_fsi_wt if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_mod_sex`i'
	}

* sev - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.nwave##i.sector fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_sev_sec`i'
		sum				sev_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_sev_sec`i'
	}

* sev - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			sev_fsi i.nwave##i.sexhh fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & nwave != -1, ///
							vce(cluster hhid)
		eststo 			wave_sev_sex`i'
		sum				sev_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : wave_sev_sex`i'
	}

	
************************************************************************
**# 7 - create coefplots
************************************************************************

************************************************************************
**## 7.1 - urban/rural coefplot
************************************************************************

	coefplot			 (std_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) /// bkf
							rename(1.post#2.sector = "FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "FIES Score") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Mild Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Moderate Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Severe Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(std_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) /// eth
							rename(1.post#2.sector = "FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "FIES Score ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Mild Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Moderate Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Severe Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(std_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) /// mwi
							rename(1.post#2.sector = " FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_32, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " FIES Score") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_32, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " Mild Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_32, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " Moderate Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_32, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " Severe Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(std_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) /// nga
							rename(1.post#2.sector = " FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_33, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " FIES Score ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_33, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " Mild Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_33, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " Moderate Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_33, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = " Severe Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ), ///
							xline(0, lcolor(maroon))  levels(95)  ciopts(lwidth(*3) lcolor(*3) ) ///
							xtitle("Point Estimates and 95% Confidence Intervals") ///
							headings("FIES Score" = "{bf:Burkina Faso}" "FIES Score " ///
							= "{bf:Ethiopia}" " FIES Score" = "{bf:Malawi}" ///
							" FIES Score " = "{bf:Nigeria}")  ///
							legend(pos(4) order(2 4) col(1)) ///
							saving("$fig/coef_sector", replace)	
			
	grc1leg2 		"$fig/coef_sector.gph", col(1) ring(0) pos(3) ///
						 commonscheme
				
	graph export 	"$fig/coef_sector.eps", as(eps) replace

	
************************************************************************
**## 7.2 - urban/rural coefplot DID only
************************************************************************

	coefplot			 (std_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) /// bkf
							rename(1.post#2.sector = "FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) /// eth
							rename(1.post#2.sector = "FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) /// mwi
							rename(1.post#2.sector = " FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_22, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) /// nga
							rename(1.post#2.sector = " FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_23, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = " Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) , ///
							xline(0, lcolor(maroon))  levels(95)  ciopts(lwidth(*3) lcolor(*3) ) ///
							xtitle("Point Estimates and 95% Confidence Intervals") ///
							headings("FIES Score" = "{bf:Burkina Faso}" "FIES Score " ///
							= "{bf:Ethiopia}" " FIES Score" = "{bf:Malawi}" ///
							" FIES Score " = "{bf:Nigeria}")  ///
							legend(off) ///
							saving("$fig/coef_sector_did", replace)	

	grc1leg2 		"$fig/coef_sector_did.gph", loff commonscheme
				
	graph export 	"$fig/coef_sector_did.eps", as(eps) replace


	
************************************************************************
**## 7.3 - female/male coefplot
************************************************************************

	coefplot			 (std_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) /// bkf
							rename(1.post#2.sexhh = "FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_55, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "FIES Score") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_55, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "Mild Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_55, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "Moderate Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_55, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "Severe Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(std_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) /// eth
							rename(1.post#2.sexhh = "FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_51, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "FIES Score ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_51, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "Mild Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_51, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "Moderate Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_51, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = "Severe Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(std_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) /// mwi
							rename(1.post#2.sexhh = " FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_52, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " FIES Score") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_52, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " Mild Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_52, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " Moderate Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_52, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " Severe Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(std_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) /// nga
							rename(1.post#2.sexhh = " FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_53, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " FIES Score ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_53, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " Mild Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_53, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " Moderate Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_53, label(ANCOVA) keep(2.sexhh) ///
							rename(2.sexhh = " Severe Insecurity ") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ), ///
							xline(0, lcolor(maroon))  levels(95)  ciopts(lwidth(*3) lcolor(*3) ) ///
							xtitle("Point Estimates and 95% Confidence Intervals") ///
							headings("FIES Score" = "{bf:Burkina Faso}" "FIES Score " ///
							= "{bf:Ethiopia}" " FIES Score" = "{bf:Malawi}" ///
							" FIES Score " = "{bf:Nigeria}")  ///
							legend(pos(4) order(2 4) col(1)) ///
							saving("$fig/coef_sexhh", replace)	
			
	grc1leg2 		"$fig/coef_sexhh.gph", col(1) ring(0) pos(3) ///
						 commonscheme
				
	graph export 	"$fig/coef_sexhh.eps", as(eps) replace

	
************************************************************************
**## 7.4 - female/male coefplot DID only
************************************************************************

	coefplot			 (std_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) /// bkf
							rename(1.post#2.sexhh = "FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_45, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) /// eth
							rename(1.post#2.sexhh = "FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_41, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = "Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) /// mwi
							rename(1.post#2.sexhh = " FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_42, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) /// nga
							rename(1.post#2.sexhh = " FIES Score ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Mild Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Moderate Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_43, label(Diff-in-Diff) keep(1.post#2.sexhh) ///
							rename(1.post#2.sexhh = " Severe Insecurity ") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ), ///
							xline(0, lcolor(maroon))  levels(95)  ciopts(lwidth(*3) lcolor(*3) ) ///
							xtitle("Point Estimates and 95% Confidence Intervals") ///
							headings("FIES Score" = "{bf:Burkina Faso}" "FIES Score " ///
							= "{bf:Ethiopia}" " FIES Score" = "{bf:Malawi}" ///
							" FIES Score " = "{bf:Nigeria}")  ///
							legend(off) ///
							saving("$fig/coef_sexhh_did", replace)	
			
	grc1leg2 		"$fig/coef_sexhh_did.gph", loff commonscheme
				
	graph export 	"$fig/coef_sexhh_did.eps", as(eps) replace


************************************************************************
**## 7.5 - Event Study Coefplot Index - Sector
************************************************************************	
	
* index - sector - ethiopia
	coefplot			wave_fsi_sec1, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_fies_sec", replace)	

* index - sector - malawi
	coefplot			wave_fsi_sec2, keep(3.nwave#2.sector 4.nwave#2.sector ///
							5.nwave#2.sector 6.nwave#2.sector 8.nwave#2.sector ///
							9.nwave#2.sector 10.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector 14.nwave#2.sector 15.nwave#2.sector ///
							16.nwave#2.sector) rename(3.nwave#2.sector = "Jun '20" ///
							4.nwave#2.sector = "Jul '20" 5.nwave#2.sector = "Aug '20" ///
							6.nwave#2.sector = "Sep '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							12.nwave#2.sector = "Mar '21" 13.nwave#2.sector = "Apr '21" ///
							14.nwave#2.sector = "May '21" 15.nwave#2.sector = "Jun '21" ///
							16.nwave#2.sector = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_fies_sec", replace)	
	
* index - sector - nigeria
	coefplot			wave_fsi_sec3, keep(2.nwave#2.sector 3.nwave#2.sector ///
							4.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector) rename(2.nwave#2.sector = "May '20" ///
							3.nwave#2.sector = "Jun '20" 4.nwave#2.sector = "Jul '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 12.nwave#2.sector = "Mar '21" ///
							13.nwave#2.sector = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_fies_sec", replace)	
	
* index - sector - burkina						
	coefplot			wave_fsi_sec5, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 "Sep '20" = 6 ///
							"Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 "Jan '21" = 10 ///
							"Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 "May '21" = 14 ///
							"Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_fies_sec", replace)							
		
	graph combine 		"$fig/eth_fies_sec.gph" "$fig/mwi_fies_sec.gph" ///
						"$fig/nga_fies_sec.gph"  "$fig/bf_fies_sec.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/fies_sec", replace)
						 
	graph export 		"$fig/fies_sec.eps", as(eps) replace	
	

************************************************************************
**## 7.6 - Event Study Coefplot Index - Sex
************************************************************************	

* index - sexhh - ethiopia
	coefplot			wave_fsi_sex1, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_fies_sex", replace)	

* index - sexhh - malawi
	coefplot			wave_fsi_sex2, keep(3.nwave#2.sexhh 4.nwave#2.sexhh ///
							5.nwave#2.sexhh 6.nwave#2.sexhh 8.nwave#2.sexhh ///
							9.nwave#2.sexhh 10.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh 14.nwave#2.sexhh 15.nwave#2.sexhh ///
							16.nwave#2.sexhh) rename(3.nwave#2.sexhh = "Jun '20" ///
							4.nwave#2.sexhh = "Jul '20" 5.nwave#2.sexhh = "Aug '20" ///
							6.nwave#2.sexhh = "Sep '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							12.nwave#2.sexhh = "Mar '21" 13.nwave#2.sexhh = "Apr '21" ///
							14.nwave#2.sexhh = "May '21" 15.nwave#2.sexhh = "Jun '21" ///
							16.nwave#2.sexhh = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_fies_sex", replace)	
	
* index - sexhh - nigeria
	coefplot			wave_fsi_sex3, keep(2.nwave#2.sexhh 3.nwave#2.sexhh ///
							4.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh) rename(2.nwave#2.sexhh = "May '20" ///
							3.nwave#2.sexhh = "Jun '20" 4.nwave#2.sexhh = "Jul '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 12.nwave#2.sexhh = "Mar '21" ///
							13.nwave#2.sexhh = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_fies_sex", replace)	
	
* index - sexhh - burkina						
	coefplot			wave_fsi_sex5, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_fies_sex", replace)							
	
	graph combine 		"$fig/eth_fies_sex.gph" "$fig/mwi_fies_sex.gph" ///
						"$fig/nga_fies_sex.gph"  "$fig/bf_fies_sex.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/fies_sex", replace)
						 
	graph export 		"$fig/fies_sex.eps", as(eps) replace


************************************************************************
**## 7.7 - Event Study Coefplot Mild - Sector 
************************************************************************	

* mild - sector - ethiopia
	coefplot			wave_mld_sec1, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_mld_sec", replace)	

* mild - sector - malawi
	coefplot			wave_mld_sec2, keep(3.nwave#2.sector 4.nwave#2.sector ///
							5.nwave#2.sector 6.nwave#2.sector 8.nwave#2.sector ///
							9.nwave#2.sector 10.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector 14.nwave#2.sector 15.nwave#2.sector ///
							16.nwave#2.sector) rename(3.nwave#2.sector = "Jun '20" ///
							4.nwave#2.sector = "Jul '20" 5.nwave#2.sector = "Aug '20" ///
							6.nwave#2.sector = "Sep '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							12.nwave#2.sector = "Mar '21" 13.nwave#2.sector = "Apr '21" ///
							14.nwave#2.sector = "May '21" 15.nwave#2.sector = "Jun '21" ///
							16.nwave#2.sector = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_mld_sec", replace)	
	
* mild - sector - nigeria
	coefplot			wave_mld_sec3, keep(2.nwave#2.sector 3.nwave#2.sector ///
							4.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector) rename(2.nwave#2.sector = "May '20" ///
							3.nwave#2.sector = "Jun '20" 4.nwave#2.sector = "Jul '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 12.nwave#2.sector = "Mar '21" ///
							13.nwave#2.sector = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_mld_sec", replace)	
	
* mild - sector - burkina						
	coefplot			wave_mld_sec5, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 "Sep '20" = 6 ///
							"Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 "Jan '21" = 10 ///
							"Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 "May '21" = 14 ///
							"Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_mld_sec", replace)							

	graph combine 		"$fig/eth_mld_sec.gph" "$fig/mwi_mld_sec.gph" ///
						"$fig/nga_mld_sec.gph"  "$fig/bf_mld_sec.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/mld_sec", replace)
						 
	graph export 		"$fig/mld_sec.eps", as(eps) replace
													
							
************************************************************************
**## 7.8 - Event Study Coefplot Mild - Sex
************************************************************************	

* mild - sexhh - ethiopia
	coefplot			wave_mld_sex1, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_mld_sex", replace)	

* mild - sexhh - malawi
	coefplot			wave_mld_sex2, keep(3.nwave#2.sexhh 4.nwave#2.sexhh ///
							5.nwave#2.sexhh 6.nwave#2.sexhh 8.nwave#2.sexhh ///
							9.nwave#2.sexhh 10.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh 14.nwave#2.sexhh 15.nwave#2.sexhh ///
							16.nwave#2.sexhh) rename(3.nwave#2.sexhh = "Jun '20" ///
							4.nwave#2.sexhh = "Jul '20" 5.nwave#2.sexhh = "Aug '20" ///
							6.nwave#2.sexhh = "Sep '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							12.nwave#2.sexhh = "Mar '21" 13.nwave#2.sexhh = "Apr '21" ///
							14.nwave#2.sexhh = "May '21" 15.nwave#2.sexhh = "Jun '21" ///
							16.nwave#2.sexhh = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_mld_sex", replace)	
	
* mild - sexhh - nigeria
	coefplot			wave_mld_sex3, keep(2.nwave#2.sexhh 3.nwave#2.sexhh ///
							4.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh) rename(2.nwave#2.sexhh = "May '20" ///
							3.nwave#2.sexhh = "Jun '20" 4.nwave#2.sexhh = "Jul '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 12.nwave#2.sexhh = "Mar '21" ///
							13.nwave#2.sexhh = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_mld_sex", replace)	
	
* mild - sexhh - burkina						
	coefplot			wave_mld_sex5, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_mld_sex", replace)							
	
	graph combine 		"$fig/eth_mld_sex.gph" "$fig/mwi_mld_sex.gph" ///
						"$fig/nga_mld_sex.gph"  "$fig/bf_mld_sex.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/mld_sex", replace)
						 
	graph export 		"$fig/mld_sex.eps", as(eps) replace	



************************************************************************
**## 7.9 - Event Study Coefplot Mod - Sector
************************************************************************	

* mod - sector - ethiopia
	coefplot			wave_mod_sec1, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_mod_sec", replace)	

* mod - sector - malawi
	coefplot			wave_mod_sec2, keep(3.nwave#2.sector 4.nwave#2.sector ///
							5.nwave#2.sector 6.nwave#2.sector 8.nwave#2.sector ///
							9.nwave#2.sector 10.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector 14.nwave#2.sector 15.nwave#2.sector ///
							16.nwave#2.sector) rename(3.nwave#2.sector = "Jun '20" ///
							4.nwave#2.sector = "Jul '20" 5.nwave#2.sector = "Aug '20" ///
							6.nwave#2.sector = "Sep '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							12.nwave#2.sector = "Mar '21" 13.nwave#2.sector = "Apr '21" ///
							14.nwave#2.sector = "May '21" 15.nwave#2.sector = "Jun '21" ///
							16.nwave#2.sector = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_mod_sec", replace)	
	
* mod - sector - nigeria
	coefplot			wave_mod_sec3, keep(2.nwave#2.sector 3.nwave#2.sector ///
							4.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector) rename(2.nwave#2.sector = "May '20" ///
							3.nwave#2.sector = "Jun '20" 4.nwave#2.sector = "Jul '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 12.nwave#2.sector = "Mar '21" ///
							13.nwave#2.sector = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_mod_sec", replace)	
	
* mod - sector - burkina						
	coefplot			wave_mod_sec5, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 "Sep '20" = 6 ///
							"Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 "Jan '21" = 10 ///
							"Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 "May '21" = 14 ///
							"Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_mod_sec", replace)							

	graph combine 		"$fig/eth_mod_sec.gph" "$fig/mwi_mod_sec.gph" ///
						"$fig/nga_mod_sec.gph"  "$fig/bf_mod_sec.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/mod_sec", replace)
						 
	graph export 		"$fig/mod_sec.eps", as(eps) replace
	
							
************************************************************************
**## 7.10 - Event Study Coefplot Mod - Sex 
************************************************************************	

* mod - sexhh - ethiopia
	coefplot			wave_mod_sex1, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_mod_sex", replace)	

* mod - sexhh - malawi
	coefplot			wave_mod_sex2, keep(3.nwave#2.sexhh 4.nwave#2.sexhh ///
							5.nwave#2.sexhh 6.nwave#2.sexhh 8.nwave#2.sexhh ///
							9.nwave#2.sexhh 10.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh 14.nwave#2.sexhh 15.nwave#2.sexhh ///
							16.nwave#2.sexhh) rename(3.nwave#2.sexhh = "Jun '20" ///
							4.nwave#2.sexhh = "Jul '20" 5.nwave#2.sexhh = "Aug '20" ///
							6.nwave#2.sexhh = "Sep '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							12.nwave#2.sexhh = "Mar '21" 13.nwave#2.sexhh = "Apr '21" ///
							14.nwave#2.sexhh = "May '21" 15.nwave#2.sexhh = "Jun '21" ///
							16.nwave#2.sexhh = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_mod_sex", replace)	
	
* mod - sexhh - nigeria
	coefplot			wave_mod_sex3, keep(2.nwave#2.sexhh 3.nwave#2.sexhh ///
							4.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh) rename(2.nwave#2.sexhh = "May '20" ///
							3.nwave#2.sexhh = "Jun '20" 4.nwave#2.sexhh = "Jul '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 12.nwave#2.sexhh = "Mar '21" ///
							13.nwave#2.sexhh = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_mod_sex", replace)	
	
* mod - sexhh - burkina						
	coefplot			wave_mod_sex5, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_mod_sex", replace)							
	
	graph combine 		"$fig/eth_mod_sex.gph" "$fig/mwi_mod_sex.gph" ///
						"$fig/nga_mod_sex.gph"  "$fig/bf_mod_sex.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/mod_sex", replace)
						 
	graph export 		"$fig/mod_sex.eps", as(eps) replace	

	
************************************************************************
**## 7.11 - Event Study Coefplot Sev - Sector
************************************************************************	

* sev - sector - ethiopia
	coefplot			wave_sev_sec1, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_sev_sec", replace)	

* sev - sector - malawi
	coefplot			wave_sev_sec2, keep(3.nwave#2.sector 4.nwave#2.sector ///
							5.nwave#2.sector 6.nwave#2.sector 8.nwave#2.sector ///
							9.nwave#2.sector 10.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector 14.nwave#2.sector 15.nwave#2.sector ///
							16.nwave#2.sector) rename(3.nwave#2.sector = "Jun '20" ///
							4.nwave#2.sector = "Jul '20" 5.nwave#2.sector = "Aug '20" ///
							6.nwave#2.sector = "Sep '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							12.nwave#2.sector = "Mar '21" 13.nwave#2.sector = "Apr '21" ///
							14.nwave#2.sector = "May '21" 15.nwave#2.sector = "Jun '21" ///
							16.nwave#2.sector = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_sev_sec", replace)	
	
* sev - sector - nigeria
	coefplot			wave_sev_sec3, keep(2.nwave#2.sector 3.nwave#2.sector ///
							4.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 12.nwave#2.sector ///
							13.nwave#2.sector) rename(2.nwave#2.sector = "May '20" ///
							3.nwave#2.sector = "Jun '20" 4.nwave#2.sector = "Jul '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 12.nwave#2.sector = "Mar '21" ///
							13.nwave#2.sector = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_sev_sec", replace)	
	
* sev - sector - burkina						
	coefplot			wave_sev_sec5, keep(1.nwave#2.sector 2.nwave#2.sector ///
							3.nwave#2.sector 5.nwave#2.sector 6.nwave#2.sector ///
							7.nwave#2.sector 8.nwave#2.sector 9.nwave#2.sector ///
							10.nwave#2.sector 11.nwave#2.sector 13.nwave#2.sector ///
							15.nwave#2.sector) rename(1.nwave#2.sector = "Apr '20" ///
							2.nwave#2.sector = "May '20" 3.nwave#2.sector = "Jun '20" ///
							5.nwave#2.sector = "Aug '20" 6.nwave#2.sector = "Sep '20" ///
							7.nwave#2.sector = "Oct '20" 8.nwave#2.sector = "Nov '20" ///
							9.nwave#2.sector = "Dec '20" 10.nwave#2.sector = "Jan '21" ///
							11.nwave#2.sector = "Feb '21" 13.nwave#2.sector = "Apr '21" ///
							15.nwave#2.sector = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 "Sep '20" = 6 ///
							"Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 "Jan '21" = 10 ///
							"Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 "May '21" = 14 ///
							"Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_sev_sec", replace)							

	graph combine 		"$fig/eth_sev_sec.gph" "$fig/mwi_sev_sec.gph" ///
						"$fig/nga_sev_sec.gph"  "$fig/bf_sev_sec.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/sev_sec", replace)
						 
	graph export 		"$fig/sev_sec.eps", as(eps) replace

	
************************************************************************
**## 7.10 - Event Study Coefplot Sev - Sex 
************************************************************************	

* sev - sexhh - ethiopia
	coefplot			wave_sev_sex1, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3  "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15)  msymbol(D) vertical ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Ethiopia") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/eth_sev_sex", replace)	

* sev - sexhh - malawi
	coefplot			wave_sev_sex2, keep(3.nwave#2.sexhh 4.nwave#2.sexhh ///
							5.nwave#2.sexhh 6.nwave#2.sexhh 8.nwave#2.sexhh ///
							9.nwave#2.sexhh 10.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh 14.nwave#2.sexhh 15.nwave#2.sexhh ///
							16.nwave#2.sexhh) rename(3.nwave#2.sexhh = "Jun '20" ///
							4.nwave#2.sexhh = "Jul '20" 5.nwave#2.sexhh = "Aug '20" ///
							6.nwave#2.sexhh = "Sep '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							12.nwave#2.sexhh = "Mar '21" 13.nwave#2.sexhh = "Apr '21" ///
							14.nwave#2.sexhh = "May '21" 15.nwave#2.sexhh = "Jun '21" ///
							16.nwave#2.sexhh = "Jul '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 ///
							"Apr '21" = 13 "May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Malawi") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/mwi_sev_sex", replace)	
	
* sev - sexhh - nigeria
	coefplot			wave_sev_sex3, keep(2.nwave#2.sexhh 3.nwave#2.sexhh ///
							4.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 12.nwave#2.sexhh ///
							13.nwave#2.sexhh) rename(2.nwave#2.sexhh = "May '20" ///
							3.nwave#2.sexhh = "Jun '20" 4.nwave#2.sexhh = "Jul '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 12.nwave#2.sexhh = "Mar '21" ///
							13.nwave#2.sexhh = "Apr '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Nigeria") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/nga_sev_sex", replace)	
	
* sev - sexhh - burkina						
	coefplot			wave_sev_sex5, keep(1.nwave#2.sexhh 2.nwave#2.sexhh ///
							3.nwave#2.sexhh 5.nwave#2.sexhh 6.nwave#2.sexhh ///
							7.nwave#2.sexhh 8.nwave#2.sexhh 9.nwave#2.sexhh ///
							10.nwave#2.sexhh 11.nwave#2.sexhh 13.nwave#2.sexhh ///
							15.nwave#2.sexhh) rename(1.nwave#2.sexhh = "Apr '20" ///
							2.nwave#2.sexhh = "May '20" 3.nwave#2.sexhh = "Jun '20" ///
							5.nwave#2.sexhh = "Aug '20" 6.nwave#2.sexhh = "Sep '20" ///
							7.nwave#2.sexhh = "Oct '20" 8.nwave#2.sexhh = "Nov '20" ///
							9.nwave#2.sexhh = "Dec '20" 10.nwave#2.sexhh = "Jan '21" ///
							11.nwave#2.sexhh = "Feb '21" 13.nwave#2.sexhh = "Apr '21" ///
							15.nwave#2.sexhh = "Jun '21") reloc("Apr '20" = 1 ///
							"May '20" = 2 "Jun '20" = 3 "Jul '20" = 4 "Aug '20" = 5 ///
							"Sep '20" = 6 "Oct '20" = 7 "Nov '20" = 8 "Dec '20" = 9 ///
							"Jan '21" = 10 "Feb '21" = 11 "Mar '21" = 12 "Apr '21" = 13 ///
							"May '21" = 14 "Jun '21" = 15) msymbol(D) ///
							vertical mcolor(gs8) mfcolor(white) ciopts(color(edkblue) ///
							lwidth(*1) lcolor(*3) ) yline(0, lcolor(maroon)) ///
							levels(95) xtitle("Survey Month Year") recast(line) ///
							ytitle("Point Estimates and 95% Confidence Intervals")  ///
							title("Burkina Faso") yscale(r(-0.6 0.6)) ylab(-0.6(0.2)0.6) ///
							xlabel(1 "Apr '20" 2 "May '20" 3 "Jun '20" ///
							4 "Jul '20" 5 "Aug '20" 6 "Sep '20" 7 "Oct '20" 8 "Nov '20" ///
							9 "Dec '20" 10 "Jan '21" 11 "Feb '21" 12 "Mar '21" ///
							13 "Apr '21" 14 "May '21" 15 "Jun '21", angle(45)) ///
							legend(off) saving("$fig/bf_sev_sex", replace)							
	
	graph combine 		"$fig/eth_sev_sex.gph" "$fig/mwi_sev_sex.gph" ///
						"$fig/nga_sev_sex.gph"  "$fig/bf_sev_sex.gph" , col(2) iscale(.5)  ///
						 commonscheme saving("$fig/sev_sex", replace)
						 
	graph export 		"$fig/sev_sex.eps", as(eps) replace	
	
	
************************************************************************
**# 8 - create coefplots by country
************************************************************************
/*
* burkina faso
	coefplot			 (std_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "FIES Score") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Mild Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Moderate Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_25, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_35, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Severe Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ), ///
							order(std_fsi_25 std_fsi_35 mld_fsi_25 mld_fsi_35 ///
							mod_fsi_25 mod_fsi_35 sev_fsi_25 sev_fsi_35 ) ///
							xline(0, lcolor(maroon))  xtitle("Coefficients") ///
							levels(95)  ciopts(lwidth(*3) lcolor(*3) ) ///
							headings("FIES Score" = "{bf:Burkina Faso}") ///
							legend(pos(6) order(2 4) col(2))
							

* ethiopia
	coefplot			 (std_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "FIES Score") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(std_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "FIES Score") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mld_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Mild Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mld_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Mild Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(mod_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Moderate Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(mod_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Moderate Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ) ///
							(sev_fsi_21, label(Diff-in-Diff) keep(1.post#2.sector) ///
							rename(1.post#2.sector = "Severe Insecurity") msymbol(D) ///
							mcolor(gs8) mfcolor(white) ciopts(color(edkblue)) ) ///
							(sev_fsi_31, label(ANCOVA) keep(2.sector) ///
							rename(2.sector = "Severe Insecurity") msymbol(S) ///
							mcolor(gs1) mfcolor(white) ciopts(color(eltgreen)) ), ///
							order(std_fsi_25 std_fsi_35 mld_fsi_25 mld_fsi_35 ) ///
							xline(0, lcolor(maroon))  xtitle("Coefficients") ///
							levels(95)  ciopts(lwidth(*3) lcolor(*3) ) ///
							headings("FIES Score" = "{bf:Ethiopia}") ///
							legend(pos(6) order(2 4) col(2))
*/							
	
************************************************************************
**# 9 - check correlation ANCOVA
************************************************************************
	
* generate correlation variables to check for ancova 

* std_fsi burkina faso	
	gen 			std_fsi_y0_5 = std_fsi_y0 if country == 5 
	gen				std_fsi_5_5 = std_fsi if country == 5 & wave == 5 // first # is country second # is wave
	
* std_fsi ethiopia
	gen 			std_fsi_y0_1 = std_fsi_y0 if country == 1
	gen				std_fsi_1_1 = std_fsi if country == 1 & wave == 1 // first # is country second # is wave
	
* std_fsi malawi
	gen 			std_fsi_y0_2 = std_fsi_y0 if country == 2
	gen				std_fsi_2_3 = std_fsi if country == 2 & wave == 3 // first # is country second # is wave
		
* std_fsi nigeria
	gen 			std_fsi_y0_3 = std_fsi_y0 if country == 3
	gen				std_fsi_3_2 = std_fsi if country == 3 & wave == 2 // first # is country second # is wave
	
* mld_fsi burkina faso	
	gen 			mld_fsi_y0_5 = mld_fsi_y0 if country == 5 
	gen				mld_fsi_5_5 = mld_fsi if country == 5 & wave == 5 // first # is country second # is wave
	
* mld_fsi ethiopia
	gen 			mld_fsi_y0_1 = mld_fsi_y0 if country == 1
	gen				mld_fsi_1_1 = mld_fsi if country == 1 & wave == 1 // first # is country second # is wave
	
* mld_fsi malawi
	gen 			mld_fsi_y0_2 = mld_fsi_y0 if country == 2
	gen				mld_fsi_2_3 = mld_fsi if country == 2 & wave == 3 // first # is country second # is wave
		
* mld_fsi nigeria
	gen 			mld_fsi_y0_3 = mld_fsi_y0 if country == 3
	gen				mld_fsi_3_2 = mld_fsi if country == 3 & wave == 2 // first # is country second # is wave

* mod_fsi burkina faso	
	gen 			mod_fsi_y0_5 = mod_fsi_y0 if country == 5 
	gen				mod_fsi_5_5 = mod_fsi if country == 5 & wave == 5 // first # is country second # is wave
	
* mod_fsi ethiopia
	gen 			mod_fsi_y0_1 = mod_fsi_y0 if country == 1
	gen				mod_fsi_1_2 = mod_fsi if country == 1 & wave == 2 // first # is country second # is wave
	
* mod_fsi malawi
	gen 			mod_fsi_y0_2 = mod_fsi_y0 if country == 2
	gen				mod_fsi_2_3 = mod_fsi if country == 2 & wave == 3 // first # is country second # is wave
		
* mod_fsi nigeria
	gen 			mod_fsi_y0_3 = mod_fsi_y0 if country == 3
	gen				mod_fsi_3_4 = mod_fsi if country == 3 & wave == 4 // first # is country second # is wave

* sev_fsi burkina faso	
	gen 			sev_fsi_y0_5 = sev_fsi_y0 if country == 5 
	gen				sev_fsi_5_5 = sev_fsi if country == 5 & wave == 5 // first # is country second # is wave
	
* sev_fsi ethiopia
	gen 			sev_fsi_y0_1 = sev_fsi_y0 if country == 1
	gen				sev_fsi_1_2 = sev_fsi if country == 1 & wave == 2 // first # is country second # is wave
	
* sev_fsi malawi
	gen 			sev_fsi_y0_2 = sev_fsi_y0 if country == 2
	gen				sev_fsi_2_3 = sev_fsi if country == 2 & wave == 3 // first # is country second # is wave
		
* std_fsi nigeria
	gen 			sev_fsi_y0_3 = sev_fsi_y0 if country == 3
	gen				sev_fsi_3_4 = sev_fsi if country == 3 & wave == 4 // first # is country second # is wave

	
* correlations std_fsi
	corr			std_fsi_y0_5 std_fsi_5_5
	corr			std_fsi_y0_1 std_fsi_1_1
	corr			std_fsi_y0_2 std_fsi_2_3
	corr			std_fsi_y0_3 std_fsi_3_2	
	
* correlations mld_fsi
	corr			mld_fsi_y0_5 mld_fsi_5_5
	corr			mld_fsi_y0_1 mld_fsi_1_1
	corr			mld_fsi_y0_2 mld_fsi_2_3
	corr			mld_fsi_y0_3 mld_fsi_3_2

* correlations mod_fsi
	corr			mod_fsi_y0_5 mod_fsi_5_5
	corr			mod_fsi_y0_1 mod_fsi_1_2
	corr			mod_fsi_y0_2 mod_fsi_2_3
	corr			mod_fsi_y0_3 mod_fsi_3_4

* correlations sev_fsi
	corr			sev_fsi_y0_5 sev_fsi_5_5
	corr			sev_fsi_y0_1 sev_fsi_1_2
	corr			sev_fsi_y0_2 sev_fsi_2_3
	corr			sev_fsi_y0_3 sev_fsi_3_4	
	
	
	
************************************************************************
**# 9 - end matter, clean up to save
************************************************************************
									
* compress data
	compress
	
* save 
	save			"$input/fies_reg_results", replace	

* close the log
	log	close
	
	
/* END */	

* Project: COVID Food Security
* Created on: October 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 12 November 2021
* Stata v.17.0

* does
	* reads in cleaned, regression ready data
	* conducts analysis
	* contains unused code for anxiety, hunger, and meals skipped
	* contains correlation checks for ancova

* assumes
	* cleaned fies data file
	* ietoolkit.ado


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
	esttab 			std_fsi_25 std_fsi_35 std_fsi_45 std_fsi_55 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] & " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0 *.wave) ///
					fragment nogap replace 
		
	esttab 			std_fsi_21 std_fsi_31 std_fsi_41 std_fsi_51 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
					
	esttab 			std_fsi_22 std_fsi_32 std_fsi_42 std_fsi_52 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
		
	esttab 			std_fsi_23 std_fsi_33 std_fsi_43 std_fsi_53 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{5}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean in the first " ///
					"column represents the pre-pandemic mean of the outcome variable in each " ///
					"country. In the last four columns, the Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the second and third columns and male " ///
					"headed households in the final two columns. Each regression " ///
					"includes a set of indicator variables to control for when " ///
					"household skip or refuse to answer a specific FIES question. " ///
					"Cluster corrected robust standard errors are reported in parentheses " ///
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
	esttab 			mld_fsi_25 mld_fsi_35 mld_fsi_45 mld_fsi_55 ///
					using "$tab/mld_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0 *.wave) ///
					fragment nogap replace 
		
	esttab 			mld_fsi_21 mld_fsi_31 mld_fsi_41 mld_fsi_51 ///
					using "$tab/mld_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
					
	esttab 			mld_fsi_22 mld_fsi_32 mld_fsi_42 mld_fsi_52 ///
					using "$tab/mld_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
		
	esttab 			mld_fsi_23 mld_fsi_33 mld_fsi_43 mld_fsi_53 ///
					using "$tab/mld_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{5}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean in the first " ///
					"column represents the pre-pandemic mean of the outcome variable in each " ///
					"country. In the last four columns, the Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the second and third columns and male " ///
					"headed households in the final two columns. Each regression " ///
					"includes a set of indicator variables to control for when " ///
					"household skip or refuse to answer a specific FIES question. " ///
					"Cluster corrected robust standard errors are reported in parentheses " ///
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
	esttab 			mod_fsi_25 mod_fsi_35 mod_fsi_45 mod_fsi_55 ///
					using "$tab/mod_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0 *.wave) ///
					fragment nogap replace 
		
	esttab 			mod_fsi_21 mod_fsi_31 mod_fsi_41 mod_fsi_51 ///
					using "$tab/mod_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
					
	esttab 			mod_fsi_22 mod_fsi_32 mod_fsi_42 mod_fsi_52 ///
					using "$tab/mod_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
		
	esttab 			mod_fsi_23 mod_fsi_33 mod_fsi_43 mod_fsi_53 ///
					using "$tab/mod_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{5}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean in the first " ///
					"column represents the pre-pandemic mean of the outcome variable in each " ///
					"country. In the last four columns, the Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the second and third columns and male " ///
					"headed households in the final two columns. Each regression " ///
					"includes a set of indicator variables to control for when " ///
					"household skip or refuse to answer a specific FIES question. " ///
					"Cluster corrected robust standard errors are reported in parentheses " ///
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
	esttab 			sev_fsi_25 sev_fsi_35 sev_fsi_45 sev_fsi_55 ///
					using "$tab/sev_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0 *.wave) ///
					fragment nogap replace 
		
	esttab 			sev_fsi_21 sev_fsi_31 sev_fsi_41 sev_fsi_51 ///
					using "$tab/sev_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
					
	esttab 			sev_fsi_22 sev_fsi_32 sev_fsi_42 sev_fsi_52 ///
					using "$tab/sev_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
		
	esttab 			sev_fsi_23 sev_fsi_33 sev_fsi_43 sev_fsi_53 ///
					using "$tab/sev_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{5}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean in the first " ///
					"column represents the pre-pandemic mean of the outcome variable in each " ///
					"country. In the last four columns, the Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the second and third columns and male " ///
					"headed households in the final two columns. Each regression " ///
					"includes a set of indicator variables to control for when " ///
					"household skip or refuse to answer a specific FIES question. " ///
					"Cluster corrected robust standard errors are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")
	
/*			
************************************************************************
**# 6 - anxiety index regression
************************************************************************

* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.post##i.sector fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			anx_2`i'
		sum				anx_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : anx_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.sector std_fsi_y0 fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			anx_3`i'
		sum				anx_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : anx_fsi_3`i'
	}

*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.post##i.sexhh fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			anx_4`i'
		sum				anx_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : anx_fsi_4`i'
	}
	
* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.sexhh std_fsi_y0 fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			anx_5`i'
		sum				anx_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : anx_fsi_5`i'
	}
	
* build table for anxiety index
	esttab 			anx_fsi_25 anx_fsi_35 anx_fsi_45 anx_fsi_55 ///
					using "$tab/anx_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0 *.wave) ///
					fragment nogap replace 
		
	esttab 			anx_fsi_21 anx_fsi_31 anx_fsi_41 anx_fsi_51 ///
					using "$tab/anx_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
					
	esttab 			anx_fsi_22 anx_fsi_32 anx_fsi_42 anx_fsi_52 ///
					using "$tab/anx_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
		
	esttab 			anx_fsi_23 anx_fsi_33 anx_fsi_43 anx_fsi_53 ///
					using "$tab/anx_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{5}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean in the first " ///
					"column represents the pre-pandemic mean of the outcome variable in each " ///
					"country. In the last four columns, the Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the second and third columns and male " ///
					"headed households in the final two columns. Each regression " ///
					"includes a set of indicator variables to control for when " ///
					"household skip or refuse to answer a specific FIES question. " ///
					"Cluster corrected robust standard errors are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")

	
************************************************************************
**# 7 - meal reduction index regression
************************************************************************

* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.post##i.sector fs3_msng fs4_msng fs5_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			mea_2`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.sector std_fsi_y0 fs3_msng fs4_msng /// 
						fs5_msng [pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			mea_3`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_3`i'
	}

*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.post##i.sexhh fs3_msng fs4_msng fs5_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			mea_4`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_4`i'
	}

* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.sexhh std_fsi_y0 fs3_msng fs4_msng /// 
						fs5_msng [pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			mea_5`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_5`i'
	}
	
* build table for meal reduction index
	esttab 			mea_25 mea_35 mea_45 mea_55 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0 *.wave) ///
					fragment nogap replace 
		
	esttab 			mea_21 mea_31 mea_41 mea_51 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
					
	esttab 			mea_22 mea_32 mea_42 mea_52 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
		
	esttab 			mea_23 mea_33 mea_43 mea_53 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{5}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean in the first " ///
					"column represents the pre-pandemic mean of the outcome variable in each " ///
					"country. In the last four columns, the Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the second and third columns and male " ///
					"headed households in the final two columns. Each regression " ///
					"includes a set of indicator variables to control for when " ///
					"household skip or refuse to answer a specific FIES question. " ///
					"Cluster corrected robust standard errors are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")


	
************************************************************************
**# 7 - hunger index regression
************************************************************************

* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.post##i.sector fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			hun_2`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_2`i'
	}
	
* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.sector std_fsi_y0 fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			hun_3`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_3`i'
	}
	
*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.post##i.sexhh fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave != -1, ///
							vce(cluster hhid)
		eststo 			hun_4`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_4`i'
	}
	
* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.sexhh std_fsi_y0 fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			hun_5`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_5`i'
	}
	
* build table for meal reduction index
	esttab 			hun_25 hun_35 hun_45 hun_55 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0 *.wave) ///
					fragment nogap replace 
		
	esttab 			hun_21 hun_31 hun_41 hun_51 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
					
	esttab 			hun_22 hun_32 hun_42 hun_52 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append
		
	esttab 			hun_23 hun_33 hun_43 hun_53 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0 *.wave) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{5}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
					"Dependent variable is the standardized raw FIES score weighted " ///
					"using household survey weights. Baseline Mean in the first " ///
					"column represents the pre-pandemic mean of the outcome variable in each " ///
					"country. In the last four columns, the Baseline Mean represents the " ///
					"pre-pandemic mean of the outcome variable in the comparison area " ///
					"— e.g., rural areas in the second and third columns and male " ///
					"headed households in the final two columns. Each regression " ///
					"includes a set of indicator variables to control for when " ///
					"household skip or refuse to answer a specific FIES question. " ///
					"Cluster corrected robust standard errors are reported in parentheses " ///
					"(\sym{*} \(p<0.10\), \sym{**} \(p<0.05\), \sym{***} \(p<0.01\)).} \\" ///
					"\end{tabular}")

*/	
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
				
	graph export 	"$fig/coef_sector.png", as(png) replace

	
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
							legend(pos(4) order(2) col(1)) ///
							saving("$fig/coef_sector_did", replace)	

	grc1leg2 		"$fig/coef_sector_did.gph", col(1) ring(0) pos(3) ///
						 commonscheme
				
	graph export 	"$fig/coef_sector_did.png", as(png) replace


	
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
				
	graph export 	"$fig/coef_sexhh.png", as(png) replace

	
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
							legend(pos(4) order(2) col(1)) ///
							saving("$fig/coef_sexhh_did", replace)	
			
	grc1leg2 		"$fig/coef_sexhh_did.gph", col(1) ring(0) pos(3) ///
						 commonscheme
				
	graph export 	"$fig/coef_sexhh_did.png", as(png) replace
	
				
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

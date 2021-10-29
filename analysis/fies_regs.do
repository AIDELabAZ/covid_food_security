* Project: COVID Food Security
* Created on: October 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 29 October 2021
* Stata v.17.0

* does
	* reads in cleaned, regression ready data
	* conducts analysis

* assumes
	* cleaned fies data file
	* ietoolkit.ado


* TO DO:
	* create standardized hunger, meal reduction and anxiety for ancova? 


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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
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
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			std_fsi_21 std_fsi_31 std_fsi_41 std_fsi_51 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			std_fsi_22 std_fsi_32 std_fsi_42 std_fsi_52 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			std_fsi_23 std_fsi_33 std_fsi_43 std_fsi_53 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mld_fsi_2`i'
		sum				mld_fsi if post == 0 & country == `i' ///
							& sector == 1
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mld_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mld_fsi i.sector mld_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mld_fsi_4`i'
		summ			mld_fsi if post == 0 & country == `i' ///
							& sexhh == 1
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mld_fsi_4`i'
	}

* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mld_fsi i.sexhh mld_fsi_y0 fs1_msng fs2_msng fs3_msng /// 
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo			mld_fsi_5`i'
		sum				mld_fsi if post == 0 & country == `i' ///
							& sexhh == 1
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mld_fsi_5`i'
	}

* build table for mild fies index
	esttab 			mld_fsi_25 mld_fsi_35 mld_fsi_45 mld_fsi_55 ///
					using "$tab/mild_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			mld_fsi_21 mld_fsi_31 mld_fsi_41 mld_fsi_51 ///
					using "$tab/mild_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			mld_fsi_22 mld_fsi_32 mld_fsi_42 mld_fsi_52 ///
					using "$tab/mild_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			mld_fsi_23 mld_fsi_33 mld_fsi_43 mld_fsi_53 ///
					using "$tab/mild_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mod_fsi_2`i'
		sum				mod_fsi if post == 0 & country == `i' ///
							& sector == 1
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mod_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mod_fsi i.sector mod_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mod_fsi_4`i'
		summ			mod_fsi if post == 0 & country == `i' ///
							& sexhh == 1
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mod_fsi_4`i'
	}

* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				mod_fsi i.sexhh mod_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
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
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			mod_fsi_21 mod_fsi_31 mod_fsi_41 mod_fsi_51 ///
					using "$tab/mod_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			mod_fsi_22 mod_fsi_32 mod_fsi_42 mod_fsi_52 ///
					using "$tab/mod_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			mod_fsi_23 mod_fsi_33 mod_fsi_43 mod_fsi_53 ///
					using "$tab/mod_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			sev_fsi_2`i'
		sum				sev_fsi if post == 0 & country == `i' ///
							& sector == 1
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : sev_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				sev_fsi i.sector sev_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
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
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			sev_fsi_4`i'
		summ			sev_fsi if post == 0 & country == `i' ///
							& sexhh == 1
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : sev_fsi_4`i'
	}


* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg				sev_fsi i.sexhh sev_fsi_y0 fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
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
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			sev_fsi_21 sev_fsi_31 sev_fsi_41 sev_fsi_51 ///
					using "$tab/sev_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			sev_fsi_22 sev_fsi_32 sev_fsi_42 sev_fsi_52 ///
					using "$tab/sev_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			sev_fsi_23 sev_fsi_33 sev_fsi_43 sev_fsi_53 ///
					using "$tab/sev_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
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
**# 6 - anxiety index regression
************************************************************************

* did - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.post##i.sector fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			anx_fsi_2`i'
		sum				anx_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : anx_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.sector anx_fsi_y0 fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			anx_fsi_3`i'
		sum				anx_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : anx_fsi_3`i'
	}

*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.post##i.sexhh fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			anx_fsi_4`i'
		sum				anx_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : anx_fsi_4`i'
	}
	
* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			anx_fsi i.sexhh anx_fsi_y0 fs1_msng fs2_msng  ///
							[pweight = hhw_covid] if country == `i' & wave > 0, ///
							vce(cluster hhid)
		eststo 			anx_fsi_5`i'
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
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			anx_fsi_21 anx_fsi_31 anx_fsi_41 anx_fsi_51 ///
					using "$tab/anx_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			anx_fsi_22 anx_fsi_32 anx_fsi_42 anx_fsi_52 ///
					using "$tab/anx_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			anx_fsi_23 anx_fsi_33 anx_fsi_43 anx_fsi_53 ///
					using "$tab/anx_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
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
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mea_fsi_2`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_fsi_2`i'
	}

* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.sector mea_fsi_y0 fs3_msng fs4_msng /// 
						fs5_msng [pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mea_fsi_3`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_fsi_3`i'
	}

*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.post##i.sexhh fs3_msng fs4_msng fs5_msng  ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mea_fsi_4`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_fsi_4`i'
	}

* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			mea_fsi i.sexhh mea_fsi_y0 fs3_msng fs4_msng /// 
						fs5_msng [pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			mea_fsi_5`i'
		sum				mea_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : mea_fsi_5`i'
	}
	
* build table for meal reduction index
	esttab 			mea_fsi_25 mea_fsi_35 mea_fsi_45 mea_fsi_55 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			mea_fsi_21 mea_fsi_31 mea_fsi_41 mea_fsi_51 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			mea_fsi_22 mea_fsi_32 mea_fsi_42 mea_fsi_52 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			mea_fsi_23 mea_fsi_33 mea_fsi_43 mea_fsi_53 ///
					using "$tab/meal_reduct_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
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
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			hun_fsi_2`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_fsi_2`i'
	}
	
* ancova - sector
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.sector hun_fsi_y0 fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			hun_fsi_3`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_fsi_3`i'
	}
	
*did - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.post##i.sexhh fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			hun_fsi_4`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_fsi_4`i'
	}
	
* ancova - sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
		reg 			hun_fsi i.sexhh hun_fsi_y0 fs6_msng fs7_msng fs8_msng  ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo 			hun_fsi_5`i'
		sum				hun_fsi if post == 0 & country == `i' ///
							[aweight =  hhw_covid]
		estadd scalar	mu = r(mean)
		estadd loc		missing "Yes" : hun_fsi_5`i'
	}
	
* build table for meal reduction index
	esttab 			hun_fsi_25 hun_fsi_35 hun_fsi_45 hun_fsi_55 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{4}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"& \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			hun_fsi_21 hun_fsi_31 hun_fsi_41 hun_fsi_51 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			hun_fsi_22 hun_fsi_32 hun_fsi_42 hun_fsi_52 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			hun_fsi_23 hun_fsi_33 hun_fsi_43 hun_fsi_53 ///
					using "$tab/hunger_i.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					" & \multicolumn{4}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
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
**# 7 - lorin's code testing section
************************************************************************ 

* color palette
	colorpalette economist
	colorpalette economist, globals
* test coef plot for Burkina Faso urban/rural

	coefplot			std_fsi_25 std_fsi_35 mld_fsi_25 mld_fsi_35 ///
							mod_fsi_25 mod_fsi_35 sev_fsi_25 sev_fsi_35 ///
							anx_fsi_25 anx_fsi_35 mea_fsi_25 mea_fsi_35 ///
							hun_fsi_25 hun_fsi_35, drop(*_cons *post 	///
							std_fsi_y0 mld_fsi_y0 mod_fsi_y0 sev_fsi_y0 ///
							anx_fsi_y0 hun_fsi_y0 mea_fsi_y0)
							xline(0, lcolor(maroon))  ///
							xtitle("Burkina Faso Urban Rural FIES Regression") ///
							levels(95) msymbol(D) mfcolor(white) pstyle(p2) ///
							ciopts(lwidth(*3) lcolor(*3) ///
							order(std_fsi_25 mld_fsi_25 mod_fsi_25 sev_fsi_25 ///
								anx_fsi_25 mea_fsi_25 hun_fsi_25 std_fsi_35 ///
								mld_fsi_35 mod_fsi_35 sev_fsi_35 ///
								anx_fsi_35 mea_fsi_35 hun_fsi_35)
				
					





























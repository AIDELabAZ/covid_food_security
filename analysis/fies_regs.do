* Project: COVID Food Security
* Created on: October 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 14 October 2021
* Stata v.17.0

* does
	* reads in cleaned, regression ready data
	* conducts analysis

* assumes
	* cleaned fies data file
	* ietoolkit.ado


* TO DO:
	* copy over Bloem reg code
	* everything!!!


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

* relabel
	lab def			post 0 "pre-COVID" 1 "COVID", replace
	
* clear svyset and eststo
	svyset, clear
	svyset	[pweight = hhw_covid]

	eststo clear

************************************************************************
**# 2 - raw fies index regression
************************************************************************

* first-difference - sector
	levelsof 		country, local(levels)
	foreach 		i of local levels {
		reg 			std_fsi_wt i.post fs1_msng fs2_msng fs3_msng ///
							fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
							[pweight = hhw_covid] if country == `i', ///
							vce(cluster hhid)
		eststo  		std_fsi_1`i'
		sum 			std_fsi_wt if post == 0 & country == `i' ///
							[aweight = hhw_covid]
		estadd scalar 	mu = r(mean)
		estadd loc 		missing "Yes" : std_fsi_1`i'
	}

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
	esttab 			std_fsi_15 std_fsi_25 std_fsi_35 std_fsi_45 std_fsi_55 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					"\multicolumn{6}{c}{\textbf{Panel A: Burkina Faso}} \\ [-1ex] ", ///
					nolabel) prehead("\begin{tabular}{l*{5}{c}} \\[-1.8ex]\hline " ///
					"\hline \\[-1.8ex] &  & " ///
					"\multicolumn{2}{c}{Urban-Rural} & \multicolumn{2}{c}{Female-Male} \\ "  ///
					"\cmidrule(lr){3-4} \cmidrule(lr){5-6} \\ "  ///
					"& \multicolumn{1}{c}{First-Diff} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} & \multicolumn{1}{c}{Diff-in-Diff} " ///
					"& \multicolumn{1}{c}{ANCOVA} \\") drop(*msng _cons *y0) ///
					fragment nogap replace 
		
	esttab 			std_fsi_11 std_fsi_21 std_fsi_31 std_fsi_41 std_fsi_51 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					"\multicolumn{5}{c}{\textbf{Panel B: Ethiopia}} \\ [-1ex] ",  ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
					
	esttab 			std_fsi_12 std_fsi_22 std_fsi_32 std_fsi_42 std_fsi_52 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					"\multicolumn{5}{c}{\textbf{Panel C: Malawi}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append
		
	esttab 			std_fsi_13 std_fsi_23 std_fsi_33 std_fsi_43 std_fsi_53 ///
					using "$tab/std_fsi.tex", booktabs label b(3) se(a2) ///
					r2(3) nonumbers nomtitles nobaselevels compress ///
					scalar("mu Baseline Mean") sfmt(3) refcat(1.post ///
					"\multicolumn{5}{c}{\textbf{Panel D: Nigeria}} \\ [-1ex] ", ///
					nolabel) drop(*msng _cons *y0) ///
					fragment nogap append postfoot("\\[-1.8ex]\hline \hline \\[-1.8ex] " ///
					"\multicolumn{6}{p{\linewidth}}{\footnotesize  \textit{Note}: " ///
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

* first difference
	levelsof		country, local(levels)
	foreach			i of local levels {
	reg mild_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid] ///
		if country == `i', cluster(hhid)
		eststo mild_fs_1`i'
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
	areg mild_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid] ///
		if country == `i', absorb(hhid) cluster(hhid)
		eststo mild_fs_2`i'
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}

* did sector
	levelsof		country, local(levels)
	foreach			i of local levels {
	reg mild_fs i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid] if country == `i', cluster(hhid)
		eststo mild_fs_3`i'
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
	areg mild_fs i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid] ///
		if country == `i', absorb(hhid) cluster(hhid)
		eststo mild_fs_4`i'
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}

* did sexhh
	levelsof		country, local(levels)
	foreach			i of local levels {
	bys country: reg mild_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid] if country == `i', cluster(hhid)
		eststo mild_fs_5`i'
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}
	
	levelsof		country, local(levels)
	foreach			i of local levels {
	areg mild_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid] ///
		if country == `i', absorb(hhid) cluster(hhid)
		eststo mild_fs_6`i'
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mild_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}
				
									
************************************************************************
**# 4 - moderate fies index regression
************************************************************************

* first difference
	bys country:	reg mod_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
		eststo mod_fs_1
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mod_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mod_fs_2
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

* did sector
	bys country:	reg mod_fs i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo mod_fs_3
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mod_fs i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mod_fs_4
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

*did sexhh
	bys country:	reg mod_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo mod_fs_5
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg mod_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo mod_fs_6
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum mod_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

				
************************************************************************
**# 5 - severe fies index regression
************************************************************************

* first difference
	bys country:	reg sev_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
		eststo sev_fs_1
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg sev_fs i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo sev_fs_2
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

* did sector
	bys country:	reg sev_fs i.post##i.sector fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo sev_fs_3
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg sev_fs i.post##i.sector fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo sev_fs_4
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

*did sexhh
	bys country:	reg sev_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng /// 
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng ///
		[pweight = hhw_covid], cluster(hhid)
		eststo sev_fs_5
		estadd loc FE		"No"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sexhh == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

	bys country:	areg sev_fs i.post##i.sexhh fs1_msng fs2_msng fs3_msng ///
		fs4_msng fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], ///
		absorb(hhid) cluster(hhid)
		eststo sev_fs_6
		estadd loc FE		"Yes"
		estadd loc Missing	"Yes"
				sum sev_fs if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

* without controlling for missing variables

* first difference
	bys country: reg std_fsi_wt i.post [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_1
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	
	bys country: areg std_fsi_wt i.post [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_2
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)

*did sector
	bys country: reg std_fsi_wt i.post##i.urban [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_1
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	
	bys country: areg std_fsi_wt i.post [pweight = hhw_covid], cluster(hhid)
	eststo std_fsi_2
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 & sector == 0 [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)


				
************************************************************************
**# 6 - descriptive analysis
************************************************************************

* first table

bys country: iebaltab ///
				fs1_nr fs2_nr fs3_nr fs4_nr fs5_nr fs6_nr fs7_nr fs8_nr ///
				[pweight = hhw_covid] if post == 1, ///
				grpvar(urban) order(1 0) grplabels(1 "Urban" @ 0 "Rural")	///
				vce(cluster hhid) ///
				
	 
	*/			
************************************************************************
**# 7 - lorin's code testing section
************************************************************************ 

	*levelsof country, local(levels)
	
/*	bys country: reg std_fsi_wt i.post fs1_msng fs2_msng fs3_msng fs4_msng ///
		fs5_msng fs6_msng fs7_msng fs8_msng [pweight = hhw_covid], cluster(hhid)
			foreach l in local levels {
				eststo  std_fsi_1`l'
			}
				estadd loc FE  		"No"
				estadd loc Missing      "Yes"
					summ std_fsi_wt if post==0 [aweight = hhw_covid]
					estadd scalar C_mean = r(mean)	 
*/	 

	
	
	levelsof 		country, local(levels)
	foreach 		i of local levels {
	reg std_fsi_wt i.post [pweight = hhw_covid] if country == `i' , cluster(hhid)  
	eststo std_fsi_1`i'
	estadd loc FE 		"Yes"
				sum std_fsi_wt if post == 0 & country == `i' [aweight = hhw_covid]
				estadd scalar C_mean = r(mean)
	}
	 
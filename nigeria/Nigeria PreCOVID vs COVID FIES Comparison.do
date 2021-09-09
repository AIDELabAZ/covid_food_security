clear all
capture log close
set more off

global precovid "C:\Users\wb303679\OneDrive - WBG\LSMS-ISA High-Frequency Phone Surveys on COVID-19\Syntax Files and Processed Data\FIES Estimation\Pre-COVID-19 LSMS-ISA Surveys\"

global covid "C:\Users\wb303679\OneDrive - WBG\LSMS-ISA High-Frequency Phone Surveys on COVID-19\Syntax Files and Processed Data\FIES Estimation\Phone Surveys\"

global quintiles "C:\Users\wb303679\OneDrive - WBG\LSMS-ISA High-Frequency Phone Surveys on COVID-19\Syntax Files and Processed Data\Consumption Aggregates\Quintiles for Phone Surveys\"

use "$precovid\FIES_PreCOVID.dta", clear
keep if country=="Nigeria"

/*

In Nigeria LSMS-ISA, the FIES module was administered twice – once in post-planting visit (July 2018-September 2019), and once in post-harvest (January 2019- February 2018). 

Same as the FIES module include in the phone survey, the module had a reference period of last 30 days, and a reference population of adult household members. 

There are 4 samples for which FIES estimates could be derived from pre-COVID-19 Nigeria LSMS-ISA dataset, identified by the variable sample:

1.	Harvest Full – Entire Nigeria LSMS-ISA sample that received FIES module in the post-harvest visit

2.	Harvest Post-COVID – Portion of the Nigeria LSMS-ISA sample that received the FIES module in post-harvest visit and that were also interviewed by the phone survey (in Round 1)

3.	Planting Full – Entire Nigeria LSMS-ISA sample that received FIES module in the post-planting visit

4.	Planting Post-COVID – Portion of the Nigeria LSMS-ISA sample that received the FIES module in post-planting visit and that were also interviewed by the phone survey (in Round 1)

To compare pre- vs. post-COVID-levels and in view of the data collection period, I would use Planting Post-COVID sample. And in terms of weights, I would use a common weight for pre- and post-COVID FIES variable and take the popweight_adult included in the phone survey database that I shared (so, the adjusted weight computed post-COVID, as part of the phone survey).

*/

keep if sample=="Planting Post-COVID"

keep HHID p_mod p_sev 

gen time = 0

tempfile precovid
save `precovid'

use "$covid\FIES_PostCOVID.dta", clear
keep if country=="Nigeria" & round==2
/*Round 2 = June 2020 */

mmerge HHID using `precovid', ukeep(HHID)
keep if _merge==3
drop _merge

tempfile covid
save `covid'

keep HHID urban popweight_adult

tempfile analysis
save `analysis'

use `precovid', clear
mmerge HHID using `analysis'
assert _merge==3
drop _merge

tempfile precovid
save `precovid'

use `covid', clear

keep HHID urban popweight_adult p_mod p_sev

gen time = 1

append using `precovid'

encode HHID, gen(hhid)

xtset hhid time

/* NATIONAL-LEVEL */

xtreg p_mod i.time [pweight=popweight_adult], fe
xtreg p_sev i.time [pweight=popweight_adult], fe

/*URBAN */

xtreg p_mod i.time [pweight=popweight_adult] if urban==1, fe
xtreg p_sev i.time [pweight=popweight_adult] if urban==1, fe

/*RURAL*/

xtreg p_mod i.time [pweight=popweight_adult] if urban==0, fe
xtreg p_sev i.time [pweight=popweight_adult] if urban==0, fe

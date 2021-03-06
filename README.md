# Food Insecurity During the First Year of the COVID-19 Pandemic in Four African Countries: Replication Code
This README describes the directory structure & should enable users to replicate all tables and figures for work related to Rudin-Rush, L. Michler, J.D., Josephson, A., and Bloem, J.R. (2022). "Food Insecurity During the First Year of the COVID-19 Pandemic in Four African Countries." *Food Policy 111*: 102306. The relevant survey data are available under under the High-Frequency Phone Survey collection: http://bit.ly/microdata-hfps.   

[![DOI](https://zenodo.org/badge/404811321.svg)](https://zenodo.org/badge/latestdoi/404811321)

Last update: June 2022. 

For issues or concerns with this repo, please contact Anna Josephson or Jeffrey Michler.

 ## Index

 - [Introduction](#introduction)
 - [Data](#data)
 - [Data cleaning](#data-cleaning)
 - [Pre-requisites](#pre-requisites)
 - [Folder structure](#folder-structure)

## Introduction
We document trends in food security up to one full year after the onset of the COVID-19 pandemic in four African countries. Using household-level data collected by the World Bank, we highlight differences over time amid the pandemic, between rural and urban areas, and between female-headed and male-headed households within Burkina Faso, Ethiopia, Malawi, and Nigeria. We first observe a sharp increase in food insecurity during the early months of the pandemic with a subsequent gradual decline. Next, we find that food insecurity has increased more in rural areas than in urban areas relative to pre-pandemic data within each of these countries. Finally, we do not find a systematic difference in changes in food insecurity between female-headed and male-headed households. These trends complement previous microeconomic analysis studying short-term changes in food security associated with the pandemic and existing macroeconomic projections.

Contributors:
* Jeffrey Bloem
* Ann Furbush 
* Anna Josephson
* Jeffrey D. Michler
* Lorin Rudin-Rush

As described in more detail below, the `.do`-file scripts variously go through each step, from cleaning raw data to analysis.

## Data 

The publicly-available data for each survey round is coupled with a basic information document, interview manual, and questionnaire for that round, which can be accessed through: 
 - Burkina Faso: http://bit.ly/burkinafaso-phonesurvey
 - Ethiopia: http://bit.ly/ethiopia-phonesurvey 
 - Malawi: http://bit.ly/malawi-phonesurvey 
 - Nigeria: http://bit.ly/nigeria-phonesurvey
 
The approach to the phone survey questionnaire design and sampling is comparable across countries. It is informed by the template questionnaire and the phone survey sampling guidelines that have been publicly made available by the World Bank. These can be accessed through: 
 - Template Questionnaire: http://bit.ly/templateqx 
 - Manual: http://bit.ly/interviewermanual
 - Sampling Guidelines: http://bit.ly/samplingguidelines.

### Pre-requisites

The data processing and analysis requires a number of user-written Stata programs:
   * 1. `grc1leg2` (v1.6 or earlier | v2.12 or later)
   * 2. `palettes`
   * 3. `colrspace`
   * 4. `blindschemes`
   * 5. `estout`
   * 6. `carryforward`
   * 7. `xfill`

The `projectdo.do` file will help you install these.

## Development Environment

### Step 1

Clone this  repository https://github.com/AIDELabAZ/covid_food_security. The general repo structure looks as follows:<br>

```stata
covid_food_security
???????????????README.md
???????????????projectdo.do
???????????????LICENSE
???????????????country             /* one dir for each country */
???    ?????????wave             /* one file for each wave */
???    ?????????master
???????????????analysis            /* overall analysis */
     ?????????pnl_cleaning
     ?????????food_security
```

### Step 2

Open the projectdo.do file and update the global filepath with your username in Section 0 (a).

   ```
    if `"`c(username)'"' == "USERNAME" {
       	global 		code  	"C:/Users/USERNAME/git/evolving_impacts_covid_africa"
		global 		data	"C:/Users/USERNAME/evolving_impacts/data"
		global 		output  "C:/Users/USERNAME/evolving_impacts/output"
    }
   ```


### Step 3

Download microdata Stata files from the following links. You will need to create an account with the World Bank if you do not already have one and will be asked to provide a reason for downloading the data. Once data are downloaded, save the data files to the corresponding folders created in Step 3. 
 - Burkina Faso Waves 1-11: http://bit.ly/burkinafaso-phonesurvey
 - Ethiopia Waves 1-12: http://bit.ly/ethiopia-phonesurvey 
 - Malawi Waves 1-12: http://bit.ly/malawi-phonesurvey 
 - Nigeria Waves 1-12: http://bit.ly/nigeria-phonesurvey
 
### Step 4

Run the `projectdo.do` file. Output graphs will be saved to the `output` folder. 

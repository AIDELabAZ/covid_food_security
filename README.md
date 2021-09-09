# Impacts of COVID-19 on food security in rural and urban Sub-Saharan Africa
This README describes the directory structure & should enable users to replicate all tables and figures for work related to food security and rural/urban heterogeneity during teh COVID-19 pandemic. The relevant survey data are available under under the High-Frequency Phone Survey collection: http://bit.ly/microdata-hfps.   

 ## Index

 - [Introduction](#introduction)
 - [Data](#data)
 - [Data cleaning](#data-cleaning)
 - [Pre-requisites](#pre-requisites)
 - [Folder structure](#folder-structure)

## Introduction

Contributors:
* Jeffrey Bloem
* Ann Furbush 
* Anna Josephson
* Jeffrey D. Michler
* Lorin Rudin-Rush

As described in more detail below, scripts various go through each step, from cleaning raw data to analysis.

## Data 

The publicly-available data for each survey round is coupled with a basic information document, interview manual, and questionnaire for that round, which can be accessed through:
 - Burkina Faso: https://microdata.worldbank.org/index.php/catalog/3768
 - Ethiopia: https://microdata.worldbank.org/index.php/catalog/3716
 - Malawi: https://microdata.worldbank.org/index.php/catalog/3766
 - Nigeria: https://microdata.worldbank.org/index.php/catalog/3712
 
The approach to the phone survey questionnaire design and sampling is comparable across countries. It is informed by the template questionnaire and the phone survey sampling guidelines that have been publicly made available by the World Bank. These can be accessed through: 
 - Template Questionnaire: http://bit.ly/templateqx 
 - Manual: http://bit.ly/interviewermanual
 - Sampling Guidelines: http://bit.ly/samplingguidelines.

## Data cleaning

The code in this repository cleans the raw phone surveys and replicates material (both in text and supplementary material) related to "Impacts of COVID-19 on Food Security in Rural and Urban Sub-Saharan Africa". 

### Pre-requisites

#### Stata reqs

The data processing and analysis requires a number of user-written Stata programs:
   * 1. `blindschemes`
   * 2. `estout`
   * 3. `mdesc`
   * 4. `grc1leg2`
   * 5. `distinct`
   * 6. `winsor2`
   * 7. `palettes`
   * 8. `catplot`
   * 9. `colrspace` 

#### Folder structure

The general repo structure looks as follows:<br>

```stata
wb_covid
├────README.md
├────projectdo.do
├────LICENSE
│    
├────country             /* one dir for each country */
│    ├──household_data
│    │  └──wave          /* one dir for each wave */
│    └──household_cleaning_code 
│
│────Analysis            /* overall analysis */
│    ├──code
│    └──output
│       ├──tables
│       └──figures
│   
└────config
```

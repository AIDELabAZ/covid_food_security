* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Stata v.17.0

* does
	* establishes an identical workspace between users
	* sets globals that define absolute paths
	* serves as the starting point to find any do-file, dataset or output
	* loads any user written packages needed for analysis

* assumes
	* access to all data and code

* TO DO:
	* add all do-files


************************************************************************
**# 0 - setup
************************************************************************

* set $pack to 0 to skip package installation
	global 			pack 	0
		
* Specify Stata version in use
    global stataVersion 17.0    // set Stata version
    version $stataVersion

	
************************************************************************
**# 0 (a) - Create user specific paths
************************************************************************


* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/AIDELabAZ/covid_food_security"
		global 		data	"G:/My Drive/wb_covid/data"
		global 		output_f "G:/My Drive/wb_covid/output/food_security"
    }

    if `"`c(username)'"' == "aljosephson" {
        global 		code  	"C:/Users/aljosephson/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
		global 		output_f "G:/My Drive/wb_covid/output/food_security"
    }

	if `"`c(username)'"' == "annfu" {
		global 		code  	"C:/Users/annfu/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
		global 		output_f "G:/My Drive/wb_covid/output/food_security"
	}
	
	if `"`c(username)'"' == "Lorin Rudin-Rush" {
		global 		code  	"C:/Users/Lorin Rudin-Rush/Documents/GitHub/covid_food_security"
		global 		data	"G:/My Drive/wb_covid/data"
		global 		output_f "G:/My Drive/wb_covid/output/food_security"
	}
	
	
************************************************************************
**# 0 (b) - Check if any required packages are installed:
************************************************************************

* install packages if global is set to 1
if $pack == 1 {
	
	* for packages/commands, make a local containing any required packages
		loc userpack "blindschemes mdesc estout distinct winsor2 palettes catplot grc1leg2 colrspace" 
	
	* install packages that are on ssc	
		foreach package in `userpack' {
			capture : which `package', all
			if (_rc) {
				capture window stopbox rusure "You are missing some packages." "Do you want to install `package'?"
				if _rc == 0 {
					capture ssc install `package', replace
					if (_rc) {
						window stopbox rusure `"This package is not on SSC. Do you want to proceed without it?"'
					}
				}
				else {
					exit 199
				}
			}
		}

	* install -xfill- package
		net install xfill, replace from(https://www.sealedenvelope.com/)
		
	* install -customsave package
		net install StataConfig, ///
		from(https://raw.githubusercontent.com/etjernst/Materials/master/stata/) replace

	* update all ado files
		ado update, update

	* set graph and Stata preferences
		set scheme plotplain, perm
		set more off
}


************************************************************************
**# 1 - run household data cleaning .do file
************************************************************************

*	do 			"$code/analysis/cleaning/pnl_cleaning.do" 	//runs all cleaning files 
	
	
************************************************************************
**# 2 - run analysis .do files
************************************************************************



/* END */
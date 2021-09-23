* Project: COVID Food Security
* Created on: July 2020
* Created by: jdm
* Edited by: lirr
* Last edit: 2 September 2021
* Stata v.17.0

* does
	* merges together all countries
	* renames variables
	* output cleaned panel data

* assumes
	* cleaned country data

* TO DO:
	* add new rounds


************************************************************************
**# 0 - setup
************************************************************************

* run do files for each country (takes a little while to run)
	run				"$code/ethiopia/eth_fies_0"
	run 			"$code/malawi/mwi_fies_0"
	run				"$code/nigeria/nga_fies_pp0"
	run				"$code/nigeria/nga_fies_ph0"
	run 			"$code/burkina_faso/bf_fies_0"

* define
	global  root    =	"$data/analysis"
	global	eth		=	"$data/ethiopia/refined/wave_00"
	global	mwi		=	"$data/malawi/refined/wave_00"
	global	nga		=	"$data/nigeria/refined/wave_00"
	global	bf		=	"$data/burkina_faso/refined/wave_00"
	global	export	=	"$data/analysis/food_security"
	global	logout	=	"$data/analysis/food_security/logs"

* open log
	cap log 			close
	log using			"$logout/pnl_cleaning_fies", append


************************************************************************
**# 1 - build data set
************************************************************************

* read in data
	use				"$root/lsms_panel", replace

* append baseline 
	append 			using "$eth/r0_fies"
	append 			using "$mwi/r0_fies"
	append 			using "$nga/r-1_fies"
	append 			using "$nga/r0_fies"
	append 			using "$bf/r0_fies"
/* END */

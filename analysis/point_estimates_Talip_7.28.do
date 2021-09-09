* open log
	cap log 		close
	log using		"G:\My Drive\wb_covid\data\analysis\logs\point_estimates", append

	
* safety precautions behavior in wave 1
	forval 			c = 1/5 {
	    mean 			bh_3 bh_1 bh_2 [pweight = phw_cs] if country == `c' & wave_orig == 1
	}
	
* safety precautions behavior over waves
	foreach 		c in 1 2 4 5 {
	    mean 			bh_3 bh_1 bh_2 [pweight = phw_cs] if country == `c', over(wave) 
	}	
	
	
* misconceptions wave 1
	foreach 		c in 2 4 {
	    foreach 		m in 2 3 4 5 {
		    replace 		myth_`m' = . if myth_`m' == 3
			tab 			myth_`m'  [aweight = phw_cs] if country == `c'
		}
	}
	
* business revenue
	forval 			c = 1/5 {
		tab 			bus_emp_inc wave if country == `c'
	}
	
* current employment 
	forval 			c = 1/5 {
	    mean 			emp [pweight = ahw_cs] if country == `c', over(wave)
	}
	
* FIES
	forval 			c = 1/5 {
	    mean 			p_mod [pweight = wt_18] if country == `c', over(wave)
	}
	
* concerns wave 1
	mean 			concern_1 concern_2 [aweight = hhw_cs] if country == 1 & wave == 6
	mean 			concern_1 concern_2 [aweight = hhw_cs] if country == 2 & wave == 6
	mean 			concern_1 concern_2 [aweight = hhw_cs] if country == 3 & wave == 5
	mean 			concern_1 concern_2 [aweight = hhw_cs] if country == 4 & wave == 6
	
* concerns over time	
	foreach 		c in 2 3 4 {
	    mean 			concern_1 concern_2 [aweight = hhw_cs] if country == `c', over(wave)
	}
	
* coping
	forval 			c = 1/5 {
	    preserve
	    egen 			temp = total(cope_none), by (country wave)
		keep if 		temp != 0 & country == `c'
		foreach 		var in cope_11 cope_9 cope_10 cope_3 cope_1 cope_none {
			mean 			`var' [pweight = hhw_cs] if country == `c', over(wave)
		}
		restore
	}

* assistance 
	forval 			c = 1/5 {
	    mean 			asst_cash asst_food asst_kind asst_any [pweight = hhw_cs] ///
							if country == `c', over(wave) 
	}

* educational engagement 
	forval 			c = 1/5 {
		mean 			edu_act [pweight = hhw_cs] if country == `c', over(wave) 
	}
	

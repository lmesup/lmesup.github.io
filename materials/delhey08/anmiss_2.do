	//  Fraction of Missings for Comparison-Variables by Coutry
	//  Creator: kohler@wz-berlin.de
	
	
	//  INTRO 
	//  -----
	
version 9.0
	clear
	set more off
	set memory 32m
	set scheme s1mono
	
	capture use data01
	if _rc==601 {
		do crdata01
		use data01
	}
	
	
	//  Collapse and Reshape
	//  --------------------

	local i 1
	foreach var of varlist compeco compemp compqual {
		gen mis`i++' = `var' >= .
	}

	collapse (mean) mis1-mis3 eu [aw=weight], by(ctrname)
	gen mean = (mis1 + mis2 + mis3)/3
	reshape long mis, i(ctrname) j(item)
	label value item item
	label define item 1 "Economy" 2 "Employment" 3 "Quality of life"

	egen axis = axis(mean ctrname), label(ctrname) reverse
	egen imeans = mean(mis), by(item)
	
	// Graph
	// -----

	// in percent
	replace mis = mis * 100
	replace imeans = imeans*100
	
	graph twoway  ///
	  || line axis imeans, lcolor(black)                                     ///
	  || scatter axis mis if eu == 1, ms(O) mfcolor(white) mlcolor(black)  ///
	  || scatter axis mis if eu == 2, ms(O) mfcolor(black) mlcolor(black)  ///
	  || , by(item, ///
	  note("Own calculations. Do-File: anmiss_2.do") ///
	  title("Figure 1: Country-EU-comparisons") subtitle("Share of missing answers by survey-country") ///
	  legend(off) col(3)) ///
	  ylabel(1(1)25, valuelabel angle(0) grid gstyle(dot) ) ytitle("")       ///
	  xlabel(0(5)15) 
	graph export anmiss_2.eps, replace

	exit
	

	  
	

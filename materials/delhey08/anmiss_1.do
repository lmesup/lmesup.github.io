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
	
	
	
	//  Collapse
	//  --------
	
	gen mcompqual = compqual >= .
	gen identical = compqual == 0
	collapse (mean) mean = mcompqual identical eu [aw=weight], by(ctrname)


	// Preparations
	// ------------

	egen axis = axis(mean), label(ctrname) reverse
	separate mean, by(eu)

	sum mean1
	local mean1 = r(mean)
	sum mean2
	local mean2 = r(mean)

	tab eu, sum(identical)
	
	// Graph
	// -----

	graph twoway  ///
	  || sc axis mean1, ms(O) mfcolor(white) mlcolor(black)  ///
	  || sc axis mean2, ms(O) mfcolor(black) mlcolor(black)  ///
	  , ylabel(1(1)25, valuelabel angle(0) grid gstyle(dot) ) ytitle("")   ///
	  xlabel(0 "0 %" .025 "2.5 %" .05 "5 %" .075 "7.5 %" .1 "10 %")  ///
	  ysize(6) legend(off) 
	graph export anmiss_1.eps, replace

	exit
	
	  
	  
	

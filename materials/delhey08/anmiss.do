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
	
	foreach var of varlist compeco-compqual {
		gen m`var' = `var' >= .
	}

	collapse (mean) mcompeco-mcompqual eu [aw=weight], by(ctrname)


	// Preparations
	// ------------

	egen high = rmax(mcomp*)
	egen low = rmin(mcomp*)
	egen mean = rmean(mcomp*)

	egen axis = axis(mean), label(ctrname) reverse
	separate mean, by(eu)
	
	// Graph
	// -----

	graph twoway  ///
	  || rspike high low axis, horizontal lcolor(black)  ///
	  || sc axis mean1, ms(O) mfcolor(white) mlcolor(black)  ///
	  || sc axis mean2, ms(O) mfcolor(black) mlcolor(black)  ///
	  , ylabel(1(1)25, valuelabel angle(0) grid gstyle(dot) ) ytitle("")   ///
	    xlabel(0 "0 %" .05 "5 %" .1 "10 %" .15 "15 %")  ///
	  ysize(6) legend(off) 
	graph export anmiss.eps, replace

	exit
	
	  
	  
	

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
	



	// Keep the Variable labels
	local i 1
	foreach var of varlist compeco-compqual {
		local labdef `"`labdef' `i++' `"`=subinstr("`:var lab `var''","Own Country-EU:","",.)'"'"'
	}

	// Histograms by Country
	sort iso3166_2
	merge iso3166_2 using agg, keep(gdp2003)
	egen sctry = axis(gdp2003), label(ctrname)
	local i 1
	foreach var of varlist compeco-compqual {
		histogram `var', by(sctry, note("") rows(5)) discrete xlabel(-2(1)2) xscale(range(-2 2))  percent
		graph export ancomp_hist`i++'.eps, replace
	}

	//  Collapse
	//  --------

	collapse (mean) compeco-compqual eu [aw=weight], by(ctrname)


	// Preparations
	// ------------

	egen high = rmax(comp*)
	egen low = rmin(comp*)
	egen mean = rmean(comp*)

	egen axis = axis(mean), label(ctrname) reverse
	separate mean, by(eu)
	
	// Graphs
	// ------

	graph twoway  ///
	  || rspike high low axis, horizontal lcolor(black)                    ///
	  || sc axis mean1, ms(O) mfcolor(white) mlcolor(black)                ///
	  || sc axis mean2, ms(O) mfcolor(black) mlcolor(black)                ///
	  , ylabel(1(1)25, valuelabel angle(0) grid gstyle(dot) ) ytitle("")   ///
	    xlabel(-2(1)2) xline(0)  ///
	  ysize(6) legend(off) 
	graph export ancomp1.eps, replace



	keep ctrname comp* eu axis
	local i 1
	foreach var of varlist comp* {
		ren `var' comp`i++'
	}
		
	reshape long comp, i(ctrname) j(item)
	label value item item
	label define item `labdef'

	separate axis, by(eu)
	gen compl = 0
	graph twoway  ///
	  || sc axis1 axis2 comp, ms(O O) mfcolor(white black) mlcolor(black black)       ///
	  || , ylabel(1(1)25, valuelabel angle(0) grid gstyle(dot)) ytitle("")           ///
	    xlabel(-2(1)2)  xline(0)                                                      ///
	  ysize(7) legend(off) by(item, rows(2) note("") legend(off) ) xtitle("")
	graph export ancomp2.eps, replace



	exit
	
	  
	  
	

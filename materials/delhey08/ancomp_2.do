	//  Distributions of Comparison-Variables by Country
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
		replace `var' = `var' + 3
		levelsof `var', local(K)
		foreach k of local K {
			gen comp`k'`i' = `var'==`k' if `var' < .
		}
		local i = `i'+1
	}

	collapse (mean) compeco compemp compqual comp11-comp53 eu [aw=weight], by(ctrname)
	egen mean = rmean(compeco-compqual)
	reshape long comp1 comp2 comp3 comp4 comp5, i(ctrname) j(item)

	label value item item
	label define item 1 "Economy" 2 "Employment"  3 "Quality of life"

	replace eu = 2-eu
	egen axis = axis(eu mean), label(ctrname) gap

	
	// Graph
	// -----

	replace comp2 = comp1 + comp2
	replace comp3 = comp2 + comp3
	replace comp4 = comp3 + comp4
	replace comp5 = comp4 + comp5
		
	graph twoway                                                               ///
	  bar comp5 comp4 comp3 comp2 comp1 axis , horizontal                      ///
	    fcolor(gs16 gs12 gs8 gs4 gs0) lcolor(black..)  lwidth(thin..)         ///
	  by(item, ///
	  note("Own calculations. Do-File: ancomp_2.do") ///
	  title("Figure 2: Outcome of country-EU comparisons") ///
	  subtitle("Cumulated percentages of responses") rows(1) legend(ring(0) pos(6)))            ///
	  ylabel(1(1)10 12(1)26, valuelabel angle(0)) ytitle("")                  ///
	  xlabel(0(.25)1) xline(.5) legend(col(3) order(5 "Def. less good" 4 "Less good" 3 "Identical" 2 "Somewhat better" 1 "Much better"))
	graph export ancomp_2.eps, replace

	exit
	

	  
	

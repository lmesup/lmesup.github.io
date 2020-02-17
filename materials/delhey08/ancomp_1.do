	//  Fraction of Missings for Comparison-Variables by Coutry
	//  Creator: kohler@wz-berlin.de
	
	
	//  INTRO 
	//  -----
	
version 9.0
	clear
	set more off
	set memory 32m
	set scheme s1mono
	
	capture use ctrname compqual weight using data01
	if _rc==601 {
		do crdata01
		use data01
	}
	

	// Calculate Weighted(!) Fractions
	tab compqual, gen(compqual)
	collapse (mean) compqual* [aw=weight], by(ctrname)
	
	// Sort countries 
	egen sctry = axis(compqual), label(ctrname)
	drop compqual ctrname

	sort sctry
	format compqual* %3.2f
	list sctry compqual*

	// reshape long
	reshape long compqual, i(sctry) j(kat)
	replace compqual = compqual * 100
	replace kat = kat - 3

	// Histograms by Country
	format compqual %8.0g

	graph twoway bar compqual kat ///
	  , by(sctry, note(""))       ///
	   xscale(range(-2 2)) yscale(range(0 80)) ///
	   fcolor(gs12) ytitle("Percent") xtitle("Own countries' vs. EU's quality of life")   ///
	  xlab(-2(1)2) ylab(0(20)80)

	graph export ancomp_1_hist.eps, replace
	

	exit
	
	  
	  
	

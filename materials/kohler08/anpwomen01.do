* Fraction of Women with Confidence Bounds around true-Value
* kohler@wz-berlin.de

version 9

	drop _all
	set memory 90m
	set more off
	
	// EU + CC only 
	use svydat01 if eu 

	keep if weich==1 

	// Calculate fraction and sd of women Make Aggregate Data
	preserve
	collapse (mean) womenbar=women hdi quota eu (sd) womensd = women (count) womenn = women ///
	  , by(survey ctrname)
	tempfile uweigted
	save `uweigted'

	restore 
	collapse (mean) womenbarw = women [aw=weight] , by(survey ctrname)
	tempfile weigted
	save `weigted'

	use `uweigted'
	merge survey ctrname using `weigted', sort
	assert _merge==3
	drop _merge

	// Sort-Order for Countries
	egen ctrsort = axis(eu ctrname), label(ctrname) gap reverse

	// Confidence Intervalls
	gen womenub = .5 + 1.96*sqrt(.5^2/womenn)
	gen womenlb = .5 - 1.96*sqrt(.5^2/womenn)

	// Separate by Quota
	replace quota = 0 if !inlist(quota,0,1) // Quota in GB-Nordirland but not in GB!
	separate womenbar, by(quota)
	
	// Shorter Labels in Graph
	replace survey = "Euromodule" if survey == "Euromodule 2001/02"


	// The Graph
	twoway ///
	  (rbar womenub womenlb ctrsort if inrange(ctrsort,1,4)   /// Confidence Bounds
	  , horizontal color(gs10) sort)                          ///
	  (rbar womenub womenlb ctrsort if inrange(ctrsort,6,15)  /// Confidence Bounds
	  , horizontal color(gs10) sort)                          ///
	  (rbar womenub womenlb ctrsort if inrange(ctrsort,17,31) /// Confidence Bounds
	  , horizontal color(gs10) sort)                          ///
	  (scatter ctrsort womenbar0                              /// Random Selection
	    , ms(O) mcolor(black) )                               ///
	  (scatter ctrsort womenbar1                              /// Quota Selection 
	    , ms(O) mlcolor(black) mfcolor(white))                ///
	  (pcarrow ctrsort womenbar ctrsort womenbarw             /// Arrorws for weigts
 	    if survey != "ESS 2002"  & quota ~= 1                 ///
	    , msize(small) mcolor(black) lcolor(black))           ///
	  (scatteri 0 .5 31 .5, c(l) ms(i) clcolor(fg) clpattern(solid))          ///
	  , by(survey, note("") l1title("") iscale(*.8))          /// Twoway Options 
	    ylab(1(1)4 6(1)15 17(1)31, valuelabel angle(horizontal))            ///
	    legend(rows(1) order(4 "Random" 5 "Quota" 6 "After Weighting")) ///
	  scheme(s1mono) ysize(8.5)
	graph export anpwomen01.eps, replace

	// Some numbers for the text
	count if womenbar < womenlb | womenbar > womenub

	gen problems = womenbar < womenlb | womenbar > womenub
	tab survey problems, row

	gen problemsw = womenbarw < womenlb | womenbarw > womenub
	tab survey problemsw, row
	tab ctrname problems, row

	sum womenn
	list ctrname womenn
	
	exit
	


	
	

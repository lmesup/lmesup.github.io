	// Graph European Turnout-Data


version 8.2
	set more off
	set scheme s1mono
	
	use s_cntry q25 vturnout wcountry using $dublin/eqls_4, clear

	// Drop respondent without right to vote in last election 

	drop if q25 == 3
	gen voter = q25==1 if q25 < .
	
	// Value Labels
	// ------------
	
	lab def yesno 0 "no" 1 "yes"
	
	
   // Collapse
	// --------

	collapse (mean) voter vturnout [aw=wcountry] , by(s_cntry)
	replace voter = voter*100
	sum voter, meanonly
	local mean = r(mean)

	// Merge nice Country-Names
	// -----------------------

	sort s_cntry
	merge s_cntry using isocntry
	assert _merge == 3
	drop _merge


	// Distribution of GDP by country and EU-Status
	// ---------------------------------------------

	graph dot voter vturnout ///
	  , over(ctrde, sort(voter)) exclude0 nofill ///
	  marker(1, mstyle(p1) mcolor(black) ) ///
	  marker(2, mstyle(p1) mlcolor(black) mfcolor(white) ) ///
	  ytitle("Wahlbeteiligung in %") ylabel(40(10)100) ymtick(45(10)95) ///
	  yline(`mean') ///
	  legend(lab(1 "EQLS") lab(2 "UNDP")) ///
	  ysize(3.5) xsize(2.8)
	graph export grturnout.eps, replace
	
	exit
	

* Fraction of Women with Confidence Bounds around true-Value (without Euromodule)
* kohler@wz-berlin.de

version 9

	drop _all
	set memory 90m
	set more off
	
	// EU + CC only 
	use svydat01 if eu
	drop if survey=="Euromodule"

	// Sampling Method
	// ---------------
	
	label define sample ///
	  1 "SRS" ///
	  2 "Cluster + individual register" ///
	  3 "Cluster + address register" ///
	  4 "Cluster + random-route" ///
	  5 "Unspecified" ///
	  6 "Quota" ///

	// EB
	gen sample:sample = 4 if survey == "EB 62.1"

	// EQLS 
	replace sample = 2 if survey == "EQLS 2003"  & ///
	  ( ctrname ==  "Ireland" ///
	  | ctrname ==  "Italy" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "Sweden" ///
	  | ctrname ==  "Czech Republic" ///
	  | ctrname ==  "Estonia" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Latvia" ///
	  | ctrname ==  "Poland" ///
	  | ctrname ==  "Romania" )
	replace sample = 4 if survey == "EQLS 2003" &  sample >= .

	// EVS
	replace sample = 1 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Denmark" ///
	  | ctrname ==  "Iceland" ///
	  | ctrname ==  "Malta" ///
	  )

	replace sample = 2 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Belarus" ///
	  |	ctrname ==  "Ireland" ///
	  | ctrname == "Romania" ///
	  | ctrname == "Sweden" ///
	  | ctrname == "Slovenia" ///
	  )
	
	replace sample = 4 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Germany" ///
	  | ctrname ==  "Greece" ///
	  | ctrname ==  "Bulgaria" ///
	  )
	
	replace sample = 5 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "Belgium" ///
	  | ctrname ==  "Croatia" ///
	  | ctrname ==  "Latvia"  ///
	  | ctrname ==  "Lithuania" ///
	  | ctrname ==  "Netherlands" ///
	  | ctrname ==  "Portugal" ///
	  | ctrname ==  "Poland" ///
	  | ctrname ==  "Ukraine" ///
	  )

	replace sample = 6 if survey == "EVS 1999" & ///
	  (	ctrname ==  "Czech Republic" ///
	  | ctrname ==  "Estonia" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "France" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Italy" ///
  	  | ctrname ==  "Luxembourg" ///
	  | ctrname ==  "Slovakia" ///
	  | ctrname ==  "Spain" ///
	  | ctrname == "Russian Federation"  ///
	  | ctrname == "Turkey"  ///
	  | ctrname ==  "United Kingdom" ///
	  )

	// ISSP
	replace sample = 1 if survey == "ISSP 2002" & ///
	  ( ctrname ==  "Australia" ///
	  | ctrname ==  "Denmark" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "Norway" ///
	  | ctrname ==  "New Zealand" ///
	  | ctrname ==  "Sweden" ///
	  )

	replace sample = 2 if survey == "ISSP 2002" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "Germany" ///
	  | ctrname ==  "Belgium" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Japan" ///
	  | ctrname ==  "Slovenia" ///
	  | ctrname ==  "Taiwan" ///
	  )

	replace sample = 5 if survey == "ISSP 2002" &  sample >= .
		
	replace sample = 6 if survey == "ISSP 2002" & ///
	  (	ctrname ==  "Brazil" ///
	  | ctrname ==  "Netherlands" ///
	  | ctrname ==  "Philippines" ///
	  | ctrname ==  "Slovakia" ///
	  )


	// ESS 2002
	replace sample = 1 if survey == "ESS 2002" & ///
	  ( ctrname == "Denmark" ///
	  | ctrname == "Finland" ///
	  | ctrname == "Sweden" ///
	  )
	replace sample = 2 if survey == "ESS 2002" & ///
	  ( ctrname == "Belgium"  ///
	  | ctrname == "Germany" ///
	  | ctrname == "Hungary" ///
	  | ctrname == "Ireland" ///
	  | ctrname == "Norway" ///
	  | ctrname == "Poland"  ///
	  | ctrname == "Slovenia" ///
	  )

	replace sample = 3 if survey == "ESS 2002" & ///
	  ( ctrname == "Czech Republic"  ///
	  | ctrname == "Greece" ///
	  | ctrname == "Israel" ///
	  | ctrname == "Italy" ///
	  | ctrname == "Luxembourg" ///
	  | ctrname == "Netherlands" ///
	  | ctrname == "Portugal" ///
	  | ctrname == "Spain" ///
	  | ctrname == "Switzerland" ///
	  | ctrname == "United Kingdom" ///
	  )

	replace sample = 4 if survey == "ESS 2002" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "France" ///
	  )

	// Euromodule
	replace sample = 3 if survey == "Euromodule" & ///
	  ( ctrname == "Sweden" ///
	  | ctrname == "Slovenia" ///
	  )

	replace sample = 3 if survey == "Euromodule" & ///
	  ( ctrname == "Hungary" ///
	  | ctrname == "Switzerland" ///
	  | ctrname == "Austria" ///
	  )
	replace sample = 4 if survey == "Euromodule" & ///
	  ( ctrname == "Germany" ///
	  | ctrname == "Spain" ///
	  | ctrname == "Turkey" ///
	  )

	replace sample = 5 if survey == "Euromodule" & ///
	  ( ctrname == "Korea Rep. of" ///
	  )

	replace quota = sample == 6


	// Calculate fraction and sd of women Make Aggregate Data
	preserve
	collapse (mean) womenbar=women hdi quota eu (sd) womensd = women (count) womenn = women ///
	  , by(survey iso3166_2)
	tempfile uweigted
	save `uweigted'

	restore 
	collapse (mean) womenbarw = women [aw=weight] , by(survey iso3166_2)
	tempfile weigted
	save `weigted'

	use `uweigted'
	merge survey iso3166_2 using `weigted', sort
	assert _merge==3
	drop _merge

	// Merge external source
	sort iso3166_2
	merge iso3166_2 using female
	assert _merge == 3
	drop _merge

	// Merge long country-names
	preserve
	use iso3166_2 ctrname using svydat01, clear
	by iso3166_2, sort: keep if _n==1
	tempfile names
	save `names'
	restore

	sort iso3166_2
	merge iso3166_2 using `names', nokeep
	assert _merge == 3
	drop _merge
	
	
	// Sort-Order for Countries
	egen ctrsort = axis(eu ctrname), label(ctrname) gap reverse

	// Confidence Intervalls
	gen womenub = 1.96*sqrt(femun * (1-femun)/womenn)
	gen womenlb = -1.96*sqrt(femun * (1-femun)/womenn)

	// Differences
	replace womenbar = womenbar - femun
	replace womenbarw = womenbarw - femun

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
	  (scatteri 0 0 31 0, c(l) ms(i) clcolor(fg) clpattern(solid))          ///
	  , by(survey, ///
	    title("Figure 2: Proportions of women") ///
	    subtitle("Differences between survey and official sources") ///
	    note(Own calculations. Do-File: anextern01_1.do) ///
	    l1title("") iscale(*.8))          /// 
	    ylab(1(1)4 6(1)15 17(1)31, valuelabel angle(horizontal))            ///
	    legend(rows(1) order(4 "Random" 5 "Quota" 6 "After Weighting")) ///
	  scheme(s1mono) ysize(9) ///
	  
	graph export anextern01_1.eps, replace preview(on)


	// Summariy table 
	gen absdif = abs(womenbar) if !quota
	gen tobig = womenbar < womenlb | womenbar > womenub if ! quota


	// Fraction of countries with best possible solutions
	collapse ///
	  (mean) absdif tobig ///
	  , by(survey)

	// Overall
	sum absdif
	gen relabsdif = 1 - absdif/r(max)
	gen index = relabsdif + (1-tobig)
	gsort - index survey
	format index %2.1f
	format absdif tobig index %3.2f
	
	listtex survey absdif tobig index using anextern01_1.tex, rstyle(tabular) replace 


	
	exit
	


	
	

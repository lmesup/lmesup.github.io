*  P(Women) for H0: P(Women) = .5
* kohler@wz-berlin.de


* History
* ant02.do: Remove Mode of Collection from Results. Descreptive Table.
* ant01.do: First Version
	
version 9
	
	clear
	set memory 80m
	set more off
	set scheme s1mono
	
	use svydat01 if eu & weich == 1 // Note 1
	replace city = 0 if city == .

	// t-values by survey iso3166_2 city
	collapse (mean) womenp=women (count) N=women, by(survey iso3166_2 city) 
	gen woment = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2
	preserve

	// Get the survey characteristics
	use survey-eu inst - gdp using svydat01, clear
	by survey iso3166_2, sort: keep if _n==1
	tempfile agg
	save `agg'
	

	// Bring survey characteristics back in
	restore
	merge survey iso3166_2 using `agg', nokeep
	assert _merge == 3
	drop _merge


	// Selection of Persons
	// --------------------

	label define persel 1 "Register" 2 "Kish/Last-Birthday"  3 "Quota" 4 "Missing"
	gen persel:persel = 1 if hhsamp == 0
	replace persel = 2 if selper == "Gfk master sample"
	replace persel = 2 if selper == "database of addresses"
	replace persel = 2 if selper == "kish grid"
	replace persel = 2 if selper == "kish grid or last birthday"
	replace persel = 2 if selper == "last birthday"
	replace persel = 2 if selper == "random selection"
	replace persel = 3 if selper == "last birthday + quota"
	replace persel = 3 if selper == "quota"
	replace persel = 4 if persel == .

	// Back-Checks
	// -----------

	label define back3 1 "Back-Checks" 2 "No Back-Checks"  3 "Missing"
	gen back3:back3 = 1 if back > 0 
	replace back3 = 2 if back == 0
	replace back3 = 3 if back < 0



	// Combined Box-Plots
	// ------------------

	// Reshape it
	gen cov1:cov = persel
	gen cov3:cov = 7 + back3

	label define cov ///
	  1 "Register" 2 "Kish/Last-Birthday"  3 "Quota" 4 "Missing"     ///
	  8 "Back-Checks" 9 "No Back-Checks"  10 "Missing"

	gen index = _n
	reshape long cov, i(index) j(dim)

	label value dim dim
	label define dim 1 "Mode of Selection"  3 "Back-Checks"

	// Some settings for the graphs
	local opt "marker(1, ms(oh)) box(1, lcolor(black) fcolor(white)) medtype(marker)" 
	local opt "`opt' medmarker(ms(O) mcolor(black)) horizontal outergap(100)"
	local opt "`opt' nofill ysize(3) ytitle(Dep. from Randomness, place(4))"
	
	// ... and well, the graph
	graph box woment, over(cov) `opt' by(dim, cols(2) note(" ") iscale(*1.3) imargin(tiny) )
	graph export ant02_beamer.eps, replace



	
	
	exit

	Notes
	-----

	(1) No information on city in EB 62.1, France and ISSP 2002, Ireland


	


	
	


*  P(Women) for H0: P(Women) = .5
* kohler@wz-berlin.de
	
version 9
	
	clear
	set memory 80m
	set more off
	set scheme s1mono
	
	use svydat01 if eu & weich == 1 & city < . // Note 1

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

	// Survey-Method
	// -------------

	label define collect 1 "Face-to-Face" 2 "Telephone" 3 "Postal"
	gen collect:collect = 1 if (svymeth >= 1 & svymeth <= 3 ) | svymeth == 7
	replace collect = 2 if svymeth == 4
	replace collect = 3 if svymeth == 5


	// Back-Checks
	// -----------

	label define back3 1 "Back-Checks" 2 "No Back-Checks"  3 "Missing"
	gen back3:back3 = 1 if back > 0 
	replace back3 = 2 if back == 0
	replace back3 = 3 if back < 0


	// Regression Models
	// -----------------
	

	// Dummies
	foreach var of varlist persel collect back3 {
		levels `var', local(K)
		foreach k of local K {
			gen `var'`k' = `var' == `k'
			local lab: label (`var') `k'
			label variable `var'`k' `"`lab'"'
		}
	}


	levels survey, local(K)
	local i 1
	foreach k of local K {
		gen svy`i' = survey=="`k'"
		lab var svy`i++' "`k'"
	}
			
	gen resmis = resrate<0
	sum resrate if !resmis
	replace resmis = r(mean) if resmis
	label variable resrate "Response Rate"
	label variable resmis "No Resp. Rate"

	reg woment persel2-persel4   
	estimates store reg1, title("(1)")

	reg woment collect2 collect3   
	estimates store reg2, title("(2)")
	
	reg woment back32 back33
	estimates store reg3, title("(3)")

	reg woment persel2-persel4 collect2 collect3 back32 back33   
	estimates store reg4, title("(4)")

	reg woment persel2-persel4 collect2 collect3 back32 back33 resrate resmis
	estimates store reg5, title("(5)")

	estout reg1 reg2 reg3 reg4 reg5 using ant01.tex, replace    ///
	  cells(b(star fmt(%3.2f)) t(par fmt(%3.2f) drop(_cons) ))  ///
	  stats(r2 N, fmt(%3.2f %3.0f) labels("R-Square" "N"))      ///
	  starlevels(* 0.05 ** 0.01)                                ///
	  posthead("\hline") prefoot("\hline") postfoot("\hline")   ///
	  label ///
	  varlabels(_cons Constant, ///
	    blist(persel2 "\multicolumn{6}{l}{\emph{Mode of Selection (Reference: Register) }}  \\" ///
	      collect2 "\multicolumn{6}{l}{\emph{Mode of Collection (Reference: Face-to-Face) }} \\ " ///
	      back32   "\multicolumn{6}{l}{\emph{Back-Checks (Reference: Yes) }} \\ " ///
	  )) ///
	  style(tex)


	// Combined Graph
	// --------------

	// Reshape it
	gen cov1:cov = persel
	gen cov2:cov = 4 + collect
	gen cov3:cov = 7 + back3

	label define cov ///
	  1 "Register" 2 "Kish/Last-Birthday"  3 "Quota" 4 "Missing"     ///
	  5 "Face-to-Face" 6 "Telephone" 7 "Postal" ///
	  8 "Back-Checks" 9 "No Back-Checks"  10 "Missing"

	gen index = _n
	reshape long cov, i(index) j(dim)

	label value dim dim
	label define dim 1 "Mode of Selection" 2 "Mode of Collection" 3 "Back-Checks"

	// Some settings for the graphs
	local opt "marker(1, ms(oh)) box(1, lcolor(black) fcolor(white)) medtype(marker)" 
	local opt "`opt' medmarker(ms(O) mcolor(black)) horizontal outergap(100)"
	local opt "`opt' nofill ysize(7) ytitle(Dep. from Randomness, place(4))"
	
	// ... and well, the graph
	graph box woment, over(cov) `opt' by(dim, cols(1) note(" ")  iscale(*1.3) )
	graph export ant01.eps, replace



	
	
	exit

	Notes
	-----

	(1) No information on city in EB 62.1, France and ISSP 2002, Ireland


	


	
	


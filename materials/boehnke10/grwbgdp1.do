* Well-Being (Life-Satisfaction) by GDP, Country-Specific over Time
* Eurobaromenter Trend + WZB 

version 9

	use satislfe nation year wsample using ~/data/eb/ebtrend, clear

	// Generate ISO-Varaible for Merging
	gen str2 iso3166_2 = "FR" if nation == "france":nation
	replace iso3166_2 = "BE" if nation == "belgium":nation
	replace iso3166_2 = "NL" if nation == "netherlands":nation
	replace iso3166_2 = "DE" if nation == "germany-west":nation
	replace iso3166_2 = "IT" if nation == "italy":nation
	replace iso3166_2 = "LU" if nation == "luxembourg":nation
	replace iso3166_2 = "DK" if nation == "denmark":nation
	replace iso3166_2 = "IE" if nation == "ireland":nation
	replace iso3166_2 = "GB" if nation == "great britain":nation
	replace iso3166_2 = "GB" if nation == "northern ireland":nation
	replace iso3166_2 = "GR" if nation == "greece":nation
	replace iso3166_2 = "ES" if nation == "spain":nation
	replace iso3166_2 = "PT" if nation == "portugal":nation
	replace iso3166_2 = "DE" if nation == "germany-east":nation
	replace iso3166_2 = "NO" if nation == "norway":nation
	replace iso3166_2 = "FI" if nation == "finland":nation
	replace iso3166_2 = "SE" if nation == "sweden":nation
	replace iso3166_2 = "AT" if nation == "austria":nation

	// Mirror Life Satisfaction
	sum satislfe, meanonly
	replace satislfe = r(max)-satislfe + 1


	// Collaps the Data
	collapse (mean) satislfe [aweight=wsample] , by(iso3166_2 year)
	lab var satislfe "Mean Well-Being (Life Satisfaction)"

	// Merge GDP per capita
	sort iso3166_2 year
	merge iso3166_2 year using ~/data/agg/gdp50-02.dta, nokeep
	assert _merge == 3
	drop _merge
	compress

	// Group countries according to correlations
	separate satislfe, by(iso3166_2) veryshortlabel
	gen group:group = .
	foreach var of varlist satislfe1-satislfe16 {
		reg `var' GDP
		replace group = 1 if (abs(_b[GDP]) > (2 * _se[GDP])) & _b[GDP] > 0 & e(sample)
		replace group = 2 if  abs(_b[GDP]) < (2 * _se[GDP]) & e(sample)
		replace group = 3 if (abs(_b[GDP]) > (2 * _se[GDP])) & _b[GDP] < 0 & e(sample)
	}
	lab def group 1 "Signifcant positive" 2 "Not significant" 3 "Significant negative"
		
	// Define the Position for the Data-Labels (by Hand)
	drop if satislfe >= . | GDP >= .
	by iso3166_2 (GDP), sort: gen mlaby = satislfe if _n==1 &  ///
	  ( iso3166_2 == "IE"  ///
	  | iso3166_2 == "GR"  ///
	  | iso3166_2 == "ES"  ///
	  | iso3166_2 == "FI"  ///
	  | iso3166_2 == "FR"  ///
	  | iso3166_2 == "NL"  ///
	  | iso3166_2 == "IT"  ///
	  )
	by iso3166_2 (GDP), sort: replace mlaby = satislfe if _n==_N & mlaby[1] >= .
	gen mlabvpos = 3
	replace mlabvpos = 6 if  ///
	  ( iso3166_2 == "LU"  ///
	  | iso3166_2 == "BE"  ///
	  | iso3166_2 == "ES"  ///
	  | iso3166_2 == "SE"  ///
	  | iso3166_2 == "PT"  ///
	  )
	replace mlabvpos = 9 if  ///
	  ( iso3166_2 == "GR"  ///
	  | iso3166_2 == "FI"  ///
	  )
	replace mlabvpos = 12 if  ///
	  ( iso3166_2 == "IE"  ///
	  | iso3166_2 == "FR"  ///
	  | iso3166_2 == "IT"  ///
	  | iso3166_2 == "NL"  ///
	  )


	// The Graph
	drop if iso3166_2 == "NO"
	tw ///
	  || line satislfe? satislfe?? GDP, lcolor(black..) ///
	  ///      AT  BE  DE  DK  ES  FI  FR  GB  GR  IE  IT  LU  NL  PT  SE
	  lpattern("l" "l" "l" "l" "l" "l" "l" "l" "l" "." "l" "-" "l" "l" "l")     ///
	    lcolor(gs0 gs0 gs9 gs0 gs0 gs0 gs0 gs0 gs0 gs0 gs9 gs9 gs9 gs0 gs9 gs0) ///
	  || scatter mlaby GDP, ms(i) mlab(iso3166_2) mlabvpos(mlabvpos)            ///
	  || , by(group, legend(off) cols(3) note("")) scheme(s1mono) ylab(2.5(.25)3.75)     ///
	  ytitle("Mean subj. well-being (life satisfaction)")
	graph export grwbgdp1.eps, replace, preview(on)

	exit
	
	

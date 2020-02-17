* Several Participation Measures by Social expenditure
* Author: kohler@wzb.eu
	
	// Intro
	// -----
	
version 9.2
	set more off
	set scheme s1mono

	// CSES-Data
	// ---------
	clear
	set memory 100m
	
	use ///
    persid iso3166  dataset voter contact persother campact protest actgroup weight ///
    using cses, clear
	append using ess02  ///
    , keep(persid iso3166  dataset voter contact protest actgroup weight)
	append using ess04  ///
    , keep(persid iso3166  dataset voter contact protest actgroup weight)
	append using issp02 ///
    , keep(persid iso3166  dataset voter weight )
	append using issp04 ///
    , keep(persid iso3166  dataset voter contact donate petition protest actgroup weight)
	append using eqls03 ///
    , keep(persid iso3166  dataset voter contact actgroup weight)

   // Store variable labels
   foreach var of varlist voter-donate {
     local lab`var' : variable label `var'
   }


	// Calculate Mean Participation
	collapse (mean) voter-donate [aweight=weight], by(dataset iso3166)
	egen ctrname = iso3166(iso3166), o(codes)

   // Classify Nations
	gen natfam = 1 if iso3166 == "US"
	replace natfam = 2 if ///
	  inlist(iso3166,"AT","BE","DE","DK","ES") ///
	  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
	  | inlist(iso3166,"IT","LU","NL","PT","SE")
	replace natfam = 3 if ///
	  inlist(iso3166,"BG","CZ","EE","HU","KR") ///
	  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
	replace natfam = 4 if natfam == .

   // Add social expenditures data
   sort iso3166
   merge iso3166 using exp
   gen socbrut = socbrut01 if mi(socbrut04) // OECD-Data
   replace socbrut = socbrut04 if mi(socbrut01) // Eurostat-Data
   replace socbrut = (socbrut04+socbrut01) if !mi(socbrut04,socbrut01)
   lab var socbrut ///
    "Social expenditures (brutto) as % of GDP (interpolated)" 

	gen mis = .
	foreach var of varlist voter-donate {

      // Average, Minimum, Maximum Participation Measure of Datasets
		by iso3166, sort: gen mean`var' = sum(`var')/sum(`var'<.)
		by iso3166: replace mean`var' = mean`var'[_N]

		replace mis = `var' >= .
		by mis iso3166 (`var'), sort: gen min`var' = `var'[1] if !mis
		by mis iso3166 (`var'): gen max`var' = `var'[_N] if !mis

      foreach x of varlist socbrut socnet01 taxrev04 pens04 {

        // Graph and Export
	   	graph twoway ///
		    || rspike min`var' max`var' `x', lcolor(black)         ///
		    || scatter mean`var' `x' if natfam == 1                ///
             , ms(O) mlcolor(black) mfcolor(black)               ///
		    || scatter mean`var' `x' if natfam == 2                ///
             , ms(O) mlcolor(black) mfcolor(gs8)                 ///
		    || scatter mean`var' `x' if natfam == 3                ///
             , ms(O) mlcolor(black) mfcolor(white)               ///
		    || scatter mean`var' `x' if natfam == 4                ///
             , ms(S) mlcolor(black) mfcolor(white)               ///
          || lowess  mean`var' `x', lcolor(black)                ///
		    || , name(`x', replace) nodraw ytitle(`"`lab`var''"')  ///
               xtitle(`:variable label `x'')                     ///
               legend(rows(1) order(2 "US" 3 "EU-15" 4 "FC-11" 5 "Other"))
       }
   grc1leg socbrut socnet01 taxrev04 pens04
   graph export anparticipaton_by_exp_`var'.eps, replace preview(on)

	}
	
	
exit




	

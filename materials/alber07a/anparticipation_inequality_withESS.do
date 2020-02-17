* Calculate raw participation inequalities by country and survey-year
* Author: kohler@wzb.eu
	
	// Intro
	// -----
	
version 9.2
	set more off
	set scheme s1mono

	// CSES-Data
	// ---------

	// Get Data
	use ///
	  iso3166_2 dweight ///
	  voter contact persother campact protest actgroup  ///
	  dataset hhinc edu emp ///
	  using cses01, clear

	// Recode Emp and edu to fit into the loop
	replace emp = . if emp > 2
	replace emp = 3-emp
	replace emp = emp * 2

	replace edu = edu + 1

	foreach strata of varlist hhinc edu emp {
		local i 1
		foreach var of varlist voter contact persother campact protest actgroup {
			
			// Overall Aggregates (for the definition of the sort-order)
			preserve
			local title: var lab `var'
			collapse (mean) `var'bar=`var' [aweight=dweight], by(iso3166_2)
			sort iso3166_2
			tempfile overall
			save `overall'
			restore, preserve
			
			// Aggregates by social strata
			collapse (mean) `var' [aweight=dweight], by(iso3166_2 `strata') fast
			drop if `strata' >= .
			sort iso3166_2
			merge iso3166_2 using `overall'
			assert _merge==3
			drop _merge
			
			// Construct x-axis definition
			gen natfam = 1 if iso3166_2 == "US"
			replace natfam = 2 if iso3166_2 == "CH"
			replace natfam = 3 if iso3166_2 == "SE"
			replace natfam = 4 if iso3166_2 == "NL"
			replace natfam = 4 if iso3166_2 == "DE"
			replace natfam = 5 if iso3166_2 == "ES"
			replace natfam = 5 if iso3166_2 == "PT"
			replace natfam = 6 if iso3166_2 == "HU"
			replace natfam = 6 if iso3166_2 == "PL"
			replace natfam = 6 if iso3166_2 == "CZ"
			
			egen axis = axis(natfam `var'bar), label(iso3166_2) 
			replace axis = axis - .4 if `strata'==1
			replace axis = axis - .2 if `strata'==2
			replace axis = axis + .2 if `strata'==4
			replace axis = axis + .4 if `strata'==5
			
			// Definition of linegraphs (bypass a bug with Stata version 9.2 colors)
			levelsof iso3166_2, local(K)
			local line ""
			foreach k of local K {
				local line `"`line' (line `var' axis if iso3166_2 == "`k'", sort lcolor(black))"'
			}
			
			// The Graph
			graph twoway `line' ///
			  || scatter `var' axis, ms(o) mfcolor(white) mlcolor(black) ///
			  || , legend(off) ///
			  xlabel(1/10, valuelabel alternate) xline(1.5(1)9.5, lstyle(grid)) ///
			  xtitle("") title(`"`title''"', box bexpand fcolor(gs10)) ///
			  ytitle("") ///
			  name(g`i++', replace) nodraw
			
			restore
			
		}
		
		graph combine g1 g2 g3 g4 g5 g6, rows(3)
		graph export anparticipation_inequality_cses_`strata'.eps, replace
	}

	// ISSP-Data
	// ---------

	use ///
	  iso3166_2 weight ///
	  voter contact donate petition protest actgroup ///
	  hhinc edu emp ///
	  using issp01, clear

	// Recode Emp and edu to fit into the loop
	replace emp = . if emp > 2
	replace emp = 3-emp
	replace emp = emp * 2

	replace edu = edu + 1


	foreach strata of varlist hhinc edu emp {
		local i 1
		foreach var of varlist voter contact donate petition protest actgroup {
			
			// Overall Aggregates (for the definition of the sort-order)
			preserve
			local title: var lab `var'
			collapse (mean) `var'bar=`var' [aweight=weight], by(iso3166_2)
			sort iso3166_2
			tempfile overall
			save `overall'
			restore, preserve
			
			// Aggregates by social strata
			collapse (mean) `var' [aweight=weight], by(iso3166_2 `strata') fast
			drop if `strata' >= .
			sort iso3166_2
			merge iso3166_2 using `overall'
			assert _merge==3
			drop _merge
			
			// Construct x-axis definition
			gen natfam = 1 if iso3166_2 == "US"
			replace natfam = 2  if iso3166_2 == "CH"
			replace natfam = 2  if iso3166_2 == "GB"
			replace natfam = 2  if iso3166_2 == "IE"
			replace natfam = 3  if iso3166_2 == "SE"
			replace natfam = 3  if iso3166_2 == "FI"
			replace natfam = 3  if iso3166_2 == "DK"
			replace natfam = 3  if iso3166_2 == "NO"
			replace natfam = 4 if iso3166_2 == "NL"
			replace natfam = 4 if iso3166_2 == "BE"
			replace natfam = 4 if iso3166_2 == "FR"
			replace natfam = 4 if iso3166_2 == "DE"
			replace natfam = 4 if iso3166_2 == "AT"
			replace natfam = 5 if iso3166_2 == "ES"
			replace natfam = 5 if iso3166_2 == "PT"
			replace natfam = 5 if iso3166_2 == "CY"
			replace natfam = 6 if iso3166_2 == "SI"
			replace natfam = 6 if iso3166_2 == "PO"
			replace natfam = 6 if iso3166_2 == "HU"
			replace natfam = 6 if iso3166_2 == "CZ"
			replace natfam = 6 if iso3166_2 == "SK"
			replace natfam = 6 if iso3166_2 == "LV"
			replace natfam = 7 if iso3166_2 == "BU"
			replace natfam = 7 if iso3166_2 == "RU"
			
			egen axis = axis(natfam `var'bar), label(iso3166_2) 
			replace axis = axis - .4 if `strata'==1
			replace axis = axis - .2 if `strata'==2
			replace axis = axis + .2 if `strata'==4
			replace axis = axis + .4 if `strata'==5
			
			// Definition of linegraphs (bypass a bug with Stata version 9.2 colors)
			levelsof iso3166_2, local(K)
			local line ""
			foreach k of local K {
				local line `"`line' (line `var' axis if iso3166_2 == "`k'", sort lcolor(black))"'
			}
			
			// The Graph
			graph twoway `line' ///
			  || scatter `var' axis, ms(o) mfcolor(white) mlcolor(black) ///
			  || , legend(off) ///
			  xlabel(1/22, valuelabel alternate) xline(1.5(1)21.5, lstyle(grid)) ///
			  xtitle("") title(`"`title''"', box bexpand fcolor(gs10)) ///
			  ytitle("") ///
			  name(g`i++', replace) nodraw
			
			restore
			
		}
		
		graph combine g1 g2 g3 g4 g5 g6, rows(3)
		graph export anparticipation_inequality_issp_`strata'.eps, replace
	}



// ESS02-Data
	// ---------

	cd M:\group\ARS\USI\kohler\participation07\analysen
	use ///
	  iso3166_2 weight ///
	  voter contact donate petition protest actgroup ///
	  hhinc edu emp ///
	  using cress02_01, clear

	// Recode Emp and edu to fit into the loop
	replace emp = . if emp > 2
	replace emp = 3-emp
	replace emp = emp * 2

	replace edu = edu + 1


	foreach strata of varlist hhinc emp edu {
		local i 1
		foreach var of varlist voter contact donate petition protest actgroup {
			
			// Overall Aggregates (for the definition of the sort-order)
			preserve
			local title: var lab `var'
			collapse (mean) `var'bar=`var' [aweight=weight], by(iso3166_2)
			sort iso3166_2
			tempfile overall
			save `overall'
			restore, preserve
			
			// Aggregates by social strata
			collapse (mean) `var' [aweight=weight], by(iso3166_2 `strata') fast
			drop if `strata' >= .
			sort iso3166_2
			merge iso3166_2 using `overall'
			assert _merge==3 //if iso3166_2 != "GB"  // <- Edu for GB not defined
			drop _merge
			

			// Construct x-axis definition
			gen natfam=.
			replace natfam = 2  if iso3166_2 == "CH"
			replace natfam = 2  if iso3166_2 == "GB"
			replace natfam = 2  if iso3166_2 == "IE"

			replace natfam = 3  if iso3166_2 == "SE"
			replace natfam = 3  if iso3166_2 == "FI"
			replace natfam = 3  if iso3166_2 == "DK"
			replace natfam = 3  if iso3166_2 == "NO"

			replace natfam = 4 if iso3166_2 == "NL"
			replace natfam = 4 if iso3166_2 == "BE"
			replace natfam = 4 if iso3166_2 == "FR"
			replace natfam = 4 if iso3166_2 == "DE"
			replace natfam = 4 if iso3166_2 == "AT"
			replace natfam = 4 if iso3166_2 == "ES"
			replace natfam = 4 if iso3166_2 == "GR"
			replace natfam = 4 if iso3166_2 == "IT"
			replace natfam = 4 if iso3166_2 == "LU"
			replace natfam = 4 if iso3166_2 == "PT"

			replace natfam = 6 if iso3166_2 == "SI"
			replace natfam = 6 if iso3166_2 == "CZ"
			replace natfam = 6 if iso3166_2 == "HU"
			replace natfam = 6 if iso3166_2 == "PL"


			egen axis = axis(natfam `var'bar), label(iso3166_2) 
			replace axis = axis - .4 if `strata'==1
			replace axis = axis - .2 if `strata'==2
			replace axis = axis + .2 if `strata'==4
			replace axis = axis + .4 if `strata'==5
			
			// Definition of linegraphs (bypass a bug with Stata version 9.2 colors)
			levelsof iso3166_2, local(K)
			local line ""
			foreach k of local K {
				local line `"`line' (line `var' axis if iso3166_2 == "`k'", sort lcolor(black))"'
			}
			
			// The Graph
			graph twoway `line' ///
			  || scatter `var' axis, ms(o) mfcolor(white) mlcolor(black) ///
			  || , legend(off) ///
			  xlabel(1/21, valuelabel alternate) xline(1.5(1)21.5, lstyle(grid)) ///
			  xtitle("") title(`"`title''"', box bexpand fcolor(gs10)) ///
			  ytitle("") ///
			  name(g`i++', replace) nodraw
			
			restore
			
		}
		
		graph combine g1 g2 g3 g4 g5 g6, rows(3)
		graph export anparticipation_inequality_issp_`strata'.eps, replace
	}





// ESS04-Data
	// ---------

	cd M:\group\ARS\USI\kohler\participation07\analysen
	use ///
	  iso3166_2 weight ///
	  voter contact petition protest actgroup ///
	  hhinc edu emp ///
	  using cress04_01, clear

	// Recode Emp and edu to fit into the loop
	replace emp = . if emp > 2
	replace emp = 3-emp
	replace emp = emp * 2

	replace edu = edu + 1


	foreach strata of varlist hhinc emp edu {
		local i 1
		foreach var of varlist voter contact petition protest actgroup {
			
			// Overall Aggregates (for the definition of the sort-order)
			preserve
			local title: var lab `var'
			collapse (mean) `var'bar=`var' [aweight=weight], by(iso3166_2)
			sort iso3166_2
			tempfile overall
			save `overall'
			restore, preserve
			
			// Aggregates by social strata
			collapse (mean) `var' [aweight=weight], by(iso3166_2 `strata') fast
			drop if `strata' >= .
			sort iso3166_2
			merge iso3166_2 using `overall'
			assert _merge==3 if iso3166_2 != "GB"  // <- Edu for GB not defined
			drop _merge
			

			// Construct x-axis definition
			gen natfam=.
			replace natfam = 2  if iso3166_2 == "CH"
			replace natfam = 2  if iso3166_2 == "GB"
			replace natfam = 2  if iso3166_2 == "IE"
			replace natfam = 2  if iso3166_2 == "IS"

			replace natfam = 3  if iso3166_2 == "SE"
			replace natfam = 3  if iso3166_2 == "FI"
			replace natfam = 3  if iso3166_2 == "DK"
			replace natfam = 3  if iso3166_2 == "NO"

			replace natfam = 4 if iso3166_2 == "NL"
			replace natfam = 4 if iso3166_2 == "BE"
			replace natfam = 4 if iso3166_2 == "FR"
			replace natfam = 4 if iso3166_2 == "DE"
			replace natfam = 4 if iso3166_2 == "AT"
			replace natfam = 4 if iso3166_2 == "ES"
			replace natfam = 4 if iso3166_2 == "GR"
			replace natfam = 4 if iso3166_2 == "LU"
			replace natfam = 4 if iso3166_2 == "PT"

			replace natfam = 6 if iso3166_2 == "SI"
			replace natfam = 6 if iso3166_2 == "CZ"
			replace natfam = 6 if iso3166_2 == "HU"
			replace natfam = 6 if iso3166_2 == "PL"
			replace natfam = 6 if iso3166_2 == "EE"
			replace natfam = 6 if iso3166_2 == "SK"
			replace natfam = 6 if iso3166_2 == "UA"


			egen axis = axis(natfam `var'bar), label(iso3166_2) 
			replace axis = axis - .4 if `strata'==1
			replace axis = axis - .2 if `strata'==2
			replace axis = axis + .2 if `strata'==4
			replace axis = axis + .4 if `strata'==5
			
			// Definition of linegraphs (bypass a bug with Stata version 9.2 colors)
			levelsof iso3166_2, local(K)
			local line ""
			foreach k of local K {
				local line `"`line' (line `var' axis if iso3166_2 == "`k'", sort lcolor(black))"'
			}
			
			// The Graph
			graph twoway `line' ///
			  || scatter `var' axis, ms(o) mfcolor(white) mlcolor(black) ///
			  || , legend(off) ///
			  xlabel(1/24, valuelabel alternate) xline(1.5(1)21.5, lstyle(grid)) ///
			  xtitle("") title(`"`title''"', box bexpand fcolor(gs10)) ///
			  ytitle("") ///
			  name(g`i++', replace) nodraw
			
			restore
			
		}
		
		graph combine g1 g2 g3 g4 g5, rows(3)
		graph export anparticipation_inequality_issp_`strata'.eps, replace
	}


// EQLS-Data
	// ---------

	cd M:\group\ARS\USI\kohler\participation07\analysen
	use ///
	  iso3166_2 weight ///
	  voter contact actgroup ///
	  hhinc edu emp ///
	  using creqls_1, clear

	// Recode Emp and edu to fit into the loop
	replace emp = . if emp > 2
	replace emp = 3-emp
	replace emp = emp * 2

	replace edu = edu + 1


	foreach strata of varlist hhinc emp edu {
		local i 1
		foreach var of varlist voter contact actgroup {
			
			// Overall Aggregates (for the definition of the sort-order)
			preserve
			local title: var lab `var'
			collapse (mean) `var'bar=`var' [aweight=weight], by(iso3166_2)
			sort iso3166_2
			tempfile overall
			save `overall'
			restore, preserve
			
			// Aggregates by social strata
			collapse (mean) `var' [aweight=weight], by(iso3166_2 `strata') fast
			drop if `strata' >= .
			sort iso3166_2
			merge iso3166_2 using `overall'
			assert _merge==3 
			drop _merge
			

			// Construct x-axis definition
			gen natfam=.
			replace natfam = 2  if iso3166_2 == "GB"
			replace natfam = 2  if iso3166_2 == "IE"

			replace natfam = 3 if iso3166_2 == "NL"
			replace natfam = 3 if iso3166_2 == "FR"
			replace natfam = 3 if iso3166_2 == "DE"
			replace natfam = 3 if iso3166_2 == "AT"
			replace natfam = 3 if iso3166_2 == "CY"
			replace natfam = 3 if iso3166_2 == "GR"
			replace natfam = 3 if iso3166_2 == "IT"
			replace natfam = 3 if iso3166_2 == "BE"
			replace natfam = 3 if iso3166_2 == "LU"
			replace natfam = 3 if iso3166_2 == "MA"
			replace natfam = 3 if iso3166_2 == "TR"
			replace natfam = 3 if iso3166_2 == "ES"

			replace natfam = 4  if iso3166_2 == "SE"
			replace natfam = 4  if iso3166_2 == "FI"
			replace natfam = 4  if iso3166_2 == "DK"

			replace natfam = 6 if iso3166_2 == "BG"
			replace natfam = 6 if iso3166_2 == "CZ"
			replace natfam = 6 if iso3166_2 == "HU"
			replace natfam = 6 if iso3166_2 == "LV"
			replace natfam = 6 if iso3166_2 == "PL"
			replace natfam = 6 if iso3166_2 == "EE"
			replace natfam = 6 if iso3166_2 == "LT"
			replace natfam = 6 if iso3166_2 == "RO"
			replace natfam = 6 if iso3166_2 == "SI"
			replace natfam = 6 if iso3166_2 == "SK"

			egen axis = axis(natfam `var'bar), label(iso3166_2) 
			replace axis = axis - .4 if `strata'==1
			replace axis = axis - .2 if `strata'==2
			replace axis = axis + .2 if `strata'==4
			replace axis = axis + .4 if `strata'==5
			
			// Definition of linegraphs (bypass a bug with Stata version 9.2 colors)
			levelsof iso3166_2, local(K)
			local line ""
			foreach k of local K {
				local line `"`line' (line `var' axis if iso3166_2 == "`k'", sort lcolor(black))"'
			}
			
			// The Graph
			graph twoway `line' ///
			  || scatter `var' axis, ms(o) mfcolor(white) mlcolor(black) ///
			  || , legend(off) ///
			  xlabel(1/2)), valuelabel alternate) xline(1.5(1)21.5, lstyle(grid)) ///
			  xtitle("") title(`"`title''"', box bexpand fcolor(gs10)) ///
			  ytitle("") ///
			  name(g`i++', replace) nodraw
			
			restore
			
		}
		
		graph combine g1 g2 g3, rows(3)
		graph export anparticipation_inequality_issp_`strata'.eps, replace
	}

	exit
	

* Several participation measures by country
* Author: kohler@wzb.eu
	
	// Intro
	// -----
	
version 9.2
	set more off
	set scheme s1mono

	clear
	set memory 100m
	
	use ///
    persid iso3166 dataset voter contact protest actgroup using cses, clear
	append using ess02  ///
    , keep(persid iso3166  dataset voter contact protest actgroup )
	append using ess04  ///
    , keep(persid iso3166  dataset voter contact protest actgroup )
	append using issp04 ///
    , keep(persid iso3166  dataset voter contact protest actgroup )
	append using eqls03 ///
    , keep(persid iso3166  dataset voter contact actgroup )

	lab var contact "Politikerkontakt"
	lab var protest "Demonst.-teiln."
	lab var actgroup "Bürgerinitiative"
	
	gen natfam = 1 if iso3166 == "US"
	replace natfam = 2 if ///
	  inlist(iso3166,"AT","BE","DE","DK","ES") ///
	  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
	  | inlist(iso3166,"IT","LU","NL","PT","SE")
	replace natfam = 3 if ///
	  inlist(iso3166,"CY","MT","TR")
	replace natfam = 4 if ///
	  inlist(iso3166,"BG","CZ","EE","HU") ///
	  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
	replace natfam = 5 if natfam == .
	keep if natfam < 5

	// Initialise postfile
	tempfile diff
	postfile coefs str2 iso3166 str10 dataset form b using `diff', replace

	drop if mi(voter)
	local i 0
	foreach var of varlist contact actgroup protest {
		local lab `"`lab' `++i' "`:var lab `var''" "'
		levelsof dataset if !mi(`var'), local(D)
		foreach dataset of local D {
			levelsof iso3166 if dataset == "`dataset'" & !mi(`var'), local(K)
			foreach k of local K {
					reg `var' voter if iso3166 == "`k'" & dataset == "`dataset'"
					post coefs ("`k'") ("`dataset'") (`i') (_b[voter])
			}
		}
	}
	postclose coefs

	use `diff', replace
	drop if b==0

   // Classify Nations
	gen natfam = 1 if iso3166 == "US"
	replace natfam = 2 if ///
	  inlist(iso3166,"AT","BE","DE","DK","ES") ///
	  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
	  | inlist(iso3166,"IT","LU","NL","PT","SE")
	replace natfam = 3 if ///
	  inlist(iso3166,"BG","CZ","EE","HU") ///
	  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
	replace natfam = 4 if natfam == .
	keep if natfam < 4

	label value form form
	label def form `lab'

	// Average, Minimum, Maximum Participation Measure of Datasets
	by form iso3166, sort: gen meanb = sum(b)/sum(b<.)
	by form iso3166: replace meanb = meanb[_N]

	by form iso3166 (b), sort: gen minb = b[1] 
	by form iso3166 (b): gen maxb = b[_N]
	
	// Order of categorical axis
	by iso3166, sort: egen order = mean(b) 
	egen axis = axis(natfam order), reverse label(iso3166) gap

	// Vertical lines for country group averages
	by natfam, sort: gen MEANb = sum(meanb)/sum(meanb<.) if _N > 1
	by natfam: replace MEANb = MEANb[_N] if _N > 1
	levelsof natfam, local(K)
	local vlines ""
	foreach k of local K {
        local vlines ///
          "`vlines' || line axis MEANb if natfam==`k', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
	}

	// Graph and Export
	levelsof axis, local(ylab)
	graph twoway ///
	  || sc axis meanb,  ms(O) mcolor(black)                            ///
	  || rspike minb maxb axis, horizontal lcolor(black)                ///
	  || `vlines'                                                       ///
	  || , by(form, rows(1) legend(off)                                 ///
        note("Quellen: CSES I, CSES II, ESS '02, ESS '04, EQLS '03 ISSP '04", span)    ///
        title(`"Grafik 8: "', span ring(2) pos(11) justification(left) size(medlarge)) ///
      subtitle(`"Ausübung alternativer Formen politischer "'           ///
               `"Partizipation unter Wählern und "' ///
               `"Nicht-Wählern"' , margin(l+17 b+3)  ///
                span ring(2) pos(11) justification(left) size(medlarge)))              ///
  	  ysize(5) xsize(4.5)                                                               ///
 	  ylabel(`ylab', valuelabel angle(0) labsize(*.8) gstyle(dot))                      /// 
	  ytitle("") xtitle("Differenz des Partizipationsanteils" "(Wähler minus Nicht-Wähler)")

	graph export ../figure8DE.eps, replace preview(on) 

	

exit



	

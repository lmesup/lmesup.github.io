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
    persid iso3166 dataset  contact protest actgroup using cses, clear
	append using ess02  ///
    , keep(persid iso3166  dataset  contact protest actgroup )
	append using ess04  ///
    , keep(persid iso3166  dataset  contact protest actgroup )
	append using issp04 ///
    , keep(persid iso3166  dataset  contact protest actgroup )
	append using eqls03 ///
    , keep(persid iso3166  dataset  contact actgroup )

	lab var contact "Politikerkontakt"
	lab var protest "Demonstr.teiln."
	lab var actgroup "Bürgerinitiative"
	
	local i 1
	foreach var of varlist contact actgroup protest {
		local lab `"`lab' `i' "`:var lab `var''" "'
		ren `var' participation`i++'
	}

    // Calculate Mean Participation
	collapse (mean) participation*, by(dataset iso3166)
	egen ctrname = iso3166(iso3166), o(codes)

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

	gen mis = .

	gen index = _n
	reshape long participation, i(index) j(form)
	label value form form
	label def form `lab'

	// Average, Minimum, Maximum Participation Measure of Datasets
	by form iso3166, sort: gen meanparticipation = sum(participation)/sum(participation<.)
	by form iso3166: replace meanparticipation = meanparticipation[_N]

	replace mis = participation >= .
	by mis form iso3166 (participation), sort: gen minparticipation = participation[1] if !mis
	by mis form iso3166 (participation): gen maxparticipation = participation[_N] if !mis

	// Order of categorical axis
	by iso3166, sort: egen order = mean(participation) 
	egen axis = axis(natfam order), reverse label(iso3166) gap

	// Vertical lines for country group averages
	by natfam, sort: gen MEANparticipation = sum(meanparticipation)/sum(meanparticipation<.) if _N > 1
	by natfam: replace MEANparticipation = MEANparticipation[_N] if _N > 1

	levelsof natfam, local(K)
	local vlines ""
	foreach k of local K {
       local vlines ///
       "`vlines' || line axis MEANparticipation if natfam==`k', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
	}

	// Graph and Export
	levelsof axis, local(ylab)
	graph twoway ///
	  || sc axis  meanparticipation , ms(O) mcolor(black)                           ///
	  || rspike minparticipation maxparticipation axis, horizontal lcolor(black)    ///
	  || `vlines'                                                                   ///        
	  || , ylabel(`ylab', valuelabel angle(0) labsize(*.8) gstyle(dot))             ///
	       ytitle("") xtitle(Partizipationsrate) legend(off)  ///
          by(form, rows(1) legend(off) ///
            note("Quellen: CSES I, CSES II, ESS '02, ESS '04, EQLS '03 ISSP '04", span)       ///
            title(`"Grafik 7: "', span ring(2) pos(11) justification(left) size(medlarge)) ///
            subtitle(`"Ausübung alternativer Formen  "'                                ///
               `"politischer Partizipation"', margin(l+17 b+3)                             ///
                span ring(2) pos(11) justification(left) size(medlarge)))                  ///
         	  ysize(5) xsize(4.5) 

	graph export ../figure7DE.eps, replace preview(on) 
	

exit




	

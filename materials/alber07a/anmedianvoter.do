* Difference in electoral participation
* Author: lenarz@wzb.eu -> diff_voter.do
* Rework: kohler@wzb.eu 

version 9.2
	set more off
	set scheme s1mono

	clear
	set memory 100m

	use ///
	  persid iso3166 dataset voter hhinc edu weight ///
	  using cses, clear
	append using ess02  ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using ess04  ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using issp02 ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using issp04 ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using eqls03 ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )

	// Keep the top 50 percent of the voters
	keep if voter==1 
	collapse (mean) hhinc if hhinc < ., by(iso3166 dataset)
	
	// Classify Nations
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

	by iso3166, sort: egen meanhhinc = mean(hhinc)
	by iso3166, sort: egen maxhhinc = max(hhinc)
	by iso3166, sort: egen minhhinc = min(hhinc)

	// Rendering of categorical axis labels
	egen axis = axis(natfam meanhhinc), reverse label(iso3166) gap
	by natfam, sort: egen MEANhhinc = mean(meanhhinc)


	levelsof axis if natfam < 5, local(I)
	levelsof natfam, local(J)
	local vlines ""
	foreach j of local J {
		local vlines ///
		  "`vlines' || line axis MEANhhinc if natfam==`j', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
	}

	// Graph and Export
	graph twoway ///
	  `vlines'                                               ///
	  || rspike minhhinc maxhhinc axis                       ///
      , horizontal lcolor(black)                             ///
	  || dot meanhhinc axis                                  ///
      , horizontal msymbol(O) mlcolor(black) mfcolor(black)  ///
	  ||                                                     ///
      , ylabel(`I', valuelabel angle(0)) ytitle("")          ///
      xtitle("Average income quintile")    ///
	  xlabel(2(1)4) xtick(2(1)4) xmtick(2.5(1)3.5) ///
      legend(off) ///
      note("Source: CSES I, CSES II, ISSP '04, ISSP '02, ESS '02, ESS '04, EQLS '03", span) ///
	  title("Figure 2" "Income of voters by country") ///
	  xsize(6.5) ysize(10)
	  
	
	graph export ../figure2.eps, replace preview(on)
	exit


         



	

* Difference in electoral participation
* Author: lenarz@wzb.eu -> diff_voter.do
* Rework: kohler@wzb.eu 

version 10
	set more off
	set scheme s1mono

	clear
	set memory 100m

	use ///
	  persid iso3166 dataset contact protest actgroup hhinc edu weight ///
	  using cses, clear
	append using ess02  ///
	  , keep(persid iso3166 dataset contact protest actgroup hhinc edu weight  )
	append using ess04  ///
	  , keep(persid iso3166 dataset contact protest actgroup hhinc edu weight  )
	append using issp02 ///
	  , keep(persid iso3166 dataset contact protest actgroup hhinc edu weight  )
	append using issp04 ///
	  , keep(persid iso3166 dataset contact protest actgroup hhinc edu weight  )
	append using eqls03 ///
	  , keep(persid iso3166 dataset contact protest actgroup hhinc edu weight  )

	lab var contact "Politikerkontakt"
	lab var protest "Demonst.-teiln."
	lab var actgroup "Bürgerinitiative"

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

	// Produce results as table
	// ------------------------

	preserve
	gen hhinc3 = 1 if hhinc == 1
	replace hhinc3 = 2 if inlist(hhinc,2,3,4)
	replace hhinc3 = 3 if hhinc == 5

	collapse (mean) voter natfam if hhinc3 < ., by(iso3166 hhinc3 dataset)
	by iso3166 hhinc3, sort: gen byte surveys = _N
	by iso3166 hhinc3, sort: egen voter_hhinc = mean(voter)
	by iso3166 hhinc3: keep if _n==1
	keep iso3166 surveys hhinc3 voter_hhinc natfam
	replace voter_hhinc = round(voter_hhinc * 100,1)
	reshape wide voter_hhinc, i(iso3166) j(hhinc3)
	tempfile part1
	save `part1'
	restore , preserve

	collapse (mean) voter natfam if edu < ., by(iso3166 edu dataset)
	by iso3166 edu, sort: egen voter_edu = mean(voter)
	by iso3166 edu: keep if _n==1
	keep voter_edu iso3166 edu
	replace voter_edu = round(voter_edu * 100,1)
	reshape wide voter_edu, i(iso3166) j(edu)

	merge iso3166 using `part1', sort
	assert _merge==3
	drop _merge

	sort natfam iso3166
	listtex iso3166 surveys voter_hhinc* voter_edu* using ../table2DE.txt ///
	  , replace rstyle(tabdelim)
	sum


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
	append using issp04 ///
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

	collapse (mean) contact protest actgroup natfam if hhinc3 < ., by(iso3166 hhinc3 dataset)
	by iso3166 hhinc3, sort: gen byte surveys = _N
	by iso3166 hhinc3, sort: egen contact_hhinc = mean(contact)
	by iso3166 hhinc3, sort: egen protest_hhinc = mean(protest)
	by iso3166 hhinc3, sort: egen actgroup_hhinc = mean(actgroup)
	by iso3166 hhinc3: keep if _n==1

	keep iso3166 surveys hhinc3 *_hhinc natfam
	replace contact_hhinc = round(contact_hhinc * 100,1)
	replace protest_hhinc = round(protest_hhinc * 100,1)
	replace actgroup_hhinc = round(actgroup_hhinc * 100,1)

	reshape wide contact_hhinc protest_hhinc actgroup_hhinc, i(iso3166) j(hhinc3)
	tempfile part1
	save `part1'
	restore , preserve

	collapse (mean) contact protest actgroup natfam if edu < ., by(iso3166 edu dataset)
	by iso3166 edu, sort: gen byte surveys = _N
	by iso3166 edu, sort: egen contact_edu = mean(contact)
	by iso3166 edu, sort: egen protest_edu = mean(protest)
	by iso3166 edu, sort: egen actgroup_edu = mean(actgroup)
	by iso3166 edu: keep if _n==1

	keep iso3166 surveys edu *_edu natfam
	replace contact_edu = round(contact_edu * 100,1)
	replace protest_edu = round(protest_edu * 100,1)
	replace actgroup_edu = round(actgroup_edu * 100,1)

	reshape wide contact_edu protest_edu actgroup_edu, i(iso3166) j(edu)
	merge iso3166 using `part1', sort
	assert _merge==3
	drop _merge

	sort natfam iso3166
	listtex iso3166 surveys contact_hhinc* contact_edu* using ../table3DE_contact.txt ///
	  , replace rstyle(tabdelim)

	listtex iso3166 surveys protest_hhinc* protest_edu* using ../table3DE_protest.txt ///
	  , replace rstyle(tabdelim)

	listtex iso3166 surveys actgroup_hhinc* actgroup_edu* using ../table3DE_actgroup.txt ///
	  , replace rstyle(tabdelim)


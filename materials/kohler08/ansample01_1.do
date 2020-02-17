* Sampling Methods and Features by Country and Survey-Program  (without Euromodule)
* kohler@wz-berlin.de

version 9

	drop _all
	set memory 90m
	set more off
	
	// Data
	use svydat01, clear
	drop if survey == "Euromodule"
	
	// Aggregate Data only
	by survey ctrname, sort: keep if _n==1
	keep survey ctrname eu pretest-quota


	// Sampling Method
	// ---------------
	
	label define sample ///
	  1 "SRS" ///
	  2 "Cluster + individual register" ///
	  3 "Cluster + address register" ///
	  4 "Cluster + random-route" ///
	  5 "Unspecified" ///
	  6 "Quota" ///

	// EB
	gen sample:sample = 4 if survey == "EB 62.1"

	// EQLS 
	replace sample = 2 if survey == "EQLS 2003"  & ///
	  ( ctrname ==  "Ireland" ///
	  | ctrname ==  "Italy" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "Sweden" ///
	  | ctrname ==  "Czech Republic" ///
	  | ctrname ==  "Estonia" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Latvia" ///
	  | ctrname ==  "Poland" ///
	  | ctrname ==  "Romania" )
	replace sample = 4 if survey == "EQLS 2003" &  sample >= .

	// EVS
	replace sample = 1 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Denmark" ///
	  | ctrname ==  "Iceland" ///
	  | ctrname ==  "Malta" ///
	  )

	replace sample = 2 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Belarus" ///
	  |	ctrname ==  "Ireland" ///
	  | ctrname == "Romania" ///
	  | ctrname == "Sweden" ///
	  | ctrname == "Slovenia" ///
	  )
	
	replace sample = 4 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Germany" ///
	  | ctrname ==  "Greece" ///
	  | ctrname ==  "Bulgaria" ///
	  )
	
	replace sample = 5 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "Belgium" ///
	  | ctrname ==  "Croatia" ///
	  | ctrname ==  "Latvia"  ///
	  | ctrname ==  "Lithuania" ///
	  | ctrname ==  "Netherlands" ///
	  | ctrname ==  "Portugal" ///
	  | ctrname ==  "Poland" ///
	  | ctrname ==  "Ukraine" ///
	  )

	replace sample = 6 if survey == "EVS 1999" & ///
	  (	ctrname ==  "Czech Republic" ///
	  | ctrname ==  "Estonia" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "France" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Italy" ///
  	  | ctrname ==  "Luxembourg" ///
	  | ctrname ==  "Slovakia" ///
	  | ctrname ==  "Spain" ///
	  | ctrname == "Russian Federation"  ///
	  | ctrname == "Turkey"  ///
	  | ctrname ==  "United Kingdom" ///
	  )

	// ISSP
	replace sample = 1 if survey == "ISSP 2002" & ///
	  ( ctrname ==  "Australia" ///
	  | ctrname ==  "Denmark" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "Norway" ///
	  | ctrname ==  "New Zealand" ///
	  | ctrname ==  "Sweden" ///
	  )

	replace sample = 2 if survey == "ISSP 2002" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "Germany" ///
	  | ctrname ==  "Belgium" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Japan" ///
	  | ctrname ==  "Slovenia" ///
	  | ctrname ==  "Taiwan" ///
	  )

	replace sample = 5 if survey == "ISSP 2002" &  sample >= .
		
	replace sample = 6 if survey == "ISSP 2002" & ///
	  (	ctrname ==  "Brazil" ///
	  | ctrname ==  "Netherlands" ///
	  | ctrname ==  "Philippines" ///
	  | ctrname ==  "Slovakia" ///
	  )


	// ESS 2002
	replace sample = 1 if survey == "ESS 2002" & ///
	  ( ctrname == "Denmark" ///
	  | ctrname == "Finland" ///
	  | ctrname == "Sweden" ///
	  )
	replace sample = 2 if survey == "ESS 2002" & ///
	  ( ctrname == "Belgium"  ///
	  | ctrname == "Germany" ///
	  | ctrname == "Hungary" ///
	  | ctrname == "Ireland" ///
	  | ctrname == "Norway" ///
	  | ctrname == "Poland"  ///
	  | ctrname == "Slovenia" ///
	  )

	replace sample = 3 if survey == "ESS 2002" & ///
	  ( ctrname == "Czech Republic"  ///
	  | ctrname == "Greece" ///
	  | ctrname == "Israel" ///
	  | ctrname == "Italy" ///
	  | ctrname == "Luxembourg" ///
	  | ctrname == "Netherlands" ///
	  | ctrname == "Portugal" ///
	  | ctrname == "Spain" ///
	  | ctrname == "Switzerland" ///
	  | ctrname == "United Kingdom" ///
	  )

	replace sample = 4 if survey == "ESS 2002" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "France" ///
	  )

	// Euromodule
	replace sample = 3 if survey == "Euromodule" & ///
	  ( ctrname == "Sweden" ///
	  | ctrname == "Slovenia" ///
	  )

	replace sample = 3 if survey == "Euromodule" & ///
	  ( ctrname == "Hungary" ///
	  | ctrname == "Switzerland" ///
	  | ctrname == "Austria" ///
	  )
	replace sample = 4 if survey == "Euromodule" & ///
	  ( ctrname == "Germany" ///
	  | ctrname == "Spain" ///
	  | ctrname == "Turkey" ///
	  )

	replace sample = 5 if survey == "Euromodule" & ///
	  ( ctrname == "Korea Rep. of" ///
	  )


	// EU and friends only
	// -------------------

	keep if eu > 0
	
	// Full documentation?
	// -------------------
	
	gen docsamp = sample!=5
	gen docsubst = subst >= 0
	gen docresp = resratei == 1
	gen docback = back >= 0

	collapse ///
	  (sum) docsamp docsubst docresp docback ///
	  (count) noc=docsamp ///
	  , by(survey)

	// Rank
	gen index = docsamp/noc + docsubst/noc + docresp/noc + docback/noc
	gsort - index survey
	format index %2.1f
	
	listtex survey noc docsamp docsubst docresp docbac index using ansample01_1.tex, rstyle(tabular) replace
	
	exit
	


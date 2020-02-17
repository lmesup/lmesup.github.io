* Fraction of Women with Confidence Bounds around true-Value
* kohler@wz-berlin.de

version 9

	drop _all
	set memory 90m
	set more off
	
	// Data
	use svydat01, clear

	// Number of Participating Countries
	by survey ctrname, sort: gen noc = 1 if _n==1
	by survey (ctrname): replace noc = sum(noc)
	by survey: replace noc = noc[_N]

	// Number of Countries within the "EU 29"
	by survey ctrname, sort: gen nocEU = 1 if _n==1 & eu
	by survey (ctrname): replace nocEU = sum(nocEU)
	by survey: replace nocEU = nocEU[_N]

	// Number of obs per Country (EU only)
	by survey ctrname: gen nobs = _N
	by survey (nobs), sort: gen nobsmin = nobs[1]
	by survey (nobs): gen nobsmax = nobs[_N]
	
	// Keep first obs only
	by survey: keep if _n==1
	keep survey noc nocEU nobsmin nobsmax
	

	// Produce the table
	input str30 target
	"Citizens 15+"
	"Residents 18+"
	"Residents 15+"
	"Citizens 18+"
	"-"
	"Residents 18+ "
	
	listtex survey target noc nocEU using ansvydes02.tex, rstyle(tabular) replace
	
	exit
	


	
	

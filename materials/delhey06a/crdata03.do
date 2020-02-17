	// Add Stamdard of Living  to data02
	// ---------------------------------
	// (based on crdata02.do) 

version 8.2
	set more off
	
	// Data to generate
	local mylist "origID cntry dep"

	// Hungary/Turkey
	// --------------
	
	use $em/em, clear
	keep if inlist(country,3,8)
	drop if v8 < 18
	
	// ID
	ren id origID

	// Country-String
	gen cntry = "Hungary" if country == 3
	replace cntry = "Turkey" if country == 8
	drop country

	// Deprivation 
	egen dep = neqany(v21a-v21s), v(2)
	egen mis = rmiss(v21a-v21s)
	replace dep = dep/(19 - mis) * 19
	
	// Store
	keep `mylist' 
	compress
	tempfile hutur
	save `hutur'


	// Germany
	// --------

	use $wfs/wfs
	keep if f031s ==1

	// ID
	ren idnum origID

	// Country
	gen cntry = "Germany (W)" if splits==1
	replace cntry = "Germany (E)" if splits==2


	// Deprivation 
	egen dep = neqany(f092*), v(2)
	egen mis = rmiss(f092*)
	replace dep = dep/(22 - mis) * 19

	// Append
	// ------

	keep `mylist' 
	compress
	append using `hutur'

   // Labels
	// ------

	lab var origID "Case ID of original data"
	lab var cntry "Country"
	lab var dep "Standard of living"

	sort cntry origID
	tempfile using
	save `using'
	
	use data02, clear
	sort cntry origID
	merge cntry origID using `using'

	save data03, replace
	
	exit
	
	

	// Correlation between Difference-Measures

version 8
	set more off
	capture log close
	log using andiffr, replace
	
	// Data
	// ----

	use ID cntry year within1-turkey_g using data02, clear

	by cntry, sort: pwcorr within1-turkey_g


	log close
	exit




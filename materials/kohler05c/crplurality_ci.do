	* Adds the Bootstraped Confidence-Intervalls to the Result-Set

version 8.2
	set more off
	
	// Entropy
	// ------

	use SEentropy, clear
	gen entropyLB = .
	gen entropyUB = .
	gen entropybs = .
	gen s_cntry = _n in 1/28
	forv i = 1/28 {
		_pctile _bs_`i', p(5 95)
		replace entropyLB = r(r1) in `i'
		replace entropyUB = r(r2) in `i'
		sum _bs_`i', meanonly
		replace entropybs = r(mean) in `i'
	}

	keep s_cntry  entropyLB  entropyUB entropybs
	keep in 1/28
	sort s_cntry
	
	tempfile entropy
	save `entropy'


	// Deviance
	// --------

	use SEdeviance, clear
	gen devianceLB = .
	gen devianceUB = .
	gen deviancebs = .
	gen s_cntry = _n in 1/28
	forv i = 1/28 {
		_pctile _bs_`i', p(5 95)
		replace devianceLB = r(r1) in `i'
		replace devianceUB = r(r2) in `i'
		sum _bs_`i', meanonly
		replace deviancebs = r(mean) in `i'
	}
	
	keep s_cntry  devianceLB  devianceUB deviancebs
	keep in 1/28
	sort s_cntry
	
	tempfile deviance
	save `deviance'


	// Merge Files togehter
	// --------------------
	
	use plurality, clear

	sort s_cntry
	merge s_cntry using `entropy'
	assert _merge==3
	drop _merge

	sort s_cntry
	merge s_cntry using `deviance'
	assert _merge==3
	drop _merge
	

	// Bias-Correction
	// ---------------

	gen bscorr = entropy_s - entropybs
	replace entropyLB = entropyLB + bscorr
	replace entropyUB = entropyUB + bscorr

	replace bscorr = deviance - deviancebs
	replace devianceLB = devianceLB + bscorr
	replace devianceUB = devianceUB + bscorr

	drop deviancebs entropybs
	
	compress
	save plurality_ci, replace


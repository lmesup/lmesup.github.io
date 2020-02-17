* Entropy and Deviance
* --------------------
	
	// Data
	// ----
	
	use s_cntry emplstat persstat teacat hhincqu2 ///
	  using  "$dublin/eqls_4", clear
	
	mark touse
	markout touse hhincqu2 persstat teacat
	keep if touse
	
	keep if emplstat == 1
	drop emplstat
	
	label define yesno 0 "no" 1 "yes"
	
	
	// Entropy
	// -------

	preserve

	* Pattern-Variable
	by hhincqu2 persstat teacat, sort: gen ses = 1 if _n==1
	replace ses = sum(ses) 
	
	plurality ses, by(s_cntry)  // *! version 1.0.0 August 11, 2004 @ 16:21:49
	
	by s_cntry, sort: keep if _n == 1
	matrix Npl = r(N)
	matrix Kpl = r(categ)
	matrix entropy = r(entropy)
	matrix entropy_s = r(stand_entrop)
	matrix diversity_s = r(stand_div)
   svmat Npl
	svmat Kpl
	svmat entropy	 
	svmat entropy_s
	svmat diversity_s
   ren Npl1 Npl
	ren Kpl1 Kpl
	ren entropy1 entropy	 
	ren entropy_s1 entropy_s
	ren diversity_s1 diversity_s 

	sort s_cntry
	tempfile plurality
	save `plurality' 

	// Deviance
	// --------

	restore
	
	// Frequency Data
	by s_cntry hhincqu2 teacat persstat, sort: gen n = _N
	by s_cntry hhincqu2 teacat persstat: keep if _n==1
	fillin s_cntry hhincqu2 teacat persstat
	replace n = 0 if _fillin
	drop _fillin

	// Make Dummy Variables
	foreach var of varlist  hhincqu2 teacat persstat  {
		quietly tab `var', gen(`var')
	}

	// Initialize Postfile
	tempfile deviance
	postfile deviance s_cntry deviance Nempty Ndev using `deviance'
	
	// Loglinear Model by s_cntry
	forvalues k = 1/28 {
		count if n == 0 & s_cntry==`k'
		local zero = r(N)
		sum n if s_cntry==`k'
		local n = r(sum)
		poisson n hhincqu22-hhincqu24 teacat2-teacat4 persstat2-persstat6 if s_cntry==`k'
		post deviance  (`k') (e(chi2)/(e(chi2) + `n')) (`zero') (`n')
	}

	postclose deviance

	use `deviance', clear
	sort s_cntry
	save, replace


	// Add to result-set 0

	use resultset0, clear
	sort s_cntry
	merge s_cntry using `plurality'
	drop _merge
	sort s_cntry
	merge s_cntry using `deviance'
	drop _merge

	save plurality, replace
	
	exit
	

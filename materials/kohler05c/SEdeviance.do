* Bootstrap for Endogenity
* ------------------------

version 8.2
	set more off
	capture log close
	

	// Defines High-Speed deviance for Bootstrap

	capture program drop _dev
program define _dev, rclass
version 8.2

	// Intro
	// -----
		
	quietly {
		preserve
		
		// Make Frequency Data
		// --------------------
		
		by s_cntry hhincqu2 teacat persstat, sort: gen n = _N
		by s_cntry hhincqu2 teacat persstat: keep if _n==1
		
		fillin s_cntry hhincqu2 teacat persstat
		replace n = 0 if _fillin
		drop _fillin

		// Make Dummy Variables
		// ----------------
		
		foreach var of varlist  hhincqu2 teacat persstat  {
			quietly tab `var', gen(`var')
		}
		
		// Loglinear Model by s_cntry
		forvalues k = 1/28 {
			sum n if s_cntry==`k', meanonly
			local n = r(sum)
			poisson n hhincqu22-hhincqu24 teacat2-teacat4 persstat2-persstat6 if s_cntry==`k'
			return scalar dev`k' = (e(chi2)/(e(chi2) + `n'))
		}
		
	}
end
	
	// +------------------------+
	// | I Endogenity/Diversity | 
   // +------------------------+
	
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

	// Heterogenity
	// ------------

	forv i=1/28 {
		local explist "`explist' r(dev`i')"
	}
	
	bootstrap "_dev" `explist' ///
	  , reps(1000) strata(s_cntry) nowarn nobc nonormal dot ///
	  saving(SEdeviance) replace 
	


	exit
	

* Q by Reachability X Sampling Method
* kohler@wz-berlin.de

version 9

	// Intro
	clear
	set memory 80m
	set more off
	set scheme s1mono

	// Data
	use svydat03 if eu & sample != 6 & svymeth != 5
	keep if weich == 1
	drop if hresrate > 90

	replace back = 0 if back==-1
	label value back back
	label define back 0 "No back checks or not known" 1 "Back checks"

	// Q
	collapse (mean) womenp=women hresrate (count) N=women, by(survey iso3166_2 sample)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	drop if survey=="EB 62.1" // No resprates!

	// Response-Rate Plot
	tw ///
	  || sc Q hresrate, ms(O) mlc(black) mfc(black)        ///
	  || lowess Q hresrate, lc(black) lp(solid)            ///
	  || , xlab(#5, grid)                                  ///
	  xtitle(Harmonised response rates)                    ///
	  ytitle("Absolute value of sample bias (|Q|)") ylab(0(2)6, grid)       ///
	  by(sample, legend(off) note("") )

	graph export anQhresmeth.eps, replace
	
exit



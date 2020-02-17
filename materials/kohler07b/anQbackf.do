* Q by HDI
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

	replace backf = 0 if backf >= .
	drop if survey == "EB 62.1" | survey == "EQLS 2003"
	
	// Q
	collapse (mean) womenp=women backf (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2

	// BACKF Plot
	tw ///
	  || sc Q backf, ms(O) mlc(black) mfc(black)                                        ///
	  || lowess Q backf, lcolor(black) lpattern(solid)                                  ///
	  || , xtitle(Fraction of sampl. units selected for back checks) xlabel(#5, grid)   ///
      ytitle("Absolute value of sample bias (|Q|)")                                                      ///
	  ylab(0(2)6, grid)                                                                 ///
	  legend(off)
	graph export anQbackf.eps, replace

exit


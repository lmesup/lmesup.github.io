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

	// Q
	collapse (mean) womenp=women hdi (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))

	// HDI Plot
	tw ///
	  || sc Q hdi, ms(O) mlc(black) mfc(black)              ///
	  || lowess Q hdi, lc(black) lp(solid)                  ///
	  || , xtitle(HDI-Rank) xlabel(#5, grid)                ///
      ytitle("Absolute value of sample bias (|Q|)")                          ///
	  ylab(0(2)6, grid)                                     ///
	  legend(off)
	graph export anQhdi.eps, replace

	pwcorr Q hdi, sig

	
exit


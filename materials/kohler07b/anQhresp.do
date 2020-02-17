* Q by Response Rates
* kohler@wz-berlin.de

* History
* anQhresp: Newly defined Response-Rates (from crsvydatß3)
* ant02.do: Remove Mode of Collection from Results. Descreptive Table.
* ant01.do: First Version
	
version 9

	// Intro
	clear
	set memory 80m
	set more off
	set scheme s1mono

	// Data
	use svydat03 if eu & sample != 6 & svymeth != 5
	keep if weich == 1
	drop if hresrate >= 90
	
	// Q
	collapse (mean) womenp=women hresrate (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2
	preserve

	// Response-Rate Plot
	tw ///
	  || sc Q hresrate, ms(O) mlc(black) mfc(black)        ///
	  || lowess Q hresrate, lc(black) lp(solid)            ///
	  || if survey != "EB 62.1" , xlab(#5, grid)    ///
	  xtitle(Harmonised response rates)                    ///
	  ytitle("Absolute value of sample bias (|Q|)") ylab(0(2)6, grid)       ///
	  legend(off)
	graph export anQhresp.eps, replace

	pwcorr Q hresrate, sig
	
exit


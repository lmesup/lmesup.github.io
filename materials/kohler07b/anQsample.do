* Q by Sampling Methods
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

	// keep sample-labels
	tempfile labels
	label save sample using `labels'
	
	// Q
	collapse (mean) womenp=women hdi sample (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2
	do `labels'
	label value sample sample
	
	// Sampling-Methods Plot
	// ---------------------

	// Calculate some Values
	by sample, sort: egen Qpct1 = pctile(Q), p(25)
	by sample, sort: egen Qpct2 = pctile(Q), p(50)
	by sample, sort: egen Qpct3 = pctile(Q), p(75)
	
	// Jitter along X
	set seed 731
	gen xjitter = sample+invnorm(uniform())*.05

	// The Graph
	tw                                                          ///
	  || rbar Qpct1 Qpct2 sample                                ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || rbar Qpct2 Qpct3 sample                                ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || sc Q xjitter                                           ///
	  , ms(o) mcolor(black) msize(small)                        ///
	  || , xtitle(Sampling-Method)                              ///
	  xlab(1 "SRS" ///
	  2  "Indiv. Reg."   ///
	  3  "Add. Reg."      ///
	  4  "Random-Route"   ///
	  5  "Unknown"   ///
	  )  /// 
      ytitle("Absolute value of sample bias (|Q|)")                        ///
	  ylab(0(2)6, grid)                                         ///
	  legend(off)                         
	graph export anQsample.eps, replace

exit


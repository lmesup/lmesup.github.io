* Q by Back-Checks
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

	// keep back-labels
	tempfile labels
	label save yesno using `labels'
	
	// Q
	collapse (mean) womenp=women hdi back sample (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2
	do `labels'
	label value back yesno
	label define yesno -1 "n.a.", modify
	
	// Sampling-Methods Plot
	// ---------------------

	// Calculate some Values
	by  back, sort: egen Qpct1 = pctile(Q), p(25)
	by  back, sort: egen Qpct2 = pctile(Q), p(50)
	by  back, sort: egen Qpct3 = pctile(Q), p(75)
	
	// Jitter along X
	set seed 731
	gen xjitter = back+invnorm(uniform())*.05

	// The Graph
	tw                                                          ///
	  || rbar Qpct1 Qpct2 back                                  ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || rbar Qpct2 Qpct3 back                                  ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || sc Q xjitter                                           ///
	  if sample != 6, ms(o) mcolor(black) msize(small)          ///
	  || sc Q xjitter                                           ///
	  if sample == 6, ms(o) mlcolor(black) mfcolor(white) msize(small)          ///
	  || , xtitle(Back-Checks)                                  ///
	  xlabel(-1(1)1, valuelabel )                               ///
      ytitle("Absolute value of sample bias (|Q|)")                              ///
	  ylab(0(2)6, grid)                                         ///
	  legend(off)
	graph export anQback.eps, replace

exit


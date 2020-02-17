* Q by Substitutions allowed
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

	// keep subst-labels
	tempfile labels
	label save yesno using `labels'
	
	// Q
	collapse (mean) womenp=women hdi subst sample (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2
	do `labels'
	label value subst yesno
	label define yesno -1 "n.a.", modify


	// Plot
	// -----

	// Calculate some Values
	by subst, sort: egen Qpct1 = pctile(Q), p(25)
	by subst, sort: egen Qpct2 = pctile(Q), p(50)
	by subst, sort: egen Qpct3 = pctile(Q), p(75)
	
	// Jitter along X
	set seed 731
	gen xjitter = subst+invnorm(uniform())*.05

	// The Graph
	tw                                                          ///
	  || rbar Qpct1 Qpct2 subst                                 ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || rbar Qpct2 Qpct3 subst                                 ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || sc Q xjitter, ms(o) mcolor(black) msize(small)         ///
	  || , xtitle(Substitution allowed)                         ///
	  xlabel(0 1, valuelabel )                                  ///
      ytitle("Absolute value of sample bias (|Q|)")                        ///
	  ylab(0(2)6, grid)                                         ///
	  legend(off)
	graph export anQsubst.eps, replace

exit


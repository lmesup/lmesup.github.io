* B by Back-Checks
* kohler@wz-berlin.de

* anBback: version for re_submission, design weights included
* anQback: verion for submission

version 9

	// Intro
	clear
	set memory 80m
	set more off
	set scheme s1mono

	// Data
	use svydat04 if eu & sample != 6 & svymeth != 5
	keep if weich == 1


	// Calculate design effects 
	svyset [pweight=dweight], strata(ost)
	foreach survey in "EVS 1999" "ISSP 2002" "EB 62.1" {
		quietly svy: mean women if iso3166_2=="DE" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local de`:word 1 of `survey'' = D[1,1]
	}
	svyset [pweight=dweight], strata(nirl)
	foreach survey in "ISSP 2002" "EB 62.1" {
		quietly svy: mean women if iso3166_2=="GB" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local gb`:word 1 of `survey''  = D[1,1]
	}

	// keep back-labels
	tempfile labels
	label save yesno using `labels'
	
	// B
	collapse (mean) womenp=women hdi back sample (count) N=women [aw=dweight], by(survey iso3166_2)
	gen B = abs((womenp - .5)/sqrt(.5^2/N))

	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEB')) if survey=="EB 62.1" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEVS')) if survey=="EVS 1999" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deISSP')) if survey=="ISSP 2002" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbEB')) if survey=="EB 62.1" & iso3166_2 == "GB"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbISSP')) if survey=="ISSP 2002" & iso3166_2 == "GB"

	sort survey iso3166_2
	do `labels'
	label value back yesno
	label define yesno -1 "n.a.", modify
	
	// Sampling-Methods Plot
	// ---------------------

	// Calculate some Values
	by  back, sort: egen Bpct1 = pctile(B), p(25)
	by  back, sort: egen Bpct2 = pctile(B), p(50)
	by  back, sort: egen Bpct3 = pctile(B), p(75)
	
	// Jitter along X
	set seed 731
	gen xjitter = back+invnorm(uniform())*.05

	// The Graph
	tw                                                          ///
	  || rbar Bpct1 Bpct2 back                                  ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || rbar Bpct2 Bpct3 back                                  ///
	  , lcolor(black) fcolor(white) barwidth(.5) lwidth(medium) ///
	  || sc B xjitter                                           ///
	  if sample != 6, ms(o) mcolor(black) msize(small)          ///
	  || sc B xjitter                                           ///
	  if sample == 6, ms(o) mlcolor(black) mfcolor(white) msize(small)          ///
	  || , xtitle(Back-Checks)                                  ///
	  xlabel(-1(1)1, valuelabel )                               ///
      ytitle("Absolute value of unit nonresponse bias")       ///
	  ylab(0(2)6, grid)                                         ///
	  legend(off)
	graph export anBback.eps, replace

exit


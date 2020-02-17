* B by HDI
* kohler@wz-berlin.de

* History
* anBhdi: With design-weights for Germany + Norther Irealnd
* anQhid: Version for Submission
	
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

	// B
	collapse (mean) womenp=women hdi (count) N=women [aw=dweight], by(survey iso3166_2)
	gen B = abs((womenp - .5)/sqrt(.5^2/N))

	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEB')) if survey=="EB 62.1" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEVS')) if survey=="EVS 1999" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deISSP')) if survey=="ISSP 2002" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbEB')) if survey=="EB 62.1" & iso3166_2 == "GB"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbISSP')) if survey=="ISSP 2002" & iso3166_2 == "GB"

	// HDI Plot
	tw ///
	  || sc B hdi, ms(O) mlc(black) mfc(black)              ///
	  || lowess B hdi, lc(black) lp(solid)                  ///
	  || , xtitle(HDI-Rank) xlabel(#5, grid)                ///
      ytitle("Absolute value of unit nonresponse bias")   ///
	  ylab(0(2)6, grid)                                     ///
	  legend(off)
	graph export anBhdi.eps, replace

	pwcorr B hdi, sig

	
exit


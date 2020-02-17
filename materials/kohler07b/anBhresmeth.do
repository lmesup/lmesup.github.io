* B by Reachability X Sampling Method
* kohler@wz-berlin.de

version 9

	// Intro
	clear
	set memory 80m
	set more off
	set scheme s1mono

	// Data
	use svydat04 if eu & sample != 6 & svymeth != 5
	keep if weich == 1
	drop if hresrate > 90


	// Calculate design effects 
	svyset [pweight=dweight], strata(ost)
	foreach survey in "EVS 1999" "ISSP 2002" {
		quietly svy: mean women if iso3166_2=="DE" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local de`:word 1 of `survey'' = D[1,1]
	}
	svyset [pweight=dweight], strata(nirl)
	foreach survey in "ISSP 2002"  {
		quietly svy: mean women if iso3166_2=="GB" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local gb`:word 1 of `survey''  = D[1,1]
	}

	replace back = 0 if back==-1
	label value back back
	label define back 0 "No back checks or not known" 1 "Back checks"

	// B
	collapse (mean) womenp=women hresrate (count) N=women [aw=dweight], by(survey iso3166_2 sample)
	gen B = abs((womenp - .5)/sqrt(.5^2/N))

	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEVS')) if survey=="EVS 1999" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deISSP')) if survey=="ISSP 2002" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbISSP')) if survey=="ISSP 2002" & iso3166_2 == "GB"

	drop if survey=="EB 62.1" // No resprates!

	// Response-Rate Plot
	tw ///
	  || sc B hresrate, ms(O) mlc(black) mfc(black)        ///
	  || lowess B hresrate, lc(black) lp(solid)            ///
	  || , xlab(#5, grid)                                  ///
	  xtitle(Harmonised response rates)                    ///
	  ytitle("Absolute value of unit nonresponse bias") ylab(0(2)6, grid)       ///
	  by(sample, legend(off) note("") )

	graph export anBhresmeth.eps, replace
	
	by sample, sort: pwcorr B hresrate, sig


	exit



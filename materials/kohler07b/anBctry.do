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
	collapse (mean) womenp=women eu (count) N=women, by(survey ctrname)
	gen B = abs((womenp - .5)/sqrt(.5^2/N))

	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEB')) /// 
	if survey=="EB 62.1" & ctrname == "Germany"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEVS')) /// 
	if survey=="EVS 1999" & ctrname == "Germany"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deISSP')) /// 
	if survey=="ISSP 2002" & ctrname == "Germany"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbEB')) /// 
	if survey=="EB 62.1" & ctrname == "United Kingdom"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbISSP')) /// 
	if survey=="ISSP 2002" & ctrname == "United Kingdom"

	drop womenp N

	encode survey, gen(svy)
	drop survey

	reshape wide B, i(ctrname) j(svy)
	egen Bmean = rmean(B?)
	egen Bmax = rmax(B?)
	egen Bmin = rmin(B?)

	egen axis = axis(eu Bmean), label(ctrname) reverse gap 
	
	graph twoway ///
	|| rspike Bmin Bmax axis, lcolor(black) horizontal ///
	|| scatter axis B1, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis B2, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis B3, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis B4, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis B5, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis B6, ms(o) mlcolor(black) mfcolor(white)              ///
	||, ylab(1(1)4 6(1)15 17(1)31, angle(0) valuelabel grid gstyle(dot)) ///
	  ytitle("")                                                         ///
	  xline(1.96) xtitle("Absolute value of unit nonresponse bias")          ///
          legend(off) ysize(6)
	graph export anBctry.eps, replace


	// Within and Between Variance
	drop Bmean Bmax Bmin axis
	egen rvar = rsd(B*)
	replace rvar = rvar^2
	egen rmean = rmean(B*)

	sum rvar      // Mean of within country variance
	sum rmean, d  // Variance of Country means 

	preserve 
	

	
	exit

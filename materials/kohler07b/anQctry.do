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
	collapse (mean) womenp=women eu (count) N=women, by(survey ctrname)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	drop womenp N

	encode survey, gen(svy)
	drop survey

	reshape wide Q, i(ctrname) j(svy)
	egen Qmean = rmean(Q?)
	egen Qmax = rmax(Q?)
	egen Qmin = rmin(Q?)

	egen axis = axis(eu Qmean), label(ctrname) reverse gap 
	
	graph twoway ///
	|| rspike Qmin Qmax axis, lcolor(black) horizontal ///
	|| scatter axis Q1, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis Q2, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis Q3, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis Q4, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis Q5, ms(o) mlcolor(black) mfcolor(white)              ///
	|| scatter axis Q6, ms(o) mlcolor(black) mfcolor(white)              ///
	||, ylab(1(1)4 6(1)15 17(1)31, angle(0) valuelabel grid gstyle(dot)) ///
	  ytitle("")                                                         ///
	  xline(1.96) xtitle("Absolute value of sample bias (|Q|)")          ///
          legend(off) ysize(6)
	graph export anQctry.eps, replace


	// Within and Between Variance
	drop Qmean Qmax Qmin axis
	egen rvar = rsd(Q*)
	replace rvar = rvar^2
	egen rmean = rmean(Q*)

	sum rvar      // Mean of within country variance
	sum rmean, d  // Variance of Country means 

	preserve 
	

	
	exit

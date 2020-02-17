 //  Who has wrong perceptions? 
 //  Creator: kohler@wz-berlin.de
 
 
 //  INTRO 
 //  -----
 
version 9.0
	clear
	set more off
	set memory 32m
	set scheme s1mono
	

	// The truth!
	// ----------
	
	use ctrname gdp2003 using agg, clear
	xtile x = gdp2003, n(4)
	gen true = -2 if x == 1
	replace true = -1 if x == 2
	replace true = 1 if x == 3
	replace true = 2 if x == 4
	
	keep ctrname true gdp2003
	sort ctrname
	tempfile agg
	save `agg'


	// Produce the Dataset
	// -------------------
	
	capture use data01, clear
	if _rc==601 {
		do crdata01
		use data01
	}
	
	sort ctrname
	merge ctrname using `agg'
	assert _merge == 3
	drop _merge


	// AV
	// --

	gen correct = 0 if compeco==true & !mi(compeco)
	replace correct = 0 if abs(true)==1 & compeco==0 & !mi(compeco)
	replace correct = -1 if compeco<true & correct!=0 & !mi(compeco)
	replace correct =  1 if compeco>true & correct!=0 & !mi(compeco)

	gen tohigh = correct==1 if inlist(correct,0,1)
	gen tolow = correct==-1 if inlist(correct,-1,0)

	// A graphical representation of the AV
	// ------------------------------------

	preserve
	tab correct, gen(correct)
	collapse (mean) correct? gdp2003 eu [aweight = weight], by(iso3166_2)

	gen correct2low = -1 * (correct2 - correct2/2)
	gen correct2high = (correct2 - correct2/2)
	replace correct1 = correct2low + (correct1 * -1) 
	replace correct3 = correct2high + correct3


	gen labpos = 0

	replace eu = eu*-1
	egen axis = axis(eu gdp2003), gap reverse
	graph twoway                                                                    ///
	  || rbar correct1 correct2low axis, horizontal fcolor(gs0) lcolor(black)      ///
	  || rbar correct2low correct2high axis, horizontal  fcolor(gs8) lcolor(black) ///
	  || rbar correct2high correct3 axis, horizontal fcolor(gs16) lcolor(black)     ///
	  || sc axis labpos, ms(i) mlab(iso3166_2) mlabpos(0)             ///
	  || , scheme(s1mono)                                             ///
	  legend(order(1 "Too low" 2 "Correct" 3 "Too high") rows(1) )    ///
	  xscale(titlegap(-3.5)) ///
	  xtitle(Percent) xlab(-.75 "75" -.5 "50" -.25 "25" .25 "25" .5 "50" .75 "75") ///
	  ylabel(none) ytitle("")
	graph export anwhowrong.eps, replace
	restore
	
	// UV
	// --

	gen ecstat:ecstat = 1 if empocc==1
	replace ecstat = 2 if inlist(empocc,2,3)
	replace ecstat = 3 if empocc==4
	replace ecstat = 4 if empocc==8
	replace ecstat= 5 if inlist(empocc,5,6,7)
	label define ecstat 1 "Self employed" 2 "White collar" 3 "Blue collar" 4 "Student" 5 "Econ. inactive"
	

	foreach var of varlist loc edu ecstat mar {
		levelsof `var', local(K)
		foreach k of local K {
			gen `var'`k':yesno = `var'==`k' if !mi(`var')
			label variable `var'`k' "`:label (`var') `k''"
		}
	}
			
	levelsof iso3166_2, local(K)
		foreach k of local K {
			gen c`k':yesno = iso3166_2=="`k'" if !mi(`var')
			label variable c`k' "`k'"
	}
	
	mark touse
	markout touse correct men age edu2-edu4 ecstat2-ecstat5 cBE-cSK
	keep if touse

	logit tolow men age cBE-cSK
	estimates store mod1
	
	logit tolow edu2-edu4 cBE-cSK
	estimates store mod2
	
	logit tolow ecstat2-ecstat5 cBE-cSK
	estimates store mod3
	
	logit tolow men age edu2-edu4 ecstat2-ecstat5 cBE-cSK
	estimates store mod4

	logit tohigh men age cBE-cSK
	estimates store mod5
	
	logit tohigh edu2-edu4 cBE-cSK
	estimates store mod6
	
	logit tohigh ecstat2-ecstat5 cBE-cSK
	estimates store mod7
	
	logit tohigh men age edu2-edu4 ecstat2-ecstat5 cBE-cSK
	estimates store mod8

	estout mod1 mod2 mod3 mod4 mod5 mod6 mod7 mod8 ///
	using anwhowrong.txt ///
	  , replace style(tab) label varwidth(1) ///
	  cells(b(fmt(%3.2f) star)) ///
	  drop(cBE cCY cCZ cDE cDK cEE cES cFI cFR cGB cGR cHU cIE cIT cLT cLU cLV cMT cNL cPL cPT cSE cSI cSK) ///
	  varlabels(_cons Constant, ///
	  blist(edu2 "Education (reference: low" ///
	  ecstat2   "Combined occupational and employment status (reference: self-employed) " ///
	  )) ///
	  stats(r2_p bic N, labels("Pseudo R²" "BIC" "obs.") fmt(%9.2f %9.0f %9.0f)) ///
	  starlevels(* 0.05) 

	estimates drop _all

	exit
	







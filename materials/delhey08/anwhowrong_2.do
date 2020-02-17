 //  Who has wrong perceptions? -> Delhey Proposal for "the truth"
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
	
	input str2 iso3166_2 truelb trueub
	LV -2  -2
	PL -2  -2
	EE -2  -2
	LT -2  -2
	SK -2  -2
	HU -1  -1
	CZ -1  -1
	MT -1  -1
	SI -1  -1
	CY -1  -1
	PT -1  -1
	GR -1   0
	ES -1   1
	IT  0   1
	DE  0	1
	FI  0	1
	FR  0	1
	SE  0 	1
	BE  0   1
	GB  0   1
	NL  1   1
	AT  1   1
	DK  1   1
	IE  1   2
	LU  2   2
end

	sort iso3166_2
	merge iso3166_2 using agg, keep(gdp2003) nokeep
	assert _merge==3
	drop _merge
	sort iso3166_2
	tempfile agg
	save `agg'


	// Produce the Dataset
	// -------------------
	
	capture use data01, clear
	if _rc==601 {
		do crdata01
		use data01
	}
	
	sort iso3166_2
	merge iso3166_2 using `agg'
	assert _merge == 3
	drop _merge


	// AV
	// --

	gen correct = 0 if compeco>=truelb & compeco<= trueub & !mi(compeco)
	replace correct = -1 if compeco<truelb & !mi(compeco)
	replace correct =  1 if compeco>trueub & correct!=0 & !mi(compeco)

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
	graph twoway                                                      ///
	  || rbar correct1 correct2low axis, horizontal fcolor(gs0) lcolor(black)      ///
	  || rbar correct2low correct2high axis, horizontal  fcolor(gs8) lcolor(black) ///
	  || rbar correct2high correct3 axis, horizontal fcolor(gs16) lcolor(black)     ///
	  || sc axis labpos, ms(i) mlab(iso3166_2) mlabpos(0)             ///
	  || , scheme(s1mono)                                             ///
	  legend(order(1 "Too low" 2 "Correct" 3 "Too high") rows(1) )    ///
	  xscale(titlegap(-3.5)) ///
	  xtitle(Percent) xlab(-.75 "75" -.5 "50" -.25 "25" .25 "25" .5 "50" .75 "75") ///
	  ylabel(none) ytitle("")
	graph export anwhowrong_2.eps, replace
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
	keep if touse & (!cLV &  !cPL & !cEE & !cLT & !cSK & !cIE & !cLU )

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
	using anwhowrong_2.txt ///
	  , replace style(tab) label varwidth(1) ///
	  cells(b(fmt(%3.2f) star)) ///
/* 	  drop(cBE cCY cCZ cDE cDK cEE cES cFI cFR cGB cGR cHU cIE cIT cLT cLU cLV cMT cNL cPL cPT cSE cSI cSK) /// 
*/	  varlabels(_cons Constant, ///
	  blist(edu2 "Education (reference: low)" ///
	  ecstat2   "Combined occupational and employment status (reference: self-employed) " ///
	  )) ///
	  stats(r2_p bic N, labels("Pseudo R²" "BIC" "obs.") fmt(%9.2f %9.0f %9.0f)) ///
	  starlevels(* 0.05) 

	estimates drop _all

	exit
	







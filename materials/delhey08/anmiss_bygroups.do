	//  Fraction of Missings for Comparison-Variables by Coutry
	//  Creator: kohler@wz-berlin.de
	
	
	//  INTRO 
	//  -----
	
version 9.0
	clear
	set more off
	set memory 32m
	set scheme s1mono
	
	capture use data01
	if _rc==601 {
		do crdata01
		use data01
	}
	
	
	local i 1
	foreach var of varlist compeco compemp compqual {
		gen mis`i++' = `var' >= .
	}

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
	markout touse  men age edu2-edu4 ecstat2-ecstat5 cBE-cSK
	keep if touse
	
	logit mis1 men age cBE-cSK
	estimates store mod1
	
	logit mis1 edu2-edu4 cBE-cSK
	estimates store mod2
	
	logit mis1 ecstat2-ecstat5 cBE-cSK
	estimates store mod3
	
	logit mis1 men age edu2-edu4 ecstat2-ecstat5 cBE-cSK
	estimates store mod4

	logit mis2 men age cBE-cSK
	estimates store mod5
	
	logit mis2 edu2-edu4 cBE-cSK
	estimates store mod6
	
	logit mis2 ecstat2-ecstat5 cBE-cSK
	estimates store mod7
	
	logit mis2 men age edu2-edu4 ecstat2-ecstat5 cBE-cSK
	estimates store mod8

	logit mis3 men age cBE-cSK
	estimates store mod9
	
	logit mis3 edu2-edu4 cBE-cSK
	estimates store mod10
	
	logit mis3 ecstat2-ecstat5 cBE-cSK
	estimates store mod11
	
	logit mis3 men age edu2-edu4 ecstat2-ecstat5 cBE-cSK
	estimates store mod12
	
	estout mod1 mod2 mod3 mod4 mod5 mod6 mod7 mod8 mod9 mod10 mod11 mod12 ///
	using anmiss_bygroups.txt ///
	  , replace style(tab) label varwidth(1) ///
	  cells(b(fmt(%3.2f) star)) ///
 	  drop(cBE cCY cCZ cDE cDK cEE cES cFI cFR cGB cGR cHU cIE cIT cLT cLU cLV cMT cNL cPL cPT cSE cSI cSK) /// 
	  varlabels(_cons Constant, ///
	  blist(edu2 "Education (reference: low)" ///
	  ecstat2   "Combined occupational and employment status (reference: self-employed) " ///
	  )) ///
	  stats(r2_p bic N, labels("Pseudo R²" "BIC" "obs.") fmt(%9.2f %9.0f %9.0f)) ///
	  starlevels(* 0.05) 

	estimates drop _all

	exit
	

















	collapse (mean) mis1-mis3 eu [aw=weight], by(ctrname)
	gen mean = (mis1 + mis2 + mis3)/3
	reshape long mis, i(ctrname) j(item)
	label value item item
	label define item 1 "Economy" 2 "Employment" 3 "Quality of life"

	egen axis = axis(mean ctrname), label(ctrname) reverse
	egen imeans = mean(mis), by(item)
	
	// Graph
	// -----

	// in percent
	replace mis = mis * 100
	replace imeans = imeans*100
	
	graph twoway  ///
	  || line axis imeans, lcolor(black)                                     ///
	  || scatter axis mis if eu == 1, ms(O) mfcolor(white) mlcolor(black)  ///
	  || scatter axis mis if eu == 2, ms(O) mfcolor(black) mlcolor(black)  ///
	  || , by(item, note("") legend(off) col(3))                                  ///
	  ylabel(1(1)25, valuelabel angle(0) grid gstyle(dot) ) ytitle("")     ///
	  xlabel(0(5)15) 
	graph export anmiss_2.eps, replace

	exit
	

	  
	

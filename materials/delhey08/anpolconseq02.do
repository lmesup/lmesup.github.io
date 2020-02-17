version 9
	set more off
	set scheme s1mono
	capture log close
	log using anpolconseq02, replace
	
	use data01, clear
	
	// Keep the Variable labels
	local i 1
	foreach var of varlist  euengine {
		local labdef `"`labdef' `i++' `"`:var lab `var''"'"'
	}
	

	// Control Variables
	// -----------------

	gen age2 = age^2
	label var age2 "Age (squared)"

	tab ownfin, gen(ownfin) 
	lab var ownfin1 "Very bad"
	lab var ownfin2 "Rather bad"
	lab var ownfin3 "Rather good"
	lab var ownfin4 "Very good"
	
	tab edu, gen(edu)
	lab var edu1 "Low"
	lab var edu2 "Intermediate"
	lab var edu3 "High"
	lab var edu4 "Other/Missing"

	tab empocc, gen(empocc)
	label var empocc1 "Self-employed"
	label var empocc2 "Managers"
	label var empocc3 "Other white collar"
	label var empocc4 "Manual workers"
	label var empocc5 "House person"
	label var empocc6 "Unemployed"
	label var empocc7 "Retired"
	label var empocc8 "Students"

	tab mar, gen(mar)
	label var mar1 "Married"
	label var mar2 "Unmarried"
	label var mar3 "Divoreced"
	label var mar4 "Widowed"
	label var mar5 "Other/Missing"


	replace compqual = !inlist(compqual,-1,0,1) if !mi(compqual)
		
	// Declare Postfile
	// ----------------

	tempfile coefs
	tempname coef
	postfile `coef' str2 iso3166_2 bcomp secomp using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	replace intnr = 1 if intnr == .
	svyset intnr [pweight=weight]

	foreach ctr in AT BE CY CZ DE DK EE ES FI FR GB GR HU IE IT LT ///
	  LU LV MT NL PL PT SE SI SK  {
		svy: logit euengine compqual ownfin ///
		  men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
		  if iso3166_2 == `"`ctr'"'
		estimates store `ctr'
		local b1 = cond(_b[compqual],_b[compqual],.)
		local b2 = cond(_se[compqual],_se[compqual],.)
		post `coef' (`"`ctr'"') (`b1') (`b2')
		
	}
	

	postclose `coef'
	
	// Graphs
	// ------

	use `coefs', clear

	sort iso3166_2
	merge iso3166_2 using agg, keep(ctrname eu hdi2002 gdp2003 )
	assert _merge == 3
	drop _merge

	by ctrname, sort: gen mean = sum(bcomp)/sum(bcomp<.)
	by ctrname: replace mean = mean[_N]
	egen axis = axis(mean), label(ctrname) reverse

	gen ubcomp = bcomp + 1.96 * secomp
	gen lbcomp = bcomp - 1.96 * secomp
	
	graph twoway ///
	  || rspike ubcomp lbcomp axis, horizontal lcolor(black) ///
	  || scatter axis bcomp if eu == 1, ms(O) mfcolor(white) mlcolor(black)       ///
	  || scatter axis bcomp if eu == 2, ms(O) mfcolor(black) mlcolor(black)       ///
	  || , ysize(8) ylab(1(1)25, valuelabel angle(0) grid gstyle(dot)) ytitle("")  ///
	  xline(0) xtitle("")
	graph export anpolconseq02a.eps, replace


	separate bcomp, by(eu)
	graph twoway ///
	  || scatter bcomp1 bcomp2 gdp2003, ms(O ..) mfcolor(white black) mlcolor(black ..) ///
	  || lowess bcomp gdp2003 if ctrname != "Luxembourg", lcolor(black)  ///
	  || ,  yline(0) xtitle("") by(depvar, rows(2) note("") legend(off)) xscale(log)
	graph export anpolconseq02b.eps, replace
	

	log close
	exit
	
 

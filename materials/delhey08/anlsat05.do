	// Comparison of Life-Satisfaction on Quality-of-Life-Comparison with and without control
	// (See anlsat03.do for formattted Regression tables )
	// kohler@wz-berlin.de
	
version 9
	set more off
	set scheme s1mono
	capture log close
	log using anlsat05, replace
	
	// Data
	// ----

	use data01, clear

	// Control Variables
	// -----------------

	gen age2 = age^2
	label var age2 "Age (squared)"

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


	// Standardize in X
	// ----------------
	foreach var of varlist compqual ownfin {
		sum `var'
		replace `var' = (`var'-r(mean))/r(sd)
	}

	// Declare Postfile
	// ----------------
	tempfile coefs
	tempname coef
	postfile `coef' str2 iso3166_2 bcomp secomp bownfin seownfin using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	replace intnr = 1 if intnr == .
	svyset intnr [pweight=weight]

	local i 1
	local j 1
	foreach ctr in AT BE CY CZ DE DK EE ES FI FR GB GR HU IE IT LT LU LV MT NL PL PT SE SI SK {
		svy: ologit ownqual compqual ownfin men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
		  if iso3166_2 == `"`ctr'"'
		local b1 = cond(_b[compqual],_b[compqual],.)
		local se1 = cond(_se[compqual],_se[compqual],.)
		local b2 = cond(_b[ownfin],_b[ownfin],.)
		local se2 = cond(_se[ownfin],_se[ownfin],.)
		post `coef' (`"`ctr'"') (`b1') (`se1') (`b2') (`se2') 
	}

	postclose `coef'
	
	// Graphs
	// ------

	use `coefs', clear

	sort iso3166_2
	merge iso3166_2 using agg, keep(ctrname eu hdi2002 gdp2003 )
	assert _merge == 3
	drop _merge

	egen axis = axis(bcomp), label(ctrname) reverse

	gen ubcomp = bcomp + 1.96 * secomp
	gen lbcomp = bcomp - 1.96 * secomp
	gen ubownfin = bownfin + 1.96 * seownfin
	gen lbownfin = bownfin - 1.96 * seownfin
	
	graph twoway ///
	  || rspike ubcomp lbcomp axis, horizontal lcolor(black)  ///
	  || rspike ubownfin lbownfin axis, horizontal lcolor(gs10)  ///
	  || scatter axis bcomp if eu == 2, ms(O) mfcolor(black) mlcolor(black)  ///
	  || scatter axis bcomp if eu == 1, ms(O) mfcolor(white) mlcolor(black)  ///
	  || scatter axis bownfin, ms(O) mcolor(gs10)  ///
	  || , ysize(8) ylab(1(1)25, valuelabel angle(0) grid gstyle(dot)) ytitle("")  ///
	  xline(0) xtitle("Regression coefficients from ordered logit models") ///
	  legend( ///
	  order( ///
	  3 "Comparison NMS 10" ///
	  5 "Own financial situation" ///
	  4 "Comparison, OMS 15" ) ///
	   rows(2))
	graph export anlsat05.eps, replace
	

	log close
	exit
	
 

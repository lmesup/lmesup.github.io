	// Comparison of Life-Satisfaction on Quality-of-Life-Comparison with and without control
	// (See anlsat03.do for formattted Regression tables )
	// kohler@wz-berlin.de
	
version 9
	set more off
	set scheme s1mono
	capture log close
	log using anlsat04, replace
	
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


	// Declare Postfile
	// ----------------
	tempfile coefs
	tempname coef
	postfile `coef' str2 iso3166_2 str30 compindic bcomp secomp bownfin seownfin using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	replace intnr = 1 if intnr == .
	svyset intnr [pweight=weight]

	foreach var of varlist compeco compemp compqual {
		lab var `var' `"`=substr(`"`:var lab `var''"',16,.)'"'
		local i 1
		local j 1
		foreach ctr in AT BE CY CZ DE DK EE ES FI FR GB GR HU IE IT LT LU LV MT NL PL PT SE SI SK {
			svy: ologit ownqual `var' ownfin men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
			  if iso3166_2 == `"`ctr'"'
			local b1 = cond(_b[`var'],_b[`var'],.)
			local se1 = cond(_se[`var'],_se[`var'],.)
			local b2 = cond(_b[ownfin],_b[ownfin],.)
			local se2 = cond(_se[ownfin],_se[ownfin],.)
			post `coef' (`"`ctr'"') (`"`:var lab `var''"') (`b1') (`se1') (`b2') (`se2')
			estimates store `ctr'
			local estoutlist "`estoutlist' `ctr'"
			local mlabel "`mlabel' `ctr'" 
		}

		estout `estoutlist'  using anlsat06_`var'.txt ///
		  , replace style(tab) label ///
		  mlabel(`mlabel') /// 
		collabels(, none) ///
		  cells(b(fmt(%3.2f) star)) ///
		  stats(N, labels("obs.") fmt(%9.0f) ) ///
		  varlabels(_cons "Cutpoint" , ///
		  blist(                                                                          ///
		  ownfin2 "Satisfaction with own financial situation (reference: very bad) "      ///
		  edu2    "Education (reference: low education)     "                             ///
		  empocc2 "Combined Employment and Occupation (reference: self-employed)  "       ///
		  mar2    "Marital status (reference: married)  "                                 ///
		  ))       	///
		  eqlabels(,none)  ///
		  starlevels(* 0.05)
		estimates drop _all
		macro drop _estoutlist
	}

	postclose `coef'
	
	// Graphs
	// ------

	use `coefs', clear

	sort iso3166_2
	merge iso3166_2 using agg, keep(ctrname eu hdi2002 gdp2003 )
	assert _merge == 3
	drop _merge

	replace eu = eu == 2
	egen axis = axis(eu gdp2003), label(ctrname) gap reverse

	gen ubcomp = bcomp + 1.96 * secomp
	gen lbcomp = bcomp - 1.96 * secomp
	gen ubownfin = bownfin + 1.96 * seownfin
	gen lbownfin = bownfin - 1.96 * seownfin
	
	sum bcomp if trim(compindic) == "Economy situation" & eu == 1
	gen meanac = r(mean) if trim(compindic) == "Economy situation" & eu == 1
	sum bcomp if trim(compindic) == "Economy situation" & eu == 0
	gen meaneu = r(mean) if trim(compindic) == "Economy situation" & eu == 0

	sum bcomp if trim(compindic) == "Employment situation" & eu == 1
	replace meanac = r(mean) if trim(compindic) == "Employment situation" & eu == 1
	sum bcomp if trim(compindic) == "Employment situation" & eu == 0
	replace meaneu = r(mean) if trim(compindic) == "Employment situation" & eu == 0

	sum bcomp if trim(compindic) == "Quality of life" & eu == 1
	replace meanac = r(mean) if trim(compindic) == "Quality of life" & eu == 1
	sum bcomp if trim(compindic) == "Quality of life" & eu == 0
	replace meaneu = r(mean) if trim(compindic) == "Quality of life" & eu == 0


	graph twoway ///
	  || rspike ubcomp lbcomp axis, horizontal lcolor(black)  ///
	  || line axis meanac, lpattern(dot) lcolor(black) ///
	  || line axis meaneu, lpattern(dot) lcolor(black) ///
	  || scatter axis bcomp if eu == 1, ms(O) mfcolor(black) mlcolor(black)  ///
	  || scatter axis bcomp if eu == 0, ms(O) mfcolor(white) mlcolor(black)  ///
	  || , by(compindic, ///
	  title("Figure 6: Impact of Country-EU-comparison on life-satisfaction") ///
	  subtitle("Unstandardised coefficients of ordered logit models") ///
	  note("Own calculations. Do_file: anlsat06.do")  ///
	  rows(1) note("") ) ///
	  ylab(1(1)10 12(1)26, valuelabel angle(0) grid gstyle(dot)) ytitle("")  ///
	  xline(0, lcolor(gs8) lwidth(*1.2) ) xtitle("Regression coefficients from ordered logit models") ///
	  legend( ///
	  order( ///
	  4 "NMS 10" ///
	  5 "OMS 15" ) ///
	   rows(1))
	graph export anlsat06.eps, replace
	

	log close
	exit
	
 

version 9
	set more off
	set scheme s1mono
	capture log close
	log using anlsat02, replace
	
	// Data
	// ----

	use data01, clear


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


		// Keep the Variable labels
	local i 1
	foreach var of varlist compeco-compqual {
		local labdef `"`labdef' `i++' `"`=subinstr("`:var lab `var''","Own Country-EU:","",.)'"'"'
	}

	
	// Declare Postfile
	// ----------------

	tempfile coefs
	tempname coef
	postfile `coef' str2 iso3166_2 comparison b se n r2 using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	replace intnr = 1 if intnr == .
	svyset intnr [pweight=weight]

	local i 1
	foreach var of varlist compeco compemp compenv compsoc compqual {
		foreach ctr in AT BE CY CZ DE DK EE ES FI FR GB GR HU {
			svy: ologit ownqual `var' men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
			  if iso3166_2 == `"`ctr'"'
			local b = cond(_b[`var'],_b[`var'],.)
			local se = cond(_se[`var'],_se[`var'],.)
			post `coef' (`"`ctr'"') (`i') (`b') (`se') (e(N)) (e(r2_p))
			estimates store `ctr'
			local estoutlist `" `estoutlist' `ctr' "'
			local tabfmt `"`tabfmt'r"'
			local mlabel `"`mlabel' "`ctr'" "'
		}

	
		// Table
		estout `estoutlist'  using anlsat02_`var'_part1.tex ///
		  , replace style(tex) label ///
		  prehead(\begin{tabular}{l`tabfmt'} \hline  & \multicolumn{13}{c}{Survey country} \\\ ) ///
		  posthead(\hline) ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel(`mlabel') /// 
		  collabels(, none) ///
		  cells(b(fmt(%3.2f) star)) ///
		  stats(N F p, labels("\$n\$") fmt(%9.0f %9.2f  %9.3f) ) ///
		  varlabels(_cons "Cutpoint" , ///
		    blist(                                                                                                          ///
		      edu2    "\multicolumn{14}{l}{\emph{Education (reference: low education) }}  \\\ "                             ///
	          empocc2 "\multicolumn{14}{l}{\emph{Combined Employment and Occupation (reference: self-employed) }} \\\ "     ///
	          mar2    "\multicolumn{14}{l}{\emph{Marital status (reference: married) }} \\\ "                               ///
		  ))       	///
		  eqlabels(,none)  ///
		  starlevels(* 0.05) 
		estimates drop _all

		macro drop _estoutlist
		macro drop _tabfmt
		macro drop _mlabel
		
		foreach ctr in IE IT LT LU LV MT NL PL PT SE SI SK {
			svy: ologit ownqual `var' men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
			  if iso3166_2 == `"`ctr'"'
			local b = cond(_b[`var'],_b[`var'],.)
			local se = cond(_se[`var'],_se[`var'],.)
			post `coef' (`"`ctr'"') (`i') (`b') (`se') (e(N)) (e(r2_p))
			estimates store `ctr'
			local estoutlist `" `estoutlist' `ctr' "'
			local tabfmt `"`tabfmt'r"'
			local mlabel `"`mlabel' "`ctr'" "'
		}
		
	
		// Table
		estout `estoutlist'  using anlsat02_`var'_part2.tex ///
		  , replace style(tex) label ///
		  prehead(\begin{tabular}{l`tabfmt'} \hline  & \multicolumn{12}{c}{Survey country} \\\ ) ///
		  posthead(\hline) ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel(`mlabel') /// 
		  collabels(, none) ///
		  cells(b(fmt(%3.2f) star)) ///
		  stats(N F p, labels("\$n\$") fmt(%9.0f %9.2f  %9.3f) ) ///
		  varlabels(_cons "Cutpoint" , ///
		    blist(                                                                                                          ///
		      edu2    "\multicolumn{13}{l}{\emph{Education (reference: low education) }}  \\\ "                             ///
	          empocc2 "\multicolumn{13}{l}{\emph{Combined Employment and Occupation (reference: self-employed) }} \\\ "     ///
	          mar2    "\multicolumn{13}{l}{\emph{Marital status (reference: married) }} \\\ "                               ///
		  ))       	///
		  eqlabels(,none)  ///
		  starlevels(* 0.05) 
		estimates drop _all

		macro drop _estoutlist
		macro drop _tabfmt
		macro drop _mlabel
		local i = `i' + 1

		}

	postclose `coef'
	

	// Graphs
	// ------

	use `coefs', clear

	by iso3166_2, sort: gen bmean = sum(b)/5
	by iso3166_2: replace bmean = bmean[_N]
		
	// Conficence Intervalls
	gen ub = b + 1.96*se
	gen lb = b - 1.96*se

	sum ub, meanonly
	local max = r(max)
	sum lb, meanonly
	local min = r(min)

	sort iso3166_2
	merge iso3166_2 using agg, keep(ctrname eu hdi2002 gdp2003 )
	assert _merge == 3
	drop _merge

	label value comparison comparison
	label define comparison `labdef'

	egen axis = axis(gdp2003), label(ctrname) reverse
	separate axis, by(eu)
	graph twoway ///
	  || rspike ub lb axis, horizontal lcolor(black) ///
	  || scatter axis1 axis2 b, ms(O O) mfcolor(white black) mlcolor(black black)  ///
	  || , by(comparis, rows(2) legend(off)) ysize(8) ylab(1(1)25, valuelabel angle(0)) ///
	  xline(0) xscale(range(`min' `max')) xlabel(`=round(`min',.1)'(.3)`=round(`max',.1)')
	graph export anlsat02.eps, replace
	

	log close
	exit
	
 

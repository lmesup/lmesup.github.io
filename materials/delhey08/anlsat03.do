	// Comparison of Life-Satisfaction on Quality-of-Life-Comparison with and without control
	// kohler@wz-berlin.de
	
version 9
	set more off
	set scheme s1mono
	capture log close
	log using anlsat03, replace
	
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


	// Declare Postfile
	// ----------------

	tempfile coefs
	tempname coef
	postfile `coef' str2 iso3166_2 control bcomp bownfin using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	replace intnr = 1 if intnr == .
	svyset intnr [pweight=weight]

	local i 1
	local j 1
	foreach ctr in AT BE CY CZ DE DK EE ES FI FR GB GR HU IE IT LT LU LV MT NL PL PT SE SI SK {
		svy: ologit ownqual compqual men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
		  if iso3166_2 == `"`ctr'"'
		local b = cond(_b[compqual],_b[compqual],.)
		post `coef' (`"`ctr'"') (0) (`b') (.)
		estimates store null1`ctr'

		svy: ologit ownqual compqual ownfin men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
		  if iso3166_2 == `"`ctr'"'
		local b = cond(_b[compqual],_b[compqual],.)
		post `coef' (`"`ctr'"') (1) (`b') (_b[ownfin])
		estimates store full`ctr'

		svy: ologit ownqual ownfin men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
		  if iso3166_2 == `"`ctr'"'
		local b = cond(_b[ownfin],_b[ownfin],.)
		post `coef' (`"`ctr'"') (2) (.) (`b')
		estimates store null2`ctr'

		// Form estoutlists etc. with 4 countries respectively (this is a tricky one!)
		local estout`j' "`estout`j'' full`ctr' null1`ctr' null2`ctr' "
		local mlab`j' "`mlab`j'' (1) (2) (3) "
		local countryheader`j' = `"`countryheader`j'' & \multicolumn{3}{c}{`ctr'} "'
		local j = cond(`i'==4,`j'+1,`j')
		local i = cond(`i'==4,1,`i'+1)
	}
	postclose `coef'

	// Make the Regression-Tables
	// --------------------------
	
	forv i = 1/`j' {
		estout `estout`i'' using anlsat03_part`i'.tex     ///
		  , replace style(tex) label                      ///
		  prehead(                                        ///
		    \begin{tabular}{lrrrrrrrrrrrr} \hline         ///
		    & \multicolumn{12}{c}{Survey country} \\\     ///
		    `countryheader`i'' \\\                        ///
		  )                                               ///
		  posthead(\hline)                                ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel(`mlab`i'')                                       /// 
		  collabels(, none)                                       ///
		  cells(b(fmt(%3.2f) star))                               ///
		  stats(N F p, labels("\$n\$") fmt(%9.0f %9.2f  %9.3f) )  ///
		  varlabels(_cons "Cutpoint" ,                            ///
		  blist(                                                                                                    ///
		  edu2    "\multicolumn{13}{l}{\emph{Education (reference: low education) }}  \\ "                          ///
		  empocc2 "\multicolumn{13}{l}{\emph{Combined Employment and Occupation (reference: self-employed) }} \\ "  ///
		  mar2    "\multicolumn{13}{l}{\emph{Marital status (reference: married) }} \\ "                            ///
		  ))                                                                                                     	///
		  eqlabels(,none)                                                                                           ///
		  starlevels(* 0.05) 
	}
	

	// Graphs
	// ------

	use `coefs', clear

	sort iso3166_2
	merge iso3166_2 using agg, keep(ctrname eu hdi2002 gdp2003 )
	assert _merge == 3
	drop _merge

	reshape wide bcomp bownfin , i(iso3166_2) j(control)
	egen axis = axis(bcomp0), label(ctrname) reverse
	
	graph twoway ///
	  || pcarrow  bcomp0 axis bcomp1 axis, horizontal color(black) ///
	  || pcarrow  bownfin2 axis bownfin1 axis, horizontal color(gs10) ///
	  || scatter axis bcomp0 if eu == 1, ms(O) mfcolor(white) mlcolor(black)  ///
	  || scatter axis bcomp0 if eu == 2, ms(O) mfcolor(black) mlcolor(black)  ///
	  || scatter axis bownfin2, ms(o) mcolor(gs10)  ///
	  || , ysize(8) ylab(1(1)25, valuelabel angle(0) grid gstyle(dot)) ytitle("")  ///
	  xline(0) ///
	  legend(order(3 "Comparison" 5 "Own financial situation" 1 "Without mutual control") title(Coeficients from Ordered Logit) rows(2))
	graph export anlsat03.eps, replace
	

	log close
	exit
	
 

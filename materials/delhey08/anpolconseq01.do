version 9
	set more off
	set scheme s1mono
	capture log close
	log using anpolconseq01, replace
	
	// Dep. Variable
	// -------------
	
	// Which parties are against EU-Integration
	
	use countryn eu partynam edate per108 per110 rile* ///
	  using ~/data/manifesto/manifesto if eu==10, clear
	by countryn (edate), sort: keep if edate == edate[_N]  // Last election

	// Pro EU - Contra EU
	gen eucmp = per108-per110

	// If leftiest party is agains EU:
	by countryn (rilecmp), sort: gen leftagainst = eucmp[1]<0

	// If most right party is against EU:
	by countryn (rilecmp): gen rightagainst = eucmp[_N]<0

	// Store country-data to merge it with our data
	by countryn: keep if _n==1
	ren countryn ctrname
	keep ctrname leftagainst rightagainst
	replace ctrname = "United Kingdom" if ctrname == "Great Britain"
	sort ctrname
	tempfile manifesto
	save `manifesto'
	
	// Merge to our data
	use data01, clear
	sort ctrname
	merge ctrname using `manifesto'
	assert _merge == 3
	drop _merge

	
	// Construct Pro EU
	gen proeu:yesno = 1
	replace proeu = 0 if inlist(right,8,9,10) & rightagainst==1 
	replace proeu = 0 if inlist(right,1,2,3) & leftagainst==1
	replace proeu = . if mi(right)
	label variable proeu "Attitude in favour of EU"


	// Keep the Variable labels
	local i 1
	foreach var of varlist proeu proconstitution ecofut euengine {
		local labdef `"`labdef' `i++' `"`:var lab `var''"'"'
	}
	

	// Distriputions of Control-Variables
	// ----------------------------------

	preserve
	collapse (mean) proeu proconstitution ecofut euengine ///
	  [aweight=weight], by(iso3166_2)

	local i 1
	foreach var of varlist proeu proconstitution ecofut euengine {
		ren `var' mean`i++'
	}
	reshape long mean, i(iso3166_2) j(depvar)
	label define depvar `labdef'
	label value depvar depvar

	sort iso3166_2
	merge iso3166_2 using agg
	assert _merge == 3
	drop _merge
	
	egen axis = axis(gdp2003), label(ctrname) reverse

	graph twoway ///
	  || scatter axis mean if eu == 1, ms(O) mfcolor(white) mlcolor(black)         ///
	  || scatter axis mean if eu == 2, ms(O) mfcolor(black) mlcolor(black)         ///
	  || , ysize(8) ylab(1(1)25, valuelabel angle(0) grid gstyle(dot)) ytitle("")  ///
	  xtitle("") by(depvar, rows(2) note("") legend(off))
	graph export anpolconseq01_depvars.eps, replace
	
	 restore
		

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
	postfile `coef' str2 iso3166_2 depvar bcomp bownfin using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	replace intnr = 1 if intnr == .
	svyset intnr [pweight=weight]

	local k 0
	foreach var of varlist proeu proconstitution ecofut euengine {
	local i 1
	local j 1
	estimates clear
		local k = `k' + 1
		foreach ctr in AT BE CY CZ DE DK EE ES FI FR GB GR HU IE IT LT ///
		  LU LV MT NL PL PT SE SI SK  {
			count if `var' == 0 & iso3166_2 == "`ctr'"
			if r(N) == 0 {
				post `coef' (`"`ctr'"') (`k') (.) (.)
			}
			else {
				svy: logit `var' compqual ownfin ///
				  men age age2 edu2-edu4 empocc2-empocc8 mar2-mar5  ///
				  if iso3166_2 == `"`ctr'"'
				estimates store `ctr'
				local b1 = cond(_b[compqual],_b[compqual],.)
				local b2 = cond(_b[ownfin],_b[ownfin],.)
				post `coef' (`"`ctr'"') (`k') (`b1') (`b2')

				// Form estoutlists etc. with 4 countries respectively (this is a tricky one!)
				local `var'`j' "``var'`j'' `ctr' "
				local mlab`j' "`mlab`j'' `ctr' "
				local j = cond(`i'==13,`j'+1,`j')
				local i = cond(`i'==13,1,`i'+1)
			}
		}
	
		
		// Make the Regression-Tables
		// --------------------------
		
		forv i = 1/`j' {
			estout ``var'`i'' using anpolconseq01_`var'_part`i'.tex      ///
			  , replace style(tex) label                                 ///
			  prehead(                                                   ///
			  \begin{tabular}{lrrrrrrrrrrrrr} \hline                     ///
			  & \multicolumn{13}{c}{Survey country} \\   )               ///
			  posthead(\hline)                                           ///
			  prefoot(\hline) postfoot(\hline \end{tabular} )            ///
			  mlabel(`mlab`i'')                                          /// 
			collabels(, none)                                            ///
			  cells(b(fmt(%3.2f) star))                                  ///
			  stats(N F p, labels("\$n\$") fmt(%9.0f %9.2f  %9.3f) )     ///
			  varlabels(_cons "Constant" ,                               ///
			  blist(                                                                                                    ///
			  edu2    "\multicolumn{14}{l}{\emph{Education (reference: low education) }}  \\ "                          ///
			  empocc2 "\multicolumn{14}{l}{\emph{Combined Employment and Occupation (reference: self-employed) }} \\ "  ///
			  mar2    "\multicolumn{14}{l}{\emph{Marital status (reference: married) }} \\ "                            ///
			  ))                                                                                                     	///
			  eqlabels(,none)                                                                                           ///
			  starlevels(* 0.05) 
		}
			
	}
	postclose `coef'
	

	
	// Graphs
	// ------

	use `coefs', clear

	sort iso3166_2
	merge iso3166_2 using agg, keep(ctrname eu hdi2002 gdp2003 )
	assert _merge == 3
	drop _merge

	label define depvar `labdef'
	label value depvar depvar
		

	by ctrname, sort: gen mean = sum(bcomp)/sum(bcomp<.)
	by ctrname: replace mean = mean[_N]
	egen axis = axis(mean), label(ctrname) reverse

	graph twoway ///
	  || scatter axis bcomp if eu == 1, ms(O) mfcolor(white) mlcolor(black)       ///
	  || scatter axis bcomp if eu == 2, ms(O) mfcolor(black) mlcolor(black)       ///
	  || , ysize(8) ylab(1(1)25, valuelabel angle(0) grid gstyle(dot)) ytitle("")  ///
	  xline(0) xtitle("") by(depvar, rows(2) note("") legend(off))
	graph export anpolconseq01a.eps, replace

	separate bcomp, by(eu)
	graph twoway ///
	  || scatter bcomp1 bcomp2 gdp2003, ms(O ..) mfcolor(white black) mlcolor(black ..) ///
	  || lowess bcomp gdp2003 if ctrname != "Luxembourg", lcolor(black)  ///
	  || ,  yline(0) xtitle("") by(depvar, rows(2) note("") legend(off)) xscale(log)
	graph export anpolconseq01b.eps, replace
	

	log close
	exit
	
 

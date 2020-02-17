	// Logit-Models Turnout on satisfaction  * country

version 8.2
	clear
	set more off
	set matsize 200
	set scheme s1mono
	capture log close
	log using anturnout4, replace
	
	use s_cntry hh2a hh2b hhinc4 q24a q25 q29* q30*  q31 q46 q54* q56* hhstat emplstat wcountry ///
	  using $dublin/eqls_4, clear

	// Voter
	// ----

	// Nur Wahlberechtigte
	drop if q25 == 3 | q25 >= .
	gen voter = q25==1 

	// Merge Nice Country-Names
	// ------------------------

	sort s_cntry
	merge s_cntry using isocntry
	drop _merge

	// Country-Dummies (in sort order for nice tables)
	by ctrde, sort: gen fraction = sum(voter*wcountry)/sum(wcountry)
	by ctrde, sort: replace fraction = fraction[_N]
	sort fraction
	egen ctrsort = egroup(fraction), label(ctrde)
	tab ctrsort, gen(ctrsort)
	foreach var of varlist ctrsort1-ctrsort28 {
		local label: variable label `var'
		local label = subinstr("`label'","ctrsort==","",1)
		label variable `var' "`label'"
	}

	// Rectangularize Data
	// -------------------

	// I'll keep Missings of Categorical Data
	replace emplstat = 7 if emplstat == .
	replace hhstat = 7 if hhstat == .

	// Listwise Deletion
	mark touse
	markout touse s_cntry hh2a hh2b hhinc4 q24a q25 q31 q46 hhstat emplstat
	keep if touse

	// Recoding
	// --------
	
	// Gender
	gen men = hh2a == 1
	label variable men "Mann"
	
	// Centered Age/Age-squared
	sum hh2b
	gen age = hh2b - r(mean)
	gen age2 = age^2
	label var age "Alter"
	label var age2 "Alter (quadriert)"

	// Income
	egen income = xtile(hhinc4), p(2(2)98) by(s_cntry)
	sum income
	replace income = income - r(mean)
	label var income "Einkommen (50 Quantile)"

	// Education
	egen edu = xtile(q46), p(10(10)90) by(s_cntry)
	sum edu, meanonly
	replace edu = edu - r(mean)
	label var edu "Bildung (Dezile)"

	// Occupation (Household)
	gen occ1 = hhstat==1
	label var occ1 "Dienstklasse"
	gen occ2 = hhstat==2
	label var occ2 "Andere Nicht Manuelle"
	gen occ3 = hhstat==3
	label var occ3 "Selbständige "
	gen occ4 = hhstat==4 | hhstat==5
	label var occ4 "Arbeiter"
	gen occ5 = hhstat == 6 | hhstat == 7
	label var occ5 "Sonstige/Missing"
	
	
	// Employment (Respondend)
	gen emp1 = emplstat==1
	label var emp1 "Erwerbstaetige"
	gen emp2 = emplstat==2
	label var emp2 "Hausfrau/mann"
	gen emp3 = emplstat==3
	label var emp3 "Arbeitslos"
	gen emp4 = emplstat==4
	label var emp4 "Rentner/Pensionäre"
	gen emp5 = emplstat== 5 | emplstat==6 | emplstat == 7
	label var emp5 "Sonstige/Missing"
	
	// Group-Participation
	gen group = q24 == 1
	label var group "Mitarbeit in Gruppe"

	// Life Satisfaction
	gen lsat = q31
	label var lsat "Allg. Lebenszufriedenheit"

	// Tensions
	egen clev = rsum(q29*)
	replace clev = . if clev == 0
	
	// Anomie
	gen anom = q30b + q30e
	sum anom, meanonly
	replace anom = r(max) + 1 - anom

	// Quality of Public Services
	egen pubqual = rsum(q54*)
	replace pubqual = . if pubqual == 0

	// Quality of the Environment
	egen envqual = rsum(q56*)
	replace envqual = . if envqual == 0
	sum envqual, meanonly       // Mirror, to have high values hight "satisfaction"
	replace envqual = r(max) + 1 - envqual
	
	// Life Satisfaction-Model
	// ------------------------

	// Interactions
	foreach var of varlist ctrsort2-ctrsort28 {
		gen `var'lsat = `var' * lsat
		local label: variable label `var'
		label variable `var'lsat "`label' * lsat"
	}

	// Model
	logit voter ctrsort2-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5  ///
	  group lsat ctrsort2lsat - ctrsort28lsat [pw=wcountry]

	// Predicted values
	gen Llowlsat   = _b[_cons] + _b[lsat] if ctrsort==1
	gen Lhighlsat  = _b[_cons] + _b[lsat]*10 if ctrsort==1
	forv i = 2/28 {
		capture replace Llowlsat  = _b[_cons] + _b[ctrsort`i'] + _b[lsat] + _b[ctrsort`i'lsat] if ctrsort==`i'
		capture replace Lhighlsat = _b[_cons] + _b[ctrsort`i'] + _b[lsat]*10 + _b[ctrsort`i'lsat]*10 if ctrsort==`i'
	}
	drop  ctrsort2lsat-ctrsort28lsat


	// Public Services-Model
	// ---------------------

	// Interactions
	foreach var of varlist ctrsort2-ctrsort28 {
		gen `var'pubqual = `var' * pubqual
		local label: variable label `var'
		label variable `var'pubqual "`label' * pubqual"
	}

	// Model
	logit voter ctrsort2-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5  ///
	  group pubqual ctrsort2pubqual - ctrsort28pubqual [pw=wcountry]

	// Predicted values
	gen Llowpubqual   = _b[_cons] + _b[pubqual] if ctrsort==1
	gen Lhighpubqual  = _b[_cons] + _b[pubqual]*50 if ctrsort==1
	forv i = 2/28 {
		capture replace Llowpubqual  = _b[_cons] + _b[ctrsort`i'] + _b[pubqual] + _b[ctrsort`i'pubqual] if ctrsort==`i'
		capture replace Lhighpubqual = _b[_cons] + _b[ctrsort`i'] + _b[pubqual]*50 + _b[ctrsort`i'pubqual]*50 if ctrsort==`i'
	}
	drop  ctrsort2pubqual-ctrsort28pubqual


	// Cleavage-Model
	// --------------

	// Interactions
	foreach var of varlist ctrsort2-ctrsort28 {
		gen `var'clev = `var' * clev
		local label: variable label `var'
		label variable `var'clev "`label' * clev"
	}

	// Model
	logit voter ctrsort2-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5  ///
	  group clev ctrsort2clev - ctrsort28clev [pw=wcountry]

	// Predicted values
	gen Llowclev   = _b[_cons] + _b[clev] if ctrsort==1
	gen Lhighclev  = _b[_cons] + _b[clev]*16 if ctrsort==1
	forv i = 2/28 {
		capture replace Llowclev  = _b[_cons] + _b[ctrsort`i'] + _b[clev] + _b[ctrsort`i'clev] if ctrsort==`i'
		capture replace Lhighclev = _b[_cons] + _b[ctrsort`i'] + _b[clev]*16 + _b[ctrsort`i'clev]*16 if ctrsort==`i'
	}
	drop  ctrsort2clev-ctrsort28clev


	// Lhat -> Phat
	// ------------

	foreach var of varlist L* {
		local stub = substr("`var'",2,.)
		gen P`stub' = exp(`var')/(1+exp(`var'))
		drop `var'
	}
	
	// Graphical Representation
	// -------------------------

	keep s_cntry ctrsort Plow* Phigh* 
	by ctrsort, sort: keep if _n==1

	// Reshape and Relabel
	reshape long Plow Phigh, i(ctrsort) j(var lsat pubqual clev )
	label define contrast 1 "lsat" 2 "pubqual" 3 "clev" 
	encode var, gen(contrast) label(contrast)
	label define contrast 1 "Leben" 2 "Öffentliche Dienste"  3 "Cleavage-Wahrnemung" ///
	   , modify

	// Plot
	sort ctrsort
	graph twoway ///
	  (rspike Plow Phigh ctrsort, horizontal blcolor(black)) ///
	  (scatter ctrsort Plow , ms(O) mfcolor(white) mlcolor(black)) ///
	  (scatter ctrsort Phigh , ms(O) mfcolor(black) mlcolor(black)) ///
	  ,   by(contrast, rows(1) note(""))    ///  
	  yscale(reverse) ylabel(1(1)28, valuelabel angle(horizontal)) ///
	  ytitle("")  ysize(3.7) xsize(5.6) ///
	  legend(order(2 3) lab(2 "Unzufriedene") lab(3 "Zufriedene"))
	graph export anturnout4a.eps, replace

	// Plot II
	gen diff = (Phigh - Plow)
	by ctrsort, sort: egen diffmean = mean(diff)
	sum diffmean, meanonly
	local mean = r(mean)

	graph dot diffmean ///
	  , over(ctrsort, sort(diffmean))  exclude0  ///
	  marker(1, mstyle(p1) mcolor(black) ) ///
	  ytitle("Index Krisensymptome II")  ///
	  yline(`mean') ///
	  ysize(3.25) xsize(2.8) 
	graph export anturnout4b.eps, replace
	

	// Store some results for later use
	keep s_cntry ctrsort diffmean
	by s_cntry, sort: keep if _n==1
	ren diffmean index2
	sort s_cntry 
	save anturnout4, replace

	log close
	exit
	

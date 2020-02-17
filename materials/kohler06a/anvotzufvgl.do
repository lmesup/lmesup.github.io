	// Logit-Models Turnout on satisfaction  * country

version 8.2
	clear
	set more off
	set matsize 200
	set scheme s1mono
	capture log close
	log using anvotzuf, replace
	
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

	// Ehem. Autokratisches System
	// ---------------------------

	gen ac = eu == 2 | eu == 3

	// Rectangularize Data
	// -------------------

	// I'll keep Missings of Categorical Data
	replace emplstat = 7 if emplstat == .
	replace hhstat = 7 if hhstat == .

	// Listwise Deletion
	mark touse
	markout touse s_cntry hh2a hh2b hhinc4 q24a q25 q31 q46 hhstat emplstat
	keep if touse


	// Label according to the Sort-Order
	// ---------------------------------

	preserve
	// Country-Dummies (in sort order for nice tables)
	by ctrde, sort: gen fraction = sum(voter*wcountry)/sum(wcountry)
	by ctrde, sort: replace fraction = fraction[_N]
	bysort ac fraction: keep if  _n==1
	gen ctrsort:ctrsort = (ac-1) + _n
	count
	local n = r(N)
	forv i = 1/`n' {
		local label = ctrde[`i']
		local nr = ctrsort[`i']
		label define ctrsort `nr' "`label'", modify
	}
	keep ctrde ctrsort
	sort ctrde
	tempfile ctrsort
	save `ctrsort'
	restore

	sort ctrde
	merge ctrde using `ctrsort'
	drop _merge

	levels ctrsort, local(K)
	foreach k of local K {
		gen ctrsort`k' = ctrsort == `k'
		local label: label (ctrsort) `k'
		label variable ctrsort`k' "`label'"
	}


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
	gen income = log(hhinc4)
	sum income
	replace income = income - r(mean)
	label var income "HH-Äquiv.-Eink. (in PPS)"

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
	egen clev = rsum(q29a q29b)
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
	
	// Life Satisfaction-Model (with control)
	// --------------------------------------

	// Interactions
	foreach var of varlist ctrsort1-ctrsort28 {
		gen `var'lsat = `var' * lsat
		local label: variable label `var'
		label variable `var'lsat "`label' * lsat"
	}

	// Model
	logit voter ctrsort1-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5  ///
	  group lsat ctrsort1lsat - ctrsort28lsat [pw=wcountry]
	estimates store lsat

	// Predicted values
	gen Llowlsat   = _b[_cons] + _b[lsat] if ctrsort==0
	gen Lhighlsat  = _b[_cons] + _b[lsat]*10 if ctrsort==0
	forv i = 1/28 {
		capture replace Llowlsat  = _b[_cons] + _b[ctrsort`i'] + _b[lsat] + _b[ctrsort`i'lsat] if ctrsort==`i'
		capture replace Lhighlsat = _b[_cons] + _b[ctrsort`i'] + _b[lsat]*10 + _b[ctrsort`i'lsat]*10 if ctrsort==`i'
	}

	// Life Satisfaction-Model (without control)
	// ----------------------------------------

	// Model
	logit voter ctrsort1-ctrsort28 lsat ctrsort1lsat - ctrsort28lsat [pw=wcountry]
	estimates store lsat

	// Predicted values
	gen Llowwoc   = _b[_cons] + _b[lsat] if ctrsort==0
	gen Lhighwoc  = _b[_cons] + _b[lsat]*10 if ctrsort==0
	forv i = 1/28 {
		capture replace Llowwoc  = _b[_cons] + _b[ctrsort`i'] + _b[lsat] + _b[ctrsort`i'lsat] if ctrsort==`i'
		capture replace Lhighwoc = _b[_cons] + _b[ctrsort`i'] + _b[lsat]*10 + _b[ctrsort`i'lsat]*10 if ctrsort==`i'
	}
	drop  ctrsort1lsat-ctrsort28lsat

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
	reshape long Plow Phigh, i(ctrsort) j(var lsat woc )
	label define contrast 1 "lsat" 2 "woc" 
	encode var, gen(contrast) label(contrast)
	label define contrast 1 "Leben" 2 "WOC"  ///
	   , modify

	// Plot
	sort ctrsort
	graph twoway ///
	  (rspike Plow Phigh ctrsort, horizontal blcolor(black)) ///
	  (scatter ctrsort Plow , ms(O) mfcolor(white) mlcolor(black)) ///
	  (scatter ctrsort Phigh , ms(O) mfcolor(black) mlcolor(black)) ///
	  ,   by(contrast, rows(1) note(""))    ///  
	  yscale(reverse) ylabel(0(1)14 16(1)28, valuelabel angle(horizontal)) ///
	  ytitle("")  ysize(3.7) xsize(5.6) ///
	  legend(order(2 3) lab(2 "Unzufriedene") lab(3 "Zufriedene"))

	drop var
	reshape wide diff Phigh Plow, i(ctrsort) j(contrast)
	gen pos = int(uniform()*12) + 1
	sc diff1 diff2 diff2, connect(. l) ms(O i) sort mlab(ctrsort) mlabvpos(pos)
	
	log close
	exit
	

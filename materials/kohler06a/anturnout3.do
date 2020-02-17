	// Logit-Models Turnout on social structur * country

version 8.2
	clear
	set more off
	set matsize 200
	set scheme s1mono
	capture log close
	log using anturnout3, replace
	
	use s_cntry hh2a hh2b hhinc4 q24a q25 q31 q46 hhstat emplstat wcountry ///
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


	// Education- Model
	// -----------------

	// Interactions
	foreach var of varlist ctrsort2-ctrsort28 {
		gen `var'edu = `var' * edu
		local label: variable label `var'
		label variable `var'edu "`label' * Edu"
	}

	// Model
	logit voter ctrsort2-ctrsort28 ctrsort2edu-ctrsort28edu men age age2 edu [pw=wcountry]

	// Predicted values
	gen Llowedu   = _b[_cons] + _b[edu]*-3 if ctrsort==1
	gen Lhighedu  = _b[_cons] + _b[edu]*5 if ctrsort==1
	forv i = 2/28 {
		capture replace Llowedu  = _b[_cons] + _b[ctrsort`i'] + _b[edu]*-3 + _b[ctrsort`i'edu]*-3 if ctrsort==`i'
		capture replace Lhighedu = _b[_cons] + _b[ctrsort`i'] + _b[edu]* 5 + _b[ctrsort`i'edu]*5 if ctrsort==`i'
	}
	drop  ctrsort2edu-ctrsort28edu 
	
	// Class-Model
	// -----------

	foreach var1 of varlist ctrsort2-ctrsort28 {
		foreach var2 of varlist occ2-occ5 {
			gen `var1'`var2' = `var1' * `var2'
			local label1: variable label `var1'
			local label2: variable label `var2'
			label variable `var1'`var2' "`label1' * `label2'"
		}
	}

	// Model
	logit voter ctrsort2-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5 ctrsort2occ2-ctrsort28occ5 [pw=wcountry]

	// Predicted values
	gen Llowocc   = _b[_cons] +  _b[occ4] if ctrsort==1
	gen Lhighocc  = _b[_cons] if ctrsort==1
	forv i = 2/28 {
		capture replace Llowocc  = _b[_cons] + _b[ctrsort`i'] + _b[occ4] + _b[ctrsort`i'occ4] if ctrsort==`i'
		capture replace Lhighocc = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}
	drop  ctrsort?occ* ctrsort??occ*
	
	// Employment-Model
	// ----------------

	foreach var1 of varlist ctrsort2-ctrsort28 {
		foreach var2 of varlist emp2-emp5 {
			gen `var1'`var2' = `var1' * `var2'
			local label1: variable label `var1'
			local label2: variable label `var2'
			label variable `var1'`var2' "`label1' * `label2'"
		}
	}

	// Model
	logit voter ctrsort2-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5 ctrsort2emp2-ctrsort28emp5 [pw=wcountry]

	// Predicted values
	gen Llowemp   = _b[_cons] +  _b[emp3] if ctrsort==1
	gen Lhighemp  = _b[_cons] if ctrsort==1
	forv i = 2/28 {
		capture replace Llowemp  = _b[_cons] + _b[ctrsort`i'] + _b[emp3] + _b[ctrsort`i'emp3] if ctrsort==`i'
		capture replace Lhighemp = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}
	drop  ctrsort?emp* ctrsort??emp*


	// Lhat -> Phat
	// ------------

	foreach var of varlist L* {
		local stub = substr("`var'",2,.)
		gen P`stub' = exp(`var')/(1+exp(`var'))
		drop `var'
	}
	
	// Graphical Representation
	// -------------------------

	// Aggregate Data
	foreach var of varlist emp1 emp3 occ1 occ4 {
		local stub = substr("`var'",1,3)
		local type = cond(substr("`var'",4,1)=="1","high","low")
		by ctrsort, sort: gen N`type'`stub' = sum(`var')
		by ctrsort: replace N`type'`stub' = N`type'`stub'[_N]
	}
	
	keep s_cntry ctrsort Plow* Phigh* N*
	by ctrsort, sort: keep if _n==1

	// Reshape and Relabel
	reshape long Plow Phigh Nlow Nhigh, i(ctrsort) j(var edu occ emp)
	label define contrast 1 "edu" 3 "occ" 2 "emp"
	encode var, gen(contrast) label(contrast)
	label define contrast 1 "Geringe vs. Hohe Bildung" ///
	  3 "Arbeiter vs. Dienstklasse" 2 "Arbeitslos vs. Erwerbstätig", modify

	// Plot
	sort ctrsort
	graph twoway ///
	  (rspike Plow Phigh ctrsort, horizontal blcolor(black)) ///
	  (scatter ctrsort Plow , ms(O) mfcolor(white) mlcolor(black)) ///
	  (scatter ctrsort Phigh , ms(O) mfcolor(black) mlcolor(black)) ///
	  ,  by(contrast, rows(1) note("") ) ///
	  yscale(reverse) ylabel(1(1)28, valuelabel angle(horizontal)) ///
	  ytitle("")  ysize(3.7) xsize(5.6) ///
	  legend(order(2 3) lab(2 "Statusniedere") lab(3 "Statushöhere"))


	graph export anturnout3a.eps, replace

	// Plot II
	gen weight = 1 if var == "edu"
	replace weight = log(Nlow) if var ~= "edu"
	sum weight, meanonly
	replace weight = r(mean) if var == "edu"
	gen diff = (Phigh - Plow) * weight 
	by ctrsort, sort: egen diffmean = mean(diff)
	by ctrsort, sort: gen nmiss = sum(diff>=.)
	by ctrsort, sort: replace nmiss = nmiss[_N]

	sum diffmean, meanonly
	local mean = r(mean)

	separate diffmean, by(nmiss)

	graph dot diffmean0 diffmean1 ///
	  , over(ctrsort, sort(diffmean))  exclude0  ///
	  marker(1, mstyle(p1) mcolor(black) ) ///
	  marker(2, mstyle(p1) mlcolor(black) mfcolor(white) ) ///
	  ytitle("Index Krisensymptome I")  ///
	  yline(`mean') ///
	  legend(lab(1 "3 Dimensionen") lab(2 "2 Dimensionen")) ///
	  ysize(3.5) xsize(2.8) 
	graph export anturnout3b.eps, replace
	
	// Store some results for later use
	keep s_cntry ctrsort diffmean
	by s_cntry, sort: keep if _n==1
	ren diffmean index1
	sort s_cntry
	save anturnout3, replace

	log close
	exit
	

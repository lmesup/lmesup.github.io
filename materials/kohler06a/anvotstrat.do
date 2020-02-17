	// Logit-Models Turnout on social structur * country

version 8.2
	clear
	set more off
	set matsize 800
	set scheme s1mono
	capture log close
	log using anvotstrat, replace
	
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

	// Descriptive Graphs
	// ------------------

	// Education
	graph box q46, horizontal  ///
	  over(ctrde, sort(1)) ///
	  over(ac, label(nolabels) )  ///
	  nofill nooutsides ///
	  box(1, bstyle(outline)) box(2, bstyle(outline))  ///
	  marker(1, ms(oh) mcolor(black)) marker(2, ms(oh) mcolor(black))  ///
	  medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  ytitle("") note("") graphregion(margin(r=30)) ///
	  title(Alter bei Schulabschluss, box width(100)) ///
	  name(g1, replace)
	
	// Employment
  	graph dot emp1 emp2 emp3 emp4, horizontal nofill exclude0 ///
	  over(ctrde, sort((mean) emp3))  ///
	  over(ac, label(nolabels) )  ///
	  marker(1, mstyle(p1) mlcolor(black) mfcolor(white) ) ///
	  marker(2, mstyle(p1) mcolor(gs10) msize(small) ) ///
	  marker(3, mstyle(p1) mcolor(black) ) ///
	  marker(4, mstyle(p1) mlcolor(gs10) mfcolor(white) msize(small) ) ///
	  legend( order(3 1 2 4)  region(lstyle(none))  ///
	    lab(1 "Erwerbstätig") lab(2 "Hausfrau/mann") lab(3 "Arbeitslos") lab(4 "Rentner")  ///
	    pos(2) col(1) width(30)) ///
	  title("Erwerbsstatus (in %)", box width(100) ) ///
	  name(g2, replace)

	// Klasse
	graph dot occ1 occ2 occ3 occ4, horizontal nofill exclude0 ///
	  over(ctrde, sort((mean) occ4))  ///
	  over(ac, label(nolabels) )  ///
	  marker(1, mstyle(p1) mlcolor(black) mfcolor(white) ) ///
	  marker(2, mstyle(p1) mcolor(gs10) msize(small) ) ///
	  marker(3, mstyle(p1) mlcolor(gs10) mfcolor(white) msize(small) ) ///
	  marker(4, mstyle(p1) mcolor(black) ) ///
	  legend( order(4 1 2 3) region(lstyle(none)) ///
	    lab(1 "Dienstklasse") lab(2 "And. Nicht-Manuelle") lab(3 "Selbständige") lab(4 "Arbeiter") ///
	    pos(2) col(1) width(30)) ///
	  title("Beruf Hauptverdiener (in %)", box width(100) ) ///
	  name(g3, replace)

	graph combine g1 g2 g3, col(1) ysize(8.0) xsize(3) graphregion(margin(none))
	graph export anvotstrat_des.eps, replace
	
	// Education- Model
	// -----------------

	// Interactions
	foreach var of varlist ctrsort1-ctrsort28 {
		gen `var'edu = `var' * edu
		local label: variable label `var'
		label variable `var'edu "`label' * Edu"
	}

	// Model
	logit voter ctrsort1-ctrsort28 ctrsort1edu-ctrsort28edu men age age2 edu [pw=wcountry]
	estimates store edu
	
	// Predicted values
	gen Llowedu   = _b[_cons] + _b[edu]*-3 if ctrsort==0
	gen Lhighedu  = _b[_cons] + _b[edu]*5 if ctrsort==0
	forv i = 1/28 {
		capture replace Llowedu  = _b[_cons] + _b[ctrsort`i'] + _b[edu]*-3 + _b[ctrsort`i'edu]*-3 if ctrsort==`i'
		capture replace Lhighedu = _b[_cons] + _b[ctrsort`i'] + _b[edu]* 5 + _b[ctrsort`i'edu]*5 if ctrsort==`i'
	}
	drop  ctrsort1edu-ctrsort28edu 
	
	// Class-Model
	// -----------

	foreach var1 of varlist ctrsort1-ctrsort28 {
		foreach var2 of varlist occ2-occ5 {
			gen `var1'`var2' = `var1' * `var2'
			local label1: variable label `var1'
			local label2: variable label `var2'
			label variable `var1'`var2' "`label1' * `label2'"
		}
	}

	// Model
	logit voter ctrsort1-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5 ctrsort1occ2-ctrsort28occ5 [pw=wcountry]
	estimates store occ

	
	// Predicted values
	gen Llowocc   = _b[_cons] +  _b[occ4] if ctrsort==0
	gen Lhighocc  = _b[_cons] if ctrsort==0
	forv i = 1/28 {
		capture replace Llowocc  = _b[_cons] + _b[ctrsort`i'] + _b[occ4] + _b[ctrsort`i'occ4] if ctrsort==`i'
		capture replace Lhighocc = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}

	replace Llowocc = . if inlist(iso3166_2,"CY")
	replace Lhighocc = . if inlist(iso3166_2,"CY")
	
	drop  ctrsort?occ* ctrsort??occ*

	// Employment-Model
	// ----------------

	foreach var1 of varlist ctrsort1-ctrsort28 {
		foreach var2 of varlist emp2-emp5 {
			gen `var1'`var2' = `var1' * `var2'
			local label1: variable label `var1'
			local label2: variable label `var2'
			label variable `var1'`var2' "`label1' * `label2'"
		}
	}

	// Model
	logit voter ctrsort1-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5 ctrsort1emp2-ctrsort28emp5 [pw=wcountry]
	estimates store emp

	// Predicted values
	gen Llowemp   = _b[_cons] +  _b[emp3] if ctrsort==0
	gen Lhighemp  = _b[_cons] if ctrsort==0
	forv i = 1/28 {
		capture replace Llowemp  = _b[_cons] + _b[ctrsort`i'] + _b[emp3] + _b[ctrsort`i'emp3] if ctrsort==`i'
		capture replace Lhighemp = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}

	replace Llowemp = . if inlist(iso3166_2,"MT","DK","GR","CY","LU")
	replace Lhighemp = . if inlist(iso3166_2,"MT","DK","GR","CY","LU")
	
	drop  ctrsort?emp* ctrsort??emp*

	// Table
	estout edu emp occ ///
	using anvotstrat.tex ///
	  , replace style(tex) label ///
	  keep(men age age2 edu income occ2 occ3 occ4 occ5 emp2 emp3 emp4 emp5) ///
	  prehead(\begin{tabular}{lrrr} \hline  & \multicolumn{3}{c}{Ungleichheitsdimension} \\\\ ) ///
	  posthead(\hline) ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  mlabel("Bildung" "Erwerbsstatus" "Klasse" ) /// 
			collabels(, none) ///
	  cells(b(fmt(%3.2f) star)) ///
	  stats(r2_p N, labels("\$r_{\text{MF}}^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
	  varlabels(_cons Konstante, ///
	  blist(occ2 "\multicolumn{4}{l}{\\emph{Klasse}} \\\\ `=char(13)'" ///
			emp2 "\multicolumn{4}{l}{\\emph{Erwerbsstatus}} \\\\ `=char(13)'" ///
			)) ///	 
	  starlevels(* 0.05) 

	// Lhat -> Phat
	// ------------

	foreach var of varlist L* {
		local stub = substr("`var'",2,.)
		gen P`stub' = exp(`var')/(1+exp(`var'))
		drop `var'
	}
	
	// Graph for 3 Models
	// -------------------

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
	graph twoway ///
	  (rspike Plow Phigh ctrsort, horizontal blcolor(black)) ///
	  (scatter ctrsort Plow , ms(O) mfcolor(black) mlcolor(black)) ///
	  (scatter ctrsort Phigh , ms(O) mfcolor(white) mlcolor(black)) ///
	  ,  by(contrast, rows(1) note("") ) ///
	  yscale(reverse) ylabel(0(1)14 16(1)28, valuelabel angle(horizontal)) ///
	  ytitle("")  ysize(3.7) xsize(5.6) ///
	  legend(order(2 3)lab(2 "Statusniedere") lab(3 "Statushöhere"))

	graph export anvotstrat1.eps, replace

	// Graph for "Krisenindikator"
	// --------------------------
	
	gen diff = (Phigh - Plow) 
	by ctrsort, sort: egen diffmean = mean(diff)
	by ctrsort, sort: gen nmiss = sum(diff>=.)
	by ctrsort, sort: replace nmiss = nmiss[_N]

	sum diffmean, meanonly
	local mean = r(mean)

	gen diffmean0 = diffmean if nmiss == 0
	gen diffmean1 = diffmean if nmiss > 0
	gen ac = ctrsort >= 16


	// Label according to the Sort-Order

	preserve
	decode ctrsort, gen(ctrstring)
	bysort ac diffmean: keep if  _n==1
	gen sorter:sorter = (ac-1) + _n
	count
	local n = r(N)
	forv i = 1/`n' {
		local label = ctrstring[`i']
		local nr = sorter[`i']
		label define sorter `nr' "`label'", modify
	}
	keep ctrsort sorter
	sort ctrsort
	tempfile sorter
	save `sorter'
	restore
	sort ctrsort
	merge ctrsort using `sorter'
	drop _merge

	sum diffmean0 if ac
	gen acm = r(mean) if ac
	sum diffmean1 if !ac
	gen ecm = r(mean) if !ac
	
	// Plot
	graph twoway ///
	  (dot diffmean0 diffmean1 sorter , ///
	  horizontal mstyle(p1 p1) mlcolor(black black) mfcolor(black white)) ///
	  (line sorter acm, clpattern(shortdash) clcolor(black) clwidth(thin) ) ///
	  (line sorter ecm, clpattern(shortdash) clcolor(black) clwidth(thin) ) ///
	  , yscale(reverse) ///
	  ylabel(0(1)14 16(1)28, valuelabel angle(0))  ///
	   ///
	  ytitle("")  ///
	  legend(order(1 2) lab(1 "3 Dimensionen") lab(2 "<3 Dimensionen")) ///
	  ysize(3.5) xsize(2.8) 
	graph export anvotstrat2.eps, replace
	
	// Store some results for later use
	// -------------------------------

	keep s_cntry ctrsort var diffmean diff
	reshape wide diff, i(s_cntry) j(var, string)
	ren diffmean index1
	sort s_cntry
	save anvotstrat, replace

	log close
	exit
	

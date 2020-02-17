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


	// Descriptive Graphs
	// ------------------

	// Life-Satisfaction
	graph box lsat, horizontal  ///
	  over(ctrde, sort(1)) ///
	  over(ac, label(nolabels) )  ///
	  nofill nooutsides ///
	  box(1, bstyle(outline)) box(2, bstyle(outline))  ///
	  marker(1, ms(oh) mcolor(black)) marker(2, ms(oh) mcolor(black))  ///
	  medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  ytitle("") note("") graphregion(margin(r=30)) ///
	  title(Lebenszufriedenheit, box width(100)) ///
	  name(g1, replace)

	// Tensions
	graph box clev, horizontal  ///
	  over(ctrde, sort(1)) ///
	  over(ac, label(nolabels) )  ///
	  nofill nooutsides ///
	  box(1, bstyle(outline)) box(2, bstyle(outline))  ///
	  marker(1, ms(oh) mcolor(black)) marker(2, ms(oh) mcolor(black))  ///
	  medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  ytitle("") note("") graphregion(margin(r=30)) ///
	  title(Anomie, box width(100)) ///
	  name(g2, replace)

	// Klasse
	graph box pubqual, horizontal  ///
	  over(ctrde, sort(1)) ///
	  over(ac, label(nolabels) )  ///
	  nofill nooutsides ///
	  box(1, bstyle(outline)) box(2, bstyle(outline))  ///
	  marker(1, ms(oh) mcolor(black)) marker(2, ms(oh) mcolor(black))  ///
	  medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  ytitle("") note("") graphregion(margin(r=30)) ///
	  title(Zuf. m. öffentl. Diensten, box width(100)) ///
	  name(g3, replace)

	graph combine g1 g2 g3, col(1) ysize(8.0) xsize(3) graphregion(margin(none))
	graph export anvotzuf_des.eps, replace

	
	
	// Life Satisfaction-Model
	// ------------------------

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
	drop  ctrsort1lsat-ctrsort28lsat


	// Public Services-Model
	// ---------------------

	// Interactions
	foreach var of varlist ctrsort1-ctrsort28 {
		gen `var'pubqual = `var' * pubqual
		local label: variable label `var'
		label variable `var'pubqual "`label' * pubqual"
	}

	// Model
	logit voter ctrsort1-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5  ///
	  group pubqual ctrsort1pubqual - ctrsort28pubqual [pw=wcountry]
	estimates store pubqual

	// Predicted values
	gen Llowpubqual   = _b[_cons] + _b[pubqual] if ctrsort==0
	gen Lhighpubqual  = _b[_cons] + _b[pubqual]*50 if ctrsort==0
	forv i = 1/28 {
		capture replace Llowpubqual  = _b[_cons] + _b[ctrsort`i'] + _b[pubqual] + _b[ctrsort`i'pubqual] if ctrsort==`i'
		capture replace Lhighpubqual = _b[_cons] + _b[ctrsort`i'] + _b[pubqual]*50 + _b[ctrsort`i'pubqual]*50 if ctrsort==`i'
	}
	drop  ctrsort1pubqual-ctrsort28pubqual


	// Tensions-Modell
	// --------------

	// Interactions
	foreach var of varlist ctrsort1-ctrsort28 {
		gen `var'clev = `var' * clev
		local label: variable label `var'
		label variable `var'clev "`label' * clev"
	}

	// Model
	logit voter ctrsort1-ctrsort28 men age age2 edu ///
	  income occ2-occ5 emp2-emp5  ///
	  group clev ctrsort1clev - ctrsort28clev [pw=wcountry]
	estimates store clev

	// Predicted values
	gen Llowclev   = _b[_cons] + _b[clev] if ctrsort==0
	gen Lhighclev  = _b[_cons] + _b[clev]*6 if ctrsort==0
	forv i = 1/28 {
		capture replace Llowclev  = _b[_cons] + _b[ctrsort`i'] + _b[clev] + _b[ctrsort`i'clev] if ctrsort==`i'
		capture replace Lhighclev = _b[_cons] + _b[ctrsort`i'] + _b[clev]*6 + _b[ctrsort`i'clev]*6 if ctrsort==`i'
	}
	drop  ctrsort1clev-ctrsort28clev


	// Table
	estout lsat pubqual clev ///
	using anvotzuf.tex ///
	  , replace style(tex) label ///
	  keep(men age age2 edu income occ2 occ3 occ4 occ5 emp2 emp3 emp4 emp5 group) ///
	  prehead(\begin{tabular}{lrrr} \hline  & \multicolumn{3}{c}{Ungleichheitsdimension} \\\\ ) ///
	  posthead(\hline) ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  mlabel("Leben" "Öffentl. Dienste" "Cleav.-Wahrn." ) /// 
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
	  yscale(reverse) ylabel(0(1)14 16(1)28, valuelabel angle(horizontal)) ///
	  ytitle("")  ysize(3.7) xsize(5.6) ///
	  legend(order(2 3) lab(2 "Unzufriedene") lab(3 "Zufriedene"))
	graph export anvotzuf1.eps, replace

	// Graph for "Krisenindikator"
	// --------------------------

	gen diff = (Phigh - Plow) 
	by ctrsort, sort: egen diffmean = mean(diff)
	gen ac = ctrsort >= 16

	sum diffmean if ac
	gen acm = r(mean) if ac
	sum diffmean if !ac
	gen ecm = r(mean) if !ac

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

	
	// Plot
	graph twoway ///
	  (dot diffmean sorter , ///
	  horizontal mstyle(p1 p1) mlcolor(black black) mfcolor(black white)) ///
	  (line sorter acm, clpattern(shortdash) clcolor(black) clwidth(thin) ) ///
	  (line sorter ecm, clpattern(shortdash) clcolor(black) clwidth(thin) ) ///
	  , yscale(reverse) ///
	  ylabel(0(1)14 16(1)28, valuelabel angle(0))  ///
	  legend(off) ///
	  ytitle("")  ///
	  ysize(3.3) xsize(2.8) 
	graph export anvotzuf2.eps, replace
	

	// Store some results for later use
	// -------------------------------

	keep s_cntry ctrsort var diffmean diff
	reshape wide diff, i(s_cntry) j(var, string)
	ren diffmean index2
	sort s_cntry
	save anvotzuf, replace

	log close
	exit
	

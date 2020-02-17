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
	bysort eu fraction: keep if  _n==1
	gen ctrsort:ctrsort = (eu-1) + _n
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

	// Education- Model
	// -----------------

	// Interactions
	foreach var of varlist ctrsort2-ctrsort30 {
		gen `var'edu = `var' * edu
		local label: variable label `var'
		label variable `var'edu "`label' * Edu"
	}

	// Model
	logit voter ctrsort2-ctrsort30 ctrsort2edu-ctrsort30edu men age age2 edu [pw=wcountry]
	estimates store eduwc
	
	// Predicted values
	gen Lloweduwc   = _b[_cons] + _b[edu]*-3 if ctrsort==1
	gen Lhigheduwc  = _b[_cons] + _b[edu]*5 if ctrsort==1
	forv i = 2/30 {
		capture replace Lloweduwc  = _b[_cons] + _b[ctrsort`i'] + _b[edu]*-3 + _b[ctrsort`i'edu]*-3 if ctrsort==`i'
		capture replace Lhigheduwc = _b[_cons] + _b[ctrsort`i'] + _b[edu]* 5 + _b[ctrsort`i'edu]*5 if ctrsort==`i'
	}


	// Model
	logit voter ctrsort2-ctrsort30 ctrsort2edu-ctrsort30edu edu [pw=wcountry]
	
	// Predicted values
	gen Lloweduwoc   = _b[_cons] + _b[edu]*-3 if ctrsort==1
	gen Lhigheduwoc  = _b[_cons] + _b[edu]*5 if ctrsort==1
	forv i = 2/30 {
		capture replace Lloweduwoc  = _b[_cons] + _b[ctrsort`i'] + _b[edu]*-3 + _b[ctrsort`i'edu]*-3 if ctrsort==`i'
		capture replace Lhigheduwoc = _b[_cons] + _b[ctrsort`i'] + _b[edu]* 5 + _b[ctrsort`i'edu]*5 if ctrsort==`i'
	}

	drop  ctrsort2edu-ctrsort30edu 
	
	// Class-Model
	// -----------

	foreach var1 of varlist ctrsort2-ctrsort30 {
		foreach var2 of varlist occ2-occ5 {
			gen `var1'`var2' = `var1' * `var2'
			local label1: variable label `var1'
			local label2: variable label `var2'
			label variable `var1'`var2' "`label1' * `label2'"
		}
	}

	// Model
	logit voter ctrsort2-ctrsort30 men age age2 edu ///
	  income occ2-occ5 emp2-emp5 ctrsort2occ2-ctrsort30occ5 [pw=wcountry]
	estimates store occwc
	
	// Predicted values
	gen Llowoccwc   = _b[_cons] +  _b[occ4] if ctrsort==1
	gen Lhighoccwc  = _b[_cons] if ctrsort==1
	forv i = 2/30 {
		capture replace Llowoccwc  = _b[_cons] + _b[ctrsort`i'] + _b[occ4] + _b[ctrsort`i'occ4] if ctrsort==`i'
		capture replace Lhighoccwc = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}

	replace Llowoccwc = . if inlist(iso3166_2,"CY")
	replace Lhighoccwc = . if inlist(iso3166_2,"CY")


	// Model
	logit voter ctrsort2-ctrsort30 occ2-occ5 ctrsort2occ2-ctrsort30occ5 [pw=wcountry]
	
	// Predicted values
	gen Llowoccwoc   = _b[_cons] +  _b[occ4] if ctrsort==1
	gen Lhighoccwoc  = _b[_cons] if ctrsort==1
	forv i = 2/30 {
		capture replace Llowoccwoc  = _b[_cons] + _b[ctrsort`i'] + _b[occ4] + _b[ctrsort`i'occ4] if ctrsort==`i'
		capture replace Lhighoccwoc = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}

	replace Llowoccwoc = . if inlist(iso3166_2,"CY")
	replace Lhighoccwoc = . if inlist(iso3166_2,"CY")
	
	drop  ctrsort?occ* ctrsort??occ*

	// Employment-Model
	// ----------------

	foreach var1 of varlist ctrsort2-ctrsort30 {
		foreach var2 of varlist emp2-emp5 {
			gen `var1'`var2' = `var1' * `var2'
			local label1: variable label `var1'
			local label2: variable label `var2'
			label variable `var1'`var2' "`label1' * `label2'"
		}
	}

	// Model
	logit voter ctrsort2-ctrsort30 men age age2 edu ///
	  income occ2-occ5 emp2-emp5 ctrsort2emp2-ctrsort30emp5 [pw=wcountry]
	estimates store empwc

	// Predicted values
	gen Llowempwc   = _b[_cons] +  _b[emp3] if ctrsort==1
	gen Lhighempwc  = _b[_cons] if ctrsort==1
	forv i = 2/30 {
		capture replace Llowempwc  = _b[_cons] + _b[ctrsort`i'] + _b[emp3] + _b[ctrsort`i'emp3] if ctrsort==`i'
		capture replace Lhighempwc = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}

	replace Llowempwc = . if inlist(iso3166_2,"MT","DK","GR","CY","LU")
	replace Lhighempwc = . if inlist(iso3166_2,"MT","DK","GR","CY","LU")

	// Model
	logit voter ctrsort2-ctrsort30 emp2-emp5 ctrsort2emp2-ctrsort30emp5 [pw=wcountry]

	// Predicted values
	gen Llowempwoc   = _b[_cons] +  _b[emp3] if ctrsort==1
	gen Lhighempwoc  = _b[_cons] if ctrsort==1
	forv i = 2/30 {
		capture replace Llowempwoc  = _b[_cons] + _b[ctrsort`i'] + _b[emp3] + _b[ctrsort`i'emp3] if ctrsort==`i'
		capture replace Lhighempwoc = _b[_cons] + _b[ctrsort`i'] if ctrsort==`i'
	}

	replace Llowempwoc = . if inlist(iso3166_2,"MT","DK","GR","CY","LU")
	replace Lhighempwoc = . if inlist(iso3166_2,"MT","DK","GR","CY","LU")
	
	drop  ctrsort?emp* ctrsort??emp*

	// Table
	estout eduwc empwc occwc ///
	using anvotstrat1.tex ///
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
	
	// Graphical Representation
	// -------------------------

	keep s_cntry ctrsort Plow* Phigh* 
	by ctrsort, sort: keep if _n==1

	// Reshape and Relabel
	reshape long Plow Phigh, i(ctrsort) j(var eduwc eduwoc occwc occwoc empwc empwoc )

	gen contrast:contrast = 1 if var == "eduwc" | var == "eduwoc"
	replace contrast = 2 if var == "empwc" | var == "empwoc"
	replace contrast = 3 if var == "occwc" | var == "occwoc"
	label define contrast 1 "Geringe vs. hohe Bildung" ///
	  3 "Arbeiter vs. Dienstklasse" 2 "Arbeitslos vs. Erwerbstätig", modify
	gen control = index(var,"wc")

	// Plot
	sort ctrsort
	graph twoway ///
	  (rspike Plow Phigh ctrsort if !control, horizontal blcolor(gs12) blwidth(thin)) ///
	  (scatter ctrsort Plow if !control, ms(o) mfcolor(gs12) mlcolor(gs12)) ///
	  (scatter ctrsort Phigh if !control, ms(o) mfcolor(gs12) mlcolor(gs12)) ///
	  (rspike Plow Phigh ctrsort if control, horizontal blcolor(black)) ///
	  (scatter ctrsort Plow if control, ms(O)  mfcolor(black) mlcolor(black)) ///
	  (scatter ctrsort Phigh if control, ms(O) mfcolor(white) mlcolor(black)) ///
	  ,  yscale(reverse) ylabel(1(1)15 17(1)26 28(1)30, grid gstyle(dot) valuelabel angle(horizontal)) ///
	    by(contrast, rows(1) note("")) ///
	  ytitle("")  ysize(3.7) xsize(5.6) ///
	  legend(order(5 6) lab(5 "Statusniedere") lab(6 "Statushöhere"))
	graph export anvotstrat1a.eps, replace


	// Store some results for Later User
	// --------------------------------

	drop if !control
	gen diff = (Phigh - Plow) 
	by ctrsort, sort: egen diffmean = mean(diff)

	keep s_cntry ctrsort var diff diffmean
	reshape wide diff, i(s_cntry) j(var, string)
	ren diffmean index1
	sort s_cntry
	save anvotstrat1, replace

	log close
	exit
	
	

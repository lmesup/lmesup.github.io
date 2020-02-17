	// anlsat01, but no Control-Variables
	// ---------------------------------

	// weights, robust se
	// estout

	// - treats contacts within country and generalized reference-groups separately
	// - includes differences between  own LC and Own Countries LC
	// - Nicer Graphs

version 8
	set more off
	set scheme s1mono
	capture log close
	log using annocontrols, replace
	
	// Data
	// ----

	use data02, clear

	gen contacts = (friends + neighbours)/2
	gen own = germany_i if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace own=hungary_i if cntry == "Hungary"
	replace own=turkey_i if cntry == "Turkey"
	
	// Declare Postfile
	// ----------------

	tempfile coefs
	tempname coef
	postfile `coef' str11 ctry str20 diffctry str1 type b_c se_c n r2 using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	svyset [pweight=pweight]
	gen selected = .
	lab var selected "Coef. Reference-Country"
	
	// Turkey
	foreach type in g i {
		foreach diffctry in  poland hungary spain italy france sweden netherlands switzerland {
			replace selected = `diffctry'_`type'
				svyreg lsat selected   ///
				  if cntry == "Turkey"
				local b = cond(_b[selected],_b[selected],.)
				local se = cond(_se[selected],_se[selected],.)
				post `coef' ("Turkey") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
		}
	}
	

	// Hungary
	foreach type in g i {
		foreach diffctry in  poland spain italy germany france sweden netherlands switzerland {
			replace selected = `diffctry'_`type'
			svyreg lsat selected  ///
			  if cntry == "Hungary"
			local b = cond(_b[selected],_b[selected],.)
			local se = cond(_se[selected],_se[selected],.)
			post `coef' ("Hungary") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
		}
	}	
	
	// Germany_E
	foreach type in g i {
		foreach diffctry in  poland hungary spain italy france otherpart netherlands switzerland {
			replace selected = `diffctry'_`type'
			svyreg lsat selected  ///
			  if cntry == "Germany (E)"
			local b = cond(_b[selected],_b[selected],.)
			local se = cond(_se[selected],_se[selected],.)
			post `coef' ("Germany (E)") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
		}
	}
		
	// Germany_W
	foreach type in g i {
		foreach diffctry in  poland hungary spain italy france otherpart netherlands switzerland {
			replace selected = `diffctry'_`type'
			svyreg lsat selected  ///
			  if cntry == "Germany (W)"
			local b = cond(_b[selected],_b[selected],.)
			local se = cond(_se[selected],_se[selected],.)
			post `coef' ("Germany (W)") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
		}
	}

	
	// Regression Models for Within-country-Comparisons
	// -------------------------------------------------
				

	local i 1
	foreach k in "Turkey" "Hungary" "Germany (E)" "Germany (W)" {
		foreach diffctry in own contacts {
			replace selected = `diffctry' 
			svyreg lsat selected  ///
			  if cntry == "`k'"
			local `diffctry'`i' = _b[selected]
		}
		local i = `i' + 1
	}

	label var selected "Reference Group"

	postclose `coef'

	// Graphs
	// ------

	use `coefs', clear
	
	gen country:ctry = 4 if ctry == "Germany (W)"
	replace country = 3 if ctry == "Germany (E)"
	replace country = 2 if ctry == "Hungary"
	replace country = 1 if ctry == "Turkey"
	label def ctry 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"

	gen refcountry =      1 if diffctry == "poland"
	replace refcountry =  2 if diffctry == "hungary"
	replace refcountry =  3 if diffctry == "spain" 
	replace refcountry =  4 if diffctry == "italy"	  
	replace refcountry =  5 if diffctry == "otherpart" & (country == 3 | country== 4)
	replace refcountry =  5 if diffctry == "germany" & (country == 1 | country== 2)
	replace refcountry =  6 if diffctry == "france" 
	replace refcountry =  7 if diffctry == "sweden"  
	replace refcountry =  8 if diffctry == "netherlands"
	replace refcountry =  9 if diffctry == "switzerland"


	// Lines for Neigbours/Friends Reference Groups
	gen contacts =  `contacts1' if country == 1
	replace contacts =  `contacts2' if country == 2
	replace contacts =  `contacts3' if country == 3
	replace contacts =  `contacts4' if country == 4

	// Lines for Own Country Reference Group
	gen own =  `own1' if country == 1
	replace own =  `own2' if country == 2
	replace own =  `own3' if country == 3
	replace own =  `own4' if country == 4

	// Conficence Intervalls
	gen ub = b_c + 1.96*se_c
	gen lb = b_c - 1.96*se_c

	local conopt "clstyle(p1) mstyle(p1) sort mfcolor(white) mlcolor(black) clcolor(black) "
	local rareaopt "sort bcolor(gs12)"
	local lineopt "clstyle(p2 p3) sort"
	
	tw ///
	  (rarea ub lb refcountry, `rareaopt') ///
	  (connected b_c refcountry, `conopt') ///
	  (line contacts own  refcountry, `lineopt') ///
	  if type == "i"  ///
	  , by(country, rows(1) note("")) ///
	  xlab(1 "PL" 2 "HU" 3 "ES" 4 "IT" 5 "D" 6 "FR" 7 "SW" ///
	  8 "NL" 9 "CH", alternate) ///
	  xtitle("") ytitle(Regression Coefficients) ///
	  legend(order(2 3 4) rows(2) lab(2 "Other Countries") lab(3 "Neigbours and Friends") lab(4 "Own country")) ///
	  ylabel(0(.1).5)

	graph export annocontrols_i.eps, replace

	tw ///
	  (rarea ub lb refcountry, `rareaopt') ///
	  (connected b_c refcountry, `conopt') ///
	  (line contacts own  refcountry , `lineopt' ) ///
	  if type == "g"  ///
	  , by(country, rows(1) note("")) ///
	  xlab(1 "PL" 2 "HU" 3 "ES" 4 "IT" 5 "D" 6 "FR" 7 "SW" ///
	  8 "NL" 9 "CH", alternate) ///
	  xtitle("") ytitle(Regression Coefficients) ///
	  legend(order(2 3 4) rows(2) lab(2 "Other Countries") lab(3 "Neigbours and Friends") lab(4 "Own country")) ///
	  ylabel(0(.1).5)

	graph export annocontrols_g.eps, replace

	log close
	exit
	
 
 

	

	
	
	
	

	

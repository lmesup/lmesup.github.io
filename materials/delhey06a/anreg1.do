	// Refinemet of anreg1.do
	// - treats contacts within country and generalized reference-groups separately
	// - includes differences between  own LC and Own Countries LC
	// - Nicer Graphs

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anreg2, replace
	
	// Data
	// ----

	use data02, clear


	// Control Variables
	// -----------------

	gen age2 = age^2
	gen lhinceq = log(hinceq)  // 21 obs to missing

	recode edu (1 2 = 1) (3 = 2) (4= 3) (5=4) (6 = .)
	label define edu 1 "Primary and below" 2 "lower secondary" 3 "secondary" 4 "tertiary", modify
	tab edu, gen(edu)

	tab emp, gen(emp)
	tab occ, gen(occ)

	replace mar = . if mar == 5
	tab mar, gen(mar)

	gen contacts = (friends + neighbours)/2
	

	// Declare Postfile
	// ----------------

	tempfile coefs
	tempname coef
	postfile `coef' str11 ctry str20 diffctry str1 type b_c se_c n r2 using `coefs'

	// Regression Models
	// -----------------


	// Germanies
	foreach ctry in "Germany (W)" "Germany (E)" {
		foreach diffctry in hungary poland france spain italy switzerland netherlands germany otherpart {
			foreach type in g i {
				regress lsat `diffctry'_`type' men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
				  if cntry == "`ctry'"
				local b = cond(_b[`diffctry'_`type'],_b[`diffctry'_`type'],.)
				local se = cond(_se[`diffctry'_`type'],_se[`diffctry'_`type'],.)
				post `coef' ("`ctry'") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
			}
		}
	}
	regress lsat contacts men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Germany (W)"
	local bcontacts_germanyw = _b[contacts]
	regress lsat contacts men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Germany (E)"
	local bcontacts_germanye = _b[contacts]
	regress lsat germany_i men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Germany (W)"
	local bown_germanyw = _b[germany_i]
	regress lsat germany_i men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Germany (E)"
	local bown_germanye = _b[germany_i]
	

	// Hungary
	foreach diffctry in poland france spain italy switzerland netherlands germany sweden {
		foreach type in g i {
			regress lsat `diffctry'_`type' contacts men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Hungary"
			local b = cond(_b[`diffctry'_`type'],_b[`diffctry'_`type'],.)
			local se = cond(_se[`diffctry'_`type'],_se[`diffctry'_`type'],.)
			post `coef' ("Hungary") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
		}
	}
	regress lsat contacts men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Hungary"
	local bcontacts_hungary = _b[contacts]
	regress lsat hungary_i men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Hungary"
	local bown_hungary = _b[hungary_i]

	
	// Turkey
	foreach diffctry in hungary poland france spain italy switzerland netherlands {
		foreach type in g i {
			regress lsat `diffctry'_`type'  men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Turkey"
			local b = cond(_b[`diffctry'_`type'],_b[`diffctry'_`type'],.)
			local se = cond(_se[`diffctry'_`type'],_se[`diffctry'_`type'],.)
			post `coef' ("Turkey") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
		}
	}
	regress lsat contacts men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Turkey"
	local bcontacts_turkey = _b[contacts]
	regress lsat turkey_i men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4 if cntry == "Turkey"
	local bown_turkey = _b[turkey_i]
	
	postclose `coef'

	use `coefs', clear
	
	gen country:ctry = 1 if ctry == "Germany (W)"
	replace country = 2 if ctry == "Germany (E)"
	replace country = 3 if ctry == "Hungary"
	replace country = 4 if ctry == "Turkey"
	label def ctry 1 "Germany (W)" 2 "Germany (E)" 3 "Hungary" 4 "Turkey"

	gen refcountry =      1 if diffctry == "poland"
	replace refcountry =  2 if diffctry == "hungary"
	replace refcountry =  3 if diffctry == "spain" 
	replace refcountry =  4 if diffctry == "italy"	  
	replace refcountry =  5 if diffctry == "otherpart" & (country == 1 | country== 2)
	replace refcountry =  5 if diffctry == "germany" & (country == 3 | country== 4)
	replace refcountry =  6 if diffctry == "france" 
	replace refcountry =  7 if diffctry == "sweden"  
	replace refcountry =  8 if diffctry == "netherlands"
	replace refcountry =  9 if diffctry == "switzerland"


	// Lines for Neigbours/Friends Reference Groups
	gen contacts =  `bcontacts_germanyw' if country == 1
	replace contacts =  `bcontacts_germanye' if country == 2
	replace contacts =  `bcontacts_hungary' if country == 3
	replace contacts =  `bcontacts_turkey' if country == 4

	// Lines for Own Country Reference Group
	gen own =  `bown_germanyw' if country == 1
	replace own =  `bown_germanye' if country == 2
	replace own =  `bown_hungary' if country == 3
	replace own =  `bown_turkey' if country == 4


	// Conficence Intervalls
	gen ub = b_c + 1.96*se_c
	gen lb = b_c - 1.96*se_c



	local conopt "clstyle(p1) mstyle(p1) sort"
	local rareaopt "sort"
	local lineopt "clstyle(p2 p3) sort"
	
	tw ///
	  (rarea ub lb refcountry, `rareaopt') ///
	  (connected b_c refcountry, `conopt') ///
	  (line contacts own refcountry, `lineopt') ///
	  if type == "i"  ///
	  , by(country, rows(1) note("")) ///
	  xlab(1 "PL" 2 "HU" 3 "ES" 4 "IT" 5 "D" 6 "FR" 7 "SW" ///
	  8 "NL" 9 "CH", alternate) ///
	  xtitle("") ytitle(Regression Coefficients) ///
	  legend(order(2 3 4) rows(1) lab(2 "Other Countries") lab(3 "Neigbours and Friends") lab(4 "Own country") ) ///
	  ylabel(0(.1).5)


	tw ///
	  (rarea ub lb refcountry, `rareaopt') ///
	  (connected b_c refcountry, `conopt') ///
	  (line contacts own refcountry, `lineopt' ) ///
	  if type == "g"  ///
	  , by(country, rows(1) note("")) ///
	  xlab(1 "PL" 2 "HU" 3 "ES" 4 "IT" 5 "D" 6 "FR" 7 "SW" ///
	  8 "NL" 9 "CH", alternate) ///
	  xtitle("") ytitle(Regression Coefficients) ///
	  legend(order(2 3 4) rows(1) lab(2 "Other Countries") lab(3 "Neigbours and Friends") lab(4 "Own country") ) ///
	  ylabel(0(.1).5)


	log close
	exit

	






 
 

	

	
	
	
	

	

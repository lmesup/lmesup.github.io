	// Aspirations as Dependend
	// ------------------------

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anaspir01, replace
	
	// Data
	// ----

	use data02, clear


	// Control Variables
	// -----------------

	// Control Variables

	gen age2 = age^2
	label var age2 "Age (squared)"
	gen lhinceq = log(hinceq)  // 21 obs to missing
	label var lhinceq "log income"

	recode edu (1 2 = 1) (3 = 2) (4= 3) (5=4) (6 = .)
	label define edu 1 "Primary and below" 2 "lower secondary" 3 "secondary" 4 "tertiary", modify
	tab edu, gen(edu)
	label var edu2 "Lower secondary"
	label var edu3 "Secondary"
	label var edu4 "Tertiary"

	tab emp, gen(emp)
	label var emp2 "Part-time"
	label var emp3 "Retired"
	label var emp4 "Unemployed"
	label var emp5 "Homemaker"
	label var emp6 "Other/Missing"

	tab occ, gen(occ)
	label var occ2 "Skilled worker/foreman"
	label var occ3 "Lower white collar"
	label var occ4 "Upper white collar"
	label var occ5 "Self employed"
	label var occ6 "Other/Missing"

	replace mar = . if mar == 5
	tab mar, gen(mar)
	label var mar2 "Married/Living together"
	label var mar3 "Widowed"
	label var mar4 "Divorced/separated"

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
				svyreg within2 selected  men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
				  if cntry == "Turkey"
				local b = cond(_b[selected],_b[selected],.)
				local se = cond(_se[selected],_se[selected],.)
				post `coef' ("Turkey") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
				estimates store `diffctry'_`type'_turkey
			}

		// Table
			estout poland_`type'_turkey hungary_`type'_turkey spain_`type'_turkey italy_`type'_turkey france_`type'_turkey ///
			  sweden_`type'_turkey netherlands_`type'_turkey switzerland_`type'_turkey ///
			  using anaspir01_turkey_`type'.tex ///
			  , replace style(tex) label ///
			  prehead(\begin{tabular}{lrrrrrrrr} \hline  & \multicolumn{8}{c}{Reference Country} \\\\ ) ///
			  posthead(\hline) ///
			  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
			  mlabel("PL" "HU" "ES" "IT"  "FR"  "SW" "NL" "CH" ) /// 
			collabels(, none) ///
			  cells(b(fmt(%3.2f) star)) ///
			  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
			  varlabels(_cons Constant) ///
			  starlevels(* 0.05) 
		estimates drop _all
		}


	// Hungary
	foreach type in g i {
		foreach diffctry in  poland spain italy germany france sweden netherlands switzerland {
			replace selected = `diffctry'_`type'
			svyreg within2 selected men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Hungary"
			local b = cond(_b[selected],_b[selected],.)
			local se = cond(_se[selected],_se[selected],.)
			post `coef' ("Hungary") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
			estimates store `diffctry'_`type'_hungary
		}
		estout poland_`type'_hungary spain_`type'_hungary italy_`type'_hungary ///
		  germany_`type'_hungary france_`type'_hungary ///
		  sweden_`type'_hungary netherlands_`type'_hungary switzerland_`type'_hungary ///
			  using anaspir01_hungary_`type'.tex ///
		  , replace style(tex) label ///
		  prehead(\begin{tabular}{lrrrrrrrrr} \hline  & \multicolumn{8}{c}{Reference Country} \\\\ ) ///
		  posthead(\hline) ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel("PL" "HU" "ES" "IT" "DE" "FR" "SV" "NL" "CH" ) /// 
		collabels(, none) ///
		  cells(b(fmt(%3.2f) star)) ///
		  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
		  varlabels(_cons Constant) ///
		  starlevels(* 0.05) 
		estimates drop _all
	}
		
	
	// Germany_E
	foreach type in g i {
		foreach diffctry in  poland hungary spain italy france otherpart netherlands switzerland {
			replace selected = `diffctry'_`type'
			svyreg within2 selected men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Germany (E)"
			local b = cond(_b[selected],_b[selected],.)
			local se = cond(_se[selected],_se[selected],.)
			post `coef' ("Germany (E)") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
			estimates store `diffctry'_`type'_germanye
		}
		estout poland_`type'_germanye hungary_`type'_germanye spain_`type'_germanye italy_`type'_germanye ///
		   otherpart_`type'_germanye france_`type'_germanye  netherlands_`type'_germanye switzerland_`type'_germanye ///
			  using anaspir01_germanye_`type'.tex ///
		  , replace style(tex) label ///
		  prehead(\begin{tabular}{lrrrrrrrrr} \hline  & \multicolumn{8}{c}{Reference Country} \\\\ ) ///
		  posthead(\hline) ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel("PL" "HU" "ES" "IT"  "DE (W)" "FR" "NL" "CH" ) /// 
		collabels(, none) ///
		  cells(b(fmt(%3.2f) star)) ///
		  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
		  varlabels(_cons Constant) ///
		  starlevels(* 0.05)
		estimates drop _all
		}
	
	// Germany_W
	foreach type in g i {
		foreach diffctry in  poland hungary spain italy france otherpart netherlands switzerland {
			replace selected = `diffctry'_`type'
			svyreg within2 selected men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Germany (W)"
			local b = cond(_b[selected],_b[selected],.)
			local se = cond(_se[selected],_se[selected],.)
			post `coef' ("Germany (W)") ("`diffctry'") ("`type'") (`b') (`se') (e(N)) (e(r2))
			estimates store `diffctry'_`type'_germanyw
		}

		estout poland_`type'_germanyw hungary_`type'_germanyw spain_`type'_germanyw italy_`type'_germanyw ///
		  otherpart_`type'_germanyw france_`type'_germanyw  netherlands_`type'_germanyw switzerland_`type'_germanyw ///
			  using anaspir01_germanyw_`type'.tex ///
		  , replace style(tex) label ///
		  prehead(\begin{tabular}{lrrrrrrrrr} \hline  & \multicolumn{8}{c}{Reference Country} \\\\ ) ///
		  posthead(\hline) ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel("PL" "HU" "ES" "IT"  "DE (E)" "FR" "NL" "CH" ) /// 
		collabels(, none) ///
		  cells(b(fmt(%3.2f) star)) ///
		  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
		  varlabels(_cons Constant) ///
		  starlevels(* 0.05) 
		estimates drop _all
		}
	
	
	// Regression Models for Within-country-Comparisons
	// -------------------------------------------------
				

	local i 1
	foreach k in "Turkey" "Hungary" "Germany (E)" "Germany (W)" {
		foreach diffctry in own contacts {
			replace selected = `diffctry' 
			svyreg within2 selected men age age2 lhinceq edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "`k'"
			local `diffctry'`i' = _b[selected]
			estimates store `diffctry'`i'
		}
		local i = `i' + 1
	}

	label var selected "Reference Group"
	estout own1 contacts1 own2 contacts2 own3 contacts3 own4 contacts4 ///
	  using anaspir01_within.tex ///
	  , replace style(tex) label ///
	  prehead(\begin{tabular}{lrrrrrrrr} \hline & \multicolumn{2}{c}{Turkey} & \multicolumn{2}{c}{Hungary} & \multicolumn{2}{c}{Germany (E)} & \multicolumn{2}{c}{Germany (W)} \\\\  ) ///
	  posthead(\hline) ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  mlabel("own country" "neig./friends" "own country" "neig./friends" "own country" "neig./friends" "own country" "neig./friends"  ) /// 
	collabels(, none) ///
	  cells(b(fmt(%3.2f) star)) ///
	  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
	  varlabels(_cons Constant) ///
	  starlevels(* 0.05) 
	estimates drop _all

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

	graph export anaspir01_i.eps, replace

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

	graph export anaspir01_g.eps, replace

	log close
	exit
	
 
 

	

	
	
	
	

	

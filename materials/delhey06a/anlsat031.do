	// Life Satisfaction on inter-national Comparisons with age interaction
	// --------------------------------------------------------------------

	// Reiterate with Deorivation
	
	// - treats contacts within country and generalized reference-groups separately
	// - includes differences between  own LC and Own Countries LC
	// - Nicer Graphs

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anlsat031, replace
	
	// Data
	// ----

	use data03, clear

	// Control Variables
	// -----------------

	gen age2 = age^2
	label var age2 "Age (squared)"

 	egen aq = xtile(age), p(25(25)75) by(cntry) 
 	tab aq, gen(aq) 

	label var aq1 "1st age quart."
	label var aq2 "2nd age quart."
	label var aq3 "3rd age quart."
	label var aq4 "4th age quart."

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
	postfile `coef' str11 ctry str20 diffctry str1 type b_c b_ia se_ia n r2 using `coefs'

	// Regression Models for Inter-National Comparisons
	// -------------------------------------------------

	svyset [pweight=pweight]
	gen selected1 = .
	gen selected2 = .
	gen selected3 = .
	gen selected4 = .

	lab var selected1 "Ref.-Country (1st Age Quartile)"
	lab var selected2 "Ref.-Country * 2nd Age Quartile"
	lab var selected3 "Ref.-Country * 3rd Age Quartile"
	lab var selected4 "Ref.-Country * 4th Age Quartile"
		
	// Turkey
	foreach type in g i {
		foreach diffctry in poland hungary spain italy france sweden netherlands switzerland {

			replace selected1 = `diffctry'_`type' 
			replace selected2 = `diffctry'_`type' * aq2
			replace selected3 = `diffctry'_`type' * aq3
			replace selected4 = `diffctry'_`type' * aq4

			svyreg lsat selected1 aq2 aq3 aq4 selected2-selected4   men  lhinceq dep edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Turkey"
			local b_c = cond(_b[selected1],_b[selected1],.)
			local b_ia = cond(_b[selected4],_b[selected4],.)
			local se = cond(_se[selected4],_se[selected4],.)
				post `coef' ("Turkey") ("`diffctry'") ("`type'") (`b_c') (`b_ia') (`se') (e(N)) (e(r2))
				estimates store `diffctry'_`type'_turkey
			}

		// Table
			estout poland_`type'_turkey hungary_`type'_turkey spain_`type'_turkey italy_`type'_turkey france_`type'_turkey ///
			  sweden_`type'_turkey netherlands_`type'_turkey switzerland_`type'_turkey ///
			  using anlsat031_turkey_`type'.tex ///
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

			replace selected1 = `diffctry'_`type' 
			replace selected2 = `diffctry'_`type' * aq2
			replace selected3 = `diffctry'_`type' * aq3
			replace selected4 = `diffctry'_`type' * aq4

			svyreg lsat selected1 aq2 aq3 aq4 selected2-selected4 men  lhinceq dep edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Hungary"
			local b_c = cond(_b[selected1],_b[selected1],.)
			local b_ia = cond(_b[selected4],_b[selected4],.)
			local se = cond(_se[selected4],_se[selected4],.)
			post `coef' ("Hungary") ("`diffctry'") ("`type'") (`b_c') (`b_ia') (`se') (e(N)) (e(r2))
			estimates store `diffctry'_`type'_hungary
		}
		estout poland_`type'_hungary spain_`type'_hungary italy_`type'_hungary ///
		  germany_`type'_hungary france_`type'_hungary ///
		  sweden_`type'_hungary netherlands_`type'_hungary switzerland_`type'_hungary ///
			  using anlsat031_hungary_`type'.tex ///
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

			replace selected1 = `diffctry'_`type' 
			replace selected2 = `diffctry'_`type' * aq2
			replace selected3 = `diffctry'_`type' * aq3
			replace selected4 = `diffctry'_`type' * aq4

			svyreg lsat selected1 aq2 aq3 aq4 selected2-selected4  men  lhinceq dep edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Germany (E)"
			local b_c = cond(_b[selected1],_b[selected1],.)
			local b_ia = cond(_b[selected4],_b[selected4],.)
			local se = cond(_se[selected4],_se[selected4],.)
			post `coef' ("Germany (E)") ("`diffctry'") ("`type'") (`b_c') (`b_ia') (`se') (e(N)) (e(r2))
			estimates store `diffctry'_`type'_germanye
		}
		estout poland_`type'_germanye hungary_`type'_germanye spain_`type'_germanye italy_`type'_germanye ///
		   otherpart_`type'_germanye france_`type'_germanye  netherlands_`type'_germanye switzerland_`type'_germanye ///
			  using anlsat031_germanye_`type'.tex ///
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

			replace selected1 = `diffctry'_`type' 
			replace selected2 = `diffctry'_`type' * aq2
			replace selected3 = `diffctry'_`type' * aq3
			replace selected4 = `diffctry'_`type' * aq4

			svyreg lsat selected1 aq2 aq3 aq4 selected2-selected4 men  lhinceq dep edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
			  if cntry == "Germany (W)"
			local b_c = cond(_b[selected1],_b[selected1],.)
			local b_ia = cond(_b[selected4],_b[selected4],.)
			local se = cond(_se[selected4],_se[selected4],.)
			post `coef' ("Germany (W)") ("`diffctry'") ("`type'") (`b_c') (`b_ia') (`se') (e(N)) (e(r2))
			estimates store `diffctry'_`type'_germanyw
		}

		estout poland_`type'_germanyw hungary_`type'_germanyw spain_`type'_germanyw italy_`type'_germanyw ///
		  otherpart_`type'_germanyw france_`type'_germanyw  netherlands_`type'_germanyw switzerland_`type'_germanyw ///
			  using anlsat031_germanyw_`type'.tex ///
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

	// Upward Coef (separated by significance) 
	gen b_cu = b_c + b_ia
	gen b_cus = b_cu if abs(b_ia) >= 2 * se_ia
	gen b_cuu = b_cu if abs(b_ia) < 2 * se_ia
	
	local lineopt "clstyle(p2 p3) sort"
	local capopt "ms(i) clcolor(black)"
	local scatteropt "mstyle(p1 p1) mfcolor(black white) mlcolor(black black)"
	local twopt  `"by(country, rows(1) note("")) xlab(1 "PL" 2 "HU" 3 "ES" 4 "IT" 5 "D" 6 "FR" 7 "SW"  8 "NL" 9 "CH", alternate) "'
	local twopt `"`twopt' xtitle("") ytitle(Regression Coefficients)"'
	local twopt `"`twopt' legend(order(-  "4th Age-Quartile:" 2 3 4) holes(1 5) cols(2) lab(2 "1st Age-Quartile") lab(3 "significant interaction") lab(4 "non signifcant interaction"))"' 

		tw ///
	  (line b_c refcountry, sort) ///
	  (rcapsym b_c b_cu refcountry, `capopt' ) ///
	  (scatter b_cus b_cuu refcountry, `scatteropt' ) ///
	  if type == "i"  ///
	  , `twopt'  

	graph export anlsat031_i.eps, replace

	tw ///
	  (line b_c refcountry, sort) ///
	  (rcapsym b_c b_cu refcountry, `capopt' ) ///
	  (scatter b_cus b_cuu refcountry, `scatteropt' ) ///
	  if type == "g"  ///
	  , `twopt' 

	graph export anlsat031_g.eps, replace

	log close
	exit
	
 
 

	

	
	
	
	

	

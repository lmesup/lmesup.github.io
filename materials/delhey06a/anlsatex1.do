	// Easy example for anlsat-Analysis
	// -------------------------------
	// Reiterate anlsatex.do with Deprivation Index
	

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anlsatex1, replace
	
	// Data
	// ----

	use data03, clear


	// Put Countries in Order

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)


	// Scatterplot with Lowess
	// -----------------------

	lowess lsat switzerland_i, by(country ///
	  , note("") title("") ) jitter(1) ms(oh) mcolor(black) xtitle(Own living conditions - living conditions Switzerland)
	graph export anlsatex1_figure.eps, replace

	// Correlation Coefficients
	// ------------------------


	by country, sort: corr lsat switzerland_i


	// Regression Models
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

	forv i = 1/4 {
		regress lsat switzerland_i men age age2 lhinceq dep edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
		  [pweight = pweight] if country == `i'
		estimates store country`i'
	}

	estout country* using anlsatex1_table.tex ///
	, replace style(tex) label ///
	  prehead(\begin{tabular}{r*{@M}{r}} \hline ) ///
	  posthead(\hline) ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  mlabel("Turkey" "Hungary" "Germany (E)" "Germany (W)" ) /// 
	  collabels(, none) ///
	  cells(b(fmt(%4.3f) star)) ///
	  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.3f %9.0f)) ///
	  varlabels(_cons Constant) ///
	  starlevels(* 0.05) 

	exit
	


 
 

	

	
	
	
	

	

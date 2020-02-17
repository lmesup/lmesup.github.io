	// Missings by socio demographic variables

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anmiss2, replace
	
	// Data
	// ----

	use cntry men-mar *_o using data02, clear

	// Put Countries in Order
	// --------------------

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)


	// Index for Missing values
	// -------------------------

	foreach var of varlist own_o - turkey_o {
		gen m`var' = `var' >= .
	}

	replace mgermany_o = motherpart_o if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace msweden_o = 0 if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace mhungary_o = 0 if cntry=="Hungary"
	replace mgermany_o = 0 if cntry=="Turkey"
	drop motherpart_o mturkey_o

	gen misindex = mswitzerland+mnetherlands+msweden+mfrance+mgermany+mitaly+mspain+mhungary+mpoland

	// Group Continious Variables Age and Income
	// -----------------------------------------

	gen age4:age4 = 1 if age <= 25
	replace age4 = 2 if inrange(age,26,39)
	replace age4 = 3 if inrange(age,40,65)
	replace age4 = 4 if age > 65 & age < .
	label var age4 "Age-Groups"
	label define age4 1 "25 and below" 2 "26-39" 3 "40-65" 4 "over 65"

	bysort cntry: egen hinc4 = xtile(hinceq), p(25(25)75)
	label define hinc4 1 "poorest" 2 "2nd quartile" 3 "3rd quartile" 4 "richest"
	label val hinc4 hinc4
	label var hinc4 "Quartiles of Household-Equivalence Income"

	// Nicer labels for Gender
	// -----------------------

	label val men gender 
	label define gender 0 "women" 1 "men"

	// Set Other to Missing (Save space in the table)
	// ----------------------------------------------

	replace edu = . if edu == 6
	replace emp = . if emp == 6
	replace occ = . if occ == 6
	replace mar = . if mar == 5

	// Make Resultset
	// --------------
	
	preserve

	local i 1
	foreach var of varlist men age4 hinc4 edu emp occ mar {
		drop if `var' >= .
		collapse (mean) misindex, by(country `var')
		reshape wide misindex, i(`var') j(country)
		tempfile `var'
		decode `var', gen(group)
		gen var = `i++'
		save ``var''
		restore, preserve
	}
	restore
	
	use `men', clear
	append using `age4'
	append using `hinc4'
	append using `edu'
	append using `emp'
	append using `occ'
	append using `mar'


	// Display Resultset nicely
	// ------------------------

	// Characteristics -> should go into the list Header, but didn't!
	char define misindex1[varname] "Germany (W)"
	char define misindex2[varname] "Germany (E)"
	char define misindex3[varname] "Hungary"
	char define misindex4[varname] "Turkey"

	// Formats
	format misind*  %3.1f

	// The table
	list group misind*, sepby(var) table noobs subvarname

	// Make a LaTeX table
	// ------------------


	listtex group misind* if var==1 using anmiss2.tex ///
	, replace end("\\\\") ///
	  head("\begin{tabular}{rcccc} \hline" ///
		"& Germany (W) & Germany (E) & Hungary & Turkey \\\\ \hline" ///
		"\multicolumn{5}{l}{\emph{Gender}} \\\\ " ) 
	listtex group misind* if var==2 ///
	, replace end("\\\\") appendto(anmiss2.tex) ///
	  head(" \hline" ///
		"\multicolumn{5}{l}{\emph{Age-Groups}} \\\\ " ) 
	listtex group misind* if var==3  ///
	, replace end("\\\\") appendto(anmiss2.tex) ///
	  head(" \hline" ///
		"\multicolumn{5}{l}{\emph{Quartiles of Household Equivalence Income}} \\\\ " ) 
	listtex group misind* if var==4  ///
	, replace end("\\\\") appendto(anmiss2.tex) ///
	  head(" \hline" ///
		"\multicolumn{5}{l}{\emph{Education}} \\\\ " ) 
	listtex group misind* if var==5  ///
	, replace end("\\\\") appendto(anmiss2.tex) ///
	  head(" \hline" ///
		"\multicolumn{5}{l}{\emph{Employment Status}} \\\\ " ) 
	listtex group misind* if var==6  ///
	, replace end("\\\\") appendto(anmiss2.tex) ///
	  head(" \hline" ///
		"\multicolumn{5}{l}{\emph{Occupational Status}} \\\\ " ) 
	listtex group misind* if var==7  ///
	, replace end("\\\\") appendto(anmiss2.tex) ///
	  head(" \hline" ///
		"\multicolumn{5}{l}{\emph{Marital Status}} \\\\ " ) ///
	  foot("\hline" "\end{tabular}")

	log close
	exit
	

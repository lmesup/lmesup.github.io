* Vote-Inequality on institutional mechanisms

	// Data
	// ----

	// Turnout 
	use s_cntry q25 wcountry using $dublin/eqls_4, clear
	drop if q25 == 3
	gen voter = q25==1 if q25 < .
	collapse (mean) voter [aw=wcountry] , by(s_cntry)
	replace voter = voter*100
	format voter %2.0f

	// Merge Election-System
	sort s_cntry
	mmerge s_cntry using electsystem1
	drop _merge
	
	// List Relevant Data to Tex
	// -------------------------

	mmerge s_cntry using isocntry
	gen ac = eu == 2 | eu == 3
	drop _merge

	// Compute Display-Variables
	gen pflicht:yesno = compul>0
	gen propor:yesno = type == 1 if type < .
	gen weekend:yesno = day == 0 | day==6 if day < .
	gen org=orgevs

	// Bring into order
	sort ac voter
	listtex ctrde voter pflicht weekend nopers regis propor multip compet orgevs leftimp ///
	  using crelectsystem1.tex ///
	  , replace  rstyle(tabular) 


	// Merge Voter-Inequlity Data
	// --------------------------

	sort s_cntry
	merge s_cntry using  anvotstrat anvotzuf, nokeep
	drop _merge*


	// Labels
	// ------

	lab var weekend "Wochenende"
	lab var nopers "Unpersönlich"
	lab var regis "Registrierung"
	lab var propor "Verhältniswahlrecht"
	lab var multip "Anzahl Parteien"
	lab var compet "Wettbewerbstgrad"
	lab var org "Organisationsgrad"
	lab var leftimp  "Linksstärke"
	
	
	// Do not analyse Compulsory Voting Countries
	// ------------------------------------------

	drop if pflicht
	
	// Initialize File
	// ---------------
	
	file open results using anvoteungl01.tex, write text replace
	
	file write  results "\\begin{tabular}{lrrrr} \hline" _n ///
	  "& \multicolumn{2}{c}{Soziostrukturelle}"  ///
	  "& \multicolumn{2}{c}{XXX} \\\\ "  _n ///
	  "& \multicolumn{2}{c}{Ungleichheit}"  ///
	  "& \multicolumn{2}{c}{Ungleichheit} \\\\ "  _n ///
	  "&  \$b \\times R \$ &  \$b_m \\times R \$ &  \$b \\times R \$ &  \$b_m \\times R \$ \\\\ \hline" 

	
	//  Regression Coeff., Simple
	// -----------------------------------------
	
	foreach var of varlist weekend nopers regis propor multip compet org leftimp  {
		local label: variable label `var'
		reg index1 `var'
		sum `var' if e(sample)
		file write results _n " `label' & " %4.2f (_b[`var'] * (r(max) - r(min)))
		reg index1 `var' voter 
		sum `var' if e(sample)
		file write results " & " %4.2f (_b[`var'] * (r(max) - r(min)))
		reg index2 `var'
		sum `var' if e(sample)
		file write results " & " %4.2f (_b[`var']* (r(max) - r(min)))
		reg index2 `var' voter 
		sum `var' if e(sample)
		file write results " & " %4.2f (_b[`var']* (r(max) - r(min))) " \\\\ "
	}

	file write results "  \hline " _n ///
	                   "\\end{tabular}" 
	file close results
	
	cat anvoteungl01.tex
	
	exit
	


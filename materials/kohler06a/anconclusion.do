	// Logit-Models Turnout on social structur * country

version 8.2
	clear
	set more off
	set matsize 200
	set scheme s1mono
	capture log close
	log using anconclusion, replace
	
	use s_cntry q25 wcountry using $dublin/eqls_4, clear
	drop if q25 == 3
	gen voter = q25==1 if q25 < .
	collapse (mean) voter [aw=wcountry] , by(s_cntry)
	sort s_cntry
	merge s_cntry using  anturnout3, nokeep
	drop _merge
	sort s_cntry
	merge s_cntry using anturnout4, nokeep
	drop _merge
	sort s_cntry
	merge s_cntry using electsystem, nokeep

	sum voter, meanonly
	replace voter = 1-((voter - r(min))/(r(max)-r(min)))+.05

	sum index1
	replace index1 = (index1-r(mean))/r(sd)

	sum index2
	replace index2 = (index2-r(mean))/r(sd)
	
	graph twoway ///
	  (scatter index1 index2 [aw=voter], ms(oh) mcolor(black) ) ///
	  (scatter index1 index2, ms(i) mlab(iso3166_2) mlabpos(0)) ///
	  , legend(off) aspectratio(1) ysize(3) xsize(3)  ///
	  ytitle(Krisensymptomatik I) xtitle(Krisensymptomatik II) ///
	  xlab(, grid)  ylab(, grid) ///
	  yline(0) xline(0) ///
	  note("Symbolgröße proportional zur Wahlenthaltung", span)
	graph export anconclusion.eps, replace

	gen index = index1 + index2
	sum index
	replace index = (index - r(mean))/r(sd)
	
	gen weekend:yesno = day == 0 | day==6 if day < .
	label variable weekend "Wochenendwahl"
	label variable compet "Wettbewerbsgrad"
	gen pflicht:yesno = compul > 0 if compul < .
	label variable pflicht "Wahlpflicht"
	gen propor:yesno = type == 1 if type < .
	label variable propor "Verhältniswahlrecht"
	gen state:yesno = inlist(regis,1,3) if day < .
	label variable state "Staatlich initiierte Registrierung"
	gen org=orgevs
	label variable org "Organisationsgrad"


	// Initialize File
	// ---------------
	
	file open results using anconclusion.tex, write text replace
	
	file write  results "\\begin{tabular}{lccccc}" _n ///
	  "& Wochen- & Wahl- & Verhältnis- & Regis-  & Unper-  \\\\" _n ///
	  "& ende    &pflicht& wahlrecht   &trierung & sönlich \\\\ \\hline" _n
	
	// Unstandardized  Regression Coeff., Simple
	// -----------------------------------------
	
	file write results ///
	  "\$b\$" 
	foreach xvar of varlist weekend pflicht propor regis nopers  {
		quietly {
			reg index `xvar'
			file write results " & " %4.2f (_b[`xvar']) 
		}
	}
	file write results " \\\\ " _n


	// Unstandardized  Regression Coeff., Multiple
	// -------------------------------------------
	
	file write results ///
	  "\$b|\\text{Wahlbeteiligung}\$" 
	foreach xvar of varlist weekend pflicht propor regis nopers  {
		reg index voter `xvar'
		file write results " & " %4.2f (_b[`xvar']) 
	}
	file write results " \\\\ \hline " _n ///
	                   "\\end{tabular}" 
	
	file close results
	
	cat anconclusion.tex
	

	log close
	exit
	

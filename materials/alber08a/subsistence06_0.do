	// Analyse zu Q61

version 9
	set more off
	set scheme s1mono

	use $dublin/eqls_4, clear

	gen eu = 1 if  feu15==1
	replace eu = 2 if fac10==1
	replace eu = 3 if fcc3==1

	// Hypothese 1: Gemueseanbau haeufiger im Osten
	// -------------------------------------------
	preserve
	
	// Store some means
	sum q61 [aw=wcountry]
	local mean = r(mean)
	sum q61 [aw=wcountry] if eu==1
	local mean1 = r(mean)
	sum q61 [aw=wcountry] if eu==2
	local mean2 = r(mean)
	sum q61 [aw=wcountry] if eu==3
	local mean3 = r(mean)

	// Calculate the country-specific means
	collapse ///
	  (mean) q61 eu gdppcap1 [aw=wcountry], by(s_cntry)

	// Prepare the Graph
	egen yaxis = axis(eu gdppcap1), label(s_cntry) gap reverse
	gen mean1 = `mean1' if eu==1
	gen mean2 = `mean2' if eu==2
	gen mean3 = `mean3' if eu==3
	
	twoway ///
	  || scatter yaxis q61   ///
	  || line yaxis mean1, lcolor(black)     ///
	  || line yaxis mean2, lcolor(black)     ///
	  || line yaxis mean3, lcolor(black)     ///
	  || , ylabel(1(1)3 5(1)14 16(1)30, valuelabel angle(0) grid) ///
	  ytitle("") legend(off) xsize(3)
	graph export q61.eps, replace
	  
	// Hypothese 2: Gemueseanbau wichtiger fuer Lebenszufriendenheit im Osten
	// ----------------------------------------------------------------------

	restore

	// Live-Satisfaction
	ren q31 lsat

	// Gardening
	gen gardener:yesno = q61>1 if !mi(q61)
	lab var gardener "Gemüseanbau"

	// Income
	ren hhincqu2 inc
	label define hhincqu2 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile"  4 "4th quartile", modify
	
	// In Education
	gen inedu:yesno = emplstat == 5 | teacat == 4
	lab var inedu "In education"
	
	// Employment-Status
	gen emp:emp = emplstat
	replace emp = 5 if emplstat >= 5  // "Missing" + "Other" + "Still Studying"
	label def emp 1 "Employed" 2 "Homemaker" 3 "Unemployed" 4 "Retired" 5 "Other"
	
	// Education
	gen edu:edu = teacat
	replace edu = 4 if edu >= . // "Missing" + "Still Studying" = "Other"
	label define edu 1 "Low" 2 "Intermediate" 3 "High" 4 "Other"

   // "Class" of Main-Earner 
	gen class:class = hhstat
	replace class = 7 if class >= .
	label define class 1 "Upper white collar" 2 "Lower white collar" 3 "Self employed" 4 "Skilled Worker" ///
	  5 "Non skilled worker" 6 "Farmer" 7 "Other"

	// Gender
	gen men:yesno = hh2a==1 if hh2a < .
	lab var men "Men"
	drop hh2a
	
	// Age
	sum hh2b, meanonly
	gen age = hh2b-r(mean)
	lab var age "Age"
	gen age2 = age^2
	lab var age2 "Age (squared)"
	drop hh2b

	// Marital-Status
	ren q32 mar
	label def q32 1 "Married/living togehter" 2 "Separated/divorced" 3 "Widowed" 4 "Single, never married", modify

	// Dummies
capture program drop mydummies
program mydummies
version 9
	syntax varlist
	foreach var of local varlist {
		quietly levelsof `var', local(K)
		foreach k of local K {
			gen `var'`k':yesno = `var'==`k' if !mi(`var')
			label var `var'`k' "`:label (`var') `k''"
		}
	}
end
mydummies inc emp  edu class mar

	// Listwise Deletion
	mark touse
	markout touse ///
	  lsat inc2-inc4 inedu emp2-emp5 edu2-edu4 class2-class7 men age age2 ///
	  mar2-mar4 gardener
	keep if touse
	
	// Baseline Models
	forv i = 1/3 {
		areg lsat gardener if eu==`i', absorb(s_cntry)
		estimates store base`i'
	}

	// Full Models
	forv i = 1/3 {
		areg lsat gardener  ///
		  men age age2 ///
		  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
		  mar2-mar4  ///
		  if eu==`i', absorb(s_cntry) 
		estimates store full`i'
	}

	// Regression Table
	estout  base1 base2 base3 full1 full2 full3       /// 
	using q61_tab1.tex                                ///
	  , replace style(tex) label varwidth(35)          ///
	  prehead(\begin{tabular}{lrrrrrr} \hline )      ///
	  posthead(\hline)                                ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  cells(b(fmt(%3.2f) star)) ///
	  varlabels(_cons Constant, ///
	  blist(edu2 "\multicolumn{7}{l}{\emph{Education (reference: low) }}  \\" ///
	  emp2   "\multicolumn{7}{l}{\emph{Employment status (reference: employed) }} \\ " ///
	  class2 "\multicolumn{7}{l}{\emph{Class (reference: upper white collar) }} \\ " ///
	  inc2   "\multicolumn{7}{l}{\emph{Income (reference: 1st within country quartile) }} \\ " ///
	  mar2   "\multicolumn{7}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
	  )) ///
	  mlabel("EU-15" "AC-10" "CC-3" "EU-15" "AC-10" "CC-3" )  ///
	  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
	  starlevels(* 0.05) 
	estimates drop _all


	// Hypothese 3: Gemueseanbau mildert den negativen Effekt des Einkommens
	// ---------------------------------------------------------------------

	// Interaction-term
	foreach var of varlist inc1-inc4 {
		gen `var'gar = `var' * gardener
		lab var `var'gar `"`=substr("`:var lab `var''",1,3)' {$\times$} Gemüseanb."'
	}
	
	// Baseline Models
	forv i = 1/3 {
		areg lsat gardener inc2gar-inc4gar inc2-inc4  if eu==`i', absorb(s_cntry)
		estimates store base`i'
	}

	// Full Models
	forv i = 1/3 {
		areg lsat gardener inc2gar-inc4gar  ///
		  men age age2 ///
		  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
		  mar2-mar4   ///
		  if eu==`i', absorb(s_cntry) 
		estimates store full`i'
	}

	// Regression Table
	estout base1 base2 base3 full1 full2 full3       /// 
	using q61_tab2.tex                                ///
	  , replace style(tex) label varwidth(35)          ///
	  prehead(\begin{tabular}{lrrrrrr} \hline )      ///
	  posthead(\hline)                                ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  cells(b(fmt(%3.2f) star)) ///
	  varlabels(_cons Constant, ///
	  blist(edu2 "\multicolumn{7}{l}{\emph{Education (reference: low) }}  \\" ///
	  emp2   "\multicolumn{7}{l}{\emph{Employment status (reference: employed) }} \\ " ///
	  class2 "\multicolumn{7}{l}{\emph{Class (reference: upper white collar) }} \\ " ///
	  inc2   "\multicolumn{7}{l}{\emph{Income (reference: 1st within country quartile) }} \\ " ///
	  mar2   "\multicolumn{7}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
	  )) ///
	  mlabel("EU-15" "AC-10" "CC-3" "EU-15" "AC-10" "CC-3" )  ///
	  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f)) ///
	  starlevels(* 0.05) 
	estimates drop _all

	exit
	



	

	// Life-satisfaction and subsistence economy
	// All analyes

version 9
	set more off
	set scheme s1mono

	use $dublin/eqls_4, clear

	gen eu = 1 if  feu15==1
	replace eu = 2 if fac10==1
	replace eu = 3 if fcc3==1

	gen fc = inlist(s_cntry,3,5,7,13,16,17,21,22,23,24)  // Former communist dummy
	
	gen gardener = q61>1 if !mi(q61)
	lab var gardener "Sideline farmer"

	decode s_cntry, gen(ctrname)
	replace ctrname = proper(ctrname)
	replace ctrname = "United Kingdom" if ctrname == "Uk"
	
	// Implication 1: Frequency of subsistence farming
	// -----------------------------------------------

	preserve

	// Store some means
	sum gardener [aw=wcountry]
	local mean = r(mean)
	sum gardener [aw=wcountry] if !fc
	local mean1 = r(mean)
	sum gardener [aw=wcountry] if fc
	local mean2 = r(mean)

	// Calculate the country-specific means
	collapse ///
	  (mean) gardener gdppcap1 fc      ///
	  (sd) gardenersd=gardener         ///
	  (count) gardenern=gardener       ///
	  [aw=wcountry], by(ctrname)

	// Confidence Bounds
	gen ub = gardener + 1.96 * gardenersd/sqrt(gardenern)
	gen lb = gardener - 1.96 * gardenersd/sqrt(gardenern)
	
	// Prepare the Graph
	egen yaxis = axis(fc gardener), label(ctrname) gap reverse
	gen mean1 = `mean1' if !fc
	gen mean2 = `mean2' if fc
	
	twoway ///
	  || line yaxis mean1, lcolor(black)          ///
	  || line yaxis mean2, lcolor(black)          ///
	  || scatter yaxis gardener, mcolor(black) ms(O)   ///
	  || rspike ub lb yaxis, horizontal lcolor(black) ///
	  || , ylabel(1(1)10 12(1)29, valuelabel angle(0) grid) ///
	  ytitle("") legend(off) xsize(3)
	graph export subsistence06_1_g1.eps, replace

	keep ctrname gdppcap1 fc
	tempfile agg
	save `agg'
	
	  
	// Implication 2: Subsistence farming and life satisfaction
	// --------------------------------------------------------

	restore

	// Live-Satisfaction
	ren q31 lsat

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

	iis s_cntry
	
	// Baseline Models
	forv i = 0/1 {
		xtreg lsat gardener if fc==`i', fe
		estimates store base`i'
	}

	// Full Models
	forv i = 0/1 {
		xtreg lsat gardener  ///
		  men age age2 ///
		  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
		  mar2-mar4  ///
		  if fc==`i', fe
		estimates store full`i'
	}

	// Regression Table
	estout  base0 full0 base1 full1                        /// 
	using subsistence06_1_tab1.tex                         ///
	  , replace style(tex) label varwidth(35)              ///
	  prehead(\begin{tabular}{lrrrr} \hline                ///
	  & \multicolumn{2}{c}{Traditional} & \multicolumn{2}{c}{Former} \\    ///
	  & \multicolumn{2}{c}{market economies} & \multicolumn{2}{c}{communist states} \\  )  ///
	  posthead(\hline)                                ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  cells(b(fmt(%3.2f) star)) ///
	  varlabels(_cons Constant, ///
	  blist(edu2 "\multicolumn{5}{l}{\emph{Education (reference: low) }}  \\" ///
	  emp2   "\multicolumn{5}{l}{\emph{Employment status (reference: employed) }} \\ " ///
	  class2 "\multicolumn{5}{l}{\emph{Class (reference: upper white collar) }} \\ " ///
	  inc2   "\multicolumn{5}{l}{\emph{Income (reference: 1st within country quartile) }} \\ " ///
	  mar2   "\multicolumn{5}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
	  )) ///
	  mlabels("(1)" "(2)" "(3)" "(4)" )  ///
	  collabels(,none) ///
	  stats(r2_w rho N, labels("\$r^2\$ (within)" "\$\rho\$ (Var. expl. by country)" "\$n\$") fmt(%9.2f %9.2f %9.0f)) ///
	  starlevels(* 0.05) 
	estimates drop _all

	// Country specific results
	// ------------------------
	// (not used so far)

	tempfile coef
	postfile coefs str30 ctrname b se using `coef'
	
	levelsof ctrname, local(K)
	foreach k of local K {
		reg lsat gardener  ///
		  men age age2 ///
		  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
		  mar2-mar4  ///
		  if ctrname=="`k'"
		post coefs ("`k'") (_b[gardener]) (_se[gardener])
	}
	postclose coefs

	preserve
	use `coef', clear
	merge ctrname using `agg', sort
	assert _merge==3
	drop _merge
	
	
	gen ub = b + 1.96*se
	gen lb = b - 1.96*se

	tw ///
	  || rspike ub lb gdppcap1 ///
	  || sc b gdppcap1 if fc, ms(O) mcolor(black)   ///
	  || sc b gdppcap1 if !fc, ms(O) mfcolor(white) mlcolor(black)  ///
	  || if ctrname != "Luxembourg"

 	
	restore
	
	// Hypothese 3: Gemueseanbau mildert den negativen Effekt des Einkommens
	// ---------------------------------------------------------------------

	// Interaction-term
	foreach var of varlist inc1-inc4 {
		gen `var'gar = `var' * gardener
		lab var `var'gar `"`=substr("`:var lab `var''",1,3)' {$\times$} sidel. farm."'
	}
	
	// Baseline Models
	forv i = 0/1 {
		xtreg lsat gardener inc2gar-inc4gar inc2-inc4  if fc==`i', fe 
		estimates store base`i'
	}

	// Full Models
	forv i = 0/1 {
		xtreg lsat gardener inc2gar-inc4gar  ///
		  men age age2 ///
		  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
		  mar2-mar4   ///
		  if fc==`i', fe
		estimates store full`i'
	}

	// Regression Table
	estout base0 full0 base1 full1                     /// 
	using subsistence06_1_tab2.tex                     ///
	  , replace style(tex) label varwidth(35)          ///
	  prehead(\begin{tabular}{lrrrr} \hline                ///
	  & \multicolumn{2}{c}{Traditional} & \multicolumn{2}{c}{Former} \\    ///
	  & \multicolumn{2}{c}{market economies} & \multicolumn{2}{c}{communist states} \\  )  ///
	  posthead(\hline)                                 ///
	  prefoot(\hline) postfoot(\hline \end{tabular} )  ///
	  cells(b(fmt(%3.2f) star)) ///
	  varlabels(_cons Constant, ///
	  blist(edu2 "\multicolumn{5}{l}{\emph{Education (reference: low) }}  \\" ///
	  emp2   "\multicolumn{5}{l}{\emph{Employment status (reference: employed) }} \\ " ///
	  class2 "\multicolumn{5}{l}{\emph{Class (reference: upper white collar) }} \\ " ///
	  inc2   "\multicolumn{5}{l}{\emph{Income (reference: 1st within country quartile) }} \\ " ///
	  mar2   "\multicolumn{5}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
	  )) ///
	  mlabels("(1)" "(2)" "(3)" "(4)" )  ///
	  collabels(,none) ///
	  stats(r2_w rho N, labels("\$r^2\$ (within)" "\$\rho\$ (Var. expl. by country)" "\$n\$") fmt(%9.2f %9.2f %9.0f)) ///
	  starlevels(* 0.05) 
	estimates drop _all

	exit
	



	

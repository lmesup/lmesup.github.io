version 9.1
	set more off
	capture log close
	log using an1st, replace
	eststo clear

	use ess04, clear
	drop if inlist(cntry,"IS","UA") // Drop Island and Ukraine
	drop if inlist(cntry,"GR","IT","LU","BE") // Drop compulsory vote countries


	// Dummi-Coding etc
	tab edu, gen(edu)
	tab emp, gen(emp)
	tab hhinc, gen(hhinc)
	gen majority = inlist(cntry,"GB","FR")
	gen lrmajority = leftright * majority

	// Listwise Deletion
	mark touse
	markout touse voter leftright age men edu2 edu3 emp2-emp5 hhinc2-hhinc5 
	keep if touse


	// Left-Right Graph
	// ----------------

	preserve
	gen n = 1 if !mi(leftright) 
	collapse (count) n, by(cntry leftright voter)

	by cntry voter (leftright), sort: gen N = sum(n)
	by cntry voter (leftright), sort: gen p = n/N[_N]

	gen voterp  = p if voter 
	gen nvoterp = -p if !voter
	gen zero = 0

	graph tw ///
	  || bar voterp leftright, horizontal ///
	  || bar nvoterp leftright, horizontal ///
	  plotregion(style(none)) ///
	  yscale(noline) ylabel(none) ytitle("") ///
	  xscale(noline) ///
	  xlabel(-.5 "50%" 0 "0" .5 "50%") xtick(-.5(.25).5) ///
	  by(cntry, note("")) legend(order(1 "Voters" 2 "Non voters")) 
	restore
	
	// Voter Models
	// ------------

	// Random intercept settings
	encode cntry, gen(ctrnum)
	iis ctrnum
	
	// Leftright only
	xtlogit voter leftright 
	eststo

	// Age+Gender
	xtlogit voter leftright age men 
	eststo

	// Education
	xtlogit voter leftright age men edu2 edu3
	eststo

	// Social Structure
	xtlogit voter leftright age men edu2 edu3 emp2-emp5 hhinc2-hhinc5
	eststo

	xtlogit voter ///
	  leftright lrmajority age men edu2 edu3 emp2-emp5 hhinc2-hhinc5 majority
	eststo

	esttab, label

	log close

	exit







	

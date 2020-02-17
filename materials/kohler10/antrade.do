version 9.1
	set more off
	capture log close
	log using antrade, replace
	eststo clear

	use ess04, clear
	drop if inlist(cntry,"IS","UA") // Drop Island and Ukraine
	drop if inlist(cntry,"GR","IT","LU","BE") // Drop compulsory vote countries


	// Dummi-Coding etc
	tab edu, gen(edu)
	tab emp, gen(emp)
	tab hhinc, gen(hhinc)
	gen scand = inlist(cntry,"DK","SE","FI","NO")
	gen lrscand = leftright * scand
	gen postcom = inlist(cntry,"CZ","EE","HU","PL","SI","SK")
	gen lrpostcom = leftright * postcom

	
	// Listwise Deletion
	mark touse
	markout touse union leftright age men edu2 edu3 emp2-emp5 hhinc2-hhinc5 
	keep if touse

	// Union Models
	// ------------

	// Random intercept settings
	encode cntry, gen(ctrnum)
	iis ctrnum
	
	// Leftright only
	xtlogit union leftright 
	eststo

	// Age+Gender
	xtlogit union leftright age men 
	eststo

	// Education
	xtlogit union leftright age men edu2 edu3
	eststo

	// Social Structure
	xtlogit union leftright age men edu2 edu3 emp2-emp5 hhinc2-hhinc5
	eststo

	xtlogit union ///
	  leftright lrscand age men edu2 edu3 emp2-emp5 hhinc2-hhinc5 scand
	eststo

	esttab, label

	log close
	
	exit







	

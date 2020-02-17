version 9.1
set scheme s1mono
	
	// Ideal types
	// -----------
	  
	clear
	set seed 731
	input society posind type 
	1 500   1   
	2 1000  2 
	1 1500  3 
	2 2000  4 
	1 2500  1 
end

	fillin society posind type
	drop if (posind > 1500 & society == 1) | (posind < 1500 & society == 2)

	lab val type type
	lab def type ///
	  1 "Container" ///
	  2 "Individualisation" ///
	  3 "Supra-nationalisation"   ///
	  4 "National solidarity"
	
	by type society (posind), sort:  gen av = _n^2 if type == 1

	by type (society posind): replace av = _n^2 if type == 2 & society==1
	replace av = 6 if type == 2 & society==2
	
	by type (society posind), sort: replace av = _n^2 if type == 3 & society == 1
	by type (society posind), sort: replace av = (_n-1)^2 if type == 3 & society==2

	by type (society posind), sort: replace av = 1 if type == 4 & society == 1
	by type (society posind), sort: replace av = 9 if type == 4 & society == 2


	sc posind society [aw=av],                                            ///
	  by(type, rows(1) note("") )                                         ///
	  xlabel(1 "A" 2 "B") xscale(range(0.5 2.5)) xtitle("")               ///
	  yscale(range(1000 2600)) ytitle("Resources")  ///
	  ylabel(none) ytick(1000(500)2500, grid)
	
	graph export grsoctypes.eps, replace
	

	// Try-out regression-Models for each type:
	// ----------------------------------------
	
	by type society: gen posref = sum(posind)/_N
	by type society: replace posref = posref[_N]
	gen posrel = posind - posref

	by type society: gen avref = sum(av)/_N
	by type society: replace avref = avref[_N]

	gen indi1 = posind * posref
	gen indi2 = posrel * posref


	levelsof type, local(K)
	foreach k of local K {
		di _n as text "Data generating process is " as result "`:label (type) `k''"
		reg av posind posrel if type == `k'
		reg av posind posrel indi1 if type == `k'
		reg av posind posrel indi2 if type == `k'
	}
	exit
	

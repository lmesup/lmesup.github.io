// Some descriptions by country
// kohler@wzb.eu

	
version 9.2
	set scheme s1mono
	use ESScontact, clear

	// No result information very common in NO, LU, and CZ
	drop if inlist(cntry,"NO","LU","CZ")

	// Characteristics of fieldwork organisation
	// -----------------------------------------

	// Day if week
	gen dayofweek = dow(edate)
	gen circdate = dayofweek/7 * 360

	local i 1
	levelsof circdate, local(K)
	foreach day in Su M T W T F S {
		local clabel `"`clabel' `:word `i++' of `K'' `"`day'"' "'
	}

	levelsof cntry, local(K)
	foreach k of local K {
		circrplot circdate if cntry== "`k'" ///
		  , clabel(`clabel') name(g`k', replace) nodraw ///
		  subtitle("") title("`k'", pos(12) bexpand box)
		local graphs "`graphs' g`k'"
	}
	
	graph combine `graphs'
	graph export andescription_by_country_day.eps, replace

	// Time of day
	gen circtime = etime/24 * 360
	local graphs "" 
	levelsof cntry, local(K)
	foreach k of local K {
		circrplot circtime if cntry== "`k'" ///
		  , clabel(0 "0" 90 "6" 180 "12" 270 "18") ///
		    name(g`k', replace) nodraw ///
		    subtitle("") title("`k'", pos(12) bexpand box)
		local graphs "`graphs' g`k'"
	}
	
	graph combine `graphs'
	graph export andescription_by_country_time.eps, replace

	// Contact structure
	preserve

	gen visit1 = mode==1 | mode == 3 if !mi(mode)
	by cntry idno, sort: gen visit2 = _N
	collapse (mean) visit*, by(cntry)

	sum visit2
	gen mvisit = visit1 + visit2/r(max)
	egen axis = axis(mvisit), label(cntry) reverse
	levelsof axis, local(ylab)
	
	local opt "horizontal ms(0) mlcolor(black)"
	
	graph twoway ///
	  || dot  visit1 axis, `opt' mfcolor(black) xaxis(1) ///
	  || dot  visit2 axis, `opt' mfcolor(white) xaxis(2) ///
	  || , ylab(`ylab', valuelabel angle(0)) ytitle("")  ///
	  legend(order(1 "Fraction of face-to-face contacts" ///
	  2 "Average number of contacts" )  pos(2) cols(1))  ///
	  xtitle(Fraction of face-to-face contacts, axis(1)) ///
	  xtitle(Number of contacts, axis(2)) 
	graph export andescription_by_country_contact.eps, replace
	restore, preserve
	
	// Characteristics of the environment
	// ----------------------------------

	local i 1
	foreach var of varlist phys litter vanda {
		gen  environment`i' = `var'
		local legorder `"`legorder' `i++' "`:var lab `var''""'
	}

	// Mirror phyisical state of buildings
	sum environment1, meanonly
	replace environment1 = r(max) + 1 - environment1 
	
	by cntry idno tryer, sort: keep if _n==1 // Appropriate unit of observation
	collapse (mean) environment*, by(cntry)
	egen menvironment = rmean(environment*)
	egen axis = axis(menvironment), label(cntry) reverse

	levelsof axis, local(ylab)

	local opt "horizontal ms(0) mlcolor(black)"
	
	graph twoway ///
	  || dot  environment1 axis, `opt' mfcolor(black) ///
	  || dot  environment2 axis, `opt' mfcolor(white) ///
	  || dot  environment3 axis, `opt' mfcolor(gs5)   ///
	  || , ylab(`ylab', valuelabel angle(0)) ytitle("") ///
	  legend(order(`legorder') pos(2) cols(1))
	graph export andescription_by_country_environment.eps, replace

	restore, preserve

	// Characteristics of Respondents
	// ------------------------------

	// Xenophobia
	local legorder ""
	local i 1
	foreach var of varlist alarm inter sec bgany {
		gen xeno`i':yesno = `var' == 1 if !mi(`var')
		local legorder `"`legorder' `i++' "`:var labe `var''""'
	}

	by cntry idno tryer, sort: keep if _n==1 // Appropriate unit of observation
	collapse (mean) xeno*, by(cntry)
	egen mxeno = rmean(xeno*)
	egen axis = axis(mxeno), label(cntry) reverse

	levelsof axis, local(ylab)

	local opt "horizontal ms(0) mlcolor(black)"
	
	graph twoway ///
	  || dot  xeno1 axis, `opt' mfcolor(black) ///
	  || dot  xeno2 axis, `opt' mfcolor(white) ///
	  || dot  xeno3 axis, `opt' mfcolor(gs5)   ///
	  || dot  xeno4 axis, `opt' mfcolor(gs10)  ///
	  || , ylab(`ylab', valuelabel angle(0)) ytitle("") ///
	  legend(order(`legorder') pos(2) cols(1))
	graph export andescription_by_country_xeno.eps, replace

	restore, preserve

	// Cooperativeness
	gen coop1 = telnum==1 if telnum < 3
	gen coop2 = coop>2 if inrange(coop,1,4)

	by cntry idno tryer, sort: keep if _n==1 // Appropriate unit of observation
	collapse (mean) coop1 coop2, by(cntry)
	egen axis = axis(coop2), label(cntry) reverse

	levelsof axis, local(ylab)

	local opt "horizontal ms(0) mlcolor(black)"
	
	graph twoway ///
	  || dot  coop1 axis, `opt' mfcolor(black) ///
	  || dot  coop2 axis, `opt' mfcolor(white) ///
	  || , ylab(`ylab', valuelabel angle(0)) ytitle("") ///
	  legend(order(1 "Phone number provided" 2 "Not rated as uncooperative") ///
	  pos(2) cols(1))
	graph export andescription_by_country_coop.eps, replace
	

	exit

	


	


// B by within household reachability (EBLS only)
// kohler@wz-berlin.de	

version 9

	clear
	set memory 90m
	set more off

	tempfile iso
	
	// EBLS
	// ----

	use svydat04 if survey=="EQLS 2003"
	ren id s_respnr
	merge s_respnr using $dublin/eqls_4, sort keep(hh2b hh2d hh3d_2 hh3a_2 hh3b_2)
	drop _merge
	keep if hart == 1
	keep if sample==4
	
	// Case ID
	ren s_respnr id
	
	// Frauen
	ren women women1
	gen women2:yesno = hh3a_2 == 2 if !missing(hh3a_2)
	assert women1 != women2

	// Age
	gen age1 = hh2b if !missing(hh2b)
	gen age2 = hh3b_2 if !missing(hh3b_2)

	// Economic Status
	gen emp1:yesno = hh2d==1 
	gen emp2:yesno = hh3d_2==1  
	
	// Household-Characteristic
	keep id women? age? emp? iso*
	reshape long women age emp, i(id) j(person)
	label define hht 1 "Male breadwinner" 2 "Female breadwinner" 3 "Both employed" 4 "None employed"
	by id (women), sort: gen hhtyp:hht = 1 if emp[1]==1 & emp[2]==0
	by id (women), sort: replace hhtyp = 2 if emp[1]==0 & emp[2]==1
	by id (women), sort: replace hhtyp = 3 if emp[1]==1 & emp[2]==1
	by id (women), sort: replace hhtyp = 4 if emp[1]==0 & emp[2]==0
	keep if person==1


	// t-values by survey iso3166_2 city
	collapse (mean) womenp=women (count) N=women, by(hhtyp iso3166_2) 
	gen B = (womenp - .5)/sqrt(.5^2/N)
	sort hhtyp iso3166_2
	
	local opt `"ytitle("") medtype(marker) medmarker(ms(O) mc(black) msize(*1.5))"'
	local opt `"`opt'  marker(1, ms(oh)) "'
	local opt `"`opt' box(1, lcolor(black) fcolor(white))"'
	local opt `"`opt' ytitle("Unit nonresponse bias")"'

	// The Graph
	graph                                                       ///
	  box B                                                     ///
	  , over(hhtyp)  `opt'                                     
	graph export anBrwithin1.eps, replace

exit


	exit


	


	
	


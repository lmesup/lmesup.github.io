version 9.1
	set more off
	capture log close
	log using anlrdes, replace
	
	use ess04, clear
	drop if inlist(cntry,"IS","UA")           // Drop Island and Ukraine
	drop if inlist(cntry,"GR","IT","LU","BE") // Drop compulsory vote countries

	// Weights
	gen weight = dweight * pweight

	// The dependent Varialbe
	gen nvotetyp:typ = 1  if leftright == 5
	replace nvotetyp = 2  if leftright == .
	replace nvotetyp = 3  if inrange(leftright,0,4)
	replace nvotetyp = 4  if inrange(leftright,6,10)
	label define typ 1 "Disengaged" 2 "Nonideological" 3 "Left" 4 "Right" 
	tab nvotetyp
	
	// Dummy-Coding 
	tab emp, gen(emp)
	tab hhinc, gen(hhinc)
	tab mar, gen(mar)
	tab egp, gen(egp)

	// Descriptive statistics
	tabstat men age hhinc hhsize [aw=weight],  by(nvotetyp) 
	tabstat emp? [aw=weight],  by(nvotetyp)
	tabstat egp? [aw=weight],  by(nvotetyp)
	tabstat hhinc? [aw=weight],  by(nvotetyp)
	tabstat mar? [aw=weight],  by(nvotetyp)
	tabstat lifesat vote polint democsat rel church [aw=weight],  by(nvotetyp) 

	tab cntry nvotetyp, row

	log close

	
	

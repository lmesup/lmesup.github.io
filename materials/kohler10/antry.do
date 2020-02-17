version 9.1
	set more off

	use ess04, clear
	drop if inlist(cntry,"IS","UA") // Drop Island and Ukraine
	drop if inlist(cntry,"GR","IT","LU","BE") // Drop compulsory vote countries

	capture log close
	log using antry, replace
	set output inform

	// The dependent Varialbe
	gen nvotetyp:typ = 1  if leftright == 5
	replace nvotetyp = 2  if inrange(leftright,0,4)
	replace nvotetyp = 3  if inrange(leftright,6,10)
	replace nvotetyp = 4  if leftright == .
	label define typ 1 "Diseng.-NV" 2 "Left NV" 3 "Right NV" 4 "Nonideo NV"
	tab nvotetyp
	
	// Dummy-Coding 
	tab emp, gen(emp)

	set output proc
	mlogit nvotetyp vote  polint men age hhinc emp2 emp3 emp4 emp5

	prchange

	log close
	translate antry.smcl antry.ps, replace
	!pstopdf antry.pdf
		
	mlogplot voter polint men age hhinc , ///
	  std(0u0su) p(.1)  note(D=Disengaged, N=Non Ideological, L = Left, R = Right) ///
	  dc  ntics(9)
	graph export antry1.png, replace

	mlogplot emp2 emp3 emp4 emp5 , ///
	  std(0000) p(.1)  note(D=Disengaged, N=Non Ideological, L = Left, R = Right) ///
	  dc  ntics(9)
	graph export antry2.png, replace


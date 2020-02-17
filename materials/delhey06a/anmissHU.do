	// What about friends in Hungary?

version 8
	set more off
	capture log close
	log using anmissHU, replace
	
	// Data
	// ----

	use $em/em, clear

	tab v13 country if inlist(country,2,3,8), col

	gen misfriends = v75f >= .
	gen misneigh = v75e >= .

	tab misfriends v13 if country==3, col
	tab misneigh v13 if country==3, col

	log close
	exit
	
	

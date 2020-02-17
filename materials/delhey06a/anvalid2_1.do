	// Same as anvalid2, but within Person Comparisons included
	

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anvalid2_1, replace
	
	// Data
	// ----

	use ID cntry year within* friends neighbours germany_i hungary_i turkey_i using data02, clear

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)

	gen own = germany_i if country == 4 | country == 3
	replace own = hungary_i if country == 2
	replace own = turkey_i if country == 1
	label var within1 "Five Years ago"
	label var within2 "Entitled" 
	label var own "Own Country"
	label var friends "Friends"
	label var neighbours "Neighbors"
	
	
	// Individual Mode
	graph hbox ///
  	  within1 within2 friends neighbours own, ///
	  ascategory by(country, cols(1) note("") ) yline(0, lpattern(dot)) ///
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) ///
	  ysize(4.30) xsize(3.15) 
	graph export anvalid2a_1.eps, replace

	by cntry, sort: pwcorr within1 within2 friends neighbours own

	log close
	exit











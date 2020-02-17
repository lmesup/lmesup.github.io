	// How reasistitic are the evaluations about countries Living Condions

version 9
	set more off
	set scheme s1mono
	capture log close
	log using anvalid3, replace
	
	// Data
	// ----

	use ID cntry year hungary_i-turkey_i using data02, clear

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)

	replace germany_i = otherpart_i if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace hungary_i = . if cntry=="Hungary"
	replace turkey_i = . if cntry=="Turkey"

	foreach word in ///
	  hungary poland spain italy germany france sweden netherlands switzerland {
		local cap = proper("`word'")
		label var `word'_i "`cap'"
	}

	gen typ = 1
	tempfile international
	save `international'


	use ID cntry year friends neighbours germany_i hungary_i turkey_i using data02, clear

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)

	gen own = germany_i if country == 4 | country == 3
	replace own = hungary_i if country == 2
	replace own = turkey_i if country == 1
	drop germany_i hungary_i turkey_i
	label var own "Own Country"
	label var friends "Friends"
	label var neighbours "Neighbors"
	
	gen typ = 2
	tempfile within
	save `within'

	use `international', clear
	append using `within'

	// Individual Mode
	graph hbox ///
  	  switzerland_i netherlands_i sweden_i france_i germany_i italy_i spain_i hungary_i poland_i ///
	  own neighbours friends, ///
	  over(typ, relabel(1 `" "Inter-national" " " "' 2 `" "Within" " " "') label(angle(90))) ///
	  nofill ascategory by(country, cols(1) note("") ) yline(0, lpattern(dot)) ///
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) ///
	  ysize(6.15) xsize(3.15) 
	graph export anvalid3a.eps, replace

	log close
	exit



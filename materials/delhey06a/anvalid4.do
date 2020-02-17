	// How reasistitic are the evaluations about countries Living Condions

version 9
	set more off
	set scheme s1mono
	capture log close
	log using anvalid3, replace
	
	// Data
	// ----

	use ID cntry year hungary_i-turkey_i friends neighbours using data02, clear

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)

	gen own = germany_i if country == 4 | country == 3
	replace own = hungary_i if country == 2
	replace own = turkey_i if country == 1
	label var own "Own Country"
	label var friends "Friends"
	label var neighbours "Neighbors"

	replace germany_i = otherpart_i if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace hungary_i = . if cntry=="Hungary"
	replace turkey_i = . if cntry=="Turkey"

	gen comp0 = .
	local i 1
	foreach var of varlist /// 
 	  switzerland_i netherlands_i sweden_i france_i germany_i italy_i spain_i hungary_i poland_i ///
	  own neighbours friends {
		if "`var'" == "own" {
			local i = `i' + 1
		}
		ren  `var' comp`i++'
	}
	gen comp10 = .
	
	keep ID comp* country
	reshape long comp, i(ID) j(comptyp)

	lab val comptyp comptyp

	local i 1
	foreach word in /// 
	switzerland netherlands sweden france germany italy spain hungary poland { 
		local cap = proper("`word'")
		label define comptyp `i++'  "`cap'", modify
	}
	label define comptyp  0 `"Inter-national Comparisons     "'  , modify
	label define comptyp 10 `"Within Country Comparisons     "'  , modify
	label define comptyp 11 "Own Country" 12 "Neighbors"  13 "Friends", modify
	
	graph hbox comp, ///
	  over(comptyp, label(ticks) ) ///
	  by(country, cols(1) note("") ) yline(0, lpattern(dot)) ///
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) ///
	  ysize(6.15) xsize(3.15) 
	graph export anvalid4.eps, replace

	log close
	exit



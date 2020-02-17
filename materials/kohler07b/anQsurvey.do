* Q by Sampling Methods
* kohler@wz-berlin.de

version 9

	// Intro
	clear
	set memory 80m
	set more off
	set scheme s1mono

	// Data
	use svydat03 if eu & sample != 6 & svymeth != 5
	keep if weich == 1
	
	// Q
	collapse (mean) womenp=women (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2
	
	local opt `"ytitle("") medtype(marker) medmarker(ms(O) mc(black) msize(*1.5))"'
	local opt `"`opt'  marker(1, ms(oh)) "'
	local opt `"`opt' box(1, lcolor(black) fcolor(white))"'
	local opt `"`opt' ytitle("Absolute value of sample bias (|Q|)")"'

	// The Graph
	graph                                                       ///
	  box Q                                                     ///
	  , over(survey)  `opt'                                     
	graph export anQsurvey.eps, replace

exit


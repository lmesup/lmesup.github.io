* B by Sampling Methods
* kohler@wz-berlin.de

version 9

	// Intro
	clear
	set memory 80m
	set more off
	set scheme s1mono

	// Data
	use svydat04 if eu & sample != 6 & svymeth != 5
	keep if weich == 1

	// Calculate design effects 
	svyset [pweight=dweight], strata(ost)
	foreach survey in "EVS 1999" "ISSP 2002" "EB 62.1" {
		quietly svy: mean women if iso3166_2=="DE" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local de`:word 1 of `survey'' = D[1,1]
	}
	svyset [pweight=dweight], strata(nirl)
	foreach survey in "ISSP 2002" "EB 62.1" {
		quietly svy: mean women if iso3166_2=="GB" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local gb`:word 1 of `survey''  = D[1,1]
	}

	
	// B
	collapse (mean) womenp=women (count) N=women [aweight = dweight] , by(survey iso3166_2)
	gen B = abs((womenp - .5)/sqrt(.5^2/N))

	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEB')) if survey=="EB 62.1" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deEVS')) if survey=="EVS 1999" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`deISSP')) if survey=="ISSP 2002" & iso3166_2 == "DE"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbEB')) if survey=="EB 62.1" & iso3166_2 == "GB"
	replace B = abs((womenp - .5)/sqrt(.5^2/N *`gbISSP')) if survey=="ISSP 2002" & iso3166_2 == "GB"

	sort survey iso3166_2
	
	local opt `"ytitle("") medtype(marker) medmarker(ms(O) mc(black) msize(*1.5))"'
	local opt `"`opt'  marker(1, ms(oh)) "'
	local opt `"`opt' box(1, lcolor(black) fcolor(white))"'
	local opt `"`opt' ytitle("Absolute value of unit nonresponse bias")"'

	// The Graph
	graph                                                       ///
	  box B                                                     ///
	  , over(survey)  `opt'                                     
	graph export anBsurvey.eps, replace

exit


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
	collapse (mean) womenp=women sample back subst (count) N=women, by(survey iso3166_2)
	gen Q = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2

	label value sample sample
	label define sample ///
	  1 "SRS" 2 "Ind. reg."  3  "Add. reg."  4  "Rd. route"  5  "Unknown" ///
	  , modify

	label value back back
	label define back ///
	  -1 "N.a." 0 "No" 1 "Yes"                                                 ///
	  , modify

	label value subst subst
	label define subst ///
	   0 "No" 1 "Yes", modify

	local opt `"nodraw ytitle("") medtype(marker) medmarker(ms(O) mc(black) msize(*1.5))"'
	local opt `"`opt'  marker(1, ms(oh)) ytick(0(1)5, grid) "'
	local opt `"`opt' box(1, lcolor(black) fcolor(white))"'
	local opt `"`opt' graphregion(margin(zero))"'

	// The Graph
	graph                                                       ///
	  box Q                                                     ///
	  , over(sample)  `opt'                                     ///
	  title(Sampling method, bexpand box pos(12))               ///
	  name(sample, replace) fxsize(68) 

	graph                                                       ///
	  box Q                                                     ///
	  , over(back)  `opt' ylabel(none)                          ///
	  title(Back checks, bexpand box pos(12))                   ///
	  name(back, replace) fxsize(40)
	  
	graph                                                       ///
	  box Q                                                     ///
	  , over(subst)  `opt' ylabel(none)                         ///
	  title(Substitution, bexpand box pos(12))                  ///
	  name(subst, replace) fxsize(30)

	graph combine sample back subst ///
	  , rows(1) imargin(tiny) l1title("Absolute value of sample bias (|Q|)", size(small)) xsize(6)

	graph export anQmethod.eps, replace

exit


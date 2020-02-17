* Several Participation Measures by welfare-regime and survey-year
* Author: kohler@wzb.eu
	
	// Intro
	// -----
	
version 9.2
	set more off
	set scheme s1mono

	// Get Data
	use ///
	  ctrname weight voter contact donate petition protest actgroup regime ///
	  using issp02, clear

	tempfile regime
	label save regime using `regime'

	// Make data long
	local i 1
	foreach var of varlist voter contact donate petition protest actgroup {
		ren `var' p`i++'
	}
	gen index = _n
	reshape long p, i(index) j(indicator)
	label value indicator indicator
	label define indicator 1 "Voter" 2 "Contacter" 3 "Donator" ///
	  4 "Petitioner" 5 "Demonstrator" 6 "Activist" 
	
	// Calculate mean participation rates
	collapse (mean) p regime [aweight=weight], by(indicator ctrname)

	// Graph inequality
	egen axis = axis(regime ctrname), label(ctrname) gap reverse
	egen averagep = mean(p), by(regime indicator)
	
	graph twoway ///
	  || line axis averagep if regime == 1, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 2, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 3, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 4, sort lcolor(black) lpattern(solid) ///
	  || dot p axis, horizontal ms(O) mcolor(black) ///
	  || , by(indicator, note("")  legend(off)) ///
	  ylabel(1/7 9/12 14/18 20/24, ///
	    valuelabel angle(0)) ///
	  ytitle("") xtitle("Proportion of Participators") ///
	  ysize(7)
	graph export anparticipation_by_regime_ISSP02.eps, replace

	// Make Biplot from plotted Data
	drop averagep
	reshape wide p, i(ctrname) j(indicator)
	rename p1 Voter
	rename p2 Contacter
	rename p3 Donator
	rename p4 Petitioner
	rename p5 Demonstrator
	rename p6 Activist

	do `regime'
	label value regime regime
	
	egen iso=iso3166(ctrname)
	sort iso
	input labpos
3	//   AT
6	//   AU
7	//   BE
6	//   BG
3	//   CA
11	//   CH
9	//   CZ
1	//   DE
2	//   DK
6	//   FI
2	//   FR
6	//   HU
6	//   JP
12	//   LV
1	//   NL
11	//   NO
9	//   PL
3	//   SE
6	//   SI
6	//   SK
3	//   US
	
	biplot8 Voter-Activist, mlabel(iso) ///
	  subpop(regime, ms(O O O O) mlcolor(black..) mfcolor(black gs5 gs10 white) ///
	  mlab(iso iso iso iso) mlabvpos(labpos))
  	graph export anparticipation_by_regime_biplot_ISSP02.eps, replace



// ESS02-Data
	// ---------

	cd M:\group\ARS\USI\kohler\participation07\analysen
	// Get Data
	use ///
	  iso3166_2 weight voter contact donate petition protest actgroup regime ///
	  using cress02_01, clear

	tempfile regime
	label save regime using `regime'

	// Make data long
	local i 1
	foreach var of varlist voter contact donate petition protest actgroup {
		ren `var' p`i++'
	}
	gen index = _n
	reshape long p, i(index) j(indicator)
	label value indicator indicator
	label define indicator 1 "Voter" 2 "Contacter" 3 "Donator" ///
	  4 "Petitioner" 5 "Demonstrator" 6 "Activist" 
	
	// Calculate mean participation rates
	collapse (mean) p regime [aweight=weight], by(indicator iso3166_2)

	// Graph inequality
	egen axis = axis(regime iso3166_2), label(iso3166_2) gap reverse
	egen averagep = mean(p), by(regime indicator)
	
	graph twoway ///
	  || line axis averagep if regime == 1, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 2, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 3, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 4, sort lcolor(black) lpattern(solid) ///
	  || dot p axis, horizontal ms(O) mcolor(black) ///
	  || , by(indicator, note("")  legend(off)) ///
	  ylabel(1/4 6/9 11/20 22/24, ///
	    valuelabel angle(0)) ///
	  ytitle("") xtitle("Proportion of Participators") ///
	  ysize(7)
	graph export anparticipation_by_regime_ESS02_1.eps, replace


// ESS04-Data
	// ---------

	cd M:\group\ARS\USI\kohler\participation07\analysen
	// Get Data
	use ///
	  iso3166_2 weight voter contact petition protest actgroup regime ///
	  using cress04_01, clear

	tempfile regime
	label save regime using `regime'

	// Make data long
	local i 1
	foreach var of varlist voter contact petition protest actgroup {
		ren `var' p`i++'
	}
	gen index = _n
	reshape long p, i(index) j(indicator)
	label value indicator indicator
	label define indicator 1 "Voter" 2 "Contacter"  ///
	  3 "Petitioner" 4 "Demonstrator" 5 "Activist" 
	
	// Calculate mean participation rates
	collapse (mean) p regime [aweight=weight], by(indicator iso3166_2)

	// Graph inequality
	egen axis = axis(regime iso3166_2), label(iso3166_2) gap reverse
	egen averagep = mean(p), by(regime indicator)
	
	graph twoway ///
	  || line axis averagep if regime == 1, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 2, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 3, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 4, sort lcolor(black) lpattern(solid) ///
	  || dot p axis, horizontal ms(O) mcolor(black) ///
	  || , by(indicator, note("")  legend(off)) ///
	  ylabel(1/7 9/12 14/22 24/27, ///
	    valuelabel angle(0)) ///
	  ytitle("") xtitle("Proportion of Participators") ///
	  ysize(7)
	graph export anparticipation_by_regime_ESS02_1.eps, replace
	

// EQLS-Data
	// ---------

	cd M:\group\ARS\USI\kohler\participation07\analysen
	// Get Data
	use ///
	  iso3166_2 weight voter contact actgroup regime ///
	  using creqls_1, clear

	tempfile regime
	label save regime using `regime'

	// Make data long
	local i 1
	foreach var of varlist voter contact actgroup {
		ren `var' p`i++'
	}
	gen index = _n
	reshape long p, i(index) j(indicator)
	label value indicator indicator
	label define indicator 1 "Voter" 2 "Contacter" 3 "Activist" 
	
	// Calculate mean participation rates
	collapse (mean) p regime [aweight=weight], by(indicator iso3166_2)

	// Graph inequality
	egen axis = axis(regime iso3166_2), label(iso3166_2) gap reverse
	egen averagep = mean(p), by(regime indicator)
	
	graph twoway ///
	  || line axis averagep if regime == 1, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 2, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 3, sort lcolor(black) lpattern(solid) ///
	  || line axis averagep if regime == 4, sort lcolor(black) lpattern(solid) ///
	  || dot p axis, horizontal ms(O) mcolor(black) ///
	  || , by(indicator, note("")  legend(off)) ///
	  ylabel(1/10 12/14 16/27 29/30, ///
	    valuelabel angle(0)) ///
	  ytitle("") xtitle("Proportion of Participators") ///
	  ysize(7)
	graph export anparticipation_by_regime_eqls_1.eps, replace



exit




	

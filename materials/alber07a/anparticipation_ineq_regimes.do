* Calculate raw participation inequalities by welfare regimes 
* Author: kohler@wzb.eu
	
	// Intro
	// -----
	
version 9.2
	set more off
	set scheme s1mono

	// ISSP-Data
	// ---------

	use ///
	  iso3166_2 regime weight ///
	  voter contact donate petition protest actgroup ///
	  hhinc edu emp if regime < 4 ///
	  using issp02, clear

	tempfile regime
	label save regime using `regime'

	// Recode Emp and edu to fit into the loop
	replace emp = . if emp > 2
	replace emp = 3-emp
	replace emp = emp * 2

	replace edu = edu + 1


	foreach strata of varlist hhinc edu emp {
		local i 1
		foreach var of varlist voter contact donate petition protest actgroup {
			
			preserve
			local title: var lab `var'

			// Aggregates by social strata
			collapse (mean) `var' regime [aweight=weight], by(iso3166_2 `strata') fast
			drop if `strata' >= .

			egen ctrname = iso3166(iso3166_2), o(codes)
			egen axis = axis(regim ctrname), label(iso3166_2) gap
			replace axis = axis - .4 if `strata'==1
			replace axis = axis - .2 if `strata'==2
			replace axis = axis + .2 if `strata'==4
			replace axis = axis + .4 if `strata'==5
			
			// Definition of linegraphs (bypass a bug with Stata version 9.2 colors)
			levelsof iso3166_2, local(K)
			local line ""
			foreach k of local K {
				local line `"`line' (line `var' axis if iso3166_2 == "`k'", sort lcolor(black))"'
			}
			
			// The Graph
			graph twoway `line' ///
			  || scatter `var' axis, ms(o) mfcolor(white) mlcolor(black) ///
			  || , legend(off) ///
			  xlabel(1/5 7/11 13/16, valuelabel alternate) xline(6 12) ///
			  xtitle("") title(`"`title''"', box bexpand fcolor(gs10)) ///
			  ytitle("") ///
			  name(g`i++', replace) nodraw
			
			restore
			
		}
		
		graph combine g1 g2 g3 g4 g5 g6, rows(3)
		graph export anparticipation_ineq_regimes_`strata'.eps, replace
	}
	exit
	

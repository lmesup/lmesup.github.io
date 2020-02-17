* Turnout by elections systems
* kohler@wzb.eu
* Based on cr_elec_res.do by lenarz@wzb.eu


	clear
	set more off
version 9.2
	
	insheet using electionsystems.tsv, clear
    keep iso3166 fund
	sort iso3166
	
	lab var iso3166 "Iso3166_2 country codes (2-digit)"
	lab var fund "Do political parties receive direct/indirect public funding?"
	lab def fund 0 "No" 1 "Direct" 2 "Indirect" 3 "Direct and indirect" 4 "Other"
	lab val fund fund

	merge iso3166 using exp
	drop _merge

	sort iso3166
	save inclusive, replace


	

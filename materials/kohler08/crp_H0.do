*  P(Women) for H0: P(Women) = .5
* kohler@wz-berlin.de
	
version 9
	
	clear
	set memory 80m
	set more off
	
	use svydat01

	collapse (sum) womenp=women (sd) womensd = women (count) N=women if weich == 1, by(survey iso3166_2)

	// t-values
	gen woment = womenp - .5 /(womensd/sqrt(N))

	sort survey iso3166_2
	tempfile probs
	save `probs'

	use svydat01, clear
	keep survey iso3166_2 gdppcap1-back
	by survey iso3166_2, sort: keep if _n==1
	merge survey iso3166_2 using `probs'

	
	


	
	


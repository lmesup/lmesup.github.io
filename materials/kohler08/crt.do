* Resultset with t-values 
* kohler@wz-berlin.de
	
version 9
	
	clear
	set memory 80m
	set more off

	// EU + CC only 
	use svydat01 if ///
	  iso3166_2 ~= "UA" & iso3166_2 ~= "KR" ///	
	  & iso3166_2 ~= "BY" & iso3166_2 ~= "IS" ///
	  & iso3166_2 ~= "IL" & iso3166_2 ~= "HR" ///
	  & iso3166_2 ~= "US" & iso3166_2 ~= "RU" ///
	  & iso3166_2 ~= "NO" & iso3166_2 ~= "HR" ///
	  & iso3166_2 ~= "CH" & iso3166_2 ~= "AU" ///
	  & iso3166_2 ~= "AZ" & iso3166_2 ~= "PH" ///
	  & iso3166_2 ~= "NZ" & iso3166_2 ~= "JP" ///
	  & iso3166_2 ~= "CL" & iso3166_2 ~= "CA" ///

	keep if weich==1 

	// Do not separate Norhtern Irland resp. Parts of Germany
	replace iso3166_2 = "DE" if iso3166_2 == "DE (E)" | iso3166_2 =="DE (W)"

	// Sort-Order for Countries
	preserve
	keep ctrname eu 
	bysort ctrname: keep if _n == 1
	gsort -eu -ctrname 
	gen ctrsort = _n
	forvalues i = 1/37 {
		label define ctrsort `i' "`=ctrname[`i']'", modify
	}
	label val ctrsort ctrsort

	sort ctrname
	tempfile gdp
	save `gdp'
	restore

	collapse (mean) womenp=women (sd) womensd = women (count) N=women, by(survey iso3166_2 city hinc)

	// t-values
	gen woment = abs((womenp - .5) /(womensd/sqrt(N)))

	sort survey iso3166_2
	tempfile probs
	save `probs'

	use svydat01, clear
	keep survey iso3166_2 gdppcap1-back
	by survey iso3166_2, sort: keep if _n==1
	merge survey iso3166_2 using `probs'
	drop if _merge==1

	// Variable: quota
	gen quota:yesno = index(selper, "quota") >  0
	label variable quota "Quotaverfahren"
	
	graph dot woment, over(iso3166_2, sort(meant)) by(survey ) yline(2) ysize(8)

	tab survey, gen(svy)
	tab iso3166_2, gen(ctr)
	reg woment svy2-svy6 ctr2-ctr28 N


	

	
	


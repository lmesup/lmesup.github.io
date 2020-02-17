// Distribution of independen variables
// ------------------------------------
// (kohler@wzb.eu)

version 10
clear
set more off
set matsize 800
set scheme s1mono
use btwsurvey2

// Liswise deletion
mark touse
markout touse agegroup emp occ edu bul mar denom party polint
drop if !touse
drop touse

// Harmonize scales of political intereset
egen polint3 = xtile(polint), p(33(33)66) by(zanr)
lab val polint3 polint3
lab def polint3 1 "Low" 2 "Medium" 3 "High" 
lab var polint3 "Political interest"

// General graph settings
// ---------------------

// Format date variables
format %tdYY eldate

// Order of line-types
local pat solid dot dash longdash_3dot shortdash_dot
local pat `pat' longdash vshortdash dash_dot dash_dot_dot
local pat `pat' longdash_dot_dot longdash_shortdash tight_dot


// Loop over Indeps
// ----------------

// Initialize
preserve
foreach var of varlist agegroup emp occ edu bul mar denom polint3 {

	// Create percentages (using population weights)
	contract eldate bul `var', freq(n)
	merge eldate bul using popweights, uniqusing sort nokeep
	assert _merge==3
	drop _merge

	by eldate bul, sort: gen buln = sum(n)
	by eldate bul, sort: replace buln = buln[_N]
		
	by eldate `var', sort: replace n = sum(n*(popweight/buln))
	by eldate `var', sort: replace n = n[_N]
	by eldate `var', sort: keep if _n==1
	
	by eldate (`var'), sort: gen N = sum(n)
	by eldate (`var'), sort: replace N = N[_N]
	gen p = n/N*100

	// Labels for lines
	by `var' (eldate), sort: gen lab = p if _n == _N  ///
	  & `var' != "RP/SL":`:value label `var''  ///
	  & `var' != "NI":`:value label `var''  ///
	  & `var' != "HE":`:value label `var''  ///
	  & `var' != "ST":`:value label `var''  ///
	  & `var' != "Homemaker":`:value label `var''  /// 
	  & `var' != "Blue collar":`:value label `var'' 
	by `var' (eldate), sort: replace lab = p if _n == 1  ///
	  & (`var' == "RP/SL":`:value label `var''  ///
	  | `var' == "NI":`:value label `var'' /// 
	  | `var' == "HE":`:value label `var'' /// 
	  | `var' == "ST":`:value label `var'' /// 
	  | `var' == "Homemaker":`:value label `var'' /// 
	  | `var' == "Blue collar":`:value label `var'')
	
	gen pos = 3

	replace pos = 1 if `var' ==  "65+":`:value label `var''
	replace pos = 4 if `var' ==  "18-30":`:value label `var''

	replace pos = 2 if `var' ==  "In education":`:value label `var''
	replace pos = 3 if `var' ==  "Homemaker":`:value label `var''
	replace pos = 4 if `var' ==  "Other":`:value label `var''

	replace pos = 12 if `var' ==  "Employed":`:value label `var''
	replace pos = 6 if `var' ==  "Retired":`:value label `var''
	replace pos = 2 if `var' ==  "In educ.":`:value label `var''
	replace pos = 3 if `var' ==  "Homemaker":`:value label `var''
	replace pos = 4 if `var' ==  "Other":`:value label `var''

	replace pos = 6 if `var' ==  "White collar":`:value label `var''
	replace pos = 5 if `var' ==  "Blue collar":`:value label `var''

	replace pos = 1 if `var' ==  "BE/BB":`:value label `var''
	replace pos = 4 if `var' ==  "SN":`:value label `var''
	replace pos = 2 if `var' ==  "ST":`:value label `var''
	replace pos = 4 if `var' ==  "TH":`:value label `var''
	replace pos = 5 if `var' ==  "MV":`:value label `var''
	replace pos = 5 if `var' ==  "RP/SL":`:value label `var''
	replace pos = 12 if `var' ==  "NI":`:value label `var''
	replace pos = 9 if `var' ==  "HE":`:value label `var''
	replace pos = 6 if `var' ==  "ST":`:value label `var''
	

	// Create Plots with a Loop
	macro drop _l
	levelsof `var', local(K)
	local i 1
	foreach k of local K {
		local l  ///
	  `"`l' || li p eldate if `var'==`k', lc(black) lp(`:word `i++' of `pat'')"'
	}

	// Create the graphs
	tw  ///
	  `l' ///
	  || scatter lab eldate, ms(i) mlab(`var') mlabcolor(black) mlabvpos(pos) ///
	  || , title(`:var lab `var'', pos(12) box bexpand)  ///
	  nodraw name(`var', replace) legend(off)  ///
	  xtitle("")  ///
	  xscale(range(`=date("1Jan1949","DMY")' `=date("1Jan2012","DMY")' ))  ///
	  ytitle("")
	restore, preserve
}
	

// combined graph
// --------------

graph combine agegroup emp occ edu bul mar denom polint3 ///
  , rows(4) xsize(8.3) ysize(11.7) 
graph export grindeps2.eps, replace

exit

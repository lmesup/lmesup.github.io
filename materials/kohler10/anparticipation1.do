* Several participation measures by country
* Author: kohler@wzb.eu
	
// Intro
// -----
	
version 10
set more off
set scheme s1mono

clear
set memory 100m

use ess04

lab var contact "Contacted politician"
lab var protest "Take part in demonstration"
lab var actgroup "Worked in activity group"

local i 1
foreach var of varlist contact actgroup protest {
	local lab `"`lab' `i' "`:var lab `var''" "'
	ren `var' participation`i++'
}

 // Calculate Mean Participation
collapse (mean) participation*, by(dataset iso3166)
egen ctrname = iso3166(iso3166), o(codes)

// Classify Nations
gen natfam = 1 if iso3166 == "US"
replace natfam = 2 if ///
  inlist(iso3166,"AT","BE","DE","DK","ES") ///
  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
  | inlist(iso3166,"IT","LU","NL","PT","SE")
replace natfam = 3 if ///
  inlist(iso3166,"BG","CZ","EE","HU") ///
  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
replace natfam = 4 if natfam == .
keep if natfam < 4

gen mis = .

gen index = _n
reshape long participation, i(index) j(form)
label value form form
label def form `lab'

	// Average, Minimum, Maximum Participation Measure of Datasets
	by form iso3166, sort: gen meanparticipation = sum(participation)/sum(participation<.)
	by form iso3166: replace meanparticipation = meanparticipation[_N]

	replace mis = participation >= .
	by mis form iso3166 (participation), sort: gen minparticipation = participation[1] if !mis
	by mis form iso3166 (participation): gen maxparticipation = participation[_N] if !mis

	// Order of categorical axis
	by iso3166, sort: egen order = mean(participation) 
	egen axis = axis(natfam order), reverse label(iso3166) gap

	// Vertical lines for country group averages
	by natfam, sort: gen MEANparticipation = sum(meanparticipation)/sum(meanparticipation<.) if _N > 1
	by natfam: replace MEANparticipation = MEANparticipation[_N] if _N > 1

	levelsof natfam, local(K)
	local vlines ""
	foreach k of local K {
       local vlines ///
       "`vlines' || line axis MEANparticipation if natfam==`k', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
	}

	// Graph and Export
	levelsof axis, local(ylab)
	graph twoway ///
	  || dot meanparticipation axis, horizontal ms(O) mcolor(black)                 ///
	  || rspike minparticipation maxparticipation axis, horizontal lcolor(black)    ///
	  || `vlines'                                                                   ///        
	  || , ysize(6.5) xsize(10) ylabel(`ylab', valuelabel angle(0) labsize(*.8))    ///
	       ytitle("") xtitle(Proportion of participation) legend(off)  ///
          by(form, rows(1) legend(off) ///
          note("Source: CSES I, CSES II, ESS '02, ESS '04, EQLS '03 ISSP '04", span)       ///
	       title("Figure 7" "Alternative forms of particiaption by country"))   

	graph export ../figure7.eps, replace preview(on) orientation(landscape)
	

exit




	

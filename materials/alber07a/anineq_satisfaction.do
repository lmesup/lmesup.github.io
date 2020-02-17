* Difference in electoral participation regrading Satisfaction with Democracy
* Author: kohler@wzb.eu 

version 9.2
set more off
set scheme s1mono

clear
set memory 100m

use ///
 persid iso3166 dataset men age voter hhinc edu emp democsat weight ///
 using cses, clear
append using ess02  ///
 , keep(persid iso3166 dataset men age voter hhinc edu emp democsat weight )
append using ess04  ///
 , keep(persid iso3166 dataset men age voter hhinc edu emp democsat weight )
append using issp04 ///
 , keep(persid iso3166 dataset men age voter hhinc edu emp democsat weight )


// Split different question modes
gen subjective = democsat if dataset == "CSES-MODULE-1" | dataset == "CSES-MODULE-2" ///
	  | dataset == "ESS 2002" | dataset == "ESS 2004"
gen objective  = democsat if dataset == "ISSP 2004"


//Dummys der Statifizierungsvariablen bilden
tab hhinc, gen(hhinc)
tab edu, gen(edu)
tab emp, gen(emp)
tab subjective, gen(sub)
tab objective, gen(obj)

// Initialise postfile
tempfile diff
postfile coefs str2 iso3166 str10 dataset str10 strat b using `diff', replace

	//Differenzen by country 
	levelsof dataset, local(D)
	foreach dataset of local D {
		levelsof iso3166 if dataset == "`dataset'", local(K)
		quietly foreach k of local K {
			count if !mi(voter) & !mi(sub4) & dataset == "`dataset'" & iso3166 == "`k'"
			if r(N) > 300 {
				reg voter men age hhinc2-hhinc5 emp2-emp5 sub2-sub4 if iso3166 == "`k'" & dataset == "`dataset'"
				post coefs ("`k'") ("`dataset'") ("CSES, ESS") (_b[sub4])
			}
			count if !mi(voter) & !mi(obj4) & dataset == "`dataset'" & iso3166 == "`k'"
			if r(N) > 300 {
				reg voter men age hhinc2-hhinc5 emp2-emp5 obj2-obj4 if iso3166 == "`k'" & dataset == "`dataset'"
				post coefs ("`k'") ("`dataset'") ("ISSP 2004") (_b[obj4])
			}
		}
	}

postclose coefs

use `diff', replace
drop if b==0

// Classify Nations
gen natfam = 1 if iso3166 == "US"
replace natfam = 2 if ///
  inlist(iso3166,"AT","BE","DE","DK","ES") ///
  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
  | inlist(iso3166,"IT","LU","NL","PT","SE")
replace natfam = 3 if ///
  inlist(iso3166,"CY","MT","TR")
replace natfam = 4 if ///
  inlist(iso3166,"BG","CZ","EE","HU","KR") ///
  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
replace natfam = 5 if natfam == .

// Average, Minimum, Maximum Participation Measure of Datasets
by iso3166 strat, sort: gen meanb = sum(b)/sum(b<.)
by iso3166 strat: replace meanb = meanb[_N]

by iso3166 strat (b), sort: gen minb = b[1] 
by iso3166 strat (b): gen maxb = b[_N] 

// Values for vertical lines 
by natfam strat, sort: gen MEANb = sum(meanb)/sum(meanb<.) if _N > 1
by natfam strat: replace MEANb = MEANb[_N] if _N > 1


// Graphs by Country
// -----------------

// Order of categorical axis
by iso3166, so: gen order = sum(meanb)/sum(meanb<.)
by iso3166: replace order = order[_N]

egen axis = axis(natfam order), reverse label(iso3166) gap

// Rendering of categorical axis labels
levelsof axis if natfam < 5, local(I)

levelsof natfam, local(J)
local vlines ""
foreach j of local J {
  local vlines ///
 "`vlines' || line axis MEANb if natfam==`j', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
}

// Graph and Export
graph twoway ///
   `vlines'                                                       ///
   || rspike minb maxb axis                                       ///
      , horizontal lcolor(black)                                  ///
   || dot meanb axis                                              ///
      , horizontal msymbol(O) mlcolor(black) mfcolor(black)       ///
   || if natfam < 5                                               ///
      , ylabel(`I', valuelabel angle(0) labsize(*.8)) ytitle("")  ///
      xtitle("Turnout of satisfied minus turnout of dissatisfied") ///
	  xlabel(-.2(.2).4) xtick(-.2(.1).4) xmtick(-.15(.1).35)     ///
      by(strat, legend(off) ///
      note("Source: CSES I, CSES II, ESS '02, ESS '04, ISSP 2004", span)    ///
    title("Figure 6" "Inequality of electoral participation")) ///
    xsize(10) ysize(6.5) 
	
	graph export ../figure6.eps, replace preview(on) orientation(landscape) 


exit
	

* Difference in particpating on election campaign
* Author: lenarz@wzb.eu -> diff_petition.do
* Rework: kohler@wzb.eu 

version 9.2
set more off
set scheme s1mono

clear
set memory 100m

use ///
 persid iso3166 dataset petition hhinc edu emp weight ///
 using issp04, clear

//Dummys der Statifizierungsvariablen bilden
tab hhinc, gen(hhinc)
tab edu, gen(edu)
tab emp, gen(emp)

// Initialise postfile
tempfile diff
postfile coefs str2 iso3166 str10 dataset str10 strat b using `diff', replace

//Differenzen by country 
levelsof dataset, local(D)
quietly foreach dataset of local D {
  levelsof iso3166 if dataset == "`dataset'", local(K)
  foreach k of local K {
    count if !mi(petition) & !mi(hhinc5) & dataset == "`dataset'" & iso3166 == "`k'"
    if r(N) > 300 {
      reg petition hhinc2-hhinc5 if iso3166 == "`k'" & dataset == "`dataset'"
      post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5])
    }
    count if !mi(petition) & !mi(edu3) & dataset == "`dataset'" & iso3166 == "`k'"
    if r(N) > 300 {
      reg petition edu2 edu3 if iso3166 == "`k'"  & dataset == "`dataset'"
      post coefs ("`k'") ("`dataset'") ("edu") (_b[edu3])
    }
    count if !mi(petition) & !mi(emp1) & dataset == "`dataset'" & iso3166 == "`k'"
    if r(N) > 300 {
        reg petition emp1 emp3-emp5 if iso3166 == "`k'" & dataset == "`dataset'"
        post coefs ("`k'") ("`dataset'") ("emp") (_b[emp1])
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
  inlist(iso3166,"BG","CZ","EE","HU","KR") ///
  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
replace natfam = 4 if natfam == .

// Average, Minimum, Maximum Participation Measure of Datasets
by iso3166 strat, sort: gen meanb = sum(b)/sum(b<.)
by iso3166 strat: replace meanb = meanb[_N]

by iso3166 strat (b), sort: gen minb = b[1] 
by iso3166 strat (b): gen maxb = b[_N] 

// Values for vertical lines 
by natfam strat, sort: gen MEANb = sum(meanb)/sum(meanb<.) if _N > 1
by natfam strat: replace MEANb = MEANb[_N] if _N > 1

levelsof strat, local(K)
foreach strat of local K {

  // Order of categorical axis
  egen axis`strat' = axis(natfam meanb) if strat == "`strat'", reverse label(iso3166) gap

  // Rendering of categorical axis labels
  levelsof axis`strat', local(I)

  levelsof natfam, local(J)
  local vlines ""
  foreach j of local J {
    local vlines ///
   "`vlines' || line axis`strat' MEANb if natfam==`j', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
  }

  // Graphik and Export
  graph twoway ///
     `vlines'                                                       ///
     || rspike minb maxb axis`strat' if strat == "`strat'"          ///
        , horizontal lcolor(black)                                  ///
     || dot meanb axis`strat' if strat== "`strat'"                  ///
        , horizontal msymbol(O) mlcolor(black) mfcolor(black)       ///
     || , ylabel(`I', valuelabel angle(0)) ytitle("")            ///
          xtitle("Inequality in signing a petition (`strat')") ///
          xsize(4) ysize(6) legend(off)
  graph export anineq_petition_`strat'.eps, replace preview(on)

}


        

         
            




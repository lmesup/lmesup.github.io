* Difference in electoral participation
* Author: lenarz@wzb.eu -> diff_voter.do
* Rework: kohler@wzb.eu 

version 9.2
set more off
set scheme s1mono

clear
set memory 100m

use ///
 persid iso3166 dataset voter hhinc edu age weight ///
 using cses, clear
append using ess02  ///
 , keep(persid iso3166 dataset voter hhinc edu age weight  )
append using ess04  ///
 , keep(persid iso3166 dataset voter hhinc edu age weight  )
append using issp02 ///
 , keep(persid iso3166 dataset voter hhinc edu age weight  )
append using issp04 ///
 , keep(persid iso3166 dataset voter hhinc edu age weight  )
append using eqls03 ///
 , keep(persid iso3166 dataset voter hhinc edu age weight  )


// Classify Nations
drop if iso3166=="TR"
gen natfam = 1 if iso3166 == "US"
replace natfam = 2 if ///
  inlist(iso3166,"AT","BE","DE","DK","ES") ///
  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
  | inlist(iso3166,"IT","LU","NL","PT","SE")
replace natfam = 3 if ///
	  inlist(iso3166,"CY","MT","TR")
replace natfam = 4 if ///
  inlist(iso3166,"BG","CZ","EE","HU") ///
  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
replace natfam = 5 if natfam == .
keep if natfam < 5
	
// Dummys der Statifizierungsvariablen bilden
tab hhinc, gen(hhinc)
tab edu, gen(edu)

// Age dummies
gen age1 = inrange(age,18,29) if age < . 
gen age2 = inrange(age,30,64) if age < . 
gen age3 = inrange(age,64,110) if age < .

// Generate Interactions
foreach var of varlist hhinc2-hhinc5 edu2-edu3 {
		gen `var'age1 = `var'*age1
		gen `var'age2 = `var'*age2
		gen `var'age3 = `var'*age3
	}
		
// Initialise postfile
tempfile diff
postfile coefs str2 iso3166 str10 dataset str10 strat b ia using `diff', replace

//Differenzen by country 
levelsof dataset, local(D)
quietly foreach dataset of local D {
  levelsof iso3166 if dataset == "`dataset'", local(K)
  foreach k of local K {
    count if !mi(voter) & !mi(hhinc5) & dataset == "`dataset'" & iso3166 == "`k'"
    if r(N) > 300 {
      reg voter hhinc2-hhinc5 age1 age3 hhinc?age1 hhinc?age3 if iso3166 == "`k'" & dataset == "`dataset'"
      post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5]) (_b[hhinc5age3])
    }
    count if !mi(voter) & !mi(edu3) & dataset == "`dataset'" & iso3166 == "`k'"
    if r(N) > 300 {
      reg voter edu2 edu3 age1 age3 edu?age1 edu?age3 if iso3166 == "`k'"  & dataset == "`dataset'"
      post coefs ("`k'") ("`dataset'") ("edu") (_b[edu3]) (_b[edu3age3])
    }
  }
}

postclose coefs

use `diff', replace
drop if b==0
drop if ia == 0	
	
gen bold = b + ia

// Classify Nations
gen natfam = 1 if iso3166 == "US"
replace natfam = 2 if ///
  inlist(iso3166,"AT","BE","DE","DK","ES") ///
  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
  | inlist(iso3166,"IT","LU","NL","PT","SE")
replace natfam = 3 if ///
	  inlist(iso3166,"CY","MT","TR")
replace natfam = 4 if ///
  inlist(iso3166,"BG","CZ","EE","HU") ///
  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
replace natfam = 5 if natfam == .
keep if natfam < 5
	
// Average, Minimum, Maximum Participation Measure of Datasets
by iso3166 strat, sort: gen meanb = sum(b)/sum(b<.)
by iso3166 strat: replace meanb = meanb[_N]

by iso3166 strat, sort: gen meanbold = sum(bold)/sum(bold<.)
by iso3166 strat: replace meanbold = meanbold[_N]

	replace strat = "Bildung" if strat == "edu"
	replace strat = "Einkommen" if strat == "hhinc"
	
	
// Order of categorical axis
by iso3166, sort: gen axismean = sum(b)/sum(b<.)
by iso3166: replace axismean = axismean[_N]
egen axis = axis(natfam axismean), reverse label(iso3166) gap

levelsof axis, local(I)
	
// Graph and Export
graph twoway ///
  || pcarrow meanb axis meanbold axis                         ///
  , horizontal lcolor(black) mcolor(black)                    ///
  || sc axis meanb                                            ///
  ,  msymbol(O) mcolor(black)                                 ///
  || , ylabel(`I', valuelabel angle(0)gstyle(dot)) ytitle("") ///
  by(strat,                                                   ///
     note("Quellen: CSES I, CSES II, ISSP '04, ISSP '02, ESS '02, ESS '04, EQLS '03", span) ///
     title(`"Grafik 5: "', span ring(2) pos(11) justification(left) size(medlarge)) ///
     subtitle(`"Ungleichheit der Wahlbeteiligung der "'                             ///
              `"Rentnerbevölkerung und der  jüngeren "' ///
              `"Generation"', margin(l+17 b+3)                     ///
               span ring(2) pos(11) justification(left) size(medlarge)))            ///
  ysize(5.5) xsize(4)                                                               ///
  legend(order(2 "30-64" 1 "65 und älter"))                                         ///
  xtitle("Differenz der Wahlbeteiligung" "(Statushöhere minus Statusniedere)")      

graph export ../figure5DE.eps, replace preview(on) 

exit





	
        

         
            




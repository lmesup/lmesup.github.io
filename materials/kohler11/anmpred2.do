// Bootstraph of Non-voters' probability of voting for party i 
// -----------------------------------------------------------
// (kohler@wzb.eu)

version 10
clear
set more off
set matsize 800
set scheme s1mono
use btwsurvey if year(eldate)

// Liswise deletion
mark touse
markout touse agegroup emp occ edu bul mar denom polint
keep if touse
drop touse

// Center
by zanr, sort: center polint, standard

// Use two 1949-survey as just one (no non-voters in 2324, no party in 2361)
replace zanr = "2324/2361" if inlist(zanr,"2324","2361")

// Add weights
merge eldate bul using popweights, uniqusing sort
by zanr, sort: gen double pweight = (_N/popweight)^(-1)

// Dummies
xi i.agegroup*c_polint i.emp*c_polint i.occ*c_polint i.edu*c_polint  /// 
  i.bul*c_polint i.mar*c_polint i.denom*c_polint


// Initialize loop for Bootstrap
// ------------------------------
keep party _I* pweight eldate zanr voter

tempname CI
postfile `CI' bsample str9 zanr eldate categ Phat 	/// 
  using anmpred2_bs, replace 


// Models for original sample
// --------------------------

// Loop over dates and surveys
levelsof eldate, local(K)
foreach k of local K {
	levelsof zanr if eldate==`k' & !mi(party), local(L)
	foreach l of local L {
		
		// Estimate model
		capture mlogit party _I* [pweight=pweight]	///
		  if eldate==`k' & zanr=="`l'" & voter 	///
		  , base(1)
		
		if !_rc {
			
			// Predict
			predict Phat1 Phat2 Phat3
			
			// Post
			forv j = 1/3 {
				sum Phat`j' [aw=pweight]  /// 
				  if !voter & eldate==`k' & zanr=="`l'", meanonly
				post `CI' (0) ("`l'") (`k') (`j') (r(mean))
			}
			drop Phat*
		}
	}
}


// Bootstrap
// ---------

preserve
set seed 731

quietly {
	forv i = 1/200 {
		noi di as text "Sample " as res `i' as text  " of " as res 200
		bsample, strata(eldate zanr) 
		
		// Loop over dates and surveys
		levelsof eldate, local(K)
		foreach k of local K {
			levelsof zanr if eldate==`k' & !mi(party), local(L)
			foreach l of local L {
			
				// Estimate model
				capture mlogit party _I* [pweight=pweight]	///
				  if eldate==`k' & zanr=="`l'" & voter 	///
				  , base(1)

				if !_rc {

					// Predict
					predict Phat1 Phat2 Phat3
					
					// Post
					forv j = 1/3 {
						sum Phat`j' [aw=pweight]  /// 
						  if !voter & eldate==`k' & zanr=="`l'", meanonly
						post `CI' (`i') ("`l'") (`k') (`j') (r(mean))
					}
					drop Phat*
				}
			}
		}
		restore, preserve
	}
}
postclose `CI'

exit


// Bootstrap of Non-voters' probability of voting for party i state elections 
// --------------------------------------------------------------------------
// thewes@wzb.eu, UK-edits

version 11
clear
set more off
set matsize 800
set scheme s1mono
use ltwsurvey if year(eldate), clear

// Liswise deletion
mark touse
markout touse agegroup emp occ edu mar denom 
keep if touse
drop touse

// Initialize loop for Bootstrap
// ------------------------------

keep party agegroup emp occ edu mar denom eldate area voter

tempname CI
postfile `CI' bsample str9 area eldate categ Phat 	/// 
  using anmpred2_bs_ltw, replace 

// Models for original sample
// --------------------------

// Loop over dates and surveys
levelsof eldate, local(K)
quietly {
	foreach k of local K {
		levelsof area if eldate==`k' & !mi(party), local(L)
		foreach l of local L {
			
			// Estimate model
			capture mlogit party i.agegroup i.emp i.occ i.edu i.mar i.denom	///
			  if eldate==`k' & area=="`l'" & voter 	///
			  , base(1)
			
			if !_rc {
				
				// Predict
				predict Phat1 Phat2 Phat3
				
				// Post
				forv j = 1/3 {
					sum Phat`j'   /// 
					  if !voter & eldate==`k' & area=="`l'", meanonly
					post `CI' (0) ("`l'") (`k') (`j') (r(mean))
				}
				drop Phat*
			}
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
		bsample, strata(eldate area) 
		
		// Loop over dates and surveys
		levelsof eldate, local(K)
		foreach k of local K {
			levelsof area if eldate==`k' & !mi(party), local(L)
			foreach l of local L {
			
				// Estimate model
				capture mlogit party i.agegroup i.emp i.occ i.edu i.mar i.denom	///
				  if eldate==`k' & area=="`l'" & voter 	///
				  , base(1)

				if !_rc {

					// Predict
					predict Phat1 Phat2 Phat3
					
					// Post
					forv j = 1/3 {
						sum Phat`j'  /// 
						  if !voter & eldate==`k' & area=="`l'", meanonly
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


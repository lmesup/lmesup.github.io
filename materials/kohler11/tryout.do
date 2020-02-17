// Non-voters' probability of voting for party i
// ---------------------------------------------
// (kohler@wzb.eu)

version 10
clear
set more off
set matsize 800
set scheme s1mono
use btwsurvey 

// Periods
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

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


// Create linear predictor and it's standard error

// Dummies
xi i.agegroup*c_polint i.emp*c_polint i.occ*c_polint i.edu*c_polint  /// 
  i.bul*c_polint i.mar*c_polint i.denom*c_polint

ren party party3
input LhatSPD LhatCDU LhatOth SESPD SECDU SEOth
end

// Predicit voting behavior of non-voters
tempname CI
tempfile ci
postfile `CI' str9 zanr eldate index categ Phat ub lb se using `ci'

by voter eldate zanr, sort: 	/// 
  gen index = _n if !voter 
gen pattern = .

quietly {
	levelsof eldate, local(K)
	foreach k of local K {
		levelsof zanr if eldate==`k' & !mi(party), local(L)
		foreach l of local L {

			// Estimate model
			mlogit party _I* [pweight=pweight]	///
			  if eldate==`k' & zanr=="`l'" & voter 	///
			  , base(1)
			
			// Build Vector for -prvalue, x()-  and loop over obs
			local indepnames: colnames e(b)
			local indepnames: list uniq indepnames 
			local indepnames: subinstr local indepnames `"_cons"' `""', all

			by `indepnames', sort: replace pattern = _n==1
			
			levelsof index if pattern & eldate==`k' & zanr=="`l'", local(I)
			foreach i of local I {
				foreach var of local indepnames {
					sum `var' 			/// 
					  if index == `i' & eldate==`k' & zanr=="`l'", meanonly
					local x `"`x' `var'==`=r(mean)'"'
				}
				
				// Estimate and post values
				prvalue, delta x(`x')
				matrix CI = r(pred)
				forv r=1/3 {
					post `CI' ("`l'") (`k') (`i')  /// 
					  (`=CI[`r',4]') (`=CI[`r',1]') (`=CI[`r',2]')  /// 
					  (`=CI[`r',3]') (`=CI[`r',5]') 
				}
			}
			
		}
	}
}

use `ci', clear


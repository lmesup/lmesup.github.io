// Modelfit of multinomial regression Models
// ----------------------------------------
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

// Add weights
merge eldate bul using popweights, uniqusing sort
by zanr, sort: gen double pweight = (_N/popweight)^(-1)

// Estimate Models (to get the Pseudo R^2)

quietly {

	// Dummies
	xi i.agegroup*polint i.emp*polint i.occ*polint i.edu*polint  /// 
	  i.bul*polint i.mar*polint i.denom*polint
	
	ren party party3
	
	// Predicit voting behavior of non-voters
	tempname results
	tempfile x
	postfile `results' eldate str8 zanr n r2 using `x'
	levelsof eldate, local(K)
	foreach k of local K {
		levelsof zanr if eldate==`k', local(L)
		foreach l of local L {
			mlogit party _I* [pweight=pweight]	///
			  if eldate==`k' & zanr=="`l'" & voter
			post `results' (`k') ("`l'") (e(N)) (e(r2_p))
		}
	}
	postclose `results'
}

use `x', clear


format eldate %tdYY

gsort -n
levelsof eldate, local(lab)
graph twoway ///
  || lowess r2 eldate, lcolor(black)    ///
  || scatter r2 eldate [aweight=n], mlcolor(black) mfcolor(white) ms(O) 	///
  || , xlab(`lab') ylab(, grid)					///
  xtitle(Election date) ytitle(McFadden's Pseudo R²) legend(off)

graph export anmfit2.eps, replace
  

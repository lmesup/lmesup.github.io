// Show selected coefficients of the prediction model
// --------------------------------------------------
// (kohler@wzb.eu)

version 10
clear
set more off
set matsize 800
set scheme s1mono
use btwsurvey

// Liswise deletion
mark touse
markout touse agegroup emp occ edu bul mar denom party polint
drop if !touse
drop touse

// Center
by zanr, sort: center polint

// Add weights
merge eldate bul using popweights, uniqusing sort
by zanr, sort: gen double pweight = (_N/popweight)^(-1)

// Estimate Models (to get the Pseudo R^2)

quietly {

	// Dummies
	xi i.agegroup*c_polint i.emp*c_polint i.occ*c_polint i.edu*c_polint  /// 
	  i.bul*c_polint i.mar*c_polint i.denom*c_polint
	
	ren party party3
	
	// Predicit voting behavior of non-voters
	tempname results
	tempfile x
	postfile `results' eldate str8 zanr b1 b2 b3 b4 b5 b6 using `x'
	levelsof eldate, local(K)
	foreach k of local K {
		levelsof zanr if eldate==`k', local(L)
		foreach l of local L {
			mlogit party _I* [pweight=pweight]	///
			  if eldate==`k' & zanr=="`l'" & voter 	///
			  , base(1)
			post `results' (`k') ("`l'")  ///
			  ([2]_b[_Iagegroup_3]) ([2]_b[_Iemp_5]) ([2]_b[_Iocc_3])  /// 
			  ([2]_b[_Iedu_3]) ([2]_b[_Imar_3]) ([2]_b[_Idenom_2])
		}
	}
	postclose `results'
}

use `x', clear

format eldate %tdYY

reshape long b, i(zanr) j(coef)

replace b = b*-1 if coef==3

lab val coef coef
lab def coef 1 "Age 60+ vs. <30" 2 "Unemployed vs. employed"  ///
  3 "Self empl. vs. B. collar" 4 "High vs. low educ."  ///
  5 "Single vs. couple"  6 "Cath. vs. Prot."

graph twoway ///
  || lowess b eldate, lcolor(black)    ///
  || scatter b eldate, mlcolor(black) mfcolor(white) ms(O) 	///
  || if inrange(b,-5,5) , xlab(`lab') ylab(, grid) yline(0) ///
  xtitle(Election date) ytitle(Coef of equation CDU/CSU vs. SPD) ///
  by(coef, legend(off) note(""))
graph export anmcoefs.eps, replace

  

  

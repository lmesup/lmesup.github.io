// Checks for Normality assumption
// kohler@wzb.eu
// (Analysis provoked by reviewer 1, point E)

version 11
clear
set more off
capture log close
log using annormal, replace

// Work with data
// --------------

use v2a v22 using wvs5ab.dta

// Life satisfaction
generate lsat=v22
label variable lsat "Life satisfaction 1-10"
drop v22

// ISO 3166 Ländercodes and Country names
// Change "non-iso" country names
label define v2a 						/// 
  2 "united kingdom" 					///
  11 "united states" 					///
  15 "south africa" 					///
  24 "korea, republic of" 				///
  40 "taiwan, province of china" 		///
  50 "russian federation" 				///
  61 "moldova, republic of" 			///
  71 "viet nam" 						///
  91 "iran, islamic republic of", modify

// Apply egen-iso (from egenmore)
egen iso2 = iso3166(v2a), o(names)
egen ctr  = iso3166(iso2), o(codes)
drop v2a


// Normal Probability Plots for countries with lsat=[5,6]
// ------------------------------------------------------

egen meanlsat = mean(lsat), by(iso2)
keep if inrange(meanlsat,5,6)

local i 1
levelsof ctr, local(L)
levelsof iso2, local(K)
foreach k of local K {
	pnorm lsat if iso2=="`k'" 			///
	  , ti("`:word `i++' of `L''", pos(12) bexpand box)   ///
	  name(`k', replace) nodraw ylab(0(.5)1)  ///
	  ytitle("") xtitle("")
	local names `names' `k'

}

graph combine `names' 					///
  , xcommon ycommon l1title(Normal F) b1title(Empirical)  ///
  imargin(small)
graph export annormal.eps, replace

// Skewness lsat=[5,6]
// ----------------------

statsby Mean=(r(mean)) Skewness=(r(skewness)), by(ctr) clear: sum lsat, d
sort Mean
list ctr Mean Skewness, noobs 


log close
exit



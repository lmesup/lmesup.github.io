// Compare the two IEFF correction for various sigmas
// kohler@wzb.eu

version 11
clear
set more off
set scheme s1mono

// Define simulation program
// -------------------------
// (copy from ansimulation.do)

capture program drop satsim
program define satsim, rclass
version 11
	syntax [, obs(integer 1) sigma(real 1) range(numlist)]
	drop _all
	set obs `obs'

	local recode: subinstr local range " " ",", all
	local last: word count `range'
	local min: word 1 of `range'
	local max: word `last' of `range'

	local mu = runiform()*(`max'-`min')+`min'

	tempvar z
	gen `z' = recode(round(rnormal(`mu',`sigma'),1),`recode')
	sum `z'
	return scalar mu = `mu'
	return scalar sigma = `sigma'
	return scalar min= `min'
	return scalar max = `max'
	return scalar mean = r(mean)
	return scalar sd  = r(sd)
end


// Work with data
// --------------

use v2a v22 v259a using wvs5ab_new_happy.dta

// Life satisfaction
generate lsat=v22
label variable lsat "Life satisfaction 1-10"
drop v22

// ISO 3166 Ländercodes and Country names
// Change "non-iso" country names
label define v2a 						///
  2 "united kingdom" 					///
  3 "germany"                           ///
  11 "united states" 					///
  15 "south africa" 					///
  24 "korea, republic of" 				///
  34 "germany"                          ///
  40 "taiwan, province of china" 		///
  50 "russian federation" 				///
  61 "moldova, republic of" 			///
  71 "viet nam" 						///
  91 "iran, islamic republic of", modify

// Apply egen-iso (from egenmore)
egen iso2 = iso3166(v2a), o(names)
drop v2a

collapse 				 	 /// 
  (mean) lsatbar=lsat  /// 
  (sd) lsatsd=lsat  ///
  (count) n = lsat   ///
  [aw=v259a] 		///
  , by(iso2)

// IEFF-A correction
// -----------------

gen maxsd = lsatsd/sqrt((1-lsatbar)*(lsatbar-10)*(n/(n-1)))

// Run simulations for IEFF-B
// --------------------------

preserve

local i 1
foreach sigma in 0.1 0.5 1 2 3 4.5 {

	set seed 731
	simulate, reps(200): 		/// 
	  satsim, obs(1000) range(1/10) sigma(`sigma')
	reg sd mean c.mean#c.mean
	estimates store lsat`i++'

}

restore

// IEFF-B corrections
// ------------------

local i 1
tempvar lsatsdhat
gen `lsatsdhat' = .
foreach sigma in 0.1 0.5 1 2 3 4.5 {
	estimates restore lsat`i'
	replace `lsatsdhat' 				///  
	  = _b[_cons] + _b[mean]*lsatbar + _b[c.mean#c.mean]*lsatbar^2
	gen sim`i++' = lsatsd*(`sigma'/`lsatsdhat')
}

corr maxsd sim*

// Graph results
// -------------

reshape long sim, i(iso2) j(typ)
label define typ 						/// 
  1 "{&sigma}=0.1" 2 "{&sigma}=0.5" 3 "{&sigma}=1" 		/// 
  4 "{&sigma}=2"  5 "{&sigma}=3" 6 "{&sigma}=4.5"
label value typ typ

graph twoway 							///
  || scatter sim maxsd, ms(Oh) mcolor(black)  ///
  || lfit sim maxsd, lcolor(black)  ///
  ||, by(typ, note("Graphs by assumed {&sigma}") legend(off) yrescale) 	/// 
  xtitle("Std. Dev. {&lowast} IEFF{superscript:A}") ///
  ytitle("Std. Dev. {&lowast} IEFF{superscript:B}")  ///
  saving(ancompare, replace)

graph export ancompare.eps, replace

exit



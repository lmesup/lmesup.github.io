// Standard deviation of WFS corrected for IEFF
// kohler@wzb.eu,

// Based on: wvs5_inequality.do (j.delhey@jacobs-university.de)

version 11
clear
set more off
capture log close
set graph off
log using anwvsieff, replace

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

use v2a v10 v22 v68 using wvs5ab.dta

// Life satisfaction
generate lsat=v22
label variable lsat "Life satisfaction 1-10"
drop v22

// Happiness
generate happy= 5 - v10
label variable happy "feeling happy 1-4"
drop v10

// Satisfaction with financial situation of household
generate incsat=v68
label variable incsat "income satisfaction 1-10"
drop v68

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


drop v2a


// Standard Deviation by Country and total
// ---------------------------------------

table iso2, c(mean lsat mean happy mean incsat) row 
table iso2, c(sd lsat sd happy sd incsat) row 

// Run simulations for WVS instruments and estimates of sigma
// ----------------------------------------------------------

// Life Satisfaction
preserve
sum lsat
local lsatsigma = r(sd)

simulate, reps(200): 		/// 
  satsim, obs(1000) range(1/10) sigma(`lsatsigma')
reg sd mean c.mean#c.mean
estimates store lsat

// Happiness
restore, preserve
sum happy
local happysigma = r(sd)

simulate, reps(200): 		/// 
  satsim, obs(1000) range(1/4) sigma(`happysigma')
reg sd mean c.mean#c.mean
estimates store happy

// Income satisfaction
restore, preserve
sum incsat
local incsatsigma = r(sd)

simulate, reps(200): 		/// 
  satsim, obs(1000) range(1/10) sigma(`incsatsigma')
reg sd mean c.mean#c.mean
estimates store incsat

// Estimate IEFF for WVS data
// --------------------------

restore
collapse 				 	 /// 
  (mean) lsatbar=lsat happybar=happy incsatbar=incsat /// 
  (sd) lsatsd=lsat happysd=happy incsatsd=incsat ///
  , by(iso2)

foreach name in lsat happy incsat {
	estimates restore `name'
	gen `name'sdhat 						/// 
	  = _b[_cons] + _b[mean]*`name'bar + _b[c.mean#c.mean]*`name'bar^2
	gen `name'ieff = ``name'sigma'/`name'sdhat
	gen `name'corr = `name'sd*`name'ieff
}


// Rank change plots
// -----------------

egen ctrname = iso3166(iso2), o(codes)
replace ctrname = subinstr(ctrname,"Of","of",.)

foreach stub in lsat happy incsat {

	spearman `stub'sd `stub'corr, stats(obs p) pw
	egen `stub'rank = rank(`stub'sd)
	egen `stub'rankcorr = rank(`stub'corr)
	generate `stub'chg = `stub'rank - `stub'rankcorr
	
	graph dot (asis) `stub'chg, over(ctrname, sort(`stub'chg)) ///
	  title("Rank change by IEFF") 					///
	  subtitle("- = more unequal, + = more equal") ///
	  note("Data: WVS5ab; Do-file: anwvsieff.do", span) ///
	  xsize(3) ysize(8) yline(0) 		/// 
	  saving(anwvsieff_`stub'rankchg, replace)
	graph export anwvsieff_`stub'rankchg.eps, replace
}

// Standard deviation by mean plots
// --------------------------------

local lsattitle "Life satisfaction"
local happytitle "Happiness"
local incsattitle "Income satisfaction"

foreach stub in lsat happy incsat {

	graph twoway 						 /// 
	  || lowess `stub'sd `stub'bar, lcolor(black)  ///
	  || scatter `stub'sd `stub'bar 	///
	  , mcolor(black) ms(o) 			/// 
	  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall)  ///
	  || , title("``stub'title'") ///
	  ytitle("Gross standard deviation") ///
	  xtitle("Mean") ///
	  note("Data: WVS5ab; Do-file: anwvsieff.do", span) ///
	  xsize(4.5) ysize(4.5) legend(off)  /// 
	  saving(anwvsieff_`stub'sdbymean, replace)
	graph export "anwvsieff_`stub'sdbymean.eps", replace


	graph twoway 						 /// 
	  || lowess `stub'corr `stub'bar, lcolor(black)  ///
	  || scatter `stub'corr `stub'bar 	///
	  , mcolor(black) ms(o) 			/// 
	  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall)  ///
	  || , title("``stub'title'") ///
	  ytitle("IEFF-corrected standard deviation") ///
	  xtitle("Mean") ///
	  note("Data: WVS5ab; Do-file: anwvsieff.do", span) ///
	  xsize(4.5) ysize(4.5) legend(off)  ///
	  saving(anwvsieff_`stub'corrbymean, replace)
	graph export "anwvsieff_`stub'corrbymean.eps", replace

}


// Correlates with aggregate level variables
// -----------------------------------------

// Prepare country data for merging
preserve
use wvs5countrydata, clear

replace ctryname = "united kingdom" if ctryname == "Great Britain"
replace ctryname = "Iran, Islamic Republic of" if ctryname == "Iran"
replace ctryname = "Moldova, Republic of" if ctryname == "Moldova"
replace ctryname = "Russian Federation" if ctryname == "Russia"
replace ctryname = "Korea, Republic of" if ctryname == "South Korea"
replace ctryname = "Taiwan, Province of China" if ctryname == "Taiwan"
replace ctryname = "Trinidad and Tobago" if ctryname == "Trinidad&Tob."
replace ctryname = "Viet Nam" if ctryname == "Vietnam"

egen iso2 = iso3166(ctryname), o(names)
drop if iso2==""

tempfile x
save `x'

// Merge
restore
merge n:1 iso2 using `x', keep(3) nogen  /// 
  keepusing(gini2005 pop2005 gdp2000 gdp2005 ppp2005 wregion)

// Take logs
generate poplog = log(pop2005)
generate gdp00log = log(gdp2000)
generate gdp05log = log(gdp2005)
generate ppp05log = log(ppp2005)

foreach stub in lsat happy incsat {

	// Corrlate
	pwcorr `stub'sd gini2005 ppp05log, sig
	pwcorr `stub'corr gini2005 ppp05log, sig

	// Figures
	graph twoway 						///
	  || lowess `stub'sd gini2005, lcolor(black)  /// 
	  || scatter `stub'sd gini2005 		///
	  , jitter(2) ms(o) 				/// 
	  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall) ///
	  || , ///
	  xtitle("")  /// 
	  ytitle("Gross standard deviation")  /// 
	  legend(off)  xsize(4.5) ysize(4.5)  ///
	  name(`stub'1, replace) nodraw

	graph twoway 						///
	  || lowess `stub'corr gini2005, lcolor(black)  /// 
	  || scatter `stub'corr gini2005 		///
	  , jitter(2) ms(o) 				/// 
	  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall) ///
	  || ,  ///
	  xtitle("")  /// 
	  ytitle("IEFF-corrected standard deviation")  /// 
	  legend(off)  xsize(4.5) ysize(4.5)  ///
	  name(`stub'2, replace) nodraw

	graph combine `stub'1 `stub'2 		/// 
	  , rows(1) b1title(Income inequality (Gini), size(small))	///
	  ycommon title("``stub'title'") 			/// 
	  note("Data: WVS5ab; Do-file: anwvsieff.do", span) ///
	  saving(anwvsieff_`stub'bygini, replace)
	graph export "anwvsieff_`stub'bygini.eps", replace

	eststo clear
	eststo: regress `stub'sd gini2005 ppp05log 
	eststo: regress `stub'corr gini2005 ppp05log 
	esttab using "anwvsieff_`stub'reg1" ///
	  , replace rtf r2 
}

log close
exit



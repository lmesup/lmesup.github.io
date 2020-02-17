// Standard deviation/Diveded by maximum SD
// kohler@wzb.eu,


version 11
clear
set more off
capture log close
set graph off
log using anwvsmaxsd, replace


// Work with data
// --------------

use v2a v10 v22 v68 using wvs5ab.dta

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
drop v2a


// MEAN, SD, and MAX(SD)
// --------------------

collapse 				 	 /// 
  (mean) lsatbar=lsat (sd) lsatsd=lsat 	/// 
  , by(iso2)

gen maxsd = sqrt((1-lsatbar)*(lsatbar-10)) // Kalmijn/Veenhoven 2005: 372
gen lsatcorr = lsatsd/maxsd

// Rank change plots
// -----------------

egen ctrname = iso3166(iso2), o(codes)
replace ctrname = subinstr(ctrname,"Of","of",.)

spearman lsatsd lsatcorr, stats(obs p) pw
egen lsatrank = rank(lsatsd)
egen lsatrankcorr = rank(lsatcorr)
generate lsatchg = lsatrank - lsatrankcorr

graph dot (asis) lsatchg, over(ctrname, sort(lsatchg)) ///
  title("Rank change by IEFF{superscript:A} correction") 					///
  subtitle("- = more unequal, + = more equal") ///
  note("Data: WVS5ab; Do-file: anwvsmaxsd.do", span) ///
  xsize(3) ysize(8) yline(0) 		/// 
  saving(anwvsmaxsd_lsatrankchg, replace)
graph export anwvsmaxsd_lsatrankchg.eps, replace


// Standard deviation by mean plots
// --------------------------------

local lsattitle "Life satisfaction"

graph twoway 						 /// 
  || lowess lsatsd lsatbar, lcolor(black)  ///
  || scatter lsatsd lsatbar 	///
  , mcolor(black) ms(o) 			/// 
  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall)  ///
  || , title("`lsattitle'") ///
  ytitle("Gross standard deviation") ///
  xtitle("Mean") ///
  note("Data: WVS5ab; Do-file: anwvsmaxsd.do", span) ///
  xsize(4.5) ysize(4.5) legend(off)  /// 
  saving(anwvsmaxsd_lsatsdbymean, replace)
graph export "anwvsmaxsd_lsatsdbymean.eps", replace


graph twoway 						 /// 
  || lowess lsatcorr lsatbar, lcolor(black)  ///
  || scatter lsatcorr lsatbar 	///
  , mcolor(black) ms(o) 			/// 
  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall)  ///
  || , title("`lsattitle'") ///
  ytitle("IEFF{superscript:A} corrected standard deviation") ///
  xtitle("Mean") ///
  note("Data: WVS5ab; Do-file: anwvsmaxsd.do", span) ///
  xsize(4.5) ysize(4.5) legend(off)  ///
  saving(anwvsmaxsd_lsatcorrbymean, replace)
graph export "anwvsmaxsd_lsatcorrbymean.eps", replace


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

tempfile x
save `x'
restore

// Merge
merge n:1 iso2 using `x', keep(3) nogen  /// 
  keepusing(gini2005 pop2005 gdp2000 gdp2005 ppp2005 wregion)

// Take logs
generate poplog = log(pop2005)
generate gdp00log = log(gdp2000)
generate gdp05log = log(gdp2005)
generate ppp05log = log(ppp2005)

// Corrlate
pwcorr lsatsd gini2005 ppp05log, sig
pwcorr lsatcorr gini2005 ppp05log, sig

// Figures
graph twoway 						///
  || lowess lsatsd gini2005, lcolor(black)  /// 
  || scatter lsatsd gini2005 		///
  , jitter(2) ms(o) 				/// 
  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall) ///
  || , ///
  xtitle("")  /// 
  ytitle("Gross standard deviation")  /// 
  legend(off)  xsize(4.5) ysize(4.5)  ///
  name(lsat1, replace) nodraw

graph twoway 						///
  || lowess lsatcorr gini2005, lcolor(black)  /// 
  || scatter lsatcorr gini2005 		///
  , jitter(2) ms(o) 				/// 
  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall) ///
  || ,  ///
  xtitle("")  /// 
  ytitle("IEFF{superscript:A} corrected standard deviation")  /// 
  legend(off)  xsize(4.5) ysize(4.5)  ///
  name(lsat2, replace) nodraw

graph combine lsat1 lsat2 		/// 
  , rows(1) b1title(Income inequality (Gini), size(small))	///
  title("`lsattitle'") 			/// 
  note("Data: WVS5ab; Do-file: anwvsmaxsd.do", span) ///
  saving(anwvsmaxsd_lsatbygini, replace)
graph export "anwvsmaxsd_lsatbygini.eps", replace

eststo clear
eststo: regress lsatsd gini2005 ppp05log 
eststo: regress lsatcorr gini2005 ppp05log 
esttab using "anwvsmaxsd_lsatreg1" ///
  , replace rtf r2 beta

log close
exit



// Standard deviation of WFS corrected using both IEFF-types
// kohler@wzb.eu,

// Based on: wvs5_inequality.do (j.delhey@jacobs-university.de)

version 11
clear
set more off
set scheme s1mono
capture log close
log using anwvsieff3, replace

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

// Standard Deviation by Country and total
// ---------------------------------------

tab iso2 [aw=v259a], sum(lsat)

// Run simulations for IEFF-B
// --------------------------

preserve
sum lsat [aw=v259a]
local lsatsigma = r(sd) 

set seed 731
simulate, reps(200): 		/// 
  satsim, obs(1000) range(1/10) sigma(`lsatsigma')
reg sd mean c.mean#c.mean
estimates store lsat


// Create IEFF corrections
// -----------------------

restore
collapse 				 	 /// 
  (mean) lsatbar=lsat  /// 
  (sd) lsatsd=lsat  ///
  (count) n = lsat   ///
  [aw=v259a] 		///
  , by(iso2)

// IEFF-A
gen maxsd 								/// 
  = sqrt((1-lsatbar)*(lsatbar-10)*(n/(n-1))) // Kalmijn/Veenhoven 2005: 372
gen lsatieffA = 1/maxsd
gen lsatcorr1 = lsatsd/maxsd

// IEFF-B
estimates restore lsat
gen lsatsdhat = _b[_cons] + _b[mean]*lsatbar + _b[c.mean#c.mean]*lsatbar^2
gen lsatieffB = `lsatsigma'/lsatsdhat
gen lsatcorr2 = lsatsd*lsatieffB

// Long Country names
egen ctrname = iso3166(iso2), o(codes)
replace ctrname = subinstr(ctrname,"Of","of",.)


// Produce Appendix-Table
// ----------------------

format %4.3f lsatsd lsatieffA lsatcorr1 lsatieffB lsatcorr2 
listtex 								/// 
  iso2 ctrname lsatsd lsatieffA lsatcorr1 lsatieffB lsatcorr2  ///
  using anwvsieff3.txt, replace rstyle(tabdelim) 


// Rank change table
// -----------------

corr lsatsd lsatcorr1 lsatcorr2
spearman lsatsd lsatcorr1, stats(obs p) pw
spearman lsatsd lsatcorr2, stats(obs p) pw

egen rank0 = rank(lsatsd)
egen rank1 = rank(lsatcorr1)
egen rank2 = rank(lsatcorr2)

gen rowname = ctrname + " (" + iso + ")"
generate rankchg1 = rank0 - rank1
generate rankchg2 = rank0 - rank2

format %2.0f rank*
sort rank0
listtex 								/// 
  rowname rank0 rank1 rank2 rankchg1 rankchg2  ///
  using anwvsieff3_rankchg.txt, replace rstyle(tabdelim) 

// Plot
generate rankchg3 = (rankchg1+rankchg2)/2
egen axis = axis(rankchg3 iso2), label(ctrname) reverse

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis rankchg1 axis rankchg2 if rankchg1 != rankchg2,  /// 
  mcolor(black) lcolor(black)              ///
  || scatter axis rankchg1, mlcolor(black) mfcolor(black) ms(O)  ///
  || , ylab(`K', valuelabel angle(0) grid gstyle(dot)) 		///
  xlab(, grid) 							///
  xsize(4) ysize(8) xline(0) 			///
  ytitle("") legend(off) 				///
  note("Negative values indicate change towards more inequality. Arrows show"  ///
  "differences between IEFF{superscript:A} and IEFF{superscript:B}, if any.", span)  ///
  saving(anwvsieff3_rankchg, replace)
graph export anwvsieff3_rankchg.eps, replace


// Parallel coordinates plot of ranks
preserve
keep iso ctrname rank* 
reshape long rank, i(iso) j(typ)

gen dummy = typ>0
bysort iso2 (typ): gen rankvar = rank[_N] if dummy

twoway 									///
  || pcarrow rank dummy rankvar dummy if typ==1  & rankvar != rank /// 
  || line rank dummy if inlist(typ,0,1), c(L) lcolor(black) lwidth(*1.1) 		///
  || scatter rank dummy if typ==0, mlab(ctrname) mlabpos(9) ms(i) mlabsize(*1.0) /// 
  || scatter rank dummy if typ==1, mlab(iso) mlabpos(3) mlabsize(*1.0) ms(i)  /// 
  || , ysize(9) xsize(6) 				///
  yscale(off reverse range(1 57)) plotregion(lstyle(none))  ///
  legend(off)  ylab(minmax)							///
  xlabel(0 `""Raw" "Std. Dev.""' 1 `""Corrected" "Std. Dev.""', noticks labsize(*1.0))  ///
  xscale(lstyle(none) range(-0.6 1.1)) xtitle("") 		///
  note( 								///
  "Countries ordered by level of happiness inequality. Double headed arrows"  ///
  "indicate differences between methods of correction", span)  ///
  saving(anwvsieff3_rankparcoord, replace)
graph export anwvsieff3_rankparcoord.eps, replace

restore


// By mean plots
// -------------

ren lsatsd lsatcorr0
keep iso2 lsatbar lsatsd lsatcorr* ctrname
reshape long lsatcorr, i(iso2) j(typ)
label value typ typ
label define typ 						/// 
  0 "Std. Dev." 						/// 
  1 "Std. Dev. {&lowast} IEFF{superscript:A}"  /// 
  2 "Std. Dev. {&lowast} IEFF{superscript:B}"

graph twoway 						 /// 
  || lowess lsatcorr lsatbar, lcolor(black)  ///
  || scatter lsatcorr lsatbar 			///
    , mcolor(black) ms(O) 			/// 
  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall)   ///
  || , 									/// 
  ytitle("Inequality of life satisfaction") ///
  xtitle("Mean life satisfaction") ///
  by(typ, yrescale rows(3) legend(off) note("")) ///
  ysize(9) xsize(6) 				///
  saving(anwvsieff3_corrbymean, replace)

graph export "anwvsieff3_corrbymean.eps", replace

// By Income inequality plots
// --------------------------

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

tempfile x1
save `x1'
restore

// Merge
merge n:1 iso2 using `x1', keep(3) nogen  /// 
  keepusing(gini2005 ppp2005)

// Take logs
generate ppp05log = log(ppp2005)

label variable ppp2005 "Wealth (p/c)"
label variable gini2005 "Income inequality"

by typ, sort: corr lsatcorr ppp2005 gini2005


// Figure
graph twoway 						///
  || lowess lsatcorr gini2005, lcolor(black)  /// 
  || scatter lsatcorr gini2005 		///
  , jitter(2) ms(O) mcolor(black) 				/// 
  mlab(iso2) mlabpos(12) mlabcolor(black) mlabsize(vsmall) ///
  || ,  ///
  by(typ, yrescale legend(off) note("") rows(3))  ///
  ytitle("Inequality of life satisfaction") ///
  xtitle("Income inequality (Gini 2005)")  ///
  ysize(9) xsize(6) 				///
  saving(anwvsieff3_corrbygini, replace)
graph export "anwvsieff3_corrbygini.eps", replace
	
eststo clear
eststo: regress lsatcorr gini2005 ppp05log if typ==0
eststo: regress lsatcorr gini2005 ppp05log if typ==1
eststo: regress lsatcorr gini2005 ppp05log if typ==2

label variable ppp05log "Log GDP per capita (in PPP)" 
label variable gini2005 "Income inequality (Gini)" 

esttab using "anwvsieff3_regression" ///
  , replace rtf r2 beta nonumbers mtitles("Std. Dev." "IEFF-A" "IEFF-B")  ///
  label


// Other correlations
// ------------------

preserve

// Quality of Governance Data
use ~/data/qog/QoG_t_s_v27May10.dta, clear

keep ccode year 						/// 
  ea_gesw wbgi_vae  /// 
  wbgi_pse wbgi_gee wbgi_rqe wbgi_rle wbgi_cce 	/// 
  hf_efiscore fi_index fi_sog wvs_gen 

// Last available bit

gen missing = 0
foreach var of varlist ea_gesw wbgi_vae  /// 
  wbgi_pse wbgi_gee wbgi_rqe wbgi_rle wbgi_cce 	/// 
  hf_efiscore fi_index fi_sog wvs_gen {

	replace missing = `var'==.
	bysort missing ccode (year): 						///
	  gen `var'last = `var'[_N] if `var'!=.
	by missing ccode (year): 						///
	  gen `var'year= year[_N] if `var'!=.
	by ccode (missing), sort: replace `var'last = `var'last[1] if `var'==.
	by ccode (missing), sort: replace `var'year = `var'year[1] if `var'==.
}

by ccode, sort: keep if _n==1
keep ccode year *last *year

label variable ea_geswlast "Social security (% GDP) "
label variable wbgi_vaelast "Voice and accountability" 
label variable wbgi_pselast "Political Stability"
label variable wbgi_geelast "Gov effectiveness" 
label variable wbgi_rqelast "Regulatory Quality" 
label variable wbgi_rlelast "Rule of Law" 
label variable wbgi_ccelast "Control of Corruption"
label variable hf_efiscorelast "Economic Freedom (Heritage)"
label variable fi_indexlast "Economic Freedom (Fraser)"
label variable fi_soglast "Size of government"
label variable wvs_genlast "Gender Equality Scale"

kountry ccode, from(iso3n) to(iso2c)
ren _ISO2C_ iso2
drop if iso2 ==""
compress

tempfile x2
save `x2'

restore
merge m:1 iso2 using `x2', keep(1 3)

tempname r
tempfile corrs
postfile `r' str30 var r0 r1 r2 using `corrs'
foreach var of varlist 					/// 
  gini2005 ppp2005 ea_geswl wbgi_vael  /// 
  wbgi_psel wbgi_geel wbgi_rqel wbgi_rlel wbgi_ccel 	/// 
  hf_efiscorel fi_indexl fi_sogl wvs_genl {

	corr lsatcorr `var' if typ==0
	local r0 = r(rho)
	corr lsatcorr `var' if typ==1
	local r1 = r(rho)
	corr lsatcorr `var' if typ==2
	local r2 = r(rho)

	post `r' ("`:variable label `var''") (`r0') (`r1') (`r2')
}

postclose `r'

use `corrs', clear

egen axis = axis(r0), label(var) reverse

graph twoway 							///
  || scatter axis r0, mcolor(black) 					///
  || rcap r1 r2 axis, horizontal lcolor(black) 		///
  || , ylabel(1(1)13, valuelabel angle(0) grid gstyle(dot) )  ///
  legend(order(1 "Std. Dev." 2 "Std. Dev. {&lowast} IEFF{superscript:A,B}"))  ///
  ytitle("") xtitle(Correlation with inequality of life satisfaction)  ///
  xline(0) xlabel(-.75(.25).75)
graph export "anwvsieff3_corrbyaggregates.eps", replace


log close
exit



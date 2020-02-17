version 9.1
set more off
capture log close
log using anagg, replace
eststo clear

// Add Corruption Index
use iso3166 cpi using ~/data/agg/cpi04, clear
ren iso3166 cntry
sort cntry
tempfile cpi
save `cpi'

use ess04
merge cntry using `cpi', nokeep
label var cpi "Corruption"
assert _merge==3
drop _merge

// Election system dummies
gen majority = inlist(cntry,"GB","FR")
label variable majority "Majority system"
gen compulsory = inlist(cntry,"BE","IT","LU","BE") // | inlist(cntry,"AT","NL")
label variable compulsory "Compulsory elections"
gen workday = inlist(cntry,"IE","GB", "NL", "NO")
label variable workday "Elections on rest days"
gen fc = inlist(cntry,"CZ","EE","PL","SI","HU") | inlist(cntry,"SK")
label variable fc "Communist legacy"


// Centering
foreach var of varlist govsat democsat trst* cpi {
   sum `var'
   gen c`var' = (`var'-r(mean))/r(sd)
   label variable c`var' "`:var lab `var'' (standardized)"
}

// Aggregate level Variables one by one
foreach var of varlist compulsory workday ccpi fc {
  logit voter `var' [pw=nweight], vce(cluster cntry)
  mfx, at(zero)
  eststo
}


// Aggregate level Variables all together
logit voter compulsory workday ccpi fc [pw=nweight], vce(cluster cntry)
mfx, at(zero)
eststo


esttab using anagg, ///
  rtf replace title("Version from `=c(current_date)' `=c(current_time)'")  ///
  label margin pr2 obslast  b(%3.2f) t(%3.1f) ///
  compress nodepvar nogaps 

log close
exit




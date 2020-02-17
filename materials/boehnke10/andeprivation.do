version 9
	set more off
	set scheme s1mono
capture log close
log using andeprivation, replace
	

// EQLS 2003
// ---------
	
use ///
  using $dublin/eqls_4, clear

label define s_cntry 11 "United Kingdom", modify
egen iso3166 = iso3166(s_cntry)

// Live-Satisfaction
// ----------------
ren q31 lsat

// Income
ren hhincqu2 inc
label define hhincqu2 ///
 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile"  4 "4th quartile", modify
tab inc, gen(inc)

// Deprivation
egen deprivmis = rmiss(q20_? q21?)
egen deprivation = anycount(q20_? q21?) if deprivmis == 0, v(2)
gen deprived = deprivation < 3 if !mi(deprivation)


* Initialize Postfile
* -------------------

tempfile dep
postfile coef  str2 iso3166 str15 domain coef r2 using `dep'

* OLS Regressions by country 
* --------------------------

levelsof iso3166, local(K)
foreach k of local K {

	// Relative
	reg lsat ///
	  inc2 inc3 inc4  ///
	  if iso3166=="`k'"
     post coef  ("`k'") ("Relative")  (_b[inc4]) (e(r2))

	// Absolute
	reg lsat deprived  ///
	  if iso3166=="`k'"
     post coef  ("`k'") ("Absolute")  (_b[deprived]) (e(r2))
}
postclose coef


* Write out Aggregate-Data
* -------------------------

keep iso3166 gdppcap1 
by iso3166, sort: keep if _n==1
tempfile gdp
save `gdp'

* Unify Coefficient and GDP Data 
* -------------------------------

use `dep'
sort iso3166
merge iso3166 using `gdp'
assert _merge == 3
drop _merge


lab def domain_r ///
  1 "Relative" 2 "Absolute" ///
  , modify

encode domain, gen(domain_r) label(domain_r)


* Graph
* -----

set scheme s1mono

* Most Countries
graph twoway ///
  || scatter coef gdppcap, ms(O) mfcolor(white) mlcolor(black) ///
  || lowess coef gdppcap, clstyle(p1) clwidth(*1.5) ///
  || if iso3166 ~= "LU" ///
  , by(domain_r, legend(off) note("")) xtitle("GDP per capita in pps") ///
    ytitle(Difference in life satisfaction) 

graph export andeprivation.eps, replace preview(on)

log close
exit


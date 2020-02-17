* Dimensions of satisfaction on overall satisfaction with life

* History
* anlsatdim.do and crlsatdim.do by Mischke@wz-berlin.de
* anlsatdim1.do with Eurobarometer for ChangeQual Meeting in Paris, 2004
* anlsatdim2.do rewrote for EQLS data

* Intro
* ------

version 9
clear
set more off
	capture log close
	set scheme s1mono
log using anlsatdim2, replace


	// Intro
	// -----

	capture program drop mydummies
program mydummies
version 9
	syntax varlist
	foreach var of local varlist {
		quietly levelsof `var', local(K)
		foreach k of local K {
			gen `var'`k':yesno = `var'==`k' if !mi(`var')
			label var `var'`k' "`:label (`var') `k''"
		}
	}
end


* Data
* ----

use $dublin/eqls_4.dta
label define s_cntry 11 "United Kingdom", modify
egen iso3166 = iso3166(s_cntry)

* Rename dimensions of satisfaction
* ---------------------------------

rename q31 slife
rename q41a sat2
rename q41c sat3
rename q41d sat4
rename q41e sat5
rename q41f sat1
rename q41g sat6 

* Recode Control-Variables
* -------------------------

// Income
ren hhincqu2 inc
label define hhincqu2 ///
 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile"  4 "4th quartile", modify
	
// Employment-Status
gen emp:emp = emplstat
replace emp = 5 if emplstat >= 5  | teacat == 4  // "Missing" + "Other" + "Still Studying"
label def emp ///
 1 "Employed" 2 "Homemaker" 3 "Unemployed" 4 "Retired" 5 "Still in education/other"

// Education
gen edu:edu = teacat
replace edu = 4 if edu >= . // "Missing" + "Still Studying" = "Other"
label define edu 1 "Low" 2 "Intermediate" 3 "High" 4 "Other"

// Gender
gen men:yesno = hh2a==1 if hh2a < .
lab var men "Men"
drop hh2a

// Age
sum hh2b, meanonly
gen age = hh2b-r(mean)
lab var age "Age"
gen age2 = age^2
lab var age2 "Age (squared)"
drop hh2b

// Sociability: Marital-Status
ren q32 mar
label def q32 ///
 1 "Married/living together" 2 "Separated/divorced" 3 "Widowed" 4 "Single, never married", modify

// Dummies
mydummies inc emp edu mar

// Listwise Deletion
// ----------------

mark touse
markout touse ///
slife sat* inc mar age age2 edu men emp
keep if touse


* Initialize Postfile
* -------------------

tempfile lsatdim
postfile coef  str2 iso3166 str15 domain coef r2 using `lsatdim'

* OLS Regressions by country 
* --------------------------

levelsof iso3166, local(K)
foreach k of local K {
  foreach var of varlist sat* {
    reg slife `var' men age age2 inc2-inc4 emp2-emp5 mar2-mar4 edu2-edu4 ///
      if iso3166 == "`k'" 
    post coef  ("`k'") ("`var'")  (_b[`var']) (e(r2))
  }
}
postclose coef


* Random Intercept models to check for significance
* -------------------------------------------------

encode iso3166, gen(i)
gen ia = .
foreach var of varlist sat* {
  gen ia`var' = `var' * gdppcap1
  xtreg slife `var' ia`var' men age age2 inc2-inc4 emp2-emp5 mar2-mar4 edu2-edu4 ///
    gdppcap1, i(i)
}


* Write out Aggregate-Data
* -------------------------

keep iso3166 gdppcap1 
by iso3166, sort: keep if _n==1
tempfile gdp
save `gdp'

* Unify Coefficient and GDP Data 
* -------------------------------

use `lsatdim'
sort iso3166
merge iso3166 using `gdp'
assert _merge == 3
drop _merge

encode domain, gen(domain_r)
lab def domain_r ///
  1 "Health" 2 "Education"  3 "Stand. of living" 4 "Accomodation" ///
  5 "Family" 6 "Social life" ///
  , modify


* Graph
* -----

set scheme s1mono

* Most Countries
graph twoway ///
  || scatter coef gdppcap, ms(O) mfcolor(white) mlcolor(black) ///
  || lowess coef gdppcap, clstyle(p1) clwidth(*1.5) ///
  || if iso3166 ~= "LU" ///
  , by(domain_r, legend(off) note("")) xtitle("GDP per capita in pps") ///
    ytitle(Regression coefficient)

graph export anlsatdim2.eps, replace preview(on)

log close
exit


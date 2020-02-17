* Interactions of capabilities with GDP

version 9
	set more off
	capture log close
	log using ancap, replace
	
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
	
	// EQLS 2003
	// ---------
	
	use ///
	  using $dublin/eqls_4, clear
  label define s_cntry 11 "United Kingdom", modify
  egen iso3166 = iso3166(s_cntry)

	// Live-Satisfaction
	// ----------------
	ren q31 lsat

	// Employment-Status
	gen emp:emp = emplstat
	replace emp = 5 if emplstat >= 5  | teacat == 4  // "Missing" + "Other" + "Still Studying"
	label def emp 1 "Employed" 2 "Homemaker" 3 "Unemployed" 4 "Retired" 5 "Still in education/other"
	
	// Education
	gen edu:edu = teacat
	replace edu = 4 if edu >= . // "Missing" + "Still Studying" = "Other"
	label define edu 1 "Low" 2 "Intermediate" 3 "High" 4 "Other"

   // Income
	ren hhincqu2 inc
	label define hhincqu2 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile"  4 "4th quartile", modify
	
   // Family
	ren q32 mar
	label def q32 1 "Married/living together" 2 "Separated/divorced" 3 "Widowed" 4 "Single, never married", modify

	// Sociability: Contact with friends/neigbours at least once a weak
	gen contacts:yesno = q34c <= 3 if !mi(q34c)
	lab var contacts "Yes"
	drop q34c

	// Age
	sum hh2b, meanonly
	gen age = hh2b-r(mean)
	lab var age "Age"
	gen age2 = age^2
	lab var age2 "Age (squared)"
	drop hh2b

	// Gender
	gen men:yesno = hh2a==1 if hh2a < .
	lab var men "Men"
	drop hh2a
	
	// Dummies

	mydummies inc emp edu mar 

   // Capability 1 ???

   egen mis2 = rmiss(q29?)
   egen cap2 = rsum(q54?) if !mis2 // Public services

   gen cap3 = q28 // Trust in people

   egen mis4 = rmiss(q29?)
   egen cap4 = rsum(q29?) if !mis4
   *sum cap4
   *replace cap4 = r(max)-cap4  // Perceive Tensions



	// Listwise Deletion
	// ----------------

	mark touse
	markout touse ///
	  lsat inc emp edu mar men age contacts 
	keep if touse


* Initialize Postfile
* -------------------

tempfile cap
postfile coef  str2 iso3166 str15 domain coef r2 using `cap'

* OLS Regressions by country 
* --------------------------


levelsof iso3166, local(K)
foreach var of varlist cap* {
  foreach k of local K {
  reg lsat `var' ///
	  men age age2 ///
	  inc2-inc4 emp1 emp2 emp4 emp5 edu2-edu4 ///
	  if iso3166=="`k'"
     post coef  ("`k'") ("`var'")  (_b[`var']) (e(r2))
  }
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

use `cap'
sort iso3166
merge iso3166 using `gdp'
assert _merge == 3
drop _merge


encode domain, gen(domain_r) 


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

graph export ancap.eps, replace preview(on)

log close
exit


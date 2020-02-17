* Interactions of inequalities with GDP
* EQLS 2003 and ISSP 2002

version 9
	set more off
	set scheme s1mono
	capture log close
	log using anlsatdim3, replace
	
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

	// Vertical Inequalities
	// ----------------------

	// Health/Personality
	gen illness:yesno = q44!=1 if !mi(q44)

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
	
	gen hqual = (q19_2==1) + (q19_3==1) + (q19_4==1) if !mi(q19_2,q19_3,q19_4)
	label variable hqual "Accommodation"
	drop q19*
	
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

	mydummies inc emp edu mar hqual

	// Listwise Deletion
	// ----------------

	mark touse
	markout touse ///
	  lsat inc emp edu mar men age ///
	  hqual contacts health 
	keep if touse



* Initialize Postfile
* -------------------

tempfile lsatdim
postfile coef  str2 iso3166 str15 domain coef r2 using `lsatdim'

* OLS Regressions by country 
* --------------------------

levelsof iso3166, local(K)
foreach k of local K {


	// Old-Inequalities
	reg lsat ///
	  men age age2 ///
	  inc2-inc4 emp1 emp2 emp4 emp5 edu2-edu4 ///
	  if iso3166=="`k'"
     post coef  ("`k'") ("Income")  (_b[inc4]) (e(r2))
     post coef  ("`k'") ("Unemployment")  (_b[emp1]) (e(r2))
     post coef  ("`k'") ("Education")  (_b[edu3]) (e(r2))

	// Housing
	reg lsat ///
	  men age age2  ///
	  inc2-inc4 emp2-emp5 edu2-edu4 ///
	  hqual0 hqual1 hqual3 ///
	  if iso3166=="`k'"
   post coef  ("`k'") ("Accommodation") (_b[hqual0]) (e(r2))

	// Family
	reg lsat  ///
	  men age age2 ///
	  inc2-inc4 emp2-emp5 edu2-edu4 ///
 	  mar1 ///
	  if iso3166=="`k'"
   post coef  ("`k'") ("Married") (_b[mar1]) (e(r2))

   // Contacts
	reg lsat  ///
	  men age age2 ///
	  inc2-inc4 emp2-emp5  edu2-edu4 ///
 	  mar2-mar4 contacts  ///
	  if iso3166=="`k'"
   post coef  ("`k'") ("Contacts") (_b[contacts]) (e(r2))


}
postclose coef

// Random Intercept Models
// -----------------------

encode iso3166, gen(i)
iis i

foreach var of varlist ///
 inc2-inc4 emp1 emp2 emp4 emp5 edu2-edu4 ///
 hqual0 hqual1 hqual3 ///
 mar ///
 contacts {
 gen `var'gdp = `var' * gdppcap1
}


// Old-Inequalities
xtreg lsat ///
  men age age2 ///
  inc2* inc3* inc4* emp1* emp2* emp4* emp5* edu2* edu3* edu4* ///
  if iso3166 != "LU"

// Housing
xtreg lsat ///
  men age age2  ///
  inc2-inc4 emp2-emp5 edu2-edu4 ///
  hqual0* hqual1* hqual3* if iso3166 != "LU"

// Family
xtreg lsat  ///
  men age age2 ///
  inc2-inc4 emp2-emp5 edu2-edu4 ///
  mar1* if iso3166 != "LU"

 // Contacts
xtreg lsat  ///
  men age age2 ///
  inc2-inc4 emp2-emp5  edu2-edu4 ///
  mar2-mar4 contacts* if iso3166 != "LU"



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


lab def domain_r ///
  1 "Unemployment" 2 "Education" 3 "Income" 4 "Accommodation" ///
  5 "Married" 6 "Contacts" ///
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
    ytitle(Regression coefficient) 

graph export anlsatdim3.eps, replace preview(on)

log close
exit




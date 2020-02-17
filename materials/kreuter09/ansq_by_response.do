// SQ Descriptions by Respondent y/n, contactability, and substantial vars
// kohler@wzb.eu

version 9.2
set scheme s1mono
use ctrcase cntry idno visit result using ESScontact, clear

// Clean Data
// ----------

// No result information very common in NO, LU, and CZ
drop if inlist(cntry,"NO","LU","CZ")

// We drop the remaining sequences with no "result information"
by ctrcase (visit), sort: gen x  = sum(result==8)
by ctrcase (visit): drop if x > 0

// Visit - Variable have gaps in FI, CH and IL
// We drop these sequences
by ctrcase (visit): replace x = visit -1 != visit[_n-1] if _n > 1
by ctrcase (visit): replace x = sum(x)
by ctrcase (visit): replace x = x[_N]
drop if x
drop x

// Now sqset
sqset result ctrcase visit

// Generate descriptive statistics
// -------------------------------

egen sqlength = sqlength()
egen sqlength2= sqlength(), e(2) // <- Contact with R, no interview 
egen sqlength3= sqlength(), e(3) // <- Contact with someone else
egen sqlength4= sqlength(), e(4) // <- No contact at all

egen sqlength5= sqlength(), e(5) // <- Address not valid
gen  invalrevisit = sqlength5 >= 2 if !mi(sqlength5)
drop sqlength5

egen sqelemcount = sqelemcount()
egen sqepicount = sqepicount()

egen firstpos1 = sqfirstpos(), pattern(2 1)
replace firstpos1 = firstpos1 > 0 if !mi(firstpos1)

egen firstpos2 = sqfirstpos(), pattern(3 1)
replace firstpos2 = firstpos2 > 0 if !mi(firstpos2)

egen firstpos3 = sqfirstpos(), pattern(4 3 1)
replace firstpos3 = firstpos3 > 0 if !mi(firstpos3)



// Add Respondent Data
// -------------------

by cntry idno, sort: keep if _n==1
sort cntry idno

preserve
use ESSdata if survey == "ESS 1", clear
tempfile using
sort cntry idno
save `using'
restore

merge cntry idno using `using', nokeep sort

// Correlate with respondent y/n
// -----------------------------

gen respondent:yeso = _merge == 3
drop _merge

separate sqlength, by(respondent)
graph dot sqlength0 sqlength1, over(cntry)

separate sqelemcount, by(respondent)
graph dot sqelemcount0 sqelemcount1, over(cntry)

// Correlate with othr indicators for contactability
// -------------------------------------------------

table cntry athome, c(mean sqlength mean sqelemcount)
by cntry, sort: corr sqlength sqelemcount tvtot


// Correlate with substantial variables
// ------------------------------------

gen married = marital == 1 if !mi(marital)
by cntry, sort:  ///
  corr sqlength sqelemcount women age hhmmb marital hinc  ///
  polintr ppltrst lrscale stflife


exit
-----------

gen married = marital == 1 if !mi(marital)
by cntry, sort:  ///
  corr sqlength sqelemcount women age hhmmb marital hinc  ///
  polintr ppltrst lrscale stflife


exit

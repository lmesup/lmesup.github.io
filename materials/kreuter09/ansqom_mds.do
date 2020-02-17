// Optimal matching of result sequences and MDS
// kohler@wzb.eu

	
version 10
clear
set more off
set memory 90m
set scheme s1mono
set matsize 5000
capture log close

use survey cntry idno visit result* using ESScontactbig, clear

// Clean Sequence data
// -------------------

// Harmonize contact results of ESS 1 and ESS 2
gen result:result = 9
replace result = 1 if result1 == 1 | inlist(result2,1,2)
replace result = 2 if result1 == 2 | result2== 4
replace result = 3 if result1 == 3 | inlist(result2,3,5)
replace result = 4 if result1 == 4 | result2 == 6
replace result = 9 if result1 == 9 | result2 == 9
lab define result 1 "Interview" 2 "Contact with resp"  ///
  3 "Contact with someone" 4 "No contact"
drop result1 result2

// We drop all sequences with no "result information"
bysort survey cntry idno (visit): gen x  = sum(result==9)
by survey cntry idno (visit): drop if x > 0

// Visit - Variable have gaps in several countries
// We drop these sequences
by survey cntry idno (visit): replace x = visit -1 != visit[_n-1] if _n > 1
by survey cntry idno (visit): replace x = sum(x)
by survey cntry idno (visit): replace x = x[_N]
drop if x
drop x

// Remove last contact attempt
bysort survey cntry idno (visit): drop if _n==_N

// Length 5 and above
by survey cntry idno (visit): keep if _N>4       

// Declare sequence data
gen str1 ctrcase = ""
replace ctrcase = survey + " " + cntry + " " + string(idno,"%12.0f")
sqset result ctrcase visit

// Now sqset
sqset result ctrcase visit

// sqom
// ----

sqom, full

// MDS
// ---

mdsmat SQdist
predict dim, saving(mds)
copy /home/ado/sq/sqmdsadd.ado sqmdsadd.ado, replace  // Pre-alpha of sqmdsadd
sqmdsadd using mds



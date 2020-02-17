// Try Optimal Matching with detailed Outcome variable
// Authors: kohler@wzb.eu


version 10
clear
set memory 90m
set scheme s1mono

// Data
// ----

use survey cntry idno visit result* etime using ESScontactbig, clear


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

// Drop last visit, length 5 and higher!
bysort survey cntry idno (visit): drop if _n==_N
by survey cntry idno (visit): keep if _N>4

// Detailed result
gen whrs = !(inlist(dow(dofc(etime)),0,6) | hh(etime) >= 19)
gen dresult = 1 if result == 1 & whrs == 0
replace dresult = 2 if result == 1 & whrs == 1
replace dresult = 3 if result == 2 & whrs == 0
replace dresult = 4 if result == 2 & whrs == 1
replace dresult = 5 if result == 3 & whrs == 0
replace dresult = 6 if result == 3 & whrs == 1
replace dresult = 7 if result == 4 & whrs == 0
replace dresult = 8 if result == 4 & whrs == 1
replace dresult = 9 if result == 9

// Now sqset
gen str1 ctrcase = ""
replace ctrcase = survey + " " + cntry + " " + string(idno,"%12.0f")
sqset dresult ctrcase visit, ltrim

// Remaining interviews
egen x1 = sqlength(), elem(1)
egen x2 = sqlength(), elem(2)
drop if x1 | x2
drop x1 x2

// SQOM
sqom if cntry=="DE", full 
sqclusterdat
clustermat singlelinkage SQdist, name(test) add
clustermat stop, variables(test*)
cluster generate groups = groups(3), name(test)
sqclusterdat, return keep(test* groups)

exit

Thats all sensless...


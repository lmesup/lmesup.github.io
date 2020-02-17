// Optimal matching by respondent y/n, contactability, and substantial vars
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


// We only use sequences of length 6 and above
by ctrcase (visit): drop if visit[_N] <= 5

// Now sqset
sqset result ctrcase visit

// Optimal Matching
// ----------------

sqom, full

// Cluster Analysis
// ----------------

sqclusterdat
clustermat singlelinkage SQdist, add name(single)
clustermat stop single, variables(single*)
cluster generate single = groups(2/6) , ties(skip)
sqclusterdat, return

gen group = 1 if inrange(single_hgt,0,.1)
replace group = 2 if inrange(single_hgt,.1,.16)
replace group = 3 if inrange(single_hgt,.16,.22)


// File Dump
// ---------

save ansqom_by_response, replace


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

tab group respondent, row
tab cntry group, sum(respondent) nostandard


// Correlate with othr indicators for contactability
// -------------------------------------------------

table cntry group, c(mean athome)
table cntry group, c(mean tvtot)


// Correlate with substantial variables
// ------------------------------------

gen married = marital == 1 if !mi(marital)
table cntry group, c(mean women mean age mean hhmmb mean marital mean hinc)
table cntry group, c(mean  polintr mean ppltrst mean lrscale mean stflife)

exit

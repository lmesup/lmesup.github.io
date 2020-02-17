// Optimal matching of result sequences
// kohler@wzb.eu

	
version 10
set scheme s1mono


version 10
clear
set memory 90m
set scheme s1mono
capture log close
log using anseqdes2, replace

use survey cntry idno visit result* using ESScontactbig, clear


// Clean Data
// ----------
// (from ansqdes2.do)

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


// Now Sqset
// ---------

bysort survey cntry idno (visit): drop if _n==_N // <- Remove last contact attempt
by survey cntry idno (visit): keep if _N>4       // <- Length 5 and above

// Now sqset
gen str1 ctrcase = ""
replace ctrcase = survey + " " + cntry + " " + string(idno,"%12.0f")
sqset result ctrcase visit, ltrim

sqset result ctrcase visit


// sqom
// ----

sqom, full k(1)  // Not more than on indel in sequence


// Cluster Analysis
// ----------------

sqclusterdat
clustermat singlelinkage SQdist, add name(single)
clustermat stop single, variables(single*) rule(calinski) groups(2/5)
clustermat stop single, variables(single*) rule(duda) groups(1/5)
cluster generate single3 = groups(4), ties(more) 

sqclusterdat, return 



// Analyze cluster solution by country
// ------------------------------------

preserve
by ctrcase, sort: keep if _n==1

tw ///
  || kdensity wards_hgt, lcolor(black) lpattern(solid) xaxis(1) yaxis(1) ///
  || kdensity single_hgt, lcolor(black) lpattern(dash) xaxis(2) yaxis(2) ///
  , legend(order(1 "Wards linkage" 2 "Single linkage"))  ///
  xtitle("Dissimilarity measure from wards linkage", axis(1)) ///
  xtitle("Dissimilarity measure from single linkage", axis(2)) ///
  xtick(0(10)150, axis(1)) xtick(0(.02).4, axis(2))
graph export ansqom1_cluster.eps, replace

gen group = 1 if inrange(single_hgt,0,.1)
replace group = 2 if inrange(single_hgt,.1,.16)
replace group = 3 if inrange(single_hgt,.16,.22)

keep ctrcase group
sort ctrcase
tempfile x
save `x'
restore
sort ctrcase
merge ctrcase using `x'
drop _merge

	by group ctrcase, sort: gen newx = _n==1
	by group, sort: replace newx = sum(newx)

	replace ctrcase = string(newx)
	
	sqindexplot ///
	  , by(group, yrescale title(Indexplots by sequence clusters) col(3)) ///
	  scheme(s2color) legend(rows(1))
	graph export ansqom1_indexplot.eps, replace
	tab cntry group, row

  
	exit
	
	

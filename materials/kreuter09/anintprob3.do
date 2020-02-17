// Repsonse probability by Sequence 
// kohler@wzb.eu

version 10
clear
set more off
set memory 90m
set scheme s1mono
capture log close

use survey cntry idno visit result* type using ESScontact1-3, clear

// Clean Sequence data
// -------------------

// Harmonize contact results of ESS 1 and ESS 2/3
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

// Length 3 and above
by survey cntry idno (visit): keep if _N>=2

// Declare sequence data
gen str1 ctrcase = ""
replace ctrcase = survey + " " + cntry + " " + string(idno,"%12.0f")
sqset result ctrcase visit

// Generate Sequence characteristics
// ---------------------------------

egen sq1= sqlength()       // <- Overall
egen sq2= sqlength(), elem(4) // No contact at all 
egen sq3 = sqelemcount()
egen sq4 = sqepicount()
bysort ctrcase (visit): gen sq5 = 1 if inlist(result,2,3,4) & result[_n-1]==2
by ctrcase (visit): replace sq5 = sum(sq5)
by ctrcase (visit): replace sq5 = sq5[_N]

foreach var of varlist sq2-sq5 {
	gen p`var' = `var'/sq1
}


* sqom, full
* mdsmat SQdist
* predict sqdim, saving(mds)
*copy /home/ado/sq/sqmdsadd.ado sqmdsadd.ado, replace  // Pre-alpha of sqmdsadd
* sqmdsadd using mds

sort survey cntry idno
merge survey cntry idno using anseqdes4_omresults
assert _merge == 3
drop _merge

label variable sq1 "# of Contacts"
label variable psq2 "No contacts"
label variable psq3 "Diff. elements"
label variable psq4 "Episodes"
label variable psq5 "Dist. interaction"
label variable sqdim "MDS dimension 1"


// Benchmark Quantity
// ------------------

gen single = !inlist(type,5,6,7,8) if inrange(type,1,10)
lab var single "Single vs. multi"


// Add Respondent Data
// -------------------

by survey cntry idno, sort: keep if _n==1
sort survey cntry idno

preserve
use ESSdata1-3, clear
tempfile using
sort survey cntry idno
save `using'
restore

merge survey cntry idno using `using', nokeep 
gen respondent:yeso = _merge == 3
drop _merge

// Correlate with p
// ----------------

tempname r
tempfile rfile
postfile `r' str5 survey str2 cntry str20 var r n using `rfile'

levelsof survey, local(Round)
foreach round of local Round {
	levelsof cntry, local(K)
	foreach k of local K {
		foreach var of varlist sq1 psq* sqdim single {
			capture quietly corr respondent `var' if cntry == "`k'" & survey == "`round'"
			post `r' ("`round'") ("`k'") ("`:var lab `var''") (r(rho)) (r(N))
			}
		}
	}
postclose `r'

use `rfile', clear

gen t = r/sqrt((1-r^2)/(n-2))
gen sig = ttail(n,abs(t)) <= 0.05

egen axis = axis(cntry), label(cntry) reverse

label define vars 1 "# of Contacts" 2 "No contacts" 3 "Diff. elements" ///
  4 "Episodes" 5 "Dist. interaction" 6 "MDS dimension 1" 
encode var if var != "Single vs. multi", gen(varnum) label(vars)

egen benchmarkmin = min(r), by(axis var)
egen benchmarkmax = max(r), by(axis var)
by axis (var),sort: replace benchmarkmin = benchmarkmin[_N]
by axis (var): replace benchmarkmax = benchmarkmax[_N]

levelsof axis, local(ylab)
graph twoway ///
  || rbar benchmarkmin benchmarkmax axis, bcolor(gs8) horizontal  ///
  || scatter axis r if survey == "ESS 1",  ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter axis r if survey == "ESS 2",  ms(O) mlcolor(black) mfcolor(gs8)  ///
  || scatter axis r if survey == "ESS 3",  ms(O) mlcolor(black) mfcolor(black)  ///
  || , by(varnum, rows(2) note("") ) ///
  legend(order(2 "ESS 1" 3 "ESS 2" 4 "ESS 3" 1 "Benchmark") row(1)) 	/// 
  ylab(`ylab', valuelabel angle(0)) ///
  ytitle("") xlab(#5) /// 
  ysize(7) xline(0)
graph export anintprob3.eps, replace


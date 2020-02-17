// SQ Descriptions by Respondent y/n, contactability, and substantial vars
// kohler@wzb.eu

version 10
clear
set more off
set memory 90m
set scheme s1mono
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


label variable sq1 "# of Contacts"
label variable psq2 "No contacts"
label variable psq3 "Diff. elements"
label variable psq4 "Episodes"
label variable psq5 "Dist. interaction"


// Add Respondent Data
// -------------------

replace survey = "ESS 1" if survey == "ESS 2002"
replace survey = "ESS 2" if survey == "ESS 2004"

by survey cntry idno, sort: keep if _n==1
sort survey cntry idno

preserve
use ESSdata, clear
tempfile using
sort cntry idno
save `using'
restore

merge survey cntry idno using `using', nokeep sort


// Correlate with respondent y/n
// -----------------------------

gen respondent:yeso = _merge == 3
drop _merge

tempname r
tempfile rfile
postfile `r' str5 survey str2 cntry str20 var r n using `rfile'

levelsof survey, local(Round)
foreach round of local Round {
	levelsof cntry, local(K)
	foreach k of local K {
		foreach var of varlist sq1 psq* {
			corr respondent `var' if cntry == "`k'" & survey == "`round'"
			post `r' ("`round'") ("`k'") ("`:var lab `var''") (r(rho)) (r(N))
			}
		}
	}
postclose `r'

preserve
use `rfile', clear

gen t = r/sqrt((1-r^2)/(n-2))
gen sig = ttail(n,abs(t)) <= 0.05

egen mean = mean(r), by(cntry)
egen axis = axis(mean), label(cntry) reverse

label define vars 1 "# of Contacts" 2 "No contacts" 3 "Diff. elements" ///
  4 "Episodes" 5 "Dist. interaction"
encode var, gen(varnum) label(vars)

levelsof axis, local(ylab)
graph twoway ///
  || scatter axis r if sig, ms(O) mcolor(black) ///
  || scatter axis r if !sig, ms(O) mlcolor(black) mfcolor(white) ///
  || , by(varnum, rows(2) holes(3) note("") ) ///
  legend(order(1 "sig." 2 "not sig.")) ///
  ylab(`ylab', valuelabel angle(0)) ///
  ytitle("") xlab(#5) /// ///
  ysize(7) xline(0)

graph export anintprob1_1.eps, replace

restore, preserve

// Correlate with Employment y/n
// -----------------------------

tempname r
tempfile rfile
postfile `r' str5 survey str2 cntry str20 var r n using `rfile'

levelsof survey, local(Round)
foreach round of local Round {
	levelsof cntry, local(K)
	foreach k of local K {
		foreach var of varlist sq1 psq* {
			capture corr athome `var' if cntry == "`k'" & survey == "`round'" & respondent
			post `r' ("`round'") ("`k'") ("`:var lab `var''") (r(rho)) (r(N))
			}
		}
	}
postclose `r'

use `rfile', clear

gen t = r/sqrt((1-r^2)/(n-2))
gen sig = ttail(n,abs(t)) <= 0.05

egen mean = mean(r), by(cntry)
egen axis = axis(mean), label(cntry) reverse

label define vars 1 "# of Contacts" 2 "No contacts" 3 "Diff. elements" ///
  4 "Episodes" 5 "Dist. interaction"
encode var, gen(varnum) label(vars)

levelsof axis, local(ylab)
graph twoway ///
  || scatter axis r if sig, ms(O) mcolor(black) ///
  || scatter axis r if !sig, ms(O) mlcolor(black) mfcolor(white) ///
  || , by(varnum, rows(2) holes(3) note("") ) ///
  legend(order(1 "sig." 2 "not sig.")) ///
  ylab(`ylab', valuelabel angle(0)) ///
  ytitle("") xlab(#5) /// ///
  ysize(7) xline(0)

graph export anintprob1_2.eps, replace
restore, preserve

// Correlate with Employment y/n
// -----------------------------

tempname r
tempfile rfile
postfile `r' str5 survey str2 cntry str20 var r n using `rfile'

levelsof survey, local(Round)
foreach round of local Round {
	levelsof cntry, local(K)
	foreach k of local K {
		foreach var of varlist sq1 psq* {
			capture corr tvtot `var' if cntry == "`k'" & survey == "`round'" & respondent
			post `r' ("`round'") ("`k'") ("`:var lab `var''") (r(rho)) (r(N))
			}
		}
	}
postclose `r'

use `rfile', clear

gen t = r/sqrt((1-r^2)/(n-2))
gen sig = ttail(n,abs(t)) <= 0.05

egen mean = mean(r), by(cntry)
egen axis = axis(mean), label(cntry) reverse

label define vars 1 "# of Contacts" 2 "No contacts" 3 "Diff. elements" ///
  4 "Episodes" 5 "Dist. interaction"
encode var, gen(varnum) label(vars)

levelsof axis, local(ylab)
graph twoway ///
  || scatter axis r if sig, ms(O) mcolor(black) ///
  || scatter axis r if !sig, ms(O) mlcolor(black) mfcolor(white) ///
  || , by(varnum, rows(2) holes(3) note("") ) ///
  legend(order(1 "sig." 2 "not sig.")) ///
  ylab(`ylab', valuelabel angle(0)) ///
  ytitle("") xlab(#5) /// ///
  ysize(7) xline(0)

graph export anintprob1_3.eps, replace
restore


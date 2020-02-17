// SQ Descriptions by key survey variables
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

gen single = inrange(type,2,4) if inlist(type,2,3,4,6)
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

// Select specific contratst for correlations
gen married = marital==1 if !mi(marital)
gen worker = inlist(egpr,8,9,10) if !mi(egpr)

tempname r
tempfile rfile
postfile `r' str5 survey str2 cntry str20 keyvar str20 seqvar r n using `rfile'

foreach keyvar of varlist  ///
  city women age married hinc worker ppltrst polintr lrscale stflife  {
	foreach round in "ESS 1" "ESS 2" "ESS 3" {
		levelsof cntry, local(K)
		foreach k of local K {
			foreach seqvar of varlist sq1 psq* sqdim single {
				capture  ///
				  corr `keyvar' `seqvar'  ///
				  if cntry == "`k'" & survey == "`round'" & respondent
				post `r' ("`round'") ("`k'") ("`keyvar'") ("`:var lab `seqvar''") (r(rho)) (r(N))
				}
			}
		}
	}

postclose `r'
use `rfile', clear

gen t = r/sqrt((1-r^2)/(n-2))
gen sig = ttail(n,abs(t)) <= 0.05
	
egen mean = mean(r), by(cntry keyvar)

label define seqvars 1 "# of Contacts" 2 "No contacts" 3 "Diff. elements" ///
  4 "Episodes" 5 "Dist. interaction" 6 "MDS dimension 1" 
encode seqvar if seqvar != "Single vs. multi", gen(seqvarnum) label(seqvars)


egen benchmarkmin = min(r), by(cntry keyvar seqvar)
egen benchmarkmax = max(r), by(cntry keyvar seqvar)
by cntry keyvar (seqvar),sort: replace benchmarkmin = benchmarkmin[_N]
by cntry keyvar (seqvar): replace benchmarkmax = benchmarkmax[_N]

egen axis = axis(cntry), label(cntry) reverse

levelsof axis, local(ylab)
levelsof keyvar, local(K)
foreach k of local K {
	
	graph twoway ///
	  || rbar benchmarkmin benchmarkmax axis, bcolor(gs8) horizontal  ///
	  || scatter axis r if survey == "ESS 1",  ms(O) mlcolor(black) mfcolor(white)  ///
	  || scatter axis r if survey == "ESS 2",  ms(O) mlcolor(black) mfcolor(gs8)  ///
	  || scatter axis r if survey == "ESS 3",  ms(O) mlcolor(black) mfcolor(black)  ///
	  || if keyvar == "`k'"  ///
	  , by(seqvarnum, rows(2) note("") ) ///
	  legend(order(2 "ESS 1" 3 "ESS 2" 4 "ESS 3" 1 "Benchmark") row(1)) 	/// 
	  ylab(`ylab', valuelabel angle(0)) ///
	  ytitle("") xlab(#5) /// 
	  ysize(7) xline(0)
	

	graph export ankeyvars2_`k'.eps, replace
}

replace keyvar = "Age" if keyvar == "age" 
replace keyvar = "City" if keyvar == "city" 
replace keyvar = "Income" if keyvar == "hinc" 
replace keyvar = "Left" if keyvar == "lrscale" 
replace keyvar = "Married" if keyvar == "married" 
replace keyvar = "Pol. Int." if keyvar == "polintr" 
replace keyvar = "Trust" if keyvar == "ppltrst" 
replace keyvar = "Satisf." if keyvar == "stflife" 
replace keyvar = "Women" if keyvar == "women" 
replace keyvar = "Worker" if keyvar == "worker" 


graph box r, over(keyvar) by(seqvarnum, note("") rows(3) )  ///
  horizontal ///
  ytitle(Pearson's r) ///
  ysize(9) yline(0) ///
  medtype(marker) medmarker(ms(O) mc(black)) ///
  marker(1, ms(oh)) box(1, lcolor(black) fcolor(white))

graph export ankeyvars2_all.eps, replace


graph box r if seqvar == "Single vs. multi", over(keyvar)  ///
  horizontal ///
  ytitle(Pearson's r) ///
  ysize(3) xsize(2.5) yline(0) ///
  medtype(marker) medmarker(ms(O) mc(black)) ///
  marker(1, ms(oh)) box(1, lcolor(black) fcolor(white))

graph export ankeyvars2_benchmark.eps, replace




exit



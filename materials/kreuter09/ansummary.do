// Summary Plot
// kohler@wzb.eu

version 10
clear
set more off
set memory 90m
set scheme s1mono

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


// Calculate Correlations
// ----------------------

// Select specific contratst for correlations
gen married = marital==1 if !mi(marital)
gen worker = inlist(egpr,8,9,10) if !mi(egpr)
gen emp = !athome if !mi(athome)

tempname r1 r2
tempfile rfile1 rfile2
postfile `r1' str5 survey str2 cntry str20 keyvar str20 seqvar ry using `rfile1'
postfile `r2' str5 survey str2 cntry str20 seqvar rp using `rfile2'

foreach keyvar of varlist  ///
  married hinc worker ppltrst polintr lrscale stflife tvtot emp {
	foreach round in "ESS 1" "ESS 2" "ESS 3" {
		levelsof cntry, local(K)
		foreach k of local K {
			foreach seqvar of varlist sq1 psq* sqdim single {
				capture  ///
				  corr `keyvar' `seqvar'  ///
				  if cntry == "`k'" & survey == "`round'" & respondent 
				post `r1' ("`round'") ("`k'") ("`keyvar'") ("`:var lab `seqvar''") (r(rho))
			}
		}
	}
}
postclose `r1'


foreach round in "ESS 1" "ESS 2" "ESS 3" {
	levelsof cntry, local(K)
	foreach k of local K {
		foreach seqvar of varlist sq1 psq* sqdim single {
			capture  ///
			  corr respondent `seqvar'  ///
			  if cntry == "`k'" & survey == "`round'" 
			post `r2' ("`round'") ("`k'") ("`:var lab `seqvar''") (r(rho))
		}
	}
}
postclose `r2'

// Process Resultsset
// ------------------

use `rfile2', clear
sort survey cntry seqvar
save `rfile2', replace

use `rfile1', clear
sort survey cntry seqvar
merge survey cntry seqvar using `rfile2'
assert _merge==3
drop _merge


// Numeric Indikator for Sequence Characteristic
label define seqvars 1 "# of Contacts" 2 "No contacts" 3 "Diff. elements" ///
  4 "Episodes" 5 "Dist. interaction" 6 "MDS dimension 1" 7 "Single vs. multi"
encode seqvar, gen(seqvarnum) label(seqvars)


sum rp, meanonly
local xmean = r(mean)
sum ry, meanonly
local ymean = r(mean)

graph twoway  /// 
  || scatter ry rp if seqvarnum==1, ms(O) mlcolor(black) mfcolor(gs0)  ///
  || scatter ry rp if seqvarnum==2, ms(O) mlcolor(black) mfcolor(gs8)  ///
  || scatter ry rp if seqvarnum==3, ms(O) mlcolor(black) mfcolor(gs16)  ///
  || scatter ry rp if seqvarnum==4, ms(S) mlcolor(black) mfcolor(gs0)  ///
  || scatter ry rp if seqvarnum==5, ms(S) mlcolor(black) mfcolor(gs8)  ///
  || scatter ry rp if seqvarnum==6, ms(S) mlcolor(black) mfcolor(gs16)  ///
  || scatter ry rp if seqvarnum==7, ms(X) mcolor(black) ///
  || , legend(pos(2)  ///
  order(1 "# of contacts" 3 "No contacts" 3 "Diff. elements"  ///
  4 "Episodes" 5 "Dist. interaction" 6 "MDS dimension 1"  ///
  7 "Single vs. multi") rows(7))  ///
  xtitle(Correlation with response)  ///
  ytitle(Correlation with survey variable) ///
  xline(0) yline(0)
graph export ansummary_1.eps, replace

bysort survey cntry keyvar (seqvar): gen benchmarky = ry[_N]
bysort survey cntry keyvar (seqvar): gen benchmarkx = rp[_N]

graph twoway  ///
  || scatter benchmarky benchmarkx, ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter ry rp, ms(O) mlcolor(black) mfcolor(black)  ///
  || if seqvarnum != 7, by(seqvarnum, note("")) xline(0) yline(0) ///
  legend(order(1 "Benchmark" 2 "Sequence characteristic"))  ///
  xtitle(Correlation with response)  ///
  ytitle(Correlation with survey variable) 
graph export ansummary_2.eps, replace

gen absry = abs(ry)
gen absrp = abs(rp)
gen absbenchmarky = abs(benchmarky)
gen absbenchmarkx = abs(benchmarkx)


graph twoway  /// 
  || scatter absry absrp if seqvarnum==1, ms(O) mlcolor(black) mfcolor(gs0) ///
  || scatter absry absrp if seqvarnum==2, ms(O) mlcolor(black) mfcolor(gs8) ///
  || scatter absry absrp if seqvarnum==3, ms(O) mlcolor(black) mfcolor(gs16) ///
  || scatter absry absrp if seqvarnum==4, ms(S) mlcolor(black) mfcolor(gs0) ///
  || scatter absry absrp if seqvarnum==5, ms(S) mlcolor(black) mfcolor(gs8) ///
  || scatter absry absrp if seqvarnum==6, ms(S) mlcolor(black) mfcolor(gs16) ///
  || scatter absry absrp if seqvarnum==7, ms(X) mcolor(black) ///
  || , legend(pos(2)  ///
  order(1 "# of contacts" 3 "No contacts" 3 "Diff. elements"  ///
  4 "Episodes" 5 "Dist. interaction" 6 "MDS dimension 1"  ///
  7 "Single vs. multi") rows(7))  ///
  xtitle(Correlation with response)  ///
  ytitle(Correlation with survey variable) 
graph export ansummary_3.eps, replace


graph twoway  ///
  || scatter absbenchmarky absbenchmarkx, ms(O) mlcolor(black) mfcolor(white) ///
  || scatter absry absrp, ms(O) mlcolor(black) mfcolor(black)  ///
  || if seqvarnum != 7, by(seqvarnum, note(""))  ///
  legend(order(1 "Benchmark" 2 "Sequence characteristic"))  ///
  xtitle(Correlation with response)  ///
  ytitle(Correlation with survey variable) ///
  xline(.2) yline(.2)
graph export ansummary_4.eps, replace


graph box absry absbenchmarky , over(cntry)  ///
  horizontal ///
  ytitle(Absolute correlation with key survey variables )       ///
  ysize(3) xsize(2.5)         ///
  medtype(marker) 						/// 
  medmarker(ms(O) mc(black))            ///
  marker(1, ms(oh) mlcolor(black)) 					/// 
  marker(2, ms(oh) mlcolor(black)) 					/// 
  box(1, lcolor(black) fcolor(white)) 	///
  box(2, lcolor(black) fcolor(gs8)) 	///
  legend(order(1 "Sequence characteristics" 2 "Benchmark"))
graph export ansummary_5.eps, replace


graph box absry if seqvarnum~=7, over(cntry)  ///
  horizontal ///
  ytitle(Absolute correlation with key survey variables )       ///
  ysize(3) xsize(2.5)         ///
  medtype(marker) 						/// 
  medmarker(ms(O) mc(black))            ///
  marker(1, ms(oh) mlcolor(black)) 					/// 
  box(1, lcolor(black) fcolor(white)) 	///
  by(seqvarnum, note(""))
graph export ansummary_6.eps, replace


exit



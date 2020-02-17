// Success of weigthing with contact sequences
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


// Construct weights (probit model for repondent)
// ---------------------------------------------

gen respondent:yeso = _merge == 3
drop _merge

probit respondent sq1 psq*
predict Phat
gen cweight = 1/Phat

sum cweight

// Gender heterogenous couples
// ---------------------------

keep if hhmmb == 2 & marital == 1
assert respondent == 1

// Calculate (weighted) fractions of women
// -----------------------------------------

preserve
collapse (mean) cwp = women [aweight=cweight], by(survey cntry)
tempfile f1
save `f1'
restore, preserve
collapse (mean) dwp = women [aweight=weight], by(survey cntry)
tempfile f2
save `f2'
restore 
collapse (mean) women (count) N = women, by(survey cntry)

merge survey cntry using `f1' `f2', sort
drop _merge*

// Design the graph
// ----------------

// Sort-Order for Countries
egen mean = mean(women), by(cntry)
egen ctrsort = axis(mean cntry), label(cntry) reverse

// Confidence Intervalls
gen womenub = .5 + 1.96*sqrt(.5^2/N)
gen womenlb = .5 - 1.96*sqrt(.5^2/N)

// The Graph
twoway ///
  || rbar womenub womenlb ctrsort                           /// Confidence Bounds
  , horizontal color(gs10) sort                             ///
  || scatter ctrsort women                                  /// Random Selection
  , ms(O) mcolor(black)                                     ///
  || scatteri 0 .5 17 .5                                    /// A vertical line if fg
  , c(l) ms(i) clcolor(fg) clpattern(solid)                 ///
  || pcarrow women ctrsort cwp ctrsort                      /// Weights
  , horizontal color(black)                                 ///
  || , by(survey, note("") l1title("") iscale(*.8))         /// Twoway Options 
  ylab(1(1)17, valuelabel angle(horizontal))  ///
  legend(rows(1) order(2 "Prop. of women" 4 "Weighted prop. of women" ))  ///
  scheme(s1mono) ysize(5.5)
graph export anweigths.eps, replace

// Some numbers for the text
count if women < womenlb | women > womenub
count if cwp < womenlb | cwp > womenub
count if dwp < womenlb | dwp > womenub

gen betterc = 1 							/// 
  if (women < .5 & cwp > women)			/// 
  |  (women > .5 & cwp < women)
replace betterc = 0 						/// 
  if (women > .5 & cwp > women)			/// 
  |  (women < .5 & cwp < women) 		///
  |  (women == .5 & cwp != .5)
tab betterc

gen betterd = 1 							/// 
  if (women < .5 & dwp > women)			/// 
  |  (women > .5 & dwp < women)
replace betterd = 0 						/// 
  if (women > .5 & dwp > women)			/// 
  |  (women < .5 & dwp < women) 		///
  |  (women == .5 & dwp != .5)
tab betterd

sum women cwp dwp


exit
	


	
	

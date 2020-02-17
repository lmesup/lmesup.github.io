// Description of sequences
// kohler@wzb.eu

// History
// anseqdes.do  // Prag
// anseqdes1.do // 3MC
// anseqdes2.do // Post 3MC

version 10
clear
set memory 90m
set scheme s1mono
capture log close
log using anseqdes2, replace

use survey cntry idno visit result* using ESScontactbig, clear

// Clean Data
// ----------

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

// Now sqset
gen str1 ctrcase = ""
replace ctrcase = survey + " " + cntry + " " + string(idno,"%12.0f")
sqset result ctrcase visit, ltrim

// Some numbers
// ------------

di as text "Number of contact attempts: " as result _N
sqtab, ranks(1/10)

egen sqlength = sqlength()
sqstattabsum survey

// Sequence index plot
// -------------------

// Definition of order variables
egen sqlength2= sqlength(), e(2) // <- Contact with R, no interview 
egen sqlength3= sqlength(), e(3) // <- Contact with someone else
egen sqlength4= sqlength(), e(4) // <- No contact at all
egen pos421 = sqfirstpos(), pattern(4 2 1)
egen pos431 = sqfirstpos(), pattern(4 3 1)
egen pos21 = sqfirstpos(), pattern(2 1)
egen pos31 = sqfirstpos(), pattern(3 1)
egen pos41 = sqfirstpos(), pattern(4 1)

// The plot
sqindexplot if cntry == "DE" & sqlength > 4  /// 
  , by(survey, legend(pos(6)) note("") yrescale) 				///
  order(sqlength pos421 pos21 pos431 pos31 pos41 sqlength4 sqlength3 sqlength2)			///
  color(gs2 gs6 gs10 gs14) 				 ///
  legend(rows(2)) ysize(10) 			///
  ylab(#10)
graph export anseqdes2_indexplot.eps, replace
drop sq* pos*


// Conclusions from Sequence index plot
// ------------------------------------

bysort survey cntry idno (visit): drop if _n==_N // <- Remove last contact attempt
by survey cntry idno (visit): keep if _N>4       // <- Length 5 and above

// Reset sequence data
sqset result ctrcase visit


// Prepare Resultsset
// ------------------

egen sqlengtho= sqlength()       // <- Overall
egen sqlength2= sqlength(), e(2) // <- Contact with R, no interview 
egen sqlength3= sqlength(), e(3) // <- Contact with someone else
egen sqlength4= sqlength(), e(4) // <- No contact at all

egen sqelemcount = sqelemcount()
egen sqepicount = sqepicount()

bysort ctrcase (visit): gen pos2not1 = 1 if inlist(result,2,3,4) & result[_n-1]==2
by ctrcase (visit): replace pos2not1 = sum(pos2not1)
by ctrcase (visit): replace pos2not1 = pos2not1[_N]

bysort ctrcase (visit): gen pos24 = 1 if result==4 & result[_n-1]==2
by ctrcase (visit): replace pos24 = sum(pos24)
by ctrcase (visit): replace pos24 = pos24[_N]

sqom, idealtype(4:5 3 2) name(distance)

foreach var of varlist sqlength4 sqepicount sqelemcount pos* {
	gen p`var' = `var'/sqlengtho
}

by ctrcase, sort: keep if _n==1
collapse (mean) sq* pos* ppos* psq* distance , by(survey cntry) 
encode survey, gen(svynum)
drop survey
reshape wide 							/// 
  sqlengtho sqlength2 sqlength3 sqlength4 	/// 
  pos2not1 pos24  	///
  sqelemcount sqepicount 					/// 
  distance  ///
    psqlength4 psqepicount psqelemcount 			///
  ppos2not1 ppos24  	///
  , i(cntry) j(svynum)


// Length Chart
// -------------
// (I made two; which should we choose)

gen order = (sqlengtho1 + sqlengtho2)/2
egen axis = axis(order cntry), reverse label(cntry)

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis sqlengtho1 axis sqlengtho2  ///
  ,  lcolor(black) mlcolor(black) /// 
  || scatter axis sqlengtho1,  ms(O) mcolor(black)  ///
  || , ylab(`K', valuelabel angle(0) grid notick) ytitle("")  ///
  xtitle("# of contact attempts") /// 
  legend(order(2 "2002" 1 "2004 vs. 2002") row(1)) 	/// 
  title(Contact attempts, box bexpand pos(12)) 	///
  name(g1, replace) nodraw

drop order axis
gen order = (psqlength41 + psqlength42)/2
egen axis = axis(order cntry), reverse label(cntry)

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis psqlength41 axis psqlength42 	///
  ,  lcolor(black) mlcolor(black) /// 
  || scatter axis psqlength41, ms(O) mlcolor(black) mfcolor(black)  ///
  || , ylab(`K', valuelabel angle(0) grid notick) ytitle("")  ///
  xtitle("Proportion of no contacts") /// 
  legend(order(2 "2002" 1 "2004 vs. 2002") row(1)) 	/// 
  title("No contacts/sequence length", box bexpand pos(12)) 	///
  name(g2, replace) nodraw

grc1leg g1 g2, row(1) 
graph export anseqdes2_length.eps, replace

// Some numbers to mention
sum sqlengtho? psqlength4?
corr sqlengtho? psqlength4?

  
// Epinum Chart
// -------------

drop order axis
gen order = (psqelemcount1 + psqelemcount2)/2
egen axis = axis(order cntry), reverse label(cntry)

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis psqelemcount1 axis psqelemcount2  ///
  ,  lcolor(black) mlcolor(black) /// 
  || scatter axis psqelemcount1,  ms(O) mcolor(black)  ///
  || , ylab(`K', valuelabel angle(0) grid notick) ytitle("")  ///
  xtitle("Different elements/Length") /// 
  legend(order(2 "2002" 1 "2004 vs. 2002") row(1)) 	/// 
  title(Different elements, box bexpand pos(12)) 	///
  name(g1, replace) nodraw

drop order axis
gen order = (psqepicount1 + psqepicount2)/2
egen axis = axis(order cntry), reverse label(cntry)

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis psqepicount1 axis psqepicount2 	///
  ,  lcolor(black) mlcolor(black) /// 
  || scatter axis psqepicount1, ms(O) mlcolor(black) mfcolor(black)  ///
  || , ylab(`K', valuelabel angle(0) grid notick) ytitle("")  ///
  xtitle("Episodes/Length") /// 
  legend(order(2 "2002" 1 "2004 vs. 2002") row(1)) 	/// 
  title("Episodes", box bexpand pos(12)) 	///
  name(g2, replace) nodraw

grc1leg g1 g2, row(1) 
graph export anseqdes2_episodes.eps, replace


// Some numbers to mention
sum psqelemcount? psqepicount?
corr psqelemcount? psqepicount?


// Idealised sub-sequences chart
// -----------------------------

drop order axis
gen order = (ppos2not11 + ppos2not12)/2
egen axis = axis(order cntry), reverse label(cntry)

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis ppos2not11 axis ppos2not12  ///
  ,  lcolor(black) mlcolor(black) /// 
  || scatter axis ppos2not11,  ms(O) mcolor(black)  ///
  || , ylab(`K', valuelabel angle(0) grid notick) ytitle("")  ///
  xtitle("(Contact with resp. -> no interview)/Length") /// 
  legend(order(2 "2002" 1 "2004 vs. 2002") row(1)) 	/// 
  title("Disturbed interv.-respond. interaction", box bexpand pos(12)) 	///
xsize(3)

graph export anseqdes2_ideal.eps, replace


// Distance to idealtype 4:5 3 2
// -----------------------------

drop order axis
gen order = (distance1 + distance2)/2
egen axis = axis(order cntry), reverse label(cntry)

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis distance1 axis distance2  ///
  ,  lcolor(black) mlcolor(black) /// 
  || scatter axis distance1,  ms(O) mcolor(black)  ///
  || , ylab(`K', valuelabel angle(0) grid notick) ytitle("")  ///
  xtitle("Levensthein Distance") /// 
  legend(order(2 "2002" 1 "2004 vs. 2002") row(1)) 	/// 
  title("Distance to ideal type", box bexpand pos(12)) 	///
  xsize(3)

graph export anseqdes2_om.eps, replace


exit


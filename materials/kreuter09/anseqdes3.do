// Description of sequences
// kohler@wzb.eu

// History
// anseqdes.do  // Prag
// anseqdes1.do // 3MC
// anseqdes2.do // Post 3MC
// anseqdes3.do // Sequence length 3+

version 10
clear
set memory 90m
set scheme s1mono
set matsize 5000
capture log close
log using anseqdes3, replace

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
sqstattabsum survey cntry
drop sqlength

// Sequence index plot
// -------------------

// The plot
sqindexplot if cntry == "DE" & survey == "ESS 2002" /// 
  , color(gs2 gs6 gs10 gs14) 				    ///
  legend(off)           		     	///
  ylab(1 500(500)5500)  ytick(1 100(100)5400)  ///
  title(ESS 1, bexpand box) 	///
  name(g1, replace) nodraw

sqindexplot if cntry == "DE" & survey == "ESS 2004" /// 
  , color(gs2 gs6 gs10 gs14) 				    ///
  legend(off)           		     	///
  ylab(1 500(500)5500) ytick(1 100(100)5400)  /// 
  title(ESS 2, bexpand box) 	/// 
  name(g2, replace) nodraw

graph combine g1 g2, name(gdata, replace) nodraw

sqindexplot if cntry == "DE" & survey == "ESS 2004" /// 
  , color(gs2 gs6 gs10 gs14) 				    ///
  legend(order(4 "No contact" 3 "Contact with someone else"  /// 
  2 "Contact with respondent"  1 "Interview") rows(2) pos(6))	     	///
  yscale(off) xscale(off) 				/// 
  name(leg, replace) nodraw 
  
// Delete Plrogregion and fix ysize (Thanks, Vince)
_gm_edit .leg.plotregion1.draw_view.set_false
_gm_edit .leg.ystretch.set fixed

graph combine gdata leg, rows(2) ysize(10)
graph export anseqdes3_indexplot.eps, replace


// Conclusions from Sequence index plot
// ------------------------------------

bysort survey cntry idno (visit): drop if _n==_N // <- Remove last contact attempt
by survey cntry idno (visit): keep if _N>=2       // <- Length 2 (i.e. 3) and above

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

foreach var of varlist sqlength4 sqepicount sqelemcount pos* {
	gen p`var' = `var'/sqlengtho
}


sqom, full
mdsmat SQdist
predict sqdim, saving(mds)
*copy /home/ado/sq/sqmdsadd.ado sqmdsadd.ado, replace  // Pre-alpha of sqmdsadd
sqmdsadd using mds

sqtab
sqtab, so
sqtab, se

by ctrcase, sort: keep if _n==1
collapse (mean) sq* pos* ppos* psq*, by(survey cntry) 
encode survey, gen(svynum)
drop survey
reshape wide 							/// 
  sqlengtho sqlength2 sqlength3 sqlength4 	/// 
  pos2not1 pos24  	///
  sqelemcount sqepicount 					/// 
  psqlength4 psqepicount psqelemcount 			///
  ppos2not1 ppos24  	///
  sqdim 								/// 
  , i(cntry) j(svynum)


// Length Chart
// -------------

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
graph export anseqdes3_length.eps, replace

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
graph export anseqdes3_episodes.eps, replace


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

graph export anseqdes3_ideal.eps, replace


// MDS of OM, full
// ---------------

drop order axis
gen order = (sqdim1 + sqdim2)/2
egen axis = axis(order cntry), reverse label(cntry)

levelsof axis, local(K)
graph twoway ///
  || pcarrow axis sqdim1 axis sqdim2  ///
  ,  lcolor(black) mlcolor(black) /// 
  || scatter axis sqdim1,  ms(O) mcolor(black)  ///
  || , ylab(`K', valuelabel angle(0) grid notick) ytitle("")  ///
  xtitle("(Contact with resp. -> no interview)/Length") /// 
  legend(order(2 "2002" 1 "2004 vs. 2002") row(1)) 	/// 
  title("1st dimension of MDS on levensthein distances", box bexpand pos(12)) 	///
  xsize(3)
graph export anseqdes3_sqmds.eps, replace

capture log close

exit


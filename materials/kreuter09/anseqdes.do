// Description of sequences
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

// Now sqset
sqset result ctrcase visit

sqindexplot if cntry == "DE", scheme(s2color) ///
  title(Sequence-Index-Plot for Germany)
graph export anseqdes_indexplot.eps, replace

// Generate descriptive statistics
// -------------------------------

egen sqlength = sqlength()
egen sqlength2= sqlength(), e(2) // <- Contact with R, no interview 
egen sqlength3= sqlength(), e(3) // <- Contact with someone else
egen sqlength4= sqlength(), e(4) // <- No contact at all

egen sqlength5= sqlength(), e(5) // <- Address not valid
gen  invalrevisit = sqlength5 >= 2 if !mi(sqlength5)
drop sqlength5

egen sqelemcount = sqelemcount()
egen sqepicount = sqepicount()

egen firstpos1 = sqfirstpos(), pattern(2 1)
replace firstpos1 = firstpos1 > 0 if !mi(firstpos1)

egen firstpos2 = sqfirstpos(), pattern(3 1)
replace firstpos2 = firstpos2 > 0 if !mi(firstpos2)

egen firstpos3 = sqfirstpos(), pattern(4 3 1)
replace firstpos3 = firstpos3 > 0 if !mi(firstpos3)

// Tables of Sequence describtions
// --------------------------------

by ctrcase, sort: keep if _n==1
collapse (mean) sq* invalrevisit firstpos*, by(cntry) 

egen axis = axis(sqlength cntry), reverse label(cntry)
levelsof axis, local(K)
graph twoway ///
  || dot sqlength axis, horizontal  ms(0) mcolor(black) ///
  || dot sqlength2 axis, horizontal ms(o) mlcolor(black) mfcolor(white) ///
  || dot sqlength3 axis, horizontal ms(o) mlcolor(black) mfcolor(gs8) ///
  || dot sqlength4 axis, horizontal ms(o) mlcolor(black) mfcolor(black) ///
  || , title(Average length of sequences) ///
  subtitle("Overall, and of specific elements" ) ///
  ylab(`K', valuelabel angle(0)) ytitle("") ///
  legend(pos(2) col(1) order(1 "Overall" 2 "Contact with R" 3 "Contact" 4 "No contact"))
graph export anseqdes_length.eps, replace


drop axis
egen axis = axis(invalrevisit cntry), reverse label(cntry)
levelsof axis, local(K)
graph twoway ///
  || dot invalrevisit axis, horizontal  ms(0) mcolor(black) ///
  || , title(Frequency of re-contacting an invalid address) ///
  ylab(`K', valuelabel angle(0)) ytitle("") xtitle("")
graph export anseqdes_invalrevisit.eps, replace

drop axis
egen axis = axis(sqepicount cntry), reverse label(cntry)
levelsof axis, local(K)
graph twoway ///
  || dot sqepicount axis, horizontal ms(O) mlcolor(black) mfcolor(black)  ///
  || dot sqelemcount axis, horizontal  ms(0) mlcolor(black) mfcolor(white)  ///
  || , title("Number of elements and episodes") ///
  ylab(`K', valuelabel angle(0)) ytitle("") ///
  legend(pos(2) col(1) order(1 "Number of episodes" 2 "Number of elements"))
graph export anseqdes_epicount.eps, replace

drop axis
egen axis = axis(firstpos1 cntry), reverse label(cntry)
levelsof axis, local(K)
graph twoway ///
  || dot firstpos1 axis, horizontal ms(O) mlcolor(black) mfcolor(black)  ///
  || dot firstpos2 axis, horizontal ms(O) mlcolor(black) mfcolor(white)  ///
  || dot firstpos3 axis, horizontal ms(O) mlcolor(black) mfcolor(gs8)  ///
  || , title(Proportion of ideal typical patterns) ///
  ylab(`K', valuelabel angle(0)) ytitle("") ///
  legend(pos(2) col(1) order(1 "Rcontact-I" 2 "Contact-I" 3 "Nocontact/Contact/I"))
graph export anseqdes_ideal.eps, replace

exit


// Describe Election Metadata extensivly

version 10
set scheme s1mono


// Number of Parties
// -----------------

use elections, clear

by election, sort: gen sumvotes = sum(nvotes)
replace nvalid = sumvotes if mi(nvalid)
gen pvotes = (nvotes/nvalid)*100
by election, sort: gen nparty_ge1 = sum(pvote>=1) if !mi(pvote)


by election, sort: keep if _n==_N

sum nparty_ge1
local mean = r(mean)
set obs  `=_N+1'
replace nparty_ge1 = `mean' in -1
replace ctrname = "Mean" in -1

encode ctrname, gen(ctrnum) 
egen axis = axis(nparty_ge1 ctrnum), label(ctrnum)

sort axis
levelsof axis, local(lab)
graph twoway ///
  || bar nparty_ge1 axis if ctrname != "Mean" 	///
  , horizontal barwidth(0.7) bcolor(black) 		///
  || bar nparty_ge1 axis if ctrname == "Mean" 	///
  , horizontal barwidth(0.7) bfcolor(white) blcolor(black) 		///
  || scatter axis nparty_ge1, ms(i) mlab(nparty_ge1) mcolor(black) mlabpos(3)  ///
  || ,  ylabel(`lab', valuelabel angle(0)) xlabel(0(2)12, format(%3.0f) grid)  ///
  ytitle("") 							/// 
  xtitle(Number of parties with 1% or more of vote)  /// 
  ysize(6.5) xscale(range(0 13)) legend(off)  ///
  note("Note: Calculated from data for latest national election.", span)

graph export grpartynum1.eps, replace
!epstopdf grpartynum1.eps


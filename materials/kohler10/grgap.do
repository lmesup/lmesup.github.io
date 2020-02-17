// A Summary table of impact probability
// -------------------------------------
// kohler@wzb.eu

set scheme s1mono

version 10
use elections2, clear

// n_1, n_2
by election (nvotes), sort: gen W = nvotes[_N]
by election (nvotes): gen R = nvotes[_N-1]
by election: keep if _n==_N

// diffindex
replace W = 100 * (W/nvalid)
replace R = 100 * (R/nvalid)

// Gap
gen gap = W - R
format gap  %2.0f
sum gap

// Fake Median country
sum gap, meanonly
local gap = r(mean)
set obs `=_N+1'
replace ctrname = "Mean" in -1
replace gap = `gap' in -1


// Graph
egen axis = axis(gap ctrname), label(ctrname) reverse
sort axis
levelsof axis, local(lab)

graph twoway ///
  || bar gap axis if ctrname != "Mean" 	///
  , horizontal barwidth(0.7) bcolor(black) 		///
  || bar gap axis if ctrname == "Mean" 	///
  , horizontal barwidth(0.7) bfcolor(white) blcolor(black) 		///
  || scatter axis gap, ms(i) mlab(gap) mcolor(black) mlabpos(3)  ///
  || ,  ylabel(`lab', valuelabel angle(0)) 	/// 
  xlabel(0(5)20, format(%3.0f) grid)  ///
  ytitle("") legend(off) ///
  xtitle(Gap in %) ysize(6.5)  ///
  xscale(range(0 20)) 					/// 
  note("Note: Calculated from data for latest national election.", span)
graph export grgap.eps, replace
!epstopdf grgap.eps


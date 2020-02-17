// Describe Election Metadata extensivly

version 10
set scheme s1mono

use elections, clear

by election, sort: gen sumvotes = sum(nvotes)
by election: replace nvalid = sumvotes[_N] if mi(nvalid)
by election: keep if _n==_N

gen vturnout = nvalid/nelectorate * 100

sum vturnout
local mean = r(mean)
set obs  `=_N+1'
replace vturnout = `mean' in -1
replace ctrname = "Mean" in -1

encode ctrname, gen(ctrnum) 
egen axis = axis(vturnout), label(ctrnum)

format vturnout %2.0f
sort axis
levelsof axis, local(lab)
graph twoway ///
  || bar vturnout axis if ctrname != "Mean" 	///
  , horizontal barwidth(0.7) bcolor(black) 		///
  || bar vturnout axis if ctrname == "Mean" 	///
  , horizontal barwidth(0.7) bfcolor(white) blcolor(black) 		///
  || scatter axis vturnout, ms(i) mlab(vturnout) mcolor(black) mlabpos(3)  ///
  || ,  ylabel(`lab', valuelabel angle(0)) 	/// 
  xlabel(0(10)100, format(%3.0f) grid)  ///
  ytitle("") legend(off) xtitle(% of Eligible Electorate)  ///
  ysize(6.5)  ///
  xscale(range(0 108)) 					

graph export grturnout_by_country2_1.eps, replace


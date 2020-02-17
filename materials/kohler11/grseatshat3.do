// Voting behavior of non-Voters
// -----------------------------
// (kohler@wzb.eu)

version 10

use seats, clear

// Periods
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

// Reduce data size to decrease graph file size
replace bsample = bsample > 0
by bsample eldate party6, sort: keep if _n==1

// Show very large confidence bounds as arrows
gen arrowUB = cond(diffUB>=18,18,diffUB)
gen arrowLB = cond(diffLB<=-18,-18,diffLB)

// Order of figures
lab def party6 1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "B90/Gr."  /// 
5 "Linke/PDS" 6 "Other"
encode party6, gen(party6num) label(party6)

// Graph
graph twoway 							///
  || rcap diffUB diffLB eldate if diffUB <= 18 & diffLB >= -18  ///
  , lcolor(black) 	          			///
  || pcarrow arrowUB eldate arrowLB eldate if diffLB < -18  ///
  , lcolor(black) mcolor(black)     			///
  || pcarrow arrowLB eldate arrowUB eldate if diffUB > 18 & !mi(diffUB)  ///
  , lcolor(black) mcolor(black)     			///
  || scatter arrowLB eldate if diffLB < -18  ///
  , ms(i) mlab(diffLB) mlabpos(6)   		///
  || scatter arrowUB eldate if diffUB > 18 & !mi(diffUB) ///
  , ms(i) mlab(diffUB) mlabpos(12)   		///
  || scatter diff eldate, ms(O) mlcolor(black) mfcolor(gs12) 	///
  || , by(party6num, legend(off) note(""))  ///
  yline(0) ytitle("Counterfactual seats minus realized seats") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")

graph export grseatshat3.eps, replace

exit

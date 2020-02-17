// Graph gallagher index
// ---------------------
// (kohler@wzb.eu)

version 11

use seats, clear

// Periods
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

// 6 largest parties
by bsample eldate party6, sort: keep if _n==1

// Generate Gallagher Index
bysort bsample eldate: egen S6 = sum(seats6)
by bsample eldate: egen Shat6 = sum(mhat6)

by bsample eldate, sort: 				/// 
  gen G6 = sum( ((seats6/S6)*100 - (mhat6/Shat6)*100)^2 )  
by bsample eldate, sort: replace G6 = G6[_N] 

egen minG6 = pctile(G6) if bsample , p(2.5) by(eldate)
egen maxG6 = pctile(G6) if bsample , p(97.5) by(eldate)

// Reduce data size to decrease graph file size
replace bsample = bsample > 0
by bsample eldate, sort: keep if _n==1

// Graph
levelsof eldate, local(xlab)
graph twoway 							///
  || rcap minG6 maxG6 eldate, lcolor(black) 	          			///
  || scatter G6 eldate if !bsample, ms(O) mlcolor(black) mfcolor(gs12) 	///
  || , legend(off)  ///
  ytitle("Gallagher Index") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`xlab') ylab(0(2)12)

graph export grgallagher3.eps, replace

exit



















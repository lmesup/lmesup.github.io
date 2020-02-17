// Descriptive Figure of Left-Right by Country
// kohler@wzb.eu

version 10
set more off
set scheme s1mono


// Overall - Graph
// ---------------

use btwsurvey if !mi(lr), clear
by zanr, sort: gen nweight = 1/_N * 1000
tab lr, gen(lr)

collapse (mean) lr1-lr6 [aweight=nweight] if !mi(voter), by(voter)

forv i = 1/6 {
	replace lr`i' = lr`i'*100			
}

gen vstring = "Wähler" if voter
replace vstring = "Nicht-Wähler" if !voter

keep lr? vstring voter
reshape long lr, i(voter) j(k)

replace k = k - .2 if voter
replace k = k + .2 if !voter

format lr %2.0f

local baropt `"barwidth(.4) lcolor(black) "' 
graph tw 								   ///
  || scatter lr k, mlab(lr) mlabpos(12) ms(i) 	/// 
  || bar lr k if voter, `baropt' fcolor(black)  /// 
  || bar lr k if !voter, `baropt' fcolor(gs14) 	///
  , legend(order(2 "Wähler" 3 "Nichtwähler")) 	///
  xtitle("") xlab(1 "Links" 2 "Mitte-Links"   /// 
  3 "Mitte" 4 "Mitte-Rechts" 5 "Rechts" 6 "k.A." )  ///
  ytitle(Prozent) ylab(, grid) 		

graph export anlr_all.eps, replace


// By time - Graph
// ---------------

use btwsurvey if !mi(lr), clear
by zanr, sort: gen nweight = 1/_N * 1000

recode lr (1 2 = 1) (3 6 = 3) (4 5=5)
tab lr, gen(lr)

collapse (mean) lr1-lr3 [aweight=nweight] if !mi(voter), by(voter eldate)

forv i = 1/3 {
	replace lr`i' = lr`i'*100			
}


egen index = group(eldate voter)
reshape long lr, i(index) j(k)
lab val k k
lab def k 1 "Links" 2 "Unklar" 3 "Rechts"

// Perioden
// --------

global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

format eldate %tdYY
levelsof eldate, local(xlab)
graph tw 								   ///
  || connected lr eldate if voter, ms(O) mcolor(black)  	///
  || connected lr eldate if !voter, ms(O) mfcolor(white) mlcolor(black)  	///
  || , by(k, rows(3) note("")) legend(order(1 "Wähler" 2 "Nichtwähler")) ///
  xtitle(Zeit) ytitle(Prozent) ylab(, grid)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
 xlab(`xlab')

graph export anlr_bytime.eps, replace




  
exit



// Descriptive Figure of Left-Right by Country
// kohler@wzb.eu

version 10
set more off
set scheme s1mono

// Construct Resultsset
// --------------------

use ess04_1, clear

tab cntry
return list

gen lrsix:lrsix = 1 if inlist(leftright,0,1,2)
replace lrsix = 2 if inlist(leftright,3,4)
replace lrsix = 3 if inlist(leftright,5)
replace lrsix = 4 if inlist(leftright,6,7)
replace lrsix = 5 if inlist(leftright,8,9,10)
replace lrsix = 6 if mi(leftright)

label define lrsix 1 "Left" 2 "Centre-Left" 3 "Centre" 	///  
4 "Centre-Right" 5 "Right" 6 "Unengaged"

tab lrsix, gen(lrsix)


// European Average
// ---------------

collapse (mean) lrsix1-lrsix6 [aw=nweight] if !mi(voter), by(voter)

forv i = 1/6 {
	replace lrsix`i' = lrsix`i'*100			
}

gen cntry = "European average"
sort cntry

gen vstring = "Voter" if voter
replace vstring = "Non-Voter" if !voter

gsort -vstring 
gen cntryname = "European average" in 1

keep lrsix? cntry vstring voter
reshape long lrsix, i(voter) j(k)

replace k = k - .2 if voter
replace k = k + .2 if !voter

format lrsix %2.0f

local baropt `"barwidth(.4) lcolor(black) "' 
graph tw 								   ///
  || scatter lrsix k, mlab(lrsix) mlabpos(12) ms(i) 	/// 
  || bar lrsix k if voter, `baropt' fcolor(black)  /// 
  || bar lrsix k if !voter, `baropt' fcolor(gs14) 	///
  , legend(order(2 "Voters" 3 "Non-Voters")) 	///
  xtitle("") xlab(1 `""Left" (0-2)"' 2 `""Center-Left" "(3, 4)""'  /// 
  3 `""Center" "(5)""' 4 `""Center-Right" "(6, 7)""'  /// 
  5 `""Right" "(8-10)""' 6 `""Other" "(Don't know)""' )  ///
  ytitle(Percent) ylab(, grid) 			/// 		
  note("Note: Pooled results of European Social II. For further details see www.europeansocialsurvey.org.", span)

graph export anlr_by_voteing2_EUgraph.eps, replace


  
exit



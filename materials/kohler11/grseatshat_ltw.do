// Voting behavior of non-Voters for federal elections
// ---------------------------------------------------
// (thewes@wzb.eu)

// Note: This Do-file needs data produced by
//  anmpredltw.do (runs several hours)

version 10

// Global Settings
// ---------------

// Periods
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

// Merge resultsset of anmpredltw and election data
// -----------------------------------------------

// Big ones
use elections if area != "DE", clear
gen party3 = "CDU/CSU" if party == "CDU/CSU"
replace party3 = "SPD" if party == "SPD"

keep if inlist(party3,"CDU/CSU","SPD") 
tempfile spdcdu
save `spdcdu'

use anmpred2_bs_ltw, clear
collapse (mean) Phat, by(bsample area eldate categ ) // Mean over survey
gen party3 = "SPD" if categ==1
replace party3 = "CDU/CSU" if categ==2
keep if inlist(party3,"CDU/CSU","SPD") 

merge area eldate party3 using `spdcdu', sort uniqusing nokeep
assert _merge==3
drop _merge
tempfile merged
save `merged'

// Other ones (Joinby)
use elections if area != "DE" & party != "Parteilose", clear
gen party3 = "Oth" if !inlist(party,"CDU/CSU","SPD")
keep if party3=="Oth"
sort eldate
tempfile other
save `other'

use anmpred2_bs_ltw, clear
collapse (mean) Phat, by(bsample area eldate categ ) // Mean over survey
gen party3 = "Oth" if categ==3
keep if party3=="Oth"
sort eldate
joinby area eldate using `other'

append using `merged'

// Prhatbar for any party
// -----------------------

gen other = party3=="Oth"
by bsample area eldate other, sort: 			/// 
  gen sumother=sum(ppartyvotes) if other
by bsample area eldate other, sort: 			/// 
  gen ppartyrescale=ppartyvotes/sumother[_N] if other

ren Phat Phat3
gen Phat = Phat3 if !other
replace Phat = ppartyrescale * Phat3 if other

by bsample area eldate (party), sort: gen cumPhat = sum(Phat)
by bsample area eldate (party), sort: assert round(cumPhat[_N],.000001)==1
drop cumPhat other sumother ppartyrescale 


// Voteshat Nonvoter
// -----------------

sum pvalid, meanonly
gen L = ceil(r(max)) - pvalid
gen npartyvoteshat_nonvoter = Phat * L/100 * nelectorate


// Voteshat
// --------

gen voteshat = npartyvotes + npartyvoteshat_nonvoter
assert voteshat < nelectorate



// Mandatszuteilung
// ----------------

// counterfactual observed distribution of seats
levelsof appmethod, local(K)
foreach k of local K {
egen `k' = apport(npartyvotes) ///
	  if appmethod == "`k'" 			///
	, by(eldate bsample area) s(size) threshold(5) e(party=="Liste D" | party=="SSW") m(`k')
}
replace seats  							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton, ///
    cond(!mi(webster),webster,.)))
drop jefferson hamilton webster

// counterfactual estimated distribution of seats
levelsof appmethod, local(K)
foreach k of local K {
egen `k' = apport(voteshat) ///
	  if appmethod == "`k'" 			///
	, by(eldate bsample area) s(size) threshold(5) e(party=="Liste D" | party=="SSW") m(`k')
}
gen mhat  							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton, ///
    cond(!mi(webster),webster,.)))
drop jefferson hamilton webster

// Special:
//gen diff = mhat - ficseats
//replace mhat = seats + diff


// Graph difference of Non-voters estimators to observed result
// ------------------------------------------------------------

// Aggregate values for 6 major parties
gen str8 party6 = party if inlist(party,"SPD","CDU/CSU","FDP")
replace party6 = "Linke/PDS" if inlist(party,"Linke","PDS","WASG")
replace party6 = "B90/Gr." if inlist(party,"B90","Gruene","B90/Gr")
replace party6 = "Other" if party6 == ""

egen seats6 = sum(seats), by(bsample area eldate party6)
egen mhat6 = sum(mhat), by(bsample area eldate party6)

egen minmhat6 = pctile(mhat6) if bsample , p(2.5) by(area eldate party6)			//area ??? 
egen maxmhat6 = pctile(mhat6) if bsample , p(97.5) by(area eldate party6)

gen diff = (mhat6) - seats6 if !bsample
gen diffUB = (maxmhat6) - seats6 if bsample
gen diffLB = (minmhat6) -  seats6 if bsample 

// Reduce data size to decrease graph file size
replace bsample = bsample > 0
by area bsample eldate party6, sort: keep if _n==1

// Fine tune 
lab def party6 1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "B90/Gr."  /// 
5 "Linke/PDS" 6 "Other"
encode party6, gen(party6num) label(party6)
format %tdYY eldate

gen arrowUB = cond(diffUB>=18,18,diffUB)
gen arrowLB = cond(diffLB<=-18,-18,diffLB)

// Graph

// CDU
graph twoway 							///
  || rcap diffUB diffLB eldate if diffUB < 18 & diffLB > -18  ///
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
  || if party6num==1, by(area, legend(off) note(""))  ///
  yline(0) ytitle("Counter-factual seats minus realized seats - CDU") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`=date("1.1.1960","MDY")'(`=5*366')`=date("1.1.2009","MDY")')
graph export grseatshat_ltw_cdu.eps, replace

// SPD
graph twoway 							///
  || rcap diffUB diffLB eldate if diffUB < 18 & diffLB > -18  ///
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
  || if party6num==2, by(area, legend(off) note(""))  ///
  yline(0) ytitle("Counter-factual seats minus realized seats - SPD") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`=date("1.1.1960","MDY")'(`=5*366')`=date("1.1.2009","MDY")')
graph export grseatshat_ltw_spd.eps, replace

// FDP
graph twoway 							///
  || rcap diffUB diffLB eldate if diffUB < 18 & diffLB > -18  ///
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
  || if party6num==3, by(area, legend(off) note(""))  ///
  yline(0) ytitle("Counter-factual seats minus realized seats - FDP") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`=date("1.1.1960","MDY")'(`=5*366')`=date("1.1.2009","MDY")')
graph export grseatshat_ltw_fdp.eps, replace

// B90/Gr.
graph twoway 							///
  || rcap diffUB diffLB eldate if diffUB < 18 & diffLB > -18  ///
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
  || if party6num==4, by(area, legend(off) note(""))  ///
  yline(0) ytitle("Counter-factual seats minus realized seats - B90/Gr.") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`=date("1.1.1960","MDY")'(`=5*366')`=date("1.1.2009","MDY")')
graph export grseatshat_ltw_cdu_b90.eps, replace

// Linke/PDS
graph twoway 							///
  || rcap diffUB diffLB eldate if diffUB < 18 & diffLB > -18  ///
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
  || if party6num==5, by(area, legend(off) note(""))  ///
  yline(0) ytitle("Counter-factual seats minus realized seats - Linke/PDS") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`=date("1.1.1960","MDY")'(`=5*366')`=date("1.1.2009","MDY")')
graph export grseatshat_ltw_linke.eps, replace

// Other
graph twoway 							///
  || rcap diffUB diffLB eldate if diffUB < 18 & diffLB > -18  ///
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
  || if party6num==6, by(area, legend(off) note(""))  ///
  yline(0) ytitle("Counter-factual seats minus realized seats - Other") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`=date("1.1.1960","MDY")'(`=5*366')`=date("1.1.2009","MDY")')
graph export grseatshat_ltw_other.eps, replace


exit



















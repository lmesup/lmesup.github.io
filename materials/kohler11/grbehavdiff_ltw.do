// Voting behavior of non-Voters for federal elections
// ---------------------------------------------------
// (thewes@wzb.eu)

// Note: This Do-file needs data produced by
//  anmpredltw.do (runs several hours)

version 10
clear all
set memory 200m

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
format eldate %td

merge eldate area party3 using `spdcdu', sort uniqusing nokeep
assert _merge==3
drop _merge
tempfile merged
save `merged'

// Other ones (Joinby)
use elections if area != "DE", clear
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
joinby eldate using `other'

append using `merged'

// Prhatbar for any party
// -----------------------

gen other = party3=="Oth"
by bsample area eldate other, sort: 			/// 
  gen double sumother=sum(ppartyvotes) if other
by bsample area eldate other, sort: 			/// 
  gen double ppartyrescale=ppartyvotes/sumother[_N] if other

ren Phat Phat3
gen double Phat = Phat3 if !other
replace Phat = ppartyrescale * Phat3 if other

by bsample area eldate (party), sort: gen double cumPhat = sum(Phat)
by bsample area eldate (party), sort: assert round(cumPhat[_N],.000001)==1
drop cumPhat other sumother ppartyrescale 


// Graph difference of Non-voters estimators to observed result
// ------------------------------------------------------------

// Aggregate values for 6 major parties
gen str8 party6 = party if inlist(party,"SPD","CDU/CSU","FDP")
replace party6 = "Linke/PDS" if inlist(party,"Linke","PDS","WASG")
replace party6 = "B90/Gr." if inlist(party,"B90","Gruene","B90/Gr")
replace party6 = "Other" if party6 == ""

egen ppartyvotes6 = sum(ppartyvotes), by(bsample area eldate party6)
egen Phat6 = sum(Phat), by(bsample area eldate party6)

egen minPhat6 = pctile(Phat6) if bsample, p(2.5) by(eldate area party6)
egen maxPhat6 = pctile(Phat6) if bsample, p(97.5) by(eldate area party6)

gen diff = (Phat6*100) - ppartyvotes6 if !bsample // Point est. from sample 0
gen diffUB = (maxPhat6*100) - ppartyvotes6 if bsample
gen diffLB = (minPhat6*100) -  ppartyvotes6 if bsample 

// Reduce data size to decrease graph file size
replace bsample = bsample>0
by bsample area eldate party6, sort: keep if _n==1

// Fine tune 
lab def party6 1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "B90/Gr."  /// 
5 "Linke/PDS" 6 "Other"
encode party6, gen(party6num) label(party6)
format %tdYY eldate

// Graph

// CDU
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || scatter diff eldate, ms(O) mlcolor(black) mfcolor(gs12) ///
  || if party6num==1, by(area, legend(off) note(""))  ///
  ylab(-60(20)20) yline(0) ytitle("Non-voters minus voters (in %) - CDU") /// 
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")
graph export grbehavdiff_ltw_cdu.eps, replace

// SPD
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || scatter diff eldate, ms(O) mlcolor(black) mfcolor(gs12) ///
  || if party6num==2, by(area, legend(off) note(""))  ///
  ylab(-60(20)20) yline(0) ytitle("Non-voters minus voters (in %) - SPD") /// 
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")
graph export grbehavdiff_ltw_spd.eps, replace

// FDP
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || scatter diff eldate, ms(O) mlcolor(black) mfcolor(gs12) ///
  || if party6num==3, by(area, legend(off) note(""))  ///
  ylab(-60(20)20) yline(0) ytitle("Non-voters minus voters (in %) - FDP") /// 
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")
graph export grbehavdiff_ltw_fdp.eps, replace

// B90/Gr.
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || scatter diff eldate, ms(O) mlcolor(black) mfcolor(gs12) ///
  || if party6num==4, by(area, legend(off) note(""))  ///
  ylab(-60(20)20) yline(0) ytitle("Non-voters minus voters (in %) - B90/Gr.") /// 
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")
graph export grbehavdiff_ltw_b90.eps, replace

// Linke/PDS
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || scatter diff eldate, ms(O) mlcolor(black) mfcolor(gs12) ///
  || if party6num==5, by(area, legend(off) note(""))  ///
  ylab(-60(20)20) yline(0) ytitle("Non-voters minus voters (in %) - Linke/PDS") /// 
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")
graph export grbehavdiff_ltw_linke.eps, replace

// Other
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || scatter diff eldate, ms(O) mlcolor(black) mfcolor(gs12) ///
  || if party6num==6, by(area, legend(off) note(""))  ///
  ylab(-60(20)20) yline(0) ytitle("Non-voters minus voters (in %)" - Other) /// 
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")
graph export grbehavdiff_ltw_other.eps, replace



exit



// Voting behavior of non-Voters
// -----------------------------
// (kohler@wzb.eu)

// Note: This Do-file needs data produced by
//  anmpred2.do (runs several hours)

version 10

// Global Settings
// ---------------

// Periods
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

// Merge resultsset of anmpred2 and election data
// -----------------------------------------------

// Big ones
use elections if area == "DE", clear
gen party3 = "CDU/CSU" if party == "CDU/CSU"
replace party3 = "SPD" if party == "SPD"
keep if inlist(party3,"CDU/CSU","SPD") 
tempfile spdcdu
save `spdcdu'

use anmpred2_bs, clear
collapse (mean) Phat, by(bsample eldate categ ) // Mean over survey
gen party3 = "SPD" if categ==1
replace party3 = "CDU/CSU" if categ==2
keep if inlist(party3,"CDU/CSU","SPD") 

merge eldate party3 using `spdcdu', sort uniqusing
assert _merge==3
drop _merge
tempfile merged
save `merged'

// Other ones (Joinby)
use elections if area == "DE" & party != "Parteilose", clear
gen party3 = "Oth" if !inlist(party,"CDU/CSU","SPD")
keep if party3=="Oth"
sort eldate
tempfile other
save `other'

use anmpred2_bs, clear
collapse (mean) Phat, by(bsample eldate categ ) // Mean over survey
gen party3 = "Oth" if categ==3
keep if party3=="Oth"
sort eldate
joinby eldate using `other'

append using `merged'

// Prhatbar for any party
// -----------------------

gen other = party3=="Oth"
by bsample eldate other, sort: 			/// 
  gen sumother=sum(ppartyvotes) if other
by bsample eldate other, sort: 			/// 
  gen ppartyrescale=ppartyvotes/sumother[_N] if other

ren Phat Phat3
gen Phat = Phat3 if !other
replace Phat = ppartyrescale * Phat3 if other

by bsample eldate (party), sort: gen cumPhat = sum(Phat)
by bsample eldate (party), sort: assert round(cumPhat[_N],.000001)==1
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

// 1949a -> counterfactual observed distribution of seats
bysort bsample: egen x = prseats(npartyvotes) 			/// 
if year(eldate)==1949  /// unverb. Listen CDU/CSU +1, SPD +1
  , s(400) threshold(5) g(party,"Zentrum","DP","BP","WAV","SSW","DKP/DRP") 	/// 
  method(divisor)
replace seats = x if year(eldate)==1949

// 1949b -> counterfactual estimated distribution of seats
drop x
bysort bsample: egen x = prseats(votes) 			/// 
  if year(eldate)==1949  /// unverb. Listen CDU/CSU +1, SPD +1
  , s(400) threshold(5) g(party,"Zentrum","DP","BP","WAV","SSW","DKP/DRP") 	/// 
  method(divisor)
gen mhat = x if year(eldate)==1949

// 1953
drop x
bysort bsample: egen x = prseats(voteshat) 	/// 
  if year(eldate)==1953  /// CDU/CSU +2,  DP +1
  , s(484) threshold(5) g(party,"Zentrum","DP") method(divisor) 
replace x = x + 2 if party == "CDU/CSU" & year(eldate)==1953
replace x = x + 1 if party == "DP" & year(eldate)==1953
replace mhat = x if mhat==.

// 1957
drop x
bysort bsample: egen x = prseats(voteshat) 	/// 
if year(eldate)==1957  /// CDU/CSU +3
  , s(494) threshold(5) g(party,"DP") method(divisor) 
replace x = x + 3 if party == "CDU/CSU" & year(eldate)==1957
replace mhat = x if mhat==.

// 1961
drop x
bysort bsample: egen x = prseats(voteshat) 	/// 
if year(eldate)==1961  /// CDU/CSU +5 
  , s(494) threshold(5) method(divisor)
replace x = x + 5 if party == "CDU/CSU" & year(eldate)==1961
replace mhat = x if mhat==.

// 1965-1983
drop x
bysort bsample eldate: egen x = prseats(voteshat)  /// 
  if inrange(year(eldate),1965,1983)          /// Note 1
  , s(496) threshold(5) method(divisor)
replace x = x + 1 if party == "SPD" & year(eldate)==1980
replace x = x + 2 if party == "SPD" & year(eldate)==1983
replace mhat = x if mhat==.

// 1987
drop x
bysort bsample: egen x = prseats(voteshat) if year(eldate)==1987 /// CDU/CSU +1
  , s(496) threshold(5) method(hamilton) 
replace x = x + 1 if party == "CDU/CSU" & year(eldate)==1987
replace mhat = x if mhat==.

// 1990
drop x
bysort bsample: egen x = prseats(voteshat) 			/// 
  if year(eldate)==1990	/// getrennte 5% Klausel in Ost/West, 6 CDU/CSU Ueberhang
  , s(656) threshold(5) g(party,"B90/Gr","PDS") method(hamilton)
replace x = x + 6 if party == "CDU/CSU" & year(eldate)==1990
replace mhat = x if mhat==.

// 1994
drop x
bysort bsample eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==1994 /// Note 2
  , s(656) g(party,"PDS") threshold(5) method(hamilton) 
replace x = x + 12 if party == "CDU/CSU" & year(eldate)==1994
replace x = x + 4 if party == "SPD" & year(eldate)==1994
replace mhat = x if mhat==.

// 1998
drop x
bysort bsample eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==1998 /// Note 2
  , s(656) g(party,"PDS") threshold(5) method(hamilton) 
replace x = x + 13 if party == "SPD" & year(eldate)==1998
replace mhat = x if mhat==.

// 2002
drop x
bysort bsample eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==2002 /// CDU/CSU +1, SPD +4
  , s(596) threshold(5)  method(hamilton) 
replace x = x + 1 if party == "CDU/CSU" & year(eldate)==2002
replace x = x + 4 if party == "SPD" & year(eldate)==2002
replace x = 2 if party == "PDS" & year(eldate)==2002
replace mhat = x if mhat==.

// 2005
drop x
bysort bsample eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==2005 ///  SPD +10, CDU/CSU +7
  , s(598) threshold(5)  method(hamilton) 
replace x = x + 7 if party == "CDU/CSU" & year(eldate)==2005
replace x = x + 10 if party == "SPD" & year(eldate)==2005
replace mhat = x if mhat==.
drop x
replace mhat = 0 if mhat==.

replace seats = 0 if seats == .

// Seats in parliament
by bsample eldate (party), sort: gen Shat = sum(mhat)
by bsample eldate (party), sort: replace Shat = Shat[_N]

// Gap closing proportion
// ----------------------

gen str1 W = ""
bysort bsample eldate (seats): replace W = party[_N]

gen str1 Wstar= ""
bysort bsample eldate (mhat regparty): replace Wstar = party[_N]

gen gapclose = W != Wstar


// Coalition loosing majority
// --------------------------

bysort bsample eldate regparty: gen Sstar_C = sum(mhat)
bysort bsample eldate regparty: replace Sstar_C = Sstar_C[_N]

gen















bysort bsample eldate, sort: keep if _n==1
collapse change, by(eldate)











egen minmhat6 = pctile(mhat6) if bsample , p(2.5) by(eldate party6)
egen maxmhat6 = pctile(mhat6) if bsample , p(97.5) by(eldate party6)

gen diff = (mhat6) - seats6 if !bsample
gen diffUB = (maxmhat6) - seats6 if bsample
gen diffLB = (minmhat6) -  seats6 if bsample 

// Reduce data size to decrease graph file size
replace bsample = bsample > 0
by bsample eldate party6, sort: keep if _n==1

// Fine tune 
lab def party6 1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "B90/Gr."  /// 
5 "Linke/PDS" 6 "Other"
encode party6, gen(party6num) label(party6)
format %tdYY eldate

gen arrowUB = cond(diffUB>=18,18,diffUB)
gen arrowLB = cond(diffLB<=-18,-18,diffLB)

// Graph
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
  || , by(party6num, legend(off) note(""))  ///
  yline(0) ytitle("Counter-factual seats minus realized seats") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")

graph export grseatshat.eps, replace

exit



















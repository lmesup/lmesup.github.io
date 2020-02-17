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

merge eldate party3 using `spdcdu', sort uniqusing nokeep
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

levelsof appmethod, local(K)
foreach k of local K {
egen `k' = apport(voteshat) ///
	  if appmethod == "`k'" 			///
	, by(eldate bsample) s(size) threshold(5) e(strpos(grundmandat,party)>0) m(`k')
}
gen mhat  							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton,.))
drop jefferson hamilton



// 1949 counterfactual observed distribution of seats
levelsof appmethod, local(K)
foreach k of local K {
egen `k' = apport(npartyvotes) if year(eldate)==1949 ///
	  & appmethod == "`k'" 			///
	, by(eldate bsample) s(size) threshold(5) e(strpos(grundmandat,party)>0) m(`k')
}
replace seats  							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton,.)) if year(eldate)==1949
drop jefferson hamilton



// 1953 counterfactual observed distribution of seats
levelsof appmethod, local(K)
foreach k of local K {
egen `k' = apport(npartyvotes) if year(eldate)==1953 ///
	  & appmethod == "`k'" 			///
	, by(eldate bsample) s(size) threshold(5) e(strpos(grundmandat,party)>0) m(`k')
}
replace seats  							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton,.)) if year(eldate)==1953
drop jefferson hamilton


// Overhang seats
// --------------

replace seats = seats + 2 if party == "CDU/CSU" & year(eldate)==1953
replace seats = seats + 1 if party == "DP" & year(eldate)==1953
replace mhat = mhat + 2 if party == "CDU/CSU" & year(eldate)==1953
replace mhat = mhat + 1 if party == "DP" & year(eldate)==1953
replace mhat = mhat + 3 if party == "CDU/CSU" & year(eldate)==1957
replace mhat = mhat + 5 if party == "CDU/CSU" & year(eldate)==1961
replace mhat = mhat + 1 if party == "SPD" & year(eldate)==1980
replace mhat = mhat + 2 if party == "SPD" & year(eldate)==1983
replace mhat = mhat + 1 if party == "CDU/CSU" & year(eldate)==1987
replace mhat = mhat + 6 if party == "CDU/CSU" & year(eldate)==1990
replace mhat = mhat + 12 if party == "CDU/CSU" & year(eldate)==1994
replace mhat = mhat + 4 if party == "SPD" & year(eldate)==1994
replace mhat = mhat + 13 if party == "SPD" & year(eldate)==1998
replace mhat = mhat + 1 if party == "CDU/CSU" & year(eldate)==2002
replace mhat = mhat + 4 if party == "SPD" & year(eldate)==2002
replace mhat = 2 if party == "PDS" & year(eldate)==2002
replace mhat = mhat + 7 if party == "CDU/CSU" & year(eldate)==2005
replace mhat = mhat + 9 if party == "SPD" & year(eldate)==2005
replace mhat = mhat + 21 if party == "CDU/CSU" & year(eldate)==2009
replace mhat = mhat + 3 if party == "CDU/CSU" & year(eldate)==2009



// Graph difference of Non-voters estimators to observed result
// ------------------------------------------------------------

// Aggregate values for 6 major parties
gen str8 party6 = party if inlist(party,"SPD","CDU/CSU","FDP")
replace party6 = "Linke/PDS" if inlist(party,"Linke","PDS","WASG")
replace party6 = "B90/Gr." if inlist(party,"B90","Gruene","B90/Gr")
replace party6 = "Other" if party6 == ""

egen seats6 = sum(seats), by(bsample eldate party6)
egen mhat6 = sum(mhat), by(bsample eldate party6)

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
  yline(0) ytitle("Counterfactual seats minus realized seats") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("")

graph export grseatshat.eps, replace

exit



















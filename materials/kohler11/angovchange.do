// Voting behavior of non-Voters
// -----------------------------
// (kohler@wzb.eu)

// Note: This Do-file needs data produced by
// anmpred2.do (runs several hours)

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


// Seats to zero of generated missings
replace mhat = 0 if mi(mhat)
replace seats = 0 if mi(seats)

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

// Seats in parliament
by bsample eldate (party), sort: gen Shat = sum(mhat)
by bsample eldate (party), sort: replace Shat = Shat[_N]


// Explanation-Figure
// ------------------

preserve
keep if year(eldate)==2005
label define pnum 1 "CDU/CSU" 2 "FDP" 5 "SPD" ///
  4 "Gruene" 3 "Linke"  
encode party, g(pnum) label(pnum)

list party mhat seats if bsample==1 & mhat!=0

by eldate bsample (pnum), sort: gen cumseat = sum(mhat)
by eldate bsample (pnum), sort: gen cumseatlag = cumseat[_n-1]
replace cumseatlag = 0 if cumseatlag == .

keep cumseat cumseatlag bsample pnum
reshape wide cumseat cumseatlag, i(bsample) j(pnum)

gen majority = 308

graph twoway 							///
  || rbar cumseat1 cumseatlag1 bsample , horizontal bcolor(gs4)  ///
  || rbar cumseat2 cumseatlag2 bsample , horizontal bcolor(gs2) ///
  || rbar cumseat3 cumseatlag3 bsample , horizontal bcolor(gs14) ///
  || rbar cumseat4 cumseatlag4 bsample , horizontal bcolor(gs10) ///
  || rbar cumseat5 cumseatlag5 bsample , horizontal bcolor(gs12) ///
  || line bsample majority, lcolor(black)  ///
  || , 									/// 
  legend(order(- "Right wing:" 1 "CDU/CSU" 2 "FDP"  /// 
  - " " "Left Wing:" 3 "PDS/Linke" 4 "B90/Gr." 5 "SPD") cols(1) pos(2)  ///
  region(lstyle(none))) 					///
  xline(308, lcolor(black))    			/// 
  ytitle("No. of bootstrap sample") yscale(reverse)  /// 
  ylab(1 25(25)200, angle(0) ) xlabe(0(100)600) 	///
  xtitle(Cumulative number of seats) 		///
  ysize(4)

graph export angovchange.eps, replace

// Winner change hands
// --------------------

restore
gen str1 W = ""
bysort bsample eldate (seats votes): replace W = party[_N]

gen str1 Wstar= ""
bysort bsample eldate (mhat voteshat): replace Wstar = party[_N]

gen gapclose = W != Wstar

// Coalition loosing majority
// --------------------------

bysort bsample eldate regparty: gen Sstar_C = sum(mhat) if regparty
bysort bsample eldate (regparty): replace Sstar_C = Sstar_C[_N]

gen cinsuff = Sstar_C < Shat/2 + 1

// Winner takes all
// ----------------

bysort bsample eldate (mhat voteshat): gen S_Wstar = mhat[_N]
gen Wsuff = S_Wstar >= Shat/2 + 1

// Make a table
// -----------

bysort bsample eldate, sort: keep if _n==1
collapse gapclose cinsuff Wsuff, by(eldate)

foreach var of varlist gapclose-Wsuff {
	replace `var' = `var'*100
}
format %tdMonth_dd,_CCYY eldate
format %3.0f gapclose-Wsuff

listtex eldate gapclose cinsuff Wsuff using angovchange2.tex, replace  ///
  head(`"&\multicolumn{1}{c}{New winner}"'            ///
  `"&\multicolumn{1}{c}{Gov. coal. insuff.}"'    ///
  `"&\multicolumn{1}{c}{Winner suff. alone} \\  "' ///
  `"Election&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{R}>S^*_{W})$}"'  ///
  `"&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{C}<\frac{1}{2}S)$}"'     ///
  `"&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{W^*}>\frac{1}{2}S)$} \\ \hline"')  ///
  end(\\) 					///
  

exit


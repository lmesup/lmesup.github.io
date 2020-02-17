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
// ------------------------------------------------

// Big ones
use elections if area != "DE", clear
gen party3 = "CDU/CSU" if party == "CDU/CSU"
replace party3 = "SPD" if party == "SPD"
keep if inlist(party3,"CDU/CSU","SPD") 
tempfile spdcdu
save `spdcdu'

use anmpred2_bs_ltw, clear
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
sort area eldate
tempfile other
save `other'

use anmpred2_bs_ltw, clear
gen party3 = "Oth" if categ==3
keep if party3=="Oth"
sort area eldate
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

replace seats = 0 if seats=.
replace mhat = 0 if mhat == .


// Seats in parliament
by bsample eldate (party), sort: gen Shat = sum(mhat)
by bsample eldate (party), sort: replace Shat = Shat[_N]

// Explanation-Figure
// ------------------

preserve
keep if year(eldate)==2006 & area=="BE"
label define pnum 1 "CDU/CSU" 2 "FDP" 5 "SPD" ///
  4 "Gruene" 3 "Linke"  
encode party, g(pnum) label(pnum)

list party mhat seats if bsample==1 & mhat!=0

by eldate bsample (pnum), sort: gen cumseat = sum(mhat)
by eldate bsample (pnum), sort: gen cumseatlag = cumseat[_n-1]
replace cumseatlag = 0 if cumseatlag == .

keep cumseat cumseatlag bsample pnum
reshape wide cumseat cumseatlag, i(bsample) j(pnum)

gen majority = 65

graph twoway 							///
  || rbar cumseat1 cumseatlag1 bsample , horizontal bcolor(gs4)  ///
  || rbar cumseat2 cumseatlag2 bsample , horizontal bcolor(gs2) ///
  || rbar cumseat4 cumseatlag4 bsample , horizontal bcolor(gs10) ///
  || rbar cumseat3 cumseatlag3 bsample , horizontal bcolor(gs14) ///
  || rbar cumseat5 cumseatlag5 bsample , horizontal bcolor(gs12) ///
  || line bsample majority, lcolor(black)  ///
  || , 									/// 
  legend(order(- "Right wing:" 1 "CDU/CSU" 2 "FDP"  /// 
  - " " "Left Wing:" 4 "Grüne" 3 "PDS/Linke" 5 "SPD") cols(1) pos(2)  ///
  region(lstyle(none))) 					///
  xline(65, lcolor(black))    			/// 
  ytitle("# of bootstrap sample") yscale(reverse)  /// 
  ylab(1(1)3, angle(0) ) xlabe(0(10)130) 	///
  xtitle(Cum. number of seats) 		///
  ysize(4)

graph export angovchange_ltw.eps, replace

// Winner change hands
// --------------------

restore
gen str1 W = ""
bysort bsample eldate area (seats votes): replace W = party[_N]

gen str1 Wstar= ""
bysort bsample eldate area (mhat voteshat): replace Wstar = party[_N]

gen gapclose = W != Wstar

// Coalition loosing majority
// --------------------------

bysort bsample eldate area regparty: gen Sstar_C = sum(mhat) if regparty
bysort bsample eldate area (regparty): replace Sstar_C = Sstar_C[_N]

gen cinsuff = Sstar_C < Shat/2 + 1

// Winner takes all
// ----------------

bysort bsample eldate area (mhat voteshat): gen S_Wstar = mhat[_N]
gen Wsuff = S_Wstar >= Shat/2 + 1

// Make a table
// -----------

bysort bsample eldate area, sort: keep if _n==1
collapse gapclose cinsuff Wsuff, by(eldate)

foreach var of varlist gapclose-Wsuff {
	replace `var' = `var'*100
}
format %tdMonth_dd,_CCYY eldate
format %3.0f gapclose-Wsuff

listtex eldate gapclose cinsuff Wsuff using angovchange_ltw.tex, replace  ///
  head(`"&\multicolumn{1}{c}{New winner}"'            ///
  `"&\multicolumn{1}{c}{Gov. coal. insuff.}"'    ///
  `"&\multicolumn{1}{c}{Winner suff. alone} \\  "' ///
  `"Election&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{R}>S^*_{W})$}"'  ///
  `"&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{C}<\frac{1}{2}S)$}"'     ///
  `"&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{W^*}>\frac{1}{2}S)$} \\ \hline"')  ///
  end(\\) 					///
  

exit


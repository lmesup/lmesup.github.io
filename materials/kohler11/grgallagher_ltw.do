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
collapse (mean) Phat, by(bsample area eldate categ ) // Mean over survey
gen party3 = "SPD" if categ==1
replace party3 = "CDU/CSU" if categ==2
keep if inlist(party3,"CDU/CSU","SPD") 

merge eldate party3 area using `spdcdu', sort uniqusing nokeep
assert _merge==3
drop _merge
tempfile merged
save `merged'

// Other ones (Joinby)
use elections if area != "DE" & party != "Parteilose", clear
gen party3 = "Oth" if !inlist(party,"CDU/CSU","SPD")
keep if party3=="Oth"
sort eldate area
tempfile other
save `other'

use anmpred2_bs_ltw, clear
collapse (mean) Phat, by(bsample area eldate categ ) // Mean over survey
gen party3 = "Oth" if categ==3
keep if party3=="Oth"
sort eldate area
joinby eldate area using `other'

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
by bsample area eldate: egen x = sum(voteshat)
assert x < nelectorate


// Mandatszuteilung
// ----------------

// counterfactual observed distribution of seats
levelsof appmethod, local(K)
foreach k of local K {
	egen `k' = apport(npartyvotes) ///
	  if appmethod == "`k'" 			///
	  , by(bsample eldate area) s(size) threshold(5)  /// 
	  e(party=="Liste D" | party=="SSW") method(`k')  
}
gen seatscf							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton, ///
    cond(!mi(webster),webster,.)))
drop jefferson hamilton webster

// counterfactual estimated distribution of seats
levelsof appmethod, local(K)
foreach k of local K {
egen `k' = apport(voteshat) ///
	  if appmethod == "`k'" 			///
	  , by(bsample eldate area) s(size) threshold(5) 	/// 
	  e(party=="Liste D" | party=="SSW") m(`k')  
}
gen mhat  							/// 
  = cond(!mi(jefferson),jefferson, ///
    cond(!mi(hamilton),hamilton, ///
    cond(!mi(webster),webster,.)))
drop jefferson hamilton webster


// Graph difference of Non-voters estimators to observed result
// ------------------------------------------------------------

// Aggregate values for 6 major parties
gen str8 party6 = party if inlist(party,"SPD","CDU/CSU","FDP")
replace party6 = "Linke/PDS" if inlist(party,"Linke","PDS","WASG")
replace party6 = "B90/Gr." if inlist(party,"B90","Gruene","B90/Gr")
replace party6 = "Other" if party6 == ""

egen seats6 = sum(seatscf), by(bsample area eldate party6)
egen mhat6 = sum(mhat), by(bsample area eldate party6)

by bsample area eldate party6, sort: keep if _n==1

// Gallagher index
by bsample area eldate: egen S6 = sum(seats6)
by bsample area eldate: egen Shat6 = sum(mhat6)
assert S6 == Shat6

by bsample area eldate, sort: 				/// 
  gen G6 = sum( ((seats6/S6)*100 - (mhat6/Shat6)*100)^2 )  
by area bsample eldate, sort: replace G6 = G6[_N] 

egen minG6 = pctile(G6) if bsample , p(2.5) by(area eldate)
egen maxG6 = pctile(G6) if bsample , p(97.5) by(area eldate)

// Reduce data size to decrease graph file size
replace bsample = bsample > 0
by bsample area eldate, sort: keep if _n==1

// Fine tune 
format %tdYY eldate

// Graph
graph twoway 							///
  || rcap minG6 maxG6 eldate, lcolor(black) 	          			///
  || scatter G6 eldate if !bsample, ms(O) mlcolor(black) mfcolor(gs12) 	///
  || , legend(off)  ///
  ytitle("Gallagher Index") ///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid)) ///
  xtitle("") xlab(`=date("1.1.1960","MDY")'(`=5*366')`=date("1.1.2009","MDY")') ylab(0(20)80) by (area)

graph export grgallagher_ltw.eps, replace

exit



















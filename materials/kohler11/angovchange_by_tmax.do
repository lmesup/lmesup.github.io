// Check variablity by Tmax
// ------------------------
// (kohler@wzb.eu)

// Note: This Do-file needs data produced by
//  anmpred23.do (runs several hours)

version 11
clear all
set memory 500m
set more off

// Copy from crseats 
// =================
// New lines indicated with "-> new"

// Big ones
use elections if area == "DE", clear
gen party3 = "CDU/CSU" if party == "CDU/CSU"
replace party3 = "SPD" if party == "SPD"
keep if inlist(party3,"CDU/CSU","SPD") 
tempfile spdcdu
save `spdcdu'

use anmpred23_bs, clear
collapse (mean) Phat, by(bsample bul eldate categ) // Mean over survey
gen party3 = "SPD" if categ==1
replace party3 = "CDU/CSU" if categ==2
keep if inlist(party3,"CDU/CSU","SPD") 

merge m:1 eldate party3 using `spdcdu', keep(3) nogen
tempfile merged
save `merged'

// Other ones (Joinby)
use elections if area == "DE", clear
gen party3 = "Oth" if !inlist(party,"CDU/CSU","SPD")
keep if party3=="Oth"
sort eldate
tempfile other
save `other'

use anmpred23_bs, clear
collapse (mean) Phat, by(bsample bul eldate categ) // Mean over survey
gen party3 = "Oth" if categ==3
keep if party3=="Oth"
sort eldate
joinby eldate using `other'

append using `merged'

// Prhatbar for any party
// -----------------------

gen other = party3=="Oth"
by bsample bul eldate other, sort: 			/// 
  gen sumother=sum(ppartyvotes) if other
by bsample bul eldate other, sort: 			/// 
  gen ppartyrescale=ppartyvotes/sumother[_N] if other

ren Phat Phat3
gen Phat = Phat3 if !other
replace Phat = ppartyrescale * Phat3 if other
label variable Phat "Counterfactual voting probability for party"

by bsample bul eldate (party), sort: gen double cumPhat = sum(Phat)
by bsample bul eldate (party), sort: assert round(cumPhat[_N],.000001)==1
drop cumPhat other sumother ppartyrescale Phat3 party3 categ

label variable bul "Region"

// Loop over various settings of Tmax
// ----------------------------------

tempfile start
save `start'

forv tmax = 91(1)100 {               // -> new


	// Voteshat Nonvoter
	// -----------------

	gen L = `tmax' - pvalid         // -> new
	label variable L "Levarage at `round(=r(max),.01)'"

	gen npartyvoteshat_nonvoter = Phat * L/100 * nelectorate
	label variable npartyvoteshat_nonvoter "Nonvonter's votes for party"

	// Voteshat
	// --------

	gen voteshat = npartyvotes + npartyvoteshat_nonvoter
	assert voteshat < nelectorate
	label variable voteshat "Votes (voters and nonvoters)"

	// Mandatszuteilung 1949
	// ---------------------

	preserve

	keep if year(eldate)==1949

	// "Oberverteilung"
	gen district = 52  if bul==6     // minus 2 Parteilose
	replace district = 78  if bul==5  
	replace district =  4+13+22  if bul==1 // minus 1 Parteiloser in SH
	replace district = 36  if bul==4 
	replace district = 58  if bul==2
	replace district = 109 if bul==3  
	replace district = 25  if bul==7  
	
	// "Unterverteilung" hat
	egen districtmhat 			   /// 
	  = apport(voteshat) 		   ///
	  if party != "Parteilose"     ///
	  , size(district) by(bsample bul) t(5) m(jefferson)  
	
	// "Unterverteilung" artificial "real"
	egen districtseats 			   /// 
	  = apport(npartyvotes) 		   ///
	  if party != "Parteilose"     ///
	  , size(district) by(bsample bul) t(5) m(jefferson)  
	
	replace districtmhat = 1 if party=="Parteilose" & bul==1
	replace districtmhat = 2 if party=="Parteilose" & bul==6
	replace districtseats = 1 if party=="Parteilose" & bul==1
	replace districtseats = 2 if party=="Parteilose" & bul==6
	
	// Aggregate
	by bsample party, sort: egen mhat = sum(districtmhat)
	by bsample party, sort: egen x = sum(districtseats)
	replace seats = x
	by bsample party (bul), sort: keep if _n==1
	drop district* x
	
	sum bul, meanonly
	assert r(min)==1 & r(max)==1
	drop bul
	
	tempfile 49
	save `49'
	
	// Mandatszuteilung 1953
	// ---------------------
	
	restore, preserve
	keep if year(eldate)==1953 & party != "Parteilose"
	
	// "Oberverteilung"
	gen district = 67  if bul==6     // minus 2 Parteilose
	replace district = 91  if bul==5  
	replace district = 6+17+24  if bul==1  
	replace district = 44  if bul==4  
	replace district = 66  if bul==2  
	replace district = 138 if bul==3  
	replace district = 31  if bul==7  
	
	// "Unterverteilung" hat
	egen districtmhat 			       /// 
	  = apport(voteshat) 		   ///
	  if party != "BP" ///
	  , size(district) by(bsample bul) t(5)  		///
	  e(strpos(grundmandat,party)>0)
	
	// "Unterverteilung" artificial "real"
	egen districtseats 			       /// 
	  = apport(npartyvotes) 		   ///
	  if party != "BP" ///
	  , size(district) by(bsample bul) t(5)  		///
	  e(strpos(grundmandat,party)>0)
	
	// Aggregate
	by bsample party, sort: egen mhat = sum(districtmhat)
	by bsample party, sort: egen x = sum(districtseats)
	replace seats = x
	by bsample party (bul), sort: keep if _n==1
	drop district* x
	
	sum bul, meanonly
	assert r(min)==1 & r(max)==1
	drop bul
	
	tempfile 53
	save `53'
	
	// All other years
	// ---------------
	
	restore
	keep if year(eldate)>1953 & party != "Parteilose"
	assert bul==0
	drop bul
	
	levelsof appmethod, local(K)
	foreach k of local K {
		egen `k' = apport(voteshat) ///
		  if appmethod == "`k'" 		///
		  , by(eldate bsample) s(size) threshold(5) e(strpos(grundmandat,party)>0) m(`k')
	}
	gen mhat = jefferson if appmethod == "jefferson"
	replace mhat = hamilton if appmethod == "hamilton"
	replace mhat = webster if appmethod == "webster"
	drop jefferson hamilton webster
	
	// Clean up
	// ---------
	
	// Append years
	append using `49'
	append using `53'
	
	// Seats to zero of generated missings
	replace mhat = 0 if mi(mhat)
	replace seats = 0 if mi(seats)
	
	// Overhang seats
	// --------------
	
	// Überhangmandate
	replace mhat = mhat + 1 if party == "CDU/CSU" & year(eldate)==1949
	replace mhat = mhat + 1 if party == "SPD" & year(eldate)==1949 
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
	label variable mhat "Counterfactual number of seats"
	
	// Überhangmandate Counterfactual real elections '49 + '53
	replace seats = seats + 1 if party == "CDU/CSU" & year(eldate)==1949
	replace seats = seats + 1 if party == "SPD" & year(eldate)==1949 
	replace seats = seats + 2 if party == "CDU/CSU" & year(eldate)==1953
	replace seats = seats + 1 if party == "DP" & year(eldate)==1953
	
	// Check results
	bysort bsample eldate: egen S = sum(seats)
	by bsample eldate: egen Shat = sum(mhat)
	assert S == Shat
	drop S Shat
	
	// Aggregate values for 6 major parties
	// ------------------------------------
	
	gen str8 party6 = party if inlist(party,"SPD","CDU/CSU","FDP")
	replace party6 = "Linke/PDS" if inlist(party,"Linke","PDS","WASG")
	replace party6 = "B90/Gr." if inlist(party,"B90","Gruene","B90/Gr")
	replace party6 = "Other" if party6 == ""
	label variable party6 "Party (6 largest)"
	
	egen seats6 = sum(seats), by(bsample eldate party6)
	egen mhat6 = sum(mhat), by(bsample eldate party6)
	label variable seats6 "No. of seats for 6 largest parties"
	label variable mhat6 "No. of counterfactual seats for 6 largest parties"
	
	egen minmhat6 = pctile(mhat6) if bsample , p(2.5) by(eldate party6)
	egen maxmhat6 = pctile(mhat6) if bsample , p(97.5) by(eldate party6)
	label variable minmhat6 "Upper bound of 95% confidence intervall around mhat"
	label variable maxmhat6 "Lower bound of 95% confidence intervall around mhat"
	
	gen diff = mhat6 - seats6 if !bsample
	gen diffUB = maxmhat6 - seats6 if bsample
	gen diffLB = minmhat6 -  seats6 if bsample 
	label variable diff  "Counterfactual seats minus real seats"
	label variable diffUB "Upper bound of 95% confidence intervall around diff"
	label variable diffLB "Lower bound of 95% confidence intervall around diff"
	
	format %tdYY eldate
	
	compress

	// Copy from angovchange3.do
	// =========================

	// Seats in parliament
	by bsample eldate (party), sort: gen Shat = sum(mhat)
	by bsample eldate (party), sort: replace Shat = Shat[_N]

	// Winner change hands
	// --------------------
	
	gen str1 W = ""
	bysort bsample eldate (seats votes): replace W = party[_N]
	
	gen str1 Wstar= ""
	bysort bsample eldate (mhat voteshat): replace Wstar = party[_N]
	
	gen gapclose = W != Wstar
	
	// Coalition loosing majority
	// --------------------------
	
	bysort bsample eldate regparty: gen Sstar_C = sum(mhat) if regparty
	bysort bsample eldate (regparty): replace Sstar_C = Sstar_C[_N]
	
	gen cinsuff = Sstar_C < floor(Shat/2) + 1
	
	// Winner takes all
	// ----------------
	
	bysort bsample eldate (mhat voteshat): gen S_Wstar = mhat[_N]
	gen Wsuff = S_Wstar >= floor(Shat/2) + 1
	
	// Keep small files
	// ----------------
	
	bysort bsample eldate, sort: keep if _n==1
	collapse gapclose cinsuff Wsuff, by(eldate)

	foreach var of varlist gapclose-Wsuff {
		replace `var' = `var'*100
	}

	gen Tmax = `tmax'
	
	tempfile f`tmax'
	save `f`tmax''

	use `start', clear
}

// Append files
// ------------

use `f92', clear
forv i = 93(1)100 {
	append using `f`i''
}
	
// Reshape long
// ------------

ren gapclose p1
ren cinsuff p2
ren Wsuff p3

gen index = _n
reshape long p, i(index) j(criterium)

label define criterium  ///
  1 "New winner" 2 "Gov. coal. insuff" 3 "Winner suff. alone"
label value criterium criterium

gen x = Tmax-95.5
gen circx = eldate + x*100
format circx %tdYY

levelsof eldate, local(K)
foreach k of local K {
	local lines `lines' || line p circx  ///
	  if eldate == `k', lcolor(black..) lpattern(solid dash dot) sort
}

graph twoway `lines' ///
  || ,  ///
  xlab(`K') by(criterium, rows(3) legend(off) note("")) ///
  xtitle("") ytitle("Pr({&Delta}O)")

graph export angovchange_by_tmax.eps, replace

exit


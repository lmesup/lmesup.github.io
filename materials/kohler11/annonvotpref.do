// Preferences of non-voters
// kohler@wzb.eu

version 10
set scheme s1mono

use btwsurvey, clear

*quietly {

	// Dummies
	foreach var of varlist 					///
	  agegroup emp occ edu bul mar denom {
		tab `var', gen(`var')
	}
	
	// Predicit voting behavior of non-voters
	tempname results
	tempfile x
	postfile `results' eldate str3 party delta using `x'
	levelsof eldate, local(K)
	foreach k of local K {
		mlogit party agegroup2 agegroup3 occ2-occ4 edu2 edu3 bul2-bul7 	///
		  mar2 mar3 denom2 denom3 if eldate==`k'
		predict PhatCDU PhatSPD PhatOth if eldate == `k'
		
		reg PhatSPD voter
		post `results' (`k') ("CDU"') (-_b[voter])
		reg PhatCDU voter
		post `results' (`k') ("SPD"') (-_b[voter])
		reg PhatOth voter
		post `results' (`k') ("Oth"') (-_b[voter])
		drop Phat*
	}
	postclose `results'
*}

use btw if area=="DE", clear
replace party = "CDU" if party == "CSU"
replace party = "Oth" if !inlist(party,"CDU","SPD")
by eldate party, sort: replace npartyvotes = sum(npartyvotes)
by eldate party, sort: replace npartyvotes = npartyvotes[_N]
by eldate party, sort: keep if _n==1

gen ppartyvotes = (npartyvotes/nvalid)*100
keep eldate party ppartyvotes
sort eldate party

merge eldate party using `x', sort
assert _merge==3
drop _merge

gen ppartynonvotes = ppartyvotes + delta*100

graph twoway 							///
  || pcarrow ppartyvotes eldate ppartynonvotes eldate  	///
  , lcolor(black) mcolor(black) 		///
  || connected ppartyvotes eldate if party == "CDU"  ///
  , ms(O) mcolor(black)                 ///
  || connected ppartyvotes eldate if party == "SPD"  ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || connected ppartyvotes eldate if party == "Oth"  ///
  , ms(O) mlcolor(black) mfcolor(gs8)  ///









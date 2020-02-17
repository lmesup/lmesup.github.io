// Create seats from Models
// ------------------------
// (kohler@wzb.eu)

// Note: This Do-file needs data produced by
//  anmpred23.do (runs several hours)

version 11
clear all
set memory 500m

// Merge resultsset of anmpred2 and election data
// -----------------------------------------------

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

merge eldate party3 using `spdcdu', sort uniqusing nokeep
assert _merge==3
drop _merge
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

// Voteshat Nonvoter
// -----------------

sum pvalid
gen L = ceil(r(max)) - pvalid
label variable L "Levarage at `round(=r(max),.01)'"

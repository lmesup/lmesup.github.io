// Probability of Government change
// --------------------------------
// (kohler@wzb.eu)

version 11

// Global Settings
// ---------------

// Periods
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

use seats, clear

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

// Make a table
// ------------

bysort bsample eldate, sort: keep if _n==1
collapse gapclose cinsuff Wsuff, by(eldate)

foreach var of varlist gapclose-Wsuff {
	replace `var' = `var'*100
}
format %tdMonth_dd,_CCYY eldate
format %3.0f gapclose-Wsuff

listtex eldate gapclose cinsuff Wsuff using angovchange3.tex, replace  ///
  head(`"&\multicolumn{1}{c}{New winner}"'            ///
  `"&\multicolumn{1}{c}{Gov. coal. insuff.}"'    ///
  `"&\multicolumn{1}{c}{Winner suff. alone} \\  "' ///
  `"Election&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{R}>S^*_{W})$}"'  ///
  `"&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{C}<\frac{1}{2}S)$}"'     ///
  `"&\multicolumn{1}{c}{$\widehat{\text{Pr}}(S^*_{W^*}>\frac{1}{2}S)$} \\ \hline"')  ///
  end(\\) 					///
  

exit


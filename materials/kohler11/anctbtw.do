// A Summary table of impact probability
// -------------------------------------
// kohler@wzb.eu

set scheme s1mono

version 10
use btw if area == "DE", clear
by eldate ngroupvotes, sort: keep if _n==1


// K
ren ngroups1 K

// L
sum pvalid
local maxturn = r(max)
gen L = `maxturn' - pvalid
replace L = L/100 * nelectorate

// W, R, O
by eldate (ngroupvotes), sort: gen W = ngroupvotes[_N]
by eldate (ngroupvotes): gen R = ngroupvotes[_N-1]
by eldate (ngroupvotes): gen O = sum(ngroupvotes) if _n<(_N-1)
by eldate (ngroupvotes): replace O = O[_N-2]
replace O = O/nvalid

by eldate: keep if _n==_N

// Calculate tipping point
gen t = (W + L * O - R + L * (1-O)) / (2 * L)
assert abs(round((R + (t-O) * L) - (W +  (1-t-O) * L)),1) <= 1 if t != .
replace t = . if t > 1

// tstar
gen tstar = (1 - t - O)

// observed diff
replace W = 100 * (W/nvalid)
replace R = 100 * (R/nvalid)
gen diff = R - W

// neccessary difference
replace L = L/nelectorate

foreach var of varlist t tstar L O {
	replace `var' = `var' * 100
}

format %2.0f diff L pvalid W R 
sort eldate

tostring t tstar O, replace force format(%2.0f)

replace t = "$>$100" if t == "."
replace tstar = "$<$0" if tstar == "." | strpos(tstar,"-")


listtex eldate pvalid L K W R diff t tstar O  ///
  using anctbtw.tex  ///
  , replace rstyle(tabular) 	///
  head( ///
  "\begin{tabular}{lccccccccc}\hline" ///
  " & \multicolumn{6}{c|}{Observed quantities}&\multicolumn{2}{c}{To close the gap ...}\\ " ///
  " & Turnout of  & Lever- & Parties & Winnner & Runner up & \multicolumn{1}{c|}{Gap}& runner up & leader should  &               \\ "  ///
  "Election   & valid voters& age    & $>1$\%. & \% & \%     & \multicolumn{1}{c|}{1st-2nd} &  needs    & gain $\leq$ & Assumed others  \\ \hline" ) ///
  end("\\") ///
  foot("\hline \\" ///
  "\end{tabular}") 			///  


exit













exit









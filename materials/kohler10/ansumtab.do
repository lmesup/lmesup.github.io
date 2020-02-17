// A Summary table of impact probability
// -------------------------------------
// kohler@wzb.eu

version 10
clear

// Input ESS and Office
input str2 iso3166 str11 es str6 off
AT "List PR"  "Seats"  
BE "List PR"  "Seats"  
BG "List PR"  "Seats"  
CH "List PR"  "Seats"  
CY "List PR"  "Person" 
CZ "List PR"  "Seats"  
DE "MMP"      "Seats"  
DK "List PR"  "Seats"  
EE "List PR"  "Seats"  
ES "List PR"  "Seats"  
FI "List PR"  "Person" 
FR "TRS"      "Person" 
GB "FPTP"     "Seats"  
GR "List PR"  "Seats"  
HU "MMP"      "Seats"  
IE "STV"      "Seats"  
IT "List PR"  "Seats"  
LT "Parallel" "Person" 
LU "List PR"  "Seats"  
LV "List PR"  "Seats"  
MT "STV"      "Seats"  
NL "List PR"  "Seats"  
NO "List PR"  "Seats"  
PL "List PR"  "Person" 
PT "List PR"  "Seats"  
RO "List PR"  "Person" 
SE "List PR"  "Seats"  
SI "List PR"  "Seats"  
SK "List PR"  "Seats"  
US "FPTP"     "Person" 
end

// Merge to Election Meta-Data
sort iso3166
compress
tempfile system
save `system'
use elections2, clear
sort iso3166
merge iso3166 using `system'
assert _merge==3
drop _merge

// From NP
gen pvotes = (nvotes/nvalid)
bysort election: gen nparty_ge1 = sum(pvotes>=.01) if !mi(pvotes)
bysort election: replace nparty_ge1 = nparty_ge1[_N]
sum nparty_ge1, meanonly
gen pimp_np = 1-nparty_ge1/r(max)

// From Leverage, i.e. rescaled Leverage - d/(d+1) 
// (see Note 1)
by election: gen sumvotes = sum(nvotes)
by election: replace nvalid = sumvotes[_N] if mi(nvalid)

sort election nvotes // Do not change this line!

gen turnout = nvoters/nelectorate
gen vturnout = nvalid/nelectorate
gen pinvalid = ninvalid/nelectorate

sum pinvalid if inlist(iso3166,"BE","CY","LU")
gen addinvalid = cond((r(mean) - pinvalid)>0,r(mean) - pinvalid,0)
replace addinvalid = 					///  
 1 - (vturnout+pinvalid) if (vturnout + pinvalid + addinvalid) >= 1

sum turnout if inlist(iso3166,"BE","CY","LU")
gen absvoters = cond( ///
  vturnout+pinvalid+addinvalid + (1-r(mean)) <= 1, ///
  1-r(mean), ///
  1-(vturnout+pinvalid+addinvalid) ///
  )

gen leverage = 1-(vturnout+pinvalid+addinvalid+absvoters)

by election (nvotes): gen pvote1st = pvotes[_N]
by election (nvotes): gen pvote2nd = pvotes[_N-1]
gen pimp_lev = leverage - (pvote1st - pvote2nd)/(pvote1st - pvote2nd + 1)
replace pimp_lev = 0 if pimp_lev < 0
sum pimp_lev, meanonly
replace pimp_lev = pimp_lev/r(max)


by election: keep if _n==_N

// Difference in attitudes (ISSP and ESS)
preserve
use v3 v201 v258 v297 using $issp/za3950_f1, clear
drop if v201 < 18
decode v3, gen(x)
gen cntry = upper(substr(x,1,2))
replace cntry = "BE" if strpos(x,"Flanders")
gen voter:dummy = v297 == 1 if inrange(v297,1,2)
gen left = inlist(v258,1,2) if v258 != 3 & v258 < 5
gen survey = "ISSP"
keep survey cntry voter left 
compress
tempfile issp
save `issp'

use cntry voter leftright using ess04_1
gen left = inlist(leftright,0,1,2,3,4) if leftright!=5 & !mi(leftright)
gen survey = "ESS"
drop leftright
append using `issp'

drop if voter == .

tempfile ineq
tempname post
postfile `post' str2 iso3166 pimp_ineq using `ineq'
levelsof cntry, local(K)
foreach k of local K {
	quietly {
		count if cntry=="`k'" & survey == "ESS"
		local svy = cond(r(N)>0,"ESS","ISSP")
		capture reg left voter if cntry == "`k'"& survey == "`svy'"
		if _rc local coef = .
		else local coef = abs(_b[voter])
		count if left != . & cntry=="`k'" & survey == "`svy'"
		local num = r(N)
		count if cntry=="`k'" & survey == "`svy'"
		local denom = r(N)
		post `post' ("`k'") (`coef' * `num'/`denom')
	}
}
postclose `post'
restore

merge iso3166 using `ineq', sort nokeep
drop _merge

gen order = log(pimp_np+1) + log(pimp_lev+1) + log(pimp_ineq+1)
sort order

format %3.2f pimp* order

listtex ctrname es off pimp_np pimp_lev pimp_ineq order ///
  using ansumtab.tex  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{lccccc|c}\hline" ///
  "        &Election&Office  &  &  &   \\ "  ///
  "Country &System  &at stake&NP&TO&DV& Order \\ \hline") ///
  foot("\hline \end{tabular}") end("\\")

exit

Note 1
------

Let Y and X be the vote proportion of two parties. Define D as the
difference between both parties, i.e.

D = Y - X

Further assume that L is the Leverage. If all non-voters vote for
the same party the new porportion of this gaining party can be expressed as

X_new = X*(1-L) + L  (1)

and the proportion of the other party will be

Y_new = Y*(1-L)       (2)

Problem: How large must L be that the difference between X_new and
Y_new gets zero? This is the case if (1) - (2) is zero. If we use
X=Y-D, we can write

(Y-D)(1-L) + L - Y(1-L) = 0

which can be transformed to

Y - YL - D + DL + L - Y + YL = 0
                - D + DL + L = 0
                      DL + L = D
                      L(D+L) = D                              
                           L = D/(D+1)


Hence, for the limiting case that all non-voters vote for one party,
the Leverage should be at list D/(D-1) to get a change in electoral
outcome.












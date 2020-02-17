// A Summary table of impact probability
// -------------------------------------
// kohler@wzb.eu

set scheme s1mono

version 10
use elections2, clear

// np
gen pvotes = (nvotes/nvalid)
bysort election: gen K = sum(pvotes>=.01) if !mi(pvotes)
bysort election: replace K = K[_N]

// L
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

gen L = 1-(vturnout+pinvalid+addinvalid+absvoters)
replace L = 0 if L < 0

replace L = L*nelectorate

// n_1, n_2
by election (nvotes): gen W = nvotes[_N]
by election (nvotes): gen R = nvotes[_N-1]
by election (nvotes): gen O = sum(nvotes) if _n<(_N-1)
by election (nvotes): replace O = O[_N-2]
replace O = O/nvalid

by election: keep if _n==_N

// Calculate tipping point
gen t = (W + L* (1-O) - R) / (2 * L)
assert abs(round((R + t* L) - (W +  (1-t-O) * L)),1) <= 1 if t != .
replace t = . if t > 1

// tstar
gen tstar = (1 - t - O)
assert float(t + tstar + O) == 1 if t != .

// diffindex
replace W = 100 * (W/nvalid)
replace R = 100 * (R/nvalid)

// Gap
gen gap = W - R
format gap  %2.0f
sum gap


gen twobiggest = W + R
sort twobiggest


format W R twobiggest %3.0f
l iso3166 W R twobiggest, noobs
sum twobiggest








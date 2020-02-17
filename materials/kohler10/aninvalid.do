// Describe Election Metadata extensivly

version 10
set scheme s1mono

use elections, clear

by election: gen sumvotes = sum(nvotes)
by election: replace nvalid = sumvotes[_N] if mi(nvalid)

sort election nvotes // Do not change this line!

gen turnout = nvoters/nelectorate * 100
gen vturnout = nvalid/nelectorate * 100
gen pinvalid = ninvalid/nelectorate*100

sum pinvalid if inlist(iso3166,"BE","CY","LU")
gen addinvalid = cond((r(mean) - pinvalid)>0,r(mean) - pinvalid,0)
replace addinvalid = 100 - (vturnout+pinvalid) if (vturnout + pinvalid + addinvalid) >= 100

sum turnout if inlist(iso3166,"BE","CY","LU")
gen absvoters = cond( ///
  vturnout+pinvalid+addinvalid + (100-r(mean)) <= 100, ///
  100-r(mean), ///
  100-(vturnout+pinvalid+addinvalid) ///
  )

gen leverage = 100-(vturnout+pinvalid+addinvalid+absvoters)

gen pvotes = (nvotes/nvalid)*100
by election: gen nparty_ge1 = sum(pvote>=1) if !mi(pvote)
by election: gen nparty_ge5 = sum(pvote>=5) if !mi(pvote)
by election: gen nparty_withseats = sum(nseats>=1) if !mi(nseats)

by election (nvotes): gen pvote1st = pvotes[_N]
by election (nvotes): gen pvote2nd = pvotes[_N-1]

by election (nvotes): egen pmedian = median(pvotes) if pvotes >= 1

gen closeness = pvote1st - pmedian

by election: keep if _n==_N

format turnout pinvalid vturnout leverage pvote* pmedian closeness %3.1f
sort turnout

gen rowname = ctrname + " (" + string(eldate,"%tdDD_Mon_CCYY") + ")"

gen mlabpos = 12 if pinvalid > 1
replace mlabpos = 6 if pinvalid <= 1
replace mlabpos = 7 if iso3166 == "LV" 
replace mlabpos = 6 if iso3166 == "CZ" 
replace mlabpos = 1 if iso3166 == "EE" 
replace mlabpos = 8 if iso3166 == "LV" 
replace mlabpos = 3 if iso3166 == "HU"
replace mlabpos = 6 if iso3166 == "GB"
replace mlabpos = 6 if iso3166 == "CH"
replace mlabpos = 6 if iso3166 == "SK"
replace mlabpos = 6 if iso3166 == "PL"
replace mlabpos = 6 if iso3166 == "DE"
replace mlabpos = 3 if iso3166 == "LU"
replace mlabpos = 9 if iso3166 == "US"
replace mlabpos = 12 if iso3166 == "FI"

graph twoway 							///
  || scatter pinvalid turnout, mlab(iso3166) mlabvpos(mlabpos) mcolor(black) ///
  || lowess pinvalid turnout, lcolor(black)  ///
  || lowess pinvalid turnout if !inlist(iso3166,"LU","BE","CY")  /// 
  , lcolor(black) lpattern(dash)  ///
  || lfit pinvalid turnout, lcolor(black)  ///
  || lfit pinvalid turnout if !inlist(iso3166,"LU","BE","CY")  ///
  , lcolor(black) lpattern(dash) ///
  , legend(off) note("Line is LOWESS with bw = 0.8", span)  ///
  ytitle("Invalid votes (in %)") xtitle("Turnout (in %)")  ///
  xlab(40(10)100) xtick(40(5)100) ytick(0(0.5)5)




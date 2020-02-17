// Describe Election Metadata extensivly

version 10
set scheme s1mono

use elections, clear

// 1 country per row
by election, sort: gen sumvotes = sum(nvotes)
by election: replace nvalid = sumvotes[_N] if mi(nvalid)
by election: keep if _n==_N

// Turnout and Invalid votes
gen turnout = nvoters/nelectorate * 100
gen vturnout = nvalid/nelectorate * 100
gen pinvalid = ninvalid/nelectorate * 100

// Invalid votes in compulsory voting countries
sum pinvalid if inlist(iso3166,"BE","CY","LU") 
local compinv = r(mean)

// Absend votes in compulsroy voting systems
sum turnout if inlist(iso3166,"BE","CY","LU")
local compabs = r(mean)

// Additional invalid votes due to compulsory voting
gen addinvalid = cond((`compinv' - pinvalid)>=0,`compinv' - pinvalid,0)
replace addinvalid = 100 - (vturnout+pinvalid) 	/// 
  if (vturnout + pinvalid + addinvalid) >= 100

// Absent Voters
gen absvoters = cond( ///
  vturnout+pinvalid+addinvalid + (100-`compabs') <= 100, ///
  100-`compabs', ///
  100-(vturnout+pinvalid+addinvalid) ///
  )

// Leverage
gen leverage = 100-(vturnout+pinvalid+addinvalid+absvoters)


// Fake Median country
sum pinvalid if !inlist(iso3166,"BE","CY","LU"), meanonly
local mpinvalid = r(mean)
sum absvoters if !inlist(iso3166,"BE","CY","LU"), meanonly
local mabsvoters= r(mean)
sum addinvalid if !inlist(iso3166,"BE","CY","LU"), meanonly
local maddinvalid= r(mean)
sum leverage if !inlist(iso3166,"BE","CY","LU"), meanonly
local mleverage= r(mean)
set obs `=_N+1'
replace ctrname = "Mean" in -1
replace absvoters = `mabsvoters' in -1
replace pinvalid = `mpinvalid' in -1
replace addinvalid = `maddinvalid' in -1
replace leverage = `mleverage' in -1

replace leverage = 0 if inlist(iso3166,"LU","CY","BE")
encode ctrname, gen(ctrnum) 
egen axis = axis(leverage ctrnum), label(ctrnum) reverse

format leverage %2.0f
sort axis
levelsof axis, local(lab)

graph twoway ///
  || bar leverage axis if ctrname != "Mean" 	///
  , horizontal barwidth(0.7) bcolor(black) 		///
  || bar leverage axis if ctrname == "Mean" 	///
  , horizontal barwidth(0.7) bfcolor(white) blcolor(black) 		///
  || scatter axis leverage, ms(i) mlab(leverage) mcolor(black) mlabpos(3)  ///
  || ,  ylabel(`lab', valuelabel angle(0)) 	/// 
  xlabel(0(10)100, format(%3.0f) grid)  ///
  ytitle("") legend(off) ///
  xtitle(Leverage in %) ysize(6.5)  ///
  xscale(range(0 108))

graph export grlevbycntry2_1.eps, replace


exit


Leverage is calculated as the registered electorate minus turnout,
absent e;lectors and invalid votes. Turnout is as reported in Figure
1. As explained in the text, under conditions of maximum turnout
absent electors are estimted at 9.3 percent and invalid vote at 4.9
percent.

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

// From Office
gen offnum = off == "Seats"

// Form ES
gen esnum = es != "FPTP"

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

by offnum  (iso3166), sort: gen noff = _n
graph twoway 							/// 
  || scatter noff offnum if iso3166 != "US"  ///
  , ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter noff offnum if iso3166 == "US", ms(O) mcolor(black)  	///
  || pcarrowi 8 -0.3 7.01 -0.05, lcolor(black) mcolor(black)  ///
  || scatteri 8 -0.3 "US", mlabpos(12) mlabcolor(black) ms(i) ///
  xlab(0 `""One executive""Office""' 1 `""Seats in a""Parliament""')  ///
  legend(off) xtitle("") xscale(range(-0.5 1.5)) xsize(3)  ///
  ylabe(0(5)30) 						///
  title(Office, box pos(12) bexpand) 		///
  name(g1, replace) nodraw

by esnum (iso3166), sort: gen nes = _n
graph twoway 							/// 
  || scatter nes esnum if iso3166 != "US"  ///
  , ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter nes esnum if iso3166 == "US", ms(O) mcolor(black)  	///
  || pcarrowi 3 -0.3 2.01 -0.01, lcolor(black) mcolor(black)  ///
  || scatteri 3 -0.3 "US", mlabpos(12) mlabcolor(black) ms(i) ///
  xlab(0 `""FPTP""' 1 `""Other""Election Sytems""')  ///
  legend(off) xtitle("") xscale(range(-0.5 1.5)) xsize(3)  ///
  ylabe(0(5)30) 						///
  title(Election System, box pos(12) bexpand) 		///
  name(g2, replace) nodraw

replace leverage = leverage * 100
sum leverage if iso3166=="US"
graph twoway 							/// 
  || kdensity leverage, lcolor(black)  ///
  || scatteri .005 `=r(mean)' "US", ms(i) mlabpos(2)  ///
  legend(off) xtitle("Leverage") xsize(3)  ///
  xline(`=r(mean)') xlabel(1(10)40) 	///
  title(Leverage, box pos(12) bexpand) 		///
  name(g3, replace) nodraw


by nparty_ge1 (iso3166), sort: gen nparty = _n
graph twoway 							/// 
  || scatter nparty nparty_ge1 if iso3166 != "US"  ///
  , ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter nparty nparty_ge1 if iso3166 == "US", ms(O) mcolor(black)  	///
  || pcarrowi 3 1 2.02 1.98, lcolor(black) mcolor(black)  ///
  || scatteri 3 1 "US", mlabpos(12) mlabcolor(black) ms(i) ///
  legend(off) xtitle("Number of Parties") xscale(range(0 13)) xsize(3)  ///
  ylabe(0(1)8) xlab(2(2)12) 			///
  title(Number of parties, box pos(12) bexpand) 		///
  name(g4, replace) nodraw

graph combine g1 g2 g3 g4




exit




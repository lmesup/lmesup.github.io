// A Summary table of impact probability
// -------------------------------------
// kohler@wzb.eu

set scheme s1mono

version 11
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

// Distributable Leverage
replace L = L/nelectorate
gen availL = L - O*L

gen trescale = t/(t+tstar)

foreach var of varlist t tstar availL O trescale {
	replace `var' = `var' * 100
}

gen diff = (abs(R-t) + abs(W-tstar))/2

gen impossible = t >= 100 | tstar <= 0
gsort impossible trescale

format %2.0f diff L availL W R trescale
tostring t tstar, replace force format(%2.0f)

replace t = "-" if t == "."
replace tstar = "$<$0" if strpos(tstar,"-")
replace tstar = "-" if tstar == "."

gen mlabel = "+{&infin}"

gen fifty = 50
gen background = 100
gen tfigure = cond(!mi(trescale),trescale,200)
egen axis = axis(tfigure availL ctrname), reverse label(ctrname)
replace trescale = 100 if trescale > 100
graph twoway ///
  || bar background axis if !mi(trescale) 				///
  , horizontal fcolor(black) lcolor(black) lstyle(p1) barwidth(0.7) 	///
  || bar trescale axis if !mi(trescale)					///
  , horizontal fcolor(white) lcolor(black) lstyle(p1) barwidth(0.7) 	///
  || scatter axis trescale if trescale==100, ms(i) mlab(mlabel) mlabpos(3)	///
  || line axis fifty 					///
  , sort lcolor(gs8) 	///
  || , ylabel(1/30, valuelabel angle(0) noticks)  /// 
  xtitle(Share of avail. leveraged vote runner up needs to win, size(*.85)) xscale(range(0 107))  ///
  xlabel(0(20)100, format(%3.0f))  ///
  ytitle("") legend(off) ///
  ysize(6.5)  ///
  note("Note: Proportion of the available leverage that the runner up party must win"  ///
  "in order to catch up with the winning party. For details of the calculation"  ///
  "see Appendix B.", span )
graph export anct5.eps, replace
!epstopdf anct5.eps


gen tpoint = trescale
lab var tpoint "Tipping point"

center L gap O K, standardize

lab var c_L "Leverage"
lab var c_gap "Gap"
lab var c_O "Percent to others"
lab var c_K "Number of parties"

drop if inlist(iso3166,"LU","MT","BE")
eststo clear
eststo: reg tpoint c_L
eststo: reg tpoint c_gap
eststo: reg tpoint c_K
eststo: reg tpoint c_O
eststo: reg tpoint c_L c_gap c_K c_O

esttab using anct5.tex, tex replace label nomtitles r2





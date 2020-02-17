// A Summary table of impact probability
// -------------------------------------
// kohler@wzb.eu
set scheme s1mono

version 10
use elections2, clear

// np
gen pvotes = (nvotes/nvalid)
bysort election: gen np = sum(pvotes>=.01) if !mi(pvotes)
bysort election: replace np = np[_N]

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


// a, b
by election (nvotes): gen p_1 = pvotes[_N]
by election (nvotes): gen p_2 = pvotes[_N-1]

by election: keep if _n==_N

gen pstar_1 = p_1 * (1-L)
gen pstar_2 = p_2 * (1-L)

// t
gen t = 1/(np) * (((np-1)*(pstar_1-pstar_2))/L + 1)
replace t = . if t > 1

// e
gen e = (1 - t)/(np-1)

// frac
gen tbye = t/e

// observed diff
gen diff = p_1 - p_2

foreach var of varlist p_1 p_2 diff L t e {
	replace `var' = `var' * 100
}

format %3.1f p_1 p_2 diff L 
sort tbye

tostring t e, replace force format(%3.1f)
tostring tbye, gen(disprob) force format(%3.2f)

replace t = ">100" if t == "."
replace e = "-" if e == "."
replace disprob = "-" if disprob == "."


listtex ctrname p_1 p_2 diff L np t e disprob ///
  using anct.tex  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{lcccccccc}\hline" ///
  "        & \multicolumn{5}{c}{Observed quantities} & \multicolumn{3}{c}{Hypothetical quantities} \\ "  ///
  "        &        &Runner  &       & Lever- &Parties & Min. for& All other &      \\ "  ///
  "Country &Winner  &Up & Diff. & age    &$<$ 1\% & runner up   & Parties & Disp. \\ \hline") ///
  foot("\hline \end{tabular}") end("\\")


replace tbye = log(tbye)
gen  wbyl = log(p_2/p_1)
egen axis = axis(tbye) if tbye < ., label(ctrname) reverse
levelsof axis, local(K)
graph twoway 							/// 
  || scatter axis tbye, mcolor(black)	/// 
  || pcarrow axis tbye axis wbyl, lcolor(black) mcolor(black) 		///
  ||, ylab(`K', valuelabel angle(0))	 ///
  ytitle("") xtitle(Log(Disproportinability)) xline(0) 	///
  legend(order(1 "Necessary" 2 "Real"))
graph export anct.eps, replace
!epstopdf anct.eps

  



exit









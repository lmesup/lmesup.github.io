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

by election: keep if _n==_N


// Calculate tipping point
gen t = (W + L / (K - 1) - R) / (L + L / (K - 1))
assert abs(round((R + t * L) - (W + (1-t)/(K-1) * L),1)) <= 1 if t != .
replace t = . if t > 1

// tstar
gen tstar = (1 - t)/(K-1)

// observed diff
replace W = 100 * (W/nvalid)
replace R = 100 * (R/nvalid)
gen diff = R - W

// neccessary difference
gen necdiff = 100 * (t-tstar)

replace L = L/nelectorate

foreach var of varlist t tstar L vturnout  {
	replace `var' = `var' * 100
}

format %2.0f diff L vturnout W R 
gsort necdiff - L

tostring t tstar, replace force format(%2.0f)
tostring necdiff, gen(necdiffs) force format(%2.0f)

replace t = "$>$100" if t == "."
replace tstar = "-" if tstar == "."
replace necdiffs = "-" if necdiffs == "."


replace ctrname = ctrname + " ('" + substr(string(year(eldate)),3,.) + ")"


listtex ctrname vturnout L K W R diff t tstar  ///
  using anct2.tex  ///
  if inrange(abs(necdiff),0,13) 							///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{lcccccccc}\hline" ///
  " & \multicolumn{6}{c|}{Observed quantities} & \multicolumn{2}{c}{To close the gap ...} \\ "  ///
  " & Turnout of  & Lever- & Parties & Winnner & Runner up & \multicolumn{1}{c|}{Gap}     & runner up & leader should   \\ "  ///
  "Election  & valid voters& age    & $>1$\%. & \%      & \%        & \multicolumn{1}{c|}{1st-2nd} &  needs    & gain $\leq$   \\ \hline" ///
  " \multicolumn{9}{l}{\textbf{\hspace{.5cm}Change possible} } \\ ") ///
  end("\\")

listtex ctrname vturnout L K W R diff t tstar  ///
  if inrange(abs(necdiff),14,25) 							///
  , appendto(anct2.tex) rstyle(tabular) 	///
  head(" \multicolumn{9}{l}{\textbf{\hspace{.5cm}Change unlikely}} \\ ") ///
  end("\\") 

listtex ctrname vturnout L K W R diff t tstar  ///
  if inrange(abs(necdiff),25,100) 							///
  , appendto(anct2.tex) rstyle(tabular) 	///
  head("\multicolumn{9}{l}{\textbf{\hspace{.5cm}Change most improbable}} \\ ")  ///
  end("\\") 
	
listtex ctrname vturnout L K W R diff t tstar  ///
  if necdiff == . 							///
  , appendto(anct2.tex) rstyle(tabular) 	///
  head(" \multicolumn{9}{l}{\textbf{\hspace{.5cm}Change impossible}} \\ ")  ///
  foot("\hline \\" ///
  "\end{tabular}") 			///  
  end("\\") 

egen axis = axis(necdiff) if necdiff < ., label(ctrname) 
levelsof axis, local(K)
graph twoway 							/// 
  || scatter axis necdiff, mcolor(black)	/// 
  || pcarrow axis necdiff axis diff, lcolor(black) mcolor(black) 		///
  ||, ylab(`K', valuelabel angle(0))	 ///
  ytitle("") xtitle("Difference in proportions" "(Real winner - real runner up)") xline(0) 	///
  legend(order(1 "Necessary" 2 "Real"))
graph export anct2.eps, replace
!epstopdf anct2.eps

  


exit









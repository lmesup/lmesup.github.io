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
gen tediff = e-t

// observed diff
gen diff = p_1 - p_2

foreach var of varlist p_1 p_2 diff L t e turnout tediff {
	replace `var' = `var' * 100
}

format %2.0f p_1 p_2 diff L turnout 
gsort - tediff - L

tostring t e, replace force format(%2.0f)
tostring tbye, gen(disprob) force format(%3.1f)
tostring tediff, gen(tediffs) force format(%2.0f)

replace t = ">100" if t == "."
replace e = "-" if e == "."
replace disprob = "-" if disprob == "."
replace tediffs = "-" if tediffs == "."


listtex ctrname turnout L np diff t e tediffs ///
  using anct1.tex  ///
  if inrange(abs(tediff),0,13) 							///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{lccccccc}\hline" ///
  "       & Official & Lever- & Parties & Gap     & Challenger & Assumed \%    & Challenger's \\ "  ///
  "Country& turnout  & age    & $>1$\%. & 1st-2nd &  \%        & of leader     & lead \\ \hline" ///
  " \multicolumn{8}{l}{\textbf{\hspace{.5cm}Change possible} } \\ ") ///
  end("\\") 

listtex ctrname turnout L np diff t e tediffs ///
  if inrange(abs(tediff),14,25) 							///
  , appendto(anct1.tex) rstyle(tabular) 	///
  head(" \multicolumn{8}{l}{\textbf{\hspace{.5cm}Change unlikely}} \\ ") ///
  end("\\") 

listtex ctrname turnout L np diff t e tediffs ///
  if inrange(abs(tediff),25,100) 							///
  , appendto(anct1.tex) rstyle(tabular) 	///
  head("\multicolumn{8}{l}{\textbf{\hspace{.5cm}Change most improbable}} \\ ")  ///
  end("\\") 
	
listtex ctrname turnout L np diff t e tediffs ///
  if tediff == . 							///
  , appendto(anct1.tex) rstyle(tabular) 	///
  head(" \multicolumn{8}{l}{\textbf{\hspace{.5cm}Change most impossible}} \\ ")  ///
  foot("\hline \end{tabular}") 			///  
  end("\\") 


egen axis = axis(tediff) if tediff < ., label(ctrname) 
levelsof axis, local(K)
graph twoway 							/// 
  || scatter axis tediff, mcolor(black)	/// 
  || pcarrow axis tediff axis diff, lcolor(black) mcolor(black) 		///
  ||, ylab(`K', valuelabel angle(0))	 ///
  ytitle("") xtitle("Difference in proportions" "(Real winner - real runner up)") xline(0) 	///
  legend(order(1 "Necessary" 2 "Real"))
graph export anct1.eps, replace
!epstopdf anct1.eps

  







exit









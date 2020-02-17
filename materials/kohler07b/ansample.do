* Sampling Methods and Features by Country and Survey-Program 
* kohler@wz-berlin.de

version 9

drop _all
set memory 90m
set more off
set scheme s1mono

// Data
// ----

use svydat02, clear
by survey ctrname, sort: keep if _n==1
keep survey-sample

// EU and friends only
// -------------------

keep if eu > 0
egen axis = axis(eu ctrname), reverse label(ctrname) gap

// Fine tune X-Axis coordintas
// ----------------------------

gen samplex = sample
by ctrname sample (survey), sort: gen np = _N
by ctrname sample (survey): replace samplex = samplex - .125 if np == 2 & _n==1
by ctrname sample (survey): replace samplex = samplex + .125 if np == 2 & _n==2
by ctrname sample (survey): replace samplex = samplex - .25 if np == 3 & _n==1
by ctrname sample (survey): replace samplex = samplex + .25 if np == 3 & _n==3

by ctrname sample (survey): replace samplex = samplex - .375 if np == 4 & _n==1
by ctrname sample (survey): replace samplex = samplex - .125 if np == 4 & _n==2
by ctrname sample (survey): replace samplex = samplex + .125 if np == 4 & _n==3
by ctrname sample (survey): replace samplex = samplex + .375 if np == 4 & _n==4

// Graph for Sample Method
// -----------------------

separate samplex, by(survey) veryshortlabel
graph twoway ///
|| sc axis samplex1, ms(Oh) mlc(black) mfc(white) /// 
|| sc axis samplex2, ms(O) mc(black)   /// 
|| sc axis samplex3, ms(Sh) mlc(black) mfc(white)   /// 
|| sc axis samplex4, ms(S) mc(black)   /// 
|| sc axis samplex5, ms(Th) mlc(black) mfc(white)   /// 
|| sc axis samplex6, ms(T) mc(black)    ///
|| , legend(off)  ///
  ylab(1(1)4 6(1)15 17(1)31, valuelabel angle(0) grid ) ytitle("") ///
  xscale(range(.625 6.375))           ///
  xline(1.5(1)5.5) ///
  xlab(1 "SRS" ///
  2  "Indiv. Reg."   ///
  3  "Addr. Reg."      ///
  4  "Rand.-Route"   ///
  5  "Unspec."   ///
  6  "Quota"    ///
  )  /// 
  title(Sample method, pos(12) box bexpand fcolor(gs12) ) ///
  nodraw name(g1, replace) 
  
// Graph for substitution
// ----------------------

gen substx = subst
by ctrname subst (survey), sort: replace np = _N
by ctrname subst (survey): replace substx = substx - .125 if np == 2 & _n==1
by ctrname subst (survey): replace substx = substx + .125 if np == 2 & _n==2

by ctrname subst (survey): replace substx = substx - .25 if np == 3 & _n==1
by ctrname subst (survey): replace substx = substx + .25 if np == 3 & _n==3

by ctrname subst (survey): replace substx = substx - .375 if np == 4 & _n==1
by ctrname subst (survey): replace substx = substx - .125 if np == 4 & _n==2
by ctrname subst (survey): replace substx = substx + .125 if np == 4 & _n==3
by ctrname subst (survey): replace substx = substx + .375 if np == 4 & _n==4

by ctrname subst (survey): replace substx = substx - .50 if np == 5 & _n==1
by ctrname subst (survey): replace substx = substx - .25 if np == 5 & _n==2
by ctrname subst (survey): replace substx = substx + .25 if np == 5 & _n==5
by ctrname subst (survey): replace substx = substx + .50 if np == 5 & _n==5

separate substx, by(survey) veryshortlabel
graph twoway ///
|| sc axis substx1, ms(Oh) mlc(black) mfc(white) /// 
|| sc axis substx2, ms(O) mc(black)   /// 
|| sc axis substx3, ms(Sh) mlc(black) mfc(white)   /// 
|| sc axis substx4, ms(S) mc(black)   /// 
|| sc axis substx5, ms(Th) mlc(black) mfc(white)   /// 
|| sc axis substx6, ms(T) mc(black)    ///
|| if subst > -3 , ///
  legend(off)  ///
  ylabel(none)  yline(1(1)4 6(1)15 17(1)31, lstyle(grid) ) ytitle("") ///
  xlabel(0 "No"  1 `"Yes"') ///
  xline(0.5) xscale(range(-.25 1.375) ) ///
  fxsize(20)  ///
  title(Subst. allowed, pos(12) box bexpand fcolor(gs12) ) nodraw name(g2, replace)


// Graph for Back-Checks
// ----------------------

gen backd = back == 0 if back >= 0
gen backx = backd
by ctrname backd (survey), sort: replace np = _N
by ctrname backd (survey): replace backx = backx - .125 if np == 2 & _n==1
by ctrname backd (survey): replace backx = backx + .125 if np == 2 & _n==2

by ctrname backd (survey): replace backx = backx - .25 if np == 3 & _n==1
by ctrname backd (survey): replace backx = backx + .25 if np == 3 & _n==3

by ctrname backd (survey): replace backx = backx - .375 if np == 4 & _n==1
by ctrname backd (survey): replace backx = backx - .125 if np == 4 & _n==2
by ctrname backd (survey): replace backx = backx + .125 if np == 4 & _n==3
by ctrname backd (survey): replace backx = backx + .375 if np == 4 & _n==4

by ctrname backd (survey): replace backx = backx - .50 if np == 5 & _n==1
by ctrname backd (survey): replace backx = backx - .25 if np == 5 & _n==2
by ctrname backd (survey): replace backx = backx + .25 if np == 5 & _n==5
by ctrname backd (survey): replace backx = backx + .50 if np == 5 & _n==5

separate backx, by(survey) veryshortlabel
graph twoway ///
|| sc axis backx1, ms(Oh) mlc(black) mfc(white) /// 
|| sc axis backx2, ms(O) mc(black)   /// 
|| sc axis backx3, ms(Sh) mlc(black) mfc(white)   /// 
|| sc axis backx4, ms(S) mc(black)   /// 
|| sc axis backx5, ms(Th) mlc(black) mfc(white)   /// 
|| sc axis backx6, ms(T) mc(black)    ///
|| if backd < . , ///
  legend(off)  ///
  ylabel(none)  yline(1(1)4 6(1)15 17(1)31, lstyle(grid) ) ytitle("") ///
  xlabel(0 "Yes" 1 "No" ) ///
  xline(0.5) xscale(range(-.25 1.375)) ///
  fxsize(20)   ///
  title(Back-checks, pos(12) box bexpand fcolor(gs12) ) nodraw name(g3, replace)

graph combine g1 g2 g3, rows(1) imargin(tiny) nodraw name(combined, replace)


// Legend Graph
// ------------
// thanks vwiggins@stata.com

// Legend
tw sc substx1 substx2 substx3 substx4 substx5 substx6 axis ///
  , legend(order(1 "EB 62.1" 2 "EQLS '03" 3 "ESS '02" ///
                 4 "ESS '04" 5 "EVS '99"  6 "ISSP '02") rows(2))  ///
  name(leg, replace) yscale(off) xscale(off) nodraw  ///
  ms(Oh O Sh S Th T) mc(black ..)

// Delete Plrogregion and fix ysize (Thanks, Vince)
_gm_edit .leg.plotregion1.draw_view.set_false
_gm_edit .leg.ystretch.set fixed

graph combine combined leg, cols(1)  

graph export ansample.eps, replace


// Summary-Table
// -------------

// Count number of best possible solutions
replace sample = . if sample < 0
by ctrname sample, sort: gen ranksamp = 1 if _n==1
by ctrname (sample): replace ranksamp = sum(ranksamp)
gen bestsamp = ranksamp==1 if sample < .

replace subst = . if subst < 0
by ctrname subst, sort: gen ranksubst = 1 if _n==1
by ctrname (subst): replace ranksubst = sum(ranksubst)
gen bestsubst = ranksubst==1 if subst < .

replace back = . if back < 0
replace back = back==0 if back < .
by ctrname back, sort: gen rankback = 1 if _n==1
by ctrname (back): replace rankback = sum(rankback)
gen bestback = rankback==1 if back < .
 
// Fraction of countries with best possible solutions
collapse ///
  (mean) bestsamp bestsubst bestback ///
  , by(survey)

// Overall
gen index = bestsamp + bestsubst
gsort - index survey
format index %2.1f
format bestsamp bestsub bestback %3.2f

listtex survey bestsamp bestsubst bestbac index using ansample.tex, rstyle(tabular) replace

exit



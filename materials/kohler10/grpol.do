// Descriptive Figure of Voting by Political Variables
// kohler@wzb.eu

version 10
set more off

use ess04, clear

// Additive Index trust
egen trust = rmean(trst*)
replace trust = round(trust,1)
lab val trust trust
lab define trust 0 "(very low) 0" 10 "(very high) 10"
label variable trust "Trust in political institutions"

lab def sat 0 "(extremely dissatisfied) 0" 10 "(extremely satisfied) 10"
lab val democsat sat
lab val govsat sat

lab def pi 0 "No" 1 "Yes"
lab val pi pi


local i 1
local last 0
foreach var of varlist polint polcmpl pi govsat trust democsat lrgroup {
  levelsof `var', local(K)
  gen var`i++':groupvar = `var' + `last' + 1
  foreach k of local K {
     label define groupvar `=`k'+`last'+1' "`:label (`var') `k''", modify
     local l = `k' + 1
  }
  local last = `l' + `last' 
}

gen str id = ""
tostring idno, replace
replace id = cntry + idno
keep id cntry voter* var* nweight
reshape long var, i(id) j(varnr)
drop if var == .

egen axis = axis(varnr varnr var), gap reverse label(var)
collapse (mean) voter varnr ///
        (count) n = voter [aw=nweight], by(axis)

gen naxis:naxis = axis
sort naxis
forv i = 1/`=_N' {
  label define naxis `=naxis[`i']' "(`=n[`i']')", modify
}

by varnr, sort: gen younglab = "Age < 25" if _n==1
by varnr: gen oldlab = "Age 64+" if _n==1

sort axis
levelsof axis, local(K)
tw ///
  || scatter axis voter, mcolor(black) xaxis(1 2)  ///
  || scatter naxis voter, yaxis(2) ms(i) ///
  || line axis voter if varnr == 1, lcolor(black) lpattern(solid)  ///
  || line axis voter if varnr == 2, lcolor(black) lpattern(solid)  ///
  || line axis voter if varnr == 3, lcolor(black) lpattern(solid)  ///
  || line axis voter if varnr == 4, lcolor(black) lpattern(solid)  ///
  || line axis voter if varnr == 5, lcolor(black) lpattern(solid)  ///
  || line axis voter if varnr == 6, lcolor(black) lpattern(solid)  ///
  || line axis voter if varnr == 7, lcolor(black) lpattern(solid)  ///
  || , ///
       ymlabel(`K', valuelabel angle(0) labsize(2.5) grid gstyle(dot))    ///
       ylabel(5 "Left-Right" 18 "Satisf. with Democracy" 31 "Trust in Polit. Institutions"  ///
              44 "Satisf. with Government" 48 "Party Identification" ///
              55 "Politics too Complicated"   61 "Political Interest",  ///
              noticks labsize(3) labgap(*2) angle(0)) ///
       ytitle("") ytitle("", axis(2)) ///
       ymlabel(`K', noticks valuelabel angle(0) labsize(2.5) axis(2)) ///
       ylabel(5 "38663" 18 "37186" 31 "38311"  ///
              44 "37401" 48 "37858" ///
              55 "37988"   61 "38580", axis(2) ///
              noticks labsize(3) labgap(*2) angle(0)) ///
       ytitle("") ///
       xlabel(.55 "55" .60 "60" .65 "65" .7 "70" ///
              .75 "75" .8 "80" .85 "85" .9 "90", labsize(3) axis(2)) ///
       xlabel(none, axis(1)) xtick(.55(.05).9, axis(1)) ///
       xtitle("Proportion of voters (in %)", axis(2))  xtitle("", axis(1)) ///
       scheme(s1mono) legend(off) ysize(8.5)
graph export grpol.eps, replace

exit



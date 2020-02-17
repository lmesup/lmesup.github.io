// Descriptive Figure of Voting on Socio-Economic Status
// kohler@wzb.eu

version 10
set more off

use ess04, clear

// Variable redifinitions
gen agegroup:agegroup = 1 if inrange(age,18,21)
replace agegroup = 2 if inrange(age,22,24)
replace agegroup = 3 if inrange(age,25,34)
replace agegroup = 4 if inrange(age,35,79)
replace agegroup = 5 if inrange(age,80,102)
label define agegroup 1 "18-21" 2 "22-24" 3 "25-34" 4 "35-79" 5 "80 and above"

replace emp = 2 if emp==2 | emp==3 | emp==4
label define emp 2 "Outside labour force", modify

label value men men
label define men  0 "Female" 1 "Male"

label value church church
label define church 0 "Never" 1 "Sometimes"

label value discrim discrim
label define discrim 0 "No" 1 "Yes"

local i 1
local last 0
foreach var of varlist agegroup edu men church domicil egp hhinc emp discrim {
  levelsof `var', local(K)
  gen var`i++':groupvar = `var' + `last' + 1
  foreach k of local K {
     label define groupvar `=`k'+`last'+1' "`:label (`var') `k''", modify
     local l = `k' + 1
  }
  local last = `l' + `last' 
}

gen voteryoung = voter if age <= 24
gen voterold = voter if age >= 65
gen votermiddle = voter if inrange(age,30,65)

gen str id = ""
tostring idno, replace
replace id = cntry + idno
keep id cntry voter* var* nweight
reshape long var, i(id) j(varnr)
drop if var == .

egen axis = axis(varnr varnr var), gap reverse label(var)
collapse (mean) voter voteryoung votermiddle voterold  varnr ///
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
  || line axis voter if varnr == 8, lcolor(black) lpattern(solid)  ///
  || line axis voter if varnr == 9, lcolor(black) lpattern(solid)  ///
  || line axis voteryoung if varnr == 2, lcolor(black) lpattern(solid)  ///
  || line axis voterold if varnr == 2, lcolor(black) lpattern(solid)  ///
  || scatter axis voteryoung if var==2, ///
     mlcolor(black) mfcolor(white) ms(o) mlab(younglab) mlabpos(1) ///
  || scatter axis voterold if var==2, ///
     mlcolor(black) mfcolor(gs8) ms(o) mlab(oldlab) mlabpos(1) ///
  || , ///
       ymlabel(`K', valuelabel angle(0) labsize(2.5) grid gstyle(dot)) ///
       ylabel(3 "Discriminated" 8 "Employment Status" 14 "Household Income" ///
               21 "Social Class" 28 "Size of Community" ///
               32 "Church Attendence" 36 "Gender" 41 "Education" ///
               48 "Age", noticks labsize(3) labgap(*2) angle(0)) ///
       ytitle("") ytitle("", axis(2)) ///
       ymlabel(`K', noticks valuelabel angle(0) labsize(2.5) axis(2)) ///
       ylabel(3 "38403" 8 "38432" 14 "30360" 21 "35842" 28 "38587"  32 "38529" ///
              36 "38593" 41 "38424" 48 "38428", noticks axis(2) ///
              labsize(3) labgap(*2) angle(0)) ///
       ytitle("") ///
       xlabel(.55 "55" .60 "60" .65 "65" .7 "70" ///
              .75 "75" .8 "80" .85 "85" .9 "90", labsize(3) axis(2)) ///
       xlabel(none, axis(1)) xtick(.55(.05).9, axis(1)) ///
       xtitle("Proportion of voters (in %)", axis(2))  xtitle("", axis(1)) ///
       scheme(s1mono) legend(off) ysize(8.5)
graph export grses.eps, replace


exit



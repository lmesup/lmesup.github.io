* Several participation measures by country
* Author: kohler@wzb.eu
	
// Intro
// -----
	
version 10
set more off
set scheme s1mono

clear
set memory 100m

use ess04

lab var unionmemb "Union Member"
lab var petition "Signed petition"
lab var protest  "Demonstration"
lab var actgroup "Party/action group"
lab var contact  "Contacted politician"

local i 1
foreach var of varlist unionmemb-contact {
	local lab `"`lab' `i' "`:var lab `var''" "'
	ren `var' participation`i++'
}

preserve
 // Calculate Mean Participation
collapse (mean) participation* [aw=nweight], by(cntry)

gen index = _n
reshape long participation, i(index) j(form)
label value form form
label def form `lab'


// Order of categorical axis
encode cntry, gen(ctrnum)
by cntry, sort: egen order = mean(participation) 
egen axis = axis(order), reverse label(ctrnum) gap

// Graph and Export
levelsof axis, local(ylab)
graph twoway ///
	  || dot participation axis, horizontal ms(O) mcolor(black)         ///
	  || , ysize(6.5) xsize(10) ylabel(`ylab', valuelabel angle(0) labsize(*.8)) ///
	       ytitle("") xtitle(Proportion of participation) legend(off)  ///
          by(form, rows(1) legend(off)) ///

graph export anparticipationses.eps, replace

// Participation on Socio Economic Variables
// -----------------------------------------

restore

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

gen str id = ""
tostring idno, replace
replace id = cntry + idno

keep id cntry participation* var* nweight
reshape long var, i(id) j(varnr)
drop if var == .

egen axis = axis(varnr varnr var), gap reverse label(var)
collapse (mean) participation* varnr [aw=nweight], by(axis)

lab var participation1 "Union Member"
lab var participation2 "Signed petition"
lab var participation3 "Demonstration"
lab var participation4 "Party/action group"
lab var participation5 "Contacted politician"

sort axis
levelsof axis, local(K)

foreach part of varlist participation* {

tw ///
  || scatter axis `part', mcolor(black)                             ///
  || line axis `part' if varnr == 1, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 2, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 3, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 4, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 5, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 6, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 7, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 8, lcolor(black) lpattern(solid)  ///
  || line axis `part' if varnr == 9, lcolor(black) lpattern(solid)  ///
  || ,                                                              ///
       ymlabel(`K', valuelabel angle(0) labsize(2.5) grid gstyle(dot)) ///
       ylabel(3 "Discriminated" 8 "Employment Status" 14 "Household Income" ///
               21 "Social Class" 28 "Size of Community"               ///
               32 "Church Attendence" 36 "Gender" 41 "Education"      ///
               48 "Age", noticks labsize(3) labgap(*2) angle(0))      ///
       ytitle("")                                                     ///
       ymlabel(`K', noticks valuelabel angle(0) labsize(2.5))         ///
       ytitle("")                                                     ///
       xtitle("Proportion of `:var lab `part''")                      ///
       scheme(s1mono) legend(off) ysize(8.5)
      graph export anparticipationses_`part'.eps, replace
}


exit



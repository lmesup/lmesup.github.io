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
  || ,                                                              ///
       ymlabel(`K', valuelabel angle(0) labsize(2.5) grid gstyle(dot)) ///
       ylabel(5 "Left-Right" 18 "Satisf. with Democracy" 31 "Trust in Polit. Institutions"  ///
              44 "Satisf. with Government" 48 "Party Identification" ///
              55 "Politics too Complicated"   61 "Political Interest",  ///
              noticks labsize(3) labgap(*2) angle(0)) ///
       ytitle("")                                                     ///
       ymlabel(`K', noticks valuelabel angle(0) labsize(2.5))         ///
       ytitle("")                                                     ///
       xtitle("Proportion of `:var lab `part''")                      ///
       scheme(s1mono) legend(off) ysize(8.5)
      graph export anparticipationpol_`part'.eps, replace
}


exit



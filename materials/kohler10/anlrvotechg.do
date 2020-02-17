// Apply Richards Proposal from July 12 2007
version 10
clear
set matsize 500
set more off
set scheme s1mono
capture log close
log using anpol_by_country, replace

use ess04, clear

gen lrvote = 1 if pi==1 & lrgroup==1
replace lrvote = 2 if pi==1 & lrgroup==3
replace lrvote = 3 if pi==1 & lrgroup==2 
replace lrvote = 1 if pi==0 & lrgroup==1 & uniform()>= .5
replace lrvote = 2 if pi==0 & lrgroup==3 & uniform()>= .5
replace lrvote = 3 if pi==0 & lrgroup==2 & uniform()>= .5
replace lrvote = 4 if lrvote == . & (pi==0 | inlist(lrgroup,3,4))
drop if lrvote==.

// Graph 1, Before allocating windfall
// -----------------------------------

preserve
drop if voter == .
tab lrvote, gen(lrvote)
collapse (mean) lrvote1-lrvote4 (count) n=lrvote [aw=nweight], by(cntry voter)

forv i = 1/4 {
  by cntry (voter), sort: gen lrvotet`i' = sum(lrvote`i'*n)/sum(n)
  by cntry (voter): replace lrvotet`i' = lrvotet`i'[_N]
  gen diff`i' = abs(lrvote`i' - lrvotet`i')
}

drop if voter==0
egen difft = rsum(diff?)
encode cntry, gen(iso3166)
egen axis = axis(difft), label(iso3166) reverse

reshape long lrvote lrvotet diff, i(cntry) j(categ)
label value categ categ
label define categ 1 "Commited left" 2 "Commited center"  3 "Commited right" 4 "Windfall"

levelsof axis, local(ylab)
graph twoway ///
   || scatter axis lrvote, ms(O) mcolor(black)  ///
   || pcarrow axis lrvote axis lrvotet, lcolor(black) mcolor(black) ///
   || , by(categ, col(4)  legend(off) note("") ///
        title(Before allocating windfall)) ///
        ylab(`ylab', valuelabel angle(0)) ///
        ytitle("") ///
        name(g1, replace) nodraw

keep cntry axis
by cntry, sort: keep if _n==1
sort cntry axis

tempfile axis
save `axis'

restore


// Graph 2, After allocating windfall
// -----------------------------------

drop if voter == .

local n 1
while `n' != 0 {
   by cntry, sort: replace lrvote = lrvote[ceil(uniform()*_N)] if lrvote==4
   count if lrvote == 4
   local n r(N)
}

tab lrvote, gen(lrvote)
collapse (mean) lrvote1-lrvote3 (count) n=lrvote [aw=nweight], by(cntry voter)

forv i = 1/3 {
  by cntry (voter), sort: gen lrvotet`i' = sum(lrvote`i'*n)/sum(n)
  by cntry (voter): replace lrvotet`i' = lrvotet`i'[_N]
  gen diff`i' = abs(lrvote`i' - lrvotet`i')
}


merge cntry using `axis'
assert _merge==3
drop _merge

drop if voter==0

reshape long lrvote lrvotet diff, i(cntry) j(categ)
label value categ categ
label define categ 1 "Commited left" 2 "Commited center"  3 "Commited right" 4 "Windfall"

levelsof axis, local(ylab)
graph twoway ///
   || scatter axis lrvote, ms(O) mcolor(black)  ///
   || pcarrow axis lrvote axis lrvotet, lcolor(black) mcolor(black) ///
   || , by(categ, col(4) legend(off) note("") ///
        title(Hot deck allocation of windfall)) ///
        ylab(`ylab', valuelabel angle(0)) ///
        ytitle("")  ///
        name(g2, replace) nodraw

graph twoway ///
   || scatter axis lrvote, ms(O) mcolor(black)  ///
   || pcarrow axis lrvote axis lrvotet, lcolor(black) mcolor(black) ///
	legend(order(1 "Voters only" 2 "Expected change") ///
	  cols(2) ) name(leg, replace) yscale(off) xscale(off) nodraw

	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
   _gm_edit .leg.ystretch.set fixed


graph combine g1 g2 leg, rows(3) ysize(9) title(Expected change from non voters) ///
   note("`=c(current_date)', `=c(current_time)'")

graph export anlrvotechg.eps, replace

exit








// Descriptive Figure of Left-Right by Country
// kohler@wzb.eu

version 10
set more off

use cntry lrgroup nweight using ess04, clear
tab lrgroup, gen(lrgroup)
collapse (mean) lrgroup1-lrgroup4 [aw=nweight], by(cntry)
reshape long lrgroup, i(cntry) j(categ)

gen dim = 1 if inlist(categ,1,2)
replace dim = 2 if inlist(categ,3,4)

// Calculate Sums in order to stack
by cntry dim, sort: gen sumdim1 = sum(lrgroup)
by cntry dim: replace sumdim1 = sumdim1[_N]
by cntry (dim): replace sumdim1 = sumdim1[1]

by cntry dim, sort: gen sumdim2 = sum(lrgroup)
by cntry dim: replace sumdim2 = sumdim2[_N]
by cntry (dim): replace sumdim2 = sumdim2[_N]

assert round((sumdim1 + sumdim2)*100,1) == 100

// Construct Axis with labels
encode cntry, gen(cntrynum)
egen axis = axis(sumdim1), gap reverse label(cntrynum)

// Follow [G] graph twoway bar
replace sumdim2 = -sumdim2
replace lrgroup = -lrgroup if categ==3
gen zero = 0

tw ///
 || bar sumdim2 axis if dim==2, horizontal col(gs12)          ///
 || bar lrgroup axis if categ==3, horizontal col(gs4)         ///
 || bar sumdim1 axis if dim==1, horizontal col(gs10)          ///
 || bar lrgroup axis if categ==1, horizontal col(gs6)         ///
 || sc axis zero, ms(i) mlab(axis)                            ///
 || , scheme(s1mono) plotregion(style(none))                  ///
      ytitle("") yscale(noline) ylab(none)  ///
      legend(order(1 "Unengaged" 2 "Uncommited" 4 "Left" 3 "Right") rows(1) ) ///
  xtitle("Proportion" "(in %)") xscale(titlegap(-3.5) range(-.8 .8))       ///
  xlab(-.8 "80" -.6 "60" -.4 "40" -.2 "20" .2 "20" .4 "40" .6 "60" .8 "80" ///
       , grid glcolor(black) glpattern(solid)) ///
  xmtick(-.70(.1).7, grid glcolor(black) glpattern(dash)) ///
  text(25 0 "Not commited   ", placement(w) size(4)) text(25 0 "   Commited", placement(e) size(4))

graph export grlr.eps, replace

exit



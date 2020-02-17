// Descriptive Figure of Left-Right by Country
// kohler@wzb.eu

version 10
set more off

use cntry leftright lrgroup nweight using ess04, clear


// Histogram
// ---------
preserve
replace leftright = 12 if leftright == .

tab leftright, gen(leftright)
collapse (mean) leftright1-leftright12 [aw=nweight]
gen index = 1
reshape long leftright, j(categ) i(index)
replace leftright = leftright*100
format leftright %2.0f
replace categ = categ-1 if categ < 12

graph twoway 							 /// 
  || bar leftright categ, color(black) barwidth(0.7) ///
  || scatter leftright categ, ms(i) mlab(leftright) mlabpos(12) mlabsize(medium)  ///
  ||  ,  xlabel( 								///
  0 `""0" "Left""' ///
  1(1)9 								///
  10 `""10" "Right""' 		 		    ///
  12 `""Don't" "know" "' 			    ///
  ) 									///
  xtitle("") 							/// 
  yscale(range(0 51)) ylabel(0(5)50, grid format(%2.0f)) 	 ///
  ytitle("Percent") legend(off) 		///
  note("Source: European Social Survey 2004" "Number of valid respondents: 40,371", size(medium) span)

graph export anlr_hist.eps, replace
!epstopdf anlr_hist.eps

restore


// Pie Chart
// ---------

tab lrgroup, gen(lrgroup)
graph pie lrgroup1-lrgroup4 [aw=nweight] /// 
  , scheme(s1mono) line(lcolor(black))   /// 
  plabel(_all percent, box fcolor(white) lcolor(black) size(*1.2) format(%3.1f))	        /// 
  pie(1, color(gs0))  					/// 
  pie(2, color(gs16)) 					///
  pie(3, color(gs6)) 					///
  pie(4, color(gs10)) 					///
  legend(order(1 "Left" 2 "Right" 3 "Uncommited" 4 "Unengaged" ) rows(1) ) 
graph export anlr_pie.eps, replace


// Table
// -----

collapse (mean) lrgroup1-lrgroup4 [aw=nweight], by(cntry)
forv i = 1/4 {
	replace lrgroup`i' = lrgroup`i'*100
}

format lrgroup* %3.1f
egen cntryname = iso3166(cntry), o(codes)

listtex cntryname lrgroup1-lrgroup4 ///
  using anlr_table.tex  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{lrrrr}\hline" ///
  "& \multicolumn{4}{c}{Percentage of eligible Respondents} \\ " ///
  "&  Left   & Right & Uncommited & Unengaged \\ \hline") ///
  foot("\hline \end{tabular}") end("\\")

// Bar-Chart
// ---------

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

assert round((sumdim1 + sumdim2),1) == 100

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

graph export anlr_bar.eps, replace

exit



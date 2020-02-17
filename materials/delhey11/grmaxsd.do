// Standard deviation of WFS corrected using both IEFF-types
// kohler@wzb.eu,

// Based on: wvs5_inequality.do (j.delhey@jacobs-university.de)

version 11
clear
set more off
set scheme s1mono

// Figure
// ------

local opt lcolor(black) lwidth(*1.5)
tw 										/// 
  || function y1 = 1/(sqrt((0 - x)*(x-10))), `opt' lpattern(solid) range(0 10) ///
  || function y2 = 1/(sqrt((1 - x)*(x-7))), `opt' lpattern(dash) range(1 7) ///
  || function y3 = 1/(sqrt((1 - x)*(x-4))), `opt' lpattern(dash_dot) range(1 4) ///
  legend(order(1 "11 point scale" 2 "7 point scale" 3 "4 point scale") rows(1))  ///
  ylabel(0(1)6, grid) xmtick(1(2)9)					/// 
  ytitle(Instrument effect from max(SD) (IEFF{superscript:A}))  					/// 
  xtitle("Mean of latent happiness") 	///
  saving(grmaxsd, replace)

graph export grmaxsd.eps, replace

exit



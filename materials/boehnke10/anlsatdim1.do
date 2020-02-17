* 4 dimensions of satisfaction on overall satisfaction with life
* (based on anlsatdim.do and crlsatdim.do by Mischke@wz-berlin.de)

* Intro
* ------

version 8.2
clear
set memory 78m
set more off

* Data
* ----

use  c2 d8 q4_1 q4_2 q4_3 q4_4 q4_7 age d7 d10 hinceq d15a ///
   gdppcap totfert abort poverty country2 using ebh_5.dta

* Rename dimensions of satisfaction
* ---------------------------------

rename q4_2 sathe
rename q4_1 satl
rename q4_3 satsy
rename q4_4 satfa
rename q4_7 satfi

* Recode Control-Variables
* -------------------------

gen age2 = age^2
gen lninc = log(hinceq)
gen emp = d15a > 4 & d15a < .
gen men = d10 == 1 if d10 < .

gen marital:marital = 1 if d7 == 1 | d7 == 2
replace marital = 2 if d7 == 3
replace marital = 3 if d7 >= 4 & d7 <= 8
lab def marital 1 "married" 2 "partner" 3 "no partner"
tab marital, gen(mar)

gen edu = 5 if d8 == 0
levels country2, local(K)
foreach k of local K {
	_pctile d8 if d8 > 0 & country2 == `k', nq(4)
	replace edu = 1 if d8 > 0 & d8 <= r(r1) & country2 == `k'
	replace edu = 2 if d8 > r(r1) & d8 < r(r2) & country2 == `k'
	replace edu = 3 if d8 > r(r2) & d8 < r(r3) & country2 == `k'
	replace edu = 4 if d8 > r(r3) & d8 < . & country2 == `k'
}
tab edu, gen(edu)


* Initialize Postfile
* -------------------

tempfile lsatdim
postfile coef country2 satfi satfa sathe satsy r2 using `lsatdim'

* OLS Regressions by country 
* --------------------------

levels country2, local(K)
foreach k of local K {
	reg satl satfi satfa sathe satsy age age2 lninc emp men mar2 mar3 edu2-edu5 ///
	  if country2 == `k' 
	post coef  (`k') (_b[satfi]) (_b[satfa]) (_b[sathe]) (_b[satsy]) (e(r2))
}
postclose coef

* Write out Aggregate-Data
* -------------------------

keep country2 gdppc poverty totfert abort
by country2, sort: keep if _n==1
tempfile gdp
save `gdp'

* Unify Coefficient and GDP Data 
* -------------------------------

use `lsatdim'
sort country2
merge country2 using `gdp'
assert _merge == 3
drop _merge

* Labeling country2
* -----------------

#delimit ;
label define country2lb 1 "BG" 2 "CY" 3 "CZ" 4 "EE" 5 "HU" 
6 "LV" 7 "LT" 8 "MT" 9 "PL" 10 "RO" 11 "SK" 12 "SI" 13 "TR"
14 "BE" 15 "DK" 16 "DE" 17 "GR" 18 "IT" 19 "ES" 20 "FR" 
21 "IE" 23 "LU" 24 "NL" 25 "PT" 26 "UK" 29 "FI" 30 "SE" 31 "AT";
#delimit cr
label values country2 country2lb


* Graph
* -----

* Most Countries
graph twoway ///
  (scatter satfa satfi gdppcap) ///
  (lowess satfa gdppcap, clstyle(p1) clwidth(*1.5)) ///
  (lowess satfi gdppcap, clstyle(p2) clwidth(*1.5)) ///
  if country2~=23 ///
  , ytitle("b(family) and b(finances)") ///
    xtitle("GDP per capita in ppps") legend(off) name(g1, replace)

* Luxemburg
graph twoway ///
   (scatter satfa satfi gdppcap, mlabel(country2 country2))  ///
    if country2==23 ///
    , yscale(alt) ytitle(" ") ///
      xtitle(" ") xscale(range(43749 43751)) xlabel(43750) ///
      legend(label(1 "familiy") label(2 "finances") order(1 2) pos(2) col(1)) ///
      fxsize(30) name(lu, replace)

* Graph Combine
graph combine g1 lu, ycommon imargin (0 2 0 0)  ///
  title("Regression of Life-Satisfaction on Domain Satisfactions")  ///
  note(anlsatdim1.do)

graph export graphs/anlsatdim1.eps, replace

exit


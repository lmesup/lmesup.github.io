* Fixed-Effects-Logit-Modelle (augenblicklich/permanent)

clear
version 7.0
set memory 60m
set matsize 800


capture which rgroup
if _rc ~= 0 {
	archinst rgroup
}

use pidlv

drop est escheid eparspd eparkons eparb90


* Rekodierungen
* -------------

drop if pid == .
gen spd = pid == 2 
gen cdu = pid == 3 | pid == 4
gen b90 = pid == 5 

tab welle, gen(year)

keep persnr spd cdu b90 e* year* uw prgroup

* Building UVlists
foreach piece of varlist e* {
	local uv "`uv' `piece'"
}

* Building statlist
foreach piece of local uv {
	local statlist "`statlist' _b[`piece']"
}

* SPD - Modell
* ------------

* General Model
xtlogit spd e* year2-year13 [iw=uw], fe

* Fit-Indices
quietly clogit spd e* year2-year13, group(persnr)
fitstat

* Variance Estimation
rgroup "xtlogit spd e* year2-year13 [iw=uw], fe" "`statlist'",  /*
*/ rgroups(prgroup)

* Store Results
matrix bspd = r(val)'
matrix sespd = r(se)'


* CDU - Modell
* ------------

* General Model
xtlogit cdu e* year2-year13 [iw=uw], fe

* Fit-Indices
quietly clogit cdu e* year2-year13, group(persnr)
fitstat

* Variace Estimation
rgroup "xtlogit cdu e* year2-year13 [iw=uw], fe" "`statlist'",  /*
*/ rgroups(prgroup)

* Store results
matrix bcdu = r(val)'
matrix secdu = r(se)'


* B90 - Modell
* ------------

* General Model
xtlogit b90 e* year2-year13 [iw=uw], fe
local eadmsel = _b[eadmsel]
local eseladm = _b[eseladm]

* Fit-Indices
quietly clogit b90 e* year2-year13, group(persnr)
fitstat

* Variace Estimation
local coef: subinstr local uv `"eseladm"' `" "'
local coef: subinstr local coef `"eadmsel"' `" "'
macro drop _statlist
foreach piece of local coef {
	local statlist " `statlist' _b[`piece'] "
}
rgroup "xtlogit b90 e* year2-year13 [iw=uw], fe" "`statlist'", /*
*/  rgroups(prgroup)

* Store Results
matrix bb90 = r(val)'
matrix seb90 = r(se)'



* Save results
* ------------

drop _all

svmat bspd
svmat sespd
svmat bcdu
svmat secdu
svmat bb90
svmat seb90

* Fehlende Koeffizienten:
gen str8 uv = "."
forvalues i = 1/21 {
	local stat: word `i' of `uv'
	replace uv = "`stat'" in `i'
}

* eadmsel feht im B90-Modell: 1. Koeffizient
gen x = .
replace x = seb90[_n-1] if _n > 1
replace seb90 = x if _n >= 1
gen y = .
replace y = bb90[_n-1] if _n > 1
replace bb90 = y if _n>=1
replace bb90 = `eadmsel' in 1

* eseladm fehlt im B90-Modell: 4. Koeffizient
replace x = .
replace x = seb90[_n-1] if _n > 4
replace seb90 = x if _n >= 4
replace y = .
replace y = bb90[_n-1] if _n > 4
replace bb90 = y if _n>=4
replace bb90 = `eseladm' in 4

drop x y

save pidlv3, replace

* Producing Output
* ----------------

* calculate t
gen tspd = bspd1/sespd1
gen tcdu = bcdu1/secdu1
gen tb90 = bb901/seb901

*Format output 
gen str8 spd1 =  string(bspd1, "%5.2f")
gen str8 cdu1 =  string(bcdu1, "%5.2f")
gen str8 b901 =  string(bb901, "%5.2f")

gen str8 spd2 = "(" + trim(string(tspd, "%5.2f")) + ")"
gen str8 cdu2 = "(" + trim(string(tcdu, "%5.2f")) + ")"
gen str8 b902 = "(" + trim(string(tb90, "%5.2f")) + ")"

keep uv spd? cdu? b90?

gen i = _n
ren uv uv1
gen str8 uv2 = " "
reshape long uv spd cdu b90, j(coef) i(i)

* output
list uv spd cdu b90, nodisplay noobs

exit




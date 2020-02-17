* Fixed-Effects-Logit-Modelle (zeitversetzt, Variante mit Zeitinteraktion)
* Vollständige Information

clear
version 7.0
set memory 60m
set matsize 800


capture which rgroup
if _rc ~= 0 {
	archinst rgroup
	net install rgroup
}

use persnr welle pid e* polint uw prgroup using pidlv
drop est escheid 

* +------------------------------------------------------+
* |                     Rekodierungen                    |
* +------------------------------------------------------+

* Parteiidentifikaton
* -------------------
 
drop if pid == .
gen byte spd = pid == 2 
gen byte cdu = pid == 3 | pid == 4
gen byte b90 = pid == 5 

* Erhebungswellen-Dummies
* -----------------------

tab welle, gen(year)

* Shorten varname
* ---------------

ren eparkons eparcdu

* Time-Lags
* ---------

sort persnr welle
foreach piece of varlist e* {
	qby persnr (welle): replace `piece' = 1 + ln(sum(`piece'))  /*
	*/  if `piece' > 0
}

* Log(Anzahl Teilnahmen)
* ----------------------

qby persnr (welle): gen teiln = 1 + ln(_n)


* Politisches Interesse
* ---------------------

replace polint = . if polint < 0
replace polint = 4 - polint /* Spiegelung, kein Interesse = 0 */ 

gen polinti = polint * teiln


* Building UVlist
* ---------------

foreach piece of varlist e* {
	local ia = abbrev("`piece'",7)
	gen byte `ia'i = polint * `piece'
	local uv "`uv' `piece' `ia'i"
}

* +---------------+
* | Koeffizienten |
* +---------------+ 

* SPD - Modell
* ------------

xtlogit spd `uv' polint* year2-year13 [iw=uw], fe
matrix bspd = e(b)'

* Fit-Indices
quietly clogit spd `uv' polint* year2-year13, group(persnr)
fitstat

* CDU - Modell
* ------------

xtlogit cdu `uv' polint* year2-year13 [iw=uw], fe
matrix bcdu = e(b)'

* Fit-Indices
quietly clogit cdu `uv' polint* year2-year13, group(persnr)
fitstat

* B90 - Modell
* ------------

xtlogit b90 `uv' polint*  year2-year13 [iw=uw], fe
matrix bb90 = e(b)'

* Fit-Indices
quietly clogit b90 `uv' polint* year2-year13, group(persnr)
fitstat


* Save results
* ------------
preserve
drop _all

svmat bspd
svmat bcdu
svmat bb90

* Fehlende Koeffizienten:
gen str8 uv = "."
local i 1
foreach piece of local uv {
	replace uv = "`piece'" in `i' 
	local i = `i' + 1
}

gen index = _n
save pidlv7, replace
restore


* +--------------------+
* |Variance Estimation |
* +--------------------+

* Statlist
* --------

foreach piece of local uv {
	local statlist "`statlist' _b[`piece'] "
}

* SPD-Modell
* ----------

rgroup "xtlogit spd `uv' polint* year2-year13 [iw=uw], fe" "`statlist'",  /*
*/ rgroups(prgroup)
matrix sespd = r(se)'


* CDU-Modell
* ----------

* Zu wenig Beobachtungen bei einigen Koeffizienten

local coef: subinstr local statlist `"_b[eparb90]"' `" "' 
local coef: subinstr local coef `"_b[eparb90i]"' `" "' 

rgroup "xtlogit cdu `uv' polint* year2-year13 [iw=uw], fe" "`coef'",  /*
*/ rgroups(prgroup)
matrix secdu = r(se)'


* B90-Modell
* ----------

* Zu wenig Beobachtungen bei einigen Koeffizienten

local coef: subinstr local statlist `"_b[eseladm]"' `" "'
local coef: subinstr local coef `"_b[eseladmi]"' `" "'
local coef: subinstr local coef `"_b[eadmsel]"' `" "'
local coef: subinstr local coef `"_b[eadmseli]"' `" "'
local coef: subinstr local coef `"_b[eparcdu]"' `" "'
local coef: subinstr local coef `"_b[eparcdui]"' `" "'
local coef: subinstr local coef `"_b[eparb90]"' `" "'
local coef: subinstr local coef `"_b[eparb90i]"' `" "'

rgroup "xtlogit b90 `uv' polint* year2-year13 [iw=uw], fe" "`coef'", /*
*/  rgroups(prgroup)
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
local i 1
foreach piece of local uv {
	replace uv = "`piece'" in `i' 
	local i = `i' + 1
}

* eparb90(i) fehlt im CDU-Modell
gen x = .
replace x = secdu[_n-2] if _n >= 47
replace seb90 = x if _n >= 45

* eadmsel(i) fehlt im B90-Modell
replace x = .
replace x = seb90[_n-2] if _n >= 3
replace seb90 = x if _n >= 1

* eseladm(i) fehlt im B90-Modell
replace x = .
replace x = seb90[_n-2] if _n >= 9
replace seb90 = x if _n >= 7

* eparcdu(i) fehlt im B90-Modell
replace x = .
replace x = seb90[_n-2] if _n >= 47
replace seb90 = x if _n >= 45

* eparb90(i) fehlt im CDU-Modell
replace x = .
replace x = seb90[_n-2] if _n >= 49
replace seb90 = x if _n >= 47

drop x 

gen index = _n

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






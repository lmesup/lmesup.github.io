* Fixed-Effects-Logit-Modelle (zeitversetzt - Dummiekodirung)
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

use persnr welle pid e* welle uw prgroup using pidlv
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

* Dummies für Time-Lag
* --------------------
sort persnr welle
foreach piece of varlist e* {
	qby persnr (welle): gen `piece'1 = `piece' ==  (1 + `piece'[_n-1])
	qby persnr (welle): replace `piece'1 = 1 if `piece' == 1 & _n == 1
	qby persnr (welle): gen `piece'2 = `piece'1[_n-1] == 1
	qby persnr (welle): replace `piece'2 = sum(`piece'2)
	drop `piece'
}

* Building UVlist
* ---------------

foreach piece of varlist e* {
	local uv "`uv' `piece' "
}

* +---------------+
* | Koeffizienten |
* +---------------+ 

* SPD - Modell
* ------------

xtlogit spd `uv'  year2-year13 [iw=uw], fe
matrix bspd = e(b)'

* Fit-Indices
clogit spd `uv'  year2-year13, group(persnr)
fitstat

* CDU - Modell
* ------------

xtlogit cdu `uv'  year2-year13 [iw=uw], fe
matrix bcdu = e(b)'

* Fit-Indices
quietly clogit cdu `uv'  year2-year13, group(persnr)
fitstat

* B90 - Modell
* ------------

xtlogit b90 `uv'   year2-year13 [iw=uw], fe
matrix bb90 = e(b)'

* Fit-Indices
quietly clogit b90 `uv'  year2-year13, group(persnr)
fitstat


* Zwischenspeichern der Koeffizienten
* -----------------------------------

preserve

drop _all
svmat bspd
svmat bcdu
svmat bb90
gen index = _n

gen str8 uv = "."
local i 1
foreach piece of local uv {
	replace uv = "`piece'" in `i' 
	local i = `i' + 1
}

save pidlv6, replace
restore

exit




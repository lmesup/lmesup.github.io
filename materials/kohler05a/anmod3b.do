* Coefficients Model 3 (gradual effects)

clear
version 7.0
set memory 60m
set matsize 800

use persnr welle pid e* polin uw prgroup using pidlv

* +------------------------------------------------------+
* |                     Rekodierungen                    |
* +------------------------------------------------------+

* Parteiidentifikaton
* -------------------
 
drop if pid == .
gen byte left = pid == 2 
gen byte kons = pid == 3 

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

replace polin = . if polin < 0
replace polin = 4 - polin /* Spiegelung, kein Interesse = 0 */ 

gen polini = polin * teiln
  
* Building UVlist
* ---------------

foreach piece of varlist e* {
	local ia = abbrev("`piece'",7)
	gen byte `ia'i = polin * `piece'
	local uv "`uv' `piece' `ia'i"
}

* +---------------+
* | Koeffizienten |
* +---------------+ 

xtlogit left `uv' polin* year2-year13 [iw=uw], fe
matrix bleft = e(b)'

xtlogit kons `uv' polin* year2-year13 [iw=uw], fe
matrix bkons = e(b)'

* Save results
* ------------

preserve
drop _all

svmat bleft
svmat bkons

* Fehlende Koeffizienten:
gen str8 uv = "."
local i 1
foreach piece of local uv {
	replace uv = "`piece'" in `i' 
	local i = `i' + 1
}

gen index = _n
save mod3, replace
restore

exit

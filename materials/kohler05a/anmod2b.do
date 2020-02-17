* Koeff. Fixed-Effects-Logit-Modell 2 (Unvollständige Information)

clear
version 7.0
set memory 60m
set matsize 800

use persnr welle pid e* welle polin uw prgroup using pidlv

* Rekodierungen
* -------------

drop if pid == .
gen byte left = pid == 2
gen byte kons = pid == 3

tab welle, gen(year)

replace polin = . if polin < 0
replace polin = 4 - polin /* Spiegelung, kein Interesse = 0 */ 

ren eparkons eparcdu

* Building UVlist
* ---------------

foreach piece of varlist e* {
	local ia = abbrev("`piece'",7)
	gen byte `ia'i = polin * `piece'
	local uv "`uv' `piece' `ia'i"
}


* Koeffizienten 
* ------------- 

xtlogit left `uv' polin year2-year13 [iw=uw], fe
matrix bleft = e(b)'

xtlogit kons `uv' polin year2-year13 [iw=uw], fe
matrix bkons = e(b)'


* Save results
* ------------

drop _all

svmat bleft
svmat bkons

gen str8 uv = "."
local i 1
foreach piece of local uv {
	replace uv = "`piece'" in `i' 
	local i = `i' + 1
}

gen index = _n
save mod2b, replace

exit



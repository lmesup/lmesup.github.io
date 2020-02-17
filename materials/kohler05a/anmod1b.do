* Koeffizeinten Fixed-Effects-Logit-Modell (augenblicklich/permanent)

clear
version 7.0
set memory 60m
set matsize 800

use persnr welle e* welle uw prgroup pid using pidlv
drop eparspd eparkons 


* Rekodierungen
* -------------


drop if pid == .
gen left = pid == 2 
gen kons = pid == 3 
drop pid

tab welle, gen(year)
drop welle


* Building Uvarist
foreach piece of varlist e* {
	local uvars "`uvars' `piece'"
}

* LEFT - Modell
* ------------

* General Model
xtlogit left e* year2-year13 [iw=uw], fe

* Store Results
matrix bleft = e(b)'

* KONS - Modell
* ------------

* General Model
xtlogit kons e* year2-year13 [iw=uw], fe

* Store results
matrix bkons = e(b)'

* Save results
* ------------

drop _all

svmat bleft
svmat bkons

gen str8 uv = "."
forvalues i = 1/21 {
	local uv: word `i' of `uvars'
	replace uv = "`uv'" in `i'
}

save mod1b, replace

exit




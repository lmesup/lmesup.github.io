* Suchraum im B90-Modell (ungewichtet) schwirig? 

clear
version 7.0
set memory 60m
set matsize 800

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
* | Modell        |
* +---------------+ 

* Random noise    
* ------------    

sort persnr welle
gen x = int(uniform()*20) + 1
qby persnr (welle): replace b90 = b90[_n-1] if x[_N] == 1

clogit b90 `uv' polint* year2-year13, group(persnr) 


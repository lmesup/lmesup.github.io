* Fixed-Effects-Logit-Modelle Grüne, Ad-Hoc-hypothese zum Schulabschluss. 
* Unvollständige Information

clear
version 7.0
set memory 60m
set matsize 800


capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}


mkdat  /*
*/ ap0502 bp1502 cp1502 dp1102 ep1102 fp0902 gp1102 hp0602  /*
*/ ip1402 jp1402 kp1902 lp1502 mp1402 np1002  /*
*/ using $soepdir,  /*
*/ netto(-3,-2,-1,0,1,2,3,4,5) files(p) waves(a b c d e f g h i j k l m n)


*  +----------------------------------------------------------------+
*  |                        Rename to Reshape                       |
*  +----------------------------------------------------------------+

* Programm zum Umbenennen einer Varlist
capture program drop umben
program define umben
	local newname `1'
	mac shift
	local i 84
	while "`1'" ~= "" {
		ren `1' `newname'`i'
		local i = `i' + 1
		mac shift
	}
end

umben uni ap0502 bp1502 cp1502 dp1102 ep1102 fp0902 gp1102 hp0602  /*
*/ ip1402 jp1402 kp1902 lp1502 mp1402 np1002  

*  +----------------------------------------------------------------+
*  |                    Reshape                                     |
*  +----------------------------------------------------------------+

keep persnr uni*
reshape long uni, i(persnr) j(welle)


*  +----------------------------------------------------------------+
*  |                   Ereignisindikator Studiumsbeginn             |
*  +----------------------------------------------------------------+

* Ereignisindikatoren
* -------------------
sort persnr welle

* Aufnahme eines Studiums
* -----------------------

gen byte euni = 1  /*
*/ if uni >= 1 & uni <= 2 & uni[_n-1] == -2 
qby persnr (welle): replace euni = sum(euni) if _n > 1


*  +----------------------------------------------------------------+
*  |                 Merge with pidlv                               |
*  +----------------------------------------------------------------+


sort persnr welle
save 11, replace


use persnr welle pid e* welle polint uw prgroup using pidlv
drop est escheid 
sort persnr welle

merge persnr using 11
keep if _merge==1 | _merge == 3


* Rekodierungen
* -------------

drop if pid == .
gen byte spd = pid == 2 
gen byte cdu = pid == 3 | pid == 4
gen byte b90 = pid == 5 

tab welle, gen(year)

replace polint = . if polint < 0
replace polint = 4 - polint /* Spiegelung, kein Interesse = 0 */ 

ren eparkons eparcdu

* Building UVlist
* ---------------

foreach piece of varlist e* {
	local ia = abbrev("`piece'",7)
	di "gen byte `ia'i = polint * `piece'"
	gen byte `ia'i = polint * `piece'
	local uv "`uv' `piece' `ia'i"
}

* +---------------+
* | Koeffizienten |
* +---------------+ 


* B90 - Modell
* ------------

xtlogit b90 `uv' polint  year2-year13 [iw=uw], fe
matrix bb90 = e(b)'


* Save results
* ------------

drop _all

svmat bb90
local uv: rownames bb90

gen str8 uv = "."
local i 1
foreach piece of local uv {
	replace uv = "`piece'" in `i' 
	local i = `i' + 1
}

gen index = _n
save pidlv5, replace





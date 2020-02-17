* Vergleich der Simulation mit realen Daten (SOEP 1988)

version 6.0
clear
set memory 60m

* 0) Cool-Ados
* -------------

* benoetigt mkdat.ado
capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}
capture which hplot
if _rc ~= 0 {
	archinst hplot
}


* 1) Retrival
* -----------

* Klasse, Bilung, Kohorte und Partei
mkdat megph88 pid88 bil88 bbil88 using $soepdir,  /*
*/ waves(e) files(peigen) keep(sex gebjahr)

* Merge der Querschnittsgewichtung und Random-Groups
drop enetto 
ren ehhnr hhnrakt
sort persnr
tempfile temp
save `temp', replace
use persnr ephrf prgroup using $soepdir/phrf
sort persnr
merge persnr using `temp'
drop if _merge ~= 3
drop _merge

* 2) Rekodierungen
* ----------------

gen egp = .
replace egp = 1 if megph >= 5 & megph <= 7 
replace egp = 2 if megph == 1
replace egp = 3 if megph == 2 | megph == 4 | megph == 8 | megph == 12
replace egp = 4 if megph == 3 | (megph >= 9 & megph <= 11)
lab var egp Klasse
lab val egp egp
lab def egp 1 "Arbeitgeber" 2 "Manager" 3 "Mischtyp/Techniker"  /*
*/ 4 "Soz.B./Arbeiter"   
drop if egp == .

gen bil = bil88 == 3 | bil88 == 4 if bil88 ~= .
lab var bil "Bilung"
lab val bil bil
lab def bil 0 "niedrig" 1 "hoch", modify
drop if bil == .

gen koh = gebjahr >= 1940 if gebjahr ~= .
lab var koh "Kohorte"
lab val koh koh
lab def koh 0 "alt" 1 "jung"
drop if koh == .

replace pid = . if pid == 1 | pid >= 6
gen spd = pid == 2 if pid ~= .
gen kons = pid == 3 | pid == 4 if pid ~= .
gen b90 = pid == 5 if pid ~= .
drop if pid == .

collapse (mean) mkons=kons mspd=spd  mb90=b90 [aweight = ephrf], /* 
*/ by(egp bil koh) 
sort koh bil egp

tempname simul4
save `simul4'

use simul, clear

collapse  (min) minkons=kons minspd=spd minb90=b90  /*
*/        (max) maxkons=kons maxspd=spd maxb90=b90 /*
*/, by(egp bil koh) 

replace bil = "aniedrig" if bil=="niedrig"  /* damit niedrig zuerst kommt */
sort koh bil egp
ren koh skoh
ren bil sbil
ren egp segp
merge using `simul4'

* common options 
local opt "flipt bor xscale(0,1) format(%2.1f) line range xlab(0(.2)1) s(i|i)"
local opt "`opt' gaps(0,4,8,12) pen(222) cstart(10000) l(egp) gllj glpos(0) ttick "
local opt "`opt' glegend(Alt, niedrige Bildung!Alt, hohe Bildung!Jung, niedrige Bildung!Jung, hohe Bildung)" 

hplot minkons mkons maxkons , /*
*/ `opt' title(CDU/CSU u. FDP) t2(" ") 

hplot minspd mspd maxspd , /*
*/ `opt' title(SPD) t2(" ") 

hplot minb90  mb90 maxb90 , /*
*/ `opt' title(Buendnis 90/Die Gruenen) t2(" ")

exit




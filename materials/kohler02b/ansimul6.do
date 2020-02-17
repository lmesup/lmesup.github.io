* Vergleich der Simulation mit realen Daten
* Struktur der Parteipräferenzen in Simulation (Mittelwerte)
* SOEP und Allbus

* Die Datei benötigt myhplot2.ado, eine hochspezialisierte Version von 
* hplot.ado. Die Datei sollte im Arbeitsverzeichnis liegen.


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


* 1) Retrival SOEP
* -----------------

* Klasse, Bilung, Kohorte und Partei
mkdat  /*
*/ megph84 megph85 megph86 megph87 megph88 megph89 megph90 megph91 megph92 /*
*/  megph93 megph94 megph95 megph96 megph97  /*
*/ pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 /*
*/  pid93 pid94 pid95 pid96 pid97  /*
*/ bil84 bil85 bil86 bil87 bil88 bil89 bil90 bil91 bil92 /*
*/  bil93 bil94 bil95 bil96 bil97  /*
*/ using $soepdir,  /*
*/ waves(a b c d e f g h i j k l m n) files(peigen) keep(gebjahr)  /*
*/ netto(-3,-2,-1,0,1,2,3,4,5)

* Merge der Gewichtung und Random-Groups
sort persnr
tempfile temp
save `temp', replace
use persnr aphrf bphrf cphrf dphrf ephrf fphrf gphrf hphrf iphrf  /*
*/ jphrf kphrf lphrf mphrf nphrf using $soepdir/phrf
sort persnr
merge persnr using `temp'
drop if _merge ~= 3
drop _merge

for any a b c d e f g h i j k l m n \ num 84/97: ren Xphrf phrfY
keep persnr megph* pid* bil* gebjahr phrf*
reshape long megph pid bil phrf, j(welle) i(persnr)


* 2) Rekodierungen SOEP
* ---------------------

gen egp = .
replace egp = 1 if megph >= 5 & megph <= 7 
replace egp = 2 if megph == 1
replace egp = 3 if megph == 2 | megph == 4 | megph == 8 | megph == 12
replace egp = 4 if megph == 3 | (megph >= 9 & megph <= 11)
lab var egp Klasse
lab val egp egp
lab def egp 1 "Arbeitgeber" 2 "Admin. Dienste" 3 "Mischtyp/Experten"  /*
*/ 4 "Soz.D./Arbeiter"   
drop if egp == .

replace bil = bil == 3 | bil == 4 if bil ~= .
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

count

* 3. Analyse SOEP
* ------------

collapse (mean) soepkons=kons soepspd=spd  soepb90=b90  [aweight = phrf], /* 
*/ by(egp bil koh) 
sort koh bil egp

tempname simul4
save `simul4'


* 4) Retrival ALLBUS
* ------------------

* Klasse, Bilung, Kohorte und Partei
use v2 v22 v323 v333 v395 v400 v436 v437 v436 v437 v844 v845  /*
*/ using $allbdir/allb8098

keep if v2 <= 1992

* 5) Rekodierungen  ALLBUS
* ------------------------

* Mueller-EGP (Einordung Pappi) 

* Administrative Dienstklasse (ISCO 1 und 2; 121-129; 201-999)
gen megp = 1 if (v400 == 1 | v400 == 2) &  /*
*/ ((v395==1 | v395==2) | (v395>=121 & v395<=129) | (v395>=201 & v395<=999))

* Experten (ISCO 11-54; 81-110)
replace  megp = 2 if (v400 == 1 | v400 == 2) &   /*
*/ ((v395>=11 & v395<=54) | (v395>=81 & v395<=110))

* Soziale Dienstleistungen  (ISCO 61-79; 131-199) 
replace  megp = 3 if (v400 == 1 | v400 == 2) &   /*
*/ ((v395>=61 & v395<=79) | (v395>=131 & v395<=199))

* Rest
replace megp = v400 + 1 if v400 > 2 & v400 ~= .  
replace megp = v400 if v400 < 0

* Kategorisierung EGP
gen egp = .
replace egp = 1 if megp >= 5 & megp <= 7 
replace egp = 2 if megp == 1
replace egp = 3 if megp == 2 | megp == 4 | megp == 8 | megp == 12
replace egp = 4 if megp == 3 | (megp >= 9 & megp <= 11)
lab var egp Klasse 
lab val egp egp
lab def egp 1 "Arbeitgeber" 2 "Admin. Dienste" 3 "Mischtyp/Experten"  /*
*/ 4 "Soz.D./Arbeiter"   
drop if egp == .

* Bildung
gen bil = v333 == 4 | v333 == 5 if v333 ~= .
lab var bil "Bilung"
lab val bil bil
lab def bil 0 "niedrig" 1 "hoch", modify
drop if bil == .

* Kohorte
gen koh = v323 >= 1940 if v323 ~= .
lab var koh "Kohorte"
lab val koh koh
lab def koh 0 "alt" 1 "jung"
drop if koh == .

* Wahlabsicht
replace v22 = . if v22 == 4 | v22 == 5 | v22 >= 7
gen spd = v22 == 2 if v22 ~= .
gen kons = v22 == 1 | v22 == 3
gen b90 = v22 == 6 if v22 ~= .
drop if v22 == .

* 6 Analyse ALLBUS
* ----------------

count

collapse (mean) allbkons=kons allbspd=spd  allbb90=b90, /* 
*/ by(egp bil koh) 
sort koh bil egp

tempname simul2
save `simul2'

use simul, clear

collapse  (mean) kons=kons spd=spd b90=b90 , /*
*/ by(egp bil koh) 

replace bil = "aniedrig" if bil=="niedrig"  /* damit niedrig zuerst kommt */
replace egp = "AArbeitgeber" if egp == "Arbeitgeber"
sort koh bil egp
replace egp = "Arbeitgeber" if egp == "AArbeitgeber"
ren koh skoh
ren bil sbil
ren egp segp
merge using `simul4'
drop _merge
merge using `simul2'


* common options 
local opt "flipt bor xscale(0,1) grid format(%2.1f) xlab(0(.2)1) s(p..)"
local opt "`opt' gaps(0,4,8,12) cstart(10000) l(egp) pen(222) gllj glpos(0) ttick "
local opt "`opt' glegend(Alt, niedrige Bildung!Alt, hohe Bildung!Jung, niedrige Bildung!Jung, hohe Bildung)" 
local opt "`opt' fontr(750) fontc(381)"

myhplot2 kons soepkons allbkons, /*
*/ `opt' title(CDU/CSU u. FDP) t2(" ") /*
*/ saving(simul6a, replace)

myhplot2 spd soepspd allbspd , /*
*/ `opt' title(SPD) t2(" ") /*
*/ saving(simul6b, replace)

myhplot2 b90 soepb90 allbb90, /*
*/ `opt' title(Buendnis 90/Die Gruenen) t2(" ") /*
*/ saving(simul6c, replace)

exit


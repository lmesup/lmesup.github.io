* Vergleich der Simulation mit realen Daten
* (Allbus 1984-1992)
* Beschränkung auf Zeitraum vor 1992, da Einordnung nach Pappi nur bis 1992

* Dieser Do-File benötigt eine myhplot.ado. Dies ist eine 
* spezielle Version von hplot.ado. Mit myhplot.ado werden waagrechte 
* bei Angabe der Option "range" waagrechte Linien von der ersten zur 
* zweiten Variable gezeichnet. myhplot.ado ist eine hochspezialisierte
* Version von hplot.ado. Die Datei findet sich darum im Arbeitsverzeichnis
* ~/diss/analysen. Sie sollte nicht in das persoenliche Ado-Verzeichnis
* kopiert werden.



version 6.0
clear
set memory 60m

* 0) Cool-Ados
* -------------


* 1) Retrival
* -----------

* Klasse, Bilung, Kohorte und Partei
use v2 v22 v323 v333 v395 v400 v436 v437 v436 v437 v844 v845  /*
*/ using $allbdir/allb8098

keep if v2 <= 1992

* 2) Rekodierungen 
* ----------------

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

count

collapse (mean) mkons=kons mspd=spd  mb90=b90, /* 
*/ by(egp bil koh) 
sort koh bil egp

tempname simul
save `simul'

use simul_c, clear

collapse  (min) minkons=kons minspd=spd minb90=b90  /*
*/        (max) maxkons=kons maxspd=spd maxb90=b90, /*
*/ by(egp bil koh) 

replace bil = "aniedrig" if bil=="niedrig"  /* damit niedrig zuerst kommt */
replace egp = "AArbeitgeber" if egp == "Arbeitgeber"
sort koh bil egp
replace egp = "Arbeitgeber" if egp == "AArbeitgeber"
ren koh skoh
ren bil sbil
ren egp segp
merge using `simul'

* common options 
local opt "flipt bor xscale(0,1) line range format(%2.1f) xlab(0(.2)1) s(ii|)"
local opt "`opt' gaps(0,4,8,12) pen(222) cstart(10000) l(egp) gllj glpos(0) ttick "
local opt "`opt' glegend(Alt, niedrige Bildung!Alt, hohe Bildung!Jung, niedrige Bildung!Jung, hohe Bildung)" 
local opt "`opt' fontr(750) fontc(381)"

myhplot minkons maxkons mkons, /*
*/ `opt' title(CDU/CSU u. FDP) t2(" ") /*
*/ saving(simul5a_c, replace)

myhplot minspd maxspd mspd , /*
*/ `opt' title(SPD) t2(" ") /*
*/ saving(simul5b_c, replace)

myhplot minb90 maxb90 mb90, /*
*/ `opt' title(Buendnis 90/Die Gruenen) t2(" ") /*
*/ saving(simul5c_c, replace)

exit




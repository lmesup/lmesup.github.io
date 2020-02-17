* Vergleich der Simulation mit realen Daten 
* (SOEP 1984 - 1997, unbalanced Panel Design)

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

* benoetigt mkdat.ado
capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}


* 1) Retrival
* -----------

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


* 2) Rekodierungen
* ----------------

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

collapse (mean) mkons=kons mspd=spd  mb90=b90  [aweight = phrf], /* 
*/ by(egp bil koh) 
sort koh bil egp

tempname simul4
save `simul4', replace

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
merge using `simul4'

* common options 
local opt "flipt bor xscale(0,1) format(%2.1f) range line xlab(0(.2)1) s(ii|)"
local opt "`opt' gaps(0,4,8,12) cstart(10000) pen(222) l(egp) gllj glpos(0) ttick "
local opt "`opt' glegend(Alt, niedrige Bildung!Alt, hohe Bildung!Jung, niedrige Bildung!Jung, hohe Bildung)" 
local opt "`opt' fontr(750) fontc(381)"


myhplot minkons maxkons mkons , /*
*/ `opt' title(CDU/CSU u. FDP) t2(" ") /*
*/ saving(simul4a_c, replace)

myhplot minspd maxspd mspd , /*
*/ `opt' title(SPD) t2(" ") /*
*/ saving(simul4b_c, replace)

myhplot minb90 maxb90 mb90, /*
*/ `opt' title(Buendnis 90/Die Gruenen) t2(" ") /*
*/ saving(simul4c_c, replace)

exit




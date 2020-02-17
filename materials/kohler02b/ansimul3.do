* Beschreibung des demokratischen Klassenkampfs im
* simulierten Datensatz simul.dta
* Erzeugt "simul3.gph", (entspricht simul2.gph, jedoch mit 
* Minimum und Maximum als Begrenzung des Verteilungsbereichs)

version 6.0

* 0) Cool-Ados
* -------------

* benoetigt hplot.ado.
capture which hplot
if _rc ~= 0 {
	archinst hplot
}

use simul, clear

* 1) Grafische Darstellung
* ------------------------

collapse (mean) mkons=kons mspd=spd  mb90=b90 /* 
*/        (min) minkons=kons minspd=spd minb90=b90 /*
*/        (max) maxkons=kons maxspd=spd maxb90=b90, /*
*/ by(egp bil koh) 

replace bil = "aniedrig" if bil=="niedrig"  /* damit niedrig zuerst kommt */
replace egp = "AArbeitgeber" if egp == "Arbeitgeber"
sort koh bil egp
replace egp = "Arbeitgeber" if egp == "AArbeitgeber"

* common options 
local opt "flipt bor xscale(0,1) format(%2.1f) line range xlab(0(.2)1) s(|o|)"
local opt "`opt' gaps(0,4,8,12) cstart(10000) pen(222) l(egp) gllj glpos(0) ttick "
local opt "`opt' glegend(Alt, niedrige Bildung!Alt, hohe Bildung!Jung, niedrige Bildung!Jung, hohe Bildung)" 
local opt "`opt' fontr(750) fontc(381)"

hplot minkons mkons maxkons, /*
*/ `opt' title(CDU/CSU u. FDP) t2(" ") /*
*/ saving(simul3a, replace)

hplot minspd mspd maxspd, /*
*/ `opt' title(SPD) t2(" ") /*
*/ saving(simul3b, replace)

hplot minb90 mb90 maxb90, /*
*/ `opt' title(Buendnis 90/Die Gruenen) t2(" ") /*
*/ saving(simul3c, replace)

exit

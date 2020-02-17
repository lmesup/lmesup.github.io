* Beschreibung des demokratischen Klassenkampfs im
* simulierten Datensatz simul.dta
* Erzeugt "simul2.gph", ein Variante von simul1.gph in anderer
* anderer Anordnung

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
*/        (p5)  p5kons=kons p5spd=spd p5b90=b90 /*
*/        (p95)  p95kons=kons p95spd=spd p95b90=b90, /*
*/ by(egp bil koh) 

replace bil = "aniedrig" if bil=="niedrig"  /* damit niedrig zuerst kommt */
replace egp = "AArbeitgeber" if egp == "Arbeitgeber"
sort koh bil egp
replace egp = "Arbeitgeber" if egp == "AArbeitgeber"

* common options 
local opt "flipt bor xscale(0,1) format(%2.1f) line range xlab(0(.2)1) s(|O|)"
local opt "`opt' gaps(0,4,8,12) cstart(10000) l(egp) gllj glpos(0) ttick "
local opt "`opt' glegend(Alt, niedrige Bildung!Alt, hohe Bildung!Jung, niedrige Bildung!Jung, hohe Bildung)" 

hplot p5kons mkons p95kons, /*
*/ `opt' title(CDU/CSU u. FDP) t2(" ") /*
*/ saving(simul2a, replace)

hplot p5spd mspd p95spd, /*
*/ `opt' title(SPD) t2(" ") /*
*/ saving(simul2b, replace)

hplot p5b90 mb90 p95b90, /*
*/ `opt' title(Buendnis 90/Die Gruenen) t2(" ") /*
*/ saving(simul2c, replace)

exit

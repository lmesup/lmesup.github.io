* Beschreibung des demokratischen Klassenkampfs im
* simulierten Datensatz simul1.dta
* Erzeugt "simul1.gph"

version 6.0

* 0) Cool-Ados
* -------------

* benoetigt hplot.ado.
capture which hplot
if _rc ~= 0 {
	archinst hplot
}

use simul, clear

* 1) Tabellarische Darstellung
* ----------------------------

sort egp koh bil
by egp koh bil: sum kons b90 spd


* 2) Grafische Darstellung
* ------------------------

collapse (mean) m1=kons m2=spd m3=b90 /* 
*/        (min) min1=kons min2=spd min3=b90 /*
*/        (max) max1=kons max2=spd max3=b90, /*
*/ by(egp bil koh) 

gen group = _n
reshape long m min max, i(group) j(partei)
lab var partei "Wahlverhalten (Prognose)"
lab val partei partei
lab def partei 1 "Konservativ" 2 "SPD" 3 "B90/Gr."

* common options 
local opt /* 
*/ "flipt bor xscale(0,1) format(%2.1f) line range xlab(0(.2)1) s(|o|)"
local opt "`opt' cstart(3000) fontr(900) fontc(400)"


local i 1
while `i' <= 16 {
	tempfile g`i'
	local i = `i' + 1 
}


* Grapiken links:
hplot min m max  /*
*/ if egp == "Arbeitgeber" & koh=="alt" & bild == "niedrig",  /*
*/ l(partei) t2t("Arbeitgeber, niedrige Bildung, alte Kohorte") `opt'   /*
*/  saving(`g1', replace)
hplot min m max  /*
*/ if egp == "Admin. Dienste" & koh=="alt" & bild == "niedrig",  /*
*/ l(partei) t2t("Admin. Dienste, niedrige Bildung, alte Kohorte") `opt'   /*
*/  saving(`g5', replace)
hplot min m max  /*
*/ if egp == "Mischtyp/Experten" & koh=="alt" & bild == "niedrig",  /*
*/ l(partei) t2t("Mischtyp/Experten, niedrige Bildung, alte Kohorte") `opt'   /*
*/  saving(`g9', replace)
hplot min m max  /*
*/ if egp == "Soz.D./Arbeiter" & koh=="alt" & bild == "niedrig",  /*
*/ l(partei) t2t("Soz.D./Arbeiter, niedrige Bildung, alte Kohorte") `opt'   /*
*/  saving(`g13', replace)

* Graphiken 2. Spalte
hplot min m max  /*
*/ if egp == "Arbeitgeber" & koh=="alt" & bild == "hoch",  /*
*/  t2t("Arbeitgeber, hohe Bildung, alte Kohorte") `opt' blank  /*
*/  saving(`g2', replace)
hplot min m max  /*
*/ if egp == "Admin. Dienste" & koh=="alt" & bild == "hoch",  /*
*/  t2t("Admin. Dienste, hohe Bildung, alte Kohorte") `opt' blank  /*
*/  saving(`g6', replace)
hplot min m max  /*
*/ if egp == "Mischtyp/Experten" & koh=="alt" & bild == "hoch",  /*
*/  t2t("Mischtyp/Experten, hohe Bildung, alte Kohorte") `opt' blank  /*
*/  saving(`g10', replace)
hplot min m max  /*
*/ if egp == "Soz.D./Arbeiter" & koh=="alt" & bild == "hoch",  /*
*/  t2t("Soz.D./Arbeiter, hohe Bildung, alte Kohorte") `opt' blank  /*
*/  saving(`g14', replace)

hplot min m max  /*
*/ if egp == "Arbeitgeber" & koh=="jung" & bild == "niedrig",  /*
*/  t2t("Arbeitgeber, niedrige Bildung, junge Kohorte") `opt' blank  /*
*/  saving(`g3', replace)
hplot min m max  /*
*/ if egp == "Admin. Dienste" & koh=="jung" & bild == "niedrig",  /*
*/  t2t("Admin. Dienste, niedrige Bildung, junge Kohorte") `opt' blank  /*
*/  saving(`g7', replace)
hplot min m max  /*
*/ if egp == "Mischtyp/Experten" & koh=="jung" & bild == "niedrig",  /*
*/  t2t("Mischtyp/Experten, niedrige Bildung, junge Kohorte") `opt' blank /*
*/  saving(`g11', replace)
hplot min m max  /*
*/ if egp == "Soz.D./Arbeiter" & koh=="jung" & bild == "niedrig",  /*
*/  t2t("Soz.D./Arbeiter, niedrige Bildung, junge Kohorte") `opt' blank  /*
*/  saving(`g15', replace)

* Graphiken 4. Spalte
hplot min m max  /*
*/ if egp == "Arbeitgeber" & koh=="jung" & bild == "hoch",  /*
*/  t2t("Arbeitgeber, hohe Bildung, junge Kohorte") `opt' blank  /*
*/  saving(`g4', replace)
hplot min m max  /*
*/ if egp == "Admin. Dienste" & koh=="jung" & bild == "hoch",  /*
*/  t2t("Admin. Dienste, hohe Bildung, junge Kohorte") `opt' blank  /*
*/  saving(`g8', replace)
hplot min m max  /*
*/ if egp == "Mischtyp/Experten" & koh=="jung" & bild == "hoch",  /*
*/  t2t("Mischtyp/Experten, hohe Bildung, junge Kohorte") `opt' blank  /*
*/  saving(`g12', replace)
hplot min m max  /*
*/ if egp == "Soz.D./Arbeiter" & koh=="jung" & bild == "hoch",  /*
*/  t2t("Soz.D./Arbeiter, hohe Bildung, junge Kohorte") `opt' blank  /*
*/  saving(`g16', replace)


graph using `g1' `g2' `g3' `g4' /*
*/          `g5' `g6' `g7' `g8'  /*
*/          `g9' `g10' `g11' `g12' /*
*/          `g13' `g14' `g15' `g16' /*
*/ , saving(simul1, replace)

exit

* Merkmale des EGP Klassenschemas im SOEP
* Persönliches Einkommen im letzten Monat
version 6.0
clear
set memory 60m

* Retrival des "Nettoeinkommen im letzten Monat"
use persnr ap3302 using $soepdir/ap
ren ap3302 ein84
sort persnr
save 11, replace

* Merge mit egpanh.dta
use persnr welle egp phrf using egpanh if welle == 84, clear
sort persnr
merge persnr using 11
keep if _merge == 3
drop _merge
erase 11.dta

* TABELLARISCH
* ------------

sort egp
replace ein = . if ein<=0
by egp: sum ein

* BOXPLOT
* -------

gen logein = log10(ein)
graph logein if egp > 0, by(egp) box /*
*/ yscale(1,5) ylabel(1,2,3,4,5) /*
*/ l1title("LOG10 (Einkommen)") t2title(" ") saving(egpei1a, replace)

* Vergleich mit ALLBUS
* --------------------

* Abspeichern zum Vergleich mit ALLBUS--Klassenschema:
keep egp ein phrf
collapse (mean) ein=ein [iweight = phrf] if ein > 0, by(egp)
gen data = 1
lab var data Datenquelle
lab val data data
lab def data 1 "SOEP" 2 "ALLBUS"
save temp1, replace

* ALLBUS Klassenschema
use v2 v363 v436 v844 v845 /*
*/using $allbdir/allb8098 if v2==1984, clear
ren v363 egpb
replace egp = . if egp == 0 | egp > 11
ren v436 ein
replace ein = . if ein<=0
eta2 ein egp
gen weight = v844*v845 if v844<99
collapse (mean) ein = ein [iweight=weight], by(egpb)
gen data = 2
label val data data
label val egp egp
append using temp1
erase temp1.dta

* Graphische Darstellung
* ----------------------
drop if egpb <= 0 | egpb == .
reshape wide ein, i(egpb) j(data)

lab var ein1 SOEP
lab var ein2 ALLBUS

hplot ein*, l(egpb) grid s(45) ttick /*
*/ bor  xscale(900,4000) xlabel(1000,2000,3000,4000) /*
*/ title("arith. Mittel (Einkommen)") saving(egpei2a, replace)
exit

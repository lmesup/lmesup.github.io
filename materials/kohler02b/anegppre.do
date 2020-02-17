* Merkmale des EGP Klassenschemas im SOEP
* Berufsprestige
* Erstellt Graphik egppre1.gph und egppre2*.gph
version 6.0
clear
set memory 60m

use wegen phrf treim egp using egpanh, clear

* Begrenzung Wertebereich der Prestigeskalen auf gueltige Auspraegungen
* ---------------------------------------------------------------------

replace wegen = . if wegen < 20 | wegen > 187
replace treim = . if treim < 14 | treim > 79

* Graphische Darstellung
* ----------------------

* BOXPLOT
capture program drop anegpmer
    program define anegpmer
        gph open, saving(anegppre, replace)
        sort egpb
        * ... mit Wegener
        graph wegen if egpb > 0, by(egpb) box /*
        */yscale(20,187) ylabel(20,60,100,140,180) /*
        */ bbox(0,0,11533,31900,600,300,0) t2title("nach Wegener")
        * ... mit Treiman
        graph treim if egpb > 0, by(egpb) box /*
        */yscale(14,79) ylab(15,30,45,60,75) /*
        */ bbox(11530,0,23063,31900,600,300,0) t2title("nach Treiman")
       gph close
    end
anegpmer
graph using anegppre, l1title(Berufsprestige) saving(egppre1, replace)

erase anegppre.gph

* Replikation von Tabelle 2.2 bei Erikson/Goldthorpe (1992: 45)
* -------------------------------------------------------------

* 7er Schema  (do egp7.var)
gen egp7=egpb
recode egp7 1 2 =1 3 11 =2 4 5 =3 6 =4 7 8 =5 9 =6 10 =7
lab var egp7 "EGP-Klassen, 7er-Schema"
lab val egp7 egp7
lab def egp7 1 "Dienstklasse" 2 "Nicht-manuelle Routineber." /*
*/ 3 "Selbstaendige" 4 "Selbstaendige Landwirte" 5 "Gelernte Arbeiter" /*
*/ 6 "Un- und angelernte Arb."  7 "Landarbeiter"

* Abspeichern zum Vergleich mit ALLBUS--Klassenschema:
keep egp7 wegen treim phrf
collapse (mean) wegen=wegen treim=treim [iweight = phrf], by(egp7)
gen data = 1
lab var data Datenquelle
lab val data data
lab def data 1 "SOEP" 2 "ALLBUS" 3 "Erikson"
save temp1, replace

* ALLBUS Klassenschema
use v2 v359 v360 v363 v408 v844 v845 /*
*/using $allbdir/allb8098, clear

gen weight = v844*v845

gen egp7=v363
recode egp7 1 2 =1 3 11 =2 4 5 =3 6 =4 7 8 =5 9 =6 10 =7 0 12=.
lab var egp7 "EGP-Klassen, 7er-Schema"
lab val egp7 egp7

collapse (mean) treim=v359 wegen=v360 [iweight=weight], by(egp7)
gen data=2
label val data data
append using temp1

* Daten aus Erikson Goldthorpe (1992: 45)
input
    1 56 92 3
    2 35 50 3
    3 42 49 3
    4 44 50 3
    5 35 49 3
    6 29 39 3
    7 24 30 3
end
table egp7 data if egp7 > 0, c(m wegen m treim) f(%2.0f)

* Graphische Darstellung
* ----------------------
drop if egp7<=0 | egp7 == .
reshape wide treim wegen, i(egp) j(data)

lab var wegen1 SOEP
lab var wegen2 ALLBUS
lab var wegen3 "Erikson/Goldthorpe"
lab var treim1 SOEP
lab var treim2 ALLBUS
lab var treim3 "Erikson/Goldthorpe"

hplot wegen*, l(egp7) grid s(465) pen(223) ttick /*
*/ bor xscale(15,92) xlabel(15,30,45,60,75,90) saving(egppre2a, replace)/*
*/ title("arith. Mittel (Prestige n. Wegener)") fontrb(570) fontcb(290)

hplot treim*, l(egp7) grid s(465) pen(223) ttick/*
*/ bor xscale(20,60) xlabel(20,30,40,50,60) saving(egppre2b, replace)/*
*/ t2title(".") title("arith. Mittel (Prestige n. Treiman)")/*
*/ fontrb(570) fontcb(290)

erase temp1.dta
exit

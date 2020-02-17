* Zentrale Fallzahlen im SOEP
version 6.0
clear
set memory 60m

* Daten laden
* -----------
use $soepdir/ppfad

* Rekodierungen
* -------------
* Umbenennen $netto
for any a b c d e f g h i j k l m n \ num 84/97: ren Xnetto nettoY

* Stammperson
gen stamm = 0
replace stamm = 1 if netto84 == 1
replace stamm = 2 if netto84 ==2
lab var stamm "Stammperson"
lab val stamm yesno
lab def stamm 0 "nein" 1 "befragt" 2 "nicht befragt"

* Stammpersonen mit Luecken zaehlen als Ausfall
gen net84 = netto84

local i 85
while `i' <= 97 {
    local j = `i'-1
	gen net`i' = netto`i'
    replace net`i' = -2 /*
    */ if stamm > 0 & netto`i' == 1 & (netto`j' < 1 | netto`j' > 2)
    local i = `i' + 1
}

* Wide -> Long
* ------------

keep persnr psample netto* net* stamm
reshape long netto net, i(persnr) j(welle)

* Fallzahlen realisierte Interviews
* ---------------------------------

tab welle psample if netto==1


* Graphik: Fallzahlen alte und neue Befrage
* -----------------------------------------

* Berechnung der Fallzahlen
keep if psample == 1 | psample == 2
keep if net==1 | net==2
collapse (count) n=persnr, by(welle stamm net)
reshape wide n, i(welle net) j(stamm)
reshape wide n0 n1 n2, i(welle) j(net)

replace n21= 0 if n21==.

gen nstamm =  n11 + n21 + n22        /* Stammpersonen insgesamt */
gen nstammb = n11 + n21              /* befragte Stammpersonen  */
gen nstammn = n11                    /* balanced Population */
gen nnew = n01 + n02                 /* neue Personen insgesamt */
gen nnewb = n01                      /* befragte neue Personen  */

* Ausgabe der Graphik
lab var welle "Erhebungsjahr"

capture program drop grafik
    program define grafik
        gph open, saving(cases1, replace)
            graph nstammb nnewb nstamm nstammn nnew nnewb welle, /*
            */c(ll||||) s(iiiiii) pen(222222) sort bor /*
            */xlab(84,86,88,90,92,94,96) /*
            */ylab(0,2500,5000,7500,10000,12500,15000) /*
            */l2t("Fallzahl") t1(" ")
            gph pen 1
            gph font 600 300
            gph text 11000 26000 0 -1 Stammpersonen
            gph text 19000 26000 0 -1 neue Personen
        gph close
    end
grafik

exit

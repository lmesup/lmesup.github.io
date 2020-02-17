* Grafiken der Koeffizienten im Analysedesign 1

* Intro
* -----
clear
version 7.0
set memory 60m


* antraeg1.do gelaufen? 
* Wenn nicht, jetzt starten und Koeffizienten laden
capture use des1_13
if _rc ~= 0 {
	do antraeg1
	use des1_13
}

* Ich merke mir den Lag
gen des = 1

* antreag2.do gelaufen, 
* Wenn nicht jetzt starten und Koeffizienten anhängen
append using des1_1
if _rc ~= 0 {
	do antraeg2
	append using des1_1
}

* Ich merke mir den Lag
replace des = 2 if des == .

* Ein paar Beschriftungen
lab var des "Design"
lab val des des
lab def des 1 "Lag-13" 2 "Lag-1"
lab var des11 "SPD"
lab var des12 "CDU/CSU, FDP"
lab var des13 "B90/Gr." 

* Durchnumerierung der Koeffizienten für beide lags
* --------------------------------------------------

gen index = _n in 1/14
replace index = _n-14 in 15/28
drop if index > 10

* Beobachtung fuer die Referenzkategorien
* ---------------------------------------

set obs 22
for num 1/3: replace des1X = 0 in 21/22
replace index = 0 in 21/22
replace des = 1 in 21
replace des = 2 in 22

* X-Achse für Vergangene Parteineigung
* ------------------------------------

gen pid = 0 if index == 0
replace pid = 1 if index == 1
replace pid = 2 if index == 2
lab var pid " "
lab val pid pid
lab def pid 0 "SPD" 1 "CDU" 2 "B90"

* X-Achse für Politische Stimmung im HH
* -------------------------------------

gen hhstim = 1 if index == 8
replace hhstim = 2 if index == 9
replace hhstim = 3 if index == 10
lab var hhstim " "
lab val hhstim hhstim
lab def hhstim 1 "CDU/FDP" 2 "SPD" 3 "B90/Gr."

* X-Achse für Klasse
* ------------------

gen egp = 0 if index==0
replace egp = 1 if index == 3 
replace egp = 2 if index == 4 
replace egp = 3 if index == 5 
replace egp = 4 if index == 6 
replace egp = 5 if index == 7 
lab var egp " "
lab val egp egp
lab def egp 0 "Selb." 1 "Adm. D." 2 "Exp." 3 "Soz. D."  /*
*/ 4 "Mischt." 5 "Arb."


* Zum Löschen der y-Achsenbeschriftung
* ------------------------------------

lab val des11 des1
lab val des12 des1
lab val des13 des1
lab def des1 0 " "


* Zusammenführen der beiden Teilgrafiken
* --------------------------------------

capture program drop grtraeg
	program define grtraeg
		gph open, saving(`1', replace)
			graph using g1
			graph using g2
			gph pen 2 
			gph point 500 7000 175 1
			gph point 500 13000 175 3
            gph point 500 22000 175 2
			gph pen 1
			gph text 675 7500 0 -1 SPD
			gph text 675 13500 0 -1 CDU/CSU/FDP
			gph text 675 22500 0 -1 B90/GR.
			gph text 22500 10000 0 1 Lag-13
			gph text 22500 24000 0 1 Lag-1
			gph text 22000 16000 0 0 `2' `3'
			gph font 1200 600
			gph text 11531 600 1 0 Marginaleffekte
		gph close
	end

* Vergangene Parteineigung
* ------------------------

graph des11 des12 des13 pid if pid~= . & des==1, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3) xscale(.75,2.25)  /*
*/ ytick(-1(.25)1) rtick(-1(.25)1) yscale(-1,1) xlab(0(1)2) /* 
*/ ylab(-1(.25)1) rlab(0) /*
*/ bbox(0,800,23063,17000,900,450,0) saving(g1, replace)
graph des11 des12 des13 pid if pid~= . & des==2, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3) xscale(.75,2.25)  /*
*/ ytick(-1(.25)1) rtick(-1(.25)1) yscale(-1,1) xlab(0(1)2) /* 
*/ rlab(-1(.25)1) ylab(0) /*
*/ bbox(0,15000,23063,32000,900,450,0) saving(g2, replace)
grtraeg traeg3a Vergangene Parteineigung


* Aktuelle HH-Stimmung
* --------------------

graph des11 des12 des13 hhstim if hhstim~= . & des==1, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-1(.25)1) rtick(-1(.25)1) yscale(-1,1) xlab(1(1)3) /* 
*/ ylab(-1(.25)1) rlab(0) /*
*/ bbox(0,800,23063,17000,900,450,0) saving(g1, replace)
graph des11 des12 des13 hhstim if hhstim~= . & des==2, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-1(.25)1) rtick(-1(.25)1) yscale(-1,1) xlab(1(1)3) /* 
*/ rlab(-1(.25)1) ylab(0) /*
*/ bbox(0,15000,23063,32000,900,450,0) saving(g2, replace)
grtraeg traeg3b Aktuelle HH-Stimmung

* Aktuelle Klassenposition
* ------------------------

graph des11 des12 des13 egp if egp~= . & des==1, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-1(.25)1) rtick(-1(.25)1) yscale(1,1) xlab(0(1)5) /* 
*/ ylab(-1(.25)1) rlab(0) /*
*/ bbox(0,800,23063,17000,900,450,0) saving(g1, replace)
graph des11 des12 des13 egp if egp~= . & des==2, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-1(.25)1) rtick(-1(.25)1) yscale(-1,1) xlab(0(1)5) /* 
*/ rlab(-1(.25)1) ylab(0) /*
*/ bbox(0,15000,23063,32000,900,450,0) saving(g2, replace)
grtraeg traeg3c Klassenzugehoerigkeit

erase g1.gph
erase g2.gph

exit




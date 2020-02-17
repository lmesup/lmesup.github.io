* Grafiken der Koeffizienten im Analysedesign 2

* Intro
* -----
clear
version 7.0
set memory 60m


* antraeg1.do gelaufen? 
* Wenn nicht, jetzt starten und Koeffizienten laden
capture use des2_13
if _rc ~= 0 {
	do antraeg1
	use des2_13
}

* Ich merke mir den Lag
gen des = 1

* antreag2.do gelaufen, 
* Wenn nicht jetzt starten und Koeffizienten anhängen
append using des2_1
if _rc ~= 0 {
	do antraeg2
	append using des2_1
}

* Ich merke mir den Lag
replace des = 2 if des == .

* Ein paar Beschriftungen
lab var des "Design"
lab val des des
lab def des 1 "Lag-13" 2 "Lag-1"
lab var des21 "SPD"
lab var des22 "CDU/CSU, FDP"
lab var des23 "B90/Gr." 

* Durchnumerierung der Koeffizienten für beide lags
* --------------------------------------------------

gen index = _n in 1/20
replace index = _n-20 in 21/40
drop if index > 16

* Beobachtungen fuer die Referenzkategorien
* ---------------------------------------

set obs 34
for num 1/3: replace des2X = 0 in 33/34
replace index = 0 in 33/34
replace des = 1 in 33
replace des = 2 in 34

* X-Achse für Klasse
* ------------------

gen egp = 0 if index == 0 
replace egp = 1 if index == 1 | index == 6 
replace egp = 2 if index == 2 | index == 7 
replace egp = 3 if index == 3 | index == 8 
replace egp = 4 if index == 4 | index == 9 
replace egp = 5 if index == 5 | index == 10
lab var egp " "
lab val egp egp
lab def egp 0 "Selb." 1 "Adm. D." 2 "Exp." 3 "Soz. D."  /*
*/ 4 "Mischt."  5  "Arb."


* X-Achse für Politische Stimmung im HH
* -------------------------------------

gen hhstim = 1 if index == 11  | index == 14
replace hhstim = 2 if index == 12  | index == 15
replace hhstim = 3 if index == 13  | index == 16
lab var hhstim " "
lab val hhstim hhstim
lab def hhstim 1 "CDU/FDP" 2 "SPD" 3 "B90/Gr."


* Zum Löschen der Y-Achsenbeschriftung
* ------------------------------------

lab val des21 des2
lab val des22 des2
lab val des23 des2
lab def des2 0 " "

* Zum Löschen der X-Achsenbeschriftung
* ------------------------------------

gen egpno = egp
lab var egpno " "
lab val egpno egpno 
lab def egpno 0 " " 1 " " 2 " " 3 " " 4 " " 5 " "

gen hhno = hhstim
lab var hhno " "
lab val hhno hhno 
lab def hhno 1 " " 2 " " 3 " " 


* Zusammenführen der beiden Teilgrafiken
* --------------------------------------

capture program drop grtraeg
	program define grtraeg
		gph open, saving(`1', replace)
			graph using g1
			graph using g2
			graph using g3
			graph using g4
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
			gph text 22000 16000 0 0 `2'
			gph font 1200 600
			gph text 11531 600 1 0 Marginaleffekte
			gph text  6000 200 1 0 Aktuell
			gph text 16500 200 1 0 Frueher       
		gph close
	end

* Aktuelle HH-Stimmung
* --------------------

graph des21 des22 des23 hhno if hhstim~= . & des==1 in 11/13,  border yline(0) /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(1(1)3) /* 
*/ ylab(-.5(.25).5) rlab(0) /*
*/ bbox(0,800,13032,17800,900,450,0) saving(g1, replace)
graph des21 des22 des23 hhno if hhstim~= . & des==2 in 27/29, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(1(1)3) /* 
*/ rlab(-.5(.25).5) ylab(0) /*
*/ bbox(0,15000,13032,32000,900,450,0) saving(g2, replace)
graph des21 des22 des23 hhstim if hhstim~= . & des==1 in 14/16,  border yline(0) /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(1(1)3) /* 
*/ ylab(-.5(.25).5) rlab(0) /*
*/ bbox(10031,800,23063,17800,900,450,0) saving(g3, replace)
graph des21 des22 des23 hhstim if hhstim~= . & des==2 in 30/32, border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(1(1)3) /* 
*/ rlab(-.5(.25).5) ylab(0) /*
*/ bbox(10032,15000,23063,32000,900,450,0) saving(g4, replace)
grtraeg traeg4a HH-Stimmung


* Klasse
* ------

graph des21 des22 des23 egpno  /*
*/ if egp~=. & des==1 & ((index >= 1 & index <= 5) | index == 0),  /*
*/ border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(0(1)5) /* 
*/ ylab(-.5(.25).5) rlab(0) /*
*/ bbox(0,800,13032,17800,900,450,0) saving(g1, replace)
graph des21 des22 des23 egpno  /*
*/ if egp~=. & des==2 & ((index >= 1 & index <= 5) | index == 0),  /*
*/ border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(0(1)5) /* 
*/ rlab(-.5(.25).5) ylab(0) /*
*/ bbox(0,15000,13032,32000,900,450,0) saving(g2, replace)
graph des21 des22 des23 egp  /*
*/ if egp~=. & des==1 & ((index >= 6 & index <= 10) | index == 0),  /*
*/ border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(0(1)5) /* 
*/ ylab(-.5(.25).5) rlab(0) /*
*/ bbox(10031,800,23063,17800,900,450,0) saving(g3, replace)
graph des21 des22 des23 egp  /*
*/ if egp~=. & des==2 & ((index >= 6 & index <= 10) | index == 0),  /*
*/ border yline(0)  /*
*/ c(l[-#]l[.]l) sort s(OTS) pen(222) key1(" ") gap(3)  /*
*/ ytick(-.5(.25).5) rtick(-.5(.25).5) yscale(-.55,.55) xlab(0(1)5) /* 
*/ rlab(-.5(.25).5) ylab(0) /*
*/ bbox(10032,15000,23063,32000,900,450,0) saving(g4, replace)
grtraeg traeg4b Klassenzugehoerigkeit


erase g1.gph
erase g2.gph
erase g3.gph
erase g4.gph


exit




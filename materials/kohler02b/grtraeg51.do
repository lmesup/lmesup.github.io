* Haben Kinder aus Arbeiter und Selbständigenhaushalten trägere
* Parteipräferenzen
* Variante: 3 Klassen, Nur CDU vs. SPD

clear
version 7.0
set memory 60m
set matsize 800
use traeg1

* Recodierungen
* -------------

* EGP
* ---

gen egp = 2 if megp == 1 /* Administrative Dienste */
replace egp = 2 if megp == 2 /* Experten */
replace egp = 2 if megp == 3 /* Soziale Dienste */
replace egp = 2 if megp == 4 | megp == 8 | megp == 12 /* Mischtypen */
replace egp = 1 if megp >= 5 & megp <= 7 /* Selbständige */
replace egp = 3 if megp >= 9 & megp <= 11 /* Arbeiter */
lab var egp "Mueller - EGP, 6er Teilung"
lab val egp megp6
lab def megp6 2 "Andere Klassen" 3 "Arbeiter" 1 "Selbstaendige" 

* Parteineigung
* -------------

gen pi = 1 if pid == 2 /* SPD */ 
replace pi = 2 if pid == 3  /* CDU */
lab val pi pi
lab def pi 1 "SPD" 2 "CDU" 

* Alter
* -----

gen age = (1900 + welle) - gebjahr if gebjahr > 0

* Population der Personen, die im zwischen 1984 und 1997 das 
* Befragungsalter (17) erreichten
* ------------------------------

sort persnr welle
qby persnr: gen adols = sum(age==17)
keep if adols == 1

* Verwendet wird jeweils die erste und letzte valide Beobachtung jedes
* Befragten
* ----------

drop if egp == . | pi == .

* Klasse im ersten bzw. letzten Jahr
* ----------------------------------

sort persnr welle
qby persnr: gen egp1 = egp[1]
qby persnr: gen egp2 = egp[_N]
lab val egp1 megp6
lab val egp2 megp6

* Partei im ersten und letzten Jahr
* ---------------------------------

qby persnr: gen pid1 = pi[1]
qby persnr: gen pid2 = pi[_N]

* Lag
* ---

qby persnr: gen lag = welle[_N] - welle[1]
drop if lag<=5

* Behalte nur die erste Beobachtung
* ---------------------------------

qby persnr: keep if _n==1


* Indiziere Stabile Parteineiger
* ------------------------------

gen stab = pid1 == pid2  /* mit keine PI */

* Aggregiere die Daten über EGP
* -----------------------------

gen n = 1
collapse (sum) n=n nstab=stab (mean) lag=lag, by(egp1 egp2)

* Berechne Anteil Stabiler in den By-Groups
* -----------------------------------------

gen stab=nstab/n


* Fake empty cases (But draw with invisible pen!)
* -----------------------------------------------

fillin egp1 egp2
gen stab1 = .25 if _fillin==1

* Common-Options der Graphiken
* ----------------------------

sum stab
local min = round(r(min),.1)-.1
local max = round(r(max),.1)+.1
local opt "xscale(`min',`max') format(%3.2f) xlab(`min'(.2)`max') bor grid"
local opt "`opt' rlegend(n) l(egp2) gllj glpos(200) cstart(7000) " 

hplot stab if egp1==egp2, `opt' saving(traeg5a, replace) ti(" ")

hplot stab stab1 if egp1~=egp2, `opt' gaps(0,2,4)  /*
*/glegend(Selbstaendige!Andere Klassen!Arbeiter)/*
*/ s(oi) t2(" ") t1(" ")  /*
*/ saving(traeg5b, replace)

exit

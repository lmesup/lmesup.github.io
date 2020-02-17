* Haben Kinder aus Arbeiter und Selbständigenhaushalten trägere
* Parteipräferenzen
* Variante: 3 Klassen, Nur CDU vs. SPD

clear
version 7.0
set memory 60m
set matsize 800
use traeg1 if hhnr~=-2

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
replace pi = 2 if pid == 3 | pid == 4  /* CDU */
replace pi = 3 if pid == 5
lab val pi pi
lab def pi 1 "SPD" 2 "CDU/FDP" 3 "B90/Gr." 

* Alter
* -----

gen age = (1900 + welle) - gebjahr if gebjahr > 0

* Population der Personen, die im zwischen 1984 und 1997 das 
* Befragungsalter (17) erreichten
* ------------------------------

sort persnr welle
qby persnr: gen adols = sum(age==17)
keep if adols == 1


* How many Persons?
* -----------------

sort persnr
qby persnr: gen x = 1 if _n==1
replace x = sum(x)
di "Number of Persons: " x[_N]

* Listwise Deletion
* -----------------

drop if egp == . | pi == .


* Verwendet wird jeweils die erste und letzte valide Beobachtung jedes
* Befragten
* ----------

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
drop if lag<=1

* Behalte nur die erste Beobachtung
* ---------------------------------

qby persnr: keep if _n==1

* Some Distributions
* ------------------
sum lag
hist lag, ylab(0(.02).13) saving(temp, replace) bor
xi: reg lag i.egp1*i.egp2


* Indiziere Stabile Parteineiger
* ------------------------------

gen stab = pid1 == pid2  /* mit keine PI */

* Aggregiere die Daten über EGP
* -----------------------------

gen n = 1
collapse (sum) n=n nstab=stab (mean) lag=lag [aw=uw], by(egp1 egp2)

* Berechne Anteil Stabiler in den By-Groups
* -----------------------------------------

gen stab=nstab/n
replace n = round(n,1)

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

hplot stab if egp1==egp2, `opt' saving(traeg6a, replace) ti(" ")

hplot stab stab1 if egp1~=egp2, `opt' gaps(0,2,4)  /*
*/glegend(Selbstaendige!Andere Klassen!Arbeiter)/*
*/ s(oi) t2(" ") t1(" ")  /*
*/ saving(traeg6b, replace)

exit

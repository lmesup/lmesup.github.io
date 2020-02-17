* Haben Kinder aus Arbeiter und Selbständigenhaushalten trägere
* Parteipräferenzen
* 

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
replace egp = 3 if megp == 2 /* Experten */
replace egp = 4 if megp == 3 /* Soziale Dienste */
replace egp = 5 if megp == 4 | megp == 8 | megp == 12 /* Mischtypen */
replace egp = 1 if megp >= 5 & megp <= 7 /* Selbständige */
replace egp = 6 if megp >= 9 & megp <= 11 /* Arbeiter */
lab var egp "Mueller - EGP, 6er Teilung"
lab val egp megp6
lab def megp6 1 "Selb." 2 "Others"  3 "Arb."


* Alter
* -----

gen age = (1900 + welle) - gebjahr if gebjahr > 0

* Population der Personen, die im zwischen 1984 und 1997 das 
* Befragungsalter (17) erreichten
* ------------------------------

sort persnr welle
qby persnr: gen adols = sum(age==17)
keep if adols == 1

* Lag
* ---

qby persnr: gen lag = welle[_N] - welle[1]
drop if lag <= 2

* Anzahl von Wechseln der PID
* ---------------------------

sort persnr welle
replace pid = . if pid == 1
qby persnr: gen pidchg = pid~=pid[_n-1] if pid ~= . & pid[_n-1] ~= .
qby persnr: replace pidchg = sum(pidchg)/lag

* Klasse im ersten Jahr
* ---------------------

qby persnr: gen egp1 = egp[1]

* Anzahl von Wechseln der Klasse
* ------------------------------

qby persnr: gen egpchg = egp~=egp[_n-1] if egp ~= . & egp[_n-1] ~= .
qby persnr: replace egpchg = sum(egpchg)/lag


* Behalte nur die letzte Beobachtung
* ----------------------------------

qby persnr: keep if _n==_N



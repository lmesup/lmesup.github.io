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
replace egp = 2 if megp == 2 /* Experten */
replace egp = 2 if megp == 3 /* Soziale Dienste */
replace egp = 2 if megp == 4 | megp == 8 | megp == 12 /* Mischtypen */
replace egp = 1 if megp >= 5 & megp <= 7 /* Selbständige */
replace egp = 3 if megp >= 9 & megp <= 11 /* Arbeiter */
lab var egp "Mueller - EGP, 6er Teilung"
lab val egp megp6
lab def megp6 1 "Selb." 2 "Others"  3 "Arb."

* Parteineigung
* -------------

* PID
gen pi = 1 if pid == 2 /* SPD */ 
replace pi = 2 if pid == 3 | pid == 4 /* CDU, FDP */


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
drop if lag <= 2
gen lnlag = lag

* Alter im letzen Jahr
* -------------------
qby persnr: gen age2 = age[_N]


* Behalte nur die erste Beobachtung
* ---------------------------------

qby persnr: keep if _n==1


* Indiziere Stabile Parteineiger
* ------------------------------

gen stab = pid1 == pid2  /* mit keine PI */


* Indiziere Stabile Sozialstruktur
* --------------------------------


* Logit-Modell
* ------------

xi: logit stab i.egp1*lnlag i.egp1*i.egp2 
predict phat
sort egp1
graph phat lag, by(egp1) s([egp2])



exit

* Kollinearität HH-Stimm - EGP im lag13-Analysedesign

clear
version 7.0
set memory 60m
set matsize 800
use traeg1

* Balanced Sample
* ---------------

keep if mark

* Recodierungen
* -------------

* EGP
gen egp = 1 if megp == 1 /* Administrative Dienste */
replace egp = 2 if megp == 2 /* Experten */
replace egp = 3 if megp == 3 /* Soziale Dienste */
replace egp = 4 if megp == 4 | megp == 8 | megp == 12 /* Mischtypen */
replace egp = 5 if megp >= 5 & megp <= 7 /* Selbständige */
replace egp = 6 if megp >= 9 & megp <= 11 /* Arbeiter */
lab var egp "Mueller - EGP, 6er Teilung"
lab val egp megp6
lab def megp6 1 "Admin" 2 "Experten" 3 "Soz. D." 4 "Mischt." 5 "Selb." 6 "Arb."

* PID
gen pi = 1 if pid == 2 /* SPD */ 
replace pi = 2 if pid == 3 | pid == 4  /* CDU, FDP */
replace pi = 3 if pid == 5 /* B90 */

* Bildung
gen hbil = bil == 3 | bil == 4

* Alter
gen age = (1900 + welle) - gebjahr if gebjahr > 0

* Kohorte
gen olds = gebjahr<1940 if gebjahr > 0

* Geschlecht
gen men = sex==1 if sex > 0 

* Arbeistlos:
gen alos = est==5

* Haushaltszusammensetzung
sort welle hhnr 
qby welle hhnr: gen valid = sum(pid~=.) 
qby welle hhnr: replace valid = valid[_N] - 1
qby welle hhnr: gen kons = sum(pid==3 | pid==4)
qby welle hhnr: gen spd = sum(pid==2)
qby welle hhnr: gen b90 = sum(pid==5)
qby welle hhnr: replace kons = kons[_N]  /* Anzahl CDU - Anhänger */
qby welle hhnr: replace spd = spd[_N]    /* Anzahl SPD - Anhänger */
qby welle hhnr: replace b90 = b90[_N]    /* Anzahl B90 - Anhänger */
qby welle hhnr: replace kons = kons -1 if pid == 3 | pid == 4
qby welle hhnr: replace spd = spd[_N] -1  if pid == 2
qby welle hhnr: replace b90 = b90[_N] -1  if pid == 5
replace kons = kons/valid
replace spd = spd/valid
replace b90 = b90/valid
replace kons = . if valid <= 0 /* Don't use 1 Pers. HH */
replace spd = . if valid <= 0
replace b90 = . if valid <= 0
drop valid

* Imputation der Variablen zur Haushaltszusammensetzung
* ----------------------------------------------------
set seed 731
gen long r = _n
gen split = kons==. 
sort pid egp hbil split r
qby pid egp hbil: gen valid = sum(split == 0) 
qby pid egp hbil: gen ikons = kons[int(uniform()*valid)+1] if kons == . 
replace ikons = kons if ikons == .

replace split = spd==. 
sort pid egp hbil split r
qby pid egp hbil: replace valid = sum(split == 0) 
qby pid egp hbil: gen ispd = spd[int(uniform()*valid)+1] if b90 == . 
replace ispd = spd if ispd == .

replace split = b90==. 
sort pid egp hbil split r
qby pid egp hbil: replace valid = sum(split == 0) 
qby pid egp hbil: gen ib90 = b90[int(uniform()*valid)+1] if b90 == . 
replace ib90 = b90 if ib90 == .

* Lags: Zeitraum: 1984-1997 (13-Jahre)
* ------------------------------------

sort persnr welle
qby persnr: gen pilag = pi[_n-13]
qby persnr: gen egplag = egp[_n-13]
qby persnr: gen hbillag = hbil[_n-13]
qby persnr: gen ikonslag = ikons[_n-13]
qby persnr: gen ispdlag = ispd[_n-13]
qby persnr: gen ib90lag = ib90[_n-13]
qby persnr: gen aloslag = alos[_n-13]

* Auswahl der Beobachtungen
* -------------------------

* Nur CDU,SPD,FDP,B90 (-> Note 1)
drop if pi == . | pilag == .

* Nur bekannte Klassenzugehoerigkeit
drop if egp == . | egplag == .


* Einige bivariate Zusammenhänge
* ------------------------------

tab ikons egp, V 
tab ispd egp, V  
tab ib90 egp, V  
tab ikonslag egplag, V
tab ispdlag egplag, V 
tab ib90lag egplag, V 

exit

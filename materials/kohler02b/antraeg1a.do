* Traegheit der Parteiidentifikation, lag1 mit Balanced-Sample
* Variante von antraeg1, zur Beantwortung der Frage, ob die 
* Unterschiede zwischen lag1 und lag13 auf dem unterschiedlichen
* Sample beruht.

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
qby welle hhnr: replace kons = kons - 1 if pid == 3 | pid == 4
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
gen split = kons==. 
sort pid egp hbil split
qby pid egp hbil: gen valid = sum(split == 0) 
qby pid egp hbil: gen ikons = kons[int(uniform()*valid)+1] if kons == . 
replace ikons = kons if ikons == .

replace split = spd==. 
sort pid egp hbil split
qby pid egp hbil: replace valid = sum(split == 0) 
qby pid egp hbil: gen ispd = spd[int(uniform()*valid)+1] if b90 == . 
replace ispd = spd if ispd == .

replace split = b90==. 
sort pid egp hbil split
qby pid egp hbil: replace valid = sum(split == 0) 
qby pid egp hbil: gen ib90 = b90[int(uniform()*valid)+1] if b90 == . 
replace ib90 = b90 if ib90 == .

* Lags: Zeitraum: 1984-1997 (13-Jahre)
* ------------------------------------

sort persnr welle
qby persnr: gen pilag = pi[_n-1]
qby persnr: gen egplag = egp[_n-1]
qby persnr: gen hbillag = hbil[_n-1]
qby persnr: gen ikonslag = ikons[_n-1]
qby persnr: gen ispdlag = ispd[_n-1]
qby persnr: gen ib90lag = ib90[_n-1]
qby persnr: gen aloslag = alos[_n-1]

* Auswahl der Beobachtungen
* -------------------------

* Nur CDU,SPD,FDP,B90 (-> Note 1)
drop if pi == . | pilag == .

* Nur bekannte Klassenzugehoerigkeit
drop if egp == . | egplag == .


* Datenbeschreibung und Dummy-Bildung
* -----------------------------------

count

* PID
count if pi ~= pilag
tab pi, gen(pi) mis
tab pilag, gen(pilag) mis

* EGP
count if egp ~= egplag
tab egp, gen(egp)
tab egplag, gen(egplag)

* Bildung
count if hbil ~= hbillag 
tab hbil
tab hbillag

* Oldsorte
tab olds

* Alter 
hist3 age, v(35(5)75) bor ylab l1(Dichte) b2(Alter 1997)  /*
*/ saving(traeg1x, replace)

* Arbeitslosigkeit
count if alos ~= aloslag
tab alos
tab aloslag

* Haushaltsstimmung
count if ikons ~= ikonslag
tab ikons 
tab ikonslag

* Haushaltsstimmung
count if ispd ~= ispdlag
tab ispd
tab ispdlag

* Haushaltsstimmung
count if ib90 ~= ib90lag
tab ib90 
tab ib90lag


* SVY-Data
* --------

svyset strata psample 
svyset pweight bw
svyset psu intnr 

* Apply Design 2
* --------------

mlogit pi pilag2-pilag3 egp2-egp6 ikons ispd ib90 hbil age men olds
svymlog pi pilag2-pilag3 egp2-egp6 ikons ispd ib90 hbil age men olds

* Lagged Variables
svytest [2]:pilag2 pilag3 
svytest [3]:pilag2 pilag3
svytest pilag2 pilag3

* Aktuelle Variablen
svytest [2]:egp2 egp3 egp4 egp5 egp6 
svytest [3]:egp2 egp3 egp4 egp5 egp6
svytest egp2 egp3 egp4 egp5 egp6

svytest [2]:ikons ispd ib90
svytest [3]:ikons ispd ib90
svytest ikons ispd ib90

svytest [2]:hbil
svytest [3]:hbil
svytest hbil

svytest [2]:age
svytest [3]:age
svytest age

svytest [2]:olds
svytest [3]:olds
svytest olds

svytest [2]:men
svytest [3]:men
svytest men

* Marginaleffekte
mfx compute, predict(outcome(1)) nose at(ikons=0,ispd=0,ib90=0)
matrix des11 = r(dfdx)
mfx compute, predict(outcome(2)) nose at(ikons=0,ispd=0,ib90=0)
matrix des12 = r(dfdx)
mfx compute, predict(outcome(3)) nose at(ikons=0,ispd=0,ib90=0)
matrix des13 = r(dfdx)

* Keep results for grtraeg3 
preserve  
drop _all
matrix des1 = (des11 \ des12 \ des13)'
svmat des1
save des1_1a, replace
restore


* Apply Design 3
* --------------

mlogit pi egp2-egp6 egplag2-egplag6 ikons ispd ib90 ikonslag ispdlag ib90lag  /*
*/ hbil age men olds
svymlog pi egp2-egp6 egplag2-egplag6 ikons ispd ib90 ikonslag ispdlag ib90lag  /*
*/ hbil age men olds 

* Lagged Variables
svytest egplag2 egplag3 egplag4 egplag5 egplag6  /*
*/ ikonslag ispdlag ib90lag 
svytest [2]: egplag2 egplag3 egplag4 egplag5 egplag6  /*
*/ ikonslag ispdlag ib90lag 
svytest [3]: egplag2 egplag3 egplag4 egplag5 egplag6  /*
*/ ikonslag ispdlag ib90lag 

* Aktuelle Varablen
svytest egp2 egp3 egp4 egp5 egp6 ikons ispd ib90
svytest [2]: egp2 egp3 egp4 egp5 egp6 ikons ispd ib90
svytest [3]: egp2 egp3 egp4 egp5 egp6 ikons ispd ib90

* Interessentheorie
svytest egplag2 egplag3 egplag4 egplag5 egplag6 
svytest egp2 egp3 egp4 egp5 egp6 
svytest [2]:egplag2 egplag3 egplag4 egplag5 egplag6 
svytest [2]:egp2 egp3 egp4 egp5 egp6 
svytest [3]:egplag2 egplag3 egplag4 egplag5 egplag6 
svytest [3]:egp2 egp3 egp4 egp5 egp6 

* Interaktionsansatz
svytest ikonslag ispdlag ib90lag
svytest ikons ispd ib90
svytest [2]:ikonslag ispdlag ib90lag
svytest [2]:ikons ispd ib90
svytest [3]:ikonslag ispdlag ib90lag
svytest [3]:ikons ispd ib90

* Rest
svytest [2]:hbil
svytest [3]:hbil
svytest hbil

svytest [2]:age
svytest [3]:age
svytest age

svytest [2]:olds
svytest [3]:olds
svytest olds

svytest [2]:men
svytest [3]:men
svytest men


* Marginaleffekte
mfx compute, predict(outcome(1)) nose  /*
*/ at(ikons=0,ispd=0,ib90=0,ikonslag=0,ispdlag=0,ib90lag=0)
matrix des21 = r(dfdx)
mfx compute, predict(outcome(2)) nose  /*
*/ at(ikons=0,ispd=0,ib90=0,ikonslag=0,ispdlag=0,ib90lag=0)
matrix des22 = r(dfdx)
mfx compute, predict(outcome(3)) nose  /*
*/ at(ikons=0,ispd=0,ib90=0,ikonslag=0,ispdlag=0,ib90lag=0)
matrix des23 = r(dfdx)

* keep results for grtraeg4
drop _all
matrix des2 = (des21 \ des22 \ des23)'
svmat des2

save des2_1a, replace

exit


Notes
-----

1) Nur die soziostrukturellen Ursachen der Präferenz für SPD,CDU,FDP,
B90 sind bekannt. Deshalb werden nur diese Personen untersucht. Man
könnte "keine Parteiidentifikation" bei den "reinen" Anhängern
prinzipiell rekodieren. Dies würde jedoch lediglich stabile
Beobachtungen erzeugen, die nichts zur Analyse beitragen können.

		
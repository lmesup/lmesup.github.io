* Kaplan-Mayer 
* Haben Kinder aus Arbeiter und Selbständigenhaushalten trägere
* Parteipräferenzen

clear
version 7.0
set memory 60m
set matsize 800
use traeg1

* Recodierungen
* -------------

* EGP
* ---

gen egp = 1 if megp == 1 /* Administrative Dienste */
replace egp = 2 if megp == 2 /* Experten */
replace egp = 2 if megp == 3 /* Soziale Dienste */
replace egp = 2 if megp == 4 | megp == 8 | megp == 12 /* Mischtypen */
replace egp = 2 if megp >= 5 & megp <= 7 /* Selbständige */
replace egp = 6 if megp >= 9 & megp <= 11 /* Arbeiter */
lab var egp "Mueller - EGP, 6er Teilung"
lab val egp megp6
lab def megp6 1 "Admin" 2 "Experten" 3 "Soz. D." 4 "Mischt." 5 "Selb." 6 "Arb."


* PID
gen pi = 1 if pid == 2 /* SPD */ 
replace pi = 2 if pid == 3  /* CDU */

* Alter
gen age = (1900 + welle) - gebjahr if gebjahr > 0

* Population der Personen, die im zwischen 1984 und 1997 das 
* Befragungsalter (17) erreichten
* ------------------------------

sort persnr welle
qby persnr: gen adols = sum(age==17)
keep if adols == 1

* Making Spell-Data
* -----------------

drop if egp==. | pi == .
sort persnr age
qby persnr: keep if egp[_n-1] ~= egp | pi[_n-1] ~= pi
qby persnr: gen time = age[_n+1] - age
qby persnr: replace time = 1 if _n==_N
qby persnr: replace time = sum(time) 
qby persnr: gen censor = 1 if egp[_n+1]~=egp 
qby persnr: replace censor = 0 if pi[_n+1]~=pi
qby persnr: replace censor = 1 if _n==_N
stset age censor, id(persnr)

* Kaplan-Mayer
* ------------

sts graph, by(egp) ls([.][-#][-#.]) noorigin  /*
*/ key1(c(l[.]) pen(2) "Selbstaendige")  /*
*/ key2(c(l[-#]) pen(3) "Andere Klassen")  /*
*/ key3(c(l[_#.]) pen(4) "Arbeiter") /*
*/ t1(" ")  nolabel yasis xasis xlab(1(2)13) ylab(0(.1).4)


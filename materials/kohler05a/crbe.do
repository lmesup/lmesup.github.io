* Erzeugt Between-Effects Koeffizienten

clear
set memory 60m
set matsize 800
version 7.0
set more off

* 0) Cool-Ados
* ------------

capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}

capture which hplot
if _rc ~= 0 {
	ssc install hplot
}

capture which mmerge
if _rc ~= 0 {
	ssc install mmerge
}


*  +----------------------------------------------------------------+
*  |                             Retrival                           |
*  +----------------------------------------------------------------+

mkdat  /*
Schulbildung 
*/ apsbil bpsbil cpsbil dpsbil epsbil fpsbil gpsbil hpsbil  /*
*/ ipsbil jpsbil kpsbil lpsbil mpsbil npsbil opsbil ppsbil /*
*/ qpsbil  /*
Berufsbildung 
*/ apbbil01 bpbbil01 cpbbil01 dpbbil01 epbbil01 fpbbil01 gpbbil01 hpbbil01 /*
*/ ipbbil01 jpbbil01 kpbbil01 lpbbil01 mpbbil01 npbbil01 opbbil01 ppbbil01 /*
*/ qpbbil01  /*
*/ apbbil02 bpbbil02 cpbbil02 dpbbil02 epbbil02 fpbbil02 gpbbil02 hpbbil02 /*
*/ ipbbil02 jpbbil02 kpbbil02 lpbbil02 mpbbil02 npbbil02 opbbil02 ppbbil02 /*
*/ qpbbil02  /*
*/ apbbil03 bpbbil03 cpbbil03 dpbbil03 epbbil03 fpbbil03 gpbbil03 hpbbil03 /*
*/ ipbbil03 jpbbil03 kpbbil03 lpbbil03 mpbbil03 npbbil03 opbbil03 ppbbil03 /*
*/ qpbbil03  /*
*/ using $soepdir, files(pgen) waves(a b c d e f g h i j k l m n o p q) /*
*/ netto(-3,-2,-1,0,1,2,3,4,5) keep(sex gebjahr qsampreg)
keep if qsampreg==1

holrein /*
Erwerbsstatus: 
*/ ap08 bp16 cp16 dp12 ep12 fp10 gp12 hp15 ip15 jp15 kp25 lp21 /*
*/ mp15 np11 op09 pp10 qp10 /*
Arbeitslos:
*/ _x99 bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09 jp09 kp16 lp13 mp12 /*
*/ np08 op04 pp05 qp04   /*
*/ using $soepdir, files(p) waves(a b c d e f g h i j k l m n o p q)

* Bundesland
holrein abula using $soepdir, files(h) waves(a)
holrein /*
*/ bbula cbula dbula ebula fbula gbula hbula ibula jbula kbula lbula mbula  /*
*/ nbula obula pbula qbula  /*
*/ using $soepdir, files(hbrutto) waves(b c d e f g h i j k l m n o p q)

soepren ?bula, new(bul) w(1984/2000)
soepren ?psbil, new(bil) w(1984/2000)
soepren ?pbbil01, new(bbil01) w(1984/2000)
soepren ?pbbil02, new(bbil02) w(1984/2000)
soepren ?pbbil03, new(bbil03) w(1984/2000)

forvalues i=1984/2000 {
  gen bbil`i' = 1 if bbil03`i' == 1
  replace bbil`i'= bbil01`i' + 1 if bbil01`i' >= 1
  replace bbil`i'= bbil02`i' + 7 if bbil02`i'>=1
  replace bbil`i' = -1 /*
  */ if bbil01`i' == -1 | bbil02`i' == -1 | bbil03`i' == -1
  drop bbil01`i' bbil02`i' bbil03`i'
  lab val bbil`i' bbil
  lab var bbil`i' "Berufsbildung"
}
lab def bbil 1 "Kein" 2 "Lehre" 3 "BerufsFH" 4 "S.Geswes" 5 "Fachsch." /*
*/ 6 "Beamtena" 7 "And. Ausb." 8 "FHS" 9 "Univ.,TH" 10 "Uni.Ausl"

soepren ap08 bp16 cp16 dp12 ep12 fp10 gp12 hp15 ip15 jp15 kp25 lp21  /*
*/ mp15 np11 op09 pp10 qp10, new(est) w(1984/2000)

* Erwerbstatus seit 91
forvalues i=1991/1995 {
  recode est`i' 1 2=1 3 4=2 5=3 6=4 8=6 7 9=7
  note est`i': recodiert
}

* Erwerbstatus 96 u. 97 
forvalues i=1996/1997 {
  recode est`i' 5=7
  note est`i': recodiert
}

* Erwerbstatus 98 u. 99
forvalues i=1998/1999 {
  recode est`i' 5 8 =7
  note est`i': recodiert
}

* Erwerbstatus 2000
recode est2000 5 =6 8 =7
note est2000: recodiert


* Arbeitslos gemeldet
* ------------------

gen apx = .
soepren  /*
*/ apx bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09 jp09 kp16 lp13 mp12 /*
*/ np08 op04 pp05 qp04, new(alos) w(1984/2000)
replace alos1984 = 1 if est1984==5
replace alos1984 = 2 if est1984~=5 & est1984 ~= .

keep persnr sex gebjahr bil* bbil* bul* alos* est*

reshape long bil bbil bul alos est , i(persnr) j(welle)
sort persnr welle
save 11, replace

use persnr welle hnr netto fam megph pid hst using pidlv, clear
mmerge persnr welle using 11, type(1:1) unmatched(master)

sort persnr welle

* Mindestens eine Teilnahme zwischen 1984 und 1997
by persnr (welle): gen byte bef = 1 if netto == 1
by persnr (welle): replace bef = sum(bef)
by persnr (welle): replace bef = bef[_N]
drop if bef == 0

* Zufällige Auswahl eine Beobachtung pro Befragtem:
set seed 731
gen r = uniform()
sort persnr r
by persnr (r): keep if _n == 1

* xtdata
iis persnr
tis welle


*  +----------------------------------------------------------------+
*  |                   Rekodierungen                                |
*  +----------------------------------------------------------------+

* +-----+
* | PID |
* +-----+

gen left = pid == 2 if pid ~= .
gen kons = pid == 3 if pid ~= .

* +---------+
* | Klassen |
* +---------+

gen egp = 1 if megph >= 5 & megph <= 7
replace egp = 2 if megph == 1
replace egp = 3 if megph == 2 | megph == 4 | megph == 8 | megph == 12
replace egp = 4 if megph == 3 | (megph >= 9 & megph <= 12) 
tab egp, gen(degp)

* +------------------+
* | Arbeitslosigkeit |
* +------------------+

gen dalos = alos == 1 if alos > 0 & alos ~= .

* +--------------+
* | Schulbildung |
* +--------------+

replace bil = . if bil == -1
replace bil = . if bil == 7
tab bil, gen(dbil)
for var dbil*: replace X = -1 if bil == 1 /* Effektkodierung */

* +---------------+
* | Berufsbildung |
* +---------------+

replace bbil = . if bbil == -1
replace bbil = 8 if bbil >= 8 & bbil <= 10
tab bbil, gen(dbbil)
for var dbbil*: replace X = -1 if bbil == 2 /* Effektkodierung */


* +---------------+
* | Erwerbsstatus |
* +---------------+

replace est = . if est <= 0
replace est = 7 if est == 5
tab est, gen(dest)


* +--------------+
* |Familienstand |
* +--------------+

replace fam = . if fam==-1
tab fam, gen(dfam)


* +--------------------+
* | Eltern von Kindern |
* +--------------------+

sort hnr
qby hnr: gen kind = 1 if hst == 3 | hst == 4
qby hnr: replace kind = sum(kind)
gen eltern = 0
qby hnr: replace eltern = 1 if kind[_N] >= 1 & hst >= 0 & hst <= 2

* +-------------------+
* | Kontrollvariablen |
* +-------------------+

* Geschlecht
gen men = sex == 1 if sex > 0

* Gebjahr
replace gebjahr = . if gebjahr <= 0

* Bundesland
replace bul = . if bul <= 0
tab bul, gen(dbul)

* Welle
tab welle, gen(dwelle)

*  +-------------------------------------------------+
*  |                   Weights & friends             |
*  +-------------------------------------------------+

sort persnr
mmerge persnr using weights 
drop if _merge==2
drop _merge
compress


*  +-------------------------------------------------+
*  |                   Speichervariablen             |
*  +-------------------------------------------------+


input str8 uv 
	eadmsel
	emissel
	earbsel
	eseladm
	emisadm
	earbadm
	eselmis
	eadmmis
	earbmis
	eselarb
	eadmarb
	emisarb
        earblos
        eest
        easchul
	ehschul
	ebschul
	ebstart
	ehoch1
	ekind1
	ekind2
end


*  +----------------------------------------------------------------+
*  |                   Modellschätzung                              |
*  +----------------------------------------------------------------+

logit left degp2-degp4 dalos dbil2-dbil6 dbbil1 dbbil3-dbbil8 dest2-dest6  /*
*/ dfam2-dfam6 eltern men gebjahr  dbul2-dbul15 dwelle2-dwelle14 [pw = uw] 

gen bleft_be = .
replace bleft_be = 0 - _b[degp2] in 1
replace bleft_be = 0 - _b[degp3] in 2
replace bleft_be = 0 - _b[degp4] in 3
replace bleft_be = _b[degp2] - 0 in 4
replace bleft_be = _b[degp2] - _b[degp3] in 5
replace bleft_be = _b[degp2] - _b[degp4] in 6
replace bleft_be = _b[degp3] - 0 in 7
replace bleft_be = _b[degp3] - _b[degp2] in 8
replace bleft_be = _b[degp3] - _b[degp4] in 9
replace bleft_be = _b[degp4] - 0 in 10 
replace bleft_be = _b[degp4] - _b[degp2] in 11
replace bleft_be = _b[degp4] - _b[degp3] in 12
replace bleft_be = _b[dalos] in 13
replace bleft_be = 0 - _b[dalos] in 14
replace bleft_be = 0 - _b[dbil6] in 15
replace bleft_be = _b[dbbil8] in 16 
replace bleft_be = 0 - _b[dbbil1] in 17
replace bleft_be = . in 18
replace bleft_be = 0 - _b[dfam3] in 19
replace bleft_be = _b[eltern] in 20
replace bleft_be = . in 21


logit kons degp2-degp4 dalos dbil2-dbil6 dbbil1 dbbil3-dbbil8 dest2-dest6  /*
*/ dfam2-dfam6 eltern men gebjahr  dbul2-dbul15 dwelle2-dwelle14 [pw = uw] 

gen bkons_be = .
replace bkons_be = 0 - _b[degp2] in 1
replace bkons_be = 0 - _b[degp3] in 2
replace bkons_be = 0 - _b[degp4] in 3
replace bkons_be = _b[degp2] - 0 in 4
replace bkons_be = _b[degp2] - _b[degp3] in 5
replace bkons_be = _b[degp2] - _b[degp4] in 6
replace bkons_be = _b[degp3] - 0 in 7
replace bkons_be = _b[degp3] - _b[degp2] in 8
replace bkons_be = _b[degp3] - _b[degp4] in 9
replace bkons_be = _b[degp4] - 0 in 10 
replace bkons_be = _b[degp4] - _b[degp2] in 11
replace bkons_be = _b[degp4] - _b[degp3] in 12
replace bkons_be = _b[dalos] in 13
replace bkons_be = 0 - _b[dalos] in 14
replace bkons_be = 0 - _b[dbil6] in 15
replace bkons_be = _b[dbbil8] in 16 
replace bkons_be = 0 - _b[dbbil1] in 17
replace bkons_be = . in 18
replace bkons_be = 0 - _b[dfam3] in 19
replace bkons_be = _b[eltern] in 20
replace bkons_be = . in 21

*  +-----------------------------------------------------+
*  |                  Save                               |
*  +-----------------------------------------------------+

keep uv bleft bkons
gen index = _n
drop if index > 21
sort uv
save be, replace

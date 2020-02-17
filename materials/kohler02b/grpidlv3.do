* Vergleich Fixed-Effects mit Querschnittsanalysen

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
	archinst hplot
}

*  +----------------------------------------------------------------+
*  |                             Retrival                           |
*  +----------------------------------------------------------------+

mkdat  /*
*/ fam84 fam85 fam86 fam87 fam88 fam89 fam90 fam91 fam92 fam93 fam94 fam95 /*
*/ fam96 fam97  /*
*/ est84 est85 est86 est87 est88 est89 est90 est91 est92 est93 est94 est95 /*
*/ est96 est97  /*
*/ megph84 megph85 megph86 megph87 megph88 megph89 megph90 megph91 megph92  /*
*/ megph93 megph94 megph95 megph96 megph97  /*
*/ pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93 pid94 pid95 /*
*/ pid96 pid97  /*
*/ bil84 bil85 bil86 bil87 bil88 bil89 bil90 bil91 bil92 bil93 bil94 bil95 /*
*/ bil96 bil97  /*
*/ bul84 bul85 bul86 bul87 bul88 bul89 bul90 bul91 bul92 bul93 bul94 bul95 /*
*/ bul96 bul97  /*
*/ bbil84 bbil85 bbil86 bbil87 bbil88 bbil89 bbil90 bbil91 bbil92 bbil93  /*
*/  bbil94 bbil95 bbil96 bbil97  /*
*/ hst84 hst85 hst86 hst87 hst88 hst89 hst90 hst91 hst92 hst93  /*
*/  hst94 hst95 hst96 hst97  /*
*/ using $soepdir,  /*
*/ files(peigen) waves(a b c d e f g h i j k l m n) keep(sex gebjahr hhnr) /*
*/ netto(-3,-2,-1,0,1,2,3,4,5)

holrein /* 
Arbeitslos:     */  _x99 bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09  /*
                */ jp09 kp16 lp13 mp12 np08 /*
*/  using $soepdir, /*
*/ files(p) waves(a b c d e f g h i j k l m n)

*  +----------------------------------------------------------------+
*  |                        Rename to Reshape                       |
*  +----------------------------------------------------------------+

* Programm zum Umbenennen einer Varlist
capture program drop umben
program define umben
	local newname `1'
	mac shift
	local i 84
	while "`1'" ~= "" {
		ren `1' `newname'`i'
		local i = `i' + 1
		mac shift
	}
end

drop hhnr

umben hhnr ahhnr bhhnr chhnr dhhnr ehhnr fhhnr ghhnr  /*
*/ hhhnr ihhnr jhhnr khhnr lhhnr mhhnr nhhnr
umben netto anetto bnetto cnetto dnetto enetto fnetto gnetto  /*
*/ hnetto inetto jnetto knetto lnetto mnetto nnetto
gen apx = .
umben arblos bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09 jp09 kp16 lp13  /*
*/ mp12 np08
replace arblos84 = 1 if est84==5
replace arblos84 = 2 if est84~=5 & est84 ~= .


*  +----------------------------------------------------------------+
*  |                    Reshape + xtdata                            |
*  +----------------------------------------------------------------+

reshape long hhnr netto fam est megph pid arblos bil bbil bul hst, /*
*/ i(persnr) j(welle)

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

gen spd = pid == 2 if pid ~= .
gen cdu = pid == 3 | pid == 4 if pid ~= .
gen b90 = pid == 5 if pid ~= .

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

gen dalos = arblos == 1 if arblos > 0 & arblos ~= .

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

sort hhnr
qby hhnr: gen kind = 1 if hst == 3 | hst == 4
qby hhnr: replace kind = sum(kind)
gen eltern = 0
qby hhnr: replace eltern = 1 if kind[_N] >= 1 & hst >= 0 & hst <= 2

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
merge persnr using weights 
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
	ealos
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

logit spd degp2-degp4 dalos dbil2-dbil6 dbbil1 dbbil3-dbbil8 dest2-dest6  /*
*/ dfam2-dfam6 eltern men gebjahr  dbul2-dbul15 dwelle2-dwelle14 [pw = uw] 

gen bspd = .
replace bspd = 0 - _b[degp2] in 1
replace bspd = 0 - _b[degp3] in 2
replace bspd = 0 - _b[degp4] in 3
replace bspd = _b[degp2] - 0 in 4
replace bspd = _b[degp2] - _b[degp3] in 5
replace bspd = _b[degp2] - _b[degp4] in 6
replace bspd = _b[degp3] - 0 in 7
replace bspd = _b[degp3] - _b[degp2] in 8
replace bspd = _b[degp3] - _b[degp4] in 9
replace bspd = _b[degp4] - 0 in 10 
replace bspd = _b[degp4] - _b[degp2] in 11
replace bspd = _b[degp4] - _b[degp3] in 12
replace bspd = _b[dalos] in 13
replace bspd = 0 - _b[dalos] in 14
replace bspd = 0 - _b[dbil6] in 15
replace bspd = _b[dbbil8] in 16 
replace bspd = 0 - _b[dbbil1] in 17
replace bspd = . in 18
replace bspd = 0 - _b[dfam3] in 19
replace bspd = _b[eltern] in 20
replace bspd = . in 21


logit cdu degp2-degp4 dalos dbil2-dbil6 dbbil1 dbbil3-dbbil8 dest2-dest6  /*
*/ dfam2-dfam6 eltern men gebjahr  dbul2-dbul15 dwelle2-dwelle14 [pw = uw] 

gen bcdu = .
replace bcdu = 0 - _b[degp2] in 1
replace bcdu = 0 - _b[degp3] in 2
replace bcdu = 0 - _b[degp4] in 3
replace bcdu = _b[degp2] - 0 in 4
replace bcdu = _b[degp2] - _b[degp3] in 5
replace bcdu = _b[degp2] - _b[degp4] in 6
replace bcdu = _b[degp3] - 0 in 7
replace bcdu = _b[degp3] - _b[degp2] in 8
replace bcdu = _b[degp3] - _b[degp4] in 9
replace bcdu = _b[degp4] - 0 in 10 
replace bcdu = _b[degp4] - _b[degp2] in 11
replace bcdu = _b[degp4] - _b[degp3] in 12
replace bcdu = _b[dalos] in 13
replace bcdu = 0 - _b[dalos] in 14
replace bcdu = 0 - _b[dbil6] in 15
replace bcdu = _b[dbbil8] in 16 
replace bcdu = 0 - _b[dbbil1] in 17
replace bcdu = . in 18
replace bcdu = 0 - _b[dfam3] in 19
replace bcdu = _b[eltern] in 20
replace bcdu = . in 21

logit b90 degp2-degp4 dalos dbil2-dbil6 dbbil1 dbbil3-dbbil8 dest2-dest6  /*
*/ dfam2-dfam6 eltern men gebjahr  dbul2-dbul15 dwelle2-dwelle14 [pw = uw] 

gen bb90 = .
replace bb90 = 0 - _b[degp2] in 1
replace bb90 = 0 - _b[degp3] in 2
replace bb90 = 0 - _b[degp4] in 3
replace bb90 = _b[degp2] - 0 in 4
replace bb90 = _b[degp2] - _b[degp3] in 5
replace bb90 = _b[degp2] - _b[degp4] in 6
replace bb90 = _b[degp3] - 0 in 7
replace bb90 = _b[degp3] - _b[degp2] in 8
replace bb90 = _b[degp3] - _b[degp4] in 9
replace bb90 = _b[degp4] - 0 in 10 
replace bb90 = _b[degp4] - _b[degp2] in 11
replace bb90 = _b[degp4] - _b[degp3] in 12
replace bb90 = _b[dalos] in 13
replace bb90 = 0 - _b[dalos] in 14
replace bb90 = 0 - _b[dbil6] in 15
replace bb90 = _b[dbbil8] in 16 
replace bb90 = 0 - _b[dbbil1] in 17
replace bb90 = . in 18
replace bb90 = 0 - _b[dfam3] in 19
replace bb90 = _b[eltern] in 20
replace bb90 = . in 21


*  +----------------------------------------------------------------+
*  |                  Zusammenführung                               |
*  +----------------------------------------------------------------+

keep uv bspd bcdu bb90
gen index = _n
drop if index > 21
sort uv
save 11, replace

capture use pidlv3, clear
if _rc ~= 0 {
	do anpidlv2
	use pidlv3, clear
}

sort uv
merge uv using 11

*  +----------------------------------------------------------------+
*  |                   Graphik                                      |
*  +----------------------------------------------------------------+

* Beschriftungen
* --------------

for var bspd bcdu bb90: label var X "Between-Effects"
for var bspd1 bcdu1 bb901: label var X "Fixed-Effects"

sort index
replace uv = "Admin. Dienste" if uv == "eadmsel"
replace uv = "Mischt./Experte" if uv == "emissel"
replace uv = "Arb./Soz. Dienste" if uv == "earbsel"
replace uv = "Selbstaendige" if uv == "eseladm"
replace uv = "Mischt./Experte"  if uv == "emisadm"
replace uv = "Arb./Soz. Dienste" if uv == "earbadm"
replace uv = "Selbstaendige" if uv == "eselmis"
replace uv = "Admin. Dienste" if uv == "eadmmis"
replace uv = "Arb./Soz. Dienste" if uv == "earbmis"
replace uv = "Selbstaendige" if uv == "eselarb"
replace uv = "Admin. Dienste" if uv == "eadmarb"
replace uv = "Mischt./Experte" if uv == "emisarb"
replace uv = "Eintritt" if uv == "ealos"
replace uv = "Austritt" if uv == "eest"
replace uv = "Schulabschluss" if uv == "easchul"
replace uv = "Hochschulabschluss" if uv == "ehschul"
replace uv = "Berufsausbildung" if uv == "ebschul"
replace uv = "Beginn Erwerbsleben" if uv == "ebstart"
replace uv = "Hochzeit" if uv == "ehoch1"
replace uv = "Geburt erstes Kind" if uv == "ekind1"
replace uv = "Geburt weiterer Kinder" if uv == "ekind2"


* Common Options
* --------------

local opt `"range xline(0) legend(uv) line gap(0,3,6,9,12,14)"'
local opt `"`opt' glegend(Selbstaendig geworden von!Admin. Dienste geworden von!Mischtyp/Experte geworden von! Arbeiter geworden von!Arbeitslosigkeit!Investition in Zwischengueter)"'
local opt `"`opt' gllj glpos(10) format(%2.1f) xscale(-1.6,1.6) "'
local opt `"`opt' xlab(-1.5(.5)1.5) border flipt"'

hplot bspd* , `opt' saving(pidlv3a, replace) t(SPD-Modell)
hplot bcdu* , `opt' saving(pidlv3b, replace) t(CDU/FDP-Modell)
hplot bb90* , `opt' saving(pidlv3c, replace) t(B90-Modell)


*  +----------------------------------------------------------------+
*  |                   Summary-Statistics                           |
*  +----------------------------------------------------------------+

preserve
drop if index  > 12
drop bb90
ren bspd b11
ren bcdu b12
ren bspd1 b21
ren bcdu1 b22
keep index uv b* 
reshape long b1 b2, i(index) j(x)
drop x
replace index = _n
reshape long b, i(i) j(model)
replace b = abs(b)
tab uv model, sum(b) nost nof noo
restore

sum b*

erase 11.dta

exit



* Laengsschnittdatensatz fuer Kapitel 6
* ---------------------------------------------
* Pid, Klasse, Arbeitslosigkeit, kritische Lebensereignisse. 
* Partner, gebjahr, sex 
*  alle Wellen, unbalanced, langes Format, weights

clear
set memory 60m
version 7.0
set more off

* 0) Cool-Ados
* ------------

capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
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
*/ using $soepdir,  /*
*/ files(peigen) waves(a b c d e f g h i j k l m n) keep(sex gebjahr hhnr) /*
*/ netto(-3,-2,-1,0,1,2,3,4,5)

holrein /* 
pol. Interesse: */ _x0 bp75 cp75 dp84 ep73 fp89 gp83 hp89 ip89 jp89 /*
                */ kp91 lp97 mp83 np93 /*
Schulabschluss: */ _x3 bp5401 cp5401 dp5401 ep4901 fp6701 gp6701 hp6301  /*
			    */ ip6301 jp7301 kp7301 lp7901 mp6001 np6001 /*
HSchulabschluss:*/ _x4 bp5402 cp5402 dp5402 ep4902 fp6702 gp6702 hp6302  /*
				*/  ip6302 jp7302 kp7302 lp7902 mp6002 np6002 /*
Bausbildungsschluss: */ _x5 bp5406 cp5406 dp5406 ep4906 fp6705 gp6705 /*
		        */ hp6305 ip6306 jp7306 kp7306 lp7906 mp6006 np6006 /*
Interviewdatum: */ _x90 bpmonin cpmonin dpmonin epmonin fpmonin gpmonin  /*
			    */ hpmonin ipmonin jpmonin kpmonin lpmonin mpmonin npmonin /*
erstmals erw 1: */ _x12 bp22g09 cp22g09 dp20g09 ep20g01 fp18g01 gp21g01 /*
				*/  hp23g01 ip23g01 jp23g01 kp3801 lp3001 mp2801 np2201 /*
erstmals erw2:  */ _x13  bp22g10 cp22g10 dp20g10 ep20g02 fp18g02 gp21g02  /*
		        */ hp23g02 ip23g02 jp23g02 kp39 lp31 mp29 np23  /*
Arbeitslos:     */  _x99 bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09  /*
                */ jp09 kp16 lp13 mp12 np08 /*
*/  using $soepdir, /*
*/ files(p) waves(a b c d e f g h i j k l m n)

holrein /*
*/ partnr84 partnr85 partnr86 partnr87 partnr88 partnr89 partnr90 partnr91  /*
*/  partnr92 partnr93 partnr94 partnr95 partnr96 partnr97 /*
*/ using $soepdir, /*
*/ files(pgen) waves(a b c d e f g h i j k l m n) 

drop *hhnr

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

gen apx = .
umben monin apx bpmonin cpmonin dpmonin epmonin fpmonin gpmonin hpmonin  /*
*/  ipmonin jpmonin kpmonin lpmonin mpmonin npmonin 
gen apx = .
umben polint apx bp75 cp75 dp84 ep73 fp89 gp83 hp89 ip89 jp89 kp91 lp97 /*
*/  mp83 np93 
gen apx = .
umben aschulab apx bp5401 cp5401 dp5401 ep4901 fp6701 gp6701  hp6301   /*
*/ ip6301 jp7301 kp7301 lp7901 mp6001 np6001
gen apx = . 
umben hschulab apx bp5402 cp5402 dp5402 ep4902 fp6702 gp6702  hp6302   /*
*/ ip6302 jp7302 kp7302  lp7902 mp6002 np6002
gen apx = . 
umben bschulab apx bp5406 cp5406 dp5406 ep4906 fp6705 gp6705  hp6305   /*
*/ ip6306 jp7306 kp7306  lp7906 mp6006 np6006
gen apx = .
umben bstart1 apx bp22g09 cp22g09 dp20g09 ep20g01 fp18g01 gp21g01 /*
*/ hp23g01 ip23g01 jp23g01 kp3801 lp3001 mp2801 np2201 
gen apx = .
umben bstart2 apx  bp22g10 cp22g10 dp20g10 ep20g02 fp18g02 gp21g02  /*
*/ hp23g02 ip23g02 jp23g02 kp39 lp31 mp29 np23  
umben netto anetto bnetto cnetto dnetto enetto fnetto gnetto  /*
*/ hnetto inetto jnetto  knetto lnetto mnetto nnetto
gen apx = .
umben arblos bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09 jp09 kp16 lp13  /*
*/ mp12 np08
replace arblos84 = 1 if est84==5
replace arblos84 = 2 if est84~=5 & est84 ~= .


*  +----------------------------------------------------------------+
*  |                    Reshape + xtdata                            |
*  +----------------------------------------------------------------+

reshape long fam est megph pid polint /*
*/ aschulab bschulab hschulab bstart1 bstart2  /*
*/ netto arblos partnr monin, /*
*/ i(persnr) j(welle)

sort persnr welle

* Mindestens drei Teilnahmen!
by persnr (welle): gen byte bef = 1 if netto == 1
by persnr (welle): replace bef = sum(bef)
by persnr (welle): replace bef = bef[_N]
drop if bef < 3

iis persnr
tis welle


*  +----------------------------------------------------------------+
*  |                   Rekodierungen                                |
*  +----------------------------------------------------------------+


* Veränderung der Originaldaten
* -----------------------------

replace partnr = 55101 if partnr == 55103 & persnr == 55102
replace partnr = 103501 if partnr == 103503 & persnr == 103502
replace partnr = 731804 if partnr == 713804 & persnr == 595303
replace partnr = 5007301 if persnr == 5007302 & partnr == 5007201
replace partnr = . if persnr == 5101203 & partnr == 5101201
replace partnr = . if persnr == 5187703 & partnr == 5187701
replace partnr = . if persnr == 5188103 & partnr == 5188101

* Ereignisindikatoren
* -------------------

* Gliederung:
* 	Klassenereignisse
*	Arbeitslosigkeit
*	Aging-Conservatism
*	Interaktionstheorie

sort persnr welle

* +---------+
* | Klassen |
* +---------+

* Selbstaendig Werden
* -------------------

* Admin. D.  -> Selbstaendig
qby persnr (welle): gen byte eadmsel = 1  /*
*/ if (megph >= 5 & megph <= 7)  /*
*/ & megph[_n-1] == 1
qby persnr (welle): replace eadmsel = . if _n==1
qby persnr (welle): replace eadmsel = sum(eadmsel) if _n > 1
lab var eadmsel "Adm. D -> Selb."

* Micht. -> Selbstaendig
qby persnr (welle): gen byte emissel = 1  /*
*/ if (megph >= 5 & megph <= 7)  /*
*/ & (megph[_n-1] ==2 | megph[_n-1] ==4 | megph[_n-1] ==8 | megph[_n-1] ==12)
qby persnr (welle): replace emissel = . if _n==1
qby persnr (welle): replace emissel = sum(emissel) if _n > 1
lab var emissel "Mischt. -> Selb."

* Arbeiter -> Selbstaendig
qby persnr (welle): gen byte earbsel = 1  /*
*/ if (megph >= 5 & megph <= 7)  /*
*/ & (megph[_n-1] == 3 | (megph[_n-1] >= 9 & megph[_n-1] <= 11))
qby persnr (welle): replace earbsel = . if _n==1
qby persnr (welle): replace earbsel = sum(earbsel) if _n > 1
lab var earbsel "Arb. -> Selb."

* Administrative Dienste Werden
* -----------------------------

* Selbstaendig  -> Admin. D. 
qby persnr (welle): gen byte eseladm = 1  /*
*/ if megph == 1 /*
*/ & (megph[_n-1] >= 5 & megph[_n-1] <= 7)
qby persnr (welle): replace eseladm = . if _n==1
qby persnr (welle): replace eseladm = sum(eseladm) if _n > 1
lab var eseladm "Adm. D -> Admin. D."

* Micht. -> Admin. D.
qby persnr (welle): gen byte emisadm = 1  /*
*/ if megph == 1  /*
*/ & (megph[_n-1] ==2 | megph[_n-1] ==4 | megph[_n-1] ==8 | megph[_n-1] ==12)
qby persnr (welle): replace emisadm = . if _n==1
qby persnr (welle): replace emisadm = sum(emisadm) if _n > 1
lab var emisadm "Mischt. -> Admin. D."

* Arbeiter -> Admin. D.
qby persnr (welle): gen byte earbadm = 1  /*
*/ if megph == 1  /*
*/ & (megph[_n-1] == 3 | (megph[_n-1] >= 9 & megph[_n-1] <= 11))
qby persnr (welle): replace earbadm = . if _n==1
qby persnr (welle): replace earbadm = sum(earbadm) if _n > 1
lab var earbadm "Arb. -> Admin. D."


* Mischtyp Werden
* ---------------

* Selbstaendig  -> Mischtyp 
qby persnr (welle): gen byte eselmis = 1  /*
*/ if (megph == 2 | megph == 4 | megph == 8 | megph == 12) /*
*/ & (megph[_n-1] >= 5 & megph[_n-1] <= 7)
qby persnr (welle): replace eselmis = . if _n==1
qby persnr (welle): replace eselmis = sum(eselmis) if _n > 1
lab var eselmis "Mis. D -> Mischtyp"

* Admin D. -> Mischtyp
qby persnr (welle): gen byte eadmmis = 1  /*
*/ if (megph == 2 | megph == 4 | megph == 8 | megph == 12)  /*
*/ & megph[_n-1] == 1
qby persnr (welle): replace eadmmis = . if _n==1
qby persnr (welle): replace eadmmis = sum(eadmmis) if _n > 1
lab var eadmmis "Admin D. -> Mischtyp"

* Arbeiter -> Mischtyp
qby persnr (welle): gen byte earbmis = 1  /*
*/ if (megph == 2 | megph == 4 | megph == 8 | megph == 12)  /*
*/ & (megph[_n-1] == 3 | (megph[_n-1] >= 9 & megph[_n-1] <= 11))
qby persnr (welle): replace earbmis = . if _n==1
qby persnr (welle): replace earbmis = sum(earbmis) if _n > 1
lab var earbmis "Arb. -> Mischtyp"

* Arbeiter Werden
* ----------------

* Selbstaendig  -> Arb. 
qby persnr (welle): gen byte eselarb = 1  /*
*/ if (megph == 3 | (megph >= 9 & megph <= 11))  /*
*/ & (megph[_n-1] >= 5 & megph[_n-1] <= 7)
qby persnr (welle): replace eselarb = . if _n==1
qby persnr (welle): replace eselarb = sum(eselarb) if _n > 1
lab var eselarb "Arb. D -> Arb."

* Admin D. -> Arb.
qby persnr (welle): gen byte eadmarb = 1  /*
*/ if (megph == 3 | (megph >= 9 & megph <= 11))   /*
*/ & megph[_n-1] == 1
qby persnr (welle): replace eadmarb = . if _n==1
qby persnr (welle): replace eadmarb = sum(eadmarb) if _n > 1
lab var eadmarb "Admin D. -> Arb."

* Mischtyp -> Arb.
qby persnr (welle): gen byte emisarb = 1  /*
*/ if (megph == 3 | (megph >= 9 & megph <= 11))   /*
*/ & (megph[_n-1] ==2 | megph[_n-1] ==4 | megph[_n-1] ==8 | megph[_n-1] ==12)
qby persnr (welle): replace emisarb = . if _n==1
qby persnr (welle): replace emisarb = sum(emisarb) if _n > 1
lab var emisarb "Arb. -> Arb."

* +------------------+
* | Arbeitslosigkeit |
* +------------------+

* Arbeitslos werden
* -----------------

qby persnr (welle): gen ealos = 1  /*
*/ if arblos == 1 & arblos[_n-1] == 2
qby persnr (welle): replace ealos = . if _n==1
qby persnr (welle): replace ealos = sum(ealos) if _n > 1
lab var ealos "Arbeitslos geworden"

* Ende Arbeitslosigkeit
* ---------------------

qby persnr (welle): gen byte eest = 1  /*
*/ if arblos == 2 & arblos[_n-1] == 1
qby persnr (welle): replace eest = . if _n==1
qby persnr (welle): replace eest = sum(eest) if _n > 1
lab var eest "Erwerbst. geworden"

* +--------------------+
* | Aging-Conservatism |
* +--------------------+

* Ende Schulausbildung
* --------------------

gen byte easchul = 1  /*
*/ if aschulab >= 1 & aschulab <= 5 
qby persnr (welle): replace easchul = sum(easchul) if _n > 1
lab var easchul "Schulausbildung abgeschlossen" 

* Ende Hochschulausbildung
* ------------------------

gen byte ehschul = 1  /*
*/ if hschulab >= 1 & hschulab <= 2
qby persnr (welle): replace ehschul = sum(ehschul) if _n > 1
lab var ehschul "Hochschulausbildung abgeschlossen"

* Ende Berufsausbildung
* ---------------------

gen byte ebschul = 1 if  /*
*/ bschulab >= 1 & bschulab <= 7
qby persnr (welle): replace ebschul = sum(ebschul) if _n > 1
lab var ebschul "Berufsausbildung abgeschlossen"

* Aufnahme eigener Erwerbstaetigkeit
* ----------------------------------

gen byte ebstart = 1  /*
*/ if ((bstart1 >= monin[_n-1] & bstart1 ~= .)  /*
*/ | (bstart2 <= monin & bstart2 ~= . & bstart2 > 0))  /*
*/ & welle <= 93 & monin > 0 & monin ~= .
replace ebstart = 1 if bstart2 == 1 & welle >= 94
qby persnr (welle): replace ebstart = . if _n==1
qby persnr (welle): replace ebstart = sum(ebstart) if _n > 1
lab var ebstart "Start in Berufslaben"

* Erste Hochzeit?
* ---------------

qby persnr (welle): gen byte ehoch1 = 1 /*
*/ if fam == 1 & fam[_n-1]==3
qby persnr (welle): replace ehoch1 = . if _n==1
qby persnr (welle): replace ehoch1 = sum(ehoch1) if _n > 1
lab var ehoch1 "Erste Hochzeit"

capture assert ehoch1 <= 1
if _rc ~= 0 {
	* assertion is false"
	* Eine Reihe von Personen haben haben mehr als einen
	* Ubergang von Ledig zu Verh. Die Hochzeiten dieser
    * Personen werden hier ignoriert. 
}


* Scheidungen/Trennungen
* ----------------------

qby persnr (welle): gen byte escheid = 1 /*
*/ if (fam == 2 | fam == 4) & (fam[_n-1] == 1 | fam[_n-1] == 6)
qby persnr (welle): replace escheid = . if _n==1
qby persnr (welle): replace escheid = sum(escheid) if _n > 1
lab var escheid "Scheidung/Trennung?"


* Geburt des ersten Kindes
* ------------------------

* Match Geburtsdaten der Kinder
save 11, replace
use hhnr persnr kidgeb01 - kidgeb15 /*
 */ using $soepdir/biobirth

	* Veränderung Originaldaten
	replace kidgeb01 = kidgeb02 if persnr == 156002
	replace kidgeb02 = kidgeb03 if persnr == 156002
	replace kidgeb03 = -2 if persnr == 156002

sort persnr
save 12, replace
use 11, replace
merge persnr using 12
drop if _merge == 2
drop _merge

* Erzeugung Ereignisindikator
sort persnr welle
qby persnr (welle): gen byte ekind1 = 1 /*
*/ if kidgeb01 - 1900 == welle - 1
qby persnr (welle): replace ekind1 = sum(ekind1) if _n > 1
assert ekind1 <= 1 | ekind1 == .
lab var ekind1 "Geburt erstes Kind?"

* Geburt weiterer Kinder
* ---------------------

gen byte ekind2 = 1 /*
*/ if (kidgeb02 - 1900 == welle - 1) /*
*/  | (kidgeb03 - 1900 == welle - 1) /*
*/  | (kidgeb04 - 1900 == welle - 1) /*
*/  | (kidgeb05 - 1900 == welle - 1) /*
*/  | (kidgeb06 - 1900 == welle - 1) /*
*/  | (kidgeb07 - 1900 == welle - 1) /*
*/  | (kidgeb08 - 1900 == welle - 1) /*
*/  | (kidgeb09 - 1900 == welle - 1) /*
*/  | (kidgeb10 - 1900 == welle - 1) /*
*/  | (kidgeb11 - 1900 == welle - 1) /*
*/  | (kidgeb12 - 1900 == welle - 1) /*
*/  | (kidgeb13 - 1900 == welle - 1) /*
*/  | (kidgeb14 - 1900 == welle - 1) /*
*/  | (kidgeb15 - 1900 == welle - 1)
qby persnr (welle): replace ekind2 = sum(ekind2) if _n > 1
lab var ekind2 "Geburt weiterer Kinder?"
drop kidgeb*

* Zuweisung zum Lebenspartner
save 11, replace
keep partnr welle ekind1 ekind2
ren partnr persnr
ren ekind1 pkind1
ren ekind2 pkind2
sort persnr welle 
save 12, replace
use 11, clear
sort persnr welle
merge persnr welle using 12
drop if _merge == 2
drop _merge
replace ekind1 = pkind1 if sex == 1 & pkind1 ~= .
replace ekind2 = pkind2 if sex == 1 & pkind2 ~= .
drop pkind*

* +---------------------+
* | Interaktionstheorie |
* +---------------------+

* Neuer Partner mit anderer PI
* ----------------------------

* Match Partnereigenschaften
save 11, replace
keep pid polint partnr welle
ren partnr persnr
ren pid parpid
ren polint parpint
drop if persnr == . | persnr < 0
sort persnr welle
save 12, replace
use 11, clear
sort persnr welle
merge persnr welle using 12
drop if _merge == 2
drop _merge

* Neuer Partner SPD, selbst nicht SPD
sort persnr welle
qby persnr (welle): gen byte eparspd = 1  /*
*/ if parpid == 2 & pid ~= 2  /*
*/ & partnr ~= partnr[_n-1]  & partnr ~= . & partnr  > 0 
qby persnr (welle): replace eparspd = . if _n==1
qby persnr (welle): replace eparspd = sum(eparspd) if _n > 1
lab var eparspd "Lebenspartner SPD"

* Neuer Partner CDU/FDP, selbst nicht CDU/FDP
qby persnr (welle): gen byte eparkons = 1  /*
*/ if (parpid == 3 | parpid==4) & (pid ~= 3 & pid ~= 4) /*
*/ & partnr ~= partnr[_n-1]  & partnr ~= . & partnr  > 0 
qby persnr (welle): replace eparkons = . if _n==1
qby persnr (welle): replace eparkons = sum(eparkons) if _n > 1
lab var eparkons "Lebenspartner CDU/FDP"

* Neuer Partner B90, selbst nicht B90
qby persnr (welle): gen byte eparb90 = 1  /*
*/ if parpid == 5 & pid ~= 5 /*
*/ & partnr ~= partnr[_n-1]  & partnr ~= . & partnr  > 0 
qby persnr (welle): replace eparspd = . if _n==1
qby persnr (welle): replace eparb90 = sum(eparb90) if _n > 1
lab var eparb90 "Lebenspartner B90"

*  +-------------------------------------------------+
*  |                   Weights & friends             |
*  +-------------------------------------------------+

sort persnr
merge persnr using weights 
drop if _merge==2
drop _merge
compress

sort persnr welle
qby persnr (welle): drop if _n == 1

save pidlv, replace
erase 11.dta
erase 12.dta

exit



Veränderung der Originaldaten
-----------------------------

biobirth.dta

        hhnr        15601      persnr       156002    kidgeb01           -2
    kidgeb02         1965    kidgeb03         1971    kidgeb04           -2
    kidgeb05           -2    kidgeb06           -2    kidgeb07           -2
    kidgeb08           -2    kidgeb09           -2    kidgeb10           -2
    kidgeb11           -2    kidgeb12           -2    kidgeb13           -2
    kidgeb14           -2    kidgeb15           -2

replace kidgeb01 = kidgeb02 if persnr == 156002
replace kidgeb02 = kidgeb03 if persnr == 156002
replace kidgeb03 = -2 if persnr == 156002

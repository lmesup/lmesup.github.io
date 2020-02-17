* Main Analyzing Data for Kohler02c
* ---------------------------------
*  all waves, unbalanced, long, weights

clear
set memory 120m
version 7.0
set more off

* 0) Cool-Ados
* ------------

capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}

capture which mmerge
if _rc ~= 0 {
	ssc install mmerge
}


*  +----------------------------------------------------------------+
*  |                             Retrival                           |
*  +----------------------------------------------------------------+

mkdat /*
PI
*/ ap5601 bp7901 cp7901 dp8801 ep7701 fp9301 gp8501 hp9001 ip9001 jp9001  /*
*/ kp9201 lp9801 mp8401 np9401 op9701 pp111 qp116 /*
*/ ap5602 bp7902 cp7902 dp8802 ep7702 fp9302 gp8502 hp9002 ip9002 jp9002  /*
*/ kp9202 lp9802 mp8402 np9402 op9702 pp11201 qp11701 /*
pol. Interesse:
*/ _x0 bp75 cp75 dp84 ep73 fp89 gp83 hp89 ip89 jp89  kp91 lp97 mp83 np93  /*
*/ op96 pp110 qp115   /*
Erwerbsstatus: 
*/ ap08 bp16 cp16 dp12 ep12 fp10 gp12 hp15 ip15 jp15 kp25 lp21 /*
*/ mp15 np11 op09 pp10 qp10 /*
Schulabschluss:
*/ _x3 bp5401 cp5401 dp5401 ep4901 fp6701 gp6701 hp6301 ip6301 jp7301 kp7301  /*
*/ lp7901 mp6001 np6001 op5101 pp6801 qp6802    /*
HSchulabschluss:
*/ _x4 bp5402 cp5402 dp5402 ep4902 fp6702 gp6702 hp6302 ip6302 jp7302 kp7302  /*
*/ lp7902 mp6002 np6002 op5102 pp6802 qp6803  /*
Bausbildungsschluss:
*/ _x5 bp5406 cp5406 dp5406 ep4906 fp6705 gp6705 hp6305 ip6306 jp7306 kp7306  /*
*/ lp7906 mp6006 np6006 op5106 pp6806 qp6807  /*
Interviewdatum:
*/ _x90 bpmonin cpmonin dpmonin epmonin fpmonin gpmonin hpmonin ipmonin jpmonin  /*
*/ kpmonin lpmonin mpmonin npmonin opmonin ppmonin qpmonin /*
erstmals erw 1:
*/ _x12 bp22g09 cp22g09 dp20g09 ep20g01 fp18g01 gp21g01 hp23g01 ip23g01 jp23g01  /*
*/ kp3801 lp3001 mp2801 np2201 op2201 pp2201 qp2101     /*
erstmals erw2:
*/ _x13  bp22g10 cp22g10 dp20g10 ep20g02 fp18g02 gp21g02 hp23g02 ip23g02 jp23g02  /*
*/ kp39 lp31 mp29 np23 op23 pp23 qp22      /*
früherer Beruf
*/ ap1601 bp24b01 cp24b01 dp22b01 ep22b01 fp20b01 gp23b01 hp25b01  /*
*/ ip25b01 jp25b01 _x1 _x11 _x21 _x21a _n1 _n6 _m1 /*
*/ ap1602 bp24b02 cp24b02 dp22b02 ep22b02 fp20b02 gp23b02 hp25b02  /*
*/ ip25b02 jp25b02 _x2 _x12a _x22 _x22a _n2 _n7 _m8 /*
*/ ap1603 bp24b03 cp24b03 dp22b03 ep22b03 fp20b03 gp23b03 hp25b03  /*
*/ ip25b03 jp25b03 _x3a _x13a _x23b _x23a _n3 _n8 _m9 /*
*/ ap1604 bp24b04 cp24b04 dp22b04 ep22b04 fp20b04 gp23b04 hp25b04  /*
*/ ip25b04 jp25b04 _x4a _x14a _x24a _x24aa _n4 _n9 _m10 /*
*/ ap1605 bp24b05 cp24b05 dp22b05 ep22b05 fp20b05 gp23b05 hp25b05  /*
*/ ip25b05 jp25b05 _x5a _x15a _x25a _x25b _n5 _n10 _m11       /*
*/  using $soepdir, /*
*/ files(p) waves(a b c d e f g h i j k l m n o p q)  /*
*/ netto(-3,-2,-1,0,1,2,3,4,5) keep(sex gebjahr qsampreg) 

holrein /*
Familienstand
*/ afamstd bfamstd cfamstd dfamstd efamstd ffamstd gfamstd hfamstd  /*
*/ ifamstd jfamstd kfamstd lfamstd mfamstd nfamstd ofamstd pfamstd  /*
*/ qfamstd    /*
Partner
*/ partnr84 partnr85 partnr86 partnr87 partnr88 partnr89 partnr90 partnr91  /*
*/ partnr92 partnr93 partnr94 partnr95 partnr96 partnr97 partnr98 partnr99  /*
*/ partnr00 /*
Beruf
*/ isco84 isco85 isco86 isco87 isco88 isco89 isco90 isco91 isco92 /*
*/ isco93 isco94 isco95 isco96 isco97 isco98 isco99 isco00 /*
Goldthorpe-Klassen
*/ goldth84 goldth85 goldth86 goldth87 goldth88 goldth89 goldth90  /*
*/ goldth91 goldth92 goldth93 goldth94 goldth95 goldth96 goldth97  /*
*/ goldth98 goldth99 goldth00/*
*/ using $soepdir, /*
*/ files(pgen) waves(a b c d e f g h i j k l m n o p q)


holrein /*
*/ astell bstell cstell dstell estell fstell gstell hstell istell  /*
*/ jstell kstell lstell mstell nstell ostell pstell qstell /*
*/ using $soepdir, files(pbrutto) waves(a b c d e f g h i j k l m n o p q) 


* Einkommenskalendarien
* ---------------------

holrein  /*
*/ ap2a02 bp2a02 cp2a02 dp2a02 ep2a02 fp2a02 gp2a02 /* Monate Lohn/Gehalt 
*/ hp2a02 ip2a02 jp2a02 kp2a02 lp2a02 mp2a02 np2a02 op2a02 pp2a02 qp2a02  /*
*/ ap2b02 bp2b02 cp2b02 dp2b02 ep2b02 fp2b02 gp2b02 /* Monate Einkommen 
*/ hp2b02 ip2b02 jp2b02 kp2b02 lp2b02 mp2b02 np2b02 op2b02 pp2b02 qp2b02 /*
*/ ap2c02 bp2c02 cp2c02 dp2c02 ep2c02 fp2c02 gp2c02 /* Monate Nebenerwerb 
*/ hp2c02 ip2c02 jp2c02 kp2c02 lp2c02 mp2c02 np2c02 op2c02 pp2c02 qp2c02 /*
*/ ap2d02 bp2d02 cp2d02 dp2d02 ep2d02 fp2d02 gp2d02 /* Monate Rente/Pension 
*/ hp2d02 ip2d02 jp2d02 kp2d02 lp2d02 mp2d02 np2d02 op2d02 pp2d02 qp2d02 /*
*/ ap2f02 bp2f02 cp2f02 dp2f02 ep2f02 fp2f02 gp2f02 /* Monate Arbeitslosengeld 
*/ hp2f02 ip2f02 jp2f02 kp2f02 lp2f02 mp2f02 np2f02 op2f02 pp2f02 qp2f02 /*
*/ ap2g02 bp2g02 cp2g02 dp2g02 ep2g02 fp2g02 gp2g02 /* Monate Arbeitsl.-hilfe
*/ hp2g02 ip2g02 jp2g02 kp2g02 lp2g02 mp2g02 np2g02 op2g02 pp2g02 qp2g02 /*
*/ ap2h02 bp2h02 cp2h02 dp2h02 ep2h02 fp2h02 gp2h02 /* Mon. Unterh. Arbeitsamt 
*/ hp2h02 ip2h02 jp2h02 kp2h02 lp2h02 mp2h02 np2h02 op2h02 pp2h02 qp2h02 /*
*/ ap2k02 bp2k02 cp2k02 dp2k02 ep2k02 fp2k02 gp2k02 /* Mon. Baf"og, Stipendien 
*/ hp2k02 ip2k02 jp2k02 kp2k02 lp2k02 mp2k02 np2k02 op2k02 pp2k02 qp2k02 /*
*/ ap2a03 bp2a03 cp2a03 dp2a03 ep2a03 fp2a03 gp2a03 /* Lohn/Gehalt           
*/ hp2a03 ip2a03 jp2a03 kp2a03 lp2a03 mp2a03 np2a03 op2a03 pp2a03 qp2a03 /*		 
*/ ap2b03 bp2b03 cp2b03 dp2b03 ep2b03 fp2b03 gp2b03 /* Einkommen             
*/ hp2b03 ip2b03 jp2b03 kp2b03 lp2b03 mp2b03 np2b03 op2b03 pp2b03 qp2b03 /*		 
*/ ap2c03 bp2c03 cp2c03 dp2c03 ep2c03 fp2c03 gp2c03 /* Nebenerwerb           
*/ hp2c03 ip2c03 jp2c03 kp2c03 lp2c03 mp2c03 np2c03 op2c03 pp2c03 qp2c03 /*		 
*/ ap2d03 bp2d03 cp2d03 dp2d03 ep2d03 fp2d03 gp2d03 /* Rente/Pension         
*/ hp2d03 ip2d03 jp2d03 kp2d03 lp2d03 mp2d03 np2d03 op2d03 pp2d03 qp2d03 /*		 
*/ ap2f03 bp2f03 cp2f03 dp2f03 ep2f03 fp2f03 gp2f03 /* Arbeitslosengeld      
*/ hp2f03 ip2f03 jp2f03 kp2f03 lp2f03 mp2f03 np2f03 op2f03 pp2f03 qp2f03 /*		 
*/ ap2g03 bp2g03 cp2g03 dp2g03 ep2g03 fp2g03 gp2g03 /* Arbeitslosenhilfe     
*/ hp2g03 ip2g03 jp2g03 kp2g03 lp2g03 mp2g03 np2g03 op2g03 pp2g03 qp2g03 /*		 
*/ ap2h03 bp2h03 cp2h03 dp2h03 ep2h03 fp2h03 gp2h03 /* Unterh. vom Arbeitsam 
*/ hp2h03 ip2h03 jp2h03 kp2h03 lp2h03 mp2h03 np2h03 op2h03 pp2h03 qp2h03 /*		 
*/ ap2k03 bp2k03 cp2k03 dp2k03 ep2k03 fp2k03 gp2k03 /* Mon. Baf"og, Stipendie
*/ hp2k03 ip2k03 jp2k03 kp2k03 lp2k03 mp2k03 np2k03 op2k03 pp2k03 qp2k03 /*
*/ using $soepdir,  /*
*/ files(pkal) waves(a b c d e f g h i j k l m n o p q)

* Nie erwerbstaetig
holrein ap09 aisco using $soepdir, files(p) waves(a) 

*  +----------------------------------------------------------------+
*  |                        Recoding                                |
*  +----------------------------------------------------------------+

* PI
* --

lab def pid 1 "Keine" 2 "SPD" 3 "CDU/CSU" 4 "FDP" 5 "B90/Gr" /*
*/ 6 "Andere P"

* Waves a - g
local i 1984
foreach piece in ap56 bp79 cp79 dp88 ep77 fp93 gp85 {
            gen pid`i' = 1 if `piece'01 == 2
            replace pid`i' = 2 if `piece'02==1
            replace pid`i' = 3 if `piece'02>=2 & `piece'02<=4
            replace pid`i' = 4 if `piece'02==5
            replace pid`i' = 5 if `piece'02==6
            replace pid`i' = 6 if `piece'02==7 | `piece'02==8
            lab var pid`i' "Parteiidentifikation"
            lab val pid`i' pid
            local i = `i' + 1
}
    

* Welle h
gen pid1991 = 1 if hp9001 == 2
replace pid1991 = 2 if hp9002==1
replace pid1991 = 3 if hp9002==2
replace pid1991 = 4 if hp9002==3
replace pid1991 = 5 if hp9002==4 | hp9002==5
replace pid1991 = 6 if hp9002>=6 & hp9002<=8
lab var pid1991 "Parteiidentifikation"
lab val pid1991 pid

* Waves i,j,
local i 1992
foreach piece in ip90 jp90 {
            gen pid`i' = 1 if `piece'01 == 2
            replace pid`i' = 2 if `piece'02==1
            replace pid`i' = 3 if `piece'02>=2 & `piece'02<=3
            replace pid`i' = 4 if `piece'02==4
            replace pid`i' = 5 if `piece'02==5 | `piece'02==6
            replace pid`i' = 6 if `piece'02==7 | `piece'02==8 | `piece'02==9
            lab var pid`i' "Parteiidentifikation"
            lab val pid`i' pid
            local i = `i' + 1
}

* Waves k, l, m, n
local i 1994
foreach piece in kp92 lp98 mp84 np94 {
            gen pid`i' = 1 if `piece'01 == 2
            replace pid`i' = 2 if `piece'02==1
            replace pid`i' = 3 if `piece'02>=2 & `piece'02<=3
            replace pid`i' = 4 if `piece'02==4
            replace pid`i' = 5 if `piece'02==5
            replace pid`i' = 6 if `piece'02>=6 & `piece'02<=8
            lab var pid`i' "Parteiidentifikation"
            lab val pid`i' pid
            local i = `i' + 1
}

* Wave o
gen pid1998 = 1 if op9701 == 2
replace pid1998 = 2 if op9702==1
replace pid1998 = 3 if op9702==2 | op9702==3 | op9702==13
replace pid1998 = 4 if op9702==4
replace pid1998 = 5 if op9702==5
replace pid1998 = 6 if op9702>=6 & op9702<=22
lab var pid1998 "Parteiidentifikation"
lab val pid1998 pid
                                  
* Waves p,q
local i 1999
foreach var of varlist pp111 qp116  {
	gen pid`i' = 1 if `var' == 2
	lab var pid`i' "Parteiidentifikation"
	lab val pid`i' pid
	local i = `i' + 1
}
local i 1999
foreach var of varlist pp11201 qp11701 {
	replace pid`i' = 2 if `var'==1
	replace pid`i' = 3 if `var'==2 | `var'==3 | `var'==13
	replace pid`i' = 4 if `var'==4
	replace pid`i' = 5 if `var'==5
	replace pid`i' = 6 if `var'>=6 & `var'<=23
	local i = `i' + 1
}

* Erwerbsstatus
* -------------

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

* Befragenstatus
* --------------

soepren ?netto, new(netto) w(1984/2000)

* Berufsbezogenens persoenliches Einkommen (-> Note 1)
* ---------------------------------------

local i 1984
foreach wave in a b c d e f g h i j k l m n o p q {
  gen ein`i' = 0 if netto`i' == 1 | netto`i' == 4
    quietly {
    
      * Pro Jahr
      foreach typ in a b c d f g h k {
        local month `wave'p2`typ'02
        local wage `wave'p2`typ'03
        replace `month' = . if `month'  <= 0
        replace `wage' = . if `wage' <= 0
        replace ein`i' = ein`i' + (`month' *  `wage') if `wage' ~= . /*
        */ & `month' ~= .
      }
    
      * Pro Monat
      replace ein`i' = ein`i'/12
      
      * Einkommen von 0: Missing
      replace ein`i' = . if ein`i' ==  0
    }
    lab var ein`i' "Berufsbez. pers. Bruttoeinkommen `i'"
    local i=`i'+1
}

* Fruehere berufliche Stellung 
* ----------------------------

* until 1993
local i 1984
foreach piece in ap16 bp24b cp24b dp22b ep22b fp20b gp23b hp25b ip25b jp25b {
quietly {
  gen bst`i' = .
  
  * Beamten
  replace bst`i'=40 if `piece'05==1 /* einfach */
  replace bst`i'=41 if `piece'05==2 /* mittel */
  replace bst`i'=42 if `piece'05==3 /* gehoben */
  replace bst`i'=43 if `piece'05==4 /* hoeher */

  * Angestellte
  if `i'< 1991 {
    replace bst`i'=50 if `piece'04==1 /* Ind. Werkmeister */
    replace bst`i'=51 if `piece'04==2 /* einfach */
    replace bst`i'=52 if `piece'04==3 /* qualif */
    replace bst`i'=53 if `piece'04==4 /* hochqualif */
    replace bst`i'=54 if `piece'04==5 /* fuehrung */
  }
  else if `i' >= 1991 {
    replace bst`i'=50 if `piece'04==1 /* Ind. Werkmeister */
    replace bst`i'=51 if `piece'04==2 | `piece'04==3 /* einf. */
    replace bst`i'=52 if `piece'04==4 /* qualif */
    replace bst`i'=53 if `piece'04==5 /* hochqualif */
    replace bst`i'=54 if `piece'04==6 /* fuehrung */
  }

  * Arbeiter
  replace bst`i'=60 if `piece'01==1 /* ungelernt */
  replace bst`i'=61 if `piece'01==2 /* angelernt */
  replace bst`i'=62 if `piece'01==3 /* Facharbeiter */
  replace bst`i'=63 if `piece'01==4 /* Vorarbeiter */
  replace bst`i'=64 if `piece'01==5 /* Meister */

  * Auszubildende
  replace bst`i'=70 if `piece'03==1 /* Azubi */
  replace bst`i'=70 if `piece'03==2 /* Praktikant */

  * Selbstaendige
  replace bst`i'= 10 if `piece'02==1 /* Landwirte */
  replace bst`i'= 15 if `piece'02==2 /* freie Berufe */
  replace bst`i'= 21 if `piece'02==3 /* Selb < 9 */
  replace bst`i'= 23 if `piece'02==4 /* Selb >= 10 */
  replace bst`i'= 30 if `piece'02==5 /* Mithelfend */
  note bst`i': SOEP-Name `piece'01-`piece'05
  drop `piece'01 `piece'02 `piece'03 `piece'04 `piece'05
  local i = `i'+1
}
}

* Frueherer Beruf
* ----------------

soepren aisco, new(isc) wave(1984)
replace isc1984 = . if est1984 >= 1 & est1984 <= 4
replace isc1984 = . if isc1984 < 0

* Isco, Goldthorpe
* ----------------

soepren goldth*, new(goldth) wave(1984/2000)
soepren isco*, new(isco) wave(1984/2000)


* Stellung im Haushalt
* --------------------

soepren ?stell, new(hst) w(1984/2000)

* Partnernummer
* ------------
soepren partnr*, new(part) w(1984/2000)  

* Interviewmonat
* -------------

gen apx = .
soepren  /*
*/ apx bpmonin cpmonin dpmonin epmonin fpmonin gpmonin hpmonin ipmonin jpmonin  /*
*/ kpmonin lpmonin mpmonin npmonin opmonin ppmonin qpmonin, new(monin) w(1984/2000) 

* Politisches Interesse
* --------------------

gen apx = .
soepren /*
*/ apx bp75 cp75 dp84 ep73 fp89 gp83 hp89 ip89 jp89  kp91 lp97 mp83 np93  /*
*/ op96 pp110 qp115, new(polin) w(1984/2000)

* Allgemeinbildender Schulabschluss
* --------------------------------
  
gen apx = .
soepren /*
*/ apx bp5401 cp5401 dp5401 ep4901 fp6701 gp6701 hp6301 ip6301 jp7301 kp7301  /*
*/ lp7901 mp6001 np6001 op5101 pp6801 qp6802, new(aschulab) w(1984/2000)     

* Hochschulabschluss
* ------------------

gen apx = .
soepren /*
*/ apx bp5402 cp5402 dp5402 ep4902 fp6702 gp6702 hp6302 ip6302 jp7302 kp7302  /*
*/ lp7902 mp6002 np6002 op5102 pp6802 qp6803, new(hschulab) w(1984/2000) 

* Berufsausbildungsabschluss
* --------------------------

gen apx = .
soepren  /*
*/ apx bp5406 cp5406 dp5406 ep4906 fp6705 gp6705 hp6305 ip6306 jp7306 kp7306  /*
*/ lp7906 mp6006 np6006 op5106 pp6806 qp6807, new(bschulab) w(1984/2000)

* Beginn Erwerbsleben, Version 1
* ------------------------------

gen apx = .
soepren  /*
*/ apx bp22g09 cp22g09 dp20g09 ep20g01 fp18g01 gp21g01 hp23g01 ip23g01 jp23g01  /*
*/ kp3801 lp3001 mp2801 np2201 op2201 pp2201 qp2101, new(bstart1) w(1984/2000)  

* Beginn Erwerbsleben, Version 2
* ------------------------------

gen apx = .
soepren  /*
*/ apx  bp22g10 cp22g10 dp20g10 ep20g02 fp18g02 gp21g02 hp23g02 ip23g02 jp23g02  /*
*/ kp39 lp31 mp29 np23 op23 pp23 qp22, new(bstart2) w(1984/2000)     


* Familienstand
* -------------

soepren  /*
*/ afamstd bfamstd cfamstd dfamstd efamstd ffamstd gfamstd hfamstd  /*
*/ ifamstd jfamstd kfamstd lfamstd mfamstd nfamstd ofamstd pfamstd  /*
*/ qfamstd,  new(fam) w(1984/2000)

* Haushaltsnummer
* ---------------

soepren ?hhnr, new(hnr) w(1984/2000)


*  +----------------------------------------------------------------+
*  |                    Reshape + xtdata                            |
*  +----------------------------------------------------------------+

keep if qsampreg == 1

keep persnr sex gebjahr hst* hnr* pid* bst* isc*  /*
*/ goldth* ein* est* polin* fam* aschulab* bschulab* hschulab*  /*
*/ bstart1* bstart2* netto* part* monin*
  
reshape long /*
*/ hst hnr pid bst isc isco goldth ein est polin fam aschulab bschulab  /*
*/ hschulab bstart1 bstart2 netto part monin, /*
*/ i(persnr) j(welle)

sort persnr welle

* Mindestens drei Teilnahmen!
by persnr (welle): gen byte bef = 1 if netto == 1
by persnr (welle): replace bef = sum(bef)
by persnr (welle): replace bef = bef[_N]
drop if bef < 3

* +------------------------------+
* |Fortschreibung frueherer Beruf|
* +------------------------------+

sort persnr welle
by persnr (welle): replace bst=bst[_n-1] if est >= 5 & est<= 7  & _n~=1
by persnr (welle): replace isc=isc[_n-1] if est >= 5 & est<= 7  & _n~=1


* +-----------+
* |EGP-Klassen|
* +-----------+

* Zuweisung durch EGP-Master-File
* -------------------------------

* cregp gelaufen?, wenn nein dann jetzt!

capture d using egp  
if _rc~= 0 {
	preserve
	do cregp
	restore
}

* Merge zu jeder ISC-Bst Kombination die Klasse aus dem 
* EGP-Master zu

mmerge bst isc using egp, type(n:1) missing(value)  /*
*/ unmatched(master) 
drop _merge

* Verwendung der SOEP-Orignalvariablen wo moeglich
* -------------------------------------------------

replace egp = goldth if goldth >= 0 & goldth ~= .


* Einordnung ueber den Hauptverdiener/Haushaltsvorsitzender
* ---------------------------------------------------------

gen hstmir = 99-hst
sort welle hnr ein hstmir persnr
by welle hnr: gen egph = egp[_N] if ein[_N] ~= .

sort welle hnr hst persnr
by welle hnr: replace egph = egp[1]  /*
*/ if egph == . & hst[1] >= 0 & hst[1] <= 2

* Beruf = aktueller Beruf oder frueherer Beruf
replace isco = isc if isco <= 0 

* Hauptverdiener-Beruf
sort welle hnr ein hstmir persnr
by welle hnr: gen isch = isco[_N] if ein[_N] ~= .

sort welle hnr welle hst persnr
by welle hnr: replace isch = isco[1]  /*
*/ if isch == . & hst[1] >= 0 & hst[1] <= 2
drop ein

* Mueller - EGP
* -------------
* (Quelle: http://www.uni-koeln.de/kzfss/ks-mueta.htm)

* Administrative Dienstklasse (ISCO 1 und 2; 121-129; 201-999)
gen megph = 1 if (egph == 1 | egph == 2) &  /*
*/ ((isch==1 | isch==2) | (isch>=121 & isch<=129) | (isch>=201 & isch<=999))

* Experten (ISCO 11-54; 81-110)
replace  megph = 2 if (egph == 1 | egph == 2) &   /*
*/ ((isch>=11 & isch<=54) | (isch>=81 & isch<=110))

* Soziale Dienstleistungen  (ISCO 61-79; 131-199) 
replace  megph = 3 if (egph == 1 | egph == 2) &   /*
*/ ((isch>=61 & isch<=79) | (isch>=131 & isch<=199))

* Rest
replace megph = egph + 1 if egph > 2 & egph ~= .  

* Beschriftung
lab var megph "Mueller-EGP (Hauptverdiener)"
lab val megph megp 
lab def megp 1 "Admin. D." 2 "Experten" 3 "Soz. D."  4 "Non-man"  /*
*/  5 "gr.Selb." 6 "kl.Selb."  7 "selb.Lw." 8 "Vorarb."  /*
*/  9 "Facharb." 10 "Un/Angel" 11 "Landarb"  12 "Heimber"
drop egp egph


* Veränderung der Originaldaten
* -----------------------------

replace part = 55101 if part == 55103 & persnr == 55102
replace part = 103501 if part == 103503 & persnr == 103502
replace part = 731804 if part == 713804 & persnr == 595303
replace part = 5007301 if persnr == 5007302 & part == 5007201
replace part = . if persnr == 5101203 & part == 5101201
replace part = . if persnr == 5187703 & part == 5187701
replace part = . if persnr == 5188103 & part == 5188101

* +--------------------------------------------------------+
* | Indicators for Social Structural Events                |
* +--------------------------------------------------------+

* Gliederung:
* 	Klassenereignisse
*	Aging-Conservatism
*	Interaktionstheorie

sort persnr welle

* +---------+
* | Klassen |
* +---------+

* Selbstaendig Werden
* -------------------

* Admin. D.  -> Selbstaendig
by persnr (welle): gen byte eadmsel = 1  /*
*/ if (megph >= 5 & megph <= 7)  /*
*/ & megph[_n-1] == 1
by persnr (welle): replace eadmsel = . if _n==1
by persnr (welle): replace eadmsel = sum(eadmsel) if _n > 1
lab var eadmsel "Adm. D -> Selb."

* Micht. -> Selbstaendig
by persnr (welle): gen byte emissel = 1  /*
*/ if (megph >= 5 & megph <= 7)  /*
*/ & (megph[_n-1] ==2 | megph[_n-1] ==4 | megph[_n-1] ==8 | megph[_n-1] ==12)
by persnr (welle): replace emissel = . if _n==1
by persnr (welle): replace emissel = sum(emissel) if _n > 1
lab var emissel "Mischt. -> Selb."

* Arbeiter -> Selbstaendig
by persnr (welle): gen byte earbsel = 1  /*
*/ if (megph >= 5 & megph <= 7)  /*
*/ & (megph[_n-1] == 3 | (megph[_n-1] >= 9 & megph[_n-1] <= 11))
by persnr (welle): replace earbsel = . if _n==1
by persnr (welle): replace earbsel = sum(earbsel) if _n > 1
lab var earbsel "Arb. -> Selb."

* Administrative Dienste Werden
* -----------------------------

* Selbstaendig  -> Admin. D. 
by persnr (welle): gen byte eseladm = 1  /*
*/ if megph == 1 /*
*/ & (megph[_n-1] >= 5 & megph[_n-1] <= 7)
by persnr (welle): replace eseladm = . if _n==1
by persnr (welle): replace eseladm = sum(eseladm) if _n > 1
lab var eseladm "Adm. D -> Admin. D."

* Micht. -> Admin. D.
by persnr (welle): gen byte emisadm = 1  /*
*/ if megph == 1  /*
*/ & (megph[_n-1] ==2 | megph[_n-1] ==4 | megph[_n-1] ==8 | megph[_n-1] ==12)
by persnr (welle): replace emisadm = . if _n==1
by persnr (welle): replace emisadm = sum(emisadm) if _n > 1
lab var emisadm "Mischt. -> Admin. D."

* Arbeiter -> Admin. D.
by persnr (welle): gen byte earbadm = 1  /*
*/ if megph == 1  /*
*/ & (megph[_n-1] == 3 | (megph[_n-1] >= 9 & megph[_n-1] <= 11))
by persnr (welle): replace earbadm = . if _n==1
by persnr (welle): replace earbadm = sum(earbadm) if _n > 1
lab var earbadm "Arb. -> Admin. D."


* Mischtyp Werden
* ---------------

* Selbstaendig  -> Mischtyp 
by persnr (welle): gen byte eselmis = 1  /*
*/ if (megph == 2 | megph == 4 | megph == 8 | megph == 12) /*
*/ & (megph[_n-1] >= 5 & megph[_n-1] <= 7)
by persnr (welle): replace eselmis = . if _n==1
by persnr (welle): replace eselmis = sum(eselmis) if _n > 1
lab var eselmis "Mis. D -> Mischtyp"

* Admin D. -> Mischtyp
by persnr (welle): gen byte eadmmis = 1  /*
*/ if (megph == 2 | megph == 4 | megph == 8 | megph == 12)  /*
*/ & megph[_n-1] == 1
by persnr (welle): replace eadmmis = . if _n==1
by persnr (welle): replace eadmmis = sum(eadmmis) if _n > 1
lab var eadmmis "Admin D. -> Mischtyp"

* Arbeiter -> Mischtyp
by persnr (welle): gen byte earbmis = 1  /*
*/ if (megph == 2 | megph == 4 | megph == 8 | megph == 12)  /*
*/ & (megph[_n-1] == 3 | (megph[_n-1] >= 9 & megph[_n-1] <= 11))
by persnr (welle): replace earbmis = . if _n==1
by persnr (welle): replace earbmis = sum(earbmis) if _n > 1
lab var earbmis "Arb. -> Mischtyp"

* Arbeiter Werden
* ----------------

* Selbstaendig  -> Arb. 
by persnr (welle): gen byte eselarb = 1  /*
*/ if (megph == 3 | (megph >= 9 & megph <= 11))  /*
*/ & (megph[_n-1] >= 5 & megph[_n-1] <= 7)
by persnr (welle): replace eselarb = . if _n==1
by persnr (welle): replace eselarb = sum(eselarb) if _n > 1
lab var eselarb "Arb. D -> Arb."

* Admin D. -> Arb.
by persnr (welle): gen byte eadmarb = 1  /*
*/ if (megph == 3 | (megph >= 9 & megph <= 11))   /*
*/ & megph[_n-1] == 1
by persnr (welle): replace eadmarb = . if _n==1
by persnr (welle): replace eadmarb = sum(eadmarb) if _n > 1
lab var eadmarb "Admin D. -> Arb."

* Mischtyp -> Arb.
by persnr (welle): gen byte emisarb = 1  /*
*/ if (megph == 3 | (megph >= 9 & megph <= 11))   /*
*/ & (megph[_n-1] ==2 | megph[_n-1] ==4 | megph[_n-1] ==8 | megph[_n-1] ==12)
by persnr (welle): replace emisarb = . if _n==1
by persnr (welle): replace emisarb = sum(emisarb) if _n > 1
lab var emisarb "Arb. -> Arb."

* +------------------+
* | Arbeitslosigkeit |
* +------------------+


* +--------------------+
* | Aging-Conservatism |
* +--------------------+

* Ende Schulausbildung
* --------------------

gen byte easchul = 1  /*
*/ if aschulab >= 1 & aschulab <= 5 
by persnr (welle): replace easchul = sum(easchul) if _n > 1
lab var easchul "Schulausbildung abgeschlossen" 

* Ende Hochschulausbildung
* ------------------------

gen byte ehschul = 1  /*
*/ if hschulab >= 1 & hschulab <= 2
by persnr (welle): replace ehschul = sum(ehschul) if _n > 1
lab var ehschul "Hochschulausbildung abgeschlossen"

* Ende Berufsausbildung
* ---------------------

gen byte ebschul = 1 if  /*
*/ bschulab >= 1 & bschulab <= 7
by persnr (welle): replace ebschul = sum(ebschul) if _n > 1
lab var ebschul "Berufsausbildung abgeschlossen"

* Aufnahme eigener Erwerbstaetigkeit
* ----------------------------------

gen byte ebstart = 1  /*
*/ if ((bstart1 >= monin[_n-1] & bstart1 ~= .)  /*
*/ | (bstart2 <= monin & bstart2 ~= . & bstart2 > 0))  /*
*/ & welle <= 93 & monin > 0 & monin ~= .
replace ebstart = 1 if bstart2 == 1 & welle >= 94
by persnr (welle): replace ebstart = . if _n==1
by persnr (welle): replace ebstart = sum(ebstart) if _n > 1
lab var ebstart "Start in Berufslaben"

* Erste Hochzeit?
* ---------------

by persnr (welle): gen byte ehoch1 = 1 /*
*/ if fam == 1 & fam[_n-1]==3
by persnr (welle): replace ehoch1 = . if _n==1
by persnr (welle): replace ehoch1 = sum(ehoch1) if _n > 1
lab var ehoch1 "Erste Hochzeit"

capture assert ehoch1 <= 1
if _rc ~= 0 {
	* assertion is false
	* Eine Reihe von Personen haben haben mehr als einen
	* Ubergang von Ledig zu Verh. Die Hochzeiten dieser
    * Personen werden hier ignoriert. 
}


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
by persnr (welle): gen byte ekind1 = 1 /*
*/ if kidgeb01 == welle - 1
by persnr (welle): replace ekind1 = sum(ekind1) if _n > 1
assert ekind1 <= 1 | ekind1 == .
lab var ekind1 "Geburt erstes Kind?"

* Geburt weiterer Kinder
* ---------------------

gen byte ekind2 = 1 /*
*/ if (kidgeb02  == welle - 1) /*
*/  | (kidgeb03  == welle - 1) /*
*/  | (kidgeb04  == welle - 1) /*
*/  | (kidgeb05  == welle - 1) /*
*/  | (kidgeb06  == welle - 1) /*
*/  | (kidgeb07  == welle - 1) /*
*/  | (kidgeb08  == welle - 1) /*
*/  | (kidgeb09  == welle - 1) /*
*/  | (kidgeb10  == welle - 1) /*
*/  | (kidgeb11  == welle - 1) /*
*/  | (kidgeb12  == welle - 1) /*
*/  | (kidgeb13  == welle - 1) /*
*/  | (kidgeb14  == welle - 1) /*
*/  | (kidgeb15  == welle - 1)
by persnr (welle): replace ekind2 = sum(ekind2) if _n > 1
lab var ekind2 "Geburt weiterer Kinder?"
drop kidgeb*

* Zuweisung zum Lebenspartner
save 11, replace
keep part welle ekind1 ekind2
ren part persnr
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
keep pid polin part welle
ren part persnr
ren pid parpid
ren polin parpint
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
by persnr (welle): gen byte eparspd = 1  /*
*/ if inlist(parpid,2) & inlist(pid,2) ~= 1  /*
*/ & part ~= part[_n-1]  & part ~= . & part  > 0 
by persnr (welle): replace eparspd = . if _n==1
by persnr (welle): replace eparspd = sum(eparspd) if _n > 1
lab var eparspd "New Left Partner"

* Neuer Partner CDU, selbst nicht CDU
by persnr (welle): gen byte eparkons = 1  /*
*/ if inlist(parpid,3) & inlist(pid,3) ~= 1 /*
*/ & part ~= part[_n-1]  & part ~= . & part  > 0 
by persnr (welle): replace eparkons = . if _n==1
by persnr (welle): replace eparkons = sum(eparkons) if _n > 1
lab var eparkons "New Conservative Partner"

*  +-------------------------------------------------+
*  |                   Weights & friends             |
*  +-------------------------------------------------+
iis persnr
tis welle

sort persnr
merge persnr using weights 
drop if _merge==2
drop _merge
compress

sort persnr welle
by persnr (welle): drop if _n == 1

drop est
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

Note 1
------

Berufsbezogenes pers"onliches Bruttoeinkommen

Das berufsbezogene pers"onliche Bruttoeinkommen wird durch die Summe aller
Einkommensarten, die aus der aktuellen oder ehemaligen beruflichen Postion
resultieren, gem"a"s folgender Formel ermittelt:

\begin{equation}
\mbox{berufsbez. pers. Bruttoeink}
= \frac{1}{12} \sum_{i=1}^I \left(f_i * x_i\right)
\end{equation}

Dabei ist $ i $ eine von $ I $ Einkommensarten, die aus der berufliche
Position resultieren, $ f $ sind die Anzahl der Monate, in der eine
Einkommensart bezogen wurde und $ x $ der vom Befragen gesch"atzte
durchschnittliche Betrag dieser Einkommensart f"ur den angegebenen Zeitraum.
Verwendet werden Einkommen des abgelaufenen Kalenderjahrs.

Folgende Einkommensarten wurden als "`aus der beruflichen Position
resultierent"' angesehen:

\begin{enumerate}
\item Lohn oder Gehalt als Arbeitnehmer (einschl. Ausbildungsverg"utung und
  Vorruhestandsbez"uge)
\item Einkommen aus selbst"andiger oder freiberuflicher T"atigkeit
\item Einkommen aus Nebenerwerbst"atigkeit, Nebenverdienste
\item Altersrente oder -pension, Invalidenrente und Betriebsrente aufgrund
  eigener Erwerbst"atigkeit
\item Arbeitslosengeld
\item Arbeitslosenhilfe
\item Unterhaltsgeld vom Arbeitsamt bei Fortbildung oder Umschulung
\item Baf"og, Stipendium oder Berufsausbildungsbeihilfe
\end{enumerate}

Als nicht aus der beruflichen Position resultierend galten Witwen- und
Waisenrenten, bzw.\ -pensionen sowie Zahlungen von Personen, die nicht im
Haushalt leben.

In einigen F"allen findet sich der Missing--Code -2 (trifft nicht zu) bei
der Angabe des Betrags einer Einkommensart, obwohl bei der Anzahl der Monate
eine g"ultige Angabe eingetragen wurde. Hier wurde stets der Anzahl der Monate
Vorrang einger"aumt, und der Missing--Code bei der Angabe des Betrags auf
-1 gesetzt.


Note 2
------


Angabe zur Konfession enthält Mehfachnennungen. Alle Beobachtungen mit
Mehrfachnennungen wurden auf die "Kategorie" Sonstiges
gesetzt. Sonstiges ist damit "Andere christliche, Nichtchristliche,
Mehrfachnennungen und keine Angabe".

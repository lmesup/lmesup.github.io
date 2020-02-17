* Master-File for EGP-Classes
* ---------------------------

* Please see the Notes at the end of the file!

* ATTENTION: This Do-File automatically installs 
* Stata-Ados from the Internet. Comment the section
* "Cool-Ados" if you want to install them by hand!

version 7.0
set more off
clear
set memory 30m



*+-----------+
*| COOL-ADOS |
*+-----------+

capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}

capture which soepren
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install soepren
}


* +--------+
* |Retrival|
* +--------+

* Occupational Status, Employment Status
* --------------------------------------

mkdat /*
*/ ap2801 bp3801 cp4601 dp3801 ep3801 fp3801 gp3701 hp4801 ip4801 /*
*/ jp4801 kp5101 lp4301 mp4101 np3501 op3501 pp3801 qp3601  /*
*/ ap2802 bp3802 cp4602 dp3802 ep3802 fp3802 gp3702 hp4802 ip4802  /*
*/ jp4802 kp5102 lp4302 mp4102 np3502 op3502 pp3802 qp3602  /*
*/ ap2803 bp3803 cp4603 dp3803 ep3803 fp3803 gp3703 hp4803 ip4803  /*
*/ jp4803 kp5103 lp4303 mp4103 np3503 op3503 pp3803 qp3603  /*
*/ ap2804 bp3804 cp4604 dp3804 ep3804 fp3804 gp3704 hp4804 ip4804  /*
*/ jp4804 kp5104 lp4304 mp4104 np3504 op3504 pp3804 qp3604    /*
*/ ap2805 bp3805 cp4605 dp3805 ep3805 fp3805 gp3705 hp4805 ip4805  /*
*/ jp4805 kp5105 lp4305 mp4105 np3505 op3505 pp3805 qp3605    /*
*/ ap08 bp16 cp16 dp12 ep12 fp10 gp12 hp15 ip15 jp15 kp25 lp21 /*
*/ mp15 np11 op09 pp10 qp10 /*
*/ using $soepdir, files(p) waves(a b c d e f g h i j k l m n o p q) /*
*/ netto(-3,-2,-1,0,1,2,3,4) 

* Beruf
* -----

holrein  /*
*/ isco84 isco85 isco86 isco87 isco88 isco89 isco90 isco91 isco92 /*
*/ isco93 isco94 isco95 isco96 isco97 isco98 isco99 isco00 /*
  */ using $soepdir, files(pgen) waves(a b c d e f g h i j k l m n o p q)

* EGP
* ---

holrein /*
*/ goldth84 goldth85 goldth86 goldth87 goldth88 goldth89 goldth90  /*
*/ goldth91 goldth92 goldth93 goldth94 goldth95 goldth96 goldth97  /*
*/ goldth98 goldth99 goldth00 /*
*/ using $soepdir, files(pgen) waves(a b c d e f g h i j k l m n o p q) 


*+-------------+
*|Rekodierungen|
*+-------------+

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

for varlist est*: lab val X est
lab def est 1 "Vollzeit" 2 "Teilzeit" 3 "Umschul." 4 "Unregelm" /*
         */  5 "arb.los" 6 "Wehrd." 7 "not erw."

* Berufliche Stellung (-> Note 1)
* -------------------

soepren ap2801 bp3801 cp4601 dp3801 ep3801 fp3801 gp3701 hp4801  /*
*/ ip4801 jp4801 kp5101 lp4301 mp4101 np3501 op3501 pp3801 qp3601,   /*
*/ new(arb) wave(1984/2000)

soepren ap2802 bp3802 cp4602 dp3802 ep3802 fp3802 gp3702 hp4802  /*
*/ ip4802 jp4802 kp5102 lp4302 mp4102 np3502 op3502 pp3802 qp3602,   /*
*/ new(sel) wave(1984/2000)

soepren ap2803 bp3803 cp4603 dp3803 ep3803 fp3803 gp3703 hp4803  /*
*/ ip4803 jp4803 kp5103 lp4303 mp4103 np3503 op3503 pp3803 qp3603,   /*
*/ new(azb) wave(1984/2000)

soepren ap2804 bp3804 cp4604 dp3804 ep3804 fp3804 gp3704 hp4804  /*
*/ ip4804 jp4804 kp5104 lp4304 mp4104 np3504 op3504 pp3804 qp3604,  /*
*/ new(ang) wave(1984/2000)

soepren ap2805 bp3805 cp4605 dp3805 ep3805 fp3805 gp3705 hp4805  /*
*/ ip4805 jp4805 kp5105 lp4305 mp4105 np3505 op3505 pp3805 qp3605,  /*
*/ new(bea) wave(1984/2000)

forvalues i=1984/2000 {
  gen bst`i'=.
  
  * Beamten
  replace bst`i'=40 if bea`i'==1 /* einfach */
  replace bst`i'=41 if bea`i'==2 /* mittel */
  replace bst`i'=42 if bea`i'==3 /* gehoben */
  replace bst`i'=43 if bea`i'==4 /* hoeher */
          
  * Angestellte
  if `i'< 91 {
    replace bst`i'=50 if ang`i'==1 /* Ind. Werkmeister */
    replace bst`i'=51 if ang`i'==2 /* einfach */
    replace bst`i'=52 if ang`i'==3 /* qualif */
    replace bst`i'=53 if ang`i'==4 /* hochqualif */
    replace bst`i'=54 if ang`i'==5 /* fuehrung */
  }
  else if `i' >= 91 {
    replace bst`i'=50 if ang`i'==1 /* Ind. Werkmeister */
    replace bst`i'=51 if ang`i'==2 | ang`i'==3  /* einf. */
    replace bst`i'=52 if ang`i'==4 /* qualif */
    replace bst`i'=53 if ang`i'==5 /* hochqualif */
    replace bst`i'=54 if ang`i'==6 /* fuehrung */
  }

  * Arbeiter
  replace bst`i'=60 if arb`i'==1 /* ungelernt */
  replace bst`i'=61 if arb`i'==2 /* angelernt */
  replace bst`i'=62 if arb`i'==3 /* Facharbeiter */
  replace bst`i'=63 if arb`i'==4 /* Vorarbeiter */
  replace bst`i'=64 if arb`i'==5 /* Meister */

  * Auszubildende
  replace bst`i'=70 if azb`i'==1 /* Azubi */
  replace bst`i'=70 if azb`i'==2 /* Praktikant */

  * Selbstaendige
  if `i'< 97 {
    replace bst`i'= 10 if sel`i'==1 /* Landwirte */
    replace bst`i'= 15 if sel`i'==2 /* freie Berufe */
    replace bst`i'= 21 if sel`i'==3 /* Selb < 9 */
    replace bst`i'= 23 if sel`i'==4 /* Selb >= 10 */
    replace bst`i'= 30 if sel`i'==5 /* Mithelfend */
  }
  else if `i' >= 97 {
    replace bst`i'= 10 if sel`i'==1 /* Landwirte */
    replace bst`i'= 15 if sel`i'==2 /* freie Berufe */
    replace bst`i'= 21  /*	
    */ if sel`i' == 3 | sel`i' == 4   /* Selb < 9 */
    replace bst`i'= 23 if sel`i'==5 /* Selb >= 10 */
    replace bst`i'= 30 if sel`i'==6 /* Mithelfend */
  }

  * Missings
  lab var bst`i' "Berufl. Stellung Befragter `i'"
  lab val bst`i' bst
  foreach var of varlist arb`i' sel`i' azb`i' bea`i' est`i' {
    local a: char `var'[note1]
    local a = substr("`a'",11,.)
    local note "`note' `a'"
  }
  note bst`i': SOEP-Namen `note'
  drop arb`i' sel`i' azb`i' ang`i' bea`i' est`i'
}

* Mehrfachnennungen sofern v. impliziten Entsch. der Reihenfolge abweichend
replace bst1994 = 51 if persnr ==  521802
replace bst1994 =  . if persnr ==  372101
replace bst1994 = 51 if persnr == 5074002
replace bst1994 =  . if persnr ==   363601
replace bst1994 =  . if persnr ==   442203
replace bst1994 = 51 if persnr ==  464302
replace bst1994 = 41 if persnr == 5035902
replace bst1994 = 51 if persnr == 5172602
replace bst1994 = 53 if persnr ==  518403
replace bst1994 =  . if persnr ==  138603
* Filter"fehler"
replace bst1988 =  . if persnr ==   36001
replace bst1988 =  . if persnr ==  283302
replace bst1988 =  . if persnr ==  391403
replace bst1988 =  . if persnr ==  452104
replace bst1996 =  . if persnr ==  153301
replace bst1996 =  . if persnr ==  420002

* EGP
* ---

soepren goldth*, new(egp) waves(1984/2000)
foreach var of varlist egp* {
  replace `var' = . if `var' <= 0
}


* ISC
* ---

soepren isco*, new(isc) waves(1984/2000)
foreach var of varlist isc* {
  replace `var' = . if `var' <= 0
}


* +-------+
* |Reshape|
* +-------+

keep persnr bst* isc* egp*
reshape long bst isc egp, i(persnr) j(welle)


* +---------------+
* |Konsistenzcheck|
* +---------------+

assert bst > 0
assert isc > 0
assert egp > 0

* Haben alle Bst-Isc-Muster dieselbe EGP-Klasse?

sort bst isc egp

* Anzahl Bst-Isc-Muster
by bst isc: gen pattern1 = _n==1
replace pattern1 = sum(pattern1)

* Anzahl Egp-Muster innerhalb Bst-Isc
by bst isc egp: gen pattern2 = _n==1
by bst isc (egp): replace pattern2 = sum(pattern2)

* Anzahl Egp-Musster innerhalb Bst-Isc sollte 1 sein!
capture assert pattern2==1


* +----------------+
* |Datenbereinigung|  (-> Note 2)
* +----------------+

if _rc ~= 0 {
  by bst isc egp: gen n=_N
  sort bst isc n
  by bst isc (n): keep if _n==_N
}

replace egp= . if egp <= 0


* +---------------+
* |Save EGP-Master|
* +---------------+

sort bst isc 
by bst isc: assert _N==1
keep bst isc egp
compress
save egp, replace

exit


-------------------------------------------------------------------------

Notes
-----

1) OCCUPATIONAL STATUS
----------------------

Die Vercodung der beruflichen Stellung im SOEP l"a"st Mehrfachangaben
prinzipiell zu.  Faktisch sind dieser aber nur in den Jahren 1984 und
1994 vorhanden. Diese beziehen sich in den meisten F"allen auf
Kombinationen von diversen berufl. Stellungen mit den unterschiedl.
Selbst"andigen--Kategorien. Hier wurde dem Selbst"andigen--Status stets
Vorrang einger"aumt. In den "ubrigen F"allen wurde zus"atzlich die
Information des ISCO-Codes eingeholt und gem"a"s der folgenden "Ubersicht
zugeordnet:

\begin{verbatim}
1984 (komplett nach Selbst"andigen-Regel):
 persnr  Arbeiter   Selbst.   Auszub.   Angest.    Beamte   ->     bst
 ------------------------------------------------------------------------
   9801      tnz   fr. Ber.       tnz  hqual.A.       tnz   ->    fr. Ber.
 104402      tnz   Mithelf.       tnz   qual.A.       tnz   ->    Mithelf.
 227301      tnz     Selb>9       tnz  F"uhrauf       tnz   ->     Selb> 9
 280601  Meister   Mithelf.       tnz       tnz       tnz   ->    Mithelf.
 280603  Meister    Selb<10       tnz       tnz       tnz   ->     Selb<10
 315801  Meister    Selb<10       tnz       tnz       tnz   ->     Selb<10
 344401      tnz    Selb<10       tnz  qual. A.       tnz   ->     Selb<10
 348603      tnz   Mithelf.       tnz  einf. A.       tnz   ->     Selb<10
 365301  Meister    Selb<10       tnz       tnz       tnz   ->    Mithelf.
 410101      tnz    Selb<10     Azubi       tnz       tnz   ->     Selb<10
 407001   ungel.   Landwirt       tnz       tnz       tnz   ->    Landwirt
 445901      tnz     Selb>9       tnz  hqual.A.       tnz   ->     Selb> 9
 452101   angel.   Landwirt       tnz       tnz       tnz   ->    Landwirt
 473301 Facharb.    Selb<10       tnz       tnz       tnz   ->     Selb<10
 479802      tnz   Mithelf.       tnz   qual.A.       tnz   ->    Mithelf.
 574701   ungel.     Landw.       tnz       tnz       tnz   ->      Landw.


1994 (Selbstaendigen--Regel)
 persnr  Arbeiter   Selbst.   Auszub.   Angest.    Beamte   ->      bst
 -------------------------------------------------------------------------
  28801   ungel.     Landw.     Azubi  hqual.A.       tnz   ->      Landw.
  33203      tnz    Selb<10       tnz  hqual.A.       tnz   ->     Selb<10
  34502 Facharb.    Selb<10       tnz       tnz  mitl. B.   ->     Selb<10
  75404   angel.   Mithelf.       tnz       tnz       tnz   ->    Mithelf.
  80603  Meister    Selb<10       tnz       tnz       tnz   ->     Selb<10
  94705      tnz    Selb<10       tnz  hqual.A.       tnz   ->     Selb<10
 106001      tnz    Selb<10       tnz  F"uhrauf       tnz   ->     Selb<10
 198403      tnz    Selb<10       tnz  F"uhrauf       tnz   ->     Selb<10
 336301 Facharb.   Mithelf.       tnz       tnz       tnz   ->    Mithelf.
 344202   angel.    Selb<10       tnz       tnz       tnz   ->     Selb<10
 608302   ungel.     Landw.       tnz       tnz       tnz   ->      Landw.
5107102   angel.   Mithelf.       tnz       tnz       tnz   ->
5124101 Facharb.    Selb<10       tnz       tnz       tnz   ->

1994 (+ ISCO):
 persnr  Arbeiter Auszub.   Angest.    Beamte  isco ->      bst
 --------------------------------------------------------------
 521802   ungel.      tnz  einf. A.       tnz   134  ->  einf. A.
 319101   angel.      tnz   qual.A.       tnz   551  ->    angel.
 355305   angel.      tnz  einf. A.       tnz   842  ->    angel.
 372101   angel.      tnz  einf. A.       tnz    -1  ->       -1
5074002   angel.      tnz  einf. A.       tnz   451  ->   einf.A.
5082404   angel.      tnz  einf. A.       tnz   842  ->    angel.
 363601 Facharb.      tnz   qual.A.       tnz   Unzu ->       -1
 442203 Facharb.      tnz  einf. A.       tnz   Unzu ->       -1
 464302 Facharb.      tnz  einf. A.       tnz   570  ->   einf.A.
5035902 Facharb.      tnz      tnz    mitl. B.  394  ->   mitl.B.
5082002 Facharb.      tnz  qual. A.       tnz   773  ->  Facharb.
5168301 Facharb.      tnz  qual. A.       tnz   922  ->  Facharb.
5172602 Facharb.      tnz  einf. A.       tnz   393  ->   einf.A.
#518403  Vorarb.      tnz  hqual.A.       tnz   421  ->  hqual.A.
5007902  Vorarb.      tnz  einf. A.       tnz   874  ->   Vorarb.
 142801  Vorarb.      tnz   qual.A.       tnz   951  ->   Vorarb.
 304103 Facharb.    Azubi  einf. A.       tnz   540  ->     Azubi
  10803      tnz    Azubi       tnz  mitl. B.   582  ->     Azubi
 165903      tnz    Azubi       tnz  mitl. B.   582  ->     Azubi
 811602      tnz    Azubi       tnz  mitl. B.   Unzu ->     Azubi
5202102      tnz    Azubi       tnz  Gehob.Di   310  ->     Azubi
 173803      tnz    Azubi  einf. A.       tnz   Unzu ->     Azubi
5403702      tnz    Azubi  einf. A.       tnz    -1  ->     Azubi
 527805      tnz    Azubi  qual. A.       tnz   Unzu ->     Azubi
5126702      tnz    Azubi  qual. A.       tnz   134  ->     Azubi
  2801      tnz      tnz   qual.A.      k.A.    75  ->   qual. A.
138603      tnz      tnz  F"uhrauf   h"oherB   Unzu ->         -1
\end{verbatim}

Sechsmal finden sich Angaben zum Beruf, obwohl die Personen nicht
erwerbst"atig waren. Diese Angaben wurden jeweils den Missing--Code $ -2 $
gesetzt:

\begin{verbatim}
          persnr  est88      bst1988      isco88
    261.   36001  not erw.   fr. Ber.   -2       -> bst1988= -2
   2506.  283302  not erw.   einf. A.   -2       -> bst1988= -2
  11207.  391403  not erw.    angel.    -2       -> bst1988= -2
  13032.  452104  not erw.    ungel.    -2       -> bst1988= -2

          persnr  est96      bst1996      isco96
   1272.  153301  not erw.   mitl. B.  Unzul"an  -> bst1996= -2
  12138.  420002  not erw.   hqual.A.   -2       -> bst1996= -2
\end{verbatim}

Ab dem Erhebungsjahr 1991 werden einfache Angestellte in einfache
Angestellte mit und ohne Ausbildungsabschlu"s untergliedert. Diese Katgorien
wurden zu einer Kategorie zusammengefa"st.


2) Datenbereinigung
-------------------

Das SOEP enth"alt an einigen Stellen inkonsistente Zuweisungen von
EGP-Klassen, d.h. Personen mit gleicher beruflicher Stellung und
gleichem Beruf wurden unterschiedliche EGP-Klassen zugewiesen. F"ur
den EGP-Master File wird jeweils diejenige EGP-Klasse verwendet,
welche am h"aufigsten zugewiesen wurde.




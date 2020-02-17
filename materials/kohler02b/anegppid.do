* Vergleich Zusammenhang PID EGP--Klassen in ALLBUS und SOEP 1990
version 6.0
clear
set memory 60m


* Retrival SOEP
* -------------

* "Parteiidentifikation 1990", SOEP
use persnr gp85* using $soepdir/gp, clear
sort persnr
save 11, replace

* Gewichte
use persnr gphrf using $soepdir/phrf
sort persnr
save 12, replace

* EGP
use persnr egpb iscb9 bstb9 using $soepdir/gpeigen, clear
sort persnr

* Merge SOEP
* ----------

merge persnr using 11
keep if _merge == 3
drop _merge
sort persnr
merge persnr using 12
keep if _merge == 3
drop _merge
erase 11.dta
erase 12.dta

* Bereinigung SOEP
* ----------------

* Weights
ren gphrf weights

* PID
gen pid=1 if gp8501==2
replace pid = 2 if gp8502==1
replace pid = 3 if gp8502>=2 & gp8502<=4
replace pid = 4 if gp8502==5
replace pid = 5 if gp8502==6
replace pid = 6 if gp8502==7 | gp8502==8
lab var pid "Parteiidentifikation"
lab val pid pid
lab def pid 1 "Keine" 2 "SPD" 3 "CDU/CSU" 4 "FDP" 5 "B90/Gr" /*
*/ 6 "Andere P"

* EGP
replace egpb=. if egpb<0

* BST, ISC
ren bstb bst
ren iscb isc

* DATA
gen data = 1

save 11, replace

* Retrival ALLBUS
* ---------------

use v2 v20 v21 v363 v844 v845 if v2==1990 /*
*/using $allbdir/allb8098, clear
drop v2

* Bereinigung ALLBUS
* ----------------

* weigths
gen weights = v844*v845 if v844<99

* PID
gen pid=1 if v20==2
replace pid = 2 if v21 == 2
replace pid = 3 if v21 == 1
replace pid = 4 if v21 == 3
replace pid = 5 if v21 == 6 | v21 == 7  /* B90/Gr u. Alternat. Liste */
replace pid = 6 if v21 == 4 | v21 == 5 | (v21>=8 & v21<=10)
lab var pid "Parteiidentifikation"
lab val pid pid
lab def pid 1 "Keine" 2 "SPD" 3 "CDU/CSU" 4 "FDP" 5 "B90/Gr" /*
*/ 6 "Andere P"

* EGP
ren v363 egpb90
replace egpb=. if egpb==0
replace egpb=. if egpb>=12  /* insb. Genossenschaftsbauern */

* DATA
gen data = 2

gen persnr=_n
sort persnr

* Append ALLBUS u. SOEP
* ---------------------

append using 11
lab val egpb egp

save 11, replace

* Gesamtzusammenhang: Cramers V Allbus und SOEP
* ---------------------------------------------
*(Gewichte für chi^2 nicht erlaubt)

* Ungewichtet mit PID==1
tab egpb pid if data==1, V row
tab egpb pid if data==2, V row

* Ungewichtet ohne PID==1
tab egpb pid if data==1 & pid~=1, V
tab egpb pid if data==2 & pid~=1, V

* Cramers V anwendung Allbus auf SOEP
* -----------------------------------
drop if data==2

* Zuspielen des ALLBUS--Klassenschemas
sort bst isc
merge bst isc using egppat2

* Festlegen der Analyseeinheiten
keep if _merge==3
drop if bst==21 & bst==23
drop if egpb < 0
drop if egpallb == 0 | egpallb >= 12
drop if bst==21 | bst==22

* Ungewichtet mit PID==1
tab egpb pid, V
tab egpallb pid, V

* Ungewichtet ohne PID==1
tab egpb pid if pid~=1, V
tab egpallb pid if pid~=1, V

* Graphik Zeilenprozente
* ----------------------

use 11, clear

gen n1 = 1 if data==1
gen n2 = 1 if data==2
replace weight=1 if data==2
collapse (sum) n1 n2 [iw=weight], by(egp pid)
drop if pid==. | egp==.

sort egp
by egp: gen Nsoep = sum(n1)
by egp: gen Nallb = sum(n2)
by egp: gen persoep = n1/Nsoep[_N]*100
by egp: gen perallb = n2/Nallb[_N]*100
drop n* N*
drop if egp==10  /* Landarbeiter geringe Fallzahl */
sort egp

reshape wide persoep perallb, i(egp) j(pid)
local xlabs "0,10,20,30,40,50,60"
local xscale "0,66"
local font "fontr(1125) fontc(500)"

* Grapik oben links:
hplot persoep1 perallb1, l(egp) flipt bor grid cstart(8000) `font' /*
*/ xscale(`xscale') xlab(`xlabs') saving(egppid1, replace) /*
*/ t2t("Keine Parteiidentif.") symbol(op)

* Grapik oben rechts
hplot persoep2 perallb2, blank flipt bor grid cstart(8000) `font' /*
*/ xscale(`xscale') xlab(`xlabs') saving(egppid2, replace)/*
*/ t2t("SPD") symbol(op)

* Grapik mitte links:
hplot persoep3 perallb3, l(egp) flipt bor grid cstart(8000) `font' /*
*/ xscale(`xscale') xlab(`xlabs') saving(egppid3, replace)/*
*/ t2t("CDU/CSU") symbol(op)

* Grapik mitte rechts
hplot persoep4 perallb4, blank flipt bor grid cstart(8000) `font' /*
*/ xscale(`xscale') xlab(`xlabs') saving(egppid4, replace)/*
*/ t2t("FDP") symbol(op)

* Grapik unten links:
hplot persoep5 perallb5, l(egp) flipt bor grid cstart(8000) `font' /*
*/ xscale(`xscale') xlab(`xlabs') saving(egppid5, replace)/*
*/ t2t("B90/Gr.") symbol(op)

* Grapik unten rechts
hplot persoep6 perallb6, blank flipt bor grid cstart(8000) `font' /*
*/ xscale(`xscale') xlab(`xlabs') saving(egppid6, replace)/*
*/ t2t("Andere") symbol(op)

exit

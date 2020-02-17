* Muster ISCO-BST-EGP fuer SOEP und ALLBUS
* Erstellt Datensätze egppat1 (für SOEP) und egppat2 (für Allbus)
version 5.0
clear
set memory 60m

* Muster im SOEP
* --------------

clear
#delimit ;
mkdat
 bstb84 bstb85 bstb86 bstb87 bstb88 bstb89 bstb90 bstb91 bstb92 bstb93
  bstb94 bstb95 bstb96 bstb97
 iscb84 iscb85 iscb86 iscb87 iscb88 iscb89 iscb90 iscb91 iscb92 iscb93
  iscb94 iscb95 iscb96 iscb97
 egpb84 egpb85 egpb86 egpb87 egpb88 egpb89 egpb90 egpb91 egpb92 egpb93
  egpb94 egpb95 egpb96 egpb97
using $soepdir, netto(-3,-2,-1,0,1,2,3,4,5) files(peigen)
waves(a b c d e f g h i j k l m n)    ;
#delimit cr
renpfix bstb bst
renpfix iscb isc
renpfix egpb egp
drop hhnr ahhnr-nnetto
reshape long bst isc egp, i(persnr) j(welle)
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _s1, replace

#delimit ;
mkdat
 bsth84 bsth85 bsth86 bsth87 bsth88 bsth89 bsth90 bsth91 bsth92 bsth93
  bsth94 bsth95 bsth96 bsth97
 isch84 isch85 isch86 isch87 isch88 isch89 isch90 isch91 isch92 isch93
  isch94 isch95 isch96 isch97
 egph84 egph85 egph86 egph87 egph88 egph89 egph90 egph91 egph92 egph93
  egph94 egph95 egph96 egph97
using $soepdir, netto(-3,-2,-1,0,1,2,3,4,5) files(peigen)
waves(a b c d e f g h i j k l m n)   ;
#delimit cr
renpfix bsth bst
renpfix isch isc
renpfix egph egp
drop hhnr ahhnr-nnetto
reshape long bst isc egp, i(persnr) j(welle)
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _s2, replace

#delimit ;
mkdat
 bstp84 bstp85 bstp86 bstp87 bstp88 bstp89 bstp90 bstp91 bstp92 bstp93
  bstp94 bstp95 bstp96 bstp97
 iscp84 iscp85 iscp86 iscp87 iscp88 iscp89 iscp90 iscp91 iscp92 iscp93
  iscp94 iscp95 iscp96 iscp97
 egpp84 egpp85 egpp86 egpp87 egpp88 egpp89 egpp90 egpp91 egpp92 egpp93
  egpp94 egpp95 egpp96 egpp97
using $soepdir, netto(-3,-2,-1,0,1,2,3,4,5) files(peigen)
waves(a b c d e f g h i j k l m n)  ;
#delimit cr
renpfix bstp bst
renpfix iscp isc
renpfix egpp egp
drop hhnr ahhnr-nnetto
reshape long bst isc egp, i(persnr) j(welle)
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _s3, replace

#delimit ;
mkdat
 bstt84 bstt85 bstt86 bstt87 bstt88 bstt89 bstt90 bstt91 bstt92 bstt93
  bstt94 bstt95 bstt96 bstt97
 isct84 isct85 isct86 isct87 isct88 isct89 isct90 isct91 isct92 isct93
  isct94 isct95 isct96 isct97
 egpt84 egpt85 egpt86 egpt87 egpt88 egpt89 egpt90 egpt91 egpt92 egpt93
  egpt94 egpt95 egpt96 egpt97
using $soepdir, netto(-3,-2,-1,0,1,2,3,4,5) files(peigen)
waves(a b c d e f g h i j k l m n) ;
#delimit cr
renpfix bstt bst
renpfix isct isc
renpfix egpt egp
drop hhnr ahhnr-nnetto
reshape long bst isc egp, i(persnr) j(welle)
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _s4, replace

use _s1, clear
merge bst isc using _s2
drop _merge
sort bst isc
merge bst isc using _s3
drop _merge
sort bst isc
merge bst isc using _s4
drop _merge
keep bst isc egp
sort bst isc
save egppat1, replace
erase _s1.dta
erase _s2.dta
erase _s3.dta
erase _s4.dta


* Muster im Allbus
* ----------------

* Lade bst, isc und egp (Befragter)
use v356 v357 v363 using $allbdir/allb8098, clear
gen bst = v356
gen isc = v357
gen egpallb = v363
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _a1, replace

* Lade bst, isc und egp (ehemaliger)
use v376 v377 v383 using $allbdir/allb8098, clear
gen bst = v376
gen isc = v377
gen egpallb = v383
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _a2, replace

* Lade bst, isc und egp (Pappi)
use v394 v367 v400 using $allbdir/allb8098, clear
gen bst = v394
gen isc = v367
gen egpallb = v400
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _a3, replace

* Lade bst, isc und egp (Einordung Terwey)
use v401 v402 v408 using $allbdir/allb8098, clear
gen bst = v401
gen isc = v402
gen egpallb = v408
sort bst isc
quietly by bst isc: gen n=_N
quietly by bst isc: keep if _n==1
save _a4, replace

use _a1, clear
merge bst isc using _a2
drop _merge
sort bst isc
merge bst isc using _a3
drop _merge
sort bst isc
merge bst isc using _a4
drop _merge
replace bst= 10 if bst>= 10 & bst<=13
replace bst= 15 if bst>= 15 & bst<=17
replace bst= 21 if bst==22
replace bst= 23 if bst==24
replace bst= 70 if bst>=70 & bst<=74
replace bst= -1 if bst==49 /* Wehr- Zivildienst */
replace bst= -1 if bst==65 /* Genossenschaftsbauer */
replace bst= -1 if bst < 10
replace bst= -1 if bst > 74
replace bst= -2 if bst == 0
replace isc= -2 if isc == 0
replace isc= -1 if isc >= 1000
keep bst isc egp
sort bst isc
save egppat2, replace
erase _a1.dta
erase _a2.dta
erase _a3.dta
erase _a4.dta

exit

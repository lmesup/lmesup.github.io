* Zusammenhangs zwischen gebildetem und erfragten Rechts--Links Schema
* Datenbasis: Politbarometer 1990 (West) ab Oktober
* (rl--Schema vorher nur mit 4 Kategorien erfaßt)
version 6.0
clear

* Daten laden
* -----------

use v3 v190 v191 v192 v279 v280 using $politdir/s1920 /*
*/if v3 >= 10

* Bildung des erfragten Rechts--Links--Schemas
* --------------------------------------------

gen rl = (5-v191) + 5/*
*/ if v191~=0 | v191~=9     /* v191 == linksorientierung */
replace rl = v192 /*
*/if v192~=9 & v192 ~= 0    /* v192 == rechtsorientierung */
replace rl = 5 if v191 == 0 & v192 == 0

* Kontrolle
tab rl v191, mis
tab rl v192, mis


* Rechts--Links--Schema aus PID
* -----------------------------

gen rl1 = (5-v280)+5 if v279==1 | v279==6 & v280~=0 & v280~=9
replace rl1 = v280 if v279>=2 & v279<=5 & v280~=0 & v280~=9
replace rl1=5 if v279==9  /* keine PID -> lr = mitte */

* Kontrolle
sort v279
by v279: tab rl1 v280, mis

* Analyse
* -------

corr rl1 rl
graph rl rl1, ba(10) c(m) jitter(5)

exit

* Grafik der 10 häufigsten Same Order Sequenzes, balanced Panel-Design
version 6.0
clear
set memory 60m

use persnr welle mark pid using stab1

* Balanced-Panel Design
* ---------------------
keep if mark
drop mark


* keep the PIDs in their Order
* ----------------------------

sort persnr welle
qby persnr: drop if pid == pid[_n-1]  & _n~=1
qby persnr: gen order = _n
drop welle

* reshape into wide
* -----------------

replace pid = 0 if pid == . 
reshape wide pid, i(persnr) j(order)


* Nicht-Stabile- Sequenzen 
* ------------------------

egen valid = rmiss(pid*)
replace valid = 14 - valid

hist valid, border ylab(0(.05).15) l1("Anteil") b2("Anzahl der Stadien")  /*
*/ saving(stab5a, replace)

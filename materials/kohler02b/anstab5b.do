* Same Order Sequenzen, balanced Panel-Design

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
qby persnr: drop if pid == pid[_n-1] & _n~=1
qby persnr: gen order = _n
drop welle

* reshape into wide
* -----------------

replace pid = 0 if pid == . 
reshape wide pid, i(persnr) j(order)

* How many different Parties
* --------------------------

egen valid = rmiss(pid*)
replace valid = 14 - valid
tab valid

* Distribution of Stable Parties
* ------------------------------

tab pid1 if valid==1

* Nicht-Stabile- Sequenzen 
* ------------------------

drop if valid == 1
local allpids "pid1 pid2 pid3 pid4 pid5 pid6 pid7 pid8 pid9 pid10"  
local allpids "`allpids' pid11 pid12 pid13 pid14"
sort `allpids'
quietly by `allpids': gen groups = 1 if _n == 1
replace groups = sum(groups)
quietly by `allpids': gen n = _N
quietly by `allpids': keep if _n == 1

* Die Häufigkeitsverteilung der Karrierenanzahl
tab n
gen nkat = recode(n,1,10,100,1000)
tab nkat

sort n
list `allpids' n in -10/-1


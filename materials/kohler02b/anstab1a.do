* Lag-1 Trans-Probabilities, mit Rekodierung der Angabe 
* keine Parteiidentifikation.

clear
set memory 60m
version 6.0

use stab1

gen pidorig = pid

sort persnr welle
* Rekodierung der Angabe "keine PID".
qby persnr:  /*
*/ replace pid = cond(uniform()>.5,pid[_n-1],pid[_n+2]) if /*
*/   pid[_n-1]~=1 & pid[_n-1]~=. & pid[_n+2]~=1 & pid[_n+2]~=. & pid==1 /*
*/ & pid[_n+1]==1

qby persnr:  /*
*/ replace pid = cond(uniform()>.5,pid[_n-1],pid[_n+1]) if /*
*/   pid[_n-1]~=1 & pid[_n-1]~=. & pid[_n+1]~=1 & pid[_n+1]~=. & pid==1


* 1) Transition-Probabilities, Lag1
* ---------------------------------
xttrans pid, fre /* unbalanced Panel Design */
xttrans pid if  pid >= 2 & pid <= 5, fre

xttrans pid if mark, fre /* balanced Panel Design */
xttrans pid if mark & pid>= 2 & pid <= 5, fre

* 2) Veräderung gegenüber Origialdaten
* ------------------------------------
sort persnr welle
qby persnr: gen pidorigl = pidorig[_n-1]
qby persnr: gen pidl = pid[_n-1]

tab pidorigl pidorig, matcell(O)
tab pidl pid, matcell(C)

drop _all
svmat O 
svmat C
for num 1/6: gen DX = CX/OX
for num 1/6: gen ODDX = .
local i 1
while `i' <= 6 {
	local j 1 
	while `j' <= 6 {
		replace ODD`j' = D`j'/D`i' in `i'
		local j = `j' + 1
	}
	local i = `i' + 1
}

mkmat ODD*, mat(ODD)
matrix list ODD, format(%4.2f)

exit


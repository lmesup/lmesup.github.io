* Lag-1 Trans-Probabilities, mit Rekodierung der Angabe 
* keine Parteiidentifikation, Gewichtet

clear
set memory 60m
version 6.0

use stab1

gen pidorig = pid

* Rekodierung der Angabe "keine PID".
* -----------------------------------
sort persnr
qby persnr:  /*
*/ replace pid = cond(uniform()>.5,pid[_n-1],pid[_n+2]) if /*
*/   pid[_n-1]~=1 & pid[_n-1]~=. & pid[_n+2]~=1 & pid[_n+2]~=. & pid==1 /*
*/ & pid[_n+1]==1

qby persnr:  /*
*/ replace pid = cond(uniform()>.5,pid[_n-1],pid[_n+1]) if /*
*/   pid[_n-1]~=1 & pid[_n-1]~=. & pid[_n+1]~=1 & pid[_n+1]~=. & pid==1

* Neue Tabelle
* ------------

qby persnr: gen pidl = pid[_n-1]
tab pidl pid [aw=uw], row matcell(C)
local N = r(N) - C[1,1]
local i 2 
while `i' <= 6 {
	local cell = C[`i',`i']
	local diag = `diag' + `cell'
	local i = `i' + 1
}
di `diag'/`N'


* Veränderung gegenüber Origialdaten
* ------------------------------------

sort persnr welle
qby persnr: gen pidorigl = pidorig[_n-1]

tab pidorigl pidorig [aw=uw], matcell(O)

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


* SS-Sequenzen-Typen der Ausgeschlossenen Befragten

clear
set memory 60m
version 6.0

use stab2b

* Klassifikation der Karrieren nach ueberhaupt genannten Parteien
* ---------------------------------------------------------------

* Keine PID-genannt?
gen kpid  = 0
local i 84
while `i' <= 97 {
	replace kpid = 1 if pid`i' == 1
	local i = `i' + 1 
}

* SPD genannt?
gen spd  = 0
local i 84
while `i' <= 97 {
	replace spd = 1 if pid`i' == 2
	local i = `i' + 1 
}

* CDU genannt?
gen cdu  = 0
local i 84
while `i' <= 97 {
	replace cdu = 1 if pid`i' == 3
	local i = `i' + 1 
}

* FDP genannt?
gen fdp  = 0
local i 84
while `i' <= 97 {
	replace fdp = 1 if pid`i' == 4
	local i = `i' + 1 
}

* Buendnis 90/Die Gruenen genannt?
gen b90  = 0
local i 84
while `i' <= 97 {
	replace b90 = 1 if pid`i' == 5
	local i = `i' + 1 
}


* Sonstige genannt?
gen sonst  = 0
local i 84
while `i' <= 97 {
	replace sonst = 1 if pid`i' == 6
	local i = `i' + 1 
}

* kA genannt?

gen kA  = 0
local i 84
while `i' <= 97 {
	replace kA = 1 if pid`i' == .
	local i = `i' + 1 
}


* SS-Sequenzen
* ------------

* Anzahl der SS-Sequenzen
local allpids "b90 spd kpid kA cdu fdp sonst"  
sort `allpids'
qby `allpids': gen n = _N
qby `allpids': keep if _n==1

* Typologie

gen typ = 0
replace typ = 1 if spd & cdu == 0 & b90 == 0 & fdp == 0 & sonst == 0
replace typ = 2 if cdu & b90 == 0 & fdp == 0 & spd == 0 & sonst == 0
replace typ = 3 if b90 & fdp == 0 & spd == 0 & cdu == 0 & sonst == 0
replace typ = 4 if fdp & spd == 0 & cdu == 0 & b90 == 0 & sonst == 0
replace typ = 4.5 if sonst &  spd == 0 & cdu == 0 & b90 == 0 & fdp == 0
replace typ = 5 if spd & b90 & cdu == 0 & fdp == 0 & sonst == 0
replace typ = 6 if cdu & fdp & spd == 0 & b90 == 0 & sonst == 0
replace typ = 7 if ((cdu & spd) | (cdu & b90) | (fdp & spd) | (fdp & b90)) /*
*/  & sonst == 0
replace typ = 7.5 if sonst == 1 & typ ~= 4.5
replace typ = 8 if kpid & spd == 0 & cdu == 0 & b90 == 0 & fdp == 0 & sonst == 0
assert typ ~= 0

tab typ kpid [fw=n], row col

keep if kA==1 | sonst==1

tab typ kA [fw=n], row col

gen N = sum(n)
di N[_N]


keep if kA | sonst


exit



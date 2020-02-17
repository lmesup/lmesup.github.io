* Welche SS-Sequenzen kommen nicht vor?

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

* k.A. genannt?
gen kA  = 0
local i 84
while `i' <= 97 {
	replace kA = 1 if pid`i' == .
	local i = `i' + 1 
}


* SS-Sequenzen
* ------------

* Anzahl der SS-Sequenzen
local allpids "b90 spd kpid cdu fdp"  /* SS-Sequences collapsed over k.A. */
sort `allpids'
qby `allpids': gen n = _N

* Liste aller Karrieren
qby `allpids': keep if _n == 1
keep `allpids' n 
sort n
fillin `allpids'
list `allpids' n if _fillin

exit

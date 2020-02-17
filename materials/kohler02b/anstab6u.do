* Work in Progress

clear
set memory 60m
version 6.0

use stab2u

local allpids "pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93"
local allpids "`allpids' pid94 pid95 pid96 pid97"
sort `allpids'
quietly by `allpids': gen groups = 1 if _n == 1
replace groups = sum(groups)
quietly by `allpids': gen n = _N
quietly by `allpids': keep if _n == 1

sort n


* 5) Klassifikation der Karrieren nach ueberhaupt genannten Parteien
* ------------------------------------------------------------------

* Buendnis 90/Die Gruenen genannt?
gen b90  = 0
local i 84
while `i' <= 97 {
	replace b90 = 1 if pid`i' == 5
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

* Karrieremuster
local allpids "b90 spd cdu fdp"
sort `allpids'
quietly by `allpids': gen pattern = 1 if _n == 1
replace pattern = sum(pattern)

* Anzahl der Karrieren
quietly by `allpids': gen count = sum(n)
quietly by `allpids': replace count = count[_N]

* Liste aller Karrieren
quietly by `allpids': keep if _n == 1
keep `allpids' count pattern
sort count
list b90 spd cdu fdp count

* Control
gen N = sum(count)
di N[_N]


exit



* PID-Karrieren, Unbalanced Panel-Design (2 Teilnahmen)


clear
set memory 60m
version 6.0

use stab2u

* Fallzahl
* --------

count

* Sequenzen
* ---------

* Generate Sequences
local allpids "pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93"  
local allpids "`allpids' pid94 pid95 pid96 pid97"
sort `allpids'
quietly by `allpids': gen groups = 1 if _n == 1
replace groups = sum(groups)
quietly by `allpids': gen n = _N
quietly by `allpids': keep if _n == 1

* Distribution of Sequence-Frequencies
tab n
gen nkat = recode(n,1,10,100,1000)
tab nkat

sort n
list `allpids' n in -10/-1


exit



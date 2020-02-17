* Struktur der Parteipräferenzen in Simulation (Mittelwerte)


version 7.0
clear
set memory 20m

* 0) Cool-Ados
* -------------

* hplot.ado, horizontally labeled plots (N. Cox)
capture which hplot
if _rc ~= 0 {
	ssc inst hplot
}

* 1) Prepare
* ----------

use simul, clear

collapse  /*
*/ (mean) kons=kons left=left  /*
*/ (min) lkons=kons lleft=left  /*
*/ (max) ukons=kons uleft=left,  by(egp) 

* common options 
local opt "flipt bor xscale(-.02,1.02) line range format(%2.1f) xlab(0(.2)1) s(|o|)"
local opt "`opt' cstart(10000) l(egp) pen(222) gllj glpos(0) ttick "

* 2) Graph
* --------

hplot lkons kons ukons, /*
*/ `opt' title(Conservatives) t2(" ") /*
*/ saving(grsimul1_01, replace)

hplot lleft left uleft, /*
*/ `opt' title(Lefties) t2(" ") /*
*/ saving(grsimul1_02, replace)

exit


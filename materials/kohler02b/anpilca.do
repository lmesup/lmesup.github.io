* LCA der Parteipräferenz

version 6.0
clear
set memory 60m

* 0) Cool-Ados
* -------------

* 1) Retrival
* -----------

use $politdir/s2275  /* Politbarometer 1992 */

* 2) Rekodierungen
* ----------------

* Wahlabsicht
gen ppw = v11 if v11 > 0 & v11 <= 4
lab var ppw Wahlabsicht
lab val ppw v11

* Recall-Frage
gen ppr = v12 if v12 > 0 & v12 <= 4
lab var ppr "Recall-Frage"
lab val ppr v12

* Sympathie-Skalometer
gen pps = 1 if v20 > v22 & v20 > v23 & v20 > v19
replace pps = 1 if v21 > v22 & v21 > v23 & v21 > v19
replace pps = 2 if v19 > v20 & v19 > v21 & v19 > v22 & v19 > v23
replace pps = 3 if v22 > v20 & v22 > v21 & v22 > v19 & v22 > v23
replace pps = 4 if v23 > v20 & v23 > v21 & v23 > v19 & v23 > v22
lab var pps "relationaler Sympathieskalometer"
lab val pps v11

* Parteiidentifikation
gen ppi = 1 if v345 >=2 & v345 <= 4
replace ppi = 2 if v345 ==1 
replace ppi = 3 if v345 ==5 
replace ppi = 4 if v345 ==6
lab var ppi "Parteiidentifikation"
lab val ppi v11

* 3) Listwise Deletion

keep if ppi~=. & pps ~= . & ppr ~= . & ppw ~= .

keep ppw ppi ppr pps
contract ppw ppi ppr pps , freq(n)
fillin ppw ppi ppr pps
replace n = 0 if n==.
keep n
outfile using anpilca.raw, replace





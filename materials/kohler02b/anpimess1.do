* Constant-Inbreeding Modell

version 6.0
clear
set memory 60m

* 0) Cool-Ados
* -------------

capture which desmat
if _rc ~= 0 {
	net stb-54
	net install dm73_1
}

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

* Parteiidentifikation
gen ppi = 1 if v345 >=2 & v345 <= 4
replace ppi = 2 if v345 ==1
replace ppi = 3 if v345 ==5 
replace ppi = 4 if v345 ==6
lab var ppi "Parteiidentifikation"
lab val ppi v11

* 3) Listwise Deletion

mark touse if ppi~=. & ppr ~= . &  ppw ~= .
keep if touse

gen n= 1
collapse (sum) n, by(ppw ppi ppr )
fillin ppw ppi ppr  
replace n = .05 if _fillin==1



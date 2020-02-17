* Vergleich der  Messungen der Parteipräferenz

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

mark touse if ppi~=. & pps ~= . & ppr ~= . & ppw ~= .


* 3) Anteil stabiler Parteipraeferenz

* Count listwise valid
count if touse
local lv = r(N)

* Count pairwise valid
count if ppw ~= .
local ww = r(N)
count if ppw ~= . & ppi ~= .
local wi = r(N)
count if ppw ~= . & pps ~= .
local ws = r(N)
count if ppw ~= . & ppr ~= .
local wr = r(N)

count if ppi ~= . 
local ii = r(N)
count if ppi ~= . & pps ~= .
local is = r(N)
count if ppi ~= . & ppr ~= .
local ir = r(N)

count if pps ~= . 
local ss = r(N)
count if pps ~= . & ppr ~= .
local sr = r(N)

count if ppr ~= . 
local rr = r(N)

* Count Stabils
* Output in Matrix V
* links pairwise, rechts listwise deletion

* 1. Spalte
count if ppw == ppw & ppw ~= .
matrix V1 = r(N)/`ww'

count if ppw == ppi & ppw~= . & ppi ~= .
matrix V1 = V1 \ r(N)/`wi'

count if ppw == pps & ppw~= . & pps ~= .
matrix V1 = V1 \ r(N)/`ws'

count if ppw == ppr & ppw~= . & ppr ~= .
matrix V1 = V1 \ r(N)/`wr'

* 2. Spalte
count if ppi == ppw & touse
matrix V2 = r(N)/`lv'

count if ppi==ppi & ppi ~= .
matrix V2 = V2 \ r(N)/`ii'

count if ppi == pps & ppi~= . & pps ~= .
matrix V2 = V2 \ r(N)/`is'

count if ppi == ppr & ppi~= . & ppr ~= .
matrix V2 = V2 \ r(N)/`ir'


* 3. Spalte
count if pps == ppw & touse
matrix V3 = r(N)/`lv'

count if pps==ppi & touse
matrix V3 = V3 \ r(N)/`lv'

count if pps == pps & pps ~= .
matrix V3 = V3 \ r(N)/`ss'

count if pps == ppr & pps~= . & ppr ~= .
matrix V3 = V3 \ r(N)/`sr'

* 4. Spalte
count if ppr == ppw & touse
matrix V4 = r(N)/`lv'

count if ppr==ppi & touse
matrix V4 = V4 \ r(N)/`lv'

count if ppr == pps & touse
matrix V4 = V4 \ r(N)/`lv'

count if ppr == ppr & ppr ~= .
matrix V4 = V4 \ r(N)/`rr'

matrix V = V1,V2,V3,V4

* Output
matrix rownames V = ppw ppi pps ppr
matrix colnames V = ppw ppi pps ppr
matrix list V, format(%4.2g)

exit




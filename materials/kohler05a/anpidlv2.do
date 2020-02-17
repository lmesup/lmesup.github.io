* Beschreibung der Analysedaten (Liste + Grafik)
* Verteilung der UV's

clear
version 8.0
set memory 60m
use pidlv

* Declare Postfiles
* -----------------

postfile efre model var N h f using 11, replace

* +----------+
* | All Data |
* +----------+

preserve


* Personendatensatz
* -----------------
drop if pid == .
sort persnr
by persnr: keep if _n==_N

* Ausführliche Form
* -----------------

tab1 e*


* Number of Persons 
* -----------------

count
local N = r(N)

* Count Persons with Ereignis > 0
* -------------------------------

local i 1
foreach var of varlist e* {
	lab def Var `i' "`var'", modify
	count if `var' > 0 
	local h = r(N)
	local f = `h'/`N'
	post efre (0) (`i') (`N') (`h') (`f')
	local i = `i' + 1
}
label save Var using Var, replace
restore


* +----------------+
* | Model-Settings |
* +----------------+


* Deletion "Angabe verweigert"
* ----------------------------

drop if pid == .
recode pid 4/6 =1


* LOOP over Model-Settings
* ------------------------

forvalues pi = 2/3 {
	preserve

	* Only Persons with Changing AV
	* -----------------------------

	sort persnr welle
	gen pi = pid == `pi'
	by persnr: gen pichg = pi~=pi[_n-1] if _n~=1
	by persnr: replace pichg = sum(pichg)
	by persnr: keep if pichg[_N] >= 1

	* Personendatensatz
	* -----------------
	
	by persnr: keep if _n==_N

	* Ausführliche Form
	* -----------------

	tab1 e*

	* Number of Persons 
	* -----------------
	
	count
	local N = r(N)
	
	* Count Persons with Ereignis > 0
	* -------------------------------
	
	local i 1
	foreach var of varlist e* {
		lab def Var `i' "`var'", modify
		count if `var' > 0 
		local h = r(N)
		local f = `h'/`N'
		post efre (`pi') (`i') (`N') (`h') (`f')
		local i = `i' + 1
	}
	restore
}

postclose efre

use 11, clear
do Var
label val var Var
reshape wide N h f, i(var) j(model)
format N* %5.0f
format h* %4.0f
format f* %3.2f
l var N*
l var h*
l var f* 

* +------------------------+ 
* | Graphische Darstellung |
* +------------------------+

reshape long

* Zum Löschen der y-Achsenbeschriftung
* ------------------------------------

gen fnolab = f
format fnolab %3.2f
lab val fnolab f 
lab def f 0 " "


graph twoway scatter f model if model == 0 | model == 2, connect(L) msymbol(i) name(g1, replace) ///
	xlab(0 "GSOEP" 2 "SPD") xtitle(" ") ytitle("Fraction of Events")
graph twoway scatter fnolab model if model == 0 | model == 3, connect(L) msymbol(i) name(g2, replace) ///
	xlab(0 "GSOEP" 3 "CDU/CSU") xtitle(" ") ytitle(" ")

graph combine g1 g2, rows(1) ycommon note("Do File: anpidlv2.do")
graph export figure2.wmf, replace

exit


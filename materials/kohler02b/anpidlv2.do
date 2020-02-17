* Beschreibung der Analysedaten (Liste + Grafik)
* Verteilung der UV's

clear
version 7.0
set memory 60m
use pidlv

drop est escheid /* Um varlist e* verwenden zu können */


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
recode pid 4=3 5=4 6=5


* LOOP over Model-Settings
* ------------------------

forvalues pi = 2/4 {
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
lab val fnolab f 
lab def f 0 " "

label val model mod
lab def mod 0 "All" 2 "SPD" 3 "CDU/FDP" 4 "B90/Gr."

capture program drop anpidlv2
	program define anpidlv2
		* common options
		local opt "border c(L) s(i) yscale(0,.25) ytick(0(.05).25) "
		sort var model
		gph open, saving(pidlv_uv, replace)
			graph f model if model == 0 | model == 2,  /*
			*/ bbox(0,0,23063,13000,900,450,0) `opt'  /*
			*/ ylab(0(.05).25) xlab(0,2) b2t(" ")
			graph fnolab model if model == 0 | model == 3,  /*
			*/ bbox(0,9500,23063,22500,900,450,0) `opt'    /*
			*/ ylab(0) xlab(0,3)  b2t(" ")
			graph fnolab model if model == 0 | model == 4,  /*
			*/ bbox(0,19000,23063,32000,900,450,0) `opt'  /*
			*/ ylab(0) xlab(0,4)  b2t(" ")
			gph font 1200 600
			gph pen 1
			gph text 11560 500 1 0 Anteile
			gph text 22500 16500 0 0 Modelltyp
		gph close
	end
anpidlv2

exit


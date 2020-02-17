* Beschreibung der Analysedaten
* Fallzahl, Zeiträume, Beobachtungsdichte

clear
version 7.0
set memory 60m
use pidlv

* Deletion "Angabe verweigert"
* ----------------------------

drop if pid == .
recode pid 4/6=1

* Declare Postfiles
* -----------------

postfile pidlv model n mtpoi mdens using 11, replace

* LOOP over Model-Settings
* ------------------------

forvalues pi = 2/3 {
	preserve
	
	* Only Persons with Changing AV
	* -----------------------------

	sort persnr welle
	gen pi = pid == `pi'
	by persnr: gen pichg = pi ~= pi[_n-1] if _n ~= 1
	by persnr: replace pichg = sum(pichg)
	by persnr: keep if pichg[_N] >= 1

	* Beobachtungszeiträume
	* ---------------------

	by persnr: gen t0= welle[1]
	by persnr: gen t1= welle[_N]
	by persnr: gen points= _N

	* Personendatensatz
	* -----------------

	by persnr: keep if _n==_N


	* Number of Persons 
	* -----------------

	count
	local n = r(N)

	* Anzahl Beobachtungszeitraum
	* ---------------------------
	
	gen tpoints = (t1-t0)+1
	sum tpoints
	local mtpoi = r(mean)
	tab tpoints

	* Dens of valid Points
	* ---------------------
	
	sort t0 t1
	by t0 t1: gen n = _N
	by t0 t1: gen meanp = sum(points)
	by t0 t1: replace meanp = meanp[_N]/n
	gen densp = meanp/tpoints
	sum densp
	local mdens = r(mean)

	* Post
	* ----

	post pidlv (`pi') (`n') (`mtpoi') (`mdens') 
	restore
}

postclose pidlv

use 11, clear
format mtpoi %2.1f
format mdens %3.2f
list



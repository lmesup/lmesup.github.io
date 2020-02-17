* Beschreibung der Analysedaten
* Verteilung der Anzahl von Teilnahmen an Erhebungswellen

clear
version 8.0
set memory 60m
use pidlv

* Deletion "Angabe verweigert"
* ----------------------------

drop if pid == .
recode pid 4/6=1

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

	* Beobachtungszeiträume
	* ---------------------

	by persnr: gen t0= welle[1]
	by persnr: gen t1= welle[_N]

	* Personendatensatz
	* -----------------

	by persnr: keep if _n==_N


	* Anzahl Zeitpunkte
	* -----------------
	
	gen tpoints = (t1-t0)+1
	keep tpoints
	save tpoi`pi', replace
	restore
}


* Graphik
* -------


use tpoi2, clear
histogram tpoints, discrete fraction  name(g1, replace) title("Lefties-model") ///
	xtitle(Number of Respondents) xlabel(2(2)16)
use tpoi3, clear
histogram tpoints, discrete fraction  name(g2, replace) title("Conservatives-model") ///
    	xtitle(Number of Respondents) xlabel(2(2)16)

graph combine g1 g2, xcommon ycommon rows(1) note("Do File: grpidlv1.do")
graph export pidlv1.wmf


erase tpoi2.dta
erase tpoi3.dta

exit
		 
		


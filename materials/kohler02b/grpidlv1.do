* Beschreibung der Analysedaten
* Verteilung der Anzahl von Teilnahmen an Erhebungswellen

clear
version 7.0
set memory 60m
use pidlv

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

capture program drop grpidlv1
	program define grpidlv1
		gph open, saving(pidlv1, replace)
			local opt "border yscale(0,.4) gap(1) ytick(0(.05).4) "
			use tpoi2, clear
			hist tpoints, l1t(" ") b2t(" ") t1t(SPD-Modell) /*
			*/ bbox(0,0,23063,11250,900,450,0) `opt' ylab(0(.1).3)
			use tpoi3, clear
			hist tpoints, l1t(" ") b2t(" ") t1t(CDU/FDP-Modell) /*
			*/ bbox(0,10125,23063,21375,900,450,0) `opt' ylab(0)   
			use tpoi4, clear
			hist tpoints, l1t(" ") b2t(" ") t1t(B90-Modell) /*
			*/ bbox(0,20250,23063,31500,900,450,0) `opt' ylab(0)  
			gph pen 1
			gph text 22800 16500 0 0 Anzahl von Teilnahmen an Befragungswellen
			gph font 1000 500
			gph text 11560 400 1 0 Anteil an Befragten
		gph close
	end
grpidlv1

erase tpoi2.dta
erase tpoi3.dta
erase tpoi4.dta

exit
		 
		


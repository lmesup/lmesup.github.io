* Beschreibung der Analysedaten
* Graphik der Teilnahmemuster

clear
version 7.0
set memory 60m
use pidlv

* Deletion "Angabe verweigert"
* ----------------------------

drop if pid == .
recode pid 4=3 5=4 6=5

* LOOP over Model-Settings
* -----------------------

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
	by persnr: gen points= _N

	* Personendatensatz
	* -----------------

	by persnr: keep if _n==_N


	* Keep Datenmuster
	* ----------------

	sort t0 t1
	by t0 t1: gen n = _N
	by t0 t1: keep if _n == _N
	fillin t0 t1
	drop if t0>t1
	replace n = 0 if n == .

	* Reshape
	* -------

	gen index = _n
	reshape long t, i(index) j(year)

	* Calculate Thickness
	* -------------------

	* Relative Häufigkeit der Muster
	gen N = sum(n)
	local N = N[_N]
	gen f = n/`N'
	

	* Anteil an höchster Häufigkeit in 1/8
	sort f
	local F = f[_N]
	gen pen = cond(f==0,0,round((f/`F'*8)+1,1))

	* Anzal der unterschiedlichen Pens
	sort pen
	by pen: gen penindex = 1 if _n==1
	replace penindex = sum(penindex)
	local PEN = penindex[_N]

	* Making Pen-Makro
	by pen: gen x = _n
	sort x pen
	macro drop _pen
	forvalues thick = 1/`PEN' {
		local p = pen[`thick']
		local pen`pi' "`pen`pi''`p'"
	}
	
	* t-Variable für jeden Pen
	forvalues nr = 1/`PEN' {
		gen reg`nr' = index if penindex == `nr'
	}
	
	* Store Results
	sort index year

	keep index reg* t
	if `pi' > 2 {
		foreach var of varlist reg* {
			lab val `var' nolab
		}
	}
	label define nolab 5 " "
	save 1`pi', replace

	restore
}


* +------------------------+ 
* | Graphische Darstellung |
* +------------------------+

global pen2 `pen2'
global pen3 `pen3'
global pen4 `pen4'

capture program drop grpidlv2
	program define grpidlv2
		gph open, saving(pidlv2, replace)
			local opt "c(LLLLLLL) s(iiiiii) border xlab(84(2)96)"
			local opt "`opt' yscale(1,88) ytick(5(20)85) gap(2)"
			use 12, clear
			local pen $pen2
			graph reg* t, pen(`pen') key1(" ") b2t(" ")  /*
			*/ l1t(" ") t2t(SPD-Modell) ylab(5(20)85) /*
			*/ bbox(0,0,23063,11500,900,450,0) `opt'
			use 13, clear
			local pen $pen3
			graph reg* t, pen(`pen') key1(" ") b2t(" ")  /*
			*/ l1t(" ") t2t(CDU/FDP-Modell) ylab(5) /*
			*/ bbox(0,10000,23063,21500,900,450,0) `opt' 
			use 14, clear
			local pen $pen4
			graph reg* t, pen(`pen') key1(" ") b2t(" ")  /*
			*/ l1t(" ") t2t(B90-Modell) ylab(5) /*
			*/ bbox(0,20000,23063,31500,900,450,0) `opt' 
			gph pen 1
			gph text 22800 16500 0 0 Beobachtungszeitraum
			gph font 900 450
			gph text 11560 400 1 0 Laufende Nummer 
		gph close
	end
grpidlv2

erase 12.dta
erase 13.dta
erase 14.dta

exit

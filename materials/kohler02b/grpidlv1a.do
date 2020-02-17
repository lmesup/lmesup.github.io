* Graphik der Untersuchungzeiträume im  
* Modells SPD vs. Rest

clear
version 7.0
set memory 60m
use persnr welle pi using pidlv

* Listwise Deletion
* -----------------

drop if pi >= 3
sort persnr welle

* Only Persons with Changing AV
* -----------------------------

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

* Number of Persons 
* -----------------

sort t0 t1
by t0 t1: gen n = _N


* Mean and dens of Points
* -----------------------

by t0 t1: gen meanp = sum(points)
by t0 t1: replace meanp = meanp[_N]/n
gen densp = meanp/((t1 - t0)+1)
sum densp, d

* Keep Datenmuster
* ----------------

by t0 t1: keep if _n == _N

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
gen pen = round((f/`F'*8)+1,1)

* Anzal der unterschiedlichen Pens
sort pen
by pen: gen penindex = 1 if _n==1
replace penindex = sum(penindex)
local PEN = penindex[_N]

* Making Pen-Makro
by pen: gen x = _n
sort x pen
forvalues thick = 1/`PEN' {
	local p = pen[`thick']
	local pen "`pen'`p'"
}

* t-Variable für jeden Pen
forvalues nr = 1/`PEN' {
	gen i`nr' = index if penindex == `nr'
}

sort index year
drop index

graph i* t, c(LLLLLLL) pen(`pen') s(iiiiiii) border  /*
*/ xlab(84(2)96) ylab(5(20)85) key1(" ") b2t("Untersuchungszeitraum") /*
*/ saving(pidlv1, replace)




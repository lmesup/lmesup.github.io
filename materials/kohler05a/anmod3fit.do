* Fit Model 3 (gradual effects)

clear
version 7.0
set memory 60m
set matsize 800

* ADO-INSTALLATION 
* ----------------

* The following section automatically installs Ado-Files over the
* Internet. You need to have a conection to the internet for this.
* If you don't have a connection to the internet you need to commend 
* out the entire section. In this case you have to install the ados
* by hand (See [U] 32 or Kohler/Kreuter (2001))

capture which fitstat
if _rc ~= 0 {
	net stb-56
	net install sg145
}

* ---------------------------------------------end of installing section. 


use persnr welle pid e* polin uw prgroup using pidlv

* +------------------------------------------------------+
* |                     Rekodierungen                    |
* +------------------------------------------------------+

* Parteiidentifikaton
* -------------------
 
drop if pid == .
gen byte left = pid == 2
gen byte kons = pid == 3

* Erhebungswellen-Dummies
* -----------------------

tab welle, gen(year)

* Shorten varname
* ---------------

ren eparkons eparcdu

* Time-Lags
* ---------

sort persnr welle
foreach piece of varlist e* {
	qby persnr (welle): replace `piece' = 1 + ln(sum(`piece'))  /*
	*/  if `piece' > 0
}

* Log(Anzahl Teilnahmen)
* ----------------------

qby persnr (welle): gen teiln = 1 + ln(_n)


* Politisches Interesse
* ---------------------

replace polin = . if polin < 0
replace polin = 4 - polin /* Spiegelung, kein Interesse = 0 */ 

gen polini = polin * teiln

  
* Building UVlist
* ---------------

foreach piece of varlist e* {
	local ia = abbrev("`piece'",7)
	gen byte `ia'i = polin * `piece'
	local uv "`uv' `piece' `ia'i"
}

* +--------------+
* | Fit-Measures |
* +--------------+ 


* Fit-Indices
quietly clogit left `uv' polin* year2-year13, group(persnr)
fitstat, saving(left)

* Fit-Indices
quietly clogit kons `uv' polin* year2-year13, group(persnr)
fitstat, saving(kons)

* OUTPUT
* ------

matrix fit = fs_left',fs_kons'
matrix list fit

exit


exit

* Fit Fixed-Effects-Logit-Modell (augenblicklich/permanent)

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


use persnr welle e* welle uw prgroup pid using pidlv
drop eparspd eparkons  /* to be able to use shortcut e* afterwards */


* Rekodierungen
* -------------


drop if pid == .
gen left = pid == 2 
gen kons = pid == 3 
drop pid

tab welle, gen(year)
drop welle

* Lefties-Model
* -------------

quietly clogit left e* year2-year13, group(persnr)
fitstat, saving(left)

* KONS - Modell
* ------------

* Fit-Indices
quietly clogit kons e* year2-year13, group(persnr)
fitstat, saving(kons)

* OUTPUT
* ------

matrix fit = fs_left',fs_kons'
matrix list fit

exit




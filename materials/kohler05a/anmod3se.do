* Random Group Variance Estimation Model 3 (gradual effects)

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

capture which rgroup
if _rc ~= 0 {
	ssc install rgroup 
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


* +--------------------+
* |Variance Estimation |
* +--------------------+

* Statlist
* --------

foreach piece of local uv {
	local statlist "`statlist' _b[`piece'] "
}

* Models
* -------

rgroup "xtlogit left `uv' polin year2-year13 [iw=uw], fe" "`statlist'",  /*
*/ rgroups(prgroup)
matrix bleft = r(val)'
matrix seleft = r(se)'

rgroup "xtlogit kons `uv' polin year2-year13 [iw=uw], fe" "`statlist'",  /*
*/ rgroups(prgroup)
matrix bkons = r(val)'
matrix sekons = r(se)'


* Save results
* ------------

drop _all

svmat bleft
svmat seleft
svmat bkons
svmat sekons

gen str8 uv = "."
local i 1
foreach piece of local uv {
	replace uv = "`piece'" in `i' 
	local i = `i' + 1
}

gen index = _n

* Producing Output
* ----------------

* calculate t
gen tleft = bleft1/seleft1
gen tkons = bkons1/sekons1

*Format output 
gen str8 left1 =  string(bleft1, "%5.2f")
gen str8 kons1 =  string(bkons1, "%5.2f")

gen str8 left2 = "(" + trim(string(tleft, "%5.2f")) + ")"
gen str8 kons2 = "(" + trim(string(tkons, "%5.2f")) + ")"

keep uv left? kons? 

gen i = _n
ren uv uv1
gen str8 uv2 = " "
reshape long uv left kons, j(coef) i(i)

* output
list uv left kons, nodisplay noobs

exit






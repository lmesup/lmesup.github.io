* R-Groups Variance Estimation Model 1

clear
version 7.0
set memory 60m
set matsize 800

* -----------------------------------------------------------------

* ADO-INSTALLATION 
* ----------------

* The following section automatically installs Ado-Files over the
* Internet. You need to have a conection to the internet for this.
* If you don't have a connection to the internet you need to commend 
* out the entire section. In this case you have to install the ados
* by hand (See [U] 32 or Kohler/Kreuter (2001))
* rgroup.ado, Random Group Variance Estimation (U. Kohler)

capture which rgroup
if _rc ~= 0 {
	ssc install rgroup 
}

* ---------------------------------------------end of installing section. 

use persnr welle e* welle uw prgroup pid using pidlv
drop eparspd eparkons 

* Rekodierungen
* -------------

drop if pid == .
gen left = pid == 2 
gen kons = pid == 3 
drop pid

tab welle, gen(year)
drop welle


* Building Uvarist
foreach piece of varlist e* {
	local uvars "`uvars' `piece'"
}

* Building statlist
foreach piece of local uvars {
	local statlist "`statlist' _b[`piece']"
}

* Variance Estimation
* -------------------
  
rgroup "xtlogit left e* year2-year13 [iw=uw], fe" "`statlist'",  /*
*/ rgroups(prgroup)

* Store Results
matrix bleft = r(val)'
matrix seleft = r(se)'

rgroup "xtlogit kons e* year2-year13 [iw=uw], fe" "`statlist'",  /*
*/ rgroups(prgroup)

* Store results
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
forvalues i = 1/19 {
	local stat: word `i' of `uvars'
	replace uv = "`stat'" in `i'
}

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




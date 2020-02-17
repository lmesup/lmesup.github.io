* Analyse von deff der Klumpung
clear
version 6.0
set memory 60m


* Retrival
* --------

mkdat ap6801 ksample /*
*/ using $soepdir, files(p) waves(a) keep(sex gebjahr)

holrein fam84 egph84 hhein84 pid84 bdauer84 using $soepdir, /*
*/files(peigen) waves(a)

holrein treim84 using $soepdir, files(pgen) /*
*/ waves(a)

holrein aintnr using $soepdir, files(pbrutto) /*
*/ waves(a)

ren ahhnr hhnrakt
sort persnr
save 11, replace

use persnr apdesreg aphrf using $soepdir/phrf
sort persnr
save 12, replace

use 11
merge persnr using 12
keep if _merge==3
drop _merge

* Rekodierungen
* -------------

drop if ksample == 2
gen men = sex==1
gen age = 1984 - gebjahr
gen married = fam84 == 1
replace bdauer = . if bdauer < 0
gen dienst = egph84==1 | egph84==2
replace dienst = . if egph84<0
replace treim = . if treim<0
gen cdu = pid== 3
replace cdu = . if pid==.
gen lebzuf = ap6801 if ap6801 > 0


svyset psu hhnr
svymean men age married bdauer dienst treim cdu lebzuf
matrix deff1 = e(deff)'

svyset psu aintnr
svymean men age married bdauer dienst treim cdu lebzuf
matrix deff2 = e(deff)'

svyset pweight aphrf
svymean men age married bdauer dienst treim cdu lebzuf
matrix deff3= e(deff)'

svmat deff1
svmat deff2
svmat deff3

keep deff*

input str8 var
men
age
married
bdauer
dienst
treim
cdu
lebzuf
end

list var deff* in 1/8
exit

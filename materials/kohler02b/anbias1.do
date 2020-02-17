* Analyse von bias_\bar{y}
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

ren ahhnr hhnrakt
sort persnr
save 11, replace

use persnr apdesreg aphrf using $soepdir\phrf
sort persnr
save 12, replace

use 11
merge persnr using 12
keep if _merge==3
drop _merge

* Rekodierungen
* -------------

sort hhnrakt
quietly by hhnrakt: gen hhgr=_n
quietly by hhnrakt: replace hhgr=hhgr[_N]
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
gen samplew = 1/.0002 if ksample == 1
sum hhgr if ksamp==2
replace samplew = 1/(.0008*r(mean)*1/hhgr) if ksample ==2

capture program drop bias
program define bias
    version 6.0
    postfile bias mean mean1 mean2 mean3 using bias, replace
    while "`1'" ~= "" {
        sum `1'
        local mean = r(mean)
        sum `1' [aweight = samplew]
        local mean1 = r(mean)
        sum `1' [aweight = apdesreg]
        local mean2 = r(mean)
        sum `1' [aweight = aphrf]
        local mean3 = r(mean)
        post bias `mean' `mean1' `mean2' `mean3'
        macro shift
    }
    postclose bias
end
bias men age married bdauer dienst treim cdu lebzuf

use bias, clear

input str8 var
men
age
married
bdauer
dienst
treim
cdu
lebzuf

gen bias1 = mean1 - mean
gen bias2 = mean2 - mean
gen bias3 = mean3 - mean

list var bias*
exit

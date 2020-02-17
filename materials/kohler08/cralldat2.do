* Repräsentativität (der Datensatz mit Sampling-Verfahren fur individuen)
* luniak@wz-berlin.de

version 8.2

clear
set memory 80m
set more off

//Vorbereitung der Datensätze

use alldat, clear
sort source iso3166_2
save alldat, replace

use sampdata, clear   // Sampdata produced with EpiData by luniak@wz-berlin.de
rename survey source
rename iso3166 iso3166_2
compress 
sort source iso3166_2

//Merge
merge source iso3166_2 using alldat
drop _merge 

// Variable: quota
gen quota1 = index(selper, "quota") ==  0
gen quota = quota1
replace quota = . if selper == "" & quota1 == 1
replace quota = 1 if quota1 == 0
replace quota = 0 if quota1 == 1 & selper != ""
label variable quota "Quotaverfahren"
label define yesno 1 ja 0 nein
label value quota yesno
drop quota1

save alldat2, replace

exit

* Berechnung eta^2 Einkommen/Prestige -> EGP

version 6.0
clear
set memory 60m

* I) SOEP
* -------

* Retrival des "Nettoeinkommen im letzten Monat"
#delimit ;
mkdat
 ap3302 bp4302 cp5202 dp4402 ep4402 fp4502 gp4302 hp5402 ip5402 jp5402
 kp6402 lp5302 mp4702 np5402
using $soepdir, files(p) waves(a b c d e f g h i j k l m n)
netto(-3,-2,-1,0,1,2,3,4,5);
#delimit cr

capture program drop umben
    program define umben
    local i 84
    while "`1'" ~= "" {
        ren `1' ein`i'
        local i = `i' + 1
        mac shift
    }
    end
umben ap3 bp4 cp5 dp4 ep4 fp4 gp4 hp5 ip5 jp5 kp6 lp5 mp4 np5

keep persnr ein*

reshape long ein, i(persnr) j(welle)
replace ein = . if ein<=0
sort persnr welle
save 11, replace

* Merge mit egpanh.dta
use persnr welle egp wegen treim phrf using egpanh, clear
replace wegen = . if wegen < 20 | wegen > 187
replace treim = . if treim < 14 | treim > 79
sort persnr welle
merge persnr welle using 11
assert _merge==3
drop _merge
erase 11.dta

* Berechnung eta^2 und Ablegen in Postfile
postfile eta ein p1 p2 k using eta, replace
oneway ein egp [aweight = phrf] if welle == 84
local e1 = r(mss) / (r(mss) + r(rss))
oneway treim egp [aweight = phrf]
local e2 = r(mss) / (r(mss) + r(rss))
oneway wegen egp [aweight = phrf]
local e3 = r(mss) / (r(mss) + r(rss))
post eta `e1' `e2' `e3' 11

* II ALLBUS
* ---------

use v2 v359 v360 v363 v436 v844 v845 /*
*/using $allbdir/allb8098, clear
ren v363 egp
ren v359 treim
ren v360 wegen
ren v436 ein
replace egp =. if egp == 0 | egp > 11
replace ein=. if ein<=0
replace wegen = . if wegen < 20 | wegen > 187
replace treim = . if treim < 14 | treim > 79
gen weight = v844 * v845

* Berechnung eta^2 und Ablegen in Postfile
oneway ein egp [aweight = weight] if v2==1984
local e1 = r(mss) / (r(mss) + r(rss))
oneway treim egp [aweight = weight]
local e2 = r(mss) / (r(mss) + r(rss))
oneway wegen egp [aweight = weight]
local e3 = r(mss) / (r(mss) + r(rss))
post eta  `e1' `e2' `e3' 11
postclose eta
exit


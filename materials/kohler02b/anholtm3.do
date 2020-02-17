* Replikation der eta^2 Werte bei Holtman (1990) (Eink/Prestige)

version 6.0
clear
set memory 60m

* I) SOEP
* -------

* Retrival des "berufliche Stellung und ISCO des Befragten"
#delimit ;
mkdat
 bstb84 bstb85 bstb86 bstb87 bstb88 bstb89 bstb90 bstb91 bstb92 bstb93
    bstb94 bstb95 bstb96 bstb97
 iscb84 iscb85 iscb86 iscb87 iscb88 iscb89 iscb90 iscb91 iscb92 iscb93
    iscb94 iscb95 iscb96 iscb97
using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)
netto(-3,-2,-1,0,1,2,3,4,5);
#delimit cr

* Retrival des "Nettoeinkommen im letzten Monat"
#delimit ;
holrein
 ap3302 bp4302 cp5202 dp4402 ep4402 fp4502 gp4302 hp5402 ip5402 jp5402
 kp6402 lp5302 mp4702 np5402
using $soepdir, files(p) waves(a b c d e f g h i j k l m n) ;
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

keep persnr ein* bst* isc*

reshape long ein bstb iscb, i(persnr) j(welle)
replace ein = . if ein<=0
sort persnr welle
save 11, replace

* Merge mit egpanh.dta
use persnr welle egpb wegen treim phrf using egpanh, clear
replace wegen = . if wegen < 20 | wegen > 187
replace treim = . if treim < 14 | treim > 79
sort persnr welle
merge persnr welle using 11
assert _merge==3
drop _merge
erase 11.dta

* Zuspielen des Allbus Klassenschemas:
sort bst isc
ren bstb bst
ren iscb isc
merge bst isc using egppat2
compress

* Festlegen der Analyseeinheiten
keep if _merge==3
drop if egpb < 0
drop if egpallb == 0 | egpallb == 12
drop if bst==21 | bst==23

* Berechnung eta^2 und Ablegen in Postfile
postfile eta ein p1 p2 using eta, replace

oneway ein egpb [aweight = phrf] if welle == 84
local e1 = r(mss) / (r(mss) + r(rss))
oneway treim egpb [aweight = phrf]
local e2 = r(mss) / (r(mss) + r(rss))
oneway wegen egpb [aweight = phrf]
local e3 = r(mss) / (r(mss) + r(rss))

post eta `e1' `e2' `e3'

oneway ein egpallb [aweight = phrf] if welle == 84
local e1 = r(mss) / (r(mss) + r(rss))
oneway treim egpallb [aweight = phrf]
local e2 = r(mss) / (r(mss) + r(rss))
oneway wegen egpallb [aweight = phrf]
local e3 = r(mss) / (r(mss) + r(rss))

post eta `e1' `e2' `e3'
postclose eta


* POSTFILE
* --------

use eta, clear
list

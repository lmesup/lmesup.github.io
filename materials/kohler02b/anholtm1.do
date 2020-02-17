* Warum ist eta^2 (Einkommen) im SOEP so niedrig?

version 6.0
clear
set memory 60m

* I) SOEP
* -------

* Retrival des "Nettoeinkommen im letzten Monat"
use persnr ap3302 using $soepdir/ap
ren ap3302 ein84
sort persnr
save 11, replace

use persnr bstb84 iscb84 using $soepdir/apeigen
sort persnr
save 12, replace

* Merge mit egpanh.dta
use persnr welle egp ein phrf using egpanh if welle == 84, clear
sort persnr
merge persnr using 11
drop if _merge==1
drop _merge
erase 11.dta
sort persnr
merge persnr using 12
drop if _merge==1

* Berechnung eta^2 unter verschiedenen Bedingungen

* Liegt es an den Gymnasial und Fachlehrern
oneway ein egp [aweight = phrf] if isc~=132 & bst~=42
* Sollte bei ca. .5 liegen um wie bei Allbus zu sein:
di = r(mss) / (r(mss) + r(rss))

* Liegt es an den Produktionsleitern?
oneway ein egp [aweight = phrf] if isc~=212 & bst~=53
* Sollte bei ca. .5 liegen um wie bei Allbus zu sein:
di = r(mss) / (r(mss) + r(rss))

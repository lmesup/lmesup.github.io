* Gewichtungsfaktoren fuer Laengschnitte 84-2000 + Rgroups
* --------------------------------------------------------

* ATTENTION: This Do-File automatically installs 
* Stata-Ados from the Internet. Comment the section
* "Cool-Ados" if you want to install them by hand!

version 7.0
clear
set memory 60m
set more off


*+--------------------------------+
*| INSTALLATION VON ZUSATZMODULEN |
*+--------------------------------+

* COOL-ADOS: Diese Ados werden im Folgenden automatisch über das 
* Internet geladen und installiert.
* Das setzt natürlich voraus, dass ihr Rechner eine feste Verbindung 
* zum Internet hat. Sollte dies nicht der Fall sein müssen Sie die 
* entsprechenden Ados von Hand installieren. Hinweise hierzu in 
* Kohler/Kreuter (2001)


capture which soepren
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install soepren
}


* +--------+
* |Retrival|
* +--------+

use hhnr  /* 
*/ design ksamp intnr /*
*/ using $soepdir/varianz
sort hhnr
save u1, replace

use persnr hhnr prgroup /* 
*/ 	aphrf bphrf cphrf dphrf ephrf fphrf gphrf hphrf iphrf jphrf kphrf  /*
*/ 	lphrf mphrf nphrf ophrf pphrf qphrf  /*
*/ 	bpbleib cpbleib dpbleib epbleib fpbleib gpbleib hpbleib  /*
*/ 	ipbleib jpbleib kpbleib lpbleib mpbleib npbleib opbleib ppbleib qpbleib /*
*/ using $soepdir/phrf, clear
sort hhnr

merge hhnr using u1, nokeep


* +---------------------------------+
* |Rename - it's easier to work with|
* +---------------------------------+
	
soepren ?phrf, new(hrf) waves(1984/2000)
soepren ?pbleib, new(bleib) waves(1985/2000)


* +----------------+
* |Balanced Weights|
* +----------------+

gen double bw = design   
forvalues i=1985/2000 {
		replace bw = bw *  bleib`i' 
}
lab var bw "Weights, Balanced Panel-Design 84-00"


* +------------------+
* |Unbalanced weights|
* +------------------+

gen double uw = 0
gen mark = .

forvalues k=2000(-1)1984 {
	forvalues i=1984/`k' {
		quietly {
			replace mark = uw==0
			replace uw = hrf`i' if uw == 0
			local start = `i'+1
			forvalues j=`start'/`k' {
				replace uw = uw * bleib`j' if mark
			}
		}
	}
}

lab var uw "Weights, Unbalanced Panel-Design 84-00"

keep persnr bw uw ksamp intnr prgroup
sort persnr
save weights, replace

exit

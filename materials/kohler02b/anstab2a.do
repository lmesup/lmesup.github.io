* Stationäres Markov-Modell 1. Ordnung 
* Vgl. Plewis 1985: 147-149; Bishop, Fienberg, Holland 1975, Ch 7

clear
version 6.0
set memory 60m
set matsize 800

use stab1

keep if mark == 1
drop mark

qby persnr:  /*
*/ replace pid = cond(uniform()>.5,pid[_n-1],pid[_n+2]) if /*
*/   pid[_n-1]~=1 & pid[_n-1]~=. & pid[_n+2]~=1 & pid[_n+2]~=. & pid==1 /*
*/ & pid[_n+1]==1

qby persnr:  /*
*/ replace pid = cond(uniform()>.5,pid[_n-1],pid[_n+1]) if /*
*/   pid[_n-1]~=1 & pid[_n-1]~=. & pid[_n+1]~=1 & pid[_n+1]~=. & pid==1

sort persnr welle
qby persnr: gen lag1 = pid[_n-1]
qby persnr: gen lag2 = pid[_n-2]

lab val lag1 pid
lab val lag2 pid

keep if pid>=2 & pid<=5
keep if lag1>=2 & lag1<=5
keep if lag2>=2 & lag2<=5

gen n=1

collapse (sum) n=n , by(pid lag1 lag2)
desmat pid*lag1*lag2
poisson n _x*
lrtest, saving(0)
desrep pid.lag2 pid.lag1.lag2
desmat pid*lag1 lag2*lag1
poisson n _x*
lrtest
exit
 

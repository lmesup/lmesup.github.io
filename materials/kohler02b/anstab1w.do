* Lag-1 Trans-Probabilities 

clear
set memory 60m
version 6.0

use stab1

sort persnr
qby persnr: gen lag1 = pid[_n-1]

* 1) Transition-Probabilities, Lag1
* ---------------------------------
tab lag1 pid [aw=uw], row 
tab lag1 pid [aw=uw] if pid >= 2 & pid <= 5, row

tab lag1 pid [aw=bw], row, if mark
tab lag1 pid [aw=bw] if pid >= 2 & pid <= 5 & mark, row
exit


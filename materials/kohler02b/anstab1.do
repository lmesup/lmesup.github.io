* Lag-1 Trans-Probabilities 

clear
set memory 60m
version 6.0

use stab1

* 1) Transition-Probabilities, Lag1
* ---------------------------------
xttrans pid, fre /* unbalanced Panel Design */
xttrans pid if pid >= 2 & pid <= 5, fre

xttrans pid if mark, fre /* balanced Panel Design */
xttrans pid if mark & pid>= 2 & pid <= 5, fre

exit


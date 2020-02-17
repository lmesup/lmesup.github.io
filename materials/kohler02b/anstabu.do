* Lag-1 Overall-Stability, Weighted, Unbalanced, 4 Grosse
* (Needs plenty of memory) 

clear
set memory 60m
version 6.0

use stab1

sort persnr
qby persnr: gen lag = pid[_n-1]

* Große Parteien
keep if pid>1 & pid<6 & lag>1 & lag<6	
		
* unbalanced, alle Parteien
drop persnr welle hhnr mark bw _merge 

expand uw

* unbalanced, nur SPD, CDU, FDP, B90/Gr
count if pid == lag 
local Vubal1 = r(N)
count if bigs	
di "Unbalanced, vier Große " `Vubal1'/r(N)

exit

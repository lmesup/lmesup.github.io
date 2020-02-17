* Lag-1 Overall-Stability mit Gewichtung

clear
set memory 60m
version 6.0

use stab1

sort persnr
qby persnr: gen lag = pid[_n-1]

* Große Parteien
gen bigs = pid>1 & pid<6 & lag>1 & lag<6	
		
* unbalanced, alle Parteien
tab lag pid [aw = uw], matcell(T)
local N = r(N)
local i 1
while `i' <= 6 {
	local cell = T[`i',`i']
	local diagua= `diagua' + `cell'
	local i = `i' +1
}
di "Unbalanced, alle Parteien " `diagua'/`N'

* unbalanced, nur SPD, CDU, FDP, B90/Gr
tab lag pid if bigs,  matcell(T)
local N = r(N)
local i 1
while `i' <= 4 {
	local cell = T[`i',`i']
	local diagub = `diagub' + `cell'
	local i = `i' +1
}
di "Unbalanced, grosse Parteien "  `diagub'/`N'


* Balanced alle Parteien
tab lag pid [aw=bw] if mark,  matcell(T)
local N = r(N)
local i 1
while `i' <= 6 {
	local cell = T[`i',`i']
	local diagba = `diagba' + `cell'
	local i = `i' +1
}
di "Balanced, alle Parteien " `diagba'/`N'

* Balanced nur SPD, CDU, FDP, B90/Gr
tab lag pid [aw=bw] if mark & bigs,  matcell(T)
local N = r(N)
local i 1
while `i' <= 4 {
	local cell = T[`i',`i']
	local diagbb = `diagbb' + `cell'
	local i = `i' +1
}
di "Balanced, alle Parteien " `diagbb'/`N'

exit

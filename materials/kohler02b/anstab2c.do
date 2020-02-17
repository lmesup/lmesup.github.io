* Test der Zeit-Homogenität 
* Vgl. Plewis 1985: 148

clear
set memory 60m
version 6.0

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
lab val lag1 pid
keep if pid>=2 & pid<=5
keep if lag1>=2 & lag1<=5

gen n=1

collapse (sum) n=n , by(pid lag1 welle)
desmat pid*lag1 lag1*welle
poisson n _x*
poisgof

exit
 













* 1) Overall-Stabilitaet fuer untersch. Lags
* ------------------------------------------

* Declare Postfile
tempname stab
tempfile stabil
postfile `stab' lag all_u big_u all_b big_b using `stabil' 

* Calculate Values
sort persnr welle
local i 1
gen lag = .
gen pair = .
gen bigs = .
while `i'<= 13 { 
	quietly {
		noi di "Lag " `i'
		by persnr: replace lag = pid[_n-`i']

		* Pairwise Deletion
		replace pair = pid>=1 & pid<=6 & lag>=1 & lag<=6
		* Große Parteien
		replace bigs = pid>1 & pid<6 & lag>1 & lag<6	
		
		* unbalanced, alle Parteien
		count if pid == lag & pair
		local Vubal1 = r(N)
		count if pair	
		local Vubal1 = `Vubal1'/r(N)
		noi di "Unbalanced, alle Parteien " `Vubal1'

		* unbalanced, nur SPD, CDU, FDP, B90/Gr
		count if pid == lag & bigs
		local Vubal2 = r(N)
		count if bigs
		local Vubal2 = `Vubal2'/r(N)
		noi di "Unbalanced, 4 Grosse" `Vubal2'

		* balanced alle Parteien
		count if lag==pid & mark & pair
		local Vbal1 = r(N)
		count if mark & pair
		local Vbal1 = `Vbal1'/r(N)
		noi di "Balanced, alle Parteien " `Vbal1'

		* balanced, nur SPD, CDU, FDP, B90/Gr
		count if lag==pid & mark & bigs
		local Vbal2 = r(N)
		count if mark & bigs
		local Vbal2 = `Vbal2'/r(N)
		noi di "Balanced, 4 Große " `Vbal2' 

		* Post Results
		post `stab' (`i') (`Vubal1') (`Vubal2') (`Vbal1') (`Vbal2') 
		local i = `i' + 1 
	}
}
postclose `stab'
local i = `i'+1


* 2 No Difference between Balanced and Unbalanced
* -----------------------------------------------

use `stabil', clear
gen alldiff = all_b - all_u
gen bigdiff = big_b - big_b
sum alldif bigdiff



* 3 Grafische Darstellung
* -----------------------

gen allbar = (all_u + all_b)/2
gen bigbar = (big_u + big_b)/2

capture program drop results
	program define results
		gph open, saving(stab1, replace)
		graph all_u all_b allbar big_u big_b bigbar allag1 biglag1 lag,  /*
		*/ c(||l||lll) s(iiiiiiii) border  /*
		*/  l1("Stabilitaet der PID") l2("in Cramer' s V")  /*
		*/ b2("Time-Lag in Jahren") xlab(1(1)13) ylab(.6(.1)1)
		local r1 = r(ay) * .940 + r(by)
		local c1 = r(ax) * 1.1 + r(bx)
		local r2 = r(ay) * .767 + r(by)
		local c2 = r(ax) * 1.1 + r(bx)
		gph pen 1
		gph text `r1' `c1' 0 -1 CDU, SPD, FDP, B90
		gph text `r2' `c2' 0 -1 einschl. Keine u. Sonst
		gph close
	end
results
exit


* Lag-X Trans-Probabilities, Gewichtet

clear
set memory 60m
version 6.0

use stab1


* 1) Overall-Stabilitaet fuer untersch. Lags, Originaldaten
* ---------------------------------------------------------

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

		* Große Parteien
		replace bigs = pid>1 & pid<6 & lag>1 & lag<6	
		
		* unbalanced, alle Parteien
		tab lag pid [aw = uw], matcell(T)
		local N = r(N)
		local j 1
		while `j' <= 6 {
			local cell = T[`j',`j']
			local diagua= `diagua' + `cell'
			local j = `j' +1
		}
		local ua =  `diagua'/`N'

		* unbalanced, nur SPD, CDU, FDP, B90/Gr
		tab lag pid [aw = uw] if bigs,  matcell(T)
		local N = r(N)
		local j 1
		while `j' <= 4 {
			local cell = T[`j',`j']
			local diagub = `diagub' + `cell'
			local j = `j' +1
		}
		local ub =  `diagub'/`N'

		* Balanced alle Parteien
		tab lag pid [aw=bw] if mark,  matcell(T)
		local N = r(N)
		local j 1
		while `j' <= 6 {
			local cell = T[`j',`j']
			local diagba = `diagba' + `cell'
			local j = `j' +1
		}
		local ba = `diagba'/`N'

		* Balanced nur SPD, CDU, FDP, B90/Gr
		tab lag pid [aw=bw] if mark & bigs,  matcell(T)
		local N = r(N)
		local j 1
		while `j' <= 4 {
			local cell = T[`j',`j']
			local diagbb = `diagbb' + `cell'
			local j = `j' +1
		}
		local bb `diagbb'/`N'

		* Post Results
		post `stab' (`i') (`ua') (`ub') (`ba') (`bb') 
		macro drop _diagua _diagub _diagba _diagbb
		local i = `i' + 1 
	}
}
postclose `stab'
local i = `i'+1


* 2 No Difference between Balanced and Unbalanced
* -----------------------------------------------

use `stabil', clear

gen alldiff = all_b - all_u
gen bigdiff = big_b - big_u
sum alldif bigdiff


* 3 Grafische Darstellung
* -----------------------

capture program drop results
	program define results
		gph open, saving(stab2w, replace)
		graph all_u all_u all_b   /*
		*/ big_u big_u big_b lag, /*
		*/ c(l||l||) s(iiiiii) border  /*
		*/ l1("Anteil stabiler PID") gap(4)  /*
		*/ b2("Time-Lag in Jahren") xlab(1(1)13) ylab(.6(.1)1)  /*
		*/ pen(222222) key1(" ")
		local r1 = r(ay) * .940 + r(by)
		local c1 = r(ax) * 1.1 + r(bx)
		local r2 = r(ay) * .767 + r(by)
		local c2 = r(ax) * 1.1 + r(bx)
		gph pen 1
		gph text `r1' `c1' 0 -1 CDU, SPD, FDP, B90
		gph text `r2' `c2' 0 -1 CDU, SPD, FDP, B90, Keine, Sonst.
		gph close
	end
results
exit


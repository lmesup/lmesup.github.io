* Grafik der 10 häufigsten SO-Sequenzen, balanced Panel-Design
version 6.0
clear
set memory 60m

use persnr welle mark pid using stab1

* Balanced-Panel Design
* ---------------------
keep if mark
drop mark


* keep the PIDs in their Order
* ----------------------------

sort persnr welle
qby persnr: drop if pid == pid[_n-1]  & _n~=1
qby persnr: gen order = _n
drop welle

* reshape into wide
* -----------------

replace pid = 0 if pid == . 
reshape wide pid, i(persnr) j(order)


* Nicht-Stabile- Sequenzen 
* ------------------------

egen valid = rmiss(pid*)
replace valid = 14 - valid
drop if valid == 1
local allpids "pid1 pid2 pid3 pid4 pid5 pid6 pid7 pid8 pid9 pid10"  
local allpids "`allpids' pid11 pid12 pid13 pid14"
sort `allpids'
quietly by `allpids': gen groups = 1 if _n == 1
replace groups = sum(groups)
quietly by `allpids': gen n = _N
quietly by `allpids': keep if _n == 1


* Make the Graph more readable
* ----------------------------

*replace pid5 = pid2 if valid == 2
*replace pid2 = . if valid == 2

*replace pid5 = pid3 if valid == 3
*replace pid3 = . if valid == 3
*replace pid3 = pid2 if valid == 3
*replace pid2 = . if valid == 3


* Put sequenzes into long form
* ----------------------------

sort n groups
keep in -10/-1
keep pid* n groups
reshape long pid, j(t) i(groups)
drop if pid == .

* Number Groups
* -------------

sort n groups 
qby n groups: replace groups = _n==1
replace groups = sum(groups)

* Generate Different Data-Ranges
* ------------------------------

local i 1
while `i' <= 10 {
	gen seq`i' = pid if groups == `i'
 	local i = `i' + 1
}


* Calculate Line-Thickness prop. to Frequencies
sort n groups                    /* More than one group within n */
qby n groups: gen N = n if _n==1 /* Kumul. absolute Frequencies */
replace N = sum(N)
gen f = n/N[_N]                 /* Relative Frequencies in 1/10    */
qui sum f                       /* Construct Thicknessvar 1 - 9    */
replace f = f - r(min)
replace f = int(f/((r(max)-r(min)))*8)+1
qby n groups: gen index = _n    /* Constructing a Sort Variable    */
sort index f  


* Grafik
* ------

* To label even "k.A."
lab def pid 0 "k.A.", modify

* To delete some xlabs
gen tno = t
lab val tno tno
lab def tno 1 " " 2 " " 3 " " 4 " " 5 " " 

* To delete some ylabs
for var seq*: lab val X pno
lab def pno 0 " " 1 " " 2 " " 3 " " 

capture program drop stab5b
	program define stab5b
		gph open, saving(stab5b, replace)
			tempvar tno
			local opt `"s(oo) border sort ylab(0(1)3) key1(" ") gap(8) "'
			local opt `" `opt' l1(" ") b2(" ") xtick(1(1)5) xlab(1(1)5) "'
	    	local pen = f[1]
			graph pid seq1 tno, c(.L) pen(0`pen')  /*
			*/ `opt' bbox(0,0,5200,17000,500,250,1) 
	    	local pen = f[2]
			graph seq2 tno, c(L) pen(`pen') /*
			*/ `opt' bbox(0,15000,5100,32000,500,250,1) 
	    	local pen = f[3]
			graph pid seq3 tno, c(.L) pen(0`pen') /*
			*/  `opt' bbox(4200,0,9400,17000,500,250,1) 
	    	local pen = f[4]
			graph seq4 tno, c(L) pen(`pen')  /*
			*/  `opt' bbox(4200,15000,9400,32000,500,250,1) 
	    	local pen = f[5]
			graph pid seq5 tno, c(.L) pen(0`pen')  /*
			*/  `opt' bbox(8600,0,13800,17000,500,250,1) 
	    	local pen = f[6]
			graph seq6 tno, c(L) pen(`pen')  /*
			*/ `opt'  bbox(8600,15000,13800,32000,500,250,1) 
	    	local pen = f[7]
			graph pid seq7 tno, c(.L) pen(0`pen') /*
			*/ `opt'  bbox(13000,0,18200,17000,500,250,1) 
	    	local pen = f[8]
			graph seq8 tno, c(L) pen(`pen')  /*
			*/  `opt' bbox(13000,15000,18200,32000,500,250,1) 
	    	local pen = f[9]
			graph pid seq9 t, c(.L) pen(0`pen') /*
			*/ `opt' bbox(17400,0,22600,17000,500,250,1) 
	    	local pen = f[10]
			graph seq10 t, c(L) pen(`pen') /*
			*/ `opt' bbox(17400,15000,22600,32000,500,250,1) 
			gph pen 1
			gph font 500 250
			gph text 23000 15000 0 0 Zeitablauf
		gph close
	end
stab5b

exit

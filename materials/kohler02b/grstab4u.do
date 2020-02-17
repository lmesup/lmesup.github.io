* Grafik der 10 häufigsten PID-Karrieren, Unbalanced Panel-Design (2 Teilnahmen)

clear
set memory 60m
version 6.0

use stab2u

* Sequenzen
* ---------

* Generate Sequences
local allpids "pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93"  
local allpids "`allpids' pid94 pid95 pid96 pid97"
sort `allpids'
quietly by `allpids': gen groups = 1 if _n == 1
replace groups = sum(groups)
quietly by `allpids': gen n = _N
quietly by `allpids': keep if _n == 1

* Grafische Darstellung der 10 haufigsten Sequenzen
* -------------------------------------------------

* Put sequenzes into long form
sort n
keep in -10/-1
keep pid* n groups
reshape long pid, j(welle) i(groups)

* Use "k.A."
replace pid = 0 if pid == .
lab def pid 0 "k.A.", modify

* Number Groups
sort n groups 
qby n groups: replace groups = _n==1
replace groups = sum(groups)

* Some Random-Noise
set seed 731
gen r = (uniform()-.5)/3 in 1/10

* Generate Different Data-Ranges
local i 1
while `i' <= 10 {
	gen seq`i' = pid if groups == `i'
	replace seq`i' = seq`i' + r[`i']
 	local i = `i' + 1
}

* Calculate Line-Thickness prop. to Frequencies
sort n groups                    /* More than one group within n */
qby n groups: gen N = n if _n==1 /* Kumul. absolute Frequencies */
replace N = sum(N)
gen f = n/N[_N]                 /* Relative Frequencies in 1/10    */
qui sum f                       /* Construct Thicknessvar 1 - 9    */
replace f = int(f/r(max)*8)+1
qby n groups: gen index = _n    /* Constructing a Sort Variable    */
sort index f  
local i 1
while `i' <= 10 {               /* Pick Thicknesses */ 
    local p = f[`i']
	local pen "`pen'`p'"
	local i = `i' + 1
}

graph pid seq1-seq10 welle, c(.LLLLLLLLLL) s(iiiiiiiiiii) pen(0`pen')  /*
*/  ylab(0(1)3) xlab(84(2)97) border sort saving(stab4u, replace)  /*
*/ t1("Unbalanced Panel-Design")

exit
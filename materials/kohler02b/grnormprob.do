* Erstellt die Grafik normprob.gph mit unterschiedlichen Verteilungsformen einer
* Zufallszahl aus [0,1]

* 0) Cool-Ados
* -------------

* benoetigt denscomp.ado
capture which denscomp
if _rc ~= 0 {
	net from http://www.stata.com/datenanalyse
	net install ados
}

clear
set obs 4000
gen x1 = normprob(invnorm(uniform())-1)
gen x0 = normprob(invnorm(uniform()))
gen x2 = normprob(invnorm(uniform())+1)
local i 0
while `i' <= 2 {
	sum x`i'
	local l`i' = r(mean)
	local i = `i' + 1
}

gen id = _n
reshape long x, j(faktor) i(id)
lab var faktor "Mittelwert Zufallsvariable"
lab val faktor faktor
lab def faktor 2 "Mean = 1" 1 "Mean = -1" 0 "Mean = 0"
lab var x "Phi[X~Mean,1]"
gen Phi = _n/50 in 1/50

denscomp x, by(faktor) at(Phi) c(lll) xscale(0,1) xline(`l1',`l0',`l2') /*
*/ xlabel(0(.2)1) ylab border ti(Phi[X~(Mean,1)]) pen(222) /*
*/ saving(normprob, replace)
exit

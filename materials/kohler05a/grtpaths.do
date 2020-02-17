* Produce Graphs like in Allison (1994)

version 8.0
clear
set obs 1000

gen t = _n/10
set obs 1001
replace t = 55 in 1001
replace t = t - 55
sort t

gen y1 = 95 if t>= -30 & t < 0
replace y1 = 95 in 550
replace y1 = 103 in 551
replace y1 = 103 if t> 0 & t<= 30

generat y2 = 76 + .25*t if t >= -30 & t < 0
replace y2 = 76 + .25*t in 550
replace y2 = 84 + .25*t in 551
replace y2 = 84 + .25*t if t > 0 & t<= 30

generat y3 = 61 + .25*t if t >= -30 & t < 0
replace y3 = 61 in 550
replace y3 = 69 in 551
replace y3 = 69 - .25*t if t > 0 & t <= 30

gen y4 = 46 if t >= -30 & t < 0
replace y4 = 46 in 550
replace y4 = 54 in 551
replace y4 = (54 - 2 * ln(t + .5 ))  if t > 0 & t <= 30

gen y5 = 32 if t >= -30 & t <= 0
replace y5 = 32 + normd((t-15)/5) * 20 if t > 0 & t <= 30

gen y6 = 15 if t >= -30 & t <= 0
replace y6 = 15 + log((t+.1)*8) if t > 0 & t <= 30

lab var t "Time"
lab val t t
lab def t 0 "Event" 30 " "

for num 1/6: lab val yX y
lab def y 105 "Y(t)"

set obs 1007
replace t = 32 in 1002/1007

gen label = 103 in 1002
replace label = 84 + .25 * 30 in 1003
replace label = 69 - .25*30 in 1004
replace label = (54 - 2 * ln(30 + .5 )) in 1005
replace label = 32 + normd((30-15)/5) * 20 in 1006
replace label = 15 + log((30+.1)*8) in 1007
lab val label y

gen str1 labstr = "A" in 1002
replace labstr = "B" in 1003
replace labstr = "C" in 1004
replace labstr = "D" in 1005
replace labstr = "E" in 1006
replace labstr = "F" in 1007


drop if t < -30 | t > 32

graph twoway (line y* t)  ///
	(scatter label t, ms(i) ml(labstr) mlabpos(0) ) , ///
	legend(off) ///
	xlab(0, val) xtick(-30(10)30) xscale(r(-30 32)) xtitle(Time, placement(east)) ///
      yscale(off) ylabel(none) ytick(none) ytitle("Y(t)", orientation(horizontal) placement(north)) ///
	note("Do-File: grtpaths.do")
graph export figure1.wmf, replace
exit




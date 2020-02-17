// Re-Analysis of Kalimijn/Veenhoven distributions
// kohler@wzb.eu

clear
version 11.1


// Input distributions from Kalmijn/Veenhoven (2005)
// -------------------------------------------------

input lsat A1 A2 B1 B2 C1 C2 D E F G H K A3 L1 L2 M1 M2 N1 N2 A4 P Q R S1 S2 T U V W X Y1 Y2 Z
 10 0 100 0 0 3 0 0 10 0 10 0 50 0 0 0 0 0 0 50 100 95 90 86 80 20 75 70 65 60 55 19 1 . 
 9 0 0 0 0 6 0 0 10 10 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 17 3 .
 8 0 0 0 0 14 3 0 10 10 20 50 0 0 0 0 0 50 50 0 0 0 0 0 0 0 0 0 0 0 0 15 5 .
 7 0 0 0 0 27 6 0 10 20 10 0 0 0 50 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 13 7 .
 6 100 0 50 0 27 14 0 10 10 0 0 0 0 0 0 0 50 0 0 0 0 0 0 0 0 0 0 0 0 0 11 9 .
 5 0 0 50 0 14 27 20 10 10 0 0 0 0 50 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 9 11 20
 4 0 0 0 0 6 27 20 10 20 10 0 0 0 0 0 0 0 0 50 0 0 0 0 0 0 0 0 0 0 0 7 13 20
 3 0 0 0 0 3 14 20 10 10 20 50 0 100 0 50 0 50 0 0 0 0 0 0 0 0 0 0 0 0 0 5 15 20
 2 0 0 0 50 0 6 20 10 10 10 0 0 0 0 0 0 0 50 0 0 0 0 0 0 0 0 0 0 0 0 3 17 20
 1 0 0 0 50 0 3 20 10 0 10 0 50 0 0 50 50 0 0 0 0 5 10 15 20 80 25 30 35 40 45 1 19 20
end

// Correct input error (easier here than upstream)
replace M1 = 50 if lsat==6

// Reorganize data 
aorder
order lsat

unab vars: A1-Z
local i 1
foreach var of varlist A1-Z {
	ren `var' n`i++'
}
reshape long n, i(lsat) j(typ)
label value typ typ

local i 1
foreach piece in `vars' {
	label define typ `i++' "`piece'", modify
}

// Run Checks
// ---------

// SDmax for all distributions
sdlim lsat [fw=n], l(1 10) by(typ)
matrix SDcorr0 = r(sdcorr)
matrix SD0 = r(sd)

// Change number of observations
replace n = n/10
sdlim lsat [fw=n], l(1 10) by(typ)
matrix SDcorr1 = r(sdcorr)
matrix SD1 = r(sd)

svmat SDcorr0
svmat SDcorr1
svmat SD0
svmat SD1

corr SD* // -> Corrected standard deviations perform better!

drop SD1 SDcorr1
replace n = n/10

// Linear transformations
replace lsat = lsat * 2
sdlim lsat [fw=n], l(1 20) by(typ)
matrix SDcorr1 = r(sdcorr)
matrix SD1 = r(sd)
svmat SDcorr1
svmat SD1

corr SD* // Both version perform simlar
gen d1 = SDcorr0 - SDcorr1
gen d2 = SD0 - SD1
sum SD0 SD1 SDcorr* d1 d2, sep(2) // but: SD1/2=SD0!

drop SD1 SDcorr1
replace lsat = lsat/2

// The tau analysis
sdlim lsat [fw=n] if inlist(typ,1,2,5,6,7,8,9,10,11,12,13,14), l(1 10) by(typ)
matrix A = r(sdcorr)
svmat A
replace A1=0 in 2
gen index = _n
tab index A1, taub nofreq

sdlim lsat [fw=n] if inlist(typ,1,2,3,5,6,15,16,17,18,19,20,14), l(1 10) by(typ)
matrix B = r(sdcorr)
svmat B
replace B1=0 in 2
replace index = 15 if index==6
tab index B1, taub nofreq

exit





// Population weights based on Electorate

version 10.1
use btw if area~="DE", clear

gen byte bul = 1 if inlist(area,"SH","HH","HB")
replace bul = 2 if inlist(area,"NI")
replace bul = 3 if inlist(area,"NW")
replace bul = 4 if inlist(area,"HE")
replace bul = 5 if inlist(area,"BY")
replace bul = 6 if inlist(area,"BW")
replace bul = 7 if inlist(area,"RP","SL")
replace bul = 8 if inlist(area,"BE","BB")
replace bul = 9 if inlist(area,"MV")
replace bul = 10 if inlist(area,"SN")
replace bul = 11 if inlist(area,"ST")
replace bul = 12 if inlist(area,"TH")

by eldate area, sort: keep if _n==1
by eldate bul, sort: gen long popweight = sum(nelectorate)
by eldate bul, sort: replace popweight = popweight[_N]
by eldate bul, sort: keep if _n==1

keep eldate bul popweight

save popweights, replace

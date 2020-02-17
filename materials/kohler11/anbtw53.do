// Reproduce Seat-Distribution for 1953

clear all
use elections if year(eldate)==1953 & area=="DE"
keep eldate party grundmandat seats ppartyvotes
tempfile 53
save `53'

use btw if year(eldate) == 1953 & area != "DE", clear
replace party = "CDU/CSU" if inlist(party,"CDU","CSU")
merge m:1  party using `53', keep(3)
drop _merge

bysort area party (npartyvotes): keep if _n==_N


// "Oberverteilung"
gen district = 67  if area=="BW"     // minus 2 Parteilose
replace district = 91  if area=="BY"  
replace district =  6  if area=="HB"  
replace district = 44  if area=="HE"  
replace district = 17  if area=="HH"  
replace district = 66  if area=="NI"  
replace district = 138 if area=="NW"  
replace district = 31  if area=="RP"  
replace district = 24  if area=="SH" 

// "Unterverteilung"
egen districtseats 			       /// 
  = apport(npartyvotes) 		   ///
  if party != "BP" ///
   , size(district) by(area) t(5)  		///
  e(strpos(grundmandat,party)>0)

// Überhangmandate
replace districtseats = districtseats+2 if party == "CDU/CSU" & area=="SH"
replace districtseats = districtseats+1 if party == "DP" & area=="HH"

by party, sort: egen seatscreated = sum(districtseats)
by party, sort: keep if _n==1

l party seatscreated seats, sum

assert seatscreated==seats

exit












// Reproduce Seat-Distribution for 1949

use btw if year(eldate) == 1949 & area != "DE", clear

// "Oberverteilung"
gen district = 52  if area=="BW"     // minus 2 Parteilose
replace district = 78  if area=="BY"  
replace district =  4  if area=="HB"  
replace district = 36  if area=="HE"  
replace district = 13  if area=="HH"  
replace district = 58  if area=="NI"  
replace district = 109 if area=="NW"  
replace district = 25  if area=="RP"  
replace district = 22  if area=="SH"  // minus 1 Parteiloser

// "Unterverteilung
egen districtseats 			       /// 
  = apport(npartyvotes) 		   ///
  if party != "Parteilose"  	   ///
   , size(district) by(area) t(5)  ///

replace districtseats = 1 if party=="Parteilose" & area=="SH"
replace districtseats = 2 if party=="Parteilose" & area=="BW"

// Würrtemberg/Hohenzollern-Effekt
replace districtseats = districtseats-2 if party == "KPD" & area=="BW"
replace districtseats = districtseats+1 if party == "CDU" & area=="BW"
replace districtseats = districtseats+1 if party == "SPD" & area=="BW"

// Überhangmandate
replace districtseats = districtseats+1 if party == "CDU" & area=="BW"
replace districtseats = districtseats+1 if party == "SPD" & area=="HB"

replace party = "CDU/CSU" if inlist(party,"CDU","CSU")
by party, sort: egen seatscreated = sum(districtseats)

by party, sort: keep if _n==1

tempfile 49
save `49'

use elections if year(eldate)==1949 & area=="DE"
merge 1:1 party using `49'

l party seatscreated seats, sum

assert seatscreated==seats

exit












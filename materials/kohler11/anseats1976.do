// Seats in Bundestag (Checking my programs)
// ----------------------------------------
// kohler@wzb.eu

version 10
set more off

use npartyvotes nvalid party area eldate using elections ///
	if area=="DE" & year(eldate)==1976, clear

egen seats = prseats(npartyvotes), s(496) threshold(5) method(divisor) 

gen long h_npartyvotes = round(nvalid * .49,1) if party == "CDU/CSU"
replace h_npartyvotes = round(nvalid * .422,1) if party == "SPD"
replace h_npartyvotes = round(nvalid * .071,1) if party == "FDP"
egen h_seats = prseats(h_npartyvotes), s(496) threshold(5) method(divisor) 



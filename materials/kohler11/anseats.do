// Seats in Bundestag (Checking my programs)
// ----------------------------------------
// kohler@wzb.eu

version 10
set more off

use elections if area=="DE", clear
tab party if party=="Gruene"

gen m = .

egen x = prseats(npartyvotes) 			/// 
if year(eldate)==1949  /// unverb. Listen CDU +1, SPD +1
  , s(400) threshold(5) g(party,"Zentrum","DP","BP","WAV","SSW","DKP/DRP") 	/// 
  method(divisor)
replace m = x if m==.

drop x
egen x = prseats(npartyvotes) if year(eldate)==1953  /// CDU +2,  DP +1
  , s(484) threshold(5) g(party,"Zentrum","DP") method(divisor) 
replace m = x if m==.

drop x
egen x = prseats(npartyvotes) if year(eldate)==1957  /// CDU +3
  , s(494) threshold(5) g(party,"DP") method(divisor) 
replace m = x if m==.

drop x
egen x = prseats(npartyvotes) if year(eldate)==1961  /// CDU +5 
  , s(494) threshold(5) method(divisor)
replace m = x if m==.

drop x
bysort eldate: egen x = prseats(npartyvotes)  /// 
  if inrange(year(eldate),1965,1983)          /// Note 1
  , s(496) threshold(5) method(divisor) 
replace m = x if m==.

drop x
egen x = prseats(npartyvotes) if year(eldate)==1987 /// CDU +1
  , s(496) threshold(5) method(hamilton) 
replace m = x if m==.

drop x
egen x = prseats(npartyvotes) 			/// 
  if year(eldate)==1990	/// getrennte 5% Klausel in Ost/West, 6 CDU Ueberhang
  , s(656) threshold(5) g(party,"B90/Gr","PDS") method(hamilton) 
replace m = x if m==.

drop x
bysort eldate: egen x = prseats(npartyvotes)  /// 
  if inrange(year(eldate),1994,1998) /// Note 2
  , s(656) g(party,"PDS") threshold(5) method(hamilton) 
replace m = x if m==.

drop x
bysort eldate: egen x = prseats(npartyvotes)  /// 
  if year(eldate)==2002 /// Note 3; CDU +1, SPD +4
  , s(596) threshold(5)  method(hamilton) 
replace m = x if m==.

drop x
bysort eldate: egen x = prseats(npartyvotes)  /// 
  if year(eldate)==2005 ///  SPD +10, CDU +7
  , s(598) threshold(5)  method(hamilton) 
replace m = x if m==.


// Graph Disproportionability
// --------------------------

gen votesperseat = npartyvotes/m
lab var votesperseat "Votes per seat"

global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")


replace party = "PDS/Linke" if inlist(party,"PDS","Die Linke")
replace party = "Gruene" if inlist(party,"Gruene","B90/Gr")


format eldate %tdYY
levelsof eldate if area=="DE", local(xlab)

graph twoway 							  ///
  || sc votesperseat eldate if !inlist(party,"CDU/CSU","SPD","FDP","Gruene","PDS/Linke")  ///
  , ms(o) mlcolor(gs8) mfcolor(gs8)     ///
  || connected votesperseat eldate if party == "CDU/CSU"  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(T) mlcolor(black) mfcolor(black) msize(*1.5)    /// 
  || connected votesperseat eldate if party == "SPD"  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(O) mlcolor(black) mfcolor(white)   /// 
  || connected votesperseat eldate if party == "FDP"  ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(T) mlcolor(black) mfcolor(gs8)     ///
  || connected votesperseat eldate if party == "Gruene"  ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(S) mlcolor(black) mfcolor(white)     ///
  || connected votesperseat eldate if party == "PDS/Linke"  ///
  , sort lcolor(black) lpattern(dot)     ///
  ms(O) mlcolor(black) mfcolor(gs8)     ///
  ,  legend(order(2 "CDU/CSU" 3 "SPD" 4 "FDP" 5 "Gruene" 6 "PDS/Linke" 1 "Other") rows(2))  ///
  ytitle(Votes per seat)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xlab(`xlab')

exit

Note 1
------

1976 Diskrepanz zwischen offiziellen Quellen und Stata-d'Hondt
wg. Zusammenfassung der Stimmen von CDU u. CSU. 

Ueberhangmandate:
1980 SPD +1
1983 SPD +2


Note 2
------

Ueberhangmandate
1994 CDU +12, SPD +4
1998 SPD +13

Note 3
------

2002 PDS erreicht 2 Direktmandate (scheitert an der 5% Klausel +
Grundmandatsklausel).  Die beiden Direktmandate wurden von der
Sitzzahl abgezogen.














drop x





// Potential power of state elections
// ----------------------------------
// kohler@wzb.eu

version 10
set more off
set scheme s1mono


// In which legislative periods of Bundestag fall legislative periods of Bundesrat?
// -------------------------------------------------------------------------------

use elections, clear

// Only elections, no parties
by area eldate, sort: keep if _n==1

// Begin and end of periods (defined by elections or fed. gov. change)
foreach date in 						/// 
  14Aug1949 6Sep1953 15Sep1957 17Sep1961 19Sep1965 /// 
  1Dec1966  /// 
  28Sep1969 19Nov1972 3Oct1976 4Oct1980  /// 
  10Oct1982 6Mar1983 15Jan1987 2Dec1990 16Oct1994  /// 
  27Sep1998 22Sep2002 18Sep2005 {
	local B `"`B' `=date("`date'","DMY")'"'
}

foreach date in 						/// 
  6Sep1953 15Sep1957 17Sep1961 19Sep1965 /// 
  1Dec1966  /// 
  28Sep1969 19Nov1972 3Oct1976 4Oct1980  /// 
  10Oct1982 6Mar1983 25Jan1987 2Dec1990 16Oct1994  /// 
  27Sep1998 22Sep2002 18Sep2005 "`=c(current_date)'" {
	local E `"`E' `=date("`date'","DMY")'"'
}

by area (eldate), sort: gen begin = eldate
by area (eldate): gen end = eldate[_n+1]
by area (eldate): replace end = date(c(current_date),"DMY") if _n==_N

// Indicator variables for legislative BT periods in which the state periods falls
keep if area != "DE" & brseats > 0

local periods1: word count `B'
local periods2: word count `E'

forv i = 1/`periods1' {
	local j = `i' + 1
	gen legperiod_`i' =  (begin >= `:word `i' of `B''  & begin < `:word `i' of `E'')  ///
	  | (end  > `:word `i' of `B''  & end <= `:word `i' of `E'')  
}

// This counts in how many legislative BT periods a state period falls
egen noflegperiod = rsum(legperiod_*)

// Create a state-election record for each legislative BT period
expand noflegperiod

// "Deindex" the periods (the opposite of -separate-)
gen legperiod = .
foreach var of varlist legperiod_* {
	local i = substr("`var'",11,.) // Extract the index number
	by area eldate, sort: replace legperiod = `i' if legperiod_`i' == 1 & _n==1 &legperiod==.
}
by area eldate: replace legperiod = legperiod[_n-1]+1 if _n==2
label variable legperiod "Legislative period of Bundestag"

gen legperiodbegin = .
gen legperiodend = .
levelsof legperiod, local(K)
foreach k of local K {
	replace legperiodbegin = `:word `k' of `B'' if legperiod ==`k'
	replace legperiodend = `:word `k' of `E'' if legperiod==`k'
}

keep area eldate legperiod legperiodbegin legperiodend
sort area eldate


// Status of the parties in state government after each important event
// --------------------------------------------------------------------

// I need two joinby (for the 1st time in my life ...)
joinby area eldate using elections

// Regierungspartei im Bund J/N
gen regpartyDE:yesno = 0
replace regpartyDE = 1 if		/// CDU/FDP/DP
  inlist(party,"CDU/CSU","FDP","DP") 	///
  & legperiod==1
replace regpartyDE = 1 if		/// CDU/DP
  inlist(party,"CDU/CSU","DP") 	///
  & legperiod==2
replace regpartyDE = 1 if		/// CDU/FDP
  inlist(party,"CDU/CSU","FDP") 	///
  & inlist(legperiod,3,4,5,11,12,13,14,15)  
replace regpartyDE = 1 if		/// Große Koalition
  inlist(party,"CDU/CSU","SPD") ///
  & inlist(legperiod,6,18)  
replace regpartyDE = 1 if		/// Sozialliberal
  inlist(party,"FDP","SPD") 	///
  & inlist(legperiod,7,8,9,10)  
replace regpartyDE = 1 if		/// Rot-Grün
  inlist(party,"SPD","Gruene") 	///
  & inlist(legperiod,16,17)

// Oppositionspartei im Bund J/N
gen opppartyDE:yesno = 0
replace opppartyDE = 1 if 				                            ///	
  inlist(party,"SW","Zentrum","SPD","KPD","DKP/DRP","BP","WAV") 	///
  & inlist(legperiod, 1)
replace opppartyDE = 1 if		            ///
  inlist(party,"Zentrum","SPD","GB/BHE") 	///
  & inlist(legperiod, 2)
replace opppartyDE = 1 if		/// 
  inlist(party,"SPD","FDP") 	///
  & inlist(legperiod, 3)
replace opppartyDE = 1 if		/// 
  inlist(party,"SPD") 	        ///
  & inlist(legperiod, 4,5)
replace opppartyDE = 1 if		/// 
  inlist(party,"FDP") 	        ///
  & inlist(legperiod, 6)
replace opppartyDE = 1 if 		///	
  inlist(party,"CDU/CSU") 	    ///
  & inlist(legperiod,7,8,9,10 )
replace opppartyDE = 1 if 		///	
  inlist(party,"SPD") 	        ///
  & inlist(legperiod,11 )
replace opppartyDE = 1 if 		///	
  inlist(party,"SPD","Gruene") 	///
  & inlist(legperiod,12,13 )
replace opppartyDE = 1 if 				///	
  inlist(party,"SPD","PDS","B90/Gr")	///
  & inlist(legperiod,14)
replace opppartyDE = 1 if 				///	
  inlist(party,"SPD","PDS","Gruene")	///
  & inlist(legperiod,15)
replace opppartyDE = 1 if	            ///
  inlist(party,"CDU/CSU","PDS","FDP") 	///
  & inlist(legperiod,16,17)
replace opppartyDE = 1 if	            ///
  inlist(party,"FDP","Gruene","Linke") 	///
  & inlist(legperiod,18)

// Define Pro/Contra/Neutral
bysort area eldate legperiod: gen npro = sum(regparty==1 & regpartyDE==1)
bysort area eldate legperiod: replace npro = npro[_N]

bysort area eldate legperiod: gen ncontra = sum(regparty==1 & opppartyDE==1)
bysort area eldate legperiod: replace ncontra = ncontra[_N]
bysort  area eldate legperiod: keep if _n==1
				   
gen status = 1 if npro & !ncontra
replace status = 2 if !npro & ncontra
replace status = 3 if (npro & ncontra) | (!npro & !ncontra)
replace status = 1 if area=="HH" & year(eldate)==1953

// Previous Status
by area (eldate legperiod), sort: gen lagstatus = status[_n-1]

// Composition of the Bundesrat (this was difficult ...)
// -----------------------------------------------------

keep unitid area eldate legperiod* brseats status lagstatus 

gen brpro = brseats if status == 1 & lagstatus==.
gen brcontra = brseats if status == 2 & lagstatus==.
gen brneutral = brseats if status == 3 & lagstatus==.

sort area eldate legperiod
by area (eldate legperiod): replace brpro = - brseats if status[_n-1]==1 & status!=1
by area (eldate legperiod): replace brcontra = - brseats if status[_n-1]==2 & status!=2
by area (eldate legperiod): replace brneutral = - brseats if status[_n-1]==3 & status!=3

by area (eldate legperiod): replace brpro = brseats if status==1 & status[_n-1]!=1
by area (eldate legperiod): replace brcontra = brseats if status==2 & status[_n-1]!=2
by area (eldate legperiod): replace brneutral = brseats if status==3 & status[_n-1]!=3

by area (eldate legperiod): replace brpro = 0 if status==1 & status[_n-1]==1
by area (eldate legperiod): replace brcontra = 0 if status==2 & status[_n-1]==2
by area (eldate legperiod): replace brneutral = 0 if status==3 & status[_n-1]==3

bysort area eldate (legperiod): gen btw = _n==2
bysort area eldate (legperiod): replace eldate = legperiodbegin if _n==2

sort eldate btw area
replace brpro = sum(brpro)
replace brcontra = sum(brcontra)
replace brneutral = sum(brneutral)

by eldate (btw area): drop if _n<_N & btw

// External "shocks"
// ----------------

// Hessen +1 für Contra wg. Neuer Sitzzahl
replace brcontra = brcontra + 1 if eldate>=date("18Jan1996","DMY")

// Graph distribution of Seats
// ---------------------------
// (after Bundesrat was "filled up")

// absolute majority
gen mehrheit = ceil((brcontra+brpro+brneutral)/2)

// Perioden
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

format eldate %tdYY
graph twoway 							/// 
  || line mehrheit eldate, lcolor(gs10) lpattern(solid) c(L) lwidth(*2.5) ///
  || line brcontra eldate, lcolor(black) lpattern(solid) lwidth(*1.2)  ///
  || line brpro eldate, lcolor(black) lpattern(dash) lwidth(*1.2)   ///
  || scatter brpro brcontra eldate if btw, ms(O..) mlcolor(black..) mfcolor(white..) ///
  || if mehrheit>=21, legend(order(2 "Contra" 3 "Pro" 4 "Shocks by Fed. State") rows(1))  ///
  ytitle(Seats in Bundesrat) xtitle(Time)


// Indicate high influence elections
// --------------------------------

gen diff1 = brcontra - (mehrheit-.5)
gen diff2 = brpro - (mehrheit-.5)

// Pro-Kontra Parteien bekommen die Stimmen des tatsächlichen Gewinners
gen hbrpro = brpro + brseats if status!=1
gen hbrcontra = brcontra + brseats if status!=2
replace hbrpro = brpro - brseats if status==1
replace hbrcontra = brcontra - brseats if status==2
gen hbrneutral = brneutral - brseats if status==3

gen tag1 = sign(brpro-(mehrheit-.5)) != sign(hbrpro-(mehrheit-.5)) & mehrheit >=21
gen tag2 = sign(brcontra-(mehrheit-.5)) != sign(hbrcontra-(mehrheit-.5)) & mehrheit >=21

graph twoway 							/// 
  || line mehrheit eldate, lcolor(gs10) lpattern(solid) lwidth(*2) ///
  || line brpro eldate, lcolor(black) lpattern(solid)  ///
  || scatter brpro eldate if tag1 & !btw , mcolor(black) ms(O) ///
  || pcarrow brpro eldate hbrpro eldate if tag1 & !btw, lcolor(black) mcolor(black) ///
  || if mehrheit>=21 ///
  , legend(off) ylab(`ylab', valuelabel angle(0) grid gstyle(dot))   ///
  name(g1, replace) title(Votes for Federal Government, box bexpand pos(12))
  
graph twoway 							/// 
  || line mehrheit eldate, lcolor(gs10) lpattern(solid) lwidth(*2) ///
  || line brcontra eldate, lcolor(black) lpattern(solid)   ///
  || scatter brcontra eldate if tag2 & !btw, mcolor(black) ms(O) ///
  || pcarrow brcontra eldate hbrcontra eldate if tag2 & !btw, lcolor(black) mcolor(black) ///
  || if mehrheit>=21 ///
  , legend(off) ylab(`ylab', valuelabel angle(0) grid gstyle(dot))   ///
  name(g2, replace) title(Votes against Federal Government, box bexpand pos(12))

graph combine g1 g2, xcommon ycommon rows(2)




exit

egen axis1 = axis(eldate area) if tag1, label(unitid) reverse 
egen axis2 = axis(eldate area) if tag2, label(unitid) reverse 


levelsof axis1, local(ylab)
graph twoway 							/// 
  || scatter axis1 diff1, mcolor(black)  ///
  || pcarrow axis1 diff1 axis1 hdiff1, lcolor(black) mcolor(black)  ///
  || if tag1, legend(off) ylab(`ylab', valuelabel angle(0) grid gstyle(dot)) 	///
  ysize(7) xline(0) xlab(-6(1)5) ytitle("")

levelsof axis2, local(ylab)
graph twoway 							/// 
  || scatter axis2 diff2, mcolor(black)  ///
  || pcarrow axis2 diff2 axis2 hdiff2, lcolor(black) mcolor(black)  ///
  || if tag2, legend(off) ylab(`ylab', valuelabel angle(0) grid gstyle(dot)) 	///
  ysize(7) xline(0) xlab(-6(1)5) ytitle("")







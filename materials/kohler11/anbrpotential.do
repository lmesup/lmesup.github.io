// Potential power of state elections
// ----------------------------------
// kohler@wzb.eu

version 10
set more off
set scheme s1mono

// Only State-Elections (without Berlin (West))
use elections, clear
levelsof eldate if area=="DE", local(xlab) // I need this
keep if area != "DE" & brseats > 0

// Define Pro/Contra/Neutral
bysort area eldate: gen npro = sum(regparty==1 & regpartyDE==1)
bysort area eldate: replace npro = npro[_N]

bysort area eldate: gen ncontra = sum(regparty==1 & opppartyDE==1)
bysort area eldate: replace ncontra = ncontra[_N]

bysort area eldate: keep if _n==1

gen status = 1 if npro & !ncontra
replace status = 2 if !npro & ncontra
replace status = 3 if (npro & ncontra) | (!npro & !ncontra)
replace status = 1 if area=="HH" & year(eldate)==1953

// Previous Status
by area, sort: gen lagstatus = status[_n-1]

// Composition of the Bundesrat (this was difficult ...)
keep unitid area eldate brseats status lagstatus 

gen brpro = brseats if status == 1 & lagstatus==.
gen brcontra = brseats if status == 2 & lagstatus==.
gen brneutral = brseats if status == 3 & lagstatus==.

bysort area (eldate): replace brpro = - brseats if status[_n-1]==1 & status!=1
bysort area (eldate): replace brcontra = - brseats if status[_n-1]==2 & status!=2
bysort area (eldate): replace brneutral = - brseats if status[_n-1]==3 & status!=3

bysort area (eldate): replace brpro = brseats if status==1 & status[_n-1]!=1
bysort area (eldate): replace brcontra = brseats if status==2 & status[_n-1]!=2
bysort area (eldate): replace brneutral = brseats if status==3 & status[_n-1]!=3

bysort area (eldate): replace brpro = 0 if status==1 & status[_n-1]==1
bysort area (eldate): replace brcontra = 0 if status==2 & status[_n-1]==2
bysort area (eldate): replace brneutral = 0 if status==3 & status[_n-1]==3

sort eldate area
replace brpro = sum(brpro)
replace brcontra = sum(brcontra)
replace brneutral = sum(brneutral)

// Hessen +1 für Contra wg. Neuer Sitzzahl
replace brcontra = brcontra + 1 if eldate>=date("18Jan1996","DMY")

// Absolute Mehrheit
gen mehrheit = ceil((brcontra+brpro+brneutral)/2)

// Graph the results
// (after Bundesrat was "filled up")

// Perioden
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

format eldate %tdYY
graph twoway 							/// 
  || line mehrheit eldate, lcolor(gs8) lpattern(solid)  ///
  || line brcontra eldate, lcolor(black) lpattern(solid)	lwidth(*1.2) ///
  || line brpro eldate, lcolor(black) lpattern(dash)	lwidth(*1.2)  ///
  || if mehrheit>=21, legend(order(2 "Contra" 3 "Pro"))  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xlab(`xlab')                            ///

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
  || line mehrheit eldate, lcolor(gs8) lpattern(solid)  ///
  || line brpro eldate, lcolor(black) lpattern(solid)  ///
  || scatter brpro eldate if tag1, mcolor(black) ms(O) ///
  || pcarrow brpro eldate hbrpro eldate if tag1, lcolor(black) mcolor(black) ///
  || if year(eldate) > 1960 & year(eldate) < 1995  ///
  , legend(off) ylab(`ylab', valuelabel angle(0) grid gstyle(dot))   ///
  name(g1)
  
graph twoway 							/// 
  || line mehrheit eldate, lcolor(gs8) lpattern(solid)  ///
  || line brcontra eldate, lcolor(black) lpattern(solid)  ///
  || scatter brcontra eldate if tag2, mcolor(black) ms(O) ///
  || pcarrow brcontra eldate hbrcontra eldate if tag2, lcolor(black) mcolor(black) ///
  || if year(eldate) > 1960 & year(eldate) < 1995  ///
  , legend(off) ylab(`ylab', valuelabel angle(0) grid gstyle(dot))   ///
  name(g2)

graph combine g1 g2, xcommon ycommon rows(2)
graph print




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




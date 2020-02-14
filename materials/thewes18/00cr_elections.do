/* Thewes (2018): Prepare elections
----------------------------------------------------------------------------
- Prepare Bundestagswahl 2009: Tournout required for 03gr_maps_bw.do
- Prepare Landtagswahl 2011: Required for Yn-prediction.

Files:
- btw2009.dta: Turnout
- ltw2011.dta: Torunout and party-results

Source: https://www.statistik-bw.de/Wahlen/
----------------------------------------------------------------------------
*/ 

//  BTW 2009
// ----------

import delimited using "data/makro/btw_2009.csv", delimit(";") varnames(1) clear

drop cdu spd fdp

ren wahlberechtigte SB
ren wählerinnen Voter
ren ungültigezweitstimmen invalid 
ren gültigezweitstimmen valid 

gen GKZ = subinstr(word(gemeinde,1),"0","",1)
gen name = substr(gemeinde,10,.)

destring GKZ, replace

gen turnout09 = (Voter/SB) * 100
lab var turnout09 "Wahlbeteiligung BTW 2009"

keep GKZ turnout09

save "data/btw2009", replace



//  LTW 2011
// ----------
import delimited using "data/makro/ltw_2011.csv", delimit(";") varnames(1) clear

ren wahlberechtigte SB
ren wählerinnen Voter
ren ungültigestimmen invalid 
ren gültigestimmen valid 
ren grüne p_gruene
ren dielinke p_linke
ren cdu p_cdu
ren spd p_spd
ren fdp p_fdp

foreach var of varlist volksabstimmung auf big büso dkp rep dievioletten familie npd ödp pbc diepartei piraten rsb einzelbewerber {
	replace `var' = 0 if `var' == .
}
gen p_andere = volksabstimmung + auf + big + büso + dkp + rep + dievioletten + familie + npd + ödp + pbc + diepartei + piraten + rsb + einzelbewerber
lab var p_andere "ANDERE"

gen p_nicht = SB - valid

gen GKZ = subinstr(word(gemeinde,1),"0","",1)
gen name = substr(gemeinde,10,.)

order GKZ name
keep GKZ name SB Voter invalid valid p_*
destring GKZ, replace


foreach var of varlist p_* {
	replace `var' = `var' / SB 
}

gen turnout11 = Voter/SB

keep GKZ p_* turnout11

save "data/ltw2011", replace

exit

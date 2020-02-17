// Non-voters' probability of voting for party i
// ---------------------------------------------
// (kohler@wzb.eu)

version 10
clear
set more off
set matsize 800
set scheme s1mono
use btwsurvey if year(eldate)

// Global Settings
// ---------------

// Periods
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

// Liswise deletion
mark touse
markout touse agegroup emp occ edu bul mar denom polint
keep if touse
drop touse

// Center
by zanr, sort: center polint, standard

// Use two 1949-survey as just one (no non-voters in 2324, no party in 2361)
replace zanr = "2324/2361" if inlist(zanr,"2324","2361")

// Add weights
merge eldate bul using popweights, uniqusing sort
by zanr, sort: gen double pweight = (_N/popweight)^(-1)

// Dummies
xi i.agegroup*c_polint i.emp*c_polint i.occ*c_polint i.edu*c_polint  /// 
  i.bul*c_polint i.mar*c_polint i.denom*c_polint

// Predicit voting behavior of non-voters
// --------------------------------------

tempname CI
postfile `CI' str9 zanr eldate categ Phat3 LB3 UB3 SE3 	/// 
  using anmpred1_ci, replace 

quietly {
	levelsof eldate, local(K)
	foreach k of local K {
		levelsof zanr if eldate==`k' & !mi(party), local(L)
		foreach l of local L {
			noi di as text "Process: Year " as res %tdCCYY `k'  /// 
			  as text " (Survey: " as res "`l'" as text ")"
			
			// Estimate model
			mlogit party _I* [pweight=pweight]	///
			  if eldate==`k' & zanr=="`l'" & voter 	///
			  , base(1)
			
			// Build Vector for -prvalue, x()-  and loop over obs
			local indepnames: colnames e(b)
			local indepnames: list uniq indepnames 
			local indepnames: subinstr local indepnames `"_cons"' `""', all
			
			macro drop _x
			foreach var of local indepnames {
				sum `var' [aw=pweight] 	/// 
				  if !voter & eldate==`k' & zanr=="`l'", meanonly
				local x `"`x' `var'==`=r(mean)'"'
			}
				
			// Estimate and post values
			prvalue, delta x(`x')
			matrix CI = r(pred)
			forv r=1/3 {
				post `CI' ("`l'") (`k')  /// 
				  (`=CI[`r',4]') (`=CI[`r',1]') (`=CI[`r',2]')  /// 
				  (`=CI[`r',3]') (`=CI[`r',5]')
			}
		}
	}
}
postclose `CI'


use anmpred1_ci, clear

// Calculate mean Phat's
// ---------------------

collapse (mean) Phat3 LB3 UB3 SE3 		///
  , by(eldate categ)

// Add real election Data
// ----------------------

gen party3 = "SPD" if categ==1
replace party3 = "CDU/CSU" if categ==2
replace party3 = "Oth" if categ==3
sort eldate party3
tempfile x
save `x'

use elections if area == "DE"
gen party3 = "CDU/CSU" if party == "CDU/CSU"
replace party3 = "SPD" if party == "SPD"
replace party3 = "Oth" if party3 == ""
sort eldate party3
merge eldate party3 using `x'

// Prhatbar for any party
// -----------------------

gen other = party3=="Oth"
by eldate other, sort: gen sumother=sum(ppartyvotes) if other
by eldate other, sort: gen ppartyrescale=ppartyvotes/sumother[_N] if other

gen Phat = Phat3 if !other
replace Phat = ppartyrescale * Phat3 if other

gen UB = Phat3 						/// 
  + 1.96 * SE3 * 						/// 
  (1 + (abs(0.5-Phat3) - abs(0.5 - Phat)) 	/// 
     * (1- (abs(0.5-Phat3) - abs(0.5 - Phat))))
gen LB = Phat3 - 1.96 * SE3 * ///
  (1 + (abs(0.5-Phat3) - abs(0.5 - Phat)) 	/// 
  * (1- (abs(0.5-Phat3) - abs(0.5 - Phat))))

drop other sumother ppartyrescale 

// Graph difference of Non-voters estimators to observed result
// ------------------------------------------------------------

// Only 6 major parties
gen str8 party6 = party if inlist(party,"SPD","CDU/CSU","FDP")
replace party6 = "Linke/PDS" if inlist(party,"Linke","PDS","WASG")
replace party6 = "B90/Gr." if inlist(party,"B90","Gruene","B90/Gr")
replace party6 = "Other" if party6 == ""

egen ppartyvotes6 = sum(ppartyvotes), by(eldate party6)
egen Phat6 = sum(Phat), by(eldate party6)

gen SE6 = SE3 * (1 + (abs(0.5-Phat3) - abs(0.5-Phat6)) 	/// 
  * (1 - (abs(0.5-Phat3) - abs(0.5-Phat6))))

gen UB6 = cond((Phat6 + 1.96*SE6)<1,Phat6 + 1.96*SE6,1)
gen LB6 = cond((Phat6 - 1.96*SE6)>0,Phat6 - 1.96*SE6,0)

gen diff = (Phat6*100) - ppartyvotes6
gen diffUB = (UB6*100) - ppartyvotes6
gen diffLB = (LB6*100) -  ppartyvotes6

lab def party6 1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "B90/Gr."  /// 
5 "Linke/PDS" 6 "Other"
encode party6, gen(party6num) label(party6)

format %tdYY eldate
graph twoway 							///
  || rcap diffUB diffLB eldate, lcolor(black) 	          	///
  || connected diff eldate, ms(O) mcolor(black) 	          	///
  || if Phat != . 					///
  , by(party6num, legend(off) note(""))  ///
  ylab(-20(10)30, grid) ytick(-25(10)25)  ///
  yline(0) 								///
  xline($cdu1 $big $spd1 $cdu2 $spd2, lstyle(grid))

graph export anmpred1_g1.eps, replace


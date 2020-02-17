// Parameters of Changebility one by one

version 10
clear
set memory 128m
set matsize 500
set scheme s1mono

// Perioden
// --------

global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

// Number of parties
// -----------------

use elections, clear
by unitid, sort: keep if _n==1

format eldate %tdYY
levelsof eldate if area=="DE", local(xlab)
graph twoway 							  ///
  || connected nparties1 eldate 		  ///
  , sort lcolor(black) lpattern(solid)    ///
  ms(O) mlcolor(black) mfcolor(gs8) 	  /// 
  || if area == "DE" 					  ///
  , xtitle(Zeit) ytitle(Anzahl Parteien) ytick(0(2)10 , grid)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
 xlab(`xlab')
graph export anparameters_NP1.eps, replace

graph twoway 							  ///
  || connected nparties1 eldate           ///
  , sort lcolor(black) lpattern(solid)	  ///
  ms(O) mlcolor(gs8) mfcolor(black) 	  /// 
  || if area != "DE" 					  ///
  , by(area, note("")) 					  ///
  xtitle(Zeit) ytitle(Anzahl Parteien) 			  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2)
graph export anparameters_NP2.eps, replace

sum pvalid
gen L = ceil(r(max)) - pvalid

pwcorr L nparties1 if area=="DE", sig
pwcorr L nparties1 if area!="DE", sig

sum nparties1 if area=="DE"
sum nparties1 if area!="DE"


// Joint size of others
// --------------------

use elections, clear

by unitid (npartyvotes), sort: keep if _n<_N-1
by unitid (npartyvotes): gen nother = sum(npartyvotes)
gen pother = nother/nvalid*100
by unitid, sort: keep if _n==_N

format eldate %tdYY
levelsof eldate if area=="DE", local(xlab)
graph twoway 							  ///
  || connected pother eldate 			  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(O) mlcolor(black) mfcolor(gs8)       ///
  || if area == "DE" 					  ///
  , xtitle(Zeit) ytitle(Joint size of other parties) ytick(10(5)50 , grid)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
 xlab(`xlab')
graph export anparameters_OthSize1.eps, replace

graph twoway 							  ///
  || connected pother eldate 			  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(O) mlcolor(black) mfcolor(gs8)       ///
  || if area != "DE" 					  ///
  , xtitle(Zeit) ytitle(Joint size of other parties) ylab(0(10)50 , grid)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
  xlab(`xlab')                            ///
  by(area, note("")) 					  
graph export anparameters_OthSize2.eps, replace

  
// GAP
// ---

use elections, clear
by unitid (npartyvotes), sort: gen gap = ppartyvotes[_N]-ppartyvotes[_N-1]
by unitid (npartyvotes), sort: gen winner = ppartyvotes[_N]
by unitid (npartyvotes), sort: gen runnerup = ppartyvotes[_N-1]
by unitid (npartyvotes), sort: gen winnername = party[_N]
by unitid (npartyvotes), sort: gen runnerupname = party[_N-1]
by unitid, sort: keep if _n==1

gen spd = winner if winnername == "SPD"
replace spd = runnerup if runnerupname == "SPD"
gen cdu = winner if winnername == "CDU/CSU"
replace cdu = runnerup if runnerupname == "CDU/CSU"

format eldate %tdYY
levelsof eldate if area=="DE", local(xlab)
graph twoway 							  ///
  || connected cdu eldate 			      ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(O) mlcolor(black) mfcolor(black)     ///
  || connected spd eldate 			      ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(O) mlcolor(black) mfcolor(white)     ///
  || if area == "DE" 					  ///
  ,  legend(order(1 "CDU/CSU" 2 "SPD") rows(1) pos(1) ring(0))  ///
  xtitle(Zeit) ytitle(Valid votes in %) ytick(30(2.5)50 , grid)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
  xtick(`xlab') xlabe(none) xtitle("")    ///
  ytitle("Gültige Stimmen (in %)") 		///
  name(g1, replace) nodraw

graph twoway 							     ///
  || line gap eldate 				         ///
  , sort lcolor(black) lpattern(solid)       ///
  || sc gap eldate if winnername=="CDU/CSU"  ///
  , ms(O) mlcolor(black) mfcolor(black) 	 ///
  || sc gap eldate if winnername=="SPD"      ///
  , ms(O) mlcolor(black) mfcolor(white) 	 ///
  || if area == "DE" 					     ///
  ,  legend(order(2 "Wahlsieger CDU/CSU" 3 "Wahlsieger SPD")  /// 
  pos(1) ring(0) rows(1))                    ///
  xtitle(Zeit) ytitle("Vorsprung (in %)")  /// 
  ytick(0(5)20 , grid) ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	     ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
  xlab(`xlab') 							     ///
  name(g2, replace) nodraw
graph combine g1 g2, cols(1)
graph export anparameters_G1.eps, replace

graph twoway 							      ///
  || line gap eldate 				          ///
  , sort lcolor(black) lpattern(solid)        ///
  || sc gap eldate if winnername=="CDU/CSU"   ///
  , ms(O) mlcolor(black) mfcolor(black) 	  ///
  || sc gap eldate if winnername=="SPD"       ///
  , ms(O) mlcolor(black) mfcolor(white) 	  ///
  || sc gap eldate if !inlist(winnername,"SPD","CDU/CSU")  ///
  , ms(O) mlcolor(black) mfcolor(gs8) 	      ///
  || if area != "DE", by(area, note("")) 	  /// 
  legend(order(2 "Wahlsieger CDU/CSU" 3 "Wahlsieger SPD" 4 "Anderer Wahlsieger")  /// 
  rows(1))  ///
  xtitle(Zeit) ytitle("Vorsprung (in %)") ytick(0(10)40 , grid) ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 
graph export anparameters_G2.eps, replace

sum pvalid
gen L = ceil(r(max)) - pvalid

pwcorr L gap if area=="DE", sig
pwcorr L gap if area!="DE", sig

sum gap if area== "DE"
sum gap if area!= "DE"

// Leverage
// --------

use elections, clear
by unitid, sort: keep if _n==1

sum pvalid
gen L = ceil(r(max)) - pvalid

format eldate %tdYY
levelsof eldate if area=="DE", local(xlab)
graph twoway 							  ///
  || connected L eldate 			  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(O) mlcolor(black) mfcolor(gs8)       ///
  || if area == "DE" 					  ///
  , xtitle(Zeit) ytitle(Hebel (in %)) ylab(0(10)50 , grid)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
  xlab(`xlab') 							///
  text(48 `=date("1jan1957","DMY")' "CDU geführte" "Regierungen"  /// 
  , justification(center)) 				/// 
  text(48 `=date("1jan1976","DMY")' "Sozialliberale" "Koalition"  /// 
  , justification(center)) 				/// 
  text(48 `=date("1jun1990","DMY")' "Ära Kohl"  /// 
  , justification(center)) 				/// 
  text(48 `=date("1jun2001","DMY")' "Rot-" "Grün"  /// 
  , justification(center)) 				
graph export anparameters_L1.eps, replace

graph twoway 							  ///
  || connected L eldate 			  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(O) mlcolor(black) mfcolor(gs8)       ///
  || if area != "DE" 					  ///
  , xtitle(Zeit) ytitle(Hebel (in %)) ylab(0(10)50 , grid)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xlab(`xlab', alternate)                 ///
  by(area, note("")) 					  
graph export anparameters_L2.eps, replace


pwcorr L eldate if area == "DE", sig
pwcorr L eldate if area == "DE" & year(eldate) > 1949, sig

pwcorr L eldate if area != "DE", sig

// Preferences of non-voters
// -------------------------

use btwsurvey, clear

quietly {

	// Dummies
	xi i.agegroup*polint i.emp*polint i.occ*polint i.edu*polint  /// 
	  i.bul*polint i.mar*polint i.denom*polint 
	
	
	// Predicit voting behavior of non-voters
	tempname results
	tempfile x
	postfile `results' eldate str3 party delta using `x'
	levelsof eldate, local(K)
	foreach k of local K {
		mlogit party _I* if eldate==`k'
		predict PhatCDU PhatSPD PhatOth if eldate == `k'
		
		reg PhatSPD voter
		post `results' (`k') ("CDU"') (-_b[voter])
		reg PhatCDU voter
		post `results' (`k') ("SPD"') (-_b[voter])
		reg PhatOth voter
		post `results' (`k') ("Oth"') (-_b[voter])
		drop Phat*
	}
	postclose `results'
}

use `x', clear
format eldate %tdYY
replace delta = delta*100

levelsof eldate, local(xlab)
graph twoway 							///
  || connected delta eldate if party == "CDU"  ///
  , ms(O) mcolor(black)                 ///
  || connected delta eldate if party == "SPD"  ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || connected delta eldate if party == "Oth"  ///
  , ms(O) mlcolor(black) mfcolor(gs8)  ///
  || , xtitle(Zeit) ytitle(Prozentsatzdifferenz Stimmanteile) 	///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xlab(`xlab') 							 ///          
  yline(0) ylab(, grid) ///       
  legend(order(1 "CDU/CSU" 2 "SPD" 3 "Andere") rows(1))
graph export anparameters_deltabtw.eps, replace


clear
use ltwsurvey, clear

quietly {

	// Dummies
	xi i.agegroup i.emp i.occ i.edu i.mar i.denom 
	
	
	// Predicit voting behavior of non-voters
	tempname results
	tempfile x
	postfile `results' eldate str2 area str3 party delta  using `x'
	
	levelsof area, local(L)	
	foreach l of local L {
		levelsof eldate if area=="`l'", local(K)
		foreach k of local K {
			mlogit party _I* if eldate==`k' & area=="`l'"
			predict PhatCDU PhatSPD PhatOth if eldate == `k' & area=="`l'"
			
			reg PhatSPD voter
			post `results' (`k') ("`l'") ("CDU"') (-_b[voter])
			reg PhatCDU voter
			post `results' (`k') ("`l'") ("SPD"') (-_b[voter])
			reg PhatOth voter
			post `results' (`k') ("`l'") ("Oth"') (-_b[voter])
			drop Phat*
	
		}
	}
	postclose `results'
}

use `x', clear
format eldate %tdYY
replace delta = delta*100

//levelsof eldate, local(xlab)

graph twoway 							///
  || connected delta eldate if party == "CDU"  			///
  , ms(O) mcolor(black)                				///
  || connected delta eldate if party == "SPD" 			///
  , ms(O) mlcolor(black) mfcolor(white) 			///
  || connected delta eldate if party == "Oth"  			///
  , ms(O) mlcolor(black) mfcolor(gs8)  				///
  || , xtitle(Zeit) ytitle(Prozentsatzdifferenz Stimmanteile) 	///
  xlab(#9) 							/// 
  yline(0) 							///
  ylab(, grid) 							/// 
  legend(order(1 "CDU/CSU" 2 "SPD" 3 "Andere") rows(1))  ///	
  by(area, note(""))	///
  
graph export anparameters_deltaltw.eps, replace

tab party, sum(delta)


// Vertretungsgewichte
// -------------------

use elections, clear

bysort area eldate: gen SEATS = sum(seats)
bysort area eldate: replace SEATS = SEATS[_N]
drop if seats == 0

bysort area eldate, sort: replace nvalid = sum(npartyvotes)
bysort area eldate, sort: replace nvalid = nvalid[_N]

gen vertretungsgewicht = npartyvotes/seats 
lab var vertretungsgewicht "Vertretungsgewicht"

replace party = "PDS/Linke" if inlist(party,"PDS","Linke")
replace party = "Gruene" if inlist(party,"Gruene","B90/Gr")

format eldate %tdYY
levelsof eldate if area=="DE", local(xlab)
graph twoway 							  ///
  || connected vertretungsgewicht eldate if party == "CDU/CSU"  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(T) mlcolor(black) mfcolor(black) msize(*1.5)    /// 
  || connected vertretungsgewicht eldate if party == "SPD"  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(O) mlcolor(black) mfcolor(white)   /// 
  || connected vertretungsgewicht eldate if party == "FDP"  ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(T) mlcolor(black) mfcolor(gs8)     ///
  || connected vertretungsgewicht eldate if party == "Gruene"  ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(S) mlcolor(black) mfcolor(white)     ///
  || connected vertretungsgewicht eldate if party == "PDS/Linke"  & seats > 2 ///
  , sort lcolor(black) lpattern(dot)     ///
  ms(O) mlcolor(black) mfcolor(gs8)     ///
  || if area == "DE" 					///
  ,  legend(order(1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "Gruene" 5 "PDS/Linke")  ///
  rows(2))  ///
  ytitle(Vertretungsgewicht)  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xlab(`xlab') 
graph export anparameters_vertretungsgewichtbtw.eps, replace

replace vertretungsgewicht = vertretungsgewicht/1000
graph twoway 							  ///
  || connected vertretungsgewicht eldate if party == "CDU/CSU"  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(t) mlcolor(black) mfcolor(black) msize(*1.5)    /// 
  || connected vertretungsgewicht eldate if party == "SPD"  ///
  , sort lcolor(black) lpattern(solid)     ///
  ms(o) mlcolor(black) mfcolor(white)   /// 
  || connected vertretungsgewicht eldate if party == "FDP"  ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(t) mlcolor(black) mfcolor(gs8)     ///
  || connected vertretungsgewicht eldate if party == "Gruene"  ///
  , sort lcolor(black) lpattern(dash)     ///
  ms(s) mlcolor(black) mfcolor(white)     ///
  || connected vertretungsgewicht eldate if party == "PDS/Linke"  ///
  , sort lcolor(black) lpattern(dot)     ///
  ms(o) mlcolor(black) mfcolor(gs8)     ///
  || if area != "DE" 					///
  ,  by(area, note("")) 							/// 
  legend(order(1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "Gruene" 5 "PDS/Linke")  ///
  rows(2))  ///
  ytitle(Vertretungsgewicht (in 1000))  ///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	/// 	  
  xlab(`xlab', alternate) 
graph export anparameters_vertretungsgewichtltw.eps, replace


// Coalitions
// ----------

use elections if seats != . , clear

by area eldate (seats), sort: gen SEATS = sum(seats)
by area eldate (seats): replace SEATS = SEATS[_N]
gen pseats = seats/SEATS * 100

by area eldate (seats): 		/// 
  gen minderheit = sum(pseats*regparty)
by area eldate (seats): 		/// 
  replace minderheit = minderheit[_N] <= 50

by area eldate (seats): 	/// 
  gen coalition = sum(regparty)
by area eldate (seats): 		///
  replace coalition = coalition[_N]>1

by area eldate (seats): 	/// 
  gen coalitiontype = regparty[_N]==1 if coalition & !minderheit

replace coalitiontype = 2 if !coalition & !minderheit
replace coalitiontype = 3 if minderheit

by area eldate (ppartyvotes), sort: keep if _n==1

gen fdate = eldate
by area (eldate), sort: gen ldate = eldate[_n+1]
replace ldate = `=date("`=c(current_date)'","DMY")' if ldate==.

by area (eldate): gen epi = sum(coalitiontype!=coalitiontype[_n-1])

by area epi, sort: gen begin = fdate[1]
by area epi, sort: gen end  = ldate[_N]

gen ltw = area!="DE"
gen east = inlist(area,"MV","BB","TH","ST","SN")
egen axis = axis(ltw east area), label(area) gap reverse

format %dYY begin end
levelsof eldate if area=="DE", local(xlab)
levelsof axis, local(K)
graph twoway 							///
  || rbar begin end axis if coalitiontype==1  ///
  , horizontal lcolor(black) fcolor(gs4) lstyle(p1) barwidth(0.75) ///
  || rbar begin end axis if coalitiontype==0 ///
  , horizontal lcolor(black) fcolor(gs12) lstyle(p1) barwidth(0.75) ///
  || rbar begin end axis if coalitiontype==2 ///
  , horizontal lcolor(black) fcolor(black) lstyle(p1) barwidth(0.75) ///
  || rbar begin end axis if coalitiontype==3 ///
  , horizontal lcolor(black) fcolor(white) lstyle(p1) barwidth(0.75) ///
  || , ylab(`K', valuelabel angle(0)) 		///
  xtitle(Zeit) ytitle("") 	///
  xline($cdu1 $big $spd1 $cdu2 $spd2) 	  ///
  xlab(`xlab') 							 ///          
  yline(0) ylab(, grid) ///       
  legend(order(3 "Alleinregierung" 1 "Regierungsauftrag" 	/// 
  2 "Koalitionszusage"  4 "Minderheitsregierung") rows(2) span)  ///
  ysize(5)
graph export anparameters_coalition.eps, replace


exit



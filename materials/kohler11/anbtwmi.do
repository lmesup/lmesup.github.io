// Probability of Change in O for BTW
// ----------------------------------
// (kohler@wzb.eu)

version 10
clear
set matsize 800
set scheme s1mono
use btwsurvey


// Prhatbar
// --------

foreach var of varlist 				/// 
  party agegroup emp occ edu bul mar denom {
	tab `var', gen(`var'_)
}

foreach var of varlist 				/// 
    agegroup_* emp_* occ_* edu_* bul_* mar_* denom_* {
	gen `var'polint = `var'*polint
}


ice party* agegroup* emp_* edu* bul_* occ_* mar* denom* polint  ///
  if year(eldate)==2002 , passive( 								///
  party_1: party==1 \party_2: party==2 \party_3: party==3  ///
  \agegroup_1: agegroup==1 \agegroup_2: agegroup==2 \agegroup_3: agegroup==3  ///  
  \edu_1: edu==1 \edu_2: edu==2 \edu_3: edu==3 	///
  \mar_1: mar==1 \mar_2: mar==2 \mar_3: mar==3 	///
  \denom_1: denom==1 \denom_2: denom==2 \denom_3: denom==3 	///
  \party_1: party==1 \party_2: party==2 \party_3: party==3  ///
  \agegroup_1polint: agegroup_1*polint \agegroup_2polint: agegroup_2*polint \agegroup_3polint: agegroup_3*polint  ///  
  \emp_1polint: emp_1*polint \emp_2polint: emp_2*polint \emp_3polint: emp_3*polint \emp_4polint: emp_4*polint \emp_5polint: emp_5*polint \emp_6polint: emp_6*polint  ///
  \occ_1polint: occ_1*polint \occ_2polint: occ_2*polint \occ_3polint: occ_3*polint \occ_4polint: occ_4*polint  /// 
  \edu_1polint: edu_1*polint \edu_2polint: edu_2*polint \edu_3polint: edu_3*polint 	///
  \bul_1polint: bul_1*polint \bul_2polint: bul_2*polint \bul_3polint: bul_3*polint 	///
  \bul_4polint: bul_4*polint \bul_5polint: bul_5*polint \bul_6polint: bul_6*polint 	///
  \bul_7polint: bul_7*polint \bul_8polint: bul_8*polint \bul_9polint: bul_9*polint 	///
  \bul_10polint: bul_10*polint \bul_11polint: bul_11*polint \bul_12polint: bul_12*polint 	///
  \mar_1polint: mar_1*polint \mar_2polint: mar_2*polint \mar_3polint: mar_3*polint 	///
  \denom_1polint: denom_1*polint \denom_2polint: denom_2*polint \denom_3polint: denom_3*polint) ///
  substitute( 								///
  party: party_1 party_2 party_3, 		/// 
  agegroup:  agegroup_1  agegroup_2  agegroup_3,  ///  
  edu: edu_1  edu_2  edu_3, 	///
  mar: mar_1  mar_2  mar_3, 	///
  denom:   denom_2  denom_3) 	///
  eq(party: agegroup_2 agegroup_3 	/// 
  emp_2 emp_3 emp_4 emp_5 emp_6 	/// 
  bul_2 bul_3 bul_4 bul_5 bul_6 bul_7 bul_8 bul_9 bul_10 bul_11 bul_12 	///
  occ_2 occ_3 occ_4 mar_1 mar_2 mar_3 denom_2 denom_3 polint ///
  agegroup_2polint agegroup_3polint 	/// 
  emp_2polint emp_3polint emp_4polint emp_5polint emp_6polint 	/// 
  bul_2polint bul_3polint bul_4polint bul_5polint bul_6polint /// 
  bul_7polint bul_8polint bul_9polint bul_10polint bul_11polint bul_12polint 	///
  occ_2polint occ_3polint occ_4polint mar_1polint mar_2polint mar_3polint /// 
  denom_2polint denom_3polint polint, ///
  agegroup: party_2 party_3 	/// 
  emp_2 emp_3 emp_4 emp_5 emp_6 	/// 
  edu_2 edu_3 bul_2 bul_3 bul_4 bul_5 bul_6 bul_7 bul_8 bul_9 bul_10 bul_11 bul_12 	///
  occ_2 occ_3 occ_4 mar_1 mar_2 mar_3 denom_2 denom_3 polint , ///
  edu: agegroup_2 agegroup_3 party_2 party_3 	/// 
  emp_2 emp_3 emp_4 emp_5 emp_6 	/// 
  bul_2 bul_3 bul_4 bul_5 bul_6 bul_7 bul_8 bul_9 bul_10 bul_11 bul_12 	///
  occ_2 occ_3 occ_4 mar_1 mar_2 mar_3 denom_2 denom_3 polint, ///
  mar: agegroup_2 agegroup_3 party_2 party_3 	/// 
  emp_2 emp_3 emp_4 emp_5 emp_6 	/// 
  edu_2 edu_3 bul_2 bul_3 bul_4 bul_5 bul_6 bul_7 bul_8 bul_9 bul_10 bul_11 bul_12 	///
  occ_2 occ_3 occ_4 mar_1 mar_2 denom_2 denom_3 polint , ///
  denom: agegroup_2 agegroup_3 party_2 party_3 	/// 
  emp_2 emp_3 emp_4 emp_5 emp_6 	/// 
  edu_2 edu_3 bul_2 bul_3 bul_4 bul_5 bul_6 bul_7 bul_8 bul_9 bul_10 bul_11 bul_12 	///
  occ_2 occ_3 occ_4 mar_1 mar_2 mar_3 polint , ///
  polint: agegroup_2 agegroup_3 party_2 party_3 	/// 
  emp_2 emp_3 emp_4 emp_5 emp_6 	/// 
  edu_2 edu_3 bul_2 bul_3 bul_4 bul_5 bul_6 bul_7 bul_8 bul_9 bul_10 bul_11 bul_12 	///
  occ_2 occ_3 occ_4 mar_1 mar_2 mar_3 denom_2 denom_3) ///
  seed(731) saving(11, replace) m(5)









// Predicit voting behavior of non-voters
tempname results
tempfile x
postfile `results' eldate str3 party3 Prhatbar using `x'
levelsof eldate, local(K)
foreach k of local K {






	
	mlogit party _I* if eldate==`k'
	predict PhatCDU PhatSPD PhatOth if eldate == `k'
	
	sum PhatSPD if !voter
	post `results' (`k') ("SPD"') (r(mean))
	sum PhatCDU if !voter
	post `results' (`k') ("CDU"') (r(mean))
	sum PhatOth if !voter
	post `results' (`k') ("Oth"') (r(mean))

		drop Phat*
	}
	postclose `results'
}

// Merge Election-Dataset
// ----------------------

use `x', clear
sort eldate party3
save `x', replace

use elections if area == "DE"

gen party3 = "CDU" if party == "CDU/CSU"
replace party3 = "SPD" if party == "SPD"
replace party3 = "Oth" if party3 == ""

sort eldate party3
merge eldate party3 using `x'
assert _merge==3
drop _merge


// Prhatbar for Other Parties
// --------------------------

gen other = party3=="Oth"
by eldate other, sort: gen sumother=sum(ppartyvotes) if other
by eldate other, sort: gen ppartyrescale=ppartyvotes/sumother[_N] if other
replace Prhatbar = ppartyrescale * Prhatbar if other

drop other sumother ppartyrescale 

// Voteshat Nonvoter
// -----------------

sum pvalid, meanonly
gen L = ceil(r(max)) - pvalid
gen npartyvoteshat_nonvoter = Prhatbar * L/100 * nelectorate


// Voteshat
// --------

gen voteshat = npartyvotes + npartyvoteshat_nonvoter


// Mandatszuteilung
// ----------------

// 1949a -> counterfactual observed distribution of seats
egen x = prseats(npartyvotes) 			/// 
if year(eldate)==1949  /// unverb. Listen CDU/CSU +1, SPD +1
  , s(400) threshold(5) g(party,"Zentrum","DP","BP","WAV","SSW","DKP/DRP") 	/// 
  method(divisor)
replace seats = x if year(eldate)==1949

// 1949b -> counterfactual estimated distribution of seats
drop x
egen x = prseats(votes) 			/// 
if year(eldate)==1949  /// unverb. Listen CDU/CSU +1, SPD +1
  , s(400) threshold(5) g(party,"Zentrum","DP","BP","WAV","SSW","DKP/DRP") 	/// 
  method(divisor)
gen mhat = x if year(eldate)==1949

// 1953
drop x
egen x = prseats(voteshat) if year(eldate)==1953  /// CDU/CSU +2,  DP +1
  , s(484) threshold(5) g(party,"Zentrum","DP") method(divisor) 
replace x = x + 2 if party == "CDU/CSU" & year(eldate)==1953
replace x = x + 1 if party == "DP" & year(eldate)==1953
replace mhat = x if mhat==.

// 1957
drop x
egen x = prseats(voteshat) if year(eldate)==1957  /// CDU/CSU +3
  , s(494) threshold(5) g(party,"DP") method(divisor) 
replace x = x + 3 if party == "CDU/CSU" & year(eldate)==1957
replace mhat = x if mhat==.

// 1961
drop x
egen x = prseats(voteshat) if year(eldate)==1961  /// CDU/CSU +5 
  , s(494) threshold(5) method(divisor)
replace x = x + 5 if party == "CDU/CSU" & year(eldate)==1961
replace mhat = x if mhat==.

// 1965-1983
drop x
bysort eldate: egen x = prseats(voteshat)  /// 
  if inrange(year(eldate),1965,1983)          /// Note 1
  , s(496) threshold(5) method(divisor)
replace x = x + 1 if party == "SPD" & year(eldate)==1980
replace x = x + 2 if party == "SPD" & year(eldate)==1983
replace mhat = x if mhat==.

// 1987
drop x
egen x = prseats(voteshat) if year(eldate)==1987 /// CDU/CSU +1
  , s(496) threshold(5) method(hamilton) 
replace x = x + 1 if party == "CDU/CSU" & year(eldate)==1987
replace mhat = x if mhat==.

// 1990
drop x
egen x = prseats(voteshat) 			/// 
  if year(eldate)==1990	/// getrennte 5% Klausel in Ost/West, 6 CDU/CSU Ueberhang
  , s(656) threshold(5) g(party,"B90/Gr","PDS") method(hamilton)
replace x = x + 6 if party == "CDU/CSU" & year(eldate)==1990
replace mhat = x if mhat==.

// 1994
drop x
bysort eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==1994 /// Note 2
  , s(656) g(party,"PDS") threshold(5) method(hamilton) 
replace x = x + 12 if party == "CDU/CSU" & year(eldate)==1994
replace x = x + 4 if party == "SPD" & year(eldate)==1994
replace mhat = x if mhat==.

// 1998
drop x
bysort eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==1998 /// Note 2
  , s(656) threshold(5) method(hamilton) 
replace x = x + 13 if party == "SPD" & year(eldate)==1998
replace mhat = x if mhat==.

// 2002
drop x
bysort eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==2002 /// CDU/CSU +1, SPD +4
  , s(596) threshold(5)  method(hamilton) 
replace x = x + 1 if party == "CDU/CSU" & year(eldate)==2002
replace x = x + 4 if party == "SPD" & year(eldate)==2002
replace x = 2 if party == "PDS" & year(eldate)==2002
replace mhat = x if mhat==.

// 2005
drop x
bysort eldate: egen x = prseats(voteshat)  /// 
  if year(eldate)==2005 ///  SPD +10, CDU/CSU +7
  , s(598) threshold(5)  method(hamilton) 
replace x = x + 7 if party == "CDU/CSU" & year(eldate)==2005
replace x = x + 10 if party == "SPD" & year(eldate)==2005
replace mhat = x if mhat==.
drop x
replace mhat = 0 if mhat==.

// Perioden
// --------

format eldate %dYY
global cdu1 = date("30.11.1966","DMY")
global big = date("21.10.1969","DMY")
global spd1 = date("1.10.1982","DMY")
global cdu2 = date("26.10.1998","DMY")
global spd2 = date("18.10.2005","DMY")

// Difference in Seats Graph
// -------------------------

gen mdiff = mhat - seats

levelsof eldate, local(K)
graph twoway ///
  || scatter mdiff eldate  ///
  if !inlist(party,"CDU/CSU","SPD","FDP","B90/Gr","Gruene","PDS","Linke") ///
  & seats != 0                                                          ///
  , ms(o) mcolor(gs8)			                                          ///
  || connected mdiff eldate if party=="CDU/CSU" 	                     ///
  , lcolor(black) lpattern(solid) ms(T) mfcolor(black) mlcolor(black)   ///
  || connected mdiff eldate if party=="SPD" 	                           ///
  , lcolor(black) lpattern(solid) ms(O) mfcolor(white) mlcolor(black)   ///
  || connected mdiff eldate if party=="FDP" 	                           ///
  , lcolor(black) lpattern(solid) ms(T) mfcolor(gs8) mlcolor(black)   ///
  || connected mdiff eldate if party=="B90/Gr" | party=="Gruene"        ///
  , lcolor(black) lpattern(solid) ms(S) mfcolor(white) mlcolor(black)  	///
  || connected mdiff eldate if party=="PDS" | party=="Linke"            ///
  , lcolor(black) lpattern(solid) ms(O) mfcolor(gs8) mlcolor(black) 	///
  || , legend(rows(2)                                                   ///
  order(2 "CDU/CSU" 3 "SPD" 4 "FDP" 5 "B90/Gr." 6 "PDS/Linke" 1 "Sonst."))  ///
  yline(0) ylab(, grid) ytitle(Mandatsgewinne bzw. Mandatsverluste) ///
  xlab(`K') xline($cdu1 $big $spd1 $cdu2 $spd2) xtitle(Zeit) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) 
graph export anbtw_1.eps, replace


// Wechsel des Regierungsauftrags
// ------------------------------

preserve
keep if inlist(party,"CDU/CSU","SPD")
by eldate (party), sort: gen majordiff = seats[1]-seats[2]
by eldate (party), sort: gen majorhatdiff = mhat[1]-mhat[2]

levelsof eldate, local(K)
graph twoway ///
  || pcarrow majordiff eldate majorhatdiff eldate  /// 
  if inlist(party,"CDU/CSU","SPD")  ///
  , lcolor(black) mcolor(black)  ///
  || connected majordiff eldate ///
  , lcolor(black) lpattern(solid) ms(O) mlcolor(black) mfcolor(black)  ///
  || ,                                                    ///
  yline(0) ylab(, grid) ytitle("Differenz Mandate (CDU/CSU - SPD)") ///
  xlab(`K') xline($cdu1 $big $spd1 $cdu2 $spd2) xtitle(Zeit) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
  legend(off)
graph export anbtw_2.eps, replace
restore

// Loss of absolute majority
// -------------------------

by eldate, sort: gen SEATS = sum(seats)
by eldate, sort: replace SEATS = SEATS[_N]

drop if !regparty
by eldate, sort: gen govseats = sum(seats)
by eldate, sort: replace govseats = govseats[_N]

by eldate, sort: gen govmhat = sum(mhat)
by eldate, sort: replace govmhat = govmhat[_N]

by eldate, sort: keep if _n==1

gen govdiff = govseats - (int(SEATS/2) + 1)
gen govdiffhat = govmhat - (int(SEATS/2) +1)

levelsof eldate, local(K)
graph twoway ///
  || pcarrow govdiff eldate govdiffhat eldate   ///
  , lcolor(black) mcolor(black)  ///
  || connected govdiff eldate ///
  , lcolor(black) lpattern(solid) ms(o) mlcolor(black) mfcolor(black)  /// ///
  || if govdiff < 75  ///
   , legend(off) xlab(`K') ///
  xlab(`K') xline($cdu1 $big $spd1 $cdu2 $spd2) xtitle(Zeit) 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
  legend(off) ///
  ylab(0(10)70) yline(0) name(g1, replace) nodraw

graph twoway ///
  || pcarrow govdiff eldate govdiffhat eldate   ///
  , lcolor(black) mcolor(black)  ///
  || connected govdiff eldate ///
  , lcolor(black) lpattern(solid) ms(o) mlcolor(black) mfcolor(black)  /// ///
  || if govdiff > 75  ///
   , legend(off) xlab(`K') ///
  xlab(none) xline($cdu1 $big $spd1 $cdu2 $spd2) xtitle("") 	  ///
  xscale(range(`=date("23.5.1949","DMY")' `=date("`c(current_date)'","DMY")')) ///
  legend(off) ///
  ylab(135 141) fysize(10) name(g2, replace) nodraw

graph combine g2 g1, rows(2) imargin(b=0 t=0)  ///
  l1title(Mandate Regierungskoalition - abs. Mehrheit) 
graph export anbtw_3.eps, replace



  
  

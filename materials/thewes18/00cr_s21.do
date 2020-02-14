/* Thewes (2018): Prepare Election-Data
----------------------------------------------------------------------------
- Official S21-results
- postal votes are distributed on constituencies
- aggregate constituencies to municipality-level
- combine with shape-data (pr_maps.do) to create distance-var
- merge macro-data (00cr_makro.do)
- merge election-data (00cr_elections.do)

Files:
- s21.dta:  voting-results on municipality-level with distance and macro-data
            Source: BW_20111127_Stuttgart21.xls: Statistisches Landesamt Baden-Württemberg
            IMPORTANT: no free access!
- ind_dist: distance for municipality-names. Needed for individual data.
----------------------------------------------------------------------------
*/ 

import excel  ///
  KKZ KName GKZ GName Art SBezNum SBez SB SBo SBA2 SBA3	Voter VoterA invalid valid ja nein ///
  using "data/makro/BW_20111127_Stuttgart21.xls",  clear cellrange(A2:Q9954)

// CLEANING
keep GKZ GName SBezNum SB Voter valid ja

replace GKZ = subinstr(GKZ,"0","",1)


* ----------proportional apportion for postal-vote-GKZs --------------

gen kb = GName == "Briefwahl für mehrere Gemeinden"

replace GKZ = "8336991a" if SBezNum == "079-90" & kb
replace GKZ = "8336991b" if SBezNum == "081-90" & kb
replace GKZ = "8336991c" if SBezNum == "103-90" & kb
replace GKZ = "8336991d" if SBezNum == "008-90" & kb

replace GKZ = "8425991a" if SBezNum == "888-90" & kb
replace GKZ = "8425991b" if SBezNum == "777-90" & kb
replace GKZ = "8425991c" if SBezNum == "999-90" & kb

replace GKZ = "8316991a" if SBezNum == "900-99" & kb
replace GKZ = "8316991b" if SBezNum == "900-01" & GKZ == "8316991"

gen gkz8117991 = inlist(GKZ,"8117016","8117031","8117058")
gen gkz8136991 = inlist(GKZ,"8136020","8136049")
gen gkz8226991 = inlist(GKZ,"8226080","8226027")
gen gkz8237991 = inlist(GKZ,"8237054","8237032","8237072")
gen gkz8316991a = inlist(GKZ,"8316012","8316013")
gen gkz8316991b = inlist(GKZ,"8316003","8316010")
gen gkz8327991 = inlist(GKZ,"8327004","8327005","8327006","8327007","8327008","8327012","8327013")
  replace gkz8327991 = 1 if inlist(GKZ,"8327020","8327023","8327027","8327029","8327033","8327040","8327041")
gen gkz8336991a = inlist(GKZ,"8336079","8336080","8336025","8336010","8336004","8336090","8336094","8336096","8336089")
gen gkz8336991b = inlist(GKZ,"8336034","8336081")
gen gkz8336991c = inlist(GKZ,"8336103","8336106")
gen gkz8336991d = inlist(GKZ,"8336008","8336024","8336075","8336100")
gen gkz8337991 = inlist(GKZ,"8337059","8337097")
gen gkz8415991 = inlist(GKZ,"8415028","8415048")
gen gkz8417991 = inlist(GKZ,"8417014","8417029","8417047","8417071","8417078","8417052")
gen gkz8425991a = inlist(GKZ,"8425022","8425024","8425035","8425036","8425050","8425052","8425055","8425062","8425064")
  replace gkz8425991a = 1 if inlist(GKZ,"8425073","8425073","8425079","8425083","8425085")
  replace gkz8425991a = 1 if inlist(GKZ,"8425088","8425090","8425091","8425092","8425093")
gen gkz8425991b = inlist(GKZ,"8425004","8425005","8425008","8425011","8425013","8425014","8425140","8425019")
gen gkz8425991c = inlist(GKZ,"8425097","8425098","8425104","8425110","8425112","8425123")
  replace gkz8425991c = 1 if inlist(GKZ,"8425124","8425125","8425130","8425134","8425135")
gen gkz8426991 = inlist(GKZ,"8426005","8426006","8426020","8426011","8426036","8426043","8426064","8426078","8426090")
  replace gkz8426991 = 1 if inlist(GKZ,"8426109","8426113","8426118","8426135")
gen gkz8436991 = inlist(GKZ,"8436005","8436019","8436024","8436027","8436032","8436067","8436040","8436047","8436053")
  replace gkz8436991 = 1 if inlist(GKZ,"8436077","8436093")


gen oldvalid = valid
qui foreach x in 8117991 8136991 8226991 8237991 8316991a 8316991b 8327991 8336991a 8336991b 8336991c 8336991d 8337991 8415991 8417991 8425991a 8425991b 8425991c 8426991 8436991 { 
  // ---VOTES---
  // Total voters in GKZs 
  bysort gkz`x': egen sumSB`x' = sum(SB) if gkz`x'
  
  // Total postal voters in postal-GKZs (to apportion)
  sum Voter if GKZ == "`x'", meanonly
  gen addvotes`x' = r(mean) if gkz`x'
  replace addvotes`x' = round(addvotes`x' * (SB / sumSB`x')) if gkz`x'

  // Allocate postal voters
  replace Voter = Voter + addvotes`x' if gkz`x'
  replace valid = valid + addvotes`x' if gkz`x'

  // ---YES---
  // Total Yes-votes
  gen result = ja/oldvalid if gkz`x'
  sum result, meanonly
  replace result = result*1/r(sum)

  sum SB, meanonly
  gen SBw = SB*1/r(sum)

  gen wgt = result*SBw
  sum wgt, meanonly
  replace wgt = wgt*1/r(sum)

  bysort gkz`x': egen sumja`x' = sum(ja) if gkz`x'

  // Total Yes-voters in postal-GKZs (to apportion)
  sum ja if GKZ == "`x'", meanonly
  gen addja`x' = r(mean) if gkz`x'

  replace addja`x' = round(addja`x' * wgt) if gkz`x'

  // Allocate Yes-votes 
  replace ja = ja + addja`x' if gkz`x'

  // Cleaning
  drop *`x' result SBw wgt
}

drop if substr(GName,1,9) =="Briefwahl"   // umlaut-problem

destring GKZ, replace

// Aggregat
collapse (sum) Voter (sum) SB (sum) ja (sum) valid, by(GKZ GName)

// Results
gen double turnout = Voter / SB * 100
lab var turnout "Wahlbeteiligung S21"

gen yes = ja / valid * 100
lab var yes "Zustimmung in %"

tempfile results
save `results', replace


* Open Shape-Data and merge results
* ---------------------------------

use "data/shp/utm32_de_data", clear
destring AGS, gen(GKZ)

// CLEANING:
// Only BW
keep if inrange(GKZ,8000000,8999999)

// Municipalities "Gutsbezirk Münsingen" and "Rheinau": uninhabited
drop if inlist(GKZ,8415086,8317971)


// Merge S21-Voting-Data
merge m:1 GKZ using `results', nogen


// Distance
sum x_center if GEN == "Stuttgart", meanonly
local x = r(mean)
sum y_center if GEN == "Stuttgart", meanonly
local y = r(mean)

gen distance = sqrt((x_center - `x')^2 + (y_center - `y')^2) /1000
gen distance_d = distance > 0

drop ADE GF BSG AGS SDV_RS BEZ IBZ BEM NBD SN_* FK_S3 NUTS RS_0 AGS_0 WSK DEBKG_ID

drop if id == 331


// Merge all macro data
// --------------------

merge m:1 RS using data/makro, nogen
merge m:1 RS using data/area, keepus(area pop*) keep(3) nogen
merge m:1 GKZ using data/unemp, keepus(unemp_abs) nogen
merge m:1 RS using data/age, keepus(age* pop*) nogen
merge m:1 RS using data/hhsize, nogen
merge m:1 GKZ using data/PLZ, keep(3) nogen

merge m:1 GKZ using data/btw2009, keep(3) nogen
merge m:1 GKZ using data/ltw2011, keep(3) keepus(p*) nogen


// Preparation
// -----------
gen diff_turnout = turnout - turnout09
gen unemp = unemp_abs/pop25_55
lab var unemp "Arbeitslosenquote"

gen Ri = yes/100

save "data/s21", replace


// Create distance file for individual distances
collapse (mean) distance, by(s_ort)
save "data/ind_dist", replace

exit

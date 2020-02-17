version 9.1
clear
set memory 90m
set more off
use $ess/ess2004, clear


// Survey variables
// ----------------

// Date of Interview
gen intdate = mdy(inwmm,inwdd,inwyr)
egen meanintdate = mean(intdate), by(cntry)
replace intdate = meanintdate if intdate == .
drop meanintdate
format intdate %d
lab var intdate "Date of interview"


// Demographic Variables
// ---------------------

// Age
gen age = inwyr-yrbrn
label variable age "Age"

// Gender
gen men:dummy = gndr == 1 if gndr <= 2
lab var men "Man y/n"

// Class (Dominance approach)
gen selfr = emplrel == 2 if !mi(emplrel)
gen selfp = emprelp == 2 if !mi(emprelp)
gen superr = (jbspv == 1)*10 if !mi(jbspv)
gen superp = (jbspvp == 1)*10 if !mi(jbspvp)
iskoegp egpr, isko(iscoco) sempl(selfr) supvis(superr)
iskoegp egpp, isko(iscocop) sempl(selfp) supvis(superp)

gen egp:egp = 3 if inlist(egpr,4,5,11) | inlist(egpp,4,5,11)
replace egp = 1 if (inlist(egpr,1) | inlist(egpp,1)) & mi(egp)
replace egp = 2 if (inlist(egpr,2) | inlist(egpp,2)) & mi(egp)
replace egp = 4 if (inlist(egpr,3) | inlist(egpp,3)) & mi(egp) ///
  & !inlist(egpr,7,8) & !inlist(egpp,7,8)
replace egp = 5 if (inlist(egpr,7,8,9,10) | inlist(egpp,7,8,9,10)) & mi(egp)

label variable egp "Social class"
label define egp 1 "Upper service class" 2 "Lower service class" ///
  3 "Self employed" 4 "Routine non manual"  ///
  5 "Manual workers", modify

// Education
gen edu:edu = 1 if inlist(edulvla,0,1)				
replace edu = 2 if inlist(edulvla,2,3,4)
replace edu = 3 if inlist(edulvla,5,6)
lab var edu "Education"
lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"

// Impute education data for GB
preserve
use $ess/ess2002 if cntry=="GB", clear
	gen edu:edu = 1 if inlist(edulvl,0,1)				
	replace edu = 2 if inlist(edulvl,2,3,4)
	replace edu = 3 if inlist(edulvl,5,6)
tab regiongb, gen(D_)
mlogit edu eduyrs yrbrn D_*
restore

tab regiongb, gen(D_)
predict edu1 edu2 edu3
gen edugb = 1 if edu1 > max(edu1,edu3)
replace edugb = 2 if edu2 > max(edu1,edu3)
replace edugb = 3 if edu3 > max(edu1,edu2)
replace edu = edugb if cntry=="GB"
drop D_* edugb

// Marital Status
gen mar:mar = 1 if marital==1
replace mar = 2 if marital==4
replace mar = 3 if inlist(marital,2,3)
replace mar = 4 if marital==5
label define mar ///
  1 "Married, or living together as married" ///
  2 "Widowed" ///
  3 "Divorced or separated" ///
  4 "Single, never married"
label variable mar "Marital status"   

// Union membership
gen unionmemb:dummy = mbtru==1 if mbtru<=3
lab var unionmemb "Trade Union Member y/n"

// Employment status
gen emp:emp = .
replace emp = 1 if mnactic == 1
replace emp = 5 if mnactic == 3 | mnactic == 4
replace emp = 2 if mnactic == 2 
replace emp = 3 if mnactic == 6
replace emp = 4 if mnactic == 5 | mnactic == 7 | mnactic == 8 | mnactic == 9
lab def emp 1 "Employed" 2 "In education" 3 "Retired" ///
      4 "Homemaker/Other not in labor force" 5 "Unemployed"
   lab var emp "Employment status"

// Household income
egen hhinc = xtile(hinctnt), p(25(25)75) by(cntry)		
label variable hhinc "Houshold income"					
label value hhinc hhinc
label define hhinc ///
  1 "1st Quartile" ///
  2 "2nd Quartile" ///
  3 "3rd Quartile" ///
  4 "4th Quartile" 
   
// Household size
gen hhsize = hhmmb if hhmmb <= 30
label variable hhsize "How many persons in household"

// Church attendence
gen church:dummy = 1 if inlist(rlgatnd,1,2,3,4,5,6)				
replace church = 0 if inlist(rlgatnd,7)
label variable church "Church attendence"

// Religiousity
egen rel=xtile(rlgdgr), p(50) by(cntry)
replace rel=rel-1
lab val rel dummy 								
label variable rel "Religious y/n"

// Denomination
gen denom:denom = 1 if rlgdnm==1
replace denom = 2 if rlgdnm==2
replace denom = 3 if inrange(rlgdnm,3,8) 
replace denom = 4 if rlgblg==2							
label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None"
   label variable denom "Denomination"

   // Discrimination
   // (833 missings for SI interpreted as "No")
   gen discrim = dscrgrp==1 if !mi(dscrgrp)
   replace discrim = 0 if dscrgrp == . & cntry=="SI"

   // Urban/Rural
   label variable domicil "Size of community"
   label define domicil 1 "Big city" 2 "Suburbs, Outskirts" 3 "Small city, town" ///
     4 "Country village" 5 "Farm, Countryside", modify

 	// Participation-Indices
// ---------------------

gen voter:dummy = vote == 1 if inrange(vote,1,2)			
label variable voter "Voted on last election y/n"

gen petition:dummy = sgnptit == 1 if sgnptit <= 2			
label variable petition ///							
  "Sign a petition y/n"

gen protest:dummy = pbldmn == 1 if pbldmn <= 2				
label variable protest ///
  "Taken part in demonstration y/n"

gen actgroup:dummy = wrkprty == 1 if wrkprty <= 2				
label variable actgroup "Worked in political party/action group in past 12 months y/n"

gen contact:dummy = contplt == 1 if contplt <= 2			
label variable contact "Contact with politician in past 12 months y/n"


// Attitudes
// ---------

   gen pi:yesno = clsprty == 1 if !mi(clsprty)
   label var pi "Party identification y/n"

ren stfdem democsat
lab var democsat "Satisfaction with democracy"

ren stflife lifesat 
lab var lifesat "Satisfaction with life as a hole"

   ren stfgov govsat 
lab var govsat "Satisfaction with government"

gen leftright:lr = lrscale						
label variable leftright "Left-right scale"
label define lr ///
  0 "Far left" 10 "Far right"

   gen lrgroup:lrgroup = 1 if inrange(leftright,0,4)
   replace lrgroup = 2 if inrange(leftright,6,10)
   replace lrgroup = 3 if leftright == 5
   replace lrgroup = 4 if leftright == .
   label variable lrgroup "Left-right groups"
   label define lrgroup ///
      1 "Left" 2 "Right" 3 "Non-commited" 4 "Unengaged"

sum polintr, meanonly
gen polint:polint = r(max)+1 - polintr
label variable polint "Political interest"
label define polint 1 "Minor" 2 "Somewhat" 3 "High" 4 "Very high"


   // Election date
   // -------------

// Depict the date of the "last" national parliamentry election
// (this is fairly complicated)
   tempfile step
   save `step'

   keep cntry idno intdate 
preserve
keep cntry
by cntry, sort: keep if _n==1
   ren cntry iso3166
merge iso3166 using ~/data/agg/electiondates, nokeep keep(eltype eldate)
assert _merge == 3
drop _merge

   drop if eltype == "Executive"
   drop eltype
   
by iso3166 (eldate), sort: gen elnr = _n
reshape wide eldate, i(iso3166) j(elnr)
compress
   ren iso3166 cntry
sort cntry
tempfile temp
save `temp'

restore
sort cntry 
merge cntry using `temp'
assert _merge==3
drop _merge

gen index = _n
reshape long eldate, i(index) j(elnr)
drop if eldate == .

gen diff = intdate - eldate
drop if diff < 0  
by index (diff), sort: keep if _n==1 // keep obs with smallest difference
by cntry idno, sort: assert _n==1
   keep cntry idno eldate
   tempfile eldates
   save `eldates'

   use `step'
   merge cntry idno using `eldates', sort
   

// Clean Data
// ----------

   label var eldate "Date of last election"

   // above 18 at election day!
drop if age-ceil((intdate - eldate)/365) < 18

   // Countries not to use
   drop if cntry== "UA"

   // Equal sample size weights
   quietly tab cntry
   by cntry, sort: gen nweight = 1/_N * r(N)/r(r) * dweight
   label var nweight "Equal sample size weight * dweight"

keep idno cntry intdate eldate ctzcntr yrbrn age men domicil ///
     egp edu mar emp hhinc hhsize church rel denom discrim      ///
     vote voter pi unionmemb petition protest actgroup contact  ///
     polint polcmpl govsat democsat lifesat leftright lrgroup   ///
     trstprl trstplt trstprt                                   ///
  dweight pweight nweight

order idno cntry intdate eldate ctzcntr yrbrn age men domicil  ///
     egp edu mar emp hhinc hhsize church rel denom  discrim ///
     vote voter pi unionmemb petition protest actgroup contact ///
     polint polcmpl govsat democsat lifesat leftright lrgroup ///
     trstprl trstplt trstprt                                ///
  dweight pweight nweight

label data "Subset of ESS 2004"
   compress
save ess04_1, replace

exit






// Create ESS respondent file
// ==========================
// kohler@wzb.eu

version 10

clear
set memory 90m
set more off
	
// ESS
// ---

use ///
  name idno cntry tvtot ppltrst polintr lrscale domicil hinctnt ///
  gndr hhmmb marital lvghw mainact  uempla uempli rtrd stflife  ///
  hswrk  iscoco emp* dweight yrbrn inwyr  ///
  using $ess/ESS1e05_1, clear

append using $ess/ESS2e03 ///
  , keep(name idno cntry tvtot ppltrst polintr lrscale domicil hinctnt ///
  gndr hhmmb marital lvghw mainact uempla uempli rtrd stflife ///
  hswrk  iscoco emp* dweight yrbrn inwyr  ///
  )


// Weights
ren dweight weight

// Women
gen women:yesno = gndr ==2 if !missing(gndr)
label variable women "Women y/n"

// City
gen city:yesno = domicil == 1 | domicil == 2 | domicil == 3 ///
  if !missing(domicil)
label variable city "Living in a city y/n"

// HHIncome
egen hinc = xtile(hinctnt), p(10(10)90) by(cntry)
label variable hinc "Household income"

// Age
gen age = inwyr - yrbrn
label variable age "Age"

// Survey
gen survey = "ESS 1" if name == "ESS2002/2003"
replace survey = "ESS 2" if name == "ESS2e03"
replace survey = "ESS 3" if name == "ESS3e03_1"
label variable survey "Survey ID"

// EGP
gen selfr = emplrel == 2 if !mi(emplrel)
gen selfp = emprelp == 2 if !mi(emprelp)
iskoegp egpr, isko(iscoco) sempl(selfr) supvis(emplno)
label variable egpr "EGP Respondent" 

// At home
gen athomer:yesno = uempla | uempli | rtrd | hswrk
replace athomer = 0 if inlist(mainact,1,2,5,7)
label variable athomer "At home y/n (Respondent)" 

// Save File
order survey cntry idno weight  ///
  athomer tvtot  ///
  hhmmb women age city marital hinc egpr  ///
  ppltrst polintr lrscale stflife

keep survey-stflife
compress

save ESSdata, replace



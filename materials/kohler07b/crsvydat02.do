* Create Main Dataset for Project
* ===============================

version 9.2

clear
set memory 90m
set more off
	

// First, we make a Country-Names Table, becaus it is nice to have one
// ===================================================================

use iso* ctrname hdi gdp eu using svydat01 
by iso3166_2, sort: keep if _n==1
compress
save ctrnames, replace

// Aggregate Survey Descriptions
// =============================

// ESS 2002
// --------

use source-quota using sampess2002
ren source survey 
replace survey = "ESS 2002"

gen sample:sample = 1 if  ///
  ( iso3166_2 == "DK" ///
  | iso3166_2 == "FI" ///
  | iso3166_2 == "SE" ///
  )
replace sample = 2 if ///
  ( iso3166_2 == "BE" ///
  | iso3166_2 == "DE" ///
  | iso3166_2 == "HU" ///
  | iso3166_2 == "IE" ///
  | iso3166_2 == "NO" ///
  | iso3166_2 == "PL" ///
  | iso3166_2 == "SI" ///
  )

replace sample = 3 if ///
  ( iso3166_2 == "CZ" ///
  | iso3166_2 == "GR" ///
  | iso3166_2 == "IL" ///
  | iso3166_2 == "IT" ///
  | iso3166_2 == "LU" ///
  | iso3166_2 == "NL" ///
  | iso3166_2 == "PT" ///
  | iso3166_2 == "ES" ///
  | iso3166_2 == "CH" ///
  | iso3166_2 == "GB" ///
  )

replace sample = 4 if  ///
  ( iso3166_2 ==  "AT" ///
  | iso3166_2 ==  "FR" ///
  )

tempfile ess02
save `ess02'


// ESS 2004
// --------

use source-quota using sampess2004
ren source survey 
replace survey = "ESS 2004"

gen sample:sample = 1 if  ///
  ( iso3166_2 == "DK" ///
  | iso3166_2 == "FI" ///
  | iso3166_2 == "EE" ///
  | iso3166_2 == "IS" ///
  | iso3166_2 == "NO" ///
  | iso3166_2 == "SE" ///
  | iso3166_2 == "SK" ///
  )
replace sample = 2 if ///
  ( iso3166_2 == "BE" ///
  | iso3166_2 == "DE" ///
  | iso3166_2 == "ES" ///
  | iso3166_2 == "HU" ///
  | iso3166_2 == "PL" ///
  | iso3166_2 == "SI" ///
  )

replace sample = 3 if ///
  ( iso3166_2 == "AT" ///
  | iso3166_2 == "CZ" ///
  | iso3166_2 == "IE" ///
  | iso3166_2 == "GR" ///
  | iso3166_2 == "LU" ///
  | iso3166_2 == "NL" ///
  | iso3166_2 == "PT" ///
  | iso3166_2 == "CH" ///
  | iso3166_2 == "GB" ///
  | iso3166_2 == "UA" ///
  )

replace sample = 4 if  ///
  ( iso3166_2 ==  "FR" ///
  )

tempfile ess04
save `ess04'

// EB 62.1, EQLS 2003, ISSP 2002, EVS 1999
// ---------------------------------------

// (Dataset from soccondeu-project)
use survey iso3166_2 inst-quota                 ///
  using svydat01                                ///
  if survey != "Euromodule" & survey != "ESS 2002" 

by survey iso3166_2, sort: keep if _n==1 
	
// EB
gen sample:sample = 4 if survey == "EB 62.1"
label variable sample "Sampling method"

// EQLS 
replace sample = 2 if survey == "EQLS 2003"  & ///
  ( iso3166_2 == "IE" ///
  | iso3166_2 == "IT" ///
  | iso3166_2 == "FI" ///
  | iso3166_2 == "SE" ///
  | iso3166_2 == "CZ" ///
  | iso3166_2 == "EE" ///
  | iso3166_2 == "HU" ///
  | iso3166_2 == "LV" ///
  | iso3166_2 == "PL" ///
  | iso3166_2 == "RO" )
replace sample = 4 if survey == "EQLS 2003" &  sample >= .

// EVS
replace sample = 1 if survey == "EVS 1999" & ///
  ( iso3166_2 == "DK" ///
  | iso3166_2 == "IS" ///
  | iso3166_2 == "MT" ///
  )

replace sample = 2 if survey == "EVS 1999" & ///
  ( iso3166_2 == "BY" ///
  | iso3166_2 == "IE" ///
  | iso3166_2 == "RO" ///
  | iso3166_2 == "SE" ///
  | iso3166_2 == "SI" ///
  )
	
replace sample = 4 if survey == "EVS 1999" & ///
  ( iso3166_2 == "DE" ///
  | iso3166_2 == "GR" ///
  | iso3166_2 == "BG" ///
  )
	
replace sample = 5 if survey == "EVS 1999" & ///
  ( iso3166_2 == "AT" ///
  | iso3166_2 == "BE" ///
  | iso3166_2 == "HR" ///
  | iso3166_2 == "LV" ///
  | iso3166_2 == "LT" ///
  | iso3166_2 == "NL" ///
  | iso3166_2 == "PT" ///
  | iso3166_2 == "PL" ///
  | iso3166_2 == "UA" ///
  )

replace sample = 6 if survey == "EVS 1999" & ///
  ( iso3166_2 == "CZ" ///
  | iso3166_2 == "EE" ///
  | iso3166_2 == "ES" ///
  | iso3166_2 == "FI" ///
  | iso3166_2 == "FR" ///
  | iso3166_2 == "GB" ///
  | iso3166_2 == "HU" ///
  | iso3166_2 == "IT" ///
  | iso3166_2 == "LU" ///
  | iso3166_2 == "RU" ///
  | iso3166_2 == "SK" ///
  | iso3166_2 == "TR" ///
  )

// ISSP
replace sample = 1 if survey == "ISSP 2002" & ///
  ( iso3166_2 ==  "AU" ///
  | iso3166_2 ==  "DK" ///
  | iso3166_2 ==  "FI" ///
  | iso3166_2 ==  "NO" ///
  | iso3166_2 ==  "NZ" ///
  | iso3166_2 ==  "SE" ///
  )

replace sample = 2 if survey == "ISSP 2002" & ///
  ( iso3166_2 ==  "AT" ///
  | iso3166_2 ==  "DE" ///
  | iso3166_2 ==  "BG" ///
  | iso3166_2 ==  "HU" ///
  | iso3166_2 ==  "JP" ///
  | iso3166_2 ==  "SI" ///
  | iso3166_2 ==  "TW" ///
  )

replace sample = 5 if survey == "ISSP 2002" &  sample >= .
	
replace sample = 6 if survey == "ISSP 2002" & ///
  ( iso3166_2 ==  "BR" ///
  | iso3166_2 ==  "NL" ///
  | iso3166_2 ==  "PH" ///
  | iso3166_2 ==  "SK" ///
  )

append using `ess02'
append using `ess04'

label define sample ///
  1 "SRS" ///
  2 "Cluster + individual register" ///
  3 "Cluster + address register" ///
  4 "Cluster + random-route" ///
  5 "Unspecified" ///
  6 "Quota" 

sort survey iso3166_2
tempfile svydes
save `svydes'


// Individual Data
// ===============

// ESS 2004
// --------

use idno cntry domicil hinctnt gndr gndr2 hhmmb lvgptn lvgoptn lvghw dweight ///
 yrbrn inwyr  using $ess/ess2004, clear

// Weights
ren dweight weight

// Case ID
ren idno id

// Weich/Hart
gen weich:yesno = hhmmb == 2 & (lvgptn == 1 | lvgoptn == 1 | lvghw == 1) ///
  if !missing(hhmmb)
replace weich = . if  lvgptn >= . & lvgoptn >= .  & lvghw >= .
gen hart:yesno = weich==1 & gndr~=gndr2 if !missing(weich,gndr,gndr2)

// Frauen
gen women:yesno = gndr ==2 if !missing(gndr)

// City
gen city:yesno = domicil == 1 | domicil == 2 | domicil == 3 if !missing(domicil)

// HHIncome
egen hinc = xtile(hinctnt), p(25(25)75) by(cntry) 

// Age
gen age = inwyr - yrbrn

// Survey
gen survey = "ESS 2004"

// ISO
ren cntry iso3166_2


// Save File
keep survey id weight iso3166_2 weich-age
tempfile essi
save `essi'


// Merge everything togther and clean
// ==================================

use survey id weight iso3166_2 weich-age ///
  using svydat01 if survey != "Euromodule" & survey != "ESS" 
append using `essi'

sort iso3166_2
merge iso3166_2 using ctrnames, nokeep
assert _merge==3
drop _merge

sort survey iso3166_2
merge survey iso3166_2 using `svydes'
assert _merge==3
drop _merge

// Harmonize Survey Institutes-Names
label variable inst "Survey institute"
replace inst = "ARS" if index(inst,"ARS")
replace inst = "MVK" if index(inst,"MVK")
replace inst = "BMRB" if index(inst,"BMRB") 
replace inst = "CBOS" if index(inst,"CBOS") 
replace inst = "CEPS/INSTAED" if index(upper(inst),"CEPS") 
replace inst = "DEMOSCOPIA" if index(upper(inst),"DEMOSCOPIA") 
replace inst = "ESRI" if index(inst,"ESRI") | inst == "Economic and Social Research Institute"
replace inst = "GALLUP" if index(upper(inst),"GALLUP")
replace inst = "GfK" if index(upper(inst),"GFK")
replace inst = "IPR" if index(inst,"IPR")
replace inst = "MISCO" if index(upper(inst),"MISCO")
replace inst = "SFI" if index(inst,"SFI")
replace inst = "TNS" if index(inst,"TNS")
replace inst = "Infas" if index(inst,"infas")
replace inst = "University of Ljubljana" if inst=="Universoty of Lubljana"

// Some Data Clearing
label variable age "Age in years"
label variable weight "Weights"
label variable ctrname "Full country name"
label variable hdi "Human development index"
label variable gdp "Gross domestic product"
label variable pretest "Pretest conducted"
label variable svymeth "Survey mode"
label variable resrate "Response rate"
label variable resratei "Response rate harmonized y/n"
label variable subst "Substitution allowed"

label variable back "Back checking regulations y/n"
replace back = 1 if back >=1

drop strata dispro* hhsamp selhh selper intpay quota


order survey id iso3166_2 iso3166_3 ctrname eu hdi gdp inst-sample weich-age
compress
label data "ESS 02/04, EQLS 03, ISSP 02, EVS 99, EB 62.1"

save svydat02, replace

exit

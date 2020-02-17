// Data set  of contact data from ESS I, II, III
// Authors: kohler@wzb.eu, fkreuter@survey.umd.edu

// History
// -------

// crESScontact.do 						 
//  - dataset for Prague conference. 		 
//  - ESS 2002 only 						 
//  - Pre-release of datasets
//
// crESScontactbig.do 					 
//  - Rework of crESScontact.do 			
//  - ESS'02 and ESS'04 					 
//  - Official data releases
//
// crESScontact1-3.do 					 
//  - Add ESS III


version 10
set more off
clear
set memory 140m

// +--------------+
// | Country list |
// +--------------+

// Only countries with observations in each round
local i 1
foreach file in ess1contacts ess2contacts ess3cf_ed1 {
	use cntry using $ess/`file', clear
	contract cntry
	sort cntry
	tempfile f`i'
	save `f`i++''
}

use `f1'
merge cntry using `f2' `f3', nokeep

drop if cntry=="SI"  // SI no idno for 2004

local i 1
levelsof cntry if _merge1==1 & _merge2==1, local(K)
foreach k of local K {
	if `i++' == 1 local clist `"`clist' cntry == "`k'" "'
	else local clist `"`clist' | cntry == "`k'" "'
}


// +---------+
// |ESS 2002 |
// +---------+

// Data
// ----

use $ess/ess1contacts.dta if `clist', clear

// We drop "non-eligible" (n=2689) and some other "invalid" codes 
egen x = anycount(result*), values(5,7,8)
keep if !x 
drop x

// We drop respondents with more than on1 Interview (n=1610)! 
egen x = anycount(result*), values(1)
keep if x <= 1
drop x


// Missing values
// --------------

mvdecode intnum1 intnum2 intnum3, mv(-9,999999,99999999=.c)

quietly foreach var of varlist  ///
  datev1-monv10 hourv1-minv10 nselect outnoi1-outnoi10 totcint* /// 
  refrs1_1-refrs1_4 refrs2_1  coop1 coop2 coop3 refrs3_1 type   ///
  genderr ager proxv1-proxv10 {
	replace `var' = .a if `var' == 77
	replace `var' = .b if `var' == 88
	replace `var' = .c if `var' == 99
}
replace type= .b if type==888
replace type= .c if type==999

quietly foreach var of varlist ///
  dayv1-dayv10 modev1-reiss10 outint1-outint3 coop1 coop2 coop3 ///
  ager-outineli alarm-vanda telnum proxv1-proxv10  {
	replace `var' = .a if `var' == 7
	replace `var' = .b if `var' == 8
	replace `var' = .c if `var' == 9
}

// Elapsed time of interview
// -------------------------

ren datev1 date1
forvalues i=1/10 {
	gen etime`i' = mdyhms(monv`i',date`i',2002,hourv`i',minv`i',0)
	format %tcDa,_Mon_dd_YY_!(HH:MM!) etime`i'
}

// Unique Country Idenifier
// ------------------------
// (for reshape)

// Czech idno not unique for idno 1795, 1796 1874 and 347
// (We only keep first of each)
by cntry idno, sort: drop if _n==2

gen str1 ctrcase = ""
replace ctrcase = cntry + " " + string(idno,"%20.0f" )
isid ctrcase

// Construct visits by interviewers
// --------------------------------

preserve
keep cntry ctrcase totcint* intnum* 
reshape long totcint intnum, i(ctrcase) j(tryer)
drop if mi(intnum)
expand totcint
drop totcint
by ctrcase  (tryer), sort: gen visit = _n

tempfile file1
save `file1'
restore

// Make a long visit dataset
// -------------------------

keep idno ctrcase cntry ager alarm bgany gender sign litter       ///
  phys physcom type inter sec porch  telnum vanda                ///
  result* etime* modev* coop*  
  
reshape long ///
  result etime modev coop  ///
  , i(ctrcase) j(visit)
tempfile file2
save `file2'
	
// Merge interviewers and visits
// -----------------------------

use `file1', clear
merge ctrcase visit using `file2', sort

drop if _merge == 1 // more visits recorded than records in file 
drop if _merge== 2 & mi(result) 
drop _merge

// Consitence-Checks and  Data cleaning
// ------------------------------------

// 3 Obs from FI with gaps -> drop
by ctrcase, sort: gen x = 1 if result[_n-1] == . & result != . & _n!= 1
by ctrcase, sort: replace x = sum(x)
by ctrcase, sort: drop if x[_N]
drop x

// Drop trailing "Missings"
by ctrcase (visit), sort: gen x = sum(result==.)
by ctrcase (visit), sort: drop if result == . & (x[_n-1] == x - 1)
drop x

// Drop trailing "no informations"
by ctrcase (visit), sort: gen x = sum(result==9)
by ctrcase (visit), sort: drop if result == 9 & (x[_n-1] == x - 1)
drop x

// We don't want any entries after an interview
by ctrcase (visit), sort: gen x = sum(result[_n-1]==1)
drop if x == 1
drop x


// Grap information on last contact from ESS
// -----------------------------------------

// Prepare to merge information from ESS-Data
sort cntry idno result
tempfile orig
save `orig'

// Prepare ESS 
use cntry idno inwmm inwdd inwshh inwyr inwsmm using $ess/ess2002 if `clist', clear

gen str1 ctrcase = ""
replace ctrcase = cntry + " " + string(idno,"%20.1f" )
isid ctrcase
	
gen result=1
gen fromESS = 1

gen etime = mdyhms(inwmm,inwdd,inwyr,inwshh,inwsmm,0)
drop inwmm inwdd inwshh inwsmm
	
sort cntry idno result
tempfile using
save `using'

// Merge Contact + ESS
use `orig'
merge cntry idno result using `using'
assert result == 1 if _merge == 2 
drop _merge

by ctrcase (visit), sort: replace visit = visit[_n-1] + 1 if mi(visit)
drop if visit == . // 486 obs from ESS-Daten without Contact protocol

by ctrcase (visit), sort: replace fromESS = fromESS[_N]==1
	
// End matter
replace genderr=. if genderr==0
replace genderr=. if genderr==88
replace type = . if type ==11

foreach var of varlist alarm - bgany {
	replace `var' = . if `var' == 2 & cntry== "IT"
	replace `var' = 2 if `var' == 0 & cntry== "IT"
}

// Preperations for appending other rounds
// ---------------------------------------

gen survey = "ESS 1"
ren result result1
tempfile ess1
save `ess1'

// +---------+
// |ESS 2004 |
// +---------+

// Data
// ----

use $ess/ess2contacts.dta if `clist', clear

// SI no idno for 2004
drop if cntry=="SI"

// We drop "non-eligible" (n=2700) and some other "invalid" codes 
egen x = anycount(resula1-resula10), values(0,7,8)
keep if !x 
drop x

// We drop respondents with more than on1 Interview (n=12)
egen x = anycount(resula1-resula10), values(1)
keep if x <= 1
drop x

// Missing values
// --------------

mvdecode intnum1 intnum2 intnum3, mv(-9=.c)

quietly foreach var of varlist  ///
  datev1-monv10 hourv1-minv10 outnia1-outnia10 totcint* /// 
  rersa2_* rersa2_*  rersa1_* type  {
	replace `var' = .a if `var' == 77
	replace `var' = .b if `var' == 88
	replace `var' = .c if `var' == 99
}

quietly foreach var of varlist ///
  dayv1-dayv10 modeva1-modeva10 coop1 coop2 coop3 ///
  ager-outineli phys litter vanda telnum  {
	replace `var' = .a if `var' == 7
	replace `var' = .b if `var' == 8
	replace `var' = .c if `var' == 9
}

// Elapsed time of interview
// -------------------------

ren datev1 date1
forvalues i=1/10 {
	gen etime`i' = mdyhms(monv`i',date`i',2004,hourv`i',minv`i',0)
	format %tcDa,_Mon_dd_YY_!(HH:MM!) etime`i'
}

// Unique Country Idenifier
// ------------------------
// (for reshape)

gen str1 ctrcase = ""
replace ctrcase = cntry + " " + string(idno,"%20.0f" )
isid ctrcase

// Construct visits by interviewers
// -------------------------------

preserve
keep cntry ctrcase totcint* intnum* 
reshape long totcint intnum, i(ctrcase) j(tryer)
drop if mi(intnum)
expand totcint
drop totcint
by ctrcase  (tryer), sort: gen visit = _n

tempfile file1
save `file1'
restore

// Make a long visit dataset
// -------------------------

keep idno ctrcase cntry ager gender litter       ///
  phys type telnum vanda                ///
  resula* etime* modev* coop*  

ren resulala lastres
ren resula2n seclastres 
reshape long ///
  resula etime modeva coop  ///
  , i(ctrcase) j(visit)
tempfile file2
save `file2'
	
// Merge interviewers and visits
// -----------------------------

use `file1', clear
merge ctrcase visit using `file2', sort

drop if _merge == 1 // more visits recorded than records in file 
drop if _merge== 2 & mi(resula) 
drop _merge

// Harmonize Variable Names
// ------------------------

ren resula result
ren modeva modev

// Consitence-Checks and  Data cleaning
// ------------------------------------

// Drop obs with gaps (FI: 41, IE: 21, CZ: 2, PT: 1)
by ctrcase, sort: gen x = 1 if result[_n-1] == . & result != . & _n!= 1
by ctrcase, sort: replace x = sum(x)
by ctrcase, sort: drop if x[_N]
drop x

// Drop trailing "Missings"
by ctrcase (visit), sort: gen x = sum(result==.)
by ctrcase (visit), sort: drop if result == . & (x[_n-1] == x - 1)
drop x

// Drop trailing "no informations (code 8)"
by ctrcase (visit), sort: gen x = sum(result==9)
by ctrcase (visit), sort: drop if result == 9 & (x[_n-1] == x - 1)
drop x

// We don't want any entries after an interview
by ctrcase (visit), sort: gen x = sum(result[_n-1]==1)
drop if x == 1
drop x

// Grap information on last contact from ESS
// -----------------------------------------

// Prepare to merge information from ESS-Data
sort cntry idno result
tempfile orig2
save `orig2'

// Prepare ESS
use cntry idno inwmm inwdd inwyr inwshh inwsmm  ///
  using $ess/ess2004 if `clist', clear

gen str1 ctrcase = ""
replace ctrcase = cntry + " " + string(idno,"%20.1f" )
isid ctrcase
	
gen result=1
gen fromESS = 1

gen etime = mdyhms(inwmm,inwdd,inwyr,inwshh,inwsmm,0)
drop inwmm inwdd inwshh inwsmm
	
sort cntry idno result
tempfile using2
save `using2'

// Merge Contact + ESS
use `orig2'
merge cntry idno result using `using2'
assert result ==1 if _merge == 2 
drop _merge

by ctrcase (visit), sort: replace visit = visit[_n-1] + 1 if mi(visit)
drop if visit == . // Some obs from ESS-Daten without Contact protocol

by ctrcase (visit), sort: replace fromESS = fromESS[_N]==1

// Preperations for appending other rounds
// ---------------------------------------

gen survey = "ESS 2"
ren result result2
tempfile ess2
save `ess2'


// +--------+
// |ESS III |
// +--------+

// Data
// ----

use name-vanda intnum4-totcin10 coop4-coop8 			///   
using $ess/ess3cf_ed1.dta if `clist', clear

// We drop "non-eligible" (n=4337) and some other "invalid" codes 
egen x = anycount(resulb1-resulb10), values(7,8,9)
keep if !x 
drop x

// We drop respondents with more than 1 Interview (n=19)
egen x = anycount(resulb1-resulb10), values(1)
keep if x <= 1
drop x

// Missing values
// --------------

mvdecode intnum*, mv(999999=.c)

quietly foreach var of varlist  ///
  datev1-monv10 hourv1-minv10 outnia1-outnia10 totcint* /// 
  rersa2_* rersa2_*  rersa1_* type  {
	replace `var' = .a if `var' == 77
	replace `var' = .b if `var' == 88
	replace `var' = .c if `var' == 99
}

quietly foreach var of varlist ///
  dayv1-dayv10 coop1 coop2 coop3 ///
  modevb1-modevb10 ager-outineli phys litter vanda telnum  {
	replace `var' = .a if `var' == 7
	replace `var' = .b if `var' == 8
	replace `var' = .c if `var' == 9
}

// Elapsed time of interview
// -------------------------

ren datev1 date1
forvalues i=1/10 {
	gen etime`i' = mdyhms(monv`i',date`i',2006,hourv`i',minv`i',0)
	format %tcDa,_Mon_dd_YY_!(HH:MM!) etime`i'
}

// Unique Country Idenifier
// ------------------------
// (for reshape)

gen str1 ctrcase = ""
replace ctrcase = cntry + " " + string(idno,"%20.0f" )
isid ctrcase

// Construct visits by interviewers
// -------------------------------

preserve
keep cntry ctrcase totcint* intnum* 
reshape long totcint intnum, i(ctrcase) j(tryer)
drop if mi(intnum)
expand totcint
drop totcint
by ctrcase  (tryer), sort: gen visit = _n

tempfile file1
save `file1'
restore

// Make a long visit dataset
// -------------------------

keep idno ctrcase cntry ager gender litter       ///
  phys type telnum vanda                ///
  resulb* etime* modevb* coop*  

reshape long ///
  resulb etime modevb coop  ///
  , i(ctrcase) j(visit)
tempfile file2
save `file2'
	
// Merge interviewers and visits
// -----------------------------

use `file1', clear
merge ctrcase visit using `file2', sort

drop if _merge == 1 // more visits recorded than records in file 
drop if _merge== 2 & mi(resulb) 
drop _merge

// Harmonize Variable Names
// ------------------------

ren resulb result
ren modevb modev

// Consitence-Checks and  Data cleaning
// ------------------------------------

// Drop obs with gaps (FI: 41, IE: 21, CZ: 2, PT: 1)
by ctrcase, sort: gen x = 1 if result[_n-1] == . & result != . & _n!= 1
by ctrcase, sort: replace x = sum(x)
by ctrcase, sort: drop if x[_N]
drop x

// Drop trailing "Missings"
by ctrcase (visit), sort: gen x = sum(result==.)
by ctrcase (visit), sort: drop if result == . & (x[_n-1] == x - 1)
drop x

// Drop trailing "no informations (code 8)"
by ctrcase (visit), sort: gen x = sum(result==9)
by ctrcase (visit), sort: drop if result == 9 & (x[_n-1] == x - 1)
drop x

// We don't want any entries after an interview
by ctrcase (visit), sort: gen x = sum(result[_n-1]==1)
drop if x == 1
drop x

// Grap information on last contact from ESS
// -----------------------------------------

// Prepare to merge information from ESS-Data
sort cntry idno result
tempfile orig2
save `orig2'

// Prepare ESS
use cntry idno inwmms inwdds inwyys inwshh inwsmm using $ess/ESS3e03_1 ///
if `clist' , clear

gen str1 ctrcase = ""
replace ctrcase = cntry + " " + string(idno,"%20.1f" )
isid ctrcase
	
gen result=1
gen fromESS = 1

gen etime = mdyhms(inwmm,inwdd,inwyys,inwshh,inwsmm,0)
drop inwmm inwdd inwshh inwsmm inwyys
	
sort cntry idno result
tempfile using2
save `using2'

// Merge Contact + ESS
use `orig2'
merge cntry idno result using `using2'
assert result ==1 if _merge == 2 
drop _merge

by ctrcase (visit), sort: replace visit = visit[_n-1] + 1 if mi(visit)
drop if visit == . // Some obs from ESS-Daten without Contact protocol

by ctrcase (visit), sort: replace fromESS = fromESS[_N]==1

// Preperations for appending other rounds
// ---------------------------------------

gen survey = "ESS 3"
ren result result2
tempfile ess3
save `ess3'


// +--------+
// | Append |
// +--------+

use `ess1'
append using `ess2'
append using `ess3'

order survey fromESS ctrcase cntry idno visit intnum result1 result2 tryer	/// 
  ager-litter vanda telnum etime modev coop

// Labels and Friends
// ------------------

// Variable labels
label var survey "Survey"
label var fromESS "Data from ESS available"
label var ctrcase "Unique country-respondent key"
label var cntry "Country (ISO 3166)"
label var idno "Respondent's idenification number"
label var visit "# of visit"
label var intnum "Interviewer number"
label var tryer "# of inserted interviewer"
label var ager "Age of respondnet (estimated by interviewer) "
label var genderr "Gender of respondent (recorded by interviewer)"
label var type "Type of house respondent livesin"
label var alarm "Alarm system present"
label var inter "Intercom/entry phone present"
label var sec "Security lights present"
label var porch "Closed or open porch present"
label var sign "Beware of dog sign present"
label var bgany "Bars/grills on any window present"
label var phys "State of buildings/dwellings in area"
label var physcom "State of address compared to area"
label var litter "Litter/rubbish in immediate area"
label var vanda "Vandalism, graffiti, etc. in area"
label var telnum "telephone number"
label var etime "Time of visit"
label var modev "Mode of visit"
label var result1 "Result of visit (ESS I)"
label var result2 "Result of visit (ESS II/III)"
label var coop "Estimated cooperation"

// 1 = Yes, 2 = No
foreach var of varlist alarm inter sec porch sign bgany {
	label value `var' yesno2
}
label define yesno2  1 "Yes"  2 "No" 		 

// Common/Uncommon
foreach var of varlist litter vanda {
	label value `var' common
}
label define common 1 "Very common" 2 "Fairly common" 3 "Not very common"   ///
  4 "Not at all common" 

// Good/Bad
foreach var of varlist phys physcom {
	label value `var' quality
}
label define quality 1 "Very good/much better"  5 "Very bad/much worse" 

// Idosyncratic
foreach var of varlist ager genderr telnum modev result* type coop {
	label value `var' `var'
}

label define modev  1 "F2F visit"  2 "telephone"  3 "F2F only intercom"  ///
  4 "info through office" 

label define result1 					/// 
  1 "Interview" 						/// 
  2 "Contact with R NO interview" 		///  
  3 "Only contact with someone else" 	/// 
  4 "NO contact at all" 				///  
  9 "No information"

label define result2 					/// 
  1 "Interview" 						/// 
  2 "Partial Interview" 				/// 
  3 "Contact - Target not yet selected" ///
  4 "Contact with target, no interview" ///
  5 "Contact with someone else" 		/// 
  6 "No contact at all" 			    ///
  9 "No information"

label define result3 					/// 
  1 "Interview" 						/// 
  2 "Partial Interview" 				/// 
  3 "Contact - Target not yet selected" ///
  4 "Contact with target, no interview" ///
  5 "Contact with someone else" 		/// 
  6 "No contact at all" 			    ///
  9 "No information"

  
label define coop 1 "definetly not" 2 "probably not" 3 "perhaps in future" ///
  4 "will coop in future" 

// Not occupied, but usefull
label define yesno  0 "No" 1 "Yes" 		 

// +-------+
// | Store |
// +-------+

compress
label data "Long contact protocolls ESS 1-3"
note: Creators: kohler@wzb.eu, fkreuter@survey.umd.edu

save ESScontact1-3, replace


exit



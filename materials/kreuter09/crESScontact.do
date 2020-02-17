	// Creates major Dataset for project
	// kohler@wzb.eu

	// build from: cr_ESSseqa_result.do by FK

	
version 9.2
	set more off
	clear
	set memory 120m
	use $ess/contactsess2.dta // Note: FR and SE not in dataset!


	// We do not know anything about 149 of 680702 obs. -> Drop
	drop if result1==.
	drop if result1==0
	
	// Missing values
	// --------------
	
	mvdecode intnum1, mv(999999=.c)
	
	foreach var of varlist ///
	  datev1-monv10 hourv1-minv10 nselect outnoi1-outnoi10 totcint* /// 
	  refrs1_1-refrs1_4 refrs2_1  coop1 coop2 coop3 refrs3_1 type {	    
		replace `var' = .a if `var' == 77
		replace `var' = .b if `var' == 88
		replace `var' = .c if `var' == 99
	}
	
	foreach var of varlist ///
	  dayv1-dayv10 modev1-reiss10 outint1-outint3 coop1 coop2 coop3 ///
	  ager-outineli alarm-vanda telnum proxv1-proxv10  {
		replace `var' = .a if `var' == 7
		replace `var' = .b if `var' == 8
		replace `var' = .c if `var' == 9
	}


	// Elapse date and time
	// ---------------------

	ren datev1 date1
	forvalues i=1/16 {
		gen edate`i' = mdy(monv`i',date`i',2002)
	}
	
	forvalues i=1/16 {
		gen etime`i' = hourv`i' + minv`i'/100  if inrange(hourv`i',0,24) & inrange(minv`i',0,60)
	}


	// Unique Country Idenifier
	// ------------------------
	// (for reshape)

	// Slovenia has no uniqe idenifyer! 
	// (We drop Slovenia, because we cannot merge with ESS)
	drop if cntry == "SI"

	// Czech idno not unique for idno 1795, 1796 1874 and 347
	// (We only keep firsr of each)
	by cntry idno, sort: drop if _n==2
	
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

	keep idno ctrcase cntry ager alarm bgany gender sign litter       ///
	  phys physcom type inter sec porch  telnum vanda                ///
	  result* edate* etime* modev* coop*  
	  
	reshape long ///
	  result edate etime modev coop  ///
	  , i(ctrcase) j(visit)
	tempfile file2
	save `file2'
		
	// Merge interviewers and visits
	// -----------------------------
	use `file1', clear
	merge ctrcase visit using `file2', sort

	drop if _merge == 1 // more visits recorded than records in file (61 cases)
	drop if _merge== 2 & mi(result) 
	drop _merge


	// Labels and Friends
	// ------------------

	// Variable labels
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
	label var edate "Date of visit"
	label var etime "Time of visit"
	label var modev "Mode of visit"
	label var result "Result of visit"
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
	foreach var of varlist ager genderr telnum modev result type coop {
		label value `var' `var'
	}
	label define telnum 1 "number provided" 2 "refused" 3 "no phone"
	label define modev  1 "F2F visit"  2 "telephone"  3 "F2F only intercom"  ///
	  4 "info through office" 
	label define result 1 "Interview" 2 "Contact with R NO interview"  ///
	  3 "Only contact with someone else" 4 "NO contact at all"  ///
	  5 "Address is not valid (unoccp..)"  8 "No information"
	label define coop 1 "definetly not" 2 "probably not" 3 "perhaps in future" ///
	  4 "will coop in future" 
	label define ager 1 "under 20" 2 "20 to 39" 3 "40 to 59"  4 "60 or older" 
	label define genderr 1 "male"  2 "female"
	label define type 1 "Farm"            ///
	  2 "Detached house"  ///
	  3 "Semi-detached house"  ///
	  4 "Terraced house"  ///
	  5 "house in commerc. prop."  ///
	  6 "Multi-unit house"  ///
	  7 "Student apartments"  ///
	  8 "Sheltered housing"  ///
	  9 "Trailor or boat"  ///
	  10 "other"  

	// Not occupied, but usefull
	label define yesno  0 "No" 1 "Yes" 		 
	
	order ctrcase cntry idno visit intnum tryer ager-litter vanda telnum ///
	  edate etime result modev coop 

	// Consitence-Checks and  Data cleaning
	// ------------------------------------

	// Drop protocols with invalid result information
	by ctrcase, sort: gen marker = 1 if inlist(result,6,7)
	by ctrcase (marker), sort: drop if marker[1]==1
	drop marker

	// "No information" and "not available" treated identical
	replace result= 8 if result==9

	// Missings nur am Sequenzende -> "ltrim"
	drop if result == . 

	// Prepare to merge information from ESS-Data
	sort cntry idno result
	tempfile orig
	save `orig'

	// Sometimes, information on last contact must be taken from original ESS
	// ---------------------------------------------------------------------
	use cntry idno inwmm inwdd using $ess/ess2002 ///
	  if !inlist(cntry,"SI","FR","SE") , clear

	gen str1 ctrcase = ""
	replace ctrcase = cntry + " " + string(idno,"%20.1f" )
	isid ctrcase
	
	gen result=1
	gen fromESS = 1

	gen intdate = mdy(inwmm,inwdd,2002)
	drop inwmm inwdd 
	
	sort cntry idno result
	tempfile using
	save `using'

	// Merge Contact + ESS
	use `orig'
	merge cntry idno result using `using'
	assert result ==1 if _merge == 2 
	drop _merge
	
	replace edate = intdate if mi(edate)
	drop intdate

	by ctrcase (visit), sort: replace visit = visit[_n-1] + 1 if mi(visit)
	drop if visit == . // Some obs from ESS-Daten without Contact protocol

	by ctrcase (visit), sort: replace fromESS = fromESS[_N]==1
	

	// End matter
	format %d edate

	replace genderr=. if genderr==0
	replace genderr=. if genderr==88
	replace type = . if type ==11

	foreach var of varlist alarm - bgany {
		replace `var' = . if `var' == 2 & cntry== "IT"
		replace `var' = 2 if `var' == 0 & cntry== "IT"
	}

	save ESScontact.dta, replace orphans



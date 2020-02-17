* ------------
* FK: 	   11/29/06
* last change: 11/29/06
* create analysis file for sequence analysis
* ------------

	set more off
	clear
	set mem 100m
	use $ess/contactsess2.dta if cntry == "DE" | cntry == "NL" | cntry == "GB"  
	
	* ----------------------------------------------------
	* variables beyond proxv10 seem to be (mostly?) empty
	* compare with country files
	* ----------------------------------------------------
	
* keep idno-proxv10
	


* --------
	* missing values
	* --------
	
	mvdecode intnum1, mv(999999=.c)
	
	foreach var of varlist  datev1-monv10 hourv1-minv10 nselect outnoi1-outnoi10 /// 
	refrs1_1- refrs1_4 refrs2_1  refrs3_1 type ///
	  {	    
		mvdecode `var', mv(77=.a)
		mvdecode `var', mv(88=.b)
		mvdecode `var', mv(99=.c)
	}
	foreach var of varlist  dayv1-dayv10 modev1-reiss10 /* result1-result10 */  /// 
	outint1-outint3 coop1 coop2 coop3 ager-outineli ///
	  alarm-telnum proxv1-proxv10 	///
	  {	    
		mvdecode `var', mv(7=.a)
		mvdecode `var', mv(8=.b)
		mvdecode `var', mv(9=.c)
	}
	
	drop if result1==.
	drop if result1==0
	
	* --------
	* value labels
	* --------
	
	label define telnum 1 "number provided"   ///
	  2 "refused" 		 ///
	  3 "no phone"
	label define modev  1 "F2F visit"           ///
	  2 "telephone" 		   ///
	  3 "F2F only intercom"   ///
	  4 "info through office" 
	label define yesno  0 "No"   ///
	  1 "Yes" 		 
	label define yesno2  1 "Yes"   ///
	  2 "No" 		 
	label define result 1 "Interview"   			  ///
	  2 "Contact with R NO interview" 	  ///
	  3 "Only contact with someone else" ///
	  4 "NO contact at all"		  ///
	  5 "Address is not valid (unoccp..)" 
	
	label define coop 1 "definetly not"     ///
	  2 "probably not"      ///
	  3 "perhaps in future" ///
	  4 "will coop in future" ///
	  
	  label define ager 1 "under 20" ///
	  2 "20 to 39" ///
	  3 "40 to 59" ///
	  4 "60 or older" 
	
	label define gen 1 "male" ///
	  2 "female"
	
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
	
    label define common 1 "Very common"       ///
	  2 "Fairly common"     ///
	  3 "Not very common"   ///
	  4 "Not at all common" 
	
    label define quality 1 "Very good/much better"       ///
	  5 "Very bad/much worse" 
	
	for var modev1-modev10:   label value X modev
	
	foreach num of numlist 1/12 {
		label value reiss`num' yesno	
	}
	
	foreach num of numlist 1/16 {
		label value result`num' result
	}
	
	for var coop1 coop2 coop3: 	   label value X coop
	label value ager ager
	for var alarm inter sec porch sign bgany non othit: label value X yesno2
	for var litter vanda:	   label value X common
	for var phys physcom:     label value X quality
	
	* ----------------
	* datev1-datev10 DD/MM
	* dayv1-dayv2    Day of the week
	* hour1-hour3    Time 24 hr
	* minv1-minv10   Minute
	* -----------------
	
	* isid idno // idno is unique only within country
	* generate unique country id
	* ----------------------------------------------
	
	gen     country=1 if cntry=="DE"
	replace country=2 if cntry=="NL"
	replace country=3 if cntry=="GB"
	
	gen double CntryCase = country*10000000+idno
	isid CntryCase
	sort CntryCase 
	
	
	* recode of interviewer id variable
	* generate interviewer id for each contact
	* ----------------------------------------------
	
	// Construct visits by interviewers
	preserve
	keep CntryCase totcint* intnum* 
	reshape long totcint intnum, i(CntryCase) j(tryer)
	drop if mi(intnum)
	expand totcint
	by CntryCase  (tryer), sort: gen visit = _n
	
	// Look at it
	list CntryCase visit intnum totcint in 1/15, sepby(i)
	tab visit
	
	// Ok, that's fine, go on
	tempfile file1
	save `file1'
	
	// Make a long visit Dataset
	restore
	ren datev1 date1
	drop datev*
	
	keep CntryCase result* date? date??  monv*
	reshape long result date monv, i(CntryCase) j(visit)
	tempfile file2
	save `file2'
		
	// Merge them together
	use `file1', clear
	merge CntryCase visit using `file2', sort
	drop if _merge== 2 & mi(result) 
	drop if _merge == 1 // more visits recorded than records in file here 42 cases
	drop _merge

	// Drop protocols with invalid result information
	by CntryCase, sort: gen marker = 1 if inlist(result,6,7)
	by CntryCase (marker), sort: drop if marker[1]==1

	// "No information" and "not available" treated identical
	replace result= 8 if result==9

	// Missings nur am Sequenzende -> "ltrim"
	drop if result == . 

	// Prepare to merge information from ESS-Data
	sort CntryCase result
	tempfile orig
	save `orig'

	// Prepare ESS
	use cntry idno inwmm inwdd using $ess/ess2002 ///
	  if cntry == "DE" | cntry == "NL" | cntry == "GB"  , clear

	gen     country=1 if cntry=="DE"
	replace country=2 if cntry=="NL"
	replace country=3 if cntry=="GB"
	
	gen double CntryCase = country*10000000+idno
	isid CntryCase
	drop cntry idno country
	sort CntryCase

	gen result=1
	gen fromESS = 1
	
	sort CntryCase
	sort CntryCase result
	tempfile using
	save `using'

	// Merge Contact + ESS
	use `orig'
	merge CntryCase result using `using'
	drop _merge
	
	gen contactdate = mdy(monv,date,2002)
	gen intdate = mdy(inwmm,inwdd,2002)
	replace contactdate = intdate if mi(contactdate)

	drop monv date inwmm inwdd intdate

	by CntryCase (visit), sort: replace visit = visit[_n-1] + 1 if mi(visit)
	drop if visit == . // 10 obs aus ESS-Daten ohne Kontaktprotokoll 

	by CntryCase (visit), sort: replace fromESS = fromESS[_N]==1

	save ESSseqa_result.dta, replace


	

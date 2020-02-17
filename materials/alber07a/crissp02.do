	// Subdata from ISSP 2002 with Participation indices
	// -------------------------------------------------
	// Creator: kohler@wzb.eu

version 9
	clear
	set memory 90m
	set more off

	use $issp/issp02

	// Recode Administrative Variables
	// ------------------------------

	gen dataset = "ISSP 2002"
	ren v362 dataset_version
	tostring v2, gen(persid)
	ren v361 weight
	ren v360 mode
	
	// Country
	label define v3 ///
	   1  "AU"  2 "DE"   3 "DE"   4 "GB"   5 "GB"   6 "US"   7 "AT"   8 "HU"   9 "IT"  10 "IE"  ///
	  11 "NL"  12 "NO"  13 "SE"  14 "CZ"  15 "SI"  16 "PL"  17 "BG"  18 "RU"  19 "NZ"  ///
	  20 "CA"  21 "PH"  22 "IL"  23 "IL"  24 "JP"  25 "ES"  26 "LV"  27 "SK"  28 "FR"  ///
	  29 "CY"  30 "PT"  31 "CL"  32 "DK"  33 "CH"  34 "BE"  35 "BR"  37 "FI"  38 "MX"  ///
	  39 "TW"  40 "ZA", modify  
	egen ctrnames = iso3166(v3), o(codes)
	egen iso3166 = iso3166(ctrnames)

	// Average Interviewdates ISSP 2002
	// Taken from http://zacat.gesis.org/webview/index.jsp
	sort iso3166
	tempfile issp
	save `issp'
	clear
	input str2 iso3166 bday bmonth byear eday emonth eyear
	AU 1 12 2001 30 11 2002  
	BR 1 11 2003 30 11 2002
	BG 1  9 2001 30 10 2001  
	CL 1 12 2002 20 12 2002
	DK 1 11 2002 28  2 2003  
	DE 1  2 2002 30  8 2002  
	FI 1 10 2002 30  1 2003  
	BE 1  3 2002 30  7 2002  
	FR 1  9 2002 30 12 2002  
	GB 1  6 2002 30 11 2002  
	IE 1 12 2001 28  2 2002  
	IL 1  4 2002 30  6 2002  
	JP 1 11 2002 30 11 2002 
	LV 1 12 2003 30 12 2002 
	MX 1  3 2003 30  3 2003 
	NL 1 10 2002 30  1 2003  
	NZ 1  8 2002 30 10 2002  
	GB 1 10 2002 30  1 2003  
	NO 1  9 2002 30 11 2002  
	AT 1 12 2003 28  2 2004  
	PH 1 11 2002 30 12 2002  
	PL 1  4 2002 30  4 2002  
	PT 1  2 2003 30  7 2003  
	RU 1  2 2002 30  3 2002  
	SE 1  2 2002 30  3 2002  
	CH 1 11 2002 30  3 2003
	SI 1  2 2003 30  3 2003  
	SK 1  9 2002 30 10 2002  
	ES 1  6 2003 30  6 2003  
	TW 1  6 2002 30  7 2002  
	CZ 1  9 2002 30 10 2002  
	HU 1 12 2002 30 12 2002 
	US 1  2 2002 30  6 2002  
	CY 1  6 2002 30  9 2002  
end
	sort iso3166
	tempfile intdate
	save `intdate'
	use `issp'
	sort iso3166
	merge iso3166 using `intdate'
	assert _merge==3
	drop _merge
	gen intdate = round((mdy(bmonth,bday,byear) + mdy(emonth,eday,eyear))/2,1)
	format intdate %d
	labe variable intdate "Date of interview"
	drop bmonth bday byear emont eday eyear
	
	// Demographic Variables
	// ---------------------

	gen age = v201
	replace age = . if age < 18 
	label variable age "`:var lab v201'"

	gen men:dummy = v200 == 1 if v200 <= 2
	lab var men "Man y/n"

	gen edu:edu = 1 if inlist(v205,0,1,2)
	replace edu = 2 if inlist(v205,3,4)
	replace edu = 3 if inlist(v205,5)
	lab var edu "Education"
	lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"
		
	gen mar:mar = 1 if v202==1
	replace mar = 2 if v202==2
	replace mar = 3 if inlist(v202,3,4)
	replace mar = 4 if v202==5
	label value mar mar
	label define mar ///
	  1 "Married, or living together as married" ///
	  2 "Widowed" ///
	  3 "Divorced Or Separated" ///
	  4 "Single, Never Married"
   
	gen unionmemb:dummy = v250==1 if v250<=3
	lab var unionmemb "Trade Union Member y/n"

	gen emp:emp = 1 if inlist(v244,1,2,3)
	replace emp = 2 if v244 == 5
	replace emp = 3 if v244 == 6
	replace emp = 4 if v244 == 7
	replace emp = 5 if v244 == 4 | (v244 >= 8 & v244 < 11)
	lab var emp "Employment Status"
	lab def emp 1 "Employed" 2 "Unemployed" 3 "Still Studying" 4 "Retired" ///
	 5 "Homemaker/Other not in labor force"  

	egen hhinc = xtile(v250) if v250 < 996000 , p(20(20)80) by(iso3166)
	label variable hhinc "Houshold income"
	label value hhinc hhinc
	label define hhinc ///
	  1 "1st Quintile" ///
	  2 "2nd Quintile" ///
	  3 "3rd Quintile" ///
	  4 "4th Quintile" ///
	  5 "5th Quintile"
   
	gen hhsize = v251 
	label variable hhsize "`:var lab v256'"

	gen church:dummy = 0 if inlist(v290,5,6,7,8)
	replace church = 1 if inlist(v290,1,2,3,4)
	label variable church "Regular church attendence"

	gen denom:denom = 1 if v289==2
	replace denom = 2 if v289==3
	replace denom = 3 if inrange(v289,4,12) 
	replace denom = 4 if v289==1
	label variable denom "Denomination"
	label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None" 
	
	gen rural:dummy = v358<=3 if v358 <=6
	label variable rural "Living in rural area/village" 

 	// Participation-Indices
	// ---------------------

	gen voter:dummy = v287 == 1 if inrange(v287,1,2)
	label variable voter "Voted on last election y/n"
	
	gen leftright:lr = v253
	replace leftright = . if leftright > 5
	label variable leftright "`:var lab v258'"
	label define lr ///
	  1 "Far left" 2 "Left, center left" 3 "Center, liberal" ///
	  4 "Right, conservative" 5 "Far right"


	// Clean Data
	// ----------
	
	drop v? v?? v???
	drop if age < 18

	label data "Subset of ISSP 2002"
	save issp02, replace

	exit
	



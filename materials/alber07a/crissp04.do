	// Subdata from ISSP 2004 with Participation indices
	// -------------------------------------------------
	// Creator: kohler@wzb.eu

version 9
	clear
	set memory 90m
	set more off

	use $issp/ZA3950_F1

	// Recode Administrative Variables
	// ------------------------------

	gen dataset = "ISSP 2004"
	ren v381 dataset_version
	tostring v2, gen(persid)
	ren v382 weight
	ren v380 mode
	
	// Country
	decode v3, gen(x)
	gen iso3166 = substr(x,1,2)
	replace iso3166 = "BE" if strpos(x,"Flanders")
	label variable iso3166 "ISO 3166 Country Codes"
	drop x
	egen ctrname = iso3166(iso3166), origin(codes)
	label variable ctrname "Country"

	// Average Interviewdates ISSP 2004
	// Taken from http://zacat.gesis.org/webview/index.jsp
	sort v3
	tempfile issp
	save `issp'
	clear
	input str2 iso3166 bday bmonth byear eday emonth eyear
	AT  7  9 2005 29 12 2005
	AU  1 11 2004 31 12 2004
	BR 05  1 2006 29  1 2006
	BG 15  7 2005 26  7 2005
	CA 29  1 2004 31  3 2004
	CL 11  6 2005  3  7 2005
	CY 15  4 2004 20  9 2004
	CZ 27  9 2004 29 10 2004
	DK 27 10 2004 15  6 2005
	FI 08  9 2004 30 11 2004
	BE 17  3 2004 12  7 2004
	FR  .  .    .  .  .    .
	DE  2  3 2003 12  7 2003
	GB  1  6 2004 30 11 2004
	HU  3 12 2004 20 12 2004
	IE  1 10 2003 15 11 2003
	IL 15  2 2005  1  9 2005
	JP 13 11 2004 21 11 2004
	LV 24 11 2004 16 12 2004
	MX  3  2 2006 12  2 2006
	NL 12 12 2004 31  3 2005
	NZ 29  6 2004  7  9 2004
	NO 29  9 2004 26 11 2004
	PH  4  6 2004 29  6 2004
	PL  1  1 2005 31  1 2005
	PT  1  4 2004 30  9 2004
	RU 26  2 2005 15  3 2005
	SK  6  4 2005 20  4 2005
	SI  1 10 2003 30 11 2003
	ZA  1  8 2004 30  9 2004
	KR 24  6 2004 30  8 2004
	ES  1  8 2004 30 10 2004
	SE  1  2 2004 30  4 2004
	CH 16  3 2005  7  7 2005
	TW  1  4 2004 30  5 2004
	UY 12  7 2004 16  8 2004
	US  1  8 2004 30  1 2005
	VE 22  3 2004  8  4 2004
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

	egen hhinc = xtile(v255), p(20(20)80) by(iso3166)
	label variable hhinc "Houshold income"
	label value hhinc hhinc
	label define hhinc ///
	  1 "1st Quintile" ///
	  2 "2nd Quintile" ///
	  3 "3rd Quintile" ///
	  4 "4th Quintile" ///
	  5 "5th Quintile"
   
	gen hhsize = v256 if v256 <= 30
	label variable hhsize "`:var lab v256'"

	gen church:dummy = 0 if inlist(v300,1,2,3,4)
	replace church = 1 if inlist(v300,5,6,7,8)
	label variable church "Regular church attendence"

	gen rel:dummy = v27<=2 if v27<=4
	label variable rel "At least somewhat religious"
	
	gen denom:denom = 1 if v299==2
	replace denom = 2 if v299==3
	replace denom = 3 if inrange(v299,4,11) | v299==91
	replace denom = 4 if v299==0
	label variable denom "Denomination"
	label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None" 
	
	gen rural:dummy = v378<=3 if v378 < 6
	label variable rural "Living in rural area/village" 

 	// Participation-Indices
	// ---------------------

	gen voter:dummy = v297 == 1 if inrange(v297,1,2)
	label variable voter "Voted on last election y/n"
	
	gen petition:dummy = v18 <= 2 if v18 <= 4
	label variable petition ///
	  "Sign a petition y/n"

	gen protest:dummy = v19 <= 2 if v19 <= 4
	label variable protest ///
	  "Taken part in demonstration y/n"

	gen actgroup:dummy = v20 <= 2 if v20 <= 4
	label variable actgroup "Attend politcal meeting/rally y/n"

	gen contact:dummy = v21 <= 2 if v21 <= 4
	label variable contact "Contact with politician in past 5 years y/n"

	gen donate:dummy = v22 <= 2 if v22 <= 4
	label variable donate ///
	  "Donate money or raise funds y/n"
		
	
	// Attitudes
	// ---------

	ren v59 corrupt

	egen democsat = xtile(v60), by(iso3166) p(25(25)75)
	lab var democsat "Satisfaction with democracy"
	lab val democsat democsat
	label define democsat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 

	sum v25, meanonly
	gen pii:pii = r(max) + 1 - v25 
	label define pii ///
	  1 "Never belonged to" 2 "Used to belong" 3 "Belong, not participate" ///
	  5 "Belong and participate"
	label variable pii "`:var lab v25'"

	gen leftright:lr = v258
	replace leftright = . if leftright > 5
	label variable leftright "`:var lab v258'"
	label define lr ///
	  1 "Far left" 2 "Left, center left" 3 "Center, liberal" ///
	  4 "Right, conservative" 5 "Far right"

	sum v42, meanonly
	gen polint:polint = r(max)+1 - v42
	label variable polint "Political interest"
	label define polint 1 "Minor" 2 "Somewhat" 3 "High" 4 "Very high"

	// Clean Data
	// ----------
	
	drop v? v?? v???
	drop if age < 18

	label data "Subset of ISSP 2004"
	save issp04, replace

	exit
	



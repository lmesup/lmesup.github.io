	// Subdata from EQLS 20043with Participation indices
	// -------------------------------------------------
	// Creator: lenarz@wzb.eu

version 9
	clear
	set memory 90m
	set more off

	use $dublin/eqls_4.dta

	// Recode Administrative Variables
	// ------------------------------

	gen dataset = "EQLS 2003"
	tostring s_respnr, gen(persid)
	ren wcountry weight

	// Country
	label define s_cntry 11 "United Kingdom", modify
	egen iso3166 = iso3166(s_cntry)
    	label variable iso3166 "ISO 3166 Country Codes"

	egen ctrname = iso3166(iso3166), origin(codes)
	label variable ctrname "Country"

	// Average Interviewdates ISSP 2004
	// Taken from Ahrend (2003)
	sort iso3166
	tempfile eqls
	save `eqls'
	clear
	input str2 iso3166 bday bmonth byear eday emonth eyear
	AT 21  5 2003 30 06 2003 
	BE 19  5 2003 11  7 2003
	BG 24 05 2003 12 06 2003
	CY 02 06 2003 04 08 2003
	CZ 23 05 2003 16 06 2003
	DE 12 05 2003 04 07 2003
	DK 13  6 2003 3   7 2003
	EE 30 05 2003 12 06 2003
	ES 02 06 2003 12 07 2003
	FI 05 06 2003 05 08 2003 
 	FR 20 05 2003 05 06 2003
	GB 26 05 2003 30 06 2003
	GR 10 06 2003 09 07 2003
	HU 17 05 2003 23 06 2003
	IE 31 05 2003 23 06 2003
	IT 12 05 2003 13 06 2003 
	LT 23 05 2003 15 06 2003
	LU 12 05 2003 03 07 2003 
	LV 12 05 2003 04 07 2003 
	MT 30 05 2003 30 06 2003
	NL 26 05 2003 28 06 2003
	PL 23 05 2003 17 06 2003
	PT 12 05 2003 30 06 2003
	RO 02 06 2003 20 06 2003
	SE 28 05 2003 06 07 2003
	SI 21 05 2003 17 06 2003
	SK 30 05 2003 23 06 2003
 	TR 14 07 2003 28 07 2003
end
	sort iso3166
	tempfile intdate
	save `intdate'
	use `eqls'
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

	gen age = hh2b
	label variable age "`:var lab hh2b'"

	gen men:dummy = hh2a == 1 if hh2a <= 2
	lab var men "Man y/n"

	gen edu:edu = q47
	replace edu = . if q47 == 4
	lab var edu "Education"
	lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"
		
	gen mar:mar = q32
	replace mar = 2 if q32==3
	replace mar = 3 if q32==2
	label value mar mar
	label define mar ///
	  1 "Married, or living together as married" ///
	  2 "Widowed" ///
	  3 "Divorced Or Separated" ///
	  4 "Single, Never Married"
   
	*gen unionmemb:dummy = v250==1 if v250<=3					// Nichts entsprechendes im Datensatz. Selber zuordnen?
	*lab var unionmemb "Trade Union Member y/n"

	gen emp:emp = emplstat
	replace emp = 2 if emplstat == 3
	replace emp = 3 if emplstat == 5
	replace emp = 5 if inlist(emplstat,2,6) 
	lab var emp "Employment Status"
	lab def emp 1 "Employed" 2 "Unemployed" 3 "Still Studying" 4 "Retired" ///
	 5 "Homemaker/Other not in labor force"  

	egen hhinc = xtile(hhinc1), p(20(20)80) by(iso3166)
	label variable hhinc "Houshold income"
	label value hhinc hhinc
	label define hhinc ///
	  1 "1st Quintile" ///
	  2 "2nd Quintile" ///
	  3 "3rd Quintile" ///
	  4 "4th Quintile" ///
	  5 "5th Quintile"
   
	gen hhsize = hh1 if hh1 <= 30
	label variable hhsize "`:var lab hh1'"

	gen church:dummy = 1 if inlist(q26,1,2,3)
	replace church = 0 if inlist(q26,5,6,7)
	label variable church "Regular church attendence"

	*gen rel:dummy = v27<2 if v27<4					// Nichts Entsprechendes gefunden
	*label variable rel "At least somewhat religious"
	
	*gen denom:denom = 1 if v299==2					// Nichts Entsprechendes gefunden
	*replace denom = 2 if v299==3
	*replace denom = 3 if inrange(v299,4,11) | v299==91
	*replace denom = 4 if v299==0
	*label variable denom "Denomination"
	*label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None" 
	
	gen rural:dummy = region == 1 if region <3
	label variable rural "Living in rural area/village" 


 	// Participation-Indices
	// ---------------------

	gen voter:dummy = q25 == 1 if q25<3
	label variable voter "Voted on last election y/n"
	
	*gen petition:dummy = v17 <= 2 if v17 <= 4			// Nichts Entsprechendes gefunden
	*label variable petition ///
	  "Sign a petition y/n"

	*gen protest:dummy = v19 <= 2 if v19 <= 4				// Nichts Entsprechendes gefunden
	*label variable protest ///
	  "Taken part in demonstration y/n"

	gen actgroup:dummy = q24a <= 1 if q24a <= 2
	label variable actgroup "Attend politcal meeting/rally y/n"

	gen contact:dummy = q24b <= 1 if q24b <= 2
	label variable contact "Contact with politician in past 5 years y/n"

	*gen donate:dummy = v22 <= 2 if v22 <= 4				// Nichts Entsprechendes gefunden
	*label variable donate ///
	  "Donate money or raise funds y/n"
		
	
	// Attitudes
	// ---------

	*ren corrupt corrupt							// Corrupt ist im EQLS ein Index mit Werten für jedes Land an

	gen democsat = . 
	lab var democsat "Satisfaction with democracy"
	lab val democsat democsat
	label define democsat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 

	egen lifesat = xtile(q31), by(iso3166) p(25(25)75)
	lab var lifesat "Satisfaction with life as a hole"
	lab val lifesat lifesat 
	label define lifesat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 


	*sum v25, meanonly							// Nichts Entsprechendes gefunden
	*gen pii:pii = r(max) + 1 - v25 
	*label define pii ///
	  1 "Never belonged to" 2 "Used to belong" 3 "Belong, not participate" ///
	  5 "Belong and participate"
	*label variable pii "`:var lab v25'"

	*gen leftright:lr = v258						// Nichts Entsprechendes gefunden
	*replace leftright = . if leftright > 5
	*label variable leftright "`:var lab v258'"
	*label define lr ///
	  1 "Far left" 2 "Left, center left" 3 "Center, liberal" ///
	  4 "Right, conservative" 5 "Far right"

	*sum v42, meanonly							// Nichts Entsprechendes gefunden
	*gen polint:polint = r(max)+1 - v42
	*label variable polint "Political interest"
	*label define polint 1 "Minor" 2 "Somewhat" 3 "High" 4 "Very high"

	// Clean Data
	// ----------
	
	keep  dataset iso3166 intdate age men edu mar emp hhinc hhsize /// 
	church rural voter actgroup contact democsat lifesat corrupt weight persid
	drop if age < 18

	label data "Subset of EQLS 2003"
	save eqls03, replace

	exit
	



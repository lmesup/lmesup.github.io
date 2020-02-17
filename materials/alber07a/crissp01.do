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

	ren v1 dataset
	ren v381 dataset_version
	ren v2 persid
	ren v382 weight
	ren v380 mode

	// Country
	decode v3, gen(ctrname)
	gen iso3166_2 = substr(ctrname,1,2)
	replace ctrname = substr(ctrname,4,.)
	replace ctrname = "Germany" if strpos(ctrname,"Germany") 
	replace ctrname = "Belgium" if strpos(ctrname,"Flanders")
	replace iso3166_2 = "BE" if ctrname=="Belgium"
	label variable ctrname "Country"
	label variable iso3166_2 "ISO 3166 Country Codes"

	// Date of last election
	// todo

	// Demographic Variables
	// ---------------------

	gen age = v201 if v201 >= 18 
	label variable age "`:var lab v201'"

	gen men:dummy = v200 == "Male":v200 if !mi(v200)
	lab var men "Man y/n"

	gen edu:edu = 1 if inlist(v205,0,1,2)
	replace edu = 2 if inlist(v205,3,4)
	replace edu = 3 if inlist(v205,5)
	lab var edu "Education"
	lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"
		
	gen mar = v202 if v202 < 2
	replace mar = 3 if inlist(v202,3,4)
	replace mar = 4 if v202 == 5
	label value mar mar
	label define mar ///
	  1 "Married, or living together as married" ///
	  2 "Widowed" ///
	  3 "Divorced Or Separated" ///
	  4 "Single, Never Married"
   
	gen unionmemb:dummy = v265==1 if v250<=3
	lab var unionmemb "Trade Union Member y/n"

	gen emp:emp = 1 if inlist(v244,1,2,3)
	replace emp = 2 if v244 == 5
	replace emp = 3 if v244 == 6
	replace emp = 4 if v244 == 7
	replace emp = 5 if v244 == 4 | (v244 >= 8 & v244 < 11)
	lab var emp "Employment Status"
	lab def emp 1 "Employed" 2 "Unemployed" 3 "Still Studying" 4 "Retired" ///
	 5 "Homemaker/Other not in labor force"  

	egen hhinc = xtile(v255) if v255 < 999996, p(20(20)80) by(iso3166_2)
	label value hhinc hhinc
	label define hhinc ///
	  1 "1st Quintile" ///
	  2 "2nd Quintile" ///
	  3 "3rd Quintile" ///
	  4 "4th Quintile" ///
	  5 "5th Quintile"
   
	gen hhsize = v256 if v256 < 95
	label variable hhsize "`:var lab v256'"

	gen church:dummy = 0 if inlist(v300,1,2,3,4)
	replace church = 1 if inlist(v300,5,6,7,8)
	label variable church "Regular church attendence"

	gen rel:dummy = v27>1 if v27<=2 & !mi(v27)
	label variable rel "At least somewhat religious"
	
	gen denom:denom = 1 if inlist(v298,100,110)
	replace denom = 2 if inrange(v298,200,299)
	replace denom = 3 if inlist(v298,14,15,16,17,18) | v298==91
	replace denom = 3 if inrange(v298,300,963)
	replace denom = 4  if v298==0 
	label variable denom "Denomination"
	label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None" 
	
	gen rural:dummy = inlist(v378,4,5) if !mi(v378)
	label variable rural "Living in rural area/village" 

 	// Participation-Indices
	// ---------------------

	gen voter:dummy = v297 == 1 if !mi(v297) & age >= 18
	label variable voter "Voted on last election y/n"
	
	gen contact:dummy = v21 == 1 if inlist(v297,1)
	label variable contact "Contact with politician in past year y/n"
	
	// Attitudes
	// ---------

	egen democsat = xtile(v60) , by(iso3166_2) p(25(25)75)
	label define democsat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 
	label variable democsat "Satisfaction with democracy'"

	sum v56, meanonly
	gen fairelect:fair = r(max) + 1 - v56
	label define fair 1 "unfair" 5 "fair"
	label variable fairelect "`:var lab v56'"

	gen leftright:lr = v258 if v258 <= 5
	label variable leftright "`:var lab v258'"
	label define lr ///
	  0 "Left" ///
	  5 "Right" 
	
	sum v42
	gen polint:polint = r(max)-v42 +1
	label variable polint "Political interest"
	lab  define polint 1 "low" 4 "high"

	// Save
	// ----

	drop v? v?? v???
	drop if mi(age)
	label data "ISSP 2004 (age 18 and above)"
	save issp01, replace

	exit
	

	// European Social Survey from 2004 
	// -------------------------------------------------
	// (Subset of European Social Survey from 2004)
	// Creator: lenarz@wzb.eu

version 9
	clear
	set memory 90m
	set more off

	use $ess/ess2004.dta

	// Recode Administrative Variables
	// ------------------------------
	
	gen dataset= "ESS 2004"
	
	ren edition dataset_version
	
	tostring idno, gen(persid)

	gen intdate = mdy(inwmm,inwdd,inwyr)
	format intdate %d
	lab var intdate "Date of interview"

	ren dweight weight
	ren inwtm mode

	gen iso3166=cntry					
	label variable iso3166 "ISO 3166 Country Codes"

	// Demographic Variables
	// ---------------------

	gen age = inwyr-yrbrn
	label variable age "R: age"

	gen men:dummy = gndr == 1 if gndr <= 2
	lab var men "Man y/n"

	gen edu:edu = 1 if inlist(edulvla,0,1,2)				
	replace edu = 2 if inlist(edulvla,3,4)
	replace edu = 3 if inlist(edulvla,5,6)
	lab var edu "Education"
	lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"
		
	gen mar:mar = 1 if marital==1
	replace mar = 2 if marital==4
	replace mar = 3 if inlist(marital,2,3)
	replace mar = 4 if marital==5
	label value mar mar
	label define mar ///
	  1 "Married, or living together as married" ///
	  2 "Widowed" ///
	  3 "Divorced Or Separated" ///
	  4 "Single, Never Married"

	gen unionmemb:dummy = mbtru==1 if mbtru<=3
	lab var unionmemb "Trade Union Member y/n"


	gen emp:emp = .
	replace emp = 1 if mnactic == 1
	replace emp = 2 if mnactic == 3 | mnactic == 4
	replace emp = 3 if mnactic == 2 
	replace emp = 4 if mnactic == 6
	replace emp = 5 if mnactic == 5 | mnactic == 7 | mnactic == 8 | mnactic == 9
	lab def emp 1 "Employed" 2 "Unemployed" 3 "Education" ///
	4 "Retired" 5 "Homemaker/Other not in labor force"


	egen hhinc = xtile(hinctnt), p(20(20)80) by(iso3166)		
	label variable hhinc "Houshold income"					
	label value hhinc hhinc
	label define hhinc ///
	  1 "1st Quintile" ///
	  2 "2nd Quintile" ///
	  3 "3rd Quintile" ///
	  4 "4th Quintile" ///
	  5 "5th Quintile"
   
	gen hhsize = hhmmb if hhmmb <= 30
	label variable hhsize "How many persons in household"

	gen church:dummy = 1 if inlist(rlgatnd,1,2,3,4)				
	replace church = 0 if inlist(rlgatnd,5,6,7)
	label variable church "Regular church attendence"

	egen rel=xtile(rlgdgr), p(50) by(iso3166)
	replace rel=rel-1
	lab val rel dummy 								
	label variable rel "Religious y/n"
	
	gen denom:denom = 1 if rlgdnm==1
	replace denom = 2 if rlgdnm==2
	replace denom = 3 if inrange(rlgdnm,3,8) 
	replace denom = 4 if rlgblg==2							
	label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None" 
	
	*gen rural:dummy = v378<=3 if v378 < 6					
	*label variable rural "Living in rural area/village" 



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

	*gen donate= 0
	*replace donate=. if dntmny==. | sptcdm==.
	*replace donate=1 if dntmny==1 |  ///
           hmnodm==1 | epaodm==1 | prtydm==1 							
	*label variable donate ///
	  "Donated money in past 12 months y/n"

	
		
	
	// Attitudes
	// ---------

	egen democsat = xtile(stfdem), by(iso3166) p(25(25)75)	
	lab var democsat "Satisfaction with democracy"
	lab val democsat democsat
	label define democsat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 

	egen lifesat = xtile(stflife), by(iso3166) p(25(25)75)
	lab var lifesat "Satisfaction with life as a hole"
	lab val lifesat lifesat 
	label define lifesat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 

	gen leftright:lr = lrscale						
	replace leftright = 1 if inrange(lrscale,0,2)
	replace leftright = 2 if inrange(lrscale,3,4)
	replace leftright = 3 if lrscale==5
	replace leftright = 4 if inrange(lrscale,6,7)
	replace leftright = 5 if inrange(lrscale,8,10)
	label variable leftright "R: Party affiliation: left-right (der.)"
	label define lr ///
	  1 "Far left" 2 "Left, center left" 3 "Center, liberal" ///
	  4 "Right, conservative" 5 "Far right"

	sum polintr, meanonly
	gen polint:polint = r(max)+1 - polintr
	label variable polint "Political interest"
	label define polint 1 "Minor" 2 "Somewhat" 3 "High" 4 "Very high"

	// Clean Data
	// ----------
	
	keep dataset dataset_version persid intdate weight mode iso3166 ///
	age men edu mar unionmemb emp hhinc hhsize church rel ///
	denom voter petition protest actgroup contact democsat lifesat ///
	leftright polint //Variable donate konnte nicht mehr gebildet werden, war im ESS02 noch möglich
	
	drop if age < 18

	label data "Subset of ESS 2004"
	save ess04, replace

	exit







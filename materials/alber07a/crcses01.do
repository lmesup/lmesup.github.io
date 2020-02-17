	// Subdata from CSES Modules 1 and 2
	// ----------------------------------
	// Creator: kohler@wzb.eu

version 9
	clear
	set memory 90m
	set more off

	// +--------------+
	// | CSES Modul 1 |
	// +--------------+

	use $cses/mycses1

	// Recode Administrative Variables
	// ------------------------------

	ren a1001 dataset
	ren a1002 dataset_version
	ren a1004 studyid
	ren a1005 persid

	ren a1010_1 dweight
	ren a1013 popweight

	ren a1015 eltype  
	label value eltype eltype
	label define eltype ///
	  10 "Parliamentary/Legislative" ///
	  12 "Parliamentary/Legislative And Presidential" ///
	  13 "Parliamentary/Legislative And Prime Minister" ///
	  20 Presidential

	ren a1023 mode
	labelrename `:value label mode' mode
	label define mode 6 "Internet based survey", modify

	gen intnr = a1024 if a1024 < 99999
	label variable intnr "`:var lab a1024'"

	gen intmen:dummy=a1025==1 if a1025<=2
	label variable intmen "Interviewer man y/n"
	label define dummy 0 "No" 1 "Yes"

	// Country
	sort a1006
	preserve
	clear
	input a1006 str30 ctrname str2 iso3166_2 str5 eu
	80 Albania AL      NoEU
	320 Argentina AR   NoEU
	360 Australia AU   NoEU
	400 Austria  AT    EU-15
	561 Belgium BE     EU-15
	562 Belgium BE     EU-15
	700 "Bosnia-Herzegovina" BA NoEU
	760 Brazil BR      NoEU
	1000 Bulgaria BG   CC-4
	1120 Belarus  BY   NoEU
	1240 Canada CA     NoEU
	1520 Chile   CL    NoEU
	1580 Taiwan  TW    NoEU
	1700 Colombia CO   NoEU
	1880 "Costa Rica" CR NoEU
	1910 Croatia  HR   CC-4
	2030 "Czech Republic" CZ NMS-10
	2080 Denmark DK   EU-15
	2180 Ecuador EC   NoEU
	2330 Estonia EE   NMS-10
	2460 Finland FI   EU-15
	2500 France  FR   EU-15
	2680 Georgia     GE NoEU
	2760 Germany DE  EU-15
	3000 Greece  GR  EU-15
	3440 "Hong Kong" HK NoEU
	3480 Hungary HU  NMS-10
	3520 Iceland IS  NoEU
	3560 India ID    NoEU
	3760 Israel IL   NoEU
	3800 Italy IT    NoEU
	3920 Japan JP    NoEU
	4100 "Korea, Rep."  KR NoEU
	4280 Latvia LV   NMS-10
	4400 Lithuania LT NMS-10
	4840 Mexico MX  NoEU
	4980 "Moldova, Rep." MD NoEU
	5280 Netherlands NL EU-15
	5540 "New Zealand" NZ NoEU
	5780 Norway NO NoEU
	5910 Panama PA NoEU
	6040 Peru PE   NoEU
	6080 Philippines PH NoEU
	6160 Poland PL NMS-10
	6200 Portugal PT EU-15
	6420 Romania RO CC-4
	6430 Russia RU NoEU
	7020 Singapore SG NoEU
	7030 Slovakia SK NMS-10
	7050 Slovenia SI NMS-10
	7100 "South Africa" ZA NoEU
	7240 Spain ES EU-15
	7520 Sweden SE EU-15
	7560 Switzerland CH NoEU
	7640 Thailand TH NoEU
	7800 "Trinidad And Tobago" TT NoEU
	7920 Turkey TU CC-4
	8040 Ukraine UA NoEU
	8070 Macedonia MK NoEU
	8260 "United Kingdom" GB EU-15
	8400 "United States" US NoEU
	8580 Uruguay UY NoEU
	8620 Venezuela VE NoEU
	8910 Yugoslavia YU NoEU
	8940 Zambia ZM NoEU
end
	
	sort a1006
	compress
	tempfile iso
	save `iso'
	restore
	merge a1006 using `iso', nokeep
	assert _merge==3
	drop _merge a1006
	label variable ctrname "Country"
	label variable iso3166_2 "ISO 3166 Country Codes"
	
	// Election date
	gen el1date = mdy(a1016,a1017,a1018)
	format %dN/D/Y el1date 
	lab var el1date "Date of 1st Election"
	gen el2date = mdy(a1019,a1020,a1021)
	format %dN/D/Y el?date
	lab var el2date "Date of 2nd Election"
	drop a1016-a1021

	// Interviewer-date
	// Impute missing month
	replace a1026 = . if a1026==99
	by studyid, sort: gen mi = sum(a1026)/sum(a1026<.)
	by studyid: replace a1026 = round(mi[_N],1) if a1026>=.
	drop mi
	// impute missing day
	replace a1027 = 15 if a1027 == 99  
	// do not imput year
	replace a1028 = . if a1028 == 9999
	// date
	gen intdate = mdy(a1026,a1027,a1028)
	format %dN/D/Y el1date
	lab var intdate "Date of Interview"
	drop a1026-a1028
	
	// Demographic Variables
	// ---------------------

	gen age = a2001
	replace age = . if age >= 998 | age < 15
	label variable age "`:var lab a2001'"

	gen men:dummy = a2002 == 1 if a2002<=2
	lab var men "Man y/n"
	drop a2002

	gen edu:edu = 1 if inlist(a2003,1,2,3,4)
	replace edu = 2 if inlist(a2003,5,6,7)
	replace edu = 3 if inlist(a2003,8)
	lab var edu "Education"
	lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"
		
	ren a2004 mar
	replace mar = . if mar >= 8
	replace mar = . if iso3166_2 == "BE"
	label value mar mar
	label define mar ///
	  1 "Married, or living together as married" ///
	  2 "Widowed" ///
	  3 "Divorced Or Separated" ///
	  4 "Single, Never Married"
   
	gen unionmemb:dummy = a2005==1 if a2005<=2
	lab var unionmemb "Trade Union Member y/n"
	drop a2005

	gen unionmembhh:dummy = a2006==1 if a2006<=2
	replace unionmembhh = 1 if unionmemb==1 & a2006 <= 2
	lab var unionmembhh "Trade Union Member in HH y/n"
	drop a2006

	gen emp:emp = 1 if inlist(a2007,1,2,3)
	replace emp = 2 if a2007 == 5
	replace emp = 3 if a2007 == 6
	replace emp = 4 if a2007 == 7
	replace emp = 5 if a2007 == 4 | (a2007 >= 8 & a2007 < 11)
	lab var emp "Employment Status"
	lab def emp 1 "Employed" 2 "Unemployed" 3 "Still Studying" 4 "Retired" ///
	 5 "Homemaker/Other not in labor force"  
	replace emp = . if iso3166_2 == "CL"  // Invalid in Chile

	ren a2012 hhinc
	replace hhinc = . if hhinc > 5
	label value hhinc hhinc
	label define hhinc ///
	  1 "1st Quintile" ///
	  2 "2nd Quintile" ///
	  3 "3rd Quintile" ///
	  4 "4th Quintile" ///
	  5 "5th Quintile"
   
	gen hhsize = a2013 if a2013 <= 80
	label variable hhsize "`:var lab a2013'"

	gen childs = a2014 if a2014 <= 80
	label variable childs "`:var lab a2014'"

	gen control = hhsize < childs if childs < .
	replace hhsize = . if control==1
	replace childs = . if control==1
	drop control
	
	gen church:dummy = 0 if inlist(a2015,1,2,3)
	replace church = 1 if inlist(a2015,4,5,6)
	label variable church "Regular church attendence"

	gen rel:dummy = a2016>1 if a2016<8
	label variable rel "At least somewhat religious"
	
	gen denom:denom = 1 if a2017==1
	replace denom = 2 if inrange(a2017,2,13)
	replace denom = 3 if inlist(a2017,14,15,16,17,18) | a2017==91
	replace denom = 3 if inrange(a2017,20,29)
	replace denom = 3 if inrange(a2017,30,39)
	replace denom = 3 if inrange(a2017,40,79)
	replace denom = 3 if a2017==80 | a2017==84 | a2017==85
	replace denom = 4 ///
	  if a2017==81 | a2017==82 | a2017==83 | a2017==92 | a2017==93  
	label variable denom "Denomination"
	label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None" 
	
	gen rural:dummy = a2022==1 if a2022 < 7
	label variable rural "Living in rural area/village" 

 	// Participation-Indices
	// ---------------------

	gen voter:dummy = a2028 == 1 | a2028 == 6 if inrange(a2028,1,7)
	label variable voter "Voted on last election y/n"
	
	gen contact:dummy = a3027 == 1 if inlist(a3027,1,5)
	label variable contact "Contact with politician in past year y/n"
	
	// Attitudes
	// ---------

	gen democsat:democsat = a3001
	replace democsat = . if inlist(democsat,3,8,9)
	replace democsat = democsat - 1 if democsat > 3
	replace democsat = 5 - democsat
	label define democsat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 
	label variable democsat "`:var lab a3001'"

	replace a3002 = . if a3002 >= 8 
	sum a3002, meanonly
	gen fairelect:fair = r(max) + 1 - a3002
	label define fair 1 "unfair" 5 "fair"
	label variable fairelect "`:var lab a3002'"

	gen pi:dummy = inlist(a3004,1,6) if inrange(a3004,1,7)
	label variable pi "Party identification"

	replace a3012 = . if a3012 >= 8 | a3012 == 0
	sum a3012, meanonly
	gen pii:pii = r(max) + 1 - a3012 
	label define pii 1 "Not very close" 2 "Somewhat close" 3 "Very close"
	label variable pii "`:var lab a3012'"

	replace a3013 = . if a3013 >= 8 
	sum a3013, meanonly
	gen partcare:care = r(max)+1 - a3013
	label define care 1 "Don't care" 5 "Care"
	label variable partcare "`:var lab a3013'"

	replace a3014 = . if a3014 >= 8 
	sum a3014, meanonly
	gen partneces:neces = r(max)+1 - a3014
	label define neces 1 "Not necessary" 5 "Necessary"
	label variable partneces "`:var lab a3014'"

	replace a3022 = . if a3022 >= 8 
	sum a3022, meanonly
	gen econdevel:badgood = r(max)+1 - a3022
	label define badgood 1 "Very bad" 2 "Bad" 3 "Neither good or bad" ///
	  4 "Good" 5 "Very good"
	label variable econdevel "`:var lab a3022'"

	gen econchange:chg = 3 if a3023 == 1
	replace econchange = 2 if a3023 == 3
	replace econchange = 1 if a3023 == 5
	label define chg 1 "Gotten worse" 2 "Stayed the same" 3 "Gotten better" 
	label variable econchange "`:var lab a3023'"

	replace a3026 = . if a3026 >= 8 
	sum a3026, meanonly
	gen polknow:know = r(max)+1 - a3026
	label define know 1 "They don't know" 5 "They know"
	label variable polknow "`:var lab a3026'"

	replace a3028 = . if a3028 >= 8 
	sum a3028, meanonly
	gen powmatters:matters = r(max) + 1 - a3028 
	label define matters 1 "It doesn't makes a difference" ///
	5 "It makes a difference" 
	label variable powmatters "`:var lab a3028'"

	gen votematters:matters = a3029  if  a3029 < 8
	label variable votematters "`:var lab a3029'"

	gen leftright:lr = a3031
	replace leftright = . if leftright > 10
	label variable leftright "`:var lab a3031'"
	label define lr ///
	  0 "Left" ///
	  10 "Right" 
	

	mvdecode a2023-a2025, mv(8,9)
	gen polinform:polin = 1+ (a2023==1) + (a2024==1) + (a2025==1) ///
	  if !mi(a2023,a2024,a2025)
	label variable polinform "Political information index"
	label define polin 1 "Minor" 2 "Somewhat" 3 "High" 4 "Very high"


	// Kontext
	// -------
	
	ren a2027 constit 
	replace constit = . if constit == 0 | constit >= 99998
	_strip_labels constit

	ren a4002 constit_cand
	replace constit_cand = . if constit_cand == 0 | constit_cand==9999
	_strip_labels constit_cand

	ren a4003 constit_party
	replace constit_party = . if constit_party == 0 | constit_party==999
	_strip_labels constit_party

	ren a4005 constit_turnout
	replace constit_turnout = . ///
	  if constit_turnout == 0 | constit_turnout==999
	_strip_labels constit_turnout
	
	replace a5031 = 1 if a5031 == 9
	sum a5031, meanonly
	gen compulsory:compul = r(max)+1 - a5031
	label variable compulsory "Compulsory Voting"
	label define compul 1 "No" 2 "Yes, without sanction" ///
	3 "Yes, limited enforcement" 4 "Yes, weak enforcement" ///
	5 "Yes, strong enforcement"

	// Clean up Data
	drop a1* a2* a3* a4* a5*

	compress
	tempfile cses1
	save `cses1'

	// +--------------+
	// | CSES Modul 2 |
	// +--------------+

	use using $cses/mycses2

	// Recode Administrative Variables
	// ------------------------------

	ren b1001 dataset
	ren b1002 dataset_version
	ren b1004 studyid
	ren b1005 persid

	ren b1010_1 dweight
	ren b1013 popweight

	ren b1015 eltype
	label value eltype eltype
	label define eltype ///
	  10 "Parliamentary/Legislative" ///
	  12 "Parliamentary/Legislative And Presidential" ///
	  13 "Parliamentary/Legislative And Prime Minister" ///
	  20 Presidential

	ren b1023 mode
	labelrename `:value label mode' mode
	label define mode 6 "Internet based survey", modify

	gen intnr = b1024 if b1024 < 99999
	label variable intnr "`:var lab b1024'"

	gen intmen:dummy=b1025==1 if b1025<=2
	label variable intmen "Interviewer man y/n"
	replace intmen=. if studyid == "PHL_2004"

	// Country
	gen int x = real(b1006)
	sort x
	preserve
	clear
	input x str30 ctrname str2 iso3166_2 str5 eu
	80 Albania AL      NoEU
	320 Argentina AR   NoEU
	360 Australia AU   NoEU
	400 Austria  AT    EU-15
	560 Belgium BE     EU-15
	700 "Bosnia-Herzegovina" BA NoEU
	760 Brazil BR      NoEU
	1000 Bulgaria BG   CC-4
	1120 Belarus  BY   NoEU
	1240 Canada CA     NoEU
	1520 Chile   CL    NoEU
	1580 Taiwan  TW    NoEU
	1700 Colombia CO   NoEU
	1880 "Costa Rica" CR NoEU
	1910 Croatia  HR   CC-4
	2030 "Czech Republic" CZ NMS-10
	2080 Denmark DK   EU-15
	2180 Ecuador EC   NoEU
	2330 Estonia EE   NMS-10
	2460 Finland FI   EU-15
	2500 France  FR   EU-15
	2680 Georgia GE NoEU
	2761 Germany DE EU-15
	2762 Germany DE EU-15
	3000 Greece  GR  EU-15
	3440 "Hong Kong" HK NoEU
	3480 Hungary HU  NMS-10
	3520 Iceland IS  NoEU
	3560 India ID    NoEU
	3720 Ireland IE  EU-15
	3760 Israel IL   NoEU
	3800 Italy IT    NoEU
	3920 Japan JP    NoEU
	4100 "Korea, Rep."  KR NoEU
	4280 Latvia LV   NMS-10
	4400 Lithuania LT NMS-10
	4840 Mexico MX  NoEU
	4980 "Moldova, Rep." MD NoEU
	5280 Netherlands NL EU-15
	5540 "New Zealand" NZ NoEU
	5780 Norway NO NoEU
	5910 Panama PA NoEU
	6040 Peru PE   NoEU
	6080 Philippines PH NoEU
	6160 Poland PL NMS-10
	6200 Portugal PT EU-15
	6420 Romania RO CC-4
	6430 Russia RU NoEU
	7020 Singapore SG NoEU
	7030 Slovakia SK NMS-10
	7050 Slovenia SI NMS-10
	7100 "South Africa" ZA NoEU
	7240 Spain ES EU-15
	7520 Sweden SE EU-15
	7560 Switzerland CH NoEU
	7640 Thailand TH NoEU
	7800 "Trinidad And Tobago" TT NoEU
	7920 Turkey TU CC-4
	8040 Ukraine UA NoEU
	8070 Macedonia MK NoEU
	8261 "United Kingdom" GB EU-15
	8400 "United States" US NoEU
	8580 Uruguay UY NoEU
	8620 Venezuela VE NoEU
	8910 Yugoslavia YU NoEU
	8940 Zambia ZM NoEU
end
	
	sort x
	compress
	tempfile iso
	save `iso'
	restore
	merge x using `iso', nokeep
	assert _merge==3
	drop _merge x b1006
	label variable ctrname "Country"
	label variable iso3166_2 "ISO 3166 Country Codes"
	
	// Election date
	gen el1date = mdy(b1016,b1017,b1018)
	format %dN/D/Y el1date 
	lab var el1date "Date of 1st Election"
	gen el2date = mdy(b1019,b1020,b1021)
	format %dN/D/Y el?date
	lab var el2date "Date of 2nd Election"
	drop b1016-b1021

	// Interviewer-date
	// Impute missing month
	replace b1026 = . if b1026==99
	by studyid, sort: gen mi = sum(b1026)/sum(b1026<.)
	by studyid: replace b1026 = round(mi[_N],1) if b1026>=.
	drop mi
	// impute missing day
	replace b1027 = 15 if b1027 == 99  
	// do not imput year
	replace b1028 = . if b1028 == 9999
	// date
	gen intdate = mdy(b1026,b1027,b1028)
	format %dN/D/Y el1date
	lab var intdate "Date of Interview"
	drop b1026-b1028
	
	// Demographic Variables
	// ---------------------

	gen age = b2001
	replace age = . if age >= 997 | age < 15
	label variable age "`:var lab b2001'"

	gen men:dummy = b2002 == 1 if b2002<=2
	lab var men "Man y/n"
	drop b2002

	gen edu:edu = 1 if inlist(b2003,1,2,3,4)
	replace edu = 2 if inlist(b2003,5,6,7)
	replace edu = 3 if inlist(b2003,8)
	lab var edu "Education"
	lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"
	drop if iso3166_2 == "GB" /// -> Note
		
	ren b2004 mar
	replace mar = . if mar >= 5
	replace mar = . if iso3166_2 == "BE"
	label value mar mar
	label define mar ///
	  1 "Married, or living together as married" ///
	  2 "Widowed" ///
	  3 "Divorced Or Separated" ///
	  4 "Single, Never Married"


	gen unionmemb:dummy = b2005==1 if b2005<=2
	lab var unionmemb "Trade Union Member y/n"
	drop b2005

	gen unionmembhh:dummy = b2006==1 if b2006<=2
	replace unionmembhh = 1 if unionmemb==1 & b2006 <= 2
	lab var unionmembhh "Trade Union Member in HH y/n"
	drop b2006

	gen emp:emp = 1 if inlist(b2010,1,2,3)
	replace emp = 2 if b2010 == 5
	replace emp = 3 if b2010 == 6
	replace emp = 4 if b2010 == 7
	replace emp = 5 if b2010 == 4 | (b2010 >= 8 & b2010 < 11)
	lab var emp "Employment Status"
	lab def emp 1 "Employed" 2 "Unemployed" 3 "Still Studying" ///
	  4 "Retired" 5 "Homemaker/Other not in labor force"  
	replace emp = . if iso3166_2 == "CL"  // Invalid in Chile
	replace emp = 1 if b2010 == 11 & iso3166_2 == "FR"
	replace emp = 2 if b2010 == 12 & iso3166_2 == "FR"

	ren b2020 hhinc
	replace hhinc = . if hhinc > 5
	label value hhinc hhinc
	label define hhinc ///
	  1 "1st Quintile" ///
	  2 "2nd Quintile" ///
	  3 "3rd Quintile" ///
	  4 "4th Quintile" ///
	  5 "5th Quintile"

	gen hhsize = b2021 if b2021 < 97
	label variable hhsize "`:var lab b2021'"

	gen childs = b2022 if b2022 <= 97
	label variable childs "`:var lab b2022'"

	gen control = hhsize < childs if childs < .
	replace hhsize = . if control==1
	replace childs = . if control==1
	drop control
	
	gen church:dummy = 0 if inlist(b2023,1,2,3)
	replace church = 1 if inlist(b2023,4,5,6)
	label variable church "Regular church attendence"
	  
	gen rel:dummy = b2024>1 if b2024<7
	label variable rel "At least somewhat religious"

	gen denom:denom = 1 if b2025==1
	replace denom = 2 if inrange(b2025,2,13)
	replace denom = 3 if inlist(b2025,14,15,16,17,18) | b2025==91
	replace denom = 3 if inrange(b2025,20,29)
	replace denom = 3 if inrange(b2025,30,39)
	replace denom = 3 if inrange(b2025,40,79)
	replace denom = 3 if b2025==80 | b2025==84 | b2025==85
	replace denom = 4 ///
	  if b2025==81 | b2025==82 | b2025==83 | b2025==92 | b2025==93  
	label variable denom "Denomination"
	label define denom 1 "Catholic" 2 "Protestant" 3 "Other"  4 "None"
	replace denom = 2 if b2025==81 & iso3166_2 == "NL"
	replace denom = 2 if b2025==81 & iso3166_2 == "CZ"


	gen rural:dummy = b2030==1 if b2030 < 7
	replace rural = . if iso3166_2 == "CH"
	label variable rural "Living in rural area/village" 

	// Participation-Indices
	// ---------------------

	gen persother:dummy = b3001_1 ==1 if b3001_1 <= 2
	label variable persother "`:var lab b3001_1'"

	gen campact:dummy = b3001_2 ==1 if b3001_2 <= 2
	label variable campact "`:var lab b3001_2'"

	gen voter:dummy = b3004_1 == 1 if inrange(b3004_1,1,2)
	replace voter = 1 if voter >= . & b3004_2 == 1
	replace voter = 0 if voter >= . & b3004_2 == 2
	label variable voter "Voted on last election y/n"
	
	gen contact:dummy = b3042_1 == 1 if b3042_1 <= 2
	label variable contact "Contact with politician in past 5 years y/n"

	gen protest:dummy = b3042_2 == 1 if b3042_2 <= 2
	label variable protest ///
	  "Taken part in portest or demonstration in past 5 years y/n"

	gen actgroup:dummy = b3042_3 == 1 if b3042_3 <= 2
	label variable actgroup "Worked togehter with people y/n"
	
	// Attitudes
	// ---------

	sum b3043 if b3043<7, meanonly
	gen humrights:humright = r(max) + 1 - b3043
	replace humrights = . if humrights < 0
	lab variable humrights "Subjective evaluation of freedom/human rights"
	label define humright 1 "No" 2 "Not much"  3 "Some" 4 "A lot"
	drop b3043

	sum b3044 if b3044<7, meanonly
	gen corruption:corrupt = r(max) + 1 - b3044
	replace corruption = . if corruption < 0
	lab variable corruption "Subjective evaluation of corruption"
	label define corrupt 1 "No" 2 "Seldom"  3 "widespread" 4 "very widespread"
	drop b3044

	gen democsat:democsat = b3012
	replace democsat = . if inlist(democsat,6,7,8,9)
	replace democsat = 5 - democsat
	label define democsat 4 "Very satisfied" 3 "Fairly satisfied" ///
	   2 "Not very satisfied" 1 "Not at all satisfied" 
	label variable democsat "`:var lab b3012'"

	gen pi:dummy = inlist(b3028,1,6) if inrange(b3028,1,2)
	label variable pi "Party identification"

	replace b3036 = . if b3036 >= 7 | b3036 == 0
	sum b3036, meanonly
	gen pii:pii = r(max) + 1 - b3036 
	label define pii 1 "Not very close" 2 "Somewhat close" 3 "Very close"
	label variable pii "`:var lab b3036'"

	replace b3013 = . if b3013 >= 7 
	sum b3013, meanonly
	gen powmatters:matters = r(max) + 1 - b3013 
	label define matters 1 "It doesn't makes a difference" ///
	5 "It makes a difference" 
	label variable powmatters "`:var lab b3013'"

	gen votematters:matters = b3014  if  b3014 < 7
	label variable votematters "`:var lab b3014'"

	gen leftright:lr = b3045
	replace leftright = . if leftright > 10
	label variable leftright "`:var lab b3045'"
	label define lr ///
	  0 "Left" ///
	  10 "Right" 

	mvdecode b3047_1-b3047_3, mv(8,9)
	gen polinform:polin = 1+ (b3047_1==1) + (b3047_2==1) + (b3047_3==1) ///
	  if !mi(b3047_1,b3047_2,b3047_3)
	label variable polinform "Political information index"
	label define polin 1 "Minor" 2 "Somewhat" 3 "High" 4 "Very high"


	// Kontext
	// -------
	
	ren b2031 constit 
	replace constit = . if constit == 0 | constit >= 99998
	_strip_labels constit

	ren b4002 constit_cand
	replace constit_cand = . if constit_cand == 0 | constit_cand==9999
	_strip_labels constit_cand

	ren b4003 constit_party
	replace constit_party = . if constit_party == 0 | constit_party==999
	_strip_labels constit_party

	ren b4005 constit_turnout
	replace constit_turnout = . ///
	  if constit_turnout == 0 | constit_turnout==999
	_strip_labels constit_turnout
	
	replace b5037 = 1 if b5037 == 9
	sum b5037, meanonly
	gen compulsory:compul = r(max)+1 - b5037
	label variable compulsory "Compulsory Voting"
	label define compul 1 "No" 2 "Yes, without sanction" ///
	3 "Yes, limited enforcement" 4 "Yes, weak enforcement" ///
	5 "Yes, strong enforcement"

	// Clean up Data
	drop b1* b2* b3* b4* b5*

	compress
	tempfile cses2
	save `cses2'


	// +-----------------------+
	// | Append one to another |
	// +-----------------------+
	
	use `cses1', clear
	append using `cses2'

	order persid dataset dataset_version studyid ctrname iso3166_2 eu ///
	  dweight popweight intdate mode intnr intmen ///
	  men age edu emp mar hhinc hhsize childs church rel denom rural ///
	  unionmemb unionmembhh ///
	  voter contact persother campact protest actgroup ///
	  pi pii leftright democsat fairelect partcare partneces humrights corruption ///
	  polknow powmatters votematters polinform econdevel econchange constit ///
	  constit_cand constit_party constit_turnout compulsory el1date el2date ///
	  eltype


	// +----------------+
	// | Rectangularize |
	// + ---------------+

	// Only EU, US and Switzerland
	drop if eu == "NoEU" & iso3166_2 != "CH" & iso3166_2 != "US"
	
	// I drop some studies, because some variables I realy need are missing 
	gen missing = .
	foreach var of varlist voter emp hhinc {
		by dataset iso3166_2, sort: replace missing = sum(`var'==.)
		by dataset iso3166_2: drop if missing[_N] == _N
	}
	drop missing

	// I only keep countries with two CSES participations 
	by iso3166_2 dataset, sort: gen x = 1 if _n==1
	by iso3166_2: replace x = sum(x)
	by iso3166_2: drop if x[_N] < 2
	drop x

	label data "Harmonized CSES 1,2"
	save cses01, replace

	exit
	


	Note 1: Great Britain in CSES Module 2 completely droped because
	it was an internet survey. This seems to be useless. Data on
	Education seriously flawed.

	// Eurobarometer 62.1 (2004)
	// -------------------------

	use ~/data/eb/za4230, clear
	
	// Substantial Variables
	// ---------------------

	// Pro EU Constitution
	gen proconstitution:yesno = qa2<=2 if qa2 < 5
	label var proconstitution "In favour of constitution"
	label def yesno 0 "no" 1 "yes"

	// Future of EU's Economy
	gen ecofut:yesno = qb13<=2 if qb13 < 5
	lab var ecofut "EU will become world's top Economic power"
	
	// Left-Right
	gen right:right = d1 if d1 <= 10
	replace right = .a if right == 11
	replace right = .b if right == 12
	label define right 1 "left" 10 "right" .a "refusal" .b "dk"
	lab var right "Left-right placement"

	// EU as Engine for Economy
	gen euengine:yesno = vqb19_4 == 1 if vqb19_4 <= 4  // DK included!
	lab var euengine "EU is most suited to support economic growth"
	
	// Jugements
	label define goodness 1 "Very bad" 2 "Rather bad" 3 "Rather good" 4 "Very good"
	local i 1
	foreach var of newlist nateco eueco natemp natenv natsoc ownqual ownfin {
		gen `var':goodness = 5 - vqb1_`i' if vqb1_`i++' < 5
	}
	label variable nateco "National economy situation"
	label variable eueco "European economy situation"
	label variable natemp "National employment situation"
	label variable natenv "National environment situation"
	label variable natsoc "National social welfare situation"
	label variable ownqual "Own quality of life"
	label variable ownfin "Own financial situation"
	
	// Comparisons I
	label define comp -2 "Definetelly less good" -1 "Somewhat less good" 0 "Identical" 1 "Somewhat better" 2 "Much better"
	
	local i 1
	foreach var of newlist compeco compemp compenv compsoc compqual {
		gen `var':comp = -2 if vqb2_`i' == 4
		replace `var'  = -1 if vqb2_`i' == 3
		replace `var'  =  0 if vqb2_`i' == 5
		replace `var'  =  1 if vqb2_`i' == 2
		replace `var'  =  2 if vqb2_`i++' == 1
	}
	label variable compeco "Own Country-EU: Economy situation"
	label variable compemp "Own Country-EU: Employment situation"
	label variable compenv "Own Country-EU: Environment situation"
	label variable compsoc "Own Country-EU: Social welfare situation"
	label variable compqual "Own Country-EU: Quality of life"

	// Comparisons II
	local i 1
	foreach var of newlist compusa compjap compchi compind {
		gen `var':comp = -2 if vqb4_`i' == 4
		replace `var'  = -1 if vqb4_`i' == 3
		replace `var'  =  0 if vqb4_`i' == 5
		replace `var'  =  1 if vqb4_`i' == 2
		replace `var'  =  2 if vqb4_`i++' == 1
	}
	label variable compusa "EU-USA: Quality of life"
	label variable compjap "EU-Japan: Quality of life"
	label variable compchi "EU-China: Quality of life"
	label variable compind "EU-India: Quality of life"

	// Demographie
	// -----------
	
	// Marital Status
	gen mar:mar = 1 if inlist(d7,1,2)
	replace mar = 2 if inlist(d7,3,4,5)
	replace mar = 3 if inlist(d7,6)
	replace mar = 4 if inlist(d7,8)
	replace mar = 5 if inlist(d7,7,9,10)
	label define mar 1 "Married" 2 "Unmarried" 3 "Divorced" 4 "Widowed" 5 "Other, missing"
	label var mar "Marital Status" 

	// Education
	gen edu:edu = d8r
	replace edu = 1 if edu == 5
	replace edu = 4 if inlist(edu,4,6)
	label define edu 1 "Low" 2 "Intermediate" 3 "High" 4 "Other, missing"
	label var edu "Education"

	// Employment
	ren c14 empocc
	lab var empocc "Combined employment and occupation"
		
	// Frauen
	gen men:yesno = d10 == 1 if !missing(d10)
	lab var men "Men y/n"
	
	// Age
	ren d11 age
	lab var age "Age"

	// City
	gen loc:loc = d25 if d25 < 4
	label define loc 1 "Rural area" 2 "Small or middle sized town" 3 "Large town"
	label variable loc "Type of community"

	// Houshold-Size
	ren d40abc hhgr
	label variable hhgr "Household-size"

	// Survey Properties
	// ----------------

	// ID
	ren resp_id id
	lab var id "Original response ID"
	ren intv_id intnr
	lab var intnr "Interviewer Number"
	
	// Weights
	ren w1 weight

	// Time of interview
	gen time = vp2
	gen am:time = vp2/1200 * 360 if vp2 <= 1200
	gen pm:time = (vp2-1200)/1200 * 360 if vp2 >= 1200 & vp2 < 2400
	lab def time 0 "0:00" 90 "3:00" 180 "6:00" 270 "9:00"
	lab var time "Time of Interview"
	lab var am "Circular Time of Interview (AM)"
	lab var pm "Circular Time of Interview (PM)"
	
	// Staaten nach ISO 3166
	sort country
	preserve
	clear
	input country str2 iso3166_2 str3 iso3166_3 
           1 BE BEL 
           2 DK DNK 
           3 DE DEU 
           4 DE DEU 
           5 GR GRE 
           6 ES ESP 
           7 FI FIN 
           8 FR FRA 
           9 IE IRL 
          10 IT ITA 
          11 LU LUX   
          12 NL NLD    
          13 AT AUT 
          14 PT PRT 
          15 SE SWE 
          16 GB GBR 
          17 GB GBR 
          18 CY CYP 
          19 CZ CZE 
          20 EE EST 
          21 HU HUN 
          22 LV LVA 
          23 LT LTA  
          24 MT MLT 
          25 PL POL 
          26 SK SVK 
          27 SI SVN  
end
	lab var country "Country"
	lab var iso3166_2 "Country"
	lab var iso3166_3 "Country"
	sort country
	tempfile iso
	save `iso'
	restore
	merge country using `iso'
	assert _merge == 3
	drop _merge
	
	keep country iso3166_2 iso3166_3 id intnr time am pm weight ///
	  eueco nat* own* comp*  proconstitution right ecofut euengine ///
	  men age loc edu empocc mar
	compress

	// Long country Names, EU
	sort iso3166_2
	preserve
	drop _all
	input str2 iso3166_2 str30 ctrname eu
	AT Austria 1
	AU Australia 0
	BE Belgium 1
	BG Bulgaria 3
	BR Brazil 0
	BY Belarus 0
	CH Switzerland 0
	CA Canada 0
	CL Chile 0
	CY Cyprus 2
	CZ "Czech Republic" 2
	DE Germany 1
	DK Denmark 1
	EE Estonia 2
	ES Spain 1
	FI Finland 1
	FR France 1
	GB "United Kingdom" 1
	GR Greece 1
	HR Croatia 3
	HU Hungary 2 
	IE Ireland 1
	IL Israel 0
	IS Iceland 0
	JP Japan 0 
	IT Italy 1
	KR "Korea Rep. of" 0
	LT Lithuania 2
	LU Luxembourg 1
	LV Latvia 2
	MT Malta 2
	MX Mexico 0
	NL Netherlands 1
	NZ "New Zealand" 0
	NO Norway 0
	PH Philippines 0
	PL Poland 2
	PT Portugal 1
	RO Romania 3
	RU "Russian Federation" 0
	SE Sweden 1
	SI Slovenia 2
	SK Slovakia 2
	TR Turkey 3
	TW Taiwan 0
	UA Ukraine 0
	US "United States" 0
	ZA "South Africa" 0
	
end

	label value eu eu
	label define eu 0 "no Member" 1 "OMS-15" 2 "NMS-10" 3 "CC-3"
	label variable eu "EU-Membership"
	label variable ctrname "Country"
	
	compress
	sort iso3166_2
	tempfile names
	save `names'
	restore
	merge iso3166_2 using `names', nokeep
	assert _merge == 3
	drop _merge

	sort iso3166_2

	order eu country ctrname iso3166_2 iso3166_3  ///
	  id intnr time am pm weight ///
	  eueco nat* own* comp*  proconstitution right ecofut euengine ///
	  men age loc edu empocc mar
	sort iso3166_2
	compress



	save data01, replace
	
	exit
	

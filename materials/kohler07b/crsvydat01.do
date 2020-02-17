* All Datasets + Aggregates from EQLS + SVY-Descriptions
* kohler@wz-berlin.de	
* Based on cralldat by luniak@wz-berlin.de

version 9

	clear
	set memory 90m
	set more off
	
	// EM
	// --
	
	use id country v5 v6 v7 v8 v18 v18_d v11* v24eq weight1 using $em/em, clear

	// Weights
	ren weight1 weight
	
	// Weich/Hart
	gen weich:yesno = v5 == 2 & v18 == 2 if !missing(v5,v18) 
	replace weich = v5 == 2 & v18_d == 2 if country == 2 & !missing(v5,v18_d)
	gen hart:yesno = .

	// Frauen
	gen women:yesno = v7 == 0 if v7 < .

	// City
	gen ort1 = v11_a
	replace ort1 = 0 if v11_a >= 1 & v11_a <= 3
	replace ort1 = 1 if v11_a >= 4 & v11_a <= 7

	gen ort2 = v11_ch
	replace ort2 = 0 if v11_ch >= 4 & v11_ch <= 8
	replace ort2 = 1 if v11_ch >= 0 & v11_ch <= 3

	gen ort3 = v11_d1
	replace ort3 = 0 if v11_d1 >= 7 & v11_d1 <= 9
	replace ort3 = 1 if v11_d1 >= 0 & v11_d1 <= 6

	gen ort5 = v11_e
	replace ort5 = 0 if v11_e >= 1 & v11_e <= 2
	replace ort5 = 1 if v11_e >= 3 & v11_e <= 7

	gen ort6 = v11_h
	replace ort6 = 0 if v11_h >= 5 & v11_h <= 9
	replace ort6 = 1 if v11_h >= 1 & v11_h <= 4

	gen ort7 = v11_rok
	replace ort7 = 0 if v11_rok == 3
	replace ort7 = 1 if v11_rok >= 1 & v11_rok <= 2

	gen ort8 = v11_s
	replace ort8 = 0 if v11_s >= 10 & v11_s <= 30
	replace ort8 = 1 if v11_s >= 40 & v11_s <= 60

	gen ort9 = v11_slo
	replace ort9 = 0 if v11_slo >= 5 & v11_slo <= 6
	replace ort9 = 1 if v11_slo >= 1 & v11_slo <= 4

	gen ort10 = v11_tr
	replace ort10 = 0 if v11_tr == 2
	replace ort10 = 1 if v11_tr == 1

	egen city = rfirst(ort1 - ort10)

	// HHIncome
	egen hinc = xtile(v24eq), p(25(25)75) by(country)

	// Age
	ren v8 age
	
	// Survey
	gen survey = "Euromodule"

	// Staaten nach ISO 3166
	keep id country weich hart women city hinc age survey weight 
	sort country
	preserve
	clear
	input country str2 iso3166_2 str3 iso3166_3
	1	SI	SVN
	2	DE	DEU
	3	HU	HUN
	4	ES	ESP
	5	CH	CHE
	6	SE	SWE	
	7	AT	AUT
	8	TR	TUR
	9	KR	KOR
end
	sort country
	tempfile iso
	save `iso', replace 
	restore
	merge country using `iso'
	assert _merge == 3
	drop _merge 

	// Save File
	tempfile em
	save `em'

	// EQLS
	// ----

	use s_respnr s_cntry hh1 hh2a hh2b hh3a_2 hh3b_2 hh3c_2 q32 q55 q65 wcountry ///
	  using $dublin/eqls_4, clear

	// Weights
	ren wcountry weight
	
	// Case ID
	ren s_respnr id
	
	// Weich/Hart
	gen weich:yesno = hh1 == 2 & hh3c_2 == 1 if !missing(hh1,hh3c_2) 
	gen hart:yesno = weich == 1 & hh2a ~= hh3a_2 if !missing(weich,hh2a,hh3a_2)

	// Frauen
	gen women:yesno = hh2a == 2 if !missing(hh2a)
	
	// City
	gen city:yesno = q55 >= 3 if !missing(q55)

	// HHIncome
	egen hinc = xtile(q65), p(25(25)75) by(s_cntry) 

	// Age
	ren hh2b age

	// Survey
	gen survey  = "EQLS 2003"

	// Staaten nach ISO 3166
	ren s_cntry country
	keep id country weich hart women city hinc survey age weight
	sort country
	preserve
	clear
	input country str2 iso3166_2 str3 iso3166_3
	1	AT				AUT
	2	BE				BEL
	3	BG				BGR
	4	CY				CYP
	5	CZ				CZE
	6	DK				DNK
	7	EE				EST
	8	FI				FIN
	9	FR				FRA
	10	DE				DEU
	11	GB				GBR
	12 	GR				GRC
	13	HU				HUN
	14	IE				IRL
	15	IT				ITA
	16	LV				LVA
	17	LT				LTU
	18	LU				LUX
	19 	MT				MLT
	20	NL				NLD
	21	PL				POL
	22	RO				ROU
	23	SK				SVK
	24	SI				SVN
	25	ES				ESP
	26	SE				SWE
	27	TR				TUR
	28	PT 				PRT
end
	sort country
	save `iso', replace 
	restore
	merge country using `iso'
	assert _merge == 3
	drop _merge

	// Save File
	tempfile eqls
	save `eqls'


	// ESS
	// ----

	use idno cntry domicil hinctnt gndr gndr2 hhmmb lvgptn lvgoptn lvghw dweight ///
	 yrbrn inwyr  using $ess/ess2002, clear

	// Weights
	ren dweight weight
	
	// Case ID
	ren idno id
	
	// Weich/Hart
	gen weich:yesno = hhmmb == 2 & (lvgptn == 1 | lvgoptn == 1 | lvghw == 1) ///
	  if !missing(hhmmb)
	replace weich = . if  lvgptn >= . & lvgoptn >= .  & lvghw >= .
	gen hart:yesno = weich==1 & gndr  ~= gndr2 if !missing(weich,gndr,gndr2)

	// Frauen
	gen women:yesno = gndr ==2 if !missing(gndr)

	// City
	gen city:yesno = domicil == 1 | domicil == 2 | domicil == 3 if !missing(domicil)
	
	// HHIncome
	egen hinc = xtile(hinctnt), p(25(25)75) by(cntry) 

	// Age
	gen age = inwyr - yrbrn

	// Survey
	gen survey = "ESS 2002"

	// Staaten nach ISO 3166
	gen iso3166_2 = cntry 
	keep id iso3166_2 weich hart women city hinc survey age weight
	sort iso3166_2
	preserve
	clear

	input str2 iso3166_2 str3 iso3166_3
	AT	AUT
	BE	BEL
	CH	CHE
	CZ	CZE
	DE	DEU
	DK	DNK
	ES	ESP
	FI	FIN
	FR	FRA
	GB	GBR
	GR	GRC
	HU	HUN
	IE	IRL	
	IL	ISR	
	IT	ITA
	LU	LUX
	NL	NLD
	NO	NOR
	PL	POL	
	PT	PRT	
	SE	SWE	
	SI 	SVN
end
	sort iso3166_2
	save `iso', replace 
	restore
	merge iso3166_2 using `iso'
	assert _merge == 3
	drop _merge

	// Save File
	tempfile ess
	save `ess'

	// EVS
	// ---

	use id_cocas v299 v291 v292 v294 v320 v322 country weight  o50 using $evs/evs1999, clear

	// Case-ID
	ren id_cocas id
	
	// Weich/Hart
	gen weich:yesno = v299 == 2 & v294 == 1 if !missing(v299,v294)
	gen hart:yesno = .

	// Frauen
	gen women:yesno = v291 == 2 if !missing(v291)

	// City
	gen city:yesno = v322 >=5 & v322 <= 8 if !missing(v322)
	replace city = 0 if v322 >=1 & v322 <= 4
	replace city = 1 if v322 >=5 & v322 <= 8

	// HHIncome
	egen hinc = xtile(v320), p(25(25)75) by(country) 

	// Age
	gen yinterv = cond(o50 <= 3110,1999,2000)
	gen age = yinterv - v292
	
	// Survey
	gen survey = "EVS 1999"

	// Staaten nach ISO 3166
	keep id country weich hart women city hinc survey age weight
	sort country
	preserve
	clear
	input country str19 iso3166_2 str20 iso3166_3
	1	FR				FRA
	2	GB				GBR
	3	DE				DEU
	5	AT				AUT
	6	IT				ITA
	7	ES				ESP
	8	PT 				PRT
	9	NL				NLD
	10	BE				BEL
	11	DK				DNK
	13	SE				SWE
	14	FI				FIN
	15	IS				ISL
	16	GB	            GBR
	17	IE				IRL
	18	EE				EST
	19	LV				LVA
	20	LT				LTU
	21	PL				POL
	22	CZ				CZE
	23	SK				SVK
	24	HU				HUN
	25	RO				ROU
	26	BG				BGR
	27	HR				HRV
	28 	GR				GRC
	29	RU				RUS
	32	MT				MLT
	33	LU				LUX
	34	SI				SVN
	35	UA				UKR
	36	BY				BLR
	44	TR				TUR
end
	sort country
	save `iso', replace
	restore
	merge country using `iso'
	assert _merge == 3
	drop _merge

	// Save File
	tempfile evs
	save `evs'


	// Eurobarometer 62.1 (2004)
	// -------------------------

	use resp_id country w1 d7 d10 d11 d40a p6?? using ~/data/eb/za4230

	
	// Weights
	ren w1 weight
	
	// Case ID
	ren resp_id id
	
	// Weich/Hart
	gen weich:yesno = d40a == 2 & inrange(d7,1,3) if !missing(d40a,d7)
	gen hart:yesno = .

	// Frauen
	gen women:yesno = d10 == 2 if !missing(d10)
	
	// City
	gen city:yesno = inlist(p6be,1,2) if !missing(p6be)
	replace city = inlist(p6at,3,4) if !missing(p6at)
	replace city = inlist(p6cy,1) if !missing(p6cy)
	replace city = inlist(p6cz,4,5) if !missing(p6cz)
	replace city = inlist(p6dk,1,2,3,4,5,6) if !missing(p6dk)
	replace city = inlist(p6ee,1,2) if !missing(p6ee)
	replace city = inlist(p6de,5,6,7) if !missing(p6de)
	replace city = inlist(p6el,1,2,3) if !missing(p6el)
	replace city = inlist(p6es,4,5,6,7) if !missing(p6es)
	replace city = inlist(p6fi,1,2) if !missing(p6fi)
	replace city = inlist(p6uk,2,3,5) if !missing(p6uk)
	replace city = inlist(p6hu,1,2) if !missing(p6hu)
	replace city = inlist(p6ie,1,2) if !missing(p6ie)
	replace city = inlist(p6it,3,4,5) if !missing(p6it)
	replace city = inlist(p6lt,2,3) if !missing(p6lt)
	replace city = inlist(p6lu,4,5,6) if !missing(p6lu)
	replace city = inlist(p6lv,1,2) if !missing(p6lv)
	replace city = inlist(p6mt,3) if !missing(p6mt)
	replace city = inlist(p6nl,5,6,7,8) if !missing(p6nl)
	replace city = inlist(p6pl,3,4,5) if !missing(p6pl)
	replace city = inlist(p6pt,4,5) if !missing(p6pt)
	replace city = inlist(p6se,1) if !missing(p6se)
	replace city = inlist(p6si,1,2) if !missing(p6si)
	replace city = inlist(p6sk,4,5) if !missing(p6sk)

	// HHIncome
	gen hinc = .

	// Age
	ren d11 age
	
	// Survey
	gen survey = "EB 62.1"
	
	// Staaten nach ISO 3166
	keep id country weich hart women city hinc survey age weight
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
	sort country
	save `iso', replace
	restore
	merge country using `iso'
	assert _merge == 3
	drop _merge
	
	// Save File
	tempfile eb
	save `eb'


	// ISSP
	// -----

	use v2 v3 v200 v201 v202 v250 v251 v251 v325-v357 v361 using ~/data/issp02/issp02, clear

	// Weights
	ren v361 weight

	// Case ID
	ren v2 id

	// Weich/Hart
	gen weich:yesno = v251 == 2 & v202 == 1 if !missing(v251,v202)
	gen hart:yesno = .

	// Frauen
	gen women:yesno = v200 == 2 if !missing(v200)

	// City
	gen city:yesno = inlist(v325,1,2,3) if !missing(v325)
	replace city = inlist(v326,1,2,3) if !missing(v326)
	replace city = inlist(v327,1,2,3) if !missing(v327)
	replace city = inlist(v330,1,2,3) if !missing(v330)
	replace city = inlist(v331,1,2,3) if !missing(v331)
	replace city = inlist(v332,1,2,3,4) if !missing(v332)
	replace city = inlist(v333,1,2,3) if !missing(v333)
	replace city = inlist(v334,1,2,3,4,5) if !missing(v334)
	replace city = inlist(v335,1,2,3,4,5) if !missing(v335)
	replace city = inlist(v336,1,2,3,4,5) if !missing(v336)
	replace city = inlist(v337,1,2,3) if !missing(v337)
	replace city = inlist(v338,1,2,3,4) if !missing(v338)
	replace city = inlist(v339,1,2,3) if !missing(v339)
	replace city = inlist(v341,1,2,3,4) if !missing(v341)
	replace city = inlist(v342,1,2,3,4) if !missing(v342)
	replace city = inlist(v343,1,2,3,4) if !missing(v343)
	replace city = inlist(v344,1,2) if !missing(v344)
	replace city = inlist(v345,1,2,3,4) if !missing(v345)
	replace city = inlist(v346,1,2,3,4) if !missing(v346)
	replace city = inlist(v347,1,2) if !missing(v347)
	replace city = inlist(v348,1,2,3,4,5) if !missing(v348)
	replace city = inlist(v351,1,2,3,4,5,6) if !missing(v351)
	replace city = inlist(v352,1,2,3) if !missing(v352)
	replace city = inlist(v353,1,2,3,4) if !missing(v353)
	replace city = inlist(v354,1,2,3) if !missing(v354)
	replace city = inlist(v355,1,2) if !missing(v355)
	replace city = inlist(v356,1,2) if !missing(v356)
	replace city = inlist(v357,1,2,3,4,5) if !missing(v357)
	

	// HHIncome
	egen hinc = xtile(v250), p(25(25)75) by(v3) 

	// Age
	ren v201 age

	// Survey
	gen survey = "ISSP 2002"

	// Staaten nach ISO 3166
	ren v3 country
	sort country
	keep id country weich hart women city hinc survey age weight
	preserve
	clear
	input country str19 iso3166_2 str20 iso3166_3
	1	AU				AUS
	2	DE			    DEU
	3	DE			    DEU
	4	GB				GBR
	5	GB	            GBR
	6	US				USA
	7	AT				AUT
	8	HU				HUN
	9	IT				ITA
	10	IE				IRL
	11	NL				NLD
	12	NO				NOR
	13	SE				SWE
	14	CZ				CZE
	15	SI				SVN
	16	PL				POL
	17	BG				BGR
	18	RU				RUS
	19	NZ				NZL
	20	CA				CAN
	21	PH				PHL
	22	IL				ISR
	24	JP				JPN
	25	ES				ESP
	26	LV				LVA
	27	SK				SVK
	28	FR				FRA
	29	CY				CYP
	30	PT 				PRT
	31	CL				CHL
	32	DK				DNK
	33	CH				CHE
    34  BE              BEL   // I use Flandria as Belgium
    35  BR              BRA
    37  FI              FIN
    38  MX              MEX
    39  TW              TWN
end
	sort country
	save `iso', replace 
	restore
	merge country, using `iso', nokeep
	assert _merge == 3
	drop _merge
	tempfile issp
	save `issp'

	// Zusammenführung aller Datensätze
	// --------------------------------

	use `ess', clear
	append using `evs'
	append using `eqls'
	append using `eb'
	append using `em'
	append using `issp'
	
	drop country

	label variable survey "Survey"
	label variable id "Orig. Case ID"
	label variable iso3166_2 "ISO 3166 2-Digit Country Code"
	label variable iso3166_3 "ISO 3166 3-Digit Country Code"
	label variable weich "Couple in 2-Pers HH"
	label variable hart "Couple with different Sexes in 2-Pers HH "
	label variable women "Women y/n"
	label variable city "Living in a City/Town y/n"
	label variable hinc "Quartiles of Houshold-Income"

	label define yesno 0 "no" 1 "yes"

	preserve
	
	// Aggregat-Level-Data
	// -------------------

	// Sampdata (produced with EpiData by luniak@wz-berlin.de)
	use sampdata, clear
	append using eb62sampdata
	append using isspsampdata
	replace iso3166_2 = iso3166 if iso3166_2  == ""
	assert iso3166_2 ~= ""
	replace iso3166_2 = "GB" if iso3166_2 == "NI"
	replace iso3166_2 = "GB" if iso3166_2 == "GB (Northern Irelan"
	drop iso3166
	replace survey = "ISSP 2002" if survey == ""  & source == "ISSP"
	replace survey = "EQLS 2003" if survey == "eqls"
	replace survey = "ESS 2002" if survey == "ess"
	replace survey = "EVS 1999" if survey == "evs"
	replace survey = "ISSP 1998" if survey == "issp"
	replace survey = "EB 62.1" if source == "EB62"
	drop source
	tempfile sampdata
	save `sampdata'


	// Euromodule
	clear
	input str2 iso3166_2 str18 survey str30 inst pretest svymeth strata disprob hhsamp str30 selhh str30 selper resrate resratei subst intpay back 
	SI "Euromodule" "Public Opinion and Mass Coumm. Research Centre" -3 3 0 0 0 "-2" "population register" -3 -2 -3 -3 -1
	DE "Euromodule" "Infratest" -3 3 0 0 1 "random route" "kish grid"  64 1 -3 -3 -1
	HU "Euromodule" "TARTU" -3 3 0 0 1 "prob. sample" "kish grid" 63 0 -3 -3 -1 
	ES "Euromodule" "CIS" -3 3 0 0 1 "random route" "quota"  100 0 -3 -3 -1
	CH "Euromodule" "IPSO" -3 4 1 1 1 "tel.-list" "-1"  42 1 -3 -3 -1
	SE "Euromodule" "Statistics Sweden" -3 3 0 0 0 "-2" "population register" 76 1 -3 -3 -1
	AT "Euromodule" "WISDOM" -3 4 0 0 1 "tel.-list" "-1"  -3 -2 -3 -3 -1
	TR "Euromodule" "Middle East Technical University" -3 3 1 1 1 "random route" "kish grid"  90 0 1 -3 -1
	KR "Euromodule" "Garam Research Inc" -3 3 0 0 1 "-3" "-3"  55 1 -3 -3 -1
end
	append using `sampdata'
	sort survey iso3166_2
	save `sampdata', replace

	// Merge
	restore
	sort survey iso3166_2
	merge survey iso3166_2 using `sampdata', nokeep
	assert _merge == 3
	drop _merge


	// End Matter
	// ----------

	label variable weight

	// Nicer label-baskets
	foreach var of varlist pretest strata disprop hhsamp  resratei - back {
		label value `var' yesno
	}

	label value svymeth svymeth
	label define svymeth -3 "unspecified" -2 "na"  -1 "refused"  ///
	  1 "PAPI" 2 "CAPI" 3 "face-to-face" 4 "CATI" ///
	  5 "postal" 6 "face-to-face + tel" 7 "self-completion (via-interviewer)" ///
	  8 "postal + tel"

	// Variable: quota
	replace quota = index(selper, "quota") >  0 if quota >= . 
	label variable quota "Quotaverfahren"

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
	label define eu 0 "no Member" 1 "EU-15" 2 "AC-10" 3 "CC"
	
	compress
	sort iso3166_2
	tempfile names
	save `names'
	restore
	merge iso3166_2 using `names', nokeep
	drop _merge

	// Merge GDP
	sort ctrname
	merge ctrname using ~/data/agg/gdp_world_2002, nokeep
	drop _merge
	order survey id weight iso3166_2 iso3166_3 ctrname eu weich hart women city hinc

	compress
	save svydat01, replace
	
	exit
	
	
	Notes:

	(1)  I have used Flandria as Belgium for ISSP 2002

	


	  

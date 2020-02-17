* All Datasets + Aggregates from EQLS + SVY-Descriptions
* kohler@wz-berlin.de	
* Based on cralldat by luniak@wz-berlin.de

version 9

	clear
	set memory 90m
	set more off
	
	// EVS
	// ---

	use id_cocas country weost_de wogew_de using $evs/evs1999, clear

	// Case-ID
	ren id_cocas id
	
	// Survey
	gen survey = "EVS 1999"

	// Regions with disproportionabilty
	gen ost = weost_de==2 if country == 3
	gen wost = 15120000/999 if ost == 1   // Popsize 2000, Source: Datenreport
	replace wost = 67140000/1037 if ost==0

	gen nirl = country== 16 if inlist(country,2,16)
	gen wnirl =  1685000/1000 if nirl==1  // Popsize April 2001, Source: Wikipedia
	replace wnirl = (58789194-1685000)/1000 if nirl == 0 

	// Staaten nach ISO 3166
	sort country
	preserve
	clear
	input country str19 iso3166_2 
	1	FR	
	2	GB	
	3	DE	
	5	AT	
	6	IT	
	7	ES	
	8	PT 	
	9	NL	
	10	BE	
	11	DK	
	13	SE	
	14	FI	
	15	IS	
	16	GB	
	17	IE	
	18	EE	
	19	LV	
	20	LT	
	21	PL	
	22	CZ	
	23	SK	
	24	HU	
	25	RO	
	26	BG	
	27	HR	
	28 	GR	
	29	RU	
	32	MT	
	33	LU	
	34	SI	
	35	UA	
	36	BY	
	44	TR	
end
	sort country
	tempfile iso
	save `iso', replace
	restore
	merge country using `iso'
	assert _merge == 3
	drop _merge
	
	// Save File
	keep survey iso3166_2 id ost wost nirl wnirl
	sort survey iso3166_2 id
	tempfile evs
	save `evs'

	// Eurobarometer 62.1 (2004)
	// -------------------------

	use resp_id country using ~/data/eb/za4230

	// Case ID
	ren resp_id id
	
	// Survey
	gen survey = "EB 62.1"

	// Regions with disproportionabilty
	gen ost = country == 4 if inlist(country,3,4)
	gen wost = 16821000/516 if ost == 1
	replace wost = 65680000/1045 if ost==0

	gen nirl = country== 17 if inlist(country,16,17)
	gen wnirl =  1685000/305 if nirl==1  // Popsize April 2001, Source: Wikipedia
	replace wnirl = (58789194-1685000)/1017 if nirl == 0 


	// Staaten nach ISO 3166
	sort country
	preserve
	clear
	input country str2 iso3166_2 
           1 BE 
           2 DK 
           3 DE 
           4 DE 
           5 GR 
           6 ES 
           7 FI 
           8 FR 
           9 IE 
          10 IT 
          11 LU  
          12 NL   
          13 AT 
          14 PT 
          15 SE 
          16 GB 
          17 GB 
          18 CY 
          19 CZ 
          20 EE 
          21 HU 
          22 LV 
          23 LT 
          24 MT 
          25 PL 
          26 SK 
          27 SI 
end
	sort country
	save `iso', replace
	restore
	merge country using `iso'
	assert _merge == 3
	drop _merge

	// Save File
	keep survey iso3166_2 id ost wost nirl wnirl
	sort survey iso3166_2 id
	tempfile eb
	save `eb'

	// ISSP
	// -----

	use v2 v3  using ~/data/issp02/issp02

	// Case ID
	ren v2 id

	// Survey
	gen survey = "ISSP 2002"

	// Regions with disproportionabilty
	gen ost = v3 == 3 if inlist(v3,2,3)
	gen wost = 17009000/431 if ost == 1
	replace wost = 65527000/936 if ost==0

	gen nirl = v3== 5 if inlist(v3,4,5)
	gen wnirl =  1685000/936 if nirl==1  // Popsize April 2001, Source: Wikipedia
	replace wnirl = (58789194-1685000)/1252 if nirl == 0 

	// Staaten nach ISO 3166
	ren v3 country
	sort country
	preserve
	clear
	input country str19 iso3166_2 
	1	AU	
	2	DE	
	3	DE	
	4	GB	
	5	GB	
	6	US	
	7	AT	
	8	HU	
	9	IT	
	10	IE	
	11	NL	
	12	NO	
	13	SE	
	14	CZ	
	15	SI	
	16	PL	
	17	BG	
	18	RU	
	19	NZ	
	20	CA	
	21	PH	
	22	IL	
	24	JP	
	25	ES	
	26	LV	
	27	SK	
	28	FR	
	29	CY	
	30	PT 	
	31	CL	
	32	DK	
	33	CH	
    34  BE     // I use Flandria as Belgium
    35  BR  
    37  FI  
    38  MX  
    39  TW  
end
	sort country
	save `iso', replace 
	restore
	merge country, using `iso', nokeep
	assert _merge == 3
	drop _merge
	
	keep survey id iso3166_2 ost wost nirl wnirl
	sort survey iso3166_2 id
	tempfile issp
	save `issp'

	// Merge to Main Data
	// ------------------

	use `evs'
	append using `eb'
	append using `issp'
	sort survey iso3166_2 id
	tempfile allfiles
	save `allfiles'

	
	use svydat03, clear
	sort survey iso3166_2 id
	merge survey iso3166_2 id  using `allfiles', nokeep
	assert _merge == 3 if survey=="EB 62.1" | survey=="ISSP 2002" | survey=="EVS 1999"
	drop _merge

	gen dweight = 1
	replace dweight = wost if wost < .
	replace dweight = wnirl if wnirl < .
	label var dweight "Design Weight"

	label var ost "East Germany"
	label val ost yesno
	label var wost "Design weights Germany"

	label var nirl "Northern Ireland "
	label val nirl yesno
	label var wnirl "Design weights United Kingdom"
	
	// Correction of Sampling Method for ESS 2002, Austria
	replace sample = 3 if survey == "ESS 2002" & iso3166_2 == "AT"


	// Correction of Sampling Method for ESS, Portugal
	replace sample = 4 if survey == "ESS 2002" & iso3166_2 == "PT"
	replace sample = 4 if survey == "ESS 2004" & iso3166_2 == "PT"

	compress
	save svydat04, replace


	

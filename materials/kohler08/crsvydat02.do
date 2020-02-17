* ESS and EQLS, Long Format, Strict Definition
* kohler@wz-berlin.de	

version 9

	clear
	set memory 90m
	set more off

	tempfile iso
	

	// EQLS
	// ----

	use s_respnr s_cntry hh* q32 q55 q65 wcountry ///
	  using $dublin/eqls_4, clear

	// Weights
	ren wcountry weight
	
	// Case ID
	ren s_respnr id
	
	// Weich/Hart
	gen hart:yesno = hh2a ~= hh3a_2 if !missing(hh2a,hh3a_2) & hh1 == 2 & hh3b_2 >= 18
	keep if hart == 1

	// Frauen
	gen women1:yesno = hh2a == 2 if !missing(hh2a)
	gen women2:yesno = hh3a_2 == 2 if !missing(hh3a_2)

	// Age
	gen age1 = hh2b if !missing(hh2b)
	gen age2 = hh3b_2 if !missing(hh3b_2)

	// Economic Status
	gen emp1:yesno = hh2d==1 
	gen emp2:yesno = hh3d_2==1  
	
	// City
	gen city:yesno = q55 >= 3 if !missing(q55)

	// HHIncome
	egen hinc = xtile(q65), p(25(25)75) by(s_cntry) 

	// Survey
	gen survey  = "EQLS 2003"

	// Staaten nach ISO 3166
	ren s_cntry country
	keep id country women* age* emp* city hinc survey weight
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

	reshape long women age emp, i(id) j(person)

	gen selected = person==1
	gen womenemp women*emp
	gen womenemp = women*emp
	gen womencity = women*city
	gen womenage = women*age
	gen womenhinc = women*hinc
	

	exit
	

logit selected women
logit selected women emp
logit selected women emp age
logit selected women emp 
logit selected women emp hinc
logit selected women emp hinc city
logit selected women emp hinc 
logit selected women 
logit selected women emp
logit selected women emp age
logit selected women emp age hinc
logit selected women emp age hinc women*

xtmixed logit selected women emp age hinc || iso3166_2
xtlogit selected women emp age hinc, i(iso3166_2)
xtlogit selected women emp age hinc, i(country)
xtlogit selected women emp age hinc womene-womenh, i(country)
         sum age
replace age = age - r(mean)
replace womenage = women*age
tab hinc
tab hinc, gen(hinc)
drom womenhinc
drop womenhinc
foreach var of varlist hinc2-hinc4 {
gen women`var' = women * `var'
}
xtlogit selected women emp age hinc? womenemp womencit womenage womenhinc?, i(country)
xtlogit selected women emp age hinc2-hinc4 womenemp womencit womenage womenhinc?, i(country)
xtlogit selected women city emp age hinc2-hinc4 womenemp womencit womenage womenhinc?, i(country)
logit selected women city emp age hinc2-hinc4 womenemp womencit womenage womenhinc? if iso3166_2=="TR"


	
	
	// Save File
	tempfile eqls
	save `eqls'


	// ESS
	// ----

	use idno cntry domicil hinctnt gndr gndr2 hhmmb lvgptn lvgoptn lvghw dweight ///
	  using $ess/ess2002, clear

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

	// Survey
	gen survey = "ESS 2002"

	// Staaten nach ISO 3166
	gen iso3166_2 = cntry 
	keep id iso3166_2 weich hart women city hinc survey weight
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

	// Zusammenführung aller Datensätze
	// --------------------------------

	use `ess', clear
	append using `eqls'



	exit

	








	
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

	


	  

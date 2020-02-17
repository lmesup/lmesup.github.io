* Validation of Electoral Participation
* Author: kohler@wzb.eu

version 9.2
set more off
set scheme s1mono

	// Test 1: Compare CSES with official data on turnout in constituency
	// ------------------------------------------------------------------
	
	use ///
	  iso3166 weight voter constit constit_turnout dataset el1date ///
	  using cses, clear
	tostring constit, replace
	collapse (mean) voter constit_turnout (count) n=voter [aw=weight], by(iso3166 dataset constit)

	replace voter = voter * 100
	by iso3166 dataset, sort: gen elnumber = _n==1
	by iso3166, sort: replace elnumber = sum(elnumber)
	
	graph twoway                              ///
	  || line constit_turnout constit_turnout, lcolor(black) sort ///
	  || sc voter constit_turnout if elnumber == 1 ///
	     , ms(oh) mcolor(black)           ///
	  || sc voter constit_turnout if elnumber == 2 ///
	     , ms(sh) mcolor(black)           ///
	  || lowess voter constit_turnout, lcolor(white) lwidth(*2)   ///
	  || lowess voter constit_turnout, lcolor(black)              ///
	  || if n >= 10 & !inlist(iso3166,"US","CZ") ///
	  , by(iso3166, rescale note("") )  ///
	  xtitle(Turnout according official sources)  ///
	  ytitle(Turnout according to survey) ///
	  legend(order(2 "CSES-1" 3 "CSES-2"))
	graph export anvoter_valid_constit.eps, replace
	by iso3166, sort: corr voter constit_turnout

	// Test 2: Compare turnout among different Surveyy and Official (CSES ISSP, CSES, ESS, EQLS)
	// -----------------------------------------------------------------------------------

	clear
	set memory 200m
	
	use persid dataset iso3166 weight intdate voter using cses, clear
	append using ess02, keep(persid dataset iso3166 weight intdate voter)
	append using ess04, keep(persid dataset iso3166 weight intdate voter)
	append using issp02, keep(persid dataset iso3166 weight intdate voter)
	append using issp04, keep(persid dataset iso3166 weight intdate voter)
	append using eqls03, keep(persid dataset iso3166 weight intdate voter)
	compress

	// Depict the date of the "last" election
	// (this is fairly complicated)
	preserve
	by iso3166, sort: keep if _n==1
	keep iso3166
	merge iso3166 using ~/data/agg/electiondates, nokeep keep(eldate)
	assert _merge == 3
	drop _merge
	by iso3166 (eldate), sort: gen elnr = _n
	reshape wide eldate, i(iso3166) j(elnr)
	compress
	sort iso3166
	tempfile temp
	save `temp'

	restore
	sort iso3166
	merge iso3166 using `temp'
	assert _merge==3
	drop _merge

	gen index = _n
	reshape long eldate, i(index) j(elnr)
	drop if eldate == .
	
	gen diff = intdate - eldate
	drop if diff < 0  // I loose 69 observations here
	by index (diff), sort: keep if _n==1 // keeps the observation with the smallest difference
	isid index

	// Calculate Turnout-rate by Country, Election and Dataset
	collapse (mean) voter intdate [aw=weight], by(iso3166 eldate dataset)
	sort iso3166 eldate
	tempfile datasets
	save `datasets'

	// Merge official results
	// (Data from http://www.idea.int/index.cfm)
	clear
	input str2 iso3166 str9 eldatestring turnout
	AT 24nov2002 84.3
	AT 25apr2004 71.6
	AU 02mar1996 95.8
	AU 10nov2001 94.9
	AU 09oct2004 94.3
	BE 13jun1999 90.6
	BE 18may2003 96.3
	BG 17jun2001 66.6
	BG 18nov2001 54.9 
	BG 25jun2005 55.8
	BR 27oct2002 79.5
	CA 02jun1997 67.0
	CA 27nov2000 61.2
	CA 28jun2004 60.9
	CH 24oct1999 43.2
	CH 19oct2003 45.4
	CL 16dec2001 86.6
	CY 27may2001 91.8
	CY 16feb2003 90.5
	CZ 31may1996 76.3 
	CZ 01jun1996 76.3 
	CZ 19jun1998 74.0 
	CZ 12nov1998 74.0 
	CZ 19nov1998 74.0 
	CZ 12nov2000 . 
	CZ 19nov2000 . 
	CZ 14jun2002 57.9 
	CZ 25oct2002 57.9 
	CZ 01nov2002 57.9 
	CZ 20oct2006 64.5
	DE 28sep1998 82.2
	DE 22sep2002 79.1
	DK 11mar1998 85.9
	DK 20nov2001 87.1
	DK 08feb2005 84.5
	EE 02mar2003 58.2 
	ES 11mar1996 78.1
	ES 12mar2000 68.7
	ES 14mar2004 75.7
	FI 06feb2000 76.8
	FI 16mar2003 66.7
	FR 21apr2002 79.7 
	FR 05may2002 79.7 
	FR 09jun2002 60.3 
	FR 16jun2002 60.3 
	GB 01may1997 71.5
	GB 07jun2001 59.4
	GB 05may2005 61.4
	GR 09apr2000 75.0
	GR 07mar2004 76.6
	HK 24may1998 .
	HK 10sep2000 .
	HK 12sep2004 . 
	HU 10may1998 56.7
	HU 07apr2002 73.5 
	HU 21apr2002 73.5 
	IE 06jun1998 66.1 
	IE 17may2002 62.6 
	IE 16jul2002 62.6 
	IL 29may1996 79.3 
	IL 17may1999 78.7 
	IL 06feb2001 62.3
	IL 28jan2003 67.8 
	IL 28mar2006 63.5
	IS 08may1999 84.1
	IS 10may2003 87.7
	IS 26jun2004 62.9
	IT 13may2001 81.4
	JP 20oct1996 59.0
	JP 25jun2000 60.6 
	JP 09nov2003 59.8 
	KR 13apr2000 57.2
	KR 15apr2004 60.0
	LT 05jan2003 52.7
	LU 13jun1999 86.5
	LU 13jun2004 91.7
	LV 05oct2002 71.2
	MT 05sep1998 95.4
	MX 06jul1997 57.7
	MX 02jul2000 64.0 
	MX 06jul2003 41.7
	NL 06may1998 73.2
	NL 15may2002 79.1
	NL 22jan2003 80.0
	NL 22nov2006 . 
	NO 15sep1997 78.0
	NO 10sep2001 75.0
	NZ 12oct1996 88.3
	NZ 27nov1999 84.8
	NZ 27jul2002 77.0
	NZ 17sep2005 80.3
	PH 14may2001 81.1
	PH 10may2004 84.1 
	PL 21sep1997 47.9
	PL 23sep2001 46.2
	PT 10oct1999 61.0
	PT 17mar2002 62.8
	PT 20feb2005 64.3
	RO 10dec2000 65.3 
	RU 26mar2000 68.6
	RU 14mar2004 64.4
	SE 20sep1998 81.4
	SE 15sep2002 80.1
	SI 10nov1996 73.7
	SI 15oct2000 70.4
	SI 01dec2002 65.2
	SI 03oct2004 60.6
	SK 15may1999 73.8 
	SK 29may1999 73.8 
	SK 20sep2002 70.1
	SK 17apr2004 43.5
	SK 17jun2006 54.7
	TR 03nov2002 76.9
	TW 23mar1996 76.2 
	TW 01dec2001 .
	TW 20mar2004 80.3
	UA 26dec2004 77.3
	US 05nov1996 66.0 
	US 07nov2000 67.4
	US 05nov2002 39.5 // http://elections.gmu.edu/Voter_Turnout_2002.htm
	US 02nov2004 61.0 // http://elections.gmu.edu/Voter_Turnout_2004.htm
	UY 27jun2004 88.3 
	VE 30jul2000 56.6 
	ZA 02jun1999 89.3
end

	gen eldate = daily(eldatestring,"dmy")
	drop eldatestring
		sort iso3166 eldate
		tempfile official
		save `official'

	use `datasets'

	merge iso3166 eldate using `official'

	replace voter = voter*100
	replace voter = . if voter==0
	replace voter = . if voter==100
	graph tw /// ///
	  || scatter voter turnout if dataset == "ESS 2002", ms(O) mlcolor(black) mfcolor(white) ///
	  || scatter voter turnout if dataset == "ESS 2004", ms(S) mlcolor(black) mfcolor(white) ///
	  || scatter voter turnout if dataset == "ISSP 2002", ms(O) mlcolor(black) mfcolor(gs8) ///
	  || scatter voter turnout if dataset == "ISSP 2004", ms(S) mlcolor(black) mfcolor(gs8) ///
	  || scatter voter turnout if dataset == "CSES-MODULE-1", ms(O) mlcolor(black) mfcolor(black) ///
	  || scatter voter turnout if dataset == "CSES-MODULE-2", ms(S) mlcolor(black) mfcolor(black) ///
	  || scatter voter turnout if dataset == "EQLS 2003", ms(D) mlcolor(black) mfcolor(white) ///
	  || scatter voter turnout if iso3166 == "US", ms(i) mlab(iso3166) ///
	  || line turnout turnout, sort ///
	  || , legend(order(1 "ESS 2002" 2 "ESS 2004" 3 "ISSP 2002" 4 "ISSP 2004" 5 "CSES I" 6 "CSES II" 7 "EQLS 2003") ///
	  rows(2)) xtitle("Turnout according to IDEAS") ytitle("Turnout according to survey")
	graph export anvoter_valid_IDEAS.eps, replace preview(on)

	gen diff = abs(voter - turn)
	tab dataset, sum(diff) 
	tab iso3166, sum(diff)

	gen diffdate = intdate - eldate
	corr diff intdate

	exit
	

* Turnout by elections systems
* kohler@wzb.eu
* Based on cr_elec_res.do by lenarz@wzb.eu


clear
set more off
version 9.2
 
	// Input voter turnout of recent first order elections
	// ---------------------------------------------------

	// Copy from anturnout.do
	clear
	input str2 iso3166 str9 eldatestring turnout
	AT 24nov2002 84.3
	BE 18may2003 96.3
	BG 25jun2005 55.8      
	CY 16feb2003 90.5
	CZ 03jun2006 64.5
	DE 18sep2005 77.7
	DK 08feb2005 84.5
	EE 02mar2003 58.2 
	ES 14mar2004 75.7
	FI 29jan2006 74.0
	FR 05may2002 79.7  
	GB 05may2005 61.4
	GR 07mar2004 76.6
	HU 23apr2006 64.4
	IE 17may2002 62.6 
	IT 13may2001 83.6
	LT 27jun2004 52.5
	LU 13jun2004 91.7
	LV 05oct2002 71.2
	MT 12apr2003 95.7
	NL 22jan2003 80.0
	PL 23oct2005 51.0
	PT 20feb2005 64.3
	RO 12dec2004 54.8
	SE 15sep2002 80.1
	SI 03oct2004 60.6
	SK 17jun2006 54.7
	TR 03nov2002 76.9
	US 02nov2004 61.0 // http://elections.gmu.edu/Voter_Turnout_2004.htm
end
	
	gen eldate = daily(eldatestring,"dmy")
	drop eldatestring
	
	sort iso3166 eldate
	tempfile turnout
	save `turnout'

	// Input electionsystems I
	// -----------------------
	// (Data collected by lenarz@wzb.eu, and revisited by kohler@wzb.eu)
	
	insheet using electionsystems.tsv, clear
	
	//Label variables
	lab var iso3166 "Iso3166_2 country codes (2-digit)"
	lab var eldate "Date of election"
	lab var party1 "Result of the strongest candidate/party in %"
	lab var party2 "Result of the second-strongest candidate/party in %"
	lab var partyname1 "Name of the strongest candidate/party"
	lab var partyname2 "Name of the second-strongest candidate/party"
	lab var eltype "Type of election"
	lab var turnout "Voter turnout"
	lab var comp_reg "Is it compulsory to be on the voters _reg?"
	lab var cont_reg "How frequently is the voters _reg updated?"
	lab var cost_reg "Costs for an individual to _reg for voting"
	lab var fund "Do political parties receive direct/indirect public funding?"
	
	lab def comp_reg 0 "No" 1 "Yes" 2 "Other"
	lab val comp_reg comp_reg
	lab def cont_reg 0 "Periodically" 1 "Continously" 2 "Annually" 3 "Other"
	lab val cont_reg cont_reg
	lab def fund 0 "No" 1 "Direct" 2 "Indirect" 3 "Direct and indirect" 4 "Other"
	lab val fund fund
	lab def cost_reg 0 "No costs" 1 "Low costs" 2 "High costs"
	lab val cost_reg cost_reg
	
	// Clean up dates
	gen temp = daily(eldate,"dmy")
	replace temp = daily(eldate,"dmy",2008) if temp==.
	drop eldate
	ren temp eldate

	// Prepare for merging
	sort iso3166 eldate
	tempfile system1
	save `system1'
	
	// Input electionsystems I
	// -----------------------
	// (Edited copy from cr_elec_res.do by lenarz@wzb.eu)

	clear
	input str2 iso3166 str10 elecsys str10 compvote  
	AT  list_pr no
	BE  list_pr yes
	BG  list_pr no
	CY  list_pr yes
	CZ  list_pr no
	DE      mmp no
	DK  list_pr no
	EE  list_pr no
	ES  list_pr no
	FI  list_pr no
	FR      trs no
	GB     fptp no
	GR  list_pr yes
	HU      mmp no
	IE      stv no
	IT  list_pr yes
	LT parallel no
	LU  list_pr yes
	LV  list_pr no
	MT      stv no
	NL  list_pr no
	PL  list_pr no
	PT  list_pr no
	RO  list_pr no
	SE  list_pr no
	SI  list_pr no
	SK  list_pr no
	TR  list_pr yes
	US     fptp no
end

	lab var elecsys "Electoral system"
	lab var compvote "Compulsory voting"

	// Prepare for merging
	sort iso3166 
	tempfile system2
	save `system2'


	// Prepare manifesto-Data
	// ----------------------

	use ~/data/manifesto/manifesto,  clear

	replace countryn = "United Kingdom" if countryn == "Great Britain"
	drop if countryn == "Northern Ireland"
	drop if countryn== "German Democratic Republic"
    replace countryn = "Bosnia and Herzegovina" if countryn== "Bosnia-Herzegovina"
	replace countryn = "Macedonia, The former yugoslav republic of" if countryn == "Macedonia"
	replace countryn = "Moldova, REPUBLIC OF" if countryn == "Moldova"
	replace countryn = "RUSSIAN FEDERATION" if countryn == "Russia"
	egen iso3166 = iso3166(countryn)

	bysort country (edate): keep if edate==edate[_N]

	// Mehrparteiensystem
	bysort iso3166: gen multip = sum(absseat/totseats > .05)
	bysort iso3166: replace multip = multip[_N]
	label var multip "Anzahl Parteien mit über 5 % der Sitze im Parlament"

	bysort iso3166: keep if _n==_N
	keep iso3166 multip
	format multip %2.0f

	sort iso3166
	tempfile manifesto
	save `manifesto'
	
	
	// Merge Sources togehter
	// ----------------------

	use `turnout'
	merge iso3166 eldate using `system1', nokeep
	drop _merge
	sort iso3166
	merge iso3166 using `system2', nokeep
	drop _merge
	sort iso3166
	merge iso3166 using `manifesto', nokeep
	drop _merge

	// Contstruct and clean Macro indicators for table
	// -------------------------------------

	gen sdate = string(eldate, "%dm/d/Y")

	format turnout %2.0f

	gen weekend:yesno = inlist(dow(eldate),0,6)
	label define yesno 0 "No" 1 "Yes"

	gen branch = "Leg." if eltype == "legislative"
	replace branch = "Exec." if eltype == "presidential"

	lab def comp_reg 2 "-", modify
	
	replace compvote = proper(compvote)

	replace elecsys = upper(elecsys)
	replace elecsys = "List PR" if elecsys == "LIST_PR"
	replace elecsys = "Parallel" if elecsys == "PARALLEL"

	gen compet = party1-party2
	format compet %2.0f

	sort iso3166
	save electionsystems2, replace

exit

	Sources:
	
	(1) comp_reg, fund
	www.aceproject.org

	(2) turnout, branch, compvote, elecsys
	www.idea.int/vt

	(3) compet
	http://www.binghamton.edu/cdp/
	Election Results Archive of the Center on Democratic Performance

	(4) multip
	Manifesto

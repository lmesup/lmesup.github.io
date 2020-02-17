* Turnout by elections systems
* kohler@wzb.eu
* Based on cr_elec_res.do by lenarz@wzb.eu


clear
set more off
version 9.2
 
	// Input Election specific data
	// ----------------------------
	input str2 iso3166 str9 eldate turnout exec party1 party2 ///
	  str20 partyname1 str20 partyname2
	"AT" 03oct1999 80.4 0 33.1 26.9 "SPÖ" "ÖVP" 
	"AT" 24nov2002 84.3 0 42.3 36.9 "ÖVP" "SPÖ" 
	"AT" 01oct2006 78.5 0 35.4 34.3 "SPÖ" "ÖVP" 
	"BE" 21may1995 91.1 0 17.2 13.1 "CVP" "VLD" 
	"BE" 13jun1999 90.6 0 14.3 14.3 "VLD" "CVP" 
	"BE" 18may2003 96.3 0 15.4 14.9 "VLD" "SPA" 
	"BG" 19apr1997 58.9 0 52.0 22.0 "ODS" "DL" ""
	"BG" 17jun2001 66.6 0 42.7 18.2 "NDST" "ODS" 
	"BG" 25jun2005 55.8 0 31.0 19.9 "KzB" "NDST" 
	"CY" 13feb1993 93.3 1 50.3 49.7 "Clerides" "Vassilou"
	"CY" 15feb1998 93.4 1 50.8 49.2 "Clerides" "Vassilou"
	"CY" 16feb2003 90.5 1 51.5 38.8 "Papadopoulos" "Clerides"
	"CZ" 20jun1998 74.0 0 32.3 27.7 "CSSD" "ODS" 
	"CZ" 15jun2002 57.9 0 30.0 24.5 "CSSD" "ODS" 
	"CZ" 03jun2006 64.5 0 35.4 32.3 "ODS" "CSSD" 
	"DE" 27sep1998 82.2 0 40.9 35.1 "SPD" "CDU/CSU" 
	"DE" 22sep2002 79.1 0 38.5 38.5 "SPD" "CDU/CSU" 
	"DE" 18sep2005 77.7 0 40.8 38.4 "CDU" "SPD" 
	"DK" 11mar1998 85.9 0 35.9 24.0 "SD" "V" 
	"DK" 20nov2001 87.1 0 31.3 29.1 "V" "SD" 
	"DK" 08feb2005 84.5 0 29.0 25.8 "V" "SD" 
	"EE" 05mar1995 68.9 0 32.2 16.2 "K ,EME" "R" 
	"EE" 07mar1999 57.4 0 23.4 16.1 "EK" "I" 
	"EE" 02mar2003 57.6 0 25.4 24.6 "EK" "RP" 
	"ES" 03mar1996 78.1 0 38.8 37.6 "PP" "PSOE" 
	"ES" 12mar2000 68.7 0 44.5 34.1 "PP" "PSOE" 
	"ES" 14mar2004 75.7 0 43.3 38.3 "PSOE" "PP" 
	"FI" 06feb1994 77.0 1 54.0 46.1 "Athisaari" "Rehn" 
	"FI" 06feb2000 76.8 1 51.6 48.4 "Halonen" "Aho"
	"FI" 29jan2006 74.0 1 51.8 48.2 "Halonen" "Niinistö"
	"FR" 08may1988 84.2 1 54.0 46.0 "Mitterand" "Chirac"
	"FR" 07may1995 79.7 1 52.6 47.4 "Chirac" "Jospin"
	"FR" 05may2002 79.7 1 82.2 17.8 "Chirac" "Le Pen"
	"GB" 01may1997 71.5 0 43.2 30.7 "Labour" "Conservative" 
	"GB" 07jun2001 59.4 0 40.7 31.7 "Labour" "Conservative" 
	"GB" 05may2005 61.4 0 35.2 32.3 "Labour" "Conservative" 
	"GR" 22sep1996 76.3 0 41.5 38.1 "Pasok" "ND"
	"GR" 09apr2000 75.0 0 43.8 42.7 "Pasok" "ND" 
	"GR" 07mar2004 76.6 0 45.4 40.6 "ND" "Pasok" 
	"HU" 10may1998 56.7 0 32.3 28.2 "MSzP" "FIDESz-MPP" 
	"HU" 21apr2002 73.5 0 42.0 41.6 "MSzP" "FIDESz-MDF"
	"HU" 23apr2006 64.4 0 43.2 42.0 "FIDESz-KDNP" "MSzP" 
	"IE" 25nov1992 68.5 0 39.1 24.5 "Fianna Fáil" "Fine Gael" 
	"IE" 06jun1997 66.1 0 39.3 28.0 "Fianna Fáil" "Fine Gael" 
	"IE" 17may2002 62.6 0 41.5 22.5 "Fianna Fáil" "Fine Gael" 
	"IT" 21apr1996 82.9 0 45.4 43.2 "Ulivo" "Case delle Liberte"
	"IT" 13may2001 81.4 0 45.4 43.2 "Casa delle Liberte" "Ulivo" 
	"IT" 09apr2006 83.6 0 49.8 49.7 "L'Unione" "Casa delle Liberte"
	"LT" 04jan1998 73.7 1 50.4 49.6 "Adamkus" "Paulauskas" 
	"LT" 05jan2003 52.7 1 54.7 45.3 "Paksas" "Adamkus" 
	"LT" 27jun2004 52.5 1 52.6 47.3 "Adamkus" "Prunskiene"
	"LU" 12jun1994 88.3 0 31.4 17.0 "CSV/PCS" "LSAP/SOSL"
	"LU" 13jun1999 86.5 0 30.2 24.2 "CSV/PCS" "LSAP/POSL" 
	"LU" 13jun2004 91.7 0 36.1 23.4 "CSV/PCS" "LSAP/POSL" 
	"LV" 01oct1995 71.9 0 15.2 15.0 "DPS" "TKL-ZP"
	"LV" 03oct1998 71.9 0 21.3 18.2 "TP" "LC" 
	"LV" 05oct2002 71.2 0 23.9 18.9 "JL" "PCTVL" 
	"MT" 26oct1996 97.2 0 50.7 47.8 "MLP" "NP" 
	"MT" 05sep1998 95.4 0 51.8 47.0 "NP" "MLP" 
	"MT" 12apr2003 95.7 0 51.8 47.5 "NP" "MLP" 
	"NL" 06may1998 73.2 0 29.0 24.7 "PvdA" "VVD" 
	"NL" 15may2002 79.1 0 28.0 17.0 "CDA" "LPF" 
	"NL" 22jan2003 80.0 0 28.6 27.3 "CDA" "PvdA" 
	"PL" 19nov1995 68.2 1 51.7 48.3 "Kwasniewski" "Wales" 
	"PL" 08oct2000 61.1 1 53.9 17.3 "Kwasniewski" "Olchowski" 
	"PL" 23oct2005 51.0 1 54.0 46.0 "Kaczynski" "Tusk"
	"PT" 10oct1999 61.0 0 44.1 32.3 "PSP" "PSD" 
	"PT" 17mar2002 62.8 0 40.1 37.9 "PSD" "PSP" 
	"PT" 20feb2005 64.3 0 45.3 28.8 "PSD" "PSP" 
	"RO" 17nov1996 75.9 1 54.4 45.6 "Constantinescu" "Iliescu" 
	"RO" 10dec2000 56.6 1 66.8 33.2 "Iliescu" "Tudor"
	"RO" 12dec2004 54.8 1 51.2 48.8 "Basescu" "Nastase"
	"SE" 18sep1994 88.1 0 45.2 22.4 "SAP" "MSP"
	"SE" 20sep1998 81.4 0 36.4 22.9 "SAP" "MSP" 
	"SE" 15sep2002 80.1 0 39.8 15.2 "SAP" "MSP" 
	"SI" 10nov1996 73.7 0 45.1 27.0 "SP,SLS,SDSS,SKD" "LDS" 
	"SI" 15oct2000 70.4 0 36.3 15.8 "LDS" "SDS" 
	"SI" 03oct2004 60.6 0 29.1 22.8 "SDS" "LDS" 
	"SK" 26sep1998 84.2 0 27.0 26.3 "HZDS" "SDK" 
	"SK" 21sep2002 70.1 0 19.5 15.1 "HZDS" "SDK" 
	"SK" 17jun2006 54.7 0 29.1 18.4 "Smer" "SDKU" 
	"TR" 24dec1995 85.2 0 21.4 19.7 "RP" "ANAP" 
	"TR" 19apr1999 87.1 0 22.3 18.1 "DSP" "MHP" 
	"TR" 03nov2002 76.9 0 34.3 19.4 "AKP" "CHP" 
	"US" 05nov1996 51.7 1 49.0 41.0 "Clinton" "Dole" 
	"US" 07nov2000 55.3 1 48.0 48.0 "Bush" "Gore" 
	"US" 02nov2004 61.0 1 50.7 48.3 "Bush" "Kerry"
end
	lab var iso3166 "Iso3166_2 country codes (2-digit)"
	lab var eldate "Date of election"
	lab var exec "Executive election"
	lab var turnout "Voter turnout"
	lab var party1 "Result of the strongest candidate/party in %"
	lab var party2 "Result of the second-strongest candidate/party in %"
	lab var partyname1 "Name of the strongest candidate/party"
	lab var partyname2 "Name of the second-strongest candidate/party"

	label value exec exec
	label define exec 0 "Leg." 1 "Exec." 

	
	gen edate = date(eldate,"dmy")

	sort iso3166 edate
	tempfile elecspec
	save `elecspec'
	
	
	// Input electionsystems I
	// -----------------------
	// (Edited copy from cr_elec_res.do by lenarz@wzb.eu)

	clear
	input str2 iso3166 str10 elecsys compvote bureaureg
	AT  "List PR" 0 1
	BE  "List PR" 1 1
	BG  "List PR" 0 1
	CY  "List PR" 1 1
	CZ  "List PR" 0 1
	DE      "MMP" 0 1
	DK  "List PR" 0 1
	EE  "List PR" 0 1
	ES  "List PR" 0 1
	FI  "List PR" 0 1
	FR      "TRS" 0 1
	GB     "FPTP" 0 1
	GR  "List PR" 1 1
	HU      "MMP" 0 1
	IE      "STV" 0 0
	IT  "List PR" 1 1
	LT "Parallel" 0 1
	LU  "List PR" 1 1
	LV  "List PR" 0 .a
	MT      "STV" 0 0
	NL  "List PR" 0 1
	PL  "List PR" 0 1
	PT  "List PR" 0 1
	RO  "List PR" 0 1
	SE  "List PR" 0 1
	SI  "List PR" 0 1
	SK  "List PR" 0 1
	TR  "List PR" 1 0
	US     "FPTP" 0 0
end

	lab var elecsys "Electoral system"
	lab var compvote "Compulsory voting"
	lab var bureaureg "Bureacratic registration"

	lab val compvote yesno
	lab val bureaureg yesno 
	lab def yesno 0 "No" 1 "Yes" .a "-", modify


	// Prepare for merging
	sort iso3166 
	tempfile system
	save `system'


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

	// Mehrparteiensystem
	bysort iso3166 edate: gen multip = sum(absseat/totseats > .05)
	bysort iso3166 edate: replace multip = multip[_N]

	// Keep only last three elections
	bysort iso3166 (edate): keep if _n > (_N-3)
	bysort iso3166: egen mmultip = mean(multip)  // Mean of last three
	label var multip "Average number of parties over 5%"

	bysort iso3166: keep if _n==1
	keep iso3166 mmultip

	sort iso3166 
	tempfile manifesto
	save `manifesto'
	
	// Merge Sources together
	// ----------------------

	use `elecspec'
	merge iso3166 using `system', nokeep
	assert _merge == 3
	drop _merge
	sort iso3166
	merge iso3166 using `manifesto', nokeep 
	assert _merge == 3
	drop _merge

	// Derived Variables
	// -----------------
	
	gen weekend:yesno = inlist(dow(edate),0,6)

	gen compet = party1-party2
	
	// Prepare the table
	// -----------------

	// Construct the label variable
	by iso3166 (edate), sort: ///
	  gen label = iso3166 ///
	  + " (" + string(edate[1], "%dY") ///
	  + "/" + string(edate[2], "%dY") ///
	  + "/" + string(edate[3], "%dY") + ")"

	// Classify Nations
	gen natfam = 1 if iso3166 == "US"
	replace natfam = 2 if ///
	  inlist(iso3166,"AT","BE","DE","DK","ES") ///
	  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
	  | inlist(iso3166,"IT","LU","NL","PT","SE")
	replace natfam = 3 if ///
	  inlist(iso3166,"TR","MT","CY")
	replace natfam = 4 if ///
	  inlist(iso3166,"BG","CZ","EE","HU","HR") ///
	  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
	replace natfam = 5 if natfam == .
		
	// Means for election specific quantities
	egen mturnout = mean(turnout), by(iso3166)
	egen mcompet = mean(compet), by(iso3166)

	format mturnout mcompet mmultip %2.0f
	
	// Tag 1st obs.
	by iso3166, sort: gen tag = _n==1
	
	// Define sort order
	egen axis = axis(natfam mturnout) 
	sort axis

	// Produce table
	listtex label mturnout weekend exec compvote bureaureg elecsys ///
	  mcompet mmultip ///
	  using anelectionsystems1.txt if tag, replace rstyle(tabdelim)


	// Produce numbers in the text
	// ---------------------------

	tab natfam weekend, sum(turnout)

	tab natfam exec, sum(turnout)

	tab natfam compvote, sum(turnout)

	tab natfam bureaureg, sum(turnout)

	gen proportional = inlist(elecsys,"List PR", "MMP", "STV") ///
	  if elecsys != "Parallel"
	tab natfam proportional, sum(turnout)

	by natfam, sort: reg turnout compet
	reg turnout compet if natfam==2
	di _b[_cons] + _b[compet]*2

	by natfam, sort: reg turnout mmultip
	reg turnout mmultip if natfam==2
	di _b[_cons] + _b[mmultip]*2
	

   gen sim1 = (weekend != weekend[1]) ///
    + (exec != exec[1]) ///
    + (compvot != compvote[1]) ///
    + (bureaureg != bureaureg[1]) ///
    + (proportional != proportional[1]) ///
    + (abs(compet-compet[1])/62) ///
    + (abs(mmultip - mmultip[1])/8)

	sort sim1
	list eldate  iso3166 sim1 turnout in 1/10
	
	reg turnout weekend exec compvote bureaureg proportional compet mmultip ///
	  if natfam == 2
	predict yhat if natfam == 1
	
	di yhat[1]
	
	
	exit

	Sources:
	
	(1) bureau
	www.aceproject.org

	(2) turnout, branch, compvote, elecsys
	www.idea.int/vt

	(3) compet
	http://www.binghamton.edu/cdp/
	Election Results Archive of the Center on Democratic Performance

	(4) multip
	Manifesto

* Voter turnout of recent first order elections by countries

version 9.2
	clear
	set scheme s1mono
	
	clear
	input str2 iso3166 str9 eldatestring turnout
   AT 03oct1999 80.4
	AT 24nov2002 84.3
	AT 01oct2006 78.5  // http://en.wikipedia.org/wiki/Austrian_legislative_election%2C_2006
	BE 21may1995 91.1
   BE 13jun1999 90.6
	BE 18may2003 96.3
	BG 19apr1997 58.9
	BG 17jun2001 66.6
	BG 25jun2005 55.8
	CY 13feb1993 93.3
	CY 15feb1998 93.4 
	CY 16feb2003 90.5
	CZ 20jun1998 74.0
	CZ 15jun2002 57.9 	
	CZ 03jun2006 64.5
	DE 27sep1998 82.2
	DE 22sep2002 79.1
	DE 18sep2005 77.7
	DK 11mar1998 85.9
	DK 20nov2001 87.1 
	DK 08feb2005 84.5
	EE 05mar1995 68.9
	EE 07mar1999 57.4
	EE 02mar2003 57.6
	ES 03mar1996 78.1
	ES 12mar2000 68.7
	ES 14mar2004 75.7
	FI 06feb1994 77.0 
	FI 06feb2000 76.8 
	FI 29jan2006 74.0
	FR 08may1988 84.2
	FR 07may1995 79.7
	FR 05may2002 79.7 
	GB 01may1997 71.5
	GB 07jun2001 59.4
	GB 05may2005 61.4
	GR 22sep1996 76.3
	GR 09apr2000 75.0
	GR 07mar2004 76.6
	HU 10may1998 56.7
	HU 21apr2002 73.5
	HU 23apr2006 64.4
	IE 25nov1992 68.5
	IE 06jun1997 66.1
	IE 17may2002 62.6 
	IT 21apr1996 82.9
	IT 13may2001 81.4
	IT 09apr2006 83.6
	LT 04jan1998 73.7 
    LT 05jan2003 52.7
	LT 27jun2004 52.5
	LU 12jun1994 88.3
	LU 13jun1999 86.5
	LU 13jun2004 91.7
	LV 01oct1995 71.9
	LV 03oct1998 71.9
	LV 05oct2002 71.2
	MT 26oct1996 97.2
	MT 05sep1998 95.4
	MT 12apr2003 95.7
	NL 06may1998 73.2
	NL 15may2002 79.1
	NL 22jan2003 80.0
	PL 19nov1995 68.2
	PL 08oct2000 61.1
	PL 23oct2005 51.0
	PT 10oct1999 61.0
	PT 17mar2002 62.8
	PT 20feb2005 64.3
	RO 17nov1996 75.9
	RO 10dec2000 56.6
	RO 12dec2004 54.8
	SE 18sep1994 88.1
	SE 20sep1998 81.4
	SE 15sep2002 80.1
	SI 10nov1996 73.7
	SI 15oct2000 70.4
	SI 03oct2004 60.6
	SK 26sep1998 84.2
	SK 21sep2002 70.1
	SK 17jun2006 54.7
	TR 24dec1995 85.2
	TR 19apr1999 87.1
	TR 03nov2002 76.9
	US 05nov1996 51.7  // http://elections.gmu.edu/Turnout%201980-2006.xls
   US 07nov2000 55.3  // http://elections.gmu.edu/Voter_Turnout_2000.htm
	US 02nov2004 61.0  // http://elections.gmu.edu/Voter_Turnout_2004.htm
end

   drop if iso3166=="TR"

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
		
	// Construct elapsed date variable
	gen eldate = daily(eldatestring,"dmy")
	format eldate %dY

	// Construct the label variable
	by iso3166 (eldate), sort: ///
	  gen label = iso3166 ///
	  + " (" + string(eldate[1], "%dY") ///
	  + "/" + string(eldate[2], "%dY") ///
	  + "/" + string(eldate[3], "%dY") + ")"
	
	// Min, Mean, Max
	by iso3166 (turnout), sort: ///
	  gen minturnout = turnout[1]
	by iso3166 (turnout), sort: ///
	  gen meanturnout = (turnout[1] + turnout[2] + turnout[3])/3
	by iso3166 (turnout), sort: ///
	  gen maxturnout = turnout[3]

	// Mean of Natfam
	by natfam, sort: egen groupmean = mean(meanturnout)

	egen axis = axis(natfam meanturnout), gap reverse label(label)

	levelsof axis, local(K)
	graph twoway ///
	  || line axis groupmean if natfam==2 , lcolor(gs8) lwidth(*1.2) lpat(solid) ///
	  || line axis groupmean if natfam==3 , lcolor(gs8) lwidth(*1.2) lpat(solid) ///
	  || line axis groupmean if natfam==4 , lcolor(gs8) lwidth(*1.2) lpat(solid) ///
      || dot meanturnout axis, horizontal mcolor(black) ms(O) ///
      || rspike minturnout maxturnout axis, horizontal lcolor(black) ///
	  || , legend(off) xtitle(Wahlbeteiligung in %) ytitle("") ///
	  ylab(`K', valuelabel angle(0)) ///
	  xtick(50(10)100) xmtick(55(10)95)  ///
	  ysize(6) xsize(4) ///
     title(`"Grafik 1: "', span ring(2) pos(11) justification(left) size(medlarge)) ///
     subtitle(`"Wahlbeteiligung in den letzten drei "'                              ///
              `"nationalen Wahlen"', margin(l+17 b+3)       ///
               span ring(2) pos(11) justification(left) size(medlarge))             ///
	  note("Quelle: http://www.idea.int/vt/ (USA:  McDonald/Popkin 2001)" ///
          "Die Ländernamen sind die zweistelligen Ländercodes der International" ///
          "Standardization Organisation (ISO 3166)." , span)     ///
     legend(off)  

	graph export ../figure1DE.eps, replace preview(on)
	

	
	

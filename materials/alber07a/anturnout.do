* Voter turnout of recent first order elections by countries

version 9.2
	clear
	set scheme s1mono
	
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
		
	gen eldate = daily(eldatestring,"dmy")
	format eldate %d
	sort iso3166 eldate

	// Most recent election
	by iso3166 (eldate): keep if _n==_N
	gen sdate = string(eldate, "%dm_Y")
	gen label = iso3166 + ", " + sdate

	// Mean of Natfam
	by natfam, sort: egen mturnout = mean(turnout)
	egen axis = axis(natfam turnout) if natfam < 5 , gap reverse label(label) 

	graph twoway ///
	  || line axis mturnout if natfam==1 , lcolor(gs8) lwidth(*1.2) lpat(solid) ///
	  || line axis mturnout if natfam==2 , lcolor(gs8) lwidth(*1.2) lpat(solid) ///
	  || line axis mturnout if natfam==3 , lcolor(gs8) lwidth(*1.2) lpat(solid) ///
	  || line axis mturnout if natfam==4 , lcolor(gs8) lwidth(*1.2) lpat(solid) ///
      || dot turnout axis, horizontal mcolor(black) ms(O) ///
      || , legend(off) xtitle(Turnout in %) ytitle("") ///
	  ylab(1(1)10 12 13 14 16(1)30 32, valuelabel angle(0)) ///
	  xtick(50(10)100) xmtick(55(10)95)  ///
	  ysize(10) xsize(6.5) ///
     title("Figure 1" "Electoral participation by country")  ///
	  note("Source: http://www.idea.int/vt/ (For US: McDonald/Popkin 2001)", span)  ///
     legend(off)  

	graph export ../figure1.eps, replace preview(on)
	

	
	
	
	

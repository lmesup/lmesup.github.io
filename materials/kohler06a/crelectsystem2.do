// Elections-System-Variables

	version 8.2
	clear
		
	input s_cntry str10 date compet compul system type absent advance regis
	 1 "24.11.2002"  6.18 0 1 1 0 0 1  // Austria           
	 2 "18.05.2003"   .45 2 1 1 1 0 1  // Belgium           
	 3 "17.06.2001" 24.56 0 1 1 0 0 1  // Bulgaria         
	 4 "27.05.2001" 12.71 2 1 1 . . .  // Cyprus            
	 5 "15.06.2002"  5.73 0 1 1 0 0 1  // Czechia         
	 6 "20.11.2001"  2.20 0 1 1 1 1 1  // Denmark         
	 7  "2.03.2003"  1.80 0 1 1 0 0 .  // Estonia         
	 8 "16.03.2003"  3.20 0 1 1 1 1 1  // Finland         
	 9  "5.05.2002" 63.92 0 2 3 1 0 2  // France            
	10 "22.09.2002"  0.00 0 3 1 1 1 1  // Germany         
	12  "9.04.2000"  1.06 1 1 1 . . 2  // Greece            
	13 "21.04.2002"   .98 0 3 1 0 0 1  // Hungary         
	14 "17.05.2002" 19.00 0 5 1 1 1 1  // Ireland         
	15 "13.05.2001" 14.65 1 3 1 0 1 1  // Italy            
	16  "5.10.2002"  4.89 0 1 1 1 0 3  // Latvia           
	17 "24.10.2002" 11.44 0 2 2 0 1 1  // Lithuania          
	18 "13.06.1999"  6.00 2 1 1 . . 1  // Luxembourg       
	19 "12.04.2003"  4.10 0 5 1 . . .  // Malta            
	20 "22.01.2003"  1.30 0 1 1 1 0 1  // Netherlands       
	21 "23.09.2001" 28.30 0 1 1 0 0 1  // Poland            
	28 "17.03.2002"  2.30 0 1 1 0 1 2  // Portugal         
	22 "26.11.2000"  8.01 0 1 1 0 1 1  // Romania         
	23 "21.09.2002"  4.41 0 1 1 0 0 1  // Slovakia         
	24  "1.12.2002" 13.00 0 1 1 1 1 1  // Slovenia         
	25 "12.03.2000"  5.00 0 1 1 1 1 1  // Spain            
	26 "15.09.2002" 24.60 0 1 1 1 1 1  // Sweden            
	27  "3.11.2002" 14.90 1 1 1 0 1 2  // Turkey            
	11  "7.06.2001"  9.40 0 4 3 1 1 2  // United Kindom
end
	
	label variable date "Date `last' National Election"
	note date: Quelle: CIA, The world Factbook
	note date: http://www.cia.gov/cia/publications/factbook/
	gen edate = date(date,"dmy")
	label variable edate "Date (elapsed format)"
	format edate %dD.N.CY

	gen day:day = dow(edate)
	label define day 0 "So" 1 "Mo" 2 "Di" 3 "Mi" 4 "Do" 5 "Fr" 6 "Sa"
	label variable day "Wochentag"

	label variable compet "Competetiveness (Percent Winner-Percent Second)"
	format compet %3.1f
	note compet: Quelle: CIA, The World Factbook
	note compet: http://www.cia.gov/cia/publications/factbook/
	
	label variable compul "Compul Voting
	label define compul 0 "Nein" 1 "Ja (schwach)" 2 "Ja (stark)"
	label value compul compul
	note compul: Quelle: Institute for Democracy and Electoral Assistance (IDEA)
	note compul: http://www.idea.int/vt/analysis/Compulsory_Voting.cfm

	label variable system "Electoral System"
	label define system 1 "List-PR"  2 "TRS" 3 "MMP"  4 "FPTP"  5 "STV" 6 "PB"  // -> See Note 1
	label value system system
	note system: Quelle: Institute for Democracy and Electoral Assistance (IDEA)
	note system: http://www.idea.int/esd/data/world.cfm
	
	label variable type "Electoral System Type"
	label define type 1 "PR"  2 "Semi-PR"  3 "Majority" 
	label value type type

	label variable absent "Voting by Mail/Proxy"
	label define yesno 0 "Nein"  1 "Ja"
	label value absent yesno
	note absent: Quelle: Election Process Information Collection
	note absent: http://epicproject.org/ace/compepic/en/VO03

	label variable advance "Vote in Advance"
	label value advance yesno
	note advance: Quelle: Election Process Information Collection
	note advance: http://epicproject.org/ace/compepic/en/VO06

	gen nopers:yesno = advance | absent if !missing(advance,absent)
	label variable nopers "Unpersonal Election"

	label variable regis "Registration Self-Initiated or State-Initiated"
	label value regis regis
	label define regis 1 "Staat" 2 "Wähler" 3 "TNZ"
	note advance: Quelle: Election Process Information Collection
	note advance: http://epicproject.org/ace/compepic/en/

	// Merge 2-Digit-Country-Codes
	// ---------------------------

	sort s_cntry
	merge s_cntry using isocntry, keep(iso3166_2 ctrde)
	assert _merge == 3
	drop _merge

	// Prepare Organizational Degree from ESS 2002
	// -----------------------------------------
	
	preserve
	use empl cntry trummb using $ess/ess2002, clear
	keep if empl == "employed":empl
	collapse (mean) orgess=trummb, by(cntry)
	label var orgess "Organizational Degree (ESS)"
	replace orgess = orgess * 100
	format orgess %3.0f

	ren cntry iso3166_2
	sort iso3166_2
	tempfile ess
	save `ess'

	// Prepare Organizational Degree from EVS 1999
	// -------------------------------------------

	use country v15 v306  using $evs/evs1999, clear
	keep if inlist(v306,1,2)
	collapse (mean) orgevs=v15, by(country)
	label var orgevs "Organizational Degree (EVS)"
	replace orgevs = orgevs * 100
	format orgevs %3.0f
	
	gen iso3166_2="" 
	replace iso3166_2="AT" if country == "austria":country
	replace iso3166_2="BE" if country == "belgium":country
	replace iso3166_2="BG" if country == "bulgaria":country
	replace iso3166_2="CY" if country == "cyprus":country
	replace iso3166_2="CZ" if country == "czechia":country
	replace iso3166_2="DK" if country == "denmark":country
	replace iso3166_2="EE" if country == "estonia":country
	replace iso3166_2="FI" if country == "finland":country
	replace iso3166_2="FR" if country == "france":country
	replace iso3166_2="DE" if country == "germany":country
	replace iso3166_2="GB" if country == "great britain":country
	replace iso3166_2="GR" if country == "greece":country
	replace iso3166_2="HU" if country == "hungary":country
	replace iso3166_2="IE" if country == "ireland":country
	replace iso3166_2="IT" if country == "italy":country
	replace iso3166_2="LV" if country == "latvia":country
	replace iso3166_2="LT" if country == "lithuania":country
	replace iso3166_2="LU" if country == "luxembourg":country
	replace iso3166_2="MT" if country == "malta":country
	replace iso3166_2="NL" if country == "netherlands":country
	replace iso3166_2="PL" if country == "poland":country
	replace iso3166_2="RO" if country == "romania":country
	replace iso3166_2="SK" if country == "slovakia":country
	replace iso3166_2="SI" if country == "slovenia":country
	replace iso3166_2="ES" if country == "spain":country
	replace iso3166_2="SE" if country == "sweden":country
	replace iso3166_2="TR" if country == "turkey":country
	replace iso3166_2="PT" if country == "portugal":country

	drop country
	sort iso3166_2
	tempfile evs
	save `evs'

	// Prepare manifesto-Data
	// ----------------------

	use ~/data/manifesto/manifesto if eu==10 | (eu==20 & (country==74 | country== 93)), clear
	bysort country (edate): keep if edate==edate[_N]

	// Seat-Percents
	bysort country: gen relseat = sum(absseat)
	bysort country: replace relseat = absseat/relseat[_N]

	keep if relseat > 0
	drop if rilecmp >= .
	
	// Left-Extrem
	bysort country (rilecmp): gen leftext = rilecmp[1]
	bysort country: replace leftext = leftext[_N] * (-1)
	label var leftext "Links-Extrem"

	// Rechts-Extrem
	bysort country (rilecmp): gen rightext = rilecmp[_N]
	bysort country: replace rightext = rightext[_N] 
	label var rightext "Rechts-Extrem"

	// Left-Representation
	bysort country: gen leftrep = sum((relseat>0) * rilecmp * (rilecmp<0))
	bysort country: replace leftrep = leftrep[_N] * (-1)
	label var leftrep "Links-Representation"

	// Right-Representation
	bysort country: gen rightrep = sum((relseat>0) * rilecmp * (rilecmp>0))
	bysort country: replace rightrep = rightrep[_N] 
	label var rightrep "Rechts-Representation"
	
	// Left-Importance
	bysort country: gen leftimp = sum(relseat * rilecmp * (rilecmp<0))
	bysort country: replace leftimp = leftimp[_N] * (-1)
	label var leftimp "Linkslastigkeit"

	// Right-Importance
	bysort country: gen rightimp = sum(relseat * rilecmp * (rilecmp>0))
	label var rightimp "Rechtslastigkeit"

	// Cleavage-Importance
	gen clevimp = leftimp * rightimp

	// Mehrparteiensystem
	bysort country: gen multip = sum(absseat/totseats > .05)
	bysort country: replace multip = multip[_N]
	label var multip "Anzahl Parteien mit über 5 % der Sitze im Parlament"

	bysort country: keep if _n==_N
	keep country leftext rightext leftrep rightrep leftimp rightimp clevimp multip
	format leftext rightext leftrep rightrep leftimp rightimp rightimp clevimp multip %2.0f

	gen iso3166_2="" 
	replace iso3166_2="AT" if country == "austria":country
	replace iso3166_2="BE" if country == "belgium":country
	replace iso3166_2="BG" if country == "bulgaria":country
	replace iso3166_2="CY" if country == "cyprus":country
	replace iso3166_2="CZ" if country == "czech republic":country
	replace iso3166_2="DK" if country == "denmark":country
	replace iso3166_2="EE" if country == "estonia":country
	replace iso3166_2="FI" if country == "finland":country
	replace iso3166_2="FR" if country == "france":country
	replace iso3166_2="DE" if country == "germany":country
	replace iso3166_2="GB" if country == "great britain":country
	replace iso3166_2="GR" if country == "greece":country
	replace iso3166_2="HU" if country == "hungary":country
	replace iso3166_2="IE" if country == "ireland":country
	replace iso3166_2="IT" if country == "italy":country
	replace iso3166_2="LV" if country == "latvia":country
	replace iso3166_2="LT" if country == "lithuania":country
	replace iso3166_2="LU" if country == "luxembourg":country
	replace iso3166_2="MT" if country == "malta":country
	replace iso3166_2="NL" if country == "netherlands":country
	replace iso3166_2="PL" if country == "poland":country
	replace iso3166_2="RO" if country == "romania":country
	replace iso3166_2="SK" if country == "slovakia":country
	replace iso3166_2="SI" if country == "slovenia":country
	replace iso3166_2="ES" if country == "spain":country
	replace iso3166_2="SE" if country == "sweden":country
	replace iso3166_2="TR" if country == "turkey":country
	replace iso3166_2="PT" if country == "portugal":country
	drop country

	sort iso3166_2
	tempfile manifesto
	save `manifesto'

	clear
	// Dublin 1 - Alber/Fliegner-Skala
	input str2 iso3166_2 leftimp_af
	DK  26.1
	FI  29
   SE 29.6
	BE 30
	LU 28.5
	NL 27.9
	UK 29.9
	IE 31.0
	AT 28.6
	DE 27.4
	FR 30.6
	IT 30.4
	ES 31.2
	PT 31.0
	EL 32.2
	CY 32.0
	MT 29.5
	SI 31.7
	CZ 27.0
	SK 30.6
	HU 31.9
	PL 29.5
	EE 30.6
	LV 31.1
	LT 31.2	
	BG 32.7	
	RO 32.2	
	TR 30.8
end

	tempfile alberfliegner
	save `alberfliegner'
	
      
	// Merge Other Data
	// -----------------

	restore
	sort iso3166_2
	merge iso3166_2 using `ess' `evs' `manifesto' `alberfliegner', nokeep sort
	drop _merge*

	sort iso3166_2
	order iso3166_2 s_cntry
	sort s_cntry
	save electsystem2, replace

	exit

	Note 1: Voting Systems
	----------------------
	
	First Past the Post (FPTP)

	The simplest form of plurality-majority electoral system, using
	single-member districts, a categorical ballot and candidate-centred
	voting. The winning candidate is the one who gains more votes than any
	other candidate, but not necessarily a majority of votes.

	Block Vote (BV)/Party Block Vote (PB)

	BV is a plurality-majority system used in multi-member districts in
	which electors have as many votes as there are candidates to be
	elected. Voting can be either candidate-centred or
	party-centred. Counting is identical to a First Past the Post
	system, with the candidates with the highest vote totals winning
	the seats. PB is form of the Block Vote in which electors choose
	between parties rather than candidates. The successful party will
	typically win every seat in the district.

	Two-Round System (TRS)

	A plurality-majority system in which a second election is held if
	no candidate achieves an absolute majority of votes in the first
	election.


	List Proportional Representation (List PR)

	In its most simple form List PR involves each party presenting a list
	of candidates to the electorate, voters vote for a party, and parties
	receive seats in proportion to their overall share of the national
	vote. Winning candidates are taken from the lists.


	Mixed Member Proportional (MMP)

	Systems in which a proportion of the parliament (usually half) is
	elected from plurality-majority districts, while the remaining
	members are chosen from PR lists. Under MMP the list PR seats
	compensate for any disproportionality produced by the district seat
	results.


	Single Transferable Vote (STV)

	A preferential proportional representation system used in
	multi-member districts. To gain election, candidates must surpass a
	specified quota of first-preference votes. Voters' preferences are
	re-allocated to other continuing candidates when an unsuccessful
	candidate is excluded or if an elected candidate has a surplus.
	


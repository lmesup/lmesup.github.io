// Dataset with meta data on various elections
// -------------------------------------------
// kohler@wzb.eu

version 10.0
clear


// Input Data
// ----------
// (Sources are documented as -notes- below the input section)

input str2 iso3166 str9 eldatestr str5 branch ///
  long nelectorate long nvoters long ninvalid ///
  str99 partyname long nvotes long nseats
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Social Democratic Party (SPÖ)" 1663986 68
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Peoples Party (ÖVP)" 1616493 66
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Freedom Party (FPÖ)" 519598 21
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Greens" 520130 21
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Alliance for the Future of Austria (BZÖ)" 193539 7
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Communist Party of Austria (KPÖ)" 	47578 0
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Liste Dr. Martin (MATIN)" 	131688 	0
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Neutrales Freies Österreich (NFÖ)"	10594 	0
	AT 01oct2006 "Leg." 6107851 4793780 85499 "INITIATIVE 2000 (IVE)" 	592 	0
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Liste Stark (STARK)" 	312 	0
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Sicher-Absolut-Unabhängig (SAU)" 	1514 	0
	AT 01oct2006 "Leg." 6107851 4793780 85499 "Sozialistische LinksPartei (SLP)" 	2257 0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Christian Democratic and Flemish (CD&V), New Flemish Alliance (N-VA)" 1234950 30
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Movement for Reform (MR)" 835073 23
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Socialist Party (PS)" 724787 20
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Open vld" 789445 18
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Vlaams Belang (Flemish Interest)" 799844 17
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Flemish Socialist Party - Spirit (SPA-Spirit)" 684390 14
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Humanist Democratic Centre (CDH)" 404077 10
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Greens - Walloon (Ecolo)" 340378 8
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Dedecker List" 268648 5
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Greens - Flamands (GROEN!) " 265828 4
	BE 10jun2007 "Leg." 7720796 7032077 360717 "National Front (FN)" 131385 1
	BE 10jun2007 "Leg." 7720796 7032077 360717 "VIVANT" 5742    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "BELGUNIE-BUB" 8607    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "VITAL" 1780    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "FORCE NATIONA" 6660    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Wallon" 8688    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "PJM" 4373    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "RWF" 26240    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "PC" 19329    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "FN B" 9010    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "CAP" 20083    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "NP-FN" 1605    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "VÉLORUTION" 1453    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Belgique Positif" 880    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "GSCD" 170    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "UMP-B" 1408    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "MP Education" 1362    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "PLURALIS" 757    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "CDF" 11961    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "PTB+" 14931    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "PVDA+" 37758    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "PTB+PVDA+" 3478    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "Parti Wallon" 3139    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "UNIE" 856    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "DLC" 464    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "FDB" 901    0
	BE 10jun2007 "Leg." 7720796 7032077 360717 "TREFLE" 920    0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Coalition for Bulgaria (CB)" 1129196 82
	BG 25jun2005 "Leg." 6720941 3747793 99616 "National Movement Simeon II (SND)" 725314 53
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Movement for Rights and Freedoms (DPS)" 467400 34
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Attack coalition (CA)" 296848 21
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Union of Democratic Forces (UDF)" 280323 20
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Democrats for Strong Bulgaria (DSB)" 234788 17 
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Bulgarian Peoples Union (BPU)" 189268 13
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Federazija svobodnija bisnez" 12196 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Dvishenije Nabred Bulgaria" 10275 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "SGN Granit" 5923 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Kamera n ekspertite" 3649 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Koalizija Dostoina bulgarija" 8420 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "NK, Da schivej Bulgariya" 12622 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "PD, Ederoroma" 45637 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Koaliziaj na rosata" 47410 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Noboto Vreme" 107758 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "FAGO" 18326 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "OPPB" 12760 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "BChK" 21064 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "N.SCH.P" 1918 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "PDS" 2203 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Roden Kraj" 2052 0
	BG 25jun2005 "Leg." 6720941 3747793 99616 "Independen Candidates" 12827 0

	CH 21oct2007 "Leg." 4915533 2373071 42688 "Swiss Peoples Party  (SVP/UDC) " 666318  62
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Social Democratic Party of Switzerland  (SPS/PSS)" 450116   43 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Free Democratic Party of Switzerland  (FDP/PRD) " 361103   31 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Christian Democratic Peoples Party of Switzerland  (CVP/PDC)" 332920  31 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Green Party of Switzerland  (GPS/PES)" 220785   20 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Liberal Party of Switzerland  (LPS/PLS)" 42356  4
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Green Liberal Party of Switzerland  (GLP/PEL)" 49314   3 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Evangelical Peoples Party  (EVP/PEV)" 56361   2 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Federal Democratic Union  (EDU/UDF)" 29548  1 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Party of Labour  (PdA) " 16649  1 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Ticino League  (LdT) " 13031   1 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Christian Social Party  (CSP/PCS) " 9985  1 

	CH 21oct2007 "Leg." 4915533 2373071 42688 "Swiss Democrats  (SD/DS) " 12609  0 
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Solidarités  (Sol)" 8669 0
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Alternative List (AL) " 4582 0
	CH 21oct2007 "Leg." 4915533 2373071 42688 "Others  " 56037   0
	CY 21may2006 "Leg." 501024 445915 24828 "Progressive Party of the Working People (AKEL)" 131066 18
	CY 21may2006 "Leg." 501024 445915 24828 "Democratic Rally (DISY)" 127776 30.34 18
	CY 21may2006 "Leg." 501024 445915 24828 "Democratic Party (DIKO)" 75458 11
	CY 21may2006 "Leg." 501024 445915 24828 "Movement of Social Democrats (EDEK)" 37533 5
	CY 21may2006 "Leg." 501024 445915 24828 "European Party (EK)" 24196 3
	CY 21may2006 "Leg." 501024 445915 24828 "Ecologists" 8193 1
	CY 21may2006 "Leg." 501024 445915 24828 "United Democrats" 6567 0
	CY 21may2006 "Leg." 501024 445915 24828 "Others" 10298 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Civic Democratic Party (ODS)" 1892475 81
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Czech Social Democratic Party (CSSD)" 1728827 74
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Communist Party of Bohemia and Moravia (KSCM)" 685328 26
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Christian Democratic Union - Czech Peoples party (KDU - CSL)" 386706 13
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Green Party (SZ)" 336487 6
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "European Democrats (SNK)" 111724 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Strana zdraveho rozumu 	" 24828 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Ceske hnuti za narodni jednotu " 216 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Balbinova poeticka strana " 6897 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Liberalni reformni strana " 253 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Pravo a Spravedlnost " 12756 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "NEZAVISLI " 33030 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Ceska pravice " 395 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Koruna Ceska (monarch.strana)" 7293 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Unie svobody-Demokraticka unie " 16457 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Helax-Ostrava se bavi " 1375 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Pravy Blok " 20382 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "4 VIZE-www.4vize.cz " 3109 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Ceska str.narod. socialisticka " 1387 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Moravane " 12552 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Humanisticka strana " 857 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Koalice pro Ceskou republiku " 8140 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Narodni strana " 9341 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "Folklor i Spolecnost " 574 	0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "NEZ.DEMOKRATE(preds.V.Zelezny)"  36708 0
	CZ 03jun2006 "Leg." 8333305 5372449 23473 "STRANA ROVNOST SANCI " 10879 0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Social Democratic Party (SPD)" 16194665 222
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Christian Democratic Union (CDU)" 13136740 180
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Christian Social Union (CSU)" 3494309 46
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Alliance 90/Greens (G)" 3838326 51
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Free Democratiy Party (FDP)" 4648144 61
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Left Party/PDS (L)" 4118194 54
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Republicans (Rep)" 266101 0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "OffD" 3338 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "NPD" 748568 0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Tierschutzp." 110603 0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "GRAUE" 198601 0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "PBC" 108605 0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "DIE FRAUEN" 27497 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "FAMILIE" 191842 0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "BüSo" 35649 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "BP" 35543 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "ZENTRUM" 4010 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Deutschland" 9643 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "AGFG" 21350 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "APPD" 4233 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "50Plus" 10536 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "MLPD" 45238 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Die PARTEI" 10379 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "PSG" 15605 	0
	DE 18sep2005 "Leg." 61870711 48044134 756146 "Pro DM" 10269 	0
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Liberal Party (V) " 908472 46 
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Social Democratic Party (SD)" 881037 45 
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Danish Peoples Party (DF)" 479532 25
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Conservative Peoples Party (KF)" 359404 18
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Radical Liberal Party (RV)" 177161 9 
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Socialist Peoples Party (SF)" 450975 23
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Unity List (EL)" 74982 4
	DK 13nov2007 "Leg." 4022849 3483533 24113 "New Alliance (Y)" 97295 5
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Christian Democrats (KD)" 30013  0
	DK 13nov2007 "Leg." 4022849 3483533 24113 "Others" 549  0
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Spanish Socialist Workers Party (PSOE) " 11026163 164
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Peoples Party (PP) " 9763144 148
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Convergence and Union (CiU) " 835471 10
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Republican Left of Catalonia (ERC) " 652196 8
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Basque Nationalist Party (PNV) " 420980 7
	ES 14mar2004 "Leg." 34571831 26155436 264137 "United Left (IU) " 1284081 5
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Canarian Coalition " 235221 3
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Galician Nationalist Party (BNG) " 208688 2
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Aragonese Union (ChA)" 94252 1
	ES 14mar2004 "Leg." 34571831 26155436 264137 "EA" 80905 1
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Navarra Yes" 61045 1
	ES 14mar2004 "Leg." 34571831 26155436 264137 "Others" 1229153 0
	EE 04mar2007 "Leg." 897243 555463 5250 "Reform Party" 153044 31
	EE 04mar2007 "Leg." 897243 555463 5250 "Center Party" 143518 29
	EE 04mar2007 "Leg." 897243 555463 5250 "Pro Patria and Res Publica Union (IRL)" 98347 19
	EE 04mar2007 "Leg." 897243 555463 5250 "Estonian Social Democratic Party (SDE)" 58363 10
	EE 04mar2007 "Leg." 897243 555463 5250 "Estonian Greens" 39279 6
	EE 04mar2007 "Leg." 897243 555463 5250 "Estonian Peoples Union (R)" 39215 6
	EE 04mar2007 "Leg." 897243 555463 5250	"Party of Estonian Christian Democrats" 9456 	0 
	EE 04mar2007 "Leg." 897243 555463 5250	"Constitution Party" 5464 	0
	EE 04mar2007 "Leg." 897243 555463 5250	"Estonian Independence Party" 1273 0
	EE 04mar2007 "Leg." 897243 555463 5250	"Russian Party in Estonia" 	1084 0
	EE 04mar2007 "Leg." 897243 555463 5250	"Estonian Left Party" 607 0
	EE 04mar2007 "Leg." 897243 555463 5250	"Independents" 		563 0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Center Party (KESK)" 640428 51
	FI 18mar2007 "Leg." 4292436 2790752 19516 "National Coalition Party (KOK)" 616841 50
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Social Democratic Party (SDP)" 594194 45
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Left Alliance" 244296 17
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Green League" 234429 15
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Swedish Peoples Party (SFP)" 126520 9
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Christian Democrats (KD)" 134790 7
	FI 18mar2007 "Leg." 4292436 2790752 19516 "True Finns" 112256 5
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Communist Party of Finland"	18277 	 	0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Seniors' Party of Finland" 	16715 	 	0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Finnish People's Blue-whites   " 	3913  0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Liberals" 	3171  0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "For Peace and Socialism - Communist Worker's Party " 	2007  0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Suomen Isänmaallinen kansanliike " 		821 0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "For the Poor " 		2521  0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Joint Responsibility Party " 	164 	 0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Suomen Työväenpuolue STP " 	1764  0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Itsenäisyyspuolue " 	5541 	 0
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Bourgeois Alliance"	9561 	 	1
	FI 18mar2007 "Leg." 4292436 2790752 19516 "Others"	3027	1
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Nicolas Sarkozy "		11448663 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Ségolène Royal" 	  	9500112 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"François Bayrou" 		6820119 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Jean-Marie Le Pen "		3834530 .	
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Olivier Besancenot "	 	1498581 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Philippe de Villiers "	818407 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Marie-George Buffet "	707268 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Dominique Voynet "		576666 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Arlette Laguiller "	 	487857 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"José Bové" 		483008 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Frédéric Nihous" 	 	420645 	.
	FR 22apr2007 "Exec." 44472834 37254242 534846	"Gérard Schivardi" 		123540 	.
	GB 05may2005 "Leg." 44245939 27336093 187583 "Labour"	9552436	355
	GB 05may2005 "Leg." 44245939 27336093 187583 "Conservative"	8784915	198
	GB 05may2005 "Leg." 44245939 27336093 187583 "Liberal Democrat"	5985454	62
	GB 05may2005 "Leg." 44245939 27336093 187583 "UK Independence Party"	605973	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Scottish National Party"	412267	59
	GB 05may2005 "Leg." 44245939 27336093 187583 "Green"	283414	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Democratic Unionist Party"	241856	9
	GB 05may2005 "Leg." 44245939 27336093 187583 "British National Party"	192745	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Plaid Cymru"	174838	3
	GB 05may2005 "Leg." 44245939 27336093 187583 "Sinn Fein"	174530	5
	GB 05may2005 "Leg." 44245939 27336093 187583 "Ulster Unionist Party"	127414	1
	GB 05may2005 "Leg." 44245939 27336093 187583 "Social Democratic   & Labour Party"	125626	3
	GB 05may2005 "Leg." 44245939 27336093 187583 "Independent"	99691	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Respect-Unity Coalition"	68094	1
	GB 05may2005 "Leg." 44245939 27336093 187583 "Scottish Socialist Party"	43514	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Veritas"	40607	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Alliance Party"	28291	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Others"	22958	1
	GB 05may2005 "Leg." 44245939 27336093 187583 "Socialist Labour Party"	20167	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Liberal Party"	19068	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Independent Kidderminster Hospital and Health Concern"	18739	1
	GB 05may2005 "Leg." 44245939 27336093 187583 "Speaker"	15153	1
	GB 05may2005 "Leg." 44245939 27336093 187583 "English Democrats"	15149	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Socialist Alternative"	9398	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "National Front"	8079	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Legalise Cannabis Alliance"	6950	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Monster Raving Loony Party"	6311	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Community Action Party"	5984	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Operation Christian Vote"	4004	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Mebyon Kernow"	3552	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Forward Wales"	3461	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Christian Peoples Alliance"	3291	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Vote for Yourself Rainbow Dream Ticket"	2463	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Community Group"	2365	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Ashfield Independents"	2292	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Alliance for Green Socialism"	1978	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Residents' Association of London"	1850	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Workers Party"	1669	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Socialist Environmental Alliance"	1649	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Scottish Unionist Party"	1266	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Workers Revolutionary Party"	1241	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "New England Party"	1224	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Communist Party of Britain"	1124	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "The Community (London Borough of Hounslow)"	1118	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Peace and Progress"	1036	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Scottish Senior Citizens Unity Party"	1017	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Your Party"	1006	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "S O S  ! Voters Against Overdevelopment of Northampton"	932	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Independent Working Class Association"	892	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Democratic Labour Party"	770	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "British Public Party"	763	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Free Scotland Party"	743	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Pensioners Party Scotland"	716	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Publican Party - Free to Smoke"	678	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "English Independence Party"	654	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Socialist Unity"	581	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Local Community Party"	570	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Clause   28"	516	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "UK Community Issues Party"	502	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Democratic Socialist Alliance - People Before Profit"	490	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Rock 'N' Roll Loony Party"	479	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Newcastle Academy with Christian Values Party"	477	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Freedom Party"	434	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "St Albans Party"	430	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Common Good"	428	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "The People's Choice ! Exclusively For All"	418	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Build Duddon and Morecambe Bridges"	409	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Safeguard the NHS"	400	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Croydon Pensions Alliance"	394	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Independent Progressive Labour Party"	382	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Third way"	382	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Pride in Paisley Party"	381	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Independent Green Voice"	379	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Open Forum"	366	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Islam Zinda Baad Platform"	361	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "People of Horsham First Party"	354	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "The Peace Party"	338	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Scottish Independence Party"	337	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Protest Vote Party"	313	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Virtue Currency Cognitive Appraisal Party"	274	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Organisation of Free Democrats"	264	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Senior Citizens Party"	248	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Socialist Party"	240	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Civilisation Party"	227	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Justice Party"	210	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Northern Progress"	193	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Save Bristol North Baths Party"	190	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Iraq War  . Not In My Name"	189	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Demanding Honesty in Politics and Whitehall"	187	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Death Dungeons  & Taxes"	182	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Motorcycle News Party"	167	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Alternative Party"	163	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "New Millennium Bean Party"	159	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Resolutionist Party"	159	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Get Britian Back Party"	153	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Millennium Council"	148	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Families First"	144	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Imperial Party"	129	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "English Parliamentary Party"	125	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Glasnost"	125	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Church of the Militant Elvis Party"	116	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Personality AND Rational Thinking ? Yes! Party"	107	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Max Power Party"	106	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Blair Must Go Party"	103	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "World"	84	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Wessex Regionalists"	83	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "The Pensioners Party"	82	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Silent Majority Party"	78	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Xtraordinary People Party"	74	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Removal Of Tetramasts In Cornwall"	61	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "For Integrity And Trust In Government"	57	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Progressive Democratic Party"	56	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Tiger's Eye - the Party for Kids"	50	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Their Party"	47	0
	GB 05may2005 "Leg." 44245939 27336093 187583 "Telepathic Partnership"	34	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "New Democracy (NDM)"	2995479	152
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Panhellenic Socialist Movement (PASOK)"	 2727853	102
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Communist Party of Greece(KKE)"	583815	22
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Coalition of the Radical Left (Sy.Riz.A)"	361211	14
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Popular Orthodox Rally	(La.O.S)" 271764	10
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Ecologist Greens"	75529	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Democratic Revival"	57189	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Union of Centrists"	20822	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Communist Party of Greece"	17561	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Radical Left Front"	11859	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "United Anti-Capitalist Left" 10595	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Marxist-Leninist Communist Party of Greece"	8088	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Liberal Alliance"	7516	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Liberal Party"	3092	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Organization for the Reconstruction of the Communist Party of Greece"	2494	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Fighting Socialist Party of Greece"	2099	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Greek Ecologists"	1740	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Light – Truth – Justice" 	970	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Independents"	574	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Democratic Universal Hellas" 	10	0
	GR 20sep2007 "Leg." 9921893 	7356294 196029 "Regional Urban Development" 5	0
	HU 23apr2006 "Leg." 8076781 5457553 49503 "Hungarian Socialist Party (MSzP)" 2336705 186
	HU 23apr2006 "Leg." 8076781 5457553 49503 "League of Young Democrats/Hungarian Civic Party (FIDESz-KDNP)" 2272979 164
	HU 23apr2006 "Leg." 8076781 5457553 49503 "Alliance of Free Democrats (SzDSz)" 351612 18
	HU 23apr2006 "Leg." 8076781 5457553 49503 "Hungarian Democratic Forum (MDF)" 272831 11
	HU 23apr2006 "Leg." 8076781 5457553 49503 "MIÉP-Jobbik Third Way Alliance of Parties (MIÉP-Jobbik)"	119007 0 
	HU 23apr2006 "Leg." 8076781 5457553 49503 "Hungarian Communist Workers' Party"  	21955 0 
	HU 23apr2006 "Leg." 8076781 5457553 49503 "Centre Party"  	17431 0
	HU 23apr2006 "Leg." 8076781 5457553 49503 "Others"  	15530 0

	IE 24may2007 "Leg." 3110914 2085245 19435 "Fianna Fail"	 	        858565 	106
	IE 24may2007 "Leg." 3110914 2085245 19435 "Fine Gael "	 	        564428 	51
	IE 24may2007 "Leg." 3110914 2085245 19435 "Labour Party  "	        209175 	20
	IE 24may2007 "Leg." 3110914 2085245 19435 "Green Party "	         96936 	 6
	IE 24may2007 "Leg." 3110914 2085245 19435 "Sinn Féin "	 	        143410 	 4
	IE 24may2007 "Leg." 3110914 2085245 19435 "Progressive Democrats "	 56396 	 2
	IE 24may2007 "Leg." 3110914 2085245 19435 "Independent "	  	    118951 	5
	IE 24may2007 "Leg." 3110914 2085245 19435 "People Before Profit"	  900	0
	IE 24may2007 "Leg." 3110914 2085245 19435 "Workers' Party"			  300	0
	IE 24may2007 "Leg." 3110914 2085245 19435 "Christian Solidarity"	 1400	0
	IE 24may2007 "Leg." 3110914 2085245 19435 "Fathers Rights"			 1300	0
	IE 24may2007 "Leg." 3110914 2085245 19435 "Immigration Control"	 	 1300	0
	IE 24may2007 "Leg." 3110914 2085245 19435 "Irish Socialist Network"   500	0
	IE 24may2007 "Leg." 3110914 2085245 19435 "Others"   12249	0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"l'ulivo"	11930983	220	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"rifcom"	2229464		41	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"la rosa nel pugno"	990694		18	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"comunisti italiani"	884127		16	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"di pietro it valori"	877052		16	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"feddei verdi"	784803		15	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"udeur popolari"	534088		10	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"partpens"	333278		0	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"svp"	182704		4	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"i socialisti "	115066			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"lista consumatori"	73751			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"alllombaut"	44589			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"liga fronte veneto"	21999		0	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"forza italia"	9048976		137	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"alleanza nazionale"	4707126		71	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"udc"	2580190		39	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"lega nord"	1747730		26	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"demcrist-nuovo psi"	285474		4	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"altersocmussolini"	255354			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"fiamma tricolore"	230506			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"no euro"	58746			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"pensionati uniti"	27550		0	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"ambienta-lista"	17145			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"pliberale italiano"	12265			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"sos italia"	6781			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"destra nazionale"	1093			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"sardigna natzione"	11000			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"dimensne christiana"	2489			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"per il sud"	5130			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"die freiheitlichen"	17183		0	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"movimento triveneto"	4518			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"movdemsic-noi sic"	5003			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"progetto nordest"	92002			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"solidarieta'"	5814			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"irs"	11648			0
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"terzo polo"	16174		0	
	IT 09apr2006 "Leg." 46997601 39298497 1145154 	"lega sud"	848			0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Labour Party (LP)" 340035 39
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Working for Lithuania" 246852 31
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Homeland Union (HU)" 176409 25
	LT 10oct2004 "Leg." 2664169 1228653 32998 "For the Order and Justice" 135807 10
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Liberal and Centre Union (LCU)" 109872 18
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Union of Farmers Party and New Democracy Party (UPNDP)" 78902 10
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Lithuanian Poles Electoral Action" 45302 2
	LT 10oct2004 "Leg." 2664169 1228653 32998 "CCSU" 23426 0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "LChD" 16362 0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "NCP "5989 0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Republican Party (RP) " 4326 0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Lithuanian Social Democratic Union (LSDU) " 3977 0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Lithuuanian Freedom Union (LFU) " 3337 0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "National Party" 2577 0
	LT 10oct2004 "Leg." 2664169 1228653 32998 "Lithuanian Nationalsit Union (LNU) " 2482 0
	LU 13jun2004 "Leg." 217683 200092 11182 "Christian Social Party (PCS/CSV)"  68219 24
	LU 13jun2004 "Leg." 217683 200092 11182 "Socialist Workers Party (POSL/LSAP)" 44154 14
	LU 13jun2004 "Leg." 217683 200092 11182 "Democrat Party (PD/DP)" 30316 10
	LU 13jun2004 "Leg." 217683 200092 11182 "Greens (DEI GRÉNG)"  21875 7
	LU 13jun2004 "Leg." 217683 200092 11182 "Action Committee for Democracy and Justice" 18790 5
	LU 13jun2004 "Leg." 217683 200092 11182 "The Left" 3586 0
	LU 13jun2004 "Leg." 217683 200092 11182 "Communist Party of Luxembourg (KPL)"  1737 0
	LU 13jun2004 "Leg." 217683 200092 11182 "Free Party Luxembourg (FPL)" 231 0
	LU 13jun2004 "Leg." 217683 200092 11182 "Others" 2 0
	LV 07oct2006 "Leg." 1490636 908979 7314 "Peoples Party (TP)" 177481 23 
	LV 07oct2006 "Leg." 1490636 908979 7314 "Union of Greens and Farmers (ZZS)" 151595 18
	LV 07oct2006 "Leg." 1490636 908979 7314 "New Era (JL)" 148602 18
	LV 07oct2006 "Leg." 1490636 908979 7314 "Concord Centre (SC)" 130887 17
	LV 07oct2006 "Leg." 1490636 908979 7314 "Latvia first party (LPP)/Latvian way (LC)" 77869 10
	LV 07oct2006 "Leg." 1490636 908979 7314 "Conservative Union for Fatherland and Freedom (TB/LNNK)" 62989 8
	LV 07oct2006 "Leg." 1490636 908979 7314 "For Civil Rights (PCTVL)" 54684 6
	LV 07oct2006 "Leg." 1490636 908979 7314 	"Latvian Social Democratic Workers' Party" 	31728 0
	LV 07oct2006 "Leg." 1490636 908979 7314 	"Motherland"  	18860  0
	LV 07oct2006 "Leg." 1490636 908979 7314 	"All For Latvia!"  	13469  0
	LV 07oct2006 "Leg." 1490636 908979 7314 	"New Democrats" 	11505 0
	LV 07oct2006 "Leg." 1490636 908979 7314 	"Others" 	21996 0
	MT 12apr2003 "Leg." 294106 285122 2909 "Nationalist Party (PN) " 146172 35
	MT 12apr2003 "Leg." 294106 285122 2909 "Malta Labour Party (MLP) " 134092 50
	MT 12apr2003 "Leg." 294106 285122 2909 "Democratic Alternative " 1929 0
	MT 12apr2003 "Leg." 294106 285122 2909 "Others" 20 0
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Christian Democratic Appeal (CDA)" 2608573 41
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Labour Party (PvdA)" 2085077 33
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Socialist Party (SP)" 1630803 25
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Peoples Party for Freedom and Democracy (VVD)" 1443312 22
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Party for Freedom (GW/PvdV)" 579490 9
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Green Left" 453054 7
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Christian Union" 390969 6
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Democrats 66 (D66)" 193232 3
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Reformed Political Party (SGP)" 153266 2
	NL 22nov2006 "Leg." 12264503 9854998 16315 "Party for the Animals (PvdD)" 179988 2
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Fortuyn" 	20956	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Nederland Transparant" 	2318	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"EénNL" 	62829	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Lijst Poortman" 	2181	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"PVN - Partij voor Nederland" 	5010 0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Continue Directe Democratie Partij  (CDDP)"	559	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Liberaal Democratische Partij" 	2276	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"VERENIGDE SENIOREN PARTIJ" 	12522	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Ad Bos Collectief" 	5149	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Groen Vrij Internet Partij" 	2297	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Lijst Potmis" 	4339	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"Tamara's Open Partij" 	114	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"SMP" 	184	0 
	NL 22nov2006 "Leg." 12264503 9854998 16315 	"LRVP - het Zeteltje" 	185	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Labour Party (A)" 862456 61 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Progress Party (FRP)" 581896 38 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Conservative Party (H)" 371948 23 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Socialist Left Party (SV)" 232971 15 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Centre Party (SP)" 171063 11 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Christian Peoples Party (KRF)" 178885 11 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Liberal Party (V)" 156113 10
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Red Election Aliance (RV)" 32355 0
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Coastal Party (KYST)" 21948 0
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Pensioners' Party (Pensjonistpartiet)" 	13559 	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Christian Unity Party (Kristent Samlingsparti)" 	3865 	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Environment Party The Greens (Miljøpartiet De Grønne)" 	3652 0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "The Democrats (Demokratene)" 	2706 	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Abortion Opponents' List (Abortmotstandernes Liste)" 	1932 	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Communist Party of Norway (Norges Kommunistiske Parti)" 	1066 	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Reform Party (Reformpartiet)" 	727 	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Sami People Party (Sámeálbmot bellodat Samefolkets Parti)" 	660 0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Liberal People's Party (Det Liberale Folkeparti)" 	213 	0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Norwegian Republican Alliance (Norsk Republikansk Allianse)" 	94 0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Beer Unity Party (Pilsens Samlingsparti)" 	65 0 
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Society Party (Samfunnspartiet)" 	43 	0
	NO 12sep2005 "Leg." 3421741 2649520 11257 "Others" 	46	0
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Civic Platform (PO)" 6701010 209
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Law and Justice (PiS)" 5183477 166
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Left and Democrats (LiD)" 2122981 53
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Polish Peasant Party (PSL)" 1437638 31
	PL 21oct2007 "Leg." 30615471 16495045 352843 "German Minoriy" 32462 1
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Self-Defense of the Republic of Poland (SRP)" 	247335 	 0 
	PL 21oct2007 "Leg." 30615471 16495045 352843 "League of the Right of the Republic (LPR)" 	209171  0 
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Polish Labor Party (PPP)" 	160476  0 
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Women's Party (PK)" 	45121 0 
	PL 21oct2007 "Leg." 30615471 16495045 352843 "Patriotic Self-Defense" 	2531  0 
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Socialist Party (PS) " 2588312 121
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Social Democratic Party (PSD) " 1653425 75
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Unitary Democratic Coalition (CDU) " 433369 14
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Popular Party (CDS-PP) " 416415 12
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Left Bloc (BE) " 364971 8
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Communist Party of Portuguese Workers (PCTP)" 48186  0 
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Humanist Party (PH)" 17056  0 
	PT 20feb2005 "Leg." 8944508 5747834 169052 "National Renewal Party (PRN)" 9374  0 
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Workesr' Party for Socialist Unity (POUS)" 5535  0 
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Party of new Democracy (PND)" 40358  0 
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Democratic Party of the Atlantic (PDA)" 1618  0
	PT 20feb2005 "Leg." 8944508 5747834 169052 "Others" 163  0


	
	RO 28nov2004 "Leg." 18449344 10697782 561322 "Social Democratic Party (PSD) + Humanist Party of Romania (PUR)" 3730352 132
	RO 28nov2004 "Leg." 18449344 10697782 561322 "Justice and Truth Alliance (PNL-PD) " 3191546 112 
	RO 28nov2004 "Leg." 18449344 10697782 561322 "Party of Greater Romania " 1316751 48
	RO 28nov2004 "Leg." 18449344 10697782 561322 "Hungarian Democratic Union of Romania (UDMR) " 628125 22
	RO 28nov2004 "Leg." 18449344 10697782 561322 "New Generation Party" 	227443 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "Christian-Democratic National Peasants' Party" 188268 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PFD" 79376 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PER" 73001 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PRS" 56076 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PUN" 53222 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PAP" 48152 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PSU" 44459 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "FDG" 36166 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PMR" 35278 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "URR" 32749 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PAS" 28429 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PSR" 28034 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PNDC" 27650 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PND" 20926 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PSDCTP" 20318 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "APCD" 18594 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PTD" 16271 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UBDR" 15283 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PM" 15109 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "APUR" 15041 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PPP" 14882 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UUDR" 10888 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "CRLDR" 10562 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UCDR" 10331 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UADR" 9810 1
	RO 28nov2004 "Leg." 18449344 10697782 561322 "AMDR" 9750 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "ACMSR" 9595 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "FCER" 8449 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UDCR" 7769 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UDTR" 7715 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "AET" 7396 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UEDR" 7161 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "USDR" 6643 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UTMDR" 6517 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UDTTMDR" 6452 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "ADMSDR" 6344 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "ACBDR" 6240 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "AIDRR" 6188 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UDSS" 5950 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UPDRDP" 5473 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "CIDR" 5181 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "AUCPDR" 5159 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "ALADR" 5011 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "CBABDR" 4065 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "UCARDR" 2871 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "PPDR" 2336 0
	RO 28nov2004 "Leg." 18449344 10697782 561322 "FD" 1103 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Social Democratic Party (SAP)" 1942625 130
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Moderate Party (M)" 1456014 97
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Centre Party (CP)" 437389 29
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Liberal Party (FP)" 418395 28
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Christian Democratic Party (Kd)" 365998 24
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Left Party (VP)" 324722 22
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Green Party (Mpg)" 291121 19
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Sweden Democrats" 162463 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Feminist Initiative"	37954 0 	
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Pirate Party"  	34918 	0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Swedish Senior Citizen Interest Party"  	28806 	0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "June List" 	26072 	0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Health Care Party" 	11519 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "National Democrats" 	3064 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Unity" 	2648 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "National Socialist Front" 	1417 	0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "New Future"  	1171 	0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Socialist Justice Party"  	1097 	0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "People's Will" 	881 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Kommunisterna" 	438	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Unika Partiet" 	222	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Klassiskt Liberala Partiet" 	202	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Allianspartiet" 	133	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Kvinnokraft" 	116	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Europeiska Arbetarpartiet-EAP" 	83	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Partiet för kontinuerlig direktdemokrati" 	81 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Sverige ut ur EU (UT) Frihetliga Rättvisepartiet (FRP)" 	75	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Sveriges Nationella Demokratiska Parti" 	68	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Partiet.se" 	61	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Septemberlistan" 	51	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Kommunistiska förbundet" 	30	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Nordisk Union" 	24	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Skånepartiet" 	11	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Skattereformisterna" 	9	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Rikshushållarna" 	8	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Miata Partiet" 	7	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Demokratiska partiet de nya svenskarna D.P.N.S" 	6 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Fårgutapartiet" 	6	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "PALMES PARTI" 	5	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Republikanerna" 	2	 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "VIKINGAPARTIET-VALVARUHUSET 53 PARTIER" 	1 0
	SE 17sep2006 "Leg." 6892009 5650416 99138 "Others " 1365 0
	SI 03oct2004 "Leg." 1634402 991263 22491 "Slovenian Democratic Party (SDS) " 281710 29
	SI 03oct2004 "Leg." 1634402 991263 22491 "Liberal Democracy of Slovenia (LDS) " 220848 23 
	SI 03oct2004 "Leg." 1634402 991263 22491 "United List of Social Democrats (ZLSD) " 98527 10
	SI 03oct2004 "Leg." 1634402 991263 22491 "New Slovenia - Christian Peoples Party (NSi) " 88073 9
	SI 03oct2004 "Leg." 1634402 991263 22491 "Slovene Peoples Party (SLS) " 66032 7
	SI 03oct2004 "Leg." 1634402 991263 22491 "Slovene National Party (SNS) " 60750 6
	SI 03oct2004 "Leg." 1634402 991263 22491 "Democratic Party of Pensioners of Slovenia " 39150 4
	SI 03oct2004 "Leg." 1634402 991263 22491 "Active Slovenia (AS)" 28767 0
	SI 03oct2004 "Leg." 1634402 991263 22491 "Slovenia is ours (SJN)" 25343 0
	SI 03oct2004 "Leg." 1634402 991263 22491 "Party of the Youth of Slovenia (SMS)" 20174 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"june list" 	8733 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"green party of slovenia" 	6703 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"the list for enterprising slovenia" 	5435 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"women's voice of slovenia et al. " 	5229  0
	SI 03oct2004 "Leg." 1634402 991263 22491	"party of ecological movements" 	3991 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"democratic party of slovenia" 	2670 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"party of the slovenian nation" 	2574 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"the united for an indipendent and just slovenia" 	1496 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"advance slovenia" 	995 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"social and liberal party" 	713 0
	SI 03oct2004 "Leg." 1634402 991263 22491	"independent " 859 0

	SK 17jun2006 "Leg." 4272517 2335917 32778 "Smer (Direction)" 671185 50
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Slovak Democratic and Christian Union (SDKU)" 422815 31
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Slovak National Party (SNS)" 270230 20
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Hungarian Coalition Party (SMK)" 269111 20
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Peoples Party - Movement for a Democratic Slovakia (LS-HZDS)" 202540 15
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Christian Democratic Movement (KDH)" 191443 14
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Communist Party of Slovakia" 	89418 	 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Free Forum  " 	79963 	 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Alliance of the New Citizen" 	32775  0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Movement for Democracy  " 	14728 	 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Hope  " 	14595 	 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Obcianskakonzervativnastrana"	6262 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Slovenskanarodnakoalicia-Slovenskavzajomnost"	4016 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Slovenskaludovastrana"	3815 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Agrarnastranavidieka"	3160 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "ProsperitaSlovenska"	3118 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Lavicovyblok"	9174 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Stranaobcianskejsolidarity"	2498 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Misia-Novakrestanskademokracia"	2523 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "Stranademokratickejlavice"	2906 0
	SK 17jun2006 "Leg." 4272517 2335917 32778 "ZdruzenierobotnikovSlovenska"	6864 0
	US 02nov2004 "Exec." 202746417 123535883 1240538 "George W. Bush" 62040610 	.
	US 02nov2004 "Exec." 202746417 123535883 1240538 "John Kerry "	59028444 	.
	US 02nov2004 "Exec." 202746417 123535883 1240538 "Ralph Nader "	465650 .
	US 02nov2004 "Exec." 202746417 123535883 1240538 "Michael Badnarik " 397265 	.
	US 02nov2004 "Exec." 202746417 123535883 1240538 "Michael Peroutka " 143630 	.
	US 02nov2004 "Exec." 202746417 123535883 1240538 "David Cobb "	119859 .
	US 02nov2004 "Exec." 202746417 123535883 1240538 "Other "	99887 .
end


// Merge other information
// -----------------------

// From IPU Database
preserve
use iso3166 parlstruc using ~/data/agg/electionsystem, clear
by iso3166, sort: keep if _n==1
tempfile x
save `x'

restore
sort iso3166
merge iso3166 using `x', nokeep
assert _merge==3
drop _merge


// Document Sources
// ----------------

note parlstruc: IPU: PARLINE database on national parliaments
note nelectorate: ES LT LU SI: European Journal of Political Research Yearbook 2005
note nelectorate: DE GB NO PT : European Journal of Political Research Yearbook 2006
note nelectorate: AT BE BG CH CY CZ DK EE IE FI GR HU IT LV MT NL PL SE SK: http://www.ipu.org/parline-e/parlinesearch.asp (PARLINE Database) 
note nelectorate: FR: http://en.wikipedia.org/wiki/List_of_election_results (Wikipedia)
note nelectorate: RO: http://www.idea.int/vt/ (IDEA)
note nelectorate: US: http://elections.gmu.edu/ (United States Elections Project)

note nvoters: ES LT LU SI: European Journal of Political Research Yearbook 2005
note nvoters: DE GB NO PT : European Journal of Political Research Yearbook 2006
note nvoters: BE BG CH CY CZ DK EE IE FI HU IT LV MT NL PL SE SK: http://www.ipu.org/parline-e/parlinesearch.asp (PARLINE Database) 
note nvoters: FR: http://en.wikipedia.org/wiki/List_of_election_results
note nvoters: US: http://elections.gmu.edu/ (United States Elections Project)
note nvoters: AT: http://www.bmi.gv.at/Wahlen/ (Bundesminiter des Inneren)
note nvoters: GR: http://www.ekloges.ypes.gr/pages_en/index.html
note nvoters: RO: Valid voters from http://www.bec2004.ro/documente/Tvot_CD.pdf. Also see sources for number of invalid votes. 


note ninvalid: ES LT LU SI: European Journal of Political Research Yearbook 2005
note ninvalid: DE GB NO PT : European Journal of Political Research Yearbook 2006
note ninvalid: BE BG CH CY CZ DK EE IE FI HU IT LV MT NL PL SE SK: http://www.ipu.org/parline-e/parlinesearch.asp (PARLINE Database) 
note ninvalid: FR: http://en.wikipedia.org/wiki/List_of_election_results (Wikipedia)
note ninvalid: US: http://elections.gmu.edu/ (United States Elections Project)
note ninvalid: RO: http://wwww.idea.int/vt/ (Idea)
note ninvalid: AT: http://www.bmi.gv.at/Wahlen/
note ninvalid: US: Invalid votes calculated by voters-votes
note ninvalid: GR: http://www.ekloges.ypes.gr/pages_en/index.html

note nvotes: AT: http://www.bmi.gv.at/Wahlen/ 
note nvotes: BE: http://verkiezingen2007.belgium.be/nl/cha/results/results_tab_etop.html
note nvotes: BG: http://www.2005izbori.org/results/index.html
note nvotes: CH: http://en.wikipedia.org/wiki/Elections_in_Switzerland
note nvotes: CY: http://en.wikipedia.org/wiki/Elections_in_Cyprus
note nvotes: CZ: http://www.volby.cz/pls/ps2006/ps2?xjazyk=EN
note nvotes: DE: http://www.bundeswahlleiter.de/bundestagswahl2005/ergebnisse/bundesergebnisse/b_tabelle_99.html
note nvotes: DK: http://en.wikipedia.org/wiki/Elections_in_Denmark
note nvotes: EE: http://en.wikipedia.org/wiki/Elections_in_Estonia
note nvotes: ES: European Journal of Political Research Yearbook 2005
note nvotes: FI: http://192.49.229.35/E2007/e/tulos/tulos_kokomaa.html (Ministry of Justice)
note nvotes: FR: http://www.conseil-constitutionnel.fr/dossier/presidentielles/2007/documents/tour1/resultats.htm
note nvotes: GB: http://www.parliament.uk/commons/lib/research/rp2005/rp05-033.pdf  (House of Commons 2005:92)
note nvotes: GR: http://www.ekloges.ypes.gr/pages_en/index.html
note nvotes: HU: http://en.wikipedia.org/wiki/Elections_in_Hungary (List votes, 1st round)
note nvotes: IE: http://www.ipu.org/parline-e/reports/2153_E.htm (IUP)
note nvotes: IT: http://elezionistorico.interno.it/
note nvotes: LT: http://en.wikipedia.org/wiki/Elections_in_Lithuania
note nvotes: LU: European Journal of Political Research Yearbook 2005
note nvotes: LV: http://en.wikipedia.org/wiki/Elections_in_Latvia
note nvotes: MT: http://www.ipu.org/parline-e/reports/2203_E.htm (IUP)
note nvotes: NL: http://www.kiesraad.nl/tweede/virtuele_map/uitslag-van-de
note nvotes: NO: European Journal of Political Research Yearbook 2006 + http://en.wikipedia.org/wiki/Elections_in_Norway
note nvotes: PL: http://en.wikipedia.org/wiki/Sejm_of_the_Republic_of_Poland
note nvotes: PT: European Journal of Political Research Yearbook 2006
note nvotes: RO: http://www.bec2004.ro/documente/Tvot_CD.pdf
note nvotes: SE: http://www.val.se/val/val2006/slutlig/R/rike/roster.html
note nvotes: SI: European Journal of Political Research Yearbook 2005 + http://volitve.gov.si/dz2004/en/html/rez_si.htm 
note nvotes: SK: http://www.statistics.sk/nrsr_2006/angl/obvod/results/tab3.jsp
note nvotes: US: http://www.fec.gov/pubrec/fe2004/tables.pdf


// Value Labels and Friends
// ------------------------

lab var iso3166 "Country Code (ISO 3166)"

egen ctrname = iso3166(iso3166), o(codes)
lab var ctrname "Country"

lab var eldatestr "Election date (string)"

gen eldate = date(eldatestr,"DMY")
format %tddd_Mon_YY eldate
lab var eldate "Election date"

gen election = iso3166 + " (" + string(eldate,"%td") + ")"
lab var election "Election"

gen long nvalid=nvoters-ninvalid
lab var nvalid "Number of valid votes"

gen compulsory = inlist(iso3166,"IT","BE","LU","CY","GR")
label var compulsory "Compulsory election"


lab var branch "Electoral branch"

lab var nelectorate "Size of electorate"
lab var nvoter "Number of voters"
lab var ninvalid "Number of invalid votes"
lab var partyname "Party"
lab var nvotes "Number of votes cast"
lab var nseats "Number of seats in parliament"

format n* %16.0f
order iso3166 ctrname parlstru election eldatestr eldate compulsory branch ///
  nelectorate nvoters ninvalid nvalid nvotes nseats




// Data-Checks
// -----------

assert nelectorate > nvoters if !mi(nvoters)
assert nelectorate > ninvalid if !mi(ninvalid)
assert nelectorate > nvotes if !mi(nvotes)

sort election
by election: gen long control = sum(nvotes)
by election: replace control = control[_N]

by election: assert control < nelectorate
by election: assert control < nvoters
by election: assert control == nvalid if nvalid != .
drop control



// Save
// ----

compress
save elections, replace


exit

















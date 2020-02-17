* Initialization of the Result-Set
* --------------------------------
	
* Creates a Dataset with Countries and some Aggregate Measures

version 8.2
	set more off
	

	// Load  Aggregate Data from EQLS
	// ------------------------------

	use s_cntry gdpeuro-suicidem using $dublin/eqls_4, clear

	drop gdpeuro gdppps02 gdppcap2 gdpdefl physdens healthex popsize1 popsize2 ///
	  age0_14 age15_64 age65 totfert abortrat femmort malemort firstbir agemarri ///
	 seatswom povrate urbanpop pc cars hdivalue hdirank freedom corrupt

	by s_cntry, sort: keep if _n==1

	// Country-Variables
	// ------------------

	sort s_cntry

	input str20 country str3 iso3166_3 str2 iso3166_2
	Österreich      AUT  AT
	Belgien 			  BEL  BE
	Bulgarien 		  BGR  BG
	Zypern 			  CYP  CY
	Tschechien 		  CZE  CZ
	Dänemark 		  DNK  DK
	Estland 			  EST  EE
	Finnland 		  FIN  FI
	Frankreich 		  FRA  FR
	Deutschland 	  DEU  DE
	Großbritannien  GBR  GB
	Griechenland 	  GRC  GR
	Ungarn 			  HUN  HU
	Irland 			  IRL  IE
	Italien 			  ITA  IT
	Lettland 		  LVA  LV
	Litauen 			  LTU  LT
	Luxemburg 		  LUX  LU
	Malta 			  MLT  MT
	Niederlande 	  NLD  NL
	Polen 			  POL  PL
	Rumänien 		  ROU  RO
	Slowakei 		  SVK  SK
	Slowenien 		  SVN  SI
	Spanien 			  ESP  ES
	Schweden 		  SWE  SW
	Türkei 			  TUR  TR
	Portugal			  PRT  PT
	
	label variable country "German Country Names"
	label variable iso3166_2 "ISO 3166 2 Digit Codes"
	label variable iso3166_3 "ISO 3166 3 Digit Codes"
	
	//Generate eu_cntry (1-alt, 2-neu, 3-)
	
	generate eu  =  "EU-15"
	replace eu = "AC-10" if inlist(s_cntry,4,5,7,13,16,19,17,21,23,24)
	replace eu = "CC-3"  if inlist(s_cntry,3,22,27)

	label variable eu "EU/AC/CC"

	order s_cntry country iso3166_3 iso3166_2 eu
	
	save resultset0, replace
	
	exit
	 
	

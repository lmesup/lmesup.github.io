	// Aggregates from Jan Delhey
	// --------------------------

	use country hdi2002-eff_rel using agEB621_Ländervariablen.dta, clear


	// Staaten nach ISO 3166
	sort country
	input str2 iso3166_2 str3 iso3166_3 
	BE BEL 
	DK DNK 
	DE DEU 
	GR GRE 
	ES ESP 
	FI FIN 
	FR FRA 
	IE IRL 
	IT ITA 
	LU LUX   
	NL NLD    
	AT AUT 
	PT PRT 
	SE SWE 
	GB GBR 
	CY CYP 
	CZ CZE 
	EE EST 
	HU HUN 
	LV LVA 
	LT LTA  
	MT MLT 
	PL POL 
	SK SVK 
	SI SVN  


	drop country
	lab var iso3166_2 "Country"
	lab var iso3166_3 "Country"

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
	label define eu 0 "no Member" 1 "OMS-15" 2 "NMS-10" 3 "CC-3"
	label variable eu "EU-Membership"
	label variable ctrname "Country"
	
	compress
	sort iso3166_2
	tempfile names
	save `names'
	restore
	merge iso3166_2 using `names', nokeep
	assert _merge == 3
	drop _merge
	compress

	order ctrname iso3166_2 iso3166_3 eu 
	save agg, replace
	exit
	
	

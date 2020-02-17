// Redefine Response Rates
// =======================

// Note available for EB

// EQLS
// ----

clear
input str2 iso3166_2 gross backf
	AT  1948 .
	BE  1701 .
	BG  1345 .
	CY   738 .
	CZ  1625 .
	DE  1279 . 
	DK  2749 .
	EE  1091 .
	ES  3701 .
	FI  3221 .
	FR  1291 .
	GB  1439 .
	GR  2864 .
	HU  1397 .
	IE  4196 .
	IT  1857 .
	LT  1927 .
	LU  1422 .
	LV  1491 .
	MT   674 .
	NL  1866 .
	PL  1649 .
	PT  1886 .
	RO  2469 .
	SE  2042 . 
	SI  1005 .
	SK  2381 .
	TR  2840 .
end
gen survey = "EQLS 2003"

tempfile EQLS
save `EQLS'


// EVS
// ---

clear
input str2 iso3166_2 gross backf
	AT  1891 30
	BE  5226 16
	BG  1237  5
	BY     .  .    
	CZ  3590  .
	DE  3581 20
	DK  1803  5
	EE  2874 10
	ES  8228  5
	FI  1694  5
	FR     .  .
	GB     .  5
	GR  1400  .
	HR  1845  6
	HU  1446 10
	IS  1474  .
	IE  1746  .
	IT     . 20
	LT  1279 10  
	LU  1965 10
	LV  1549 15
	MT  1286  .
	NL  2829  .
	PL  1426  .
	PT  2501 24
	RO     . 10
	RU  3368 15
	SE  1875 20
	SI  1890 65
	SK  1400 15
	TR     . 25
	UA  1794  .
end
gen survey = "EVS 1999"

tempfile EVS
save `EVS'


// ISSP
// ----

clear
input str2 iso3166_2 gross backf
	AT 3203 15
	AU 2358  .
	BE 2064 60  
	BG 1153  3
	BR    . 20
	CH 3070 20       
	CL 1496 16
	CY 1400 10
	CZ 2234 30 
	DE 3205 95 
	DK 2082 10 
	ES 2492 10
	FI 2488  .
	FR 9597  . 
	GB 3758 10
	HU 1624 25
	IE 2097 10
	IL 3501 15
	JP 1682  .
	LV 1709 10
	MX 1806  5
	NO 2450  .
	NL 5050 10
	NZ 1777  .
	PL 1861 10
	PT 1980 20
	PH 2590 30  
	RU 5476 20
	SE 1889  .
	SI 1510 60
	SK    .  4
	TW 3657 30
	US 2079 20 
end
gen survey = "ISSP 2002"

tempfile ISSP
save `ISSP'


// ESS1
// ----

clear
input str2 iso3166_2 gross backf
	AT 3744 14
	BE 3300 76 
	CH 6157 22
	CZ 3286 42
	DE 5736 38
	DK 2243  0
	ES 3384 53 
	FI 2764  9
	FR 3580 20 
	GB 3709 68
	GR 3226 33 
	HU 2452 12
	IE 3178 17 
	IL 3520 34
	IT 2936 76
	LU 3692  .
	NL 3498 25
	NO 3163 17
	PL 2962  9
	PT 2222 64
	SE 2990  8
	SI 2207  .
end
gen survey = "ESS 2002"

tempfile ESS1
save `ESS1'


// ESS2
// ----

clear
input str2 iso3166_2 gross backf
	AT 3616 225
	BE 2990 304
	CH 4590   .    // <- set to missing
	CZ 5465 340
	DE 5739 990
	DK 2308   0
	EE 2826   0
	ES 3083 475
	FI 2892 197
	FR 4110 464
	GB 3717 203
	GR 3055 617
	HU 2172 160
	IE 3657 696
	IS 1160   0
	LU 3333  50
	NL 2918 500
	NO 2705 200
	PL 2374 278
	PT 2895 997
	SE 2967 150
	SI 2097 1442
	SK 2475 300
	UA 3050 196
end
gen survey = "ESS 2004"

tempfile ESS2
save `ESS2'

// Append/Merge to svydat02
// ------------------------

use `EQLS'
append using `ESS1'
append using `ESS2'
append using `EVS'
append using `ISSP'

sort survey iso3166_2
tempfile All
save `All'

use svydat02, clear
sort survey iso3166_2
merge survey iso3166_2 using `All'
assert _merge==3 if survey ~= "EB 62.1"
drop _merge

// Redefine Response-Rate
// ----------------------

by survey iso3166_2, sort: gen hresrate=_N/gross * 100
label variable hresrate "Harmonised Response Rate" 
label variable gross "Gross Sample"


// Redefine Back-Checks for ESS
// ----------------------------

by survey iso3166_2, sort: replace backf = backf/_N * 100 if survey == "ESS 2004"
label variable backf "Fraction of sample units selected for back checks" 
	

// Save Dataset
// ------------

drop resrate resratei
order survey-svymeth gross hresrate subst back backf
compress
save svydat03, replace


exit




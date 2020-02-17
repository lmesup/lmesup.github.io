* Repräsentativität (neuer Datensatz)
* luniak@wz-berlin.de

version 8.2

clear
set memory 80m
set more off

// EM
// --
use country v5 v6 v7 v18 v18_d v11* v24eq using $em/em, clear

// Umbennen und Generieren von Variablen 

gen paar = v5
replace paar = 0 if v5 ~= 2 & v5 < .
replace paar = 1 if v5 == 2

gen mar = v18 == 2 if v18 < . 		// married and living with spouse
replace mar = v18_d == 2 if country == 2

gen female = v7 == 0 if v7 <.

gen ort1 = v11_a
replace ort1 = 0 if v11_a >= 1 & v11_a <= 3
replace ort1 = 1 if v11_a >= 4 & v11_a <= 7

gen ort2 = v11_ch
replace ort2 = 0 if v11_ch >= 4 & v11_ch <= 8
replace ort2 = 1 if v11_ch >= 0 & v11_ch <= 3

gen ort3 = v11_d1
replace ort3 = 0 if v11_d1 >= 7 & v11_d1 <= 9
replace ort3 = 1 if v11_d1 >= 0 & v11_d1 <= 6

gen ort5 = v11_e
replace ort5 = 0 if v11_e >= 1 & v11_e <= 2
replace ort5 = 1 if v11_e >= 3 & v11_e <= 7

gen ort6 = v11_h
replace ort6 = 0 if v11_h >= 5 & v11_h <= 9
replace ort6 = 1 if v11_h >= 1 & v11_h <= 4

gen ort7 = v11_rok
replace ort7 = 0 if v11_rok == 3
replace ort7 = 1 if v11_rok >= 1 & v11_rok <= 2

gen ort8 = v11_s
replace ort8 = 0 if v11_s >= 10 & v11_s <= 30
replace ort8 = 1 if v11_s >= 40 & v11_s <= 60

gen ort9 = v11_slo
replace ort9 = 0 if v11_slo >= 5 & v11_slo <= 6
replace ort9 = 1 if v11_slo >= 1 & v11_slo <= 4

gen ort10 = v11_tr
replace ort10 = 0 if v11_tr == 2
replace ort10 = 1 if v11_tr == 1

egen stadt = rfirst(ort1 - ort10)
egen hinc = xtile(v24eq), p(25(25)75) by(country) 
gen source = "em"

// Staaten nach ISO 3166
preserve
clear
input country str2 iso3166_2 str3 iso3166_3
1	SI	SVN
2	DE	DEU
3	HU	HUN
4	ES	ESP
5	CH	CHE
6	SE	SWE	
7	AT	AUT
8	TR	TUR
9	KR	KOR
end
sort country
save 222, replace 

//Merge
restore
sort country
merge country using 222
drop _merge 
drop  v5 v6 v7 v11*  v18  v18_d  v24eq ort1-ort10 country 
tempfile em
save `em'

// EQLS
// ----
use s_cntry hh1 hh2a hh2b hh3a_2 hh3b_2 hh3c_2 q32 q55 q65 using $dublin/eqls_4, clear

// Umbennen und Generieren von Variablen 

gen paar = hh1 == 2 if hh1 <.

gen mar = hh3c_2 == 1 if hh3c_2 <.

gen female = hh2a	== 2 if hh2a <.
gen female2 = hh3a_2 == 2 if hh3a_2 <.

gen stadt = q55
replace stadt = 0 if q55 == 1 | q55 == 2   // Dorf
replace stadt = 1 if q55 == 3 | q55 == 4   // Stadt

gen age = hh2b
gen age2 = hh3b_2
keep if age2 > 18

egen hinc = xtile(q65), p(25(25)75) by(s_cntry) 

gen source  = "eqls"

// Staaten nach ISO 3166
preserve
clear
input s_cntry str2 iso3166_2 str3 iso3166_3
1	AT				AUT
2	BE				BEL
3	BG				BGR
4	CY				CYP
5	CZ				CZE
6	DK				DNK
7	EE				EST
8	FI				FIN
9	FR				FRA
10	DE				DEU
11	GB				GBR
12 	GR				GRC
13	HU				HUN
14	IE				IRL
15	IT				ITA
16	LV				LVA
17	LT				LTU
18	LU				LUX
19 	MT				MLT
20	NL				NLD
21	PL				POL
22	RO				ROU
23	SK				SVK
24	SI				SVN
25	ES				ESP
26	SE				SWE
27	TR				TUR
28	PT 				PRT
end
sort s_cntry
save 666, replace 

// Merge
restore
sort s_cntry
merge s_cntry using 666
drop _merge
drop s_cntry hh1 hh2a hh2b hh3b_2 hh3c_2 q32 q55 q65 hh3a_2
tempfile eqls
save `eqls'


// ESS
// ----
use cntry domicil hinctnt gndr gndr2 hhmmb lvgptn lvgoptn lvghw using $ess/ess2002, clear

// Umbennen und Generieren von Variablen 

gen paar = hhmmb == 2 if hhmmb <.

gen partner = ( lvgptn == 1) + ( lvgoptn == 1) + ( lvghw == 1)
gen mar = partner >0 if partner < .

gen female = gndr ==2
gen female2 = gndr2 ==2

gen stadt = domicil
replace stadt = 0 if domicil == 4 | domicil == 5
replace stadt = 1 if domicil == 1 | domicil == 2 | domicil == 3

egen hinc = xtile(hinctnt), p(25(25)75) by(cntry) 

gen source = "ess"

// Staaten nach ISO 3166
gen iso3166_2 = cntry
preserve
clear

input str2 cntry str3 iso3166_3
	AT	AUT
	BE	BEL
	CH	CHE
	CZ	CZE
	DE	DEU
	DK	DNK
	ES	ESP
	FI	FIN
	GB	GBR
	GR	GRC
	HU	HUN
	IE	IRL	
	IL	ISR	
	IT	ITA
	LU	LUX
	NL	NLD
	NO	NOR
	PL	POL	
	PT	PRT	
	SE	SWE	
	SI 	SVN
end
sort cntry
save 111, replace 

//Merge
restore
sort cntry
merge cntry using 111
drop _merge cntry  hhmmb  gndr  gndr2  domicil  hinctnt  lvghw lvgptn lvgoptn partner
tempfile ess
save `ess'

// EVS
// -----
use v299 v291 v294 v320 v322 country using $evs/evs1999, clear

// Umbennen und Generieren von Variablen 

gen paar = v299 == 2 if v299 <.

gen mar = v294 == 1 if v294 <.

gen female = v291 == 2 if v291<.

gen stadt = v322
replace stadt = 0 if v322 >=1 & v322 <= 4
replace stadt = 1 if v322 >=5 & v322 <= 8

egen hinc = xtile(v320), p(25(25)75) by(country) 

gen source = "evs"


// Staaten nach ISO 3166
preserve
clear
input country str19 iso3166_2 str20 iso3166_3
1	FR				FRA
2	GB				GBR
3	DE				DEU
5	AT				AUT
6	IT				ITA
7	ES				ESP
8	PT 				PRT
9	NL				NLD
10	BE				BEL
11	DK				DNK
13	SE				SWE
14	FI				FIN
15	IS				ISL
16	"GB (Northern Ireland)"	"GBR (NorthernIreland)"
17	IE				IRL
18	EE				EST
19	LV				LVA
20	LT				LTU
21	PL				POL
22	CZ				CZE
23	SK				SVK
24	HU				HUN
25	RO				ROU
26	BG				BGR
27	HR				HRV
28 	GR				GRC
29	RU				RUS
32	MT				MLT
33	LU				LUX
34	SI				SVN
35	UA				UKR
36	BY				BLR
44	TR				TUR
end
sort country
save 333, replace 

//Merge
restore
sort country
merge country using 333
drop country  v291  v294  v299  v320  v322 _merge
tempfile evs
save `evs'

// ISSP
// -----
use v253 v202 v3 v200 v203 v254 v216 using $issp/issp98, clear

// Umbennen und Generieren von Variablen 

gen paar = v253 == 5 if v253 <.

gen mar = v202 == 1 if v202 != 0 
replace mar = 0 if inlist(v203, 2,9,.)

gen female = v200 == 2 if v200 < 9

gen stadt = v254
replace stadt = 0 if v254 == 3
replace stadt = 1 if v254 == 1 | v254 == 2
replace stadt = . if v254 == 9 | v254 == 0

egen hinc = xtile(v216), p(25(25)75) by(v3) 
gen source = "issp"

// Staaten nach ISO 3166
preserve
clear
input v3 str19 iso3166_2 str20 iso3166_3
1	AZ				AZE
2	"DE (W)"			"DEU (W)"
3	"DE (E)"			"DEU (E)"
4	GB				GBR
5	"GB (Northern Ireland)"	"GBR (NorthernIreland)"
6	US				USA
7	AT				AUT
8	HU				HUN
9	IT				ITA
10	IE				IRL
11	NL				NLD
12	NO				NOR
13	SE				SWE
14	CZ				CZE
15	SI				SVN
16	PL				POL
17	BG				BGR
18	RU				RUS
19	NZ				NZL
20	CA				CAN
21	PH				PHL
22	IL				ISR
24	JP				JPN
25	ES				ESP
26	LV				LVA
27	SK				SVK
28	FR				FRA
29	CY				CYP
30	PT 				PRT
31	CL				CHL
32	DK				DNK
33	CH				CHE
end
sort v3
save 555, replace 

//Merge
restore
sort v3
merge v3 using 555
drop _merge  v3  v200  v202 v203  v216  v253  v254 
tempfile issp
save `issp'

// Zusammenführung aller Datensätze
// --------------------------------
use `issp'
append using `em'
append using `eqls'
append using `ess'
append using `evs'

label variable paar "2 Personen im Haushalt y/n"
label variable mar "Ehepaare oder Partner, die zusammenleben y/n"
label variable source "Survey"
label variable iso3166_2 "Land"
label variable female "Frau y/n"
label variable stadt "Stadtbewohner y/n"
label variable female2 "2.Person: Frau y/n"
label variable age "Alter"
label variable age2 "2.Person: Alter"

save alldat, replace 




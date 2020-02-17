* Repräsentativität (Anteil der Frauen - weiche und harte Analyse)
* luniak@wz-berlin.de

version 8.2

clear
set memory 80m
set more off


//Euromodul
// --------
use country v5 v6 v3 v7 v18 v18_d using $em/em

// Haushaltgroesse: 2 Erwachsene ueber 18
keep if v5 == 2 & v6 == 0

// Nur Ehepaare, die zusammenleben
keep if v18 == 2

// Crosstab country sex 
tab  country v7, nof row

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

tempfile 222
save `222', replace 

// Merge mit ISO
restore
sort country
merge country using `222'

//dummyvariable female
gen female = v7 == 0 if v7<.

// neuer Datensatz (Anteil der Frauen)
collapse (mean) fem_em_w = female, by (iso3166_2)
sort iso3166_2
tempfile em_w
save `em_w'

// EQLS weich
// -------------

use s_cntry hh1 hh2a hh2b hh3b_2 hh3c_2 q32 using $dublin/eqls_4, clear
// Haushaltgroesse: 2 Erwachsene (ueber 18)
keep if hh1 == 2 & hh3b_2>=18

// verheiratet oder mit Partner zusammenlebend
keep if hh3c_2 == 1

//Crosstab country sex 
tab s_cntry hh2a, nof row

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

tempfile 666
save `666', replace 

// Merge mit ISO
restore
sort s_cntry
merge s_cntry using `666'

// dummyvariable female
gen female = hh2a == 2 if hh2a <.

// neuer Datensatz (Anteil der Frauen)
collapse (mean) fem_eqls_w = female, by (iso3166_2)
sort iso3166_2
tempfile eqls_w
save `eqls_w'

//EQLS hart
// ---------
use s_cntry hh1 q32 hh2a hh3a_2 using $dublin/eqls_4, clear

//Haushaltgroesse
keep if hh1 == 2

// verheiratet oder mit Partner zusammenlebend
keep if q32 == 1

// Heterosexualle Paare
keep if hh2a ~= hh3a_2
tab  s_cntry  hh2a, nof row

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

tempfile 777
save `777', replace 

//Merge
restore
sort s_cntry
merge s_cntry using `777'

// dummyvariable female
gen female = hh2a == 2 if hh2a <.

// neuer Datensatz (Anteil der Frauen)
collapse (mean) fem_eqls_h = female, by (iso3166_2)
sort iso3166_2
tempfile eqls_h
save `eqls_h'

//ESS hart
// -------
use cntry gndr gndr2 hhmmb lvgptn lvgoptn lvghw using $ess/ess2002, clear

// Haushaltgroesse
keep if hhmmb == 2

// Widersprueche fuer "Partner - Variablen"
gen partner = ( lvgptn == 1) + ( lvgoptn == 1) + ( lvghw == 1)
capture assert partner <= 1  
keep if partner > 0 // Nur Ehepaare oder Partner, die zusammenleben

//Heterosexualle Paare
keep if gndr ~= gndr2

//Crosstab country sex 
tab  cntry  gndr, nof row

// Staaten nach ISO 3166
// 2 stellig
gen iso3166_2 = cntry
// 3 stellig
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

tempfile 111
save `111', replace 

//Merge
restore
sort cntry
merge cntry using `111'

// dummyvariable female
gen female = gndr == 2 if gndr <.

//neuer Datensatz (Anteil der Frauen)
collapse (mean) fem_ess_h = female, by (iso3166_2)
sort iso3166_2
tempfile ess_h
save `ess_h'

// ESS weich
// ----------
use cntry gndr hhmmb lvghw using $ess/ess2002, clear

// Haushaltgroesse: 2 
keep if hhmmb == 2

// Nur Ehepaare, die zusammenleben
keep if lvghw == 1

//Crosstab country sex 
tab cntry gndr, nof row

// Staaten nach ISO 3166
// 2 stellig
gen iso3166_2 = cntry
// 3 stellig
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

tempfile 888
save `888', replace 

//Merge
restore
sort cntry
merge cntry using `888'

//dummyvariable female
gen female = gndr == 2 if gndr <.

//neuer Datensatz (Anteil der Frauen)
collapse (mean) fem_ess_w = female, by (iso3166_2)
sort iso3166_2
tempfile ess_w
save `ess_w'

//EVS
//----
use v299 v291 v294 country using $evs/evs1999, clear

//Haushaltgroesse: 2 Erwachsene
keep if v299 == 2

//Die Verheirateten
keep if v294 == 1
//Crosstab country sex 
tab  country  v291, nof row

//Staaten nach ISO 3166
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
28	GR				GRC
29	RU				RUS
32	MT				MLT
33	LU				LUX
34	SI				SVN
35	UA				UKR
36	BY				BLR
44	TR				TUR
end
sort country

tempfile 333
save `333', replace 

//Merge
restore
sort country
merge country using `333'
//dummyvariable female
gen female = v291 == 2 if v291 <.

//neuer Datensatz (Anteil der Frauen)
collapse (mean) fem_evs_w = female, by (iso3166_2)
sort iso3166_2
tempfile evs_w
save `evs_w'

//ISSP
// -----
use v253 v202 v203 v3 v200 using $issp/issp98, clear
// Haushaltgroesse: 2 Erwachsene
keep if v253 == 5

// Die Verheirateten mit festem Partner
gen mar = v202 == 1 if v202 != 0 
replace mar = 0 if inlist(v203, 2,9,.)
drop if mar == 0
drop mar

//Crosstab country sex 
tab  v3 v200, nof row


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

tempfile 555
save `555', replace 


//Merge
restore
sort v3
merge v3 using `555'

// dummyvariable female
gen female = v200 == 2 if v200 <.

// neuer Datensatz
collapse (mean) fem_issp_w = female, by (iso3166_2)
sort iso3166_2
tempfile issp_w
save `issp_w'

//Merge aller Datensätze
// ----------------------
use `issp_w'
merge iso3166_2 using `evs_w' `ess_w' `ess_h' `eqls_h' `eqls_w' `em_w'
drop _merge*

//Ausgabe und Speichern
format fem_issp - fem_em_w %5.4f
sort iso3166_2
*Anteil der Frauen
list iso3166_2 fem_ess_h fem_eqls_h fem_ess_w fem_eqls_w ///
fem_evs_w fem_issp_w fem_em_w, sep(0) mean N clean
save resultset1, replace 


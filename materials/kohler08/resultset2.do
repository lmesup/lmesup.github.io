* Repräsentativität (Anteil der Frauen, SE, Konfidenzintervall, Ranking)
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

// Standardfehler der Geschlechterverteilung für einzelne Länder
tempfile mypost1
tempname saemw
postfile `saemw' str2 iso3166_2 sa_emw using `mypost1'
levels iso3166_2, local(K)
foreach k of local K {
	ci female if iso3166_2 == "`k'"
	post `saemw' ("`k'") (r(se))
}
postclose `saemw'


// EQLS weich
// -------------

use s_cntry hh1 hh2a hh2b hh3b_2 hh3c_2 q32 using $dublin/eqls_4, clear
// Haushaltgroesse: 2 Erwachsene (ueber 18)
keep if hh1 == 2 & hh3b_2>=18

// Nur Ehepaare oder Partner, die zusammenleben
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

// Standardfehler der Geschlechterverteilung für einzelne Länder
tempfile mypost2
tempname saeqlsw
postfile `saeqlsw' str2 iso3166_2 sa_eqlsw using `mypost2'
levels iso3166_2, local(K)
foreach k of local K {
	ci female if iso3166_2 == "`k'"
	post `saeqlsw' ("`k'") (r(se))
}
postclose `saeqlsw'

//EQLS hart
// ---------
use s_cntry hh1 q32 hh2a hh3a_2 hh3c_2 using $dublin/eqls_4, clear

//Haushaltgroesse
keep if hh1 == 2

// verheiratet oder mit Partner zusammenlebend
keep if hh3c_2 == 1

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

// Standardfehler der Geschlechterverteilung für einzelne Länder
tempfile mypost3
tempname saeqlsh
postfile `saeqlsh' str2 iso3166_2 sa_eqlsh using `mypost3'
levels iso3166_2, local(K)
foreach k of local K {
	ci female if iso3166_2 == "`k'"
	post `saeqlsh' ("`k'") (r(se))
}
postclose `saeqlsh'


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

// Standardfehler der Geschlechterverteilung für einzelne Länder
tempfile mypost4
tempname saessh
postfile `saessh' str2 iso3166_2 sa_essh using `mypost4'
levels iso3166_2, local(K)
foreach k of local K {
	ci female if iso3166_2 == "`k'"
	post `saessh' ("`k'") (r(se))
}
postclose `saessh'


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

// Standardfehler der Geschlechterverteilung für einzelne Länder
tempfile mypost5
tempname saessw
postfile `saessw' str2 iso3166_2 sa_essw using `mypost5'
levels iso3166_2, local(K)
foreach k of local K {
	ci female if iso3166_2 == "`k'"
	post `saessw' ("`k'") (r(se))
}
postclose `saessw'


//EVS
//----
use v299 v291 v296 v294 country using $evs/evs1999, clear

//Haushaltgroesse: 2 Erwachsene
keep if v299 == 2

//Die Verheiratetet mit festem Partner 
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

// Standardfehler der Geschlechterverteilung für einzelne Länder
tempfile mypost6
tempname saevsw
postfile `saevsw' str19 iso3166_2 sa_evsw using `mypost6'
levels iso3166_2, local(K)
foreach k of local K {
	ci female if iso3166_2 == "`k'"
	post `saevsw' ("`k'") (r(se))
}
postclose `saevsw'

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

//Standardfehler der Geschlechterverteilung für einzelne Länder
tempfile mypost7
tempname saisspw

postfile `saisspw' str19 iso3166_2 sa_eisspw using `mypost7'

levels iso3166_2, local(K)

foreach k of local K {
	ci female if iso3166_2 == "`k'"
	post `saisspw' ("`k'") (r(se))
}
postclose `saisspw'

//Zusammenführung aller Datensätze
// --------------------------------
//sortieren
forv i = 1/7 {
	use `mypost`i'', clear
	sort iso3166_2
	save, replace
}
//Merge
use `mypost1'
merge iso3166_2 using `mypost2' `mypost3' `mypost4' `mypost5' `mypost6' `mypost7'
drop _merge*
sort iso3166_2
merge iso3166_2 using resultset1

//Ausgabe und Speichern
list iso3166_2 fem_ess_h   sa_essh fem_eqls_h  sa_eqlsh fem_ess_w  sa_essw fem_eqls_w   sa_eqlsw fem_evs_w   sa_evsw fem_issp_w  sa_eisspw fem_em_w  sa_emw, sep(0) mean N  
save resultset2, replace 


//Ranking anhand der Abweichung der empirischen Mittelwert vom 0,5 
// ----------------------------------------------------------------
reshape long fem, i(iso3166_2) j(type) string

// variable weich
gen weich = 1
replace weich = 0 if type == "_eqls_h" | type == "_ess_h" 

// Der Abstand 
gen abs = abs(fem - 0.5)
sort iso3166_2 weich abs

//Variable best - der beste Datensatz
by iso3166_2 (weich abs): gen besth = type[1] if abs[2] < . 
by iso3166_2 (weich abs): gen bestw = type[3] if abs[4] < . 
drop _merge weich abs
reshape wide

//Umbennenen
rename fem_em_w fememw
rename fem_eqls_h femeqlsh
rename fem_ess_h femessh
rename fem_eqls_w femeqlsw
rename fem_ess_w femessw
rename fem_evs_w femevsw
rename fem_issp_w femisspw

rename sa_emw sabemw
rename sa_eqlsh sabeqlsh
rename sa_essh sabessh
rename sa_eqlsw sabeqlsw
rename sa_essw sabessw
rename sa_evsw sabevsw
rename sa_eisspw sabisspw

//Ausgabe der mittelwerte, der SE und des besten Datensatzes
//-----------------------------------------------------------
reshape long fem sab, i(iso3166_2) j(type2) string
list

// 2 schlechte Graphiken 
// -----------------------

//Konfidenzinterval
gen ub = fem + 1.97*sab
gen lb = fem - 1.97*sab

// Type als numerische Variable
encode type2 if type2=="eqlsh" | type2 == "essh", gen(surveyh)
encode type2 if type2 ~="eqlsh" & type2 ~= "essh", gen(surveyw)

drop if fem >=.
by iso3166_2, sort: drop if _N ==1

// Variable weich
gen weich = 1
replace weich = 0 if type == "eqlsh" | type == "essh" 

preserve
keep if surveyh < .


//1.Graphik
graph dot (asis) fem ub lb ///
 , over(iso3166_2, sort(fem)) by(surveyh) nofill ///
   yline(0.5)

//2.Graphik
tw ///
 (scatter fem surveyh) ///
 (rcap ub lb surveyh) ///
  , by(iso3166_2) yline(0.5) xlabel(1(1)2, valuelabel)


// Die Vergabe der Labels
// ----------------------

label variable iso3166_2 "Land"
label variable type2 "Survey" 
label variable fem "Anteil der Frauen"
label variable sab "Standardfehler"
label variable besth "Bester Datensatz bezüglich harter Kriterien"
label variable bestw "Bester Datensatz bezüglich weicher Kriterien"
label variable lb "Untere Grenze des Konfidenzintervals"
label variable ub "Oberere Grenze des Konfidenzintervals"
label variable weich "Art der Analyse"
label define yesno 0 "nein" 1 "ja"
label values weich yesno

save resultset2, replace

exit

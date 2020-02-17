* Repräsentativität (Wahrscheinlichkeit des Ergebnisses unter der Annahme,
* dass der Anteil der Frauen 50% beträgt)
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

tempfile 2
save `2' 

//Merge
restore
sort country
merge country using `2'

// Wahrscheinlichkeit des Ergebnisses
tempfile binom1
postfile biemw str19 iso3166_2 pemw using `binom1'
levels iso3166_2, local(K)
foreach k of local K {
	quietly {
		count if v7 < . & iso3166_2 == "`k'"
		local freq = r(N)
		count if v7 == 0 & iso3166_2 == "`k'"
		local fefreq = r(N)
		local pemw = Binomial(`freq',`fefreq',.5) - Binomial(`freq',`fefreq'+1,.5)
		post biemw ("`k'") (`pemw')
	}	
}
postclose biemw

// EQLS weich
// -------------

use s_cntry hh1 hh2a hh2b hh3b_2 hh3c_2 q32 using $dublin/eqls_4, clear
// Haushaltgroesse: 2 Erwachsene (ueber 18)
keep if hh1 == 2 & hh3b_2>=18

// verheiratet oder mit Partner zusammenlebend
keep if hh3c_2 == 1

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
tempfile 6
save `6' 

//Merge
restore
sort s_cntry
merge s_cntry using `6'

// Wahrscheinlichkeit des Ergebnisses
tempfile binom2
postfile bieqlsw str19 iso3166_2 peqlsw using `binom2'
levels iso3166_2, local(K)
foreach k of local K {
	quietly {
		count if hh2a < . & iso3166_2 == "`k'"
		local freq = r(N)
		count if hh2a == 2 & iso3166_2 == "`k'"
		local fefreq = r(N)
		local peqlsw = Binomial(`freq',`fefreq',.5) - Binomial(`freq',`fefreq'+1,.5)
		post bieqlsw ("`k'") (`peqlsw')
	}	
}

postclose bieqlsw

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
tempfile 7
save `7' 

//Merge
restore
sort s_cntry
merge s_cntry using `7'

// Wahrscheinlichkeit des Ergebnisses
tempfile binom3
postfile bieqlsh str19 iso3166_2 peqlsh using `binom3'
levels iso3166_2, local(K)
foreach k of local K {
	quietly {
		count if hh2a < . & iso3166_2 == "`k'"
		local freq = r(N)
		count if hh2a == 2 & iso3166_2 == "`k'"
		local fefreq = r(N)
		local peqlsh = Binomial(`freq',`fefreq',.5) - Binomial(`freq',`fefreq'+1,.5)
		post bieqlsh ("`k'") (`peqlsh')
	}	
}
postclose bieqlsh

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
tempfile 1
save `1' 

//Merge
restore
sort cntry
merge cntry using `1'

// Wahrscheinlichkeit des Ergebnisses
tempfile binom4
postfile biessh str19 iso3166_2 pessh using `binom4'
levels iso3166_2, local(K)
foreach k of local K {
	quietly {
		count if gndr < . & iso3166_2 == "`k'"
		local freq = r(N)
		count if gndr == 2 & iso3166_2 == "`k'"
		local fefreq = r(N)
		local pessh = Binomial(`freq',`fefreq',.5) - Binomial(`freq',`fefreq'+1,.5)
		post biessh ("`k'") (`pessh')
	}	
}
postclose biessh

// ESS weich
// ----------
use cntry gndr hhmmb lvghw using $ess/ess2002, clear

// Haushaltgroesse: 2 
keep if hhmmb == 2

// Nur Ehepaare, die zusammenleben
keep if lvghw == 1

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
tempfile 8
save `8' 

//Merge
restore
sort cntry
merge cntry using `8'


// Wahrscheinlichkeit des Ergebnisses
tempfile binom5
postfile biessw str19 iso3166_2 pessw using `binom5'
levels iso3166_2, local(K)
foreach k of local K {
	quietly {
		count if gndr < . & iso3166_2 == "`k'"
		local freq = r(N)
		count if gndr == 2 & iso3166_2 == "`k'"
		local fefreq = r(N)
		local pessw = Binomial(`freq',`fefreq',.5) - Binomial(`freq',`fefreq'+1,.5)
		post biessw ("`k'") (`pessw')
	}	
}
postclose biessw


//EVS
//----
use v299 v291 v294 country using $evs/evs1999, clear

//Haushaltgroesse: 2 Erwachsene
keep if v299 == 2

//Verheiratet mit festem Partner
keep if v294 == 1

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
tempfile 3
save `3' 

//Merge
restore
sort country
merge country using `3'

// Wahrscheinlichkeit des Ergebnisses
tempfile binom6
postfile bievsw str19 iso3166_2 pevsw using `binom6'
levels iso3166_2, local(K)
foreach k of local K {
	quietly {
		count if v291 < . & iso3166_2 == "`k'"
		local freq = r(N)
		count if v291 == 2 & iso3166_2 == "`k'"
		local fefreq = r(N)
		local pevsw = Binomial(`freq',`fefreq',.5) - Binomial(`freq',`fefreq'+1,.5)
		post bievsw ("`k'") (`pevsw')
	}	
}
postclose bievsw

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
tempfile 5
save `5' 

//Merge
restore
sort v3
merge v3 using `5'

// Wahrscheinlichkeit des Ergebnisses
tempfile binom7
postfile biisspw str19 iso3166_2 pisspw using `binom7'
levels iso3166_2, local(K)
foreach k of local K {
	quietly {
		count if v200 < . & iso3166_2 == "`k'"
		local freq = r(N)
		count if v200 == 2 & iso3166_2 == "`k'"
		local fefreq = r(N)
		local pisspw = Binomial(`freq',`fefreq',.5) - Binomial(`freq',`fefreq'+1,.5)
		post biisspw ("`k'") (`pisspw')
	}	
}
postclose biisspw

//Zusammenführung aller Datensätze
// --------------------------------

//sortieren
forv i = 1/7 {
	use `binom`i'', clear
	sort iso3166_2
	save, replace
}

//Merge
use `binom1'
merge iso3166_2 using `binom2' `binom3' `binom4' `binom5' `binom6' `binom7'
drop _merge*
sort iso3166_2
merge iso3166_2 using resultset1
drop _merge

//Ausgabe und Speichern
list  iso3166_2  pemw  peqlsw  peqlsh  pessh  pessw  pevsw  pisspw
save resultset3, replace 


//Ranking anhand des Wahrscheinlichkeitswertes
// --------------------------------------------

reshape long p, i(iso3166_2) j(type) string

// Variable weich-hart
gen weich = 1
replace weich = 0 if type == "eqlsh" | type == "essh" 

//Variable best - der beste Datensatz
sort iso3166_2 weich p
by iso3166_2 (weich p): gen pbesth = type[1] if p[2] < . 
by iso3166_2 (weich p): gen pbestw = type[3] if p[4] < . 

// Die Vergabe der Labels
// ----------------------

label variable iso3166_2 "Land"
label variable type "Survey" 
label variable p "Wahrscheinlichkeit des Ergebnisses"
label variable pbesth "Bester Datensatz bezüglich harter Kriterien"
label variable pbestw "Bester Datensatz bezüglich weicher Kriterien"
label variable weich "Art der Analyse"
label define yesno 0 "nein" 1 "ja"
label values weich yesno


//Ausgabe des Ergebnisses
list

save resultset3, replace



exit



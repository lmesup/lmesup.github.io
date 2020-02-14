/* Thewes (2018): Prepare elections
----------------------------------------------------------------------------
- Create different macro-files on municipality-level. Will be merged to
  S21-voting-results and to individual data for prediction-model.

Files:
- makro.dta:  basic information: sex, education, religion,...
              Source: xlsx_Bevoelkerung.xlsx: Zensus Mai 2011
              2011JZ-gem21_d_0.xls: Bundesagentur für Arbeit
- area.dta:   area, population, population-density
              Source: 31122015_Auszug_GV.xls: Destatis - Gemeindeverzeichnis
- unemp.dta:  unemployment
              Source: 2011JZ-gem21_d_0.xls: Bundesagentur für Arbeit 2011:
              Arbeitsmarkt in Zahlen - Arbeitsmarktstatistik - Arbeitslose nach Gemeinden - 2011
- age.dta:    age
              Source: TABELLE_2F.xls: Zensus Mai 2011:
              Bevölkerung nach Alter in Jahren und Geschlecht für Gemeinden
- hhsize.dta: size of household
              Source: xlsx_HaushalteFamilien.xlsx: Zensus Mai 2011: Haushalte und Familien
- plz.dta:    Prepare ZIP-codes
              Source: 31122015_Auszug_GV.xls: Destatis - Gemeindeverzeichnis
----------------------------------------------------------------------------
*/ 

import excel using "data/makro/xlsx_Bevoelkerung.xlsx", sheet(Bevölkerung) cellrange(A9:HO12553) clear

// CLEANING

ren A RS

destring RS, replace
format RS %14.0g 

keep if inrange(RS,80000000000,89999999999) | inrange(RS,8000,8999)

gen kreis = inrange(RS,8000,8999)

drop B-F H J M N O Q R T U W X Z AA-DB DE-DI DL-DP DT DW-EW EY EZ FB FC FE-FM FS FW FX-GX GZ HA HD HE HH-HO

destring I-HG, replace force

ren G  s_ort
ren I  pop
ren K  male
ren L  female
ren P  fam_single
ren S  fam_married
ren V  fam_widowed
ren Y  fam_seperated
ren DC nat_de
ren DD nat_foreign
ren DJ born_de
ren DK born_foreign
ren DQ rel_rk
ren DR rel_eva
ren DS rel_other		// Other AND no answer!
ren DU mig_no
ren DV mig_yes
ren EX emp_yes
ren FA emp_no
ren FD emp_noemp
ren FN isco_fuehrung
ren FO isco_akad
ren FP isco_techn
ren FQ isco_buero
ren FR isco_dienstl
ren FT isco_handwerk
ren FU isco_montage
ren FV isco_hilfs
ren GY edu_ohne
ren HB edu_haupt
ren HC edu_mitt
ren HF edu_fh
ren HG edu_abi

replace edu_abi = edu_abi + edu_fh
drop edu_fh

* generate proportion males
* -------------------------
egen sextotal = rowtotal(male female)

replace male = male /sextotal
drop female sextotal



* generate proportions 
* --------------------

foreach y in fam nat born rel mig emp isco edu {
	egen `y'total = rowtotal(`y'_*)

	foreach x of varlist `y'_* {
		replace `x' = `x' / `y'total
	}

	drop `y'total
}

tostring RS, replace u force

replace RS = "0" + RS

lab var pop "Population"


* Fix for Seekirch (0 seperated = missing in data!)
* -------------------------------------------------

replace fam_seperated = 0 if RS == "084265001109"


* Assign "Kreisebene" to "Gemeindeebene for edu
* ---------------------------------------------
replace kreis = kreis + kreis[_n-1] if _n!=1

gen _markimp = edu_abi == .

foreach var of varlist edu_* {
	bysort kreis (RS): replace `var' = `var'[1] if `var' == .
}

drop if strlen(RS)  < 10

// prepare for merge with Faas-Data:
// ---------------------------------

replace s_ort = "Malsch, Kr Karlsruhe" if RS =="082150046046"
replace s_ort = "Talheim-b" if RS =="083275005048"
replace s_ort = subinstr(s_ort,", Stadt","",1)
replace s_ort = "Altdorf2" if RS == "081155004002"
replace s_ort = "Altheim2" if RS == "084255001004"
replace s_ort = "Dürnau2" if RS == "084265001036"
replace s_ort = "Hochdorf2" if RS == "081165007027"
replace s_ort = "Rosenberg2" if RS == "081365003060"
replace s_ort = "Schömberg2" if RS == "082350065065"

save "data/makro", replace



* Area
* ----

import excel using "data/makro/31122015_Auszug_GV.xls", sheet("Onlineprodukt_Gemeinden_311215") cellrange(C7082:N8705) clear

gen RS = C + D + E + F + G
destring RS, gen(GKZ)
format GKZ %14.0g
order GKZ, first
drop C D E F G K L

drop if GKZ < 99999999

ren H s_ort
ren I area
ren J pop
ren M popdens
ren N PLZ

// prepare for merge with Faas-Data:
// ---------------------------------

replace s_ort = subinstr(s_ort,", Stadt","",1)
replace s_ort = "Malsch, Kr Karlsruhe" if GKZ == 82150046046
replace s_ort = "Talheim-b" if GKZ == 83275005048
replace s_ort = "Altdorf2" if GKZ == 81155004002
replace s_ort = "Altheim2" if GKZ == 84255001004
replace s_ort = "Dürnau2" if GKZ == 84265001036
replace s_ort = "Hochdorf2" if GKZ == 81165007027
replace s_ort = "Rosenberg2" if GKZ == 81365003060
replace s_ort = "Schömberg2" if GKZ == 82350065065


save "data/area", replace


* Unemployment
* ------------


import excel using "data/makro/2011JZ-gem21_d_0.xls", sheet(6) cellrange(A5382:C6520) clear

ren A GKZ
destring GKZ, replace
format GKZ %14.0g

keep if GKZ >= 8111000

ren C unemp_abs

lab var unemp_abs "Arbeitslose"

save "data/unemp", replace


// Age
// ---
// Source: http://www.statistik.baden-wuerttemberg.de/wahlen/Bundestagswahl_2013/CSV.asp

import excel using "data/makro/TABELLE_2F.xls", sheet(Tabelle_2F) cellrange(A10:DA16350) clear

// CLEANING

drop in 2
keep if A == "60" | A == ""
drop A C D

replace E = "0" if E == "unter 1"
replace DA = "100" if DA == "100 und älter"

destring B, replace
format B %14.0g 

keep if inrange(B,80000000000,89999999999) | B == .

ren B GKZ

// RENAME VAR-NAMES
local i 0
foreach x of varlist E-DA {
	ren `x' persons`i' 
	local i = `i'+1
} 
drop in 1 


// RESHAPE
reshape long persons , i(GKZ) j(age)
destring persons, replace
bysort GKZ: egen total = sum(persons)

// MEAN
gen agepers = age * persons
bysort GKZ: egen totalap = sum(agepers)

gen age_mean = totalap / total

// AGE 25-55
bysort GKZ: egen pop25_55 = sum(persons) if inrange(age,25,55)


// SD
gen sd = sqrt((age - age_mean)^2) * persons

bysort GKZ: egen age_sd = sum(sd)

replace age_sd = age_sd / total


collapse (mean) age_mean (mean) age_sd (mean) pop25_55, by(GKZ)


// CONVERT TO RS (=its not GKZ, its RS-var)


tostring GKZ, gen(RS) u force

replace RS = "0" + RS

ren age_mean age
lab var age "Age Mean"
lab var age_sd "Age SD"
lab var pop25_55 "Population Age 25-55"

gen age2 = age^2
save "data/age", replace


// Size of household 
// -----------------
import excel using "data/makro/xlsx_HaushalteFamilien.xlsx", sheet(Haushalte, Familien) cellrange(A10:AC12553) clear

keep A W-AC

ren A GKZ

destring GKZ, replace
format GKZ %14.0g 

keep if inrange(GKZ,80000000000,89999999999)

destring W-AC, replace force
foreach var of varlist W-AC {
	replace `var' = 0 if `var' == .
}

ren W total

gen h6 = AB + AC
drop AB AC

ren X h1
ren Y h2
ren Z h3
ren AA h4

gen hhsize = (h1*1 + h2*2 + h3*3 + h4*4 + h6*6) / total

drop total h?

// CONVERT TO RS (=its not GKZ, its RS-var)
tostring GKZ, gen(RS) u force
replace RS = "0" + RS

drop GKZ

save "data/hhsize", replace



// Prepare PLZ
// -----------
// Source: https://www.destatis.de/DE/ZahlenFakten/LaenderRegionen/Regionales/Gemeindeverzeichnis/Gemeindeverzeichnis.html

import excel using "data/makro/AuszugGV3QAktuell.xls", sheet(Onlineprodukt_Gemeinden_300916) cellrange(C7085:P8705) clear

gen str GKZ = C + D + E + G
ren P PLZ

keep if G != ""

destring GKZ, replace
destring PLZ, replace

gen baden = inrange(PLZ,68000,69999) | inrange(PLZ,76000,77999) | inrange(PLZ,78000,78499) | inrange(PLZ,79000,79999)
replace baden = 1 if inlist(PLZ,74931,74939,74909,74937,74927,74918,74889,74933,74915,74924,74921,74939,74925,74934)
replace baden = 1 if inlist(PLZ,74867,74869,74858,74862,74847,74928,74855,74865,74821,74842,74834,74864)
replace baden = 1 if inlist(PLZ,74838,74722,74743,74850,74255,74740,74706,74749,74744,74736,74746,74731)
replace baden = 1 if inlist(PLZ,97944,97922,97953,97957,97947,97941,97950,97900,97877,97896,97956)
replace baden = 1 if inlist(PLZ,75181,75175,75180,75173,75712,75177,75179,75217,75210,75228,75239,75236)	
replace baden = 1 if inlist(PLZ,75196,75203,75245,75015,75053,75045)
replace baden = 1 if inlist(PLZ,88605,88637,88631,72477,72510,78580,78597,78567,78579,88636,88630,88356)
replace baden = 1 if inlist(PLZ,88696,88633,88699,88662,88682,88693,88677,88697,88709,88690,88718,88719)
gen ulm = inrange(PLZ,89000,89999) | inrange(PLZ,88470,88499)

gen stuttgart = GKZ == 8111000

keep baden ulm stuttgart PLZ GKZ 

save "data/plz", replace

exit

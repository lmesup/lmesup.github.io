/* Thewes (2018): Prepare micro-data
----------------------------------------------------------------------------
- Prepare 4 different surveys for Yn-prediciton in 02cr_hat.do
- 01an_reg_diag.do will be executed automatically

Files:
- faas.dta: (Model 1) (no public access)
  Prof. Dr. Thorsten Faas, Prof. Dr. Rüdiger Schmitt-Beck
  Wahlstudie Baden-Württemberg, Universität Mannheim 
- gab.dta: (Model 2) (no public access)
  Prof. Dr. Oscar Gabriel CATI-Befragung vor und nach der Volksabstimmung über 
  das Stuttgart 21-Kündigungsgesetz 
- za5625.dta: (Model 3)
  Forschungsgruppe Wahlen, Mannheim (2012): Landtagswahl in Baden-Württemberg 2011. 
  GESIS Datenarchiv, Köln. ZA5625 Datenfile Version 1.0.0, doi:10.4232/1.11453
- za5592.dta: (Model 4)
  Wagschal, Uwe; Finkbeiner, Sören (2014): Repräsentative Vorwahlumfrage zur 
  Landtagswahl 2011 in Baden-Württemberg. GESIS Datenarchiv, Köln. ZA5592 
  Datenfile Version 1.0.0, doi:10.4232/1.12004
----------------------------------------------------------------------------
*/ 

// Prepare mikro-data from Faas
// ----------------------------
use "data/faas/Volksabstimmung Stuttgart 21 - CATI NW", clear
sort identity
gen serialid=_n
keep serialid s_stichprobe s_region k001 k406 k410 k412 k475 k445 k156 k157 k158 k159 k168 k479 k205 s_ort s_vorwahl wei_trang wei_sozg wei_sozs

ren k205 PLZ

gen stuttgart = s_ort == "Stuttgart"

replace k475 = 6 if inlist(k475,11,34)
replace k475 = 7 if inlist(k475,96,99)
replace k475 = . if inlist(k475,97,98)
lab def K475 6 "Andere", modify
lab def K475 7 "Nicht", modify
tab k475 if !mi(k475), gen(p_)
ren p_1 p_cdu
ren p_2 p_spd
ren p_3 p_fdp
ren p_4 p_gruene
ren p_5 p_linke
ren p_6 p_andere
ren p_7 p_nicht

recode k156 (1 = 1) (2 = 0), gen(male)

gen age = 2011 - k157 if k157 < 9000
gen age2 = age^2

recode k158 (0 1 = 1) (2 = 2) (3 = 3) (4 5 = 4) (else = .), gen(edu)
tab edu if !mi(k158), gen(edu) 
ren edu1 edu_ohne
ren edu2 edu_haupt
ren edu3 edu_mitt
ren edu4 edu_abi

recode k159 (1 2 3 = 0) (5 = 1) (else = .)  , gen(unemp)

ren k479 hhsize
replace hhsize = . if hhsize == 99

replace k168 = . if k168 == 99
gen fam_married = k168 == 1 & !mi(k168)

recode k445 (1 = 0) (2 = 1) (98=0.5) (else = .), gen(result)
lab var result "Einstellung"

ren wei_trang GEWICHT

// Problem: yes == against S21?
/*
lab def opinion 0 "Für S21" 1 "Gegen S21"
lab val result opinion

lab def vote 0 "Für S21 gestimmt" 1 "Gegen S21 gestimmt"
lab val v_result vote

corr result v_result

scatter v_result result, jitter(20) ms(oh) ///
  xlab(0(1)1, val) ylab(0(1)1, val) ///
  xscale(range(-.3 1.3))  yscale(range(-.3 1.3))
winman close graph

gen diff:opdif = 0 if result == v_result
replace diff = 1 if result == 1 & v_result == 0
replace diff = -1 if result == 0 & v_result == 1

lab def opdif 0 "kongruent" 1 "taktisch" -1 "dumm"

tab diff edu_abi, nof row
*/

// Prepare population&distance merge
// ---------------------------------

replace s_ort = subinstr(s_ort,", Württ","",1)
replace s_ort = subinstr(s_ort,", Baden","",1)
replace s_ort = subinstr(s_ort," b Sigmaringen","",1)
replace s_ort = subinstr(s_ort,", Kr Göppingen","",1)
replace s_ort = subinstr(s_ort," b Hechingen","",1)
replace s_ort = subinstr(s_ort,"Breisach am Rh","Breisach am Rhein",1)
replace s_ort = subinstr(s_ort,", Kr Böblingen","",1)
replace s_ort = subinstr(s_ort,"Eislingen, Fils","Eislingen/Fils",1)
replace s_ort = "Emmendingen" if s_ort =="Emmendinge"
replace s_ort = subinstr(s_ort,", Donau","",1)
replace s_ort = "Esslingen am Neckar" if s_ort =="Esslingen"
replace s_ort = "Freiburg im Breisgau" if s_ort =="Freiburg i"
replace s_ort = "Freiburg im Breisgau" if s_ort =="Freiburg im Br"
replace s_ort = subinstr(s_ort,", Kr Calw","",1)
replace s_ort = "Giengen an der Brenz" if s_ort =="Giengen an der"
replace s_ort = subinstr(s_ort," b Gaildorf","",1)
replace s_ort = subinstr(s_ort,", Breisgau","",1)
replace s_ort = subinstr(s_ort,", Neckar","",1)
replace s_ort = "Heidenheim an der Brenz" if s_ort =="Heidenheim an"
replace s_ort = subinstr(s_ort,", Bergstr","",1)
replace s_ort = subinstr(s_ort," im Gäu","",1)
replace s_ort = subinstr(s_ort,", Kr Sigmaringen","",1)
replace s_ort = "Hirschberg an der Bergstraße" if s_ort =="Hirschberg an"
replace s_ort = subinstr(s_ort," b Bad Saulgau"," am Hochrhein",1)
replace s_ort = "Immenstaad am Bodensee" if s_ort =="Immenstaad am"
replace s_ort = subinstr(s_ort,", Rhein","",1)
replace s_ort = "Konstanz, Universitätsstadt" if s_ort =="Konstanz"
replace s_ort = subinstr(s_ort,", Fils","",1)
replace s_ort = "Lahr/Schwarzwald" if s_ort =="Lahr"
replace s_ort = "Lahr/Schwarzwald" if s_ort =="Lahr, Schwarzwald"
replace s_ort = "Lauffen am Neckar" if s_ort =="Lauffen am"
replace s_ort = "Mannheim, Universitätsstadt" if s_ort =="Mannheim"
replace s_ort = subinstr(s_ort," b Münsingen","",1)
replace s_ort = subinstr(s_ort,", Kr Ludwigsburg","",1)
replace s_ort = subinstr(s_ort,", Hohenz","",1)
replace s_ort = subinstr(s_ort," b Mosbach","",1)
replace s_ort = "Rheinfelden (Baden)" if s_ort =="Rheinfelden"
replace s_ort = "Rottenburg am Neckar" if s_ort =="Rottenburg am"
replace s_ort = subinstr(s_ort,", Elsenz","",1)
replace s_ort = subinstr(s_ort,", Weihung","",1)
replace s_ort = "Staufen im Breisgau" if s_ort =="Staufen im Bre"
replace s_ort = subinstr(s_ort,", Kr Lörrach","",1)
replace s_ort = subinstr(s_ort,", Hohenz","",1)
replace s_ort = "Stuttgart, Landeshauptstadt" if s_ort =="Stuttgart"
replace s_ort = "Tübingen, Universitätsstadt" if s_ort =="Tübingen"
replace s_ort = "Ulm, Universitätsstadt" if s_ort =="Ulm"
replace s_ort = "Vogtsburg im Kaiserstuhl" if s_ort =="Vogtsburg im K"
replace s_ort = subinstr(s_ort,", Rems","",1)
replace s_ort = subinstr(s_ort,", Albtal","",1)
replace s_ort = subinstr(s_ort,", Bergstr","",1)
replace s_ort = subinstr(s_ort," a Main","",1)
replace s_ort = subinstr(s_ort,", W_r","",1)
replace s_ort = subinstr(s_ort," b Schorndorf","",1)
replace s_ort = subinstr(s_ort," b Tuttlingen","",1)
replace s_ort = subinstr(s_ort,", Bodensee","",1)
replace s_ort = "Kleines Wiesental" if s_ort == "Tegernau"

merge m:1 s_ort using "data/area", keepus(pop*) keep(1 3) nogen
merge m:1 s_ort using "data/ind_dist", keepus(distance) keep(1 3)

// Region dummies
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

// Cleaning
keep serialid result distance p_* age age2 male edu_* unemp fam* popdens pop hhsize baden ulm stuttgart GEWICHT s_ort

lab var result "Einstellung S21"
lab var hhsize "Haushaltsgröße"
lab var stuttgart "Reg: Stuttgart"
lab var p_cdu "Partei: CDU"
lab var p_spd "Partei: SPD"
lab var p_fdp "Partei: FDP"
lab var p_gruene "Partei: Grüne"
lab var p_linke "Partei: Linke"
lab var p_andere "Partei: Sonstige"
lab var p_nicht "Partei: Keine"
lab var male "Männlich"
lab var age "Alter"
lab var age2 "Alter$^2$"
lab var edu_ohne "Edu: Ohne"
lab var edu_haupt "Edu: Hauptschule"
lab var edu_mitt "Edu: Realschule"
lab var edu_abi "Edu: Abitur"
lab var unemp "Arbeitslosigkeit"
lab var fam_married "Fam: verheiratet"
lab var popdens "Bevölkerungsdichte"
lab var pop "Bevölkerung"
lab var distance "Entfernung zu S21 (km)"
lab var baden "Reg: Baden"
lab var ulm "Reg: Ulm"

save "data/faas", replace



// Prepare mikro-data from Gabriel
// -------------------------------
use "data/gabriel/VES21_integriert_Vor-Nachwahl_orig", clear
gen serialid=_n

keep if inrange(NQ02_W3,1,2)

recode Region (0=0) (1=1) (6=0.5), gen(stuttgart)

replace recltw = . if inlist(recltw,83,98)
replace recltw = 6 if inlist(recltw,6,8,10,30,79)
replace recltw = 7 if inlist(recltw,81,82,99)
lab def RECLTW 6 "Andere", modify
lab def RECLTW 7 "Nicht", modify

tab recltw if !mi(recltw), gen(p_) 
ren p_1 p_spd
ren p_2 p_cdu
ren p_3 p_gruene
ren p_4 p_fdp
ren p_5 p_linke
ren p_6 p_andere
ren p_7 p_nicht


recode Q0S4 (0=.) (1=0) (2=1) (3=.), gen(unemp)

recode NQ03_W3 (1=1) (2=0), gen(result)

ren NQ0S1 age
replace age=. if age == 0
gen age2 = age^2

recode NQ0S2 (1=1) (2=0), gen(male)

recode NQ0S3_VW (1 8 = 1) (2 = 2) (3 = 3) (4 5 6 = 4) (7 9 10 = .), gen(edu)
tab edu, gen(edu)
ren edu1 edu_ohne
ren edu2 edu_haupt
ren edu3 edu_mitt
ren edu4 edu_abi

ren NPersGewNachwahl GEWICHT

// Cleaning
keep serialid result stuttgart p_* age age2 male edu_* unemp GEWICHT

lab var result "Einstellung S21"
lab var stuttgart "Reg: Stuttgart"
lab var p_cdu "Partei: CDU"
lab var p_spd "Partei: SPD"
lab var p_fdp "Partei: FDP"
lab var p_gruene "Partei: Grüne"
lab var p_linke "Partei: Linke"
lab var p_andere "Partei: Sonstige"
lab var p_nicht "Partei: Keine"
lab var male "Männlich"
lab var age "Alter"
lab var age2 "Alter$^2$"
lab var edu_ohne "Edu: Ohne"
lab var edu_haupt "Edu: Hauptschule"
lab var edu_mitt "Edu: Realschule"
lab var edu_abi "Edu: Abitur"
lab var unemp "Arbeitslosigkeit"

save "data/gab", replace


// Prepare mikro-data from ZA5625
// ------------------------------
use "data/ZA/ZA5625_v1-0-0", clear
gen serialid=_n

ren VC fam
ren VF edu
ren VQ rel

recode V37 (1=0) (2=1) (3=0.5) (else=.), gen(result)

replace V3C = . if inlist(V3C,0)
replace V3C = 6 if inlist(V3C,6,7,8,9)
replace V3C = 7 if inlist(V3C,10,11)
lab def V3C 6 "Andere", modify
lab def V3C 7 "Nicht", modify

tab V3C if !mi(V3C), gen(p_) 
ren p_1 p_cdu
ren p_2 p_spd
ren p_3 p_gruene
ren p_4 p_fdp
ren p_5 p_linke
ren p_6 p_andere
ren p_7 p_nicht

gen stuttgart = V0B == 8 if V0B < 9

gen age = .
replace age = 19 if VB == 1
replace age = 22.5 if VB == 2
replace age = 27 if VB == 3
replace age = 32 if VB == 4
replace age = 37 if VB == 5
replace age = 42 if VB == 6
replace age = 47 if VB == 7
replace age = 54.5 if VB == 8
replace age = 64.5 if VB == 9
replace age = 78.5 if VB == 10
drop VB
gen age2 = age^2

replace fam = . if fam == 7
gen fam_single = fam == 3 if !mi(fam)
gen fam_married = inlist(fam,1,2,6) if !mi(fam)
gen fam_widowed = fam == 5 if !mi(fam)
gen fam_seperated  = fam == 4 if !mi(fam)

gen male = VA == 1 if !mi(VA)

replace edu = . if edu == 6
replace edu = 3 if VF2 == 3
gen edu_ohne = inlist(edu,4,5) if !mi(edu)
gen edu_haupt = edu == 1 if !mi(edu)
gen edu_mitt = edu == 2 if !mi(edu)
gen edu_abi = inlist(edu,3) if !mi(edu)

replace VK = . if VK == 11
gen unemp = inlist(VK,5,6) if !mi(VK)

replace rel = . if rel == 7
gen rel_rk = rel == 1 if !mi(rel)
gen rel_eva = rel == 2 if !mi(rel)
gen rel_other = inlist(rel,3,5,6) if !mi(rel)

recode V0B (1=1000) (2=3500) (3=7500) (4=15000) (5=35000) (6=75000) (7=300000) (8=600000) (9=.), gen(pop)

recode VE (1=1) (2=2) (3=3) (4=4) (5=6), gen(hhsize)

ren repgew GEWICHT

// Cleaning
keep serialid result p* stuttgart age* fam_* male edu_* unemp rel_* pop hhsize GEWICHT

lab var result "Einstellung S21"
lab var hhsize "Haushaltsgröße"
lab var stuttgart "Reg: Stuttgart"
lab var p_cdu "Partei: CDU"
lab var p_spd "Partei: SPD"
lab var p_fdp "Partei: FDP"
lab var p_gruene "Partei: Grüne"
lab var p_linke "Partei: Linke"
lab var p_andere "Partei: Sonstige"
lab var p_nicht "Partei: Keine"
lab var male "Männlich"
lab var age "Alter"
lab var age2 "Alter$^2$"
lab var edu_ohne "Edu: Ohne"
lab var edu_haupt "Edu: Hauptschule"
lab var edu_mitt "Edu: Realschule"
lab var edu_abi "Edu: Abitur"
lab var unemp "Arbeitslosigkeit"
lab var fam_married "Fam: verheiratet"
lab var fam_single "Fam: ledig"
lab var fam_widowed "Fam: verwitwet"
lab var fam_seperated "Fam: getrennt"
lab var pop "Bevölkerung"
lab var rel_rk "Rel: Katholisch"
lab var rel_eva "Rel: Evangelisch"
lab var rel_other "Rel: Sonstige"

save "data/za5625", replace



// Prepare mikro-data from ZA5592
// ------------------------------
use "data/ZA/ZA5592_v1-0-0", clear
gen serialid=_n

ren Familienstand fam
ren HöchsterBildungsabschluss edu
ren Konfession rel

gen result = (thermoAblehnungZustimmungS21 * (-1) + 5) / 10

replace SonntagsfragePartei = . if inlist(SonntagsfragePartei,0)
replace SonntagsfragePartei = 6 if inlist(SonntagsfragePartei,6,7,8,9)
replace SonntagsfragePartei = 7 if inlist(SonntagsfragePartei,10)
lab def V18_A 6 "Andere", modify
lab def V18_A 7 "Nicht", modify

tab SonntagsfragePartei if !mi(SonntagsfragePartei), gen(p_) 
ren p_1 p_cdu
ren p_2 p_spd
ren p_3 p_gruene
ren p_4 p_fdp
ren p_5 p_linke
ren p_6 p_andere
ren p_7 p_nicht

gen stuttgart = RegionStuttgart == 1 if !mi(RegionStuttgart)

gen age = .
replace age = 19.5 if Alterneu == 1
replace age = 22.5 if Alterneu == 2
replace age = 27 if Alterneu == 3
replace age = 32 if Alterneu == 4
replace age = 37 if Alterneu == 5
replace age = 42 if Alterneu == 6
replace age = 47 if Alterneu == 7
replace age = 54.5 if Alterneu == 8
replace age = 64.5 if Alterneu == 9
replace age = 78.5 if Alterneu == 10
gen age2 = age^2

gen fam_single = fam == 4 if !mi(fam)
gen fam_married = inlist(fam,1,2,3) if !mi(fam)
gen fam_widowed = fam == 6 if !mi(fam)
gen fam_seperated  = fam == 5 if !mi(fam)

gen male = Geschlecht == 2 if !mi(Geschlecht)

gen edu_ohne = inlist(edu,5,6) if !mi(edu)
gen edu_haupt = edu == 1 if !mi(edu)
gen edu_mitt = edu == 2 if !mi(edu)
gen edu_abi = inlist(edu,3,4) if !mi(edu)

gen unemp = Berufstätig == 6 if !mi(Berufstätig)

gen rel_rk = rel == 1 if !mi(rel)
gen rel_eva = rel == 2 if !mi(rel)
gen rel_other = inlist(rel,3,4,5) if !mi(rel)

recode Einwohner (1=500) (2=1500) (3=2500) (4=4000) (5=7500) (6=15000) (7=35000) (8=75000) (9=175000) (10=375000) (11 = 600000), gen(pop)

recode Haushaltsgröße (1=1) (2=2) (3=3) (4=4) (5=6), gen(hhsize)

// Cleaning
keep serialid GEWICHT result p_* stuttgart age* fam_* male edu_* unemp rel_* pop hhsize

lab var result "Einstellung S21"
lab var hhsize "Haushaltsgröße"
lab var stuttgart "Reg: Stuttgart"
lab var p_cdu "Partei: CDU"
lab var p_spd "Partei: SPD"
lab var p_fdp "Partei: FDP"
lab var p_gruene "Partei: Grüne"
lab var p_linke "Partei: Linke"
lab var p_andere "Partei: Sonstige"
lab var p_nicht "Partei: Keine"
lab var male "Männlich"
lab var age "Alter"
lab var age2 "Alter$^2$"
lab var edu_ohne "Edu: Ohne"
lab var edu_haupt "Edu: Hauptschule"
lab var edu_mitt "Edu: Realschule"
lab var edu_abi "Edu: Abitur"
lab var unemp "Arbeitslosigkeit"
lab var fam_married "Fam: verheiratet"
lab var fam_single "Fam: ledig"
lab var fam_widowed "Fam: verwitwet"
lab var fam_seperated "Fam: getrennt"
lab var pop "Bevölkerung"
lab var rel_rk "Rel: Katholisch"
lab var rel_eva "Rel: Evangelisch"
lab var rel_other "Rel: Sonstige"

save "data/za5592", replace

exit

* Erzeugt Querschnitts--Datensatz fuer Kohler/Kreuter
* ---------------------------------------------------
* (calls mkdat.ado and holrein.ado)

version 6.0
set memory 60m
*-------------------------- DATEN LADEN ----------------------------------
#delimit ;
mkdat
np0105 np11701 np9501 np9502 np9503 np9504 np9506 np9507 np9401
np9402 np9403 npintnr
using c:\user\data\soep,
files(p) waves(n)
keep(sex gebjahr) ;

holrein
nbauj nwgurt nwohnfl nwohnr naus1 naus2 naus3 naus4 naus5 naus6 naus7
naus9 nrenov nmiete nmurt neinzug ntyphh1 neigen
using c:\user\data\soep,
files(hgen) waves(n);

holrein
nwum1 nwum3 nhhgr
using c:\user\data\soep,
 files(hbrutto) waves(n);

holrein
bsth97 egph97 est97 ein97 hhein97 bil97 bbil97 bdauer97
fam97 hst97 bul97
using c:\user\data\soep, files(peigen) waves(n) ;
#delimit cr

*--------------------- LEHRSTICHPROBE----------------------------------
save 11, replace
use hhnr rgroup using c:\user\data\soep\cirdef
sort hhnr
save 12, replace
use 11
sort hhnr
merge hhnr using 12
keep if rgroup20 >= 11 & rgroup20 <= 20
drop if _merge == 2
drop rgroup20 _merge
erase 11.dta
erase 12.dta

* -------------------NUR 1 PERSON PRO HAUSHALT-------------------------
set seed 731
gen r = uniform()
sort nhhnr r
quietly by nhhnr: keep if _n == 1
drop r nhhnr hhnr nnetto

*----------------------------KOSMETIK-----------------------------------

* Programm zum Umbenennen der Variablen
* -------------------------------------

capture program drop umben
program define umben
        local name "`1'"
        macro shift
        ren `1' `name'
        note `name': Ursprung: `1'
end

* Wohnungsvariablen
* -----------------

* Baujahr
umben bauj nbauj
lab var bauj "Baujahr des Hauses"
lab val bauj bauj
lab def bauj 1 "< 1918" 2 "1918-49[" 3 "1949-72[" 4 ">=1972" /*
*/ 5 "81-'95" 6 ">95"

* Jahr des Einzugs
umben einzug neinzug
lab var einzug "Jahr des Einzugs"

* Wohnungsgroesse
umben wohngr nwohnfl
lab var wohngr "Wohnungsgroesse in qm"

* Anzahl Zimmer ueber 6 qm
umben zimmer nwohnr
lab var zimmer "Anzahl Zimmer ueber 6qm"

* Beurteilung Wohnungsgroesse
umben wgurt nwgurt
lab var wgurt "Wohnungsgroesse, Beurteilung HV"
lab val wgurt wgurt
lab def wgurt 1 "v.z.kl." 2 "zu klein" 3 "richtig" 4 "zu gross" /*
*/ 5 "v.z.gr."

* Wohnungsausstattung
umben kuech naus1
lab var kuech "Kueche j/n"

umben dusch naus2
lab var dusch "Bad/Dusche j/n"

umben wc naus3
lab var wc "WC j/n"

umben heiz naus4
lab var heiz "Zentralheizung j/n"

umben kell naus5
lab var kell "Keller j/n"

umben balk naus6
lab var balk "Balkon oder Terrasse j/n"

umben gart naus7
lab var gart "Garten j/n"

umben tel naus9
lab var tel "Telephon j/n"

for var kuech dusch wc heiz kell balk gart tel: lab val X janein

* Renovierungsbeduerftigkeit
umben renov nrenov
lab var renov "Renovierungsbeduerftigkeit"
lab val renov renov
lab def renov 1 "nein" 2 "mittel" 3 "ja" 4 "abbruchr"

* Eigentmer/Mieter
umben wohnst neigen
lab var wohnst "Wohnstatus"
lab val wohnst wohnst
lab def wohnst 1 "Eigent." 2 "H-mieter" 3 "U-mieter"

* Monatl. Miete
umben miete nmiete
lab var miete "Montl. Mietausgaben"

* Beurteilung der Miete
umben mietur nmurt
lab var mietur "Mietausgaben, Beurteilung HV"
lab val mietur mietur
lab def mietur 1 "s.guenst" 2 "guenst" 3 "angemess" 4 "l.z.hoch" /*
*/ 5 "v.z.hoch"

* Wohnumfeld
* ----------

* Haustyp
umben htyp nwum1
lab var htyp "Art des Hauses"
lab val htyp htyp
lab def htyp 1 "Lw.Wogeb" 2 "EFH" 3 "1/2F-RH" 4 "MFH(3-4)" /*
*/ 5 "MFH(5-8)" 6 "MFH(>9)" 7 "Hochhaus" 8 "Sonst."

* Kietzart
umben wum nwum3
lab var wum "Wohnumfeld"
lab val wum wum
lab def wum 1 "Altbauten" 2 "Neubauten" 3 "Mischgeb." 4 "GeschZtr" /*
*/ 5 "Ind-Geb." 6 "Sonst."

* Haushaltstyp
* ------------

umben hhtyp ntyphh1
lab var hhtyp "Hauhaltstyp"
lab var hhtyp hhtyp
lab def hhtyp 1 "1 PersHH" 2 "2(no Ki)"  3 "All.erz." 4 "2+Ki<16" /*
*/ 5 "2+Ki>16" 6 "2+Ki<>16" 7 "MGen.HH" 8 "Sonst."

* Haushaltsgroesse
* ----------------

umben hhgr nhhgr
lab var hhgr "Haushaltsgroesse"


* Einstellungen
* -------------

* Zufriedenheit mit der Wohnung
lab var np0105 "Zufriedenheit mit der Wohnung"
lab val np0105 zuf

* Allgemeine Lebenszufriedenheit
lab var np11701 "Allgemeine Lebenszufriedenheit"
lab val np11701 zuf

* Sorgen
lab var np9501 "Sorgen: Allgemeine wirtsch. Entw."
lab var np9502 "Sorgen: Eigene wirtschaft. Situation"
lab var np9503 "Sorgen: Schutz der Umwelt"
lab var np9504 "Sorgen: Erhaltung des Friedens"
lab var np9506 "Sorgen: Kriminalitaetsentwicklung"
lab var np9507 "Sorgen: Sicherheit Arbeitsplatz"
for var np95*: lab val X sor

* Parteiidentifikation j/n
lab var np9401 "PI- j/n"
lab val np9401 pia
lab def pia 1 "ja" 2 "nein" 3 "w.n."

* Parteiidentifikation Partei
lab var np9402 "PI-Partei"
lab val np9402 pib
lab def pib 1 "SPD" 2 "CDU" 3 "CSU" 4 "FDP" 5 "B90/Gr." 6 "PDS" /*
*/ 7 "Rep" 8 "Sonst."

* Parteiidentifikaton Intensitaet
lab var np9403 "PI-Intensitaet"
lab val np9403 pic
lab def pic 1 "s.stark" 2 "stark" 3 "maessig" 4 "schwach" 5 "s.schw."

* Persnr
lab var persnr "Unveraenderl. Personenummer"

* Soziodemographie
* ----------------

ren ein97 eink97
for any  bsth egph est eink hhein bil bbil bdauer fam hst bul: /*
*/ ren X X

* Interviewernummer
* -----------------
umben intnr npintnr
lab var intnr Interviewernummer

*------------------------MISSING - VALUES -------------------------------
mvdecode _all, mv(-3)
mvdecode _all, mv(-2)
mvdecode _all, mv(-1)

* ---------------------ALLGEMEINE VALUE LABELS----------------------------
lab def janein 1 "ja" 2 "nein"
lab def yesno 0 "nein" 1 "ja"
lab def zuf 1 "s. unzuf" 10 "s. zufr."
lab def sor 1 "grosse S" 2 "einige S" 3 "keine S."

*------------------------SPEICHERN DATA1A-----------------------------
#delimit ;
order
persnr intnr bul sex gebjahr einzug bauj renov wohngr zimmer wgurt
kuech dusch wc heiz kell balk gart tel wohnst miete
mietur  hhtyp htyp wum np11701 np0105 np9401 np9402 np9403 np9501
np9502 np9503 np9504 np9506 np9507 hst hhgr fam bil bbil
bdauer est bsth hhein eink egph ;
#delimit cr

label data "SOEP '97 (Auszug)"
save data1a, replace

*---------------------------VERFREMDUNG--------------------------------

* Metrische Variablen
* -------------------

* Programm
capture program drop noise1
program define noise1
set seed 731
tempvar fx
gen `fx' = .
        while "`1'" ~= "" {
                quietly sum `1', d
                local range = r(p99) - r(p1)
                local a 1/sqrt(2*_pi*r(Var))
                replace `fx' =  `a' * exp((`1'-r(mean))^2/(2*r(Var))*-1)
                quietly sum `fx'
                local s = (.3 * `range')/(3 * r(max))
                replace `1'=abs(round(`1'+`s'*invnorm(uniform())*`fx',1))
                macro shift
        }
end
noise1 gebjahr einzug wohngr zimmer miete hhein

* Sonderfall: Einkommen
quietly sum eink, d
local range = r(p99) - r(p1)
local a 1/sqrt(2*_pi*r(Var))
gen fx =  `a' * exp((eink - r(mean))^2/(2*r(Var))*-1)
quietly sum fx
local s = (.3 * `range')/(3 * r(max))
replace eink = abs(round(eink + `s'*invnorm(uniform())*fx,1)) /*
*/ if eink ~= 0
drop fx

* Kategoriale Variablen
* ---------------------

* Program
capture program drop noise2
program define noise2
        set seed 731
        tempvar r
        gen `r' = .
        while "`1'" ~= "" {
                replace `r' = uniform()
                replace `1' = `1'[int(uniform()*_N + 1)] if `r' < .3
                mac shift
        }
end

noise2 bul sex bauj kuech dusch wc heiz kell balk gart tel htyp wum est bsth

* Verbundene Variablen
* ---------------------

* Program
capture program drop noise3
program define noise3
        local seed `1'
        tempvar r
        mac shift
        gen `r' = .
        while "`1'" ~= "" {
                set seed `seed'
                replace `r' = uniform()
                replace `1' = `1'[int(uniform()*_N + 1)] if `r' < .3
                mac shift
        }
end

* 1. Gruppe
noise3 731 hhtyp hst fam hhgr

* 2. Gruppe
noise3 1234 bil bbil bdauer

* Korrekturen
* -----------

replace einzug = 97 - int(uniform()*20 +1) if einzug > 97
replace gebjahr =1985 - int(uniform()*4 +1) if gebjahr > 1981
replace zimmer = 1 if zimmer == 0
save data1b, replace
exit
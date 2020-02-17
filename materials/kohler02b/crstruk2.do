* ERZEUGUNG STRUKTURDATENSAETZE
* Variablen: berufliche Stellung und Beruf, Einordungsberufe
version 5.0
clear
set memory 60m
* --------------------------RETRIVAL--------------------------------------
#delimit ;
mkdat
ap2801 bp3801 cp4601 dp3801 ep3801 fp3801 gp3701 hp4801 ip4801
       jp4801 kp5101 lp4301 mp4101 np3501                    /* Arbeiter */
ap2802 bp3802 cp4602 dp3802 ep3802 fp3802 gp3702 hp4802 ip4802
       jp4802 kp5102 lp4302 mp4102 np3502               /* Selbstaendige */
ap2803 bp3803 cp4603 dp3803 ep3803 fp3803 gp3703 hp4803 ip4803
       jp4803 kp5103 lp4303 mp4103 np3503               /* Auszubildende */
ap2804 bp3804 cp4604 dp3804 ep3804 fp3804 gp3704 hp4804 ip4804
       jp4804 kp5104 lp4304 mp4104 np3504                 /* Angestellte */
ap2805 bp3805 cp4605 dp3805 ep3805 fp3805 gp3705 hp4805 ip4805
       jp4805 kp5105 lp4305 mp4105 np3505                      /* Beamte */
ap1601 bp24b01 cp24b01 dp22b01 ep22b01 fp20b01 gp23b01 hp25b01
       ip25b01 jp25b01 _x1 _x11 _x21 _x21a           /* frueher Arbeiter */
ap1602 bp24b02 cp24b02 dp22b02 ep22b02 fp20b02 gp23b02 hp25b02
       ip25b02 jp25b02 _x2 _x12 _x22 _x22a           /* frueher Selbst.  */
ap1603 bp24b03 cp24b03 dp22b03 ep22b03 fp20b03 gp23b03 hp25b03
       ip25b03 jp25b03 _x3 _x13 _x23 _x23a              /* frueher Azubi */
ap1604 bp24b04 cp24b04 dp22b04 ep22b04 fp20b04 gp23b04 hp25b04
       ip25b04 jp25b04 _x4 _x14 _x24 _x24a            /* frueher Angest. */
ap1605 bp24b05 cp24b05 dp22b05 ep22b05 fp20b05 gp23b05 hp25b05
       ip25b05 jp25b05 _x5 _x15 _x25 _x25a           /* frueher Beamter  */
using $soepdir, files(p) waves(a b c d e f g h i j k l m n)
keep(sex gebjahr todjahr)
netto(-3,-2,-1,0,1,2,3,4) ;

holrein
aisco                                               /* frueherer Beruf  */
using $soepdir, files(p) waves(a) ;

holrein
isco84 isco85 isco86 isco87 isco88 isco89 isco90 isco91 isco92
 isco93 isco94 isco95 isco96 isco97                            /* ISCO */
partnr84 partnr85 partnr86 partnr87 partnr88 partnr89 partnr90 partnr91
 partnr92 partnr93 partnr94 partnr95 partnr96 partnr97 /*Partnernummer */
using $soepdir, files(pgen) waves(a b c d e f g h i j k l m n) ;

holrein
est84 est85 est86 est87 est88 est89 est90
 est91 est92 est93 est94 est95 est96 est97
aus84 aus85 aus86 aus87 aus88 aus89 aus90
 aus91 aus92 aus93 aus94 aus95 aus96 aus97
ein84 ein85 ein86 ein87 ein88 ein89 ein90
 ein91 ein92 ein93 ein94 ein95 ein96 ein97
hst84 hst85 hst86 hst87 hst88 hst89 hst90
 hst91 hst92 hst93 hst94 hst95 hst96 hst97
fam84 fam85 fam86 fam87 fam88 fam89 fam90
 fam91 fam92 fam93 fam94 fam95 fam96 fam97
nie84 nie85 nie86 nie87 nie88 nie89 nie90
 nie91 nie92 nie93 nie94 nie95 nie96 nie97
using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n) ;

#delimit cr
* --------------------------VEREINHEITLICHUNGEN----------------------------

capture program drop hnr                                /* Akt. HHNR */
program define hnr
        local i 84
        while "`1'"~="" {
                ren `1'hhnr hnr`i'
                lab var hnr`i' "Haushaltsnummer `i'"
                macro shift
                local i=`i'+1
        }
end
hnr a b c d e f g h i j k l m n

renpfix isco iscb                                                /* Isco */

capture program drop bst                           /* Berufl. Stellung */
program define bst
        local i 84
        while "`1'"~="" {
                * Mehrfachnennungen werden gestrichen
                * Beamten
                gen byte bstb`i'=40 if `1'05==1 /* einfach */
                replace bstb`i'=41 if `1'05==2 /* mittel */
                replace bstb`i'=42 if `1'05==3 /* gehoben */
                replace bstb`i'=43 if `1'05==4 /* hoeher */
                * Angestellte
                if `i'< 91 {
                        replace bstb`i'=50 if `1'04==1 /* Ind. Werkmeister */
                        replace bstb`i'=51 if `1'04==2 /* einfach */
                        replace bstb`i'=52 if `1'04==3 /* qualif */
                        replace bstb`i'=53 if `1'04==4 /* hochqualif */
                        replace bstb`i'=54 if `1'04==5 /* fuehrung */
                }
                else if `i' >= 91 {
                        replace bstb`i'=50 if `1'04==1 /* Ind. Werkmeister */
                        replace bstb`i'=51 if `1'04==2 | `1'04==3  /* einf. */
                        replace bstb`i'=52 if `1'04==4 /* qualif */
                        replace bstb`i'=53 if `1'04==5 /* hochqualif */
                        replace bstb`i'=54 if `1'04==6 /* fuehrung */
                }
                * Arbeiter
                replace bstb`i'=60 if `1'01==1 /* ungelernt */
                replace bstb`i'=61 if `1'01==2 /* angelernt */
                replace bstb`i'=62 if `1'01==3 /* Facharbeiter */
                replace bstb`i'=63 if `1'01==4 /* Vorarbeiter */
                replace bstb`i'=64 if `1'01==5 /* Meister */
                * Auszubildende
                replace bstb`i'=70 if `1'03==1 /* Azubi */
                replace bstb`i'=70 if `1'03==2 /* Praktikant */
                * Selbstaendige
                if `i'< 97 {
                        replace bstb`i'= 10 if `1'02==1 /* Landwirte */
                        replace bstb`i'= 15 if `1'02==2 /* freie Berufe */
                        replace bstb`i'= 21 if `1'02==3 /* Selb < 9 */
                        replace bstb`i'= 23 if `1'02==4 /* Selb >= 10 */
                        replace bstb`i'= 30 if `1'02==5 /* Mithelfend */
                }
                else if `i' >= 97 {
                        replace bstb`i'= 10 if `1'02==1 /* Landwirte */
                        replace bstb`i'= 15 if `1'02==2 /* freie Berufe */
                        replace bstb`i'= 21 /*
                        */ if `1'02 == 3 | `1'02 == 4   /* Selb < 9 */
                        replace bstb`i'= 23 if `1'02==5 /* Selb >= 10 */
                        replace bstb`i'= 30 if `1'02==6 /* Mithelfend */
                }
                * Missings
                replace bstb`i' = -1 /*
                */ if est`i' <= 4 & bstb`i' == .
                replace bstb`i' = -2 /*
                */ if est`i' >= 5 & est`i' <= 7 & bstb`i' == .
                replace bstb`i' = -2 if est`i' == -2 & bstb`i' == .
                lab var bstb`i' "Berufl. Stellung Befragter `i'"
                lab val bstb`i' bst
                note bstb`i': aus `1'01-`1'05
                drop `1'01-`1'05
                macro shift
                local i=`i'+1
        }
end
bst ap28 bp38 cp46 dp38 ep38 fp38 gp37 hp48 ip48 jp48 kp51 lp43 mp41 np35

* Konsistenzchecks (s.u.)
* Mehrfachnennungen sofern v. impliziten Entsch. der Reihenfolge abweichend
replace bstb94 = 51 if persnr ==  521802
replace bstb94 = -1 if persnr ==  372101
replace bstb94 = 51 if persnr == 5074002
replace bstb94 = -1 if persnr ==   363601
replace bstb94 = -1 if persnr ==   442203
replace bstb94 = 51 if persnr ==  464302
replace bstb94 = 41 if persnr == 5035902
replace bstb94 = 51 if persnr == 5172602
replace bstb94 = 53 if persnr ==  518403
replace bstb94 = -1 if persnr ==  138603
* Filter"fehler"
replace bstb88 = -2 if persnr ==   36001
replace bstb88 = -2 if persnr ==  283302
replace bstb88 = -2 if persnr ==  391403
replace bstb88 = -2 if persnr ==  452104
replace bstb96 = -2 if persnr ==  153301
replace bstb96 = -2 if persnr ==  420002

capture program drop exbstb               /* letzte berufliche Stellung */
program define exbstb
        local i 84
        while "`1'" ~= "" {
                * Missings
                gen byte bstbex`i' = -1 /*
                */ if nie`i' == 0 & est`i' >= 5 & est`i' <=7
                replace bstbex`i' = -2 /*
                */ if nie`i' == 1 & est`i' >= 5 & est`i' <=7
                replace bstbex`i' = -2 if est`i' <= 4
                replace bstbex`i' = -1 if est`i' == -1
                * Beamten
                replace bstbex`i'=40 if `1'05==1 /* einfach */
                replace bstbex`i'=41 if `1'05==2 /* mittel */
                replace bstbex`i'=42 if `1'05==3 /* gehoben */
                replace bstbex`i'=43 if `1'05==4 /* hoeher */
                * Angestellte
                if `i'< 91 {
                        replace bstbex`i'=50 if `1'04==1 /* Ind. Werkmeister */
                        replace bstbex`i'=51 if `1'04==2 /* einfach */
                        replace bstbex`i'=52 if `1'04==3 /* qualif */
                        replace bstbex`i'=53 if `1'04==4 /* hochqualif */
                        replace bstbex`i'=54 if `1'04==5 /* fuehrung */
                }
                else if `i' >= 91 {
                        replace bstbex`i'=50 if `1'04==1 /* Ind. Werkmeister */
                        replace bstbex`i'=51 if `1'04==2 | `1'04==3 /* einf. */
                        replace bstbex`i'=52 if `1'04==4 /* qualif */
                        replace bstbex`i'=53 if `1'04==5 /* hochqualif */
                        replace bstbex`i'=54 if `1'04==6 /* fuehrung */
                }
                * Arbeiter
                replace bstbex`i'=60 if `1'01==1 /* ungelernt */
                replace bstbex`i'=61 if `1'01==2 /* angelernt */
                replace bstbex`i'=62 if `1'01==3 /* Facharbeiter */
                replace bstbex`i'=63 if `1'01==4 /* Vorarbeiter */
                replace bstbex`i'=64 if `1'01==5 /* Meister */
                * Auszubildende
                replace bstbex`i'=70 if `1'03==1 /* Azubi */
                replace bstbex`i'=70 if `1'03==2 /* Praktikant */
                * Selbstaendige
                replace bstbex`i'= 10 if `1'02==1 /* Landwirte */
                replace bstbex`i'= 15 if `1'02==2 /* freie Berufe */
                replace bstbex`i'= 21 if `1'02==3 /* Selb < 9 */
                replace bstbex`i'= 23 if `1'02==4 /* Selb >= 10 */
                replace bstbex`i'= 30 if `1'02==5 /* Mithelfend */
                note bstb`i': aus `1'01-`1'05
                drop `1'01-`1'05
                mac shift
                local i=`i'+1
        }
end
exbstb ap16 bp24b cp24b dp22b ep22b fp20b gp23b hp25b ip25b jp25b

capture program drop exbst            /* weist Angabe aus alter Welle zu */
program define exbst
        local i 94
        while `i'<= 97 {
                * Missings
                gen byte bstbex`i' = -1 /*
                */ if nie`i' == 0 & est`i' >= 5 & est`i' <=7
                replace bstbex`i' = -2 /*
                */ if nie`i' == 1 & est`i' >= 5 & est`i' <=7
                replace bstbex`i' = -2 if est`i' <= 4
                local i = `i'+1
        }
        local i 85
        while `i'<= 97 {
                local j=`i'-1
                replace bstbex`i' = bstbex`j' /*
                */ if est`i' >= 5 & est`i' <= 7 /*
                */ & bstbex`j' >= -1 & bstbex`j'<= 64 & bstbex`i' == -1
                replace bstbex`i'= bstb`j' /*
                */ if (est`i' >= 5 & est`i' <=  7) & /*
                */   (bstb`j' >= -1 & bstb`j' <= 64) & bstbex`i' == -1
                lab var bstbex`i' "Ehem. berufl. Stell. Befr. `i'"
                lab val bstbex`i' bst
                local i = `i'+1
        }
end
exbst

capture program drop exisc                             /* letzter Beruf */
program define exisc
        * Missings
        gen byte iscbex84 = -1 /*
        */ if nie84 == 0 & est84 >= 5 & est84 <=7
        replace iscbex84 = -2 /*
        */ if nie84 == 1 & est84 >= 5 & est84 <=7
        replace iscbex84 = -2 /*
        */ if est84 <= 4
        replace iscbex84 = aisco /*
        */ if est84 >= 5 & est84 <= 7 & nie84 == 0 & aisco ~= -2
        local i 85
        while `i'<= 97 {
                local j=`i'-1
                gen byte iscbex`i' = -1 /*
                */ if nie`i' == 0 & est`i' >= 5 & est`i' <=7
                replace iscbex`i' = -2 /*
                */ if nie`i' == 1 & est`i' >= 5 & est`i' <=7
                replace iscbex`i' = -2 /*
                */ if est`i' <= 4
                replace iscbex`i' = -1 /*
                */ if est`i' == -1
                replace iscbex`i' = iscbex`j' /*
                */ if est`i' >= 5 & est`i' <= 7 /*
                */  & est`j' >= 5 & est`j' <= 7 /*
                */  & iscbex`j' ~= -2
                replace iscbex`i' = iscb`j' /*
                */ if est`i' >= 5 & est`i' <=  7 /*
                */  & est`j' <= 4 /*
                */  & iscb`j' ~= -2
                lab var iscbex`i' "Ehemaliger Beruf Befrager `i'"
                lab val iscbex`i' isc
                local i = `i'+1
        }
end
exisc

capture program drop pber                      /* Beruf des Partners */
program define pber
        version 5.0
        save egp, replace
        drop _all
        local i 84
        while `i' <=  97 {
                use persnr partnr`i' tod bstb`i' bstbex`i' aus`i' /*
                */  iscb`i' iscbex`i' using egp
                * Konsistenzchecks
                replace partnr`i'=55101 if partnr`i'==55103 & persnr==55102
                replace partnr`i'=103501 if partnr`i'==103503 & persnr==103502
                replace partnr`i'=731804 if partnr`i'==713804 & persnr==595303
                replace partnr`i'=5007301 if persnr==5007302 & partnr`i'==5007201
                replace partnr`i'=. if persnr==5101203 & partnr`i'== 5101201
                replace partnr`i'=. if persnr==5187703 & partnr`i'== 5187701
                replace partnr`i'=. if persnr==5188103 & partnr`i'== 5188101
                * Datensatz der Partner
                keep if partnr`i' > 0 & partnr`i' ~= .  /* Nur Partner */
                drop persnr
                ren partnr`i' persnr              /* Partner jetzt Persnr */
                ren todjahr ptodjahr
                replace ptodjahr = . if ptodjahr < 0
                ren bstb`i' bstpar`i'                     /* Partner-bst */
                replace bstpar`i' = bstbex`i' if bstpar`i' == .
                lab var bstpar`i' "(Ehem.) Berufl. Stel. Partner `i'"
                ren iscb`i' iscpar`i'                     /* Partner-isc */
                replace iscpar`i' = iscbex`i' if iscpar`i' == .
                lab var iscpar`i' "(Ehem.) Beruf Partner `i'"
                drop bstbex`i' iscbex`i'
                ren aus`i' ausp`i'                        /* Partner-aus */
                lab var ausp`i' "Partner in Ausbildung `i'"
                sort persnr
                save _u`i', replace
                local i=`i'+1
        }
        use egp
        local i 84
        while `i' <= 97 {
                sort persnr
                merge persnr using _u`i', update
                replace iscpar`i' = -2 if partnr`i' <= 0
                replace bstpar`i' = -2 if partnr`i' <= 0
                replace iscpar`i' = -1 if partnr`i' >= 0 & iscpar`i' == .
                replace bstpar`i' = -1 if partnr`i' >= 0 & bstpar`i' == .
                drop _merge
                erase _u`i'.dta
                local i=`i'+1
        }
end
pber
drop partnr*

capture program drop vpbst    /*(Ehem.) Beruf des verstorbenen Ehepartners */
program define vpbst
        gen byte bstvpa84= -2
        gen byte iscvpa84= -2
        local i 85
        while `i'<= 97 {
                local j=`i'-1
                local k=`j'-1
                * (ehemaliger) Partnerberuf im Sterbejahr
                gen byte bstvpa`i' = -2
                gen byte iscvpa`i' = -2
                replace bstvpa`i' = bstpar`i' /*
                */ if ptodjahr == 19`i'
                replace iscvpa`i' = iscpar`i' /*
                */ if ptodjahr == 19`i'
                * Wenn nicht: (ehemaliger) Partnerberuf vor Sterbejahr
                replace  bstvpa`i' = bstpar`j' /*
                */ if ptodjahr == 19`i' & bstvpa`i'== -2
                replace  iscvpa`i' = iscpar`j' /*
                */ if ptodjahr == 19`i' & iscvpa`i'== -2
                * Sterbejahr laenger her: Alte Angabe uebernehmen
                replace bstvpa`i' = bstvpa`j' /*
                */ if ptodjahr < 19`i' & ptodjahr > 0
                replace iscvpa`i' = iscvpa`j' /*
                */ if ptodjahr < 19`i' & ptodjahr > 0
                lab var bstvpa`i' "(Ehem.) berufl. Stell. verstorb Partner"
                lab var iscvpa`i' "(Ehem.) Beruf verstorb. Partner"
                lab val bstvpa`i' bst
                local i=`i'+1
        }
end
vpbst

capture program drop hbst        /*(Ehem.) Beruf des Hauptverdieners */
program define hbst
    local i 84
    while `i' <= 97 {
        * Einkommen bekannt:
        replace ein`i' = . if ein`i' == -1
        sort hnr`i' ein`i'
        quietly by hnr`i': gen bsth`i' = bstb`i'[_N] /*
        */ if hst`i'[_N] >= 0 & hst`i'[_N] <= 2 & ein`i'[_N] ~= .
        quietly by hnr`i': replace bsth`i' = bstbex`i'[_N] /*
        */ if hst`i'[_N] >= 0 & hst`i'[_N] <= 2 & ein`i'[_N] ~= . /*
        */ & bsth`i' == .
        quietly by hnr`i': gen isch`i' = iscb`i'[_N] /*
        */ if hst`i'[_N] >= 0 & hst`i'[_N] <= 2 & ein`i'[_N] ~= .
        quietly by hnr`i': replace isch`i' = iscbex`i'[_N] /*
        */ if hst`i'[_N] >= 0 & hst`i'[_N] <= 2 & ein`i'[_N] ~= . /*
        */ & isch`i' == .
        * Einkommen unbekannt: -> HV
        sort hnr`i' hst`i'
        quietly by hnr`i': replace bsth`i' = bstb`i'[1] /*
        */ if bsth`i' == .
        quietly by hnr`i': replace bsth`i' = bstbex`i'[1] /*
        */ if bsth`i' == .
        quietly by hnr`i': replace isch`i' = iscb`i'[1] /*
        */ if isch`i' == .
        quietly by hnr`i': replace isch`i' = iscbex`i'[1] /*
        */ if isch`i' == .
        replace ein`i' = -1 if ein`i' == . & hnr`i' ~= .
        local i = `i' + 1
    }
end
hbst

#delimit ;
lab def bst 70 "Azubi"
            10 "Landw." 15 "fr. Ber."  21 "Selb<10"  23 "Selb> 9"
            30 "Mithelf."
            40 "einf. B." 41 "mitl. B." 42 "gehob.B." 43 "hoeherB."
            50 "Ind. Wm." 51 "einf. A." 52 "qual. A." 53 "hqual.A."
            54 "Fuehrauf"
            60 "ungel." 61 "angel." 62 "Facharb." 63 "Vorarb." 64 "Meister"
            99 "Weiss nicht" ;
#delimit cr

*--------------------------EINORDNUNG------------ ------------------------
capture program drop einord
program define einord
        local i=84
        while `i'<=97 {
                gen byte bstp`i'=.                        /*  (nach Pappi)*/
                gen byte iscp`i'=.

                * Maenner/erwerbstaetig -> eigener Beruf
                replace bstp`i' = bstb`i' /*
                */ if sex == 1 & est`i' < 5
                replace iscp`i' = iscb`i' /*
                */ if sex == 1 & est`i' < 5

                * Maenner/nicht erwerbstaetig -> ehemaliger eigener Beruf
                replace bstp`i' = bstbex`i' /*
                */ if sex==1 & est`i' >= 5
                replace iscp`i' = iscbex`i' /*
                */ if sex==1 & est`i' >= 5

                * Maenner/noch nie erwerbstaetig/ledig -> HV-Beruf
                * (korrekt: Vaterberuf)
                replace bstp`i' = bsth`i' /*
                */ if sex == 1 & nie`i' == 1 & fam`i' == 3  /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)
                replace iscp`i' = isch`i' /*
                */ if sex == 1 & nie`i' == 1 & fam`i' == 3  /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)

                * Frauen/ledig/erwerbstaetig -> eigener Beruf
                replace bstp`i' = bstb`i' /*
                */ if sex == 2 & fam`i' == 3 & est`i' < 5
                replace iscp`i' = iscb`i' /*
                */ if sex == 2 & fam`i' == 3 & est`i' < 5

                * Frauen/ledig/nicht erwerbstaetig -> ehemaliger eig. Beruf
                replace bstp`i' = bstbex`i' /*
                */ if sex == 2 & fam`i' == 3 & est`i' >= 5
                replace iscp`i' = iscbex`i' /*
                */ if sex == 2 & fam`i' == 3 & est`i' >= 5

                * Frauen/ledig/nie erwerbstaetig -> HV-Beruf
                * (korrekt: Vaterberuf)
                replace bstp`i' = bsth`i' /*
                */ if sex == 2 & fam`i' == 3 & nie`i' == 1     /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)
                replace iscp`i' = isch`i' /*
                */ if sex == 2 & fam`i' == 3 & nie`i' == 1     /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)

                * Frauen/verheiratet -> (ehemaliger) Beruf des Ehemanns
                replace bstp`i' = bstpar`i' /*
                */ if sex==2 & fam`i'==1
                replace iscp`i' = iscpar`i' /*
                */ if sex==2 & fam`i'==1

                * Frauen/verwitwet -> (ehemaliger) Beruf des verstorb. Ehem.
                replace bstp`i' = bstvpa`i' if sex==2 & fam`i'==5
                replace iscp`i' = iscvpa`i' if sex==2 & fam`i'==5

                * Frauen/geschieden -> kann nicht zugewiesen werden
                replace bstp`i' = -1 /*
                */ if sex==2 & fam`i' == 2 | fam`i'== 4 | fam`i' == 6
                replace iscp`i' = -1 /*
                */ if sex==2 & fam`i' == 2 | fam`i'== 4 | fam`i' == 6
                lab var bstp`i' "Berufl. Stell. (Einordnung Pappi)"
                lab var iscp`i' "ISCO (Einordnung Pappi)"
                lab val bstp`i' bst

                gen byte bstt`i' = .                   /* (nach Terwey) */
                gen byte isct`i' = .

                * erwerbstaetig -> eigener Beruf
                replace bstt`i' = bstb`i' /*
                */ if est`i' < 5
                replace isct`i' = iscb`i' /*
                */ if est`i' < 5

                * nicht erwerbstaetig -> ehemaliger eigener Beruf
                replace bstt`i' = bstbex`i' /*
                */ if est`i' >= 5 & nie`i' == 0
                replace isct`i' = iscbex`i' /*
                */ if est`i' >= 5 & nie`i' == 0

                * nie erwerbstaetig/ledig/in Ausbildung -> HV-Beruf
                * (korrekt: Vaterb.)
                replace bstt`i' = bsth`i' /*
                */ if nie`i' == 1 & fam`i' == 3 & aus`i' == 1   /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)
                replace isct`i' = isch`i' /*
                */ if nie`i' == 1 & fam`i' == 3 & aus`i' == 1   /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)

                * nie erwerbstaetig/verheiratet/verwitwet -> Partnerberuf
                replace bstt`i' = bstpar`i' /*
                */ if nie`i' == 1 & fam`i' == 1
                replace bstt`i' = bstvpa`i' /*
                */ if nie`i'== 1 & fam`i' == 5
                replace isct`i' = iscpar`i' /*
                */ if nie`i' == 1 & fam`i' == 1
                replace isct`i'= iscbex`i' /*
                */ if nie`i' == 1 & fam`i' == 1 & isct`i' ==.
                replace isct`i'= iscvpa`i' /*
                */ if nie`i' == 1 & fam`i' == 5

                * Ehepartner Schueler/Student usw.: -> HV-Beruf
                * (korrekt: Vaterberuf)
                replace bstt`i' = bsth`i' /*
                */ if nie`i' == 1 & fam`i' == 1 & ausp`i' == 1  /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)
                replace isct`i' = isch`i' /*
                */ if nie`i' == 1 & fam`i' == 1 & ausp`i' == 1  /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)

                * Zusatz Kohler:
                * nie erwerbstaetig/ledig/nicht in Ausbildung/Kind o. Enkel
                *  -> HV-Beruf
                replace bstt`i' = bsth`i' /*
                */ if nie`i' == 1 & fam`i' == 3 & aus`i' == 0   /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)
                replace isct`i' = isch`i' /*
                */ if nie`i' == 1 & fam`i' == 3 & aus`i' == 0   /*
                */ & (hst`i' == 3 | hst`i' == 4 | hst`i' == 9)

                * nie erwerbstaetig/nicht in Ausbildung/sonst nicht zugew.
                * -> keine Zuordnungsregel
                replace bstt`i' = -2 /*
                */ if nie`i' == 1 & aus`i' == 0 & bstt`i' == .
                replace isct`i' = -2 /*
                */ if nie`i' == 1 & aus`i' == 0 & isct`i' == .

                lab var bstt`i' "Berufl. Stell. (Einordnung Terwey)"
                lab var isct`i' "ISCO (Einordnung Terwey)"
                lab val bstt`i' bst
                local i = `i'+1
        }
end
einord

save peigen, replace

*-----------------------SPEICHERN---------------------------------------
capture program drop svdat
program define svdat
    local i 84
    while `i'<=97 {
        use hhnr hnr`i' persnr `1'netto bstb`i' iscb`i' bsth`i' isch`i' /*
        */ bstp`i' iscp`i' bstt`i' isct`i' bstbex`i' iscbex`i' bstpar`i' /*
        */ iscpar`i' bstvpa`i' iscvpa`i' if `1'netto==1 using peigen, clear
        ren hnr`i' hhnrakt
        sort hhnr hhnrakt persnr
        merge hhnr hhnrakt persnr using $soepdir/`1'peigen
        assert _merge==3
        drop `1'netto _merge
        compress
        sort hhnr hhnrakt persnr
        order hhnr hhnrakt persnr bul`i' hst`i' fam`i' bil`i' bbil`i' /*
        */ bdauer`i' est`i' nie`i' bstb`i' iscb`i' bsth`i' isch`i' /*
        */ bstp`i' iscp`i' bstt`i' isct`i' bstbex`i' iscbex`i' bstpar`i' /*
        */ iscpar`i' bstvpa`i' iscvpa`i' aus`i' hhein`i' ein`i'
        save $soepdir/`1'peigen, replace
        local i = `i'+1
        mac shift
    }
end
svdat a b c d e f g h i j k l m n

erase peigen.dta

exit

-------------------------------------------------------------------------

\subsection{Berufliche Stellung}

Die Vercodung der beruflichen Stellung im SOEP l"a"st Mehrfachangaben
prinzipiell zu.  Faktisch sind dieser aber nur in den Jahren 1984 und
1994 vorhanden. Diese beziehen sich in den meisten F"allen auf
Kombinationen von diversen berufl. Stellungen mit den unterschiedl.
Selbst"andigen--Kategorien. Hier wurde dem Selbst"andigen--Status stets
Vorrang einger"aumt. In den "ubrigen F"allen wurde zus"atzlich die
Information des ISCO-Codes eingeholt und gem"a"s der folgenden "Ubersicht
zugeordnet:

\begin{verbatim}
1984 (komplett nach Selbst"andigen-Regel):
 persnr  Arbeiter   Selbst.   Auszub.   Angest.    Beamte   ->     bst
 ------------------------------------------------------------------------
   9801      tnz   fr. Ber.       tnz  hqual.A.       tnz   ->    fr. Ber.
 104402      tnz   Mithelf.       tnz   qual.A.       tnz   ->    Mithelf.
 227301      tnz     Selb>9       tnz  F"uhrauf       tnz   ->     Selb> 9
 280601  Meister   Mithelf.       tnz       tnz       tnz   ->    Mithelf.
 280603  Meister    Selb<10       tnz       tnz       tnz   ->     Selb<10
 315801  Meister    Selb<10       tnz       tnz       tnz   ->     Selb<10
 344401      tnz    Selb<10       tnz  qual. A.       tnz   ->     Selb<10
 348603      tnz   Mithelf.       tnz  einf. A.       tnz   ->     Selb<10
 365301  Meister    Selb<10       tnz       tnz       tnz   ->    Mithelf.
 410101      tnz    Selb<10     Azubi       tnz       tnz   ->     Selb<10
 407001   ungel.   Landwirt       tnz       tnz       tnz   ->    Landwirt
 445901      tnz     Selb>9       tnz  hqual.A.       tnz   ->     Selb> 9
 452101   angel.   Landwirt       tnz       tnz       tnz   ->    Landwirt
 473301 Facharb.    Selb<10       tnz       tnz       tnz   ->     Selb<10
 479802      tnz   Mithelf.       tnz   qual.A.       tnz   ->    Mithelf.
 574701   ungel.     Landw.       tnz       tnz       tnz   ->      Landw.


1994 (Selbstaendigen--Regel)
 persnr  Arbeiter   Selbst.   Auszub.   Angest.    Beamte   ->      bst
 -------------------------------------------------------------------------
  28801   ungel.     Landw.     Azubi  hqual.A.       tnz   ->      Landw.
  33203      tnz    Selb<10       tnz  hqual.A.       tnz   ->     Selb<10
  34502 Facharb.    Selb<10       tnz       tnz  mitl. B.   ->     Selb<10
  75404   angel.   Mithelf.       tnz       tnz       tnz   ->    Mithelf.
  80603  Meister    Selb<10       tnz       tnz       tnz   ->     Selb<10
  94705      tnz    Selb<10       tnz  hqual.A.       tnz   ->     Selb<10
 106001      tnz    Selb<10       tnz  F"uhrauf       tnz   ->     Selb<10
 198403      tnz    Selb<10       tnz  F"uhrauf       tnz   ->     Selb<10
 336301 Facharb.   Mithelf.       tnz       tnz       tnz   ->    Mithelf.
 344202   angel.    Selb<10       tnz       tnz       tnz   ->     Selb<10
 608302   ungel.     Landw.       tnz       tnz       tnz   ->      Landw.
5107102   angel.   Mithelf.       tnz       tnz       tnz   ->
5124101 Facharb.    Selb<10       tnz       tnz       tnz   ->

1994 (+ ISCO):
 persnr  Arbeiter Auszub.   Angest.    Beamte  isco ->      bst
 --------------------------------------------------------------
 521802   ungel.      tnz  einf. A.       tnz   134  ->  einf. A.
 319101   angel.      tnz   qual.A.       tnz   551  ->    angel.
 355305   angel.      tnz  einf. A.       tnz   842  ->    angel.
 372101   angel.      tnz  einf. A.       tnz    -1  ->       -1
5074002   angel.      tnz  einf. A.       tnz   451  ->   einf.A.
5082404   angel.      tnz  einf. A.       tnz   842  ->    angel.
 363601 Facharb.      tnz   qual.A.       tnz   Unzu ->       -1
 442203 Facharb.      tnz  einf. A.       tnz   Unzu ->       -1
 464302 Facharb.      tnz  einf. A.       tnz   570  ->   einf.A.
5035902 Facharb.      tnz      tnz    mitl. B.  394  ->   mitl.B.
5082002 Facharb.      tnz  qual. A.       tnz   773  ->  Facharb.
5168301 Facharb.      tnz  qual. A.       tnz   922  ->  Facharb.
5172602 Facharb.      tnz  einf. A.       tnz   393  ->   einf.A.
#518403  Vorarb.      tnz  hqual.A.       tnz   421  ->  hqual.A.
5007902  Vorarb.      tnz  einf. A.       tnz   874  ->   Vorarb.
 142801  Vorarb.      tnz   qual.A.       tnz   951  ->   Vorarb.
 304103 Facharb.    Azubi  einf. A.       tnz   540  ->     Azubi
  10803      tnz    Azubi       tnz  mitl. B.   582  ->     Azubi
 165903      tnz    Azubi       tnz  mitl. B.   582  ->     Azubi
 811602      tnz    Azubi       tnz  mitl. B.   Unzu ->     Azubi
5202102      tnz    Azubi       tnz  Gehob.Di   310  ->     Azubi
 173803      tnz    Azubi  einf. A.       tnz   Unzu ->     Azubi
5403702      tnz    Azubi  einf. A.       tnz    -1  ->     Azubi
 527805      tnz    Azubi  qual. A.       tnz   Unzu ->     Azubi
5126702      tnz    Azubi  qual. A.       tnz   134  ->     Azubi
  2801      tnz      tnz   qual.A.      k.A.    75  ->   qual. A.
138603      tnz      tnz  F"uhrauf   h"oherB   Unzu ->         -1
\end{verbatim}

Sechsmal finden sich Angaben zum Beruf, obwohl die Personen nicht
erwerbst"atig waren. Diese Angaben wurden jeweils den Missing--Code $ -2 $
gesetzt:

\begin{verbatim}
          persnr  est88      bst88      isco88
    261.   36001  not erw.   fr. Ber.   -2       -> bst88= -2
   2506.  283302  not erw.   einf. A.   -2       -> bst88= -2
  11207.  391403  not erw.    angel.    -2       -> bst88= -2
  13032.  452104  not erw.    ungel.    -2       -> bst88= -2

          persnr  est96      bst96      isco96
   1272.  153301  not erw.   mitl. B.  Unzul"an  -> bst96= -2
  12138.  420002  not erw.   hqual.A.   -2       -> bst96= -2
\end{verbatim}

Ab dem Erhebungsjahr 1991 werden einfache Angestellte in einfache
Angestellte mit und ohne Ausbildungsabschlu"s untergliedert. Diese Katgorien
wurden zu einer Kategorie zusammengefa"st.

\subsection{Ehemaliger Beruf und ehemalige Berufliche Stellung}

F"ur alle nicht Erwerbst"atigen (incl.\ Erziehungsurlaub, Mutterschutz,
Wehr- und Zivildienst) wird --- falls vorhanden --- der zuletzt ausge"ubte
Beruf ermittelt. Die ehemalige {\em berufliche Stellung\/} konnte
prinzipiell f"ur alle Befragungspersonen ermittelt werden. Die
Nicht--Erwerbst"atigen der Welle 1984 und die "neuen" Befragungspersonen
sp"aterer Erhebungsjahre wurden mit den Antworten auf die entsprechenden
Fragen verkodet. Bei Befragungspersonen, deren Erwerbst"atigkeit w"ahrend
der Befragungszeit endete, wurde die vorhergehende Angabe verwendet.

Anders als bei der beruflichen Stellung kann der {\em ehemalige
Beruf\/} nur f"ur "`alte"' Befragte oder w"ahrend des
Erhebungszeitraums erwerbslos werdende Befragte ermittelt werden.  Der
ehemalige Beruf wird dann durch die entsprechende Frage in Welle 1 oder
--- falls die Berufst"atigkeit w"ahrend des Erhebungszeitraums endete ---
durch die letzte Angabe ermittelt. F"ur "`neue"` Befragungspersonen,
deren Erwerbst"atigkeit nicht w"ahrend der Befragungszeit endete, kann
dagegen kein ehemaliger Beruf ermittelt werden.

\subsection{Partnerberuf}

Partnerberuf ist der Beruf des mit einer Person zusammenlebenden Partners,
gleichg"ultig ob die Person mit diesem verheiratet ist oder nicht. Unter
Partnerschaft wird hier eine reziproke Beziehung verstanden. Die
Bestimmung des Partners erfolgt durch die Variable "partnr" in den
generierten Datenfiles.  Die Qualit"at der Partnerschaft in der Variable
Partnerzeiger bleibt unber"ucksichtig.

Neben der "ublichen Missing--Definition gilt zus"atzlich:
Der Partnerberuf ist -2, wenn es keinen Partner gibt und -1, wenn keine
die Partnernummer nicht bekannt ist.

Konsitenzchecks: Folgende Einzelheiten sind zu
beachten:

Die Partnernummer verwei"st in drei F"allen auf einen Partner, der im
Bruttobestand von ppfad nicht verzeichnet ist. Diese Beobachtungen wurden
folgt behandelt:

\begin{verbatim}
Observation 1437

      persnr        55102    partnr84        55103    partnr85            .
    partnr86            .    partnr87            .    partnr88            .
    partnr89            .    partnr90            .    partnr91            .
    partnr92            .    partnr93            .    partnr94            .
    partnr95            .    partnr96            .
\end{verbatim}

Der Wert 55103 wurde auf 55101 gesetzt, einer 1909 geborenen, m"annlichen
Person, die nie ein Interview mitgemacht hat. Person 55101 ist eine 1916
geborene weibliche, nicht erwerbst"atige Person, die im selben Haushalt
wie 55102 lebt.

\begin{verbatim}
Observation 2899

      persnr       103502    partnr84       103503    partnr85       103501
    partnr86            0    partnr87            0    partnr88            0
    partnr89            0    partnr90            0    partnr91           -2
    partnr92           -2    partnr93           -2    partnr94           -2
    partnr95           -2    partnr96           -2
\end{verbatim}

Die Angabe 103503 in 1984 wurde auf 103501 wie in 1985 gesetzt.

\begin{verbatim}
Observation 18736

      persnr       595303    partnr84            0    partnr85            0
    partnr86            0    partnr87       713804    partnr88       731804
    partnr89       731804    partnr90       731804    partnr91       731804
    partnr92       731804    partnr93       731804    partnr94       731804
    partnr95       731804    partnr96       731804
\end{verbatim}

Die Angabe 713804 in 1987 wurde auf 731804 gesetzt.

In 4 F"allen verweist die partnr zweier unterschiedlicher Personen
auf eine Person. Die entsprechende Partnernummer ist also doppelt besetzt.
F"ur die Korrektur dieser F"alle wurde angenommen, da"s eine Partnerschaft
nur bestehen soll, wenn sie gegenseitig ist. Es handelt sich dabei um
folgende F"alle:

\begin{verbatim}
        persnr    hhnr  partnr91  hfamstd
 9616. 5007202  500720  5007201  verh. zu   <-- Note partnr91
 9617. 5007301  500739  5007302  verh. zu
 9618. 5007302  500739  5007201  -1         <-- Note partnr91
\end{verbatim}

Da die persnr 5007302 in einem anderen Haushalt als der angegebene Partner
lebt und persnr==5007301 im selben Haushalt wie 5007302 lebt, wurde die
partnr91 f"ur persnr==5007302 auf 5007301 gesetzt.

\begin{verbatim}
       persnr    hhnr  partnr91  hfamstd
11497. 5101201  510122  5101202  verh. zu
11498. 5101202  510122  5101201  verh. zu    <-- Note partnr91
11499. 5101203  510122  5101201  ledig       <-- Note partnr91
\end{verbatim}

Nur die Partnerschaft von 5101201 und 5101201 ist gegenseitig. Die Angabe
von 510203 wurde daher auf missing gesetzt.

\begin{verbatim}
        persnr    hhnr  partnr91  hfamstd
13174. 5188101  518816  5188102  verh. zu
13175. 5188102  518816  5188101  verh. zu       <-- Note partnr91
13176. 5188103  518816  5188101  ledig          <-- Note partnr91
\end{verbatim}

Nur die Partnerschaft von 5188101 und 5188102 ist gegenseitig. Die Angabe
von 5188103 wurde daher auf missing gesetzt.

\begin{verbatim}
        persnr    hhnr  partnr91  hfamstd
13167. 5187701  518778   5187702  verh. zu
13168. 5187702  518778   5187701  verh. zu      <-- Note partnr91
13169. 5187703  518778   5187701  verwitwe      <-- Note partnr91
\end{verbatim}

Nur die Partnerschaft von 5187701 und 5187702 ist gegenseitig. Die Angabe
von 557703 wurde daher auf missing gesetzt.

\subsection{Beruf des verstorbenen Partners}

Der Beruf des verstorbenen Partners kann bestimmt werden, wenn der Partner
w"ahrend der Erhebungszeit des SOEP gestorben ist. Die Bestimmung des
Partners erfolgt analog zum Partnerberuf.

Das Todesjahr des Partners ist individuell variabel, da die Partner
w"ahrend der Laufzeit wechseln k"onnen. Theoretisch k"onnten pro Befragter
mehrer Todes- jahre auftreten, wenn im Erhebungszeitraum mehr als ein
Partner eines Befragten gestorben ist. Tats"achlich war dies aber nicht der
Fall. Die Todesjahr-Angabe war entweder konstant, wechselte zwischen
inhaltlichem Wert und Missing-Code -1, -2, oder zwischen den
Missing-Codes. In der Variable "`ehemaliger Beruf des verstorbenen
Partners'" wird darum die zuletzt verf"ugbare Angabe eines verstorbenen
Partners abgelegt. Dies ist insofern problematisch, als die Variable auch
dann einen inhaltlichen Wert aufweist, wenn ein neuer Partner gefunden
wurde.  Das Vorgehen wurde gew"ahlt, weil die Problematik eines neuen
Partners sinnvoller innerhalb der der Einordnungsberufe selbst behandelt
wird.

Bei 269 F"allen finden sich keine Angaben f"ur den (ehemaligen) Beruf
des Partners im oder ein Jahr vor dem Todesjahr. Bei diesen F"allen wurde
vpbst nicht vercodet.


\subsection{Beruf des Hauptverdieners}\label{hauptverdiener}

Hauptverdiener ist diejenige Person des aktuellen Haushalts, deren
berufsbezogenes pers"onliches Bruttoeinkommen (siehe \ref{ein} am h"ochsten
ist. Dabei wird das pers"onliche Bruttoeinkommen des abgelaufenen
alenderjahrs zugrunde gelegt.

Der Hauptverdiener wird nur zwischen den Haushaltsvorst"anden
und deren (Ehe-) Partner ermittelt. Dies f"uhrt dazu, da"s in Haushaltungen,
in denen nur Kinder oder Enkelkinder Interviewt wurden, der Beruf des
Hauptverdieners nicht ermittelt werden konnte. Dies betrifft pro Welle
jeweils um die 20 Befragte. Diese F"alle erhalten den Missing--Code -1.

\subsection{Einordnung nach Pappi}

Der Einordnungsberuf nach Pappi erfolgt korrekt nach folgenden Regeln:

\begin{verbatim}
M"anner
    erwerbst"atig            -> eigener Beruf
    nicht erwerbst"atig      -> ehem. eigener Beruf
    nie erwerbst"atig/ledig  -> Vaterberuf ( -> a )
Frauen
    ledig
        erwerbst"atig        -> eigener Beruf
        nicht erwerbst"atig  -> ehem. eigener Beruf
        nie erwerbst"atig    -> Vaterberuf ( -> a )
    verheiratet              -> (ehem.) Beruf des Ehemanns (-> b )
    verwitwet                -> (ehem.) Beruf des verstorbenen Ehemanns (-> c)
    geschieden               -> (ehem.) Beruf des gesch. Ehepartners (-> d)
\end{verbatim}

(a) Verwendet wurde der Beruf des Hauptverdieners, nicht der Vaterberuf,
da f"ur nicht im Haushalt lebende V"ater der Vaterberuf nur f"ur Teilnehmer
der Welle C in Form der berufliche Stellung des Vaters im Alter von
15 Jahren vorliegt.

(b) Verwendet wurde der Beruf des Partners. Dies f"uhrt zu Abweichungen bei
verheirateten Frauen, die nicht mit ihren Ehepartner sondern mit einem
anderen Partner zusammenleben.

(c) Verwendet wurde der Beruf des verstorbenen Partners. Dies f"uhrt zu
Abweichungen, wenn eine verwitwete Frau mit einem Partner zusammenlebte
und dieser w"ahrend des Untersuchungszeitraums starb.

(d) Die Zuordnung eines (ehemaligen) Berufs des geschiedenen Ehepartners
ist nicht m"oglich, da die Partnernummer nicht unbedingt auf den
geschiedenen Ehepartner verweisen mu"s. Es kann daher nicht gekl"art werden,
ob sich die vor dem Zeitpunkt der Scheidung angegebene Partnernr auf den
ehemaligen Ehepartner oder auf einen etwaigen neuen Partner bezieht.


\subsection{Einordnung nach Terwey}

Der Einordnungsberuf nach Terwey erfolgt korrekt nach folgenden
Regeln:

\begin{verbatim}
erwerbst"atig                   -> eigener Beruf
nicht erwerbst"atig     -> ehemaliger eigener Beruf
nie erwerbst"atig
    ledig
        in Ausbildung   -> Vaterberuf (-> a)
    verheiratet         -> Beruf Ehepartner (-> b)
        Ehep. in Ausb.  -> Vaterberuf ( -> a)
    verwitwet           -> Beruf ehem. Ehepartner (-> c)
\end{verbatim}

Nicht zugeordnet werden hierdurch insbesondere die nie Erwerbst"atigen, die
sich nicht oder nicht mehr in einer Ausbildung befinden und nicht verheiratet
oder verwitwet sind.

(a) Verwendet wurde der Beruf des Hauptverdieners, nicht der Vaterberuf.

(b) Verwendet wurde der Beruf des Partners, nicht des Ehepartners. Dies
f"uhrt zu Abweichungen bei verheirateten Frauen, die nicht mit ihren
Ehepartner sondern mit einem anderen Partner zusammenleben.

(c) Verwendet wurde der Beruf des verstorbenen Partners. Dies f"uhrt zu
Abweichungen, wenn eine verwitwete Frau mit einem Partner zusammenlebte,
der nicht ihr Ehepartner war und dieser dieser w"ahrend des
Untersuchungszeitraums starb.

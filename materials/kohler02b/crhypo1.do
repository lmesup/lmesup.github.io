version 5.0
set more off
clear

* Hypothese:                                                      /*

 */ "Die PID ver„ndert sich bei einem Stellungswechsel auch dann  /*
 */  wenn kein Klassenwechsel stattgefunden hat.

* mit Variablen des Sozio”konomischen Panels, L„ngsschnitt, balanced,


#delimit ;
* Datensatz enthaehlt:
Bundesland
Politisches Interesse
Allgemeine Parteienpraeferenz
Praeferenz fuer welche Partei
Staerke Parteizuneigung
Erwerbsstatus
Arbeiter
Selbstaendiger
Auszubildende,Praktikanten
Angestellter
Beamter
Letzte berufliche Stellung:Selbstaendige
Letzte berufliche Stellung: Arbeiter
Letzte berufliche Stellung:Auszubildende
Letzte berufliche Stellung: Beamte
Letzte berufliche Stellung: Angestellte
Wechsel innerhalb des Unternehmens 84
Wechsel innerhalb des Unternehmens 84
Neuer Arbeitgeber
Neuer Arbeitgeber
Erstmas Berufstaetig
Erstmas Berufstaetig
Keine Veraenderung
seit Welle  K: Veraenderungstyp
Einzugsjahr

*--------------------------RETRIVAL---------------------------------------;
* Erstellt wird ein Laengsschnittdatensatz mit balanced Paneldesign,
Wellen a-m ;

mkdat
_X13 BP75 CP75 DP84 EP73 FP89 GP83 HP89 IP89 JP89 KP91 LP97 MP83
AP5601 BP7901 CP7901 DP8801 EP7701 FP9301 GP8501 HP9001 IP9001 JP9001 KP9201
       LP9801 MP8401
AP5602 BP7902 CP7902 DP8802 EP7702 FP9302 GP8502 HP9002 IP9002 JP9002 KP9202
       LP9802 MP8402
AP5603 BP7903 CP7903 DP8803 EP7703 FP9303 GP8503 HP9003 IP9003 JP9003 KP9203
       LP9803 MP8403
AP2801 BP3801 CP4601 DP3801 EP3801 FP3801 GP3701 HP4801 IP4801 JP4801 KP5101
       LP4301 MP4101
AP2802 BP3802 CP4602 DP3802 EP3802 FP3802 GP3702 HP4802 IP4802 JP4802 KP5102
       LP4302 MP4102
AP2803 BP3803 CP4603 DP3803 EP3803 FP3803 GP3703 HP4803 IP4803 JP4803 KP5103
       LP4303 MP4103
AP2804 BP3804 CP4604 DP3804 EP3804 FP3804 GP3704 HP4804 IP4804 JP4804 KP5104
       LP4304 MP4104
AP2805 BP3805 CP4605 DP3805 EP3805 FP3805 GP3705 HP4805 IP4805 JP4805 KP5105
       LP4305 MP4105
AP1602 BP24B02 CP24B02 DP22B02 EP22B02 FP20B02 GP23B02 HP25B02 IP25B02
       JP25B02 _X14 _X19 _X24
AP1601 BP24B01 CP24B01 DP22B01 EP22B01 FP20B01 GP23B01 HP25B01 IP25B01
       JP25B01 _X15 _X20 _X25
AP1603 BP24B03 CP24B03 DP22B03 EP22B03 FP20B03 GP23B03 HP25B03 IP25B03
       JP25B03 _X16 _X21 _X26
AP1605 BP24B05 CP24B05 DP22B05 EP22B05 FP20B05 GP23B05 HP25B05 IP25B05
       JP25B05 _X17 _X22 _X27
AP1604 BP24B04 CP24B04 DP22B04 EP22B04 FP20B04 GP23B04 HP25B04 IP25B04
       JP25B04 _X18 _X23 _X28
_X29 BP22G01 CP22G01 DP20G01 EP20G09 FP18G09 GP21G09 HP23G11 IP23G11
       JP23G11 _X37 _X45 _X52
_X30 BP22G02 CP22G02 DP20G02 EP20G10 FP18G10 GP21G10 HP23G12 IP23G12
       JP23G12 _X38 _X46 _X53
_X31 BP22G03 CP22G03 DP20G03 EP20G05 FP18G05 GP21G05 HP23G05 IP23G05
       JP23G05 _X39 _X47 _X54
_X32 BP22G04 CP22G04 DP20G04 EP20G06 FP18G06 GP21G06 HP23G06 IP23G06
       JP23G06 _X40 _X48 _X55
_X70 BP22G07 CP22G07 DP20G07 EP20G03 FP18G03 GP21G03 HP23G03 IP23G03
       JP23G03 _X72 _X73 _X74
_X71 BP22G08 CP22G08 DP20G08 EP20G04 FP18G04 GP21G04 HP23G04 IP23G04
       JP23G04 _X75 _X76 _X77
_X33 BP22G09 CP22G09 DP20G09 EP20G01 FP18G01 GP21G01 HP23G01 IP23G01
       JP23G01 _X41 _X49 _X56
_X34 BP22G10 CP22G10 DP20G10 EP20G02 FP18G02 GP21G02 HP23G02 IP23G02
       JP23G02 _X42 _X50 _X57
_X35 BP22G11 CP22G11 DP20G11 EP20G11 FP18G11 GP21G11 HP23G13 IP23G13
       JP23G13 _X43 _X51 _X58
_X36 _X60 _X61 _X62 _X63 _X64 _X65 _X66 _X67 _X44 KP39
        LP31 MP29
_X80 _X81 _X82 _X83 _X84 _X85 _X86 _X87 _X88 _X89 KP37
        LP29 MP27
AP08 BP09 CP05 DP05 EP05 FP06 GP09 HP07 IP09 JP09 KP16 LP13 MP12
_X68 BP16 CP16 DP12 EP12 FP10 GP12 HP15 IP15 JP15 KP25 LP21 MP15
_X90 BPMONIN CPMONIN DPMONIN EPMONIN FPMONIN GPMONIN HPMONIN IPMONIN
        JPMONIN KPMONIN LPMONIN MPMONIN

using $soepdir ,
waves(a b c d e f g h i j k l m) files(p) netto(1) uc
keep(sex gebjahr) ;

holrein
ABULA
using $soepdir, files(pbrutto) waves(a) uc ;

holrein
BBULA CBULA DBULA EBULA FBULA GBULA HBULA IBULA JBULA KBULA LBULA MBULA
using $soepdir, files(hbrutto) waves(b c d e f g h i j k l m) uc ;

holrein
aeinzug beinzug ceinzug deinzug eeinzug feinzug geinzug heinzug ieinzug
jeinzug keinzug leinzug meinzug
using $soepdir, files(hgen) waves(a b c d e f g h i j k l m) uc ;

holrein
NATION84 NATION85 NATION86 NATION87 NATION88 NATION89 NATION90 NATION91
NATION92 NATION93 NATION94 NATION95 NATION96
using $soepdir , files(pgen) waves(a b c d e f g h i j k l m) uc;

#delimit cr

*--------------------------REKODIERUNGEN--------------------------------
*                                                           LINKS-RECHTS

capture program drop lr1
program define lr1
        version 5.0
        local varlist "req ex"
        parse "`*'"
        parse "`varlist'", parse(" ")
        quietly for -1 -2 -3, l(a): mvdecode `varlist', mv(@)
        local i 84
        while "`15'"~="" {                          /* PI Quant. = leer */
                gen lr`i'= -1 if `8'==1             /* PI Qual. = SPD */
                replace lr`i'= 1 if `8'>=2 & `8'<=4 /* PI Qual. = CDU | CSU */
                replace lr`i'= lr`i' * (5+1-`15')  /* Li-Re*Quant. (spiegel)*/
                replace lr`i'= 0 if `1'==2          /* PI ja/nein = nein  */
                local i=`i'+1
                mac shift
        }
end

#delimit ;
quietly lr1                                         /*
*/ ap5601 bp7901 cp7901 dp8801 ep7701 fp9301 gp8501 /*
*/ ap5602 bp7902 cp7902 dp8802 ep7702 fp9302 gp8502 /*
*/ ap5603 bp7903 cp7903 dp8803 ep7703 fp9303 gp8503 ;
#delimit cr

* Spezielle Variablenstruktur in Welle H
quietly for -1 -2 -3, l(a): mvdecode hp9001 hp9002 hp9003, mv(@)
gen lr91=-1 if hp9002==1
replace lr91= 1 if hp9002==2
replace lr91= lr91 * (5+1-hp9003) /*<- Gespiegelte hp9003 */
replace lr91=0 if hp9001==2

* Neue Regelmaessigkeit ab Welle I
capture program drop lr2
program define lr2
        version 5.0
        local varlist "req ex"
        parse "`*'"
        parse "`varlist'", parse(" ")
        quietly for -1 -2 -3, l(a): mvdecode `varlist', mv(@)
        local i 92
        while "`11'"~="" {                         /* PI Quant. = leer */
                gen lr`i'= -1 if `6'==1             /* PI Qual. = SPD  */
                replace lr`i'= 1 if `6'==2 | `6'==3 /* PI Qual. = CDU | CSU */
                replace lr`i'= lr`i' * (5+1-`11')  /* Li-Re*Quant. (spiegel)*/
                replace lr`i'= 0 if `1'==2             /* PI ja/nein = nein */
                local i=`i'+1
                mac shift
        }
end

#delimit ;
quietly lr2
ip9001 jp9001 kp9201 lp9801 mp8401
ip9002 jp9002 kp9202 lp9802 mp8402
ip9003 jp9003 kp9203 lp9803 mp8403 ;
#delimit cr

capture program drop spiegeln
program define spiegeln
        version 5.0
                while "`1'"~="" {
                        replace lr`1' = lr`1'+ 6
                        lab var lr`1' "SPD-CDU Ident. `1'
                        lab val lr`1' lr
                        macro shift
                }
end

spiegeln 84 85 86 87 88 89 90 91 92 93 94 95 96
lab def pid 2 "SPD" 5 "Keine" 10 "CDU"

*                                                          QUANTITAET PID
capture program drop pii
program define pii
        version 5.0
        local i 84
        while `i'<=96 {
                gen pii`i'=`1'03 if `1'03>0 & `1'03~=.
                replace pii`i'=7-pii`i'
                replace pii`i'=1 if `1'01==2
                local i=`i'+1
                mac shift
        }
end

quietly pii ap56 bp79 cp79 dp88 ep77 fp93 gp85 hp90 ip90 jp90 kp92 lp98 mp84

quietly for 84-96, l(n) quote(!): lab var pii@ !PI-Intensitaet @!
quietly for 84-96, l(n): lab val pii@ pii
lab def pii 1 "Keine" 2 "s.schwach" 3 "schwach" 4 "maessig"  5 "stark" /*
*/          6 "s.stark"


*                                                     POLITISCHES INTERESSE
quietly for -1 -2 -3, l(a): mvdecode   /*
*/ bp75 cp75 dp84 ep73 fp89 gp83 hp89 ip89 jp89 kp91 lp97 , mv(@)

capture program drop spiegeln
program define spiegeln
        version 5.0
                local i 85
                while "`1'"~="" {
                        replace `1'=5 - `1'
                        ren `1' polint`i'
                        lab var polint`i' "Politisches Interesse"
                        lab val polint`i' polint
                        local i=`i'+1
                        macro shift
                }
end

quietly spiegeln bp75 cp75 dp84 ep73 fp89 gp83 hp89 ip89 jp89 kp91 lp97 mp83
quietly lab def polint 1 "Keins" 2 "Schwach" 3 "Stark" 4 "S.Stark"

*                                                          ERWERBSSTATUS
gen erw84=ap08 if ap08>0     /* Welle A */
replace erw84=8 if erw84==5

capture program drop erw     /* Welle B - G */
program define erw
        version 5.0
        local i 85
        while `i'<=90 {
                gen erw`i'=1 if `1'==1      /*erwerbstaetig*/
                replace erw`i'=2 if `1'==2  /*Teilzeit*/
                replace erw`i'=3 if `1'==3  /*Ausbildung usw.*/
                replace erw`i'=4 if `1'==4  /*geringfuegig*/
                replace erw`i'=6 if `1'==6  /*Wehr/Zivildienst*/
                replace erw`i'=7 if `1'==7  /*Nicht erwerbstaetig*/
                replace erw`i'=8 if `7'==1  /*arbeitslos gemeldet*/
                local i=`i'+1
        }
end

quietly erw bp09 cp05 dp05 ep05 fp06 gp09 bp16 cp16 dp12 ep12 fp10 gp12

capture program drop erw     /* Welle H - M */
program define erw
        version 5.0
        local i 91
        while `i'<=96 {
                gen erw`i'=1 if `1'==1 | `1'==2      /*erwerbstaetig*/
                replace erw`i'=2 if `1'==3  | `1'==4 /*Teilzeit*/
                replace erw`i'=3 if `1'==5           /*Ausbildung usw.*/
                replace erw`i'=4 if `1'==6           /*geringfuegig*/
                replace erw`i'=5 if `1'==7           /*Erziehungsurlaub*/
                replace erw`i'=6 if `1'==8           /*Wehr/Zivildienst*/
                replace erw`i'=7 if `1'==9           /*Nicht erwerbstaetig*/
                replace erw`i'=8 if `7'==1           /*arbeitslos gemeldet*/
                local i=`i'+1
        }
end

quietly erw hp07 ip09 jp09 kp16 lp13 mp12 hp15 ip15 jp15 kp25 lp21 mp15

quietly for 84-96, l(n) quote(!): lab var erw@ !Erwerbsstatus @!
quietly for 84-96, l(n): lab val erw@ erw
lab def erw 1 "erwerbst" 2 "teilzeit" 3 "Ausb." 4 "geringf."  5 "Erz.url." /*
*/          6 "WZDienst" 7 "n.erwerb" 8 "arb.los"

*                                                     BERUFLICHE STELLUNG
* Mehrfachnennungen moeglich. Empirisch jedoch nur zwischen mit den
* Selbstaendigen-Kategorien vorkommend. Selbstaendige wird grundsaetzlich
* als staerkste Kategorie angesehen

capture program drop crbest
program define crbest                            /* Berufliche Stellung */
        version 5.0
        local i 84
        while `i'<=93 {
                gen bst`i'=1 if `1'01==1 | `11'01==1       /*Arbeiter*/
                replace bst`i'= 2 if `1'01==2 | `11'01==2
                replace bst`i'= 3 if `1'01==3 | `11'01==3
                replace bst`i'= 4 if `1'01==4 | `11'01==4
                replace bst`i'= 5 if `1'01==5 | `11'01==5
                replace bst`i'=40 if `1'03==1 | `11'03==1 /*Azubi*/
                replace bst`i'=41 if `1'03==2 | `11'03==2
                replace bst`i'=10 if `1'04==1 | `11'04==1 /*Angestellte*/
                replace bst`i'=11 if `1'04==2 | `11'04==2
                replace bst`i'=12 if `1'04==3 | `11'04==3
                replace bst`i'=13 if `1'04==4 | `11'04==4
                replace bst`i'=14 if `1'04==5 | `11'04==5
                replace bst`i'=20 if `1'05==1 | `11'05==1 /*Beamte*/
                replace bst`i'=21 if `1'05==2 | `11'05==2
                replace bst`i'=22 if `1'05==3 | `11'05==3
                replace bst`i'=23 if `1'05==4 | `11'05==4
                replace bst`i'=30 if `1'02==1 | `11'02==1 /*Selbstaendige*/
                replace bst`i'=31 if `1'02==2 | `11'02==2
                replace bst`i'=32 if `1'02==3 | `11'02==3
                replace bst`i'=33 if `1'02==4 | `11'02==4
                replace bst`i'=34 if `1'02==5 | `11'02==5
                lab var bst`i' "Berufliche Stellung"
          lab val bst`i' bst
          macro shift
          local i=`i'+1
}
end

#delimit ;
quietly crbest
ap28 bp38 cp46 dp38 ep38 fp38 gp37 hp48 ip48 jp48
ap16 bp24b cp24b dp22b ep22b fp20b gp23b hp25b ip25b jp25b ;
#delimit cr

* ab Welle K keine Angabe ueber ehemalige Taetigkeit fuer neue Befragte

capture program drop crbest
program define crbest
        version 5.0
        local i 94
        while `i'<=96 {
                gen bst`i'=1 if `1'01==1       /*Arbeiter*/
                replace bst`i'= 2 if `1'01==2
                replace bst`i'= 3 if `1'01==3
                replace bst`i'= 4 if `1'01==4
                replace bst`i'= 5 if `1'01==5
                replace bst`i'=40 if `1'03==1  /*Azubi*/
                replace bst`i'=41 if `1'03==2
                replace bst`i'=10 if `1'04==1  /*Angestellte*/
                replace bst`i'=11 if `1'04==2
                replace bst`i'=12 if `1'04==3
                replace bst`i'=13 if `1'04==4
                replace bst`i'=14 if `1'04==5
                replace bst`i'=20 if `1'05==1  /*Beamte*/
                replace bst`i'=21 if `1'05==2
                replace bst`i'=22 if `1'05==3
                replace bst`i'=23 if `1'05==4
                replace bst`i'=30 if `1'02==1  /*Selbstaendige*/
                replace bst`i'=31 if `1'02==2
                replace bst`i'=32 if `1'02==3
                replace bst`i'=33 if `1'02==4
                replace bst`i'=34 if `1'02==5
                lab var bst`i' "Berufliche Stellung"
                lab val bst`i' bst
                macro shift
                local i=`i'+1
}
end

quietly crbest kp51 lp43 mp41

* Personen, die aus dem Erwerbsleben ausscheiden, werden mit ihrer fruehren
* Berufsgruppe verkodet.

capture program drop bst
program define bst
        version 5.0
        local i 84
        local j 85
        while `j'<=96 {
                replace bst`j'= bst`i' if bst`j'==. & bst`i'>0  & /*
                */              (erw`j'>1 & erw`j'~=.)
                local i=`i'+1
                local j=`j'+1
        }
end

quietly bst

* Luecken werden, sofern sich nichts an der beruflichen Stellung
* geaendert hat, ueberbrueckt

*capture program drop luecke
*program define luecke
*       version 5.0
*       local i 85
*       while `i'<= 95 {
*               local j=`i'-1
*               local k=`i'+1
*               gen ctr`i'= bst`k'-bst`j'
*               replace bst`i'=bst`j' if ctr`i'==0 & `1'netto==4
*       }
*       drop ctr*
*end
*quietly luecke b c d e f g h i j k l

quietly for 84-96, l(n) quote(!): lab var bst@ !Berufl. Stellung @!
quietly for 84-96, l(n): lab val bst@ bst

#delimit ;
lab def bst 1 "ugel.Arb" 2 "agel.Arb" 3 "qual.Tae" 4 "Vorarb" 5 "Meister"
           10 "I.-Werkm" 11 "einf.Tae" 12 "qual.Tae" 13 "hqua.Tae"
           14 "Fuhraufg"  20 "einf.D" 21 "mitt.D" 22 "gehob.D"
           23 "hoeh.D" 30 "Landwirt"  31 "Freiber" 32 "3-9Mitar"
           33 ">10Mitar" 34 "Fam.-ang"  40 "Azubi"  41 "Praktik" ;
#delimit cr

*                                              WECHSEL INTERAKTIONSPARTNER
capture program drop umb
program define umb
        version 5.0
        gen monin84=-1
        local i 85
        while "`1'"~="" {
                ren `1' monin`i'
                local i=`i'+1
                mac shift
        }
end

#delimit ;
umb
bpmonin cpmonin dpmonin epmonin fpmonin gpmonin
hpmonin ipmonin jpmonin kpmonin lpmonin mpmonin ;
#delimit cr

capture program drop bchg       /* Wechsel Arbeitsplatz (bis Welle J) */
program define bchg
        version 5.0
        gen bchg84=0
        local i 85
        local j 84
        while "`73'"~="" {
                gen bchg`i'= bchg`j' if `73'==1
                replace bchg`i'= bchg`j' + 1 if                     /*
                */                   (`1'~=-2 & `1' >  monin`j') |  /*
                */                   (`10'~=-2 & `10'<= monin`i')
                replace bchg`i'= bchg`j' + 2 if                     /*
                */                   (`19'~=-2 & `19' > monin`j') | /*
                */                   (`28'~=-2 & `28'<= monin`i')
                replace bchg`i'= bchg`j' + 2 if                     /*
                */                   (`37'~=-2 & `37' > monin`j') | /*
                */                   (`46'~=-2 & `46'<= monin`i')
                replace bchg`i'= bchg`j' + 2 if                     /*
                */                   (`55'~=-2 & `55' > monin`j') | /*
                */                   (`64'~=-2 & `64'<= monin`i')
                local i=`i'+1
                local j=`j'+1
                mac shift
        }
end

#delimit ;
quietly bchg
bp22g01 cp22g01 dp20g01 ep20g09 fp18g09 gp21g09 hp23g11 ip23g11 jp23g11
bp22g02 cp22g02 dp20g02 ep20g10 fp18g10 gp21g10 hp23g12 ip23g12 jp23g12
bp22g03 cp22g03 dp20g03 ep20g05 fp18g05 gp21g05 hp23g05 ip23g05 jp23g05
bp22g04 cp22g04 dp20g04 ep20g06 fp18g06 gp21g06 hp23g06 ip23g06 jp23g06
bp22g07 cp22g07 dp20g07 ep20g03 fp18g03 gp21g03 hp23g03 ip23g03 jp23g03
bp22g08 cp22g08 dp20g08 ep20g04 fp18g04 gp21g04 hp23g04 ip23g04 jp23g04
bp22g09 cp22g09 dp20g09 ep20g01 fp18g01 gp21g01 hp23g01 ip23g01 jp23g01
bp22g10 cp22g10 dp20g10 ep20g02 fp18g02 gp21g02 hp23g02 ip23g02 jp23g02
bp22g11 cp22g11 dp20g11 ep20g11 fp18g11 gp21g11 hp23g13 ip23g13 jp23g13 ;

#delimit cr
capture program drop bchg       /* (ab Welle K) */
program define bchg
        version 5.0
        local i 94
        local j 93
        while "`4'"~="" {
                gen bchg`i'=bchg`j' + 1 if `4'==2
                replace bchg`i'=bchg`j' + 1 if `1'==6
                replace bchg`i'=bchg`j' + 2 if `1'==1 | `1'==2 | `1'==3
                local i=`i'+1
                local j=`j'+1
                mac shift
        }
end

quietly bchg kp39 lp31 mp29 kp37 lp29 mp27

quietly for 85-96, l(n) quote(!): lab var bchg@ !Anzahl Berufswechsel seit 84!

capture program drop wchg          /* Umzug im letzten Jahr */
program define wchg
        version 5.0
        gen wchg83=0
        local i 84
        local j 83
        while "`1'"~="" {
                gen chk`i'=`i'-`1' if `1'>0
                gen wchg`i'= 0
                replace wchg`i'= wchg`j'+1 if chk`i'< 1
                local i=`i'+1
                local j=`j'+1
                mac shift
        }
        drop chk*
        drop wchg83
end

#delimit ;
quietly wchg aeinzug beinzug ceinzug deinzug eeinzug feinzug
       geinzug heinzug ieinzug jeinzug keinzug leinzug meinzug;
#delimit cr

capture program drop buchg          /* Wechsel Bundesland */
program define buchg
        version 5.0
        local i 85
        while "`2'"~="" {
                gen chk`i'=`2'-`1'
                replace wchg`i'=wchg`i'+1  if chk`i'~= 0
                local i=`i'+1
                mac shift
        }
        drop chk*
end

#delimit ;
quietly buchg
abula bbula dbula dbula ebula fbula gbula hbula ibula jbula
kbula lbula mbula ;
#delimit cr

quietly for 84-96, l(n) quote(!): lab var wchg@ !Anzahl Umzuege seit 84!

keep hhnr-mhhnr polint* nation84-wchg96

save hypo1, replace

exit

* ERZEUGUNG STRUKTURDATENSAETZE
* Variablen Bundesland, Haushaltsstellung, Familienstand, Schulbildung,
* Berufsbildung, Bidlungsdauer,  Erwerbsstatus,
* Nie Erwerbstaetig, In Ausbildung, Haushaltseinkommen

version 5.0
* --------------------------RETRIVAL--------------------------------------
#delimit ;
mkdat
afamstd bfamstd cfamstd dfamstd efamstd ffamstd gfamstd hfamstd
 ifamstd jfamstd kfamstd lfamstd mfamstd nfamstd      /* Familienstand */
apsbil bpsbil cpsbil dpsbil epsbil fpsbil gpsbil hpsbil
 ipsbil jpsbil kpsbil lpsbil mpsbil npsbil         /*Schulbildung */
apbbil01 bpbbil01 cpbbil01 dpbbil01 epbbil01 fpbbil01 gpbbil01 hpbbil01
 ipbbil01 jpbbil01 kpbbil01 lpbbil01 mpbbil01 npbbil01 /*Berufsbildung */
apbbil02 bpbbil02 cpbbil02 dpbbil02 epbbil02 fpbbil02 gpbbil02 hpbbil02
 ipbbil02 jpbbil02 kpbbil02 lpbbil02 mpbbil02 npbbil02 /* Hochschulabschl. */
apbbil03 bpbbil03 cpbbil03 dpbbil03 epbbil03  fpbbil03 gpbbil03 hpbbil03
 ipbbil03 jpbbil03 kpbbil03 lpbbil03 mpbbil03 npbbil03 /* K. Berufsbildung */
abilzeit bbilzeit cbilzeit dbilzeit ebilzeit fbilzeit
 gbilzeit hbilzeit ibilzeit jbilzeit kbilzeit lbilzeit mbilzeit nbilzeit
using $soepdir, files(pgen) waves(a b c d e f g h i j k l m n)
netto(-3,-2,-1,0,1,2,3,4);

holrein abula using $soepdir, files(h) waves(a);  /* Bundesland */

holrein
bbula cbula dbula ebula fbula gbula hbula ibula jbula kbula lbula mbula nbula
using $soepdir, files(hbrutto) waves(b c d e f g h i j k l m n) ;

holrein
astell bstell cstell dstell estell fstell gstell hstell istell jstell
       kstell lstell mstell nstell
using $soepdir, files(pbrutto) waves(a b c d e f g h i j k l m n) ;

holrein
ah46 bh39 ch51 dh51 eh42 fh42 gh42 hh48 ih49 jh49 kh49    /* HHEink  */
 lh50 mh50 nh50
using $soepdir, files(h) waves(a b c d e f g h i j k l m n) ;

holrein
ap08 bp16 cp16 dp12 ep12 fp10 gp12 hp15 ip15 jp15 kp25 lp21
     mp15 np11                                           /* Erwerbstatus */
ap04 bp14 cp14 dp10 ep10 fp08 gp10 hp05 ip13 jp13 kp18 lp14
     mp13 np09                                           /* in Ausbildung */
using $soepdir, files(p) waves(a b c d e f g h i j k l m n) ;
#delimit cr

holrein ap09 using $soepdir, files(p) waves(a)  /* nie erwerbst. */

*---------------------------VEREINHEITLICHUNGEN --------------------------
capture program drop bul                                  /* Bundesland */
program define bul
        local i 84
        while "`1'"~="" {
                ren `1'bula bul`i'
                lab var bul`i' "Bundesland `i'"
                lab val bul`i' bul
                note bul`i': aus `1'bula, hbrutto (Welle 1: ah)
                macro shift
                local i=`i'+1
        }
end
bul a b c d e f g h i j k l m n
lab def bul 0 "Berlin"  1 "Schl.Hst"  2 "HH" 3 "Nieders."  4 "HB"  5 "NW" /*
*/  6 "Hessen"  7 "R.-Pfalz"  8 "BaWue"  9 "Bayern" 11 "B (Ost)"         /*
*/ 12 "Meck-Vor" 13 "Brandb." 14 "Sa.-Anh." 15 "Thuer." 16 "Sachsen"

capture program drop hst                                /* HH-Stellung */
program define hst
        local i 84
        while "`1'"~="" {
                ren `1'stell hst`i'
                lab var hst`i' "Stellung im HH `i'"
                lab val hst`i' hst
                note hst`i': aus `1'stell, pbrutto
                macro shift
                local i=`i'+1
        }
end
hst a b c d e f g h i j k l m n

lab def hst 0 "HV" 1 "Ehepart." 2 "Lebensp." 3 "Kind" 4 "Pflegek." /*
*/  5 "SchwKind"  6 "Eltern" 7 "SchwElt." 8 "Geschw." 9 "Enkel"    /*
*/ 10 "Sonstige" 11 "n. verw."


capture program drop fam                                /* Familienstand */
program define fam
        local i 84
        while "`1'"~="" {
                ren `1'famstd fam`i'
                lab var fam`i' "Familienstand `i'"
                lab val fam`i' fam
                note fam`i': aus `1'famstd, pgen
                macro shift
                local i=`i'+1
        }
end
fam a b c d e f g h i j k l m n
lab def fam 1 "verh." 2 "getrennt" 3 "ledig" 4 "gesch." 5 "verw." 6 "heimat"


* Konsistenzchecks
replace bul92= 5 if persnr==108501
replace bul92= 5 if persnr==133103
replace bul92= 8 if persnr==318402
replace bul92= 8 if persnr==318403
replace bul92= 8 if persnr==318404
replace bul92= 8 if persnr==348603
replace bul92= 9 if persnr==447704
replace bul92=14 if persnr==5100101

capture program drop aus                                /* in Ausbildung */
program define aus
        local i 84
        while "`1'"~="" {
                ren `1' aus`i'
                replace aus`i' = 0 if aus`i' == 2
                lab var aus`i' "In Ausbildung `i'"
                lab val aus`i' yesno
                note aus`i': aus `1', p
                macro shift
                local i=`i'+1
        }
end
aus ap04 bp14 cp14 dp10 ep10 fp08 gp10 hp05 ip13 jp13 kp18 lp14 mp13 np09



capture program drop ausb                            /* Bildung */
program define ausb
        local i 84
        while "`1'"~="" {
                ren `1'psbil bil`i'
                gen bbil`i' = 1 if `1'pbbil03==1
                replace bbil`i'= `1'pbbil01 +1 if `1'pbbil01>=1
                replace bbil`i'= `1'pbbil02 +7 if `1'pbbil02>=1
                replace bbil`i' = -1 /*
                */ if `1'pbbil01 == -1 | `1'pbbil02 == -1 | `1'pbbil03 == -1
                drop `1'pbbil0*
                ren `1'bilzeit bdauer`i'
                replace bdauer`i' = -1 if bbil`i'~=. & bdauer`i' == .
                lab var bil`i' "Schulabschluss `i'"
                lab var bbil`i' "Hoechst. Berufsausb.abschl. `i'"
                lab var bdauer`i' "Ausbildungsdauer in Jahren `i'"
                lab val bil`i' bil
                lab val bbil`i' bbil
                note bil`i': aus `1'psbil, pgen
                note bbil`i': aus `1'pbbil01, pgen
                note bbil`i': Hochschulabschluesse gelten als hoeher
                macro shift
                local i=`i'+1
        }
end
ausb a b c d e f g h i j k l m n

lab def bil 1 "HS/VS" 2 "Reals." 3 "FHSReife" 4 "Abitur" 5 "Sonst." /*
*/ 6 "Kein Abs"
lab def bbil 1 "Kein" 2 "Lehre" 3 "BerufsFH" 4 "S.Geswes" 5 "Fachsch." /*
*/ 6 "Beamtena" 7 "And. Ausb." 8 "FHS" 9 "Univ.,TH" 10 "Uni.Ausl"

capture program drop estat                        /* Erwerbstatus bis 91 */
program define estat
        local i 84
        while "`1'"~="" {
                ren `1'  est`i'
                * est in Welle G f"ur Ostdeutsche nicht definiert!
                if `i' == 90 {
                        replace est`i' = -1 /*
                        */ if est`i' == . & bul`i' >= 11 & bul`i' <= 16
                }
                lab var est`i' "Erwerbstatus `i'"
                lab val est`i' est
                note est`i': aus `1', p
                macro shift
                local i=`i'+1

        }
end
estat ap08 bp16 cp16 dp12 ep12 fp10 gp12

capture program drop estat                         /* Erwerbstatus seit 91 */
program define estat
        local i 91
        while "`1'"~="" {
                ren `1'  est`i'
                recode est`i' 1 2=1 3 4=2 5=3 6=4 8=6 7 9=7
                lab var est`i' "Erwerbstatus `i'"
                lab val est`i' est
                note est`i': aus `1', p
                note est`i': recodiert
                macro shift
                local i=`i'+1
        }
end
estat hp15 ip15 jp15 kp25 lp21


capture program drop estat                       /* Erwerbstatus seit 1996 */
program define estat
        local i 96
        while "`1'" ~= "" {
                ren `1' est`i'
                recode est`i' 5=7
                lab var est`i' "Erwerbstatus `i'"
                lab val est`i' est
                note est`i': aus `1', p
                note est96: recodiert
                local i = `i'+1
                mac shift
        }
end
estat mp15 np11

lab def est 1 "Vollzeit" 2 "Teilzeit" 3 "Umschul." 4 "Unregelm" /*
         */  5 "arb.los" 6 "Wehrd." 7 "not erw."


gen byte nie84=0                                    /* nie Erwerbstaetig */
replace nie84 = 1 if ap09==2
lab var nie84 "bis 84 nie erwerbstaetig"
lab val nie84 yesno
note nie84: aus ap09

capture program drop nie
program define nie
        local i 85
        while `i' <= 97 {
                local j = `i'-1
                gen byte nie`i' = 0
                replace nie`i' = 1 /*
                */ if (est`i' == 6 | est`i' == 7) & nie`j' == 1
                * est in Welle G f"ur Ostdeutsche nicht definiert!
                if `i' == 90 {
                        replace nie`i' = -1 if est`i' == -1
                }
                lab var nie`i' "bis `i' nie erwerbstaetig"
                lab val nie`i' yesno
                note nie`i': aus ap09 und Fortschreibung Erwerbsstatus
                local i=`i'+1
        }
end
nie
lab def yesno 0 "nein" 1 "ja"


capture program drop hhein                          /* Haushaltseinkommen */
program define hhein
local i 84
while "`1'" ~= "" {
        ren `1' hhein`i'
        lab var hhein`i' "Haushaltseinkommen `i'"
        note hhein`i': aus `1', h
        macro shift
        local i = `i'+1
}
end
hhein ah46 bh39 ch51 dh51 eh42 fh42 gh42 hh48 ih49 jh49 kh49 /*
*/ lh50 mh50 nh50
save peigen, replace

* ---------------------------SPEICHERN--------------------------------------
capture program drop svdat
program define svdat
    local i 84
    while `i'<=97 {
        use if `1'netto == 1 using peigen, clear
        ren `1'hhnr hhnrakt
        keep hhnr hhnrakt persnr bul`i' hst`i' fam`i' /*
        */ bil`i' bbil`i' bdauer`i' est`i' nie`i' aus`i' hhein`i'
        order hhnr hhnrakt persnr bul`i' hst`i' fam`i' /*
        */ bil`i' bbil`i' bdauer`i' est`i' nie`i' aus`i' hhein`i'
        compress
        sort hhnr hhnrakt persnr
        save $soepdir/`1'peigen, replace
        local i = `i'+1
        mac shift
    }
end
svdat a b c d e f g h i j k l m n

erase peigen.dta

exit

----------------------------------------------------------------------------

\subsection{Bundesland}

Bei folgenden Personen wurde die Angabe -3 auf den inhaltlichen Wert
der "ubrigen Jahre gesetzt

\begin{verbatim}
persnr    84   85   86   87   88   89   90   91   92   93   94   95   96
108501    NW   NW   NW   NW   NW   NW   NW   NW   -3   NW    .    .    .
133103    NW   NW   NW   NW   NW   NW   NW   NW   -3   NW    .    .    .
318402    BW   BW   BW   BW   BW   BW   BW   BW   -3   BW   BW   BW   BW
318403    BW   BW   BW   BW   BW   BW   BW   BW   -3   BW   BW   BW   BW
318404    BW   BW   BW   BW   BW   BW   BW   BW   -3   BW   BW   BW   BW
348603    BW   BW   BW   BW   BW   BW   BW   BW   -3   BW    .    .    .
447704   Bay  Bay  Bay  Bay  Bay  Bay  Bay   Bay  -3  Bay    .    .    .
5100101    .    .    .    .    .    .  SaA  SaA   -3  SaA  SaA  SaA  SaA
\end{verbatim}

\subsubsection{H"ochster Berufsausbildungsabschluss}

Die Vercodung im SOEP l"a"st Mehrfachnennungen in der Art zu, dass
sowohl eine Kategorie der Berufsausbildung als auch eine Kategorie
der Hochschulabschl"usse angegeben werden kann. F"ur die Variable
{\em h"ochster Ausbildungsabschluss} gilt der Hochschulabschlu"s stets
als h"oherwertig.
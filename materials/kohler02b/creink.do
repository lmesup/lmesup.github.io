* ERZEUGUNG STRUKTURDATENSAETZE
* Variable Einkommen

version 5.0
clear
set memory 60m

* --------------------------RETRIVAL--------------------------------------
#delimit ;
mkdat
ap2a02 bp2a02 cp2a02 dp2a02 ep2a02 fp2a02 gp2a02 /* Monate Lohn/Gehalt */
hp2a02 ip2a02 jp2a02 kp2a02 lp2a02 mp2a02 np2a02
ap2b02 bp2b02 cp2b02 dp2b02 ep2b02 fp2b02 gp2b02 /* Monate Einkommen */
hp2b02 ip2b02 jp2b02 kp2b02 lp2b02 mp2b02 np2b02
ap2c02 bp2c02 cp2c02 dp2c02 ep2c02 fp2c02 gp2c02 /* Monate Nebenerwerb */
hp2c02 ip2c02 jp2c02 kp2c02 lp2c02 mp2c02 np2c02
ap2d02 bp2d02 cp2d02 dp2d02 ep2d02 fp2d02 gp2d02 /* Monate Rente/Pension */
hp2d02 ip2d02 jp2d02 kp2d02 lp2d02 mp2d02 np2d02
ap2f02 bp2f02 cp2f02 dp2f02 ep2f02 fp2f02 gp2f02 /* Monate Arbeitslosengeld */
hp2f02 ip2f02 jp2f02 kp2f02 lp2f02 mp2f02 np2f02
ap2g02 bp2g02 cp2g02 dp2g02 ep2g02 fp2g02 gp2g02 /* Monate Arbeitsl.-hilfe */
hp2g02 ip2g02 jp2g02 kp2g02 lp2g02 mp2g02 np2g02
ap2h02 bp2h02 cp2h02 dp2h02 ep2h02 fp2h02 gp2h02 /* Mon. Unterh. Arbeitsamt */
hp2h02 ip2h02 jp2h02 kp2h02 lp2h02 mp2h02 np2h02
ap2k02 bp2k02 cp2k02 dp2k02 ep2k02 fp2k02 gp2k02 /* Mon. Baf"og, Stipendien */
hp2k02 ip2k02 jp2k02 kp2k02 lp2k02 mp2k02 np2k02
ap2a03 bp2a03 cp2a03 dp2a03 ep2a03 fp2a03 gp2a03 /* Lohn/Gehalt           */
hp2a03 ip2a03 jp2a03 kp2a03 lp2a03 mp2a03 np2a03
ap2b03 bp2b03 cp2b03 dp2b03 ep2b03 fp2b03 gp2b03 /* Einkommen             */
hp2b03 ip2b03 jp2b03 kp2b03 lp2b03 mp2b03 np2b03
ap2c03 bp2c03 cp2c03 dp2c03 ep2c03 fp2c03 gp2c03 /* Nebenerwerb           */
hp2c03 ip2c03 jp2c03 kp2c03 lp2c03 mp2c03 np2c03
ap2d03 bp2d03 cp2d03 dp2d03 ep2d03 fp2d03 gp2d03 /* Rente/Pension         */
hp2d03 ip2d03 jp2d03 kp2d03 lp2d03 mp2d03 np2d03
ap2f03 bp2f03 cp2f03 dp2f03 ep2f03 fp2f03 gp2f03 /* Arbeitslosengeld      */
hp2f03 ip2f03 jp2f03 kp2f03 lp2f03 mp2f03 np2f03
ap2g03 bp2g03 cp2g03 dp2g03 ep2g03 fp2g03 gp2g03 /* Arbeitslosenhilfe     */
hp2g03 ip2g03 jp2g03 kp2g03 lp2g03 mp2g03 np2g03
ap2h03 bp2h03 cp2h03 dp2h03 ep2h03 fp2h03 gp2h03 /* Unterh. vom Arbeitsam */
hp2h03 ip2h03 jp2h03 kp2h03 lp2h03 mp2h03 np2h03
ap2k03 bp2k03 cp2k03 dp2k03 ep2k03 fp2k03 gp2k03 /* Mon. Baf"og, Stipendien */
hp2k03 ip2k03 jp2k03 kp2k03 lp2k03 mp2k03 np2k03
using $soepdir, files(pkal) waves(a b c d e f g h i j k l m n)
netto(-3,-2,-1,0,1,2,3,4);

holrein
est84 est85 est86 est87 est88 est89 est90 est91 est92 est93 est94 est95
est96 est97
using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n) ;
#delimit cr

capture program drop ein                                   /* Einkommen */
program define ein
        local i 84
        while "`99'"~="" {
                replace `1'02 = 0 if `1'02 == -2
                replace `15'02 = 0 if `15'02 == -2
                replace `29'02 = 0 if `29'02 == -2
                replace `43'02 = 0 if `43'02 == -2
                replace `57'02 = 0 if `57'02 == -2
                replace `71'02 = 0 if `71'02 == -2
                replace `85'02 = 0 if `85'02 == -2
                replace `99'02 = 0 if `99'02 == -2
                gen ein`i' = (`1'02 *  `1'03        /*
                */         + `15'02 * `15'03        /*
                */         + `29'02 * `29'03        /*
                */         + `43'02 * `43'03        /*
                */         + `57'02 * `57'03        /*
                */         + `71'02 * `71'03        /*
                */         + `85'02 * `85'03        /*
                */         + `99'02 * `99'03)/12
                * Berufstaetige, mit Einkommen von 0: -1
                replace ein`i' = -1 /*
                */ if ein`i' ==  0  /*
                */ & ((est`i' >= 1 & est`i' <= 4) | (est`i' == -1))
                * Eine Einkommensart nicht genannt: -1
                replace ein`i' = -1 /*
                */ if `1'03 == -1 | `15'03 == -1 | `29'03 == -1 /*
                */ | `43'03 == -1 | `57'03 == -1 | `71'03 == -1 /*
                */ | `85'03 == -1 | `99'03 == -1
                replace ein`i' = -1 /*
                */ if `1'03 == -3 | `15'03 == -3 | `29'03 == -3 /*
                */ | `43'03 == -3 | `57'03 == -3 | `71'03 == -3 /*
                */ | `85'03 == -3 | `99'03 == -3
                * Konsistenzcheck:
                replace ein`i' = -1 if ein`i' < 0
                lab var ein`i' "Berufsbez. pers. Bruttoeink. `i'"
                note ein`i': sum(`1',`15',`29',`43',`57',`71',`85')
                macro shift
                local i=`i'+1
        }
drop ap2a02 - np2k03
end

#delimit ;
ein
ap2a bp2a cp2a dp2a ep2a fp2a gp2a hp2a ip2a jp2a kp2a lp2a mp2a np2a
ap2b bp2b cp2b dp2b ep2b fp2b gp2b hp2b ip2b jp2b kp2b lp2b mp2b np2b
ap2c bp2c cp2c dp2c ep2c fp2c gp2c hp2c ip2c jp2c kp2c lp2c mp2c np2c
ap2d bp2d cp2d dp2d ep2d fp2d gp2d hp2d ip2d jp2d kp2d lp2d mp2d np2d
ap2f bp2f cp2f dp2f ep2f fp2f gp2f hp2f ip2f jp2f kp2f lp2f mp2f np2f
ap2g bp2g cp2g dp2g ep2g fp2g gp2g hp2g ip2g jp2g kp2g lp2g mp2g np2g
ap2h bp2h cp2h dp2h ep2h fp2h gp2h hp2h ip2h jp2h kp2h lp2h mp2h np2h
ap2k bp2k cp2k dp2k ep2k fp2k gp2k hp2k ip2k jp2k kp2k lp2k mp2k np2k ;
#delimit cr


save peigen, replace

* ---------------------------SPEICHERN--------------------------------------
capture program drop svdat
program define svdat
    local i 84
    while `i'<=97 {
        use if `1'netto == 1 using peigen, clear
        ren `1'hhnr hhnrakt
        keep hhnr hhnrakt persnr ein`i'
        compress
        sort hhnr hhnrakt persnr
        merge hhnr hhnrakt persnr using $soepdir/`1'peigen
        assert _merge==3
        drop _merge
        sort hhnr hhnrakt persnr
        order hhnr hhnrakt persnr bul`i' hst`i' fam`i' /*
        */ bil`i' bbil`i' bdauer`i' est`i' nie`i' aus`i' hhein`i' ein`i'
        save $soepdir/`1'peigen, replace
        local i = `i'+1
        mac shift
    }
end
svdat a b c d e f g h i j k l m n

erase peigen.dta

exit


\subsection{Berufsbezogenes pers"onliches Bruttoeinkommen}\label{ein}

Das berufsbezogene pers"onliche Bruttoeinkommen wird durch die Summe aller
Einkommensarten, die aus der aktuellen oder ehemaligen beruflichen Postion
resultieren, gem"a"s folgender Formel ermittelt:

\begin{equation}
\mbox{berufsbez. pers. Bruttoeink}
= \frac{1}{12} \sum_{i=1}^I \left(f_i * x_i\right)
\end{equation}

Dabei ist $ i $ eine von $ I $ Einkommensarten, die aus der berufliche
Position resultieren, $ f $ sind die Anzahl der Monate, in der eine
Einkommensart bezogen wurde und $ x $ der vom Befragen gesch"atzte
durchschnittliche Betrag dieser Einkommensart f"ur den angegebenen Zeitraum.
Verwendet werden Einkommen des abgelaufenen Kalenderjahrs.

Folgende Einkommensarten wurden als "`aus der beruflichen Position
resultierent"' angesehen:
\begin{enumerate}
\item Lohn oder Gehalt als Arbeitnehmer (einschl. Ausbildungsverg"utung und
Vorruhestandsbez"uge)
\item Einkommen aus selbst"andiger oder freiberuflicher T"atigkeit
\item Einkommen aus Nebenerwerbst"atigkeit, Nebenverdienste
\item Altersrente oder -pension, Invalidenrente und Betriebsrente aufgrund
eigener Erwerbst"atigkeit
\item Arbeitslosengeld
\item Arbeitslosenhilfe
\item Unterhaltsgeld vom Arbeitsamt bei Fortbildung oder Umschulung
\item Baf"og, Stipendium oder Berufsausbildungsbeihilfe
\end{enumerate}

Als nicht aus der beruflichen Position resultierend galten Witwen- und
Waisenrenten, bzw.\ -pensionen sowie Zahlungen von Personen, die nicht im
Haushalt leben.

\subsubsection{Fehlerkorrekturen}
In einigen F"allen findet sich der Missing--Code -2 (trifft nicht zu) bei
der Angabe des Betrags einer Einkommensart, obwohl bei der Anzahl der Monate
eine g"ultige Angabe eingetragen wurde. Hier wurde stets der Anzahl der Monate
Vorrang einger"aumt, und der Missing--Code bei der Angabe des Betrags auf
-1 gesetzt.
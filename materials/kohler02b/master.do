*+----------------------------------------------------------------+
*|              MASTER-DO-FILE ZUR DISSERTATION VON               |
*|                      ULRICH KOHLER                             |
*|                (UNIVERSITÄT MANNHEIM)                          |
*+----------------------------------------------------------------+             

version 7.0    
clear
set memory 60m   
set more off

*******************************************************************

*+-------------------------------+ 
*| ANPASSUNG AUF LOCALEN RECHNER | 
*+-------------------------------+

* Folgende Daten werden benötigt:
* SOEP, Lieferung 1984-2000. Datengeber: DIW, Berlin
* kumulierter Allbus (s1795), Lieferung 1980-1998. Datengeber: ZA
* kumulierte Politbarometer s1920 und s2275. Datengeber: ZA


* SOEP-Verzeichnis setzen
* ------------------------

* Ändern Sie die Pfadangabe auf den Pfad, auf dem die Daten des 
* SOEP liegen.
* Note: Sie benötigen Schreibrechte für dieses Verzeichnis!

global soepdir ~/data/soep

* ALLBUS-Verzeichnis setzen
* -------------------------

* Ändern Sie die Pfadnagabe auf das Verzeichnis, welches den kumulierten
* Allbus 1980-1998 enthält. Sie benötigen keine Schreibrechte auf diesem
* Verzeichnis.
* Note: Die Do-Files verwenden den
* Dateinamen allb8098. Dies ist die Datei, mit allen 
* Missing-Values Definitionen des SPSS-Datensatzes. 

* ACHTUNG: Nur ZA-Nr "s1795" mit der Kumulation
* 1980-98 verwenden. Andere Kumulationen verwenden andere
* Variablennamen und sind darum ungeeignet. 

global allbdir ~/data/allbus/dta

* Politbarometer-Verzeichnis setzen
* ---------------------------------

* Ändern Sie die Pfadnagabe auf das Verzeichnis, welches die
* kumulierten Politbarometer s2275 und s1920 enthält. Sie
* benötigen keine Schreibrechte auf diesem Verzeichnis.

global politdir ~/data/polit

*******************************************************************
* Ab hier sind keine weiteren Editierungen notwendig!
* Bitte lesen Sie jedoch die Hinweise zu folgendem Abschnitt

*+--------------------------------+
*| INSTALLATION VON ZUSATZMODULEN |
*+--------------------------------+

* COOL-ADOS: Diese Ados werden im Folgenden automatisch über das 
* Internet geladen und installiert.
* Das setzt natürlich voraus, dass ihr Rechner eine feste Verbindung 
* zum Internet hat. Sollte dies nicht der Fall sein müssen Sie die 
* entsprechenden Ados von Hand installieren. Hinweise hierzu in 
* Kohler/Kreuter (2001)

capture which mkdat 
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}

capture which anal 
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install anal
}

capture which denscomp
if _rc ~= 0 {
	net from http://www.stata.com/datenanalyse
	net install denscomp
}

capture which archinst
if _rc ~= 0 {
	net stb-54
	net install ip29_1
}

capture which hplot
if _rc ~= 0 {
	archinst hplot
}

capture which dups
if _rc ~= 0 {
	net stb-41
	net install dm53
}

capture which eta2    
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install eta2
}

capture which desmat 
if _rc ~= 0 {
	net stb-54
	net install dm73_1
}

capture which fitstat
if _rc ~= 0 {
	net stb-56
	net install sg145
}

capture which hist3
if _rc ~= 0 {
	archinst hist3
}

capture which rgroup
if _rc ~= 0 {
	archinst rgroup 
}

*******************************************************************


* +--------------------------------+
* |Generierung zentraler Variablen |
* +--------------------------------+

do crstruk1 /* Bundesland, Haushaltsstellung, Familienstand, Schulbildung,
               Berufsausbildung, Bildungsdauer, Erwerbsstatus,
               Nie Erwerbst"atig, In Ausbildung, Haushaltseinkommen */
do creink     /* Berufsbezogenes pers"onliches Bruttoeinkommen */
do crstruk2   /* Einordnungsberufe  "Hauptverdiener", "Pappi" und "Terwey" */
do creigen1   /* Datensatz zur Fehlerkorrektur */
anal aneigen1 /* Fehlersuche 1: Nonmatchs korrekt? */
erase eigen1.dta
do crkorr1    /* Korrektur der Non-matchs aus aneigen1 */
do creigen2   /* Datensatz zur Fehlerkorrektur (Kopie von creigen1)*/
anal aneigen2 /* Zur Kontrolle nochmal: Nonmatchs korrekt?
                 (Kopie von aneigen1) -> ok */
erase eigen2.dta
do cregp      /* EGP -- Klassenschema */
do creigen3   /* Datensatz zur Suche nach fehlerhaften Nonmatchs in EGP */
anal aneigen3 /* Fehlersuche 2: Nonmatchs korrekt? und alle groesser -2 */
erase eigen3.dta
do crkorr3    /* Korrektur Non-matchs aus aneigen3.do */
do creigen4   /* Datensatz zur Suche nach fehlerhaften Nonmatchs in EGP */
anal aneigen4 /* Nochmal Fehlersuche 2 */
erase eigen4.dta
do crkorr4    /* Korrektur eines Fehler in do crkorr3 */
do creigen5   /* Datensatz zur Suche nach fehlerhaften Nonmatchs in EGP */
anal aneigen5 /* Nochmal Fehlersuche 2  -> ok */
erase eigen5.dta

* +-------+
* |Anhang |
* +-------+

anal anegpvgl  /* Vergleich ALLBUS - SOEP Klassenschema */
do crkorr5    /* Label für bsth vergessen -> Korrektur */
do cregpanh   /* Long Data mit EGP, Einkommen, Prestige für Anhang */
anal anegpfre /* Verteilung EGP, -> egpfre.gph */
anal anegpfr2 /* Menge mit "halber" Information zugewiesene Klassen */
anal anegpfrx /* -> anegpfre für Westen */
do creta      /* eta^2 Einkommen/Prestige ->  EGP */
do grholtm  /* Replikation eta^2 bei Holtman (1990) (Eink/Prestige) */
anal anegppre /* Prestige der EGP--Klassen in ALLBUS und SOEP */
anal anegpein /* Einkommen der EGP--Klassen in ALLBUS und SOEP */
anal anholtm1 /* Warum höheres Einkommen im SOEP? */
anal anholtm2 /* Warum eta^2 im SOEP bei Einkommen niedrig?*/
anal anlr     /* Politbarometer: Validität rechts--links--Schema */
do crrl       /* Erzeugung des Rechts--Links--Schemas */
anal anrl1    /* Fehlercheck 1 Rechts--Links--Schema -> all clear */
do cregppat   /* Muster ISCO-BST-EGP fuer SOEP und ALLBUS */
anal anholtm3 /* anholtm, jedoch Anwendung ALLBUS-EGP auf SOEP Daten */

    * Fehler durch Gewichtung beim Allbus: Gewichtungsvariable 
	* enthält 99.999 für Personen, denen kein Gewicht zugewiesen werden 
    * kann. -> werden auf "." gesetzt. Analysen werden wiederholt

    * Wiederholung vorhergehender Analysen
    anal anegpfr3 /* Verteilung EGP--Klassenschema (anegpfre) */
    anal anegpfr4 /* Wie anegpfre, jedoch nur für Westen (anegpfrx) */
    do creta2
    do grholtm4 /* Replikation eta^2 bei Holtman (1990)(anholtm) */
    anal anegppr1 /* Prestige der EGP--Klassen in ALLBUS und SOEP (anegppre) */
    anal anegpei1 /* Einkommen der EGP--Klassen in ALLBUS und SOEP (anegpein) */
anal anegppid /* PID der EGP--Klassen in Allbus und SOEP '90 */
do crpid      /* PID fuer alle Wellen */
anal aneinord /* Vergleich der Einordnungsberufe */
anal aneinor1 /* Vergleich Einordnungsberufe, nur Westdeutsche */
erase egpanh.dta
erase egppat1.dta
erase egppat2.dta
erase einord.dta
erase eta.dta

* +----------+
* |Kapitel 3 |
* +----------+

anal ancases /* Zentrale Fallzahlen im SOEP */
do crweights /* Gewichtungsfaktoren fuer Laengschnitte 84-97 */

* +----------+
* |Kapitel 6 |
* +----------+

do grxtreg1 /* Beispiel für Fixed--Effects--Regression */
do grtpaths /* Erzeugt Graphik der Zeitpfade aus Allison 1994 */

* +----------+
* |Kapitel 1 |
* +----------+

anal grverbr  /* Verbrugge 1977 (-> verbr.gph) */

* +-----------+
* | Kapitel 4 |
* +-----------+

do grnormprob /* Beschreibung der Verteilung von normbrob(z~(-1,1)) */
do crsimul    /* Simuliert obj. Interessenlage -> PID */
anal ansimul1  /* Beschreibung demokratischer Klassenkampf in simul.dta */
anal ansimul2  /* Variante von ansimul1 mit anderer Anordnung der Grafiken */
anal ansimul3  /* Variante von ansimul2, mit Min/Max statt p5/p95 */
do crmegp      /* Erzeugt EGP-Klassenschema, Variante Mueller fuer SOEP */
do crstab1    /* PID, unbalanced, long, xtdata */
anal anstab   /* Lag-1 Stability für unterschiedliche Settings */
anal anstabw  /* wie anstab, jedoch Gewichtet -> Problem: Fallzahl!! */
anal ansimul4 /* Vergleich Simulation - SOEP - Daten */
anal ansimul5 /* Vergleich Simulation - Allbus - Daten */
anal ansimul6 /* Vergleich Simulation (Mittelwerte) - SOEP/ALLBUS */
erase simul.dta

* +-----------+
* | Kapitel 5 |
* +-----------+

* Stabilität
* ----------

* Transformationstabellen
anal anstab1  /* Lag-1 Trans.-Prob für unterschiedliche Settings */
anal anstab1w /* Lag-1 Trans.-Prob mit Gewichtung */
anal anstab1a /* Lag-1 Trans.-Prob m. Rekodierung "keine PID" */ 
anal anstab1aw /* Lag-1 Trans.-Prob m. Rekodierung "keine PID" mit Gewichtung */ 
anal anstab2  /* Lag-X Stability */
anal anstab2w /* Lag-X Stability, Weighted */
*anal anstab3  /* Within-Percent, unvollständig, nicht weiterverfolgt */

* Sequenzanalysen
do crstab2u   /* Datensatz PID unbalanced, wide */
do crstab2b   /* Datensatz PID balanced, wide */
anal anstab4u /* Sequenzen, Unbalanced Panel Design */
do grstab4u   /* 10 Häufigste Sequenzen, unbalanced */
anal anstab4b /* Sequenzen, Balanced Panel Design */
do grstab4b   /* 10 Häufigste Sequenzen, balanced */
anal anstab5b /* SO-Sequenzen, Balanced Panel Design */
do grstab5a   /* Anzahl der Stadien in den SO-Sequenzen */
do grstab5b   /* 10 Häufigste SO-Sequenzen, balanced */
anal anstab6b /* SS-Sequenzen, balanced */ 
anal anstab6c /* Welche Sequenzen kommen nicht vor? */
anal anstab6d /* SS-Sequenzen unter Ausschluss von Sonst./k.A */
anal anstab6e /* anstab6c unter Ausschluss von Sonst./k.A.   */
anal anstab6f /* SS-Sequenz-Typen mit Einschluss von Sonst./k.A */
erase stab1.dta
erase stab2u.dta
erase stab2b.dta

* Trägheit
* --------

*anal anstab2a /* Stationäres Markov-Modell 1. Ord. (nicht weiterverfolgt) */
*anal anstab2b /* Stationäres Markov-Modell 2. Ord. (nicht weiterverfolgt) */
*anal anstab2c /* Test der Zeit-Homogenität (nicht weiterverfolgt) */
*anal anstab2d /* Zeitvariierendes Markov-Modell (nicht weiterverfolgt) */

do crtraeg1    
anal antraeg1 /* Traegheit, Design 1+3, Lag-13 */
anal antraeg2 /* Traegheit, Design 1+3, Lag-1 */
do grtraeg3  /* Plots der Koeffizienten im Analysedesign 1 */
anal antraeg1a /* Variante von antraeg1a - Lag-1 mit balanced Design */
do grtraeg3a /* Plots mit Variante antraeg1a */
do grtraeg4 /* Plots der Koeffizienten im Analysedesign 2 */
do grtraeg5 /* Sind Arbeiter/Selbständigen-Kinder stabiler? */
do grtraeg6 /* Variante von grtraeg5 */
anal antraeg6 /* Kaplan Mayer zu: Sind Arbeiter-Kinder stabiler? */ 

* +-----------+
* | Kapitel 6 |
* +-----------+

do crpidlv /* Ereignisindikatoren, long, xtdata, weights & friends */
anal anpidlv1 /* Descr. Analysedaten: n, Teilnahmen, Beobachtungsdichte */
do grpidlv1 /* Verteilung der Teilnahmen */
do grpidlv2 /* Beobachtungszeiraeme */
anal anpidlv2 /* Verteilung unabhaengige Variablen */
anal anpidlv3 /* xtlogit - Modell 1, vollst. Information */
do grpidlv3 /* Vergleich Fixed-Effects mit Between-Effects */
anal anpidlv4 /* xtlogit - Modell 2, unvollst. Information */
do grpidlv4  /* Interaktionseffekte Klassenwechsel X Pol. Int. */
do grpidlv5  /* Interaktionseffekte Aging Cons X Pol. Int. */
do grpidlv6  /* Interaktionseffekte Arbeitslos X Pol. Int. */
do grpidlv7  /* Interaktionseffekte Interaktionspartner X  Pol. Int. */
anal anpidlv5 /* B90-Modell mit Aufnahme Studium  (nicht weiterverfolgt) */ 
do grpidlv8  /* Ergebnisplot von anpidlv5 (nicht weiterverfolgt) */
anal anpidlv6 /* Zeitversetzt - Dummy-Kodierung (nicht weiterverfolgt) */
anal anpidlv7 /* Zeitversetzt - ln(Zeitablauf) */
do grpidlv9  /* Interaktionseffekte Klassenwechsel X Pol. Int. */
do grpidlv10 /* Interaktionseffekte Aging Cons X Pol. Int. */
do grpidlv11 /* Interaktionseffekte Arbeitslos X Pol. Int. */
do grpidlv12 /* Interaktionseffekte Interaktionspartner X  Pol. Int. */


* +-----------+
* | Kapitel 4 |
* +-----------+

* Korrekturlauf!  Korrektur notwendig auf Grund eines Fehlers in
* crsimul. Korrektur in crsimul_c + Wiederholung der darauf aufbauenden
* Analysen
  
do crsimul_c /* Korrektur der Simulation */
anal ansimul3_c/* Variante von ansimul2, mit Min/Max statt p5/p95 */
anal ansimul4_c/* Vergleich Simulation - SOEP - Daten */
anal ansimul5_c/* Vergleich Simulation - Allbus - Daten */
anal ansimul6_c/* Vergleich Simulation (Mittelwerte) - SOEP/ALLBUS */
erase simul_c.dta


exit

*******************************************************************

Bemerkungen:
------------

Alle Stata-Grafiken werden zum Ausdruck in das EPS-Format
umgewandelt. Dabei werden einige weitere optische Gestaltungen wie
Linienstärke, Grafikgröße, Plotsymbolgröße usw. vorgenommen. Diese
Gestaltung wird mit dem Stata Do-File "gphprint.do" aus dem 
Graphik-Verzeichnis heraus vorgenommen.

----+----analysen---+---master.do
    |               |
    |               +---Stata-Do-Files
    |
    +---graphs------+---gphprint.do


Folgende Stage--Do--Files müssen ausgeführt werden.
egppid.sge  -> verbindet Graphiken aus anegppid.do zu egppid.gph




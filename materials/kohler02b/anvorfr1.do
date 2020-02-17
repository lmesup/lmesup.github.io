* Klaert die Vorfrage:                                          /*

 */ "Hat die Klassenvariable nur einen Einfluss bei den politisch /*
 */  Interessierten und Informierten, oder hat sie auch darueber  /*
 */  hinaus Einfluss?".

#delimit ;
* Datensatz enthaehlt:
 V1         ZA-STUDIENNUMMER
 V2         BEFRAGTEN-NUMMER
 V3         ERHEBUNGSGEBIET: WEST - OST
 V4         DEUTSCHE STAATSANGEHOERIGKEIT?
 V37        ALTER
 V106       INTERESSE, Politisches
 V141       GESCHLECHT, BEFRAGTE<R>
 V319       KIRCHGANGSHAUFIGKEIT
 V318       KONFESSIONSZUGEHOEHRIGKEIT
 V325       WAHLABSICHT
 v399       INTERESSE, Politisches (ISSP)
 V403/V405  INFORMIERTHEIT POLITISCHE
 V430       GOLDTHORPEKLASSEN, EINORDNUNG <TERWEY> ;
#delimit cr
set matsize 400
use vorfr1
log off
*-------------------REKODIERUNGEN-----------------------------------------
gen wahl=v325                                             /*Wahlabsicht*/
replace wahl=. if wahl>6
replace wahl=. if wahl==0
replace wahl=4 if wahl==6
lab var wahl "Wahlabsicht"
lab val wahl wahl
lab def wahl 1 "CDU/CSU" 2 "SPD" 3 "FDP" 4 "B90"

gen class=v430                                             /*EGP-Klassen*/
replace class=. if class==11 | class==12
replace class=class-1 if class>=5
replace class=8 if class==9
lab var class "EGP-Klassen"
lab val class class
#delimit ;
lab def class  1 "I"
               2 "II"
               3 "III"
               4 "IVab"
               5 "IVcd"
               6 "V"
               7 "VI"
               8 "VII";
#delimit cr

gen frau=v141==2                                           /*Geschlecht*/
lab var frau "Frau j/n"
lab val frau yesno
lab def yesno 0 "nein" 1 "ja"

gen rel=v319                                    /*Kirchgangshaeufigkeit*/
lab var rel "Kirchgang"
lab val rel v319

gen kon=v318                                               /*Konfession*/
recode kon 3=2 6=3 4 5=.
lab var kon "Konfession"
lab val kon kon
lab def kon 1 "kath." 2 "ev." 3 "keine"
quietly tab kon, gen(kon)


gen polint1=6-v106                           /*Politisches Intersse*/
gen polint2=6-v399
quietly factor polint1 polint2         /* -> Note */
quietly score polint
quietly sum polint
replace polint=polint+abs(_result(5))+1
drop polint1 polint2
lab var polint "Politisches Interesse"

gen polinf = (5-v403)+(v405-1)+1         /*Politische Informiertheit*/
lab var polinf "Selbsteinschaetzung Pol. Informiertheit"
lab val polinf gut9
lab def gross10 1 "s.schlecht" 5 "mittel" 9 "s.gut"
log on

d wahl class frau rel kon polint polinf
*-------------------------ANALYSE----------------------------------------

* Untersucht wird, ob der Klasseneffekt vom Politischen Interesse bzw. der
* Politischen Informiertheit abhaengt. Wenn der Klasseneffekt auf Interessen
* zurueckzufuehren ist, sollte er bei politisch Informierten Menschen staerker
* sein. Zunaechst wird untersucht ob der Interaktionseffekt Klasse*Polit.
* Interesse vorhanden ist. Danach wird untersucht, ob die Koeffizienten der
* schlecht Informierten absolut niedriger sind, als die Koeffizienten der
* gut Informierten. Dies geschieht durch die Bildung der Differenz zwischen
* den jeweiligen Koeffizienten eines Modells fÅr schlecht Informierten mit
* den Koeffizienten eines Modells fÅr die gut Informierten.


* 1) Interaktionsterm Klasse*Politisches Interesse bzw. Informiertheit

* Politisches Interesse

xi i.class*polint                                               /*West*/
gen valid=1 if wahl~=. & class~=. & kon~=. & rel~=. & v37~=. /*
        */ & frau~=. & polint~=.
mlogit wahl I* frau rel kon2 kon3 v37 /*
        */ if v3==1 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest, saving(0)
xi: mlogit wahl i.class frau rel kon2 kon3 v37 /*
        */ if v3==1 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest

xi i.class*polint
mlogit wahl I* frau rel kon2 kon3 v37 /*                        /*Ost*/
        */ if v3==2 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest, saving(0)
xi: mlogit wahl i.class frau rel kon2 kon3 v37 /*
        */ if v3==2 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest

drop valid
* Politische Informiertheit
xi i.class*polinf                                               /*West*/
gen valid=1 if wahl~=. & class~=. & kon~=. & rel~=. & v37~=. /*
        */ & frau~=. & polinf~=.
mlogit wahl I* frau rel kon2 kon3 v37 /*
        */ if v3==1 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest, saving(0)
xi: mlogit wahl i.class frau rel kon2 kon3 v37 /*
        */ if v3==1 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest

xi i.class*polinf                                               /*Ost*/
mlogit wahl I* frau rel kon2 kon3 v37 /*
        */ if v3==2 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest, saving(0)
xi: mlogit wahl i.class frau rel kon2 kon3 v37 /*
        */ if v3==2 & (v4 ==1 | v4==2) & valid==1, nolog
lrtest


*2) Staerke der Koeffizienten  (nur Westdeutsche)

sum polinf, d
gen polinf4=1 if polinf<=_result(9)
replace polinf4=2 if polinf>=_result(11)
sum polint, d
gen polint4=1 if polinf<=_result(9)
replace polint4=2 if polinf>=_result(11)

* Politische Informiertheit
xi: mlogit wahl i.class frau rel kon2 kon3 v37 /*
        */ if v3==1 & (v4==1 | v4==2) & polinf4==1, nolog
matrix B1=get(_b)
matrix B1=B1["y1".."y3","Iclass_2".."Iclass_8"]
matrix B1=B1'

xi: mlogit wahl i.class frau rel kon2 kon3 v37 /*
        */ if v3==1 & (v4==1 | v4==2) & polinf4==2, nolog
matrix B2=get(_b)
matrix B2=B2["y1".."y3","Iclass_2".."Iclass_8"]
matrix B2=B2'

svmat B1
svmat B2

gen delta1=B21-B11
gen delta2=B22-B12
gen delta3=B23-B13
lab var delta1 "Kontrast CDU vs. SPD"
lab var delta2 "Kontrast CDU vs. FDP"
lab var delta3 "Kontrast CDU vs. B90"
gen str4 names="II" in 1
replace names="III" in 2
replace names="IVab" in 3
replace names="IVcd" in 4
replace names="V" in 5
replace names="VI" in 6
replace names="VII" in 7
list names delta* in 1/8
#delimit ;
graph delta* if delta1<20 & delta2<20 & delta2<20, oneway box    /* -> Note */
              b1title("Differenz der b-Koeffizienten der EGP-Klassen")
              t1title("(Gut Informierte - Schlecht Informierte)")
              saving(anvorfr1, replace) ;
#delimit cr
exit

--------------------------------------------------------------------------
Bemerkungen:
Das Politische Interesse wurde sowohl im regulÑren Allbus, als auch in der
schriftlichen ISSP Zusatzbefragung abgefragt. Beide Variablen korrelieren
mit .88 miteinander. Ein Scatterplott beider Varibalen zeigt, da· einige
Befragte extrem unterschiedliche Angaben gemacht haben. Da nicht entschieden
werden kann, welche der Angaben richtiger ist, wurde das politische Interesse
durch eine Faktorenanalyse der beider Variablen gebildet. Der erste Faktor
erklÑrt jeweils 94% der Varianz der beiden Ausgangsvariablen. Die Scores der
FÑlle auf dem ersten Faktor wird als Variable Politisches Interesse
bezeichnet.

Die multinomilalen logistischen Regressionen konvergieren erst
nach zahlreichen Iterationen. Dennoch scheint kein ernsthaftes Konvergenz-
problem vorzuliegen. Eine Testlauf des ersten Modells mit andern Toleranzen
(.003 und .0003) brachten sowohl beim Modellfit als auch bei den Koeffizienten
vergleichbare Ergebnisse.

In jeder Teilgraphik wurde jeweils 1 Koeffizient, der wegen
"High-Discrimination" extreme (positive) Werte aufwies entfernt. Es handelt
sich dabei um den Koeffizienten der Klasse IVcd (Landwirte) in allen drei
Kontrasten im Modell fÅr die Gut Informierten.



Fragetexte:

V4: (aus) Welche StaatsbÅrgerschaft haben Sie? Wenn Sie die
StaatsbÅrgerschaft mehrerer LÑnder besitzen, nennen Sie
mir bitte alle. (Int.: Mehrfachnennungen mîglich! Mit der niedrigsten
zutreffenden Fragenummer weiterfragen!)

V37: (aus) Sagen Sie mir bitte, in welchem Monat und in welchem
Jahr Sie geboren sind?

V106: Nun zu etwas ganz anderem. Wie stark interessieren Sie sich fÅr
Politik? (Int.: Vorgaben bitte vorlesen!)

Sehr stark/Stark/Mittel/Wenig/öberhaupt nicht

V318: Welcher Religionsgemeinschaft gehîren Sie an?
(Int.: Liste S54 vorlegen! Nur eine Nennung mîglich!)
Der rîmisch-katholischen Kirche/Der evangelischen Kirche (ohne
Freikirchen)/Einer evangelischen Freikirche/Einer anderen christlichen
Religionsgemeinschaft/Einer anderen, nicht-christlichen Religionsgemein-
schaft/Keiner Religionsgemeinschaft

V319: Wie oft gehen Sie im allgemeinen in die Kirche?
(Int.: Vorgaben bitte vorlesen!)
Mehr als einmal in der Woche/Einmal in der Woche/Ein- bis dreimal im
Monat/Mehrmals im Jahr/Seltener/Nie

V325: Wenn am nÑchsten Sonntag Bundestagswahl wÑre, welche
Partei wÅrden Sie dann mit Ihrer Zweitstimme wÑhlen?
(Int.: Liste S59 vorlegen! Nur eine Nennung mîglich!)
CDU bzw. CSU/SPD/F.D.P./leer/leer/BÅndnis 90,Die GrÅnen/Die Republikaner/
PDS/Andere Partei, und zwar:/WÅrde nicht wÑhlen

V399: (ISSP) Wie stark interessieren Sie sich fÅr Politik: sehr
stark, stark, mittel, wenig oder Åberhaupt nicht?
Bitte nur ein KÑstchen ankreuzen!

V403: Bitte geben Sie an, inwieweit Sie folgenden Aussagen
zustimmen oder nicht zustimmen: Ich glaube, ich habe einen ziemlich guten
Einblick in die wichtigen politischen Probleme, denen Deutschland gegen-
Åbersteht.
Stimme stark zu/Stimme zu/Weder-noch/Stimme nicht zu/Stimme Åberhaupt
nicht zu

v405: Bitte geben Sie an, inwieweit Sie folgenden Aussagen
zustimmen oder nicht zustimmen: Ich glaube, die meisten Leute sind besser
Åber Politik informiert als ich es bin.
Stimme stark zu/Stimme zu/Weder-noch/Stimme nicht zu/Stimme Åberhaupt
nicht zu

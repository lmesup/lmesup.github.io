* Graphik zur Darstellung der Ergebnisse von Verbrugge (1977: 585)
version 6.0

* Dateneingabe
clear
input str20 Position df1 df2 df3 jf1 jf2 jf3
 Beruf              1.72 1.85 1.78 2.43 2.25 2.14
 Erwerbsstatus      1.09 1.09 1.05 1.07 1.04 1.03
 Bildung            1.87 1.77 1.67   .   .    .
 Alter              2.45 2.36 2.20 2.71 2.37 2.52
 Familienstand       .    .    .   1.24 1.45 1.17
 Geschlecht          .    .    .   1.58 1.50 1.52
 Nationalitaet      1.58 1.67 1.53  .    .    .
 Parteipraeferenz   1.53 1.54 1.39 1.68 1.56 1.55
 Religiositaet      1.56 1.47 1.45 1.28 1.23 1.25
 Neubuerger          .    .     .  1.59 1.49 1.46
 Berufsprestige     1.55 1.60 1.54 1.74 1.77 1.72
end
lab var df1 "Detroid Freund 1"
lab var df2 "Detroid Freund 2"
lab var df3 "Detroid Freund 3"
lab var jf1 "Juelich Freund 1"
lab var jf2 "Juelich Freund 2"
lab var jf3 "Juelich Freund 3"

* Berechnung der mittleren Homophilie
gen meand = (df1 + df2 + df3)/3
gen meanj = (jf1 + jf2 + jf3)/3
lab var meand "Detroit (1966)"
lab var meanj "Juelich (1971)"

* Ordnung nach Homophilie in Juelich, bei fehlenden Angaben Detroit
gen sort = meanj
replace sort = meand if sort==.
gsort -sort

hplot meanj meand, legend(Position) border grid pen(23) xscale(0.9,2.6) /*
*/ symbol(op) xlabel(1.0,1.5,2.0,2.5) format(%2.1f) /*
*/ title(Mittlere Homophilie) fontrb(570) fontcb(290) /*
*/ saving(verbr.gph, replace)

exit

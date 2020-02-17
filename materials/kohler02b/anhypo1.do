* Hypothese:                                                            /*

 */ "Die PID ver„ndert sich bei einem Stellungswechsel auch dann  /*
 */  wenn kein Klassenwechsel stattgefunden hat.

* mit Variablen des Sozio”konomischen Panels, L„ngsschnitt, balanced,

*----------------------------------DATENSATZ-----------------------------
use hypo1, clear
drop hhnr sex-mhhnr nation* erw*
reshape long polint lr pii bst bchg wchg, i(persnr) j(welle)
iis persnr
tis welle

*-------------------------------REKODIERUNGEN------------------------------
gen bst6=int(bst/10)+1
replace bst6=6 if bst6==5
replace bst6=5 if bst==30           /* <- Landwirte */
lab var bst6 "Berufliche Stellung"
lab val bst6 bst4
lab def bst6 1 "Arbeiter" 2 "Angest."  3 "Beamte" 4 "Selbst." 5 "Landw."   /*
*/           6 "Azubi"
quietly tab bst6, gen(bstd)

note: long-format Data von hypo1.dta

save hypo1l, replace
*-----------------------------ANALYSE--------------------------------------

* Deskription
for pii bst6 bchg wchg: tab @, mis
for /* lr */ pii /* bst6 */ bchg wchg: xttab @
for lr pii bst6 bchg wchg: xttrans @

xtdata, fe
qplot pii,  saving(g1, replace)
qplot bchg, saving(g2, replace)
qplot wchg, saving(g3, replace)
qplot bstd1, saving(1, replace)
qplot bstd2, saving(2, replace)
qplot bstd3, saving(3, replace)
qplot bstd4, saving(4, replace)
qplot bstd5, saving(5, replace)
qplot bstd6, saving(6, replace)
graph using 1 2 3 4 5 6, saving(g4, replace)
graph using g1 g2 g3 g4, saving(g1hypo1, replace)

* Veraenderung der PI-Intensitaet

* Within - Regression
use hypo1l, replace
xtreg pii bchg wchg bstd2-bstd6, fe
xtreg pii bchg wchg bstd2-bstd6, be

* Lagged-Variable-Regression
sort persnr welle
quietly for pii bst6 bchg wchg: gen @lag=@[_n-1]
quietly tab bst6lag, gen(bstlagd)
reg pii bchg wchg bstd2-bstd6 piilag bchglag wchglag bstlagd2-bstlagd6

exit

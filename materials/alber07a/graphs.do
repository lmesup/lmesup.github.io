version 9.2
set more off
set scheme s1mono
cd M:\group\ARS\USI\kohler\participation07\analysen


use 11.dta, clear


// Durchschnittlicher b-Koeffizient über die Datensätze by Land und Stratifizierungsvariable //
drop if b==0
*drop b_average
assert b < .
by iso3166_2 strat, sort: gen b_average=sum(b)/sum(b!=.)
by iso3166_2 strat, sort: replace b_average=b_average[_N]



// Erzeugung einer Reihenfolgevariablen für die Funktion: egen axis //

preserve
*drop row
by strat b_average iso3166_2, sort: gen row = _n

keep if row == 1

*drop row2
drop axis
by strat, sort: gen row2 = _n

save row.dta, replace
restore

merge b using row, sort
drop _merge

by strat iso3166_2, sort: replace row2=row2[1] if row2==.
by strat iso3166_2, sort: replace row2=row2[2] if row2==.
by strat iso3166_2, sort: replace row2=row2[3] if row2==.
by strat iso3166_2, sort: replace row2=row2[4] if row2==.
by strat iso3166_2, sort: replace row2=row2[5] if row2==.




// Festlegung der Reihenfolge auf der Y-Achse für die Graphik: hhinc//
*drop axis2
egen axis2 = axis(row2) if strat == "hhinc", reverse label(iso3166_2)





// Erstellen der Graphik: hhinc (durchschnittlicher b-Wert über alle Datensätze) //
tw dot b_average axis2 if strat== "hhinc", horizontal ylabel(1(1)35, valuelabel angle(0))   ///
ytitle("") xtitle("Difference in voting participation between lowest and highest HH-income-quintile") ///
xsize(5) ysize(7)


// Erstellen der Graphik: hhinc (einzelne b-Werte aller Datensätze) //
tw dot b axis2 if dataset=="creqls_1" & strat== "hhinc", horizontal msymbol(Oh) mcolor(black) legend(label(1 "EQLS")) ///
|| dot b axis2 if dataset=="issp02" & strat== "hhinc", horizontal ms(O) mcolor(black) legend(label(2 "ISSP")) ///
|| dot b axis2 if dataset=="cses01" & strat== "hhinc", horizontal ms(d) mcolor(gs9) legend(label(3 "CSES")) ///
|| dot b axis2 if dataset=="cress02_01" & strat== "hhinc", horizontal ms(S) mcolor(black) legend(label(4 "ESS '02")) ///
|| dot b axis2 if dataset=="cress04_01" & strat== "hhinc", horizontal ms(S) mcolor(gs9) legend(label(5 "ESS '04")) ///
ylabel(1(1)35, valuelabel angle(0)) ytitle("") ///
xtitle("Difference in voting participation between lowest and highest HH-income-quintile") xsize(5) ysize(7)






// Graphiken
tw dot b axis if dataset=="creqls_1" & strat== "hhinc", horizontal ///
|| dot b axis if dataset=="issp02" & strat== "hhinc", horizontal || , ylabel(1(1)36, valuelabel angle(0))

label var iso3166_2 "Countries"
tw dot b_average axis if strat == "hhinc", horizontal ylabel(1(1)36, valuelabel angle(0)) 












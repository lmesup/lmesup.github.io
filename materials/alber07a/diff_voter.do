* Difference in electoral participation
* Author: lenarz@wzb.eu
* Rework: kohler@wzb.eu
version 9.2
set more off
set scheme s1mono

//Behälter für zu erzeugenden Datensatz definieren
quietly {
tempfile diff
postfile coefs str2 iso3166_2 str10 dataset str10 strat b using `diff', replace

// Get Data
foreach dataset in issp02 cses01 cress02_01 cress04_01 creqls_1   {
	use ///
	iso3166_2 voter ///
	dataset hhinc edu emp ///
	using `dataset', clear

	//Dummys der Statifizierungsvariablen bilden
	tab hhinc, gen(hhinc)
	tab edu, gen(edu)
	tab emp, gen(emp)


	//Differenzen by country 
	levelsof iso3166_2, local(K)
	foreach k of local K {
		if "`k'" != "BE" | "`dataset'" != "issp02" {
		reg voter hhinc2-hhinc5 if iso3166_2 == "`k'" 
		post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5])
		if "`k'" != "GB" | "`dataset'" != "cress04_01" reg voter edu2 edu3 if iso3166_2 == "`k'" 
		if "`k'" != "GB" | "`dataset'" != "cress04_01" post coefs("`k'") ("`dataset'") ("edu") (_b[edu3])
		reg voter emp1 emp3-emp5 if iso3166_2 == "`k'" 
		post coefs("`k'") ("`dataset'") ("emp") (_b[emp1])
									 }
				   }
  								                  }
        }

postclose coefs

use `diff', replace

// Durchschnittlicher b-Koeffizient über die Datensätze by Land und Stratifizierungsvariable //
*drop if b==0
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
*drop axis
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



drop axis*


levelsof strat, local(K)
foreach k of local K {

	// Festlegung der Reihenfolge auf der Y-Achse für die Graphik: hhinc, edu, emp //
	egen axis`k' = axis(row2) if strat == "`k'", reverse label(iso3166_2)

	// Erstellen der Graphik: hhinc, edu, emp (durchschnittlicher b-Wert über alle Datensätze) //
	tw dot b_average axis`k' if strat== "`k'", horizontal ylabel(1(1)36, valuelabel angle(0))   ///
	ytitle("") xtitle("Difference in voting participation between lowest and highest `k'-category") ///
	xsize(5) ysize(7)


	// Erstellen der Graphik: hhinc, edu, emp (einzelne b-Werte aller Datensätze) //
	tw dot b axis`k'  if dataset=="creqls_1" & strat== "`k'", horizontal msymbol(O) mcolor(black) mfcolor(white) legend(label(1 "EQLS")) ///
	|| dot b axis`k'  if dataset=="issp02" & strat== "`k'", horizontal ms(O) mcolor(black) legend(label(2 "ISSP")) ///
	|| dot b axis`k'  if dataset=="cses01" & strat== "`k'", horizontal ms(d) mlcolor (black) mfcolor(gs9) legend(label(3 "CSES")) ///
	|| dot b axis`k'  if dataset=="cress02_01" & strat== "`k'", horizontal ms(S) mcolor(black) legend(label(4 "ESS '02")) ///
	|| dot b axis`k'  if dataset=="cress04_01" & strat== "`k'", horizontal ms(S) mlcolor (black) mfcolor(gs9) legend(label(5 "ESS '04")) ///
	ylabel(1(1)36, valuelabel angle(0)) ytitle("") ///
	xtitle("Difference in voting participation between lowest and highest `k'-category") xsize(10) ysize(7) ///
	legend(rows(5) position(3))
		         }

			  







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

			   
					  




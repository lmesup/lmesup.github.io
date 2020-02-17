* Difference in electoral participation
* kohler@wzb.eu

* Based on diff_voeter by  lenarz@wzb.eu
version 9.2
set more off
set scheme s1mono

//Behälter für zu erzeugenden Datensatz definieren
tempfile diff
postfile coefs str2 iso3166_2 str10 dataset str10 strat b using `diff', replace

*quietly {

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
			if  "`dataset'" == "issp02" {
				if "`k'" != "BE" {
					reg voter hhinc2-hhinc5 if iso3166_2 == "`k'" 
					post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5])
					reg voter edu2 edu3 if iso3166_2 == "`k'" 
					post coefs ("`k'") ("`dataset'") ("edu") (_b[edu3])
					reg voter emp1 emp3-emp5 if iso3166_2 == "`k'" 
					post coefs ("`k'") ("`dataset'") ("emp") (_b[emp1])
				}
			}
			else if  "`dataset'" == "cress04_01" {
				if "`k'" != "GB" {
					reg voter hhinc2-hhinc5 if iso3166_2 == "`k'" 
					post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5])
					reg voter edu2 edu3 if iso3166_2 == "`k'" 
					post coefs ("`k'") ("`dataset'") ("edu") (_b[edu3])
					reg voter emp1 emp3-emp5 if iso3166_2 == "`k'" 
					post coefs ("`k'") ("`dataset'") ("emp") (_b[emp1])
				}
			}
			else {
				reg voter hhinc2-hhinc5 if iso3166_2 == "`k'" 
				post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5])
				reg voter edu2 edu3 if iso3166_2 == "`k'" 
				post coefs ("`k'") ("`dataset'") ("edu") (_b[edu3])
				reg voter emp1 emp3-emp5 if iso3166_2 == "`k'" 
				post coefs ("`k'") ("`dataset'") ("emp") (_b[emp1])
			}
		 }
	}	
*}
postclose coefs

use `diff', replace

// Durchschnittlicher b-Koeffizient über die Datensätze by Land und Stratifizierungsvariable 
assert b < .
by iso3166_2 strat, sort: gen b_average=sum(b)/sum(b!=.)
by iso3166_2 strat, sort: replace b_average=b_average[_N]

levelsof strat, local(K)
foreach k of local K {

	// Festlegung der Reihenfolge auf der Y-Achse für die Graphik: hhinc, edu, emp //
	egen axis`k' = axis(b_average) if strat == "`k'", reverse label(iso3166_2)

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

			  

			   
					  




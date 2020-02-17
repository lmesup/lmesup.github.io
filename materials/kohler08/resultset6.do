* Repräsentativität (harte Analyse: Stadt-Land)
* luniak@wz-berlin.de

version 8.2

clear
set memory 80m
set more off

// Anteil der Frauen Stadt-Land
// ------------------------------
use hdata, clear
keep if stadt ~= .

// tabelle2
sort stadt
by stadt : tab iso3166_2 female , nof row

// data reshape
collapse (mean) female, by(iso3166_2 source stadt)
by source iso3166_2, sort: gen index = 1 if _n==1
replace index = sum(index)
reshape wide female, i(index) j(stadt)
drop index
reshape wide female0 female1, i(iso3166_2) j(source) string


//Ausgabe des Ergebnisses 
drop if iso3166_2 == "GB (Northern Irelan"
compress
format female0eqls - female1ess %3.2f
* Anteil der Frauen auf dem Land (0) und in der Stadt (1)
list , table 


// Wahrscheinlichkeit des Ergebnisses
// ----------------------------------
use hdata, clear
gen n = 1 if female <.

//binom-werte
collapse(sum) n female, by(iso3166_2 stadt source)
gen binom = Binomial(n, female, .5) - Binomial(n, female +1, .5)
drop n female

// reshape
sort source iso3166_2
by source iso3166_2: gen index = 1 if _n==1
replace index = sum(index)
keep if stadt ~= .
reshape wide binom, i(index) j(stadt)
drop index
reshape wide binom0 binom1, i(iso3166_2) j(source) string


//Ausgabe des Ergebnisses
drop if iso3166_2 == "GB (Northern Irelan"
compress
format binom0eqls - binom1ess %5.4f
* Wahrscheinlichkeit des Ergebnisses unter der Annahme,
* dass der Anteil der Frauen 50% beträgt
list , table 

exit

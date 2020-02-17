* Repr�sentativit�t (harte Analyse: Einkommen)
* luniak@wz-berlin.de

version 8.2

clear
set memory 80m
set more off

//Anteil der Frauen in 1. und 4. Eikommensquartile
use hdata, clear
drop if hinc == .

// tabelle2
sort hinc
by hinc : tab iso3166_2 female , nof row

// 1. und 4. Einkommensquartil
keep if hinc == 1 | hinc == 4

// data reshape
collapse (mean) female, by(iso3166_2 source hinc)
by source iso3166_2, sort: gen index = 1 if _n==1
replace index = sum(index)
reshape wide female, i(index) j(hinc)
drop index
reshape wide female1 female4, i(iso3166_2) j(source) string


// Ausgabe des Ergebnisses
drop if iso3166_2 == "GB (Northern Irelan"
compress
format female1eqls - female4ess %3.2f
* Anteil der Frauen im 1. und 4. Einkommensquartile
list , table 


// Wahrscheinlichkeit des Ergebnisses
// ----------------------------------
use hdata, clear
gen n = 1 if female <.

// binom-werte
collapse(sum) n female, by(iso3166_2 hinc source)
gen binom = Binomial(n, female, .5) - Binomial(n, female +1, .5)
drop n female

// reshape
sort source iso3166_2
by source iso3166_2: gen index = 1 if _n==1
replace index = sum(index)
keep if hinc ~= .
reshape wide binom, i(index) j(hinc)
drop index binom2 binom3
reshape wide binom1  binom4, i(iso3166_2) j(source) string


// Ausgabe des Ergebnisses
drop if iso3166_2 == "GB (Northern Irelan"
compress
format binom1eqls - binom4ess %3.2f
* Wahrscheinlichkeit des Ergebnisses unter der Annahme,
* dass der Anteil der Frauen 50% betr�gt
list , table abbreviate(4)

exit

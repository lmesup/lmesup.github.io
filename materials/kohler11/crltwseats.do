// Seats in Landtagswahlen Germany
// -------------------------------
// kohler@wzb.eu

version 10

// Produce the data set
// --------------------

insheet using ltwseats.raw, clear

// Little Helpers
tempvar tag index
gen `index' = _n
gen `tag' = v3 != ""
replace `tag' = sum(`tag')

// Area, Election date
by `tag' (`index'), sort: gen area = v3[1]
by `tag' (`index'), sort: gen eldatestr = v4[1]
drop if v1==""
drop v3 v4  `tag' `index'

// Party data
ren v1 party
replace party=trim(party)
ren v2 seats

// Elapsed election date
gen long eldate = date(eldatestr,"DMY")
format %tddd_Mon_YY eldate
lab var eldate "Election date"
drop eldatestr

// Keep only BRD!
drop if eldate < date("23.05.1949","DMY") 
drop if eldate < date("01.01.1957","DMY") & area == "SL"

// Labels and Friends
// ------------------

label variable area "Bundesland"
label variable party "Party"
label variable seats "Seats in parliament"

note: statisbu95

compress
order area eldate party seats
sort area eldate party
save ltwseats, replace

exit

Notes
-----


@BOOK{statisbu05,
editor = {{Statistisches Bundesamt}},
year = {2005},
title = {Wahl zum 16. deutschen Bundestag am 18. September 2005. Heft 1: Ergebnisse
	und Vergleichszahlen frueherer Bundestags- Europa- und Landtagswahlen
	sowie Strukturdaten fuer die Bundestagswahlkreise.},
address = {Stuttgart},
publisher = {Metzler-Poeschel}}
@ARTICLE{statisbu05b,
author = {{Statistisches Bundesamt}},
title = {Endgueltiges Ergebnis der Wahl zum 16. Deutschen Bundestag am 18.
	September 2005},
journal = {Wirtschaft und Statistik},
year = {2005},
volume = {11/2005},
pages = {1153--1167},
url = {http://www.bundeswahlleiter.de/bundestagswahl2005/downloads/endgueltigesergebnisderbundestagswahl2005.pdf}
	        

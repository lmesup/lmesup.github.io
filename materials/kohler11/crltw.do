// Landtagswahlen Germany 1949--2005
// ---------------------------------
// kohler@wzb.eu

version 10


// Produce the data set
// --------------------

insheet using ltw.raw, clear

// Little Helpers
tempvar tag index
gen `index' = _n
gen `tag' = v3 != ""
replace `tag' = sum(`tag')

// Area, Election date
by `tag' (`index'), sort: gen area = v3[1]
by `tag' (`index'), sort: gen eldatestr = v4[1]
drop if v1==""
drop v3 v4 

// Overal Election data
foreach var in nelectorate nvoters ninvalid nvalid nmissing {
	gen long `var' = v2 if v1 == "`var'"
	by `tag' (`var'), sort: replace `var' = `var'[1]
	drop if v1 == "`var'"
	}
drop `tag' `index'

// Party data
ren v1 party
replace party = trim(party)
ren v2 npartyvotes

// Elapsed election date
gen long eldate = date(eldatestr,"DMY")
format %tddd_Mon_YY eldate
lab var eldate "Election date"

// Keep only BRD!
drop if eldate < date("23.05.1949","DMY") 
drop if eldate < date("01.01.1957","DMY") & area == "SL"

// Use average for BY
replace nvalid = nvalid/2 if area == "BY" 
replace ninvalid = ninvalid/2 if area == "BY"
replace npartyvotes = npartyvotes/2 if area == "BY"


// Labels and Friends
// ------------------

label variable area "Bundesland"
label variable eldatestr "Election date (string)"
label variable nelectorate "Electorate"
label variable nvoters "Voters turned up"
label variable nvalid "Valid votes"
label variable ninvalid "Invalid votes"
label variable nmissing "Missing votes (reported by source)"
label variable party "Party"
label variable npartyvotes "Votes for party ('Zweitstimme')"


note: statisbu95

// Consistency checks
// -------------------

// Is electorate larger than voters, invalid and valid?
assert nelectorate > nvoters if !mi(nvoters)
assert nelectorate > ninvalid if !mi(ninvalid)
assert nelectorate > nvalid if !mi(nvalid)

// Do valid + invalid add to nvoters?
assert nvalid + ninvalid + cond(nmissing!=.,nmissing,0) == nvoters if area != "BY"

// Do votes for parties adds up to nvalid?
tempvar control
by area eldatestr, sort: gen `control' = sum(npartyvotes)
by area eldatestr: assert nvalid == `control'[_N]  ///
  if area != "BY" & eldatestr != "26.11.1950" // Missing votes for this election!
note npartyvotes: 41019 votes missing for BY 1950
drop `control'


compress
save ltw, replace

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
	        

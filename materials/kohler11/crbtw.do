// Election Results Germany 1949--2005
// -----------------------------------
// kohler@wzb.eu

version 10
clear

// Election data
// =============

insheet area eldatestr nelectorate nvoters nvalid  ///
  using btwvoters.raw, clear

// Labels and Friends
// ------------------

label variable area "Area area"
label variable eldatestr "Election date (string)"
label variable nelectorate "Electorate"
label variable nvoters "Voters turned up"
label variable nvalid "Valid votes ('Zweitstimme')"

note: statisbu95, statisbu95b


// Derived variables
// -----------------

// Elapsed election date
gen long eldate = date(eldatestr,"DMY")
format %tddd_Mon_YY eldate
lab var eldate "Election date"

// Invalid votes
gen long ninvalid=nvoters-nvalid
lab var ninvalid "Invalid votes"

// Consistency checks
// -------------------

// Is electorate larger than voters, invalid and valid?
assert nelectorate > nvoters if !mi(nvoters)
assert nelectorate > ninvalid if !mi(ninvalid)
assert nelectorate > nvalid if !mi(nvalid)

// Do states sum up to Germany?
sort eldate nelectorate
foreach var of varlist nelectorate nvoters nvalid ninvalid {
	tempvar control
	by eldate: gen long `control' = sum(`var') if _n!=_N
	by eldate: assert `control'[_N-1] == `var'[_N] if `var'[_N] != .
	by eldate: assert `control'[_N-2] == `var'[_N-1] if `var'[_N] == . // SL
	drop `control'
}

// Prepare for merge
// -----------------

format n* %12.0f

order area eldatestr eldate nelectorate 	/// 
  nvoters nvalid ninvalid 
compress
sort area eldate
tempfile elections
save `elections'


// Party data
// ==========

insheet area eldatestr party npartyvotes ///
  using btwpartyvotes.raw, clear

// Labels and Friends
// ------------------

label variable area "Area area"
label variable eldatestr "Election date (string)"
label variable party "Party"
label variable npartyvotes "Votes for party ('Zweitstimme')"

note: statisbu95, statisbu95b


// Derived variables
// -----------------

// Elapsed election date
gen long eldate = date(eldatestr,"DMY")
format %tddd_Mon_YY eldate
lab var eldate "Election date"


// Consitency Checks
// -----------------

// Do states sum up to Germany?
tempvar control
replace area = "ZZ" if area == "DE"
by eldate party (area), sort: gen long `control' = sum(npartyvotes) if _n!=_N
by eldate: assert `control'[_N-1] == npartyvotes[_N]
replace area = "DE" if area == "ZZ"
drop `control'

// Number of areas per election correct?
levelsof eldate, local(K)
foreach k of local K {
	quietly tab area if eldate == `k'
	assert r(r) == 10 if `k' <  date("15 Sep 1957","DMY")
	assert r(r) == 11 if `k' >=  date("15 Sep 1957","DMY") & `k' < date("2 Dec 1990","DMY")
	assert r(r) == 17 if `k' >=  date("2 Dec 1990","DMY")
}


// Prepare for merge
// -----------------

format n* %12.0f
compress
sort area eldate
tempfile parties
save `parties'


// Merge
// =====

use `elections'
merge area eldate using `parties'
assert _merge==3
drop _merge

// Consistency checks
// -------------------

// Do sum of party add up to valid votes?

tempvar control
by eldate area, sort: gen long `control' = sum(npartyvotes)
by eldate area: assert `control'[_N] == nvalid
drop `control'

  
compress
save btw, replace

exit

Notes
-----


@BOOK{statisbu05,
editor = {{Statistisches Bundesamt}},
year = {2005},
title = {Wahl zum 16. deutschen Bundestag am 18. September 2005. Heft 1: Ergebnisse
	und Vergleichszahlen früherer Bundestags- Europa- und Landtagswahlen
	sowie Strukturdaten für die Bundestagswahlkreise.},
address = {Stuttgart},
publisher = {Metzler-Poeschel}}
@ARTICLE{statisbu05b,
author = {{Statistisches Bundesamt}},
title = {Endgültiges Ergebnis der Wahl zum 16. Deutschen Bundestag am 18.
	September 2005},
journal = {Wirtschaft und Statistik},
year = {2005},
volume = {11/2005},
pages = {1153--1167},
url = {http://www.bundeswahlleiter.de/bundestagswahl2005/downloads/endgueltigesergebnisderbundestagswahl2005.pdf}
	        

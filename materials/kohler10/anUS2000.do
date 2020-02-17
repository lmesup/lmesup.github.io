// US Turnout by pgap, state and year
version 10
set more off

// Compile data
// ------------

// US Election Project
insheet year state vap vep votes using "~/data/agg/Turnout 1980-2006.csv", clear

replace state = trim(state)
replace state = "D.C." if state == "District of Columbia"

gen turnout = 100*(votes/vep)
label variable turnout "Turnout (Votes/VEP)"
drop if strpos(state,"United States")>0

keep if mod(year,4)==0

sort year state

lab var vap "Voting age population"
lab var vep "Voting eligible population"
lab var votes "Valid votes"

tempfile turnout
save `turnout'

// Dave Leip's Atlas of U.S. Presidential Elections
use ~/data/agg/eleUS if year >= 1980 , clear
replace state = trim(state)
replace state = "D.C." if state == "D. C."

// Merge
sort year state
merge year state using `turnout'
assert _merge==3
drop _merge


gen nonvoters = round((vep - totalvote)*.86,1)  // .86 = Invalid + legal excuses
gen pgap = proprep - propdem
gen absgap = votesrep - votesdem
gen winner = pgap > 0

sort pgap
gen college = evdem + evrep + cond(evoth!=.,evoth,0)
by election winner (pgap), sort: gen cumcollege = sum(college)

format turnout pgap %2.0f
capture log close
log using anUS2000, replace
list state vep nonvoters turnout absgap pgap college cumcollege if year == 2000, sepby(winner) noobs table
log close


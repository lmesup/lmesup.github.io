* Validation of Electoral Participation in ESS
* Author: kohler@wzb.eu

version 9.2
set more off
set scheme s1mono
capture log close
log using anvoter_valid, replace


// Compare turnout in ESS 2 with official sources
clear
set memory 200m

use cntry eldate nweight vote voter using ess04

// Distribution of Original Variable
tab cntry vote [aw=nweight], row nofreq mis

// Drop election dates with insufficient nobs
by cntry eldate, sort: drop if _N < 30 

// Calculate survey turnout-rate by Country and Election
gen all = vote==1
collapse (mean) valid=voter all [aw=nweight], by(cntry eldate)
sort cntry eldate
tempfile surveyrate
save `surveyrate'

// Merge official results from Political Data Yearbook:
// European Journal of Political Research 2002-2006
clear
input str2 cntry str9 eldatestring turnout
	BE		18May03		91.6
	CZ		14Jun02	   58.0
	DE		22Sep02		80.3
	GR	 	 7Mar04		89.1		
	AT		24Nov02		84.3
	EE		 2Mar03		58.2
	NL		22Jan03		80.0
	IS		10May03		87.7
	DK		20Nov01		87.1
	ES		14Mar04		75.7
	SK		20Sep02	   70.0
	HU 	 7Apr02		70.5 
	SI		 3Oct04		60.6
	SE    15Sep02		80.1
	GB		 7Jun01		59.4		    
	PT		17Mar02 		61.5
	PT		20Feb05		64.3
	NO		10Sep01		75.5
	FI	 	16Mar03		66.7
	FR		16Jun02		64.4
	LU	   13Jun04		91.9
	IE		17May02		62.6
	PL		23Sep01		46.3
	CH		19Oct03		45.2
end

gen eldate = daily(eldatestring,"dm20y")
drop eldatestring
sort cntry eldate
tempfile official
save `official'

use `surveyrate'
merge cntry eldate using `official'
assert _merge == 3
drop _merge

replace valid = valid*100
replace all = all*100
gen diff = valid - turnout

format turnout all valid diff %2.0f
sort diff

egen ctrname = iso3166(cntry), origin(codes)
format eldate %tddd_Mon_YY
list ctrname eldate turnout all valid diff, noobs clean
corr turnout valid

log close
exit


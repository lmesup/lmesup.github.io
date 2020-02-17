// Describe Election Metadata extensivly

version 10
set scheme s1mono

use elections, clear

by election: gen sumvotes = sum(nvotes)
by election: replace nvalid = sumvotes[_N] if mi(nvalid)

sort election nvotes // Do not change this line!

gen turnout = nvoters/nelectorate * 100
gen vturnout = nvalid/nelectorate * 100
gen pinvalid = ninvalid/nelectorate*100

sum pinvalid if inlist(iso3166,"BE","CY","LU")
gen addinvalid = cond((r(mean) - pinvalid)>0,r(mean) - pinvalid,0)
replace addinvalid = 100 - (vturnout+pinvalid) if (vturnout + pinvalid + addinvalid) >= 100

sum turnout if inlist(iso3166,"BE","CY","LU")
gen absvoters = cond( ///
  vturnout+pinvalid+addinvalid + (100-r(mean)) <= 100, ///
  100-r(mean), ///
  100-(vturnout+pinvalid+addinvalid) ///
  )

gen leverage = 100-(vturnout+pinvalid+addinvalid+absvoters)

gen pvotes = (nvotes/nvalid)*100
by election: gen nparty_ge1 = sum(pvote>=1) if !mi(pvote)
by election: gen nparty_ge5 = sum(pvote>=5) if !mi(pvote)
by election: gen nparty_withseats = sum(nseats>=1) if !mi(nseats)

by election (nvotes): gen pvote1st = pvotes[_N]
by election (nvotes): gen pvote2nd = pvotes[_N-1]

by election (nvotes): egen pmedian = median(pvotes) if pvotes >= 1

gen closeness = pvote1st - pmedian

by election: keep if _n==_N

format turnout pinvalid vturnout leverage pvote* pmedian closeness %3.1f
sort turnout

gen rowname = ctrname + " (" + string(eldate,"%tdDD_Mon_CCYY") + ")"


listtex rowname turnout pinvalid vturnout leverage nparty_ge1 pvote1st pmedian  ///
  using anelectiontable_table.tex  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{lccccccc}\hline" ///
  "                        &  Total   & Invalid & Valid   & & N parties & \multicolumn{2}{c}{Vote in \% of} \\ "  ///
  "Country (Election date) &  turnout & votes   & turnout & Leverage & $\ge 1\%$ & 1st party & Median party  \\ \hline") ///
  foot("\hline \end{tabular}") end("\\")

file open table using anelectiontable_notes.tex, write replace text
file write table _n "\section*{Sources and Definitions}" _n 

file write table "\begin{itemize}" _n
file write table "\item $\text{Total Turnout} = \frac{\text{Total Ballots Cast}}{\text{Registered Electorate}} {\times} 100$." _n

// Registred Electorate
file write table "\begin{itemize}" _n
file write table "\item Registered electorate:" _n
local I: char nelectorate[note0]
forv i = 1/`I' {
	local towrite: char nelectorate[note`i']
	local towrite: subinstr local towrite "_" "\_" , all
	file write table _n "`towrite'." _n
}
// Votes cast
file write table "\item Votes cast" _n
local I: char nvoters[note0]
forv i = 1/`I' {
	local towrite: char nvoters[note`i']
	local towrite: subinstr local towrite "_" "\_" , all
	file write table _n "`towrite'." _n
}
file write table "\end{itemize}" _n

// Invalid votes
file write table "\item $\text{Invalid Votes} = \frac{\text{Number of invalid votes}}{\text{Registred electorate}} {\times} 100$." _n


file write table "\begin{itemize}" _n
file write table "\item Invalid Votes:" _n
local I: char ninvalid[note0]
forv i = 1/`I' {
	local towrite: char ninvalid[note`i']
	local towrite: subinstr local towrite "_" "\_" , all
	file write table _n "`towrite'." _n
}
file write table "\end{itemize}" _n

// Valid turnout
file write table "\item $\text{Valid turnout} = \frac{\text{Number of valid votes}}{\text{Registred electorate}} {\times} 100$." _n


local AE = round(`AE',.01)
local INV = round(`INV',.01)
local mto = round(`mto',.01)
file write table "\item $\text{Leverage} = \text{Maximum Turnout} - \text{Turnout}$ ," _n
file write table _n "with Maximum Turnout is $100 - AE - INV = 100 - `AE' - `INV') = `mto'$"


file write table "\item $\text{Number of parties} = \sum\left(\frac{\text{Votes for party}}{\text{Valid votes}} \ge \text{Treshold}\right)$" _n

file write table "\begin{itemize}" _n
file write table "\item Votes for party:" _n
local I: char nvotes[note0]
forv i = 1/`I' {
	local towrite: char nvotes[note`i']
	local towrite: subinstr local towrite "_" "\_" , all
	file write table _n "`towrite'." _n
}
file write table "\item $\text{Valid Votes} = \text{Votes cast} - \text{Invalid votes}$" _n
file write table "\end{itemize}" _n
file write table "\end{itemize}" _n

file close table


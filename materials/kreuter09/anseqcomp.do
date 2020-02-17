// Comparison of used and unused sequences
// kohler@wzb.eu


version 10
clear
set memory 90m
set scheme s1mono
set matsize 5000
set more off
capture log close
log using anseqcomp, replace

use survey cntry idno visit result* using ESScontact1-3, clear

// Harmonize contact results of ESS 1 and ESS 2/3
gen result:result = 9
replace result = 1 if result1 == 1 | inlist(result2,1,2)
replace result = 2 if result1 == 2 | result2== 4
replace result = 3 if result1 == 3 | inlist(result2,3,5)
replace result = 4 if result1 == 4 | result2 == 6
replace result = 9 if result1 == 9 | result2 == 9
lab define result 1 "Interview" 2 "Contact with resp"  ///
  3 "Contact with someone" 4 "No contact"
drop result1 result2

// Tag first
bysort survey cntry idno (visit): gen first = _n==1

// Step 0: Overall
gen touse0 = 1

// Step 1: Drop all sequences with no "result information"
bysort survey cntry idno (visit): gen touse1  = sum(result==9)
by survey cntry idno (visit): replace touse1 = touse1[_N] == 0

// Step 2: Drop Sequences with gaps
by survey cntry idno (visit): gen touse2 = visit -1 != visit[_n-1] if _n > 1
by survey cntry idno (visit): replace touse2 = sum(touse2)
by survey cntry idno (visit): replace touse2 = touse2[_N]==0 & touse1

// Step 3: Drop last ellement sequences shorter 3, (i.e. 2 without last)
bysort survey cntry idno (visit): gen touse3 = _n<_N & touse2

// Step 4: Drop sequences shorter 3, (i.e. 2 without last)
by survey cntry idno (visit): gen touse4 = _N>=3 & touse3

// Last and Length 
bysort survey cntry idno (visit): gen lresult:result = result[_N]
bysort survey cntry idno (visit): gen length = _N

// Wide Date
bysort survey cntry idno (visit): keep if _n==1

// Output: Result by Observation Base
preserve
forv i = 0/4 {
	quietly {
		tab lresult if touse`i', matcell(freq`i')
		if `=rowsof(freq`i')==4' matrix freq`i' = freq`i' \ 0
	}
}
matrix freq = freq0, freq1, freq2, freq3, freq4
drop _all

svmat freq
local i 0
foreach var of varlist freq* {
	ren `var' freq`i'
	lab var freq`i' "Obs. at Step `i++'"
}

gen lresult:result = _n
lab define result 5 "No information", modify

set obs `=_N+1'

gen sum = .
forv i=0/4 {
	replace sum = sum(freq`i')
	replace freq`i' = sum[_N] if _n==_N
	gen perc`i' = round(freq`i'/freq`i'[_N] * 100,1)
}

list lresult freq* perc*, noobs


listtex lresult freq* perc* using anseqcomp_tab1.tex in 1/5 ///
  , replace rstyle(tabular) 			///
  head("\begin{tabular}{lccccc|ccccc} \hline"  	/// 
  "&\multicolumn{5}{c}{Absolute Freq.} & \multicolumn{5}{c}{Percentage} \\ "  ///
  "&All&Step 1&Step 2&Step 3&Step 4&All&Step 1&Step 2&Step 3& Step 4 \\ \hline") ///
  foot("\hline") end("\\")

listtex lresult freq* perc* in 6 ///
  , appendto(anseqcomp_tab1.tex) rstyle(tabular) 			///
  foot("\hline \end{tabular}") end("\\")

// Output: Original Length by Observation Base
restore
forv i = 0/4 {
	quietly {
		tab length if touse`i', matcell(freq`i')
		if `=rowsof(freq`i')==9' matrix freq`i' = 0 \ freq`i'
		if `=rowsof(freq`i')==8' matrix freq`i' = 0 \ 0 \ freq`i'
	}
}
matrix freq = freq0, freq1, freq2, freq3, freq4
drop _all

svmat freq
local i 0
foreach var of varlist freq* {
	ren `var' freq`i'
	lab var freq`i' "Obs. at Step `i++'"
}

gen length = _n

set obs `=_N+1'

gen sum = .
forv i=0/4 {
	replace sum = sum(freq`i')
	replace freq`i' = sum[_N] if _n==_N
	gen perc`i' = round(freq`i'/freq`i'[_N] * 100,1)
}


listtex length freq* perc* using anseqcomp_tab2.tex if _n<_N ///
  , replace rstyle(tabular) 			///
  head("\begin{tabular}{lccccc|ccccc} \hline"  	/// 
  "&\multicolumn{5}{c}{Absolute Freq.} & \multicolumn{5}{c}{Percentage} \\ "  ///
  "&All&Step 1&Step 2&Step 3&Step 4&All&Step 1&Step 2&Step 3& Step 4 \\ \hline") ///
  foot("\hline") end("\\")

listtex length freq* perc* if _n==_N ///
  , appendto(anseqcomp_tab2.tex) rstyle(tabular) 			///
  foot("\hline \end{tabular}") end("\\")




exit


// Descriptive Figure of Left-Right by Country
// kohler@wzb.eu

version 10
set more off
set scheme s1mono

use ess04, clear

gen lrsix:lrsix = 1 if inlist(leftright,0,1,2)
replace lrsix = 2 if inlist(leftright,3,4)
replace lrsix = 3 if inlist(leftright,5)
replace lrsix = 4 if inlist(leftright,6,7)
replace lrsix = 5 if inlist(leftright,8,9,10)
replace lrsix = 6 if mi(leftright)

label define lrsix 1 "Left" 2 "Centre-Left" 3 "Centre" 	///  
  4 "Centre-Right" 5 "Right" 6 "Unengaged"


// Evaluate significance
// ---------------------

tab lrsix, gen(lrsix)
tempfile mypost
postfile mypost str18 cntry    ///
  blrsix1 blrsix2 blrsix3 blrsix4 blrsix5 blrsix6  ///
  selrsix1 selrsix2 selrsix3 selrsix4 selrsix5 selrsix6  ///
  using `mypost', replace


local i 1
foreach var of varlist lrsix? {
	reg `var' voter [pw=nweight] 
	local b`i' =  _b[voter]
	local se`i++' =  _se[voter]
}
post mypost ("European average") (`b1') (`b2') (`b3') (`b4') (`b5') (`b6')  ///
  (`se1') (`se2') (`se3') (`se4') (`se5') (`se6') 


levelsof cntry, local(K)
foreach k of local K {
	local i 1
	foreach var of varlist lrsix? {
		quietly reg `var' voter [pw=nweight] if cntry == "`k'"
		local b`i' =  _b[voter]
		local se`i++' =  _se[voter]
	}
	post mypost ("`k'") (`b1') (`b2') (`b3') (`b4') (`b5') (`b6')  ///
	  (`se1') (`se2') (`se3') (`se4') (`se5') (`se6') 
}
postclose mypost

use `mypost', clear

forv i = 1/6 {
   gen sig`i' = abs(blrsix`i') >= (1.96*selrsix`i')
}

sort cntry
save `mypost', replace


// Some numbers of the text
// ------------------------

// Difference between left-right position of non-voters

use ess04, clear

// Left and right among European non-voters
keep if voter==0
gen left = inlist(leftright,0,1,2,3,4) 
gen right = inlist(leftright,6,7,8,9,10)
sum left right [aw=nweight]

// Left and right among non-voters by country
tabstat left right [aw=nweight], by(cntry) format(%3.2f)

// Significance?
gen lr = inlist(leftright,0,1,2,3,4) if right | left
collapse (mean) lr (sd) lrsd=lr (count) lrn=lr [aw=nweight], by(cntry)
gen se = lrsd/sqrt(lrn)
gen sig = (lr -  1.96*se) > .5
l if sig

// Construct Resultsset
// --------------------

use ess04, clear

gen lrsix:lrsix = 1 if inlist(leftright,0,1,2)
replace lrsix = 2 if inlist(leftright,3,4)
replace lrsix = 3 if inlist(leftright,5)
replace lrsix = 4 if inlist(leftright,6,7)
replace lrsix = 5 if inlist(leftright,8,9,10)
replace lrsix = 6 if mi(leftright)

label define lrsix 1 "Left" 2 "Centre-Left" 3 "Centre" 	///  
4 "Centre-Right" 5 "Right" 6 "Unengaged"

tab lrsix, gen(lrsix)

// Left-Right placement of voters and non-voters
preserve
collapse (mean) lrsix1-lrsix6 [aw=nweight] if !mi(voter), by(voter)
reshape long lrsix, i(voter) j(categ)
sort categ
tempfile byvoters
save `byvoters'

restore , preserve
collapse (mean) lrsix1-lrsix6 [aw=nweight] if !mi(voter)
renpfix lr tlr
gen index = 1
reshape long tlrsix, i(index) j(categ)
sort categ
merge categ using `byvoters'
assert _merge==3
drop _merge
drop index

reshape wide lrsix, i(categ) j(voter)

replace lrsix0 = lrsix0*100
replace lrsix1 = lrsix1*100
replace tlrsix = tlrsix*100

gen diff = lrsix0-lrsix1
label define categ 						/// 
  1 "Left: points 0,1,2" 2 "Left-centre: 3,4" 	///  
  3 "Centre: 5" 	///  
  4 "Centre-right: 6,7" 5 "Right: 8,9,10"  /// 
  6 "Dont' know"
lab val categ categ

format %2.0f tlrsix lrsix1 lrsix0 diff 

listtex tlrsix categ lrsix1 lrsix0 diff  /// 
using anlr_by_voteing_sumtab.tex  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{rlrrr}\hline" ///
  "\multicolumn{1}{c}{Total} & & \multicolumn{1}{c}{Voters} & \multicolumn{1}{c}{Non-voters} & \multicolumn{1}{c}{Difference} \\ " ///
  "\% & Placement & \% & \% &  \\ \hline ") ///
  foot("\hline" "\end{tabular}") end("\\")
restore , preserve

collapse (mean) lrsix1-lrsix6 [aw=nweight] if !mi(voter), by(cntry voter)

sort cntry
merge cntry using `mypost', nokeep
assert _merge==3
drop _merge

forv i = 1/6 {
	replace lrsix`i' = lrsix`i'*100			
}

// Table Resultsset
// ----------------

tostring lrsix*, format(%3.1f) replace force
// forv i = 1/6 {
//	replace lrsix`i' = lrsix`i'+ "*" if sig`i' == 1 & !voter
// }

egen cntryname = iso3166(cntry), o(codes)

gen vstring = "Voters" if voter
replace vstring = "Non-Voters" if !voter

gsort cntryname -vstring 

by cntryname: replace cntryname = "" if _n==2

listtex cntryname vstring lrsix* ///
  using anlr_by_voteing_table.tex  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{ll......}\hline" ///
  "& & \multicolumn{6}{c}{Percentage or respondents towards ...} \\ " ///
  "& & \multicolumn{1}{c}{Left} & \multicolumn{1}{c}{Cent.-L.} & \multicolumn{1}{c}{Center} & \multicolumn{1}{c}{Cent.-R.} & \multicolumn{1}{c}{Right} & \multicolumn{1}{c}{Don't know} \\ \hline") ///
  foot("\hline") end("\\")
restore  , preserve


// European Average
// ---------------

collapse (mean) lrsix1-lrsix6 [aw=nweight] if !mi(voter), by(voter)

forv i = 1/6 {
	replace lrsix`i' = lrsix`i'*100			
}

gen cntry = "European average"
sort cntry
merge cntry using `mypost', nokeep
assert _merge==3
drop _merge

tostring lrsix*, format(%3.1f) gen(lrsixstr1-lrsixstr6) force
// forv i = 1/6 {
//	replace lrsix`i' = lrsix`i'+ "*" if sig`i' == 1 & !voter
// }

gen vstring = "Voter" if voter
replace vstring = "Non-Voter" if !voter

gsort -vstring 
gen cntryname = "European average" in 1

listtex cntryname vstring lrsixstr*, appendto(anlr_by_voteing_table.tex)  ///
  rstyle(tabular) foot("\hline \end{tabular}") end("\\")


keep lrsix? cntry vstring voter
reshape long lrsix, i(voter) j(k)

replace k = k - .2 if voter
replace k = k + .2 if !voter

format lrsix %2.0f

local baropt `"barwidth(.4) lcolor(black) "' 
graph tw 								   ///
  || scatter lrsix k, mlab(lrsix) mlabpos(12) ms(i) 	/// 
  || bar lrsix k if voter, `baropt' fcolor(black)  /// 
  || bar lrsix k if !voter, `baropt' fcolor(gs14) 	///
  , legend(order(2 "Voter" 3 "Non-Voter")) 	///
  xtitle("") xlab(1 `""Left" (0-2)"' 2 `""Center-Left" "(3, 4)""'  /// 
  3 `""Center" "(5)""' 4 `""Center-Right" "(6, 7)""'  /// 
  5 `""Right" "(8-10)""' 6 `""Other" "(Don't know)""' )  ///
  ytitle(Percent) ylab(, grid) 			///
  note("`=c(current_date)'@`=c(current_time)'", span)

graph export anlr_by_voteing_EUgraph.eps, replace


// Graph resultsset
// ----------------

restore, preserve

collapse (mean) lrsix1-lrsix6 [aw=nweight] if !mi(voter), by(cntry voter)
sort cntry
merge cntry using `mypost', nokeep
assert _merge==3
drop _merge

forv i = 1/6 {
	replace lrsix`i' = lrsix`i'*100			
}


egen index = group(cntry voter)
reshape long lrsix blrsix selrsix sig, i(index) j(categ)

by categ cntry (voter), sort: gen lrsix0 = lrsix[1]
by categ cntry (voter), sort: gen lrsix1 = lrsix[2]

replace blrsix = abs(blrsix)
replace blrsix = 0 if sig==0
egen sorter = mean(blrsix), by(cntry)

encode cntry, gen(ctrnum)
egen axis = axis(sorter), label(ctrnum) reverse

label value categ lrsix

graph twoway 							///
  || pcarrow axis lrsix1 axis lrsix0 if sig==1,  /// 
  lcolor(black) mcolor(black)      ///
  || scatter axis lrsix if voter==1, mcolor(black) ms(O) ///
  || , by(categ, rows(1) note(""))  ytitle("") 	///
  legend(rows(1) order(2 "Voters" 1 "Non-voters (if sig.)")) 	///
  ylabel(1(1)23, valuelabel angle(0)) xlab(0(15)45) xtitle(Percent)  ///

graph export anlr_by_voteing_graph.eps, replace

  
exit



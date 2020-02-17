// Apply Richards Proposal from July 12 2007
version 10
clear
set matsize 500
set more off
set scheme s1mono
capture log close
log using anexpol1, replace

// Definition of Leverage
// ----------------------

// invalid ballots (http://www.idea.int/vt/)
input str30 ctrname str7 datestring turnout invalid
"Austria"         24Nov02  84 1.5
"Belgium"         18May03  92 4.3
"Czech Republic"  14Jun02  58 0.4
"Denmark"         20Nov01  87 1.0
"Estonia"          2Mar03  58 1.2
"Finland"         16Mar03  67 0.9
"France"          16Jun02  64 4.4
"Germany"         22Sep02  80 1.2
"Greece"           7Mar04  89 2.2
"Hungary"          7Apr02  70 0.6
"Iceland"         10May03  88 1.2
"Ireland"         17May02  63 1.1
"Luxembourg"      13Jun04  92 6.5  // invalid % from 1999
"Netherlands"     22Jan03  80 0.1
"Norway"          10Sep01  76 0.4  // invalid % from 2005
"Poland"          23Sep01  46 4.0
"Portugal"        17Mar02  62 1.9
"Slovakia"        20Sep02  70 1.3
"Slovenia"         3Oct04  61 2.3
"Spain"           14Mar04  76 2.6
"Sweden"          15Sep02  80 1.5
"Switzerland"     19Oct03  45 1.1
"United Kingdom"   7Jun01  59 0.3 // invalid & from 2005
end

// Initial Preparations
egen cntry = iso3166(ctrname), o(names)

gen compulsory = inlist(cntry,"BE","IT","LU","BE") // | inlist(cntry,"AT","NL")
label variable compulsory "Compulsory elections"

replace turnout = turnout/100
replace invalid = invalid/100


// Leverage Definitions
gen L1 = 1 - turnout

sum turnout if compulsory, meanonly
local compvt = r(mean)
gen L2 = (1-turnout)*`compvt'

gen maxturnout = turnout - invalid
sum maxturnout, meanonly
gen L3 = r(max)-turnout*`compvt'

// Graphical Desplay of Leverages
encode ctrname, gen(ctrnum)
egen axis = axis(L1 ctrnum), label(ctrnum) reverse

levelsof axis, local(K)
graph twoway ///
   || scatter axis L1, ms(O) mlcolor(black) mfcolor(black)  ///
   || scatter axis L2, ms(O) mlcolor(black) mfcolor(gs8)    ///
   || scatter axis L3, ms(O) mlcolor(black) mfcolor(white)  ///
   || , ylabel(`K', valuelabel angle(0) grid gstyle(dot))   ///
        ytitle("")                                          ///
        xtitle(Leverage) xmtick(.1(.1).5)                   ///
        legend(rows(1) order(1 "L1" 2 "L2" 3 "L3"))         ///
        ysize(6)
graph export anexpol1_leverage.eps, replace

sort cntry
tempfile leverage
save `leverage'

// Distance
// --------

use ess04 if voter<. & lrgroup<. & pi<., clear

// Typology
gen n = 1 
collapse (count) n, by(cntry pi lrgroup voter)
gen lrvote = 1     if lrgroup==1 
replace lrvote = 2 if lrgroup==3 
replace lrvote = 3 if lrgroup==2 
replace lrvote = 4 if lrgroup==4

// Set half of those without pi to windfall
expand 2 if pi==0 & inrange(lrgroup,1,3)
by cntry lrgroup voter pi, sort: replace lrgroup = 4 if _n==2
replace n = round(0.5 * n,1) if pi==0

// Distribution of partisanship vor voters and nonvoters
expand n
tab lrvote, gen(lrvote)
collapse (mean) lrvote1 lrvote2 lrvote3 lrvote4, by(cntry voter)

// Calculate distances
by cntry (voter), sort: gen diff1 = -1*(lrvote1 - lrvote1[_n-1])
by cntry (voter), sort: gen diff2 = -1*(lrvote2 - lrvote2[_n-1])
by cntry (voter), sort: gen diff3 = -1*(lrvote3 - lrvote3[_n-1])
by cntry (voter), sort: gen diff4 = -1*(lrvote4 - lrvote4[_n-1])
keep if voter

// Graph
egen ctrname = iso3166(cntry), o(codes)
encode ctrname, gen(ctrnum)
by cntry, sort: gen sorter = abs(diff1)+abs(diff2)+abs(diff3)+abs(diff4) 
egen axis = axis(sorter), label(ctrnum) reverse

levelsof axis, local(K)
graph twoway ///
   || scatter axis diff1, ms(O) mlcolor(black) mfcolor(white)  ///
   || scatter axis diff2, ms(O) mlcolor(black) mfcolor(gs8)    ///
   || scatter axis diff3, ms(O) mlcolor(black) mfcolor(black)  ///
   || , ylabel(`K', valuelabel angle(0) grid gstyle(dot))     ///
        ytitle("")                                            ///
        xtitle(Distance (Non-Voter minus Voter)) xmtick(-.25(.1).15) ///
        xline(0, lpattern(dash)) ///
        legend(rows(1) order(1 "Left" 2 "Center" 3 "Right"))  ///
        ysize(6)
graph export anexpol1_distance.eps, replace


// Leverage X Distance
merge cntry using `leverage', sort
assert _merge == 3
drop _merge

reshape long lrvote diff, i(cntry) j(categ)
label value categ categ
label define categ 1 "Commited left" 2 "Commited center"  ///
                   3 "Commited right" 4 "Windfall"

// Apply the Formula
gen lrvotet = lrvote*(1-L1) + (lrvote+diff)*L1

// Sorter
drop axis sorter
by cntry, sort: gen sorter = sum(abs(lrvotet-lrvote))
by cntry: replace sorter = sorter[_N]
egen axis = axis(sorter ctrnum), label(ctrnum) reverse

levelsof axis, local(ylab)
graph twoway ///
   || scatter axis lrvote, ms(O) mcolor(black)  ///
   || pcarrow axis lrvote axis lrvotet, lcolor(black) mcolor(black) ///
   || , by(categ, col(4) xrescale ///
      note("Note: X-axes scaled independently. Leverage was L1", bexpand)) ///
      ylab(`ylab', valuelabel angle(0)) ///
      ytitle("") xtitle("Proportion of votes")  ///
      legend(order(1 "Voter" 2 "Change by Non-voter"))
graph export anexpol1_changdet.eps, replace


// Insecurity: Windfall-Simulation
// -------------------------------

use ess04 if voter < . & lrgroup < . & pi < ., clear

// Typology
gen n = 1 
collapse (count) n, by(cntry pi lrgroup voter)
gen lrvote = 1     if lrgroup==1 
replace lrvote = 2 if lrgroup==3 
replace lrvote = 3 if lrgroup==2 
replace lrvote = 4 if lrgroup==4

// Set half of those without pi to windfall
expand 2 if pi==0 & inrange(lrgroup,1,3)
by cntry lrgroup voter pi, sort: replace lrgroup = 4 if _n==2
replace n = round(0.5 * n,1) if pi==0
expand n

sort cntry
merge cntry using `leverage', keep(L1)
assert _merge==3
drop _merge

encode cntry, gen(ctrnum)
drop cntry

// Random Assignment
preserve
quietly {
  forv i = 1/100 {
    noi di "round `i' of 100"
    replace lrvote = ceil(uniform()*3) if lrvote==4
    assert inlist(lrvote,1,2,3)
    tab lrvote, gen(lrvote)
    collapse (mean) lrvote1 lrvote2 lrvote3 L1, by(ctrnum voter)

    // Apply the Formula
    forv j = 1/3 {
      by ctrnum (voter), sort: ///
            gen lrvotet`j' = lrvote`j'*(1-L1) + (lrvote`j'[_n-1])*L1
    }
    keep if voter
    if `i' == 1 {
       mata: X = ///
          st_data(.,("ctrnum","lrvote1","lrvote2","lrvote3","lrvotet1","lrvotet2","lrvotet3"))
       mata: Y = X
    }
    else {
       mata: Y = Y\st_data(.,("ctrnum","lrvote1","lrvote2","lrvote3","lrvotet1","lrvotet2","lrvotet3"))
    }
    restore, preserve
  }
}

drop _all
set obs 2300
input ctrnum lrvote1 lrvote2 lrvote3 lrvotet1 lrvotet2 lrvotet3
end

mata: (void) st_store(.,("ctrnum","lrvote1","lrvote2","lrvote3","lrvotet1","lrvotet2","lrvotet3"),Y)
label val ctrnum ctrnum

collapse (p1)  lb1=lrvote1 lb2=lrvote2 lb3=lrvote3 lbt1=lrvotet1 lbt2=lrvotet2 lbt3=lrvotet3 ///
         (p50) me1=lrvote1 me2=lrvote2 me3=lrvote3 met1=lrvotet1 met2=lrvotet2 met3=lrvotet3 ///
         (p99) ub1=lrvote1 ub2=lrvote2 ub3=lrvote3 ubt1=lrvotet1 ubt2=lrvotet2 ubt3=lrvotet3 ///
         , by(ctrnum)

reshape long lb lbt me met ub ubt, i(ctrnum) j(categ)
label value categ categ
label define categ 1 "Commited left" 2 "Commited center"  ///
                   3 "Commited right" , modify

// Sorter
by ctrnum, sort: gen sorter = sum(abs(met-me))
by ctrnum: replace sorter = sorter[_N]
egen ctrname = iso3166(ctrnum), o(codes)
encode ctrname, gen(ctrnuml)
egen axis = axis(sorter ctrnum), label(ctrnuml) reverse

levelsof axis, local(ylab)
graph twoway ///
   || rcap lb ub axis, horizontal lcolor(black) ///
   || rcap lbt ubt axis, horizontal lcolor(black)  ///
   || scatter axis me, ms(o) mcolor(black)  ///
   || scatter axis met, ms(o) mlcolor(black) mfcolor(white) ///
   || , by(categ, col(4) note("")) ///
      ylab(`ylab', valuelabel angle(0)) ///
      ytitle("") xtitle("Proportion of votes") ///
      legend(order(3 "Voter" 4 "Voter and Non-voter" 1 "Range") rows(1))

graph export anexpol1_changeindet.eps, replace
   
exit

// Describe Election Metadata extensivly

version 10
set scheme s1mono

use elections, clear
by election, sort: keep if _n==1


// Total electorate
// ----------------

gen lognelect = log10(nelectorate)
egen axis = axis(lognelect), label(election) reverse
levelsof axis, local(ylab)
gr twoway 								///
  || scatter axis lognelect if branch == "Leg."  ///
  , ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axis lognelect if branch == "Exec."  ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || , ylabe(`ylab', valuelabel angle(0) grid  /// 
  gstyle(dot) labsize(*.8)) 	ytitle("") ///
  xtitle(Log base 10 of voting eligible population)  ///
  ysize(6) legend(order(1 "Legislative" 2 "Executive") rows(1))
graph export andescribe_nelectorate.eps, replace

sort axis
listtex ctrname eldate nelectorate using andescribe_nelectorate  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{llr} \hline" " & Date  & VEP \\ \hline")  /// 
  foot("\hline \end{tabular}") end("\\")
drop axis

// Turnout
// -------

gen turnout = nvoters/nelectorate*100
egen axis = axis(turnout), label(election) reverse
levelsof axis, local(ylab)
gr twoway 								///
  || scatter axis turnout if !compulsory  ///
  , ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axis turnout if compulsory  ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || , ylabe(`ylab', valuelabel angle(0) grid  /// 
  gstyle(dot) labsize(*.8)) 	ytitle("") ///
  xtitle(Turnout in %)  ///
  ysize(6) legend(order(1 "Not compulsory" 2 "Compulsory") rows(1))
graph export andescribe_turnout.eps, replace

sort axis
listtex ctrname eldate turnout using andescribe_turnout  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{llr} \hline" " & Date  & Turnout \\ \hline")  /// 
  foot("\hline \end{tabular}") end("\\")
drop axis


// Percentage of invalid Votes
// ---------------------------

gen pinvalid = ninvalid/nvoters*100
egen axis = axis(pinvalid), label(election) reverse
levelsof axis, local(ylab)
gr twoway 								///
  || scatter axis pinvalid if !compulsory  ///
  , ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axis pinvalid if compulsory  ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || , ylabe(`ylab', valuelabel angle(0) grid  /// 
  gstyle(dot) labsize(*.8)) 	ytitle("") ///
  xtitle(Percentage of invalid votes)  ///
  ysize(6) legend(order(1 "Not compulsory" 2 "Compulsory") rows(1))
graph export andescribe_pinvalid.eps, replace

sort axis
listtex ctrname eldate pinvalid using andescribe_pinvalid  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{llr} \hline" " & Date  & Invalid votes \\ \hline")  /// 
  foot("\hline \end{tabular}") end("\\")
drop axis

// Size of Leverage
// ---------------

gen lev1 = 100 - turnout

sum pinvalid if compulsory, meanonly
local pinvalid_compulsory = r(mean)
gen lev2 = (100-`pinvalid_compulsory')  - turnout

sum turnout if compulsory, meanonly
gen lev3 = (r(mean)  - `pinvalid_compulsory') - turnout

egen axis = axis(lev1), label(election) reverse
levelsof axis, local(ylab)

sort axis
levelsof axis, local(ylab)
gr twoway 								///
  || line axis lev1, lcolor(black) lpattern(solid) ///
  || line axis lev2, lcolor(black) lpattern(dash) ///
  || line axis lev3, lcolor(black) lpattern(dot) ///
  || scatter axis lev1 if !compulsory  /// ///
  , ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axis lev1 if compulsory  /// ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || scatter axis lev2 if !compulsory  /// ///
  , ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axis lev2 if compulsory  /// ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || scatter axis lev3 if !compulsory  /// ///
  , ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axis lev3 if compulsory  /// ///
  , ms(O) mlcolor(black) mfcolor(white) ///
  || , ylabe(`ylab', valuelabel angle(0) grid  /// 
  gstyle(dot) labsize(*.8)) 	ytitle("") ///
  xtitle(Percentage of invalid votes)  ///
  ysize(7) legend(order(1 "100-TO" 2 "100-Mean(IV|Comp.) - TO" 3 "Mean(V|Comp.)-TO") rows(3)) xline(0)
graph export andescribe_lev.eps, replace

listtex ctrname eldate lev1 lev2 lev3 using andescribe_lev  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{llrrr} \hline" " & Date  & Def. 1 & Def. 2 & Def. 3 \\ \hline")  /// 
  foot("\hline \end{tabular}") end("\\")


// Closeness
// ---------

use elections, clear
gen nvalid = nvoters-ninvalid

by election (nvotes),sort: gen diff = (nvotes[_N]/nvalid - nvotes[_N-1]/nvalid) * 100
by election, sort: keep if _n==1

gen pinvalid = ninvalid/nvoters*100
sum pinvalid if compulsory, meanonly
local pinvalid_compulsory = r(mean)
gen turnout = nvoters/nelectorate*100
sum turnout if compulsory, meanonly
gen lev3 = (r(mean)  - `pinvalid_compulsory') - turnout

egen axis = axis(diff), label(election) reverse
levelsof axis, local(ylab)

sort axis
levelsof axis, local(ylab)
gr twoway 								///
  || bar lev3 axis, lcolor(black) lpattern(dash) horizontal ///
  || scatter axis diff, mcolor(black) mfcolor(black) ms(O) ///
  || , ylabe(`ylab', valuelabel angle(0) grid  /// 
  gstyle(dot) labsize(*.8)) 	ytitle("") ///
  xtitle("")  ///
  ysize(7) legend(order(2 "Diff. between 2 leading parties" 1 "Leverage (Def. 3)") rows(2)) xline(0)
graph export andescribe_diff.eps, replace

listtex ctrname eldate diff lev3 using andescribe_diff  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{llrr} \hline" " & Date  &  Difference & Leverage (Def. 3) \\ \hline")  /// 
  foot("\hline \end{tabular}") end("\\")


// Disproportionability
// --------------------

use elections, clear
gen nvalid = nvoters-ninvalid

by election, sort: gen seats = sum(nseats)
by election: replace seats = seats[_N]

gen pvotes = nvotes/nvalid
gen pseats = nseats/seats

by election, sort: gen disprob = sum(abs(pvotes - pseats))
by election:  replace disprob = disprob[_N]

by election, sort: keep if _n==1

egen axis = axis(disprob election), label(election) reverse
sort axis
levelsof axis, local(ylab)
gr twoway 								///
  || scatter axis disprob, mcolor(black) mfcolor(black) ms(O) ///
  || , ylabe(`ylab', valuelabel angle(0) grid  /// 
  gstyle(dot) labsize(*.8)) ytitle("") ///
  xtitle(`"sum(|P(votes) - P(seats)|)"')  ///
  ysize(6)
graph export andescribe_disprob.eps, replace

listtex ctrname eldate disprob using andescribe_disprob  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{llrr} \hline" " & Date  &  Disprob \\ \hline")  /// 
  foot("\hline \end{tabular}") end("\\")


// Number of Parties
// -----------------


use elections, clear

by election, sort: gen sumvotes = sum(nvotes)
replace nvalid = sumvotes if mi(nvalid)


gen pvotes = (nvotes/nvalid)*100

by election, sort: gen nparty_ge1 = sum(pvote>=1) if !mi(pvote)
by election, sort: gen nparty_ge5 = sum(pvote>=5) if !mi(pvote)
by election, sort: gen nparty_withseats = sum(nseats>=1) if !mi(nseats)
by election, sort: keep if _n==_N

egen axis = axis(nparty_ge1 election), label(election) reverse
sort axis
levelsof axis, local(ylab)
gr twoway 								///
  || scatter axis nparty_ge5, mlcolor(black) mfcolor(white) ms(O) ///
  || scatter axis nparty_ge1, mlcolor(black) mfcolor(black) ms(O) ///
  || scatter axis nparty_withseats, mlcolor(black) mfcolor(gs8) ms(O) ///
  || , ylabe(`ylab', valuelabel angle(0) grid  /// 
  gstyle(dot) labsize(*.8)) ytitle("") ///
  xtitle(`"Numbers of parties"')  xlab(2(4)28, grid) xtick(2(2)28) ///
  ysize(6) legend(order(2 "Parties >= 1%" 1 "Parties >= 5%" 3 "Parties with seats") rows(2))
graph export andescribe_nparty.eps, replace

listtex ctrname eldate nparty* using andescribe_nparty  ///
  , replace rstyle(tabular) 	///
  head("\begin{tabular}{llrrr} \hline" " & Date  &  $> 1\%$ & $>5\%$ & with seats \\ \hline")  /// 
  foot("\hline \end{tabular}") end("\\")


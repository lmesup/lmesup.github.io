// US Turnout by gap, state and year
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

// Graph
// -----

gen gap = propdem-proprep
gen collmembers = evdem + evrep + cond(evoth!=.,evoth,0)

set scheme s1mono
graph twoway 							///
  || scatter turnout gap [aweight=collmembers], ms(O) mlcolor(gs8) mfcolor(white) 				///
  || lowess turnout gap, lcolor(black)	///
  || if state~="D.C." 	///
  , by(election, legend(off) col(2) ///
  note("Symbols size proportional to size of electoral college." "D.C. excluded", span)) 	///
  xtitle("Prop. Democrats - Prop. Republicans")  xline(0) ///
  ytitle("`:var lab turnout'") ysize(8)

// Gap bridging fraction
// ---------------------

// Assuming 2 parties
replace propdem = 100*propdem/(propdem + proprep)
replace proprep = 100*proprep/(propdem + proprep)
replace vep = vep - votesoth

// Calculate tipping point
gen nonvoters = (vep - totalvote)*.86  // .86 = Invalid + legal excuses
gen absdiff = votesdem - votesrep
gen necpdiff = absdiff/nonvoters
gen minpropdem = -100 * (necpdiff - 1)/2

// Check!!!!!
assert abs(round((votesdem + minpropdem/100 * nonvoters)  /// 
  - (votesrep + (100-minpropdem)/100 * nonvoters),1)) <= 1

// Electoral college size
by election, sort: gen collsize = sum(collmembers)
by election: replace collsize = collsize[_N]

// Likelihood of change
gen likelihood = minpropdem - propdem
replace likelihood = 100*minpropdem if minpropdem > 100

// Treshold of State
by election (likelihood proprep), sort: gen order = _N-_n
by election (order), sort: gen treshold = sum(collmembers) > collsize/2

encode election, gen(elenum)

// Graph the beast
// ---------------

forv i = 1/7 {
	egen axis`i' = axis(treshold order) if elenum == `i', label(state) gap 
	levelsof axis`i', local(ylab)
	gr tw 									///
	  || pcarrow axis`i' propdem axis`i' minpropdem  /// 
	  if  propdem < proprep & minpropdem < 100  ///
	  , lcolor(black) mcolor(black) 		///
	  || scatter axis`i' propdem 		/// 
	  if likelihood <= 0, ms(O) mlcolor(black) mfcolor(white) mlab(collmembers) ///
	  || scatter axis`i' propdem 		/// 
	  if likelihood > 0 & likelihood < 100, ms(O) mlcolor(black) mfcolor(gs8) ///
	  || scatter axis`i' minpropdem				/// 
	  if likelihood > 0 & likelihood < 100, ms(i) mlab(collmembers) ///
	  || scatter axis`i' propdem 		/// 
	  if likelihood >= 100, ms(O) mlcolor(black) mfcolor(black) mlab(collmembers) ///
	  || if elenum == `i' , xline(50) 		///
	  ylab(`ylab', valuelabel angle(0) grid labsize(*.9) ) ytitle("") ysize(8)  ///
	  legend(off) 							///
	  note("Numbers indicate members of electoral college" 	/// 
	  "`=c(current_date)'@`=c(current_time)'", span)  ///
	  title("`:label (elenum) `i''", box bexpand)  
	graph export anUSbystate_`i'.eps, replace
	graph print
}

  
exit




  

	





  




// Number of Events by Eventyear
cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m
set scheme s1mono

foreach cntry in DE US {
	
	// Create Event centered data set
	// ------------------------------

	foreach event in eunemp eill efambreak eretire {
		use `cntry' if `event'data, clear

		// Tag obs with events 
		by id (wave), sort: gen byte eventcount = sum(`event')
		by id (wave), sort: gen byte hasevent = eventcount[_N] >0

		// Keep a Copy for Control group
		tempfile control
		save `control', replace
		
		// Tag relevant time spans
		gen byte noevent = !`event'
		sum eventcount, meanonly

		forv  i=1/`r(max)' {
			by id (noevent eventcount), sort: gen byte tag`i'  ///
			  = inrange(wave,wave[`i']-3,wave[`i']+3)  ///
			  if eventcount[`i']==`i' 
		}

		// Clean series and transform to a long series dataset
		preserve
		local i 1
		foreach tag of varlist tag* {

			// Keep tagged
			keep if `tag'==1

			// Event year
			by id (noevent eventcount), sort: gen yeartag = 1  /// 
			  if eventcount == `i' & !noevent
			by id (yeartag), sort: gen eyear = wave[1]

			keep id wave eyear
			gen tag`event' = `i++'

			// Balance series
			by id eyear (wave), sort: 	/// 
			  keep if wave[1]+4 <= wave[_N]
			
			tempfile `tag'
			save ``tag''
			restore, preserve
		}
		restore, not
		
		use `tag1', clear
		forv i = 2/`--i' {
			capture append using `tag`i''
		}

		merge n:1 id wave using `cntry', keep(3)
		gen byte treatment = 1


		// Sequence id
		// ------------
		egen newid = group(id treatment tag`event')
		xtset newid wave

		// At risk
		// -------

		// Not poor before the event
		gen before = wave<eyear
		by newid (wave), sort: gen atrisk = sum(before & !poor)/sum(before)
		by newid (wave): keep if atrisk[_N]==1
		drop atrisk before
		
		// Fambreak special: Remove Non-carer from Treatment and Control group
		if "`event'" == "efambreak" {
			by newid (wave): gen tag = sum(efambreak==1 & hhsize0to14 == 0)
			by newid (wave): drop if tag[_N]
			drop tag
		}

		// Number of observed events
		// -------------------------
		
		by newid (wave): gen t = wave - eyear
		keep if t==0

		collapse (count) n=`event', by(eyear)
		  
		gen risk = "`event'"
		gen cntry = "`cntry'"
		tempfile `event'`cntry'
		save ``event'`cntry'', replace
	}
}

use `eunempUS'
append using `eunempDE'
append using `efambreakUS'
append using `efambreakDE'
append using `eillUS'
append using `eillDE'
append using `eretireDE'
append using `eretireUS'


separate n, by(risk) veryshortlabel

local opt lcolor(black..) mlcolor(black..)
graph twoway  ///
  || connected n4 n2 n3 n1 eyear 				///
  , `opt' 								/// 
  ms(O T S D) mfcolor(gs16 gs11 gs6 gs1) 	/// 
  lpattern(solid longdash dash dot)  ///
  legend(order(1 "Arb.-platzverlust" 2 "Krankheit"  /// 
  3 "Verrentung" 4 "Familientrennung") rows(2)) ///
  by(cntry, rows(2) note("") ) ///
  ylabel(0(70)350, grid angle(0)) ytitle("Anzahl Ereignisse")   ///
  xlabel(1982(4)2006) xtick(1984(4)2008) xtitle("") 


graph export greventcount.eps, replace



exit


















// Graph Number of Events by time
// kohler@wzb.eu


set scheme s1mono

foreach cntry in DE US {

	use `cntry', clear
	
	replace eill = . if !eilldata
	replace eunemp = . if !eunempdata
	replace efambreak = . if !efambreakdata
	replace eretire = . if !eretiredata

	collapse (sum) eill eunemp efambreak eretire, by(wave)
	gen iso = "`cntry'"

	tempfile `cntry'
	save ``cntry''
	}

use `US'
append using `DE'
	
local opt lcolor(black)
graph twoway  ///
  || connected eunemp wave if eunemp != 0, `opt' ms(O)  ///
  mcolor(black) lpattern(solid)  ///
  || connected eill wave if eill != 0, `opt' ms (O)  ///
  mlcolor(black) mfcolor(white) lpattern(longdash)  ///
  || connected eretire wave if eretire != 0, `opt' ms(S)  ///
  mlcolor(black) mfcolor(white) lpattern(dot) ///
  || connected efambreak wave if efambreak != 0, `opt' ms(S)  ///
  mcolor(black) lpattern(dash) ///
  || , legend(order(1 "Arbeitsplatzverlust" 2 "Krankheit" ///
  3 "Verrentung" 4 "Familientrennung") ) ///
  by(iso, rows(2) note("") ) ///
  ylabel(0(150)450, grid) ytitle("Anzahl Ereignisse")   ///
  xlabel(1980(5)2010) xtitle("")


graph export greventcount.eps, replace

exit


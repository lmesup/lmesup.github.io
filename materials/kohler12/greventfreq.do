
// Ourdata
// --------

// PSID and GSOEP als Cross-Sections
use joined3DE, replace
collapse (mean) poor (sd) sd = poor (count) n = poor [aweight=weight], by(wave)
gen source = "Unsere Daten"
gen cntry="DE"
tempfile ourdataDE
save `ourdataDE'

use joined3US, replace
collapse (mean) poor (sd) sd = poor (count) n = poor [aweight=weight], by(wave)
gen source = "Unsere Daten"
gen cntry="US"
tempfile ourdataUS
save `ourdataUS'


// Armut im Jahr vor dem Ereignis
// -----------------------------
// (vgl. anpoor2.do)

foreach cntry in DE US {

	if "`cntry'" == "DE" local data soep
	else if "`cntry'" == "US" local data psid
	
	use "`data'_analysis_voluntary.dta", clear
	ren welle wave
	ren poor_60pct poor
	ren yr_of_exit eyear
	ren persnr newid
	drop if poor == .
	
	keep if wave == eyear-1
	
	collapse (mean) poor (sd) sd=poor (count) n=poor [aw=weight], by(wave)

	gen source = "eage"
	gen cntry = "`cntry'"
	tempfile eage`cntry'
	save `eage`cntry'', replace
}


// HEALTH, UNEMPLOYMENT, FAMILY
// ===========================

// Prepare Data 
foreach cntry in DE US {
	
	use joined3`cntry', clear

	// Create Event centered data set
	// ------------------------------

	xtset id wave
	sort id wave 

	by id (wave): gen byte eunemp = 	/// 
	  inrange(mthunemp,3,12) & inrange(mthwork[_n-1],7,12)
	by id (wave): gen byte eill = illlong==1 & illlong[_n-1]==0
	by id (wave): gen byte etrennung = trennung

	tempfile master
	save `master'
	foreach event in eunemp eill {

		// Tag obs with events 
		by id (wave), sort: gen byte eventcount = sum(`event')
		by id (wave), sort: gen byte hasevent = eventcount[_N] >0
		
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
				
			tempfile `tag'
			save ``tag''
			restore, preserve
		}
		restore, not
		
		use `tag1', clear
		forv i = 2/`--i' {
			capture append using `tag`i''
		}

		merge n:1 id wave using `master', keep(3)

		// Sequence id
		// ------------
		
		egen newid = group(id tag`event')
		xtset newid wave

		// Select workforce
		// ----------------
		
		egen whoursbar = mean(whours), by(newid)
		keep if inrange(age,25,55) & whoursbar >= 1
		
		// Poorness before event
		// ---------------------

		if "`cntry'"== "DE" {
			gen obsbefore = 1 if wave == eyear-1
		}
		else if "`cntry'" == "US" {
			gen obsbefore = 1 if wave == eyear-1 & eyear<=1996
			replace obsbefore = 1 if wave == eyear-2 & eyear>=1998
		}
		keep if obsbefore ==1
		
		collapse (mean) poor (sd) sd=poor (count) n=poor [aw=weight] ///
		  , by(wave)
		
		gen source = "`event'"
		gen cntry = "`cntry'"
		tempfile `event'`cntry'
		save ``event'`cntry'', replace
		use `master', clear
	}
}


// Merge files together
// ---------------------

use `official', clear
append using `ourdataDE'
append using `ourdataUS'
append using `eunempDE'
append using `eunempUS'
append using `eillDE'
append using `eillUS'
append using `eageDE'
append using `eageUS'


// Produce Figures
// ---------------

// Harmonize Scale
replace poor = poor*100 if source != "Offiziell"

// Official Line
graph twoway 							/// 
  || line poor wave if source=="Offiziell" 	///
  , sort  ///
  || line poor wave if source=="Unsere Daten"  ///
  , sort   ///
  || , by(cntry, note("")) 							///
  ytitle("Percentage poor") 		///
  legend(order(1 "Official line" 2 "Our definition") rows(1))  ///
  xtitle("") ylabel(, grid)

graph export anmeasures4.eps, replace






exit





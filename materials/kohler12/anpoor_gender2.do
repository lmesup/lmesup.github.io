// Liferisk-Projekt, Create data with poorness
// kohler@wzb.eu

cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m
set scheme wzb

// RETIREMENT
// ==========

foreach cntry in DE US {

	if "`cntry'" == "DE" local data soep
	else if "`cntry'" == "US" local data psid
	
	use "`data'_analysis_voluntary.dta", clear
	ren welle wave
	ren poor_60pct poor
	ren yr_of_exit eyear
	ren persnr newid
	drop if poor == .
	gen men = sex==1 if !mi(sex)
	
	// +/- 3 year
	// ----------
	
	keep if inrange(wave,eyear-3,eyear+3)
	
	// Create aggregate statistics
	gen t = wave - eyear

	// At risk
	// -------
	// (not poor before the event)
	
	gen before = wave<eyear
	by newid (wave), sort: gen atrisk = sum(before & !poor)/sum(before)
	by newid (wave): keep if atrisk[_N]==1

	collapse (mean) mean=poor (sd) sd=poor (count) n=poor [aw=weight], by(t men)

	gen risk = "Alter"
	gen cntry = "`cntry'"
	tempfile age`cntry'
	save `age`cntry'', replace
}



// HEALTH, UNEMPLOYMENT, FAMILY
// ===========================

// Prepare Data 
foreach cntry in DE US {
	
	use joined2`cntry', clear

	// Create Event centered data set
	// ------------------------------

	xtset id wave
	sort id wave 

	by id (wave): gen byte eunemp = 	/// 
	  inrange(mthunemp,3,12) & inrange(mthwork[_n-1],7,12)
	by id (wave): gen byte eill = illlong==1 & illlong[_n-1]==0
	by id (wave): gen byte etrennung = trennung > trennung[_n-1]  /// 
	  if !mi(trennung)

	tempfile master
	save `master'
	foreach event in eunemp eill etrennung {

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
		
		// At risk
		// -------
		// (not poor before the event)

		gen before = wave<eyear
		by newid (wave), sort: gen atrisk = sum(before & !poor)/sum(before)
		by newid (wave): keep if atrisk[_N]==1

		// Poorness before event
		// ---------------------
		
		by newid (wave): gen t = wave - eyear

		collapse (mean) mean=poor (sd) sd=poor (count) n=poor [aw=weight] ///
		  , by(t men)
		
		gen risk = "`event'"
		gen cntry = "`cntry'"
		tempfile `event'`cntry'
		save ``event'`cntry'', replace
		use `master', clear
	}
}

use `ageDE'
append using `ageUS'
append using `eillUS'
append using `eillDE'
append using `eunempUS'
append using `eunempDE'
append using `etrennungUS'
append using `etrennungDE'

gen ub = mean + 1.96*sd/sqrt(n)
gen lb = mean - 1.96*sd/sqrt(n)

replace mean = mean*100
replace ub = ub*100
replace lb = lb*100

replace risk = "Krankheit" if risk=="eill"
replace risk = "Trennung" if risk == "etrennung"
replace risk = "Arbeitslosigkeit" if risk == "eunemp"
label define risk 1 "Arbeitslosigkeit" 2 "Krankheit" 3 "Trennung" ///
  4 "Alter"
encode risk, gen(risknum) label(risk)

replace cntry="Deutschland" if cntry=="DE"
replace cntry="U.S.A." if cntry=="US"

graph twoway 							///
  || line mean t if men, sort  ///
  || line mean t if !men, sort 	///
  || if risk == "Arbeitslosigkeit" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(-0.5, lwidth(10) lcolor(gs12)) ylabel(0(8)32) 	///
  by(cntry, note("") rows(1)) ///
  legend(rows(1) order(1 "Männer" 2 "Frauen" ))

graph export anpoor_gender2_unemp.eps, replace

graph twoway 							///
  || line mean t if men, sort  ///
  || line mean t if !men, sort 	///
  || if risk == "Krankheit" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(-0.5, lwidth(10) lcolor(gs12)) ylabel(0(8)32) 	///
  by(cntry, note("") rows(1))  ///
  legend(rows(1) order(1 "Männer" 2 "Frauen" ))

graph export anpoor_gender2_ill.eps, replace

graph twoway 							///
  || line mean t if men, sort  ///
  || line mean t if !men, sort 	///
  || if risk == "Trennung" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(-0.5, lwidth(10) lcolor(gs12)) ylabel(0(8)32) 	///
  by(cntry, note("") rows(1))  ///
  legend(rows(1) order(1 "Männer" 2 "Frauen" ))

graph export anpoor_gender2_trennung.eps, replace


graph twoway 							///
  || line mean t if men, sort  ///
  || line mean t if !men, sort 	///
  || if risk == "Alter" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(-0.5, lwidth(10) lcolor(gs12)) ylabel(0(8)32) 	///
  by(cntry, note("") rows(1))  ///
  legend(rows(1) order(1 "Männer" 2 "Frauen" ))

graph export anpoor_gender2_alter.eps, replace

exit












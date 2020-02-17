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
	gen time= recode(yr_of_exit,1989,1999,2008)
	ren welle wave
	ren poor_60pct poor
	ren yr_of_exit eyear
	ren persnr newid
	drop if poor == .

	// Fake "in-between" years
	if "`cntry'" == "US" expand 2 if wave > 1997
	bysort newid wave: replace wave = wave - (_N-_n)
	
	// Event
	// -------
	
	gen event = wave >= eyear
	keep if inrange(wave,eyear-3,eyear+3)
	
	// Hasevent
	// --------
	
	bysort newid (wave): gen hasevent = event[_N]==1

	// Create aggregate statistics
	by newid (wave): gen t = _n-4

	// At risk
	// -------
	
	by newid (wave), sort: gen atrisk = 	/// 
	  sum(wave == eyear & !poor[_n-1] & !poor[_n-2] & !poor[_n-3]) ///
	
	by newid (wave): replace atrisk = atrisk[_N]
	keep if atrisk

	collapse (mean) mean=poor (sd) sd=poor (count) n=poor [aw=weight], by(t time)

	gen risk = "Alter"
	gen cntry = "`cntry'"
	tempfile age`cntry'
	save `age`cntry'', replace
}



// HEALTH, UNEMPLOYMENT, FAMILY
// ===========================

// Prepare Data 
foreach cntry in  DE US {
	
	use joined`cntry', clear

	// Create Event centered data set
	// ------------------------------

	xtset id wave
	sort id wave 

	gen byte eunemp =  ///
	  inrange(mthunemp,3,12) & inrange(L1.mthwork,7,12)
	gen byte eill = (illlong==1 & L1.illlong==0)
	gen byte etrennung = trennung > L1.trennung if !mi(trennung)

	tempfile master
	save `master' 
	foreach event in eunemp eill etrennung  {


		// Tag obs with events 
		by id (wave), sort: gen byte eventcount = sum(`event')
		by id (wave), sort: gen byte hasevent = eventcount[_N] >0
		
		// Tag control group
		gen tag0 = !hasevent
		
		// Tag relevant time spans
		gen byte noevent = !`event'
		sum eventcount, meanonly
		forv  i=1/`r(max)' {
			by id (noevent eventcount), sort: gen byte tag`i'  ///
			  = inrange(wave,wave[`i']-3,wave[`i']+3)  ///
			  if eventcount[`i']==`i'
		}

		// Clean series and transform to a long series dataset
		egen mis = rmiss(hhpostgoveq)
		
		preserve
		local i 0
		foreach tag of varlist tag* {

			// Keep tagged
			keep if `tag'==1
			
			// Remove series with missings
			bysort id (mis): drop if  mis[_N] 

			// Remove short series
			bysort id: drop if _N<7
			if _N > 0 {
				
				// Create eyear
				bysort id (wave): gen eyear = wave[4] if `i'>0
				
				drop mis `tag'

				keep id wave eyear
				
				gen tag`event' = `i++'
				tempfile `tag'
				save ``tag''
				restore, preserve
			}
		}
		restore, not
		
		use `tag0', clear
		forv i = 1/`--i' {
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
		
		// Event
		// ------

		gen event = wave >= eyear 
		
		// Hasevent
		// --------
		
		by newid (wave): gen hasevent = event[_N]==1
		
		// At risk
		// -------
		
		by newid (wave), sort: gen atrisk = 	/// 
		  sum(wave == eyear & !poor[_n-1] & !poor[_n-2] & !poor[_n-3])
		by newid (wave): replace atrisk = atrisk[_N]
		
		// Poorness before event
		// ---------------------
		
		gen beforeevent = poor if wave == eyear-1
		replace beforeevent = poor if !hasevent
		
		keep if atrisk
		*keep if hasevent
		by newid (wave): gen t = _n-4
		
		gen time =recode(eyear,1989,1999,2008)

		collapse (mean) mean=poor (sd) sd=poor (count) n=poor [aw=weight] ///
		  , by(t time)
		
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
  || line mean t if time==1989, sort  ///
  || line mean t if time==1999, sort 	///
  || line mean t if time==2008, sort 	///
  || if risk == "Arbeitslosigkeit" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(0, lwidth(10) lcolor(gs12)) ylabel(0(5)25) 	///
  by(cntry, note("") rows(1)) ///
  legend(rows(1) order(1 "Achtziger" 2 "Neunziger" 3 "Nuller"))

graph export anpoor_time_unemp.eps, replace

graph twoway 							///
  || line mean t if time==1989, sort  ///
  || line mean t if time==1999, sort 	///
  || line mean t if time==2008, sort 	///
  || if risk == "Krankheit" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(0, lwidth(10) lcolor(gs12)) ylabel(0(5)25) 	///
  by(cntry, note("") rows(1))  ///
  legend(rows(1) order(1 "Achtziger" 2 "Neunziger" 3 "Nuller"))

graph export anpoor_time_ill.eps, replace

graph twoway 							///
  || line mean t if time==1989, sort  ///
  || line mean t if time==1999, sort 	///
  || line mean t if time==2008, sort 	///
  || if risk == "Trennung" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(0, lwidth(10) lcolor(gs12)) ylabel(0(5)25) 	///
  by(cntry, note("") rows(1))  ///
  legend(rows(1) order(1 "Haupt/Realschule" 2 "Abitur" 3 "Hochschulabschl."))

graph export anpoor_time_trennung.eps, replace


graph twoway 							///
  || line mean t if time==1989, sort  ///
  || line mean t if time==1999, sort 	///
  || line mean t if time==2008, sort 	///
  || if risk == "Alter" ///
  , ytitle(Anteil Armer (in %)) 	ylabel(, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3 -2 -1 0 1 2 3)  ///
  xline(0, lwidth(10) lcolor(gs12)) ylabel(0(5)25) 	///
  by(cntry, note("") rows(1))  ///
  legend(rows(1) order(1 "Achtziger" 2 "Neunziger" 3 "Nuller"))

graph export anpoor_time_alter.eps, replace



exit












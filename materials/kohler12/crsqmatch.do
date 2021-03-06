// Analysis of poorness with Matching based on levenshtein
// kohler@wzb.eu

cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m
set scheme wzb

// HEALTH, UNEMPLOYMENT, FAMILY
// ===========================

// Prepare Data 
foreach cntry in DE /* US */ {
	
	use joined3`cntry', clear

	// Create Event centered data set
	// ------------------------------

	xtset id wave
	sort id wave 

	by id (wave): gen byte eunemp = 	/// 
	  inrange(mthunemp,3,12) & inrange(mthwork[_n-1],7,12)
	by id (wave): gen byte eill = illlong==1 & illlong[_n-1]==0
	by id (wave): gen byte etrennung = trennung 

	tempfile master control treatment
	save `master'
	foreach event in eunemp eill etrennung {

		// Tag obs with events 
		by id (wave), sort: gen byte eventcount = sum(`event')
		by id (wave), sort: gen byte hasevent = eventcount[_N] >0

		// Create dataset holding controls
		preserve
		keep if hasevent == 0
		gen byte treatment = 0
		save `control', replace
		restore
		
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
		gen byte treatment = 1
		save `treatment', replace

		// Add control observations
		// ------------------------

		levelsof eyear, local(K)
		use `control'
		foreach k of local K {
			by id, sort: gen byte ctag`k'   ///
			  = inrange(wave,`k'-3,`k'+3)
		}

		preserve
		local i 1
		foreach ctag of varlist ctag* {

			// Keep tagged
			keep if `ctag'==1

			// Event year
			gen eyear = `=substr("`ctag'",-4,.)'

			tempfile f`i'
			save `f`i++''
			restore, preserve
		}
		restore, not

		use `f1', clear
		forv i = 2/`--i' {
			capture append using `f`i''
		}
		egen tag`event' = group(id eyear)
		append using `treatment'

	
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

		}
	}


exit








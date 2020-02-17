// Diff-in-Diff by Country
// kohler@wzb.eu

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

		tempfile treatment
		save `treatment', replace

		// Add control observations
		// ------------------------

		levelsof eyear, local(K)
		use `control'

		// Tag event centered data around event year
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

			// Keep 7 obs without event in tagged period
			by id (wave), sort: gen noevent = sum(`event')
			by id (wave): replace noevent = noevent[_N]==0
			keep if noevent

			// At risk of event
			by id (wave), sort: gen atrisk =  /// 
			  sum(`event'atrisk==1 & (wave == (eyear-1)))
			by id (wave): keep if atrisk[_N]==1
			drop atrisk
			
			// Balance series
			by id (wave), sort: 	/// 
			  keep if wave[1]+4 <= wave[_N]

			gen byte treatment = 0

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

		// Poorness before event
		// ---------------------
		
		by newid (wave): gen t = wave - eyear

		collapse (mean) mean=poor (sd) sd=poor (count) n=poor [aw=weight] ///
		  , by(treatment t)
		
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

by cntry risk t (treatment), sort: 		/// 
  gen DiD = (mean - mean[_n-1]) 	
by cntry risk t (treatment), sort: 		/// 
  gen SE = sqrt(sd/n + sd[_n-1]/n[_n-1]) 	

keep if treatment

forv alpha = 1(1)95 {
	gen ub`alpha' = DiD + invnormal(1-(`alpha'/100)/2)*SE
	gen lb`alpha' = DiD - invnormal(1-(`alpha'/100)/2)*SE
}

foreach var of varlist DiD ub* lb* {
	replace `var' = `var'*100
}

replace risk = "Arb.-platzverl." if risk == "eunemp"
replace risk = "Familientr." if risk == "efambreak"
replace risk = "Krankheit" if risk=="eill"
replace risk = "Verrentung" if risk == "eretire"
label define risknum 1 "Arb.-platzverl." 2 "Krankheit" 3 "Verrentung" 4 "Familientr."
encode risk, gen(risknum) label(risknum)

gen abst = abs(t)
sum ub1, meanonly
by cntry risknum (abst), sort: gen laby = ceil(r(max)) if _n==1
by cntry risknum (abst): gen labx = -3 if _n==1
by cntry risknum (abst): gen nstr = "Anz. Ereign: "+string(n[1])

forv i = 1(1)95 {
	replace lb`i' = 0 if lb`i' < 0
	local rarea `rarea' 				/// 
	  || rarea ub`i' lb`i' t if t >= 0, 			/// 
	  lcolor(black*`=(`i'+5)/100') fcolor(black) fintensity(`=`i'+5') sort
}

graph twoway 							///
  `rarea' 								///
  || line DiD t if t >= 0, lcolor(white) sort ///
  || line DiD t if t <= 0, lcolor(black) sort ///
  || scatter laby labx, ms(i) mlab(nstr) mlabpos(3) ///
  || , ytitle(Differenz Anteil Arme (in %))  /// 
  ylabel(0(3)18, grid) ///
  xtitle(Jahre vor/nach Ereignis) 		///
  xlabel(-3(1)3) ///
  xline(0, lcolor(gs12)) 	///
  by(cntry risknum, note("") rows(2) legend(off)) 		///

graph export andid_bycntry.eps, replace

exit




// Diff-in-Diff by Country and time
// kohler@wzb.eu

// andid_bytime1.do: Control group missing for US after 1996 -> fixed

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
			  sum(`event'atrisk==1 		/// 
			  & (wave == cond("`cntry'" == "US" & eyear>1997,(eyear-2),(eyear-1)))) 
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

		sum eyear, meanonly
		gen period = recode(eyear,1989,1995,2000,2010)
		collapse (mean) mean=poor (sd) sd=poor (count) n=poor [aw=weight] ///
		  , by(period treatment t)
		
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

by cntry risk period t (treatment), sort: 		/// 
  gen DiD = (mean - mean[_n-1]) 	
by cntry risk period t (treatment), sort: 		/// 
  gen SE = sqrt(sd/n + sd[_n-1]/n[_n-1]) 	

keep if treatment

// Average post event periods
keep if t>=0
collapse (mean) DiD SE n, by(cntry risk period)

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


// Rescale period to mid of intervall
gen prescale = 1982 + (1989-1982)/2 			/// 
  if cntry == "US" & inlist(risknum,1,2,4) & period==1989
replace prescale = 1983 + (1989-1983)/2        ///
  if cntry == "US" & inlist(risknum,3) & period==1989

replace prescale = 1990 + (1995-1990)/2 			/// 
  if cntry == "US" & inlist(risknum,1,2,3,4) & period==1995
replace prescale = 1996 + (2000-1996)/2 			/// 
  if cntry == "US" & inlist(risknum,1,2,3,4) & period==2000

replace prescale = 2001 + (2006-2001)/2 			/// 
  if cntry == "US" & inlist(risknum,1,2,4) & period==2010
replace prescale = 2001 + (2004-2001)/2 			/// 
  if cntry == "US" & inlist(risknum,3) & period==2010

replace prescale = 1985 + (1989-1985)/2 			/// 
  if cntry == "DE" & inlist(risknum,1,2,4) & period==1989
replace prescale = 1986 + (1989-1986)/2  ///
  if cntry == "DE" & inlist(risknum,3) & period==1989

replace prescale = 1990 + (1995-1990)/2 			/// 
  if cntry == "DE" & inlist(risknum,1,2,3,4) & period==1995
replace prescale = 1996 + (2000-1996)/2 			/// 
  if cntry == "DE" & inlist(risknum,1,2,3,4) & period==2000

replace prescale = 2001 + (2008-2001)/2 			/// 
  if cntry == "DE" & inlist(risknum,1,2,4) & period==2010
replace prescale = 2001 + (2007-2001)/2 			/// 
  if cntry == "DE" & inlist(risknum,3) & period==2010

forv i = 1(1)95 {
	replace lb`i' = 0 if lb`i' < 0
	replace ub`i' = 18 if ub`i' > 18
	local rarea `rarea' 				/// 
	  || rarea ub`i' lb`i' prescale, 			/// 
	  lcolor(black*`=(`i'+5)/100') fcolor(black) fintensity(`=`i'+5') sort
}

graph twoway 							///
  `rarea' 								///
  || line DiD prescale, lcolor(white) sort ///
  || , ytitle(Durchn. Differenz Anteil Arme (DiD in %))  /// 
  ylabel(0(3)18, grid) ///
  xlabel(, labsize(*.8)) 				///
  xtitle("") 							///
  by(cntry risknum, note("") rows(2) legend(off)) 		///

graph export andid_bytime1.eps, replace


exit









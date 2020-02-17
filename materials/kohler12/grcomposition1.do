// Composition of Treatment and Control Groups

version 11
set more off
clear
set memory 200m
set scheme s1mono

cd "$liferisks/armut/analysen"

foreach cntry in  DE US {
	
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

		// Mean income before event 
		// ------------------------
		
		by newid (wave): gen t = wave - eyear
		keep if t < 0

		collapse (mean) hhpostgoveq weight	///
		  , by(treatment eyear newid) // mean income before event

		collapse 						/// 
		  (mean) mean=hhpostgoveq 		/// 
		  (sd) sd=hhpostgoveq (count) 	/// 
		  n=hhpostgoveq [aw=weight] ///
		  , by(treatment eyear)
		
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

gen ub = mean + 1.96 * sd/sqrt(n)
gen lb = mean - 1.96 * sd/sqrt(n)

replace risk = "Arb.-platzverl." if risk == "eunemp"
replace risk = "Familientr." if risk == "efambreak"
replace risk = "Krankheit" if risk=="eill"
replace risk = "Verrentung" if risk == "eretire"

replace risk = "DE, " + risk if cntry== "DE"
replace risk = "US, " + risk if cntry== "US"

label define risknum 					/// 
  1 "DE, Arb.-platzverl."               /// 
  2 "DE, Krankheit" 					/// 
  3 "DE, Verrentung" 					/// 
  4 "DE, Familientr."                   ///
  5 "US, Arb.-platzverl."               /// 
  6 "US, Krankheit" 					/// 
  7 "US, Verrentung" 					/// 
  8 "US, Familientr.", modify

encode risk, gen(risknum) label(risknum)

graph twoway 							///
  || rarea ub lb eyear if treatment, sort ///
  || line mean mean eyear if !treatment,  /// 
  lcolor(white black) lwidth(*1.3 *1) sort ///
  || if cntry=="DE"									/// 
  , ytitle("(in Euro)", size(*1.2))  ///
  by(risknum, rows(1) note("") legend(off) iscale(*1.5)) 	///
  xtitle("") xlabel(none) xtick(1982(8)2006) 		 ///
  ylabel(8000(8000)32000)  ///
  name(g1, replace) nodraw

graph twoway 							///
  || rarea ub lb eyear if treatment, sort ///
  || line mean mean eyear if !treatment,  /// 
  lcolor(white black) lwidth(*1.3 *1) sort ///
  || if cntry=="US"									/// 
  , ytitle("(in Dollar)", size(*1.2)) ///
  by(risknum, rows(1) note("") legend(off) iscale(*1.5)) 	///
  xtitle("") xlabel(1982(8)2006) 		 ///
  ylabel(10000(15000)55000)   ///
  name(g2, replace) nodraw

// Make Legend
graph twoway 							///
  || rarea ub lb eyear, sort ///
  || line mean mean eyear,  ///
  yscale(off) xscale(off) 				/// 
  lcolor(white black) lwidth(*1.3 *1) sort ///
  legend(order(3 "Personen ohne Ereignis" 1 "Personen mit Ereignis (95% CI)")) 	///
  name(leg, replace) nodraw

// Delete Plrogregion and fix ysize (Thanks, Vince)
_gm_edit .leg.plotregion1.draw_view.set_false
_gm_edit .leg.ystretch.set fixed

graph combine g1 g2, rows(2) imargin(t=0 b=0)  /// 
  l1title(Durchschnittl. jährl. Haushaltsäquivalenzeinkommen)  ///
  name(data, replace) nodraw

graph combine data leg, rows(2) imargin(t=0 b=0)

graph export grcomposition1.eps, replace


exit








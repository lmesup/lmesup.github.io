// Measures of Poorness in Comparison
// kohler@wzb.eu

cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m


// Official Data
// --------------
// Source DE: 1981-1994 + 2004: LIS; 1995-2009: Eurostat
// Source US

input wave str2 cntry poor
	1981 DE 10.579 
	1983 DE 11.688 
	1984 DE 14.057 
	1989 DE 11.391 
	1994 DE 13.558 
	1995 DE 15 
	1996 DE 14 
	1997 DE 12 
	1998 DE 11 
	1999 DE 11 
	2000 DE 10 
	2001 DE 11 
	2003 DE 13.6 
	2004 DE 14.342
	2005 DE 12.2 
	2006 DE 12.5 
	2007 DE 15.2 
	2008 DE 15.2 
	2009 DE 15.5 
	2009 US 14.3 
	2008 US 13.2 
	2007 US 12.5 
	2006 US 12.3 
	2005 US 12.6 
	2004 US 12.7 
	2003 US 12.5 
	2002 US 12.1 
	2001 US 11.7 
	2000 US 11.3 
	1999 US 11.9 
	1998 US 12.7 
	1997 US 13.3 
	1996 US 13.7 
	1995 US 13.8 
	1994 US 14.5 
	1993 US 15.1 
	1992 US 14.8 
	1991 US 14.2 
	1990 US 13.5 
	1989 US 12.8 
	1988 US 13.0 
	1987 US 13.4 
	1986 US 13.6 
	1985 US 14.0 
	1984 US 14.4 
	1983 US 15.2 
	1982 US 15.0 
	1981 US 14.0 
	1980 US 13.0 
end
gen source = "Offiziell"

tempfile official
save `official'

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
  || lowess poor wave if source=="eage"  ///
  , sort  pstyle(p6) lcolor(gs14) ///								///
  || lowess poor wave if source=="eill"  ///
  , sort  pstyle(p4) lcolor(gs14) ///
  || lowess poor wave if source=="eunemp"  ///
  , sort  pstyle(p3) lcolor(gs14) ///
  || line poor wave if source=="Unsere Daten"  ///
  , sort  pstyle(p2) lcolor(gs14) ///
  || line poor wave if source=="Offiziell" 	///
  , sort pstyle(p1) ///
  || , by(cntry, note("")) 							///
  ytitle("Anteil Armer (in %)") 		///
  legend(order(5 "Offiziell" 4 "Unsere Daten" 3 "Arbeitslosigkeit"  /// 
  2 "Krankheit"  1 "Verrentung") rows(2))  ///
  xtitle("") ylabel(0(10)40, grid)

graph export anmeasures3_offiziell.eps, replace

// Our line
graph twoway 							/// 
  || lowess poor wave if source=="eage"  ///
  , sort  pstyle(p6) lcolor(gs14) ///								///
  || lowess poor wave if source=="eill"  ///
  , sort  pstyle(p4) lcolor(gs14) ///
  || lowess poor wave if source=="eunemp"  ///
  , sort  pstyle(p3) lcolor(gs14) ///
  || line poor wave if source=="Unsere Daten"  ///
  , sort  pstyle(p2) ///
  || line poor wave if source=="Offiziell" 	///
  , sort pstyle(p1) ///
  || , by(cntry, note("")) 							///
  ytitle("Anteil Armer (in %)") 		///
  legend(order(5 "Offiziell" 4 "Unsere Daten" 3 "Arbeitslosigkeit"  /// 
  2 "Krankheit" 1 "Verrentung") rows(2))  ///
  xtitle("") ylabel(0(10)40, grid)

graph export anmeasures3_unsere.eps, replace

// Unemployment line
graph twoway 							/// 
  || lowess poor wave if source=="eage"  ///
  , sort  pstyle(p6) lcolor(gs14) ///								///
  || lowess poor wave if source=="eill"  ///
  , sort  pstyle(p4) lcolor(gs14) ///
  || line poor wave if source=="Offiziell" 	///
  , sort pstyle(p1) lcolor(gs14) ///
  || line poor wave if source=="Unsere Daten"  ///
  , sort  pstyle(p2) ///
  || lowess poor wave if source=="eunemp"  ///
  , sort  pstyle(p3) ///
  || , by(cntry, note("")) 							///
  ytitle("Anteil Armer (in %)") 		///
  legend(order(3 "Offiziell" 4 "Unsere Daten" 5 "Arbeitslosigkeit"  /// 
  2 "Krankheit" 1 "Verrentung") rows(2))  ///
  xtitle("") ylabel(0(10)40, grid)

graph export anmeasures3_unemp.eps, replace

// Illness line
graph twoway 							/// 
  || lowess poor wave if source=="eage"  ///
  , sort  pstyle(p6) lcolor(gs14) ///								///
  || lowess poor wave if source=="eunemp"  ///
  , sort  pstyle(p3) lcolor(gs14) ///
  || line poor wave if source=="Offiziell" 	///
  , sort pstyle(p1) lcolor(gs14) ///
  || line poor wave if source=="Unsere Daten"  ///
  , sort  pstyle(p2) ///
  || lowess poor wave if source=="eill"  ///
  , sort  pstyle(p4) ///
  || , by(cntry, note("")) 							///
  ytitle("Anteil Armer (in %)") 		///
  legend(order(3 "Offiziell" 4 "Unsere Daten" 2 "Arbeitslosigkeit"  /// 
  5 "Krankheit" 1 "Verrentung") rows(2))  ///
  xtitle("") ylabel(0(10)40, grid)

graph export anmeasures3_ill.eps, replace

// Age-line
graph twoway 							/// 
  || lowess poor wave if source=="eill"  ///
  , sort  pstyle(p4) lcolor(gs14) ///
  || lowess poor wave if source=="eunemp"  ///
  , sort  pstyle(p3) lcolor(gs14) ///
  || line poor wave if source=="Offiziell" 	///
  , sort pstyle(p1) lcolor(gs14) ///
  || line poor wave if source=="Unsere Daten"  ///
  , sort  pstyle(p2) ///
  || lowess poor wave if source=="eage"  ///
  , sort  pstyle(p6) ///
  || , by(cntry, note("")) 							///
  ytitle("Anteil Armer (in %)") 		///
  legend(order(3 "Offiziell" 4 "Unsere Daten" 2 "Arbeitslosigkeit"  /// 
  1 "Krankheit" 5 "Verrentung") rows(2))  ///
  xtitle("") ylabel(0(10)40, grid)

graph export anmeasures3_age.eps, replace








exit





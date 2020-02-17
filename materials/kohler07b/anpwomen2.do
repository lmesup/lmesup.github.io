* Fraction of Women with Confidence Bounds around true-Value
* kohler@wz-berlin.de

version 9

	drop _all
	set memory 90m
	set more off
	
	// Data
	use svydat04 if eu & survey != "Euromodule"
	keep if weich == 1

	// Calculate design effects 
	svyset [pweight=dweight], strata(ost)
	foreach survey in "EVS 1999" "ISSP 2002" "EB 62.1" {
		quietly svy: mean women if iso3166_2=="DE" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local de`:word 1 of `survey'' = D[1,1]
	}
	svyset [pweight=dweight], strata(nirl)
	foreach survey in "EVS 1999"  "ISSP 2002" "EB 62.1" {
		quietly svy: mean women if iso3166_2=="GB" & survey=="`survey'"
		estat effects
		matrix D = r(deff)
		local gb`:word 1 of `survey''  = D[1,1]
	}


	// Calculate fraction and sd of women Make Aggregate Data
	collapse (mean) women eu sample (count) N = women ///
	  [aw=dweight] ///
	  , by(survey ctrname)

	// Sort-Order for Countries
	egen ctrsort = axis(eu ctrname), label(ctrname) gap reverse

	// Confidence Intervalls
	gen womenub = .5 + 1.96*sqrt(.5^2/N)
	gen womenlb = .5 - 1.96*sqrt(.5^2/N)

	replace womenub = .5 + 1.96*sqrt(.5^2/N *`deEB') ///
	  if survey=="EB 62.1" & ctrname == "Germany"
	replace womenub = .5 + 1.96*sqrt(.5^2/N *`deEVS') ///
	  if survey=="EVS 1999" & ctrname == "Germany"
	replace womenub = .5 + 1.96*sqrt(.5^2/N *`deISSP') ///
	  if survey=="ISSP 2002" & ctrname == "Germany"
	replace womenub = .5 + 1.96*sqrt(.5^2/N *`gbEB') /// 
	if survey=="EB 62.1" & ctrname == "United Kingdom"
	replace womenub = .5 + 1.96*sqrt(.5^2/N *`gbEVS') /// 
	if survey=="EVS 1999" & ctrname == "United Kingdom"
	replace womenub = .5 + 1.96*sqrt(.5^2/N *`gbISSP') /// 
	if survey=="ISSP 2002" & ctrname == "United Kingdom"
	
	replace womenlb = .5 - 1.96*sqrt(.5^2/N *`deEB') /// 
	if survey=="EB 62.1" & ctrname == "Germany"
	replace womenlb = .5 - 1.96*sqrt(.5^2/N *`deEVS') /// 
	if survey=="EVS 1999" & ctrname == "Germany"
	replace womenlb = .5 - 1.96*sqrt(.5^2/N *`deISSP') /// 
	if survey=="ISSP 2002" & ctrname == "Germany"
	replace womenlb = .5 - 1.96*sqrt(.5^2/N *`gbEB') /// 
	if survey=="EB 62.1" & ctrname == "United Kingdom"
	replace womenlb = .5 - 1.96*sqrt(.5^2/N *`gbEVS') /// 
	if survey=="EVS 1999" & ctrname == "United Kingdom"
	replace womenlb = .5 - 1.96*sqrt(.5^2/N *`gbISSP') /// 
	if survey=="ISSP 2002" & ctrname == "United Kingdom"
	
	// Separate by Quota
	gen quota = sample==6      
	separate women, by(quota)

	// The Graph
	twoway ///
	  || rbar womenub womenlb ctrsort if inrange(ctrsort,1,4)   /// Confidence Bounds
	  , horizontal color(gs10) sort                             ///
	  || rbar womenub womenlb ctrsort if inrange(ctrsort,6,15)  /// Confidence Bounds
	  , horizontal color(gs10) sort                             ///
	  || rbar womenub womenlb ctrsort if inrange(ctrsort,17,31) /// Confidence Bounds
	  , horizontal color(gs10) sort                             ///
	  || scatter ctrsort women0                                 /// Random Selection
	  , ms(O) mcolor(black)                                     ///
      || scatter ctrsort women1                                 /// Quota Selection 
	  , ms(O) mlcolor(black) mfcolor(white)                     ///
	  || scatteri 0 .5 31 .5                                    /// A vertical line if fg
	  , c(l) ms(i) clcolor(fg) clpattern(solid)                 /// 
	  || , by(survey, note("") l1title("") iscale(*.8))         /// Twoway Options 
      ylab(1(1)4 6(1)15 17(1)31, valuelabel angle(horizontal))  ///
	  legend(rows(1) order(4 "Random" 5 "Quota" ))              ///
	  scheme(s1mono) ysize(8.5)
	graph export anpwomen2.eps, replace

	// Some numbers for the text
	count if women < womenlb | women > womenub

	gen problems = women < womenlb | women > womenub
	tab survey problems, row

	exit
	


	
	

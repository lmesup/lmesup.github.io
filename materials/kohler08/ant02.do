*  P(Women) for H0: P(Women) = .5
* kohler@wz-berlin.de


* History
* ant02.do: Remove Mode of Collection from Results. Descreptive Table.
* ant01.do: First Version
	
version 9
	
	clear
	set memory 80m
	set more off
	set scheme s1mono
	
	use svydat01 if eu & weich == 1 // Note 1
	replace city = 0 if city == .

	// t-values by survey iso3166_2 city
	collapse (mean) womenp=women (count) N=women, by(survey iso3166_2 city) 
	gen woment = abs((womenp - .5)/sqrt(.5^2/N))
	sort survey iso3166_2
	preserve

	// Get the survey characteristics
	use survey-eu inst - gdp using svydat01, clear
	by survey iso3166_2, sort: keep if _n==1
	tempfile agg
	save `agg'
	

	// Bring survey characteristics back in
	restore
	merge survey iso3166_2 using `agg', nokeep
	assert _merge == 3
	drop _merge


	// Selection of Persons
	// --------------------

	label define persel 1 "Register" 2 "Kish/Last-Birthday"  3 "Quota" 4 "Missing"
	gen persel:persel = 1 if hhsamp == 0
	replace persel = 2 if selper == "Gfk master sample"
	replace persel = 2 if selper == "database of addresses"
	replace persel = 2 if selper == "kish grid"
	replace persel = 2 if selper == "kish grid or last birthday"
	replace persel = 2 if selper == "last birthday"
	replace persel = 2 if selper == "random selection"
	replace persel = 3 if selper == "last birthday + quota"
	replace persel = 3 if selper == "quota"
	replace persel = 4 if persel == .

	// Back-Checks
	// -----------

	label define back3 1 "Back-Checks" 2 "No Back-Checks"  3 "Missing"
	gen back3:back3 = 1 if back > 0 
	replace back3 = 2 if back == 0
	replace back3 = 3 if back < 0


	// Descrebtive Table
	// -----------------

	preserve
	keep persel back3 resrate resratei survey ctrname eu hdi
	by survey ctrname, sort: keep if _n==1

	forv i=1/4 {
		by survey: gen persel`i' = sum(persel==`i')
		by survey: replace persel`i' = persel`i'[_N]
	}
	
	forv i=1/3 {
		by survey: gen back3`i' = sum(back3==`i')
		by survey: replace back3`i' = back3`i'[_N]
	}
	
	replace resrate = . if resrate==-3
	replace resrate = . if resrate==-1
	by survey (resrate), sort: gen resrate1 = resrate[1]
	by survey: gen resrate2 = sum(resrate)/sum(resrate<.)
	by survey: replace resrate2 = round(resrate2[_N],1)
	replace resrate = -1 if resrate == .
	by survey (resrate), sort: gen resrate3 = resrate[_N] if resrate[_N] ~= -1
	by survey: gen resrate4 = sum(resrate==-1)
	by survey: replace resrate4 = resrate4[_N]
	
	by survey: keep if _n==1
	keep survey persel1-resrate4

	reshape long persel back3 resrate, i(survey) j(cat)
	ren persel stat1
	ren back3 stat2
	ren resrate stat3
	gen index = _n
	reshape long stat, i(index) j(item)
	drop if stat == .

	encode survey, gen(svy)
	drop survey
	drop index
	egen index = group(item cat)
	reshape wide stat, j(svy) i(index)

	tostring cat, replace
	replace cat = "Register" if cat == "1" & item == 1
	replace cat = "Kish/Last-Birthday" if cat == "2" & item == 1
	replace cat = "Quota" if cat == "3" & item == 1
	replace cat = "Missing" if cat == "4" & item == 1
	replace cat = "with Back-Checks" if cat == "1" & item == 2
	replace cat = "without Back-Checks" if cat == "2" & item == 2
	replace cat = "Missing" if cat == "3" & item == 2
	replace cat = "Minimum" if cat == "1" & item == 3
	replace cat = "Average" if cat == "2" & item == 3
	replace cat = "Maximum" if cat == "3" & item == 3
	replace cat = "Missing (num. of countr.)" if cat == "4" & item == 3

	listtex cat stat1-stat6 using ant02des.tex if item == 1                            ///
	  , type replace missnum(-) rstyle(tabular)                                        ///
	  head("\begin{tabular}{lrrrrrr} \hline "                                          ///
	  "& EB 62.1 & EQLS '03 & ESS '02 & EVS '99 & Euromod. & ISSP '02 \\ \hline "      ///
	  "\multicolumn{7}{l}{\emph{Number of Countries with Selection Mode}} \\ ") 

	listtex cat stat1-stat6 if item == 2                                               ///
	  , type appendto(ant02des.tex) missnum(-) rstyle(tabular)                         ///
	  head(                                                                            /// 
	  "\multicolumn{7}{l}{\emph{Number of Countries ... }} \\ ") 

	listtex cat stat1-stat6 if item == 3                                               ///
	  , type appendto(ant02des.tex) missnum(-) rstyle(tabular)                         ///
	  head(                                                                            /// 
	  "\multicolumn{7}{l}{\emph{Response Rate }} \\ ")                                 ///
	  foot("\hline" "\end{tabular}" )

	
	// Regression Models
	// -----------------
	
	restore
	
	// Dummies
	foreach var of varlist persel back3 {
		levels `var', local(K)
		foreach k of local K {
			gen `var'`k' = `var' == `k'
			local lab: label (`var') `k'
			label variable `var'`k' `"`lab'"'
		}
	}


	levels survey, local(K)
	local i 1
	foreach k of local K {
		gen svy`i' = survey=="`k'"
		lab var svy`i++' "`k'"
	}
			
	gen resmis = resrate<0 | quota
	replace resmis = 1 if resrate >= 90
	replace resrate = . if resrate >= 90
	sum resrate if !resmis
	replace resrate = r(mean) if resmis
	label variable resrate "Response Rate"
	label variable resmis "No Resp. Rate"

	reg woment resrate resmis
	estimates store reg1, title("(1)")

	reg woment resrate resmis  persel2-persel4
	estimates store reg2, title("(2)")

	reg woment resrate resmis  back32 back33
	estimates store reg3, title("(3)")

	reg woment resrate resmis persel2-persel4 back32 back33 
	estimates store reg4, title("(4)")

	estout reg1 reg2 reg3 reg4 using ant02.tex, replace    ///
	  cells(b(star fmt(%3.2f)) t(par fmt(%3.2f) drop(_cons) ))  ///
	  stats(r2 N, fmt(%3.2f %3.0f) labels("R-Square" "N"))      ///
	  starlevels(* 0.05 ** 0.01)                                ///
	  posthead("\hline") prefoot("\hline") postfoot("\hline")   ///
	  label ///
	  varlabels(_cons Constant, ///
	  blist(persel2 "\multicolumn{5}{l}{\emph{Mode of Selection (Reference: Register) }}  \\" ///
	  back32   "\multicolumn{5}{l}{\emph{Back-Checks (Reference: Yes) }} \\ " ///
	  resrate   "\multicolumn{5}{l}{\emph{Response Rate }} \\ " ///
	  )) ///
	  style(tex)



	// Response-Rate Plot
	// ------------------

	replace resratei = 0 if resratei < 0
	separate woment, by(resratei)

	tw ///
	  (sc woment0 woment1 resrate if !resmis, ms(O ..) mlc(black ..) mfc(white black))  ///
	  (lowess woment0 resrate if !resmis, lc(black) lp(dash) )     ///
	  (lowess woment1 resrate if !resmis, lc(black) lp(solid) )    ///
	  , xlab(20(10)90 55 `" " " "Response Rate""', notick labgap(*3.5) ) xtick(20(10)90) ///
	  legend(off) name(scatter, replace) ytitle(Dep. from Randomness) ///
	  xtitle("") ylab(0(1)5, grid) yscale(range(-.08,5.06)) nodraw

	graph box woment if resmis  ///
	  , marker(1, ms(oh)) box(1, lcolor(black) fcolor(white)) medtype(marker)     ///
	    medmarker(ms(O) mcolor(black)) fxsize(20)                                 ///
	    over(resmis, label(ticks) relabel(1 `""Missing" "Resp. Rate""') ) yalternate               ///
	  name(box, replace) yscale(range(0,5)) ylabe(0(1)5) nodraw

	graph combine scatter box, ycommon imargin(vsmall) iscale(*1.5) name(both, replace) nodraw
	

	// Legend
	tw ///
	  (sc woment0 woment1 resrate if !resmis, ms(O ..) mlc(black ..) mfc(white black))  ///
	  (lowess woment0 resrate if !resmis, lc(black) lp(dash) )     ///
	  (lowess woment1 resrate if !resmis, lc(black) lp(solid) )   ///
	  , legend(order(1 "reported" 2 "harmonised" 3 "response rate" 4 "response rate") rows(2) rowgap(*.1)) ///
	    name(leg, replace) yscale(off) xscale(off) xtitle(Response Rate)  nodraw
	  
	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
   _gm_edit .leg.ystretch.set fixed
	
	// Combine them
	graph combine both leg , cols(1) imargin(tiny) iscale(*1.2)
	graph export ant02_resrate.eps, replace
	

	// Combined Box-Plots
	// ------------------

	// Reshape it
	gen cov1:cov = persel
	gen cov3:cov = 7 + back3

	label define cov ///
	  1 "Register" 2 "Kish/Last-Birthday"  3 "Quota" 4 "Missing"     ///
	  8 "Back-Checks" 9 "No Back-Checks"  10 "Missing"

	gen index = _n
	reshape long cov, i(index) j(dim)

	label value dim dim
	label define dim 1 "Mode of Selection"  3 "Back-Checks"

	// Some settings for the graphs
	local opt "marker(1, ms(oh)) box(1, lcolor(black) fcolor(white)) medtype(marker)" 
	local opt "`opt' medmarker(ms(O) mcolor(black)) horizontal outergap(100)"
	local opt "`opt' nofill ysize(7) ytitle(Dep. from Randomness, place(4))"
	
	// ... and well, the graph
	graph box woment, over(cov) `opt' by(dim, cols(1) note(" ")  iscale(*1.3) )
	graph export ant02.eps, replace



	
	
	exit

	Notes
	-----

	(1) No information on city in EB 62.1, France and ISSP 2002, Ireland


	


	
	


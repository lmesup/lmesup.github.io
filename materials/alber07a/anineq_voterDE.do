* Difference in electoral participation
* Author: lenarz@wzb.eu -> diff_voter.do
* Rework: kohler@wzb.eu 

version 10
	set more off
	set scheme s1mono

	clear
	set memory 100m

	use ///
	  persid iso3166 dataset voter hhinc edu weight ///
	  using cses, clear
	append using ess02  ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using ess04  ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using issp02 ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using issp04 ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )
	append using eqls03 ///
	  , keep(persid iso3166 dataset voter hhinc edu weight  )

	// Classify Nations
   drop if iso3166=="TR"
	gen natfam = 1 if iso3166 == "US"
	replace natfam = 2 if ///
	  inlist(iso3166,"AT","BE","DE","DK","ES") ///
	  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
	  | inlist(iso3166,"IT","LU","NL","PT","SE")
	replace natfam = 3 if ///
	  inlist(iso3166,"CY","MT","TR")
	replace natfam = 4 if ///
	  inlist(iso3166,"BG","CZ","EE","HU") ///
	  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
	replace natfam = 5 if natfam == .
	keep if natfam < 5

	// Produce results as table
	// ------------------------

	preserve
	gen hhinc3 = 1 if hhinc == 1
	replace hhinc3 = 2 if inlist(hhinc,2,3,4)
	replace hhinc3 = 3 if hhinc == 5

	collapse (mean) voter natfam if hhinc3 < ., by(iso3166 hhinc3 dataset)
	by iso3166 hhinc3, sort: gen byte surveys = _N
	by iso3166 hhinc3, sort: egen voter_hhinc = mean(voter)
	by iso3166 hhinc3: keep if _n==1
	keep iso3166 surveys hhinc3 voter_hhinc natfam
	replace voter_hhinc = round(voter_hhinc * 100,1)
	reshape wide voter_hhinc, i(iso3166) j(hhinc3)
	tempfile part1
	save `part1'
	restore , preserve

	collapse (mean) voter natfam if edu < ., by(iso3166 edu dataset)
	by iso3166 edu, sort: egen voter_edu = mean(voter)
	by iso3166 edu: keep if _n==1
	keep voter_edu iso3166 edu
	replace voter_edu = round(voter_edu * 100,1)
	reshape wide voter_edu, i(iso3166) j(edu)

	merge iso3166 using `part1', sort
	assert _merge==3
	drop _merge

	sort natfam iso3166
	listtex iso3166 surveys voter_hhinc* voter_edu* using ../table2DE.txt ///
	  , replace rstyle(tabdelim)
	sum

	restore   
	
	//Dummys der Statifizierungsvariablen bilden
	tab hhinc, gen(hhinc)
	tab edu, gen(edu)

	// Initialise postfile
	tempfile diff
	postfile coefs str2 iso3166 str10 dataset str10 strat b using `diff', replace

	//Differenzen by country 
	levelsof dataset, local(D)
	quietly foreach dataset of local D {
		levelsof iso3166 if dataset == "`dataset'", local(K)
		foreach k of local K {
			count if !mi(voter) & !mi(hhinc5) & dataset == "`dataset'" & iso3166 == "`k'"
			if r(N) > 300 {
				reg voter hhinc2-hhinc5 if iso3166 == "`k'" & dataset == "`dataset'"
				post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5])
			}
			count if !mi(voter) & !mi(edu3) & dataset == "`dataset'" & iso3166 == "`k'"
			if r(N) > 300 {
				reg voter edu2 edu3 if iso3166 == "`k'"  & dataset == "`dataset'"
				post coefs ("`k'") ("`dataset'") ("edu") (_b[edu3])
			}
		}
	}

	postclose coefs

	use `diff', replace
	drop if b==0

	gen natfam = 1 if iso3166 == "US"
	replace natfam = 2 if ///
	  inlist(iso3166,"AT","BE","DE","DK","ES") ///
	  | inlist(iso3166,"FI","FR","GB","GR","IE") ///
	  | inlist(iso3166,"IT","LU","NL","PT","SE")
	replace natfam = 3 if ///
	  inlist(iso3166,"CY","MT","TR")
	replace natfam = 4 if ///
	  inlist(iso3166,"BG","CZ","EE","HU") ///
	  | inlist(iso3166,"LT","LV","PL","RO","SI","SK")
	replace natfam = 5 if natfam == .
	keep if natfam < 5
	
	// Average, Minimum, Maximum Participation Measure of Datasets
	by iso3166 strat, sort: gen meanb = sum(b)/sum(b<.)
	by iso3166 strat: replace meanb = meanb[_N]

	by iso3166 strat (b), sort: gen minb = b[1] 
	by iso3166 strat (b): gen maxb = b[_N] 

	// Values for vertical lines 
	by natfam strat, sort: gen MEANb = sum(meanb)/sum(meanb<.) if _N > 1
	by natfam strat: replace MEANb = MEANb[_N] if _N > 1


	// Graphs by Country
	// -----------------

	// Graph titles
   gen dim:dim = 1 if strat == "hhinc"
	replace dim = 2 if strat == "edu"
   label define dim 1 "Einkommen (5. - 1. Quintil)" 2 "Bildung (Tertiär - Primär)" 

	// Order of categorical axis
	by iso3166, so: gen order = sum(meanb)/sum(meanb<.)
	by iso3166: replace order = order[_N]

	egen axis = axis(natfam order), reverse label(iso3166) gap

	// Rendering of categorical axis labels
	levelsof axis if natfam < 5, local(I)
	levelsof natfam, local(J)
	local vlines ""
	foreach j of local J {
		local vlines ///
		  "`vlines' || line axis MEANb if natfam==`j', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
	}

	// Graph and Export
	graph twoway ///
	  `vlines'                                                     ///
	  || rspike minb maxb axis                                     ///
      , horizontal lcolor(black)                                  ///
	  || scatter axis meanb                                        ///
      , msymbol(O) mlcolor(black) mfcolor(black)                  ///
	  || , ylabel(`I', valuelabel angle(0) labsize(*.8) gstyle(dot)) ytitle("")      ///
      xtitle("Differenz der Wahlbeteiligung" "(Statushöhere minus Statusniedere)")  ///
	   xlabel(-.2(.2).4) xtick(-.2(.1).4) xmtick(-.15(.1).35)       ///
      by(dim, legend(off) ///
      note("Quellen: CSES I, CSES II, ISSP '04, ISSP '02, ESS '02, ESS '04, EQLS '03", span) ///
      title(`"Grafik 3: "', span ring(2) pos(11) justification(left) size(medlarge)) ///
      subtitle(`"Ungleichheit der Wahlbeteiligung in den"'                           ///
               `"Dimensionen Haushaltseinkommen und "'                               ///
               `"Bildung"', margin(l+17 b+3)                               ///
                span ring(2) pos(11) justification(left) size(medlarge)))            ///
	  ysize(5) xsize(4.5) 

	graph export ../figure3DE.eps, replace preview(on) 


	// Analyze by electoral system variables
	// -------------------------------------
	sort iso3166
	merge iso3166 using electionsystems2, nokeep ///
	  keep(eltype eldate comp_reg elecsys compvote multip weekend branch compet) 
	assert _merge==3
	drop _merge

	// Produce numbers in the text
	// ---------------------------

	tab natfam weekend, sum(b)
	tab natfam branch, sum(b)
	tab natfam compvote, sum(b)

	gen proportional = inlist(elecsys,"List PR", "MMP", "STV") ///
	  if elecsys != "Parallel"
	tab natfam proportional, sum(b)

	by natfam, sort: reg b compet
	reg b compet if natfam==2
	di _b[_cons] + _b[compet]*2

	by natfam, sort: reg b multip
	reg b multip if natfam==2
	di _b[_cons] + _b[multip]*2
	
	gen sim1 = (weekend != weekend[1]) ///
	  + (branch != branch[1]) ///
	  + (compvot != compvote[1]) ///
	  + (comp_reg != comp_reg[1]) ///
	  + (proportional != proportional[1]) ///
	  + (abs(compet-compet[1])/62) ///
	  + (abs(multip - multip[1])/8)

	sort sim1
	list eldate iso3166 sim1 b

	gen sim2 = (weekend != weekend[1]) ///
	  + (branch != branch[1]) ///
	  + (compvot != compvote[1]) ///
	  + (comp_reg != comp_reg[1]) ///
	  + (proportional != proportional[1]) ///
	  + (abs(multip - multip[1])/8)

	sort sim2
	list eldate  iso3166 sim2 b

	gen exec = branch == "Exec."
	gen comp = compvote == "Yes"
	reg b weekend exec comp comp_reg proportional compet multip ///
	  if natfam == 2
	predict yhat if natfam == 1

	di yhat[1]

	// Anlyse by Inclusiveness
	// -----------------------

	sort iso3166
	merge iso3166 using inclusive, nokeep
	assert _merge == 3
	drop _merge

	gen socbrut = socbrut01 if mi(socbrut04) // OECD-Data
	replace socbrut = socbrut04 if mi(socbrut01) // Eurostat-Data
	replace socbrut = (socbrut04+socbrut01)/2 if !mi(socbrut04,socbrut01)
	lab var socbrut ///
	  "Sozialausgaben (brutto)"
	lab var socnet01 ///
	  "Sozialausgaben (netto)"
	lab var taxrev04 ///
	  "Steuereinnahmen"
	lab var pens04 ///
	  "Alterssicherungsausgaben"


	preserve
	by iso3166, sort: keep if _n==1
	replace order = round(order*100,1)
   lab def fund 0 "Keine" 1 "Direkt" 2 "Indirekt" 3 "Direkt und indirekt" 4 "Sonstiges", modify
	format socbrut socnet01 taxrev04 pens04 %4.0f
	sort natfam order
	listtex iso3166 order fund socbrut socnet01 taxrev04 pens04  ///
	  using ../table3DE.txt     ///
	  , replace rstyle(tabdelim)
	restore

	// Graph and Export
	foreach x of varlist socbrut taxrev04 {
		graph twoway                                         ///
		  || scatter meanb `x' if natfam == 1                ///
		  , ms(O) mlcolor(black) mfcolor(black)              ///
		  || scatter meanb `x' if natfam == 2                ///
		  , ms(O) mlcolor(black) mfcolor(white)              ///
		  || scatter meanb `x' if natfam == 3                ///
		  , ms(S) mlcolor(black) mfcolor(black)              ///
		  || scatter meanb `x' if natfam == 4                ///
		  , ms(S) mlcolor(black) mfcolor(white)              ///
		  || lowess meanb `x' if natfam == 2, lcolor(black) lpattern(dot)   ///
		  || lowess meanb `x' if natfam == 3, lcolor(black) lpattern(solid) ///
		  || lowess meanb `x' if natfam == 4, lcolor(black) lpattern(dash)  ///
		  , name(`x', replace) nodraw legend(off)            ///
		  xtitle(`:variable label `x'')                      
	}

  graph combine socbrut taxrev04 , ///
    l1title("Ungleichheit der Wahlbeteiligung") ///
    name(g1, replace) nodraw

  // Legende
 graph twoway ///
	 || scatter meanb socbrut if natfam == 1            ///
	  , ms(O) mlcolor(black) mfcolor(black)              ///
	  || scatter meanb socbrut if natfam == 2            ///
	  , ms(O) mlcolor(black) mfcolor(white)              ///
	  || scatter meanb socbrut if natfam == 3            ///
	  , ms(S) mlcolor(black) mfcolor(black)              ///
	  || scatter meanb socbrut if natfam == 4            ///
	  , ms(S) mlcolor(black) mfcolor(white)              ///
	  legend(rows(1) order(1 "US" 2 "EU-15" 4 "Post-Soz." 3 "Med. Periph.")) ///
     name(leg, replace) yscale(off) xscale(off) nodraw 

	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
   _gm_edit .leg.ystretch.set fixed

	graph combine g1 leg, cols(1)  ///
     note("Quellen: CSES, ISSP, ESS, EQLS (Ungleichheit der Wahlbeteiligung);"      ///
          "OECD, Eurostat (Reichweite sozialstaatlicher Leistungen)", span)         ///
     title(`"Grafik 4: "', span ring(2) pos(11) justification(left) size(medlarge)) ///
     subtitle(`"Ungleichheit der Wahlbeteiligung in Ländern"' ///
              `"mit unterschiedlichen Sozialausgabe- "' ///
              `"und Staatseinnahmequoten"'                           ///
                , margin(l+17 b+3)                                                  ///
                span ring(2) pos(11) justification(left) size(medlarge))            ///
	  ysize(4) xsize(4.5) 
	graph export ../figure4DE.eps, replace preview(on) 

	reg meanb socbrut taxrev04  ///
	  if natfam == 2
	predict yhat2 if natfam == 1

	sort yhat2
	list yhat2 in 1

	exit


         



	

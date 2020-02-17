* Vote-Inequality on institutional mechanisms
	version 9

	// Data
	// ----

	// Turnout 
	use s_cntry q25 wcountry using $dublin/eqls_4, clear
	drop if q25 == 3
	gen voter = q25==1 if q25 < .
	collapse (mean) voter [aw=wcountry] , by(s_cntry)
	replace voter = voter*100
	format voter %2.0f

	// Merge Election-System
	sort s_cntry
	merge s_cntry using electsystem2, sort
	drop _merge
	
	// List Relevant Data to Tex
	// -------------------------

	merge s_cntry using isocntry, sort
	drop _merge

	// Compute Display-Variables
	gen pflicht:yesno = compul>0
	gen propor:yesno = type == 1 if type < .
	gen weekend:yesno = day == 0 | day==6 if day < .
	gen org=orgevs


	// Merge Voter-Inequlity Data
	// --------------------------

	merge s_cntry using  anvotstrat1 anvotzuf1a, nokeep sort
	drop _merge*

	// Labels
	// ------

	lab var voter "Wahlbeteiligung"
	lab var weekend "Wochenende"
	lab var nopers "Unpersönlich"
	lab var regis "Registrierung"
	lab var propor "Verhältniswahlrecht"
	lab var multip "Anzahl Parteien"
	lab var compet "Wettbewerbstgrad"
	lab var org "Organisationsgrad"
	lab var leftimp "Linksstärke"
	lab var rightimp "Rechtsstärke"

	// Bring into order
	sort eu voter
	listtex ctrde voter leftimp rightimp pflicht weekend propor multip compet orgevs ///
	  using anvoteungl02_des.tex ///
	  , replace  rstyle(tabular)

	// Listwise Deletion
	// ----------------

	mark touse
	markout touse voter leftimp rightimp pflicht weekend propor multip compet orgevs pflicht
	drop if !touse


	// EU-15
	gen eu15 = eu==1
	lab var eu15 "EU-15"
	
	// Scale indepvars to max-max = 1
	// ------------------------------

	foreach indepvar of varlist voter leftimp rightimp {
		sum `indepvar' if touse
		replace `indepvar' = (`indepvar' - r(mean))/(r(max) - r(min))
	}
	
	
	//  Regression Models horizontal Inequality
	// ----------------------------------------
	
	
	foreach var of varlist difflsat diffpubqual diffclev {
		ivreg `var' eu15 leftimp (voter = compet org propor weekend multip )
		estimates store ols`var'
		
		ivreg `var' eu15 rightimp (voter = compet org propor weekend multip )
		estimates store sls`var'
	}
	
	estout ///
	  olsdifflsatwc slsdifflsatwc olsdiffpubqualwc slsdiffpubqualwc olsdiffclevwc slsdiffclevwc ///
	  using anvoteungl02a.tex ///
	  , replace style(tex) label ///
	  prehead( ///
	  "\begin{tabular}{lrrrrrr} \hline" ///
	  "& \multicolumn{2}{c}{Leben}"   ///
	  "& \multicolumn{2}{c}{Öffentl. Dienste}"   ///
	  "& \multicolumn{2}{c}{Spann.-Wahrn.} \\ " ///
	  ) ///
	  posthead(\hline) ///
	  prefoot("\hline" ) ///
	  postfoot("\hline \\ \hline " ) ///
	  mlabel(, none ) /// 
	collabels(, none) ///
	  cells(b(fmt(%3.2f))) ///
	  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%4.2f %4.0f)) ///
	  varlabels(_cons Konstante)
	
	
	//  Regression Models horizontal Inequality
	// ----------------------------------------
	
	foreach var of varlist diffedu diffemp diffocc {
		ivreg `var' eu15 leftimp (voter = compet org propor weekend multip pflicht)
		estimates store ols`var'
		
		ivreg `var' eu15 rightimp (voter = compet org propor weekend multip pflicht)
		estimates store sls`var'
	}
	
	
	estout ///
	  olsdiffeduwc slsdiffeduwc olsdiffempwc slsdiffempwc olsdiffoccwc slsdiffoccwc ///
	  using anvoteungl02b.tex                        ///
	  , replace style(tex) label                     ///
	  prehead(                                       ///
	  "& \multicolumn{2}{c}{Bildung} "               ///
	  " & \multicolumn{2}{c}{Erwerbsstatus} "        ///
	  "& \multicolumn{2}{c}{Klasse} \\ "             ///
	  )                                              ///
	  posthead(\hline)                               ///
	  prefoot("\hline" )                             ///
	  postfoot("\hline" "\end{tabular}" )            ///
	  mlabel(, none )                                /// 
	collabels(, none)                                ///
	  cells(b(fmt(%3.2f)))                           ///
	  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%4.2f %4.0f)) ///
	  varlabels(_cons Konstante)
	
	exit
	


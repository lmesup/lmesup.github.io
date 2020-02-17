* Analysis of the ESS 2004
version 9.2
	clear	
	set more off
	set memory 90m
	

	// Convertion rates "Exchange Rates" to "PPP"
	// ------------------------------------------
	
	// Jahr: 2004 Source: http://epp.eurostat.ec.europa.eu
	// Datum des Auszugs: Fri, 11 Aug 06 12:25:40
	// Letzte Aktualisierung: Wed Jun 14 17:06:32 MEST 2006 
	
	input str2 cntry pni
	be 	  	103.1       
	cz 	  	53.4	    
	dk 	  	132.2	    
	de 	  	109	    
	ee 	  	57.4	    
	gr 	  	81.9	    
	es 	  	88.7	    
	fr 	  	107	    
	ie 	  	117.8	    
	it 	  	99.6	    
	cy 	  	89.8	    
	lv 	  	49.7	    
	lt 	  	48.5	    
	lu 	  	110.4	    
	hu 	  	58.9	    
	mt 	  	67.9	    
	nl 	  	106.5	    
	at 	  	104.3	    
	pl 	  	48.2	    
	pt 	  	82.9	    
	si 	  	73	    
	sk 	  	52.3	    
	fi 	  	112.5	    
	se 	  	117.8	    
	gb 	  	108.9
	bg 	  	36.3
	hr 	  	60.2
	ro 	  	38.4
	tr 	  	52.2
	is 	  	124.8
	no 	  	128.4
	ch 	  	130.1
end
	
	replace cntry = upper(cntry)
	gen toppp=100/pni
	
	input 
	UA . 5.362305   // from gdpdollar/gdpppp UNDP 
end
	
	
	label variable toppp "Conversion Factor"
	label variable pni "Preisniveauindex"
	order cntry pni toppp
	sort cntry
	
	tempfile agg
	save `agg'
	
	
	// Use ESS 2004
	// ------------
	
	use cntry ///
	  hhmmb hinctnt              /// Household-Size, Income
	  stf* scl* health hlthhmp   /// Attitudes
	  polintr lrscale vote       /// Politics
	  crmvct                     /// Crime-Victory 
	gndr yrbrn marital martlfr /// Socio-Demographie
	  cntbrtha fbrncnt mbrncnt   ///
	  iscoco iscocop pphincr edulvla emplrel ///
	  dweight pweight            /// Weights
	  using $ess/ess2004, clear

	drop if cntry=="EE" | cntry=="IL" | cntry=="IS" | cntry=="IT" ///
	  | cntry=="SK" | cntry=="UA"
		
	// Absolute Position
	// -----------------
	// (Source: Europ. Social Survey, Round 2 Showcards)
	
	gen l_absinc = . if hinctnt == 1
	replace l_absinc = 150 if hinctnt == 2 
	replace l_absinc = 300 if hinctnt == 3 
	replace l_absinc = 500 if hinctnt == 4 
	replace l_absinc = 1000 if hinctnt ==5  
	replace l_absinc = 1500 if hinctnt ==6  
	replace l_absinc = 2000 if hinctnt ==7  
	replace l_absinc = 2500 if hinctnt ==8  
	replace l_absinc = 3000 if hinctnt ==9  
	replace l_absinc = 5000 if hinctnt ==10  
	replace l_absinc = 7500 if hinctnt ==11   
	replace l_absinc = 10000 if hinctnt ==12
	
	gen u_absinc = 150 if hinctnt == 1
	replace u_absinc = 300 if hinctnt == 2
	replace u_absinc = 500 if hinctnt == 3
	replace u_absinc = 1000 if hinctnt == 4
	replace u_absinc = 1500 if hinctnt == 5
	replace u_absinc = 2000 if hinctnt == 6
	replace u_absinc = 2500 if hinctnt == 7
	replace u_absinc = 3000 if hinctnt == 8
	replace u_absinc = 5000 if hinctnt == 9
	replace u_absinc = 7500 if hinctnt == 10
	replace u_absinc = 10000 if hinctnt == 11
	replace u_absinc = . if hinctnt == 12
	
	// Impute upper/lower Limits of open intervalls
	replace l_absinc = .9*u_absinc if hinctnt==1
	replace u_absinc = 1.1*l_absinc if hinctnt==12
	
	// Convert to PPP
	sort cntry
	merge cntry using `agg', nokeep
	assert _merge==3
	drop _merge
	
	replace l_absinc = l_absinc  * toppp
	replace u_absinc = u_absinc  * toppp
	
	// Calculate "Absolute Position"
	gen abspos = (l_absinc + (u_absinc - l_absinc)/2)/1000
	label variable abspos "Absolute income"
	

	// "Relative Position"
	// -------------------

	capture which _gxtile
	if _rc == 111 ssc install egenmore, replace
	egen relpos4 = xtile(abspos), by(cntry) p(25(25)75)
	label variable relpos "Relative income position"

	// Assert that all quartiles are in the data:
	by cntry relpos, sort: gen control = _n==1 if relpos < .
	by cntry: replace control = sum(control)
	by cntry: replace control = control[_N]
	capture by cntry: assert control = 4
	if _rc {
		di as text "Insufficient Data for following countries:"
		tab cntry relpos if control < 4
	}
	drop control

	// "Mean Absolute Position"
	// ------------------------
	
	by cntry, sort: gen mabspos = sum(abspos)/sum(abspos!=.)
	by cntry, sort: replace mabspos = mabspos[_N]
	label variable mabspos "Mean absolute income"


	// Control Variables
	// -----------------

	gen age = 2004 - yrbrn
	label variable age "Age"

	gen men = gndr==1 if gndr < .
	label variable men "Men"

	label variable hhmmb "Household size"


	// Weights
	// -------
	// (I upweight countries with low nobs)
	
	by cntry, sort: gen N = _N
	sum N, meanonly
	gen nweight = r(max)/N
	sum nweight, meanonly
	replace nweight = nweight-r(mean)+1
	gen weight = nweight * dweight
	

	// Center Metric Variables, Interactionterms 
	// -----------------------------------------
	
	capture which center
	if _rc == 111 ssc install center, replace
	center mabspos abspos relpos hhmmb age
	
	gen ia_absmean = c_abspos * c_mabspos
	label variable ia_absmean "Absolute $\times$ Soc."
	
	gen ia_relmean = c_relpos * c_mabspos
	label variable ia_absmean "Relative $\times$ Soc."

	// Life-Satisfaction Models
	// ------------------------
	
	mark touse
	markout touse stflife c_abspos c_mabspos c_relpos ia_absmean ia_relmean c_hhmmb men c_age

	reg stflife men c_age c_hhmmb c_abspos [pweight=weight] if touse
	estimates store euA

	reg stflife men c_age c_hhmmb c_abspos c_mabspos [pweight=weight] if touse
	estimates store container1
	
	reg stflife men c_age c_hhmmb c_relpos [pweight=weight] if touse
	estimates store container2
	
	reg stflife men c_age c_hhmmb c_mabspos [pweight=weight] if touse
	estimates store euB

	reg stflife men c_age c_hhmmb c_abspos c_mabspos ia_absmean [pweight=weight] if touse
	estimates store ia_absmean
	
	reg stflife men c_age c_hhmmb c_relpos c_mabspos ia_relmean [pweight=weight] if touse
	estimates store ia_relmean
	
	estout euA container1 euB ia_absmean ///
	using aness04_2_stflife.tex ///
	, replace style(tex) label ///
	  prehead(\begin{tabular}{lrrrr} \hline  2004 & \multicolumn{4}{c}{Model type} \\ ) ///
	  posthead(\hline) ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  mlabel("(1)" "(2)" "(3)" "(4)" ) /// 
	collabels(, none) ///
	  cells(b(fmt(%3.2f) star)) ///
	  drop(men c_age c_hhmmb) ///
	  stats(r2 N bic, labels("\$r^2\$" "\$n\$" "BIC") fmt(%9.2f %9.0f %9.0f)) ///
	  varlabels(_cons Constant) ///
	  starlevels(* 0.05 ** 0.01 *** 0.001) 
	  
	  estimates clear

	// Humbled with Health
	// -------------------
   	lab var hlthhmp ""

	drop touse
	mark touse
	markout touse hlthhmp men c_age c_hhmmb c_abspos c_mabspos c_relpos ia_absmean ia_relmean c_hhmmb men c_age
	
	ologit hlthhmp men c_age c_hhmmb c_abspos [pweight=weight] if touse
	estimates store euA
	
	ologit hlthhmp men c_age c_hhmmb c_abspos c_mabspos [pweight=weight] if touse
	estimates store container1
	
	ologit hlthhmp men c_age c_hhmmb c_relpos [pweight=weight] if touse
	estimates store container2
	
	ologit hlthhmp men c_age c_hhmmb c_mabspos [pweight=weight] if touse
	estimates store euB
	
	ologit hlthhmp men c_age c_hhmmb c_abspos c_mabspos ia_absmean [pweight=weight] if touse
	estimates store ia_absmean
	
	ologit hlthhmp men c_age c_hhmmb c_relpos c_mabspos ia_relmean [pweight=weight] if touse
	estimates store ia_relmean
	
	estout euA container1 euB ia_absmean ///
	using aness04_2_hlthhmp.tex ///
	, replace style(tex) label ///
	  prehead(\begin{tabular}{lrrrr} \hline  2002 & \multicolumn{4}{c}{Model type} \\ ) ///
	  posthead(\hline) ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  mlabel("(1)" "(2)" "(3)" "(4)" ) /// 
	collabels(, none) ///
	  cells(b(fmt(%3.2f) star)) ///
	  drop(men c_age c_hhmmb cut1:_cons cut2:_cons) ///
	  stats(r2_p N bic, labels("\$r^2_p\$" "\$n\$" "BIC") fmt(%9.2f %9.0f %9.0f)) ///
	  varlabels(_cons Constant) ///
	  starlevels(* 0.05 ** 0.01 *** 0.001) 

	estimates clear

	
	// Political interest
	// ------------------

	sum polintr, meanonly
	replace polintr = r(max) + 1 - polintr
	
	drop touse
	mark touse
	markout touse polintr men c_age c_hhmmb c_abspos c_mabspos c_relpos ia_absmean ia_relmean c_hhmmb men c_age
	ologit polintr men c_age c_hhmmb c_abspos [pweight=weight] if touse
	estimates store euA
	
	ologit polintr men c_age c_hhmmb c_abspos c_mabspos [pweight=weight] if touse
	estimates store container1
	
	ologit polintr men c_age c_hhmmb c_relpos [pweight=weight] if touse
	estimates store container2
	
	ologit polintr men c_age c_hhmmb c_mabspos [pweight=weight] if touse
	estimates store euB
	
	ologit polintr men c_age c_hhmmb c_abspos c_mabspos ia_absmean [pweight=weight] if touse
	estimates store ia_absmean
	
	ologit polintr men c_age c_hhmmb c_relpos c_mabspos ia_relmean [pweight=weight] if touse
	estimates store ia_relmean
	
	estout euA container1 euB ia_absmean ///
	using aness04_2_polintr.tex ///
	, replace style(tex) label ///
	  prehead(\begin{tabular}{lrrrr} \hline  2002 & \multicolumn{4}{c}{Model type} \\ ) ///
	  posthead(\hline) ///
	  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
	  mlabel("(1)" "(2)" "(3)" "(4)" ) /// 
	collabels(, none) ///
	  cells(b(fmt(%3.2f) star)) ///
	  drop(men c_age c_hhmmb cut1:_cons cut2:_cons cut3:_cons) ///
	  stats(r2_p N bic, labels("\$r^2_p\$" "\$n\$" "BIC") fmt(%9.2f %9.0f %9.0f)) ///
	  varlabels(_cons Constant) ///
	  starlevels(* 0.05 ** 0.01 *** 0.001) 

	estimates clear


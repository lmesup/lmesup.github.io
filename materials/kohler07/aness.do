* Analysis of the ESS 2004
version 9.2
	clear	
	set more off
	set memory 90m
	
	//  Comparative price levels
	//  of final consumption by private households including indirect taxes (EU-25 = 100)
	// ----------------------------------------------------------------------------------
	
	// Jahr: 2002 u. 2004 Source: http://epp.eurostat.ec.europa.eu
	// Datum des Auszugs: Fri, 28 Aug 06 14:09:40
	// Letzte Aktualisierung: Wed Jun 14 17:06:32 MEST 2006 
	
	input	str2	cntry	pni2002	pni2004	
	be	102.3	104.2	
	cz	54.7	55	
	dk	135.6	137	
	de	107.5	106.6	
	ee	62.1	62.9	
	gr	82.2	85.1	
	es	85	87.4	
	fr	106.1	108	
	ie	122.4	123.1	
	it	97.9	102.7	
	cy	90.9	93.3	
	lv	57.6	56.4	
	lt	53	54.9	
	lu	102.9	105.3	
	hu	56.9	61.9	
	mt	73.7	74.9	
	nl	104	106.6	
	at	105.2	103.6	
	pl	59.5	52.4	
	pt	74.6	87.3	
	si	73.2	77.9	
	sk	44.6	50.5	
	fi	124.4	122.9	
	se	121.1	121.1	
	gb	114.3	103.8	
	bg	39.5	42.6	
	hr	55.3	.
	ro	41.2	43.2	
	tr	51.9	57.8	
	is	133.9	132.4	
	no	149.4	135.8	
	ch	147	141.6	
end	
							
	replace cntry = upper(cntry)

	reshape long pni, i(cntry) j(svyyear)
	gen toppp=100/pni
	
	
	label variable toppp "Conversion Factor"
	label variable pni "Preisniveauindex"
	order cntry pni toppp
	sort cntry
	
	tempfile agg
	save `agg'
	
	
	// Compile ESS 2004 and ESS 2002
	// -----------------------------

	local varlist ///
	  cntry region* lnghoma  hhmmb hinctnt stflife hlthhmp polintr ///
	  gndr yrbrn marital iscoco iscocop emplrel 

	use `varlist' using $ess/ess2004, clear
	gen svyyear = 2004

	append using $ess/ess2002, keep(`varlist')
	replace svyyear = 2002 if svyyear == .

	by cntry svyyear, sort: gen nofyears = _n==1
	by cntry: replace nofyear = sum(nofyears)
	by cntry: keep if nofyears[_N] == 2

	tab cntry nofyear
	
	drop if cntry=="EE" | cntry=="IL" | cntry=="IS" | cntry=="IT" ///
	  | cntry=="SK" | cntry=="UA" 


	drop if cntry=="NO" | cntry=="CH" | cntry=="HR"
		
	// Absolute Position
	// -----------------
	// (Source: Europ. Social Survey, Round 1 + 2 Showcards)
	
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
	label variable abspos "Absolute Income"
	
	// "Mean Absolute Position"
	// ------------------------

	egen region = concat(region*)
	xtile kohort4 = yrbrn, n(4)
	by svyyear cntry, sort: gen mabspos = sum(abspos)/sum(abspos!=.)
	by svyyear cntry, sort: replace mabspos = mabspos[_N]
	label variable mabspos "Mean income"

	// "Relative Position"
	// -------------------

	gen relpos = abspos-mabspos
	label variable relpos "Relative income"


	// Control Variables
	// -----------------

	gen age = svyyear - yrbrn
	label variable age "Age"
	gen age2 = age^2
	label variable age2 "Age squared"
	
	gen men = gndr==1 if gndr < .
	label variable men "Men"

	label variable hhmmb "Household size"

	// Dependent Variables
	// -------------------

	gen healthy:yesno  = hlthhmp != 1 if hlthhmp < .
	gen polint:yesno = polintr <= 2 if polintr < . 

	// Random-effects 
	// ---------------
	encode cntry, gen(i)
	iis i
	
	// Listwise deletion
	// -----------------

	mark touse
	markout touse abspos mabspos relpos hhmmb men age


	// Describe  Income
	// -----------------

	graph box abspos if touse ///
	  , over(cntry, sort(1)) by(svyyear, rows(2) note("Outliers excluded")) ///
 	  nooutsides /// 
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) note("") ///
	  scheme(s1mono)
	graph export aness_abspos.eps, replace

	by svyyear, sort: corr abspos relpos mabspos if touse
	  

	// Center Metric Variables, Interactionterms 
	// -----------------------------------------
	
	capture which center
	if _rc == 111 ssc install center, replace
	by svyyear, sort: center abspos relpos mabspos hhmmb age age2 if touse

	gen ia_absmean = c_abspos * c_mabspos if touse
	label variable ia_absmean "$\text{Abs.} \times \text{Abs.}_\text{Ref. Group}$"

	by svyyear cntry, sort: gen stflifebar = sum(stflife)/sum(stflife<.)
	by svyyear cntry: replace stflifebar = stflifebar[_N]

	
	// Loop for Models
	// ---------------

	capture which eret2
	if _rc == 111 ssc install eret2, replace
	capture which estout
	if _rc == 111 ssc install estout, replace


	foreach depvar of varlist stflife {
	
		forv i = 2002(2)2004 {

			reg `depvar' men c_age c_age2 c_hhmmb c_abspos c_relpos   ///
			  if touse & svyyear == `i'
			eret2 scalar r2_o = e(r2)
			estimates store mod1`i'
			
			xtreg `depvar' men c_age c_age2 c_hhmmb c_abspos c_relpos ///
			  if touse & svyyear == `i'
			estimates store mod2`i'
			
			xtreg `depvar' men c_age c_age2 c_hhmmb c_abspos c_relpos ia_absmean ///
			  if touse & svyyear == `i'
			estimates store mod3`i'

			local estoutlist "`estoutlist' mod1`i' mod2`i' mod3`i'"

		}

		estout `estoutlist'  ///
		  using aness_`depvar'.tex ///
		  , replace style(tex) label ///
		  equations(Coefs=1) ///		
		  prehead(\begin{tabular}{|l|rrr|rrr|} \hline  ///
		  & \multicolumn{3}{c}{2002} & \multicolumn{3}{|c|}{2004} \\ ) ///
		  posthead(\hline) ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel("(OLS)" "(RE-1)" "(RE-2)" "(OLS)" "(RE-1)" "(RE-2)"  ) /// 
		collabels(, none) ///
		  cells(b(fmt(%3.2f)) t(fmt(%3.1f) par)) ///
		  stats(r2_o N rho, labels("\$r^2\$" "\$n\$" "\$\rho\$") fmt(%9.2f %9.0f %9.2f)) ///
		  varlabels(_cons Constant) 
	
	estimates clear
	}
		

	local estoutlist " "
	foreach depvar of varlist healthy polint {
	
		forv i = 2002(2)2004 {

			logit `depvar' men c_age  c_hhmmb c_abspos c_relpos   ///
			  if touse & svyyear == `i'
			estimates store mod1`i'
			
			xtlogit `depvar' men c_age c_hhmmb c_abspos c_relpos ///
			  if touse & svyyear == `i'
			eret2 scalar r2_p =  ((e(chi2)/(-2) + e(ll))- e(ll))/(e(chi2)/(-2) + e(ll))
			estimates store mod2`i'
			
			xtlogit `depvar' men c_age  c_hhmmb c_abspos c_relpos ia_absmean ///
			  if touse & svyyear == `i'
			eret2 scalar r2_p =  ((e(chi2)/(-2) + e(ll))- e(ll))/(e(chi2)/(-2) + e(ll))
			estimates store mod3`i'

			local estoutlist "`estoutlist' mod1`i' mod2`i' mod3`i'"

		}

		estout `estoutlist'  ///
		  using aness_`depvar'.tex ///
		  , replace style(tex) label ///
		  equations(Coefs=1) ///		
		  prehead(\begin{tabular}{|l|rrr|rrr|} \hline  ///
		  & \multicolumn{3}{c}{2002} & \multicolumn{3}{|c|}{2004} \\ ) ///
		  posthead(\hline) ///
		  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
		  mlabel("(Logit)" "(RE-1)" "(RE-2)" "(Logit)" "(RE-1)" "(RE-2)"  ) /// 
		collabels(, none) ///
		  cells(b(fmt(%3.2f)) t(fmt(%3.1f) par)) ///
		  drop(lnsig2u:_cons) ///
		  stats(r2_p bic N rho, labels("\$r^2_p\$" "BIC" "\$n\$" "\$\rho\$") fmt(%9.2f %9.0f %9.0f %9.2f)) ///
		  varlabels(_cons Constant) ///
	
	estimates clear
	}

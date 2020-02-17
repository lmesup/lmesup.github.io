 //  Validation of Comparison-Variables by Coutry
 //  Creator: kohler@wz-berlin.de
 
 
 //  INTRO 
 //  -----
 
version 9.0
	clear
	set more off
	set memory 32m
	set scheme s1mono
	

	// Produce the Dataset
	// -------------------
	
	capture use data01, 
	if _rc==601 {
		do crdata01
		use data01
	}
	
	//  Collapse/Reshape
	local i 1
	foreach var of varlist compeco compemp compqual {
		ren  `var' comp`i++'
	}
	
	collapse (mean) comp1 comp2 comp3 eu [aw=weight], by(ctrname)
	reshape long comp, i(ctrname) j(item)
	label value item item
	label define item 1 "Economy" 2 "Employment" 3 "Quality of life"
	
	// Merge aggregates
	preserve
	use agg, clear
	sort ctrname
	tempfile agg
	save `agg'
	restore 
	sort ctrname
	merge ctrname using `agg'
	assert _merge == 3
	drop _merge

	// Merge some other aggregats from EQLS
	preserve
	use s_cntry emplrat2 longune2 lifeexp1 terteduc using $dublin/eqls_4, clear
	by s_cntry, sort: keep if _n==1

	// Construct Merge-Variable
	gen iso3166_2 = ""
	replace iso3166_2 = "AT" if s_cntry == 1			
	replace iso3166_2 = "BE" if s_cntry == 2			
	replace iso3166_2 = "BG" if s_cntry == 3			
	replace iso3166_2 = "CY" if s_cntry == 4			
	replace iso3166_2 = "CZ" if s_cntry == 5			
	replace iso3166_2 = "DK" if s_cntry == 6			
	replace iso3166_2 = "EE" if s_cntry == 7			
	replace iso3166_2 = "FI" if s_cntry == 8			
	replace iso3166_2 = "FR" if s_cntry == 9			
	replace iso3166_2 = "DE" if s_cntry == 10			
	replace iso3166_2 = "GB" if s_cntry == 11			
	replace iso3166_2 = "GR" if s_cntry == 12 			
	replace iso3166_2 = "HU" if s_cntry == 13			
	replace iso3166_2 = "IE" if s_cntry == 14			
	replace iso3166_2 = "IT" if s_cntry == 15			
	replace iso3166_2 = "LV" if s_cntry == 16			
	replace iso3166_2 = "LT" if s_cntry == 17			
	replace iso3166_2 = "LU" if s_cntry == 18			
	replace iso3166_2 = "MT" if s_cntry == 19 			
	replace iso3166_2 = "NL" if s_cntry == 20			
	replace iso3166_2 = "PL" if s_cntry == 21			
	replace iso3166_2 = "RO" if s_cntry == 22			
	replace iso3166_2 = "SK" if s_cntry == 23			
	replace iso3166_2 = "SI" if s_cntry == 24			
	replace iso3166_2 = "ES" if s_cntry == 25			
	replace iso3166_2 = "SE" if s_cntry == 26			
	replace iso3166_2 = "TR" if s_cntry == 27			
	replace iso3166_2 = "PT" if s_cntry == 28

	/// and merge
	sort iso3166_2
	tempfile iso
	save `iso'
	restore
	sort iso3166_2
	merge iso3166_2 using `iso', nokeep
	assert _merge == 3
	drop _merge

	
	// Recode some Vars for Nice Graphs
	separate comp, by(eu)

	replace gdp2003 = gdp2003/1000
	label var gdp2003 "GDP p. Cap. (in PPS)"

	label var growth "Growth rates"

	reg growth gdp2003
	predict e_growth, resid
	label var e_growth "Part. growth rates"

	lab var emplrat2 "Employment rate"
	lab var unemp03 "Unemployment rate"
	lab var longune2 "Long term unempl. rate"

	lab var hdi2002 "Human Development Index"

	replace soccap01 = soccap01/100
	lab var soccap01 "Per capita social expenditures (in PPS)"

	reg soccap01 gdp2003
	predict e_social, resid
	label var e_social "Part. social expenditures"

	label var terteduc "Perc. attained tertiary educ."
	label var lifeexp1 "Life expectancy"


	// Legend-Graph
	// ------------

	sc comp1 comp2 gdp2003, ///
	  ms(O..) mlcolor(black..) mfcolor(white black) ///
	  legend(order(2 "NMS" 1 "OMS")) ///
	  nodraw name(leg, replace) yscale(off) xscale(off) 

	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
	_gm_edit .leg.ystretch.set fixed

	// Econmy-Graphs
	// --------------

	// Loop over Indeps and draw the graphs
	foreach var of varlist gdp2003 growth e_growth {

		local droplux = cond("`var'"=="gdp2003",`"& ctrname ~= "Luxembourg""',"")
		
		// Store Regression-Results to label the Graphs
		reg comp `var' if item == 1 `droplux' 
		local r = round(cond(_b[`var']>0,sqrt(e(r2)),sqrt(e(r2))*(-1)),.01)

		sum `var'
		local mean = r(mean)
		
		graph twoway                                                                  ///
		  || sc comp1 comp2 `var', ms(O..) mlcolor(black..) mfcolor(white black) mlab(iso3166_2 iso3166_2)    ///
		  || lfit comp `var' if 1 `droplux', lcolor(black)                            ///
		  || if item == 1                                                             ///
		  || , legend(off)                                                            ///
		  title("r = `r'", pos(12) bexpand box)                           ///
		  xline(`mean', lcolor(gs10)) yline(0, lcolor(gs10)) ylab(-2(1)2) ///
		  name(`var', replace) nodraw
	}
	graph combine gdp2003 growth e_growth, ///
	  ycommon rows(1) nodraw name(data, replace) 

	graph combine data leg, cols(1) ysize(3) iscale(*1.5) ///
	  title("Figure 3: Cross-check between reality and perceivements") ///
	  subtitle("Economic situation") ///
	  note("Own calculations. Do_file: anvalid_2.do") 

	graph export anvalid_2_economy.eps, replace


	// Employment-Graphs
	// -----------------

	// Loop over Indeps and draw the graphs
	foreach var of varlist emplrat2 unemp03 gdp2003 {

		local droplux = cond("`var'"=="gdp2003",`"& ctrname ~= "Luxembourg""',"")
		
		// Store Regression-Results to label the Graphs
		reg comp `var' if item == 2 `droplux' 
		local r = round(cond(_b[`var']>0,sqrt(e(r2)),sqrt(e(r2))*(-1)),.01)

		sum `var'
		local mean = r(mean)
		
		graph twoway                                                                  ///
		  || sc comp1 comp2 `var', ms(O..) mlcolor(black..) mfcolor(white black)  mlab(iso3166_2 iso3166_2)    ///
		  || lfit comp `var' if 1 `droplux', lcolor(black)                            ///
		  || if item == 2                                                             ///
		  || , legend(off)                                                            ///
		  title("r = `r'", pos(12) bexpand box)                           ///
		  xline(`mean', lcolor(gs10)) yline(0, lcolor(gs10)) ylab(-2(1)2) ///
		  name(`var', replace) nodraw
	}
	graph combine emplrat2 unemp03 gdp2003, ///
	  ycommon rows(1)  nodraw name(data, replace)

	graph combine data leg, cols(1) ysize(3) iscale(*1.5) ///
	  title("Figure 4: Cross-check between reality and perceivements") ///
	  subtitle("Employment situation") ///
	  note("Own calculations. Do_file: anvalid_2.do") 
    graph export anvalid_2_employment.eps, replace

   
	// Quality of Life-Graphs
	// -----------------------

	// Loop over Indeps and draw the graphs
	foreach var of varlist gdp2003 lifeexp1 terteduc {
		
		local droplux = cond("`var'"=="gdp2003",`"& !inlist(ctrname,"Luxembourg")"',"")
		
		// Store Regression-Results to label the Graphs
		reg comp `var' if item == 3 `droplux' 
		local r = round(cond(_b[`var']>0,sqrt(e(r2)),sqrt(e(r2))*(-1)),.01)

		sum `var'
		local mean = r(mean)
		
		graph twoway                                                                  ///
		  || sc comp1 comp2 `var', ms(O..) mlcolor(black..) mfcolor(white black)  mlab(iso3166_2 iso3166_2)    ///
		  || lfit comp `var' if 1 `droplux', lcolor(black)                            ///
		  || if item == 3                                                             ///
		  || , legend(off)                                                            ///
		  title("r = `r'", pos(12) bexpand box)                           ///
		  xline(`mean', lcolor(gs10)) yline(0, lcolor(gs10)) ylab(-2(1)2) ///
		  name(`var', replace) nodraw
	}
	graph combine gdp2003 lifeexp1 terteduc, ///
	  ycommon rows(1) nodraw name(data, replace)

	graph combine data leg, cols(1) ysize(3) iscale(*1.5) ///
	  title("Figure 5: Cross-check between reality and perceivements") ///
	  subtitle("Overall quality of life") ///
	  note("Own calculations. Do_file: anvalid_2.do") 
	graph export anvalid_2_qol.eps, replace

	exit
	

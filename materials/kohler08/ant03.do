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
	
	use s_cntry emplfem2 seatswom using $dublin/eqls_4, clear
	by s_cntry, sort: keep if _n==1

	input 
	29 62 16.2   // Note 1
	end
	
*	gen patr = (emplfem2+seatswom)/2
*	lab var patr "Female Employment-Rate + Perc. of Women in Parliament"

	sort s_cntry
	input str2 iso3166_2 str3 iso3166_3
	AT AUT
	BE BEL
	BG BGR
	CY CYP
	CZ CZE
	DK DNK
	EE EST
	FI FIN
	FR FRA
	DE DEU
	GB GBR
	GR GRC
	HU HUN
	IE IRL
	IT ITA
	LV LVA
	LT LTU
	LU LUX
	MT MLT
	NL NLD
	PL POL
	RO ROU
	SK SVK
	SI SVN
	ES ESP
	SE SWE
	TR TUR
	PT PRT
	HR HRV 

	keep iso3166* emplfem2
	sort iso3166_2
	tempfile emplfem2
	save `emplfem2'

	use svydat01 if eu & weich == 1 // Note 1
	replace city = 0 if city == .

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

	// I use only Kish/Last-Birthday or Missing  here. No Quota, No Register
	keep if persel==2 | persel == 4 

	// t-values by survey iso3166_2 city
	collapse (mean) womenp=women hdi (count) N=women, by(survey iso3166_2 city) 
	gen woment = (womenp - .5)/sqrt(.5^2/N)
	sort survey iso3166_2

	// Get the context
	sort iso3166_2
	merge iso3166_2 using `emplfem2', nokeep
	assert _merge == 3
	drop _merge

	collapse (mean) womenp woment emplfem2 hdi [aw=N], by(iso3166_2 city)
	reshape wide womenp woment, i(iso3166_2) j(city)

	gen labelpoint = cond(abs(woment0)>abs(woment1),woment0,woment1)
	gen labelpos = cond(labelpoint>0,12,6)  
	
	tw  ///
	  (rspike woment0 woment1 emplfem2, lcolor(black))        ///
	  (sc woment0 woment1 emplfem2, ms(O O) mlc(black .. )    ///
	      mfc(black white))                                                ///
	  (sc labelpoint emplfem2, ms(i) mlab(iso3166_2) mlabvpos(labelpos))       ///
	  (lowess woment0 emplfem2 if iso3166_2 != "TR" , lc(black) lp(solid))       ///
	  (lowess woment1 emplfem2 if iso3166_2 != "TR" , lc(black) lp(dash))       ///
	  , yline(0) legend(order(2 "Rural" 3 "Urban" 5 "" 6 "") rowgap(*.01) )                        ///
	  ytitle("Sample Quality") ylabel(, grid)                              ///
	  xtitle("Female Employment-Rate 2002")

	graph export ant03.eps, replace

	replace woment0 = abs(woment0)
	replace woment1 = abs(woment1)
	replace labelpoint=cond(abs(.92-woment0)>abs(.92-woment1),woment0,woment1)
	replace labelpos=cond(labelpoint<1,6,12)
	
	tw  ///
	  (rspike woment0 woment1 hdi, lcolor(black))        ///
	  (sc woment0 woment1 hdi, ms(O O) mlc(black .. )    ///
	      mfc(black white))                                                ///
	  (sc labelpoint hdi, ms(i) mlab(iso3166_2) mlabvpos(labelpos))       ///
	  (lowess woment0 hdi if iso3166_2 != "TR" , lc(black) lp(solid))       ///
	  (lowess woment1 hdi if iso3166_2 != "TR" , lc(black) lp(dash))       ///
	  , legend(order(2 "Rural" 3 "Urban" 5 "" 6 "") rowgap(*.01) )                        ///
	  ytitle("Absolute Value of Sample Quality") ylabel(, grid)                              ///
	  xtitle("Human Development Index")

	graph export ant03_hdi.eps, replace

	
	
	exit

	Notes
	-----

	(1) No information on city in EB 62.1, France and ISSP 2002, Ireland


	


	
	


* Matched Case-Control Analysis 
* kohler@wz-berlin.de

* History
	
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
	
	gen patr = emplfem2+seatswom
	lab var patr "Female Employment-Rate + Perc. of Women in Parliament"

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

	keep iso3166* patr
	sort iso3166_2
	tempfile patr
	save `patr'

	use svydat01 if eu & weich == 1 // Note 1
	replace city = 0 if city == .

	ren women women1
	gen women2 = women1==0

	gen hh = _n
	reshape long women, i(hh) j(person)

	gen selected = person==1

	levelsof iso3166_2, local(K)
	local i 1
	foreach k of local K {
		gen womeniso`i' = women * (iso3166_2=="`k'")
		lab var womeniso`i++' `"`k'"'
	}

	clogit selected women if !city, group(hh)
	local overall_rural = _b[women]

	clogit selected women if city, group(hh)
	local overall_city = _b[women]

	clogit selected womeniso* if !city, group(hh)
	matrix b = e(b)'
	svmat b, names(bwomeniso_rural)

	clogit selected womeniso* if city, group(hh)
	matrix b = e(b)'
	svmat b, names(bwomeniso_city)

	keep bwomeniso*
	keep in 1/29
	merge using `patr'

	gen labelpoint = cond(abs(bwomeniso_rural1)>abs(bwomeniso_city1), ///
	  bwomeniso_rural1,bwomeniso_city1)
	gen labelpos = cond(labelpoint > 0,12,6)  
	
	tw  ///
	  (rspike bwomeniso_rural1 bwomeniso_city1 patr, lcolor(black))        ///
	  (sc bwomeniso_rural1 bwomeniso_city1 patr, ms(O O) mlc(black .. )    ///
	      mfc(black white))                                                ///
	  (sc labelpoint patr, ms(i) mlab(iso3166_2) mlabvpos(labelpos))       ///
	  , yline(0) legend(order(2 "Rural" 3 "Urban"))                        ///
	  ytitle(Coef. Conditonal Logit) ylabel(, grid)


	exit



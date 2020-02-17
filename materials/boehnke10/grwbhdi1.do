* Well-Being (Life-Satisfaction/Happiness) by HDI
* EQLS 2003 and ISSP 2002

version 9
	set more off
	set scheme s1mono
	tempfile iso
	
	// EQLS 2003
	// ---------
	
	use q31 s_cntry wcountry using $dublin/eqls_4, clear
	lab def s_cntry 11 "United Kingdom", modify
	egen iso3166_2 = iso3166(s_cntry)

	collapse (mean) lsat=q31  [aweight=wcountry], by(iso3166_2)

	tempfile eqls
	save `eqls'
	
	// ISSP 2002
	// ---------

	use v3 v52 v361 using $issp/issp02, clear
	replace v3 = 2 if v3 == 3
	replace v3 = 4 if v3 == 5
	sum v52, meanonly
	replace v52 = r(max)+1 - v52

	label define v3 ///
	1	"AU" /// 
	2	"DE" /// 
	3	"DE" /// 
	4	"GB" /// 
	5	"GB" /// 
	6	"US" /// 
	7	"AT" /// 
	8	"HU" /// 
	9	"IT" /// 
	10	"IE" /// 
	11	"NL" /// 
	12	"NO" /// 
	13	"SE" /// 
	14	"CZ" /// 
	15	"SI" /// 
	16	"PL" /// 
	17	"BG" /// 
	18	"RU" /// 
	19	"NZ" /// 
	20	"CA" /// 
	21	"PH" /// 
	22	"IL" /// 
	24	"JP" /// 
	25	"ES" /// 
	26	"LV" /// 
	27	"SK" /// 
	28	"FR" /// 
	29	"CY" /// 
	30	"PT" /// 
	31	"CL" /// 
	32	"DK" /// 
	33	"CH" /// 
    34  "BE" /// I use Flandria as Belgium 
    35  "BR" /// 
    37  "FI" /// 
    38  "MX" /// 
    39  "TW" , modify  
	decode v3, gen(iso3166_2)
	
	collapse (mean) happy = v52  [aweight=v361], by(iso3166_2)

	tempfile issp
	save `issp'

	// Merge both  Files
	// -----------------

	use `eqls'
	merge iso3166_2 using `issp', sort
	drop _merge
	compress
	
	// Long country Names, Country Group
	// ---------------------------------
	
	egen ctrname = iso3166(iso3166_2), o(codes) 

	gen eu = 3
	foreach k in AT BE DE DK ES FI FR GB GR IE IT LU NL PT SE {
		replace eu = 1 if iso3166_2 == "`k'" 
	}
	foreach k in BG CZ EE HU LT LV PL RO RU SI SK {
		replace eu = 2 if iso3166_2 == "`k'" 
	}
	label value eu eu
	label define eu 1 "OMS" 2 "FC" 3 "Other"
	
	// Merge HDI
	// ---------
	
	sort ctrname
	merge ctrname using ~/data/agg/gdp_world_2002, nokeep
	*assert _merge ~= 1
	drop _merge

	// The Graph
	// ---------

	ren lsat wellbeing1
	ren happy wellbeing2
	keep wellbeing* iso3166_2 eu hdi
	reshape long wellbeing, i(iso3166_2) j(operat)
	lab val operat operat
	lab def operat 1 "EQLS '03 (Life Satisfaction)" 2 "ISSP '02 (Happiness)"

	separate wellbeing, by(eu)

	gen mlab = 12
	replace mlab =  3 if iso3166_2 == "DK" & operat == 1
	replace mlab =  9 if iso3166_2 == "SE" & operat == 1
	replace mlab = 12 if iso3166_2 == "FI" & operat == 1
	replace mlab =  9 if iso3166_2 == "NL" & operat == 1
	replace mlab =  6 if iso3166_2 == "BE" & operat == 1
	replace mlab = 12 if iso3166_2 == "IE" & operat == 1
	replace mlab =  6 if iso3166_2 == "GB" & operat == 1
	replace mlab =  3 if iso3166_2 == "LU" & operat == 1
	replace mlab =  1 if iso3166_2 == "AT" & operat == 1
	replace mlab =  6 if iso3166_2 == "FR" & operat == 1
	replace mlab =  6 if iso3166_2 == "DE" & operat == 1
	replace mlab =  6 if iso3166_2 == "GR" & operat == 1
	replace mlab =  6 if iso3166_2 == "PT" & operat == 1
	replace mlab =  2 if iso3166_2 == "MT" & operat == 1
	replace mlab =  1 if iso3166_2 == "IT" & operat == 1
	replace mlab =  6 if iso3166_2 == "EE" & operat == 1
	replace mlab =  1 if iso3166_2 == "HU" & operat == 1
	replace mlab =  6 if iso3166_2 == "LT" & operat == 1
	replace mlab =  5 if iso3166_2 == "BG" & operat == 1

	replace mlab =  6 if iso3166_2 == "SE" & operat == 2
	replace mlab =  6 if iso3166_2 == "BE" & operat == 2
	replace mlab =  6 if iso3166_2 == "IE" & operat == 2
	replace mlab =  6 if iso3166_2 == "FI" & operat == 2
	replace mlab =  6 if iso3166_2 == "FR" & operat == 2
	replace mlab =  6 if iso3166_2 == "DE" & operat == 2
	replace mlab =  6 if iso3166_2 == "ES" & operat == 2
	replace mlab =  7 if iso3166_2 == "PT" & operat == 2
	replace mlab =  5 if iso3166_2 == "SI" & operat == 2
	replace mlab =  6 if iso3166_2 == "CZ" & operat == 2
	replace mlab =  6 if iso3166_2 == "PL" & operat == 2
	replace mlab =  3 if iso3166_2 == "HU" & operat == 2
	replace mlab =  6 if iso3166_2 == "SK" & operat == 2
	replace mlab =  6 if iso3166_2 == "LV" & operat == 2
	replace mlab =  3 if iso3166_2 == "RU" & operat == 2
	replace mlab =  3 if iso3166_2 == "BG" & operat == 2
	replace mlab =  3 if iso3166_2 == "PH" & operat == 2
	replace mlab =  2 if iso3166_2 == "MX" & operat == 2
	replace mlab =  9 if iso3166_2 == "US" & operat == 2
	replace mlab = 11 if iso3166_2 == "JP" & operat == 2
	replace mlab =  6 if iso3166_2 == "GB" & operat == 2

	
	tw                                                               ///
	  || scatter wellbeing hdi, mlab(iso3166_2) ms(i) mlabvpos(mlab) ///
	  || scatter wellbeing1 wellbeing2 wellbeing3 hdi, ms(O..) mlc(black..)   ///
	    mfc(black gs10 white)                                  ///
	  || , by(operat, yrescale rows(2) legend(pos(2)) note("") )     ///
	  legend(order(2 "OMS" 3 "FC" 4 "Other") cols(1))                ///
	  scheme(s1mono) xtitle(Rank of Human Development Index 2002)    ///
	  ylab(#5) xlab(0(20)100) ytitle(Well-being)
	graph export grwbhdi1.eps, replace preview(on)
	

	exit
	

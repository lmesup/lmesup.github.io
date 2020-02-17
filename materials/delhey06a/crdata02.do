	// Include Differences Own LC - Own-Countries LC
	// ---------------------------------------------
	// (based on crdata01.do) 

version 8.2
	set more off
	
	// Data to generate
	local mylist "origID cntry year pweight cntry"  // svy
	local mylist "`mylist' lsat dsat men age hinceq edu emp occ mar"  // depvar controls
	local mylist "`mylist' within1 within2 neighbours friends own_o within1_o within2_o neighbours_o friends_o "   // Reference Groups within Country
	local mylist "`mylist' hungary_i poland_i france_i spain_i italy_i switzerland_i netherlands_i otherpart_i germany_i sweden_i turkey_i"
	local mylist "`mylist' hungary_g poland_g france_g spain_g italy_g switzerland_g netherlands_g otherpart_g germany_g sweden_g turkey_g"
	local mylist "`mylist' hungary_o poland_o france_o spain_o italy_o switzerland_o netherlands_o otherpart_o germany_o sweden_o turkey_o"

	// Hungary/Turkey
	// --------------
	
	use $em/em, clear
	keep if inlist(country,3,8)
	drop if v8 < 18
	
	// ID
	ren id origID

	// SVY
	gen pweight = 1
	replace pweight = v5-v6 if v5-v6 > 0 & v5-v6 < .
	note pweight: Hungary,Turkey: Persons in HH over 18

	// Country-String
	gen cntry = "Hungary" if country == 3
	replace cntry = "Turkey" if country == 8
	drop country

	// depvars
	gen lsat = v56
	gen dsat = v61
		
	// Controls
	gen men:yesno = v7 == 1 if v7 < .
	replace age = v8
	gen hinceq = v24eqppp  // Note: 21 obs with 0 set to missing!

	gen edu:edu = 1 if v33 == 0  // pre-primary
	replace edu = 2 if v33 == 1  // primary
	replace edu = 3 if v33 == 2 | v33 == 3 // lower secondary
	replace edu = 4 if v33 >= 4 & v33 <= 7 // secondary
	replace edu = 5 if v33 >= 8 & v33 <= 10 // tertiary
	replace edu = 6 if edu >= . // other and missing

	gen emp:emp = 1 if v35 == 1 // full-time
	replace emp = 2 if v35 == 2 // part-time
	replace emp = 3 if (v42 == 1 | v42 == 2 | v42 == 3 ) & emp >= . // retired
	replace emp = 4 if v42 == 6 & emp >= . // unemployed
	replace emp = 5 if v42 == 7 & emp >= . // homemaker
	replace emp = 6 if emp >= . // other/missing

	gen occ:occ = 1 if v36 == 1 | v44 == 1 // unskilled/semi skilled worker
   replace occ = 2 if v36 == 2 | v44 == 2 // skilled worker/foreman
	replace occ = 3 if v36 == 3 | v44 == 3 // lower white collar
	replace occ = 4 if v36 == 4 | v44 == 4 // upper white collar
  	replace occ = 5 if v36 == 5 | v44 == 5 // self employed
	replace occ = 6 if occ >= . // others/missing

	gen mar:mar = 1 if v18 == 1 // single
	replace mar = 2 if v18 == 2 // married, liv. toghether
	replace mar = 3 if v18 == 4 // widowed
	replace mar = 4 if v18 == 3 | v18 == 5 // divorced/separated
	replace mar = 5 if mar >= . // other/missing
	
	// Differences to Reference Groups: Other Countries
   lab var v62j "turkey"
	foreach k in a b c d e f g h i j {
		local lab: var lab v62`k'
		gen `lab'_g = v62a - v62`k' if cntry == "Hungary"
		replace `lab'_g = v62j - v62`k' if cntry == "Turkey"
		gen `lab'_i = v75a - v62`k'
		gen `lab'_o = v62`k'
	}
	gen otherpart_g = .
	gen otherpart_i = .
	gen otherpart_o = .

	// Within Individual Reference Group
	gen within1 = v75a - v75c
	gen within2 = v75a - v75d

	// Differences to Reference Groups: Neigbours
	gen neighbours = v75a - v75e

	// Differences to Reference Groups: Friends
	gen friends = v75a - v75f

	ren v75a own_o
	ren v75c within1_o
	ren v75d within2_o
	ren v75e neighbours_o
	ren v75f friends_o
	
	// Store
	keep `mylist' 
	compress
	tempfile hutur
	save `hutur'


	// Germany
	// --------

	use $wfs/wfs
	keep if f031s ==1

	// ID
	ren idnum origID

	// year
	gen year = 1998
	
	// SVY
	gen pweight = gewpreg 
	note pweight: Germany: HHgr*Country*BIK*Ost/West
	
	// Country
	gen cntry = "Germany (W)" if splits==1
	replace cntry = "Germany (E)" if splits==2

	// depvar
	gen lsat = f118o
	gen dsat = f109o

	// Controls
	gen men:yesno = f032s == 1 if f032s < .
	ren alter age

	ren f087o hhinc 
	ren f041o hhgr
	gen hinceq = hhinc/sqrt(hhgr)

	gen edu:edu = 1 if f033s == 1  // pre-primary
	replace edu = 2 if f033s == 2  // primary
	replace edu = 3 if f033s == 3  // lower secondary
	replace edu = 4 if f033s == 4 | f033s == 5 // secondary
	replace edu = 5 if f034s == 8 | f034s == 9 // tertiary
	replace edu = 6 if edu >= . // other and missing

	gen emp:emp = 1 if f056s == 1 // full-time
	replace emp = 2 if f056s == 2 // part-time
	replace emp = 3 if (f058s == 1 | f058s == 2 | f058s == 3 ) & emp >= . // retired
	replace emp = 4 if (f058s == 7 | f058s == 8 | f058s == 9 ) & emp >= . // unemployed
	replace emp = 5 if (f058s == 10 | f058s == 11 ) & emp >= . // homemaker
	replace emp = 6 if emp >= . // other/missing

	gen occ:occ = 1 if inlist(f070o,10,11,43)  // unskilled/semi skilled worker
   replace occ = 2 if inlist(f070o,12,13,14,20,44,45) // skilled worker/foreman
	replace occ = 3 if inlist(f070o,20,21,30,31,46) // lower white collar
	replace occ = 4 if inlist(f070o,23,24,32,33) // upper white collar
  	replace occ = 5 if inlist(f070o,40,41,42,50,51,52,53,54,55,56) // self employed
	replace occ = 1 if inlist(f066o,10,11,43)  // unskilled/semi skilled worker
   replace occ = 2 if inlist(f066o,12,13,14,20,44,45) // skilled worker/foreman
	replace occ = 3 if inlist(f066o,20,21,30,31,46) // lower white collar
	replace occ = 4 if inlist(f066o,23,24,32,33) // upper white collar
  	replace occ = 5 if inlist(f066o,40,41,42,50,51,52,53,54,55,56) // self employed
	replace occ = 6 if occ >= . // others/missing

	gen mar:mar = 1 if f046s == 1 // single
	replace mar = 2 if f046s == 2 // married, liv. toghether
	replace mar = 3 if f046s == 4 // widowed
	replace mar = 4 if f046s == 3 | f046s == 5 // divorced/separated
	replace mar = 5 if mar >= . // other/missing

	// Differences to Reference Groups: Other Countries
	gen hungary_g = cond(splits==1,f123ao,f122bo) - cond(splits==1,f123jo,f122jo)
	gen poland_g = cond(splits==1,f123ao,f122bo) - cond(splits==1,f123co,f122co)
	gen france_g = cond(splits==1,f123ao,f122bo) - cond(splits==1,f123do,f122do)
	gen italy_g = cond(splits==1,f123ao,f122bo) - cond(splits==1,f123eo,f122eo)
	gen spain_g = cond(splits==1,f123ao,f122bo) - cond(splits==1,f123fo,f122fo)
	gen netherlands_g = cond(splits==1,f123ao,f122bo) - cond(splits==1,f123go,f122go)
	gen switzerland_g = cond(splits==1,f123ao,f122bo) - cond(splits==1,f123ho,f122ho)
	gen otherpart_g = cond(splits==1,f123ao,f122ao) - cond(splits==1,f123bo,f122bo)
	gen germany_g = cond(splits==1,f123ao,f122ao) - cond(splits==1,f123ao,f122ao)
	gen sweden_g = .
	gen turkey_g = .
	gen hungary_i = f121ao - cond(splits==1,f123jo,f122jo)
	gen poland_i = f121ao - cond(splits==1,f123co,f122co)
	gen france_i = f121ao - cond(splits==1,f123do,f122do)
	gen italy_i = f121ao - cond(splits==1,f123eo,f122eo)
	gen spain_i = f121ao - cond(splits==1,f123fo,f122fo)
	gen netherlands_i = f121ao - cond(splits==1,f123go,f122go)
	gen switzerland_i = f121ao - cond(splits==1,f123ho,f122ho)
	gen otherpart_i = f121ao - cond(splits==1,f123bo,f122bo)
	gen germany_i = f121ao - cond(splits==1,f123ao,f122ao)
	gen sweden_i = .
	gen turkey_i = .
	gen hungary_o = cond(splits==1,f123jo,f122jo)
	gen poland_o =  cond(splits==1,f123co,f122co)
	gen france_o =  cond(splits==1,f123do,f122do)
	gen italy_o =   cond(splits==1,f123eo,f122eo)
	gen spain_o =   cond(splits==1,f123fo,f122fo)
	gen netherlands_o =  cond(splits==1,f123go,f122go)
	gen switzerland_o =  cond(splits==1,f123ho,f122ho)
	gen otherpart_o = cond(splits==1,f123bo,f122bo)
	gen germany_o =   cond(splits==1,f123ao,f122ao)
	gen sweden_o = .
	gen turkey_o = .

	
	// Within Individual Reference Group
	gen within1 = f121ao - f121co
	gen within2 = f121ao - f121do

	// Differences to Reference Groups: Neigbours
	gen neighbours = f121ao - f121eo

	// Differences to Reference Groups: Friends
	gen friends = f121ao - f121fo

	ren f121ao own_o
	ren f121co within1_o
	ren f121do within2_o
	ren f121eo neighbours_o
	ren f121fo friends_o

	
	// Append
	// ------

	keep `mylist' 
	compress
	append using `hutur'
	gen int ID = _n
	order ID `mylist'

   // Labels
	// ------

	lab var ID "Unique case ID"
	lab var origID "Case ID of original data"
	lab var cntry "Country"
	lab var year "Year of Fieldwork"
	lab var pweight "Sampling weights (See notes)"
	lab var lsat "Life Satisfaction"
	lab var dsat "Satisfaction with Democratic Institutions"
	lab var men "Men y/n"
	lab var age "Age"
	lab var hinceq "Houshold Equivalence Income"
	lab var edu "Education"
	note hinceq: for Hungary, Turkey in PPS
	note hinceq: for Germany in Euro (hhinc/sqrt(hhgr))
	lab var emp "Employment Status"
	lab var occ "Occupational Status"
	lab var mar "Marital Status"
	lab var within1 "LC: Own - Five years ago"
	lab var within2 "LC: Own - entitled to"
	lab var neighbours "LC: Own - Neighbours "
	lab var friends "LC: Own - Friends"
	lab var own_o "own (orig)"
	lab var neighbours_o "Neighbours (orig)"
	lab var within1_o "LC: Five years ago"
	lab var within2_o "LC: entitled to"
	lab var friends_o "Friends (orig)"
	lab var hungary_g "LC: Own Country - Hungary"
	lab var poland_g "LC: Own Country - Poland "
	lab var france_g "LC: Own Country - France "
	lab var italy_g "LC: Own Country - Italy"
	lab var spain_g "LC: Own Country - Spain"
	lab var netherlands_g "LC: Own Country - Netherland"
	lab var switzerland_g "LC: Own Country - Switzerland"
	lab var otherpart_g "LC: Own Country - Otherpar"
	lab var germany_g "LC: Own Country - Germany"
	lab var sweden_g "LC: Own Country - Sweden"
	lab var hungary_i "LC: Own - Hungary"
	lab var poland_i "LC: Own - Poland "
	lab var france_i "LC: Own - France "
	lab var italy_i "LC: Own - Italy"
	lab var spain_i "LC: Own - Spain"
	lab var netherlands_i "LC: Own - Netherland"
	lab var switzerland_i "LC: Own - Switzerland"
	lab var otherpart_i "LC: Own - Otherpar"
	lab var germany_i "LC: Own - Germany"
	lab var sweden_i "LC: Own - Sweden"
	lab var turkey_i "LC: Own - Turkey (Turkish data Only)"
	lab var hungary_o "Hungary (orig) "
	lab var poland_o "Poland  (orig) "
	lab var france_o "France  (orig) "
	lab var italy_o "Italy (orig) "
	lab var spain_o "Spain (orig) "
	lab var netherlands_o "Netherland (orig) "
	lab var switzerland_o "Switzerland (orig) "
	lab var otherpart_o "Otherpar (orig) "
	lab var germany_o "Germany (orig) "
	lab var sweden_o "Sweden (orig) "
	
	lab def yesno 0 "no" 1 "yes"
  	lab def edu 1 "pre-primary" 2 "primary" 3 "lower secondary" 4 "secondary" ///
	   5 "tertiary" 6 "other/missing"
	lab def emp 	1 "full-time" 	2 "part-time" 	3 "retired" ///
	  4 "unemployed" 	5 "homemaker" 	6 "other/missing" 
	lab def occ 1 "unskilled/semi skilled worker"  2 "skilled worker/foreman" ///
	  3 "lower white collar" 4 "upper white collar" 5 "self employed" ///
	  6 "others/missing"
	lab def mar 1 "single" 2 "married, liv. toghether" 3 "widowed" ///
	  4 "divorced/separated" 5 "other/missing" 

	save data02, replace
	label data "EuroModule + WfS 98 for Delhey/Kohler"
	exit
	
	

// Creates a harmonised dataset of federal election studies 1962-2008
// ------------------------------------------------------------------
// thewes@wzb.eu


version 10.0
clear
set memory 90m



// Input
//-------
infile str5 zanr year str244 titel str244 state str244 eldatestr str244 lastnestr ///
str244 nextnestr str244 researcher str244 data str244 method using ltwsvy.raw, clear

replace zanr = "00" + zanr if length(zanr)==2
replace zanr = "0" + zanr if length(zanr)==3


// Fallzahlen
//------------
tempfile n
postfile mypost str5 zanr n using `n'
foreach zanr in 0062 0063 0327 0472 0514 0562 0563 0702 0703 0871 1245 1246 ///
1247 1248 1249 1250 1251 1370 1371 1372 1465 1466 1468 1519 1551 ///
1552 1651 1652 1653 1654 1655 1656 1697 1766 1932 1933 1934 1963  ///
2115 2116 2117 2118 2119 2301 2302 2311 2312 2313 2314 2315 2316 2317 ///
2318 2319 2398 2506 2507 2508 2509 2510 2511 2512 2513 2581 2582 2583 ///
2649 2913 2914 2915 3030 3031 3032 3120 3167 3168 3169 3381 3382 ///
3435 3436 3862 3863 3864 3865 3866 3867 3894 3895 3896 3897 3898 3953 ///
3955 3990 3991 3992 3993 3994 19661 19662 19663 19664 19665 19666 ///
4394 4396 4399 4401 4403 4405 4511 4745 4864 4866 4868 {
	capture describe using $ltw/za`zanr'
	post mypost ("`zanr'") (r(N))
}
postclose mypost
merge zanr using `n', sort
assert _merge==3
drop _merge


// Datumsumrechnung
//------------------

gen eldate = date(eldatestr, "DMY")
gen lastne = date(lastnestr, "DMY")
gen nextne = date(nextnestr, "DMY")

format %tddd_Mon_YY eldate
format %tddd_Mon_YY lastne
format %tddd_Mon_YY nextne

lab var eldate "Election date"
lab var year "Year"
lab var lastne "last national Election date"
lab var nextne "next national Election date"


drop lastnestr
drop nextnestr

// Area-Rekodierung
//------------------

gen area = "BE" if trim(state) == "Berlin"
replace area = "BB" if trim(state) == "Brandenburg"
replace area = "BW" if trim(state) == "Baden-Württemberg"
replace area = "BY" if trim(state) == "Bayern"
replace area = "HB" if trim(state) == "Bremen"
replace area = "HE" if trim(state) == "Hessen"
replace area = "HH" if trim(state) == "Hamburg"
replace area = "MV" if trim(state) == "Mecklenburg-Vorpommern"
replace area = "NI" if trim(state) == "Niedersachsen"
replace area = "NW" if trim(state) == "NRW"
replace area = "RP" if trim(state) == "Rheinland-Pfalz"
replace area = "SH" if trim(state) == "Schleswig-Holstein"
replace area = "SL" if trim(state) == "Saarland"
replace area = "SN" if trim(state) == "Sachsen"
replace area = "ST" if trim(state) == "Sachsen-Anhalt"
replace area = "TH" if trim(state) == "Thüringen"
lab var area "Area"



// Unit-ID
//---------
gen unitid = area + " (" + string(eldate,"%tdMon_YY") + ")"
lab var unitid "Unit of analysis"


// VarLabels
//-----------
lab var zanr "ZA-Nr."
lab var titel "Titel"
lab var state "State"
lab var researcher "Primary Researcher"
lab var data "Data Collecting"
lab var method "Data Collecting Method"
lab var n "N"

order unitid area eldatestr eldate  ///
  zanr state titel ///
  lastne nextne ///
  researcher data method

compress
tempfile meta
save `meta', replace


// 1962 Za-Nr 0062 "Kölner Wahlstudie 1962"
// ----------------------------------------

// Election date was 08 Jul 1962

use $ltw/za0062, clear

gen str8 zanr = "0062"
lab var zanr "Zentralarchiv study number"

gen intstart = "1Jun1962"
gen intend = "7Jul1962"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = v719 == 1 if !mi(v719)
replace voter = . if v719 == 2
lab var voter "Voter y/n"

gen polint = 5 - v518 if v518 <= 5
lab var polint "Politicial interest"

gen party:party = 1 if v721 == 1
replace party = 2 if v721 == 2
replace party = 3 if inlist(v721,3,4,5,6)
lab var party "Electoral behaviour"

gen men:yesno = v1129 == 1 if inlist(v1129,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v1057,1,2)
replace agegroup = 2 if inlist(v1057,3,4,5,6,7,8,9)
replace agegroup = 3 if inlist(v1057,10,11,12)
label variable agegroup "Agegroup"

gen emp:emp = 1 if v1085 == 1					// emp vom HHV
//replace emp = 2 if v1085 ==
replace emp = 3 if v1085 == 2
replace emp = 4 if v1085 == 4
replace emp = 5 if v1085 == 3
replace emp = 6 if v1085 == .
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v1086,11,12,13,14,15)	
replace occ = 2 if inlist(v1086,5,6,7,8,9,10)
replace occ = 3 if inlist(v1086,1,2,3,4)
replace occ = 4 if v1086 == 16
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v1102,1,2,3)
replace edu = 2 if inlist(v1102,4,5,6,7)
replace edu = 3 if inlist(v1102,8,9,10)
lab var edu "Education"

gen mar:mar = 1 if v1054 == 2
replace mar = 2 if inlist(v1054,3,4)
replace mar = 3 if v1054 == 1
label variable mar "Marital status"

xtile hhinc =  v1089, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v1106 == 2
replace denom = 2 if v1106 == 1
replace denom = 3 if inlist(v1106,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 62nw
save `62nw'

// 1962, ZA-Nr. 0063 "Landtagswahl in Hessen 1962"
// -----------------------------------------------

// Election Date was on 11 Nov 1962

use $ltw/za0063, clear

gen str8 zanr = "0063"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jun1962"
gen intend = "30Jun1962"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = v221 == 1 if !mi(v221)
replace voter = . if v221 == 2
lab var voter "Voter y/n"

gen party:party = 1 if v223==1
replace party = 2 if v223==2
replace party = 3 if inlist(v223,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v400 == 1 if inlist(v400,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v377,1,2)
replace agegroup = 2 if inlist(v377,3,4,5,6,7,8,9)
replace agegroup = 3 if inlist(v377,10,11,12)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inrange(v395,1,8)
replace emp = 2 if v395 == 12
replace emp = 3 if v395 == 11
replace emp = 4 if v395 == 9
replace emp = 5 if v395 == 10
//replace emp = 6 if v390 ==
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v395,1,2,8)
replace occ = 2 if inlist(v395,3,4)
replace occ = 3 if inlist(v395,5,6,7)
replace occ = 1 if occ == . & inlist(v391,11,12,13,14,15)
replace occ = 2 if occ == . & inlist(v391,5,6,7,8,9,10)
replace occ = 3 if occ == . & inlist(v391,1,2,3,4)
replace occ = 4 if occ == . | v395 == 9
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v397,1,2,3,4)
replace edu = 2 if inlist(v397,5,6,7)
replace edu = 3 if inlist(v397,8,9,10)
lab var edu "Education"

gen mar:mar = 1 if v374==2
replace mar = 2 if inlist(v374,3,4)
replace mar = 3 if v374==1
label variable mar "Marital status"

xtile hhinc = v394, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v399 == 2
replace denom = 2 if v399 == 1
replace denom = 3 if inlist(v399,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 62he
save `62he'
local flist "`flist' `62he'"


// 1968 0327 "Landtagswahl in Baden-Württemberg 1968"
// --------------------------------------------------

// Election Date was on 28 Apr 1968

use $ltw/za0327, clear

gen str8 zanr = "0327"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1968"
gen intend = "30Jun1968"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = v7 == 1 if v7<=2
lab var voter "Voter y/n"

gen polint = 5 - v661 if v661 <= 5
lab var polint "Politicial interest"

gen party:party = 1 if v8==2
replace party = 2 if v8==1
replace party = 3 if inlist(v8,3,4,5,6)
lab var party "Electoral behaviour"

gen men:yesno = v906 == 1 if inlist(v906,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v870,1,2)
replace agegroup = 2 if inlist(v870,3,4,5,6,7,8,9)
replace agegroup = 3 if v870 == 10
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v871,1,2,3)
replace emp = 2 if v873 == 19
//replace emp = 3 if v871 ==
replace emp = 4 if v873 == 18
replace emp = 5 if v871 == 4
//replace emp = 6 if v871 ==
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v874,1,2,3,14,15,16,17)
replace occ = 2 if inlist(v874,4,5,6,7,8,9)
replace occ = 3 if inlist(v874,10,11,12,13)
replace occ = 1 if occ == . & inlist(v873,1,2,3,14,15,16,17)
replace occ = 2 if occ == . & inlist(v873,4,5,6,7,8,9)
replace occ = 3 if occ == . & inlist(v873,10,11,12,13)
replace occ = 4 if occ == . | inlist(v874,18,19)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v872,1,2)
replace edu = 2 if v872 == 3
replace edu = 3 if inlist(v872,4,5,6)
lab var edu "Education"

gen mar:mar = 1 if v868==2
replace mar = 2 if inlist(v868,3,4,5)
replace mar = 3 if v868==1
label variable mar "Marital status"

xtile hhinc = v884, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v887 == 2
replace denom = 2 if v887 == 1
replace denom = 3 if inlist(v887,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 68bw
save `68bw'
local flist "`flist' `68bw'"



// 1966 0472 "Landtagswahl in Bayern 1966"
// ---------------------------------------

// Election Date was on 20 Nov 1966

use $ltw/za0472, clear

gen str8 zanr = "0472"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1966"
gen intend = "30Apr1966"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = v56 == 1 if !mi(v56)
replace voter = . if v56 == 2
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v93,1,2,3)
replace lr = 2 if inlist(v93,4,5)
replace lr = 3 if inlist(v93,6)
replace lr = 4 if inlist(v93,7,8)
replace lr = 5 if inlist(v93,9,10,11)
replace lr = 6 if v93==99
lab var lr "Left right self-placement"

gen party:party = 1 if v84==1
replace party = 2 if v84==2
replace party = 3 if inlist(v84,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v238 == 1 if inlist(v238,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v214,1,2)
replace agegroup = 2 if inlist(v214,3,4,5,6,7,8,9)
replace agegroup = 3 if v214 == 10
label variable agegroup "Agegroup"

gen emp:emp = 1 if v212 == 3
replace emp = 2 if v211 == 10
replace emp = 3 if v212 == 2
replace emp = 4 if v212 == 4
replace emp = 5 if v212 == 1
replace emp = 6 if v212 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v213,1,2,3,14,15,16,17)
replace occ = 2 if inlist(v213,4,5,6,7,8,9)
replace occ = 3 if inlist(v213,10,11,12,13)
replace occ = 1 if occ == . & inlist(v211,1,2,8)
replace occ = 2 if occ == . & inlist(v211,3,4)
replace occ = 3 if occ == . & inlist(v211,5,6,7)
replace occ = 4 if occ == . | inlist(v213,9,10)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v215,1,2,3,4)
replace edu = 2 if inlist(v215,5,6,7)
replace edu = 3 if inlist(v215,8,9,10)
lab var edu "Education"

gen mar:mar = 1 if v209==2
replace mar = 2 if inlist(v209,3,4)
replace mar = 3 if v209==1
label variable mar "Marital status"

xtile hhinc = v216, nq(3)     //HHV
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v237 == 2
replace denom = 2 if v237 == 1
replace denom = 3 if inlist(v237,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 66by
save `66by'
local flist "`flist' `66by'"


// 1970 ZA-Nr. 0514 "Landtagswahl in Hessen 1970"
// ----------------------------------------------

// Election Date was on 08 Nov 1970

use $ltw/za0514, clear

gen str8 zanr = "0514"
lab var zanr "Zentralarchiv study number"

gen intstart = "09Nov1970"
gen intend = "31Jan1971"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = v70 == 1 if v70<=2
lab var voter "Voter y/n"

gen polint = v7 
lab var polint "Politicial interest"

gen lr:lr = 1 if inlist(v206,1,2)
replace lr = 2 if inlist(v206,3,4)
replace lr = 3 if inlist(v206,5,6)
replace lr = 4 if inlist(v206,7,8)
replace lr = 5 if inlist(v206,9,10)
replace lr = 6 if v206 == 99
lab var lr "Left right self-placement"

gen party:party = 1 if v71==2
replace party = 2 if v71==1
replace party = 3 if inlist(v71,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v296 == 1 if inlist(v296,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v297,1,2)
replace agegroup = 2 if inrange(v297,3,5)
replace agegroup = 3 if inrange(v297,6,9)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v252,1,2,3)
replace emp = 2 if v252 == 5
replace emp = 3 if v252 == 6
replace emp = 4 if v252 == 7
replace emp = 5 if v252 == 4
replace emp = 6 if v252 == 9
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v262,1,2,3,4,12,13,14)
replace occ = 2 if inlist(v262,5,6,7,8)
replace occ = 3 if inlist(v262,9,10,11)
replace occ = 1 if occ == . & inlist(v257,1,2,3,4,12,13,14)
replace occ = 2 if occ == . & inlist(v257,5,6,7,8)
replace occ = 3 if occ == . & inlist(v257,9,10,11)
replace occ = 4 if occ == . | v257 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v251,1,2,3,4)
replace edu = 2 if inlist(v251,5,6)
replace edu = 3 if inlist(v251,7,8,9,10)
replace edu = 4 if v251 == 99
lab var edu "Education"

gen mar:mar = 1 if v247==2
replace mar = 2 if inlist(v247,3,4,5)
replace mar = 3 if v247==1
label variable mar "Marital status"

xtile hhinc = v271, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v273 == 2
replace denom = 2 if v273 == 1
replace denom = 3 if inlist(v273,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 70he
save `70he'
local flist "`flist' `70he'"



// 1966 0562 "Landtagswahl in Nordrhein-Westfalen 1966"
// ----------------------------------------------------

// Election Date was on 10 Jul 1966


use $ltw/za0562, clear

gen str8 zanr = "0562"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jun1966"
gen intend = "30Jun1966"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = v124 == 1 if !mi(v124)
replace voter = . if v124 == 2
lab var voter "Voter y/n"

gen polint = 5 - v72
lab var polint "Politicial interest"

gen party:party = 1 if v127==1
replace party = 2 if v127==2
replace party = 3 if inlist(v127,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v267 == 1 if inlist(v267,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v250,1,2)
replace agegroup = 2 if inlist(v250,3,4,5,6,7,8,9)
replace agegroup = 3 if v250 == 10
label variable agegroup "Agegroup"

gen emp:emp = 1 if v247 == 1
replace emp = 2 if v247 == 4
replace emp = 3 if v247 == 3
replace emp = 4 if v246 == 9
replace emp = 5 if v247 == 2
//replace emp = 6 if v247 ==
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v249,1,2,3,14,15,16,17)
replace occ = 2 if inlist(v249,4,5,6,7,8,9)
replace occ = 3 if inlist(v249,10,11,12,13)
replace occ = 1 if occ == . & inlist(v246,1,2,8)
replace occ = 2 if occ == . & inlist(v246,3,4)
replace occ = 3 if occ == . & inlist(v246,5,6,7)
replace occ = 4 if occ == . | v246 == 18 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v251,1,2,3,4)
replace edu = 2 if inlist(v251,5,6)
replace edu = 3 if inlist(v251,7,8,9,10)
replace edu = 4 if v251 == 99
lab var edu "Education"

gen mar:mar = 1 if v240==2
replace mar = 2 if inlist(v240,3,4)
replace mar = 3 if v240==1
label variable mar "Marital status"

xtile hhinc = v252, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v256 == 2
replace denom = 2 if v256 == 1
replace denom = 3 if inlist(v256,3,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 66nw
save `66nw'
local flist "`flist' `66nw'"


// 1967 0563 "Landtagswahl in Rheinland-Pfalz 1967"
// ------------------------------------------------

// Election Date was on 23 Apr 1967

use $ltw/za0563, clear

gen str8 zanr = "0563"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1966"
gen intend = "31Oct1966"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = v84 == 1 if !mi(v84)
replace voter = . if v84 == 2
lab var voter "Voter y/n"

gen party:party = 1 if v89==1
replace party = 2 if v89==2
replace party = 3 if inlist(v89,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v377 == 1 if inlist(v377,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v347,1,2)
replace agegroup = 2 if inlist(v347,3,4,5,6,7,8,9)
replace agegroup = 3 if v347 == 10
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v341,1,2)
replace emp = 2 if v351 == 19
replace emp = 3 if v351 == 20
replace emp = 4 if v351 == 18
replace emp = 5 if v341 == 3
replace emp = 6 if v341 == 9
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v351,1,2,3,14,15,16,17)
replace occ = 2 if inlist(v351,4,5,6,7,8,9)
replace occ = 3 if inlist(v351,10,11,12,13)
replace occ = 4 if v351 == 99
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v348,1,2,3,4)
replace edu = 2 if inlist(v348,5,6,7)
replace edu = 3 if inlist(v348,8,9,10)
replace edu = 4 if v348 == 99
lab var edu "Education"

gen mar:mar = 1 if v340==2
replace mar = 2 if inlist(v340,3,4)
replace mar = 3 if v340==1
label variable mar "Marital status"

xtile hhinc = v352, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v374 == 2
replace denom = 2 if v374 == 1
replace denom = 3 if inlist(v374,3,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 67rp
save `67rp'
local flist "`flist' `67rp'"


// 1970 0702 "Landtagswahl in Nordrhein-Westfalen 1970"
// ----------------------------------------------------

// Election Date was on 14 Jun 1970

use $ltw/za0702, clear

gen str8 zanr = "0702"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1970"
gen intend = "31May1970"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = v284 == 1 if !mi(v284)
replace voter = . if v284 == 2
lab var voter "Voter y/n"

gen polint = 5 - v7 if v7 <= 5	
lab var polint "Politicial interest"

gen party:party = 1 if v286==2 
replace party = 2 if v286==1
replace party = 3 if inlist(v286,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v435 == 1 if inlist(v435,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v371,17,30)		
replace agegroup = 2 if inrange(v371,31,65)
replace agegroup = 3 if inrange(v371,66,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v378,1,2)
replace emp = 2 if inlist(v378,6,7)     
replace emp = 3 if v378 == 4    
replace emp = 4 if v378 == 5      
replace emp = 5 if v378 == 3
replace emp = 6 if v378 == 9
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v398,11,12,13,14,15,16,17)
replace occ = 2 if inlist(v398,4,5,6,7,8,9,10)
replace occ = 3 if inlist(v398,1,2,3)
replace occ = 1 if occ == . & inlist(v379,11,12,13,14,15,16,17)
replace occ = 2 if occ == . & inlist(v379,4,5,6,7,8,9,10)
replace occ = 3 if occ == . & inlist(v379,1,2,3)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if v387 == 2
replace edu = 2 if v387 == 1
replace edu = 3 if v388 == 1
// replace edu = 4 if v348 == 
lab var edu "Education"

gen mar:mar = 1 if v437==2
replace mar = 2 if inlist(v437,3,4,5)
replace mar = 3 if v437==1
label variable mar "Marital status"

xtile hhinc = v421, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v422 == 2
replace denom = 2 if v422 == 1
replace denom = 3 if inlist(v422,3,4,7,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 70nw
save `70nw'
local flist "`flist' `70nw'"


// 1970 0703 "Landtagswahl in Niedersachsen 1970"
// ----------------------------------------------

// Election Date was on 14 Jun 1970

use $ltw/za0703, clear

gen str8 zanr = "0703"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1970"
gen intend = "31May1970"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = v292 == 1 if !mi(v292)
replace voter = . if v292 == 2
lab var voter "Voter y/n"

gen polint = 5 - v7 if v7 <= 5
lab var polint "Politicial interest"

gen party:party = 1 if v294 == 2
replace party = 2 if v294== 1
replace party = 3 if inlist(v294,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v443 == 1 if inlist(v443,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v379,18,29)		
replace agegroup = 2 if inrange(v379,30,64)
replace agegroup = 3 if inrange(v379,65,88)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v386,1,2)
replace emp = 2 if inlist(v386,6,7)
replace emp = 3 if v386 == 4
replace emp = 4 if v386 == 5   
replace emp = 5 if v386 == 3
replace emp = 6 if v386 == 9
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v406,1,2,3,14,15,16,17)
replace occ = 2 if inlist(v406,4,5,6,7,8,9)
replace occ = 3 if inlist(v406,10,11,12,13)
replace occ = 1 if occ == . & inlist(v387,11,12,13,14)
replace occ = 2 if occ == . & inlist(v387,4,5,6,7,8,9,10)
replace occ = 3 if occ == . & inlist(v387,1,2,3,15,16,17)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if v395 == 2
replace edu = 2 if v395 == 1
replace edu = 3 if v396 == 1
// replace edu = 4 if v348 == 
lab var edu "Education"

gen mar:mar = 1 if v445==2
replace mar = 2 if inlist(v445,3,4,5)
replace mar = 3 if v445==1
label variable mar "Marital status"

xtile hhinc = v429, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v430 == 2
replace denom = 2 if v430 == 1
replace denom = 3 if inlist(v430,3,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 70ni
save `70ni'
local flist "`flist' `70ni'"


// 1974 0871 "Landtagswahl in Bayern 1974"
// ---------------------------------------

// Election Date was on 27 Oct 1974

use $ltw/za0871, clear

gen str8 zanr = "0871"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1973"
gen intend = "31Jul1973"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = v17 == 1 if v17<=2
lab var voter "Voter y/n"

gen polint = 5 - v7 if v7 <= 5
lab var polint "Politicial interest"

gen party:party = 1 if v18 == 1
replace party = 2 if v18== 2
replace party = 3 if inlist(v18,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v302 == 1 if inlist(v302,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v304,17,30)		
replace agegroup = 2 if inrange(v304,31,65)
replace agegroup = 3 if inrange(v304,66,98)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v305,1,2)
replace emp = 2 if inlist(v305,5,6)
replace emp = 3 if v305 == 4
replace emp = 4 if v305 == 7   
replace emp = 5 if v305 == 3
replace emp = 6 if v305 == 9
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v319,30,31,32,34,40,41,42)
replace occ = 2 if inlist(v319,10,11,12,20,21,22,23)
replace occ = 3 if inlist(v319,1,2,3)
replace occ = 1 if occ == . & inlist(v308,30,31,32,34,40,41,42,50)
replace occ = 2 if occ == . & inlist(v308,10,11,12,20,21,22,23)
replace occ = 3 if occ == . & inlist(v308,1,2,3)
replace occ = 4 if occ == . | inlist(v319,60,61,62,63,70)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v316,1,2,3,4)	
replace edu = 2 if inlist(v316,5,6,7)
replace edu = 3 if inlist(v316,8,9,10)
replace edu = 4 if v316 == 99
lab var edu "Education"

gen mar:mar = 1 if v303==1
replace mar = 2 if inlist(v303,3,4)
replace mar = 3 if v303==2
label variable mar "Marital status"

xtile hhinc = v332, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v333 == 2
replace denom = 2 if v333 == 1
replace denom = 3 if inlist(v333,3,4,8,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 74by
save `74by'
local flist "`flist' `74by'"


// 1982 1245 "Landtagswahl in Niedersachsen 1982"
// ----------------------------------------------

// Election Date was on 21 Mar 1982

use $ltw/za1245, clear

gen str8 zanr = "1245"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1982"
gen intend = "20Mar1982"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6== 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v83 == 1 if inlist(v83,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,18,29)		
replace agegroup = 2 if inrange(v84,30,64)
replace agegroup = 3 if inrange(v84,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if inlist(v87,8,9,10)
replace emp = 3 if v87 == 6
replace emp = 4 if inlist(v87,5,7)
replace emp = 5 if v87 == 4
replace emp = 6 if v87 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v91,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v91,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v91,13,14,15)	
replace occ = 1 if occ == . & inlist(v88,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v88,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v88,13,14,15)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,2,3)	
replace edu = 2 if inlist(v86,4,5,6)
replace edu = 3 if inlist(v86,7,8,9)
replace edu = 4 if v86 == 99
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,3,4)
replace mar = 3 if v85==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,8)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 82ni
save `82ni'
local flist "`flist' `82ni'"


// 1982 1246 "Landtagswahl in Hessen 1982"
// ---------------------------------------

// Election Date was on 26 Sep 1982

use $ltw/za1246, clear

gen str8 zanr = "1246"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1982"
gen intend = "25Sep1982"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6== 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v83 == 1 if inlist(v83,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,18,29)		
replace agegroup = 2 if inrange(v84,30,64)
replace agegroup = 3 if inrange(v84,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if inlist(v87,8,9,10)
replace emp = 3 if v87 == 6
replace emp = 4 if inlist(v87,5,7)
replace emp = 5 if v87 == 4
replace emp = 6 if v87 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v91,1,2,3,4)
replace occ = 2 if inlist(v91,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v91,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v88,1,2,3,4)
replace occ = 2 if occ == . & inlist(v88,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v88,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,2,3)	
replace edu = 2 if inlist(v86,4,5,6)
replace edu = 3 if inlist(v86,7,8,9)
replace edu = 4 if v86 == 99
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,3,4)
replace mar = 3 if v85==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,8)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 82ni
save `82ni'
local flist "`flist' `82ni'"


// 1982 1247 "Landtagswahl in Bayern 1982" 
// ---------------------------------------

// Election Date was on 10 Oct 1982

use $ltw/za1247, clear

gen str8 zanr = "1247"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1982"
gen intend = "31Oct1982"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6== 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v83 == 1 if inlist(v83,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,18,29)		
replace agegroup = 2 if inrange(v84,30,64)
replace agegroup = 3 if inrange(v84,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if inlist(v87,8,9,10)
replace emp = 3 if v87 == 6
replace emp = 4 if inlist(v87,5,7)
replace emp = 5 if v87 == 4
replace emp = 6 if v87 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v91,1,2,3,4)
replace occ = 2 if inlist(v91,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v91,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v88,1,2,3,4)
replace occ = 2 if occ == . & inlist(v88,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v88,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,2,3)	
replace edu = 2 if inlist(v86,4,5,6)
replace edu = 3 if inlist(v86,7,8,9)
replace edu = 4 if v86 == 99
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,3,4)
replace mar = 3 if v85==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,8)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 82by
save `82by'
local flist "`flist' `82by'"


// 1982 1248 "Bürgerschaftswahl in Hamburg Juni 1982"
// --------------------------------------------------

// Election Date was on 06 Jun 1982

use $ltw/za1248, clear

gen str8 zanr = "1248"
lab var zanr "Zentralarchiv study number"

gen intstart = "07Jun1982"  
gen intend = "30Jun1982" 

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6== 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v83 == 1 if inlist(v83,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,18,29)		
replace agegroup = 2 if inrange(v84,30,64)
replace agegroup = 3 if inrange(v84,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if inlist(v87,8,9,10)
replace emp = 3 if v87 == 6
replace emp = 4 if inlist(v87,5,7)
replace emp = 5 if v87 == 4
replace emp = 6 if v87 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v91,1,2,3,4)
replace occ = 2 if inlist(v91,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v91,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v88,1,2,3,4)
replace occ = 2 if occ == . & inlist(v88,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v88,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,2,3)	
replace edu = 2 if inlist(v86,4,5,6)
replace edu = 3 if inlist(v86,7,8,9)
replace edu = 4 if v86 == 99
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,3,4)
replace mar = 3 if v85==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,8)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 82hha
save `82hha'
local flist "`flist' `82hha'"


// 1982 1249 "Bürgerschaftswahl in Hamburg Dezember 1982"
// ------------------------------------------------------

// Election Date was on 19 Dec 1982

use $ltw/za1249, clear

gen str8 zanr = "1249"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Dec1990" 
gen intend = "31Dec1990"    

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6== 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v83 == 1 if inlist(v83,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,18,29)		
replace agegroup = 2 if inrange(v84,30,64)
replace agegroup = 3 if inrange(v84,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if inlist(v87,8,9,10)
replace emp = 3 if v87 == 6
replace emp = 4 if inlist(v87,5,7)
replace emp = 5 if v87 == 4
replace emp = 6 if v87 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v91,1,2,3,4)
replace occ = 2 if inlist(v91,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v91,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v88,1,2,3,4)
replace occ = 2 if occ == . & inlist(v88,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v88,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,2,3)	
replace edu = 2 if inlist(v86,4,5,6)
replace edu = 3 if inlist(v86,7,8,9)
replace edu = 4 if v86 == 99
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,3,4)
replace mar = 3 if v85==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,8)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 82hhb
save `82hhb'
local flist "`flist' `82hhb'"


// 1967 1250 "Landtagswahl in Rheinland-Pfalz 1983"
// ------------------------------------------------

// Election Date was on 06 Mar 1983

use $ltw/za1250, clear

gen str8 zanr = "1250"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Feb1983"
gen intend = "05Mar1983"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6== 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v83 == 1 if inlist(v83,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,18,29)		
replace agegroup = 2 if inrange(v84,30,64)
replace agegroup = 3 if inrange(v84,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if inlist(v87,8,9,10)
replace emp = 3 if v87 == 6
replace emp = 4 if inlist(v87,5,7)
replace emp = 5 if v87 == 4
replace emp = 6 if v87 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v91,1,2,3,4)
replace occ = 2 if inlist(v91,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v91,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v88,1,2,3,4)
replace occ = 2 if occ == . & inlist(v88,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v88,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,2,3)	
replace edu = 2 if inlist(v86,4,5,6)
replace edu = 3 if inlist(v86,7,8,9)
replace edu = 4 if v86 == 99
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,3,4)
replace mar = 3 if v85==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 83rp
save `83rp'
local flist "`flist' `83rp'"


// 1983 1251 "Landtagswahl in Schleswig-Holstein 1983"
// ---------------------------------------------------

// Election Date was on 13 Mar 1983
// Zeitraum unklar

use $ltw/za1251, clear

gen str8 zanr = "1251"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1983"
gen intend = "31Mar1983"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6== 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v83 == 1 if inlist(v83,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,18,29)		
replace agegroup = 2 if inrange(v84,30,64)
replace agegroup = 3 if inrange(v84,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if inlist(v87,8,9,10)
replace emp = 3 if v87 == 6
replace emp = 4 if inlist(v87,5,7)
replace emp = 5 if v87 == 4
replace emp = 6 if v87 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v91,1,2,3,4)
replace occ = 2 if inlist(v91,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v91,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v88,1,2,3,4)
replace occ = 2 if occ == . & inlist(v88,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v88,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,2,3)	
replace edu = 2 if inlist(v86,4,5,6)
replace edu = 3 if inlist(v86,7,8,9)
replace edu = 4 if v86 == 99
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,3,4)
replace mar = 3 if v85==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,8)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 83sh
save `83sh'
local flist "`flist' `83sh'"


// 1983 1370 "Bürgerschaftswahl in Bremen 1983"
// --------------------------------------------

// Election Date was on 25 Sep 1983

use $ltw/za1370, clear

gen str8 zanr = "1370"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1983"
gen intend = "30Sep1983" 

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v5 == 1
replace party = 2 if v5 == 2
replace party = 3 if inlist(v5,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v50 == 1 if inlist(v50,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v51,18,29)		
replace agegroup = 2 if inrange(v51,30,64)
replace agegroup = 3 if inrange(v51,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v54,1,2,3)
replace emp = 2 if inlist(v54,8,9,10)
replace emp = 3 if v54 == 6
replace emp = 4 if inlist(v54,5,7)
replace emp = 5 if v54 == 4
replace emp = 6 if v54 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v58,1,2,3,4)
replace occ = 2 if inlist(v58,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v58,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v55,1,2,3,4)
replace occ = 2 if occ == . & inlist(v55,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v55,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v53,1,2,3)	
replace edu = 2 if inlist(v53,4,5,6)
replace edu = 3 if inlist(v53,7,8,9)
replace edu = 4 if v53 == 99
lab var edu "Education"

gen mar:mar = 1 if v52==1
replace mar = 2 if inlist(v52,3,4)
replace mar = 3 if v52==2
label variable mar "Marital status"

gen denom:denom = 1 if v60 == 2
replace denom = 2 if v60 == 1
replace denom = 3 if inlist(v60,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 83hb
save `83hb'
local flist "`flist' `83hb'"


// 1983 1371 "Landtagswahl in Hessen 1983"
// ---------------------------------------

// Election Date was on 25 Sep 1983

use $ltw/za1371, clear

gen str8 zanr = "1371"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1983"
gen intend = "30Sep1983"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v5 == 1
replace party = 2 if v5 == 2
replace party = 3 if inlist(v5,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v45 == 1 if inlist(v45,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v46,18,29)		
replace agegroup = 2 if inrange(v46,30,64)
replace agegroup = 3 if inrange(v46,65,94)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v49,1,2,3)
replace emp = 2 if inlist(v49,8,9,10)
replace emp = 3 if v49 == 6
replace emp = 4 if inlist(v49,5,7)
replace emp = 5 if v49 == 4
replace emp = 6 if v49 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v53,1,2,3,4)
replace occ = 2 if inlist(v53,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v53,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v50,1,2,3,4)
replace occ = 2 if occ == . & inlist(v50,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v50,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v48,1,2,3)	
replace edu = 2 if inlist(v48,4,5,6)
replace edu = 3 if inlist(v48,7,8,9)
replace edu = 4 if v48 == 99
lab var edu "Education"

gen mar:mar = 1 if v47==1
replace mar = 2 if inlist(v47,3,4)
replace mar = 3 if v47==2
label variable mar "Marital status"

gen denom:denom = 1 if v55 == 2
replace denom = 2 if v55 == 1
replace denom = 3 if inlist(v55,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 83he
save `83he'
local flist "`flist' `83he'"


// 1984 1372 "Landtagswahl in Baden-Württemberg 1984"
// --------------------------------------------------

// Election Date was on 25 Mar 1984

use $ltw/za1372, clear

gen str8 zanr = "1372"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1984" 
gen intend = "25Mar1984" 

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v5 == 2
replace party = 2 if v5 == 1
replace party = 3 if inlist(v5,3,4,5,6)
lab var party "Electoral behaviour"

gen men:yesno = v45 == 1 if inlist(v45,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v46,18,39)		
replace agegroup = 2 if inrange(v46,30,64)
replace agegroup = 3 if inrange(v46,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v49,1,2,3)
replace emp = 2 if inlist(v49,8,9,10)
replace emp = 3 if v49 == 6
replace emp = 4 if inlist(v49,5,7)
replace emp = 5 if v49 == 4
replace emp = 6 if v49 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v53,1,2,3,4)
replace occ = 2 if inlist(v53,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v53,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v50,1,2,3,4)
replace occ = 2 if occ == . & inlist(v50,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v50,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v48,1,2,3)	
replace edu = 2 if inlist(v48,4,5,6)
replace edu = 3 if inlist(v48,7,8,9)
replace edu = 4 if v48 == 99
lab var edu "Education"

gen mar:mar = 1 if v47==1
replace mar = 2 if inlist(v47,3,4)
replace mar = 3 if v47==2
label variable mar "Marital status"

gen denom:denom = 1 if v55 == 2
replace denom = 2 if v55 == 1
replace denom = 3 if inlist(v55,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 84bw
save `84bw'
local flist "`flist' `84bw'"


// 1985 1465 "Wahl zum Abgeordnetenhaus in Berlin 1985"
// ----------------------------------------------------

// Election Date was on 10 Mar 1985

use $ltw/za1465, clear

gen str8 zanr = "1465"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Feb1985"
gen intend = "09Mar1985"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v7 == 2
replace party = 2 if v7 == 1
replace party = 3 if inlist(v7,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v117 == 1 if inlist(v117,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v118,18,29)		
replace agegroup = 2 if inrange(v118,30,64)
replace agegroup = 3 if inrange(v118,65,92)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v121,1,2,3)
replace emp = 2 if inlist(v121,8,9,10)
replace emp = 3 if v121 == 6
replace emp = 4 if inlist(v121,5,7)
replace emp = 5 if v121 == 4
replace emp = 6 if v121 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v125,1,2,3,4)
replace occ = 2 if inlist(v125,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v125,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v122,1,2,3,4)
replace occ = 2 if occ == . & inlist(v122,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v122,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v120,1,2,3)	
replace edu = 2 if inlist(v120,4,5,6)
replace edu = 3 if inlist(v120,7,8,9)
replace edu = 4 if v120 == 99
lab var edu "Education"

gen mar:mar = 1 if v119==1
replace mar = 2 if inlist(v119,3,4)
replace mar = 3 if v119==2
label variable mar "Marital status"

gen denom:denom = 1 if v127 == 2
replace denom = 2 if v127 == 1
replace denom = 3 if inlist(v127,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 85be
save `85be'
local flist "`flist' `85be'"


// 1985 1466 "Landtagswahl im Saarland 1985"
// -----------------------------------------

// Election Date was on 10 Mar 1985
// Zeitraum unklar

use $ltw/za1466, clear

gen str8 zanr = "1466"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1985"
gen intend = "31Mar1985"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SL"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inlist(v8,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v117 == 1 if inlist(v117,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v118,18,29)		
replace agegroup = 2 if inrange(v118,30,64)
replace agegroup = 3 if inrange(v118,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v121,1,2,3)
replace emp = 2 if inlist(v121,8,9,10)
replace emp = 3 if v121 == 6
replace emp = 4 if inlist(v121,5,7)
replace emp = 5 if v121 == 4
replace emp = 6 if v121 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v125,1,2,3,4)
replace occ = 2 if inlist(v125,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v125,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v122,1,2,3,4)
replace occ = 2 if occ == . & inlist(v122,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v122,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v120,1,2,3)	
replace edu = 2 if inlist(v120,4,5,6)
replace edu = 3 if inlist(v120,7,8,9)
replace edu = 4 if v120 == 99
lab var edu "Education"

gen mar:mar = 1 if v119==1
replace mar = 2 if inlist(v119,3,4)
replace mar = 3 if v119==2
label variable mar "Marital status"

gen denom:denom = 1 if v127 == 2
replace denom = 2 if v127 == 1
replace denom = 3 if inlist(v127,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 85sl
save `85sl'
local flist "`flist' `85sl'"


// 1967 1468 "Landtagswahl in Nordrhein-Westfalen 1985"
// ----------------------------------------------------

// Election Date was on 12 May 1985

use $ltw/za1468, clear

gen str8 zanr = "1468"
lab var zanr "Zentralarchiv study number"

gen intstart = "13May1998"
gen intend = "31May1998"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 2
replace party = 2 if v9 == 1
replace party = 3 if inlist(v9,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v117 == 1 if inlist(v117,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v118,18,29)		
replace agegroup = 2 if inrange(v118,30,64)
replace agegroup = 3 if inrange(v118,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v121,1,2,3)
replace emp = 2 if inlist(v121,8,9,10)
replace emp = 3 if v121 == 6
replace emp = 4 if inlist(v121,5,7)
replace emp = 5 if v121 == 4
replace emp = 6 if v121 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v125,1,2,3,4)
replace occ = 2 if inlist(v125,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v125,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v122,1,2,3,4)
replace occ = 2 if occ == . & inlist(v122,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v122,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v120,1,2,3)	
replace edu = 2 if inlist(v120,4,5,6)
replace edu = 3 if inlist(v120,7,8,9)
replace edu = 4 if v120 == 99
lab var edu "Education"

gen mar:mar = 1 if v119==1
replace mar = 2 if inlist(v119,3,4)
replace mar = 3 if v119==2
label variable mar "Marital status"

gen denom:denom = 1 if v127 == 2
replace denom = 2 if v127 == 1
replace denom = 3 if inlist(v127,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 85nw
save `85nw'
local flist "`flist' `85nw'"


// 1986 1519 "Landtagswahl in Niedersachsen 1986"
// ----------------------------------------------

// Election Date was on 15 Jun 1986

use $ltw/za1519, clear

gen str8 zanr = "1519"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jun1986"
gen intend = "30Jun1986"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v5 == 2
replace party = 2 if v5 == 1
replace party = 3 if inlist(v5,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v58 == 1 if inlist(v58,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v61,18,29)		
replace agegroup = 2 if inrange(v61,30,64)
replace agegroup = 3 if inrange(v61,65,92)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v64,1,2,3)
replace emp = 2 if inlist(v64,8,9,10)
replace emp = 3 if v64 == 6
replace emp = 4 if inlist(v64,5,7)
replace emp = 5 if v64 == 4
replace emp = 6 if v64 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v68,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v68,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v68,13,14,15)	
replace occ = 1 if occ == . & inlist(v65,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v65,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v65,13,14,15)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v63,1,2,3)	
replace edu = 2 if inlist(v63,4,5,6)
replace edu = 3 if inlist(v63,7,8,9)
replace edu = 4 if v63 == 99
lab var edu "Education"

gen mar:mar = 1 if v62==1
replace mar = 2 if inlist(v62,3,4)
replace mar = 3 if v62==2
label variable mar "Marital status"

gen denom:denom = 1 if v70 == 2
replace denom = 2 if v70 == 1
replace denom = 3 if inlist(v70,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 85nw
save `85nw'
local flist "`flist' `85nw'"


// 1986 1551 "Landtagswahl in Bayern 1986"
// ---------------------------------------

// Election Date was on 12 Oct 1986

use $ltw/za1551, clear

gen str8 zanr = "1551"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1986"
gen intend = "30Oct1986"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)
lab var voter "Voter y/n"

gen polint = 3 - v3	
lab var polint "Politicial interest"

gen party:party = 1 if v7 == 2
replace party = 2 if v7 == 1
replace party = 3 if inlist(v7,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v52 == 1 if inlist(v52,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v55,18,29)		
replace agegroup = 2 if inrange(v55,30,64)
replace agegroup = 3 if inrange(v55,65,88)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v58,1,2,3)
replace emp = 2 if inlist(v58,8,9,10)
replace emp = 3 if v58 == 6
replace emp = 4 if inlist(v58,5,7)
replace emp = 5 if v58 == 4
replace emp = 6 if v58 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v62,1,2,3,4)
replace occ = 2 if inlist(v62,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v62,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v59,1,2,3,4)
replace occ = 2 if occ == . & inlist(v59,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v59,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v57,1,2,3)	
replace edu = 2 if inlist(v57,4,5,6)
replace edu = 3 if inlist(v57,7,8,9)
replace edu = 4 if v57 == 99
lab var edu "Education"

gen mar:mar = 1 if v56==1
replace mar = 2 if inlist(v56,3,4)
replace mar = 3 if v56==2
label variable mar "Marital status"

gen denom:denom = 1 if v64 == 2
replace denom = 2 if v64 == 1
replace denom = 3 if inlist(v64,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 86by
save `86by'
local flist "`flist' `86by'"


// 1986 1552 "Bürgerschaftswahl in Hamburg 1986"
// ---------------------------------------------

// Election Date was on 09 Nov 1986

use $ltw/za1552, clear

gen str8 zanr = "1552"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1986"
gen intend = "08Nov1986"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)
lab var voter "Voter y/n"

gen polint = 3 - v3	
lab var polint "Politicial interest"

gen party:party = 1 if v7 == 1
replace party = 2 if v7 == 2
replace party = 3 if inlist(v7,3,4,5,6)
lab var party "Electoral behaviour"

gen men:yesno = v52 == 1 if inlist(v52,1,2)
lab var men "Man y/n"

replace v53 = 1900 + v53 if v53 < 70
replace v53 = 1800 + v53 if v53 > 70 & v53 < 100
gen agegroup:agegroup = 1 if inrange(1986-v53,18,29)
replace agegroup = 2 if inrange(1986-v53,30,64)
replace agegroup = 3 if inrange(1986-v53,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v57,1,2,3)
replace emp = 2 if inlist(v57,8,9,10)
replace emp = 3 if v57 == 6
replace emp = 4 if inlist(v57,5,7)
replace emp = 5 if v57 == 4
replace emp = 6 if v57 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v61,1,2,3,4)
replace occ = 2 if inlist(v61,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v61,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v58,1,2,3,4)
replace occ = 2 if occ == . & inlist(v58,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v58,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v56,1,2,3)	
replace edu = 2 if inlist(v56,4,5,6)
replace edu = 3 if inlist(v56,7,8,9)
replace edu = 4 if v56 == 99
lab var edu "Education"

gen mar:mar = 1 if v55==1
replace mar = 2 if inlist(v55,3,4)
replace mar = 3 if v55==2
label variable mar "Marital status"

gen denom:denom = 1 if v63 == 2
replace denom = 2 if v63 == 1
replace denom = 3 if inlist(v63,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 86hh
save `86hh'
local flist "`flist' `86hh'"


// 1987 1651 "Landtagswahl in Hessen 1987"
// ---------------------------------------

// Election Date was on 05 Apr 1987

use $ltw/za1651, clear

gen str8 zanr = "1651"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1987"
gen intend = "04Apr1987"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = v5 == 1 if v5 != 2
lab var voter "Voter y/n"

gen polint = 3 - v3	
lab var polint "Politicial interest"

gen party:party = 1 if v6 == 1
replace party = 2 if v6 == 2
replace party = 3 if inlist(v6,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v61 == 1 if inlist(v61,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v64,18,29)
replace agegroup = 2 if inrange(v64,30,64)
replace agegroup = 3 if inrange(v64,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v67,1,2,3)
replace emp = 2 if inlist(v67,8,9,10)
replace emp = 3 if v67 == 6
replace emp = 4 if inlist(v67,5,7)
replace emp = 5 if v67 == 4
replace emp = 6 if v67 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v71,1,2,3,4)
replace occ = 2 if inlist(v71,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v71,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v68,1,2,3,4)
replace occ = 2 if occ == . & inlist(v68,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v68,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v66,1,2,3)	
replace edu = 2 if inlist(v66,4,5,6)
replace edu = 3 if inlist(v66,7,8,9)
replace edu = 4 if v66 == 99
lab var edu "Education"

gen mar:mar = 1 if v65==1
replace mar = 2 if inlist(v65,3,4)
replace mar = 3 if v65==2
label variable mar "Marital status"

gen denom:denom = 1 if v73 == 2
replace denom = 2 if v73 == 1
replace denom = 3 if inlist(v73,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 87he
save `87he'
local flist "`flist' `87he'"


// 1987 1652 "Landtagswahl in Rheinland-Pfalz 1987"
// ------------------------------------------------

// Election Date was on 17 May 1987

use $ltw/za1652, clear

gen str8 zanr = "1652"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1987"
gen intend = "31May1987"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)
lab var voter "Voter y/n"

gen polint = 3 - v3	
lab var polint "Politicial interest"

gen party:party = 1 if v7 == 2
replace party = 2 if v7 == 1
replace party = 3 if inlist(v7,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v52 == 1 if inlist(v52,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v55,18,29)
replace agegroup = 2 if inrange(v55,30,64)
replace agegroup = 3 if inrange(v55,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v58,1,2,3)
replace emp = 2 if inlist(v58,8,9,10)
replace emp = 3 if v58 == 6
replace emp = 4 if inlist(v58,5,7)
replace emp = 5 if v58 == 4
replace emp = 6 if v58 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v62,1,2,3,4)
replace occ = 2 if inlist(v62,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v62,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v59,1,2,3,4)
replace occ = 2 if occ == . & inlist(v59,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v59,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v57,1,2,3)	
replace edu = 2 if inlist(v57,4,5,6)
replace edu = 3 if inlist(v57,7,8,9)
replace edu = 4 if v57 == 99
lab var edu "Education"

gen mar:mar = 1 if v56==1
replace mar = 2 if inlist(v56,3,4)
replace mar = 3 if v56==2
label variable mar "Marital status"

gen denom:denom = 1 if v64 == 2
replace denom = 2 if v64 == 1
replace denom = 3 if inlist(v64,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 87rp
save `87rp'
local flist "`flist' `87rp'"


// 1987 1653 "Bürgerschaftswahl in Hamburg 1987" 
// ---------------------------------------------

// Election Date was on 17 May 1987

use $ltw/za1653, clear

gen str8 zanr = "1653"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1987"
gen intend = "31May1987"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)
lab var voter "Voter y/n"

gen polint = 3 - v3	
lab var polint "Politicial interest"

gen party:party = 1 if v7 == 1
replace party = 2 if v7 == 2
replace party = 3 if inlist(v7,3,4,5,6,7)
lab var party "Electoral behaviour"

gen men:yesno = v53 == 1 if inlist(v53,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v56,18,29)
replace agegroup = 2 if inrange(v56,30,64)
replace agegroup = 3 if inrange(v56,65,95)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v59,1,2,3)
replace emp = 2 if inlist(v59,8,9,10)
replace emp = 3 if v59 == 6
replace emp = 4 if inlist(v59,5,7)
replace emp = 5 if v59 == 4
replace emp = 6 if v59 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v63,1,2,3,4)
replace occ = 2 if inlist(v63,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v63,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v60,1,2,3,4)
replace occ = 2 if occ == . & inlist(v60,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v60,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v58,1,2,3)	
replace edu = 2 if inlist(v58,4,5,6)
replace edu = 3 if inlist(v58,7,8,9)
replace edu = 4 if v58 == 99
lab var edu "Education"

gen mar:mar = 1 if v57==1
replace mar = 2 if inlist(v57,3,4)
replace mar = 3 if v57==2
label variable mar "Marital status"

gen denom:denom = 1 if v65 == 2
replace denom = 2 if v65 == 1
replace denom = 3 if inlist(v65,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 87hh
save `87hh'
local flist "`flist' `87hh'"


// 1987 1654 "Landtagswahl in Schleswig-Holstein 1987"
// ---------------------------------------------------

// Election Date was on 13 Sept 1987

use $ltw/za1654, clear

gen str8 zanr = "1654"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1987"
gen intend = "30Sep1987"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)
lab var voter "Voter y/n"

gen polint = 3 - v3	
lab var polint "Politicial interest"

gen party:party = 1 if v7 == 2
replace party = 2 if v7 == 1
replace party = 3 if inlist(v7,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v51 == 1 if inlist(v51,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v54,18,29)
replace agegroup = 2 if inrange(v54,30,64)
replace agegroup = 3 if inrange(v54,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v57,1,2,3)
replace emp = 2 if inlist(v57,8,9,10)
replace emp = 3 if v57 == 6
replace emp = 4 if inlist(v57,5,7)
replace emp = 5 if v57 == 4
replace emp = 6 if v57 == 99
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v61,1,2,3,4)
replace occ = 2 if inlist(v61,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v61,13,14,15,16,17,18)	
replace occ = 1 if occ == . & inlist(v58,1,2,3,4)
replace occ = 2 if occ == . & inlist(v58,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v58,13,14,15,16,17,18)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v56,1,2,3)	
replace edu = 2 if inlist(v56,4,5,6)
replace edu = 3 if inlist(v56,7,8,9)
replace edu = 4 if v56 == 99
lab var edu "Education"

gen mar:mar = 1 if v55==1
replace mar = 2 if inlist(v55,3,4)
replace mar = 3 if v55==2
label variable mar "Marital status"

gen denom:denom = 1 if v63 == 2
replace denom = 2 if v63 == 1
replace denom = 3 if inlist(v63,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 87hh
save `87hh'
local flist "`flist' `87hh'"


// 1987 1655 "Bürgerschaftswahl in Bremen 1987"
// --------------------------------------------

// Election Date was on 13 Sep 1987

use $ltw/za1655, clear

gen str8 zanr = "1655"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1987"
gen intend = "31May1987"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v6,1,2) if inlist(v6,1,2,4)
lab var voter "Voter y/n"

gen polint = 3 - v22	
lab var polint "Politicial interest"

gen party:party = 1 if v7 == 1
replace party = 2 if v7 == 2
replace party = 3 if inlist(v7,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v38 == 1 if inlist(v38,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v41,18,29)
replace agegroup = 2 if inrange(v41,30,64)
replace agegroup = 3 if inrange(v41,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v47,1,2,3)
replace emp = 2 if v47 == 7
replace emp = 3 if v47 == 5
replace emp = 4 if inlist(v47,6,8)
replace emp = 5 if v47 == 4
replace emp = 6 if inlist(v47,9,99)
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v51,23,24)
replace occ = 2 if inlist(v51,12,13,14,15,16,17,18,19,20,21,22)	
replace occ = 3 if inlist(v51,10,11)	
replace occ = 1 if occ == . & inlist(v48,23,24)
replace occ = 2 if occ == . & inlist(v48,12,13,14,15,16,17,18,19,20,21,22)
replace occ = 3 if occ == . & inlist(v48,10,11)
replace occ = 4 if occ == . | v48 == 25
lab var occ "Occupational status"

gen edu:edu = 1 if v43 == 1	
replace edu = 2 if v43 == 2
replace edu = 3 if v43 == 3
replace edu = 4 if inlist(v43,4,9)
lab var edu "Education"

gen mar:mar = 1 if v42==1
replace mar = 2 if inlist(v42,3,4)
replace mar = 3 if v42==2
label variable mar "Marital status"

gen denom:denom = 1 if v53 == 2
replace denom = 2 if v53 == 1
replace denom = 3 if inlist(v53,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 87hb
save `87hb'
local flist "`flist' `87hb'"


// 1988 1656 "Landtagswahl in Baden-Württemberg 1988"
// --------------------------------------------------

// Election Date was on 20 Mar 1988

use $ltw/za1656, clear

gen str8 zanr = "1656"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1988"
gen intend = "31Mar1988"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,3)
lab var voter "Voter y/n"

gen polint = 3 - v27	
lab var polint "Politicial interest"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inlist(v6,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v50 == 1 if inlist(v50,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v51,1,2,3)
replace agegroup = 2 if inlist(v51,4,5,6,7,8)
replace agegroup = 3 if inlist(v51,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v57,1,2,3)
replace emp = 2 if v57 == 7
replace emp = 3 if v57 == 5
replace emp = 4 if inlist(v57,6,8)
replace emp = 5 if v57 == 4
replace emp = 6 if inlist(v57,9,99)
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v61,23,24)
replace occ = 2 if inlist(v61,12,13,14,15,16,17,18,19,20,21,22)	
replace occ = 3 if inlist(v61,10,11)	
replace occ = 1 if occ == . & inlist(v58,23,24)
replace occ = 2 if occ == . & inlist(v58,12,13,14,15,16,17,18,19,20,21,22)
replace occ = 3 if occ == . & inlist(v58,10,11)
replace occ = 4 if occ == . | v58 == 25
lab var occ "Occupational status"

gen edu:edu = 1 if v53 == 1	
replace edu = 2 if v53 == 2
replace edu = 3 if v53 == 3
replace edu = 4 if inlist(v53,4,9)
lab var edu "Education"

gen mar:mar = 1 if v52==1
replace mar = 2 if inlist(v52,3,4)
replace mar = 3 if v52==2
label variable mar "Marital status"

gen denom:denom = 1 if v63 == 2
replace denom = 2 if v63 == 1
replace denom = 3 if inlist(v63,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 88bw
save `88bw'
local flist "`flist' `88bw'"


// 1986 1697 "Landtagswahl in Schleswig-Holstein 1988"
// ---------------------------------------------------

// Election Date was on 08 May 1988

use $ltw/za1697, clear

gen str8 zanr = "1697"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1988" 
gen intend = "31May1988" 

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v7,1,2) if inlist(v7,1,2,3)
lab var voter "Voter y/n"

gen polint = 3 - v4	
lab var polint "Politicial interest"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inlist(v8,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v50 == 1 if inlist(v50,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v51,1,2,3)
replace agegroup = 2 if inlist(v51,4,5,6,7,8)
replace agegroup = 3 if inlist(v51,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v57,1,2,3)
replace emp = 2 if v57 == 7
replace emp = 3 if v57 == 5
replace emp = 4 if inlist(v57,6,8)
replace emp = 5 if v57 == 4
replace emp = 6 if inlist(v57,9,99)
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v65,6,7)
replace occ = 2 if inlist(v65,2,3,4,5)	
replace occ = 3 if v65 == 1
replace occ = 1 if occ == . & inlist(v58,6,7)
replace occ = 2 if occ == . & inlist(v58,2,3,4,5)
replace occ = 3 if occ == . & v58 == 1
replace occ = 4 if occ == . | v58 == 9
lab var occ "Occupational status"

gen edu:edu = 1 if v53 == 1	
replace edu = 2 if v53 == 2
replace edu = 3 if v53 == 3
replace edu = 4 if inlist(v53,4,9)
lab var edu "Education"

gen mar:mar = 1 if v52==1
replace mar = 2 if inlist(v52,3,4)
replace mar = 3 if v52==2
label variable mar "Marital status"

gen denom:denom = 1 if v71 == 2
replace denom = 2 if v71 == 1
replace denom = 3 if inlist(v71,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 88sh
save `88sh'
local flist "`flist' `88sh'"


// 1989 1766 "Wahl zum Abgeordnetenhaus in Berlin 1989"
// ----------------------------------------------------

// Election Date was on 29 Jan 1989

use $ltw/za1766, clear

gen str8 zanr = "1766"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jan1989"
gen intend = "28Jan1989"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v4,1,2) if inlist(v4,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inlist(v6,3,4,5,6,7,8)
lab var party "Electoral behaviour"

gen men:yesno = v55 == 1 if inlist(v55,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v56,1,2,3)
replace agegroup = 2 if inlist(v56,4,5,6,7,8)
replace agegroup = 3 if inlist(v56,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v63,1,2,3)
replace emp = 2 if v63 == 7
replace emp = 3 if v63 == 5
replace emp = 4 if inlist(v63,6,8)
replace emp = 5 if v63 == 4
replace emp = 6 if inlist(v63,9,99)
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v71,6,7)
replace occ = 2 if inlist(v71,2,3,4,5)	
replace occ = 3 if v71 == 1
replace occ = 1 if occ == . & inlist(v64,6,7)
replace occ = 2 if occ == . & inlist(v64,2,3,4,5)
replace occ = 3 if occ == . & v64 == 1
replace occ = 4 if occ == . | inlist(v64,8,9)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v59,1,2)
replace edu = 2 if v59 == 3
replace edu = 3 if v59 == 4
replace edu = 4 if inlist(v59,5,9)
lab var edu "Education"

gen mar:mar = 1 if v57==1
replace mar = 2 if inlist(v57,3,4)
replace mar = 3 if v57==2
label variable mar "Marital status"

gen denom:denom = 1 if v77 == 2
replace denom = 2 if v77 == 1
replace denom = 3 if inlist(v77,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 89be
save `89be'
local flist "`flist' `89be'"


// 1990 1932 "Landtagswahl im Saarland 1990"
// -----------------------------------------

// Election Date was on 28 Jan 1990

use $ltw/za1932, clear

gen str8 zanr = "1932"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jan1990"
gen intend = "27Jan1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SL"

gen voter:yesno = inlist(v7,1,2) if inlist(v7,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inlist(v8,3,4,5,6,7,8,9)
lab var party "Electoral behaviour"

gen men:yesno = v69 == 1 if inlist(v69,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v70,1,2,3)
replace agegroup = 2 if inlist(v70,4,5,6,7,8)
replace agegroup = 3 if inlist(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v77,1,2,3)
replace emp = 2 if v77 == 7
replace emp = 3 if v77 == 5
replace emp = 4 if inlist(v77,6,8)
replace emp = 5 if v77 == 4
replace emp = 6 if v77 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v86,6,7)
replace occ = 2 if inlist(v86,2,3,4,5)	
replace occ = 3 if v86 == 1
replace occ = 1 if occ == . & inlist(v78,6,7)
replace occ = 2 if occ == . & inlist(v78,2,3,4,5)
replace occ = 3 if occ == . & v78 == 1
replace occ = 4 if occ == . | inlist(v78,8,9)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v73,1,2)
replace edu = 2 if v73 == 3
replace edu = 3 if v73 == 4
replace edu = 4 if inlist(v73,5,9)
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,3,4)
replace mar = 3 if v71==2
label variable mar "Marital status"

gen denom:denom = 1 if v92 == 2
replace denom = 2 if v92 == 1
replace denom = 3 if inlist(v92,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90sl
save `90sl'
local flist "`flist' `90sl'"


// 1990 1933 "Landtagswahl in Nordrhein- Westfalen 1990"
// -----------------------------------------------------

// Election Date was on 13 May 1990

use $ltw/za1933, clear

gen str8 zanr = "1933"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1990" 
gen intend = "31May1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = inlist(v7,1,2) if inlist(v7,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inlist(v8,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v70 == 1 if inlist(v70,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v71,1,2,3)
replace agegroup = 2 if inlist(v71,4,5,6,7,8)
replace agegroup = 3 if inlist(v71,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v78,1,2,3)
replace emp = 2 if v78 == 7
replace emp = 3 if v78 == 5
replace emp = 4 if inlist(v78,6,8)
replace emp = 5 if v78 == 4
replace emp = 6 if v78 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v87,6,7)
replace occ = 2 if inlist(v87,2,3,4,5)	
replace occ = 3 if v87 == 1
replace occ = 1 if occ == . & inlist(v79,6,7)
replace occ = 2 if occ == . & inlist(v79,2,3,4,5)
replace occ = 3 if occ == . & v79== 1
replace occ = 4 if occ == . | inlist(v79,8,9)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v74,1,2)
replace edu = 2 if v74 == 3
replace edu = 3 if v74 == 4
replace edu = 4 if inlist(v74,5,9)
lab var edu "Education"

gen mar:mar = 1 if v72==1
replace mar = 2 if inlist(v72,3,4)
replace mar = 3 if v72==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90nw
save `90nw'
local flist "`flist' `90nw'"



// 1990 1934 "Landtagswahl in Niedersachsen 1990"
// ----------------------------------------------

// Election Date was on 13 May 1990

use $ltw/za1934, clear

gen str8 zanr = "1934"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1990"
gen intend = "31May1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v7,1,2) if inlist(v7,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inlist(v8,3,4,5,6,7,8,9,10)
lab var party "Electoral behaviour"

gen men:yesno = v70 == 1 if inlist(v70,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v71,1,2,3)
replace agegroup = 2 if inlist(v71,4,5,6,7,8)
replace agegroup = 3 if inlist(v71,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v78,1,2,3)
replace emp = 2 if v78 == 7
replace emp = 3 if v78 == 5
replace emp = 4 if inlist(v78,6,8)
replace emp = 5 if v78 == 4
replace emp = 6 if v78 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v87,6,7)
replace occ = 2 if inlist(v87,2,3,4,5)	
replace occ = 3 if v87 == 1
replace occ = 1 if occ == . & inlist(v79,6,7)
replace occ = 2 if occ == . & inlist(v79,2,3,4,5)
replace occ = 3 if occ == . & v79== 1
replace occ = 4 if occ == . | inlist(v79,8,9)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v74,1,2)
replace edu = 2 if v74 == 3
replace edu = 3 if v74 == 4
replace edu = 4 if inlist(v74,5,9)
lab var edu "Education"

gen mar:mar = 1 if v72==1
replace mar = 2 if inlist(v72,3,4)
replace mar = 3 if v72==2
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90nw
save `90nw'
local flist "`flist' `90nw'"



// 1990 1963 "Landtagswahl in Bayern 1990"
// ---------------------------------------

// Election Date was on 14 Oct 1990

use $ltw/za1963, clear

gen str8 zanr = "1963"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1990"
gen intend = "31Oct1990" 

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = v7 == 1 if v7<=2
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1	
replace party = 3 if inlist(v8,3,4,5,6,7,8,9)
lab var party "Electoral behaviour"

gen men:yesno = v65 == 1 if inlist(v65,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v66,1,2,3)
replace agegroup = 2 if inlist(v66,4,5,6,7,8,9)		// 9 = 60 bis 69
replace agegroup = 3 if v66 == 10
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v73,1,2,3)
replace emp = 2 if v73 == 7
replace emp = 3 if v73 == 5
replace emp = 4 if inlist(v73,6,8)
replace emp = 5 if v73 == 4
replace emp = 6 if v73 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v82,6,7)
replace occ = 2 if inlist(v82,2,3,4,5)	
replace occ = 3 if v82 == 1
replace occ = 1 if occ == . & inlist(v74,6,7)
replace occ = 2 if occ == . & inlist(v74,2,3,4,5)
replace occ = 3 if occ == . & v74== 1
replace occ = 4 if occ == . | inlist(v74,8,9)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v69,1,2)
replace edu = 2 if v69 == 3
replace edu = 3 if v69 == 4
replace edu = 4 if v69 == 5
lab var edu "Education"

gen mar:mar = 1 if v67==1
replace mar = 2 if inlist(v67,3,4)
replace mar = 3 if v67==2
label variable mar "Marital status"

gen denom:denom = 1 if v88 == 2
replace denom = 2 if v88 == 1
replace denom = 3 if inlist(v88,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90by
save `90by'
local flist "`flist' `90by'"



// 1991 2115 "Landtagswahl in Hessen 1991 vor Beginn des Golfkrieges"
// ------------------------------------------------------------------

// Election Date was on 20 Jan 1991
// Stichtag: 16 Jan 91: UN-Resolution 678

use $ltw/za2115, clear

gen str8 zanr = "2115"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jan1991"
gen intend = "15Jan1991"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v8,1,2) if inlist(v8,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 2
replace party = 2 if v11 == 1	
replace party = 3 if inrange(v11,3,13)
lab var party "Electoral behaviour"

//gen lr:lr = 1 if v144 == 1
gen lr:lr = 2 if v144 == 1
replace lr = 3 if v144 == 2
replace lr = 4 if v144 == 3 
//replace lr = 5 if v144 == 3
replace lr = 6 if v144 == 9
lab var lr "Left right self-placement"

gen men:yesno = v149 == 1 if inlist(v149,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v150,1,2,3)
replace agegroup = 2 if inlist(v150,4,5,6,7,8)
replace agegroup = 3 if inlist(v150,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v157,1,2,3)
replace emp = 2 if v157 == 7
replace emp = 3 if v157 == 5
replace emp = 4 if inlist(v157,6,8)
replace emp = 5 if v157 == 4
replace emp = 6 if v157 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v164,15,16)
replace occ = 2 if inlist(v164,4,5,6,7,8,9,10,11,12,13,14)	
replace occ = 3 if inlist(v164,1,2,3)
replace occ = 1 if occ == . & inlist(v160,15,16)
replace occ = 2 if occ == . & inlist(v160,4,5,6,7,8,9,10,11,12,13,14)
replace occ = 3 if occ == . & inlist(v160,1,2,3)
replace occ = 4 if occ == . | inlist(v160,17)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v153,1,2)
replace edu = 2 if v153 == 3
replace edu = 3 if v153 == 4
replace edu = 4 if inlist(v153,5,9)
lab var edu "Education"

gen mar:mar = 1 if v151==1
replace mar = 2 if inlist(v151,3,4)
replace mar = 3 if v151==2
label variable mar "Marital status"

gen denom:denom = 1 if v166 == 2
replace denom = 2 if v166 == 1
replace denom = 3 if inlist(v166,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 91hea
save `91hea'
local flist "`flist' `91hea'"




// 1991 2116 "Landtagswahl in Hessen 1991 nach Beginn des Golfkrieges"
// -------------------------------------------------------------------

// Election Date was on 20 Jan 1991
// Stichtag: 16 Jan 91: UN-Resolution 678

use $ltw/za2116, clear

gen str8 zanr = "2116"
lab var zanr "Zentralarchiv study number"

gen intstart = "16Jan1991"
gen intend = "19Jan1991"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v8,1,2) if inlist(v8,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 2
replace party = 2 if v11 == 1	
replace party = 3 if inrange(v11,3,13)
lab var party "Electoral behaviour"

//gen lr:lr = 1 if v144 == 1
gen lr:lr = 2 if v144 == 1
replace lr = 3 if v144 == 2
replace lr = 4 if v144 == 3 
//replace lr = 5 if v144 == 3
replace lr = 6 if v144 == 9
lab var lr "Left right self-placement"

gen men:yesno = v149 == 1 if inlist(v149,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v150,1,2,3)
replace agegroup = 2 if inlist(v150,4,5,6,7,8)
replace agegroup = 3 if inlist(v150,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v157,1,2,3)
replace emp = 2 if v157 == 7
replace emp = 3 if v157 == 5
replace emp = 4 if inlist(v157,6,8)
replace emp = 5 if v157 == 4
replace emp = 6 if v157 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v164,15,16)
replace occ = 2 if inlist(v164,4,5,6,7,8,9,10,11,12,13,14)	
replace occ = 3 if inlist(v164,1,2,3)
replace occ = 1 if occ == . & inlist(v160,15,16)
replace occ = 2 if occ == . & inlist(v160,4,5,6,7,8,9,10,11,12,13,14)
replace occ = 3 if occ == . & inlist(v160,1,2,3)
replace occ = 4 if occ == . | inlist(v160,17)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v153,1,2)
replace edu = 2 if v153 == 3
replace edu = 3 if v153 == 4
replace edu = 4 if inlist(v153,5,9)
lab var edu "Education"

gen mar:mar = 1 if v151==1
replace mar = 2 if inlist(v151,3,4)
replace mar = 3 if v151==2
label variable mar "Marital status"

gen denom:denom = 1 if v166 == 2
replace denom = 2 if v166 == 1
replace denom = 3 if inlist(v166,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 91heb
save `91heb'
local flist "`flist' `91heb'"


// 1991 2117 "Landtagswahl in Rheinland-Pfalz 1991"
// ------------------------------------------------

// Election Date was on 21 Apr 1991

use $ltw/za2117, clear

gen str8 zanr = "2117"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1991"
gen intend = "30Apr1991"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = inlist(v8,1,2) if inlist(v8,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 2
replace party = 2 if v11 == 1	
replace party = 3 if inrange(v11,3,13)
lab var party "Electoral behaviour"

//gen lr:lr = 1 if v144 == 1
gen lr:lr = 2 if v144 == 1
replace lr = 3 if v144 == 2
replace lr = 4 if v144 == 3 
//replace lr = 5 if v144 == 3
replace lr = 6 if v144 == 9
lab var lr "Left right self-placement"

gen men:yesno = v149 == 1 if inlist(v149,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v150,1,2,3)
replace agegroup = 2 if inlist(v150,4,5,6,7,8)
replace agegroup = 3 if inlist(v150,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v157,1,2,3)
replace emp = 2 if v157 == 7
replace emp = 3 if v157 == 5
replace emp = 4 if inlist(v157,6,8)
replace emp = 5 if v157 == 4
replace emp = 6 if v157 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v164,15,16)
replace occ = 2 if inlist(v164,4,5,6,7,8,9,10,11,12,13,14)	
replace occ = 3 if inlist(v164,1,2,3)
replace occ = 1 if occ == . & inlist(v160,15,16)
replace occ = 2 if occ == . & inlist(v160,4,5,6,7,8,9,10,11,12,13,14)
replace occ = 3 if occ == . & inlist(v160,1,2,3)
replace occ = 4 if occ == . | inlist(v160,17)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v153,1,2)
replace edu = 2 if v153 == 3
replace edu = 3 if v153 == 4
replace edu = 4 if inlist(v153,5,9)
lab var edu "Education"

gen mar:mar = 1 if v151==1
replace mar = 2 if inlist(v151,3,4)
replace mar = 3 if v151==2
label variable mar "Marital status"

gen denom:denom = 1 if v166 == 2
replace denom = 2 if v166 == 1
replace denom = 3 if inlist(v166,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 91rp
save `91rp'
local flist "`flist' `91rp'"


// 1991 2118 "Bürgerschaftswahl in Hamburg 1991"
// ---------------------------------------------

// Election Date was on 02 Jun 1991

use $ltw/za2118, clear

gen str8 zanr = "2118"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1991"
gen intend = "31May1991"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v8,1,2) if inlist(v8,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 2
replace party = 2 if v11 == 1	
replace party = 3 if inrange(v11,3,13)
lab var party "Electoral behaviour"

//gen lr:lr = 1 if v144 == 1
gen lr:lr = 2 if v144 == 1
replace lr = 3 if v144 == 2
replace lr = 4 if v144 == 3 
//replace lr = 5 if v144 == 3
replace lr = 6 if v144 == 9
lab var lr "Left right self-placement"

gen men:yesno = v149 == 1 if inlist(v149,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v150,1,2,3)
replace agegroup = 2 if inlist(v150,4,5,6,7,8)
replace agegroup = 3 if inlist(v150,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v157,1,2,3)
replace emp = 2 if v157 == 7
replace emp = 3 if v157 == 5
replace emp = 4 if inlist(v157,6,8)
replace emp = 5 if v157 == 4
replace emp = 6 if v157 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v164,15,16)
replace occ = 2 if inlist(v164,4,5,6,7,8,9,10,11,12,13,14)	
replace occ = 3 if inlist(v164,1,2,3)
replace occ = 1 if occ == . & inlist(v160,15,16)
replace occ = 2 if occ == . & inlist(v160,4,5,6,7,8,9,10,11,12,13,14)
replace occ = 3 if occ == . & inlist(v160,1,2,3)
replace occ = 4 if occ == . | inlist(v160,17)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v153,1,2)
replace edu = 2 if v153 == 3
replace edu = 3 if v153 == 4
replace edu = 4 if inlist(v153,5,9)
lab var edu "Education"

gen mar:mar = 1 if v151==1
replace mar = 2 if inlist(v151,3,4)
replace mar = 3 if v151==2
label variable mar "Marital status"

gen denom:denom = 1 if v166 == 2
replace denom = 2 if v166 == 1
replace denom = 3 if inlist(v166,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 91hh
save `91hh'
local flist "`flist' `91hh'"


// 1991 2119 "Bürgerschaftswahl in Bremen 1991"
// --------------------------------------------

// Election Date was on 29 Sep 1991

use $ltw/za2119, clear

gen str8 zanr = "2119"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1991"
gen intend = "28Sep1991"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v8,1,2) if inlist(v8,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 2
replace party = 2 if v11 == 1	
replace party = 3 if inrange(v11,3,13)
lab var party "Electoral behaviour"

//gen lr:lr = 1 if v144 == 1
gen lr:lr = 2 if v144 == 1
replace lr = 3 if v144 == 2
replace lr = 4 if v144 == 3 
//replace lr = 5 if v144 == 3
replace lr = 6 if v144 == 9
lab var lr "Left right self-placement"

gen men:yesno = v149 == 1 if inlist(v149,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v150,1,2,3)
replace agegroup = 2 if inlist(v150,4,5,6,7,8)
replace agegroup = 3 if inlist(v150,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v157,1,2,3)
replace emp = 2 if v157 == 7
replace emp = 3 if v157 == 5
replace emp = 4 if inlist(v157,6,8)
replace emp = 5 if v157 == 4
replace emp = 6 if v157 == 9
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v164,15,16)
replace occ = 2 if inlist(v164,4,5,6,7,8,9,10,11,12,13,14)	
replace occ = 3 if inlist(v164,1,2,3)
replace occ = 1 if occ == . & inlist(v160,15,16)
replace occ = 2 if occ == . & inlist(v160,4,5,6,7,8,9,10,11,12,13,14)
replace occ = 3 if occ == . & inlist(v160,1,2,3)
replace occ = 4 if occ == . | inlist(v160,17)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v153,1,2)
replace edu = 2 if v153 == 3
replace edu = 3 if v153 == 4
replace edu = 4 if inlist(v153,5,9)
lab var edu "Education"

gen mar:mar = 1 if v151==1
replace mar = 2 if inlist(v151,3,4)
replace mar = 3 if v151==2
label variable mar "Marital status"

gen denom:denom = 1 if v166 == 2
replace denom = 2 if v166 == 1
replace denom = 3 if inlist(v166,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 91hb
save `91hb'
local flist "`flist' `91hb'"




// 1992 2301 "Landtagswahl in Baden-Württemberg 1992"
// --------------------------------------------------

// Election Date was on 05 Apr 1992

use $ltw/za2301, clear

gen str8 zanr = "2301"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1991"
gen intend = "04Apr1991"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = inlist(v9,1,2) if inlist(v9,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 2
replace party = 2 if v11 == 1	
replace party = 3 if inrange(v11,3,9)
lab var party "Electoral behaviour"

gen men:yesno = v69 == 1 if inlist(v69,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v70,1,2,3)
replace agegroup = 2 if inlist(v70,4,5,6,7,8)
replace agegroup = 3 if inlist(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v77,1,2,3)
replace emp = 2 if v77 == 6
replace emp = 3 if v77 == 5
replace emp = 4 if inlist(v77,8,9)
replace emp = 5 if v77 == 4
replace emp = 6 if v77 == 7 
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v88,8,9)
replace occ = 2 if inlist(v88,4,5,6,7)	
replace occ = 3 if inlist(v88,1,2,3)
replace occ = 1 if occ == . & inlist(v81,8,9)
replace occ = 2 if occ == . & inlist(v81,4,5,6,7)
replace occ = 3 if occ == . & inlist(v81,1,2,3)
replace occ = 4 if occ == . | inlist(v81,10,99)
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v73,1,2)
replace edu = 2 if v73 == 3
replace edu = 3 if v73 == 4
replace edu = 4 if inlist(v73,5,9)
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,3,4)
replace mar = 3 if v71==2
label variable mar "Marital status"

gen denom:denom = 1 if v94 == 2
replace denom = 2 if v94 == 1
replace denom = 3 if inlist(v94,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 92bw
save `92bw'
local flist "`flist' `92bw'"




// 1992 2302 "Landtagswahl in Schleswig-Holstein 1992"
// --------------------------------------------------

// Election Date was on 05 Apr 1992

use $ltw/za2302, clear

gen str8 zanr = "2302"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1991"
gen intend = "04Apr1991"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v9,1,2) if inlist(v9,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 1
replace party = 2 if v11 == 2
replace party = 3 if inrange(v11,3,9)
lab var party "Electoral behaviour"

gen men:yesno = v72 == 1 if inlist(v72,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v73,1,2,3)
replace agegroup = 2 if inlist(v73,4,5,6,7,8,9)
replace agegroup = 3 if inlist(v73,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v80,1,2,3)
replace emp = 2 if v80 == 6
replace emp = 3 if v80 == 5
replace emp = 4 if inlist(v80,8,9)
replace emp = 5 if v80 == 4
replace emp = 6 if inlist(v80,7,99)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v92,8,9)
replace occ = 2 if inlist(v92,4,5,6,7)	
replace occ = 3 if inlist(v92,1,2,3)
replace occ = 1 if occ == . & inlist(v84,8,9)
replace occ = 2 if occ == . & inlist(v84,4,5,6,7)
replace occ = 3 if occ == . & inlist(v84,1,2,3)
replace occ = 4 if occ == . | v84 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v76,1,2)
replace edu = 2 if v76 == 3
replace edu = 3 if v76 == 4
replace edu = 4 if inlist(v76,5,9)
lab var edu "Education"

gen mar:mar = 1 if v74==1
replace mar = 2 if inlist(v74,3,4)
replace mar = 3 if v74==2
label variable mar "Marital status"

gen denom:denom = 1 if v98 == 2
replace denom = 2 if v98 == 1
replace denom = 3 if inlist(v98,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 92sh
save `92sh'
local flist "`flist' `92sh'"

// 1980 2311 "Landtagswahl in Baden-Württemberg 1980"
// --------------------------------------------------

// Election Date was on 16 Mar 1980

use $ltw/za2311, clear

gen str8 zanr = "2311"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1980"
gen intend = "31Mar1980" 

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v4 == 2
replace party = 2 if v4 == 1
replace party = 3 if inrange(v4,3,9)
lab var party "Electoral behaviour"

gen men:yesno = v36 == 1 if inlist(v36,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v37,18,29)
replace agegroup = 2 if inrange(v37,30,64)
replace agegroup = 3 if inrange(v37,65,84)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v40,1,2,3)
replace emp = 2 if inlist(v40,8,9,10)
replace emp = 3 if v40 == 6
replace emp = 4 if inlist(v40,5,7)
replace emp = 5 if v40 == 4
//replace emp = 6 if v40 == 
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v44,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v44,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v44,13,14,15)
replace occ = 1 if occ == . & inlist(v41,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v41,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v41,13,14,15)
replace occ = 4 if occ == . | v41 == 99
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v39,1,2,3)
replace edu = 2 if inlist(v39,4,5,6)
replace edu = 3 if inlist(v39,7,8,9)
//replace edu = 4 if inlist(v39,5,9)
lab var edu "Education"

gen mar:mar = 1 if v38==1
replace mar = 2 if inlist(v38,3,4)
replace mar = 3 if v38==2
label variable mar "Marital status"

gen denom:denom = 1 if v46 == 2
replace denom = 2 if v46 == 1
replace denom = 3 if inlist(v46,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 80bw
save `80bw'
local flist "`flist' `80bw'"


// 1979 2312 "Wahl zum Abgeordnetenhaus in Berlin 1979"
// ----------------------------------------------------

// Election Date was on 18 Mar 1979

use $ltw/za2312, clear

gen str8 zanr = "2312"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1979"
gen intend = "31Mar1979"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v4 == 2
replace party = 2 if v4 == 1
replace party = 3 if inrange(v4,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v19 == 1 if inlist(v19,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v20,18,29)
replace agegroup = 2 if inrange(v20,30,64)
replace agegroup = 3 if inrange(v20,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v23,1,2,3)
replace emp = 2 if inlist(v23,8,9,10)
replace emp = 3 if v23 == 6
replace emp = 4 if inlist(v23,5,7)
replace emp = 5 if v23 == 4
//replace emp = 6 if v23 == 
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v27,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v27,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v27,13,14,15)
replace occ = 1 if occ == . & inlist(v24,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v24,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v24,13,14,15)
replace occ = 4 if occ == . | v24 == 99
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v22,1,2,3)
replace edu = 2 if inlist(v22,4,5,6)
replace edu = 3 if inlist(v22,7,8,9)
//replace edu = 4 if inlist(v22,)
lab var edu "Education"

gen mar:mar = 1 if v21==1
replace mar = 2 if inlist(v21,3,4)
replace mar = 3 if v21==2
label variable mar "Marital status"

gen denom:denom = 1 if v29 == 2
replace denom = 2 if v29 == 1
replace denom = 3 if inlist(v29,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 79be
save `79be'
local flist "`flist' `79be'"


// 1981 2313 "Wahl zum Abgeordnetenhaus in Berlin 1981"
// ----------------------------------------------------

// Election Date was on 10 May 1981

use $ltw/za2313, clear

gen str8 zanr = "2313"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1981"
gen intend = "09May1981"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v7,1,2) if inlist(v7,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,7)
lab var party "Electoral behaviour"

gen polint = 3 - v5
lab var polint "Politicial interest"

gen lr:lr = 1 if inlist(v54,1,2)
replace lr = 2 if inlist(v54,3,4)
replace lr = 3 if inlist(v54,5,6)
replace lr = 4 if inlist(v54,7,8)
replace lr = 5 if inlist(v54,9,10)
replace lr = 6 if inlist(v54,98,99)
lab var lr "Left right self-placement"

gen men:yesno = v119 == 1 if inlist(v119,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v120,18,29)
replace agegroup = 2 if inrange(v120,30,64)
replace agegroup = 3 if inrange(v120,65,94)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v126,1,2,3)
replace emp = 2 if inlist(v126,8,9,10)
replace emp = 3 if v126 == 6
replace emp = 4 if inlist(v126,5,7)
replace emp = 5 if v126 == 4
//replace emp = 6 if v126 == 
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v133,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v133,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v133,13,14,15)
replace occ = 1 if occ == . & inlist(v128,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v128,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v128,13,14,15)
replace occ = 4 if occ == . | v128 == 99
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v125,1,2)
replace edu = 2 if v125 == 3
replace edu = 3 if inlist(v125,4,5)
//replace edu = 4 if inlist(v125,)
lab var edu "Education"

gen mar:mar = 1 if inlist(v124,1,2)
replace mar = 2 if inlist(v124,4,5)
replace mar = 3 if v124==3
label variable mar "Marital status"

gen denom:denom = 1 if v141 == 2
replace denom = 2 if v141 == 1
replace denom = 3 if inlist(v141,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 81be
save `81be'
local flist "`flist' `81be'"


// 1979 2314 "Bürgerschaftswahl in Bremen 1979" 
// --------------------------------------------

// Election Date was on 07 Oct 1979

use $ltw/za2314, clear

gen str8 zanr = "2314"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1979"
gen intend = "06OCt1979"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v4 == 1
replace party = 2 if v4 == 2
replace party = 3 if inrange(v4,3,9)
lab var party "Electoral behaviour"

gen men:yesno = v29 == 1 if inlist(v29,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v30,18,29)
replace agegroup = 2 if inrange(v30,30,64)
replace agegroup = 3 if inrange(v30,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v33,1,2,3)
replace emp = 2 if inlist(v33,8,9,10)
replace emp = 3 if v33 == 6
replace emp = 4 if inlist(v33,5,7)
replace emp = 5 if v33 == 4
//replace emp = 6 if v33 == 
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v37,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v37,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v37,13,14,15)
replace occ = 1 if occ == . & inlist(v34,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v34,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v34,13,14,15)
replace occ = 4 if occ == . | v34 == 99
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v32,1,2,3)
replace edu = 2 if inlist(v32,4,5,6)
replace edu = 3 if inlist(v32,7,8,9)
replace edu = 4 if v32 == .
lab var edu "Education"

gen mar:mar = 1 if v31==1
replace mar = 2 if inlist(v31,3,4)
replace mar = 3 if v31==2
label variable mar "Marital status"

gen denom:denom = 1 if v39 == 2
replace denom = 2 if v39 == 1
replace denom = 3 if inlist(v39,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 79hb
save `79hb'
local flist "`flist' `79hb'"


// 1978 2315 "Bürgerschaftswahl in Hamburg 1978"
// ---------------------------------------------

// Election Date was on 04 Jun 1978

use $ltw/za2315, clear

gen str8 zanr = "2315"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1978"
gen intend = "31May1978"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v5 == 1
replace party = 2 if v5 == 2
replace party = 3 if inrange(v5,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v39 == 1 if inlist(v39,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v40,18,29)
replace agegroup = 2 if inrange(v40,30,64)
replace agegroup = 3 if inrange(v40,65,94)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v43,1,2,3)
replace emp = 2 if inlist(v43,8,9,10)
replace emp = 3 if v43 == 6
replace emp = 4 if inlist(v43,5,7)
replace emp = 5 if v43 == 4
replace emp = 6 if v43 == .
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v47,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v47,5,6,7,8,9,10,11,12)	
replace occ = 3 if inlist(v47,13,14,15)
replace occ = 1 if occ == . & inlist(v44,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v44,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v44,13,14,15)
replace occ = 4 if occ == . | v44 == 99
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v42,1,2,3)
replace edu = 2 if inlist(v42,4,5,6)
replace edu = 3 if inlist(v42,7,8,9)
replace edu = 4 if v42 == .
lab var edu "Education"

gen mar:mar = 1 if v41==1
replace mar = 2 if inlist(v41,3,4)
replace mar = 3 if v41==2
label variable mar "Marital status"

gen denom:denom = 1 if v49 == 2
replace denom = 2 if v49 == 1
replace denom = 3 if inlist(v49,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 78hh
save `78hh'
local flist "`flist' `78hh'"


// 1978 2316 "Landtagswahl in Niedersachsen  1978"
// -----------------------------------------------

// Election Date was on 04 Jun 1978

use $ltw/za2316, clear

gen str8 zanr = "2316"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1978"
gen intend = "31May1978"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v5 == 2
replace party = 2 if v5 == 1
replace party = 3 if inrange(v5,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v38 == 1 if inlist(v38,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v39,18,29)
replace agegroup = 2 if inrange(v39,30,64)
replace agegroup = 3 if inrange(v39,65,93)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v42,1,2,3)
replace emp = 2 if inlist(v42,8,9,10)
replace emp = 3 if v42 == 6
replace emp = 4 if inlist(v42,5,7)
replace emp = 5 if v42 == 4
replace emp = 6 if v42 == .
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v46,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v46,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v46,13,14,15)
replace occ = 1 if occ == . & inlist(v43,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v43,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v43,13,14,15)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v41,1,2,3)
replace edu = 2 if inlist(v41,4,5,6)
replace edu = 3 if inlist(v41,7,8,9)
replace edu = 4 if v41 == .
lab var edu "Education"

gen mar:mar = 1 if v40==1
replace mar = 2 if inlist(v40,3,4)
replace mar = 3 if v40==2
label variable mar "Marital status"

gen denom:denom = 1 if v48 == 2
replace denom = 2 if v48 == 1
replace denom = 3 if inlist(v48,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 78ni
save `78ni'
local flist "`flist' `78ni'"

// 1979 2317 "Landtagswahl in Rheinland-Pfalz 1979"
// ------------------------------------------------

// Election Date was on 18 Mar 1979

use $ltw/za2317, clear

gen str8 zanr = "2317"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1979"
gen intend = "31Mar1979"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v4 == 2
replace party = 2 if v4 == 1
replace party = 3 if inrange(v4,3,7)
lab var party "Electoral behaviour"

gen men:yesno = v20 == 1 if inlist(v20,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v21,18,29)
replace agegroup = 2 if inrange(v21,30,64)
replace agegroup = 3 if inrange(v21,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v24,1,2,3)
replace emp = 2 if inlist(v24,8,9,10)
replace emp = 3 if v24 == 6
replace emp = 4 if inlist(v24,5,7)
replace emp = 5 if v24 == 4
replace emp = 6 if v24 == .
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v28,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v28,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v28,13,14,15)
replace occ = 1 if occ == . & inlist(v25,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v25,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v25,13,14,15)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v23,1,2,3)
replace edu = 2 if inlist(v23,4,5,6)
replace edu = 3 if inlist(v23,7,8,9)
replace edu = 4 if v23 == .
lab var edu "Education"

gen mar:mar = 1 if v22==1
replace mar = 2 if inlist(v22,3,4)
replace mar = 3 if v22==2
label variable mar "Marital status"

gen denom:denom = 1 if v30 == 2
replace denom = 2 if v30 == 1
replace denom = 3 if inlist(v30,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 79rp
save `79rp'
local flist "`flist' `79rp'"

// 1980 2318 "Landtagswahl im Saarland 1980"
// -----------------------------------------

// Election Date was on 27 Apr 1980

use $ltw/za2318, clear

gen str8 zanr = "2318"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1980"
gen intend = "26Apr1998"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SL"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v4 == 2
replace party = 2 if v4 == 1
replace party = 3 if inrange(v4,3,7)
lab var party "Electoral behaviour"

gen men:yesno = v38 == 1 if inlist(v38,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v39,18,29)
replace agegroup = 2 if inrange(v39,30,64)
replace agegroup = 3 if inrange(v39,65,91)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v42,1,2,3)
replace emp = 2 if inlist(v42,8,9,10)
replace emp = 3 if v42 == 6
replace emp = 4 if inlist(v42,5,7)
replace emp = 5 if v42 == 4
replace emp = 6 if v42 == .
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v46,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v46,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v46,13,14,15)
replace occ = 1 if occ == . & inlist(v43,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v43,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v43,13,14,15)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v41,1,2,3)
replace edu = 2 if inlist(v41,4,5,6)
replace edu = 3 if inlist(v41,7,8,9)
replace edu = 4 if v23 == .
lab var edu "Education"

gen mar:mar = 1 if v40==1
replace mar = 2 if inlist(v40,3,4)
replace mar = 3 if v40==2
label variable mar "Marital status"

gen denom:denom = 1 if v48 == 2
replace denom = 2 if v48 == 1
replace denom = 3 if inlist(v48,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 80sl
save `80sl'
local flist "`flist' `80sl'"


// 1979 2319 "Landtagswahl in Schleswig-Holstein 1979"
// --------------------------------------------------

// Election Date was on 29 Apr 1979

use $ltw/za2319, clear

gen str8 zanr = "2319"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1979"
gen intend = "28Apr1979"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v3,1,2) if inlist(v3,1,2,4)
lab var voter "Voter y/n"

gen party:party = 1 if v4 == 2
replace party = 2 if v4 == 1
replace party = 3 if inrange(v4,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v31 == 1 if inlist(v31,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v32,18,29)
replace agegroup = 2 if inrange(v32,30,64)
replace agegroup = 3 if inrange(v32,65,92)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v35,1,2,3)
replace emp = 2 if inlist(v35,8,9,10)
replace emp = 3 if v35 == 6
replace emp = 4 if inlist(v35,5,7)
replace emp = 5 if v35 == 4
replace emp = 6 if v35 == .
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v39,1,2,3,4,16,17,18)
replace occ = 2 if inlist(v39,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v39,13,14,15)
replace occ = 1 if occ == . & inlist(v36,1,2,3,4,16,17,18)
replace occ = 2 if occ == . & inlist(v36,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v36,13,14,15)
replace occ = 4 if occ == . 
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v34,1,2,3)
replace edu = 2 if inlist(v34,4,5,6)
replace edu = 3 if inlist(v34,7,8,9)
replace edu = 4 if v23 == .
lab var edu "Education"

gen mar:mar = 1 if v33==1
replace mar = 2 if inlist(v33,3,4)
replace mar = 3 if v33==2
label variable mar "Marital status"

gen denom:denom = 1 if v41 == 2
replace denom = 2 if v41 == 1
replace denom = 3 if inlist(v41,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 79sh
save `79sh'
local flist "`flist' `79sh'"

// 1993 2398 "Bürgerschaftswahl in Hamburg 1993"
// ---------------------------------------------

// Election Date was on 19 Sep 1993

use $ltw/za2398, clear

gen str8 zanr = "2398"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1993"
gen intend = "30Sep1993"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,3)
lab var voter "Voter y/n"

gen party:party = 1 if v7 == 1
replace party = 2 if v7 == 2
replace party = 3 if inrange(v7,3,10)
lab var party "Electoral behaviour"

gen men:yesno = v80 == 1 if inlist(v80,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v60,1,3)
replace agegroup = 2 if inrange(v60,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v60,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v66,1,2,3)
replace emp = 2 if v66 == 7
replace emp = 3 if v66 == 6
replace emp = 4 if v66 == 8
replace emp = 5 if inlist(v66,4,5)
replace emp = 6 if v66 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v74,13,14)
replace occ = 2 if inlist(v74,4,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v74,1,2,3)
replace occ = 1 if occ == . & inlist(v70,13,14)
replace occ = 2 if occ == . & inlist(v70,4,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v70,1,2,3)
replace occ = 4 if occ == . | v70 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v63,1,2)
replace edu = 2 if v63 == 3
replace edu = 3 if v63 == 4
replace edu = 4 if inlist(v63,5,9,.)
lab var edu "Education"

gen mar:mar = 1 if v61==1
replace mar = 2 if inlist(v61,2,4,5)
replace mar = 3 if v61==3
label variable mar "Marital status"

gen denom:denom = 1 if v76 == 2
replace denom = 2 if v76 == 1
replace denom = 3 if inlist(v76,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 93hh
save `93hh'
local flist "`flist' `93hh'"



// 1994 2506 "Landtagswahl in Bayern 1994"
// ---------------------------------------

// Election Date was on 25 Sep 1994

use $ltw/za2506, clear

gen str8 zanr = "2506"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1994"
gen intend = "24Sep1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v42
lab var polint "Politicial interest"

gen men:yesno = v68 == 1 if inlist(v68,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v69,1,3)
replace agegroup = 2 if inrange(v69,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v69,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v75,1,2,3)
replace emp = 2 if v75 == 7
replace emp = 3 if v75 == 6
replace emp = 4 if v75 == 9
replace emp = 5 if inlist(v75,4,5)
replace emp = 6 if v75 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v84,8,9)
replace occ = 2 if inlist(v84,4,5,6,7)
replace occ = 3 if inlist(v84,1,2,3)
replace occ = 1 if occ == . & inlist(v77,8,9)
replace occ = 2 if occ == . & inlist(v77,4,5,6,7)
replace occ = 3 if occ == . & inlist(v77,1,2,3)
replace occ = 4 if occ == . | v77 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v72,1,4)
replace edu = 2 if v72 == 2
replace edu = 3 if v72 == 3
replace edu = 4 if inlist(v72,5,9)
lab var edu "Education"

gen mar:mar = 1 if v70==1
replace mar = 2 if inlist(v70,2,4,5)
replace mar = 3 if v70==3
label variable mar "Marital status"

gen denom:denom = 1 if v89 == 2
replace denom = 2 if v89 == 1
replace denom = 3 if inlist(v89,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94by
save `94by'
local flist "`flist' `94by'"

// 1994 2507 "Landtagswahl in Brandenburg 1994"
// --------------------------------------------

// Election Date was on 11 Sep 1994

use $ltw/za2507, clear

gen str8 zanr = "2507"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Aug1994"
gen intend = "10Sep1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BB"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inrange(v8,3,12)
lab var party "Electoral behaviour"

gen polint = 5 - v42
lab var polint "Politicial interest"

gen men:yesno = v69 == 1 if inlist(v69,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v70,1,3)
replace agegroup = 2 if inrange(v70,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v76,1,2,3)
replace emp = 2 if v76 == 7
replace emp = 3 if v76 == 6
replace emp = 4 if v76 == 9
replace emp = 5 if inlist(v76,4,5)
replace emp = 6 if v76 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v83,13,14)
replace occ = 2 if inlist(v83,4,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v83,1,2,3)
replace occ = 1 if occ == . & inlist(v78,13,14)
replace occ = 2 if occ == . & inlist(v78,4,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v78,1,2,3)
replace occ = 4 if occ == . | v78 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v73,1,6)
replace edu = 2 if v73 == 2
replace edu = 3 if inlist(v73,3,4,5)
replace edu = 4 if inlist(v73,7,9)
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,2,4,5)
replace mar = 3 if v71==3
label variable mar "Marital status"

gen denom:denom = 1 if v85 == 2
replace denom = 2 if v85 == 1
replace denom = 3 if inlist(v85,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94bb
save `94bb'
local flist "`flist' `94bb'"

// 1994 2508 "Landtagswahl in Mecklenburg-Vorpommern 1994"
// -------------------------------------------------------

// Election Date was on 16 Oct 1994

use $ltw/za2508, clear

gen str8 zanr = "2508"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1994"
gen intend = "31Oct1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "MV"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v46
lab var polint "Politicial interest"

gen men:yesno = v64 == 1 if inlist(v64,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v65,1,3)
replace agegroup = 2 if inrange(v65,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v65,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v71,1,2,3)
replace emp = 2 if v71 == 7
replace emp = 3 if v71 == 6
replace emp = 4 if v71 == 9
replace emp = 5 if inlist(v71,4,5)
replace emp = 6 if v71 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v78,13,14)
replace occ = 2 if inlist(v78,4,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v78,1,2,3)
replace occ = 1 if occ == . & inlist(v73,13,14)
replace occ = 2 if occ == . & inlist(v73,4,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v73,1,2,3)
replace occ = 4 if occ == . | v78 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v68,1,6)
replace edu = 2 if v68 == 2
replace edu = 3 if inlist(v68,3,4,5)
replace edu = 4 if v68 == 7
lab var edu "Education"

gen mar:mar = 1 if v66==1
replace mar = 2 if inlist(v66,2,4,5)
replace mar = 3 if v66==3
label variable mar "Marital status"

gen denom:denom = 1 if v80 == 2
replace denom = 2 if v80 == 1
replace denom = 3 if inlist(v80,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94mv
save `94mv'
local flist "`flist' `94mv'"

// 1994 2509 "Landtagswahl in Niedersachsen 1994"
// ----------------------------------------------

// Election Date was on 13 Mar 1994

use $ltw/za2509, clear

gen str8 zanr = "2509"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1994"
gen intend = "31Mar1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v7,1,2) if inlist(v7,1,2,4)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,12)
lab var party "Electoral behaviour"

gen men:yesno = v68 == 1 if inlist(v68,1,2)

gen agegroup:agegroup = 1 if inrange(v69,1,3)
replace agegroup = 2 if inrange(v69,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v69,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v75,1,2,3)
replace emp = 2 if v75 == 7
replace emp = 3 if v75 == 6
replace emp = 4 if v75 == 9
replace emp = 5 if inlist(v75,4,5)
replace emp = 6 if v75 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v84,8,9)
replace occ = 2 if inlist(v84,4,5,6,7)
replace occ = 3 if inlist(v84,1,2,3)
replace occ = 1 if occ == . & inlist(v77,8,9)
replace occ = 2 if occ == . & inlist(v77,4,5,6,7)
replace occ = 3 if occ == . & inlist(v77,1,2,3)
replace occ = 4 if occ == . | v77 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v72,1,4)
replace edu = 2 if v72 == 2
replace edu = 3 if inlist(v72,3,4)
replace edu = 4 if v72 == 5
lab var edu "Education"

gen mar:mar = 1 if v70==1
replace mar = 2 if inlist(v70,2,4,5)
replace mar = 3 if v70==3
label variable mar "Marital status"

gen denom:denom = 1 if v89 == 2
replace denom = 2 if v89 == 1
replace denom = 3 if inlist(v89,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94ni
save `94ni'
local flist "`flist' `94ni'"


// 1994 2510 "Landtagswahl im Saarland 1994"
// -----------------------------------------

// Election Date was on 16 Oct 1994

use $ltw/za2510, clear

gen str8 zanr = "2510"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1994"
gen intend = "31Oct1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SL"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,10)
lab var party "Electoral behaviour"

gen men:yesno = v56 == 1 if inlist(v56,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v57,1,3)
replace agegroup = 2 if inrange(v57,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v57,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v63,1,2,3)
replace emp = 2 if v63 == 7
replace emp = 3 if v63 == 6
replace emp = 4 if v63 == 9
replace emp = 5 if inlist(v63,4,5)
replace emp = 6 if v63 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v72,8,9)
replace occ = 2 if inlist(v72,4,5,6,7)
replace occ = 3 if inlist(v72,1,2,3)
replace occ = 1 if occ == . & inlist(v65,8,9)
replace occ = 2 if occ == . & inlist(v65,4,5,6,7)
replace occ = 3 if occ == . & inlist(v65,1,2,3)
replace occ = 4 if occ == . | v65 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v60,1,4)
replace edu = 2 if v60 == 2
replace edu = 3 if inlist(v60,3,4)
replace edu = 4 if v60 == 5
lab var edu "Education"

gen mar:mar = 1 if v58==1
replace mar = 2 if inlist(v58,2,4,5)
replace mar = 3 if v58==3
label variable mar "Marital status"

gen denom:denom = 1 if v77 == 2
replace denom = 2 if v77 == 1
replace denom = 3 if inlist(v77,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94sl
save `94sl'
local flist "`flist' `94sl'"

// 1994 2511 "Landtagswahl in Sachsen 1994"
// ----------------------------------------

// Election Date was on 11 Sep 1994

use $ltw/za2511, clear

gen str8 zanr = "2511"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Aug1994"
gen intend = "10Sep1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SN"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,9)
lab var party "Electoral behaviour"

gen men:yesno = v68 == 1 if inlist(v68,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v69,1,3)
replace agegroup = 2 if inrange(v69,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v69,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v75,1,2,3)
replace emp = 2 if v75 == 7
replace emp = 3 if v75 == 6
replace emp = 4 if v75 == 9
replace emp = 5 if inlist(v75,4,5)
replace emp = 6 if v75 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v82,13,14)
replace occ = 2 if inlist(v82,4,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v82,1,2,3)
replace occ = 1 if occ == . & inlist(v77,13,14)
replace occ = 2 if occ == . & inlist(v77,4,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v77,1,2,3)
replace occ = 4 if occ == . | v77 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v72,1,6)
replace edu = 2 if v72 == 2
replace edu = 3 if inlist(v72,3,4,5) 
replace edu = 4 if v72 == 7
lab var edu "Education"

gen mar:mar = 1 if v70==1
replace mar = 2 if inlist(v70,2,4,5)
replace mar = 3 if v70==3
label variable mar "Marital status"

gen denom:denom = 1 if v84 == 2
replace denom = 2 if v84 == 1
replace denom = 3 if inlist(v84,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94sn
save `94sn'
local flist "`flist' `94sn'"


// 1994 2512 "Landtagswahl in Sachsen-Anhalt 1994"
// -----------------------------------------------

// Election Date was on 26 Jun 1994

use $ltw/za2512, clear

gen str8 zanr = "2512"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jun1994"
gen intend = "25Jun1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "ST"

gen voter:yesno = inlist(v5,1,2) if inlist(v5,1,2,4)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,13)
lab var party "Electoral behaviour"

gen polint = 5 - v41	
lab var polint "Politicial interest"

gen men:yesno = v65 == 1 if inlist(v65,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v66,1,3)
replace agegroup = 2 if inrange(v66,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v66,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v72,1,2,3)
replace emp = 2 if v72 == 7
replace emp = 3 if v72 == 6
replace emp = 4 if v72 == 9
replace emp = 5 if inlist(v72,4,5)
replace emp = 6 if v72 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v79,13,14)
replace occ = 2 if inlist(v79,4,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v79,1,2,3)
replace occ = 1 if occ == . & inlist(v74,13,14)
replace occ = 2 if occ == . & inlist(v74,4,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v74,1,2,3)
replace occ = 4 if occ == . | v74 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v69,1,6)
replace edu = 2 if v69 == 2
replace edu = 3 if inlist(v69,3,4,5) 
replace edu = 4 if v69 == 7
lab var edu "Education"

gen mar:mar = 1 if v67==1
replace mar = 2 if inlist(v67,2,4,5)
replace mar = 3 if v67==3
label variable mar "Marital status"

gen denom:denom = 1 if v81 == 2
replace denom = 2 if v81 == 1
replace denom = 3 if inlist(v81,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94st
save `94st'
local flist "`flist' `94st'"


// 1994 2513 "Landtagswahl in Thüringen 1994"
// ------------------------------------------

// Election Date was on 16 Oct 1994

use $ltw/za2513, clear

gen str8 zanr = "2513"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1994"
gen intend = "31Oct1994"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "TH"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v46	
lab var polint "Politicial interest"

gen men:yesno = v68 == 1 if inlist(v68,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v69,1,3)
replace agegroup = 2 if inrange(v69,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v69,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v75,1,2,3)
replace emp = 2 if v75 == 7
replace emp = 3 if v75 == 6
replace emp = 4 if v75 == 9
replace emp = 5 if inlist(v75,4,5)
replace emp = 6 if v75 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v82,13,14)
replace occ = 2 if inlist(v82,4,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v82,1,2,3)
replace occ = 1 if occ == . & inlist(v77,13,14)
replace occ = 2 if occ == . & inlist(v77,4,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v77,1,2,3)
replace occ = 4 if occ == . | v77 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v72,1,6)
replace edu = 2 if v72 == 2
replace edu = 3 if inlist(v72,3,4,5) 
replace edu = 4 if v72 == 7
lab var edu "Education"

gen mar:mar = 1 if v70==1
replace mar = 2 if inlist(v70,2,4,5)
replace mar = 3 if v70==3
label variable mar "Marital status"

gen denom:denom = 1 if v84 == 2
replace denom = 2 if v84 == 1
replace denom = 3 if inlist(v84,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94th
save `94th'
local flist "`flist' `94th'"


// 1995 2581 "Bürgerschaftswahl in Bremen 1995"
// --------------------------------------------

// Election Date was on 14 May 1995

use $ltw/za2581, clear

gen str8 zanr = "2581"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1995"
gen intend = "31May1995"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 1
replace party = 2 if v9 == 2
replace party = 3 if inrange(v9,3,11)
lab var party "Electoral behaviour"

gen polint = 5 - v42	
lab var polint "Politicial interest"

gen men:yesno = v62 == 1 if inlist(v62,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v63,1,3)
replace agegroup = 2 if inrange(v63,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v63,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v69,1,2,3)
replace emp = 2 if v69 == 7
replace emp = 3 if v69 == 6
replace emp = 4 if v69 == 9
replace emp = 5 if inlist(v69,4,5)
replace emp = 6 if v69 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v78,8,9)
replace occ = 2 if inlist(v78,4,5,6,7)
replace occ = 3 if inlist(v78,1,2,3)
replace occ = 1 if occ == . & inlist(v71,8,9)
replace occ = 2 if occ == . & inlist(v71,4,5,6,7)
replace occ = 3 if occ == . & inlist(v71,1,2,3)
replace occ = 4 if occ == . | v71 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v66,1,4)
replace edu = 2 if v66 == 2
replace edu = 3 if v66 == 3 
replace edu = 4 if v66 == 5
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,2,4,5)
replace mar = 3 if v64==3
label variable mar "Marital status"

gen denom:denom = 1 if v83 == 2
replace denom = 2 if v83 == 1
replace denom = 3 if inlist(v83,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 95hb
save `95hb'
local flist "`flist' `95hb'"


// 1995 2582 "Landtagswahl in Hessen 1995"
// ---------------------------------------

// Election Date was on 19 Feb 1995

use $ltw/za2582, clear

gen str8 zanr = "2582"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Feb1995"
gen intend = "28Feb1995"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v41	
lab var polint "Politicial interest"

gen men:yesno = v62 == 1 if inlist(v62,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v63,1,3)
replace agegroup = 2 if inrange(v63,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v63,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v69,1,2,3)
replace emp = 2 if v69 == 7
replace emp = 3 if v69 == 6
replace emp = 4 if v69 == 9
replace emp = 5 if inlist(v69,4,5)
replace emp = 6 if v69 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v78,8,9)
replace occ = 2 if inlist(v78,4,5,6,7)
replace occ = 3 if inlist(v78,1,2,3)
replace occ = 1 if occ == . & inlist(v71,8,9)
replace occ = 2 if occ == . & inlist(v71,4,5,6,7)
replace occ = 3 if occ == . & inlist(v71,1,2,3)
replace occ = 4 if occ == . | v71 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v66,1,4)
replace edu = 2 if v66 == 2
replace edu = 3 if v66 == 3 
replace edu = 4 if v66 == 5
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,2,4,5)
replace mar = 3 if v64==3
label variable mar "Marital status"

gen denom:denom = 1 if v83 == 2
replace denom = 2 if v83 == 1
replace denom = 3 if inlist(v83,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 95he
save `95he'
local flist "`flist' `95he'"

// 1995 2583 "Landtagswahl in Nordrhein-Westfalen 1995"
// ----------------------------------------------------

// Election Date was on 14 May 1995

use $ltw/za2583, clear

gen str8 zanr = "2583"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1995"
gen intend = "31May1995"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 1
replace party = 2 if v9 == 2
replace party = 3 if inrange(v9,3,9)
lab var party "Electoral behaviour"

gen polint = 5 - v44	
lab var polint "Politicial interest"

gen men:yesno = v64 == 1 if inlist(v64,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v65,1,3)
replace agegroup = 2 if inrange(v65,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v65,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v71,1,2,3)
replace emp = 2 if v71 == 7
replace emp = 3 if v71 == 6
replace emp = 4 if v71 == 9
replace emp = 5 if inlist(v71,4,5)
replace emp = 6 if v71 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v80,8,9)
replace occ = 2 if inlist(v80,4,5,6,7)
replace occ = 3 if inlist(v80,1,2,3)
replace occ = 1 if occ == . & inlist(v73,8,9)
replace occ = 2 if occ == . & inlist(v73,4,5,6,7)
replace occ = 3 if occ == . & inlist(v73,1,2,3)
replace occ = 4 if occ == . | v73 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v68,1,4)
replace edu = 2 if v68 == 2
replace edu = 3 if v68 == 3 
replace edu = 4 if v68 == 5
lab var edu "Education"

gen mar:mar = 1 if v66==1
replace mar = 2 if inlist(v66,2,4,5)
replace mar = 3 if v66==3
label variable mar "Marital status"

gen denom:denom = 1 if v85 == 2
replace denom = 2 if v85 == 1
replace denom = 3 if inlist(v85,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 95nw
save `95nw'
local flist "`flist' `95nw'"

// 1995 2649 "Wahl zum Abgeordnetenhaus in Berlin 1995"
// ----------------------------------------------------

// Election Date was on 22 Oct 1995

use $ltw/za2649, clear

gen str8 zanr = "2649"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1995"
gen intend = "31Oct1995"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v8,1,2,5) if inlist(v8,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v11 == 2
replace party = 2 if v11 == 1
replace party = 3 if inrange(v11,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v42	
lab var polint "Politicial interest"

gen men:yesno = v68 == 1 if inlist(v68,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v69,1,3)
replace agegroup = 2 if inrange(v69,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v69,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v77,1,2,3)
replace emp = 2 if v77 == 7
replace emp = 3 if v77 == 6
replace emp = 4 if v77 == 9
replace emp = 5 if inlist(v77,4,5)
replace emp = 6 if v77 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v86,8,9)
replace occ = 2 if inlist(v86,4,5,6,7)
replace occ = 3 if inlist(v86,1,2,3)
replace occ = 1 if occ == . & inlist(v79,8,9)
replace occ = 2 if occ == . & inlist(v79,4,5,6,7)
replace occ = 3 if occ == . & inlist(v79,1,2,3)
replace occ = 4 if occ == . | v79 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v72,1,4) | inlist(v74,1,6) 		// v72=west v74=ost
replace edu = 2 if v72 == 2 | v74 == 2
replace edu = 3 if v72 == 3 | inlist(v74,3,4,5)
replace edu = 4 if v72 == 5 | v74 == 7
lab var edu "Education"

gen mar:mar = 1 if v70==1
replace mar = 2 if inlist(v70,2,4,5)
replace mar = 3 if v70==3
label variable mar "Marital status"

gen denom:denom = 1 if v91 == 2
replace denom = 2 if v91 == 1
replace denom = 3 if inlist(v91,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 95be
save `95be'
local flist "`flist' `95be'"

// 1996 2913 "Landtagswahl in Baden-Württemberg 1996"
// --------------------------------------------------

// Election Date was on 24 Mar 1996

use $ltw/za2913, clear

gen str8 zanr = "2913"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1996" 
gen intend = "31May1996"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 2
replace party = 2 if v9 == 1
replace party = 3 if inrange(v9,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v42	
lab var polint "Politicial interest"

gen men:yesno = v61 == 1 if inlist(v61,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v62,1,3)
replace agegroup = 2 if inrange(v62,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v62,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v68,1,2,3)
replace emp = 2 if v68 == 7
replace emp = 3 if v68 == 6
replace emp = 4 if v68 == 9
replace emp = 5 if inlist(v68,4,5)
replace emp = 6 if v68 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v77,8,9)
replace occ = 2 if inlist(v77,4,5,6,7)
replace occ = 3 if inlist(v77,1,2,3)
replace occ = 1 if occ == . & inlist(v70,8,9)
replace occ = 2 if occ == . & inlist(v70,4,5,6,7)
replace occ = 3 if occ == . & inlist(v70,1,2,3)
replace occ = 4 if occ == . | v70 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v65,1,4)
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 5
lab var edu "Education"

gen mar:mar = 1 if v63==1
replace mar = 2 if inlist(v63,2,4,5)
replace mar = 3 if v63==3
label variable mar "Marital status"

gen denom:denom = 1 if v82 == 2
replace denom = 2 if v82 == 1
replace denom = 3 if inlist(v82,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 96bw
save `96bw'
local flist "`flist' `96bw'"


// 1996 2914 "Landtagswahl in Rheinland-Pfalz 1996"
// ------------------------------------------------

// Election Date was on 24 Mar 1996

use $ltw/za2914, clear

gen str8 zanr = "2914"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1996"
gen intend = "31May1996"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v41	
lab var polint "Politicial interest"

gen men:yesno = v59 == 1 if inlist(v59,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v60,1,3)
replace agegroup = 2 if inrange(v60,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v60,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v66,1,2,3)
replace emp = 2 if v66 == 7
replace emp = 3 if v66 == 6
replace emp = 4 if v66 == 9
replace emp = 5 if inlist(v66,4,5)
replace emp = 6 if v66 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v75,8,9)
replace occ = 2 if inlist(v75,4,5,6,7)
replace occ = 3 if inlist(v75,1,2,3)
replace occ = 1 if occ == . & inlist(v68,8,9)
replace occ = 2 if occ == . & inlist(v68,4,5,6,7)
replace occ = 3 if occ == . & inlist(v68,1,2,3)
replace occ = 4 if occ == . | v68 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v63,1,4)
replace edu = 2 if v63 == 2	
replace edu = 3 if v63 == 3
replace edu = 4 if v63 == 5
lab var edu "Education"

gen mar:mar = 1 if v61==1
replace mar = 2 if inlist(v61,2,4,5)
replace mar = 3 if v61==3
label variable mar "Marital status"

gen denom:denom = 1 if v80 == 2
replace denom = 2 if v80 == 1
replace denom = 3 if inlist(v80,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 96rp
save `96rp'
local flist "`flist' `96rp'"


// 1996 2915 "Landtagswahl in Schleswig-Holstein 1996"
// ---------------------------------------------------

// Election Date was on 24 Mar 1996

use $ltw/za2915, clear

gen str8 zanr = "2915"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar1996"
gen intend = "31May1996"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 1
replace party = 2 if v9 == 2
replace party = 3 if inrange(v9,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v41	
lab var polint "Politicial interest"

gen men:yesno = v61 == 1 if inlist(v61,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v62,1,3)
replace agegroup = 2 if inrange(v62,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v62,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v68,1,2,3)
replace emp = 2 if v68 == 7
replace emp = 3 if v68 == 6
replace emp = 4 if v68 == 9
replace emp = 5 if inlist(v68,4,5)
replace emp = 6 if v68 == 8
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v77,8,9)
replace occ = 2 if inlist(v77,4,5,6,7)
replace occ = 3 if inlist(v77,1,2,3)
replace occ = 1 if occ == . & inlist(v70,8,9)
replace occ = 2 if occ == . & inlist(v70,4,5,6,7)
replace occ = 3 if occ == . & inlist(v70,1,2,3)
replace occ = 4 if occ == . | v70 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v65,1,4)
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 5
lab var edu "Education"

gen mar:mar = 1 if v63==1
replace mar = 2 if inlist(v63,2,4,5)
replace mar = 3 if v63==3
label variable mar "Marital status"

gen denom:denom = 1 if v82 == 2
replace denom = 2 if v82 == 1
replace denom = 3 if inlist(v82,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 96sh
save `96sh'
local flist "`flist' `96sh'"


// 1997 3030 "Bürgerschaftswahl in Hamburg 1997"
// ---------------------------------------------

// Election Date was on 21 Sep 1997

use $ltw/za3030, clear

gen str8 zanr = "3030"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1997"
gen intend = "30Sep1997"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v7 == 1
replace party = 2 if v7 == 2
replace party = 3 if inrange(v7,3,12)
lab var party "Electoral behaviour"

gen polint = 5 - v46	
lab var polint "Politicial interest"

gen men:yesno = v69 == 1 if inlist(v69,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v70,1,3)
replace agegroup = 2 if inrange(v70,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v80,1,2,3)
replace emp = 2 if v80 == 8
replace emp = 3 if v80 == 7
replace emp = 4 if v80 == 10
replace emp = 5 if inlist(v80,5,6)
replace emp = 6 if inlist(v80,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v89,8,9)
replace occ = 2 if inlist(v89,4,5,6,7)
replace occ = 3 if inlist(v89,1,2,3)
replace occ = 1 if occ == . & inlist(v82,8,9)
replace occ = 2 if occ == . & inlist(v82,4,5,6,7)
replace occ = 3 if occ == . & inlist(v82,1,2,3)
replace occ = 4 if occ == . | v82 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v77,1,4)
replace edu = 2 if v77 == 2
replace edu = 3 if v77 == 3
replace edu = 4 if v77 == 5
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,2,4,5)
replace mar = 3 if v71==3
label variable mar "Marital status"

gen denom:denom = 1 if v94 == 2
replace denom = 2 if v94 == 1
replace denom = 3 if inlist(v94,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 97hh
save `97hh'
local flist "`flist' `97hh'"


// 1998 3031 "Landtagswahl in Niedersachsen 1998"
// ----------------------------------------------

// Election Date was on 01 Mar 1998

use $ltw/za3031, clear

gen str8 zanr = "3031"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Feb1998"
gen intend = "28Feb1998"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inrange(v8,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v45	
lab var polint "Politicial interest"

gen men:yesno = v73 == 1 if inlist(v73,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v74,1,3)
replace agegroup = 2 if inrange(v74,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v74,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v80,1,2,3)
replace emp = 2 if v80 == 8
replace emp = 3 if v80 == 7
replace emp = 4 if v80 == 10
replace emp = 5 if inlist(v80,5,6)
replace emp = 6 if inlist(v80,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v89,8,9)
replace occ = 2 if inlist(v89,4,5,6,7)
replace occ = 3 if inlist(v89,1,2,3)
replace occ = 1 if occ == . & inlist(v82,8,9)
replace occ = 2 if occ == . & inlist(v82,4,5,6,7)
replace occ = 3 if occ == . & inlist(v82,1,2,3)
replace occ = 4 if occ == . | v82 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v77,1,4)
replace edu = 2 if v77 == 2
replace edu = 3 if v77 == 3
replace edu = 4 if v77 == 5
lab var edu "Education"

gen mar:mar = 1 if v75==1
replace mar = 2 if inlist(v75,2,4,5)
replace mar = 3 if v75==3
label variable mar "Marital status"

gen denom:denom = 1 if v94 == 2
replace denom = 2 if v94 == 1
replace denom = 3 if inlist(v94,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 98ni
save `98ni'
local flist "`flist' `98ni'"


// 1998 3032 "Landtagswahl in Sachsen-Anhalt 1998"
// -----------------------------------------------

// Election Date was on 26 Apr 1998

use $ltw/za3032, clear

gen str8 zanr = "3032"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr1998"
gen intend = "25Apr1998"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "ST"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v51	
lab var polint "Politicial interest"

gen men:yesno = v76 == 1 if inlist(v76,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v77,1,3)
replace agegroup = 2 if inrange(v77,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v77,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v83,1,2,3)
replace emp = 2 if v83 == 8
replace emp = 3 if v83 == 7
replace emp = 4 if v83 == 10
replace emp = 5 if inlist(v83,5,6)
replace emp = 6 if inlist(v83,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v92,8,9)
replace occ = 2 if inlist(v92,4,5,6,7)
replace occ = 3 if inlist(v92,1,2,3)
replace occ = 1 if occ == . & inlist(v85,8,9)
replace occ = 2 if occ == . & inlist(v85,4,5,6,7)
replace occ = 3 if occ == . & inlist(v85,1,2,3)
replace occ = 4 if occ == . | v85 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v80,1,6)
replace edu = 2 if v80 == 2
replace edu = 3 if inlist(v80,3,4,5)
replace edu = 4 if v80 == 7
lab var edu "Education"

gen mar:mar = 1 if v78==1
replace mar = 2 if inlist(v78,2,4,5)
replace mar = 3 if v78==3
label variable mar "Marital status"

gen denom:denom = 1 if v97 == 2
replace denom = 2 if v97 == 1
replace denom = 3 if inlist(v97,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 98st
save `98st'
local flist "`flist' `98st'"

// 1999 3120 "Landtagswahl in Hessen 1999"
// ---------------------------------------

// Election Date was on 07 Feb 1999

use $ltw/za3120, clear

gen str8 zanr = "3120"
lab var zanr "Zentralarchiv study number"

gen intstart = "08Feb1999"
gen intend = "28Feb1999"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v44	
lab var polint "Politicial interest"

gen men:yesno = v77 == 1 if inlist(v77,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v78,1,3)
replace agegroup = 2 if inrange(v78,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v78,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v84,1,2,3)
replace emp = 2 if v84 == 8
replace emp = 3 if v84 == 7
replace emp = 4 if v84 == 10
replace emp = 5 if inlist(v84,5,6)
replace emp = 6 if inlist(v84,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v93,8,9)
replace occ = 2 if inlist(v93,4,5,6,7)
replace occ = 3 if inlist(v93,1,2,3)
replace occ = 1 if occ == . & inlist(v86,8,9)
replace occ = 2 if occ == . & inlist(v86,4,5,6,7)
replace occ = 3 if occ == . & inlist(v86,1,2,3)
replace occ = 4 if occ == . | v86 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v81,1,4)
replace edu = 2 if v81 == 2
replace edu = 3 if v81 == 3
replace edu = 4 if v81 == 5
lab var edu "Education"

gen mar:mar = 1 if v79==1
replace mar = 2 if inlist(v79,2,4,5)
replace mar = 3 if v79==3
label variable mar "Marital status"

gen denom:denom = 1 if v98 == 2
replace denom = 2 if v98 == 1
replace denom = 3 if inlist(v98,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 99he
save `99he'
local flist "`flist' `99he'"


// 1998 3167 "Landtagswahl in Bayern 1998"
// ---------------------------------------

// Election Date was on 13 Sep 1998

use $ltw/za3167, clear

gen str8 zanr = "3167"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1998"
gen intend = "30Sep1999"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v41	
lab var polint "Politicial interest"

gen men:yesno = v69 == 1 if inlist(v69,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v70,1,3)
replace agegroup = 2 if inrange(v70,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v76,1,2,3)
replace emp = 2 if v76 == 8
replace emp = 3 if v76 == 7
replace emp = 4 if v76 == 10
replace emp = 5 if inlist(v76,5,6)
replace emp = 6 if inlist(v76,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v85,8,9)
replace occ = 2 if inlist(v85,4,5,6,7)
replace occ = 3 if inlist(v85,1,2,3)
replace occ = 1 if occ == . & inlist(v78,8,9)
replace occ = 2 if occ == . & inlist(v78,4,5,6,7)
replace occ = 3 if occ == . & inlist(v78,1,2,3)
replace occ = 4 if occ == . | v78 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v73,1,4)
replace edu = 2 if v73 == 2
replace edu = 3 if v73 == 3
replace edu = 4 if v73 == 5
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,2,4,5)
replace mar = 3 if v71==3
label variable mar "Marital status"

gen denom:denom = 1 if v90 == 2
replace denom = 2 if v90 == 1
replace denom = 3 if inlist(v90,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 98by
save `98by'
local flist "`flist' `98by'"


// 1998 3168 "Landtagswahl in Mecklenburg-Vorpommern 1998"
// -------------------------------------------------------

// Election Date was on 27 Sep 1998

use $ltw/za3168, clear

gen str8 zanr = "3168"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1998"
gen intend = "26Sep1998"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "MV"

gen voter:yesno = inlist(v5,1,2,5) if inlist(v5,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v43	
lab var polint "Politicial interest"

gen men:yesno = v67 == 1 if inlist(v67,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v68,1,3)
replace agegroup = 2 if inrange(v68,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v68,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v74,1,2,3)
replace emp = 2 if v74 == 8
replace emp = 3 if v74 == 7
replace emp = 4 if v74 == 10
replace emp = 5 if inlist(v74,5,6)
replace emp = 6 if inlist(v74,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v83,8,9)
replace occ = 2 if inlist(v83,4,5,6,7)
replace occ = 3 if inlist(v83,1,2,3)
replace occ = 1 if occ == . & inlist(v76,8,9)
replace occ = 2 if occ == . & inlist(v76,4,5,6,7)
replace occ = 3 if occ == . & inlist(v76,1,2,3)
replace occ = 4 if occ == . | v76 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v71,1,6)
replace edu = 2 if v71 == 2
replace edu = 3 if inlist(v71,3,4,5)
replace edu = 4 if v71 == 7
lab var edu "Education"

gen mar:mar = 1 if v69==1
replace mar = 2 if inlist(v69,2,4,5)
replace mar = 3 if v69==3
label variable mar "Marital status"

gen denom:denom = 1 if v88 == 2
replace denom = 2 if v88 == 1
replace denom = 3 if inlist(v88,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 98mv
save `98mv'
local flist "`flist' `98mv'"

// 1999 3169 "Bürgerschaftswahl in Bremen 1999"
// --------------------------------------------

// Election Date was on 06 Jun 1999

use $ltw/za3169, clear

gen str8 zanr = "3169"
lab var zanr "Zentralarchiv study number"

gen intstart = "07Jun1999"
gen intend = "30Jun1999"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v6,1,2,5) if inlist(v6,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inrange(v8,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v49	
lab var polint "Politicial interest"

gen men:yesno = v82 == 1 if inlist(v82,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v83,1,3)
replace agegroup = 2 if inrange(v83,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v83,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v89,1,2,3)
replace emp = 2 if v89 == 8
replace emp = 3 if v89 == 7
replace emp = 4 if v89 == 10
replace emp = 5 if inlist(v89,5,6)
replace emp = 6 if inlist(v89,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v98,8,9)
replace occ = 2 if inlist(v98,4,5,6,7)
replace occ = 3 if inlist(v98,1,2,3)
replace occ = 1 if occ == . & inlist(v91,8,9)
replace occ = 2 if occ == . & inlist(v91,4,5,6,7)
replace occ = 3 if occ == . & inlist(v91,1,2,3)
replace occ = 4 if occ == . | v91 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v86,1,4)
replace edu = 2 if v86 == 2
replace edu = 3 if v86 == 3
replace edu = 4 if v86 == 5
lab var edu "Education"

gen mar:mar = 1 if v84==1
replace mar = 2 if inlist(v84,2,4,5)
replace mar = 3 if v84==3
label variable mar "Marital status"

gen denom:denom = 1 if v103 == 2
replace denom = 2 if v103 == 1
replace denom = 3 if inlist(v103,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 99hb
save `99hb'
local flist "`flist' `99hb'"



// 2001 3381 "Landtagswahl in Baden-Württemberg 2001"
// --------------------------------------------------

// Election Date was on 25 Mar 2001

use $ltw/za3381, clear

gen str8 zanr = "3381"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar2001"
gen intend = "24Mar2001"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = inlist(v6,1,2,5) if inlist(v6,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 2
replace party = 2 if v8 == 1
replace party = 3 if inrange(v8,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v41	
lab var polint "Politicial interest"

gen men:yesno = v69 == 1 if inlist(v69,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v70,1,3)
replace agegroup = 2 if inrange(v70,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v76,1,2,3)
replace emp = 2 if v76 == 8
replace emp = 3 if v76 == 7
replace emp = 4 if v76 == 10
replace emp = 5 if inlist(v76,5,6)
replace emp = 6 if inlist(v76,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v83,13,14)
replace occ = 2 if inlist(v83,4,5,6,7,8,9,10,11,12)
replace occ = 3 if inlist(v83,1,2,3)
replace occ = 1 if occ == . & inlist(v78,13,14)
replace occ = 2 if occ == . & inlist(v78,4,5,6,7,8,9,10,11,12)
replace occ = 3 if occ == . & inlist(v78,1,2,3)
replace occ = 4 if occ == . | v78 == 15
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v73,1,4)
replace edu = 2 if v73 == 2
replace edu = 3 if v73 == 3
replace edu = 4 if v73 == 5
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,2,4,5)
replace mar = 3 if v71==3
label variable mar "Marital status"

gen denom:denom = 1 if v85 == 2
replace denom = 2 if v85 == 1
replace denom = 3 if inlist(v85,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 01bw
save `01bw'
local flist "`flist' `01bw'"


// 2001 3382 "Landtagswahl in Rheinland-Pfalz 2001" 
// -----------------------------------------------

// Election Date was on 25 Mar 2001

use $ltw/za3382, clear

gen str8 zanr = "3382"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Mar2001"
gen intend = "24Mar2001"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,11)
lab var party "Electoral behaviour"

gen polint = 5 - v44	
lab var polint "Politicial interest"

gen men:yesno = v96 == 1 if inlist(v96,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v70,1,3)
replace agegroup = 2 if inrange(v70,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v76,1,2,3)
replace emp = 2 if v76 == 8
replace emp = 3 if v76 == 7
replace emp = 4 if v76 == 10
replace emp = 5 if inlist(v76,5,6)
replace emp = 6 if inlist(v76,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v85,8,9)
replace occ = 2 if inlist(v85,4,5,6,7)
replace occ = 3 if inlist(v85,1,2,3)
replace occ = 1 if occ == . & inlist(v78,8,9)
replace occ = 2 if occ == . & inlist(v78,4,5,6,7)
replace occ = 3 if occ == . & inlist(v78,1,2,3)
replace occ = 4 if occ == . | v78 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v73,1,4)
replace edu = 2 if v73 == 2
replace edu = 3 if v73 == 3
replace edu = 4 if v73 == 5
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,2,4,5)
replace mar = 3 if v71==3
label variable mar "Marital status"

gen denom:denom = 1 if v90 == 2
replace denom = 2 if v90 == 1
replace denom = 3 if inlist(v90,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 01rp
save `01rp'
local flist "`flist' `01rp'"


// 2000 3435 "Landtagswahl in Schleswig-Holstein 2000" 
// ---------------------------------------------------

// Election Date was on 27 Feb 2000

use $ltw/za3435, clear

gen str8 zanr = "3435"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Feb2000"
gen intend = "26Feb2000"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,11)
lab var party "Electoral behaviour"

gen polint = 5 - v48	
lab var polint "Politicial interest"

gen men:yesno = v99 == 1 if inlist(v99,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v73,1,3)
replace agegroup = 2 if inrange(v73,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v73,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v79,1,2,3)
replace emp = 2 if v79 == 8
replace emp = 3 if v79 == 7
replace emp = 4 if v79 == 10
replace emp = 5 if inlist(v79,5,6)
replace emp = 6 if inlist(v79,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v88,8,9)
replace occ = 2 if inlist(v88,4,5,6,7)
replace occ = 3 if inlist(v88,1,2,3)
replace occ = 1 if occ == . & inlist(v81,8,9)
replace occ = 2 if occ == . & inlist(v81,4,5,6,7)
replace occ = 3 if occ == . & inlist(v81,1,2,3)
replace occ = 4 if occ == . | v81 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v76,1,4)
replace edu = 2 if v76 == 2
replace edu = 3 if v76 == 3
replace edu = 4 if v76 == 5
lab var edu "Education"

gen mar:mar = 1 if v74==1
replace mar = 2 if inlist(v74,2,4,5)
replace mar = 3 if v74==3
label variable mar "Marital status"

gen denom:denom = 1 if v93 == 2
replace denom = 2 if v93 == 1
replace denom = 3 if inlist(v93,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 00sh
save `00sh'
local flist "`flist' `00sh'"


// 2000 3436 "Landtagswahl in Nordrhein-Westfalen 2000"
// ----------------------------------------------------

// Election Date was on 14 May 2000

use $ltw/za3436, clear

gen str8 zanr = "3436"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May2000"
gen intend = "31May2000"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 1
replace party = 2 if v9 == 2
replace party = 3 if inrange(v9,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v45	
lab var polint "Politicial interest"

gen men:yesno = v103 == 1 if inlist(v103,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v77,1,3)
replace agegroup = 2 if inrange(v77,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v77,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v83,1,2,3)
replace emp = 2 if v83 == 8
replace emp = 3 if v83 == 7
replace emp = 4 if v83 == 10
replace emp = 5 if inlist(v83,5,6)
replace emp = 6 if inlist(v83,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v92,8,9)
replace occ = 2 if inlist(v92,4,5,6,7)
replace occ = 3 if inlist(v92,1,2,3)
replace occ = 1 if occ == . & inlist(v85,8,9)
replace occ = 2 if occ == . & inlist(v85,4,5,6,7)
replace occ = 3 if occ == . & inlist(v85,1,2,3)
replace occ = 4 if occ == . | v85 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v80,1,4)
replace edu = 2 if v80 == 2
replace edu = 3 if v80 == 3
replace edu = 4 if v80 == 5
lab var edu "Education"

gen mar:mar = 1 if v78==1
replace mar = 2 if inlist(v78,2,4,5)
replace mar = 3 if v78==3
label variable mar "Marital status"

gen denom:denom = 1 if v97 == 2
replace denom = 2 if v97 == 1
replace denom = 3 if inlist(v97,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 00nw
save `00nw'
local flist "`flist' `00nw'"


// 2001 3862 "Wahl zum Abgeordnetenhaus in Berlin 2001"
// ----------------------------------------------------

// Election Date was on 21 Oct 2001

use $ltw/za3862, clear

gen str8 zanr = "3862"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct2001"
gen intend = "31Oct2001"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v9,1,2,5) if inlist(v9,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v12 == 2
replace party = 2 if v12 == 1
replace party = 3 if inrange(v12,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v53	
lab var polint "Politicial interest"

gen men:yesno = v115 == 1 if inlist(v115,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v87,1,3)
replace agegroup = 2 if inrange(v87,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v87,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v95,1,2,3)
replace emp = 2 if v95 == 8
replace emp = 3 if v95 == 7
replace emp = 4 if v95 == 10
replace emp = 5 if inlist(v95,5,6)
replace emp = 6 if inlist(v95,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v104,8,9)
replace occ = 2 if inlist(v104,4,5,6,7)
replace occ = 3 if inlist(v104,1,2,3)
replace occ = 1 if occ == . & inlist(v97,8,9)
replace occ = 2 if occ == . & inlist(v97,4,5,6,7)
replace occ = 3 if occ == . & inlist(v97,1,2,3)
replace occ = 4 if occ == . | v97 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v90,1,4) | inlist(v92,1,6)
replace edu = 2 if v90 == 2 | v92 == 2
replace edu = 3 if v90 == 3 | inlist(v92,3,4,5)
replace edu = 4 if v90 == 5 | v92 == 7
lab var edu "Education"

gen mar:mar = 1 if v88==1
replace mar = 2 if inlist(v88,2,4,5)
replace mar = 3 if v88==3
label variable mar "Marital status"

gen denom:denom = 1 if v109 == 2
replace denom = 2 if v109 == 1
replace denom = 3 if inlist(v109,3,4,5,6,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 01be
save `01be'
local flist "`flist' `01be'"


// 2001 3863 "Bürgerschaftswahl in Hamburg 2001"
// ---------------------------------------------

// Election Date was on 23 Sep 2001

use $ltw/za3863, clear

gen str8 zanr = "3863"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep2001"
gen intend = "30Sep2001"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v6,1,2,5) if inlist(v6,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inrange(v8,3,11)
lab var party "Electoral behaviour"

gen polint = 5 - v49	
lab var polint "Politicial interest"

gen men:yesno = v107 == 1 if inlist(v107,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v81,1,3)
replace agegroup = 2 if inrange(v81,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v81,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if v87 == 8
replace emp = 3 if v87 == 7
replace emp = 4 if v87 == 10
replace emp = 5 if inlist(v87,5,6)
replace emp = 6 if inlist(v87,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v96,8,9)
replace occ = 2 if inlist(v96,4,5,6,7)
replace occ = 3 if inlist(v96,1,2,3)
replace occ = 1 if occ == . & inlist(v89,8,9)
replace occ = 2 if occ == . & inlist(v89,4,5,6,7)
replace occ = 3 if occ == . & inlist(v89,1,2,3)
replace occ = 4 if occ == . | v89 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v84,1,4)
replace edu = 2 if v84 == 2
replace edu = 3 if v84 == 3
replace edu = 4 if v84 == 5
lab var edu "Education"

gen mar:mar = 1 if v82==1
replace mar = 2 if inlist(v82,2,4,5)
replace mar = 3 if v82==3
label variable mar "Marital status"

gen denom:denom = 1 if v101 == 2
replace denom = 2 if v101 == 1
replace denom = 3 if inlist(v101,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 01hh
save `01hh'
local flist "`flist' `01hh'"

// 2002 3864 "Landtagswahl in Mecklenburg-Vorpommern 2002"
// -------------------------------------------------------

// Election Date was on 22 Sep 2002

use $ltw/za3864, clear

gen str8 zanr = "3864"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep2002"
gen intend = "30Sep2002"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "MV"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,9)
lab var party "Electoral behaviour"

gen polint = 5 - v42	
lab var polint "Politicial interest"

gen men:yesno = v96 == 1 if inlist(v96,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v70,1,3)
replace agegroup = 2 if inrange(v70,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v70,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v76,1,2,3)
replace emp = 2 if v76 == 8
replace emp = 3 if v76 == 7
replace emp = 4 if v76 == 10
replace emp = 5 if inlist(v76,5,6)
replace emp = 6 if inlist(v76,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v85,8,9)
replace occ = 2 if inlist(v85,4,5,6,7)
replace occ = 3 if inlist(v85,1,2,3)
replace occ = 1 if occ == . & inlist(v78,8,9)
replace occ = 2 if occ == . & inlist(v78,4,5,6,7)
replace occ = 3 if occ == . & inlist(v78,1,2,3)
replace occ = 4 if occ == . | v78 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v73,1,6)
replace edu = 2 if v73 == 2
replace edu = 3 if inlist(v73,3,4,5)
replace edu = 4 if v73 == 7
lab var edu "Education"

gen mar:mar = 1 if v71==1
replace mar = 2 if inlist(v71,2,4,5)
replace mar = 3 if v71==3
label variable mar "Marital status"

gen denom:denom = 1 if v90 == 2
replace denom = 2 if v90 == 1
replace denom = 3 if inlist(v90,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 02mv
save `02mv'
local flist "`flist' `02mv'"

// 2002 3865 "Landtagswahl in Sachsen-Anhalt 2002"
// -----------------------------------------------

// Election Date was on 21 Apr 2002

use $ltw/za3865, clear

gen str8 zanr = "3865"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Apr2002"
gen intend = "30Apr2002"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "ST"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen ***
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v44	
lab var polint "Politicial interest"

gen men:yesno = v107 == 1 if inlist(v107,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v81,1,3)
replace agegroup = 2 if inrange(v81,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v81,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v87,1,2,3)
replace emp = 2 if v87 == 8
replace emp = 3 if v87 == 7
replace emp = 4 if v87 == 10
replace emp = 5 if inlist(v87,5,6)
replace emp = 6 if inlist(v87,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v96,8,9)
replace occ = 2 if inlist(v96,4,5,6,7)
replace occ = 3 if inlist(v96,1,2,3)
replace occ = 1 if occ == . & inlist(v89,8,9)
replace occ = 2 if occ == . & inlist(v89,4,5,6,7)
replace occ = 3 if occ == . & inlist(v89,1,2,3)
replace occ = 4 if occ == . | v89 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v84,1,6)
replace edu = 2 if v84 == 2
replace edu = 3 if inlist(v84,3,4,5)	
replace edu = 4 if v84 == 7
lab var edu "Education"

gen mar:mar = 1 if v82==1
replace mar = 2 if inlist(v82,2,4,5)
replace mar = 3 if v82==3
label variable mar "Marital status"

gen denom:denom = 1 if v101 == 2
replace denom = 2 if v101 == 1
replace denom = 3 if inlist(v101,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 02st
save `02st'
local flist "`flist' `02st'"

// 2003 3866 "Landtagswahl in Hessen 2003"
// ---------------------------------------

// Election Date was on 02 Feb 2003

use $ltw/za3866, clear

gen str8 zanr = "3866"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jan2003"
gen intend = "31Jan2003"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v51	
lab var polint "Politicial interest"

gen men:yesno = v103 == 1 if inlist(v103,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v77,1,3)
replace agegroup = 2 if inrange(v77,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v77,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v83,1,2,3)
replace emp = 2 if v83 == 8
replace emp = 3 if v83 == 7
replace emp = 4 if v83 == 10
replace emp = 5 if inlist(v83,5,6)
replace emp = 6 if inlist(v83,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v92,8,9)
replace occ = 2 if inlist(v92,4,5,6,7)
replace occ = 3 if inlist(v92,1,2,3)
replace occ = 1 if occ == . & inlist(v85,8,9)
replace occ = 2 if occ == . & inlist(v85,4,5,6,7)
replace occ = 3 if occ == . & inlist(v85,1,2,3)
replace occ = 4 if occ == . | v85 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v80,1,4)
replace edu = 2 if v80 == 2
replace edu = 3 if v80 == 3	
replace edu = 4 if v80 == 5
lab var edu "Education"

gen mar:mar = 1 if v78==1
replace mar = 2 if inlist(v78,2,4,5)
replace mar = 3 if v78==3
label variable mar "Marital status"

gen denom:denom = 1 if v97 == 2
replace denom = 2 if v97 == 1
replace denom = 3 if inlist(v97,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 03he
save `03he'
local flist "`flist' `03he'"


// 2003 3867 "Landtagswahl in Niedersachsen 2003"
// ----------------------------------------------

// Election Date was on 02 Feb 2003

use $ltw/za3867, clear

gen str8 zanr = "3867"
lab var zanr "Zentralarchiv study number"

gen intstart = "03Feb2003"
gen intend = "28Feb2003"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v50	
lab var polint "Politicial interest"

gen men:yesno = v102 == 1 if inlist(v102,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v76,1,3)
replace agegroup = 2 if inrange(v76,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v76,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v82,1,2,3)
replace emp = 2 if v82 == 8
replace emp = 3 if v82 == 7
replace emp = 4 if v82 == 10
replace emp = 5 if inlist(v82,5,6)
replace emp = 6 if inlist(v82,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v91,8,9)
replace occ = 2 if inlist(v91,4,5,6,7)
replace occ = 3 if inlist(v91,1,2,3)
replace occ = 1 if occ == . & inlist(v84,8,9)
replace occ = 2 if occ == . & inlist(v84,4,5,6,7)
replace occ = 3 if occ == . & inlist(v84,1,2,3)
replace occ = 4 if occ == . | v84 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v79,1,4)
replace edu = 2 if v79 == 2
replace edu = 3 if v79 == 3	
replace edu = 4 if v79 == 5
lab var edu "Education"

gen mar:mar = 1 if v77==1
replace mar = 2 if inlist(v77,2,4,5)
replace mar = 3 if v77==3
label variable mar "Marital status"

gen denom:denom = 1 if v96 == 2
replace denom = 2 if v96 == 1
replace denom = 3 if inlist(v96,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 03ni
save `03ni'
local flist "`flist' `03ni'"



// 1999 3894 "Wahl zum Abgeordnetenhaus in Berlin 1999"
// ----------------------------------------------------

// Election Date was on 19 Oct 1999

use $ltw/za3894, clear

gen str8 zanr = "3894"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1999"
gen intend = "31Oct1999"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v50	
lab var polint "Politicial interest"

gen men:yesno = v109 == 1 if inlist(v109,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v82,1,3)
replace agegroup = 2 if inrange(v82,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v82,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v89,1,2,3)
replace emp = 2 if v89 == 8
replace emp = 3 if v89 == 7
replace emp = 4 if v89 == 10
replace emp = 5 if inlist(v89,5,6)
replace emp = 6 if inlist(v89,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v98,8,9)
replace occ = 2 if inlist(v98,4,5,6,7)
replace occ = 3 if inlist(v98,1,2,3)
replace occ = 1 if occ == . & inlist(v91,8,9)
replace occ = 2 if occ == . & inlist(v91,4,5,6,7)
replace occ = 3 if occ == . & inlist(v91,1,2,3)
replace occ = 4 if occ == . | v91 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v85,1,4) | inlist(v86,1,6)
replace edu = 2 if v85 == 2 | v86 == 2
replace edu = 3 if v85 == 3 | inlist(v86,3,4,5)
replace edu = 4 if v85 == 5 | v86 == 7
lab var edu "Education"

gen mar:mar = 1 if v83==1
replace mar = 2 if inlist(v83,2,4,5)
replace mar = 3 if v83==3
label variable mar "Marital status"

gen denom:denom = 1 if v103 == 2
replace denom = 2 if v103 == 1
replace denom = 3 if inlist(v103,3,4,9)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 99be
save `99be'
local flist "`flist' `99be'"


// 1999 3895 "Landtagswahl in Brandenburg 1999"
// --------------------------------------------

// Election Date was on 05 Sep 1999

use $ltw/za3895, clear

gen str8 zanr = "3895"
lab var zanr "Zentralarchiv study number"

gen intstart = "06Sep1999"
gen intend = "30Sep1999"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BB"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v44	
lab var polint "Politicial interest"

gen men:yesno = v103 == 1 if inlist(v103,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v77,1,3)
replace agegroup = 2 if inrange(v77,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v77,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v83,1,2,3)
replace emp = 2 if v83 == 8
replace emp = 3 if v83 == 7
replace emp = 4 if v83 == 10
replace emp = 5 if inlist(v83,5,6)
replace emp = 6 if inlist(v83,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v92,8,9)
replace occ = 2 if inlist(v92,4,5,6,7)
replace occ = 3 if inlist(v92,1,2,3)
replace occ = 1 if occ == . & inlist(v85,8,9)
replace occ = 2 if occ == . & inlist(v85,4,5,6,7)
replace occ = 3 if occ == . & inlist(v85,1,2,3)
replace occ = 4 if occ == . | v85 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v80neu,1,6)
replace edu = 2 if v80neu == 2
replace edu = 3 if inlist(v80neu,3,4,5)
replace edu = 4 if v80neu == 7
lab var edu "Education"

gen mar:mar = 1 if v78==1
replace mar = 2 if inlist(v78,2,4,5)
replace mar = 3 if v78==3
label variable mar "Marital status"

gen denom:denom = 1 if v97 == 2
replace denom = 2 if v97 == 1
replace denom = 3 if inlist(v97,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 99bb
save `99bb'
local flist "`flist' `99bb'"


// 1999 3896 "Landtagswahl im Saarland 1999"
// -----------------------------------------

// Election Date was on 05 Sep 1999

use $ltw/za3896, clear

gen str8 zanr = "3896"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Aug1999"
gen intend = "31Oct1999"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "SL"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 1
replace party = 2 if v9 == 2
replace party = 3 if inrange(v9,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v46	
lab var polint "Politicial interest"

gen men:yesno = v97 == 1 if inlist(v97,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v71,1,3)
replace agegroup = 2 if inrange(v71,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v71,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v77,1,2,3)
replace emp = 2 if v77 == 8
replace emp = 3 if v77 == 7
replace emp = 4 if v77 == 10
replace emp = 5 if inlist(v77,5,6)
replace emp = 6 if inlist(v77,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v86,8,9)
replace occ = 2 if inlist(v86,4,5,6,7)
replace occ = 3 if inlist(v86,1,2,3)
replace occ = 1 if occ == . & inlist(v79,8,9)
replace occ = 2 if occ == . & inlist(v79,4,5,6,7)
replace occ = 3 if occ == . & inlist(v79,1,2,3)
replace occ = 4 if occ == . | v79 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v74,1,4)
replace edu = 2 if v74 == 2
replace edu = 3 if v74 == 3
replace edu = 4 if v74 == 5
lab var edu "Education"

gen mar:mar = 1 if v72==1
replace mar = 2 if inlist(v72,2,4,5)
replace mar = 3 if v72==3
label variable mar "Marital status"

gen denom:denom = 1 if v91 == 2
replace denom = 2 if v91 == 1
replace denom = 3 if inlist(v91,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 99sl
save `99sl'
local flist "`flist' `99sl'"



// 1999 3897 "Landtagswahl in Sachsen 1999"
// ----------------------------------------

// Election Date was on 19 Sep 1999

use $ltw/za3897, clear

gen str8 zanr = "3897"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1999"
gen intend = "30Sep1999"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "SN"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,11)
lab var party "Electoral behaviour"

gen polint = 5 - v46	
lab var polint "Politicial interest"

gen men:yesno = v102 == 1 if inlist(v102,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v76,1,3)
replace agegroup = 2 if inrange(v76,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v76,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v82,1,2,3)
replace emp = 2 if v82 == 8
replace emp = 3 if v82 == 7
replace emp = 4 if v82 == 10
replace emp = 5 if inlist(v82,5,6)
replace emp = 6 if inlist(v82,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v91,8,9)
replace occ = 2 if inlist(v91,4,5,6,7)
replace occ = 3 if inlist(v91,1,2,3)
replace occ = 1 if occ == . & inlist(v84,8,9)
replace occ = 2 if occ == . & inlist(v84,4,5,6,7)
replace occ = 3 if occ == . & inlist(v84,1,2,3)
replace occ = 4 if occ == . | v84 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v79,1,6)
replace edu = 2 if v79 == 2
replace edu = 3 if inlist(v79,3,4,5)
replace edu = 4 if v79 == 7
lab var edu "Education"

gen mar:mar = 1 if v77==1
replace mar = 2 if inlist(v77,2,4,5)
replace mar = 3 if v77==3
label variable mar "Marital status"

gen denom:denom = 1 if v96 == 2
replace denom = 2 if v96 == 1
replace denom = 3 if inlist(v96,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 99sn
save `99sn'
local flist "`flist' `99sn'"


// 1999 3898 "Landtagswahl in Thüringen 1999"
// ------------------------------------------

// Election Date was on 12 Sep 1999

use $ltw/za3898, clear

gen str8 zanr = "3898"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1999"
gen intend = "30Sep1999"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "TH"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,10)
lab var party "Electoral behaviour"

gen polint = 5 - v46	
lab var polint "Politicial interest"

gen men:yesno = v104 == 1 if inlist(v104,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v78,1,3)
replace agegroup = 2 if inrange(v78,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v78,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v84,1,2,3)
replace emp = 2 if v84 == 8
replace emp = 3 if v84 == 7
replace emp = 4 if v84 == 10
replace emp = 5 if inlist(v84,5,6)
replace emp = 6 if inlist(v84,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v93,8,9)
replace occ = 2 if inlist(v93,4,5,6,7)
replace occ = 3 if inlist(v93,1,2,3)
replace occ = 1 if occ == . & inlist(v86,8,9)
replace occ = 2 if occ == . & inlist(v86,4,5,6,7)
replace occ = 3 if occ == . & inlist(v86,1,2,3)
replace occ = 4 if occ == . | v86 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v81,1,6)
replace edu = 2 if v81 == 2
replace edu = 3 if inlist(v81,3,4,5)
replace edu = 4 if v81 == 7
lab var edu "Education"

gen mar:mar = 1 if v79==1
replace mar = 2 if inlist(v79,2,4,5)
replace mar = 3 if v79==3
label variable mar "Marital status"

gen denom:denom = 1 if v98 == 2
replace denom = 2 if v98 == 1
replace denom = 3 if inlist(v98,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 99th
save `99th'
local flist "`flist' `99th'"


// 2003 3953 "Bürgerschaftswahl in Bremen 2003"
// --------------------------------------------

// Election Date was on 25 May 2003

use $ltw/za3953, clear

gen str8 zanr = "3953"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May2003"
gen intend = "24May2003"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 1
replace party = 2 if v9 == 2
replace party = 3 if inrange(v9,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v50	
lab var polint "Politicial interest"

gen men:yesno = v104 == 1 if inlist(v104,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v79,1,3)
replace agegroup = 2 if inrange(v79,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v79,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v85,1,2,3)
replace emp = 2 if v85 == 8
replace emp = 3 if v85 == 7
replace emp = 4 if v85 == 10
replace emp = 5 if inlist(v85,5,6)
replace emp = 6 if inlist(v85,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v94,8,9)
replace occ = 2 if inlist(v94,4,5,6,7)
replace occ = 3 if inlist(v94,1,2,3)
replace occ = 1 if occ == . & inlist(v87,8,9)
replace occ = 2 if occ == . & inlist(v87,4,5,6,7)
replace occ = 3 if occ == . & inlist(v87,1,2,3)
replace occ = 4 if occ == . | v87 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v82,1,4)
replace edu = 2 if v82 == 2
replace edu = 3 if v82 == 3
replace edu = 4 if v82 == 5
lab var edu "Education"

gen mar:mar = 1 if v80==1
replace mar = 2 if inlist(v80,2,4,5)
replace mar = 3 if v80==3
label variable mar "Marital status"

gen denom:denom = 1 if v99 == 2
replace denom = 2 if v99 == 1
replace denom = 3 if inlist(v99,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 03hb
save `03hb'
local flist "`flist' `03hb'"


// 2003 3955 "Landtagswahl in Bayern 2003"
// ---------------------------------------

// Election Date was on 21 Sep 2003

use $ltw/za3955, clear

gen str8 zanr = "3955"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep2003"
gen intend = "30Sep2003"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BY"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 2
replace party = 2 if v9 == 1
replace party = 3 if inrange(v9,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v40	
lab var polint "Politicial interest"

gen men:yesno = v94 == 1 if inlist(v94,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v68,1,3)
replace agegroup = 2 if inrange(v68,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v68,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v74,1,2,3)
replace emp = 2 if v74 == 8
replace emp = 3 if v74 == 7
replace emp = 4 if v74 == 10
replace emp = 5 if inlist(v74,5,6)
replace emp = 6 if inlist(v74,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v83,8,9)
replace occ = 2 if inlist(v83,4,5,6,7)
replace occ = 3 if inlist(v83,1,2,3)
replace occ = 1 if occ == . & inlist(v76,8,9)
replace occ = 2 if occ == . & inlist(v76,4,5,6,7)
replace occ = 3 if occ == . & inlist(v76,1,2,3)
replace occ = 4 if occ == . | v76 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v71,1,4)
replace edu = 2 if v71 == 2
replace edu = 3 if v71 == 3
replace edu = 4 if v71 == 5
lab var edu "Education"

gen mar:mar = 1 if v69==1
replace mar = 2 if inlist(v69,2,4,5)
replace mar = 3 if v69==3
label variable mar "Marital status"

gen denom:denom = 1 if v88 == 2
replace denom = 2 if v88 == 1
replace denom = 3 if inlist(v88,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 03by
save `03by'
local flist "`flist' `03by'"



// 2004 3990 "Bürgerschaftswahl in Hamburg 2004"
// ---------------------------------------------

// Election Date was on 29 Feb 2004

use $ltw/za3990, clear

gen str8 zanr = "3990"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Feb2004"
gen intend = "28Feb2004"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v6,1,2,5) if inlist(v6,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v8 == 1
replace party = 2 if v8 == 2
replace party = 3 if inrange(v8,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v57	
lab var polint "Politicial interest"

gen men:yesno = v111 == 1 if inlist(v111,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v86,1,3)
replace agegroup = 2 if inrange(v86,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v86,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v92,1,2,3)
replace emp = 2 if v92 == 8
replace emp = 3 if v92 == 7
replace emp = 4 if v92 == 10
replace emp = 5 if inlist(v92,5,6)
replace emp = 6 if inlist(v92,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v101,8,9)
replace occ = 2 if inlist(v101,4,5,6,7)
replace occ = 3 if inlist(v101,1,2,3)
replace occ = 1 if occ == . & inlist(v94,8,9)
replace occ = 2 if occ == . & inlist(v94,4,5,6,7)
replace occ = 3 if occ == . & inlist(v94,1,2,3)
replace occ = 4 if occ == . | v94 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v89,1,4)
replace edu = 2 if v89 == 2
replace edu = 3 if v89 == 3
replace edu = 4 if v89 == 5
lab var edu "Education"

gen mar:mar = 1 if v87==1
replace mar = 2 if inlist(v87,2,4,5)
replace mar = 3 if v87==3
label variable mar "Marital status"

gen denom:denom = 1 if v106 == 2
replace denom = 2 if v106 == 1
replace denom = 3 if inlist(v106,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 04hh
save `04hh'
local flist "`flist' `04hh'"


// 2004 3991 "Landtagswahl in Thüringen 2004"
// ------------------------------------------

// Election Date was on 13 Jun 2004

use $ltw/za3991, clear

gen str8 zanr = "3991"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jun2004"
gen intend = "30Jun2004"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "TH"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v55	
lab var polint "Politicial interest"

gen men:yesno = v109 == 1 if inlist(v109,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v84,1,3)
replace agegroup = 2 if inrange(v84,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v84,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v90,1,2,3)
replace emp = 2 if v90 == 8
replace emp = 3 if v90 == 7
replace emp = 4 if v90 == 10
replace emp = 5 if inlist(v90,5,6)
replace emp = 6 if inlist(v90,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v99,8,9)
replace occ = 2 if inlist(v99,4,5,6,7)
replace occ = 3 if inlist(v99,1,2,3)
replace occ = 1 if occ == . & inlist(v92,8,9)
replace occ = 2 if occ == . & inlist(v92,4,5,6,7)
replace occ = 3 if occ == . & inlist(v92,1,2,3)
replace occ = 4 if occ == . | v92 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v87,1,6)
replace edu = 2 if v87 == 2
replace edu = 3 if inlist(v87,3,4,5)
replace edu = 4 if v87 == 7
lab var edu "Education"

gen mar:mar = 1 if v85==1
replace mar = 2 if inlist(v85,2,4,5)
replace mar = 3 if v85==3
label variable mar "Marital status"

gen denom:denom = 1 if v104 == 2
replace denom = 2 if v104 == 1
replace denom = 3 if inlist(v104,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 04th
save `04th'
local flist "`flist' `04th'"

// 2004 3992 "Landtagswahl in Brandenburg 2004"
// --------------------------------------------

// Election Date was on 19 Sep 2004

use $ltw/za3992, clear

gen str8 zanr = "3992"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep2004"
gen intend = "30Sep2004"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "BB"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 1
replace party = 2 if v10 == 2
replace party = 3 if inrange(v10,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v55	
lab var polint "Politicial interest"

gen men:yesno = v120 == 1 if inlist(v120,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v95,1,3)
replace agegroup = 2 if inrange(v95,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v95,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v101,1,2,3)
replace emp = 2 if v101 == 8
replace emp = 3 if v101 == 7
replace emp = 4 if v101 == 10
replace emp = 5 if inlist(v101,5,6)
replace emp = 6 if inlist(v101,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v110,8,9)
replace occ = 2 if inlist(v110,4,5,6,7)
replace occ = 3 if inlist(v110,1,2,3)
replace occ = 1 if occ == . & inlist(v103,8,9)
replace occ = 2 if occ == . & inlist(v103,4,5,6,7)
replace occ = 3 if occ == . & inlist(v103,1,2,3)
replace occ = 4 if occ == . | v103 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v98,1,6)
replace edu = 2 if v98 == 2
replace edu = 3 if inlist(v98,3,4,5)
replace edu = 4 if v98 == 7
lab var edu "Education"

gen mar:mar = 1 if v96==1
replace mar = 2 if inlist(v96,2,4,5)
replace mar = 3 if v96==3
label variable mar "Marital status"

gen denom:denom = 1 if v115 == 2
replace denom = 2 if v115 == 1
replace denom = 3 if inlist(v115,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 04bb
save `04bb'
local flist "`flist' `04bb'"

// 2004 3993 "Landtagswahl im Saarland 2004"
// -----------------------------------------

// Election Date was on 05 Sep 2004

use $ltw/za3993, clear

gen str8 zanr = "3993"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Aug2004"
gen intend = "04Sep2004"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "SL"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v9 == 2
replace party = 2 if v9 == 1
replace party = 3 if inrange(v9,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v49	
lab var polint "Politicial interest"

gen men:yesno = v105 == 1 if inlist(v105,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v79,1,3)
replace agegroup = 2 if inrange(v79,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v79,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v85,1,2,3)
replace emp = 2 if v85 == 8
replace emp = 3 if v85 == 7
replace emp = 4 if v85 == 10
replace emp = 5 if inlist(v85,5,6)
replace emp = 6 if inlist(v85,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v94,8,9)
replace occ = 2 if inlist(v94,4,5,6,7)
replace occ = 3 if inlist(v94,1,2,3)
replace occ = 1 if occ == . & inlist(v87,8,9)
replace occ = 2 if occ == . & inlist(v87,4,5,6,7)
replace occ = 3 if occ == . & inlist(v87,1,2,3)
replace occ = 4 if occ == . | v87 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v82,1,4)
replace edu = 2 if v82 == 2
replace edu = 3 if v82 == 3
replace edu = 4 if v82 == 5
lab var edu "Education"

gen mar:mar = 1 if v80==1
replace mar = 2 if inlist(v80,2,4,5)
replace mar = 3 if v80==3
label variable mar "Marital status"

gen denom:denom = 1 if v99 == 2
replace denom = 2 if v99 == 1
replace denom = 3 if inlist(v99,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 04sl
save `04sl'
local flist "`flist' `04sl'"

// 2004 3994 "Landtagswahl in Sachsen 2004"
// ----------------------------------------

// Election Date was on 19 Sep 2004

use $ltw/za3994, clear

gen str8 zanr = "3994"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep2004"
gen intend = "30Sep2004"

gen id = v3
lab var id "Original idenifier"
isid id

gen area = "SN"

gen voter:yesno = inlist(v7,1,2,5) if inlist(v7,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v10 == 2
replace party = 2 if v10 == 1
replace party = 3 if inrange(v10,3,7)
lab var party "Electoral behaviour"

gen polint = 5 - v55	
lab var polint "Politicial interest"

gen men:yesno = v118 == 1 if inlist(v118,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v92,1,3)
replace agegroup = 2 if inrange(v92,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v92,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v98,1,2,3)
replace emp = 2 if v98 == 8
replace emp = 3 if v98 == 7
replace emp = 4 if v98 == 10
replace emp = 5 if inlist(v98,5,6)
replace emp = 6 if inlist(v98,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v107,8,9)
replace occ = 2 if inlist(v107,4,5,6,7)
replace occ = 3 if inlist(v107,1,2,3)
replace occ = 1 if occ == . & inlist(v100,8,9)
replace occ = 2 if occ == . & inlist(v100,4,5,6,7)
replace occ = 3 if occ == . & inlist(v100,1,2,3)
replace occ = 4 if occ == . | v100 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v95,1,6)
replace edu = 2 if v95 == 2
replace edu = 3 if inlist(v95,3,4,5)
replace edu = 4 if v95 == 7
lab var edu "Education"

gen mar:mar = 1 if v93==1
replace mar = 2 if inlist(v93,2,4,5)
replace mar = 3 if v93==3
label variable mar "Marital status"

gen denom:denom = 1 if v112 == 2
replace denom = 2 if v112 == 1
replace denom = 3 if inlist(v112,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 04sn
save `04sn'
local flist "`flist' `04sn'"

// 1990 19661 "Wahl zum Abgeordnetenhaus in Berlin 1990"
// -----------------------------------------------------

// Election Date was on 14 Oct 1990

use $ltw/za19661, clear

gen str8 zanr = "19661"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1990"
gen intend = "13Oct1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = v4 == 1 if v4 != 2
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inrange(v6,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v60 == 1 if inlist(v60,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v61,1,3)
replace agegroup = 2 if inrange(v61,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v61,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v67,1,2)
replace emp = 2 if inlist(v67,3,4)
replace emp = 3 if inlist(v67,6,7)			// 6 = rentner mit arbeitsverhältnis
replace emp = 4 if v67 == 8
replace emp = 5 if v67 == 9
replace emp = 6 if inlist(v67,5,98)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v68,5,6,9)
replace occ = 2 if inlist(v68,3,4)
replace occ = 3 if inlist(v68,1,2,7,8)
replace occ = 4 if v68 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if v65 == 1
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 9
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,3,4,5,6)
replace mar = 3 if v64==2
label variable mar "Marital status"

xtile hhinc = v72, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v62 == 1
replace denom = 2 if v62 == 2
replace denom = 3 if inlist(v62,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90be
save `90be'
local flist "`flist' `90be'"

// 1990 19662 "Landtagswahl in Brandenburg 1990"
// ---------------------------------------------

// Election Date was on 14 Oct 1990

use $ltw/za19662, clear

gen str8 zanr = "19662"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1990"
gen intend = "13Oct1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "BB"

gen voter:yesno = v5 == 1 if v5 != 2
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inrange(v6,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v60 == 1 if inlist(v60,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v61,1,3)
replace agegroup = 2 if inrange(v61,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v61,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v67,1,2)
replace emp = 2 if inlist(v67,3,4)
replace emp = 3 if inlist(v67,6,7)			// 6 = rentner mit arbeitsverhältnis
replace emp = 4 if v67 == 8
replace emp = 5 if v67 == 9
replace emp = 6 if inlist(v67,5,98)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v68,5,6,9)
replace occ = 2 if inlist(v68,3,4)
replace occ = 3 if inlist(v68,1,2,7,8)
replace occ = 4 if v68 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if v65 == 1
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 9
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,3,4,5,6)
replace mar = 3 if v64==2
label variable mar "Marital status"

xtile hhinc = v72, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v62 == 1
replace denom = 2 if v62 == 2
replace denom = 3 if inlist(v62,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90bb
save `90bb'
local flist "`flist' `90bb'"

// 1990 19663 "Landtagswahl in Sachsen 1990"
// -----------------------------------------

// Election Date was on 14 Oct 1990

use $ltw/za19663, clear

gen str8 zanr = "19663"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1990"
gen intend = "13Oct1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "SN"

gen voter:yesno = v5 == 1 if v5 != 2
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inrange(v6,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v60 == 1 if inlist(v60,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v61,1,3)
replace agegroup = 2 if inrange(v61,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v61,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v67,1,2)
replace emp = 2 if inlist(v67,3,4)
replace emp = 3 if inlist(v67,6,7)			// 6 = rentner mit arbeitsverhältnis
replace emp = 4 if v67 == 8
replace emp = 5 if v67 == 9
replace emp = 6 if inlist(v67,5,98)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v68,5,6,9)
replace occ = 2 if inlist(v68,3,4)
replace occ = 3 if inlist(v68,1,2,7,8)
replace occ = 4 if v68 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if v65 == 1
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 9
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,3,4,5,6)
replace mar = 3 if v64==2
label variable mar "Marital status"

xtile hhinc = v72, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v62 == 1
replace denom = 2 if v62 == 2
replace denom = 3 if inlist(v62,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90sn
save `90sn'
local flist "`flist' `90sn'"

// 1990 19664 "Landtagswahl in Sachsen-Anhalt 1990"
// ------------------------------------------------

// Election Date was on 14 Oct 1990

use $ltw/za19664, clear

gen str8 zanr = "19664"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1990"
gen intend = "13Oct1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "ST"

gen voter:yesno = v5 == 1 if v5 != 2
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inrange(v6,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v60 == 1 if inlist(v60,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v61,1,3)
replace agegroup = 2 if inrange(v61,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v61,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v67,1,2)
replace emp = 2 if inlist(v67,3,4)
replace emp = 3 if inlist(v67,6,7)			// 6 = rentner mit arbeitsverhältnis
replace emp = 4 if v67 == 8
replace emp = 5 if v67 == 9
replace emp = 6 if inlist(v67,5,98)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v68,5,6,9)
replace occ = 2 if inlist(v68,3,4)
replace occ = 3 if inlist(v68,1,2,7,8)
replace occ = 4 if v68 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if v65 == 1
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 9
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,3,4,5,6)
replace mar = 3 if v64==2
label variable mar "Marital status"

xtile hhinc = v72, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v62 == 1
replace denom = 2 if v62 == 2
replace denom = 3 if inlist(v62,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90st
save `90st'
local flist "`flist' `90st'"

// 1990 19665 "Landtagswahl in Mecklenburg-Vorpommern 1990"
// --------------------------------------------------------

// Election Date was on 14 Oct 1990

use $ltw/za19665, clear

gen str8 zanr = "19665"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1990"
gen intend = "13Oct1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "MV"

gen voter:yesno = v5 == 1 if v5 != 2
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inrange(v6,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v60 == 1 if inlist(v60,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v61,1,3)
replace agegroup = 2 if inrange(v61,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v61,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v67,1,2)
replace emp = 2 if inlist(v67,3,4)
replace emp = 3 if inlist(v67,6,7)			// 6 = rentner mit arbeitsverhältnis
replace emp = 4 if v67 == 8
replace emp = 5 if v67 == 9
replace emp = 6 if inlist(v67,5,98)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v68,5,6,9)
replace occ = 2 if inlist(v68,3,4)
replace occ = 3 if inlist(v68,1,2,7,8)
replace occ = 4 if v68 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if v65 == 1
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 9
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,3,4,5,6)
replace mar = 3 if v64==2
label variable mar "Marital status"

xtile hhinc = v72, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v62 == 1
replace denom = 2 if v62 == 2
replace denom = 3 if inlist(v62,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90mv
save `90mv'
local flist "`flist' `90mv'"


// 1990 19666 "Landtagswahl in Thüringen 1990"
// -------------------------------------------

// Election Date was on 14 Oct 1990

use $ltw/za19666, clear

gen str8 zanr = "19666"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1990"
gen intend = "13Oct1990"

gen id = v2
lab var id "Original idenifier"
isid id

gen area = "TH"

gen voter:yesno = v5 == 1 if v5 != 2
lab var voter "Voter y/n"

gen party:party = 1 if v6 == 2
replace party = 2 if v6 == 1
replace party = 3 if inrange(v6,3,8)
lab var party "Electoral behaviour"

gen men:yesno = v60 == 1 if inlist(v60,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v61,1,3)
replace agegroup = 2 if inrange(v61,4,8)		// 2=30-59
replace agegroup = 3 if inrange(v61,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v67,1,2)
replace emp = 2 if inlist(v67,3,4)
replace emp = 3 if inlist(v67,6,7)			// 6 = rentner mit arbeitsverhältnis
replace emp = 4 if v67 == 8
replace emp = 5 if v67 == 9
replace emp = 6 if inlist(v67,5,98)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(v68,5,6,9)
replace occ = 2 if inlist(v68,3,4)
replace occ = 3 if inlist(v68,1,2,7,8)
replace occ = 4 if v68 == 10
lab var occ "Occupational status"

gen edu:edu = 1 if v65 == 1
replace edu = 2 if v65 == 2
replace edu = 3 if v65 == 3
replace edu = 4 if v65 == 9
lab var edu "Education"

gen mar:mar = 1 if v64==1
replace mar = 2 if inlist(v64,3,4,5,6)
replace mar = 3 if v64==2
label variable mar "Marital status"

xtile hhinc = v72, nq(3)
label variable hhinc "Houshold income"
label value hhinc hhinc

gen denom:denom = 1 if v62 == 1
replace denom = 2 if v62 == 2
replace denom = 3 if inlist(v62,3,4)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90th
save `90th'
local flist "`flist' `90th'"


// 2005 4394 "Landtagswahl in Schleswig-Holstein 2005"
// ---------------------------------------------------

// Election Date was on 20 Feb 2005

use $ltw/za4394, clear

gen str8 zanr = "4394"
lab var zanr "Zentralarchiv study number"

gen intstart = "15Feb2005"
gen intend = "18Feb2005"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "SH"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3d == 1
replace party = 2 if v3d == 2
replace party = 3 if inrange(v3d,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v13 if v13 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vo,8,9)
replace occ = 2 if inlist(vo,4,5,6,7)
replace occ = 3 if inlist(vo,1,2,3)
replace occ = 1 if vo == 0 & inlist(vl,8,9)
replace occ = 2 if vo == 0 & inlist(vl,4,5,6,7)
replace occ = 3 if vo == 0 & inlist(vl,1,2,3)
replace occ = 4 if vo == 0 & vl == 0 | vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 05sh
save `05sh'
local flist "`flist' `05sh'"



// 2005 4396 "Landtagswahl in Nordrhein-Westfalen 2005"
// ---------------------------------------------------

// Election Date was on 22 May 2005

use $ltw/za4396, clear

gen str8 zanr = "4396"
lab var zanr "Zentralarchiv study number"

gen intstart = "17May2005"
gen intend = "20May2005"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "NW"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3c == 1
replace party = 2 if v3c == 2
replace party = 3 if inrange(v3c,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v13 if v13 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vo,8,9)
replace occ = 2 if inlist(vo,4,5,6,7)
replace occ = 3 if inlist(vo,1,2,3)
replace occ = 1 if vo == 0 & inlist(vl,8,9)
replace occ = 2 if vo == 0 & inlist(vl,4,5,6,7)
replace occ = 3 if vo == 0 & inlist(vl,1,2,3)
replace occ = 4 if vo == 0 & vl == 0 | vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 05nw
save `05nw'
local flist "`flist' `05nw'"



// 2006 4399 "Landtagswahl in Baden-Württemberg 2006"
// --------------------------------------------------

// Election Date was on 26 Mar 2006

use $ltw/za4399, clear

gen str8 zanr = "4399"
lab var zanr "Zentralarchiv study number"

gen intstart = "20Mar2006"
gen intend = "24Mar2006"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "BW"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3c == 2
replace party = 2 if v3c == 1
replace party = 3 if inrange(v3c,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v13 if v13 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 05bw
save `05bw'
local flist "`flist' `05bw'"



// 2006 4401 "Landtagswahl in Rheinland-Pfalz 2006"
// ------------------------------------------------

// Election Date was on 26 Mar 2006

use $ltw/za4401, clear

gen str8 zanr = "4401"
lab var zanr "Zentralarchiv study number"

gen intstart = "20Mar2006"
gen intend = "24Mar2006"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "RP"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3d == 1
replace party = 2 if v3d == 2
replace party = 3 if inrange(v3d,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v13 if v13 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 06rp
save `06rp'
local flist "`flist' `06rp'"

// 2006 4403 "Landtagswahl in Sachsen-Anhalt 2006"
// -----------------------------------------------

// Election Date was on 26 Mar 2006

use $ltw/za4403, clear

gen str8 zanr = "4403"
lab var zanr "Zentralarchiv study number"

gen intstart = "20Mar2006"
gen intend = "24Mar2006"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "ST"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3d == 2
replace party = 2 if v3d == 1
replace party = 3 if inrange(v3d,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v13 if v13 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,6)
replace edu = 2 if vf == 2
replace edu = 3 if inlist(vf,3,4,5)
replace edu = 4 if vf == 7
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 06st
save `06st'
local flist "`flist' `06st'"

// 2006 4405 "Wahl zum Abgeordnetenhaus in Berlin 2006"
// ----------------------------------------------------

// Election Date was on 17 Sep 2006

use $ltw/za4405, clear

gen str8 zanr = "4405"
lab var zanr "Zentralarchiv study number"

gen intstart = "11Sep2006"
gen intend = "16Sep2006"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "BE"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3d == 1
replace party = 2 if v3d == 2
replace party = 3 if inrange(v3d,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v12 if v12 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6,7)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 06be
save `06be'
local flist "`flist' `06be'"


// 2006 4511 "Landtagswahl in Mecklenburg-Vorpommern 2006"
// -------------------------------------------------------

// Election Date was on 17 Sep 2006

use $ltw/za4511, clear

gen str8 zanr = "4511"
lab var zanr "Zentralarchiv study number"

gen intstart = "11Sep2006"
gen intend = "16Sep2006"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "MV"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3d == 1
replace party = 2 if v3d == 2
replace party = 3 if inrange(v3d,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v12 if v12 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,6)
replace edu = 2 if vf == 2
replace edu = 3 if inlist(vf,3,4,5)
replace edu = 4 if vf == 7
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 06mv
save `06mv'
local flist "`flist' `06mv'"


// 2007 4745 "Bürgerschaftswahl in Bremen 2007"
// --------------------------------------------

// Election Date was on 27 Sep 2007

use $ltw/za4745, clear

gen str8 zanr = "4745"
lab var zanr "Zentralarchiv study number"

gen intstart = "07May2007"
gen intend = "10May2007"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "HB"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3c == 1
replace party = 2 if v3c == 2
replace party = 3 if inrange(v3c,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v12 if v12 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 07hb
save `07hb'
local flist "`flist' `07hb'"



// 2008 4864 "Landtagswahl in Niedersachsen 2008"
// ----------------------------------------------

// Election Date was on 27 Jan 2008

use $ltw/za4864, clear

gen str8 zanr = "4864"
lab var zanr "Zentralarchiv study number"

gen intstart = "21Jan2008"
gen intend = "24Jan2008"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "NI"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3d == 2
replace party = 2 if v3d == 1
replace party = 3 if inrange(v3d,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v12 if v12 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 08ni
save `08ni'
local flist "`flist' `08ni'"


// 2008 4866 "Landtagswahl in Hessen 2008"
// ---------------------------------------

// Election Date was on 27 Jan 2008

use $ltw/za4866, clear

gen str8 zanr = "4866"
lab var zanr "Zentralarchiv study number"

gen intstart = "21Jan2008"
gen intend = "24Jan2008"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "HE"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3d == 2
replace party = 2 if v3d == 1
replace party = 3 if inrange(v3d,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v12 if v12 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 08he
save `08he'
local flist "`flist' `08he'"


// 2008 4868 "Bürgerschaftswahl in Hamburg 2008"
// ---------------------------------------------

// Election Date was on 24 Feb 2008

use $ltw/za4868, clear

gen str8 zanr = "4868"
lab var zanr "Zentralarchiv study number"

gen intstart = "18Feb2008"
gen intend = "21Feb2008"

gen id = pid
lab var id "Original idenifier"
isid id

gen area = "HH"

gen voter:yesno = inlist(v3a,1,2,5) if inlist(v3a,1,2,4,5)	// 2==wahrscheinlich zur Wahl gehen
lab var voter "Voter y/n"

gen party:party = 1 if v3c == 2
replace party = 2 if v3c == 1
replace party = 3 if inrange(v3c,3,8)
lab var party "Electoral behaviour"

gen polint = 5 - v12 if v12 <=5	
lab var polint "Politicial interest"

gen men:yesno = va == 1 if inlist(va,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(vb,1,3)
replace agegroup = 2 if inrange(vb,4,8)			// 2=30-59
replace agegroup = 3 if inrange(vb,9,10)		// 3=60+
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vk,1,2,3)
replace emp = 2 if vk == 8
replace emp = 3 if vk == 7
replace emp = 4 if vk == 10
replace emp = 5 if inlist(vk,5,6)
replace emp = 6 if inlist(vk,4,9)
lab var emp "Employment status"	

gen occ:occ = 1 if inlist(vl,8,9)			// OCC vom HHV fehlt
replace occ = 2 if inlist(vl,4,5,6,7)
replace occ = 3 if inlist(vl,1,2,3)
replace occ = 4 if vl == 10
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vf,1,4)
replace edu = 2 if vf == 2
replace edu = 3 if vf == 3
replace edu = 4 if vf == 5
lab var edu "Education"

gen mar:mar = 1 if vc==1
replace mar = 2 if inlist(vc,2,4,5,6)
replace mar = 3 if vc==3
label variable mar "Marital status"

gen denom:denom = 1 if vq == 2
replace denom = 2 if vq == 1
replace denom = 3 if inlist(vq,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 08hh
save `08hh'
local flist "`flist' `08hh'"


// Append files together
// ---------------------

use `62nw', clear

foreach file in `flist' {
 append using `file'
}

replace zanr = trim(zanr)


// Merge Meta-Data
// ---------------

merge zanr using `meta', sort uniqusing //nokeep
assert _merge == 3
drop _merge

// Clean Data
// ----------

replace emp = 6 if emp ==.
replace occ = 4 if occ ==.
replace edu = . if edu ==4

gen start = date(intstart,"DMY")
label variable start "Start of survey period"

gen end = date(intend,"DMY")
label variable end "End of survey period"

format eldate start end %tddd_Mon_YY


drop state
drop eldatestr
drop intstart
drop intend
drop if voter == .

// Order
order year eldate zanr start end id ///
  voter party men agegroup emp occ edu area mar hhinc denom

// Labels

lab var area "Area"


lab def yesno ///
  0 "no" 1 "yes"

lab def party ///
  1 "SPD" 2 "CDU/CSU" 3 "Other"

lab def lr ///
  1 "Left" 2 "Center-Left" 3 "Center" 4 "Center-Rigth" 5 "Right" 6 "Other"

lab def agegroup ///
  1 "18-30" 2 "30-65" 3 "65+"

lab def emp ///
  1 "Employed" 2 "In education" 3 "Retired" 4 "Homemaker" ///
  5 "Unemployed" 6 "Other/Missing"

lab def occ ///
  1 "Self employed" 2 "White collar" 3 "Blue collar" ///
  4 "Other/Missing"

lab def edu ///
  1 "VS/HS and below" 2 "MR" 3 "Abitur and above" 4 "Other/Missing"

lab def mar ///
  1 "Married/together" 2 "Widowed/Divorced/separated" ///
  3 "Single"

lab def hhinc ///
  1 "1st Tercile" 2 "2nd Tercile" 3 "3rd Tercile"

lab def denom ///
  1 "Protestant" 2 "Catholic" 3 "None/Other"


// Data-Checks
// -----------

drop if men == .
assert !mi(year)
assert !mi(zanr)
assert !mi(end)
assert !mi(start)
assert !mi(eldate)
assert !mi(id)
assert !mi(voter)
assert !mi(men)
assert end - start > 0
isid zanr id

assert inlist(voter,0,1)
assert inlist(lr,1,2,3,4,5,6) if lr < .
assert inlist(party,1,2,3) if party < .
assert inlist(men,0,1)
assert inlist(agegroup,1,2,3) if agegroup < .
assert inlist(emp,1,2,3,4,5,6)
assert inlist(occ,1,2,3,4)
assert inlist(edu,1,2,3,4) if edu < .
assert inlist(mar,1,2,3) if mar < .
assert inlist(hhinc,1,2,3,4) if hhinc < .
assert inlist(denom,1,2,3) if denom < .

// Save
// ----

compress
save ltwsurvey, replace

exit






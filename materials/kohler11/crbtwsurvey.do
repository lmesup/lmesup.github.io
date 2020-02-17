// Creates a harmonised dataset of election studies 1949-2005
// ----------------------------------------------------------

version 10.0
clear
set memory 90m

// Metadata
// --------

input year str8 zanr str80 name ///
  str10 sampdes str30 samppop str9 eldatest 
1949 2324 "Wahlstudie 1949" /// 
    "Quota" "18+" 14Aug1949 
1949 2361 "Situation nach der Btw 1949" /// 
    "Quota" "18+" 14Aug1949 
1953 0145 "Wahlstudie 1953 (Bundesstudie)" /// 
    "Random" "18-79" 06Sep1953 
1957 3272-III "Wahlstudie 1957" /// 
    "Quota" "16+" 15Sep1957 
1961 0056 "Wahlstudie 1961 (Kölner Wahlstudie, Sep)" /// 
    "Random" "16-70" 17Sep1961 
1961 0057 "Wahlstudie 1961 (Kölner Wahlstudie, Nov)" /// 
    "Random" "16-70" 17Sep1961 
1965 0314 "Wahlstudie 1965 (Nachunters.)" /// 
    "Random" "21+" 19Sep1965
1965 0556 "Wahlstudie 1965 (Voruntersuchung)" /// 
    "Random" "21+" 19Sep1965
1969 0426-II "Wahlstudie 1969 (Panel)" /// 
    "Random" "21+" 28Sep1969 
1969 0525-II "Wahlstudie 1969 (Politik in der BRD)" /// 
    "Random" "21+" 28Sep1969 
1972 0635 "Wahlstudie 1972 (Panel)" /// 
    "Random" "18+" 19Nov1972 
1976 0823 "Wahlstudie 1976 (Panel)" /// 
    "Random" "18+" 03Oct1976 
1980 1053-IX "Politbarometer 1980 (September)" /// 
    "Random" "18+" 05Oct1980 
1980 1053-X "Politbarometer 1980 (October)" /// 
    "Random" "18+" 05Oct1980 
1983 1276 "Wahlstudie 1983 (Panelstudie)" /// 
    "Random" "18+ (wahlb.)" 06Mar1983 89.1 
1987 1536-II "Politbarometer 1987 (February)" /// 
    "Random" "18+" 25Jan1987 
1987 1537-III "Wahlstudie 1987 (Panelstudie)" /// 
    "Random" "18+"  25Jan1987 
1990 1920-V "Politbarometer 1990 (May)" /// 
    "RLD" "18+ (wahlb.)" 02Dec1990  
1990 1987-XII "Politbarometer 1990 Ost (December)" /// 
    "Random" "18+ (wahlb.)" 02Dec1990  
1994 2546-IX "Politbarometer 1994 (September)" /// 
    "RLD" "18+ (wahlb.)" 16Oct1994 
1994 2601 "Nachw.-stud. 1994" /// 
    "Random" "18+ (dt.)" 16Oct1994 
1994 3065-I "Polit. Einst., polit. Part. u. Wählerverh. i. verein. Dtld 1994" /// 
    "Random" "16+"  16Oct1994 
1994 3065-II "Polit. Einst., polit. Part. u. Wählerverh. i. verein. Dtld 1994" /// 
	  "Random" "16+"  16Oct1994
1994 2559-IX "Wahlstudie 1994 (Politbarom. Ost)" ///
    "Random" "18+ (wahlb.)" 16Oct1994
1998 3066-I "Polit. Einst., polit. Part. u. Wählerverh. i. verein. Dtld 1998" /// 
    "Random" "16+" 27Sep1998 
1998 3066-II "Polit. Einst., polit. Part. u. Wählerverh. i. verein. Dtld 1998" /// 
    "Random" "16+" 27Sep1998 
1998 3073 "Dt. Nat. Wahlstudie - Nachw.-stud. 1998 (Dt. CSES-Studie)" /// 
    "Random" "18+ (wahlb.)" 27Sep1998 
1998 3160-IX "Politbarometer 1998 (Sep-38KW)" /// 
    "RLD" "18+ (wahlb.)" 27Sep1998 
1998 3160-X  "Politbarometer 1998 (October)" /// 
    "RLD" "18+ (wahlb.)" 27Sep1998 
1998 3160-XI "Politbarometer 1998 (November)" /// 
    "RLD" "18+ (wahlb.)" 27Sep1998 
1998 3160-XII "Politbarometer 1998 (December)" /// 
    "RLD" "18+ (wahlb.)" 27Sep1998 
2002 3861-I "Political Attitudes, Political Participation and Voter (Vorwahl)" /// 
    "Random" "16+" 22Sep2002  
2002 3861-II "Political Attitudes, Political Participation and Voter (Nachwahl)" /// 
    "Random" "16+" 22Sep2002  
2005 WZB  "Testmodul deutsche CSES III" /// 
    "RLD" "15+" 18Sep2005
end

label variable year "Year of election"
label variable zanr "Zentralarchiv study number"
label variable name "Name of study"
label variable sampdes "Sampling design"
label variable samppop "Sampling population"
label variable eldatest "Election date (string)"

compress
sort zanr

tempfile meta
save `meta'

// 1949 2324 "Wahlstudie 1949"
// ---------------------------

// Observartion period was Feb-Mar 1949. Election date was 14 Aug 1949

use $btw/s2324, clear

gen str8 zanr = "2324"
lab var zanr "Zentralarchiv study number"

gen intstart = "1Feb1949"
gen intend = "28Mar1949"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = 1

gen voter:yesno = 1
lab var voter "Voter y/n"
note voter: s2324 (1949) all respondents set to voter

gen polint = (v21==1) + (v28==1) + (v30==1)
lab var polint "Politicial interest"

gen party:party = 1 if v58 == 2
replace party = 2 if v58 == 1
replace party = 3 if inlist(v58,3,4,5,6)
lab var party "Electoral behaviour"
note party: s2324 (1949) Party preference

gen men:yesno = v57 == 1 if !mi(v57)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if v55 == 1
replace agegroup = 2 if inlist(v55,2,3)
replace agegroup = 3 if v55 == 4
label variable agegroup "Age group"

gen emp:emp = 1 if inlist(v49,1,2)
replace emp = 2 if v49 == 3 
replace emp = 3 if v49 == 5
replace emp = 4 if v49 == 4
replace emp = 5 if v49 == 6
replace emp = 6 if v49 == 7
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v51,4,5,6)
replace occ = 2 if inlist(v51,3,7)
replace occ = 3 if inlist(v51,1,2)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v48,1)				
replace edu = 2 if inlist(v48,2,3)
replace edu = 3 if inlist(v48,4,5)
lab var edu "Education"

gen bul:bul = 1 if inlist(v46,1)
replace bul = 2 if v46==2
replace bul = 3 if v46==3
replace bul = 4 if v46==4
replace bul = 5 if v46==5
replace bul = 6 if inlist(v46,6,7)
replace bul = 7 if v46==8
lab var bul "Region"

gen mar:mar = 1 if v56==2
replace mar = 2 if inlist(v56,3,4)
replace mar = 3 if v56==1
label variable mar "Marital status"   

xtile hhinc = v54, nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = v47
replace denom = 3 if denom==4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 49a
save `49a'

// 1949, ZA-Nr. 2361 "Situation nach der Btw 1949"
// -----------------------------------------------

use $btw/s2361 if v38 != 1, clear  // Do not use Berlin!

gen str8 zanr = "2361"
lab var zanr "Zentralarchiv study number"

gen intstart = "15Aug1949"
gen intend = "31Aug1949"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = 1

gen voter:yesno = v3 == 1 if v3<=2
lab var voter "Voter y/n"

gen polint = (v4!=3) + (v56==1)
lab var polint "Politicial interest"

gen party:party = .
lab var party "Electoral behaviour"

gen men:yesno = v49 == 1 if v49 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if v50 == 1
replace agegroup = 2 if inlist(v50,2,3)
replace agegroup = 3 if v50 == 4
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v43,1,2)
replace emp = 2 if v43 == 3 
replace emp = 3 if v43 == 5
replace emp = 4 if v43 == 4
replace emp = 5 if v43 == 6
replace emp = 6 if v43 == 7
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v45,5,6,7)
replace occ = 2 if inlist(v45,3,4)
replace occ = 3 if inlist(v45,1,2)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v42,1)				
replace edu = 2 if inlist(v42,2,3)
replace edu = 3 if inlist(v42,4,5)
lab var edu "Education"

gen bul:bul = 1 if inlist(v38,2,3,4)
replace bul = 2 if v38==5
replace bul = 3 if v38==6
replace bul = 4 if v38==7
replace bul = 5 if v38==9
replace bul = 6 if inlist(v38,10,11,12,13)
replace bul = 7 if v38==8
lab var bul "Region"

gen mar:mar = 1 if v51==2
replace mar = 2 if inlist(v51,3,4)
replace mar = 3 if v51==1
label variable mar "Marital status"   

xtile hhinc = v47, nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = v41
replace denom = 3 if denom==4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 49b
save `49b'

use `49a', clear
append using `49b'
tempfile 49
save `49'


// 1953, ZA-Nr. 0145 "Wahlstudie 1953 (Bundesstudie)" 
// --------------------------------------------------

use $btw/s0145 

gen str8 zanr = "0145"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Jul1953"
gen intend = "31Aug1953"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v224 == 1 if v224<=2
lab var voter "Voter y/n"

gen polint = (v171==1) + (v175==1) + (v177==1) + (v226==1) + (v276==1) 
lab var polint "Politicial interest"

gen party:party = 1 if v222==4 | v223==4
replace party = 2 if v222==3 | v223==3
replace party = 3 if v222==5 | v223==5
replace party = 3 if inlist(v222,1,2,6,7,8,9) | inlist(v223,1,2,6,7,8,9)
lab var party "Electoral behaviour"
note party: s0145 (1953): Party preference

gen men:yesno = v342 == 1 if v342 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v343,1,2)
replace agegroup = 2 if inlist(v343,3,4)
replace agegroup = 3 if v343 == 5
label variable agegroup "Agegroup"
note agegroup: ZA 0145 (year 1953): 2=30-60 and 3=60+

gen emp:emp = 1 if inlist(v97,1,2)
replace emp = 2 if v97 == 3 
replace emp = 3 if v97 == 6
replace emp = 4 if v97 == 5
replace emp = 5 if v97 == 4
replace emp = 6 if v97 == 7
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v101,11,21,22,71)
replace occ = 2 if inlist(v101,31,32,41)
replace occ = 3 if inlist(v101,61,81)
replace occ = 1 if occ== . & inlist(v105,11,21,22,71)
replace occ = 2 if occ== . & inlist(v105,31,32,41)
replace occ = 3 if occ== . & inlist(v105,61,81)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v345,1)				
replace edu = 2 if inlist(v345,2)
replace edu = 3 if inlist(v345,3,4)
lab var edu "Education"

gen bul:bul = 1 if inlist(v338,1,2,4)
replace bul = 2 if v338==3
replace bul = 3 if v338==5
replace bul = 4 if v338==6
replace bul = 5 if v338==9
replace bul = 6 if v338==8
replace bul = 7 if v338==7
lab var bul "Region"

gen mar:mar = 1 if v307==1
replace mar = 2 if v307==3 | v307 == 5 | v307==4
replace mar = 3 if v307==2
label variable mar "Marital status"   

xtile hhinc = v401 if v401 != 9,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = v341
replace denom = 3 if denom==4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 53
save `53'
local flist "`flist' `53'"


// 1957 ZA-Nr. 3272 "Wahlstudie 1957" 
// ----------------------------------
// No respondents below 16 in the dataset!
// I only use part III, shortly before election. Part IV, past election
// does not contain electoral participation. 

use $btw/s3272 if v2==3 & v6 != 11, clear // part 3 only, drop Berlin

gen str8 zanr = "3272-III"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1957"
gen intend = "14Sep1957"

gen id = v3
by id, sort: replace id = 10000+ id if _n==2
lab var id "Original idenifier"
isid id

gen double weight = 1
 
gen voter:yesno = v97 == 1 if v97<=2
lab var voter "Voter y/n"

egen polint = anycount(v361 v362 v364 v365 v368), v(1)
lab var polint "Politicial interest"

gen party:party = 1 if v100==2
replace party = 2 if v100==1
replace party = 3 if v100==3
replace party = 3 if inlist(v100,4,5,6,7,8,9) 
lab var party "Electoral behaviour"

gen men:yesno = v14 == 1 if v14 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v15,1,2,3)
replace agegroup = 2 if inlist(v15,4,5,6)
replace agegroup = 3 if v15 == 5
label variable agegroup "Agegroup"
note agegroup: ZA 3272 (year 1957): 2=30-60 and 3=60+

gen emp:emp = 1 if inlist(v18,1,2)
replace emp = 2 if v18 == 3 
replace emp = 3 if v18 == 4
replace emp = 4 if v18 == 6
replace emp = 5 if v18 == 5
replace emp = 6 if inlist(v18,7,.)
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v19,3,6,7)
replace occ = 2 if inlist(v19,4,5)
replace occ = 3 if inlist(v19,1)
replace occ = 4 if occ==.
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v17,1)				
replace edu = 2 if inlist(v17,2)
replace edu = 3 if inlist(v17,3,4)
lab var edu "Education"

gen bul:bul = 1 if inlist(v6,1,2,4)
replace bul = 2 if v6==3
replace bul = 3 if v6==5
replace bul = 4 if v6==6
replace bul = 5 if v6==9
replace bul = 6 if v6==8
replace bul = 7 if inlist(v6,7,10)
lab var bul "Region"

gen mar:mar = 1 if v65==1
replace mar = 2 if v65==3 | v65==4
replace mar = 3 if v65==2
label variable mar "Marital status"   

xtile hhinc = v52 if 52 != 9,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = v13
replace denom = 3 if denom==4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 57
save `57'
local flist "`flist' `57'"


// 1961 ZA-Nr. 0055 "Wahlstudie 1961 (Kölner Wahlstudie, Jul)"
// -----------------------------------------------------------

// Observation period was Jul 1961. Election was on 17. September 1961.
// I only use the study shortly before and after the election. (see downstream)


// 1961 ZA-Nr. 0056 "Wahlstudie 1961 (Kölner Wahlstudie, Sep)"
// ------------------------------------------------------------

use $btw/s0056 if v152 >= 2 & v171 != 10, clear // Drop Berlin and resp. < 18

gen str8 zanr = "0056"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1961"
gen intend = "16Sep1961"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v131 == 1 if inlist(v131,1,8)
lab var voter "Voter y/n"

gen polint = 5 - v9 if v9 <= 4
lab var polint "Politicial interest"

gen party:party = 1 if v133==1
replace party = 2 if v133==2
replace party = 3 if v133==3 
replace party = 3 if inlist(v133,4,5,6,7) 
lab var party "Electoral behaviour"
note party: s0056 (1961): Party preference

gen men:yesno = v168 == 1 if v168 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v152,2,3,4)
replace agegroup = 2 if inlist(v152,5,6,7,8,9,10)
replace agegroup = 3 if v152 >= 11 & v152 < .
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v143,1)
replace emp = 2 if inlist(v143,4) 
replace emp = 3 if v143 == 3
replace emp = 4 if v143 == 5
replace emp = 5 if v143 == 2 
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v151,11,23) | inrange(v151,71,79)
replace occ = 2 if inrange(v151,31,49)
replace occ = 3 if inrange(v151,51,69) | v151==81
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v153,11,21)				
replace edu = 2 if inlist(v153,22,23,24,31,32,41)
replace edu = 3 if inlist(v153,42,43,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v171,1,2,4)
replace bul = 2 if v171==3
replace bul = 3 if v171==5
replace bul = 4 if v171==6
replace bul = 5 if v171==9
replace bul = 6 if v171==8
replace bul = 7 if inlist(v171,7,11)
lab var bul "Region"

gen mar:mar = 1 if v142==2
replace mar = 2 if v142==3 | v142==4
replace mar = 3 if v142==1
label variable mar "Marital status"   

xtile hhinc = v156 if v156 != 99,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v164 == 2
replace denom = 2 if v164 == 1
replace denom = 3 if v164 == 3
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 61a
save `61a'
local flist "`flist' `61a'"


// 1961 ZA-Nr. 0057 "Wahlstudie 1961 (Kölner Wahlstudie, Nov.)"
// ------------------------------------------------------------

use $btw/s0057 if v161 >= 2 & v180 != 11, clear // Drop Berlin and resp. < 18

gen str8 zanr = "0057"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Nov1961"
gen intend = "31Dec1961"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v90 != 8 if v90 < 9 & v4 == 1
lab var voter "Voter y/n"

gen polint = 5 - v9 if v9 <= 4
lab var polint "Politicial interest"

gen party:party = 1 if v91==1
replace party = 2 if v91==2
replace party = 3 if v91==3 
replace party = 3 if inlist(v91,4,5,6,7) 
lab var party "Electoral behaviour"

gen men:yesno = v177 == 1 if v177 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inlist(v161,2,3,4)
replace agegroup = 2 if inlist(v161,5,6,7,8,9,10)
replace agegroup = 3 if v161 >= 11 & v161 < .
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v155,1)
replace emp = 2 if inlist(v155,6,7) 
replace emp = 3 if v155 == 3
replace emp = 4 if v155 == 8
replace emp = 5 if v155 == 2 | v155 == 4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v160,11,23) | inrange(v160,71,79)
replace occ = 2 if inrange(v160,31,49)
replace occ = 3 if inrange(v160,51,69) | v160==81
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v162,11,21)				
replace edu = 2 if inlist(v162,22,23,24,31,32,41)
replace edu = 3 if inlist(v162,42,43,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v180,1,2,4)
replace bul = 2 if v180==3
replace bul = 3 if v180==5
replace bul = 4 if v180==6
replace bul = 5 if v180==9
replace bul = 6 if v180==8
replace bul = 7 if inlist(v180,7,10)
lab var bul "Region"

gen mar:mar = 1 if v151==2
replace mar = 2 if v151==3 
replace mar = 3 if v151==1
label variable mar "Marital status"   

xtile hhinc = v165 if v165 != 99,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v173 == 2
replace denom = 2 if v173 == 1
replace denom = 3 if v173 == 3
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 61b
save `61b'
local flist "`flist' `61b'"


// 1965 ZA-Nr. 0556 "Wahlstudie 1965 (Voruntersuchung)"
// ----------------------------------------------------
// Observarion Period was Sep 1965. Election date was 19 Sep 1965

use $btw/s0556
note: ZA 0556 (year 1965) has sampling population of age 21+

gen str8 zanr = "0556"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1965"
gen intend = "14Sep1965"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v27 == 1 if inlist(v27,1,3)
lab var voter "Voter y/n"

gen polint = 5 - v9 if v9 <= 4
lab var polint "Politicial interest"

gen party:party = 1 if inlist(v113,1,2,3,4,13)
replace party = 2 if inlist(v113,5,6,7,8,13)
replace party = 3 if inlist(v113,9,10,11,12,13)
lab var party "Electoral behaviour"
note party: s0556 (1965): Party preference

gen men:yesno = v105 == 1 if v105 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v99,0,1)
replace agegroup = 2 if inrange(v99,2,8)
replace agegroup = 3 if v99 >= 9 & v99 < .
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v96,1)
replace emp = 2 if inlist(v96,5) 
replace emp = 3 if v96 == 4 & agegroup==3
replace emp = 4 if v96 == 2
replace emp = 5 if v96 == 3 | (v96==4 & emp == .)
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v98,11,23) | inrange(v98,71,79)
replace occ = 2 if inrange(v98,31,49)
replace occ = 3 if inrange(v98,51,69) | v98==81
replace occ = 1 if occ == . & (inrange(v97,11,23) | inrange(v97,71,79))
replace occ = 2 if occ == . & (inrange(v97,31,49))
replace occ = 3 if occ == . & (inrange(v97,51,69) | v97==81)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v100,11,21)				
replace edu = 2 if inlist(v100,22,23,24,31,32,42)
replace edu = 3 if inlist(v100,41,43,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v108,1,2,4)
replace bul = 2 if v108==3
replace bul = 3 if v108==5
replace bul = 4 if v108==6
replace bul = 5 if v108==9
replace bul = 6 if v108==8
replace bul = 7 if inlist(v108,7,10)
lab var bul "Region"

gen mar:mar = 1 if v93==2
replace mar = 2 if inlist(v93,3,4)
replace mar = 3 if v93==1
label variable mar "Marital status"   

xtile hhinc = v101 if v101 != 99,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v104 == 2
replace denom = 2 if v104 == 1
replace denom = 3 if v104 == 3
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 65a
save `65a'
local flist "`flist' `65a'"


// 1965 0314 "Wahlstudie 1965 (Nachunters.)"
// -----------------------------------------

use $btw/s0314
note: ZA 0314 (year 1965) has sampling population of age 21+
gen str8 zanr = "0314"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1965"
gen intend = "31Oct1965"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v113 != 8 if v113 < 9 
lab var voter "Voter y/n"

gen polint = 5 - v43 if v43 <= 4
lab var polint "Politicial interest"

gen party:party = 1 if v114==2
replace party = 2 if v114==1
replace party = 3 if v114==3 
replace party = 3 if v114==4
lab var party "Electoral behaviour"

gen men:yesno = v267 == 1 if v267 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v243,0,1)
replace agegroup = 2 if inrange(v243,2,8)
replace agegroup = 3 if v243 >= 9 & v243 < .
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v242,1,2)
replace emp = 2 if inlist(v244,92) 
replace emp = 3 if v244 == 94
replace emp = 4 if v244 == 91
replace emp = 5 if v242 == 3 & emp == . 
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v245,11,23) | inrange(v245,71,79)
replace occ = 2 if inrange(v245,31,49)
replace occ = 3 if inrange(v245,51,69) | v245==81
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v246,11,21)				
replace edu = 2 if inlist(v246,22,23,24,31,32,41)
replace edu = 3 if inlist(v246,42,43,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v270,1,2,4)
replace bul = 2 if v270==3
replace bul = 3 if v270==5
replace bul = 4 if v270==6
replace bul = 5 if v270==9
replace bul = 6 if v270==8
replace bul = 7 if inlist(v270,7,10)
lab var bul "Region"

gen mar:mar = 1 if v241==2
replace mar = 2 if inlist(v241,3,4)
replace mar = 3 if v241==1
label variable mar "Marital status"   

xtile hhinc = v247 if v247 != 99,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v266 == 2
replace denom = 2 if v266 == 1
replace denom = 3 if v266 == 3
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 65b
save `65b'
local flist "`flist' `65b'"


// 1969 ZA-Nr. 0426 "Wahlstudie 1969 (Panel)"
// -----------------------------------------

use $btw/s0426
note: 1969: sampling population of age 21+

gen str8 zanr = "0426-II"
lab var zanr "Zentralarchiv study number"

gen intstart = "17Oct1969"
gen intend = "09Nov1969"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v733

gen voter:yesno = v615 == 1 if v615 <= 1 
lab var voter "Voter y/n"

gen polint = 6 - v12 if v12 <= 5
lab var polint "Politicial interest"

gen party:party = 1 if v617==1
replace party = 2 if v617==2
replace party = 3 if v617==3 
replace party = 3 if inlist(v617,4,5) 
lab var party "Electoral behaviour"

gen men:yesno = v226 == 1 if v226 <= 1
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v224,1,2)
replace agegroup = 2 if inrange(v224,3,9)
replace agegroup = 3 if v224 >= 10 & v224 < .
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v228,1,2,3)
replace emp = 2 if inlist(v228,5) 
replace emp = 3 if v228==6
replace emp = 4 if v229==91
replace emp = 5 if v228 == 4 | (v228 == 7 & emp==.) | (v229==93 & emp == . )
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v230,11,23) | inrange(v230,71,79)
replace occ = 2 if inrange(v230,31,49)
replace occ = 3 if inrange(v230,51,69) | v230==81
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v231,11,21)				
replace edu = 2 if inlist(v231,22,23,24,31,32,41)
replace edu = 3 if inlist(v231,42,43,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v267,1,2,4)
replace bul = 2 if v267==3
replace bul = 3 if v267==5
replace bul = 4 if v267==6
replace bul = 5 if v267==9
replace bul = 6 if v267==8
replace bul = 7 if inlist(v267,7,10)
lab var bul "Region"

gen mar:mar = 1 if v225==2
replace mar = 2 if inlist(v225,3,4,5)
replace mar = 3 if v225==1
label variable mar "Marital status"   

xtile hhinc = v240 if v240 != 99,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v243 == 2
replace denom = 2 if v243 == 1
replace denom = 3 if v243 == 3 | v243 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 69a
save `69a'
local flist "`flist' `69a'"

// 1969 0525 "Wahlstudie 1969 (Politik in der BRD)" 
// ------------------------------------------------
// Observation Period 08/1969-09/1969, election date was 28 Sep. 1969

use $btw/s0525 if v456 != 11 & v4==2 // Drop Berlin
note: 1969: sampling population of age 21+

gen str8 zanr = "0525-II"  
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1969"
gen intend = "27Sep1969"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v295 == 1 if inlist(v295,1,3)
lab var voter "Voter y/n"

gen polint = 6 - v11 if v11 <= 5
lab var polint "Politicial interest"

gen party:party = 2 if v299==1 | v299==2
replace party = 1 if v299==3
replace party = 3 if v299==4 
replace party = 3 if inlist(v299,5,7) 
lab var party "Electoral behaviour"

gen men:yesno = v454 == 1 if v454 <= 2
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v383,21,29)
replace agegroup = 2 if inrange(v383,30,64)
replace agegroup = 3 if inrange(v383,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v384,1,2) // -> Note 1
replace emp = 2 if inlist(v384,7,8) 
replace emp = 3 if v384==4
replace emp = 4 if inlist(v384,5,6)
replace emp = 5 if v384 == 3
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v411,11,23) | inrange(v411,71,79)
replace occ = 2 if inrange(v411,31,49)
replace occ = 3 if inrange(v411,51,69) | v411==81
replace occ = 1 if occ == . & (inrange(v385,11,23) | inrange(v385,71,79))
replace occ = 2 if occ == . & (inrange(v385,31,49))
replace occ = 3 if occ == . & (inrange(v385,51,69) | v385==81)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v466,11,21)				
replace edu = 2 if inlist(v466,22)
replace edu = 3 if inlist(v466,41,42,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v456,1,2,4)
replace bul = 2 if v456==3
replace bul = 3 if v456==5
replace bul = 4 if v456==6
replace bul = 5 if v456==9
replace bul = 6 if v456==8
replace bul = 7 if inlist(v456,7,10)
lab var bul "Region"

gen mar:mar = 1 if v380==1
replace mar = 2 if inlist(v380,3,4,5)
replace mar = 3 if v380==2
label variable mar "Marital status"   

xtile hhinc = v435,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v436 == 2
replace denom = 2 if v436 == 1
replace denom = 3 if v436 == 3 | v436 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 69b
save `69b'
local flist "`flist' `69b'"


// 1972 ZA-Nr. 0635 "Wahlstudie 1972 (Panel)"
// ------------------------------------------
// Election date was 19. Nov 1972. Electoral participation was only
// asked in 3rd wave.

use $btw/s0635 if v4 == 3 // Only 3rd wave

gen str8 zanr = "0635"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Dec1972"
gen intend = "31Dec1972"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v263 == 1 if inlist(v263,1,2)
lab var voter "Voter y/n"

gen polint = 4 - v15 if v15 <= 3
lab var polint "Politicial interest"

gen party:party = 1 if v54==1
replace party = 2 if v54==2
replace party = 3 if v54==3 
replace party = 3 if inlist(v54,4,5) 
lab var party "Electoral behaviour"

gen men:yesno = v115 == 1 if v115 <= 2
lab var men "Man y/n"

replace v360 = 1900 + v360 if v360 < 60
replace v360 = 1800 + v360 if v360 > 60 & v360 < 100
gen agegroup:agegroup = 1 if inrange(1972-v360,21,29)
replace agegroup = 2 if inrange(1972-v360,30,64)
replace agegroup = 3 if inrange(1972-v360,65,90)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v118,1,2) 
replace emp = 2 if inlist(v118,6,7) 
replace emp = 3 if v118==5
replace emp = 4 if v118==8 & !men
replace emp = 5 if v118==4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v123,11,23) | inrange(v123,71,79)
replace occ = 2 if inrange(v123,31,49)
replace occ = 3 if inrange(v123,51,69) | v123==81
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v120,11,21)				
replace edu = 2 if inrange(v120,22,41)
replace edu = 3 if inlist(v120,42,43,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v5,1,2,4)
replace bul = 2 if v5==3
replace bul = 3 if v5==5
replace bul = 4 if v5==6
replace bul = 5 if v5==9
replace bul = 6 if v5==8
replace bul = 7 if inlist(v5,7,10)
lab var bul "Region"

gen mar:mar = 1 if v243==1
replace mar = 2 if v243==3
replace mar = 3 if v243==2
label variable mar "Marital status"   

xtile hhinc = v252 if v252 <99,  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v357 == 2
replace denom = 2 if v357 == 1
replace denom = 3 if v357 == 3 | v357 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 72
save `72'
local flist "`flist' `72'"


// 1976 0823 "Wahlstudie 1976 (Panel)"
// -----------------------------------
// Election date was: 3. Oct 1976. Voting is past election!

use $btw/s0823 if v4 == 3 // Only 3rd wave

gen str8 zanr = "0823"
lab var zanr "Zentralarchiv study number"

gen intstart = "26Oct1976"
gen intend = "19Nov1976"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v3

gen voter:yesno = v434 == 1 if inlist(v434,1,2)
lab var voter "Voter y/n"

replace v489=0 if v489==8
replace v494=0 if v494==8
replace v489=. if v489==9
replace v494=. if v494==9
gen x = v494-v489

gen lr:lr = 1 if inlist(x,-6,-5,-4,-3) 
replace lr = 2 if inlist(x,-2,-1)
replace lr = 3 if inlist(x,0)
replace lr = 4 if inlist(x,1,2)
replace lr = 5 if inlist(x,3,4,5,6) 
replace lr = 6 if x==. 
lab var lr "Left right self-placement"
drop x

gen polint = 6 - v13 if !inlist(v13,0,9)
replace polint = 1 if v12 == 3
replace polint = 2 if v12 == 2
lab var polint "Politicial interest"

gen party:party = 1 if v437==1
replace party = 2 if v437==2
replace party = 3 if v437==3 
replace party = 3 if inlist(v437,4,5,6) 
lab var party "Electoral behaviour"

gen men:yesno = v543 == 1 if inlist(v543,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v185,18,29)
replace agegroup = 2 if inrange(v185,30,64)
replace agegroup = 3 if inrange(v185,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v387,1,2,3) 
replace emp = 2 if inlist(v387,8,9,10) 
replace emp = 3 if v387==6
replace emp = 4 if (v387==5 | v387 == 7) & !men
replace emp = 5 if v387==4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v396,11,23) | inrange(v396,71,79)
replace occ = 2 if inrange(v396,31,49)
replace occ = 3 if inrange(v396,51,69) | v396==81
replace occ = 1 if inrange(v391,11,23) | inrange(v391,71,79)
replace occ = 2 if inrange(v391,31,49)
replace occ = 3 if inrange(v391,51,69) | v391==81
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v386,11,21)				
replace edu = 2 if inrange(v386,22,41)
replace edu = 3 if inlist(v386,42,43,51)
lab var edu "Education"

gen bul:bul = 1 if inlist(v5,1,2,4)
replace bul = 2 if v5==3
replace bul = 3 if v5==5
replace bul = 4 if v5==6
replace bul = 5 if v5==9
replace bul = 6 if v5==8
replace bul = 7 if inlist(v5,7,0)
lab var bul "Region"

gen mar:mar = 1 if v544==1
replace mar = 2 if inlist(v544,3,4)
replace mar = 3 if v544==2
label variable mar "Marital status"   

xtile hhinc = v400 if !inlist(v400,0,98,99),  nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v550 == 2
replace denom = 2 if v550 == 1
replace denom = 3 if v550 == 3 | v550 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 76
save `76'
local flist "`flist' `76'"


// 1980 1053 "Wahlstudie 1980 (Politbarom. West)"
// ----------------------------------------------
// Election date was 5. October 1980. I use surveys of september
// and october

use $btw/s1053 if inlist(v5,9,10)

gen str8 zanr = "1053-IX" if v5==9
replace zanr = "1053-X" if v5==10
lab var zanr "Zentralarchiv study number"

gen intstart = "01Sep1980" if v5==9
replace intstart = "06Oct1980" if v5==10
gen intend = "30Sep1980" if v5==9
replace intend = "30Oct1980" if v5==10

gen id = v2
lab var id "Original idenifier"
isid v5 id

gen double weight = v3 * v4 

gen voter:yesno = v13 == 1 if inlist(v13,1,3) & v5==9
replace voter = inlist(v246,1,2) if v246 <= 3 & v5==10
lab var voter "Voter y/n"

gen polint = 6 - v9 if !inlist(v9,0,9)
replace polint = 1 if v8 == 3
replace polint = 2 if v8 == 2
lab var polint "Politicial interest"

gen lr:lr = 1 if inlist(v93,1,2,3)
replace lr = 2 if inlist(v93,4,5)
replace lr = 3 if inlist(v93,6)
replace lr = 4 if inlist(v93,7,8)
replace lr = 5 if inlist(v93,9,10,11)
replace lr = 6 if v93==99
lab var lr "Left right self-placement"

gen party:party = 1 if v15==2 & v5==9
replace party = 2 if v15==1 & v5==9
replace party = 3 if v15==3 & v5==9
replace party = 3 if v15==6 & v5==9
replace party = 3 if inlist(v15,4,5) & v5==9
replace party = 1 if v248==2 & v5==10
replace party = 2 if v248==1 & v5==10
replace party = 3 if v248==3 & v5==10
replace party = 3 if v248==6 & v5==10
replace party = 3 if inlist(v248,4,5) & v5==9
lab var party "Electoral behaviour"

gen men:yesno = v282 == 1 if inlist(v282,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v283,18,29)
replace agegroup = 2 if inrange(v283,30,64)
replace agegroup = 3 if inrange(v283,65,93)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v286,1,2,3) 
replace emp = 2 if inlist(v286,8,9,10) 
replace emp = 3 if v286==6
replace emp = 4 if (v286==5 | v286 == 7) & !men
replace emp = 5 if v286==4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v291,1,4) | inrange(v291,16,17)
replace occ = 2 if inrange(v291,5,12)
replace occ = 3 if inrange(v291,13,15)
replace occ = 1 if occ == . & (inrange(v287,1,4) | inrange(v287,16,17))
replace occ = 2 if occ == . & inrange(v287,5,12)
replace occ = 3 if occ == . & inrange(v287,13,15)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v285,1,2)				
replace edu = 2 if inrange(v285,3,5)
replace edu = 3 if inlist(v285,6,7,8,9)
lab var edu "Education"

gen bul:bul = 1 if inlist(v301,1,2,4)
replace bul = 2 if v301==3
replace bul = 3 if v301==5
replace bul = 4 if v301==6
replace bul = 5 if v301==9
replace bul = 6 if v301==8
replace bul = 7 if inlist(v301,7,10)
lab var bul "Region"

gen mar:mar = 1 if v284==1
replace mar = 2 if inlist(v284,3,4)
replace mar = 3 if v284==2
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v296 == 2
replace denom = 2 if v296 == 1
replace denom = 3 if v296 == 3 | v296 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 80
save `80'
local flist "`flist' `80'"


// 1983 ZA-Nr. 1276 "Wahlstudie 1983 (Panelstudie)" 
// ------------------------------------------------
// Election date was 6 Mar 1983. Voting is past election

use $btw/s1276 if v3 == 3

gen str8 zanr = "1276"
lab var zanr "Zentralarchiv study number"

gen intstart = "07Mar1983"
gen intend = "31Mar1983"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v4 * v5

gen voter:yesno = inlist(v272,1,2) if v272 <= 3 
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v313,1,2,3)
replace lr = 2 if inlist(v313,4,5)
replace lr = 3 if inlist(v313,6)
replace lr = 4 if inlist(v313,7,8)
replace lr = 5 if inlist(v313,9,10,11)
replace lr = 6 if v313==99
lab var lr "Left right self-placement"

gen polint = 6 - v271 
lab var polint "Politicial interest"

gen party:party = 1 if v274==2
replace party = 2 if v274==1
replace party = 3 if v274==3
replace party = 3 if v274==4
replace party = 3 if inlist(v274,5,6,7) 
lab var party "Electoral behaviour"

gen men:yesno = v392 == 1 if inlist(v392,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v393,18,29)
replace agegroup = 2 if inrange(v393,30,64)
replace agegroup = 3 if inrange(v393,65,94)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v257,1,2,3) 
replace emp = 2 if inlist(v257,8,9,10) 
replace emp = 3 if v257==6
replace emp = 4 if (v257==5 | v257 == 7) & !men
replace emp = 5 if v257==4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v262,1,4) | inrange(v262,16,18)
replace occ = 2 if inrange(v262,5,12)
replace occ = 3 if inrange(v262,13,15)
replace occ = 1 if occ == . & (inrange(v258,1,4) | inrange(v258,16,18))
replace occ = 2 if occ == . & inrange(v258,5,12)
replace occ = 3 if occ == . & inrange(v258,13,15)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v112,1,2)				
replace edu = 2 if inrange(v112,3,5)
replace edu = 3 if inlist(v112,6,7,8,9)
lab var edu "Education"

gen bul:bul = 1 if inlist(v398,1,2,4)
replace bul = 2 if v398==3
replace bul = 3 if v398==5
replace bul = 4 if v398==6
replace bul = 5 if v398==9
replace bul = 6 if v398==8
replace bul = 7 if inlist(v398,7,10)
lab var bul "Region"

gen mar:mar = 1 if v394==1
replace mar = 2 if inlist(v394,3,4)
replace mar = 3 if v394==2
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v119 == 2
replace denom = 2 if v119 == 1
replace denom = 3 if v119 == 3 | v119 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 83b
save `83b'
local flist "`flist' `83b'"


// 1987 ZA-Nr. 1536  "Wahlstudie 1987 (Politbarom. West)"
// -----------------------------------------------------
// Election date was 25. Januar 1987. January survey does not
// have anticipated participation. I only use post-election data

use $btw/s1536 if v3 == 287 & v339 >= 18 // 3 obs age 17

gen str8 zanr = "1536-II"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Feb1987"
gen intend = "28Feb1987"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v359*v360

gen voter:yesno = inlist(v229,1,2) if inlist(v229,1,2,3)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v318,1,2,3)
replace lr = 2 if inlist(v318,4,5)
replace lr = 3 if inlist(v318,6)
replace lr = 4 if inlist(v318,7,8)
replace lr = 5 if inlist(v318,9,10,11)
replace lr = 6 if v318==99
lab var lr "Left right self-placement"

gen polint = 6 - v112 if v112<=3
replace polint = 1 if v111 == 3
replace polint = 2 if v111 == 2
lab var polint "Politicial interest"

gen party:party = 1 if v232==2
replace party = 2 if v232==1
replace party = 3 if v232==3
replace party = 3 if v232==4
replace party = 3 if inlist(v232,5,6) 
lab var party "Electoral behaviour"

gen men:yesno = v336 == 1 if inlist(v336,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v339,18,29)
replace agegroup = 2 if inrange(v339,30,64)
replace agegroup = 3 if inrange(v339,65,94)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v342,1,2,3) 
replace emp = 2 if inlist(v342,8,9,10) 
replace emp = 3 if v342==6
replace emp = 4 if (v342==5 | v342 == 7) & !men
replace emp = 5 if v342==4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v347,1,4) | inrange(v347,16,17)
replace occ = 2 if inrange(v347,5,12)
replace occ = 3 if inrange(v347,13,15)
replace occ = 1 if occ == . & (inrange(v343,1,4) | inrange(v343,16,17))
replace occ = 2 if occ == . & inrange(v343,5,12)
replace occ = 3 if occ == . & inrange(v343,13,15)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v341,1,2)				
replace edu = 2 if inrange(v341,3,5)
replace edu = 3 if inlist(v341,6,7,8,9)
lab var edu "Education"

gen bul:bul = 1 if inlist(v356,1,2,4)
replace bul = 2 if v356==3
replace bul = 3 if v356==5
replace bul = 4 if v356==6
replace bul = 5 if v356==9
replace bul = 6 if v356==8
replace bul = 7 if inlist(v356,7,10)
lab var bul "Region"

gen mar:mar = 1 if v340==1
replace mar = 2 if inlist(v340,3,4)
replace mar = 3 if v340==2
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v351 == 2
replace denom = 2 if v351 == 1
replace denom = 3 if v351 == 3 | v351 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 87a
save `87a'
local flist "`flist' `87a'"


// 1987 ZA-Nr. 1537 "Wahlstudie 1987 (Panelstudie)"
// ------------------------------------------------
// Election date was 25. Januar 1987. I took voting from
// February 1987 survey 

use $btw/s1537 if v357 == 2

gen str8 zanr = "1537-III"
lab var zanr "Zentralarchiv study number"

gen intstart = "06Feb1987"
gen intend = "23Feb1987"

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v354*v355

gen voter:yesno = inlist(v361,1,2) if v361 <= 3 
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v314,1,2,3)
replace lr = 2 if inlist(v314,4,5)
replace lr = 3 if inlist(v314,6)
replace lr = 4 if inlist(v314,7,8)
replace lr = 5 if inlist(v314,9,10,11)
replace lr = 6 if v314==.
lab var lr "Left right self-placement"

gen polint = 6 - v199 
replace polint = 1 if v198 == 3
replace polint = 2 if v198 == 2
lab var polint "Politicial interest"

gen party:party = 1 if v363==2
replace party = 2 if v363==1
replace party = 3 if v363==3
replace party = 3 if v363==4
replace party = 3 if inlist(v363,5,6) 
lab var party "Electoral behaviour"

gen men:yesno = v334 == 1 if inlist(v334,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v337,18,29)
replace agegroup = 2 if inrange(v337,30,64)
replace agegroup = 3 if inrange(v337,65,92)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v340,1,2,3) 
replace emp = 2 if inlist(v340,8,9,10) 
replace emp = 3 if v340==6
replace emp = 4 if (v340==5 | v340 == 7) & !men
replace emp = 5 if v340==4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v344,1,4) | inrange(v344,16,18)
replace occ = 2 if inrange(v344,5,12)
replace occ = 3 if inrange(v344,13,15)
replace occ = 1 if occ == . & (inrange(v341,1,4) | inrange(v341,16,18))
replace occ = 2 if occ == . & inrange(v341,5,12)
replace occ = 3 if occ == . & inrange(v341,13,15)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v339,1,2)				
replace edu = 2 if inrange(v339,3,5)
replace edu = 3 if inlist(v339,6,7,8,9)
lab var edu "Education"

gen bul:bul = 1 if inlist(v351,1,2,4)
replace bul = 2 if v351==3
replace bul = 3 if v351==5
replace bul = 4 if v351==6
replace bul = 5 if v351==9
replace bul = 6 if v351==8
replace bul = 7 if inlist(v351,7,10)
lab var bul "Region"

gen mar:mar = 1 if v338==1
replace mar = 2 if inlist(v338,3,4)
replace mar = 3 if v338==2
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v346 == 2
replace denom = 2 if v346 == 1
replace denom = 3 if v346 == 3 | v346 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 87b
save `87b'
local flist "`flist' `87b'"


// 1990 ZA-Nr. 1919 "Wahlstudie 1990 (Panelstudie)" 
// ------------------------------------------------
// Election date: 2. December 1990.
// Study not used due to serious doubts concerning representativity.
// For details, check out the link "Studienbeschreibung" on
// http://www.gesis.org/Datenservice/Wahlstudien/Btw/dw_studien.htm


// 1990 ZA-Nr. 1920 "Wahlstudie 1990 (Politbarom. West)"
// -----------------------------------------------------
// Election date: 2. December 1990. I had to use May, because no indicators for
// political interest available in other studies

use $btw/s1920 if inlist(v3,5) 

gen str8 zanr = "1920-V"
lab var zanr "Zentralarchiv study number"

gen intstart = "01May1990"
gen intend = "30May1990"

gen id = v2
lab var id "Original idenifier"
isid v3 id

gen double weight = v283*v284

gen voter:yesno = inlist(v10,1) if inlist(v10,1,2)
lab var voter "Voter y/n"

gen polint = (v210!=8)*v211 + (v212!=8)*v213 + (v214!=8)*v215  ///
  if v210!=9 & v211!=8 & v212!=9 & v213!=8 & v214!=9 & v215!=8 
lab var polint "Politicial interest"

gen lr:lr = 1 if v190 == 1 & inlist(v191,1,2)
replace lr = 2 if v190 == 1 & inlist(v191,3,4,5)
replace lr = 3 if v190 == 2
replace lr = 4 if v190 == 3 & inlist(v192,3,4,5)
replace lr = 5 if v190 == 3 & inlist(v192,1,2)
replace lr = 6 if v190==9
lab var lr "Left right self-placement"

gen party:party = 1 if v12==2
replace party = 2 if v12==1
replace party = 3 if v12==3
replace party = 3 if v12==4
replace party = 3 if inlist(v12,5,6,7) 
lab var party "Electoral behaviour"

gen men:yesno = v262 == 1 if inlist(v262,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v263,1,3)
replace agegroup = 2 if inrange(v263,4,8)
replace agegroup = 3 if inrange(v263,9,10)
label variable agegroup "Agegroup"
note agegroup: ZA 1920 (year 1990): 2=30-60 and 3=60+

gen emp:emp = 1 if inlist(v270,1,2,3) 
replace emp = 2 if inlist(v270,7) 
replace emp = 3 if v270==5
replace emp = 4 if v270==8
replace emp = 5 if v270==4
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v275,14,15) 
replace occ = 2 if inrange(v275,3,10)
replace occ = 3 if inrange(v275,1,2)
replace occ = 1 if occ == . & inrange(v271,14,15) 
replace occ = 2 if occ == . & inrange(v271,3,10)
replace occ = 3 if occ == . & inrange(v271,1,2)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v266,1,2)				
replace edu = 2 if inlist(v266,3)
replace edu = 3 if inlist(v266,4)
lab var edu "Education"

gen bul:bul = 1 if inlist(v4,1,2,4)
replace bul = 2 if v4==3
replace bul = 3 if v4==5
replace bul = 4 if v4==6
replace bul = 5 if v4==9
replace bul = 6 if v4==8
replace bul = 7 if inlist(v4,7,10)
replace bul = 8 if v4==11
lab var bul "Region"

gen mar:mar = 1 if v264==1
replace mar = 2 if inlist(v264,3,4)
replace mar = 3 if v264==2
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v277 == 2
replace denom = 2 if v277 == 1
replace denom = 3 if v277 == 3 | v277 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90
save `90'
local flist "`flist' `90'"


// 1990 ZA-Nr. 1987 "Wahlstudie 1990 (Politbarom. Ost)" 
// ----------------------------------------------------
// Election date: 2. December 1990. I use December only. December
// is post-election.

use $btw/s1987 if v3 == 12 

gen str8 zanr = "1987-XII" if v3==12
lab var zanr "Zentralarchiv study number"

gen intstart = "03Dec1990" if v3==12
gen intend = "30Dec1990" if v3==12

gen id = v2
lab var id "Original idenifier"
isid v3 id

gen double weight = v264*v265

gen voter:yesno = inlist(v59,1) if inlist(v59,1,3)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v207,1,2,3)
replace lr = 2 if inlist(v207,4,5)
replace lr = 3 if inlist(v207,6)
replace lr = 4 if inlist(v207,7,8)
replace lr = 5 if inlist(v207,9,10,11,12)
replace lr = 6 if v207==99
lab var lr "Left right self-placement"

gen polint = 6 - v58 if !inlist(v58,9)
lab var polint "Politicial interest"

gen party:party = 1 if v65==2
replace party = 2 if v65==1
replace party = 3 if v65==3
replace party = 3 if v65==4
replace party = 3 if inlist(v65,5,6,7,8) 
lab var party "Electoral behaviour"

gen men:yesno = v247 == 1 if inlist(v247,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v248,1,3)
replace agegroup = 2 if inrange(v248,4,8)
replace agegroup = 3 if inrange(v248,9,10)
label variable agegroup "Agegroup"
note agegroup: ZA 1987 (year 1990): 2=30-60 and 3=60+

gen emp:emp = 1 if inlist(v253,1,2,3) 
replace emp = 2 if inlist(v253,6,9,10) 
replace emp = 3 if inlist(v253,11,12,13)
replace emp = 4 if inlist(v253,14)
replace emp = 5 if inlist(v253,4,5,7)
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v256,5,6,9) 
replace occ = 2 if inlist(v256,3,4,8)
replace occ = 3 if inlist(v256,1,2,7,10)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v251,1)				
replace edu = 2 if inlist(v251,2)
replace edu = 3 if inlist(v251,3)
lab var edu "Education"

gen bul:bul = 8 if inlist(v263,1,2)
replace bul = 9 if v263==3
replace bul = 10 if v263==4
replace bul = 11 if v263==5
replace bul = 12 if v263==6
lab var bul "Region"

gen mar:mar = 1 if v250==1
replace mar = 2 if inlist(v250,4,5,6,7)
replace mar = 3 if inlist(v250,2,3)
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v249 == 1
replace denom = 2 if v249 == 2
replace denom = 3 if v249 == 3 | v249 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 90o
save `90o'
local flist "`flist' `90o'"


// 1994 ZA-Nr. 2546 "Wahlstudie 1994 (Politbarom. West)"
// ----------------------------------------------------
// Election date: 16. October 1994. Post-election surveys refer
// to elections on "next sunday". I have only used the "Blitz"-survey
// before the election. 

use $btw/s2546 if v3 == 9 

gen str8 zanr = "2546-IX"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1994" 
gen intend = "15Oct1994" 

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v309*v310

gen voter:yesno = inlist(v8,1,2,5) if inlist(v8,1,2,3,4,5)
lab var voter "Voter y/n"

gen lr:lr = 1 if v218 == 1 & inlist(v219,4,5)
replace lr = 2 if v218 == 1 & inlist(v219,1,2,3)
replace lr = 3 if v218 == 2
replace lr = 4 if v218 == 3 & inlist(v220,1,2,3)
replace lr = 5 if v218 == 3 & inlist(v220,4,5)
replace lr = 6 if v218==.
lab var lr "Left right self-placement"

gen polint = 6 - v117 
lab var polint "Politicial interest"

gen party:party = 1 if v11==2
replace party = 2 if v11==1
replace party = 3 if v11==3
replace party = 3 if v11==4
replace party = 3 if inlist(v11,5,6,7,8,9,14) 
lab var party "Electoral behaviour"

gen men:yesno = v284 == 1 if inlist(v284,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v285,1,3)
replace agegroup = 2 if inrange(v285,4,8)
replace agegroup = 3 if inrange(v285,9,10)
label variable agegroup "Agegroup"
note agegroup: ZA 2546 (year 1994): 2=30-60 and 3=60+

gen emp:emp = 1 if inlist(v291,1,2,3) 
replace emp = 2 if inlist(v291,7) 
replace emp = 3 if v291==6
replace emp = 4 if v291==9  & !men
replace emp = 5 if inlist(v291,4,5)
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v298,13,14)
replace occ = 2 if inrange(v298,4,10)
replace occ = 3 if inrange(v298,1,3)
replace occ = 1 if occ == . & inrange(v293,13,14)
replace occ = 2 if occ == . & inrange(v293,4,10)
replace occ = 3 if occ == . & inrange(v293,1,3)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v288,1,4)				
replace edu = 2 if inlist(v288,2)
replace edu = 3 if inlist(v288,3)
lab var edu "Education"

gen bul:bul = 1 if inlist(v307,1,2,4)
replace bul = 2 if v307==3
replace bul = 3 if v307==5
replace bul = 4 if v307==6
replace bul = 5 if v307==9
replace bul = 6 if v307==8
replace bul = 7 if inlist(v307,7,10)
replace bul = 8 if v307==11
lab var bul "Region"

gen mar:mar = 1 if v286==1
replace mar = 2 if inlist(v286,2,4,5)
replace mar = 3 if v286==3
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v300 == 2
replace denom = 2 if v300 == 1
replace denom = 3 if v300 == 3 | v300 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94a
save `94a'
local flist "`flist' `94a'"


// 1994 ZA-Nr. 2559 "Wahlstudie 1994 (Politbarom. Ost)"
// ----------------------------------------------------
// Election date: 16. October 1994. Post-election surveys refer
// to elections on "next sunday". I have only used the "Blitz"-survey
// before the election. 

use $btw/s2559 if v3 == 9 

gen str8 zanr = "2559-IX"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct1994" 
gen intend = "15Oct1994" 

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v328*v329

gen voter:yesno = inlist(v6,1,5) if inlist(v9,1,2,3,4,5)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v231,1,2,3)
replace lr = 2 if inlist(v231,4,5)
replace lr = 3 if inlist(v231,6)
replace lr = 4 if inlist(v231,7,8)
replace lr = 5 if inlist(v231,9,10,11)
replace lr = 6 if v231==99
lab var lr "Left right self-placement"

gen polint = 6 - v145
lab var polint "Politicial interest"

gen party:party = 1 if v9==2
replace party = 2 if v9==1
replace party = 3 if v9==3
replace party = 3 if v9==4
replace party = 3 if inlist(v9,5,6,7,8,9,10,11,12,13,14) 
lab var party "Electoral behaviour"

gen men:yesno = v303 == 1 if inlist(v303,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v304,1,3)
replace agegroup = 2 if inrange(v304,4,8)
replace agegroup = 3 if inrange(v304,9,10)
label variable agegroup "Agegroup"
note agegroup: ZA 2559 (year 1994): 2=30-60 and 3=60+

gen emp:emp = 1 if inlist(v310,1,2,3) 
replace emp = 2 if inlist(v310,7) 
replace emp = 3 if v310==6
replace emp = 4 if v310==9 
replace emp = 5 if inlist(v310,4,5)

replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v317,13,14)
replace occ = 2 if inrange(v317,4,11)
replace occ = 3 if inrange(v317,1,3)
replace occ = 1 if occ == . & inrange(v312,13,14)
replace occ = 2 if occ == . & inrange(v312,4,10)
replace occ = 3 if occ == . & inrange(v312,1,3)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v307,1,6)				
replace edu = 2 if inlist(v307,2)
replace edu = 3 if inlist(v307,3,4,5)
lab var edu "Education"

gen bul:bul = 8 if inlist(v325,1,2)
replace bul = 9 if v325==3
replace bul = 10 if v325==4
replace bul = 11 if v325==5
replace bul = 12 if v325==6
lab var bul "Region"

gen mar:mar = 1 if v305==1
replace mar = 2 if inlist(v305,2,4,5)
replace mar = 3 if v305==3
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v319 == 2
replace denom = 2 if v319 == 1
replace denom = 3 if v319 == 3 | v319 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94ao
save `94ao'
local flist "`flist' `94ao'"

// 1994 ZA-Nr. 2601 "Nachw.-stud. 1994"
// ------------------------------------
//  Election date: 16. October 1994, Observation period Oct/Nov 1994

use $btw/s2601 

gen str8 zanr = "2601"
lab var zanr "Zentralarchiv study number"

gen intstart = "17Oct1994" 
gen intend = "09Nov1994" 

gen id = v2
lab var id "Original idenifier"
isid id

gen double weight = v209

gen voter:yesno = inlist(v9,1,2) if inlist(v9,1,2,3)
lab var voter "Voter y/n"

gen polint = 6 - v8 
lab var polint "Politicial interest"

gen lr:lr = 1 if inlist(v89,1,2)
replace lr = 2 if inlist(v89,3,4)
replace lr = 3 if inlist(v89,5,6)
replace lr = 4 if inlist(v89,7,8)
replace lr = 5 if inlist(v89,9,10)
replace lr = 6 if v89==.
lab var lr "Left right self-placement"

gen party:party = 1 if v11==2
replace party = 2 if v11==1
replace party = 3 if v11==3
replace party = 3 if v11==4
replace party = 3 if inlist(v11,5,6,7) 
lab var party "Electoral behaviour"

gen men:yesno = v138 == 1 if inlist(v138,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v206,18,29)
replace agegroup = 2 if inrange(v206,30,64)
replace agegroup = 3 if inrange(v206,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v154,1,2,3) 
replace emp = 2 if inlist(v154,4) | (v154==7 & v155==1)
replace emp = 3 if inlist(v154,7) & v155==5
replace emp = 4 if inlist(v154,6) | (inlist(v154,7) & v155==6)
replace emp = 5 if (inlist(v154,7) & inlist(v155,3,4)) | v154==5
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v157,1,3)
replace occ = 2 if inrange(v157,4,5)
replace occ = 3 if inlist(v157,6)
replace occ = 1 if occ == . & inrange(v160,1,3)
replace occ = 2 if occ == . & inrange(v160,4,5)
replace occ = 3 if occ == . & inlist(v160,6)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inrange(v141,1,4)				
replace edu = 2 if inlist(v141,5,6,7)
replace edu = 3 if inlist(v141,8)
lab var edu "Education"

gen bul:bul = 1 if inlist(v202,1,2,4)
replace bul = 2 if v202==3
replace bul = 3 if v202==5
replace bul = 4 if v202==6
replace bul = 5 if v202==9
replace bul = 6 if v202==8
replace bul = 7 if inlist(v202,7,10)
replace bul = 8 if inlist(v202,11,12)
replace bul = 9 if v202==13
replace bul = 10 if v202==14
replace bul = 11 if v202==15
replace bul = 12 if v202==16
lab var bul "Region"

gen mar:mar = 1 if v163==1
replace mar = 2 if inlist(v163,2,3,4)
replace mar = 3 if v163==5
label variable mar "Marital status"   

xtile hhinc1 = v192, nq(3)
xtile hhinc2 = v193, nq(3)
gen hhinc = hhinc1
replace hhinc = hhinc2 if hhinc1==.
drop hhinc1 hhinc2
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = . 
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94c
save `94c'
local flist "`flist' `94c'"


// 1994 ZA-Nr. 3065 "Polit. Einst., polit. Part. u. Wählerverh. ..."
// -----------------------------------------------------------------
// Election date: 16. October 1994, 
// Observation Period I 12 Sep 94 - 14. Oct 94
// Observation Period II 24 Oct 94 - 01. Dec 94

use $btw/s3065 if (1994 - (1900+vjahr)) >= 18

gen str8 zanr = "3065-I" if vvornach==1
replace zanr = "3065-II" if vvornach==2
lab var zanr "Zentralarchiv study number"

gen intstart = "12Sep1994" if vvornach==1
gen intend = "14Oct1994" if vvornach==1
replace intstart = "24Oct1994" if vvornach==2
replace intend = "01Dec1994" if vvornach==2

gen id = vvpnid
lab var id "Original idenifier"
isid id

gen double weight = vgges

gen voter:yesno = inlist(v60,1,2) if inlist(v60,1,2,4,5)
replace voter = inrange(v61,1,12) if inrange(v61,1,96)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v250,1,2,3)
replace lr = 2 if inlist(v250,4,5)
replace lr = 3 if inlist(v250,6)
replace lr = 4 if inlist(v250,7,8)
replace lr = 5 if inlist(v250,9,10,11)
replace lr = 6 if v250==98
lab var lr "Left right self-placement"

gen polint = 6 - v50 if !inlist(v50,8,9)
lab var polint "Politicial interest"

gen party:party = 1 if v66==2
replace party = 2 if v66==1
replace party = 3 if v66==3
replace party = 3 if v66==4
replace party = 3 if inlist(v66,5,6,12) 
lab var party "Electoral behaviour"

gen men:yesno = vsex == 1 if inlist(vsex,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(1994-(1900+vjahr),18,29)
replace agegroup = 2 if inrange(1994-(1900+vjahr),30,64)
replace agegroup = 3 if inrange(1994-(1900+vjahr),65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vberuftg,1,2,6) 
replace emp = 2 if inlist(vberuftg,3,14) 
replace emp = 3 if inlist(vberuftg,10)
replace emp = 4 if inlist(vberuftg,9)
replace emp = 5 if inlist(vberuftg,5) 
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(vhvbergr,1,3) | inrange(vhvbergr,16,19)  
replace occ = 2 if inrange(vhvbergr,4,11)									  
replace occ = 3 if inrange(vhvbergr,12,15)                           
replace occ = 1 if occ == . & inrange(vberuf,1,3) | inrange(vberuf,16,19)  
replace occ = 2 if occ == . & inrange(vberuf,4,11)							  
replace occ = 3 if occ == . & inrange(vberuf,12,15) 
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vbildg,1)				
replace edu = 2 if inlist(vbildg,2)
replace edu = 3 if inlist(vbildg,3,4)
lab var edu "Education"

gen bul:bul = 1 if inlist(vland,1,2,4)
replace bul = 2 if vland==3
replace bul = 3 if vland==5
replace bul = 4 if vland==6
replace bul = 5 if vland==9
replace bul = 6 if vland==8
replace bul = 7 if inlist(vland,7,10)
replace bul = 8 if inlist(vland,11,12)
replace bul = 9 if vland==13
replace bul = 10 if vland==14
replace bul = 11 if vland==15
replace bul = 12 if vland==16
lab var bul "Region"

gen mar:mar = 1 if vfamstd==1
replace mar = 2 if inlist(vfamstd,4,5,6,7,8,9)
replace mar = 3 if inlist(vfamstd,2,3)
label variable mar "Marital status"   

xtile hhinc = vhheinko if vhheinko <= 12, nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if inlist(vrelig,1)
replace denom = 2 if inlist(vrelig,2)
replace denom = 3 if inlist(vrelig,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 94d
save `94d'
local flist "`flist' `94d'"


// 1998 ZA-Nr. 3066 "Polit. Einst., polit. Part. ..."
// -----------------------------------------------------
// Election date: 27. Sep. 1998
// Observation Period I 26. August 1998 bis 26. September 1998
// Observation Period II 08. October 1998 bis 21. November 1998

use $btw/s3066 if (1994 - (1900+vjahr)) >= 18

gen str8 zanr = "3066-I" if vvornach==1
replace zanr = "3066-II" if vvornach==2
lab var zanr "Zentralarchiv study number"

gen intstart = "26Aug1998" if vvornach==1
gen intend = "26Sep1998" if vvornach==1
replace intstart = "08Oct1998" if vvornach==2
replace intend = "21Nov1998" if vvornach==2

gen id = vvpnid
lab var id "Original idenifier"
isid id

gen double weight = vgges

gen voter:yesno = inlist(v60,1,2) if inlist(v60,1,2,4,5)
replace voter = inrange(v69,1,12) if inrange(v69,1,96)
lab var voter "Voter y/n"

gen polint = 6 - v50 if !inlist(v50,8,9)
lab var polint "Politicial interest"

gen lr:lr = 1 if inlist(v250,1,2,3)
replace lr = 2 if inlist(v250,4,5)
replace lr = 3 if inlist(v250,6)
replace lr = 4 if inlist(v250,7,8)
replace lr = 5 if inlist(v250,9,10,11)
replace lr = 6 if v250==98
lab var lr "Left right self-placement"

gen party:party = 1 if v70==2
replace party = 2 if v70==1
replace party = 3 if v70==3
replace party = 3 if v70==4
replace party = 3 if inlist(v70,5,6,7,9,10,11,12) 
lab var party "Electoral behaviour"

gen men:yesno = vsex == 1 if inlist(vsex,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(1994-(1900+vjahr),18,29)
replace agegroup = 2 if inrange(1994-(1900+vjahr),30,64)
replace agegroup = 3 if inrange(1994-(1900+vjahr),65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vberuftg,1,2,4,6) 
replace emp = 2 if inlist(vberuftg,3,12,13) 
replace emp = 3 if inlist(vberuftg,10)
replace emp = 4 if inlist(vberuftg,8,9)
replace emp = 5 if inlist(vberuftg,5,7) 
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(vpberuf,1,3) | inrange(vpberuf,16,19) ///
                 | inrange(vberuf,1,3) | inrange(vberuf,16,19)
replace occ = 2 if occ == . & (inrange(vpberuf,4,11) | inrange(vberuf,4,11))
replace occ = 3 if occ == . & (inrange(vpberuf,12,15) | inrange(vberuf,12,15))
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vbildg,0,1)				
replace edu = 2 if inlist(vbildg,2)
replace edu = 3 if inlist(vbildg,3,4)
lab var edu "Education"

gen bul:bul = 1 if inlist(vland,1,2,4)
replace bul = 2 if vland==3
replace bul = 3 if vland==5
replace bul = 4 if vland==6
replace bul = 5 if vland==9
replace bul = 6 if vland==8
replace bul = 7 if inlist(vland,7,10)
replace bul = 8 if inlist(vland,11,12)
replace bul = 9 if vland==13
replace bul = 10 if vland==14
replace bul = 11 if vland==15
replace bul = 12 if vland==16
lab var bul "Region"

gen mar:mar = 1 if vfamstdn==1
replace mar = 2 if inlist(vfamstdn,2,3,4)
replace mar = 3 if inlist(vfamstdn,5)
label variable mar "Marital status"   

xtile hhinc = vhheink if vhheink <= 12, nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if inlist(vrelig,1)
replace denom = 2 if inlist(vrelig,2)
replace denom = 3 if inlist(vrelig,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 98a
save `98a'
local flist "`flist' `98a'"


// 1998 ZA-Nr. 3073 "Dt. Nat. Wahlstudie - Nachw.-stud. 1998 (CSES)"
// -----------------------------------------------------------------
// Election date: 27. Sep. 1998
// Observation Period: September 1998 bis October 1998 

use $btw/s3073 

gen str8 zanr = "3073"
lab var zanr "Zentralarchiv study number"

gen intstart = "28Sep1998"
gen intend = "17Oct1998" 

gen id = v2
lab var id "Original identifier"
isid id

gen double weight = v265

gen voter:yesno = v194 == 1 if inlist(v194,1,2)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v66,1,2,3)
replace lr = 2 if inlist(v66,4,5)
replace lr = 3 if inlist(v66,6)
replace lr = 4 if inlist(v66,7,8)
replace lr = 5 if inlist(v66,9,10,11)
replace lr = 6 if v66==.
lab var lr "Left right self-placement"

gen polint = 5 - v93
lab var polint "Politicial interest"

gen party:party = 1 if v196==3
replace party = 2 if v196==1 | v196==2
replace party = 3 if v196==4
replace party = 3 if v196==5
replace party = 3 if inlist(v196,6,7,8,9) 
lab var party "Electoral behaviour"

gen men:yesno = v199 == 1 if inlist(v199,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(1998-v198,18,29)
replace agegroup = 2 if inrange(1998-v198,30,64)
replace agegroup = 3 if inrange(1998-v198,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(v205,1,2) 
replace emp = 2 if inlist(v205,5) | (inlist(v205,3,6,.) & v206==1)
replace emp = 3 if inlist(v205,3,6,.) & v206 == 2 
replace emp = 4 if inlist(v205,3,6,.) & v206 == 4
replace emp = 5 if inlist(v205,3,6,.) & v206 == 3
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inlist(v242,1,2,3) 							
replace occ = 2 if inlist(v242,4,5)									  
replace occ = 3 if inlist(v242,6)                           
replace occ = 1 if occ == . & inlist(v209,1,2,3) 
replace occ = 2 if occ == . & inlist(v209,4,5)		
replace occ = 3 if occ == . & inlist(v209,6)
replace occ = 1 if occ == . & inlist(v227,1,2,3) 
replace occ = 2 if occ == . & inlist(v227,4,5)		
replace occ = 3 if occ == . & inlist(v227,6)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v200,1,2)				
replace edu = 2 if inlist(v200,3,4,5)
replace edu = 3 if inlist(v200,6,7,8,9)
lab var edu "Education"

gen bul:bul = 1 if inlist(v261,1,2,4)
replace bul = 2 if v261==3
replace bul = 3 if v261==5
replace bul = 4 if v261==6
replace bul = 5 if v261==9
replace bul = 6 if v261==8
replace bul = 7 if inlist(v261,7,10)
replace bul = 8 if inlist(v261,11,12,13)
replace bul = 9 if v261==14
replace bul = 10 if v261==15
replace bul = 11 if v261==16
replace bul = 12 if v261==17
lab var bul "Region"

gen mar:mar = 1 if v201==1
replace mar = 2 if inlist(v201,2,4,5)
replace mar = 3 if inlist(v201,3)
label variable mar "Marital status"   

xtile hhinc = v252 if v252 <= 12, nq(3)
replace hhinc = 1 if v253 <= 3
replace hhinc = 2 if v253 == 4
replace hhinc = 3 if v253 > 4 & v253 < .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if inlist(v256,1)
replace denom = 2 if inlist(v256,2)
replace denom = 3 if inlist(v256,3,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 98b
save `98b'
local flist "`flist' `98b'"


// 1998 ZA-Nr. 3160 "Wahlstudie 1998 (Politbarom.)"
// ------------------------------------------------
// Election date: 27. Sep. 1998. I used the "Blitz"-survey immediately
// before the election, an three Oct/Nov/Dec Survey past the election.

use $btw/s3160 if inrange(v3,11,14) 

gen str8 zanr = "3160-IX" if v3==11
replace zanr = "3160-X" if v3==12
replace zanr = "3160-XI" if v3==13
replace zanr = "3160-XII" if v3==14
lab var zanr "Zentralarchiv study number"

gen intstart = "14Sep1998" if v3==11
gen intend = "20Sep1998" if v3==11
replace intstart = "01Oct1998" if v3==12
replace intend = "30Oct1998" if v3==12
replace intstart = "01Nov1998" if v3==13
replace intend = "30Nov1998" if v3==13
replace intstart = "01Dec1998" if v3==14
replace intend = "30Dec1998" if v3==14

gen id = v2
lab var id "Original idenifier"
isid zanr id

gen double weight = v369*v370

gen voter:yesno = inlist(v8,1,5) if inlist(v8,1,4,5) & v3==11
replace voter = inrange(v24,1,13) if inrange(v24,1,14) & inrange(v3,12,14)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v233,1,2,3)
replace lr = 2 if inlist(v233,4,5)
replace lr = 3 if inlist(v233,6)
replace lr = 4 if inlist(v233,7,8)
replace lr = 5 if inlist(v233,9,10,11)
replace lr = 6 if v233==99
lab var lr "Left right self-placement"

gen polint = 6 - v149 if !inlist(v149,0,9)
lab var polint "Politicial interest"

gen party:party = 1 if v9==2 
replace party = 2 if v9==1 
replace party = 3 if v9==3 
replace party = 3 if v9==4 
replace party = 3 if inlist(v9,5,6,7,8,9,11,12) 
lab var party "Electoral behaviour"

gen men:yesno = v274 == 1 if inlist(v274,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(v275,1,3)
replace agegroup = 2 if inrange(v275,4,8)
replace agegroup = 3 if inrange(v275,9,10)
label variable agegroup "Agegroup"
note agegroup: ZA 3160 (year 1998): 2=30-60 and 3=60+

gen emp:emp = 1 if inlist(v352,1,2,3) 
replace emp = 2 if inlist(v352,8) 
replace emp = 3 if v352==  7
replace emp = 4 if v352== 10  & !men
replace emp = 5 if inlist(v352,5,6)
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(v359,13,14)
replace occ = 2 if inrange(v359,4,11)
replace occ = 3 if inrange(v359,1,3)
replace occ = 1 if occ == . & inrange(v354,13,14)
replace occ = 2 if occ == . & inrange(v354,4,11)
replace occ = 3 if occ == . & inrange(v354,1,3)
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(v347,1,4)				
replace edu = 2 if inlist(v347,2)
replace edu = 3 if inlist(v347,3)
lab var edu "Education"

gen bul:bul = 1 if inlist(v4,1,2,4)
replace bul = 2 if v4==3
replace bul = 3 if v4==5
replace bul = 4 if v4==6
replace bul = 5 if v4==9
replace bul = 6 if v4==8
replace bul = 7 if inlist(v4,7,10)
replace bul = 8 if inlist(v4,11,12,13)
replace bul = 9 if v4==14
replace bul = 10 if v4==15
replace bul = 11 if v4==16
replace bul = 12 if v4==17
lab var bul "Region"

gen mar:mar = 1 if v276==1
replace mar = 2 if inlist(v276,2,4,5)
replace mar = 3 if v276==3
label variable mar "Marital status"   

gen hhinc = .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if v361 == 2
replace denom = 2 if v361 == 1
replace denom = 3 if v361 == 3 | v361 == 4
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 98c
save `98c'
local flist "`flist' `98c'"

// 2002 ZA-Nr. 3861 "Political Attitudes, Political Participation 
// and Voter Conduct in united Germany 2002"
// --------------------------------------------
// Election date: 22. September 2002 
// Observation Period: 
// pre-election: 12. August to 21. September 2002
// post-election: 1. October to 8. November 2002

use $btw/s3861
lc

gen str8 zanr = "3861-I" if vvornach==1
replace zanr = "3861-II" if vvornach==2
lab var zanr "Zentralarchiv study number"

gen intstart = "12Aug2002" if vvornach==1
gen intend = "21Sep2002" if vvornach==1
replace intstart = "01Oct2002" if vvornach==2
replace intend = "08Nov2002" if vvornach==2

gen id = vvpnid
lab var id "Original idenifier"
isid id
gen double weight = vgges

gen voter:yesno = inlist(v60,1) if inlist(v60,1,2,3,4,5)
replace voter = inrange(v62,1,2) if inlist(v62,1,2,4)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v250,1,2,3)
replace lr = 2 if inlist(v250,4,5)
replace lr = 3 if inlist(v250,6)
replace lr = 4 if inlist(v250,7,8)
replace lr = 5 if inlist(v250,9,10,11)
replace lr = 6 if v250==98
lab var lr "Left right self-placement"

gen polint = 6 - v50 if !inlist(v50,8,9)
lab var polint "Politicial interest"

gen party:party = 1 if v70==2
replace party = 2 if v70==1
replace party = 3 if v70==3
replace party = 3 if v70==4
replace party = 3 if inlist(v70,5,6,7,8,9,10,11) 
lab var party "Electoral behaviour"

gen men:yesno = vsex == 1 if inlist(vsex,1,2)
lab var men "Man y/n"

gen agegroup:agegroup = 1 if inrange(2002-vjahr,18,29)
replace agegroup = 2 if inrange(2002-vjahr,30,64)
replace agegroup = 3 if inrange(2002-vjahr,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(vberuftg,1,2,4,6) 
replace emp = 2 if inlist(vberuftg,3,12,13) 
replace emp = 3 if inlist(vberuftg,10)
replace emp = 4 if inlist(vberuftg,8,9)
replace emp = 5 if inlist(vberuftg,5,7) 
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inrange(vpberuf,1,3) | inrange(vpberuf,16,19) ///
                 | inrange(vberuf,1,3) | inrange(vberuf,16,19)
replace occ = 2 if occ == . & (inrange(vpberuf,4,11) | inrange(vberuf,4,11))
replace occ = 3 if occ == . & (inrange(vpberuf,12,15) | inrange(vberuf,12,15))
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(vbildga,2,3)				
replace edu = 2 if inlist(vbildga,4)
replace edu = 3 if inlist(vbildga,5,6)
lab var edu "Education"

gen bul:bul = 1 if inlist(vland,1,2,4)
replace bul = 2 if vland==3
replace bul = 3 if vland==5
replace bul = 4 if vland==6
replace bul = 5 if vland==9
replace bul = 6 if vland==8
replace bul = 7 if inlist(vland,7,10)
replace bul = 8 if inlist(vland,11,12)
replace bul = 9 if vland==13
replace bul = 10 if vland==14
replace bul = 11 if vland==15
replace bul = 12 if vland==16
lab var bul "Region"

gen mar:mar = 1 if vfamstdn==1
replace mar = 2 if inlist(vfamstdn,2,3,4)
replace mar = 3 if inlist(vfamstdn,5)
label variable mar "Marital status"   

xtile hhinc = vhheink if vhheink <= 12, nq(3)
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if inlist(vrelig,1)
replace denom = 2 if inlist(vrelig,2)
replace denom = 3 if inlist(vrelig,3,4,5,6)
label variable denom "Denomination"

keep zanr-denom

compress
tempfile 02
save `02'
local flist "`flist' `02'"


// 2005 ZA-Nr. X "Testmodul deutsche CSES III" 
// ------------------------------------------
// Election date was 18. September 2005 

use $cses/nw-btw2005-wzb-2006-1-v3 if (2005-d01) >= 18

gen str8 zanr = "WZB"
lab var zanr "Zentralarchiv study number"

gen intstart = "01Oct2005" 
gen intend = "30Oct2005"

gen id = bnr1
lab var id "Original idenifier"
isid id

gen double weight = pgewprop

gen voter:yesno = v18 == 1 if inrange(v18,1,2)
lab var voter "Voter y/n"

gen lr:lr = 1 if inlist(v12,1,2,3)
replace lr = 2 if inlist(v12,4,5)
replace lr = 3 if inlist(v12,6)
replace lr = 4 if inlist(v12,7,8)
replace lr = 5 if inlist(v12,9,10,11)
replace lr = 6 if v12==.
lab var lr "Left right self-placement"

gen polint = 5 - v14 if !inlist(v14,8,9)
lab var polint "Politicial interest"

gen party:party = 1 if v19b==2
replace party = 2 if v19b==1
replace party = 3 if v19b==3
replace party = 3 if v19b==4
replace party = 3 if inlist(v19b,5,6,7,8,9,10,21,23)
lab var party "Electoral behaviour"

gen men:yesno = d02 == 1 if inlist(d02,1,2)
lab var men "Man y/n"

replace d01 = 2005-d01
gen agegroup:agegroup = 1 if inrange(d01,18,29)
replace agegroup = 2 if inrange(d01,30,64)
replace agegroup = 3 if inrange(d01,65,89)
label variable agegroup "Agegroup"

gen emp:emp = 1 if inlist(d10,1,2,3,6)
replace emp = 2 if d10 == 5 | (d10==7 & d10a==1)
replace emp = 3 if inlist(d10,7,.) & d10a == 2
replace emp = 4 if inlist(d10,7,.) & d10a == 4
replace emp = 5 if inlist(d10,7,.) & d10a == 3
replace emp = 6 if emp==.
lab var emp "Employment status"

gen occ:occ = 1 if inlist(d12,4,5,6) | inlist(d17,4,5,6)
replace occ = 2 if occ == . & (inlist(d12,2,3) | inlist(d17,2,3))
replace occ = 3 if occ == . & (inlist(d12,1) | inlist(d17,1))  
replace occ = 4 if occ == .
lab var occ "Occupational status"

gen edu:edu = 1 if inlist(d03,1,2)				
replace edu = 2 if inlist(d03,3,4,5)
replace edu = 3 if inlist(d03,6,7,8,9)
lab var edu "Education"

gen bul:bul = 1 if inlist(bula,1,2,4)
replace bul = 2 if bula==3
replace bul = 3 if bula==5
replace bul = 4 if bula==6
replace bul = 5 if bula==9
replace bul = 6 if bula==8
replace bul = 7 if inlist(bula,7,10)
replace bul = 8 if inlist(bula,111,112,11,12)
replace bul = 9 if bula==13
replace bul = 10 if bula==14
replace bul = 11 if bula==15
replace bul = 12 if bula==16
lab var bul "Region"

gen mar:mar = 1 if d04a == 1
replace mar = 2 if inlist(d04a,2,3,5,6)
replace mar = 3 if inlist(d04a,4)
label variable mar "Marital status"   

xtile hhinc = d20 , nq(3)
replace hhinc = 1 if d20a <=3
replace hhinc = 2 if d20a == 4 | d20a == 5
replace hhinc = 3 if d20a >  5 & d20a < .
label variable hhinc "Houshold income"					
label value hhinc hhinc

gen denom:denom = 1 if inlist(d25,1)
replace denom = 2 if inlist(d25,2)
replace denom = 3 if inlist(d25,3,4,5,6)
label variable denom "Denomination"
keep zanr-denom

compress
tempfile 05
save `05'
local flist "`flist' `05'"


// Append files together
// ---------------------

use `49', clear

foreach file in `flist' {
 append using `file'
}

// Merge Meta-Data
// ---------------

sort zanr
merge zanr using `meta'
assert _merge == 3
drop _merge

// Clean Data
// ----------

drop if voter == .

// Elapsed dates
gen eldate = date(eldatest,"DMY")
label variable eldate "Date of election"

gen start = date(intstart,"DMY")
label variable start "Start of survey period"

gen end = date(intend,"DMY")
label variable end "End of survey period"

format eldate start end %tddd_Mon_YY

drop eldatest intstart intend

// Order
order year eldate zanr name sampdes samppop start end id weight ///
  voter party men agegroup emp occ edu bul mar hhinc denom 

// Labels
label variable weight "Data-set specific weights"

lab def yesno ///
  0 "no" 1 "yes"

lab def party 							///
  1 "SPD" 2 "CDU/CSU" 3 "Other"

lab def lr 								///
  1 "Left" 2 "Center-Left" 3 "Center" 4 "Center-Rigth" 5 "Right" 6 "Other"

lab def agegroup ///
  1 "18-30" 2 "30-65" 3 "65+"

lab def emp ///
  1 "Employed" 2 "In educ." 3 "Retired" 4 "Homemaker" ///
  5 "Unemp." 6 "Other" 

lab def occ ///
  1 "S.-emp." 2 "White collar" 3 "Blue collar" ///
  4 "Other"

lab def edu ///
  1 "Low" 2 "Intermed." 3 "High" 4 "Other"

lab def mar ///
  1 "Couple" 2 "Other" 3 "Single"

lab def bul ///
1 "SH/HH/HB" 2 "NI" 3 "NW" 4 "HE" 5 "BY" ///
6 "BW" 7 "RP/SL" 8 "BE/BB" 	///
9 "MV" 10 "SN" 11 "ST" 12 "TH"

lab def hhinc ///
  1 "1st Tercile" 2 "2nd Tercile" 3 "3rd Tercile"  

lab def denom ///
  1 "Prot." 2 "Cath." 3 "Other"  


// Data-Cecks
// ----------

drop if men == . // 7 Obs 3861-I and 1987-XII
drop if bul == . // 1 Obs
assert !mi(year,zanr,name,sampdes,samppop,end,start,eldate,id,weight,voter,men,bul)
assert end - start > 0
isid zanr id

assert inlist(voter,0,1)
assert inlist(lr,1,2,3,4,5,6) if lr < .
assert inlist(party,1,2,3) if party < .
assert inlist(men,0,1)
assert inlist(agegroup,1,2,3) if agegroup < .
assert inlist(emp,1,2,3,4,5,6)
assert inlist(occ,1,2,3,4)
assert inlist(edu,1,2,3) if edu < .
assert inlist(bul,1,2,3,4,5,6,7,8,9,10,11,12)
assert inlist(mar,1,2,3) if mar < .
assert inlist(hhinc,1,2,3,4) if hhinc < .
assert inlist(denom,1,2,3) if denom < .

// Save
// ----

compress
save btwsurvey, replace

exit


// Notes
// -----    

(1) Variable v385 was not labeled in Stata dataset. Codes were shown
    in the Codebook on
      http://www.za.uni-koeln.de/data/election-studies/btw/codebuch/s0525.pdf
    however. 


           

* Create Voter-Data

version 7.0
set more off

use $em/em, clear

* Select the target population
* -----------------------------

* Drop respondent without right to vote in last election 

drop if v10 == 3

* Drop respondents below 18

drop if v8 < 18

* Drop data from Sweden 1998 (no question on voter turnout)

drop if country==6 & year==1998

* Drop Data from Austria, Turkey and South Corea

drop if inlist(country,7,8,9)  /* -> Note 0 */


* Value Labels
* ------------

lab def yesno 0 "no" 1 "yes"
lab def sat 1 "dissatisfied" 11 "satisfied"


* Dependent Variables
* ------------------

gen byte voter:yesno = v10==1 if v10<=2
lab var voter "Voted on last election"

* CHECK: Why are so many missings in Spain?

* Standard Socio Demography
* --------------------------

* Country

lab var country "Country"

* Gender 

gen byte men:yesno = v7==1 if v7 < .
lab var men "Men"

* Age

drop age
ren v8 age
lab var age "Age"


* Social Position
* ---------------

* Edu  (-> Note 1)

gen byte edu:edu = 1 if v33 <= 1
replace edu = 2 if inrange(v33,2,7)
replace edu = 3 if inrange(v33,8,10)
lab var edu "Educational degree (ISCED 1997, recoded)"
lab def edu 1 "Primary and below" 2 "Secondary" 3 "Tertiary"

* Self assessed social class

gen byte class:class = v22 
replace class = 4 if v22 == 5
replace class = 5 if v22 >= .
lab var class "Self-assessed social class"
lab def class 1 "lower" 2 "working" 3 "middle" 4 "above middle"  /*
*/ 5 "missing"

* Houshold Income in Euro (-> Note 2)

ren v24 hhinc
replace hhinc = . if hhinc == 0
lab var hhinc "Household income (Euro)"

ren v24eq hhinceq
replace hhinceq = . if hhinceq == 0
lab var hhinceq "Equivalent household income (Euro)"

* Comparison of financial situation with 1 year ago

gen byte compinc:compinc = 1 if inlist(v26,1,2)
replace compinc = 2 if v26==3
replace compinc = 3 if inlist(v26,4,5)
replace compinc = 4 if v26 >= .
lab var compinc "Financial Situation compared with 1 year ago"
lab def compinc 1 "deteriorated" 2 "remained" 3 "improved" 4 "missing"

* Occupational Status

gen byte occ:v36 = v36
replace occ = v44 if occ == .
replace occ = 7 if v35 == 4 & v43 == 0 & occ >= . /* not + never employed */
replace occ = 8 if occ == .
lab var occ "(Last) Occupational status"
lab def v36 7 "not & never employed" 8 "missing", modify

* Integration
* -----------

* Houshold-Size

gen byte hhsize = v5
lab var hhsize "Household-size"

* Members of Organizations

gen byte union:yesno = v12a==1 if v12a < .
lab var union "Member of a trade union"

gen byte party:yesno = v12b==1 if v12b < .
lab var party "Member of a political party"

gen byte environ:yesno = v12d==1 if v12d < .
lab var environ "Member of an environmental association"

gen byte charity:yesno = v12e==1 if v12e < .
lab var charity "Member of an charity association"

gen byte church:yesno = v12f==1 if v12f < .
lab var church "Member of an church related  association"

gen byte sport:yesno = v12h==1 if v12h < .
lab var sport "Member of an sports club"

gen byte other:yesno = v12i==1 if v12i < .
lab var other "Member of Other "

* Close friend

gen byte friend:yesno = v13 == 1
lab var friend "Close friend"


* Urban/rural  (-> Note 3)

gen byte rural:yesno = inlist(v11_slo,5,6) if country == 1
replace rural = inlist(v11_d1,8,9) if country == 2
replace rural = inlist(v11_h,7,8,9) if country == 3
replace rural = inlist(v11_e,1) if country == 4
replace rural = inlist(v11_ch,6,7,8) if country == 5
replace rural = inlist(v11_s,40,60) if country == 6
lab var rural "Rural living area"


* Satisfaction/Hapiness (and friends)
* -----------------------------------

* Satisfaction with standard of living

gen byte satstand:sat = v23 + 1
lab var satstand "Satisfaction with standard of living"

* Satisfaction with income

gen byte satinc:sat = v28 + 1
lab var satinc "Satisfaction with income"

* Satisfaction with life in general

gen byte satlife:sat = v56 + 1
lab var satlife "Satisfaction with life in general"

* Perceived Happiness

gen byte happy:v57 = v57
lab var happy "Perceived happiness"

keep id country year voter men age edu class hhinc hhinceq compinc occ  /*
*/ hhsize union-other friend rural sat* happy weight*

order id country year weight1 weight2 voter men age edu class hhinc  /*
*/ hhinceq compinc occ hhsize union-other friend rural sat* happy

compress

save voter, replace

exit

Note 0
------

I dropped data for Austria because Austria has compulsary
voting. Moreover we have only very few respondends for Austria.

I dropped Turkey and South-Corea because of some very strange
data-patterns which I could not explain. Low income groups votes
extremely more often than high income groups in both countries. My
knowledge about both countries is way to small to get a grid for these
patterns. Therefore I decided to restrict the analysis on European
Countries.


Note 1
------

Education (v33) categorized as follows:

-----------------------------------------------------------
0 isced 0: pre-primary education
1 isced 1: primary education
-----------------------------------------------------------
2 isced 2: lower secondary education, general, vocational
3 isced 2a: lower secondary education, general
4 isced 3c: secondary edu., vocational
5 isced 3b: secondary edu., general, prep. for isced 5b
6 isced 3a: secondary edu., general, prep.for isced 5a
7 isced 4: post secondary, non tertiary education
------------------------------------------------------------
8 isced 5b: first stage of tertiary edu., technical
9 isced 5a: tertiary education, university
10 isced 5a/6: tertiary education, university/doctorate
------------------------------------------------------------ 

Note 2
------

Categorized incomes in v25 already build into monthly income of
household.


Note 3
------

Rural Areas are

Switzerland:
6 2000-4999 
7 1000-1999 
8 1-999 

Germany
8 2.000 - 4.999 
9 less than 2.000 

Spain
1  > 2000 
 
Hungary 
7 2001-5000
8 1001-2000
9 -1000 

Sweden
40 h4 other southern sweden
60 h6 other northern sweden 

Slovenia
5 village
6 rural area


// Description of sequences
// kohler@wzb.eu


version 10
clear
set memory 90m
set scheme s1mono
capture log close
log using anseqdes1, replace

use survey cntry idno visit result* using ESScontactbig, clear

// Clean Data
// ----------

// Harmonize contact results of ESS 1 and ESS 2
gen result:result = 9
replace result = 1 if result1 == 1 | inlist(result2,1,2)
replace result = 2 if result1 == 2 | result2== 4
replace result = 3 if result1 == 3 | inlist(result2,3,5)
replace result = 4 if result1 == 4 | result2 == 6
replace result = 9 if result1 == 9 | result2 == 9
lab define result 1 "Interview" 2 "Contact with resp"  ///
  3 "Contact with someone" 4 "No contact"
drop result1 result2


// We drop all sequences with no "result information"
bysort survey cntry idno (visit): gen x  = sum(result==9)
by survey cntry idno (visit): drop if x > 0

// Visit - Variable have gaps in several countries
// We drop these sequences
by survey cntry idno (visit): replace x = visit -1 != visit[_n-1] if _n > 1
by survey cntry idno (visit): replace x = sum(x)
by survey cntry idno (visit): replace x = x[_N]
drop if x
drop x

// Now sqset
gen str1 ctrcase = ""
replace ctrcase = survey + " " + cntry + " " + string(idno,"%12.0f")
sqset result ctrcase visit, ltrim

// Some numbers
// ------------

di as text "Number of contact attempts: " as result _N
sqtab, ranks(1/10)

egen sqlength = sqlength()
sqstattabsum survey

// Sequence index plot
// -------------------

// Definition of order variables
egen sqlength2= sqlength(), e(2) // <- Contact with R, no interview 
egen sqlength3= sqlength(), e(3) // <- Contact with someone else
egen sqlength4= sqlength(), e(4) // <- No contact at all
egen pos421 = sqfirstpos(), pattern(4 2 1)
egen pos431 = sqfirstpos(), pattern(4 3 1)
egen pos21 = sqfirstpos(), pattern(2 1)
egen pos31 = sqfirstpos(), pattern(3 1)
egen pos41 = sqfirstpos(), pattern(4 1)

// The plot
sqindexplot if cntry == "DE" & sqlength > 4  /// 
  , by(survey, legend(pos(6)) note("") yrescale) 				///
  order(sqlength pos421 pos21 pos431 pos31 pos41 sqlength4 sqlength3 sqlength2)			///
  color(gs2 gs6 gs10 gs14) 				 ///
  legend(rows(2)) ysize(10) 			///
  ylab(#10)
graph export anseqdes1_indexplot.eps, replace
drop sq* pos*


// Conclusions from Sequence index plot
// ------------------------------------

bysort survey cntry idno (visit): drop if _n==_N // <- Remove last contact attempt
by survey cntry idno (visit): keep if _N>4       // <- Length 5 and above

// Reset sequence data
sqset result ctrcase visit


// Prepare Resultsset
// ------------------

egen sqlengtho= sqlength()       // <- Overall
egen sqlength2= sqlength(), e(2) // <- Contact with R, no interview 
egen sqlength3= sqlength(), e(3) // <- Contact with someone else
egen sqlength4= sqlength(), e(4) // <- No contact at all

egen sqelemcount = sqelemcount()
egen sqepicount = sqepicount()

bysort ctrcase (visit): gen pos2not2 = 1 if inlist(result,2,3) & result[_n-1]==2
by ctrcase (visit): replace pos2not2 = sum(pos2not2)
by ctrcase (visit): replace pos2not2 = pos2not2[_N]

bysort ctrcase (visit): gen pos24 = 1 if result==4 & result[_n-1]==2
by ctrcase (visit): replace pos24 = sum(pos24)
by ctrcase (visit): replace pos24 = pos24[_N]

foreach var of varlist sqlength4 sqepicount sqelemcount pos* {
	gen p`var' = `var'/sqlengtho
}

by ctrcase, sort: keep if _n==1
collapse (mean) sq* pos* ppos* psq* , by(survey cntry) 
encode survey, gen(svynum)
drop survey
reshape wide 							/// 
  sqlengtho sqlength2 sqlength3 sqlength4  	/// 
  pos2not2 pos24  	///
  sqelemcount sqepicount 					///
  psqlength4 psqepicount psqelemcount 			///
  ppos2not2 ppos24  	///
  , i(cntry) j(svynum)


// Length Chart
// -------------
// (I made two; which should we choose)

gen meanlength = (sqlengtho1 + sqlengtho2)/2
egen axis = axis(meanlength cntry), reverse label(cntry)
levelsof axis, local(K)
graph twoway ///
  || pcarrow axis psqlength41 axis psqlength42, xaxis(2) lcolor(black) mlcolor(black) /// 
  || scatter axis psqlength41, xaxis(2) ms(O) mlcolor(black) mfcolor(white)  ///
  || pcarrow axis sqlengtho1 axis sqlengtho2, xaxis(1) lcolor(black) mlcolor(black) /// 
  || scatter axis sqlengtho1, xaxis(1) ms(O) mcolor(black)  ///
  || , ylab(`K', valuelabel angle(0)) ytitle("")  ///
  xtitle("# of contact attempts", axis(1)) 	/// 
  xtitle(`"Prop. of "no contacts""', axis(2)) 	/// 
  legend(pos(2) col(1) 					 /// 
  order( 								///
  4 "Contact attempts, ESS 1"  /// 
  2 `"Prop. of "no contact" ESS 1"' ///  
  1 "Change ESS1 to ESS 2"))


gen mlabpos = 12 if cntry == "AT"
replace mlabpos =  9 if cntry == "BE"  
replace mlabpos = 12 if cntry == "CH"  
replace mlabpos = 12 if cntry == "CZ"  
replace mlabpos =  1 if cntry == "DE"  
replace mlabpos =  9 if cntry == "DK"  
replace mlabpos = 12 if cntry == "ES"  
replace mlabpos =  9 if cntry == "FI"  
replace mlabpos =  3 if cntry == "GB"  
replace mlabpos =  9 if cntry == "GR"  
replace mlabpos =  9 if cntry == "HU"  
replace mlabpos = 12 if cntry == "IE"  
replace mlabpos =  1 if cntry == "IT"  
replace mlabpos =  9 if cntry == "LU"  
replace mlabpos =  9 if cntry == "NL"  
replace mlabpos = 12 if cntry == "PL"  
replace mlabpos =  8 if cntry == "PT"  

graph twoway ///
  || pcarrow psqlength41 sqlengtho1 psqlength42 sqlengtho2 	///
  , lcolor(black) mlcolor(black) /// 
  || scatter psqlength41 sqlengtho1, ms(O) mlcolor(black) mfcolor(white)  /// 
  mlab(cntry) mlabvpos(mlabpos)  ///
  || , ytitle(`"Prop. of "no contacts""')  ///
  xtitle("# of contact attempts") xscale(range(4.7 8))	     /// 
  legend(pos(6) row(1) 					 /// 
  order(2 "ESS 1" 1 "ESS 2")) 			///
  aspectratio(1)
graph export anseqdes1_length.eps, replace

// Some numbers to mention
sum sqlengtho? psqlength4?
corr sqlengtho? psqlength4?

  
// Epinum Chart
// -------------

replace mlabpos =  9 if cntry == "AT"
replace mlabpos =  9 if cntry == "BE"  
replace mlabpos =  7 if cntry == "CH"  
replace mlabpos = 12 if cntry == "CZ"  
replace mlabpos =  6 if cntry == "DE"  
replace mlabpos = 12 if cntry == "DK"  
replace mlabpos =  6 if cntry == "ES"  
replace mlabpos =  3 if cntry == "FI"  
replace mlabpos =  3 if cntry == "GB"  
replace mlabpos =  1 if cntry == "GR"  
replace mlabpos =  7 if cntry == "HU"  
replace mlabpos =  6 if cntry == "IE"  
replace mlabpos =  7 if cntry == "IT"  
replace mlabpos =  4 if cntry == "LU"  
replace mlabpos =  3 if cntry == "NL"  
replace mlabpos = 12 if cntry == "PL"  
replace mlabpos =  2 if cntry == "PT"  

graph twoway ///
  || pcarrow psqelemcount1 psqepicount1 psqelemcount2 psqepicount2 	///
  , lcolor(black) mlcolor(black) /// 
  || scatter psqelemcount1 psqepicount1  ///
  , ms(O) mlcolor(black) mfcolor(white) 	///  
  mlab(cntry) mlabvpos(mlabpos) ///
  || , aspectratio(1) ytitle("Contact outcomes per contact attempt")  ///
  xtitle("Episodes per contact attempt") ///
  legend(pos(6) rows(1) 					 /// 
  order(2 "ESS 1" 1 "Change ESS1 to ESS 2"))  

graph export anseqdes1_episodes.eps, replace


// Some numbers to mention
sum psqelemcount? psqepicount?
corr psqelemcount? psqepicount?


// Itealised sub-sequences chart
// -----------------------------

replace mlabpos = 12 if cntry == "AT"
replace mlabpos =  6 if cntry == "BE"  
replace mlabpos = 12 if cntry == "CH"  
replace mlabpos =  9 if cntry == "CZ"  
replace mlabpos = 12 if cntry == "DE"  
replace mlabpos =  7 if cntry == "DK"  
replace mlabpos =  6 if cntry == "ES"  
replace mlabpos = 12 if cntry == "FI"  
replace mlabpos = 12 if cntry == "GB"  
replace mlabpos =  3 if cntry == "GR"  
replace mlabpos =  9 if cntry == "HU"  
replace mlabpos =  6 if cntry == "IE"  
replace mlabpos =  9 if cntry == "IT"  
replace mlabpos =  4 if cntry == "LU"  
replace mlabpos =  6 if cntry == "NL"  
replace mlabpos =  9 if cntry == "PL"  
replace mlabpos =  6 if cntry == "PT"  

graph twoway ///
  || pcarrow ppos2not21 ppos241 ppos2not22 ppos242 ///
  , lcolor(black) mlcolor(black) /// 
  || scatter  ppos2not21 ppos241  ///
  , ms(O) mlcolor(black) mfcolor(white) 	///  
  mlab(cntry) mlabvpos(mlabpos) ///
  || , aspectratio(1) ytitle("Contact with sampled unit -> Contact, no int.")  ///
  xtitle("Contact with sampled unit -> No contact at all") ///
  legend(pos(6) rows(1) 					 /// 
  order(2 "ESS 1" 1 "Change ESS1 to ESS 2"))  

graph export anseqdes1_ideal.eps, replace


// Some numbers to mention
sum psqelemcount? psqepicount?
corr psqelemcount? psqepicount?


exit


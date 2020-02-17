* Well-Being (Life-Satisfaction/Happiness) by HDI
* EQLS 2003 and ISSP 2002

version 9
set more off
capture log close
log using anwbequation, replace

// Intro
// -----

capture program drop mydummies
program mydummies
version 9
	syntax varlist
	foreach var of local varlist {
		quietly levelsof `var', local(K)
		foreach k of local K {
			gen `var'`k':yesno = `var'==`k' if !mi(`var')
			label var `var'`k' "`:label (`var') `k''"
		}
	}
end

// EQLS 2003
// ---------

use ///
  s_cntry hhincqu2 hh1 hh2a hh2b q17 q19* q23b q26 q31 q32 q34c  ///
  q37c q41f q44 q52 emplstat persstat teacat region wcountry ///
  using $dublin/eqls_4, clear

// Live-Satisfaction
// ----------------
ren q31 lsat

// Vertical Inequalities
// ----------------------

ren hhincqu2 inc
label define hhincqu2 1 "1st quartile" 2 "2nd quartile" 3 "3rd quartile"  4 "4th quartile", modify
	
// Employment-Status
gen emp:emp = emplstat
replace emp = 5 if emplstat >= 5  | teacat == 4  // "Missing" + "Other" + "Still Studying"
label def emp 1 "Employed" 2 "Homemaker" 3 "Unemployed" 4 "Retired" 5 "Still in education/other"
	
// Education
gen edu:edu = teacat
replace edu = 4 if edu >= . // "Missing" + "Still Studying" = "Other"
label define edu 1 "Low" 2 "Intermediate" 3 "High" 4 "Other"

// "Class" of Main-Earner 
gen class:class = persstat
replace class = 7 if class >= .
label define class 1 "Upper white collar" 2 "Lower white collar" 3 "Self employed" 4 "Skilled Worker" ///
  5 "Non skilled worker" 6 "Farmer" 7 "Other"

// Housing
replace q17 = . if q17 == 75  // 1 obs. with 75 rooms seems to be a Data-Error
gen roomspers = q17/hh1
label var roomspers "Rooms per person"
drop q17 hh1

gen hqual = (q19_2==1) + (q19_3==1) + (q19_4==1) if !mi(q19_2,q19_3,q19_4)
label variable hqual "Accomodation problems"
drop q19*
	
// Health/Personality
gen illness:yesno = q44==1 if !mi(q44)
lab var illness "Long term illness"
drop q44
ren q41f health
lab var health "Health satisfaction"

	
// Horizontal Inequalities
// ------------------------

// Gender
gen men:yesno = hh2a==1 if hh2a < .
lab var men "Men"
drop hh2a
	
// Age
sum hh2b, meanonly
gen age = hh2b-r(mean)
lab var age "Age"
gen age2 = age^2
lab var age2 "Age (squared)"
drop hh2b


// Sociability: Work for Voluntary Organization 
gen vol:yesno = q23b==1 if q23b < .
label var vol "Yes"
drop q23b

// Sociability: Marital-Status
ren q32 mar
label def q32 1 "Married/living together" 2 "Separated/divorced" 3 "Widowed" 4 "Single, never married", modify

// Sociability: Contact with friends/neigbours at least once a weak
gen contacts:yesno = q34c <= 3 if !mi(q34c)
lab var contacts "Yes"
drop q34c

// Urban/Rural
gen urban:yesno = region == 1 if region < .
lab var urban "Urban"
drop region

// Life-Style: Religiousity 
sum q26, meanonly
gen rel = r(max)+1-q26
lab var rel "Church attendance"
drop q26

// Life-Style: Internet-User
gen internet:yesno = q52 <= 3 if !mi(q52)
lab var internet "Yes"
drop q52
	

// Dummies

mydummies inc emp  edu class mar

// Listwise Deletion
// ----------------

mark touse
markout touse ///
  lsat inc2-inc4 emp2-emp5 edu2-edu4 class2-class7 men age age2 ///
  roomsper hqual mar2-mar4 contacts vol rel internet illness health urban
keep if touse
	

// Models
// ------

iis s_cntry
	
// Basline Model
xtreg lsat, fe
estimates store base
	
// Bivariate Correlations
local i 1
foreach indep in ///
  "men" "age age2" "urban" ///  
  "inc2-inc4" "emp2-emp5" "class2-class7" "edu2-edu4"   ///
  "roomsper" "hqual" ///
  "mar2-mar4" "contacts" "vol" ///
  "rel" "internet"             ///
  "illness" "health"   {
	xtreg lsat `indep' ///
	  , fe
	estimates store m`i'
	local bimods "`bimods' m`i++'"
}
estout `bimods'  ///
  using anwbequation.tex ///
  , replace style(tex) delimiter(" ") drop(_cons) ///
  cells(b(fmt(%3.2f) star)) ///
  starlevels(* 0.05) 
estimates drop _all

// Demography
xtreg lsat ///
  men age age2 urban
estimates store demog

// Old-Inequalities
xtreg lsat ///
  men age age2 urban ///
  inc2-inc4 emp2-emp5 class2-class7 edu2-edu4 ///
  , fe
estimates store ineq

// Housing
xtreg lsat ///
  men age age2 urban  ///
  inc2-inc4 emp2-emp5 class2-class7 edu2-edu4 ///
  roomspers hqual ///
  , fe
estimates store house

// Sociability
xtreg lsat  ///
  men age age2 urban ///
  inc2-inc4 emp2-emp5 class2-class7 edu2-edu4 ///
  roomspers  hqual ///            
  mar2-mar4 contacts vol ///
  , fe
estimates store sociab

// Life-Style
xtreg lsat   ///
  men age age2 urban ///
  inc2-inc4 emp2-emp5 class2-class7 edu2-edu4 ///
  roomspers  hqual ///            
  mar2-mar4 contacts vol  ///
  rel internet ///
  , fe
estimates store lstyle

// Health/Personality
xtreg lsat   ///
  men age age2 urban ///
  inc2-inc4 emp2-emp5 class2-class7 edu2-edu4 ///
  roomspers hqual  ///            
  mar2-mar4 contacts vol  ///
  rel internet             ///
  illness health  ///
  , fe
estimates store health

estout  demog ineq house sociab lstyle health ///
  using anwbequation.tex ///
  , append style(tex) label varwidth(35) ///
  prehead(\begin{tabular}{lrrrrrrr} \hline )  ///
  posthead(\hline) ///
  prefoot(\hline) postfoot(\hline \end{tabular} ) ///
  cells(b(fmt(%3.2f) star)) ///
  varlabels(_cons Constant, ///
  blist( ///
  men "\multicolumn{9}{l}{\emph{Gender (reference: women) }} \\ " ///
  age "\multicolumn{9}{l}{\emph{Age (metric, in years)}} \\ "              ///
  urban "\multicolumn{9}{l}{\emph{Type of community (reference: rural) }} \\ "              ///
  inc2   "\multicolumn{9}{l}{\emph{Income (reference: 1st within country quartile) }} \\ " ///
  emp2   "\multicolumn{9}{l}{\emph{Employment status (reference: employed) }} \\ " ///
  class2 "\multicolumn{9}{l}{\emph{Class (reference: upper white collar) }} \\ " ///
  edu2 "\multicolumn{9}{l}{\emph{Education (reference: low) }}  \\" ///
  roomspers "\multicolumn{9}{l}{\emph{Housing}} \\ " ///
  vol "\multicolumn{9}{l}{\emph{Voluntary work (refence: no)}} \\ " ///
  mar2   "\multicolumn{9}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
  vol "\multicolumn{9}{l}{\emph{Work for voluntary organisations (refence: no)}} \\ " ///
  contacts "\multicolumn{9}{l}{\emph{Contacts with friends/neighbours (reference: no)}} \\ " ///
  rel "\multicolumn{9}{l}{\emph{Church attendence (metric, 7 point scale)}} \\ " ///
  internet "\multicolumn{9}{l}{\emph{Internet user (reference: no)}} \\ " ///
  illness "\multicolumn{9}{l}{\emph{Long term illness (reference: no)}} \\ " ///
  health  "\multicolumn{9}{l}{Health satisfaction (metric, 11 point scale)}} \\ " ///
  )) ///
  stats(rho r2 N, labels("\$\rho\$" "\$r^2\$" "\$n\$") fmt(%9.2f %9.2f %9.0f)) ///
  starlevels(* 0.05) 
estimates drop _all

log close
exit
	

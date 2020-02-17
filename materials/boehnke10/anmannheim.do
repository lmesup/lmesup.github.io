* Analyses for MZES AB-A presentation, 18.Nov.2008
* kohler@wzb.eu

// Intro
// -----

version 10
set more off
set scheme s1mono
capture log close
log using anmannheim, replace

// Making dummies with nice Labels
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

// Relabel, if labels get lost
capture program drop relabel
program relabel
	capture lab var health "Health satisfaction"
	capture lab var illness "Illness"
	capture lab var rel "Church attendance"
	capture lab var contacts "Contact with friends y/n"
	capture label var vol "Voluntary organis."
	capture label variable hqual "Accomodation problems"
	capture label var roomspers "Rooms per person"
	capture lab var urban "Urban"
	capture lab var age "Age"
	capture lab var men "Men"
	capture lab var emp "Employment"
	capture lab var emp1 "Emplyoment"
	capture lab var edu "Education"
	capture lab var edu3 "High education"
	capture lab var class "Social class"
	capture lab var class1 "Upper white collar"
	capture lab var class2 "Lower white collar"
	capture lab var class3 "Self employed"
	capture lab var class4 "Worker"
	capture lab var class6 "Farmer"
	capture lab var inc "Income"
	capture lab var mar "Marital Status"
end


// EQLS 2003
// =========

use ///
  s_cntry hhincqu2 hh1 hh2a hh2b q17 q19* q23b q26 q31 q32 q34c ///
  q37c q41f q44 q52 emplstat persstat teacat region gdppcap2 ///
  using $dublin/eqls_4, clear


// Country
// -------

label define s_cntry 11 "United Kingdom", modify
egen iso3166 = iso3166(s_cntry)

gen eu = 1 if ///
  inlist(iso3166,"AT","BE","DE","DK","ES","FI","FR") /// 
  | inlist(iso3166,"GB","GR","IE","IT","LU","NL","PT","SE")
replace eu = 2 if inlist(iso3166,"TR","CY","MT")
replace eu= 3 if ///
  inlist(iso3166,"BG","RO","CZ","EE","HU","LT","LV") /// 
  | inlist(iso3166,"PL","SI","SK")


// Live-Satisfaction
// ----------------
ren q31 lsat


// Askriptive Merkmale 
// -------------------

// Gender
gen men:yesno = hh2a==1 if hh2a < .
drop hh2a
	
// Age
ren hh2b age 


// SES
// ---

// Haushaltseinkommen
ren hhincqu2 inc
label define hhincqu2 1 "1st quartile" 2 "2nd quartile" /// 
  3 "3rd quartile"  4 "4th quartile", modify
	
// Employment-Status
gen emp:emp = emplstat
replace emp = 5 if emplstat == 6  | (mi(emplstat) & teacat == 4) 
label def emp 1 "Employed" 2 "Homemaker" 3 "Unemployed" /// 
  4 "Retired" 5 "Other"
	
// Education
gen edu:edu = teacat
label define edu 1 "Low" 2 "Intermediate" 3 "High" 4 "Other"

// "Class" of Main-Earner 
gen class:class = persstat
replace class = 7 if class >= .
label define class /// 
  1 "Upper white collar" 2 "Lower white collar" 3 "Self employed" /// 
  4 "Skilled Worker" 5 "Non skilled worker" 6 "Farmer" 7 "Other"


// Wohnbedingungen
// ---------------

// Urban/Rural
gen urban:yesno = region == 1 if region < .
drop region

// Housing
replace q17 = . if q17 == 75  // 1 obs. with 75 rooms seems to be a Data-Error
gen roomspers = q17/hh1
drop q17 hh1

// Accomodation problems
gen hqual = (q19_2==1) + (q19_3==1) + (q19_4==1) if !mi(q19_2,q19_3,q19_4)
drop q19*


// Soziale Beziehungen
// -------------------

// Sociability: Work for Voluntary Organization 
gen vol:yesno = q23b==1 if q23b < .
drop q23b

// Sociability: Marital-Status
ren q32 mar
label def q32 1 "Married/living together" 2 "Separated/divorced" /// 
3 "Widowed" 4 "Single, never married", modify

// Sociability: Contact with friends/neigbours at least once a weak
gen contacts:yesno = q34c <= 3 if !mi(q34c)
drop q34c

// Sociabilty: Church attendence
sum q26, meanonly
gen rel = r(max)+1-q26
drop q26

// Gesundheit
// ----------

gen illness:yesno = q44==1 if !mi(q44)
drop q44
ren q41f health

// Dummies
mydummies inc emp  edu class mar

// Figures
// -------

preserve
collapse (mean) eu /// 
  men age /// 
  emp1 edu3 class? /// 
  urban roomspers hqual /// 
  vol mar? contacts rel /// 
  illness health ///
  , by(iso3166)

replace class1 = class1+class2
replace class4 = class4+class5

relabel

foreach var of varlist men age emp1 edu3 urban hqual roomspers ///
  vol contacts rel health illness {
	egen axis`var' = axis(eu `var'), label(iso3166) gap reverse
	egen mean`var' = mean(`var'), by(eu)
	
	graph twoway ///
	  || sc axis`var' `var', ms(O) mcolor(black) ///
	  || li axis`var' mean`var' if eu == 1, lcolor(black) ///
	  || li axis`var' mean`var' if eu == 2, lcolor(black) ///
	  || li axis`var' mean`var' if eu == 3, lcolor(black) ///
	  || , ylab(1(1)10 12(1)14 16(1)30, valuelabel angle(0) grid gstyle(dot)) ///
      ytitle("") ///
      title("`:variable label `var''", box bexpand) ///
      xtitle("") legend(off) ///
	  ysize(5.5) xsize(4)

	graph export anmannheim_`var'.eps, replace
}

egen axisclass = axis(eu class1), label(iso3166) gap reverse
graph twoway ///
  || scatter axisclass class1, ms(O) mlcolor(black) mfcolor(white) ///
  || scatter axisclass class3, ms(O) mlcolor(black) mfcolor(gs6) ///
  || scatter axisclass class4, ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axisclass class6, ms(O) mlcolor(black) mfcolor(gs12) ///
  || , ylabel(1(1)10 12(1)14 16(1)30, valuelabel angle(0) grid gstyle(dot)) ///
  ytitle("") ///
  title("Social class", box bexpand) ///
  xtitle("") 							/// 
  legend(order(4 "Farmer" 2 "Self-employed" 3 "Worker" 1 "White collar") /// 
  pos(6) col(4) size(small)) ///
  ysize(6) xsize(4)
graph export anmannheim_class.eps, replace

egen axismar = axis(eu mar1), label(iso3166) gap reverse
graph twoway ///
  || scatter axismar mar1, ms(O) mlcolor(black) mfcolor(white) ///
  || scatter axismar mar2, ms(O) mlcolor(black) mfcolor(gs6) ///
  || scatter axismar mar3, ms(O) mlcolor(black) mfcolor(black) ///
  || scatter axismar mar4, ms(O) mlcolor(black) mfcolor(gs12) ///
  || , ylabel(1(1)10 12(1)14 16(1)30, valuelabel angle(0) grid gstyle(dot)) ///
  ytitle("") ///
  title("Marital status", box bexpand) ///
  xtitle("") legend(order(2 "Divorced" 3 "Single" 4 "Widowed" 1 "Married") /// 
  pos(6) col(4) size(small)) ///
  ysize(6) xsize(4)
graph export anmannheim_mar.eps, replace

restore

// General Settings
// ----------------

relabel

mark touse
markout touse ///
  lsat inc2-inc4 emp2-emp5 edu2-edu4 class2-class7 men age ///
  roomsper hqual mar2-mar4 contacts vol rel illness health urban
keep if touse

iis s_cntry

foreach var of varlist age health roomspers hqual rel {
	sum `var', meanonly
	replace `var' = `var' - r(mean)
	lab var `var' "`:var lab `var'' (centered)"
}	

gen age2 = age^2
lab var age2 "Age (squared)"

local m1 men age age2 urban
local m2 `m1' illness edu2-edu4 
local m3 `m2' emp2-emp5 class2-class7 
local m4 `m3' inc2-inc4
local m5 `m4' roomspers hqual mar2-mar4 contacts vol rel


// Step 1 Models
// -------------

eststo clear

eststo: xtreg lsat `m1', fe
eststo: xtreg lsat `m2', fe
eststo: xtreg lsat `m3', fe
eststo: xtreg lsat `m4', fe
eststo: xtreg lsat `m5', fe

esttab using anmannheim_step1.tex, replace ///
  tex label nomtitles nodepvars b(%3.2f) not ///
  varlabels(_cons Constant, ///
  blist( ///
  men "\multicolumn{6}{l}{\emph{`:var lab men' (Ref.: women)}} \\" ///
  urban "\multicolumn{6}{l}{\emph{`:var lab urban' (Ref.: rural)}} \\" ///
  inc2 "\multicolumn{6}{l}{\emph{`:var lab inc' (Ref.: 1st quartile)}} \\" ///
  emp2 "\multicolumn{6}{l}{\emph{`:var lab emp' (Ref.: employed)}} \\" ///
  class2 "\multicolumn{6}{l}{\emph{`:var lab class' (Ref.: upper white collar)}} \\" ///
  edu2 "\multicolumn{6}{l}{\emph{`:var lab edu' (Ref.: low)}} \\" ///
  vol "\multicolumn{6}{l}{\emph{`:var lab vol' (Ref.: no)}} \\" ///
  mar2 "\multicolumn{6}{l}{\emph{`:var lab mar' (Ref.: married)}} \\" ///
  contacts "\multicolumn{6}{l}{\emph{`:var lab contacts' (Ref.: no)}} \\" ///
  illness "\multicolumn{6}{l}{\emph{`:var lab illness'(Ref.: no)}} \\" ///
  )) ///
  stats(rho r2 N, /// 
  labels("\$\rho\$ (Var. exp. by country)" "\$r^2\$ (within)" "\$n\$") /// 
  fmt(%4.3f %4.3f %5.0f)) ///
  starlevels(* 0.05) 


// Step 2
// ------

// The Models
forv i = 1/5 {
	statsby _b _se, by(iso3166) saving(anmannheim_step2_m`i', replace): ///
	  reg lsat  `m`i''
}

// Graphs from Model 1
sum age, meanonly
local minage = r(min)
local maxage = r(max)

preserve

by iso3166, sort: keep if _n==1
merge iso3166 using anmannheim_step2_m1, sort

// Gender and Urban
gen ub = .
gen lb = .
foreach var of varlist men urban {
	replace ub = _b_`var' + 1.96 * _se_`var'
	replace lb = _b_`var' - 1.96 * _se_`var'

	graph twoway /// 
	  || lowess _b_`var' gdppcap, lcolor(black) ///
	  || rspike ub lb gdppcap /// 
	  || sc _b_`var' gdppcap if eu==1, ms(O) mlcolor(black) mfcolor(black) ///
	  || sc _b_`var' gdppcap if eu==2, ms(O) mlcolor(black) mfcolor(gs8) ///
	  || sc _b_`var' gdppcap if eu==3, ms(O) mlcolor(black) mfcolor(white) ///
	  || sc _b_`var' gdppcap, ms(i) mlab(iso3166) ///
	  || if iso3166 != "LU" ///
	  , legend(order(5 "FC" 4 "OMS" 3 "Other") rows(1)) /// 
	  xtitle(GDP (per capita)) ///
	  ti(`"`=substr(`"`:var lab `var''"',1,16)'"', bexpand box) ///
	  ytitle(Est. coefficient) yline(0, lcolor(red)) ///
	  name(step2_`var', replace) nodraw
}

// Age (special!)
gen extage = -_b_age/(2*_b_age2)
replace extage = `minage' if extage < `minage'
replace extage = `maxage' if extage > `maxage'
gen extreme1 = _b_age * extage + _b_age2 * extage^2
gen extreme2 = _b_age * `minage' + _b_age2 * `minage'^2
gen extreme3 = _b_age * `maxage' + _b_age2 * `maxage'^2
gen ageeff = /// 
  cond(abs(extreme1 - extreme2)>abs(extreme1 - extreme3)  ///
  ,extreme1 - extreme2 					///
  ,extreme1 - extreme3)

graph twoway /// 
  || lowess ageeff gdppcap ///
  || sc ageeff gdppcap if eu==1, ms(O) mlcolor(black) mfcolor(black) ///
  || sc ageeff gdppcap if eu==2, ms(O) mlcolor(black) mfcolor(gs8) ///
  || sc ageeff gdppcap if eu==3, ms(O) mlcolor(black) mfcolor(white) ///
  || sc ageeff gdppcap, ms(i) mlab(iso3166) ///
  || if iso3166 != "LU" ///
  , legend(order(4 "FC" 2 "OMS" 3 "Other") rows(1)) xtitle(GDP (per capita)) ///
  title(Age, bexpand box) ytitle(f(Est. Coefficients)) yline(0, lcolor(red))  ///
  name(step2_age, replace) nodraw

// Graphs from Model 2
restore, preserve
by iso3166, sort: keep if _n==1
merge iso3166 using anmannheim_step2_m2, sort

gen ub = .
gen lb = .
foreach var of varlist edu2 edu3 illness {
	replace ub = _b_`var' + 1.96 * _se_`var'
	replace lb = _b_`var' - 1.96 * _se_`var'

	graph twoway /// 
	  || lowess _b_`var' gdppcap, lcolor(black) ///
	  || rspike ub lb gdppcap /// 
	  || sc _b_`var' gdppcap if eu==1, ms(O) mlcolor(black) mfcolor(black) ///
	  || sc _b_`var' gdppcap if eu==2, ms(O) mlcolor(black) mfcolor(gs8) ///
	  || sc _b_`var' gdppcap if eu==3, ms(O) mlcolor(black) mfcolor(white) ///
	  || sc _b_`var' gdppcap, ms(i) mlab(iso3166) ///
	  || if iso3166 != "LU" ///
	  , legend(order(5 "FC" 4 "OMS" 3 "Other") rows(1)) /// 
	  xtitle(GDP (per capita)) ///
	  ti(`"`=substr(`"`:var lab `var''"',1,16)'"', bexpand box) ///
	  ytitle(Est. coefficient) yline(0, lcolor(red)) ///
	  name(step2_`var', replace) nodraw
}

// Graphs from Model 3
restore , preserve
by iso3166, sort: keep if _n==1
merge iso3166 using anmannheim_step2_m3, sort

gen ub = .
gen lb = .
foreach var of varlist emp3 emp4 class4 class5 {
	replace ub = _b_`var' + 1.96 * _se_`var'
	replace lb = _b_`var' - 1.96 * _se_`var'

	graph twoway /// 
	  || lowess _b_`var' gdppcap, lcolor(black) ///
	  || rspike ub lb gdppcap /// 
	  || sc _b_`var' gdppcap if eu==1, ms(O) mlcolor(black) mfcolor(black) ///
	  || sc _b_`var' gdppcap if eu==2, ms(O) mlcolor(black) mfcolor(gs8) ///
	  || sc _b_`var' gdppcap if eu==3, ms(O) mlcolor(black) mfcolor(white) ///
	  || sc _b_`var' gdppcap, ms(i) mlab(iso3166) ///
	  || if iso3166 != "LU" ///
	  , legend(order(5 "FC" 4 "OMS" 3 "Other") rows(1)) /// 
	  xtitle(GDP (per capita)) ///
	  ti(`"`=substr(`"`:var lab `var''"',1,16)'"', bexpand box) ///
	  ytitle(Est. coefficient) yline(0, lcolor(red)) ///
	  name(step2_`var', replace) nodraw
}

// Graphs from Model 4
restore , preserve
by iso3166, sort: keep if _n==1
merge iso3166 using anmannheim_step2_m4, sort

gen ub = .
gen lb = .
foreach var of varlist inc2 inc4 {
	replace ub = _b_`var' + 1.96 * _se_`var'
	replace lb = _b_`var' - 1.96 * _se_`var'

	graph twoway /// 
	  || lowess _b_`var' gdppcap, lcolor(black) ///
	  || rspike ub lb gdppcap /// 
	  || sc _b_`var' gdppcap if eu==1, ms(O) mlcolor(black) mfcolor(black) ///
	  || sc _b_`var' gdppcap if eu==2, ms(O) mlcolor(black) mfcolor(gs8) ///
	  || sc _b_`var' gdppcap if eu==3, ms(O) mlcolor(black) mfcolor(white) ///
	  || sc _b_`var' gdppcap, ms(i) mlab(iso3166) ///
	  || if iso3166 != "LU" ///
	  , legend(order(5 "FC" 4 "OMS" 3 "Other") rows(1)) /// 
	  xtitle(GDP (per capita)) ///
	  ti(`"`=substr(`"`:var lab `var''"',1,16)'"', bexpand box) ///
	  ytitle(Est. coefficient) yline(0, lcolor(red)) ///
	  name(step2_`var', replace) nodraw
}

// Graphs from Model 5
restore, preserve
by iso3166, sort: keep if _n==1
merge iso3166 using anmannheim_step2_m5, sort

gen ub = .
gen lb = .
foreach var of varlist 					/// 
  roomspers hqual mar2 mar4 vol contacts rel {
	replace ub = _b_`var' + 1.96 * _se_`var'
	replace lb = _b_`var' - 1.96 * _se_`var'

	graph twoway /// 
	  || lowess _b_`var' gdppcap, lcolor(black) ///
	  || rspike ub lb gdppcap /// 
	  || sc _b_`var' gdppcap if eu==1, ms(O) mlcolor(black) mfcolor(black) ///
	  || sc _b_`var' gdppcap if eu==2, ms(O) mlcolor(black) mfcolor(gs8) ///
	  || sc _b_`var' gdppcap if eu==3, ms(O) mlcolor(black) mfcolor(white) ///
	  || sc _b_`var' gdppcap, ms(i) mlab(iso3166) ///
	  || if iso3166 != "LU" ///
	  , legend(order(5 "FC" 4 "OMS" 3 "Other") rows(1)) /// 
	  xtitle(GDP (per capita)) ///
	  ti(`"`=substr(`"`:var lab `var''"',1,16)'"', bexpand box) ///
	  ytitle(Est. coefficient) yline(0, lcolor(red)) ///
	  name(step2_`var', replace) nodraw
}

// Produce the figures
grc1leg step2_men step2_age, rows(1)
graph export anmannheim_step2_askriptiv.eps, replace

graph display step2_illness
graph export anmannheim_step2_illness.eps, replace

grc1leg step2_edu2 step2_edu3, rows(1) ycommon
graph export anmannheim_step2_edu.eps, replace

grc1leg step2_emp3 step2_emp4, rows(1) ycommon
graph export anmannheim_step2_emp.eps, replace

grc1leg step2_class4 step2_class5, rows(1) ycommon
graph export anmannheim_step2_class.eps, replace

grc1leg step2_inc2 step2_inc4, rows(1) ycommon
graph export anmannheim_step2_inc.eps, replace

grc1leg step2_urban step2_roomspers step2_hqual, rows(1) ycommon
graph export anmannheim_step2_housing.eps, replace

grc1leg step2_mar2 step2_mar4, rows(1) ycommon
graph export anmannheim_step2_mar.eps, replace

grc1leg step2_vol step2_contacts step2_rel, rows(1)
graph export anmannheim_step2_sozbez.eps, replace


// Step 3
// ------

restore
sum gdppcap, meanonly
replace gdppcap=gdppcap-r(mean)

foreach var of varlist 					/// 
  men age age2 urban 					/// 
  illness edu2 edu3 edu4							/// 
  emp2 emp3 emp4 emp5 class2 class3 class4 class5 class6 class7  ///
  inc2 inc3 inc4 						///
  roomspers hqual mar2 mar3 mar4 contact vol rel {
	gen gdp`var' = gdppcap*`var'
	lab var gdp`var' `"GDP $ {\times} $ `:var lab `var''"'
}


eststo clear

eststo: xtreg lsat `m1' gdpmen gdpage gdpage2 gdpurban, fe
eststo: xtreg lsat `m2' gdpillness gdpedu?, fe
eststo: xtreg lsat `m3' gdpemp? gdpclass?, fe
eststo: xtreg lsat `m4' gdpinc?, fe
eststo: xtreg lsat `m5' gdproomspers gdphqual gdpmar? gdpcontact gdpvol gdprel, fe

esttab using anmannheim_step3.tex, replace ///
  tex label nomtitles nodepvars b(%3.2f) t(%3.1f) ///
  varlabels(_cons Constant) ///
  stats(rho r2 N, /// 
  labels("\$\rho\$ (Var. exp. by country)" "\$r^2\$ (within)" "\$n\$") /// 
  fmt(%3.2f %3.2f %5.0f))  starlevels(* 0.05)



// Replication, Replication
// ========================

use $ess/ess2004.dta, clear

tostring idno, gen(persid)

gen iso3166=cntry					
label variable iso3166 "ISO 3166 Country Codes"

gen age = inwyr-yrbrn
gen age2 = age^2

gen men:dummy = gndr == 1 if gndr <= 2
lab var men "Man y/n"

gen edu:edu = 1 if inlist(edulvla,0,1,2)				
replace edu = 2 if inlist(edulvla,3,4)
replace edu = 3 if inlist(edulvla,5,6)
lab var edu "Education"
lab def edu 1 "Primary and below" 2 "Secondary" 3 "University"
		
gen mar:mar = 1 if marital==1
replace mar = 2 if marital==4
replace mar = 3 if inlist(marital,2,3)
replace mar = 4 if marital==5
label value mar mar
label define mar ///
  1 "Married, or living together as married" ///
  2 "Widowed" ///
  3 "Divorced Or Separated" ///
  4 "Single, Never Married"

gen emp:emp = .
replace emp = 1 if mnactic == 1
replace emp = 2 if mnactic == 3 | mnactic == 4
replace emp = 3 if mnactic == 2 
replace emp = 4 if mnactic == 6
replace emp = 5 if mnactic == 5 | mnactic == 7 | mnactic == 8 | mnactic == 9
lab def emp 1 "Employed" 2 "Unemployed" 3 "Education" ///
  4 "Retired" 5 "Homemaker/Other not in labor force"

egen inc = xtile(hinctnt), p(25(25)75) by(iso3166)		
label variable inc "Houshold income"					
label value inc inc
label define inc ///
  1 "1st Quartile" ///
  2 "2nd Quartile" ///
  3 "3rd Quartile" ///
  4 "4th Quartile" ///
   
gen church:dummy = 1 if inlist(rlgatnd,1,2,3,4)				
replace church = 0 if inlist(rlgatnd,5,6,7)
label variable church "Regular church attendence"

ren stflife lsat 

mydummies edu mar emp inc

statsby _b _se, by(iso3166) saving(anmannheim_replication_m4, replace): ///
  reg lsat men age age2 edu2 edu3 emp2-emp5 inc2-inc4

statsby _b _se, by(iso3166) saving(anmannheim_replication_m5, replace): ///
  reg lsat men age age2 edu2 edu3 emp2-emp5 inc2-inc4 mar2-mar4 church

use ~/data/agg/gdp_world_2002, clear
egen iso3166 = iso3166(ctrname), o(names)
drop if iso3166 == "" | iso3166 == "UA"

keep iso3166 hdi
merge iso3166 using anmannheim_replication_m4, sort
keep if _merge==3

// Income figure
gen ub = .
gen lb = .
foreach var in inc2 inc4 {
	replace ub = _b_`var' + 1.96 * _se_`var'
	replace lb = _b_`var' - 1.96 * _se_`var'

	graph twoway /// 
	  || lowess _b_`var' hdi, lcolor(black) ///
	  || rspike ub lb hdi /// 
	  || sc _b_`var' hdi, ms(O) mlcolor(black) mfcolor(black) ///
	  || sc _b_`var' hdi, ms(i) mlab(iso3166) ///
	  || , legend(off) /// 
	  xtitle(HDI) ///
	  ti(`var', bexpand box) ///
	  ytitle(Est. coefficient) yline(0, lcolor(red)) ///
	  name(replication_`var', replace) nodraw
}

keep iso3166 hdi
merge iso3166 using anmannheim_replication_m5, sort
keep if _merge==3

// Marital figure
gen ub = .
gen lb = .
foreach var in mar3 mar4 {
	replace ub = _b_`var' + 1.96 * _se_`var'
	replace lb = _b_`var' - 1.96 * _se_`var'

	graph twoway /// 
	  || lowess _b_`var' hdi, lcolor(black) ///
	  || rspike ub lb hdi /// 
	  || sc _b_`var' hdi, ms(O) mlcolor(black) mfcolor(black) ///
	  || sc _b_`var' hdi, ms(i) mlab(iso3166) ///
	  || , legend(off) /// 
	  xtitle(HDI) ///
	  ti(`"`=cond("`var'"=="mar3","Divorced","Single")'"', bexpand box) ///
	  ytitle(Est. coefficient) yline(0, lcolor(red)) ///
	  name(replication_`var', replace) nodraw
}

graph combine replication_inc2 replication_inc4, rows(1) ycommon
graph export anmannheim_replication_inc.eps, replace

graph combine replication_mar3 replication_mar4, rows(1) ycommon
graph export anmannheim_replication_mar.eps, replace


// Translate all eps files to pdf (Linux only)
!find *.eps -exec epstopdf '{}' ';' 

log close
exit
	

*** WIP

version 10
clear
set memory 90m
set matsize 500
set more off
set scheme s1mono

capture log close


use ~/pub/participation_ts07/analysen/btw49to05  /// 
  if year == 1998 | year == 2005


// Dummi-Coding etc
capture program drop mydummies
program mydummies
syntax varlist
foreach var of local varlist {
  levelsof `var', local(K)
  foreach k of local K {
      gen byte `var'_`k':yesno = `var' == `k' if !mi(`var')
      label variable `var'_`k' "`:label (`var') `k''"
  }
}
end

mydummies edu emp hhinc occ agegroup bul

// Germany, 1998
// -------------

preserve
keep if year==1998

mlogit choicede men agegroup_2 agegroup_5 edu_2 edu_3 emp_2 emp_5 ///
  hhinc_2-hhinc_4 occ_2-occ_5  bul_2-bul_7 ///
  [pweight=dweight]

// Out of sample predictions for non-voters
predict phat* if voter==0 
gen nvchoicede:partyde= 1 if phat1 > max(phat2,phat3,phat4,phat5,phat6)
replace nvchoicede = 2 if phat2 > max(phat1,phat3,phat4,phat5,phat6)
replace nvchoicede = 3 if phat3 > max(phat1,phat2,phat4,phat5,phat6)
replace nvchoicede = 4 if phat4 > max(phat1,phat2,phat3,phat5,phat6)
replace nvchoicede = 5 if phat5 > max(phat1,phat2,phat3,phat4,phat6)
replace nvchoicede = 6 if phat6 > max(phat1,phat2,phat3,phat4,phat5)

// Cancatenate voters and non-voters
replace choicede = nvchoicede if choicede==.

// Aggregated Dataset
gen n = 1 if choicede < . 
collapse (sum) n [aw=dweight] if choicede < . , by(voter choicede)
reshape wide n, i(choicede) j(voter)

gen n = n0+n1
foreach var of varlist n* {
  sum `var', meanonly
  local `var' = r(sum)
}

gen p0 = (n0/`n0')*100
gen p1 = (n1/`n1')*100
gen p  = (n/`n')*100


// Resort German Parties
gen lager = 2 if choicede == 1 | choicede == 3 | choicede == 5
replace lager = 1 if choicede == 2 | choicede ==4
replace lager = 3 if choicede == 6
egen axisde = axis(lager choicede), label(choicede) reverse
drop lager


// Store as Resultsset
gen cntry = "Germany"
gen assumption = "SES"
tempfile de1
save `de1'

// Germany, SES + Pol 
// -------------------

restore, preserve
keep if cntry=="DE"

mlogit choicede men agegroup_2 agegroup_5 edu_2 edu_3 emp_2 emp_5 ///
  hhinc_2-hhinc_4 egp_2-egp_5 church discrim ///
  polint_2 polint_3 polint_4 polcmpl_2 polcmpl_3 polcmpl_4 polcmpl_5 ///
  cgovsat cdemocsat ctrust lrgroup_1 lrgroup_2 lrgroup_4 ///
  partde_2-partde_6 regionde_2-regionde_16 ///
  [pweight=dweight]


// Out of sample predictions for non-voters
predict phat* if voter==0 
gen nvchoicede:partyde= 1 if phat1 > max(phat2,phat3,phat4,phat5,phat6)
replace nvchoicede = 2 if phat2 > max(phat1,phat3,phat4,phat5,phat6)
replace nvchoicede = 3 if phat3 > max(phat1,phat2,phat4,phat5,phat6)
replace nvchoicede = 4 if phat4 > max(phat1,phat2,phat3,phat5,phat6)
replace nvchoicede = 5 if phat5 > max(phat1,phat2,phat3,phat4,phat6)
replace nvchoicede = 6 if phat6 > max(phat1,phat2,phat3,phat4,phat5)

// Cancatenate voters and non-voters
replace choicede = nvchoicede if choicede==.

// Aggregated Dataset
gen n = 1 if choicede < . 
collapse (sum) n [aw=dweight] if choicede < . , by(voter choicede)
reshape wide n, i(choicede) j(voter)

gen n = n0+n1
foreach var of varlist n* {
  sum `var', meanonly
  local `var' = r(sum)
}

gen p0 = (n0/`n0')*100
gen p1 = (n1/`n1')*100
gen p  = (n/`n')*100


// Resort German Parties
gen lager = 2 if choicede == 1 | choicede == 3 | choicede == 5
replace lager = 1 if choicede == 2 | choicede ==4
replace lager = 3 if choicede == 6
egen axisde = axis(lager choicede), label(choicede) reverse
drop lager


// Store as Resultsset
gen cntry = "Germany"
gen assumption = "SES + Pol"
tempfile de2
save `de2'

// United Kingdom, SES only
// ------------------------

restore, preserve
keep if cntry=="GB"

mlogit choicegb men agegroup_2 agegroup_5 edu_2 edu_3 emp_2 emp_5 ///
  hhinc_2-hhinc_4 egp_2-egp_5 church discrim ///
  regiongb_2-regiongb_12 ///
  [pweight=dweight]


// Out of sample predictions for non-voters
predict phat* if voter==0 
gen nvchoicegb:partygb= 1 if phat1 > max(phat2,phat3,phat4)
replace nvchoicegb = 2 if phat2 > max(phat1,phat3,phat4)
replace nvchoicegb = 3 if phat3 > max(phat1,phat2,phat4)
replace nvchoicegb = 4 if phat4 > max(phat1,phat2,phat3)

// Cancatenate voters and non-voters
replace choicegb = nvchoicegb if choicegb==.

// Aggregated Dataset
gen n = 1 if choicegb < . 
collapse (sum) n [aw=dweight] if choicegb < . , by(voter choicegb)
reshape wide n, i(choicegb) j(voter)

gen n = n0+n1
foreach var of varlist n* {
  sum `var', meanonly
  local `var' = r(sum)
}

gen p0 = (n0/`n0')*100
gen p1 = (n1/`n1')*100
gen p  = (n/`n')*100

egen axisgb = axis(choicegb), label(choicegb) reverse
gen cntry = "United Kingdom"
gen assumption = "SES"
tempfile gb1
save `gb1'

// United Kingdom, SES + Pol
// -------------------------

restore
keep if cntry=="GB"

mlogit choicegb men agegroup_2 agegroup_5 edu_2 edu_3 emp_2 emp_5 ///
  hhinc_2-hhinc_4 egp_2-egp_5 church discrim ///
  polint_2 polint_3 polint_4 polcmpl_2 polcmpl_3 polcmpl_4 polcmpl_5 ///
  cgovsat cdemocsat ctrust lrgroup_1 lrgroup_2 lrgroup_4 ///
  partgb_2-partgb_4 regiongb_2-regiongb_12 ///
  [pweight=dweight]


// Out of sample predictions for non-voters
predict phat* if voter==0 
gen nvchoicegb:partygb= 1 if phat1 > max(phat2,phat3,phat4)
replace nvchoicegb = 2 if phat2 > max(phat1,phat3,phat4)
replace nvchoicegb = 3 if phat3 > max(phat1,phat2,phat4)
replace nvchoicegb = 4 if phat4 > max(phat1,phat2,phat3)

// Cancatenate voters and non-voters
replace choicegb = nvchoicegb if choicegb==.

// Aggregated Dataset
gen n = 1 if choicegb < . 
collapse (sum) n [aw=dweight] if choicegb < . , by(voter choicegb)
reshape wide n, i(choicegb) j(voter)

gen n = n0+n1
foreach var of varlist n* {
  sum `var', meanonly
  local `var' = r(sum)
}

gen p0 = (n0/`n0')*100
gen p1 = (n1/`n1')*100
gen p  = (n/`n')*100

egen axisgb = axis(choicegb), label(choicegb) reverse
gen cntry = "United Kingdom"
gen assumption = "SES + Pol"

// Graph
// ------

// Append other Resultssets
append using `de1'
append using `de2'
append using `gb1'

levelsof axisde, local(K)
graph twoway ///
  || scatter axisde p0, ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter axisde p1, ms(O) mlcolor(black) mfcolor(black)  ///
  || pcarrow axisde p1 axisde p, mcolor(black) lcolor(black) ///
  || , 			  						                     ///
  ylabel(`K', valuelabel angle(0) grid gstyle(dot))          ///
  ytitle("")                                                 ///
  xlabel(0(10)70) xmtick(5(10)75)                            ///
  xtitle("") xline(50, lpattern(dash) lcolor(black))         ///
  by(assumption, legend(off) title("Germany") note("")       ///
  graphregion(margin(l+4)))                                  ///
  name(DE, replace) nodraw

levelsof axisgb, local(K)
graph twoway ///
 || scatter axisgb p0, ms(O) mlcolor(black) mfcolor(white)  ///
 || scatter axisgb p1, ms(O) mlcolor(black) mfcolor(black)  ///
 || pcarrow axisgb p1 axisgb p, mcolor(black) lcolor(black) ///
 || , ylabel(`K', valuelabel angle(0) grid gstyle(dot))     ///
  ytitle("")                                                ///
  xlabel(0(10)70) xmtick(5(10)75)                           ///
  xtitle(Proportion of votes (in %)) xline(50, lpattern(dash) lcolor(black)) ///
  legend(order(1 "Non-voters only" 2 "Voters" 3 "Change by Non-voter") rows(1)) ///
  by(assumption, title("United Kingdom") note(""))          ///
  name(GB, replace) nodraw

graph combine DE GB, col(1) xcommon
graph export anexpol3_survey.eps, replace

 
// Use Official results/statistics
// -------------------------------

preserve
drop _all
input str20 cntry choicede choicegb P1 turnout
         Germany  1  . 38.5 .80
         Germany  2  . 38.5 .80
         Germany  3  .  8.6 .80
         Germany  4  .  7.4 .80
         Germany  5  .  4.0 .80
         Germany  6  .  2.9 .80
"United Kingdom"  .  1 31.7 .59
"United Kingdom"  .  2 40.7 .59
"United Kingdom"  .  3 18.3 .59
"United Kingdom"  .  4  9.3 .59
end

sort cntry choicede choicegb
tempfile official
save `official'

restore
sort cntry choicede choicegb
merge cntry choicede choicegb using `official'
assert _merge==3
drop _merge

// Apply the Formula
gen P0 = P1 + (p0-p1)
gen P = P1*turnout + P0*(1-turnout)

levelsof axisde, local(K)
graph twoway ///
  || scatter axisde P0, ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter axisde P1, ms(O) mlcolor(black) mfcolor(black)  ///
  || pcarrow axisde P1 axisde P, mcolor(black) lcolor(black) ///
  || , 			  						                     ///
  ylabel(`K', valuelabel angle(0) grid gstyle(dot))          ///
  ytitle("")                                                 ///
  xlabel(0(10)70) xmtick(5(10)65)                            ///
  xtitle("") xline(50, lpattern(dash) lcolor(black))         ///
  by(assumption, legend(off) title("Germany") note("")       ///
  graphregion(margin(l+4)))                                  ///
  name(DE, replace) nodraw

levelsof axisgb, local(K)
graph twoway ///
 || scatter axisgb P0, ms(O) mlcolor(black) mfcolor(white)  ///
 || scatter axisgb P1, ms(O) mlcolor(black) mfcolor(black)  ///
 || pcarrow axisgb P1 axisgb P, mcolor(black) lcolor(black) ///
 || , ylabel(`K', valuelabel angle(0) grid gstyle(dot))     ///
  ytitle("")                                                ///
  xlabel(0(10)70) xmtick(5(10)65)                           ///
  xtitle(Proportion of votes (in %)) xline(50, lpattern(dash) lcolor(black)) ///
  legend(order(1 "Non-voters only" 2 "Voters" 3 "Change by Non-voter") rows(1)) ///
  by(assumption, title("United Kingdom") note(""))          ///
  name(GB, replace) nodraw


graph combine DE GB, col(1) xcommon
graph export anexpol3_official.eps, replace


exit













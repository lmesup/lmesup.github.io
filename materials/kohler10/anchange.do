version 9.1
clear
set matsize 500
set more off
capture log close

use ess04 if cntry=="DE", clear

// Election system dummies
gen majority = inlist(cntry,"GB","FR")
label variable majority "Majority system"
gen compulsory = inlist(cntry,"BE","IT","LU","BE") // | inlist(cntry,"AT","NL")
label variable compulsory "Compulsory elections"
gen workday = inlist(cntry,"IE","GB", "NL", "NO")
label variable workday "Elections on rest days"
gen fc = inlist(cntry,"CZ","EE","PL","SI","HU") | inlist(cntry,"SK")
label variable fc "Communist legacy"

// Variabl redifinitions
gen agegroup:agegroup = 1 if inrange(age,18,25)
replace agegroup = 2 if inrange(age,26,79)
replace agegroup = 3 if inrange(age,80,102)
label define agegroup 1 "Age 18-25" 2 "Age 26-79" 3 "Age 80 and above"

replace emp = 3 if emp==3 | emp==4 | emp==5
label define emp 3 "Homemaker/in Education/Retired", modify

// Additive Index trust
egen trust = rmean(trst*)
label variable trust "Trust in political institutions"

// Listwise Deletion
mark touse
markout touse voter age men edu egp emp hhinc church discrim ///
   polint polcmpl govsat democsat trust lrgroup
keep if touse

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

mydummies edu emp hhinc egp polint polcmpl agegroup lrgroup

// Centering
foreach var of varlist govsat democsat trust {
   sum `var'
   gen c`var' = (`var'-r(mean))/r(sd)
   label variable c`var' "`:var lab `var'' (standardized)"
}


// Merge Voting Variables
// ----------------------
isid idno
merge cntry idno using $ess/ess2004, sort keep(prtvade2 regionde) nokeep
assert _merge==3

gen choicev:choice = prtvade2
replace choicev = 6 if prtvade2 >= 6 & !mi(prtvade2)
label define choice 1 "SPD" 2 "CDU/CSU" 3 "B90/GR" 4 "FDP" 5 "PDS" 6 "Other"

tab regionde, gen(bul)

mlogit choicev men agegroup_1 agegroup_3 edu_2 edu_3 emp_2 emp_3 ///
  hhinc_2-hhinc_4 egp_2-egp_6 church discrim ///
  polint_2 polint_3 polint_4 polcmpl_2 polcmpl_3 polcmpl_4 polcmpl_5 ///
  cgovsat cdemocsat ctrust lrgroup_1 lrgroup_2 lrgroup_4 bul2-bul16


predict phat* if voter==0
gen choicenv:choice= 1 if phat1 > max(phat2,phat3,phat4,phat5)
replace choicenv = 2 if phat2 > max(phat1,phat3,phat4,phat5,phat6)
replace choicenv = 3 if phat3 > max(phat1,phat2,phat4,phat5,phat6)
replace choicenv = 4 if phat4 > max(phat1,phat2,phat3,phat5,phat6)
replace choicenv = 5 if phat5 > max(phat1,phat2,phat3,phat4,phat6)
replace choicenv = 6 if phat6 > max(phat1,phat2,phat3,phat4,phat5)

gen choice:choice = choicev
replace choice = choicenv if choice==.

label value voter voter
label define voter 0 "Non voter" 1 "Voter"

tab choice, gen(choice)

graph bar choice1-choice6,  ///
  by(voter, total legend(off) note("`=c(current_date)', `=c(current_time)'")) ///
  bar(1, color(red)) ///
  bar(2, color(black)) ///
  bar(3, color(green)) ///
  bar(4, color(yellow)) ///
  bar(5, color(pink)) ///
  bar(6, color(gs8))  ///
  blabel(bar, format(%2.0f)) showyvars percentages ///
  yvaroptions(relabel(1 "SPD" 2 "CDU" 3 "Grü" 4 "FDP" 5 "PDS" 6 "Other")) ///
  ytitle("") scheme(s1mono)

graph export anchange_DE.eps, replace

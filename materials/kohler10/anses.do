// Logistic Regression Analysis of Voting on Socio Economic Variables
// kohler@wzb.eu

version 10
set more off
capture log close
log using anses, replace
eststo clear
erase anses.rtf

use ess04, clear

// Variable redifinitions
gen agegroup:agegroup = 1 if inrange(age,18,21)
replace agegroup = 2 if inrange(age,22,24)
replace agegroup = 3 if inrange(age,25,34)
replace agegroup = 4 if inrange(age,35,79)
replace agegroup = 5 if inrange(age,80,102)
label define agegroup 1 "18-21" 2 "22-24" 3 "25-34" 4 "35-79" 5 "80 and above"

replace emp = 2 if emp==2 | emp==3 | emp==4
label define emp 2 "Outside labour force", modify

// Additive Index trust
egen trust = rmean(trst*)
label variable trust "Trust in political institutions"

encode cntry, gen(ctrnum)

// Listwise Deletion
mark touse
markout touse voter age men edu egp emp hhinc church discrim ///
   polint polcmpl govsat democsat  trust lrgroup pi
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

mydummies ctrnum edu emp hhinc egp agegroup

// Define Program do calculate Variance of Coefficients for Country
capture program drop dsetvar
program dsetvar, rclass
version 10
	quietly {
		matrix b = e(b)'
		matrix b = b["`1'".."`2'",1]
		svmat double b, name(_estadd_dsetvar)
		count if _estadd_dsetvar1 ~= .
		drop if _estadd_dsetvar1 == 0
		replace _estadd_dsetvar1 = 0 in `=r(N)+1'
		sum _estadd_dsetvar1
		return scalar dsetvar = r(sd)
		drop _estadd_dsetvar1
		}
end


// Models
// ------
foreach block in "agegroup_2-agegroup_5" "edu_2 edu_3" "men" "church" ///
 "hhinc_2-hhinc_4" "egp_2-egp_5" "emp_2 emp_5" "discrim" {

  eststo clear

  // Country-Dummies only
  logit voter `block' ctrnum_1-ctrnum_8 ctrnum_10-ctrnum_23 [pw=nweight]
  dsetvar ctrnum_1 ctrnum_23
  estadd scalar sdC = `=r(dsetvar)'
  mfx 
  eststo

  // Cage+Gender
  local other "men agegroup_2-agegroup_5 edu_2 edu_3"
  local other: subinstr local  other "`block'" ""
  logit voter `block' `other' ///
    ctrnum_1-ctrnum_8 ctrnum_10-ctrnum_23 [pw=nweight]
  dsetvar ctrnum_1 ctrnum_23
  estadd scalar sdC = `=r(dsetvar)'
  mfx
  eststo

  // Social Structure
  local other "men agegroup_2-agegroup_5 edu_2 edu_3 emp_2 emp_5 hhinc_2-hhinc_4 egp_2-egp_5"
  local other: subinstr local  other "`block'" ""
  logit voter `block' `other' ///
    ctrnum_1-ctrnum_8 ctrnum_10-ctrnum_23 [pw=nweight]
  dsetvar ctrnum_1 ctrnum_23
  estadd scalar sdC = `=r(dsetvar)'
  mfx
  eststo

  // Network
  local other "men agegroup_2-agegroup_5 edu_2 edu_3 emp_2 emp_5 hhinc_2-hhinc_4 egp_2-egp_5 church discrim"
  local other: subinstr local  other "`block'" ""
  logit voter `block' `other' ///
    ctrnum_1-ctrnum_8 ctrnum_10-ctrnum_23 [pw=nweight]
  dsetvar ctrnum_1 ctrnum_23
  estadd scalar sdC = `=r(dsetvar)'
  mfx
  eststo

  local pos = strpos("`block'","_") - 1
  local title = cond(`pos'>0,substr("`block'",1,`pos'),"`block'")
  esttab using anses, rtf append ///
    title("Discrete Change Effects for `:var lab `title''")             ///
    label margin pr2 obslast scalars("sdC SD(Country)") b(%3.2f) t(%3.1f)                ///
         compress mtitles("Country only" "Gender/Age/Educ." "Class/Income/Empl." "Discrim./Church" ) ///
         nodepvar nogaps keep(`title'*)
   }

log close
exit


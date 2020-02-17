version 9.1
set more off
capture erase anpol.rtf
capture log close
log using anpol, replace

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
mydummies ctrnum edu emp hhinc egp agegroup polint polcmpl lrgroup


// Centering
foreach var of varlist govsat democsat trust {
   sum `var'
   gen c`var' = (`var'-r(mean))/r(sd)
   label variable c`var' "`:var lab `var'' (standardized)"
}

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

// Voter Models
// ------------

// Variables alone
foreach block in ///
   "polint_2 polint_3 polint_4"  ///
   "polcmpl_2 polcmpl_3 polcmpl_4 polcmpl_5" ///
   "pi" "cgovsat" "cdemocsat" "ctrust" ///
   "lrgroup_1 lrgroup_2 lrgroup_4" {

	 eststo clear

  // Country-Dummies only
  logit voter `block' ctrnum_1-ctrnum_8 ctrnum_10-ctrnum_23 [pw=nweight]
  dsetvar ctrnum_1 ctrnum_23
  estadd scalar sdC = `=r(dsetvar)'
  mfx 
  eststo

  // All SES 
  logit voter `block' ctrnum_1-ctrnum_8 ctrnum_10-ctrnum_23 ///
   men agegroup_2-agegroup_5 edu_2 edu_3 emp_2 emp_5 hhinc_2-hhinc_4 egp_2-egp_5 church discrim [pw=nweight]
  dsetvar ctrnum_1 ctrnum_23
  estadd scalar sdC = `=r(dsetvar)'
  mfx 
  eststo

  // Full Modell

  local other "polint_2 polint_3 polint_4 polcmpl_2 polcmpl_3 polcmpl_4 polcmpl_5"
  local other "`other' pi cgovsat cdemocsat ctrust lrgroup_1 lrgroup_2 lrgroup_4"
  local other: subinstr local  other "`block'" ""

  logit voter `block' `other' ctrnum_1-ctrnum_8 ctrnum_10-ctrnum_23 ///
   men agegroup_2-agegroup_5 edu_2 edu_3 emp_2 emp_5 hhinc_2-hhinc_4 egp_2-egp_5 church discrim [pw=nweight]
  dsetvar ctrnum_1 ctrnum_23
  estadd scalar sdC = `=r(dsetvar)'
  mfx
  eststo

  local pos = strpos("`block'","_") - 1
  local title = cond(`pos'>0,substr("`block'",1,`pos'),"`block'")
  esttab using anpol                                                ///
    , rtf append title("Marginal Effects for `:var lab `title''")   ///
    label margin pr2 obslast b(%3.2f) t(%3.1f) scalar("sdC SD(Country)") ///
    compress mtitles("Country only" "Social Structure" "Complete" ) ///
    nodepvar nogaps keep(`block')
}

log close

exit

 

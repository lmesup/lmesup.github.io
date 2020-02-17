// Logistic Regression of voting on Country-Dummies
// kohler@wzb.eu

version 10
set more off
capture log close
log using anbase, replace
eststo clear

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

egen ctrname = iso3166(cntry), o(codes)
encode ctrname, gen(ctrnum)

// Additive Index trust
egen trust = rmean(trst*)

levelsof ctrnum, local(K)
foreach k of local K {
    gen byte C_`k':yesno = ctrnum == `k' 
    label variable C_`k' "`:label (ctrnum) `k''"
}

// Listwise Deletion
mark touse1
markout touse1 voter age men edu egp emp hhinc church discrim 
mark touse2
markout touse2 voter age men edu egp emp hhinc church discrim ///
   polint polcmpl govsat democsat trust lrgroup pi

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

// Country dummies only
logit voter C_1-C_5 C_7-C_23 [pw=nweight]
dsetvar C_1 C_23
estadd scalar sdC = `=r(dsetvar)'
mfx
eststo

// Country dummies only
logit voter C_1-C_5 C_7-C_23 [pw=nweight] if touse1
dsetvar C_1 C_23
estadd scalar sdC = `=r(dsetvar)'
mfx
eststo

// Country dummies only
logit voter C_1-C_5 C_7-C_23 [pw=nweight] if touse2
dsetvar C_1 C_23
estadd scalar sdC = `=r(dsetvar)'
mfx
eststo

esttab using anbase, ///
  rtf replace title("Version from `=c(current_date)' `=c(current_time)'")  ///
  label margin pr2 obslast  b(%3.2f) t(%3.1f) scalars("sdC SD(Country)") ///
  compress nodepvar nogaps 

log close
exit



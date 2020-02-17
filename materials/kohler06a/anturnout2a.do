	// anturnout2-tries with Hirarchical Models

version 8.2
	set more off
	set scheme s1mono
	capture log close
	log using anturnout2a, replace
	
	use s_cntry hh2a hh2b hhinc4 q24a q25 q31 q46 hhstat emplstat wcountry ///
	  using $dublin/eqls_4, clear

	// Rectangularize Data
	// -------------------

	// Nur Wahlberechtigte
	drop if q25 == 3

	// I'll keep Missings of Categorical Data
	replace emplstat = 7 if emplstat == .
	replace hhstat = 7 if hhstat == .

	// Listwise Deletion
	mark touse
	markout touse s_cntry hh2a hh2b hhinc4 q24a q25 q31 q46 hhstat emplstat
	keep if touse

	// Merge Nice Country-Names
	// ------------------------

	sort s_cntry
	merge s_cntry using isocntry
	drop _merge


	// Election System
	// ---------------

	sort s_cntry
	merge s_cntry using electsystem
	drop _merge

	gen weekend:yesno = day == 0 | day==6 if day < .
	label variable weekend "Wochenendwahl"
	label variable compet "Wettbewerbsgrad"
	gen pflicht:yesno = compul > 0 if compul < .
	label variable pflicht "Wahlpflicht"
	gen propor:yesno = type == 1 if type < .
	label variable propor "Verhältniswahlrecht"
	gen state:yesno = inlist(regis,1,3) if day < .
	label variable state "Staatlich initiierte Registrierung"
	gen org=orgevs
	label variable org "Organisationsgrad"


	// Recoding
	// --------
	
	// Voter
	gen voter = q25==1 if q25 < . 

	// Country-Dummies (in sort order for nice tables)
	by ctrde, sort: gen fraction = sum(voter)/_N
	by ctrde, sort: replace fraction = fraction[_N]
	egen ctrsort = egroup(eu fraction), label(ctrde)
	tab ctrsort, gen(ctrsort)
	foreach var of varlist ctrsort1-ctrsort28 {
		local label: variable label `var'
		local label = subinstr("`label'","ctrsort==","",1)
		label variable `var' "`label'"
	}

	// Gender
	gen men = hh2a == 1
	label variable men "Mann"
	
	// Centered Age/Age-squared
	sum hh2b
	gen age = hh2b - r(mean)
	gen age2 = age^2
	label var age "Alter"
	label var age2 "Alter (quadriert)"

	// Income
	egen income = xtile(hhinc4), p(2(2)98) by(s_cntry)
	sum income
	replace income = income - r(mean)
	label var income "Einkommen (50 Quantile)"

	// Education
	egen edu = xtile(q46), p(10(10)90) by(s_cntry)
	sum edu, meanonly
	replace edu = edu - r(mean)
	label var edu "Bildung (Dezile)"

	// Occupation (Household)
	gen occ1 = hhstat==1
	label var occ1 "Dienstklasse"
	gen occ2 = hhstat==2
	label var occ2 "Andere Nicht Manuelle"
	gen occ3 = hhstat==3
	label var occ3 "Selbständige "
	gen occ4 = hhstat==4 | hhstat==5
	label var occ4 "Arbeiter"
	gen occ5 = hhstat == 6 | hhstat == 7
	label var occ5 "Sonstige/Missing"
	
	
	// Employment (Respondend)
	gen emp1 = emplstat==1
	label var emp1 "Erwerbstaetige"
	gen emp2 = emplstat==2
	label var emp2 "Hausfrau/mann"
	gen emp3 = emplstat==3
	label var emp3 "Arbeitslos"
	gen emp4 = emplstat==4
	label var emp4 "Rentner/Pensionäre"
	gen emp5 = emplstat== 5 | emplstat==6 | emplstat == 7
	label var emp5 "Sonstige/Missing"
	
	// Group-Participation
	gen group = q24 == 1
	label var group "Mitarbeit in Gruppe"

	// Life Satisfaction
	gen lsat = q31
	label var lsat "Allg. Lebenszufriedenheit"

	// Xtregression Models
	// -----------------

	iis s_cntry

	// Country Only
	xtreg voter  , re
	local sunull =  e(sigma_u)

// Country + Situations
xtreg voter men age age2  , re
local suage =  e(sigma_u)

// Country + Edu
xtreg voter  men age age2 edu  , re
local suedu =  e(sigma_u)

// Country + Situations
xtreg voter  men age age2 edu income occ2-occ5 emp2-emp5  , re
local susit =  e(sigma_u)

// Country + Group
xtreg voter  men age age2 edu income occ2-occ5 emp2-emp5 group  , re
local sugroup =  e(sigma_u)

// Country + Edu + Sit + Group
xtreg voter  men edu age age2 income occ2-occ5 emp2-emp5 group lsat  , re  
local sufull =  e(sigma_u)


// Append Explained Country-Variation
// ----------------------------------


file open results using anturnout2a.tex, write append text
file write results "\\hline" _n "\$u_i\$"
file write results "&" %4.3f (`sunull') 
	foreach name in age edu sit group full {
		file write results "&" %4.3f (`su`name'')
	}
	file write results _n "PRE & 0 "
	foreach name in age edu sit group full {
		local explained= (`sunull' - `su`name'')/`sunull'
	file write results "&" %4.3f (`explained')
	}
	file write results "\\\\ \\hline" _n "\\end{tabular}"
	file close results
log close
exit








exit
	

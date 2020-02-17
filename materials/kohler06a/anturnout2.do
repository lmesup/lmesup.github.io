	// Logit-Models Voting vs. Kovariates

version 8.2
	set more off
	set scheme s1mono
	capture log close
	log using anturnout2, replace
	
	use s_cntry hh2a hh2b hhinc4 q24a q25 q31 q46 hhstat emplstat wcountry ///
	  using $dublin/eqls_4, clear


	// Voter
	// ----

	// Nur Wahlberechtigte
	drop if q25 == 3 | q25 >= .
	gen voter = q25==1 

	// Merge Nice Country-Names
	// ------------------------

	sort s_cntry
	merge s_cntry using isocntry
	drop _merge

	// Country-Dummies (in sort order for nice tables)
	by ctrde, sort: gen fraction = sum(voter*wcountry)/sum(wcountry)
	by ctrde, sort: replace fraction = fraction[_N]
	sort fraction
	egen ctrsort = egroup(fraction), label(ctrde)
	tab ctrsort, gen(ctrsort)
	foreach var of varlist ctrsort1-ctrsort28 {
		local label: variable label `var'
		local label = subinstr("`label'","ctrsort==","",1)
		label variable `var' "`label'"
	}

	// Rectangularize Data
	// -------------------

	// I'll keep Missings of Categorical Data
	replace emplstat = 7 if emplstat == .
	replace hhstat = 7 if hhstat == .

	// Listwise Deletion
	mark touse
	markout touse s_cntry hh2a hh2b hhinc4 q24a q25 q31 q46 hhstat emplstat
	keep if touse


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

	// Regression Models
	// -----------------

	// Country Only
	logit voter ctrsort2-ctrsort28 [pw=wcountry]
	estimates store null
	matrix null = e(b)'
svmat null, name(null)

// Country + Situations
logit voter ctrsort2-ctrsort28 men age age2 [pw=wcountry]
estimates store age
matrix age = e(b)'
svmat age, name(age)

// Country + Edu
logit voter ctrsort2-ctrsort28 men age age2 edu [pw=wcountry]
estimates store edu
matrix edu = e(b)'
svmat edu, name(edu)

// Country + Situations
logit voter ctrsort2-ctrsort28 men age age2 edu income occ2-occ5 emp2-emp5 [pw=wcountry]
estimates store sit
matrix sit = e(b)'
svmat sit, name(sit)

// Country + Group
logit voter ctrsort2-ctrsort28 men age age2 edu income occ2-occ5 emp2-emp5 group [pw=wcountry]
estimates store group
matrix group = e(b)'
svmat group, name(group)

// Country + Edu + Sit + Group
logit voter ctrsort2-ctrsort28 men edu age age2 income occ2-occ5 emp2-emp5 group lsat [pw=wcountry]
estimates store full
matrix full = e(b)'
svmat full, name(full)

// Outtex Models
// -------------

estout null age edu sit group full ///
	  using anturnout2.tex ///
	  , replace style(tex) label ///
	  prehead(\begin{tabular}{lrrrrrr} \hline)  ///
	  posthead(\hline) ///
	  prefoot(\hline)  ///
	  mlabel("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" ) /// 
collabels(, none) ///
	  cells(b(fmt(%3.2f) star)) ///
	  stats(r2_p N, labels("\$r^2_{\\text{McFadden}}\$" "\$n\$") fmt(%9.2f %9.0f)) ///
	  varlabels(_cons Constant) ///
	  starlevels(* 0.05) 

// Append Explained Country-Variation
// ----------------------------------


file open results using anturnout2.tex, write append text
file write results "\\hline" _n "Reduktion Länder-Varianz"
keep in 1/27
keep null1-full1
set obs 28
replace null1 = 0 in 28
sum null1
local null = r(Var)
file write results "& 0"
foreach var of varlist age1-full1 {
replace `var' = 0 in 28
sum `var'
local explained = (`null' - r(Var))/r(Var)
file write results "&" %4.3f (`explained')
}

file write results "\\\\ \\hline" _n "\\end{tabular}"
file close results

log close
exit








exit
	

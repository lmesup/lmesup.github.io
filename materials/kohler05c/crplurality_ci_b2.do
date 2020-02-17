* b-Coeff of Class by plurality (Nonparametric Method)
* ----------------------------------------------------
	
version 8.2
	set more off
	capture log close
	
	// Data
	// ----

	use ///
	  s_cntry hh1 hh2a hh2b ///
	  q17 q19* q20_* q23b q25 q26  q27* q29a q29b q31 q44 q56* ///
	  emplstat hhstat teacat ///
	  using  "$dublin/eqls_4", clear

	label define yesno 0 "no" 1 "yes"
	

	// Lebenslagen
	// -----------

	// Live-Satisfaction
	ren q31 lsat

	// Health status
	gen health = q44 == 2 if q44 < .

	// Problems of Accomodation
	egen accom = neqany(q19*), values(1)
	replace accom = . if q19_1 >= . | q19_2 >= . | q19_3 >= . | q19_4 >= .
	
	// Afford of Goods
	egen afford = neqany(q20_*), values(2)
	replace afford = . if q20_1 >= . | q20_2 >= . | q20_3 >= . | q20_4 >= . ///
	    | q20_5 >= . | q20_6 >= . 

	// Quality of Environment
	gen envqual = q56a + q56b + q56c
	
	// Independent Variables
	// ----------------------

	// Gender
	gen men:yesno = hh2a==1 if hh2a < .
	drop hh2a
	
	// Age
	gen age = hh2b 
	gen age2 = age^2

	// In Education
	gen inedu:yesno = emplstat == 5 | teacat == 4
	
	// Employment-Status
	gen emp:emp = emplstat
	replace emp = 5 if emplstat >= 5  // "Missing" + "Other" + "Still Studying"
	label def emp 1 "employed" 2 "homemaker" 3 "unemployed" 4 "retired" 5 "Other"
	drop emplstat
	
	// Education
	gen edu:edu = teacat
	replace edu = 4 if edu >= . // "Missing" + "Still Studying" = "Other"
	label define edu 1 "low" 2 "intermediate" 3 "high"
	drop teacat

   // "Class" of Main-Earner 
	ren hhstat class
	replace class = 7 if class >= .
	label define hhstat 7 "other", modify


	// Make Dummy Variables
	// --------------------

	foreach var of varlist emp edu class {
		quietly tab `var', gen(`var')
	}


	// Initialize  Postfile
	// --------------------

	local depvars lsat health accom afford envqual
	foreach name of local depvars {
		local postterm `"`postterm' n`name' bclass2`name' bclass3`name' bclass4`name' bclass5`name'"'
	}

	tempfile coefs
	tempname coef
	postfile `coef' s_cntry  `postterm' using `coef', replace

	// Regression Models
	// -----------------

	levels s_cntry, local(K)
	foreach k of local K {
		local postterm (`k')
		foreach depvar of local depvars {
			local model = cond("`depvar'" == "health","logit","regress")
			qui `model'  `depvar' men age age2 inedu emp2-emp5 edu2-edu4 class2-class7 if s_cntry==`k'
			local N = e(N)
			local class2 = _b[class2]
			local class3 = _b[class3]
			capture local class4 = _b[class4]  // High Discrimination for Malta
			capture local class5 = _b[class5]  // High Discrimination for Romania
			local postterm `" `postterm' (`N') (`class2')  (`class3') (`class4') (`class5') "' 
		}
		post `coef' `postterm'
	}
	
	// End Matters
	
	postclose `coef'
	use `coef', clear
	sort s_cntry
	save `coef', replace

	use plurality_ci
	sort s_cntry
	merge s_cntry using `coef'
	drop _merge

	save plurality_ci_b2, replace
	
	exit


	
	


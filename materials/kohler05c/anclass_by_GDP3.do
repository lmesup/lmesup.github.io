* Regression modells for Class-effect with GDP-Interaction
* --------------------------------------------------------
* Referenzkategorie "höhere white collar"

	
version 8.2
	set more off
	capture log close
	log using anclass_by_GDP3, replace
	
	// Data
	// ----

	use ///
	  s_cntry hh1 hh2a hh2b ///
	  q17 q19* q20_* q23b q25 q26  q27* q29a q29b q31 ///
	  emplstat hhstat teacat gdppcap1 ///
	  using  "$dublin/eqls_4", clear

	label define yesno 0 "no" 1 "yes"


	// Attitudes
	// ---------

	// Live-Satisfaction
	ren q31 lsat

	// Trust in Social System
	gen trust = (q27a + q27b) - 1
	sum trust, meanonly
	replace trust = r(max)+1 - trust

	// Cleavage-Awareness
	gen clevaware = (q29a + q29b) - 2
	sum clevaware, meanonly
	replace clevaware = r(max)+1 - clevaware

	local attitudes "lsat trust clevaware"
	
	// Behavior
	// --------

	// Vote Participation
	gen voter:yesno = q25==1 if q25 < 3

	// Religiousity 
	sum q26, meanonly
	gen rel = r(max)+1-q26

	// Work for Voluntary Organization 
	gen vol:yesno = q23b==1 if q23b < .

	local behavior "voter rel vol"

	// Ressources
	// ----------

	// Rooms per Person
	replace q17 = . if q17 == 75  // 1 obs. with 75 rooms seems to be a Data-Error
	gen roomspers = q17/hh1

	// Problems of Accomodation
	egen accom = neqany(q19*), values(1)
	replace accom = . if q19_1 >= . | q19_2 >= . | q19_3 >= . | q19_4 >= .

	// Afford of Goods
	egen afford = neqany(q20_*), values(2)
	replace afford = . if q20_1 >= . | q20_2 >= . | q20_3 >= . | q20_4 >= . ///
	    | q20_5 >= . | q20_6 >= . 

	local ressources "roomspers accom afford"
	
	// Independent Variables
	// ----------------------

	// Gender
	gen men:yesno = hh2a==1 if hh2a < .
	drop hh2a
	
	// Age
	sum hh2b, meanonly
	gen age = hh2b-r(mean)
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

	// GDP
	replace gdppcap1 = gdppcap1/1000
	sum gdppcap1, meanonly
	gen zgdp = gdppcap1  - r(mean)
	
	// Make Dummy Variables
	// --------------------

	foreach var of varlist emp edu class s_cntry {
		quietly tab `var', gen(`var')
	}

	label var class1 `"Höhere "White Collar""'
	label var class2 `"Niedere "White Collar""'
	label var class3 `"Selbständige"'
	label var class4 `"Facharbeiter"'
	label var class5 `"Un- und ang. Arbeiter"'
	label var class6 `"Landwirte"'
	label var class7 `"Sonstige"'
	
	// Make Interaction Terms
	// ----------------------
	
	foreach var of varlist class1-class7 {
		gen `var'gdp = `var' * zgdp
	}
	
	local depvars "`attitudes' `behavior' `ressources'"
	
	foreach depvar of local depvars {
		local model = cond("`depvar'" == "voter" | "`depvar'" == "vol","logit","regress")
		`model' `depvar' ///
		  men age age2 inedu emp2-emp5 edu2-edu4 s_cntry2-s_cntry28 ///
		  class1-class4 class6 class7 class1gdp-class4gdp class6gdp class7gdp
		estimates store `depvar'
	}

	estout `depvars' using anclass_by_GDP3.tex, replace ///
	  cells(b(star fmt(%4.3f)) se(paren fmt(%4.3f)))        ///
	  stats(r2 N, fmt(%4.2f %4.0f) label("\$r^2$" "n"))     ///
	  label varlabels(_cons Konstante) style(tex)           ///  
	prehead("\begin{tabular}{lrrrrrrrrr}" \hline)                         ///
	  posthead(\hline) prefoot(\hline)                                    ///
	  postfoot(\hline "\end{tabular}")                                    ///
	  varwidth(22) modelwidth(6)

	log close
	exit


	
	


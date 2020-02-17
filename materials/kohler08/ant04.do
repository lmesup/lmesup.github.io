* Selection of Respondents by Gender and Employment (EQLS, Strict Definition)
* kohler@wz-berlin.de	

version 9

	clear
	set memory 90m
	set more off

	tempfile iso
	
	// EQLS
	// ----

	use svydat01 if survey=="EQLS 2003"
	ren id s_respnr
	merge s_respnr using $dublin/eqls_4, sort keep(hh2b hh2d hh3d_2 hh3a_2 hh3b_2)
	drop _merge
	keep if hart == 1
	
	// Case ID
	ren s_respnr id
	
	// Frauen
	ren women women1
	gen women2:yesno = hh3a_2 == 2 if !missing(hh3a_2)

	// Age
	gen age1 = hh2b if !missing(hh2b)
	gen age2 = hh3b_2 if !missing(hh3b_2)

	// Economic Status
	gen emp1:yesno = hh2d==1 
	gen emp2:yesno = hh3d_2==1  
	
	// Household-Characteristic
	reshape long women age emp, i(id) j(person)
	label define hht 1 "Male Breadwinner" 2 "Female Breadwinner" 3 "Both Employed" 4 "None Employed"
	by id (women), sort: gen hhtyp:hht = 1 if emp[1]==1 & emp[2]==0
	by id (women), sort: replace hhtyp = 2 if emp[1]==0 & emp[2]==1
	by id (women), sort: replace hhtyp = 3 if emp[1]==1 & emp[2]==1
	by id (women), sort: replace hhtyp = 4 if emp[1]==0 & emp[2]==0
	keep if person==1


	label define persel 1 "Register" 2 "Kish/Last-Birthday"  3 "Quota" 4 "Missing"
	gen persel:persel = 1 if hhsamp == 0
	replace persel = 2 if selper == "Gfk master sample"
	replace persel = 2 if selper == "database of addresses"
	replace persel = 2 if selper == "kish grid"
	replace persel = 2 if selper == "kish grid or last birthday"
	replace persel = 2 if selper == "last birthday"
	replace persel = 2 if selper == "random selection"
	replace persel = 3 if selper == "last birthday + quota"
	replace persel = 3 if selper == "quota"
	replace persel = 4 if persel == .

	// t-values by survey iso3166_2 city
	collapse (mean) womenp=women (count) N=women, by(hhtyp persel) 
	gen woment = (womenp - .5)/sqrt(.5^2/N)

	reshape wide womenp woment N, i(hhtyp) j(persel)

	gen N = N1 + N2
	
	format women* %3.2f
	format N %4.0f
	
	listtex hhtyp N womenp* woment* using ant04.tex                                          ///
	  , type replace missnum(-) rstyle(tabular)                                              ///
	  head("\begin{tabular}{lccccc} \hline "                                                 ///
	  "& & \multicolumn{2}{c}{Fraction of Women} & \multicolumn{2}{c}{Sample Quality} \\ "   ///
	  "HH-Type & \$n\$ & Register & Household & Register & Household  \\ \hline " )          ///
	  foot("\hline" "\end{tabular}" )

	exit


	


	
	


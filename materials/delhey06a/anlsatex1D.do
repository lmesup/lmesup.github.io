	// Easy example for anlsat-Analysis
	// -------------------------------
	// Reiterate anlsatex with Deprivation Index
	

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anlsatex1D, replace
	
	// Data
	// ----

	use data03, clear

	// Put Countries in Order

	replace cntry = "Deutschland (W)" if cntry == "Germany (W)"
	replace cntry = "Deutschland (O)" if cntry == "Germany (E)"
	replace cntry = "Ungarn" if cntry == "Hungary"
	replace cntry = "Türkei" if cntry == "Turkey"

	label define country 4 "Deutschland (W)" 3 "Deutschland (O)" 2 "Ungarn" 1 "Türkei"
	encode cntry, gen(country) label(country)

	
	// Regression Models
	// -----------------

	// Control Variables

	label var age "Alter"
	label var switzerland_i "Leb. Bed.: Eigene - Schweiz"
	lab var men "Mann j/n"
	
	gen age2 = age^2
	label var age2 "Alter (quad.)"
	gen lhinceq = log(hinceq)  // 21 obs to missing
	label var lhinceq "Log(Einkommen)"

	recode edu (1 2 = 1) (3 = 2) (4= 3) (5=4) (6 = .)
	label define edu 1 "Primary and below" 2 "lower secondary" 3 "secondary" 4 "tertiary", modify
	tab edu, gen(edu)
	label var edu2 "Unt. Sekundarst."
	label var edu3 "Sekundarst."
	label var edu4 "Tertiär"

	tab emp, gen(emp)
	label var emp2 "Teilzeit"
	label var emp3 "Rentner/Pensionäre"
	label var emp4 "Arbeitslos"
	label var emp5 "Hausfrau/-mann"
	label var emp6 "Sonstige/Missing"

	tab occ, gen(occ)
	label var occ2 "Facharb./Meister"
	label var occ3 `""Niedere "White Collar""'
	label var occ4 `"Höhere "White Collar""'
	label var occ5 "Selbständig"
	label var occ6 "Sonstige/Missing"

	replace mar = . if mar == 5
	tab mar, gen(mar)
	label var mar2 "Verheiratet/zus.-Lebend"
	label var mar3 "Verwitwet"
	label var mar4 "Geschieden/getrennt"

	forv i = 1/4 {
		regress lsat switzerland_i men age age2 lhinceq dep edu2-edu4 emp2-emp4 occ2-occ6 mar2-mar4  ///
		  [pweight = pweight] if country == `i'
		estimates store country`i'
	}

	estout country* using anlsatex1_tableD.txt ///
	, replace style(tab) label ///
		  mlabel("Türkei" "Ungarn" "Deutschland (O)" "Deutschland (W)" ) ///
		  varlabels(_cons "Konstante", blist( ///
		  edu2 "Bildung`=char(13)' Referenzkategorie: Primär (und darunter)`=char(13)'" ///
		  emp2 "Erwerbsstatus`=char(13)' Referenzkategorie: Vollzeit`=char(13)'" ///
		  occ2 "Berufl. Stellung`=char(13)' Referenzkategorie: Ungel. Arbeiter`=char(13)'" ///
		  mar2 "Familienstand`=char(13)' Referenzkategorie: Ledig`=char(13)'" ///
		)) ///
	  collabels(, none) ///
	  cells(b(fmt(%4.2f) star)) ///
	  stats(r2 N, labels("r2" "n") fmt(%9.2f %9.0f)) ///
	  starlevels(* 0.05 ** 0.01 *** 0.001) legend

	exit
	


 
 

	

	
	
	
	

	

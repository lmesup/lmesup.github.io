version 9.2
set more off
set scheme s1mono
cd M:\group\ARS\USI\kohler\participation07\analysen



//Beh�lter f�r zu erzeugenden Datensatz definieren
tempfile diff
postfile coefs str2 iso3166_2 str10 dataset str10 strat b using `diff', replace



// Get Data
foreach dataset in issp02 cress02_01 {
	use ///
	iso3166_2 donate ///
	dataset hhinc edu emp ///
	using `dataset', clear

	//Dummys der Statifizierungsvariablen bilden
	tab hhinc, gen(hhinc)
	tab edu, gen(edu)
	tab emp, gen(emp)


	//Differenzen by country 
	levelsof iso3166_2, local(K)
	foreach k of local K {
	if "`dataset'" != "cress02_01" | "`k'" != "CH" {
	if "`dataset'" != "cress02_01" | "`k'" != "CZ" {
		reg donate hhinc2-hhinc5 if iso3166_2 == "`k'" 
		post coefs ("`k'") ("`dataset'") ("hhinc") (_b[hhinc5])
		reg donate edu2 edu3 if iso3166_2 == "`k'" 
		post coefs ("`k'") ("`dataset'") ("edu") (_b[edu3])
		reg donate emp1 emp3-emp5 if iso3166_2 == "`k'" 
		post coefs ("`k'") ("`dataset'") ("emp") (_b[emp1])
				   }
  								        }
                                                        }
						 }
					  

postclose coefs

use `diff', replace




			   
					  




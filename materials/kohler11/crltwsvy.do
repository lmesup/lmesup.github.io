// Landtagswahl-Metadatensatz
// thewes@wzb.eu

version 10
set more off


// Input
//-------
infile zanr year str244 titel str244 state str244 eldatestr str244 lastnestr ///
str244 nextnestr str244 researcher str244 data str244 method using ltwsvy.raw, clear

// Datumsumrechnung
//------------------
gen eldate = date(eldatestr, "DMY")
gen lastne = date(lastnestr, "DMY")
gen nextne = date(nextnestr, "DMY")

format %tddd_Mon_YY eldate
format %tddd_Mon_YY lastne
format %tddd_Mon_YY nextne

lab var eldate "Election date"
lab var eldatestr "Election date (string)"
lab var lastne "last national Election date"
lab var nextne "next national Election date"


drop year 
drop lastnestr
drop nextnestr

// Area-Rekodierung
//------------------
gen area = "BE" if trim(state) == "Berlin"
replace area = "BB" if trim(state) == "Brandenburg"
replace area = "BW" if trim(state) == "Baden-Württemberg"
replace area = "BY" if trim(state) == "Bayern"
replace area = "HB" if trim(state) == "Bremen"
replace area = "HE" if trim(state) == "Hessen"
replace area = "HH" if trim(state) == "Hamburg"
replace area = "MV" if trim(state) == "Mecklenburg-Vorpommern"
replace area = "NI" if trim(state) == "Niedersachsen"
replace area = "NW" if trim(state) == "NRW"
replace area = "RP" if trim(state) == "Rheinland-Pfalz"
replace area = "SH" if trim(state) == "Schleswig-Holstein"
replace area = "SL" if trim(state) == "Saarland"
replace area = "SN" if trim(state) == "Sachsen"
replace area = "ST" if trim(state) == "Sachsen-Anhalt"
replace area = "TH" if trim(state) == "Thüringen"
lab var area "Area"

// Unit-ID
//---------
gen unitid = area + " (" + string(eldate,"%tdMon_YY") + ")"
lab var unitid "Unit of analysis"

// VarLabels
//-----------
lab var zanr "ZA-Nr."
lab var titel "Titel"
lab var state "State"
lab var researcher "Primary Researcher"
lab var data "Data Collecting"
lab var method "Data Collecting Method"


order unitid area eldatestr eldate  ///
  zanr state titel ///
  lastne nextne ///
  researcher data method

compress
save ltwsvy, replace


exit

* Interaktionseffekte Polint X Neuer Lebenspartner

clear
set memory 60m
set matsize 800
version 7.0
set more off


* Lade Ergebnisdatensatz
* ----------------------

capture use uv b* using pidlv7
if _rc ~= 0 {
	* Ergebnisdatensatz muss erst erstellt werden
	* (Dies benoetigt einige Zeit, moeglicherweise mehrere Tage)
	anal anpidlv7
	use uv b* pidlv7, clear
}


* Jeder zweite Koeffizient ist ein Interaktionsterm
* -------------------------------------------------

gen ia = (_n/2 - int(_n/2)) ~= 0
replace ia = 2 if ia == 0


* Erzeuge Effekte für Polit. Interesse == 4 nach 3 Jahren
* -------------------------------------------------------

gen koef = round(_n,2)
reshape wide b* uv, j(ia) i(koef)
for any bspd1 bcdu1 bb901: replace X1 = (1+ln(3)) * X1
for any bspd1 bcdu1 bb901:  /*
*/ replace X2 = ((1+ln(3)) * X1) + (4 * (1 + ln(3)) * X2)
reshape long


* Sorge fuer angemessene Label
* ----------------------------

gen str20 label = "SPD-Partner" if substr(uv,2,6) == "parspd"
replace label = "CDU-Partner" if substr(uv,2,6) == "parcdu"
replace label = "B90-Partner" if substr(uv,2,6) == "parb90"

gen select = koef if koef >= 44 & koef <= 46

lab var ia "Politisches Interesse"
lab val ia ia
lab def ia 1 "Keins" 2 "s. hoch"

* Sorge fuer angemessene Linientypen
* ----------------------------------

separate bspd1, by(select)
separate bcdu1, by(select)
separate bb901, by(select)

* Variable fuer Datenlabel
* ------------------------

gen labspd = bspd1 if ia == 1
lab var labspd " "
gen labcdu = bcdu1 if ia == 1
lab var labcdu " "

* Loeschen einiger Achsenbeschriftungen
* -------------------------------------

for var bcdu144-bcdu146 bb90144-bb90146: gen Xn=X
for var b*n: lab val X nolab
lab def nolab 0 " "


* Grafiken
* --------
	

capture program drop pidlv12
program define pidlv12
	gph open, saving(pidlv12, replace)

		* common options
		* --------------

		local opt `"key1(" ") yline(0) border s(ii[label]) "' 
        local opt `" `opt' pen(221) gap(2) yscale(-2.0,2.0)"'
		local opt `"`opt' ytick(-2.0(.5)2.0) xlab(1,2) psize(150) "'
		local opt `"`opt' b2(" ") xscale(.8,2.2) t1(" ") trim(14) "'
		sort select ia

		graph bspd144-bspd146 labspd ia if select ~= ., /*
		*/ c(L[.#]L[_#].) `opt' ylab(-2.0(.5)2.0)  /*
        */ bbox(0,0,23063,16500,900,450,0) t2(SPD-Modell)
 	
		graph bcdu144n-bcdu146n labcdu ia if select ~= ., /*
		*/ c(L[.#]L[_#].) `opt' ylab(0)   /*
		*/ bbox(0,15500,23063,32000,900,450,0) t2(CDU/FDP-Modell)

		gph pen 1
		gph font 500 250
		gph text 22800 16500 0 0 Politisches Interesse

		 
	gph close
end

pidlv12

exit


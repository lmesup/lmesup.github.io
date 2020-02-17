* Interaktionseffekte Polint X Aging-Cons + Ad-Hoc-Hypothese
* auf B90-Präferenz

clear
set memory 60m
set matsize 800
version 7.0
set more off


* Lade Ergebnisdatensatz
* ----------------------

capture use uv b* using pidlv5
if _rc ~= 0 {
	* Ergebnisdatensatz muss erst erstellt werden
	* (Dies benoetigt einige Zeit, moeglicherweise mehrere Tage)
	anal anpidlv5
	use uv b* pidlv5, clear
}


* Jeder zweite Koeffizient ist ein Interaktionsterm
* -------------------------------------------------

gen ia = (_n/2 - int(_n/2)) ~= 0
replace ia = 2 if ia == 0


* Erzeuge effekte für Polit. Interesse == 4
* -----------------------------------------

gen koef = round(_n,2)
reshape wide b* uv, j(ia) i(koef)
for any bb901: replace X2 = X1 + (4 * X2)
reshape long


* Sorge fuer angemessene Label
* ----------------------------

gen str20 label = "Schulabs." if substr(uv,2,6) == "aschul"
replace label = "Hochschulabs." if substr(uv,2,6) == "hschul"
replace label = "Berufsausb." if substr(uv,2,6) == "bschul"
replace label = "Beginn Erwerbsl." if substr(uv,2,6) == "bstart"
replace label = "Hochzeit" if substr(uv,2,5) == "hoch1"
replace label = "1. Kind" if substr(uv,2,5) == "kind1"
replace label = "weit. Kinder" if substr(uv,2,5) == "kind2"
replace label = "Studium" if substr(uv,2,3) == "uni"

gen select = koef if (koef >= 30 & koef <= 42) | koef == 50

lab var ia "Politisches Interesse"
lab val ia ia
lab def ia 1 "Keins" 2 "s. hoch"

* Sorge fuer angemessene Linientypen
* ----------------------------------

separate bb901, by(select)

* Variable fuer Datenlabel
* ------------------------

gen labb90 = bb901 if ia == 2 
lab var labb90 " "

* Loeschen einiger Achsenbeschriftungen
* -------------------------------------

*for var bcdu130-bcdu142 bb90130-bb90142: gen Xn=X
*for var b*n: lab val X nolab
*lab def nolab 0 " "


* Grafik
* --------
	
capture program drop pidlv8
program define pidlv8
	gph open, saving(pidlv8, replace)

		* common options
		* --------------

		local opt `"key1(" ") yline(0) border s(iiiiiiii[label]) "' 
        local opt `" `opt' pen(222222221) gap(3) yscale(-1.25,1.25)"'
		local opt `"`opt' ytick(-1.2(.6)1.2) xlab(1,2) psize(150) "'
		local opt `"`opt' b2(" ") xscale(.8,2.2) t1(" ") trim(14) "'
		sort select ia

		graph bb90130-bb90142 bb90150 labb90 ia if select ~= ., /*
		*/ c(L[.#]L[_#]L[-]L[-.]L[l]L[_..]L[-#_]L.) `opt' ylab(0)   /*
		*/ bbox(0,20000,23063,32000,900,450,0) t2(B90-Modell)

		gph pen 1
		gph font 500 250
		gph text 22800 16500 0 0 Politisches Interesse
		 
	gph close
end

pidlv8

exit


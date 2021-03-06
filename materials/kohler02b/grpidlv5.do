* Interaktionseffekte Polint X Aging-Cons
* auf B90-Pr�ferenz

clear
set memory 60m
set matsize 800
version 7.0
set more off


* Lade Ergebnisdatensatz
* ----------------------

capture use uv b* using pidlv4
if _rc ~= 0 {
	* Ergebnisdatensatz muss erst erstellt werden
	* (Dies benoetigt einige Zeit, moeglicherweise mehrere Tage)
	anal anpidlv4
	use uv b* pidlv4, clear
}


* Jeder zweite Koeffizient ist ein Interaktionsterm
* -------------------------------------------------

gen ia = (_n/2 - int(_n/2)) ~= 0
replace ia = 2 if ia == 0


* Erzeuge effekte f�r Polit. Interesse == 4
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

gen select = koef if koef >= 30 & koef <= 42

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

* Variable fuer Datenlabel
* ------------------------

preserve
gen labb90 = bb901 if ia == 2
replace labb90 = labb90 - .1 if label=="1. Kind"
replace ia = ia + .2 if label=="1. Kind"
replace labb90 = labb90 -  .1 if label=="Hochschulabs."
replace labb90 = labb90 -  .1 if label=="Berufsausb."
replace labb90 = labb90 -  .1 if label=="Schulabs."
replace ia = ia + .2 if label=="Hochzeit"
lab var labb90 " "
keep labb90 ia label select
save _u, replace
restore
append using _u
erase _u.dta


* Loeschen einiger Achsenbeschriftungen
* -------------------------------------

for var bcdu130-bcdu142 bb90130-bb90142: gen Xn=X
for var b*n: lab val X nolab
lab def nolab 0 " "


* Grafiken
* --------
	

capture program drop pidlv5
program define pidlv5
	gph open, saving(pidlv5, replace)

		* common options
		* --------------

		local opt `"key1(" ") yline(0) border s(iiiiiii[label]) "' 
                local opt `" `opt' gap(3) yscale(-1.3,1.3) "'
		local opt `"`opt' ytick(-1.2(.6)1.2) xlab(1,2) psize(150) "'
		local opt `"`opt' b2(" ") t1(" ") trim(14) "'
		sort select ia

		graph bspd130-bspd142 ia if select ~= ., pen(2222222)/*
		*/ c(L[.#]L[_#]L[-]L[-.]L[l]L[_..]L[-#_].) `opt' ylab(-1.2(.6)1.2)  /*
                */ bbox(0,0,23063,11500,900,450,0) t2(SPD-Modell) xscale(0.8,2.2)
 	
		graph bcdu130n-bcdu142n ia if select ~= ., pen(2222222)/*
		*/ c(L[.#]L[_#]L[-]L[-.]L[l]L[_..]L[-#_].) `opt' ylab(0)   /*
		*/ bbox(0,10500,23063,22000,900,450,0) t2(CDU/FDP-Modell) xscale(0.8,2.2)

		graph bb90130n-bb90142n labb90 ia if select ~= ., pen(22222221)/*
		*/ c(L[.#]L[_#]L[-]L[-.]L[l]L[_..]L[-#_].) `opt' ylab(0)   /*
		*/ bbox(0,20000,23063,32000,900,450,0) t2(B90-Modell) xscale(0.8,2.4)

		gph pen 1
		gph font 500 250
		gph text 22800 16500 0 0 Politisches Interesse
		 
	gph close
end

pidlv5

exit


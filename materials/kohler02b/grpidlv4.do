* Interaktionseffekte Polint X Wechsel Klassenposition
* auf SPD und CDU Präferenz

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


* Erzeuge effekte für Polit. Interesse == 4
* -----------------------------------------

gen koef = round(_n,2)
reshape wide b* uv, j(ia) i(koef)
for any bspd1 bcdu1 bb901: replace X2 = X1 + (4 * X2)
reshape long

* Sorge fuer angemessene Label
* ----------------------------

gen origin = 1 if substr(uv,2,3) == "sel"
replace origin = 2 if substr(uv,2,3) == "adm"
replace origin = 3 if substr(uv,2,3) == "mis"
replace origin = 4 if substr(uv,2,3) == "arb"
lab var origin "Herkunftsklasse"
lab val origin class
lab def class 1 "Selb." 2 "Adm.D." 3 "Mischt./Exp." 4 "Arb./Soz.D."

gen destin = 1 if substr(uv,5,3) == "sel"
replace destin = 2 if substr(uv,5,3) == "adm"
replace destin = 3 if substr(uv,5,3) == "mis"
replace destin = 4 if substr(uv,5,3) == "arb"
lab var destin "Zielklasse"
lab val destin class

lab var ia "Politisches Interesse"
lab val ia ia
lab def ia 1 "Keins" 2 "s. hoch"

* Sorge fuer angemessene Linientypen
* ----------------------------------

separate bspd, by(origin)
separate bcdu, by(origin)

* Variable fuer Datenlabel
* ------------------------

preserve
replace ia = 2.1 if ia==2
gen labcdu = bcdu1 if ia == float(2.1)
lab var labcdu " "
gen labspd = bspd1 if ia == float(2.1)
lab var labspd " "
keep labcdu labspd orig ia dest
save _u, replace
restore
append using _u
erase _u.dta


* Teilweises Loeschen der Achsenbeschriftungen
* --------------------------------------------

for var bspd11-bspd14 bcdu11-bcdu14: gen Xnl=X
for var *nl: lab val X nolab
lab def nolab 0 " "

gen xnolab = ia
lab val xnolab xnolab
lab def xnolab 1 " " 2 " "

* Grafiken
* --------

capture program drop pidlv4a
	program define pidlv4a
		gph open, saving(pidlv4a, replace)
			
		* common options
		* --------------
		
		local opt `"key1(" ") yline(0) border s(iii[orig]) pen(2222) "'
	    local opt `"`opt' ytick(-1.2(.6)1.2) xlab(1,2) gap(2) "'
	    local opt `"`opt' b2(" ") xscale(1,2.2) t1(" ") psize(150) "'
		sort dest ia
		
		graph bspd12 bspd13 bspd14 labspd xnolab if dest == 1, /*
		*/ c(L[.#]L[_#]L[-].) `opt' ylab(-1.2(.6)1.2)  /*
		*/ bbox(0,0,11500,16500,700,350,0) t2("Wechsel zu Selbstaendige")

                replace labspd = labspd - .2 if dest==2 & origin==  3
                graph bspd11nl bspd13nl bspd14nl labspd xnolab if dest == 2, /*
		*/ c(L[l]L[_#]L[-].) `opt' ylab(0)  /*
		*/ bbox(0,15500,11500,32000,700,350,0) t2("Wechsel zu Admin. Dienste")

                graph bspd11 bspd12 bspd14 labspd ia if dest == 3, /*
		*/ c(L[l]L[.#]L[-].) `opt'  ylab(-1.2(.6)1.2) /*
		*/ bbox(11000,0,22500,16500,700,350,0) t2("Wechsel zu Mischt./Experte")

		graph bspd11nl bspd12nl bspd13nl labspd ia if dest == 4, /*
		*/ c(L[l]L[.#]L[_#].) `opt' ylab(0) /*
		*/ bbox(11000,15500,22500,32000,700,350,0) t2("Wechsel zu Arbeiter/Soz. Dienste")
		
		gph pen 1
		gph font 500 250
		gph text 22800 16500 0 0 Politisches Interesse
		
	gph close
end
pidlv4a


capture program drop pidlv4b
	program define pidlv4b
		gph open, saving(pidlv4b, replace)
			
		* common options
		* --------------
		
		local opt `"key1(" ") yline(0) border s(iii[orig]) pen(2222) "'
	    local opt `"`opt' ytick(-1.2(.6)1.2) xlab(1,2) gap(2) psize(150) "'
	    local opt `"`opt' b2(" ") xscale(1,2.2) t1(" ") "'
		sort dest ia
		
		graph bcdu12 bcdu13 bcdu14 labcdu xnolab if dest == 1, /*
		*/ c(L[.#]L[_#]L[-].) `opt' ylab(-1.2(.6)1.2)  /*
		*/ bbox(0,0,11500,16500,700,350,0) t2("Wechsel zu Selbstaendige")

		graph bcdu11nl bcdu13nl bcdu14nl labcdu xnolab if dest == 2, /*
		*/ c(L[l]L[_#]L[-].) `opt' ylab(0)  /*
		*/ bbox(0,15500,11500,32000,700,350,0) t2("Wechsel zu Admin. Dienste")

		graph bcdu11 bcdu12 bcdu14 labcdu ia if dest == 3, /*
		*/ c(L[l]L[.#]L[-].) `opt'  ylab(-1.2(.6)1.2) /*
		*/ bbox(11000,0,22500,16500,700,350,0) t2("Wechsel zu Mischt./Experte")

		graph bcdu11nl bcdu12nl bcdu13nl labcdu ia if dest == 4, /*
		*/ c(L[l]L[.#]L[_#].) `opt' ylab(0) /*
		*/ bbox(11000,15500,22500,32000,700,350,0) t2("Wechsel zu Arbeiter/Soz. Dienste")
		
		gph pen 1
		gph font 500 250
		gph text 22800 16500 0 0 Politisches Interesse
		
	gph close
end
pidlv4b




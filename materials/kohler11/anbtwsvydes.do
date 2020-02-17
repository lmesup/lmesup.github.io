// Landtagswahl-Metadatensatz
// kohler@wzb.eu

version 10
set more off

use btwsurvey, clear

by eldate zanr, sort: gen n = _N
by eldate zanr, sort: keep if _n==1

format %tddd_Mon start end
format %tddd_Month_CCYY eldate

capture erase anbtwsvydes.tex
levelsof eldate, local(E)
foreach e of local E {
	listtex zanr name sampdes start end n   ///
	  if eldate == `e' , rstyle(tabular) 	///
	  headlines("\multicolumn{6}{l}{\emph{Election day `=string(`e', "%tddd_Month_CCYY")'}} \\") ///
	  appendto(anbtwsvydes.tex) ///
	  end("\\")
}

exit

 

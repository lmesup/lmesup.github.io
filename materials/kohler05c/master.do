* Statusinkonsistenz und Enstrukturierung von Lebenslagen
* Creator: kohler@wz-berlin.de

* NOTE: Vorangegangene Analysen im Ordner indi04/analysen

* EDIT-SECTION
* ------------

* Please set global makro $dublin to the EQLS-Diretory

global dublin "~/data/dublin"

* INTRO 
* -----
	
version 8.0
clear
set more off
set memory 32m

do crresultset0           // Initialize Result-Set (Country-Data)
do crplurality            // Enogenity/Diversity/Devinace 
do SEentropy              // Bootstrap für Entropy -> writes to SEentropy.dta
do SEdeviance             // Bootstrap für Devianz -> writes to SEdeviance.dta
do crplurality_ci         // Merge CI to plurality Results-Set
do grplurality_by_country // Plurality by Country-Graph
do grplurality_by_GDP     // Plurality by GDP-Graph
do anplurality_by_GDP     // Plurality by GDP-Regression
do crplurality_ci_b       // Adds Class Coefs to Result-Set
do grclass_by_GDP         // LOWESS-Curves of b-coeff by GDP
do anclass_by_GDP         // Regression Modell with class-GDP-Interaction
do grGDP_by_country       // Graph GDP by Country 
do anGDP                  // Some numbers for the text
do anplurality_by_GDP2    // anplurality_by_GDP getrennt für Ländergruppen
do grclass_by_GDP2        // grclass_by_GDP mit Referenzgr. Dienstkl. 1
do anclass_by_GDP2        // anclass_by_GDP mit Referenzgr. Dienstkl. 1
do grclass_by_GDP3        // grclass_by_GDP mit Referenzgr. un- und angel. Arb.
do anclass_by_GDP3        // anclass_by_GDP mit Referenzgr. un- und angel. Arb.

// Color-Graphics for Slide-Presentations
do grclass_by_GDP3_fol        // grclass_by_GDP mit Referenzgr. un- und angel. Arb.
do grplurality_by_country_fol // Plurality by Country-Graph
do grplurality_by_GDP_fol     // Plurality by GDP-Graph
do grGDP_by_country_fol       // Graph GDP by Country 

// Double-Checks
do anr2diff_by_GDP    // R2-Differences of Class by GDP
do anclass_by_GDP_noedu  // No Education-Control

// Rework after KZfSS-Review
// -------------------------

do crplurality_ci_b2  // "Lebenslagen" als AV
do grclass_by_GDP4        // grclass_by_GDP mit Referenzgr. un- und angel. Arb.
do anclass_by_GDP4        // anclass_by_GDP mit Referenzgr. un- und angel. Arb.


	
exit
	
	
	
	


	

	
	
	


	


	

	


	

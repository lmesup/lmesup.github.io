// Landtagswahl-LaTeX-Output
// thewes@wzb.eu

version 10
set more off

use ltwsvy, clear

// LaTeX-Output
//--------------

sort area eldate 

gen election = area + " (" + string(eldate,"%dNN/CCYY") + ")" 

listtex election zanr titel method n using anltwsvydes.tex  ///
  , rstyle(tabular) replace ///
  end("\\")  



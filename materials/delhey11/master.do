// Delhey/Kohler "IEFF-corrected standard deviations"
// -------------------------------------------------

* do wvs5_inequality.do // Pre-Work by Jan Delhey
do ansimulation // Simulation Study
do anwvsieff    // Analysis of IEFF-corrected standard deviations

// Post Social Science Research Reviews
do annormal      // Checks for Normality assumption
do anwvsmaxd     // SD devided my maxSD
do anwvsieff2    // Analysis using both corrections
do ansimulation2 // ansimulation with reduced set of figures
do grmaxsd       // Figure of functions for max-SD correction
do ankalmijn     // Re-Analysis Kalmijns distributions using max-SD
do anwvsieff3    // Analysis including producint a table for rank-changes

// Copy figures 1st submission
// ---------------------------

copy anwvsieff_lsatsdbymean.eps ../figure1.eps, replace
copy ansimulation_setup.eps ../figure2.eps, replace
copy ansimulation_11scale.eps ../figure3.eps, replace
copy ansimulation_7scale.eps ../figure4.eps, replace
copy ansimulation_4scale.eps ../figure5.eps, replace
copy anwvsieff_lsatcorrbymean.eps ../figure6.eps, replace
copy anwvsieff_lsatrankchg.eps ../figure7.eps, replace
copy anwvsieff_lsatbygini.eps ../figure8.eps, replace









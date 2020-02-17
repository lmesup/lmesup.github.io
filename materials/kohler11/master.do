// Nichtwähler-Induzierte Zäsuren der Bundesrepublik Deutschland

clear
do crbtw         	// Data set of BTW
do crltw         	// Data set of LTW
do crltwseats    	// Seats in Landestag
do crelections   	// Joint Data set of elections
do crbtwsurvey   	// Survey election data for BTW
do anseats       	// Distribution of seats in BTW (checking the program)
do crltwsurvey   	// Survey election data for LTW (thewes@wzb.eu)
do anseats1976   	// Hypothetical distribution of seats 
do anparameters  	// L,G,NoP, for BTW and LTW
*do anbrpotential 	// Potential power of state elections
do anlr          	// Left-right by voteing
do crltwsvy      	// Meta-Daten Landtagswahl-Survey (thewes@wzb.eu)
do anltwsvydes   	// Dokumentation of datasets (thewes@wzb.eu)
do anbtwsvydes   	// Dokumentation of BTW datasets

// Starting a fork for participation_model
do crpopweights  	// Population weights from state electorates
do grindeps      	// Independent variables by election date
do anmfit        	// Count r^2 for regression models
do anmpred1      	// Predicted values and CI (for average non-voter)
do anmpred2      	// Bootstraped Predicted values
do grbehavdiff   	// Difference between Voters and Non-voters
do grseatshat    	// Change in seats per party 
do grgallagher   	// Gallagher Index
do angovchange   	// Probability of government change

// Return to Nichtwähler-Induziert Zäsuren der Bundesrepublik Deutschland
do anmpredltw	   	// Version of anmpred2.do for LTW 
do grbehavdiff_ltw	// Difference between Voters and Non-voters (LTW)
do grseatshat_ltw	// Change in seats per party (LTW)
do grgallagher_ltw	// Gallagher Index (LTW)
do angovchange_ltw	// Probability of government change (LTW)

// Update analysis for 2009 election (ES Resubmission)

// Reviewer 1: Update to 2009 elections
do crbtw         	// Data set of BTW (updated to 2009)
do crltw         	// Data set of LTW 
do crltwseats    	// Seats in Landestag
do crelections   	// Joint Data set of elections (updated to 2009)
do crpopweights  	// Population weights (rerun file with updated btw.dta)
do crbtwsurvey2     // Survey election data for BTW (updated to 2009)
do grindeps2      	// Independent variables by election date
do anmfit2        	// Count r^2 for regression models
do anmpred22      	// Bootstraped Predicted values
do grbehavdiff2  	// Difference between Voters and Non-voters
do grseatshat2   	// Change in seats per party 
do grgallagher2   	// Gallagher Index
do angovchange2   	// Probability of government change

// Reviewer 1: Check variabilty with T^Max
do grseatshat_100  	// Change in seats per party (T^Max = 100)
do grgallagher_100 	// Gallagher Index (T^Max = 100)
do angovchange_100 	// Probability of government change (T^Max = 100)

// Reviewer 1: Applying apportionment for district Voting '49 and '53
do anbtw49          // Check-out district voting of 1949
do anbtw53          // Check-out district voting of 1953
do anmpred23      	// Bootstraped Predicted values
do crseats          // Apportionment using anmpred23_bs.dta
do grseatshat3   	// Change in seats per party 
do grgallagher3   	// Gallagher Index
do angovchange3   	// Probability of government change
do angovchange_by_tmax // Check variablity of results by T^Max








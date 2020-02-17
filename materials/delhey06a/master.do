	// master.do

	// Edit to fit you local environment
	global wfs "~/data/wfs"  // Welfare Survey 1998 Directory
	global em "~/data/em"   // EuroModul Directory

	// ADO-INSTALLATION 
	// ----------------
	
	// This autmatically installs Cool-Ados over the internet. Obviously
	// your computer needs a connection to the internet for this.  If this
	// is not the case, you need to uncomment this section and to install
	// the Ados by hand (see Kohler/Kreuter (2005))

	capture which estout
	if _rc ~= 0 {
		ssc intall estout
	}

	capture which _gxtile
	if _rc ~= 0 {
		ssc intall _gxtile
	}

	
	do crdata01   // Produces initial Version of Main-Dataset
	do anreg1     // Regressions of Live-Satisfaction on Reference-Groups
	erase data01.dta
	do crdata02   // Include Differences Own LC - Own-Countries LC + Original Indicators
	do anreg2     // Revisited anreg1.do: Regression of Live Satisfaction on Reference-Groups
	do anvalid1   // How reasistitic are the evaluations about countries Living Condions.
	do anvalid2   // anvalid1.do for Within-Country Comparisons (neigbors,friends,own country)
	do andiffr    // correlation between difference-measures
	do anmiss1    // Distribution of Missings and number of valid observations
	do anmissHU   // Large non-response fraction in Hungary?
	do anvalid2_1 // anvalid1.do + within-Person-Comparisons
	do anmiss1_1  // anmiss1.do + within Person comparisons
	do anreg2_1   // Revisited anreg2.do: weigted + robust + within-Person-comparisons
	do anregdsat  // anreg2_1, but with democraty satisfaction as dependend
	do anmiss2    // Missing Values by Social groups
	do anlsatex   // Example for lsat-analysis.
	do anlsat01   // Live-Satisfaction on Reference-Groups, weights, robust
	do anlsat02   // anlsat01 with Interactions for Upward Comparisons
	do anlsat03   // anlsat01 with Interactions for Age
	do anlsat04   // anlsat01 with Interactions for Income
	do anlsat05   // anlsat01 with Interactions for Education
	do anaspir01  // Change dependend Variable
	do anlevel01  // Use a level-Score Model for lsat-analysis
	do annocontrols // Use Simple OLS (no Control-Variables)
	do anwithin     // Control for Within Contry Comparisons
	do anstlivsat   // Dependend Variable Satisfaction with Standard of Living

	// Add Deprivation Control to Regression Models
	do crdata03   // Adds Deprivation Index to data02
	do anlsatex1  // Reiterate anlsatex.do with Deprivation
	do anlsat011  // Reiterate anlsat01.do with Deprivation
	do anlsat021  // Reiterate anlsat02.do with Deprivation
	do anlsat031  // Reiterate anlsat03.do with Deprivation
	do anlsat041  // Reiterate anlsat04.do with Deprivation
	do anlsat051  // Reiterate anlsat05.do with Deprivation
	do anaspir011  // Reiterate anaspir01.do with Deprivation
	do anwithin1   // Reiterate anwithin.do with Deprivation
	do anstlivsat1  // Reiterate anstlivsat.do with Deprivation

	// Some Output for the German Version
	do anmiss1D.do // Note: Corretion of horizontal labels for Germany by Hand!
	do anvalid1D.do
	do anvalid2D.do
	do anlsatex1D.do
	do anlsat011D.do // Note: Correctio nof labels for Germany by Hand!


	// Refinements
	do anvalid4.do  // Combine anvalid1.do and anvolid2.do in one Graph
	
		
	
exit

	


	

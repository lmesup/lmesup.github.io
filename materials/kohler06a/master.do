	// WZB-Jahrbuch 2005
	// Creator: kohler@wz-berlin.de
	
	
	// INTRO 
	// -----
	
version 8.2
	clear
	set more off
	set memory 32m
	
	
	// Change this to fit your local environment
	// -----------------------------------------
	
	global dublin "~/data/dublin/"
	
	
	// ADO-INSTALLATION 
	// ----------------
	
	// This autmatically installs Cool-Ados over the internet. Obviously
	// your computer needs a connection to the internet for this.  If this
	// is not the case, you need to uncomment this section and to install
	// the Ados by hand (see Kohler/Kreuter (2001))
	
	capture which mmerge
	if _rc ~= 0 {
		ssc install mmerge 
	}

	
	// Do-Files
	// --------
	
	do crisocntry  // Various Country Name Formats
 	do grturnout // Graph turnout-data
	do crelectsystem // Election-System-Variables (+ Description)
	do anturnout1 // Bivariate Pairwise Correlations Election System - Turnout
	do anturnout2 // Logit-Models for turnout on individual mechanisms.
	do anturnout3 // Logit-Models for country specific turnout inequality (Status)
	do anturnout4 // Logit-Models for country specific turnout inequality (Satisf)
	do anconclusion // Zusammenfassung anturnout3 und anturnout4

	// Rethinking after USI-Presentation
	do anvotstrat // New anturnout3
	do anvotzuf // New anturnout4
	do crelectsystem1 // New crelectsystem1
	do anvotungl // New anconclusion
	do anvoteungl01 // Overall Vote-Inequality on institutional Factors
	do anvotzufvgl  // Compare Zuf-inequality controlled and uncontrolled

	// Redesign after Yearbook-Conference
	do anvotzuf1 // New anvotzuf
	do anvotstrat1 // New anvotestrat
	do crelectsystem2  // New left-right importance definition
	do anvoteungl02 // Dimension Specific Vote-Inequality on institutional Factors

	exit
	
	
	
	
	




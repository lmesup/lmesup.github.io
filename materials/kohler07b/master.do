* Internal Criteria for Representativity for European Comparative Surveys
* -----------------------------------------------------------------------

* Pre-Work published in Alber/Fahey/Saraceno "Social Conditions ..."
* see: ../soccondeu06/

do crsvydat01  // Main Dataset for the "Social Conditons ..." publication
do crsvydat02  // Add ESS 2004 etc. -> New Main Data
do ansvydes    // Short description of Surveys
do ansample    // Sampling-Methods by Country and Survey
do anresp      // Reported Response-Rates Overview
do anpwomen    // Fraction of Women with Confidence Bounds around true-Value
do crsvydat03  // Add thorough response-rate statistics + back-checks
do anQhresp    // Sample-Quality (Q) by harmonized Response Rates
do anQhdi      // Sample-Quality (Q) by Human Development Index
do anQreach    // Sample-Quality (Q) by Male Emplyoment - Female Employment Rate
do anQsample   // Sample-Quality (Q) by Sampling Method
do anQback     // Sample-Quality (Q) by Quality Back Checks
do anQsubst    // Sample-Quality (Q) by Substitutions
do anQsurvey   // Sample-Quality (Q) by Survey
do anQmethod   // Joint Plot of Q by Survey Methodology
do anQctry     // Sample-Quality (Q) by country
do anQrwithin  // Q by within household reachability (EQLS only)
do anQhresmeth // Interaction: Response rate*survey methodology
do anQrwithin1 // Random Route Samples only
do anQreachmeth // Interaction: gender related reachability*survey methodology

// Reanalysis after Review for repraes06_resubmitted, design weights for GB and DE
do crsvydat04   // Add Design weights, Correction of variable sample for AT and PT
do ansample1    // ansample.do with ESS'02 AT correction
do anpwomen2    // Fraction of Women with Confidence Bounds around true-Value
do anBhresp     // Nonresp. Bias (B) by harmonized Response Rates
do anBhdi       // Nonresp. Bias (B) by Human Development Index
do anBreach     // Nonresp. Bias (B) by Male Emplyoment - Female Employment Rate
do anBsample    // Nonresp. Bias (B) by Sampling Method
do anBback      // Nonresp. Bias (B) by Buality Back Checks
do anBsubst     // Nonresp. Bias (B) by Substitutions
do anBsurvey    // Nonresp. Bias (B) by Survey
do anBmethod    // Joint Plot of B by Survey Methodology
do anBctry      // Nonresp. Bias (B) by country
do anBrwithin1  // B by within household reachability (EBLS only)
do anBhresmeth  // Interaction: Response rate*survey methodology
do anBrwithin   // Random Route Samples only
do anBreachmeth // Interaction: gender related reachability*survey methodology

// Translate all EPS files to PDF (Linux only)
	if "$S_OS" == "Unix" {
		!find *.eps -exec epstopdf '{}' ';'
	}




	

,// Political Integration and the Participation of lower classes
// ------------------------------------------------------------

// Presentation for Berlin May 7-8 Conference:
// "The	Attractiveness of the European and American Social Model
// for New Members and Candidate Countries of the European Union"


set more off
do crcses         // CSES 1+2 dataset
do chkcses        // Check inconsistencies in cses01.dta -> see Notes in file
do crissp04       // ISSP 2004 data set similar to CSES-Data
do crissp02       // ISSP 2002 data set simlar to CSES-Data
do cress02        // ESS 2002 data set similar to CSES-Data
do cress04	      // ESS 2004 data set similar to CSES-Data
do creqls03	      // EQLS data set similar to CSES-Data
do crexp	         // Social expenditure, etc. 
do anelectionsystems  // Turnout (official) by election-Systems -> Table 1
do crelectionsystems2 // Create a dataset for electionsystems
do crinclusive        // Indices for Inclusiveness	
do anvoter_valid      // Compares voter turnout with external sources
do anturnout          // Turnout by country (Official sources)   -> Figure 1
do anineq_voter       // Inequality of electoral participation   -> Table 2+3, Figure 3,4
do anineq_ageinteraction_voter // Interaction age*inequality     -> Figure 5	
do anineq_satisfaction // Satisfaction of non-voters             -> Figure 6
do anparticipation_by_country // Various Participation indices by country -> Figure 7
do anparticipation_by_voter // Various Participation indices by country -> Figure 8
do anmedianvoter       // Income Position of the Median-Voter    -> Figure 2

// Changes after Conference
do anturnout1  // Figure 1 with "last three 1st order elections"

// Preparations for Leviathan
do anelectionsystemsDE           // Deutsche Tabelle 1
do anturnout1DE                  // Deutsche Abbildung 1
do anmedianvoterDE               // Deutsche Abbildung 2
do anineq_voterDE                // Deutsche Abbildung 3+4; Tabelle 2+3
do anineq_ageinteraction_voterDE // Deutsche Abbildung 5
do anineq_satisfactionDE         // Deutsche Abbildung 6
do anparticipation_by_countryDE  // Deutsche Abbildung 7
do anparticipation_by_voterDE    // Deutsche Abbildung 8



exit

	



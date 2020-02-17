do cress04
do an1st   // First tries with some multilevel models
do antrade // Multilevel models for trade unions
do antry   // Try out using mlogit as multiple discriminant analysis
do anlrdes // Bivariate correlation of modified lr scale with some indep.
do anvoter_valid // Comparison of survey turnout with official turnout
do grses   // Descriptive graph for bivariate ses-voter relationship
do anagg   // Influences of aggregate level variables
di anbase  // Baseline Models
do anses   // Voteing by SES
do grpol   // Descriptive graph for bivariate pol-voter relationship
do anpol   // Voteing by Political variables
do grlr    // Left-Right by country
do anlrvotechg // Extrapolation, Rose Proposal 12 July
do anchange // Extrapolation: mlogit, Germany
do anexpol1 // Extrapolation, Method 1
do anexpol2 // Extraplation with mlogit, GB and DE
do anexpol4 // Extrapolation with mlogit, DE 1998 and 2005, various assumptions

// Restart after Election Studies volume
do crelections  // Create Election Metadata
do andescribe   // Describe Election Metadata extensivly
do anelectiontable // Table for Election characteristics
do anpol1 // Voting by political variables without trust and politics too complicated
do anpol2 // anpol without satisfactio with government
do grlevbycntry // Graph voteing and Leverage by country -> figure 2
do anlr // Left-Right figures and tables -> figure 4 (discussion paper)
do anlr_by_voteing // Left-Right by voters/nonvoters -> table 1
do grturnout_by_country // -> figure 1
do grpartynum           // -> figure 3
do simulation           // -> figure B

// Revision after ES - review
do crelections2   // Add Electionsystem to Election Metadata
do cress04_1      // Use edition 3 of ESS
do ansumtab       // A comprehensive table
do aninvalid      // Plot of invalid votes by turnout
do anct           // Quantify the critical treshold
do anct1          // Quantify the critical treshold, correction 1
do ansumfig       // A comprehensive figure
do anUSbystate    // Turnout by gap & Probability of Office-Change
do anUS2000       // A table for US 2000 election
do anct2          // Correction 2 -- Using absolut numbers
do anlr_by_voteing1 // Run this for edition 3 of ESS

! cp grturnout_by_country_1.eps ../figure1.eps
! cp grlevbycntry_1.eps         ../figure2.eps
! cp grpartynum.eps            ../figure3.eps
! cp anlr_by_voteing1_EUgraph.eps ../figure4.eps

// Revision after ES - reject
do anct3          // Critical treshold with Plutzer assumptions (Buggy)
do anct4          // -> figure 6
do grturnout_by_country1 // -> figure 1
do grlevbycntry1 //  -> figure 2
do grpartynum1    // -> figure 3
do anlr_by_voteing2 // figure 4
do grgap          // -> figure 5

! cp grturnout_by_country1_1.eps ../ejprfig1.eps
! cp grlevbycntry1_1.eps         ../ejprfig2.eps
! cp grpartynum1.eps             ../ejprfig3.eps
! cp anlr_by_voteing2_EUgraph.eps ../ejprfig4.eps
! cp grgap.eps ../ejprfig5.eps
! cp anct4.eps ../ejprfig6.eps   

// Reorganizing for 2nd EJPR-Submission
do anct5          
! cp grturnout_by_country1_1.eps ../ejprfig1.eps
! cp grlevbycntry1_1.eps         ../ejprfig2.eps
! cp grpartynum1.eps             ../ejprfig3.eps
! cp grgap.eps ../ejprfig4.eps
! cp anct5.eps ../ejprfig5.eps   

// Figures for Representation-Submission
do grturnout_by_country2 // -> figure 1
do grlevbycntry2 //  -> figure 2
do grpartynum2    // -> figure 3
do grgap1          // -> figure 5
do anct6         // -> figure 6

! cp grturnout_by_country2_1.eps represfig1.eps
! cp grlevbycntry2_1.eps         represfig2.eps
! cp grpartynum2.eps             represfig3.eps
! cp grgap1.eps represfig4.eps
! cp anct6.eps represfig5.eps   

!gs -sPAPERSIZE=a4 -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE=../figures.pdf -dBATCH represfig1.eps represfig2.eps represfig3.eps represfig4.eps represfig5.eps


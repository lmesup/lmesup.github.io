// Armutsrisiken von Arbeitslosigkeit, Krankheit, Scheidung und Alter
// ------------------------------------------------------------------

version 11
set memory 200m

do crjoined  // Zusammenführen der Datensätze von Ehlert, Kohler, Radenacker
do anpoor1   // Anteil Armer vor und Nach Ereignis
do anpoor_gender // Anteil Armer vor und Nach Ereignis nach Geschlecht
do anpoor_edu   // Anteil Armer vor und Nach Ereignis nach Bildung
do anpoor_time   // Anteil Armer vor und Nach Ereignis nach Zeit
do anmeasures   // Measures of poorness and data base

do crjoined2      // Ohne Imputation der fehlenden PSID Jahre
do anpoor2        // anpoor1 using joined2.dta
do anpoor_gender2 // anpoor_gender using joined2.dta
do anpoor_edu2    //  anpoor_edu using joined2.dta
do anpoor_time2   // anpoor_time using joined2.dta

do anmeasures2  // anmeasures using joined2.dta

do crjoined3     // Neue Definition von Trennung
do anpoor3       // Trennung entfernt
do anmeasures3   // Trennung entfernt

// Preparations for presentation in Cologne
do anpoor4         // With control group
do anpoor_gender4  // anpoor_gender with control group
do anpoor_edu4     //  anpoor_edu with control group
do anpoor_time4    // anpoor_time with control group

// Prepartions for KZFSS-Submission
do crDE            // Create German data
do crUS            // Create American data
do greventcount    // Frequency of events
do grkontext       // Description of context
do andid_bycntry   // DID by Country 
do andid_bygroups  // DID by Country and Groups
do andid_bytime    // DID by Country and Time
do grpoorness      // Percentage of Persons being poor
do anreemployment  // Reemployment probabilities
do grcomposition   // Composition of Treatment + Control group
do andid_bycntry1   // DID by Country (Correction)
do andid_bytime1    // DID by Country and Time (Correction)
do grcomposition1   // Independend Scale for Germany and the US





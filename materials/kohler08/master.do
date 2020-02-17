* Internal Criteria for Representativity for European Comparative Surveys


* Pre-work by luniak@wz-berlin.de
	do resultset1  // Anteil Frauen - hart (ESS,EQLS) / weich (ESS,EQLS,ISSP,EVS,EM)
	do resultset2  // Anteil Frauen +  SE, Konfidenzintervall, Ranking + Graphiken
	do resultset3  // Wahrscheinlichkeit P(Frauen) für H0: P(Frauen) = .5
	do cralldat   // Zusammenführung aller Datensätze
	do cralldat2  // alldat.dta mit Sampling-Informationen 
	do crhdata    // Datenbasis für "harte Analysen"
	do crwdata    // Datenbasis für "weiche Analysen"
	do resultset5 // weiche Analyse: Stadt-Land
	do resultset6 // harte Analyse: Stadt-Land
	do resultset7 // weiche Analyse: Einkommen
	do resultset8 // harte  Analyse: Einkommen
	do resultest9 // weiche Analyse: Frauenanteil nach Quota 0/1

* Analysen von kohler@wz-berlin.de
	erase alldat.dta
	erase alldat2.dta
	erase hdata.dta
	erase wdata.dta

	do crsvydat01 // Datasets + Aggregates from EQLS + SVY-Descriptions
	do ansvydes01 // Short description of Surveys
	do anpwomen01 // Fraction of Women with Confidence Bounds around true-Value
	do ant01      // t by survey-characteristics
	do ant02      // t by survey-characteristics (without mode of collection)
	do anclogit01 // Conditional Logit Analysis for context-characteristcs
	do ant03      // t by context-characteristics
	do ansubgroup02 // A Description of the Gender homogenous Couples
	do ansvydes02  // Shorter description than ansvydes01
	do ansample01  // Information about Sampling-Methods
	do ansample02  // Sampling-Methods by Country and Survey
	do anextern01  // External Criteria of representativity
	do anintern01  // Internal Criteria of representativity
	do ansummary   // Table in a summary (somwhat shortcomming) 

	do ansample02C // colored version of ansample01


	// Redressment after Berlin-Conference
	do anresp01     // Response-Rate Statistics
	do ansample01_1 // without Euromodule
	do ansample02_1 // without Euromodule
	do anextern01_1 // without Euromodule
	do anintern01_1 // without Euromodule
	do ansummary_1  // withoud Euromoude

	
	
	
	

	

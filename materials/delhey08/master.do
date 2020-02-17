	// Delhey/Kohler fuer "Social Conditions in the Enlarged Europe"

	do crdata01  // Create Main Data-Set
	do anmiss    // Fraction of Missings
	do ancomp    // Distribution of Comparison Variables
	do cragg     // Dataset with Aggregates (Source: delhey)
	do anvalid   // Comparison vs. Truth
	do anlsat01  // Regression Life-Satisfaction on Comparison
	do anlsat02  // Regression Life-Satisfaction on Comparison, without financial satisfaction
	do anlsat03  // Comparison of Life-Satisfaction on Quality-of-Life-Comparison with and without control
	do anmanifesto // EU-orientiation of political parties
	do anpolconseq01.do // Political Consequences of Comparisons

	// Preparation for Conference Version
	do anmiss_1    // Fraction of Missings
	do ancomp_1    // Distribution of Comparison Variables
	do anvalid_1   // Comparison vs. Truth
	do anlsat04    // anlsat01 with metric financial situation and graph as in anlsat04
	do anlsat05    // semi-standardised solution of anlsat04


	// Redressment after Confernce
	do anmiss_2     // Fraction of Missings
	do ancomp_2     // Distribution of comparison Variables
	do anvalid_2    // Comparison vs. Truth
	do anwhowrong   // Who is wrong (not used)
	do anlsat06     // Like anlsat04.do, but with 3 comparison variables and estout
	do anwhowrong_2 // Incorp. Delhey's proposal about who is wrong and who not (not used)
	do anwhowrong_3 // Different Graph (not used)
	do anmiss_bygroups // Missings by groups
	
	exit
	

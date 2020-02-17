version 8.2
	
	use ../sum_berlin04/lsat, clear
	
	label define country2 ///
	1 "BU"  2 "CY"  3 "CZ"  4 "ET"  5 "HU"  6 "LV"   7 "LT"  8 "MA"  9 "PO" ///
	10 "RO" 11 "SK" 12 "SI" 13 "TR" 14 "BE" 15 "DK"  16 "DE" 17 "GR" 18 "IT" ///
   19 "SP" 20 "FR" 21 "IE" 23 "LU" 24 "NL" 25 "PT"  26 "UK" 29 "FI" 30 "SE" ///
   31 "AU", modify
	
	label var country2 "Country-Code"
	label var life "Mean Life-Satisfaction"
	label var health "Mean Healt-Satisfaction"
	label var health_system "Mean Satisfaction with Healt-System"
	label var family "Mean Satisfaction with Family Life"
	label var social "Mean Satisfaction with Social Life"
	label var pers_safety "Mean Satisfaction with Personal Safety"
	label var finances "Mean Satisfaction with Financial Situation"
	label var employment "Mean Satisfaction with Employment Situation"
	label var home "Mean Satisfaction with own Home"
	label var neighbourhood "Mean Satisfaction with Neighbourhood"
	label var eu "EU-15"
	
	save lsat, replace
	exit
	

	

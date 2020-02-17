* Empirical implications of individualisation in the age of Europeanisation
* kohler@wz-berlin.de

version 9.2
	clear
	set more off
	set memory 90m
	
	do grsoctypes  // Figure with ideal typical societies
	do aness04_1   // Analysis of ESS 2004 (first approach)
	do aness02_1   // Analysis of ESS 2002 (mirrors aness04_1.do)
    do aness04_2   // Adds weights to aness04_1
    do aness02_2   // Adds weights to aness02_1
	do aness02_3   // Some alternative specifications for 2002
	do aness       // Use models like vendrik/woltjer 2006
	exit
	

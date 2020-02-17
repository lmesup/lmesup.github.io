* Response-Rates
* kohler@wz-berlin.de


* History
* anresp01: Table with response-rates only
* ant02.do: Remove Mode of Collection from Results. Descreptive Table.
* ant01.do: First Version
	
version 9
	
	clear
	
	// Input the reported response rates
	// ---------------------------------

	input str10 survey resrate1 resrate2 resrate3 resrate4
	"EB 62.1" . . . 25
	"EQLS '04"  32.5  58.4  91.2  0
	"ESS '02"   43.09 61.29 79.99 0
	"EVS '99"   15    58.02 95    3
	"ISSP '02"  20    58   99     1
	end
	
	// Reonconstruct the data for Table 
	keep survey resrate1-resrate4
	reshape long resrate, i(survey) j(cat)
	format resrate %3.0f
	
	encode survey, gen(svy)
	drop survey
	reshape wide resrate, j(svy) i(cat)

	tostring cat, replace
	replace cat = "Minimum" if cat == "1" 
	replace cat = "Average" if cat == "2" 
	replace cat = "Maximum" if cat == "3" 
	replace cat = "Missing (num. of countr.)" if cat == "4" 

	// Descreptive Tables
	listtex cat resrate1-resrate5 using anresp01.tex                     ///
	  , type replace missnum("n.a.") rstyle(tabular)                          ///
	  head("\begin{tabular}{lrrrrr} \hline "                             ///
	  "& EB 62.1 & EQLS '03 & ESS '02 & EVS '99 & ISSP '02 \\ \hline ")  ///
	  foot("\hline" "\end{tabular}" )

	exit



	


	
	


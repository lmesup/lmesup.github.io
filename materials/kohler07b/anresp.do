* Overview for reported response-rates
* kohler@wz-berlin.de
* (I know, this is a bit overkilling)
	
version 9

clear

// Input the reported response rates
input str10 survey resrate1 resrate2 resrate3 resrate4
  "EB 62.1"  .  .  . 25
"EQLS 2003" 33 58 91  0
 "ESS 2002" 43 61 80  0
 "ESS 2004" 46 62 79  0
 "EVS 1999" 15 58 95  3
"ISSP 2002" 20 58 99  1
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
listtex cat resrate1-resrate6 using anresp.tex                                       ///
  , type replace missnum("n.a.") rstyle(tabular)                                     ///
  head("\begin{tabular}{lrrrrrr} \hline "                                             ///
  "& EB 62.1 & EQLS 2003 & ESS 2002 & ESS 2002 &  EVS 1999 & ISSP 2002 \\ \hline ")  ///
  foot("\hline" "\end{tabular}" )

exit










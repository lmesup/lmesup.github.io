* Produces a Dataset with Institutional Control Variables
* -------------------------------------------------------

version 7
set more off

clear
input country elecyear electype elecsys socstrength compet
/* slovenia   */   1 1997 2 2  12  1
/* germany    */   2 1998 1 1  5   0
/* hungary    */   3 1998 1 1  35  3
/* spain      */   4 1996 1 2  38  1
/* switzerland */  5 1999 1 2  3   0
/* sweden      */  6 1998 1 2  12  2
end


label value country country 
label define country 1 "slovenia" 2 "germany"  3 "hungary" 4 "spain"  /*
*/ 5 "switzerland"  6 "sweden"

* Year of last Election  (Note 0)
* ---------------------

lab var elecyear "Year of laste Election"

* Type of last Election
* ---------------------

label var electype  "Type of last Election"
label val electype electype
label define electype 1 "Parliament"  2 "President"  

* Electoral System (Note 1)
* -------------------------

label var elecsys  "Electoral System"
label val elecsys elecsys
label define elecsys 1 "MMP"  2 "List PR"

* Strength of Communist/Socialist Parties  (Note 2)
* -------------------------------------------------

label var socstrength "Strength of Socialist/Communist Parties in %"

* Competetiveness  (Note 3)
* -------------------------

label var compet  "Competetiveness"


* Save
* ----

compress
save instcontrol, replace

exit


* Note 0
* ------

Spain had general elecition in March 2000. Fieldwork was in January 2000. 


Note 1
------

List Proportional Representation (List PR): In its most simple form
List PR involves each party presenting a list of candidates to the
electorate, voters vote for a party, and parties receive seats in
proportion to their overall share of the national vote. Winning
candidates are taken from the
lists. (http://www.idea.int/esd/glossary.cfm)


Mixed Member Proportional (MMP): Systems in which a proportion of the
parliament (usually half) is elected from plurality-majority
districts, while the remaining members are chosen from PR lists. Under
MMP the list PR seats compensate for any disproportionality produced
by the district seat results. (http://www.idea.int/esd/glossary.cfm)

Note 2
------

Hungary

MSZP - Hungarian Socialist Party (Magyar Szocialista Párt)
http://www2.essex.ac.uk/elect/database/indexElections.asp?country=HUNGARY&election=hu98

Germany

PDS  http://psephos.adam-carr.net/germany/germany1.txt

Slovenia

ZLSD - (Zdrucena Lista socialnih demokratov) United List of
Social-Democrats http://psephos.adam-carr.net/slovenia/slovenia1.txt

Spain

PSOE - Partido Socialista Obrero Español (Spanish Socialist Workers'
Party) http://psephos.adam-carr.net/spain/spain1996.txt

Sweden
V - Left Party http://psephos.adam-carr.net/sweden/riksdag1.txt 

Swizerland 
Alliance of the Left  http://psephos.adam-carr.net/switzerland/switz2.txt


Note 3
------

Number of changes of the chief executive party
(http://terra.es/personal2/monolith/00index.htm)

Germany: http://terra.es/personal2/monolith/germany.htm
Hungary: http://www.terra.es/personal2/monolith/0g-hun.htm
Sweden:  http://terra.es/personal2/monolith/sweden.htm
Switzerland: http://terra.es/personal2/monolith/0g-swi.htm
Spain: http://terra.es/personal2/monolith/spain.htm
Slovenia: http://terra.es/personal2/monolith/0g-sln.htm


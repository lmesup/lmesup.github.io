	// Check and list inconsistencies in cses01.dta
	// kohler@wzb.eu

	version 9.2
	capture log close
	log using chkcses01, replace
	use cses01, clear
	
	// Constant Data Range over datasets and countries -> Note 1
	chkmin intmen men edu-hhinc church-econchange, by(dataset iso3166_2)
	chkmax intmen men edu-hhinc church-econchange, by(dataset iso3166_2)

	// All value labels defined?
	chklabdef

	// Labeled values observed in all datasets and countries?
	chklabobs

	chklabobs fairelect partcare partneces polknow econdevel econchange ///
	  if dataset == "CSES-MODULE-1" , by(iso3166_2) 

	chklabobs persother campact protest actgroup humrights corruption ///
	  if dataset == "CSES-MODULE-2", by(iso3166_2) 

	chklabobs men age edu emp mar hhinc church rel denom rural ///
	  unionmemb unionmembhh ///
	  voter pi pii leftright democsat ///
	  powmatters votematters polinform , by(dataset iso3166_2)
	// Note: No protestants accepted in Portugal and Espania
	
	// Distributions 

	encode dataset, gen(data)
	chkfreq men data, over(iso3166_2) 
	chkfreq edu data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3))) // Note 0
	chkfreq emp data, over(iso3166_2) legend(cols(1)) byopt(legend(off))
	chkfreq mar data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq hhinc data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq church data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq rel data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq denom data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq rural data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq unionmemb data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq unionmembhh data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq voter data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq contact data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3))) // Note 1
	chkfreq persother, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3))) 
	chkfreq campact, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3))) 
	chkfreq protest, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3))) 
	chkfreq actgroup, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3))) 
	chkfreq pi data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq pii data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq democsat data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq powmatters data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq polinform data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	chkfreq econdevel data, over(iso3166_2) legend(cols(1)) byopt(cols(1) legend(pos(3)))
	log close
	
	
	exit

	Note 0
	------


Lieber Bernhard Wessels, 

ich habe mich mal ein wenig in den CSES Daten umgesehen. Für GB und die 
Schweiz sind mir problematische Verteilungen in der Bildungsvariable 
aufgefallen, d.h. extrem starke Veränderungen in den Besetzungen der 
einzelnen Kategorien (siehe Tabellen unten). 

Wissen Sie an wen man sich hier wenden könnte?

Grüße
Kohler

PS: die im Internet zu den Daten bereitgestellten Patches habe ich bereits 
angewandt. 



CSES I, GB
                              Education |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                   None |          1        0.03        0.03
                     Incomplete Primary |          1        0.03        0.07
                      Primary Completed |          1        0.03        0.10
                   Incomplete Secondary |      1,815       62.65       62.75
                    Secondary Completed |        321       11.08       73.84
                   Post-Secondary Trade |        402       13.88       87.71
University Undergraduate Degree Incompl |         47        1.62       89.33
University Undergraduate Degree Complet |        309       10.67      100.00
----------------------------------------+-----------------------------------
                                  Total |      2,897      100.00


CSES II, GB
                              Education |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                   Incomplete Secondary |        317        9.53        9.53
                    Secondary Completed |        574       17.26       26.79
Post-Secondary Trade / Vocational Schoo |        495       14.88       41.67
University Undergraduate Degree Incompl |        748       22.49       64.16
University Undergraduate Degree Complet |      1,042       31.33       95.49
                                Refused |         18        0.54       96.03
                             Don'T Know |         40        1.20       97.23
                                Missing |         92        2.77      100.00
----------------------------------------+-----------------------------------
                                  Total |      3,326      100.00

      
CSES I, CH
       Cum.
                              Education |      Freq.     Percent 
----------------------------------------+-----------------------
                      Primary Completed |      1,394       68.07
                    Secondary Completed |        153        7.47
                   Post-Secondary Trade |        299       14.60
University Undergraduate Degree Complet |        189        9.23
                                Missing |         13        0.63
----------------------------------------+-----------------------
                                  Total |      2,048      100.00

CSES II, CH
                              Education |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                   None |          3        0.21        0.21
                      Primary Completed |        160       11.28       11.50
                    Secondary Completed |        833       58.74       70.24
Post-Secondary Trade / Vocational Schoo |        264       18.62       88.86
University Undergraduate Degree Complet |        154       10.86       99.72
                                Missing |          4        0.28      100.00
----------------------------------------+-----------------------------------
                                  Total |      1,418      100.00













	

	


	Note 1
	------

	Contact with Politician in past year has gone up very much between
	CSES 1 and 2 in GB and US.

	GB 1997: During the past twelve months, have you had any
	contact with a member of Parliament in any way?

    GB 2005: Over the past five years or so, have you done any of the
    following things to express your views about something the
    government should or should not be doing? -> Contacted a
    politician or government official either in person or in writing,
    or some other way

	USA 1996: During the past twelve months, have you had any
	contact with a member of Congress in any way?

	USA 2004: Over the past five years or so, have you done any of the
	following things to express your views about something the
	government should or should not be doing? -> Contacted a
	politician or government official either in person, or in writing,
	or some other way?


	

* Q by female employment
* kohler@wz-berlin.de

* History
* ant03.do
* ant02.do: Remove Mode of Collection from Results. Descreptive Table.
* ant01.do: First Version
	
version 9
	
	clear
	set memory 80m
	set more off
	set scheme s1mono

	// Female emplyoment-rates
	// -----------------------
	
	use s_cntry emplfem2 seatswom using $dublin/eqls_4, clear
	by s_cntry, sort: keep if _n==1

	input 
	29 62 16.2   // Croatia (see Note 1, below)
	end
	
	sort s_cntry
	input str2 iso3166_2 str3 iso3166_3
	AT AUT
	BE BEL
	BG BGR
	CY CYP
	CZ CZE
	DK DNK
	EE EST
	FI FIN
	FR FRA
	DE DEU
	GB GBR
	GR GRC
	HU HUN
	IE IRL
	IT ITA
	LV LVA
	LT LTU
	LU LUX
	MT MLT
	NL NLD
	PL POL
	RO ROU
	SK SVK
	SI SVN
	ES ESP
	SE SWE
	TR TUR
	PT PRT
	HR HRV 

	keep iso3166* emplfem2
	sort iso3166_2
	tempfile emplfem
	save `emplfem'


	// Merge to svydat
	// ---------------
	
	use svydat03 if eu & sample != 6 & svymeth != 5
	keep if weich == 1
	sort iso3166_2
	merge iso3166_2 using `emplfem'
	assert _merge==3
	drop _merge

	// Q
	collapse (mean) womenp=women emplfem2 (count) N=women, by(survey iso3166_2)
	gen Q = (womenp - .5)/sqrt(.5^2/N)
	sort survey iso3166_2

	tw ///
	  || sc Q emplfem, ms(O) mlc(black) mfc(black)              ///
	  || lowess Q emplfem, lc(black) lp(solid)                  ///
	  || , xtitle(Female Employment Rate) xlabel(#5, grid)      ///
      ytitle("Absolute value of sample bias (|Q|)")                              ///
	  ylab(-3(3)6, grid)                                        ///
	  legend(off)
	graph export anQfempl.eps, replace

exit


	Note 1
	------


\section{Schätzung der Beschäftigtenquote in Kroatien für Frauen zwischen 15 und 65}

Die Daten stammen aus den Human Development Reports der Jahre 2002 und
2003. Die folgenden Daten dienen als Grundlage der Schätzung:

 \begin{enumerate}
     \item Total population (millions): 5
     \item Population under age 15 (\% of total): 16,1
     \item Population age 65 and above (\% of total): 14,1
     \item Life expectancy at birth, female (years): 78,4
     \item Life expectancy at birth, male (years):  71,4
     \item Female economic activity rate (\% ages 15 and above): 48,9
 \end{enumerate}

Der Frauenanteil ($ftl$) in der Population wird anhand der Lebensdauer
	geschätzt:

	\[ ftl = \frac{(4)}{(4)+(5)} = \frac{78,4}{78,4 + 71,4} = 0,523 \]

	Die Anzahl der Frauen (af) in der Population beträgt:

	\[ af = (1)*(ftl) = 5 * 0,523 = 2,615. \]

Unter der Annahme, dass der Anteil der Mädchen und Jungen gleich ist,
wird die Anzahl der unter 15-jährigen Mädchen berechnet (maed):

	\[maed = \frac{(1)\ast(2)}{2} = \frac{5\ast16,1\%}{2} = \frac{0,805}{2}  = 0,4025 \]

Das erlaubt die Schlussfolgerung, dass es in Kroatien $2,2125 mln (f)$
erwachsene \footnote{d.h. über 15} Frauen gibt

	$(f = af - maed =  2,615 - 0,4025)$.

Die Beschäftigungs"ratio" dieser Gruppe ist bekannt und beträgt 48,9\%
(6).  Auf Grundlage dieser Daten ist es möglich die Anzahl der
erwerbstätigen Frauen ($ef$) zu berechnen:

	\[ ef = f \ast (6) = 2,2125 \ast 48,9\% = 1,082 \]

Die Schätzung des Anteils der Frauen, die über 65 sind, basiert auf
der relativen erwarteten Lebensdauer. Im Durchschnitt leben Männer 6,4
und Frauen 13,4 Jahre über das 65te Lebensjahr hinaus. Der Anteil der
Frauen in der ältesten Gruppe (falt) wird wie folgt berechnet:

	\[falt = \frac{13,4}{13,4+6,4} = 0,677 \]

Da die Gesamtpopulation zu 14,1\% (3) aus über 65-jährigen besteht,
wird die Anzahl der Frauen (fralt) in dieser Subpopulation auf $0,477$
mln geschätzt: 

	\[ fralt = (1)\ast(3)\ast falt = 5\ast14,1\%\ast0,677=0,477 \]

Dementsprechend beläuft sich die Anzahl der Frauen, die zwischen 15
und 65 Jahren alt sind ($frauen$) auf $1,7355$mln:

	\[ frauen = f - fralt = 2,2125 - 0,477 = 1,7355 \]

Unter der Annahme, dass Frauen ab dem 65ten Lebensjahr nicht mehr
erwerbstätig sind, wird die Beschäftigungsquote für Frauen zwischen
dem 15. und 65. Lebensjahr auf folgender Weise geschätzt:

	\[ bquote =  \frac{ef}{frauen} = \frac{1,082}{1,7355}= 0,62 \]

	
	


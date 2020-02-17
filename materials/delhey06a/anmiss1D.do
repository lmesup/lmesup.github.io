	// Distribution of Missings and number of valid observations
	// German Version

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anmiss1D, replace
	
	// Data
	// ----

	use cntry *_o using data02, clear

	replace cntry = "Deutschland (W)" if cntry == "Germany (W)"
	replace cntry = "Deutschland (O)" if cntry == "Germany (E)"
	replace cntry = "Ungarn" if cntry == "Hungary"
	replace cntry = "T�rkei" if cntry == "Turkey"

	label define country 4 "Deutschland (W)" 3 "Deutschland (O)" 2 "Ungarn" 1 "T�rkei"
	encode cntry, gen(country) label(country)

	foreach var of varlist own_o - turkey_o {
		gen v`var' = `var' < .
		gen m`var' = `var' >= .
	}

	replace mgermany_o = motherpart_o if cntry == "Deutschland (W)" | cntry == "Deutschland (O)"
	replace msweden_o = . if cntry == "Deutschland (W)" | cntry == "Deutschland (O)"
	replace mhungary_o = . if cntry=="Ungarn"
	replace mgermany_o = . if cntry=="T�rkei"
	replace vgermany_o = votherpart_o if cntry == "Deutschland (W)" | cntry == "Deutschland (O)"
	replace vsweden_o = . if cntry == "Deutschland (W)" | cntry == "Deutschland (O)"
	replace vhungary_o = . if cntry=="Ungarn"
	replace vgermany_o = . if cntry=="T�rkei"
	drop votherpart_o vturkey_o motherpart_o mturkey_o

	collapse (sum) v* (mean) m*, by(country)
	
	local i 1
	foreach word in hungary poland spain italy germany france sweden netherlands switzerland {
		ren  m`word'_o misfrac`i'
		ren v`word'_o valid`i++'
	}

	reshape long misfrac valid, i(country) j(refgroup)

	lab val refgroup refgroup
	local i 1
	foreach word in hungary poland spain italy germany france sweden netherlands switzerland {
		local cap = proper("`word'")
		label define refgroup `i++' "`cap'", modify
	}

	// Translate Labels for refgroup into German
	// -----------------------------------------

	label language en, rename
	label language en 
	label language de, new copy

	label define refgroup_de ///
	  1 Ungarn ///
	  2 Polen ///
	  3 Spanien ///
	  4 Italien ///
	  5 Deutschland ///
	  6 Frankreich ///
	  7 Schweden ///
	  8 Niederlande ///
	  9 Schweiz
	label value refgroup refgroup_de

	// Distribution of Missings
	// ------------------------

	foreach var of varlist misfrac mfriends_o mneighbours_o mown_o {
		replace `var' = `var' * 100
	}
	
	graph twoway ///
	  (dot  misfrac refgroup, horizontal mcolor(black) ) ///
	  (line refgroup mfriends_o, clpattern(dash) clcolor(black) ) ///
	  (line refgroup mneighbours_o, clpattern(dot) clcolor(black) ) ///
	  (line refgroup mown_o, clpattern(longdash_dot) clcolor(black)  ) ///
	  , by(country, cols(1) note("")) ///
	  legend(rows(2) lab(1 "Andere L�nder") lab(2 "Freunde") lab(3 "Nachbarn") lab(4 "Eigenes Land")) ///
	  ylabel(1(1)9, valuelabel angle(horizontal) nogrid) ytitle("") xtitle("") ///
	  ysize(5.15) xsize(3.15) 

	  graph export anmiss1D.eps, replace
	
	// Numbers of Observations
	// -----------------------

	by country: list refgroup valid, constant sep(9)
	by country: list vfriends vneighbours vown if _n==1 

	log close
	exit

	
Other countries can be seen as reference points for comparisons only,
if people are able to make evaluations about foreign countries. If
respondents denied to answer to questions on the living conditions in
other countries this might be an indicator that they cannot make such
an evaluation. In this sense, the distribution of missing values can
be used as a first indicator for the importance of other countries as
reference points.

Figure \ref{anmiss1.eps} displays the fractions of missing
observations in the variables for the evaluation of other countries by
survey country. In addition the figure displays the fraction of
missing observations for the evaluation of the living conditions of
friends, neighbors and of the living conditions in respondent's own
country. As it stands, the fraction of missings varies a good deal
between the four survey countries. There are considerable high
fractions of missings observations in the Turkish, Hungarian and East
German Data, while the West German data has relatively low fractions
of missings. An explanation for the low fraction of non-response in
West-Deutschland might be, that the reference-countries are either
neighboring countries (Switzerland, Netherlands, France, Poland) or
very important Holliday countries (Spain, Italy).

With some exceptions much more respondents denied to evaluate the
living conditions of other countries than to evaluate the living
conditions of friends, neighbors and the respondent's own country. In
this respect a large minority of respondents cannot have other
countries as a reference point for their individual aspirations.

Another general pattern is that non-response tend to be somewhat more
frequent with respect to the poorer reference countries. 

As noted, there are some exceptions from the overall pattern of higher
non-response rates for the questions about the living conditions in
other countries. The most obvious case in point can be found in the
Hungarian data: In Ungarn, friends and neighbors seem to be as
alienate as other countries, or even more so. We cannot explain the
extraordinary high non-response rates for Ungarn here, however these
rates coincidence with a high rate of people saying to have no close
friends outside the family (51 \% in Ungarn as opposed to 21 \% in
T�rkei and Deutschland), and 81 percent of the respondents, who say that
they have no close friend outside the family do not evaluate the
living conditions of friends (anmissHU.do). The second exception can
be found in the data for Deutschland. Respondents from Deutschland seem to
have no difficulty to answer the question on the living conditions in
the other part of Deutschland, and the East Germans answers this question
even more frequent than the West Germans.


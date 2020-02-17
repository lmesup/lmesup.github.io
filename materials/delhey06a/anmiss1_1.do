	// Distribution of Missings and number of valid observations + Within Person

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anmiss1_1, replace
	
	// Data
	// ----

	use cntry *_o using data02, clear

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)

	foreach var of varlist own_o - turkey_o {
		gen v`var' = `var' < .
		gen m`var' = `var' >= .
	}

	replace mgermany_o = motherpart_o if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace msweden_o = . if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace mhungary_o = . if cntry=="Hungary"
	replace mgermany_o = . if cntry=="Turkey"
	replace msweden_o = . if cntry=="Turkey"
	replace vgermany_o = votherpart_o if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace vsweden_o = . if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace vhungary_o = . if cntry=="Hungary"
	replace vgermany_o = . if cntry=="Turkey"
	replace vsweden_o = . if cntry=="Turkey"
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


	// Distribution of Missings
	// ------------------------

	graph twoway ///
	  (dot  misfrac refgroup, horizontal mcolor(black) ) ///
	  (line refgroup mwithin1_o) ///
	  (line refgroup mwithin2_o) ///
	  (line refgroup mfriends_o) ///
	  (line refgroup mneighbours_o) ///
	  (line refgroup mown_o) ///
	  , by(country, cols(1) note("")) ///
	  legend(rows(2) lab(1 "Other countries") lab(2 "Friends") lab(3 "Neighbours") ///
	  lab(4 "Own country") lab(5 "Five years ago") lab(6 "Entitled to") ) ///
	  ylabel(1(1)9, valuelabel angle(horizontal) nogrid) ytitle("") xtitle("") ///
	  ysize(8)
	graph export anmiss1_1.eps
	
	// Numbers of Observations
	// -----------------------

	by country: list refgroup valid, constant sep(9)
	by country: list vfriends vneighbours vown vwithin* if _n==1 

	
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
West-Germany might be, that the reference-countries are either
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
Hungarian data: In Hungary, friends and neighbors seem to be as
alienate as other countries, or even more so. We cannot explain the
extraordinary high non-response rates for Hungary here, however these
rates coincidence with a high rate of people saying to have no close
friends outside the family (51 \% in Hungary as opposed to 21 \% in
Turkey and Germany), and 81 percent of the respondents, who say that
they have no close friend outside the family do not evaluate the
living conditions of friends (anmissHU.do). The second exception can
be found in the data for Germany. Respondents from Germany seem to
have no difficulty to answer the question on the living conditions in
the other part of Germany, and the East Germans answers this question
even more frequent than the West Germans.


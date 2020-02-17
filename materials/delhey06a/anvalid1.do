	// How reasistitic are the evaluations about countries Living Condions

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anvalid1, replace
	
	// Data
	// ----

	use ID cntry year hungary_i-turkey_i hungary_g-turkey_g using data02, clear

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)

	replace germany_g = otherpart_g if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace germany_i = otherpart_i if cntry == "Germany (W)" | cntry == "Germany (E)"
	replace hungary_g = . if cntry=="Hungary"
	replace hungary_i = . if cntry=="Hungary"
	replace turkey_i = . if cntry=="Turkey"

	foreach word in  hungary poland spain italy germany france sweden netherlands switzerland {
		local cap = proper("`word'")
		label var `word'_g "`cap'"
		label var `word'_i "`cap'"
	}

	
	// Individual Mode
	graph hbox ///
  	  switzerland_i netherlands_i sweden_i france_i germany_i italy_i spain_i hungary_i poland_i, ///
	  ascategory by(country, cols(1) note("") ) yline(0, lpattern(dot)) ///
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) ///
	  ysize(5.15) xsize(3.15) 
	graph export anvalid1a.eps, replace

	// General Mode
	graph hbox ///
  	  switzerland_g netherlands_g sweden_g france_g germany_g italy_g spain_g hungary_g poland_g, ///
	  ascategory by(country, cols(1) note("") ) yline(0, lpattern(dot))  ///
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) ///
	  ysize(5.15) xsize(3.15) 
	graph export anvalid1b.eps, replace

	log close
	exit


Two sorts of such comparisons can be made. Firstly, we can subtract
the score of the reference country from the score for the own country,
and secondly we can subtract the score for the reference country from
the score for the evaluation of the individual living condition. These
two comparisons refer to the two modes of comparison described above 
(-> Jan?).

By doing the respective subtraction we will get a measure, which can
vary between -10 and 10. We will get negative values if the respondent
evaluates the his living condition or his own country's living
condition to be lower than the living conditions in the reference
country, and we will get positive values if it is the other way
around. The value of 0 indicates that a respondent evaluates the his
living conditions or his country's living condition to be the same as
in the reference countries to be the same.  Figure [anvalid1a.eps] and
[anvalid1b.eps] displays box plots (Cleveland 1994: 139--143) of the
distributions of variables generated accordingly. Thereby
[anvalid1b.eps] displays the results for the individual mode
comparison and [anvalid1b.eps] for the general mode comparison (->
check term). Within each figure the distributions are presented in
separate panels for each survey country. In each panel of the figure
the reference countries are sorted according to their GDP per capita
(in PPP).

It can be seen from figure [anvalid1a.eps] that the mass of the
respondents from Turkey evaluates the their living conditions to be
substantially lower than the living conditions in any other
country. Even in the comparison to the poorest of the reference
countries --- Poland --- about 75 percent of the respondents from
Turkey believe that their living condition is worse than that in
Poland. Hungarian respondents by and large share the pessimistic views
of the Turks, i.e. they belive that their living condition is worse
than the living conditions in the Western European reference
countries. However, Hungarian respondents evaluate their living
conditions to be better than that of an average Pole. Refer to the
panels for Germany, special attention is necessary for the comparison
of Germans with "Germany". In the survey, both, East-Germans and
West-Germans are ask to evaluate the living conditions in western and
eastern Germany separately. Therefore we are able to measure how
West-Germans evaluate their living condition in comparison to East
Germany, and how East Germans evaluate their living conditions in
comparison to West Germany. It can be seen from the figure, that the
respondents from both parts of Germany consider the living conditions
in West Germany to be favorable to those in East Germany. Besides that
respondents from both parts of Germany tend to see their living
conditions worse than the living conditions in Switzerland, better
than the living conditions in Poland, Hungary and the bulk of western
European countries and similar than the living conditions in France.

A very similar picture arise if we look at the distributions of the
variables for the general mode of comparison (figure
[anvalid1b.eps]). However there is one exception, which is worth
noting: The respondents from East Germany seem to be slightly too
patriotic in the evaluation of East German's living conditions.  They
evaluate the living conditions to be similar than those in Switzerland
and yet better than those in the Netherlands. According to their
answers, only West-Germany has substantial better living conditions
than East Germany. A methodological explanation for these somewhat
unrealistic responds might be, that the question on evaluating the
living conditions in eastern Germany is answered with respect to the
living conditions in the entire country, and that the answers about
West-Germany are calibrated accordingly.

Besides this minor glitch, two general points that are important for 
subsequent analysis: 

- The evaluations of the respondents by and large reflect the position
of the reference countries in the GDP league table of nations. In this
sense the evaluations can be seen as a realistic picture of an
objective entity. However even if the evaluations were unrealistic,
this would not invalidate an analysis of the question whether the ---
possibly wrong --- evaluations of ``international'' reference groups
affect peoples live satisfaction.

- The distributions of the comparison-measures vary substantially
within each survey country, and most of the distributions seem to be
fairly symmetric. Hence, there is no barrier to use these variables as
independent variables from the outset.



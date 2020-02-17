	// Same as anvalid1, but for  Within-Country Comparisons (friends,neigbours,own country)

version 8
	set more off
	set scheme s1mono
	capture log close
	log using anvalid2, replace
	
	// Data
	// ----

	use ID cntry year friends neighbours germany_i hungary_i turkey_i using data02, clear

	label define country 4 "Germany (W)" 3 "Germany (E)" 2 "Hungary" 1 "Turkey"
	encode cntry, gen(country) label(country)

	gen own = germany_i if country == 4 | country == 3
	replace own = hungary_i if country == 2
	replace own = turkey_i if country == 1
	label var own "Own Country"
	label var friends "Friends"
	label var neighbours "Neighbors"
	
	
	// Individual Mode
	graph hbox ///
  	  friends neighbours own, ///
	  ascategory by(country, cols(1) note("") ) yline(0, lpattern(dot)) ///
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) ///
	  ysize(4.15) xsize(3.15) 
	graph export anvalid2a.eps, replace

	by cntry, sort: pwcorr friends neighbours own

	log close
	exit


	Figure \ref{anvalid2} displays the distributions of the comparisons
	with possible reference groups in respondent's own country. From
empirical research it is well known, that social attributes are
similar between friends and neighbors
\citep{feld82,feld84,jackson77,laumann66,lauman73}. Therefore one
should not expect large differences between one's own living
conditions and the living conditions of friends and neighbors
respectively, and figure \ref{anvalid2} indeed shows this
pattern. In the same line the differences between the evaluation of
one's own living condition and the living condition in one's own
country should not be to large on average. In fact, a country's
living condition can be seen as the sum of the living conditions of
its citizens, so that there should not be a difference at all on
average. The empirical distribution, however, displays a slight
tendency of the respondents to evaluate their own living condition
somewhat better than the living condition in their own country. A
result like this can be often found in empirical research, and
might be explained with a general tendency of humans to see
their-selves above the mean.

The correlation between the comparisons with friends and neighbors
varies between 0.6 in Hungary and 0.89 in Turkey, suggesting that it
will hardly be possible to separate between the effects of both of
them. We therefore make separate analyses.









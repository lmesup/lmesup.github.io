* Properties of the selected Subgroup
* kohler@wz-berlin.de

version 9

	drop _all
	set memory 90m
	set more off
	
	// EU + CC only 
	use svydat01 if eu 

	replace weich = 0 if mi(weich)
	collapse (mean) age hinc city eu (count) n=women, by(survey ctrname weich)

	by survey ctrname, sort: gen index = _n==1
	replace index = sum(index)
	reshape wide age hinc city n, i(index) j(weich)

	// Sort-Order for Countries
	egen ctrsort = axis(eu ctrname), label(ctrname) gap reverse
	gen npos = 72
	

	// The Graph
	twoway ///
	  || scatter ctrsort age0                               /// Other Obs
	  , ms(O) mcolor(black)                                 ///
	  || pcarrow ctrsort age0 ctrsort age1                  /// Pers. from Gender homog. Couples
	  , msize(small) mcolor(black) lcolor(black)            ///
	  || scatter ctrsort npos                               ///
	  , ms(i) mlab(n1) mlabpos(9) mlabgap(0)                ///
	  ||  , by(survey, note("nobs from gender homog, couples are shown as numbers") ///
	  l1title("") iscale(*.8))                              /// Twoway Options 
	    ylab(1(1)4 6(1)15 17(1)31, valuelabel angle(horizontal))            ///
	    legend(rows(1) order(1 "Other observations" 2 "Gender homog. couples" )) ///
	  scheme(s1mono) ysize(8.5)
	graph export ansubgroup01.eps, replace

	exit
	


	
	

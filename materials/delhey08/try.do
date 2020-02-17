	//  Fraction of Missings for Comparison-Variables by Coutry
	//  Creator: kohler@wz-berlin.de
	
	
	//  INTRO 
	//  -----
	
version 9.0
	clear
	set more off
	set memory 32m
	set scheme s1mono
	
	capture use data01
	if _rc==601 {
		do crdata01
		use data01
	}
	
	// Histograms by Country
	label variable compqual "Own countries' vs. EU's quality of life" 
	sort iso3166_2
	merge iso3166_2 using agg, keep(hdi2002)
	assert _merge == 3
	drop _merge
	egen sctry = axis(hdi2002 ctrname), label(ctrname)

	levelsof sctry, local(K)
	local i 1
	foreach k of local K {
		local ylabel = cond(inlist(`i',1,6,11,16,21),"ylabel(0(20)80)",`"ylabel(0 "  " 20 "  " 40 "  " 60 "  " 80 "  ")"')
		local xlabel = cond(inlist(`i',21,22,23,24,25),"xlabel(-2(1)2)",`"xlabel(-2 " " -1 " " 0 " " 1 " " 2 " " )"')
		local color = cond(inlist(`i',1,2,3,4,5,6,7,8,10,12),"fcolor(gs8)","fcolor(white)" )
		
		histogram compqual if sctry == `k'  ///
		  , discrete percent xscale(range(-2 2)) yscale(range(0 80)) ///
		  `ylabel' `xlabel'  `color' ytitle("") xtitle("")   ///
		  title(`:label (sctry) `k'', pos(12) box bexpand ) nodraw name(g`i', replace)
		local names "`names' g`i++'"
	}

	graph combine `names', rows(5) imargin(tiny)
	


	
	graph export ancomp_1_hist.eps, replace
	

	exit
	
	  
	  
	

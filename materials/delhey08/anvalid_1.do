	//  Fraction of Missings for Comparison-Variables by Coutry
	//  Creator: kohler@wz-berlin.de
	
	
	//  INTRO 
	//  -----
	
version 9.0
	clear
	set more off
	set memory 32m
	set scheme s1mono
	
	capture use data01, 
	if _rc==601 {
		do crdata01
		use data01
	}


	//  Collapse
	//  --------
		
	collapse (mean) mean=compqual eu [aw=weight], by(ctrname)
	sort ctrname
	merge ctrname using agg, sort 
	assert _merge == 3
	drop _merge
	
	lab var hdi2002 "Human development index (2002)"
	
	
	sum hdi2002
	local xmean = r(mean)
	sort iso3166_2
	preserve

	clear
	input str2 iso3166_2 mlabpos
	AT  10 
	BE  3
	CY  12
	CZ  11 
	DK  9
	EE  4
	FI  12
	FR  6 
	DE  3
	GR  4
	HU  6
	IE  6 
	IT  5
	LV  9
	LT  10 
	LU  12
	MT  9
	NL  6
	PL  5
	PT  6
	SK  9
	SI  9
	ES  3 
	SE  3
	GB  4
end
	sort iso3166_2
	tempfile pos
	save `pos'
	restore
	merge iso3166_2 using `pos'
	assert _merge == 3
	drop _merge
	
	separate mean, by(eu)
	graph twoway  ///
	  || sc mean1 mean2 hdi2002 ///
	  , ms(O O) mfcolor(white black) mlcolor(black black) mlab(iso3166_2 iso3166_2) mlabvpos(mlabpos) ///
	  xline(`xmean') yline(0)  ///
	  legend(off) ytitle(Own countries' vs. EU's quality of life)


	graph export anvalid_1.eps, replace
	
	
	
	exit
	
	  
	  
	

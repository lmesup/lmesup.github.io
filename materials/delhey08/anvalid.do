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

	// Keep the Variable labels
	local i 1
	foreach var of varlist compeco-compqual {
		local `var'title `"`=subinstr("`:var lab `var''","Own Country-EU:","",.)'"'
	}
		
	collapse (mean) compeco-compqual eu [aw=weight], by(ctrname)
	sort ctrname
	merge ctrname using agg, sort
	assert _merge == 3
	drop _merge
	

	ren gdp2003 truth1
	ren unemp03 truth2
	ren eff2003 truth3
	ren soccap01 truth4
	ren hdi2002 truth5

	lab var truth1 "Gross domestic product in PPS (2003)"
	lab var truth2 "Total unemployment rate (2003)"
	lab var truth3 "Energy inefficency of production (2003)"
	lab var truth4 "Social spending per capita (2003)"
	lab var truth5 "Human development index (2003)"
	
	local i 1
	foreach var of varlist compeco compemp compenv compsoc compqual {

		sum truth`i'
		local xmean = r(mean)

		separate `var', by(eu)
		graph twoway  ///
		  || sc `var'1 `var'2 truth`i', ms(O O) mfcolor(white black) mlcolor(black black) xline(`xmean') yline(0)  ///
		  || , legend(off) name(g`i++') nodraw title(``var'title', pos(12) box bexpand ) ytitle(Own Country - EU)
	}

	graph combine g1 g2 g3 g4 g5, rows(2) ycommon
	graph export anvalid.eps, replace
	
	
	
	exit
	
	  
	  
	

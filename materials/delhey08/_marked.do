
	foreach var of varlist loc edu ecstat mar {
		levelsof `var', local(K)
		foreach k of local K {
			gen `var'`k':yesno = `var'==`k' if !mi(`var')
			label variable `var'`k' "`:label (`var') `k''"
		}
	}
			
	levelsof iso3166_2, local(K)
		foreach k of local K {
			gen c`k':yesno = iso3166_2=="`k'" if !mi(`var')
			label variable c`k' "`k'"
	}
	

	// 1st Try for Reference-Group Paper
	
	use country v7 v8 v22 v56 v62* v75* using $em/em, clear
	keep if inlist(country,8)

   lab var v62j "turkey"
	foreach k in a b c d e f g i {
		local lab: var lab v62`k'
		gen `lab' = v62j - v62`k' 
	}

	foreach var of varlist hungary-sweden {
		lowess v56 `var', jitter(4) ms(p) name(`var', replace) nodraw
	}
	
  graph combine  ///
	  hungary poland france italy spain netherlands switzerland sweden  ///
	  , xcommon ycommon

	
	

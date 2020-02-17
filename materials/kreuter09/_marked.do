// Only countries with observations in each round
local i 1
foreach file in ess1contacts ess2contacts ess3cf_ed1 {
	use cntry using $ess/`file', clear
	contract cntry
	sort cntry
	tempfile f`i'
	save `f`i++''
}

use `f1'
merge cntry using `f2' `f3', nokeep

drop if cntry=="SI"  // SI no idno for 2004

local i 1
levelsof cntry if _merge1==1 & _merge2==1, local(K)
foreach k of local K {
	if `i++' == 1 local clist `"`clist' cntry == "`k'" "'
	else local clist `"`clist' | cntry == "`k'" "'
}


// +---------+
// |ESS 2002 |
// +---------+

// Data
// ----

use $ess/ess1contacts.dta if `clist', clear


* Find out which parties are against EU-Integration
	
version 9
	set more off
	set scheme s1mono
	capture log close
	log using anmanifesto, replace

	use countryn eu partynam edate per108 per110 rile* using ~/data/manifesto/manifesto if eu==10, clear
	by countryn (edate), sort: keep if edate == edate[_N]  // Last election

	gen eucmp = per108-per110
	tw sc eucmp rilecmp || qfit eucmp rilecmp, by(countryn)

	// If leftiest party is agains EU:
	by countryn (rilecmp), sort: gen left = eucmp[1]<0

	// If most right party is against EU:
	by countryn (rilecmp): gen right = eucmp[_N]<0

	// Strore county-Data
	by countryn: keep if _n==1
	ren countryn ctrname
	keep ctrname left right
	list
	log close
	exit
	
	

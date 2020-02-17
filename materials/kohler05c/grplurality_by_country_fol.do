* Entropy and Deviance by EU (with Confidence Bounds)
* ---------------------------------------------------

version 8.2

	// Data
	// ----

	use plurality_ci, clear

	encode eu, gen(EU)
	recode EU  3=1 2=3 1=2
	label define EU 1 "EU-15" 2 "AC-10" 3 "CC-3", modify

	// Reference Lines for the Means
	// ----------------------------
	
	sum entropy_s, meanonly
	gen heterobar1 = r(mean)
	sum deviance, meanonly
	gen heterobar2  = r(mean)
	
	// Label according to the Sort-Order
	// ---------------------------------

	sort EU entropy_s
	gen sortedcnt:sortedcnt = (EU-1) + _n

	forv i=1/28 {
		local label = country[`i']
		local nr = `i' + (EU[`i']-1)
		label define sortedcnt `nr' "`label'", modify
	}

	// Reshape
	// -------

	ren entropy_s hetero1
	ren deviance hetero2
	ren entropyLB heteroLB1
	ren devianceLB heteroLB2
	ren entropyUB heteroUB1
	ren devianceUB heteroUB2

	reshape long hetero heteroLB heteroUB heterobar, i(sortedcnt) j(type)
	label value type type
	label define type 1 "Stand. Entropie" 2 "Norm. Devianz"
	
	
	// Distribution of Entropy by EU-Status and Country
	// ------------------------------------------------
	
	graph twoway ///
	  (line sortedcnt heterobar, clcolor(gs7))          ///
	  (rspike heteroLB heteroUB sortedcnt, horizontal blstyle(p1) ylabel(, nogrid))         ///
	  (dot hetero sortedcnt, ndots(30)  horizontal ms(o) msize(*1.2))    ///
	  , yscale(reverse) ytitle("") ysize(2.5) xsize(3.5)  ///
  	  ylabel(1(1)15 17(1)26 28(1)30, notick valuelabel angle(horizontal) gextend) ///
	  by(type, xrescale legend(off) note("") iscale(.9) ) 

	graph export plurality_by_country_fol.eps, replace


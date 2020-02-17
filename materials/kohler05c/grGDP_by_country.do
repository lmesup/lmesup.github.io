* GDP by Country
* --------------

version 8.2
	set scheme s1mono

	// Data
	// ----

	use plurality_ci_b, clear

	encode eu, gen(EU)
	recode EU  3=1 2=3 1=2
	label define EU 1 "EU-15" 2 "AC-10" 3 "CC-3", modify

	// Calculate Means
	// ---------------

	forv i = 1/3 {
		sum  gdppcap1 if EU == `i' & iso3166_2 ~= "LU" , meanonly
		local mean`i' = r(mean)
	}
	
	// Label according to the Sort-Order
	// ---------------------------------

	sort EU gdppcap1
	gen sortedcnt:sortedcnt = (EU-1) + _n

	forv i=1/28 {
		local label = country[`i']
		local nr = `i' + (EU[`i']-1)
		label define sortedcnt `nr' "`label'", modify
	}

	// Common Options
	// --------------

	local opt `" horizontal "'
	local opt `" `opt' ylabel(none, valuelabel angle(horizontal) axis(1)) "'
	local opt `" `opt' ylabel(none, valuelabel angle(horizontal) axis(2)) "'
	local opt `" `opt' xlabel(none, nogrid valuelabel angle(horizontal) axis(2)) "'
	local opt `" `opt' xlabel(none, nogrid valuelabel angle(horizontal) axis(2)) "'
	local opt `" `opt' yscale(reverse axis(1)) ytitle("", axis(1)) "'
	local opt `" `opt' yscale(reverse axis(2)) ytitle("", axis(2)) "'
	local opt `" `opt' xtitle("", axis(1)) "'
	local opt `" `opt' xtitle("", axis(2))  "'
	local opt `" `opt' yaxis(1 2) xaxis(1 2)"'
	local opt `" `opt' dstyle(none) mcolor(black) "'
	local twopt `" legend(off)  "'

	local mostopt `" ylabel(1(1)15 17(1)26 28(1)30, grid gstyle(dot) notick nogextend valuelabel angle(horizontal) axis(1)) "'
	local mostopt `" `mostopt' xscale(range(4000 28000) axis(1)) xscale(range(4000 28000) axis(1)) "'
	local mostopt `" `mostopt' xlabel(5000(5000)25000, axis(1)) xmtick(##2, axis(1)) "'
	local mostopt `" `mostopt' xtitle("Pro-Kopf-BIP in Kaufkraftparitäten", axis(1)) "'
	local mostopt `" `mostopt' xline(`mean1' `mean2' `mean3', noextend lcolor(gs7) ) name(most, replace)  nodraw "'

	local luxopt  `"  xscale(range(45000 45720) axis(1)) "'
	local luxopt  `" `luxopt' xlabel(45360, axis(1))  "'
	local luxopt  `" `luxopt' xscale(range(45000 45720) axis(2)) xtitle(" ", axis(1)) fxsize(10)  "'
	local luxopt  `" `luxopt' name(lux, replace) nodraw "'
	local luxopt  `" `luxopt' yscale(range(1 30)) yline(1(1)15 17(1)26 28(1)30, lstyle(dot) noextend axis(2)) "'
	
	
	// Distribution of GDP by country and EU-Status
	// ---------------------------------------------
	
	graph twoway ///
	  (dot gdppcap1 sortedcnt, `opt'  mstyle(p1) )                       ///
	   if iso3166_2 ~= "LU"  ///
	   , `mostopt' `twopt' 
	
	// Distribution of Entropy by EU-Status and Country
	// ------------------------------------------------

	graph twoway ///
	  (dot gdppcap1 sortedcnt, `opt' )                         ///
	   if iso3166_2 == "LU"  ///
	  , `luxopt' `twopt' 
	
	graph combine most lux, rows(1) imargin(tiny)  ysize(3.15) xsize(2.8) iscale(1) graphregion(margin(zero))

	graph export GDP_by_country.eps, replace


	

// Optimal matching of result sequences
// kohler@wzb.eu

	
version 9.2
	set scheme s1mono
	use ctrcase cntry idno visit result using ESScontact, clear

	// Clean Data
	// ----------

	// No result information very common in NO, LU, and CZ
	drop if inlist(cntry,"NO","LU","CZ")

	// We drop the remaining sequences with no "result information"
	by ctrcase (visit), sort: gen x  = sum(result==8)
	by ctrcase (visit): drop if x > 0

	// Visit - Variable have gaps in FI, CH and IL
	// We drop these sequences
	by ctrcase (visit): replace x = visit -1 != visit[_n-1] if _n > 1
	by ctrcase (visit): replace x = sum(x)
	by ctrcase (visit): replace x = x[_N]
	drop if x
	drop x


	// We only use sequences of length 6 and above
	// --------------------------------------------
	by ctrcase (visit): drop if visit[_N] <= 5

	// Now sqset
	sqset result ctrcase visit

	// sqom
	// ----

	sqom, full

	// Cluster Analysis
	// ----------------

	sqclusterdat
    clustermat wardslinkage SQdist, add name(wards)
    clustermat singlelinkage SQdist, add name(single)
    sqclusterdat, return 

	// Analyze cluster solution by country
	// ------------------------------------


	preserve
	by ctrcase, sort: keep if _n==1

	tw ///
	  || kdensity wards_hgt, lcolor(black) lpattern(solid) xaxis(1) yaxis(1) ///
	  || kdensity single_hgt, lcolor(black) lpattern(dash) xaxis(2) yaxis(2) ///
	  , legend(order(1 "Wards linkage" 2 "Single linkage"))  ///
	  xtitle("Dissimilarity measure from wards linkage", axis(1)) ///
	  xtitle("Dissimilarity measure from single linkage", axis(2)) ///
	  xtick(0(10)150, axis(1)) xtick(0(.02).4, axis(2))
	graph export ansqom1_cluster.eps, replace

	gen group = 1 if inrange(single_hgt,0,.1)
	replace group = 2 if inrange(single_hgt,.1,.16)
	replace group = 3 if inrange(single_hgt,.16,.22)

	keep ctrcase group
	sort ctrcase
	tempfile x
	save `x'
	restore
	sort ctrcase
	merge ctrcase using `x'
	drop _merge

	by group ctrcase, sort: gen newx = _n==1
	by group, sort: replace newx = sum(newx)

	replace ctrcase = string(newx)
	
	sqindexplot ///
	  , by(group, yrescale title(Indexplots by sequence clusters) col(3)) ///
	  scheme(s2color) legend(rows(1))
	graph export ansqom1_indexplot.eps, replace
	tab cntry group, row

  
	exit
	
	

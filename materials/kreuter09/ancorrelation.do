// Correlation of sequence characteristics with fieldwork variables
// kohler@wzb.eu

	
version 9.2
	set scheme s1mono
	use ctrcase cntry idno visit edate result using ESScontact, clear

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

	// Now sqset
	sqset result ctrcase visit

	// Generate descriptive statistics
	// -------------------------------
	
	egen sqlength4= sqlength(), e(4) // <- No contact at all

	// Correlations
	// ------------

	preserve

	// Fieldwork on Sundays
	drop if edate >= .
	gen sunday = dow(edate) == 0 

	collapse (mean) sqlength4 sunday, by(cntry)

	local opt "horizontal ms(0) mlcolor(black)"
	
	graph twoway ///
	  || scatter  sqlength4 sunday , mlcolor(black) mfcolor(black) mlab(cntry)  ///
	  || lowess  sqlength4 sunday , lcolor(black)  ///
	  title(Count of no contacts by fieldwork on sundays) legend(off) ///
	  xtitle(Proportion of contacts on sundays) ytitle(Avererage # of no contacts within sequence)
	
	graph export ancorrelation_sunday.eps, replace
	restore, preserve


	exit

	


	








	








	
	exit
	

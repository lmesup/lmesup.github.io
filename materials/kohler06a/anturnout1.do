	// Aggregate-Level Correlations of Institutional Factors and Participation

version 8.2
	set more off
	set scheme s1mono

	capture log close
	log using anturnout1, replace
	
	use s_cntry q25 vturnout wcountry using $dublin/eqls_4, clear

	// Drop respondent without right to vote in last election 

	drop if q25 == 3
	gen voter = q25==1 if q25 < .
	
	// Collapse
	// --------

	collapse (mean) voter vturnout [aw=wcountry], by(s_cntry)


	// Logit-Transformation
	// --------------------
	
	replace voter = log(voter/(1-voter))
	replace vturnout = log(vturnout*.01/(1-vturnout*.01))

	// Merge Elections-System
	// ----------------------
	
	sort s_cntry
	merge s_cntry using electsystem


	// Recoding
	// --------
	
	gen pflicht:yesno = compul > 0 if compul < .
	gen propor:yesno = type == 1 if type < .
	gen weekend:yesno = day == 0 | day==6 if day < .
	gen state:yesno = inlist(regis,1,3) if day < .
	gen org=orgevs

	// Initialize File
	// ---------------
	
	file open results using anturnout1.tex, write text replace 

	// Standardized  Regression Coeff., Simple
	// ---------------------------------------
	
	file write results ///
	  "\\multicolumn{8}{l}{\\emph{\$r\$ mit Wahlbeteiligung}} \\\\" _n
	foreach yvar of varlist voter vturnout {
		file write results (cond("`yvar'"=="voter","EQLS","UNDP"))
		foreach xvar of varlist weekend compet pflicht propor state nopers org {
				reg `yvar' `xvar'
				sum `yvar' if e(sample)
				local sty = r(sd)
				sum `xvar' if e(sample)
				local stx = r(sd)
				file write results " & " %4.2f (_b[`xvar']* `stx'/`sty') 
		}
		file write results " \\\\ " _n
	}

	// Unstandardized  Regression Coeff., Simple
	// -----------------------------------------

	file write results ///
	  "\\multicolumn{8}{l}{\\emph{\$b\$ aus linearer Einfachregression auf Wahlbeteiligung}} \\\\" _n
	foreach yvar of varlist voter vturnout {
		file write results (cond("`yvar'"=="voter","EQLS","UNDP"))
		foreach xvar of varlist weekend compet pflicht propor state nopers org {
			quietly {
				reg `yvar' `xvar'
				file write results " & " %4.2f (_b[`xvar']) 
			}
		}
		file write results " \\\\" _n
	}

	// Unstandardized  Regression Coeff., Multiple
	// -------------------------------------------

	file write results ///
	  "\\multicolumn{8}{l}{\\emph{\$b\$ aus multipler Regression auf Wahlbeteiligung}} \\\\" _n
	foreach yvar of varlist voter vturnout {
		file write results (cond("`yvar'"=="voter","EQLS","UNDP"))
		reg `yvar' weekend compet pflicht propor state nopers org
		foreach xvar of varlist weekend compet pflicht propor state nopers org {
			file write results " & " %4.2f (_b[`xvar']) 
		}
		file write results " \\\\" _n
	}

	file close results

	cat anturnout1.tex

	log close
	exit
	

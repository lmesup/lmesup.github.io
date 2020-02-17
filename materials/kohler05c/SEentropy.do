* Bootstrap for Endogenity
* ------------------------

version 8.2
	set more off
	capture log close
	


	// Defines High/Speed plurality program for Bootstrap

capture program drop _plur
program define _plur, rclass
version 8.2

	// Intro
	// -----
		
	syntax varlist [, by(varname) ]
	
	tempvar groups dummy
	tempname results byres

	quietly {

		by `varlist', sort: gen `groups' = 1 if _n == 1
		replace `groups' = sum(`groups')
		local ngroups = `groups'[_N]

		gen byte `dummy' = .
		local i 0

		// Initialize Loop 
		local bytxt `" as txt " by" as res " `by'" "'
		local i = `i' + 1
		levels `by', local(byK)
		foreach byk of local byK {
			count if `by' == `byk'
			local N = r(N)
			local H 0
			local Hst 0
			local D 0
			local C 0
			
			// Loop over groups 
			forv k = 1/`ngroups' {
				local ngroupreal = `ngroups'
				replace `dummy' = `groups' == `k'
				sum `dummy' [`weight' `exp'] if `by' == `byk',  meanonly
				if r(mean) > 0 {
					local H  = r(mean) * (log(r(mean))/log(2)) + `H'
				}
				else {
					local ngroupreal = `ngroupreal' - 1
				}
			}
			local denom = `ngroupreal'
			return scalar r`byk' = (-1 * `H')/(log(`denom')/log(2))
		}
	}
end
	
	// +------------------------+
	// | I Endogenity/Diversity | 
   // +------------------------+
	
	// Data
	// ----

	use s_cntry  emplstat persstat teacat hhincqu2 ///
	  using  "$dublin/eqls_4", clear


	mark touse
	markout touse hhincqu2 persstat teacat
	keep if touse
	
	keep if emplstat == 1
	drop emplstat
	
	// Pattern-Variable
   // ----------------

	by hhincqu2 persstat teacat, sort: gen ses = 1 if _n==1
	replace ses = sum(ses) 

	// Heterogenity
	// ------------

	forv i=1/28 {
		local explist "`explist' r(r`i')"
	}
	
	bootstrap "_plur ses, by(s_cntry)" `explist' ///
	  , reps(1000) strata(s_cntry) nowarn nobc nonormal dot ///
	  saving(SEentropy) replace
	
	exit
	

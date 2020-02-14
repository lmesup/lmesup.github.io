/* Thewes (2018): Regression diagnostic
----------------------------------------------------------------------------
- regression diagnostic for data created by 01cr_ind.do
- diagnostic only possible with "logit", not with "fracreg logit"
- adds variable "drop" with 0 for keep and 1 for outliers in each datasat.
- drop==1 will be excluded in 02cr_hat.do
----------------------------------------------------------------------------
*/ 

global methods 1 2 3 4			// which model should be calculated?
local diag 0					// Turn graphical diagnostic on (=1) or off (=0)

foreach x in $methods{
	if `x' == 1 use "data/faas", clear
	if `x' == 2 use "data/gab", clear
	if `x' == 3 use "data/za5625", clear
	if `x' == 4 use "data/za5592", clear
	
	ren p_nicht pn_nicht
	ren edu_abi edun_nicht
	if `x' >= 2 ren p_linke pn_linke
	if `x' >= 3 ren fam_seperated famn_seperated
	if `x' >= 3 ren rel_other reln_other 

	if `x' == 1 qui logit result distance p_* age age2 male edu_* unemp fam_* hhsize pop popdens baden ulm stuttgart
	if `x' == 2 qui logit result 		  p_* age age2 male edu_* unemp 							   stuttgart 
	if `x' == 3	qui logit result 		  p_* age age2 male edu_* unemp fam_* hhsize pop  rel_* 	   stuttgart
	if `x' == 4 qui logit result 		  p_* age age2 male edu_* unemp fam_* hhsize pop  rel_* 	   stuttgart 
	
	keep if e(sample)

	if `diag' == 1 {
		//Multicollinearity
		if `x' == 1 collin distance p_* age age2 male edu_* unemp fam_* hhsize popdens baden ulm stuttgart 	
		if `x' == 2 collin p_* age age2 male edu_* unemp 							   stuttgart
		if `x' >= 3 collin p_* age age2 male edu_* unemp fam_* hhsize pop  rel_* 	   stuttgart
		// only age&age2 with VIF>40 in all 4 models

		

		if `x' == 1 ldfbeta distance p_* age age2 male edu_* unemp fam_* hhsize popdens baden ulm stuttgart
		if `x' == 2 ldfbeta 		  p_* age age2 male edu_* unemp 							   stuttgart
		if `x' == 3	ldfbeta 		  p_* age age2 male edu_* unemp fam_* hhsize pop  rel_* 	   stuttgart
		if `x' == 4 ldfbeta 		  p_* age age2 male edu_* unemp fam_* hhsize pop  rel_* 	   stuttgart

		foreach var of varlist DF* {
			scatter `var' serialid, mlab(serialid) name(`var', replace) nodraw
			local name  `name' `var'
		}
		graph combine `name'
		drop DF*



		// Influential Observations

		predict p
		predict stdres, rstand
		predict dv, dev 
		predict hat, hat
		predict dx2, dx2
		predict dd, dd
		predict dbeta, dbeta

		scatter stdres p, yline(0) ms(oh) mlab(serialid)
		scatter stdres serialid, yline(0) mlab(serialid)

		scatter dv p, yline(0) ms(oh) mlab(serialid)
		scatter dv serialid, yline(0) ms(oh) mlab(serialid)

		scatter hat p, ms(oh) yline(0) mlab(serialid)
		scatter hat serialid, ms(oh) yline(0) mlab(serialid)

		scatter dx2 p, ms(oh) yline(0) mlab(serialid)
		scatter dx2 serialid, ms(oh) yline(0) mlab(serialid)

		scatter dd p, ms(oh) yline(0) mlab(serialid)
		scatter dd serialid, ms(oh) yline(0) mlab(serialid)

		scatter dbeta serialid, mlab(serialid)
		scatter dx2 serialid [w=dbeta], mfcolor(none)
		drop p stdres dv hat dx2 dd dbeta
	}

	// mark outlier
	if `x' == 1 gen drop = inlist(serialid,903,1117,1135,930,1034,251,844,1193,6,748,1368) 
	*if `x' == 2 gen drop = inlist(serialid,) 				// no outliers
	if `x' == 3	gen drop = inlist(serialid,486,1139,218,1259,211,430,353)
	if `x' == 4 gen drop = inlist(serialid,435,192,136,213,630,772,299,234,270,854)
	drop serialid 


	// undo previous renaming
	ren pn_nicht p_nicht 
	ren edun_nicht edu_abi 
	if `x' >= 2 ren pn_linke p_linke
	if `x' >= 3 ren famn_seperated fam_seperated 
	if `x' >= 3 ren reln_other rel_other 

	// save with "drop==1" for outlier.
	if `x' == 1 save "data/faas_c", replace
	if `x' == 2 save "data/gab_c", replace
	if `x' == 3 save "data/za5625_c", replace
	if `x' == 4 save "data/za5592_c", replace
}


exit

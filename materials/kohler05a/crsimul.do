* Simulates data with voting behavior for various social positions on the
* base of hypotheses about P in EU = P * U

* This draws from http://www.sowi.uni-mannheim/lesas/kohler02b/crsimul.do
* See this for a more complete simulation. Also see Kohler (2002b) for a
* description of the general ideas.

* 0) Intro
* --------

clear
version 7.0
tempfile simul
set seed 731              


* 1) Structure of the Data
* ------------------------

* Generate Data with social classes 

input byte egp
	 1
	 2
	 3
	 4
end
lab var egp "EGP-Classes"
lab val egp egp
lab def egp  /*
*/ 1 "Employers/Self-Employed"  /*
*/ 2 "Administrative Services"  /*
*/ 3 "Routine Non-Manuals/Experts"  /*
*/ 4 "Manual Wage-Laborers/Social Services"   


* Lets build 1000 observations for each category of EGP
expand 1000

* Save
save groups, replace


* 2) Simulation
* -------------

quietly {
	forvalues i=1/1000   {   /* 1000 Replications */ 
		use groups, clear	/* load data structure */

		* Systematic Component
		* --------------------

		local U = uniform()*2-1
		local P_powcons = uniform()*2-1
		local P_powleft = uniform()*2-1
		local P_procons = uniform()*2-1
		local P_proleft = uniform()*2-1
		local Pw = uniform()*2-1  

		* Systematic Part of the Reduce-Factors
		* -------------------------------------

		local redukM1 = uniform()*2-1
		local redukM2 = uniform()*2-1
		local redukW1 = uniform()*2-1
		local redukW2 = uniform()*2-1


		* U-Terms
		* --------

		* U is 
		*
		* U_power
		* U_prosperity
		
		gen Upow  = normprob(invnorm(uniform()))
		gen Upro  = normprob(invnorm(uniform()))
	
		* P-Terms
		* -------

		* P is 
		*
		* P_pow,kons  P_pros,kons 
		* P_pow,spd   P_pros,spd 
	
		* Cleavage of Power

		* Hypothesis: P_pow,kons > P_pow,spd); Difference: Random
		gen P_powcons = normprob(invnorm(uniform()) + `P_powcons')   /*
		*/ if egp == 1
		gen P_powleft = P_powcons * normprob(invnorm(uniform()) +  /*
		*/  `redukM1') if egp == 1

		* Hypothesis: P_pow,spd > P_pow,kons; Difference: Random
		replace P_powleft = normprob(invnorm(uniform()) + `P_powleft')/*
		*/  if egp ~=  1
		replace P_powcons = P_powleft * normprob(invnorm(uniform()) + /*
		*/ `redukM2') if egp ~= 1
	
		* Cleavage of Prosperity

		* Hypothese: P_pros,kons > P_pros,left; Difference: Random
		gen P_procons = normprob(invnorm(uniform()) + `P_procons')  /*
		*/ if egp == 1 | egp == 2
		gen P_proleft = P_procons * normprob(invnorm(uniform())  /*
		*/ + `redukW1') if egp == 1 | egp == 2

		* Hypothese: P_pro,left >
		replace P_proleft = normprob(invnorm(uniform()) + `P_proleft')/*
		*/ if egp == 4 
		replace P_procons = P_proleft * normprob(invnorm(uniform())  /*
		*/ + `redukW2') if egp == 4
	
		* Hypothese: P_pro,left = P_pros,kons, Difference: Random
		replace P_proleft = normprob(invnorm(uniform()) + `Pw')   /*
		*/ 	if egp == 3 
		replace P_procons = normprob(invnorm(uniform()) + `Pw')  /*
		*/ 	if egp == 3	

		* Expected Utilities
		* ------------------

		* EU = P * U
		gen EUkons = P_powcons * Upow + P_procons * Upro 
		gen EUleft = P_powleft * Upow + P_proleft * Upro 
		
		* Action Selection
		* ----------------

		gen kons = EUkons > EUleft
		gen left = EUleft > EUkons


		* Aggregation by social Groups
		* ----------------------------	

	 	gen n = 1
		collapse (sum) kons left (count) n, by(egp)

		* Calculate Frequencies
		* ----------------------

		replace left = left/n
		replace kons = kons/n

		* Save results
		* ------------------------

		gen sample = `i'

		capture append using `simul'
		save `simul', replace
	}
}


save simul, replace
exit

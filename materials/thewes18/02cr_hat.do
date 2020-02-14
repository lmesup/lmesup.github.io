/* Thewes (2018): Predict counterfactual voting
----------------------------------------------------------------------------
- Calculate fractional response models for all 4 models (01cr_ind.do)
- exclude outliers "if ! drop" (01an_reg_diag.do)
- out-of-range prediction for S21 voting data
- calculate Yn 
- calculate Bias(Y)

Files:
- s21_y.dta: voting-results and prediction of Yn/Bias(Y)/etc. 
  Needed for graphs in 04gr_******.do 
----------------------------------------------------------------------------
*/ 

global methods 1 2 3 4 // which models should be calculated?

// Calculate Predictions
// ---------------------	
local labellist = ""
foreach x in $methods {
	if `x' == 1 {
		use "data/faas_c", clear
		fracreg logit result distance p_* age age2 male edu_* unemp fam_* hhsize popdens baden ulm stuttgart [pw=GEWICHT] if !drop
		foreach var of varlist result distance p_* age age2 male edu_* unemp hhsize popdens baden ulm stuttgart {
			local label : variable label `var'
			local labellist `labellist' `var' "`label'"
		}
	}

	if `x' == 2 {
		use "data/gab_c"
		fracreg logit result 		  p_* age age2 male edu_* unemp 							   stuttgart [pw=GEWICHT]
	}

	if `x' == 3 {
		use "data/za5625_c"
		fracreg logit result 		  p_* age age2 male edu_* unemp fam_* hhsize pop  rel_* 	   stuttgart [pw=GEWICHT] if !drop
		foreach var of varlist fam_* pop  rel_* {
			local label : variable label `var'
			local labellist `labellist' `var' "`label'"
		}	
	}

	if `x' == 4 {
		use "data/za5592_c"
		fracreg logit result 		  p_* age age2 male edu_* unemp fam_* hhsize pop  rel_* 	   stuttgart [pw=GEWICHT] if !drop
	}

	if `x' == 1 estimates store m`x', title(\textbf{M `x'})
	else estimates store m`x', title(M `x')
	// out-of-range prediction
	drop *
	use "data/s21"
	predict Ri_hat`x'
	keep id Ri_hat`x'

	tempfile hat`x'
	save "`hat`x''"
}

// Regression Output
estout m1 m2 m3 m4 using "stout/regression.tex", replace			///
	label style(tex) drop(p_nicht edu_abi fam_seperated rel_other)	/// 
	cells(b(star fmt(%4.3f))) dmarker(,)							///
	stats(r2_p N, fmt(%4.3f %4.0f) label("Pseudo-\$R^2$" "N"))		///
	eq("") collabels(,none) eqlabels(none) 							///
	varlabels(`labellist' _cons "Konstante")						///
	order(p_* age* male unemp edu_* fam_* rel_* hhsize distance pop* stuttgart baden ulm)	///
	prehead(\setstretch{1,35} "\begin{tabular}{lllll}" \toprule)	///
	posthead(\midrule) prefoot(\midrule)							///
	postfoot(\bottomrule "\textit{@starlegend}" "\end{tabular}")	///
	refcat(p_andere "Partei: keine" edu_mitt "Edu: Abitur"			///
	fam_widowed "Fam: getrennt" rel_eva "Rel: Andere/Keine", below)


// Merge four predicted results to original data
use "data/s21", clear
foreach x in $methods {
	merge m:1 id using `hat`x'', nogen
}


// max-turnout
// -----------

gen Pn = 1 - turnout/100			// 100% as max turnout

// Calculate Bias
// --------------

ren valid E
ren SB EN
gen N = EN-E

gen Ye = Ri

qui foreach x in $methods {
	gen Yn`x' = ((Ri_hat`x' * (N+E)) - (Ri * E)) / N
	
	winsor2 Yn`x', cuts(2 99) replace			// Outlier 

	gen Y`x' = Pn * abs(Yn`x' - Ye)				// Bias
	gen Y_dif`x' = (Pn * (Yn`x' - Ye))			// Bias +-
	gen YnYe`x' = abs(Yn`x' - Ye)				// Differenz Yn - Ye

	// Mean Bias
	// ---------

	gen YiNi = Y`x' * EN

	sum YiNi, meanonly
	local YiNi_t `r(sum)'
	sum EN, meanonly
	local EN_t `r(sum)'
	local y_mean : display %05.4g `YiNi_t' / `EN_t'*100
	global y_mean `y_mean'

	sum Y`x', meanonly
	local y_min : display %09.3f r(min)*100

	local y_max : display %05.4g r(max)*100

	drop YiNi

	// Calculate counterfactual result
	// -------------------------------	
	gen Ri_yes = Voter * Ri_hat`x'
	sum Ri_yes, meanonly
	local Ri_yes `r(sum)'

	sum Voter, meanonly
	local result : display %05.4g `Ri_yes'/r(sum)*100
	drop Ri_yes

	noi di as res "Method `x':   Mean: " as err `y_mean' as res "  Min: " as err `y_min' as res "  Max: " as err `y_max' as res "  S21-Ergebnis: " as err `result' 
}


// Cleanup
// -------
qui {
	keep  id GKZ GEN distance EN E N Pn Ri Ye Ri_hat? Yn? YnYe? Y? Y_dif? //Ri_dif? Ri_absdif?
	order id GKZ GEN distance EN E N Pn Ri Ye Ri_hat? Yn? YnYe? Y? Y_dif? //Ri_dif? Ri_absdif? 

	lab var id "ID"
	lab var GKZ "GKZ"
	lab var distance "Distance"
	lab var E "N Voter"
	lab var N "N Non-Voter"
	lab var EN "Electorate"
	lab var Pn "P(N)"
	lab var Ri "Result Voter"
	lab var Ye "Result Voter"

	foreach x in $methods {
		lab var Ri_hat`x' "Predicted Result `x'"
		lab var Y`x' "Bias `x'"
		lab var Yn`x' "Prediction Non-Voter `x'"
		lab var Y_dif`x' "Bias +- `x'"
		lab var YnYe`x' "Opinion Difference `x'"

		replace Yn`x' = Yn`x' * 100
		replace Y`x' = Y`x' * 100
		replace Y_dif`x' = Y_dif`x' * 100
		replace YnYe`x' = YnYe`x' * 100 
		replace Ri_hat`x' = Ri_hat`x' * 100
	}

	replace Ri = Ri * 100
	replace Ye = Ye * 100
  	replace Pn = Pn * 100
}

save "data/s21_y", replace

exit

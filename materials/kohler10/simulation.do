set scheme s1mono

// Simulation for various concentrations
capture program drop spec
program define spec, rclass
version 10
	syntax [, nparty(real 2) concentration(string) re(int 6800000) ]

	// Random settings
	local plev = uniform()*(0.26 - 0.09) + 0.09
	local lv = `plev'*`re'
	local vv = `re'-`lv'
	local pobs = cond(uniform()>.5,0.1,0.4)
	local vv_a = `pobs' * `vv'

	// Disturbance setting
	if "`concentration'" == "" { 
		local midpoint = (`pobs' + 1/`nparty')/2
		local concentration = abs(invnorm(uniform())*0.1+`midpoint')
	}
	
	// Calculations
	local hdv_a  = (`vv_a' + `lv'*`concentration')/(`vv'+`lv')
	return scalar pobs = `pobs'
	return scalar nparty = `nparty'
	return scalar plev = `plev'*100
	return scalar diff = (`hdv_a' - `pobs')*100
	return scalar concentration = `concentration'
end

// Random concentration
clear
simulate r(nparty) r(pobs) r(plev) r(diff) r(concentration) ///
  , reps(2000): spec, nparty(6) 

rename _sim_1 nparty
rename _sim_2 pobs
rename _sim_3 lev
rename _sim_4 diff
rename _sim_5 concentration

replace pobs = round(pobs*100,1)
label value pobs pobs
label define pobs 10 "Party with 10% of valid votes"  40 "Party with 40% of valid votes"  

scatter diff lev ///
  , mcolor(black..) ms(Oh)     ///
  by(pobs, ///
  note(Source: Authors calculations as explained in appendix table B)) 		/// 
  xtitle(Leverage) xlabel(10(5)25) yline(0) ylabel(-10(2)10, grid) ///
  ytitle(Simulated change in % of votes) ylab(, grid) ///
 
graph export simulation_2.eps, replace
!epstopdf -o simulation_2.pdf simulation_2.eps

exit




// Simulation of data generating processes for bounded happiness scales
// kohler@wzb.eu

// Intro
// -----

clear
version 11.0

// Figure of data generating process
// ---------------------------------

set obs 15
gen x = _n-1
gen f = 1/sqrt(2*_pi) * exp(-.5 * ((x - 7)/2)^2)
gen t = x >= 10
by t, sort: gen f2 = sum(f) if t
by t, sort: replace f2 = f2[_N] if t

graph twoway ///
  || rbar f f2 x if x<=10, barwidth(.8) color(gs6) ///
  || bar f x if x<=10, barwidth(.8) color(gs12)  ///
  || bar f x if x >10, barwidth(.8) lstyle(yxline) fcolor(white)  ///
  || function y = 1/sqrt(2*_pi) * exp(-.5 * ((x-7)/2)^2) ///
  , range(0 14) lcolor(black)  ///
  legend(order(4 "Latent happiness" 2 "Observed happiness")) ///
  xlab(0(1)10) xtitle(Happiness) ytitle(Proportion) ylab(, grid)
  
graph export ansimulation_setup.eps, replace


// Define Simulation
// -----------------

capture program drop satsim
program define satsim, rclass
version 11
	syntax [, obs(integer 1) sigma(real 1) range(numlist)]
	drop _all
	set obs `obs'

	local recode: subinstr local range " " ",", all
	local last: word count `range'
	local min: word 1 of `range'
	local max: word `last' of `range'

	local mu = runiform()*(`max'-`min')+`min'

	tempvar z
	gen `z' = recode(round(rnormal(`mu',`sigma'),1),`recode')
	sum `z'
	return scalar mu = `mu'
	return scalar sigma = `sigma'
	return scalar min= `min'
	return scalar max = `max'
	return scalar mean = r(mean)
	return scalar sd  = r(sd)
end


// Run Simulations
// ---------------

local i 1
foreach range in 0/10 1/7 1/4 {
	foreach sd in .5 1 2 3 {
		simulate, reps(200): satsim, obs(1000) range(`range') sigma(`sd')
		tempfile f`i'
		save `f`i++''
		}
	}

use `f1'
forv i=2/12 {
	append using `f`i''
}

// Figures
// -------

set scheme s1mono

gen sigmacat:sigmacat = floor(sigma)
label value sigmacat sigmacat
label define sigmacat  ///
  0 "{&sigma}=0.5" 1 "{&sigma}=1 (standard normal)"  ///
  2 "{&sigma}=2" 3 "{&sigma}==3"

graph twoway   ///
  || line sigma mu, sort lpattern(dash) lcolor(black)  ///
  || sc sd mu, ms(Oh) mlcolor(black)  ///
  || if max==10, by(sigmacat,  ///
  note(Graphs by standard deviation of latent happiness, span) /// ///
  legend(off))  ///
  ytitle(Standard deviation) yscale(log) ///
  xtitle(Mean of latent happiness) xlab(0(2)10) 
graph export ansimulation_11scale.eps, replace

graph twoway   ///
  || line sigma mu, sort lpattern(dash) lcolor(black)  ///
  || sc sd mu, ms(Oh) mlcolor(black)  ///
  || if max==7, by(sigmacat,  ///
  note(Graphs by standard deviation of latent happiness, span) /// ///
  legend(off))  ///
  ytitle(Standard deviation) yscale(log) ///
  xtitle(Mean of latent happiness) xlab(1(1)7) 
graph export ansimulation_7scale.eps, replace

graph twoway   ///
  || line sigma mu, sort lpattern(dash) lcolor(black)  ///
  || sc sd mu, ms(Oh) mlcolor(black)  ///
  || if max==4, by(sigmacat,  ///
  note(Graphs by standard deviation of latent happiness, span) /// ///
  legend(off))  ///
  ytitle(Standard deviation) yscale(log) ///
  xtitle(Mean of latent happiness) xlab(1(1)4) 
graph export ansimulation_4scale.eps, replace


exit

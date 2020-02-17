// Diff-in-Diff by Country and time
// kohler@wzb.eu

cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m

capture log close
log using anreemployment.smcl, replace

// Germany
use DE  if eunempdata, clear

// Keep obs with events 
by id (wave), sort: gen byte eventcount = sum(eunemp)
by id (wave), sort: keep if eventcount[_N] >0

gen period = irecode(wave,1989,1999,2010)
gen emp = empmth >= 8 if !mi(empmth) 
bysort period: xttrans emp 

sort id wave
gen lag1 = l1.emp
gen lag2 = l2.emp
gen lag3 = l3.emp

forv i = 1/3 {
	bysort period: tab lag`i' emp [aweight=weight], row nofreq
}	

// United States
use US  if eunempdata, clear

// Keep obs with events 
by id (wave), sort: gen byte eventcount = sum(eunemp)
by id (wave), sort: keep if eventcount[_N] >0

gen period = irecode(wave,1989,1999,2010)
gen emp = empweeks >= 8*4 if !mi(empweeks) 
bysort period: xttrans emp 

sort id waveorder
gen lag1 = l1.emp
gen lag2 = l2.emp
gen lag3 = l3.emp

forv i = 1/3 {
	bysort period: tab lag`i' emp [aw=weight], row nofreq
}	

log close
exit









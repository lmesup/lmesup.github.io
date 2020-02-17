// Liferisk-Projekt, Create data with poorness
// kohler@wzb.eu

// crjoined.do First version
// crjoined2.do Do not dublicate missing PSID years

cd "$liferisks/armut/analysen"

clear all
version 11
set more off
set mem 700m

// Germany
// -------

// Unemp-file
use persnr year mthunemp mthwork using soep, clear
ren year wave
isid persnr wave

tsset persnr wave
replace mthunemp = F1.mthunemp
replace mthwork = F1.mthwork

gen byte unempdata = 1
tempfile unempDE
save `unempDE'
		
// Family-file
use persnr wave trennung using trennung, clear
isid persnr wave

gen byte familydata = 1

tempfile familyDE
save `familyDE'

// Health file
use persnr hhnr wave hhpostgoveq illlong netto whours age edu men ///
  using soep2 , clear
isid persnr wave
gen byte healthdata = 1

// Merge files
merge 1:1 persnr wave using `unempDE', nogen update
merge 1:1 persnr wave using `familyDE', nogen update

replace unempdata = 0 if unempdata==.
replace familydata = 0 if familydata==.
replace healthdata = 0 if healthdata==.

// Merge Weights and stuff
merge n:1 persnr using  ../../data/weights/gsoepweights  ///
  , keep(3) keepusing(weight) nogenerate

merge n:1 hhnr using $soep25/design 	///
  , keep(3) keepusing(psu) nogenerate

// Valid observations only
by persnr (wave), sort: keep if netto[_n+1]==10

// Define Poorness
gen poor=.
levelsof wave, local(K)
foreach k of local K {
	_pctile hhpostgoveq [aw=weight] if wave==`k' 
	replace poor = hhpostgoveq < (r(r1)*.6) if wave==`k' 
}

ren persnr id

order id hhnr wave weight 				/// 
  healthdata familydata unempdata whours men age edu  ///
  hhpostgoveq poor
  
compress

save joined2DE, replace

// United States
// -------------

// Unemp-file
use id wave wkun wkwrkd using psid, clear
ren id x11101ll
isid x11101ll wave

tsset x11101ll wave
gen mthunemp = floor(F1.wkun/4.3)
gen mthwork = floor(F1.wkwrkd/4.3)
drop wkun wkwrkd

gen byte unempdata = 1

replace wave = cond(inrange(wave,1,18),1980+wave-1,1980+ wave + (wave-19)-1)
isid x11101ll wave

tempfile unempUS
save `unempUS'

// Family-file
use persnr year trennung using psid_sep2, clear
ren persnr x11101ll
ren year wave
isid x11101ll wave

replace wave = wave - 1 if wave >= 1999
gen byte familydata = 1

tempfile familyUS
save `familyUS'

// Health-file
use x11101ll x11102 wave hhpostgoveq illlong whours age edu men  ///
  using psid2, clear
isid x11101ll wave

gen byte healthdata = 1

// Merge files
merge 1:1 x11101ll wave using `unempUS', nogen
merge 1:1 x11101ll wave using `familyUS', nogen

replace unempdata = 0 if unempdata==.
replace familydata = 0 if familydata==.
replace healthdata = 0 if healthdata==.

// Merge Weights and stuff
merge n:1 x11101ll using  ../../data/weights/psidweights  ///
  , keep(3) keepusing(weight) nogenerate

ren x11101ll id

// Valid observations only
by id  (wave), sort: keep if x11102[_n+1]!=.

// Define Poorness
gen poor=.
levelsof wave, local(K)
foreach k of local K {
	_pctile hhpostgoveq [aw=weight] if wave==`k' 
	replace poor = hhpostgoveq < (r(r1)*.6) if wave==`k' 
}


order id x11102 wave weight 				/// 
  healthdata familydata unempdata whours men age edu  ///
  hhpostgoveq poor
  
compress

save joined2US, replace


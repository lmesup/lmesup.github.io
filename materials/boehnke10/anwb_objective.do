* Domains  of Well-Being 
* EQLS 2003

version 9
	set more off
	set scheme s1mono
	
	
// EQLS 2003
// ---------

 use $dublin/eqls_4, clear

label define domain 1 "Health" 2 "Employment" ///
   3 "Education" 4 "Income" 5 "Security" 6 "Housing" ///
   7 "Family" 8 "Inclusion" 9 "Environment" 

// Country
// -------

label define s_cntry 11 "United Kingdom", modify
egen iso3166 = iso3166(s_cntry)

// Health (Long term illness)
gen wb1 = q43<=4 if !mi(q43)

// Joblessness 
preserve
ren hh2d hh3d_1
ren hh2b hh3b_1
ren hh1 hhsize
keep s_respnr hh3b* hh3d* wcountry iso3166 hhsize
reshape long hh3b_ hh3d_, i(s_respnr) j(person)
drop if person > hhsize

by s_respnr, sort: gen wb2 = sum(hh3d_<=3 & inrange(hh3b_,18,64))
by s_respnr: replace wb2 = wb[_N]>0

by s_respnr: gen missings = sum(hh3d_==.)
by s_respnr: replace wb2 = . if missings[_N]>0

by s_respnr: keep if _n==1
keep s_respnr wb2
sort s_respnr

tempfile x
save `x', replace

restore
sort s_respnr
merge s_respnr using `x'
replace wb2 = . if !inrange(hh2b,18,64)

// Education (English)
gen wb3 = q51<=2 if !mi(q51)

// Income
ren hhinc4 wb4

// Security
gen wb5 = q57==1 | q57==2 if !mi(q57)

// Housing: space
ren q17 wb6
replace wb6 = wb6/hh1	
	
// Family: married
gen wb7 = hh1 >= 2 if !mi(hh1)

// Inclusion: Contact with friends/neigbours at least once a weak
gen wb8 = q34c <= 3 if !mi(q34c)

// Environment
egen wb9 = anycount(q56*) if !mi(q56a,q56b,q56c,q56d), values(3 4)
replace wb9 = wb9 >= 2 


collapse ///
   (mean) wb1 wb2 wb3 wb5 wb6 wb7 wb8 wb9 ///
   (median) wb4 ///
   [aw=wcountry], by(iso3166 )

gen eu = .
foreach code in AT BE DE DK ES FI FR GB GR IE IT LU NL PT SE {
  replace eu = 1 if iso3166 == "`code'"
}

foreach code in TR CY MT {
  replace eu = 2 if iso3166 == "`code'"
}

foreach code in BG RO CZ EE HU LT LV PL SI SK {
  replace eu = 3 if iso3166 == "`code'"
}

forv k=1/9 {
  egen axis`k' = axis(eu wb`k'), label(iso3166) gap reverse
  egen mean`k' = mean(wb`k'), by(eu)

  if `k' == 3 replace wb3 = . if inlist(iso3166,"GB","MT","IE")
  if `k' == 4 replace wb4 = . if inlist(iso3166,"DE")

  graph twoway ///
   || dot wb`k' axis`k', ms(O) mcolor(black) horizontal ///
   || line axis`k' mean`k' if eu == 1, lcolor(black)  ///
   || line axis`k' mean`k' if eu == 2, lcolor(black)  ///
   || line axis`k' mean`k' if eu == 3, lcolor(black)  ///
   || , ylabel(1(1)10 12(1)14 16(1)30, valuelabel angle(0)) ///
      ytitle("") scheme(s1mono) name(g`k', replace) ///
      title("`:label domain `k''", box bexpand) nodraw ///
      xtitle("") legend(off)
}

graph combine g1 g2 g3 g4 g5 g6 g7 g8 g9, ysize(12)
graph export anwb_objective_1.eps, replace preview(on)


ren wb1 Health
ren wb2 Employment
ren wb3 Education
ren wb4 Income
ren wb5 Security
ren wb6 Housing 
ren wb7 Family
ren wb8 Inclusion
ren wb9 Environment 

biplot8 Health Employment Education Income Security Housing ///
  Family Inclusion Environment ///
  , subpop(eu, mlab(iso3166 iso3166 iso3166) mlabcolor(black..) ms(O..) ///
  mlcolor(black..) mfcolor(black gs8 white))  ///
  scheme(s1mono) legend(off)
graph export anwb_objective_biplot.eps, replace preview(on)

	

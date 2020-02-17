version 9.1
	set more off
	capture log close
	log using anpol_by_country, replace

	use ess04, clear

   // Election system dummies
	gen majority = inlist(cntry,"GB","FR")
   label variable majority "Majority system"
   gen compulsory = inlist(cntry,"BE","IT","LU","BE") // | inlist(cntry,"AT","NL")
   label variable compulsory "Compulsory elections"
   gen workday = inlist(cntry,"IE","GB", "NL", "NO")
   label variable workday "Elections on rest days"
   gen fc = inlist(cntry,"CZ","EE","PL","SI","HU") | inlist(cntry,"SK")
   label variable fc "Communist legacy"

   // Variabl redifinitions
   gen agegroup:agegroup = 1 if inrange(age,18,25)
   replace agegroup = 2 if inrange(age,26,79)
   replace agegroup = 3 if inrange(age,80,102)
   label define agegroup 1 "Age 18-25" 2 "Age 26-79" 3 "Age 80 and above"

   replace emp = 3 if emp==3 | emp==4 | emp==5
   label define emp 3 "Homemaker/in Education/Retired", modify

   // Additive Index trust
   egen trust = rmean(trst*)
   label variable trust "Trust in political institutions"

	// Listwise Deletion
	mark touse
	markout touse voter age men edu egp emp hhinc church discrim ///
      polint polcmpl govsat democsat trust lrgroup
	keep if touse

	// Dummi-Coding etc
   capture program drop mydummies
   program mydummies
   syntax varlist
   foreach var of local varlist {
     levelsof `var', local(K)
     foreach k of local K {
         gen byte `var'_`k':yesno = `var' == `k' if !mi(`var')
         label variable `var'_`k' "`:label (`var') `k''"
     }
   }
   end

   mydummies edu emp hhinc egp polint polcmpl agegroup lrgroup

   // Centering
   foreach var of varlist govsat democsat trust {
      sum `var'
      gen c`var' = (`var'-r(mean))/r(sd)
      label variable c`var' "`:var lab `var'' (standardized)"
   }


// Voter Models for each country
// -----------------------------

tempname mfx
postfile `mfx' str2 cntry str10 var categ b n using anpol_by_country_postfile, replace

levelsof cntry, local(Cntry)
foreach cntry of local Cntry {
   di as text "Country is `cntry'"
   foreach block in ///
      "polint_2 polint_3 polint_4" ///
      "polcmpl_2 polcmpl_3 polcmpl_4 polcmpl_5" ///
      "cgovsat" "cdemocsat" "ctrust" ///
      "lrgroup_1 lrgroup_2 lrgroup_4" {

       logit voter `block' men agegroup_1 agegroup_3  ///
       edu_2 edu_3 emp_2 emp_3 hhinc_2-hhinc_4 egp_2-egp_6 church discrim ///
       [pw=nweight] if cntry == "`cntry'"
       mfx, at(zero) nose
       matrix mfx = e(Xmfx_dydx)
       local k: word count `block'
       local pos = strpos("`block'","_") - 1
       local var = cond(`pos'>0,substr("`block'",1,`pos'),"`block'")

       forv i = 1/`k' {
           post `mfx' ("`cntry'") ("`var'") (`i') (`=mfx[1,`i']') (e(N))
       }
   }
}
postclose `mfx'

use anpol_by_country_postfile, clear

by cntry var, sort: gen meanb = sum(b)/(_N+1)
by cntry var, sort: gen varb = sum((b - meanb[_N])^2)
by cntry var, sort: replace varb = varb[_N] + (0-meanb[_N])^2

local opt `"xtitle("") note("`=c(current_date)', `=c(current_time)'", span) "'
local opt `"`opt' ytitle("") xline(0) ysize(6) scheme(s1mono)"'

// Political Interest
egen axis = axis(varb) if var == "polint", label(cntry)
levelsof axis, local(ylab) 
graph twoway ///
  || scatter axis b if categ==1, ms(O) mlcolor(black) mfcolor(white) ///
  || scatter axis b if categ==2, ms(O) mlcolor(black) mfcolor(gs8)   ///
  || scatter axis b if categ==3, ms(O) mlcolor(black) mfcolor(black) ///
  || ,  ylab(`ylab', valuelabel angle(0) grid)         ///
     legend(order(1 "Somewhat" 2 "High" 3 "Very high") rows(1) )     ///
     xlab(-.5(.25).5 0 "Minor")                                      ///
     title(Effect of political interest on voting, span)             ///
     subtitle(Discrete change effects, span)                         ///
     `opt'
graph export anpol_by_country_polint.eps, replace
drop axis

// Complains
egen axis = axis(varb) if var == "polcmpl", label(cntry)
levelsof axis, local(ylab) 
graph twoway ///
  || scatter axis b if categ==1, ms(O) mlcolor(black) mfcolor(white)    ///
  || scatter axis b if categ==2, ms(O) mlcolor(black) mfcolor(gs12)     ///
  || scatter axis b if categ==3, ms(O) mlcolor(black) mfcolor(gs8)      ///
  || scatter axis b if categ==4, ms(O) mlcolor(black) mfcolor(black)    ///
  || ,  ylab(`ylab', valuelabel angle(0) grid)                          ///
     legend(order(1 "Seldom" 2 "Occasionally" 3 "Regularly" 4 "Frequently") rows(1) )     ///
     xlab(-.5(.25).5 0 "Never")                                         ///
     title(`"Effect of "Politics to complicated to understand""', span) ///
     subtitle(Discrete change effects, span)                            ///
     `opt'
graph export anpol_by_country_polcmpl.eps, replace
drop axis

// LR-Groups
egen axis = axis(varb) if var == "lrgroup", label(cntry)
levelsof axis, local(ylab) 
graph twoway ///
  || scatter axis b if categ==1, ms(O) mlcolor(black) mfcolor(white)  ///
  || scatter axis b if categ==2, ms(O) mlcolor(black) mfcolor(black)  ///
  || scatter axis b if categ==3, ms(O) mlcolor(black) mfcolor(gs8)    ///
  || , ylab(`ylab', valuelabel angle(0) grid)                         ///
     legend(order(1 "Left" 2 "Right" 3 "Unengaged") rows(1) )         ///
     xlab(-.5(.25).5 0 "Non-commited")                                ///
     title(`"Effects of Left-Right"', span)                           ///
     subtitle(Discrete change effects, span)                          ///
     `opt' 
graph export anpol_by_country_lrgroup.eps, replace
drop axis

// Trust
egen axis = axis(b) if var == "ctrust", label(cntry)
levelsof axis, local(ylab) 
graph twoway ///
  || scatter axis b if categ==1, ms(O) mlcolor(black) mfcolor(black)  ///
  || , ylab(`ylab', valuelabel angle(0) grid)                         ///
     xlab(-.5(.25).5)                                                 ///
     title(`"Effects of trust in political institutions"', span)      ///
     subtitle(Marginal effects, span)                                 ///
     `opt' 
graph export anpol_by_country_trust.eps, replace
drop axis

// Satisfaction with government
egen axis = axis(b) if var == "cgovsat", label(cntry)
levelsof axis, local(ylab) 
graph twoway ///
  || scatter axis b if categ==1, ms(O) mlcolor(black) mfcolor(black)  ///
  || , ylab(`ylab', valuelabel angle(0) grid)                         ///
     xlab(-.5(.25).5)                                                 ///
     title(`"Effects of satsifaction with government"', span)         ///
     subtitle(Marginal effects, span)                                 ///
     `opt' 
graph export anpol_by_country_govsat.eps, replace
drop axis

// Satisfaction with government
egen axis = axis(b) if var == "cdemocsat", label(cntry)
levelsof axis, local(ylab) 
graph twoway ///
  || scatter axis b if categ==1, ms(O) mlcolor(black) mfcolor(black)  ///
  || , ylab(`ylab', valuelabel angle(0) grid)                         ///
     xlab(-.5(.25).5)                                                 ///
     title(`"Effects of satisfaction with democracy"', span)          ///
     subtitle(Marginal effects, span)                                 ///
     `opt' 
graph export anpol_by_country_democsat.eps, replace

log close

exit







	

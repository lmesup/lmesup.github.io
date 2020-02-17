// Life-satisfaction and subsistence economy
// All analyses

// History
// an1.do Analysis of SOCI submission
// an2.do Changes for SOCI re-submission
//  -> drop Farmers

version 9
clear
set more off
set scheme s1mono
set matsize 500
capture log close
log using an2, replace

use $dublin/eqls_4 if hhstat != 6, clear

gen cgroup:cgroup = 1 
replace cgroup = 2 if inlist(s_cntry,4,12,19,27,28)
replace cgroup = 3 if inlist(s_cntry,3,5,7,13,16,17,21,22,23,24)  
label var cgroup "Country group"
label def cgroup ///
  1 "Trad. market econom."  ///
  2 "Poor trad. market econom." ///
  3 "Former communist"

gen infprod1 = q61>1 if !mi(q61)
lab var infprod1 "Informal food producer"

gen infprod2 = q61>3 if !mi(61) 
lab var infprod2 "Informal food producer (>50%)"

decode s_cntry, gen(ctrname)
replace ctrname = proper(ctrname)
replace ctrname = "United Kingdom" if ctrname == "Uk"

// Income
ren hhincqu2 inc
label define hhincqu2 ///
  1 "1st quartile" ///
  2 "2nd quartile" ///
  3 "3rd quartile" ///
  4 "4th quartile", modify

gen makends = q58 < 3 if !mi(q58)
label variable makends "HH able to make ends meet"
 
// In Education
gen inedu:yesno = emplstat == 5 | teacat == 4
lab var inedu "In education"

// Employment-Status
gen emp:emp = emplstat
replace emp = 5 if emplstat >= 5  // "Missing" + "Other" + "Still Studying"
label def emp ///
  1 "Employed" ///
  2 "Homemaker" ///
  3 "Unemployed" ///
  4 "Retired" ///
  5 "Other"

// Education
gen edu:edu = teacat
replace edu = 4 if edu >= . // "Missing" + "Still Studying" = "Other"
label define edu ///
  1 "Low" ///
  2 "Intermediate" ///
  3 "High" ///
  4 "Other"

// "Class" of Main-Earner 
gen class:class = hhstat
replace class = 7 if class >= .
label define class ///
  1 "Upper white collar" ///
  2 "Lower white collar" ///
  3 "Self employed" ///
  4 "Skilled Worker" ///
  5 "Non skilled worker" ///
  6 "Farmer" /// <- droped
  7 "Other"

// Gender
gen men:yesno = hh2a==1 if hh2a < .
lab var men "Men"
drop hh2a

// Age
sum hh2b, meanonly
gen age = hh2b-r(mean)
lab var age "Age"
gen age2 = age^2
lab var age2 "Age (squared)"
drop hh2b

// Marital-Status
ren q32 mar
label def q32 ///
  1 "Married/living togehter" ///
  2 "Separated/divorced" ///
  3 "Widowed" ///
  4 "Single, never married", modify

gen rural = q55==1 
label variable rural "Open countryside"

// Live-Satisfaction
ren q31 lsat

// Dummies
capture program drop mydummies
program mydummies
version 9
	syntax varlist
	foreach var of local varlist {
		quietly levelsof `var', local(K)
		foreach k of local K {
			gen `var'`k':yesno = `var'==`k' if !mi(`var')
			label var `var'`k' "`:label (`var') `k''"
			}
		}
end
mydummies inc emp  edu class mar s_cntry

// Implication 1: Frequency of subsistence farming
// -----------------------------------------------

preserve

// Store some means
sum infprod1 [aw=wcountry] if cgroup==1
local infprod1tc = r(mean)
sum infprod1 [aw=wcountry] if cgroup==1
local infprod1pc = r(mean)
sum infprod1 [aw=wcountry] if cgroup==3
local infprod1fc = r(mean)

sum infprod2 [aw=wcountry] if cgroup==1
local infprod2tc = r(mean)
sum infprod2 [aw=wcountry] if cgroup==2
local infprod2pc = r(mean)
sum infprod2 [aw=wcountry] if cgroup==3
local infprod2fc = r(mean)


// Calculate the country-specific means
collapse ///
  (mean) infprod1 infprod2 gdppcap1 cgroup           ///
  (sd) infprodsd1=infprod1 infprodsd2=infprod2       ///
  (count) infprodn1=infprod1 infprodn2=infprod2      ///
  [aw=wcountry], by(ctrname)

// Confidence Bounds
gen ub1 = infprod1 + 1.96 * infprodsd1/sqrt(infprodn1)
gen lb1 = infprod1 - 1.96 * infprodsd1/sqrt(infprodn1)
gen ub2 = infprod2 + 1.96 * infprodsd2/sqrt(infprodn2)
gen lb2 = infprod2 - 1.96 * infprodsd2/sqrt(infprodn2)

// Prepare the Graph
keep infprod? ub? lb? ctrname cgroup gdppcap1
egen yaxis = axis(cgroup infprod1), label(ctrname) gap reverse
reshape long infprod ub lb, i(ctrname) j(indicator)

label define indicator ///
  1 "Informal food production" ///
  2 "Inf. food prod. > 50% of needs" 
label value indicator indicator

gen meantc = `infprod1tc' if cgroup==1 & indicator==1
replace meantc = `infprod2tc' if cgroup==1 & indicator==2

gen meanpc = `infprod1pc' if cgroup==2 & indicator==1
replace meanpc = `infprod2pc' if cgroup==2 & indicator==2

gen meanfc = `infprod1fc' if cgroup==3 & indicator==1
replace meanfc = `infprod2fc' if cgroup==3 & indicator==2

twoway ///
  || line yaxis meantc, lcolor(black)   ///
  || line yaxis meanpc, lcolor(black)   ///
  || line yaxis meanfc, lcolor(black)   ///
  || scatter yaxis infprod, mcolor(black) ms(O)     ///
  || rspike ub lb yaxis, horizontal lcolor(black)   ///
  || , by(indicator, xrescale rows(1) note("") )    ///
  ylabel(1(1)10 12(1)16 18(1)30, valuelabel angle(0) grid)  ///
  ytitle("") legend(order(4 "Fraction" 5 "95% Conf. Int.")) 
graph export an2_g1.eps, replace

keep ctrname gdppcap1 cgroup
tempfile agg
save `agg'


// Implication 2: The social distribution of informal food production
// ------------------------------------------------------------------

restore

// Listwise Deletion
mark touse
markout touse ///
  inc2-inc4 emp2-emp5 class2-class7 men rural age age2 ///
  mar2-mar4 infprod1  
keep if touse

// Baseline Models
forv i = 1/3 {
	logit infprod1 inc2-inc4 s_cntry2-s_cntry28 if cgroup==`i'
	estimates store incbase`i'
}

// Full Models
forv i = 1/3 {
	logit infprod1  ///
	  inc2-inc4 ///
	  men rural age age2  ///
	  emp2-emp5 class2-class7 ///
	  mar2-mar4  s_cntry2-s_cntry28 ///
	  if cgroup==`i'
	estimates store incfull`i'
}

// Regression Table
estout  incbase1 incfull1 incbase2 incfull2 incbase3 incfull3           /// 
  using an2_tab1.tex                                                    ///
  , replace style(tex) label varwidth(35)                               ///
  prehead(                                                              ///
  \begin{tabular}{lrrrrrr} \hline                                       ///
  & \multicolumn{2}{c}{Affluent}                                        ///
  & \multicolumn{2}{c}{Poor}                                            ///
  & \multicolumn{2}{c}{Former}                                          ///
  \\                                                                    ///
  & \multicolumn{2}{c}{market economies}                                ///
  & \multicolumn{2}{c}{market economies}                                ///
  & \multicolumn{2}{c}{communist states}                                ///
  \\                                                                    ///
  )                                                                     ///
  posthead(\hline)                                                      ///
  prefoot(\hline) postfoot(\hline \end{tabular} )                       ///
  cells(b(fmt(%3.2f) star))                                             ///
  drop(s_cntry*)                                                        ///
  varlabels(_cons Constant,                                             ///
  blist(                                                                ///
  edu2 "\multicolumn{7}{l}{\emph{Education (reference: low)}}  \\"      ///
  men "\multicolumn{7}{l}{\emph{Control variables}} \\ "                ///
  emp2 "\multicolumn{7}{l}{\emph{Employment status (reference: employed)}} \\ " ///
  class2 "\multicolumn{7}{l}{\emph{Class (reference: upper white collar)}} \\ " ///
  inc2 "\multicolumn{7}{l}{\emph{Income (reference: 1st within country quartile)}} \\ " ///
  mar2 "\multicolumn{7}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
  ))                                                                  ///
  mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)")                          ///
  collabels(, none)                                                     ///
  stats(r2_p N, labels("McFadden \$r^2\$" "\$n\$") fmt(%9.2f %9.0f))    ///
  starlevels(* 0.05 ** 0.01) 

estimates drop _all
macro drop _droplist

// Implication 3: Subsistence farming and life satisfaction
// --------------------------------------------------------

// Baseline Models
forv i = 1/3 {
	reg lsat infprod1 s_cntry2-s_cntry28 if cgroup==`i'
	estimates store prodbase`i'
}

// Full Models
forv i = 1/3 {
	reg lsat infprod1  ///
	  men rural age age2 ///
	  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
	  mar2-mar4  ///
	  s_cntry2-s_cntry28 if cgroup==`i'
	estimates store prodfull`i'
}

// Regression Table
estout  prodbase1 prodfull1 prodbase2 prodfull2 prodbase3 prodfull3     /// 
  using an2_tab2.tex                                                    ///
  , replace style(tex) label varwidth(35)                               ///
  prehead(                                                              ///
  \begin{tabular}{lrrrrrr} \hline                                     ///
  & \multicolumn{2}{c}{Affluent}                                      ///
  & \multicolumn{2}{c}{Poor}                                          ///
  & \multicolumn{2}{c}{Former}                                        ///
  \\                                                                  ///
  & \multicolumn{2}{c}{market economies}                              ///
  & \multicolumn{2}{c}{market economies}                              ///
  & \multicolumn{2}{c}{communist states}                              ///
  \\                                                                  ///
  )                                                                     ///
  posthead(\hline)                                                      ///
  prefoot(\hline) postfoot(\hline \end{tabular} )                       ///
  cells(b(fmt(%3.2f) star))                                             ///
  drop(s_cntry*)                                                        ///
  varlabels(_cons Constant,                                             ///
  blist(                                                              ///
  edu2 "\multicolumn{7}{l}{\emph{Education (reference: low)}}  \\"  ///
  men "\multicolumn{7}{l}{\emph{Control variables}} \\ "            ///
  emp2 "\multicolumn{7}{l}{\emph{Employment status (reference: employed)}} \\ " ///
  class2 "\multicolumn{7}{l}{\emph{Class (reference: upper white collar)}} \\ " ///
  inc2 "\multicolumn{7}{l}{\emph{Income (reference: 1st within country quartile)}} \\ " ///
  mar2 "\multicolumn{7}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
  ))                                                                  ///
  mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" )                         ///
  collabels(, none)                                                     ///
  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f))               ///
  starlevels(* 0.05 ** 0.01) 

estimates drop _all

// Hypothese 4: Interaction-Terms
// ------------------------------

// Interaction-term
foreach var of varlist inc1-inc4 {
	gen `var'gar = `var' * infprod1
	lab var `var'gar `"`=substr("`:var lab `var''",1,3)' {$\times$} sidel. farm."'
	}

// Baseline Models
forv i = 1/3 {
	reg lsat infprod1 inc2gar-inc4gar inc2-inc4 s_cntry2-s_cntry28 if cgroup==`i'
	estimates store iabase`i'
}

// Full Models
forv i = 1/3 {
	reg lsat infprod1 inc2gar-inc4gar  ///
	  men rural age age2 ///
	  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
	  mar2-mar4   ///
	  s_cntry2-s_cntry28 if cgroup==`i' 
	estimates store iafull`i'
}


// Regression Table
estout iabase1 iafull1 iabase2 iafull2 iabase3 iafull3                  /// 
  using an2_tab3.tex                                                    ///
  , replace style(tex) label varwidth(35)                               ///
  prehead(                                                              ///
  \begin{tabular}{lrrrrrr} \hline                                     ///
  & \multicolumn{2}{c}{Affluent}                                      ///
  & \multicolumn{2}{c}{Poor}                                          ///
  & \multicolumn{2}{c}{Former}                                        ///
  \\                                                                  ///
  & \multicolumn{2}{c}{market economies}                              ///
  & \multicolumn{2}{c}{market economies}                              ///
  & \multicolumn{2}{c}{communist states}                              ///
  \\                                                                  ///
  )                                                                     ///
  posthead(\hline)                                                      ///
  prefoot(\hline) postfoot(\hline \end{tabular} )                       ///
  cells(b(fmt(%3.2f) star))                                             ///
  drop(s_cntry*)                                                        ///
  varlabels(_cons Constant,                                             ///
  blist(                                                              ///
  edu2 "\multicolumn{7}{l}{\emph{Education (reference: low)}}  \\"  ///
  men "\multicolumn{7}{l}{\emph{Control variables}} \\ "            ///
  emp2 "\multicolumn{7}{l}{\emph{Employment status (reference: employed)}} \\ " ///
  class2 "\multicolumn{7}{l}{\emph{Class (reference: upper white collar)}} \\ " ///
  inc2 "\multicolumn{7}{l}{\emph{Income (reference: 1st within country quartile)}} \\ " ///
  mar2 "\multicolumn{7}{l}{\emph{Marital status (reference: married, living with partner) }} \\ " ///
  ))                                                                  ///
  mlabels("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" )                         ///
  collabels(, none)                                                     ///
  stats(r2 N, labels("\$r^2\$" "\$n\$") fmt(%9.2f %9.0f))               ///
  starlevels(* 0.05 ** 0.01) 

estimates drop _all


// Chow tests
// ----------

tab cgroup, gen(C)

foreach var1 of varlist C1 C2 C3 {
	foreach var2 of varlist infprod1  ///
	  men rural age age2 ///
	  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
	  mar2-mar4  inc2gar-inc4gar {
		gen `var1'`var2' = `var1' * `var2'
		}
	}

// Test income effects
// Contrast 1: Rich +  Post-socialist vs. poor
logit infprod1 men rural age age2 ///
  inc2-inc4 emp2-emp5 class2-class7 ///
  mar2-mar4 ///
  s_cntry2-s_cntry28 ///
  C1men C1rural C1age C1age2  ///
  C1inc2-C1inc4 C1emp2-C1emp5 C1class2-C1class7  ///
  C1mar2-C1mar4 ///
  C3men C3rural C3age C3age2  ///
  C3inc2-C3inc4 C3emp2-C3emp5 C3class2-C3class7 ///
  C3mar2-C3mar4 
estimates store full

// Joint influence
logit infprod1 men rural age age2 ///
  inc2-inc4 emp2-emp5 class2-class7 ///
  mar2-mar4 ///
  s_cntry2-s_cntry28 ///
  C1men C1rural C1age C1age2  ///
  C1inc2-C1inc4 C1emp2-C1emp5 C1class2-C1class7  ///
  C1mar2-C1mar4 ///
  C3men C3rural C3age C3age2  ///
  C3emp2-C3emp5 C3class2-C3class7 ///
  C3mar2-C3mar4 
estimates store reduced1

logit infprod1 men rural age age2 ///
  inc2-inc4 emp2-emp5 class2-class7 ///
  mar2-mar4 ///
  s_cntry2-s_cntry28 ///
  C1men C1rural C1age C1age2  ///
  C1emp2-C1emp5 C1class2-C1class7  ///
  C1mar2-C1mar4 ///
  C3men C3rural C3age C3age2  ///
  C3inc2-C3inc4 C3emp2-C3emp5 C3class2-C3class7 ///
  C3mar2-C3mar4 
estimates store reduced2

lrtest  full reduced1
lrtest  full reduced2

// Test Life-satisfaction effects
// Contrast 1: Rich +  Post-socialist vs. poor
reg lsat infprod1  ///
  men rural age age2 ///
  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
  mar2-mar4  ///
  s_cntry2-s_cntry28 ///
  C1infprod1 C1men C1rural C1age C1age2 C1inc2-C1inc4  ///
  C1emp2-C1emp5 C1inedu C1edu2-C1edu4  ///
  C1class2-C1class7 C1mar2-C1mar4   ///
  C3infprod1 C3men C3rural C3age C3age2 C3inc2-C3inc4  ///
  C3emp2-C3emp5 C3inedu C3edu2-C3edu4  ///
  C3class2-C3class7 C3mar2-C3mar4

// Contrast 2: Poor + post-socialist vs. rich
reg lsat infprod1  ///
  men rural age age2 ///
  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
  mar2-mar4  ///
  s_cntry2-s_cntry28 ///
  C2infprod1 C2men C2rural C2age C2age2 C2inc2-C2inc4  ///
  C2emp2-C2emp5 C2inedu C2edu2-C2edu4  ///
  C2class2-C2class7 C2mar2-C2mar4   ///
  C3infprod1 C3men C3rural C3age C3age2 C3inc2-C3inc4  ///
  C3emp2-C3emp5 C3inedu C3edu2-C3edu4  ///
  C3class2-C3class7 C3mar2-C3mar4


// Testing the three level interaction
// -----------------------------------


reg lsat infprod1 inc2gar-inc4gar ///
  men rural age age2 ///
  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
  mar2-mar4  ///
  s_cntry2-s_cntry28 ///
  C1infprod1 C1inc2gar-C1inc4gar C1men C1rural C1age C1age2 C1inc2-C1inc4  ///
  C1emp2-C1emp5 C1inedu C1edu2-C1edu4  ///
  C1class2-C1class7 C1mar2-C1mar4   ///
  C3infprod1 C3inc2gar-C3inc4gar C3men C3rural C3age C3age2 C3inc2-C3inc4  ///
  C3emp2-C3emp5 C3inedu C3edu2-C3edu4  ///
  C3class2-C3class7 C3mar2-C3mar4

reg lsat infprod1 inc2gar-inc4gar ///
  men rural age age2 ///
  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
  mar2-mar4  ///
  s_cntry2-s_cntry28 ///
  C2infprod1 C2inc2gar-C2inc4gar C2men C2rural C2age C2age2 C2inc2-C2inc4  ///
  C2emp2-C2emp5 C2inedu C2edu2-C2edu4  ///
  C2class2-C2class7 C2mar2-C2mar4   ///
  C3infprod1 C3inc2gar-C3inc4gar C3men C3rural C3age C3age2 C3inc2-C3inc4  ///
  C3emp2-C3emp5 C3inedu C3edu2-C3edu4  ///
  C3class2-C3class7 C3mar2-C3mar4

// Separate models by inocme 

levelsof cgroup, local(K)
foreach k of local K  {
	foreach var of varlist inc1-inc4 {
		reg lsat infprod1 ///
		  men rural age age2 ///
		  inc2-inc4 emp2-emp5 inedu edu2-edu4 class2-class7 ///
		  mar2-mar4   ///
		  s_cntry2-s_cntry28 if cgroup==`k'  & `var'
	}
}

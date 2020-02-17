* Graphiken Model 2 (augenblicklich, permanent)
version 8.0

* -----------------------------------------------------------------

* ADO-INSTALLATION 
* ----------------

* The following section automatically installs Ado-Files over the
* Internet. You need to have a conection to the internet for this.
* If you don't have a connection to the internet you need to commend 
* out the entire section. In this case you have to install the ados
* by hand (See [U] 32 or Kohler/Kreuter (2001))

capture which mmerge
if _rc ~= 0 {
	ssc install mmerge 
}

* ---------------------------------------------end of installing section. 


* Is be.dta already there? If not, create
capture describe using be
if _rc ~= 0 {
	do crbe
}


* Get Data from Fixed-Effects Model
capture use mod2b, clear
if _rc ~= 0 {
	do anmod2b
	use mod2b, clear
}
sort uv

mmerge uv using be
drop _merge


* Reshape to wide
* ---------------

gen ifinder = substr(uv,-1,1) == "i"
replace uv = reverse(substr(reverse(uv),2,.)) if ifinder==1
drop index
drop if uv== "."
reshape wide bleft1 bkons1 bkons_be bleft_be, i(uv) j(ifinder)

* Sum up interaktions
* -------------------

gen bleft0 = bleft10
gen bkons0 = bkons10
gen bleft1 = bleft10 + 3 * bleft11
gen bkons1 = bkons10 + 3 * bkons11
ren bleft_be0 bleft_be
ren bkons_be0 bkons_be

*  Generating Timepaths                                   
*  --------------------

gen finder = .
gen t = _n in 1/10
lab var t " "
lab val t t
lab def t 5 "event"

foreach piece in arbsel selarb parspd parcdu {
  replace finder = uv=="e`piece'"
  sort finder
  * Left-Model, No political interest
  gen `piece'fl0 = 0
  replace `piece'fl0 = `piece'fl0 + bleft0[_N] if t>=5 & t ~= .
  * Left-Model, Political interest
  gen `piece'fl1 = 0
  replace `piece'fl1 = `piece'fl1 + bleft1[_N] if t>=5 & t ~= .
  * Between effects
  gen `piece'bl = bleft_be[_N] if t ~= .
  * Kons-Model, No political interest
  gen `piece'fc0 = 0
  replace `piece'fc0 = `piece'fc0 + bkons0[_N] if t>=5 & t ~= .
  * Kons-Model, Political interest
  gen `piece'fc1 = 0
  replace `piece'fc1 = `piece'fc1 + bkons1[_N] if t>=5 & t ~= .
  * Between effects
  gen `piece'bc = bkons_be[_N] if t ~= .
}


* Graph 1 - Effect Changover Working Class - Self employed
* --------------------------------------------------------

* Delete some ylabels
foreach var of varlist arbselfc* arbselbc* selarbfc* selarbbc* {
  lab val `var' null
}
lab def null 0 " "

local opt "sort connect(J J) legend(off) xtick(5) ylab(-1(.5)1) ytitle(coef.)"

sum arbselfl0 if arbselfl0 ~= 0
local noint = r(mean)
sum arbselfl1 if arbselfl1 ~= 0
local int = r(mean)
graph twoway line arbselfl* arbselbl t, `opt' xlab(5 "Worker to Self-employed") name(g1, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 

sum selarbfl0 if selarbfl0 ~= 0
local noint = r(mean)
sum selarbfl1 if selarbfl1 ~= 0
local int = r(mean)
graph twoway line selarbfl* selarbbl t, `opt' xlab(5 "Self-employed to Worker") name(g2, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 

sum arbselfc0 if arbselfc0 ~= 0
local noint = r(mean)
sum arbselfc1 if arbselfc1 ~= 0
local int = r(mean)
graph twoway line arbselfc* arbselbc t, `opt' xlab(5 "Worker to Self-employed") name(g3, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 

sum selarbfc0 if selarbfc0 ~= 0
local noint = r(mean)
sum selarbfc1 if selarbfc1 ~= 0
local int = r(mean)
graph twoway line selarbfc* selarbbc t, `opt' xlab(5 "Self-employed to Worker") name(g4, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 


graph combine g1 g2, ycommon xcommon title(SPD-Model) rows(1) name(gleft, replace)
graph combine g3 g4, ycommon xcommon title(CDU/CSU-Model) rows(1) name(gcons, replace)
graph combine gleft gcons, rows(2) xcommon ycommon note("Do File: grmod2.do")
graph export figure4.wmf, replace



* Graph 2 - Effect of New Interaction Partners
* --------------------------------------------

* Delete some ylabels
foreach var of varlist parspdfc* parcdufc*  {
  lab val `var' null
}


local opt "sort connect(J J) legend(off) xtick(5) ylab(-1(.5)1) ytitle(coef.) "

sum parspdfl0 if parspdfl0 ~= 0
local noint = r(mean)
sum parspdfl1 if parspdfl1 ~= 0
local int = r(mean)
graph twoway line parspdfl* t, ///
	`opt' xlab(5 "New SPD Partner") name(g1, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 

sum parcdufl0 if parcdufl0 ~= 0
local noint = r(mean)
sum parcdufl1 if parcdufl1 ~= 0
local int = r(mean)

graph twoway line parcdufl* t, ///
	`opt' xlab(5 "New CDU Partner") name(g2, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 
sum parspdfc0 if parspdfc0 ~= 0
local noint = r(mean)
sum parspdfc1 if parspdfc1 ~= 0
local int = r(mean)
graph twoway line parspdfc* t, ///
	`opt' xlab(5 "New SPD Partner") name(g3, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 
sum parcdufc0 if parcdufc0 ~= 0
local noint = r(mean)
sum parcdufc1 if parcdufc1 ~= 0
local int = r(mean)
graph twoway line parcdufc* t, ///
	`opt' xlab(5 "New CDU Partner") name(g4, replace) ///
       text(`noint' 10 "low pol. interest", placement(nw)) ///
       text(`int' 10 "high pol. interest", placement(nw)) 

graph combine g1 g2, ycommon xcommon title(SPD-Model) rows(1) name(gleft, replace)
graph combine g3 g4, ycommon xcommon title(CDU/CSU-Model) rows(1) name(gcons, replace)

graph combine gleft gcons, rows(2) xcommon ycommon note("Do File: grmod2.do") 
graph export figure5.wmf, replace




exit



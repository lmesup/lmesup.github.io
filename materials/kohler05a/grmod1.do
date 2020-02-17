* Graphik Model 1 (augenblicklich, permanent)
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
capture use mod1b, clear
if _rc ~= 0 {
	do anmod1b
	use mod1b, clear
}
sort uv

mmerge uv using be
drop _merge

*  Generating Timepaths                                   
*  --------------------

gen finder = .
gen t = _n in 1/10
lab var t " "
lab val t t
lab def t 5 "event"

foreach piece in arbsel selarb  {
  replace finder = uv=="e`piece'"
  sort finder
  * Left-Model
  gen `piece'fl = 0
  replace `piece'fl = `piece'fl + bleft1[_N] if t>=5 & t ~= .
  gen `piece'bl = bleft_be[_N] if t ~= .
  * Conservatives-Model
  gen `piece'fc = 0
  replace `piece'fc = `piece'fc + bkons1[_N] if t>=5 & t ~= .
  gen `piece'bc = bkons_be[_N] if t ~= .
}


* Graphik
* -------

* Delete some ylabels
foreach var of varlist arbselfc arbselbc selarbfc selarbbc {
  lab val `var' null
}
lab def null 0 " "


local opt `"sort connect(J) legend(off) xtick(5) ylab(-1(.5)1) ytitle(coef.)"'
graph twoway line arbselfl arbselbl t, `opt' xlab(5 "Worker to Self-employed") name(g1, replace) 
graph twoway line selarbfl selarbbl t, `opt' xlab(5 "Self-employed to Worker") name(g2, replace)
graph twoway line arbselfc arbselbc t, `opt' xlab(5 "Worker to Self-employed") name(g3, replace)
graph twoway line selarbfc selarbbc t, `opt' xlab(5 "Self-employed to Worker") name(g4, replace)

graph combine g1 g2, ycommon xcommon title(SPD-Model) rows(1) name(gleft, replace)
graph combine g3 g4, ycommon xcommon title(CDU/CSU-Model) rows(1) name(gcons, replace)

graph combine gleft gcons, rows(2) xcommon ycommon note("Do File: grmod1.do")
graph export figure3.wmf, replace

exit



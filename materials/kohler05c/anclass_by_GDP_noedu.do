* b-Coeff of Class by plurality (Nonparametric Method)
* ----------------------------------------------------
	
version 8.2
	set more off
	capture log close
	
	// Data
	// ----

	use ///
	  s_cntry hh1 hh2a hh2b ///
	  q17 q19* q20_* q23b q25 q26  q27* q29a q29b q31 ///
	  emplstat hhstat teacat ///
	  using  "$dublin/eqls_4", clear

	label define yesno 0 "no" 1 "yes"
	

	// Attitudes
	// ---------

	// Live-Satisfaction
	ren q31 lsat

	// Trust in Social System
	gen trust = (q27a + q27b) - 1
	sum trust, meanonly
	replace trust = r(max)+1 - trust

	// Cleavage-Awareness
	gen clevaware = (q29a + q29b) - 2
	sum clevaware, meanonly
	replace clevaware = r(max)+1 - clevaware

	local attitudes "lsat trust clevaware"
	
	// Behavior
	// --------

	// Vote Participation
	gen voter:yesno = q25==1 if q25 < 3

	// Religiousity 
	sum q26, meanonly
	gen rel = r(max)+1-q26

	// Work for Voluntary Organization 
	gen vol:yesno = q23b==1 if q23b < .

	local behavior "voter rel vol"

	// Ressources
	// ----------

	// Rooms per Person
	replace q17 = . if q17 == 75  // 1 obs. with 75 rooms seems to be a Data-Error
	gen roomspers = q17/hh1

	// Problems of Accomodation
	egen accom = neqany(q19*), values(1)
	replace accom = . if q19_1 >= . | q19_2 >= . | q19_3 >= . | q19_4 >= .
	
	// Afford of Goods
	egen afford = neqany(q20_*), values(2)
	replace afford = . if q20_1 >= . | q20_2 >= . | q20_3 >= . | q20_4 >= . ///
	    | q20_5 >= . | q20_6 >= . 


	local ressources "roomspers accom afford"
	
	// Independent Variables
	// ----------------------

	// Gender
	gen men:yesno = hh2a==1 if hh2a < .
	drop hh2a
	
	// Age
	gen age = hh2b 
	gen age2 = age^2

	// In Education
	gen inedu:yesno = emplstat == 5 | teacat == 4
	
	// Employment-Status
	gen emp:emp = emplstat
	replace emp = 5 if emplstat >= 5  // "Missing" + "Other" + "Still Studying"
	label def emp 1 "employed" 2 "homemaker" 3 "unemployed" 4 "retired" 5 "Other"
	drop emplstat
	
	// Education
	gen edu:edu = teacat
	replace edu = 4 if edu >= . // "Missing" + "Still Studying" = "Other"
	label define edu 1 "low" 2 "intermediate" 3 "high"
	drop teacat

   // "Class" of Main-Earner 
	ren hhstat class
	replace class = 7 if class >= .
	label define hhstat 7 "other", modify


	// Make Dummy Variables
	// --------------------

	foreach var of varlist emp edu class {
		quietly tab `var', gen(`var')
	}


	// Initialize  Postfile
	// --------------------

	local depvars "`attitudes' `behavior' `ressources'"
	foreach name of local depvars {
		local postterm `"`postterm' n`name' bclass2`name' bclass3`name' bclass4`name' bclass5`name'"'
	}

	tempfile coefs
	tempname coef
	postfile `coef' s_cntry  `postterm' using `coef', replace

	// Regression Models
	// -----------------

	levels s_cntry, local(K)
	foreach k of local K {
		local postterm (`k')
		foreach depvar of local depvars {
			local model = cond("`depvar'" == "voter" | "`depvar'" == "vol","logit","regress")
			qui `model'  `depvar' men age age2 inedu emp2-emp5 class2-class7 if s_cntry==`k'
			local N = e(N)
			local class2 = _b[class2]
			local class3 = _b[class3]
			capture local class4 = _b[class4]  // High Discrimination for Malta
			capture local class5 = _b[class5]  // High Discrimination for Romania
			local postterm `" `postterm' (`N') (`class2')  (`class3') (`class4') (`class5') "' 
		}
		post `coef' `postterm'
	}
	
	// End Matters
	
	postclose `coef'
	use `coef', clear
	sort s_cntry
	save `coef', replace

	use plurality_ci
	sort s_cntry
	merge s_cntry using `coef'
	drop _merge


	// Graph Class-Coefficients by GDP
	set scheme s1mono
	
	// Calculate contrasts
	// -------------------

	foreach depvar in ///
	  lsat trust clevaware  ///
	  voter rel vol ///
	  roomspers accom afford {
		gen sworkuwork`depvar' = bclass4`depvar' - bclass5`depvar'
		lowess sworkuwork`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(sworkuwork`depvar'lw)  nodraw
		gen ser1uwork`depvar' = - bclass5`depvar'
		lowess ser1uwork`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(ser1uwork`depvar'lw)  nodraw
		gen ser2uwork`depvar' = bclass2`depvar' - bclass5`depvar'
		lowess ser2uwork`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(ser2uwork`depvar'lw)   nodraw
		gen selfuwork`depvar' =  bclass3`depvar' - bclass5`depvar' 
		lowess selfuwork`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(selfuwork`depvar'lw)    nodraw
	}

	// Luxemburg
	sort gdppcap1
	gen gdplux = gdppcap1[_N]
	
	gen sworkuworklux = . 
	gen ser1uworklux = . 
	gen selfuworklux  = . 
	gen ser2uworklux  = . 


	local i 1
	foreach depvar in ///
	  lsat trust clevaware  ///
	  voter rel vol ///
	  roomspers accom afford {
		replace sworkuworklux  = sworkuwork`depvar'[_N] in `i'
		replace ser1uworklux  = ser1uwork`depvar'[_N] in `i'
		replace selfuworklux  =  selfuwork`depvar'[_N] in `i'
		replace ser2uworklux = ser2uwork`depvar'[_N] in `i++'
	}

	// Common Options
	// --------------
	
	local opt `" sort clwidth(*2) yaxis(1 2) xaxis(1 2) "'

	local twopt `"legend(off) "'
	local twopt `" `twopt' yscale(range(-2 2) axis(1)) yscale(range(-2 2) axis(2))  "'
	local twopt `" `twopt' ylabel(none, axis(1))  ylabel(none, axis(2)) "'
	local twopt `" `twopt' ytitle("", axis(1)) ytitle("", axis(2)) "'
	local twopt `" `twopt' xlabel(none, axis(1)) xlabel(none, axis(2)) "'
	local twopt `" `twopt' xtitle("", axis(1)) xtitle("", axis(2)) "'
	
	local mostopt `" ylabel(-2(1)2, grid gstyle(dot) nogextend axis(1))   "'
	local mostopt `" `mostopt' xscale(range(4000 28000) axis(1)) xscale(range(4000 28000) axis(2)) "'
	local mostopt `" `mostopt' name(most, replace)  nodraw "'

	local luxopt  `"  xscale(range(45000 45720) axis(1)) xscale(range(45000 45720) axis(2))"'
	local luxopt  `" `luxopt'  fxsize(10) name(lux, replace) nodraw "'
	local luxopt  `" `luxopt'  ytick(-2(1)2, grid gstyle(dot) gextend axis(2)) "'

   local fmostopt `" xtick(5000(5000)25000, axis(2)) xmtick(7500(5000)27500, axis(2)) "' 
   local fluxopt  `" xtick(45360, axis(2)) "'

   local lmostopt `" xlabel(5000(5000)25000, axis(1)) xmtick(7500(5000)27500, axis(1)) "' 
	local lmostopt `" `lmostopt' xtitle("Pro-Kopf BIP in Kaufkraftparitäten", axis(1)) "'
	local lluxopt  `"  xlabel(45360, axis(1)) xtitle(" ") "'



	// Dienstklasse 1
	// --------------

	graph twoway ///
	  (line selfuworklsatlw gdppcap1, `opt') ///
	  (line selfuworktrustlw gdppcap1, `opt' ) ///
	  (line selfuworkclevawarelw gdppcap1, `opt' ) ///
	  (line selfuworkvoterlw gdppcap1, `opt' ) ///
	  (line selfuworkrellw gdppcap1, `opt' ) ///
	  (line selfuworkvollw gdppcap1, `opt' ) ///
	  (line selfuworkroomsperslw gdppcap1, `opt' ) ///
	  (line selfuworkaccomlw gdppcap1, `opt' ) ///
	  (line selfuworkaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' `fmostopt' ytitle(`"Selbständige "', axis(1))

	graph twoway ///
	  (scatter selfuworklux gdplux, `opt'  mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' `fluxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c1, replace) fysize(46) ysize(7.88) xsize(3.6)


	// Facharbeiter
	// ------------
	
	graph twoway ///
	  (line ser1uworklsatlw gdppcap1 , `opt') ///
	  (line ser1uworktrustlw gdppcap1, `opt' ) ///
	  (line ser1uworkclevawarelw gdppcap1, `opt' ) ///
	  (line ser1uworkvoterlw gdppcap1, `opt' ) ///
	  (line ser1uworkrellw gdppcap1, `opt' ) ///
	  (line ser1uworkvollw gdppcap1, `opt' ) ///
	  (line ser1uworkroomsperslw gdppcap1, `opt' ) ///
	  (line ser1uworkaccomlw gdppcap1, `opt' ) ///
	  (line ser1uworkaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle(`"Höhere "White Collar" "', axis(1))

	graph twoway ///
	  (scatter ser1uworklux gdplux, `opt' mcolor(black) ms(Oh)   )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c2, replace)  fysize(46) ysize(7.88) xsize(3.6)


	// Diensklasse 2
	// -------------

	graph twoway ///
	  (line ser2uworklsatlw gdppcap1 , `opt') ///
	  (line ser2uworktrustlw gdppcap1, `opt' ) ///
	  (line ser2uworkclevawarelw gdppcap1, `opt' ) ///
	  (line ser2uworkvoterlw gdppcap1, `opt' ) ///
	  (line ser2uworkrellw gdppcap1, `opt' ) ///
	  (line ser2uworkvollw gdppcap1, `opt' ) ///
	  (line ser2uworkroomsperslw gdppcap1, `opt' ) ///
	  (line ser2uworkaccomlw gdppcap1, `opt' ) ///
	  (line ser2uworkaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle(`"Niedere "White Collar" "', axis(1)) 

	graph twoway ///
	  (scatter ser2uworklux gdplux, `opt' mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c3, replace) fysize(46) ysize(7.88) xsize(3.6)


	// Selbständige
	// ------------

	graph twoway ///
	  (line sworkuworklsatlw gdppcap1 , `opt') ///
	  (line sworkuworktrustlw gdppcap1, `opt' ) ///
	  (line sworkuworkclevawarelw gdppcap1, `opt' ) ///
	  (line sworkuworkvoterlw gdppcap1, `opt' ) ///
	  (line sworkuworkrellw gdppcap1, `opt' ) ///
	  (line sworkuworkvollw gdppcap1, `opt' ) ///
	  (line sworkuworkroomsperslw gdppcap1, `opt' ) ///
	  (line sworkuworkaccomlw gdppcap1, `opt' ) ///
	  (line sworkuworkaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' `lmostopt' ytitle(`"Facharbeiter"', axis(1))

	graph twoway ///
	  (scatter sworkuworklux gdplux, `opt' mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' `lluxopt'
	
	graph combine 	most lux, ycommon imargin(zero) name(c4, replace)


	graph combine c1 c2 c3 c4, ///
	  iscale(*1.8) cols(1) imargin(zero) name(data, replace) nodraw

	// Legend
	// ------
	// thanks vwiggins@stata.com

	// Legend
	tw line ser1uworklsatlw ser1uworktrustlw 	ser1uworkclevawarelw ser1uworkvoterlw ///
	  ser1uworkrellw ser1uworkvollw ser1uworkroomsperslw ser1uworkaccomlw ///
	  ser1uworkaffordlw gdppcap1, clwidth(*2 *2 *2 *2 *2 *2 *2 *2 *2) ///
	legend( ///
	  lab(1 "Lebenszuf.") ///
	  lab(2 "Inst.-Vertr.") ///
	  lab(3 "Cleav.-Wahrn.") ///
	  lab(4 "Wahlbet.") ///
	  lab(5 "Kirchgang") ///
	  lab(6 "Ver.-Mitarb.") ///
	  lab(7 "Wohnungsgr.") ///
	  lab(8 "Wohnq.-prob.") ///
	  lab(9 "Geldprob.") ///
	  cols(3) ) name(leg, replace) yscale(off) xscale(off) nodraw 

	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
   _gm_edit .leg.ystretch.set fixed

	graph combine data leg, cols(1) xsize(3.6) ysize(7.88) 

	
exit




	

	
	


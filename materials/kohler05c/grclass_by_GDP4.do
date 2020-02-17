* Graph Class-Coefficients by GDP
version 8.2
	set more off
	set scheme s1mono
	
	// Data
	use plurality_ci_b2, clear

	// Calculate contrasts
	// -------------------

	foreach depvar in ///
	  lsat health  accom afford envqual {
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
	  lsat health envqual accom afford {
		replace sworkuworklux  = sworkuwork`depvar'[_N] in `i'
		replace ser1uworklux  = ser1uwork`depvar'[_N] in `i'
		replace selfuworklux  =  selfuwork`depvar'[_N] in `i'
		replace ser2uworklux = ser2uwork`depvar'[_N] in `i++'
	}

	// Common Options
	// --------------
	
	local opt `" sort clwidth(*2) clcolor(black) yaxis(1 2) xaxis(1 2) "'

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
	local lluxopt  `"  xlabel(45360 "LUX", axis(1)) xtitle(" ") "'



	// Dienstklasse 1
	// --------------

graph twoway ///
	  (line selfuworklsatlw gdppcap1, `opt'    clpattern(solid)) ///	 
	  (line selfuworkhealthlw gdppcap1, `opt'  clpattern(dash)) ///	 
	  (line selfuworkenvquallw gdppcap1, `opt' clpattern(longdash_dot)) ///		 
	  (line selfuworkaccomlw gdppcap1, `opt'   clpattern(dash_dot)) ///
	  (line selfuworkaffordlw gdppcap1, `opt'  clpattern(longdash)) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' `fmostopt' ytitle(`"Selbständige "', axis(1))

	graph twoway ///
	  (scatter selfuworklux gdplux, `opt'  mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' `fluxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c1, replace) fysize(46) ysize(7.88) xsize(3.6)


	// Facharbeiter
	// ------------
	
	graph twoway ///
	  (line ser1uworklsatlw gdppcap1 , `opt'   clpattern(solid))    ///	
	  (line ser1uworkhealthlw gdppcap1, `opt'  clpattern(dash))     ///	 
	  (line ser1uworkenvquallw gdppcap1, `opt' clpattern(longdash_dot))      ///		
	  (line ser1uworkaccomlw gdppcap1, `opt'   clpattern(dash_dot)) ///
	  (line ser1uworkaffordlw gdppcap1, `opt'  clpattern(longdash)) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle(`"Höhere "White Collar" "', axis(1))

	graph twoway ///
	  (scatter ser1uworklux gdplux, `opt' mcolor(black) ms(Oh)   )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c2, replace)  fysize(46) ysize(7.88) xsize(3.6)


	// Diensklasse 2
	// -------------

	graph twoway ///
	  (line ser2uworklsatlw gdppcap1 , `opt'   clpattern(solid))     ///
	  (line ser2uworkhealthlw gdppcap1, `opt'  clpattern(dash))      ///
	  (line ser2uworkenvquallw gdppcap1, `opt' clpattern(longdash_dot))       ///
	  (line ser2uworkaccomlw gdppcap1, `opt'   clpattern(dash_dot))  ///
	  (line ser2uworkaffordlw gdppcap1, `opt'  clpattern(longdash))  ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle(`"Niedere "White Collar" "', axis(1)) 

	graph twoway ///
	  (scatter ser2uworklux gdplux, `opt' mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c3, replace) fysize(46) ysize(7.88) xsize(3.6)


	// Selbständige
	// ------------

	graph twoway ///
	  (line sworkuworklsatlw gdppcap1 , `opt'   clpattern(solid))     ///
	  (line sworkuworkhealthlw gdppcap1, `opt'  clpattern(dash))      ///
	  (line sworkuworkenvquallw gdppcap1, `opt' clpattern(longdash_dot))       ///
	  (line sworkuworkaccomlw gdppcap1, `opt'   clpattern(dash_dot))  ///
	  (line sworkuworkaffordlw gdppcap1, `opt'  clpattern(longdash))  ///
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
	tw line ser1uworklsatlw ser1uworkhealthlw ser1uworkenvquallw ///
	ser1uworkaccomlw ser1uworkaffordlw gdppcap1 ///
	  , clwidth(*2 *2 *2 *2 *2 ) ///
	legend( ///
	  lab(1 "Lebenszuf.") ///
	  lab(2 "Gesundheit") ///
	  lab(3 "Umweltqual.") ///
	  lab(4 "Wohnq.-prob.") ///
	  lab(5 "Geldprob.") ///
	  cols(2) ) name(leg, replace) yscale(off) xscale(off) nodraw  ///
	  clcolor(black black black black black) clpattern(solid dash longdash_dot dash_dot longdash)

	
	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
   _gm_edit .leg.ystretch.set fixed

	graph combine data leg, cols(1) xsize(3.6) ysize(7.88) 

	graph export class_by_GDP4.eps, replace
	
exit



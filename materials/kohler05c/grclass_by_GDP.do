* Graph Class-Coefficients by GDP
version 8.2
	set more off
	set scheme s1mono
	
	// Data
	use plurality_ci_b, clear

	// Calculate contrasts
	// -------------------

	foreach depvar in ///
	  lsat trust clevaware  ///
	  voter rel vol ///
	  roomspers accom afford {
		gen sworkself`depvar' = bclass4`depvar' - bclass3`depvar'
		lowess sworkself`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(sworkself`depvar'lw)  nodraw
		gen uworkself`depvar' = bclass5`depvar' - bclass3`depvar'
		lowess uworkself`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(uworkself`depvar'lw)   nodraw
		gen ser1self`depvar' =  0 - bclass3`depvar'
		lowess ser1self`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(ser1self`depvar'lw)   nodraw
		gen ser2self`depvar' = bclass2`depvar' - bclass3`depvar'
		lowess ser2self`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(ser2self`depvar'lw)   nodraw
	}


	// Luxemburg
	sort gdppcap1
	gen gdplux = gdppcap1[_N]
	
	gen sworkselflux = . 
	gen uworkselflux = . 
	gen ser1selflux  = . 
	gen ser2selflux  = . 


	local i 1
	foreach depvar in ///
	  lsat trust clevaware  ///
	  voter rel vol ///
	  roomspers accom afford {
		replace sworkselflux  = sworkself`depvar'[_N] in `i'
		replace uworkselflux  = uworkself`depvar'[_N] in `i'
		replace ser1selflux  =  ser1self`depvar'[_N] in `i'
		replace ser2selflux = ser2self`depvar'[_N] in `i++'
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
	local lmostopt `" `lmostopt' xtitle("Pro-Kopf-BIP in Kaufkraftparitäten", axis(1)) "'
	local lluxopt  `"  xlabel(45360, axis(1)) xtitle(" ") "'



	// Un- u. angelernte Arbeiter vs. Selbständige
	// -------------------------------------------

	graph twoway ///
	  (line uworkselflsatlw gdppcap1, `opt') ///
	  (line uworkselftrustlw gdppcap1, `opt' ) ///
	  (line uworkselfclevawarelw gdppcap1, `opt' ) ///
	  (line uworkselfvoterlw gdppcap1, `opt' ) ///
	  (line uworkselfrellw gdppcap1, `opt' ) ///
	  (line uworkselfvollw gdppcap1, `opt' ) ///
	  (line uworkselfroomsperslw gdppcap1, `opt' ) ///
	  (line uworkselfaccomlw gdppcap1, `opt' ) ///
	  (line uworkselfaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' `fmostopt' ytitle("Un- und angelernte Arbeiter", axis(1)) 

	graph twoway ///
	  (scatter uworkselflux gdplux, `opt'  mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' `fluxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c1, replace) fysize(46) ysize(7.88) xsize(3.6)

	// Facharbeiter vs. Selbständige
	// -------------------------

	graph twoway ///
	  (line sworkselflsatlw gdppcap1 , `opt') ///
	  (line sworkselftrustlw gdppcap1, `opt' ) ///
	  (line sworkselfclevawarelw gdppcap1, `opt' ) ///
	  (line sworkselfvoterlw gdppcap1, `opt' ) ///
	  (line sworkselfrellw gdppcap1, `opt' ) ///
	  (line sworkselfvollw gdppcap1, `opt' ) ///
	  (line sworkselfroomsperslw gdppcap1, `opt' ) ///
	  (line sworkselfaccomlw gdppcap1, `opt' ) ///
	  (line sworkselfaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle("Facharbeiter", axis(1))

	graph twoway ///
	  (scatter sworkselflux gdplux, `opt' mcolor(black) ms(Oh)   )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c2, replace)  fysize(46) ysize(7.88) xsize(3.6)


	// Service 2 vs. Selbständige
	// --------------------------

	graph twoway ///
	  (line ser2selflsatlw gdppcap1 , `opt') ///
	  (line ser2selftrustlw gdppcap1, `opt' ) ///
	  (line ser2selfclevawarelw gdppcap1, `opt' ) ///
	  (line ser2selfvoterlw gdppcap1, `opt' ) ///
	  (line ser2selfrellw gdppcap1, `opt' ) ///
	  (line ser2selfvollw gdppcap1, `opt' ) ///
	  (line ser2selfroomsperslw gdppcap1, `opt' ) ///
	  (line ser2selfaccomlw gdppcap1, `opt' ) ///
	  (line ser2selfaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle(`"Niedere "White Collar" "', axis(1)) 

	graph twoway ///
	  (scatter ser2selflux gdplux, `opt' mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c3, replace) fysize(46) ysize(7.88) xsize(3.6)


	// Service I  vs. Selbständige
	// ---------------------------

	graph twoway ///
	  (line ser1selflsatlw gdppcap1 , `opt') ///
	  (line ser1selftrustlw gdppcap1, `opt' ) ///
	  (line ser1selfclevawarelw gdppcap1, `opt' ) ///
	  (line ser1selfvoterlw gdppcap1, `opt' ) ///
	  (line ser1selfrellw gdppcap1, `opt' ) ///
	  (line ser1selfvollw gdppcap1, `opt' ) ///
	  (line ser1selfroomsperslw gdppcap1, `opt' ) ///
	  (line ser1selfaccomlw gdppcap1, `opt' ) ///
	  (line ser1selfaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' `lmostopt' ytitle(`"Höhere "White Collar" "', axis(1))

	graph twoway ///
	  (scatter ser1selflux gdplux, `opt' mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' `lluxopt'
	
	graph combine 	most lux, ycommon imargin(zero) name(c4, replace)


	graph combine c1 c2 c3 c4, ///
	  iscale(*1.8) cols(1) imargin(zero) name(data, replace) nodraw

	// Legend
	// ------
	// thanks vwiggins@stata.com

	// Legend
	tw line uworkselflsatlw uworkselftrustlw 	uworkselfclevawarelw uworkselfvoterlw ///
	  uworkselfrellw uworkselfvollw uworkselfroomsperslw uworkselfaccomlw ///
	  uworkselfaffordlw gdppcap1, clwidth(*2 *2 *2 *2 *2 *2 *2 *2 *2) ///
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

	graph export class_by_GDP.eps, replace
	
exit



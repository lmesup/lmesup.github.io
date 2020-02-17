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
		gen sworkhserv`depvar' = bclass4`depvar' 
		lowess sworkhserv`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(sworkhserv`depvar'lw)  nodraw
		gen uworkhserv`depvar' = bclass5`depvar' 
		lowess uworkhserv`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(uworkhserv`depvar'lw)   nodraw
		gen selfhserv`depvar' =  bclass3`depvar'
		lowess selfhserv`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(selfhserv`depvar'lw)   nodraw
		gen ser2hserv`depvar' = bclass2`depvar' 
		lowess ser2hserv`depvar' gdppcap1 if iso3166_2 ~= "LU", gen(ser2hserv`depvar'lw)   nodraw
	}


	// Luxemburg
	sort gdppcap1
	gen gdplux = gdppcap1[_N]
	
	gen sworkhservlux = . 
	gen uworkhservlux = . 
	gen selfhservlux  = . 
	gen ser2hservlux  = . 


	local i 1
	foreach depvar in ///
	  lsat trust clevaware  ///
	  voter rel vol ///
	  roomspers accom afford {
		replace sworkhservlux  = sworkhserv`depvar'[_N] in `i'
		replace uworkhservlux  = uworkhserv`depvar'[_N] in `i'
		replace selfhservlux  =  selfhserv`depvar'[_N] in `i'
		replace ser2hservlux = ser2hserv`depvar'[_N] in `i++'
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



	// Un- u. angelernte Arbeiter vs. Selbständige
	// -------------------------------------------

	graph twoway ///
	  (line uworkhservlsatlw gdppcap1, `opt') ///
	  (line uworkhservtrustlw gdppcap1, `opt' ) ///
	  (line uworkhservclevawarelw gdppcap1, `opt' ) ///
	  (line uworkhservvoterlw gdppcap1, `opt' ) ///
	  (line uworkhservrellw gdppcap1, `opt' ) ///
	  (line uworkhservvollw gdppcap1, `opt' ) ///
	  (line uworkhservroomsperslw gdppcap1, `opt' ) ///
	  (line uworkhservaccomlw gdppcap1, `opt' ) ///
	  (line uworkhservaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' `fmostopt' ytitle("Un- und angelernte Arbeiter", axis(1)) 

	graph twoway ///
	  (scatter uworkhservlux gdplux, `opt'  mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' `fluxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c1, replace) fysize(46) ysize(7.88) xsize(3.6)

	// Facharbeiter vs. Selbständige
	// -------------------------

	graph twoway ///
	  (line sworkhservlsatlw gdppcap1 , `opt') ///
	  (line sworkhservtrustlw gdppcap1, `opt' ) ///
	  (line sworkhservclevawarelw gdppcap1, `opt' ) ///
	  (line sworkhservvoterlw gdppcap1, `opt' ) ///
	  (line sworkhservrellw gdppcap1, `opt' ) ///
	  (line sworkhservvollw gdppcap1, `opt' ) ///
	  (line sworkhservroomsperslw gdppcap1, `opt' ) ///
	  (line sworkhservaccomlw gdppcap1, `opt' ) ///
	  (line sworkhservaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle("Facharbeiter", axis(1))

	graph twoway ///
	  (scatter sworkhservlux gdplux, `opt' mcolor(black) ms(Oh)   )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c2, replace)  fysize(46) ysize(7.88) xsize(3.6)


	// Service 2 vs. Selbständige
	// --------------------------

	graph twoway ///
	  (line ser2hservlsatlw gdppcap1 , `opt') ///
	  (line ser2hservtrustlw gdppcap1, `opt' ) ///
	  (line ser2hservclevawarelw gdppcap1, `opt' ) ///
	  (line ser2hservvoterlw gdppcap1, `opt' ) ///
	  (line ser2hservrellw gdppcap1, `opt' ) ///
	  (line ser2hservvollw gdppcap1, `opt' ) ///
	  (line ser2hservroomsperslw gdppcap1, `opt' ) ///
	  (line ser2hservaccomlw gdppcap1, `opt' ) ///
	  (line ser2hservaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' ytitle(`"Niedere "White Collar" "', axis(1)) 

	graph twoway ///
	  (scatter ser2hservlux gdplux, `opt' mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' 
	
	graph combine 	most lux, ycommon imargin(zero) name(c3, replace) fysize(46) ysize(7.88) xsize(3.6)


	// Service I  vs. Selbständige
	// ---------------------------

	graph twoway ///
	  (line selfhservlsatlw gdppcap1 , `opt') ///
	  (line selfhservtrustlw gdppcap1, `opt' ) ///
	  (line selfhservclevawarelw gdppcap1, `opt' ) ///
	  (line selfhservvoterlw gdppcap1, `opt' ) ///
	  (line selfhservrellw gdppcap1, `opt' ) ///
	  (line selfhservvollw gdppcap1, `opt' ) ///
	  (line selfhservroomsperslw gdppcap1, `opt' ) ///
	  (line selfhservaccomlw gdppcap1, `opt' ) ///
	  (line selfhservaffordlw gdppcap1, `opt' ) ///
	  if iso3166_2 ~= "LU"  ///
	  , `twopt' `mostopt' `lmostopt' ytitle(`"Selbständige"', axis(1))

	graph twoway ///
	  (scatter selfhservlux gdplux, `opt' mcolor(black) ms(Oh) )    ///
	  ,  `twopt' `luxopt' `lluxopt'
	
	graph combine 	most lux, ycommon imargin(zero) name(c4, replace)


	graph combine c1 c2 c3 c4, ///
	  iscale(*1.8) cols(1) imargin(zero) name(data, replace) nodraw

	// Legend
	// ------
	// thanks vwiggins@stata.com

	// Legend
	tw line uworkhservlsatlw uworkhservtrustlw 	uworkhservclevawarelw uworkhservvoterlw ///
	  uworkhservrellw uworkhservvollw uworkhservroomsperslw uworkhservaccomlw ///
	  uworkhservaffordlw gdppcap1, clwidth(*2 *2 *2 *2 *2 *2 *2 *2 *2) ///
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

	graph export class_by_GDP2.eps, replace
	
exit



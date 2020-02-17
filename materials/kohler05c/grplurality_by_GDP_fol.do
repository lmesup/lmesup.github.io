* Entropy and Deviance by GDP
* ---------------------------

version 8.2

	// Data
	// ----

	use plurality_ci, clear

	encode eu, gen(EU)
	recode EU  3=1 2=3 1=2
	label define EU 1 "EU-15" 2 "AC-10" 3 "CC-3", modify

	separate entropy_s, by(EU)
	separate deviance, by(EU)
	
	// Common Options
	// --------------

	local opt `" `opt' ylabel(none, axis(1)) "'
	local opt `" `opt' ylabel(none, axis(2)) "'
	local opt `" `opt' xlabel(none, axis(1)) "'
	local opt `" `opt' xlabel(none, axis(2)) "'
	local opt `" `opt' ytitle("", axis(1)) "'
	local opt `" `opt' ytitle("", axis(2)) "'
	local opt `" `opt' xtitle("", axis(1)) "'
	local opt `" `opt' xtitle("", axis(2)) "'
	local opt `" `opt' yaxis(1 2) xaxis(1 2)"'
	local twopt `" legend(off) "'

	// Most Countries, Entropy
	// -----------------------
	
	local graph1opt `" ylabel(.78(.04).9, axis(1) grid gstyle(dot) nogextend) ytitle("Standardisierte Entropie")   "'
	local graph1opt `" `graph1opt' xtick(5000(5000)25000, axis(2)) xmtick(7500(5000)27500, axis(2))  "'
	local graph1opt `" `graph1opt' xtitle(" ", axis(2)) "'

	graph twoway ///
	  scatter entropy_s? gdppcap1 [weight = Npl], `opt'                ||  ///
	  lowess  entropy_s gdppcap1, clstyle(p1) bw(.7) `opt'             ||  ///
	  if iso3166_2 ~= "LU"                                                 ///
	  , `graph1opt' ///
	    `twopt' name(emost, replace) nodraw

	// Luxemburg, Entropy
	// ------------------
	
	graph twoway ///
	  scatter entropy_s gdppcap1, mlabel(iso3166_2) mlabpos(12) `opt' ||    ///
	  if iso3166_2 == "LU"  ///
	  , ytick(.78(.04).9, axis(2) grid gstyle(dot)) xscale(range(45000 45720) axis(1)) xtick(45360, axis(2))   ///
	    xscale(range(45000 45720) axis(2))                                         ///
      xtitle(" ", axis(2)) fxsize(10)  `twopt' name(elux, replace) nodraw
	

	// Most Countries, Deviance
	// -----------------------
	
	local graph3opt `" ylabel(.4(.1).7, axis(1) grid gstyle(dot) nogextend) ytitle("Normierte Devianz")   "'
	local graph3opt `" `graph3opt' xlabel(5000(5000)25000, axis(1))  "'
	local graph3opt `" `graph3opt' yscale(range(.4 .73) reverse axis(1)) yscale(range(.4 .73) reverse axis(2))  "'
	local graph3opt `" `graph3opt' xmtick(7500(5000)27500, axis(1))  "'
	local graph3opt `" `graph3opt' xtitle("Pro-Kopf-BIP in Kaufkraftparitäten", axis(1)) "'

	graph twoway ///
	  scatter deviance? gdppcap1 [weight = Npl], `opt'                ||  ///
	  lowess  deviance gdppcap1, clstyle(p1) bw(.7) `opt'             ||  ///
	  if iso3166_2 ~= "LU"                                                ///
	  , `graph3opt' ///
	    `twopt' name(dmost, replace) nodraw

	// Luxemburg, Deviance
	// ------------------
	
	graph twoway ///
	  scatter deviance gdppcap1, mlabel(iso3166_2) mlabpos(12) `opt' ||    ///
	  if iso3166_2 == "LU"  ///
	  , ytick(.4(.1).7, axis(2) grid gstyle(dot) ) yscale(range(.4 .73) reverse axis(1)) yscale(range(.4 .73) reverse axis(2)) ///
	  xscale(range(45000 45720) axis(1)) xlabel(45360, axis(1))   ///
	  xscale(range(45000 45720) axis(2))                                                ///
	  xtitle(" ", axis(1))  fxsize(10)  `twopt' name(dlux, replace) nodraw
	
	// Combine them
	// ------------
	
	// EMost + ELux
	graph combine emost elux, name(g1, replace) ycommon imargin(zero) iscale(*1.5)
	graph combine dmost dlux, name(g2, replace) ycommon imargin(zero) iscale(*1.5)

	// Legend
	scatter entropy_s? gdppcap1,  ///
	  legend(lab(1 "EU-15") lab(2 "AC-10") lab(3 "CC-3") order(3 2 1) rows(1)) ///
	  name(leg, replace) yscale(off) xscale(off) nodraw

	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
   _gm_edit .leg.ystretch.set fixed
	
	// Combine them
	graph combine g1 g2 leg , cols(1) imargin(tiny) ysize(2.25) xsize(3)  iscale(*1.2)
	graph export plurality_by_GDP_fol.eps, replace
	
	
	exit
	

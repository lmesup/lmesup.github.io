* Sampling Methods and Features by Country and Survey-Program 
* kohler@wz-berlin.de

version 9

	drop _all
	set memory 90m
	set more off
	set scheme wzb
	
	// Data
	use svydat01, clear

	// Aggregate Data only
	by survey ctrname, sort: keep if _n==1
	keep survey ctrname eu pretest-quota


	// Sampling Method
	// ---------------
	
	label define sample ///
	  1 "SRS" ///
	  2 "Cluster + individual register" ///
	  3 "Cluster + address register" ///
	  4 "Cluster + random-route" ///
	  5 "Unspecified" ///
	  6 "Quota" ///

	// EB
	gen sample:sample = 4 if survey == "EB 62.1"

	// EQLS 
	replace sample = 2 if survey == "EQLS 2003"  & ///
	  ( ctrname ==  "Ireland" ///
	  | ctrname ==  "Italy" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "Sweden" ///
	  | ctrname ==  "Czech Republic" ///
	  | ctrname ==  "Estonia" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Latvia" ///
	  | ctrname ==  "Poland" ///
	  | ctrname ==  "Romania" )
	replace sample = 4 if survey == "EQLS 2003" &  sample >= .

	// EVS
	replace sample = 1 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Denmark" ///
	  | ctrname ==  "Iceland" ///
	  | ctrname ==  "Malta" ///
	  )

	replace sample = 2 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Belarus" ///
	  |	ctrname ==  "Ireland" ///
	  | ctrname == "Romania" ///
	  | ctrname == "Sweden" ///
	  | ctrname == "Slovenia" ///
	  )
	
	replace sample = 4 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Germany" ///
	  | ctrname ==  "Greece" ///
	  | ctrname ==  "Bulgaria" ///
	  )
	
	replace sample = 5 if survey == "EVS 1999" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "Belgium" ///
	  | ctrname ==  "Croatia" ///
	  | ctrname ==  "Latvia"  ///
	  | ctrname ==  "Lithuania" ///
	  | ctrname ==  "Netherlands" ///
	  | ctrname ==  "Portugal" ///
	  | ctrname ==  "Poland" ///
	  | ctrname ==  "Ukraine" ///
	  )

	replace sample = 6 if survey == "EVS 1999" & ///
	  (	ctrname ==  "Czech Republic" ///
	  | ctrname ==  "Estonia" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "France" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Italy" ///
  	  | ctrname ==  "Luxembourg" ///
	  | ctrname ==  "Slovakia" ///
	  | ctrname ==  "Spain" ///
	  | ctrname == "Russian Federation"  ///
	  | ctrname == "Turkey"  ///
	  | ctrname ==  "United Kingdom" ///
	  )

	// ISSP
	replace sample = 1 if survey == "ISSP 2002" & ///
	  ( ctrname ==  "Australia" ///
	  | ctrname ==  "Denmark" ///
	  | ctrname ==  "Finland" ///
	  | ctrname ==  "Norway" ///
	  | ctrname ==  "New Zealand" ///
	  | ctrname ==  "Sweden" ///
	  )

	replace sample = 2 if survey == "ISSP 2002" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "Germany" ///
	  | ctrname ==  "Belgium" ///
	  | ctrname ==  "Hungary" ///
	  | ctrname ==  "Japan" ///
	  | ctrname ==  "Slovenia" ///
	  | ctrname ==  "Taiwan" ///
	  )

	replace sample = 5 if survey == "ISSP 2002" &  sample >= .
		
	replace sample = 6 if survey == "ISSP 2002" & ///
	  (	ctrname ==  "Brazil" ///
	  | ctrname ==  "Netherlands" ///
	  | ctrname ==  "Philippines" ///
	  | ctrname ==  "Slovakia" ///
	  )


	// ESS 2002
	replace sample = 1 if survey == "ESS 2002" & ///
	  ( ctrname == "Denmark" ///
	  | ctrname == "Finland" ///
	  | ctrname == "Sweden" ///
	  )
	replace sample = 2 if survey == "ESS 2002" & ///
	  ( ctrname == "Belgium"  ///
	  | ctrname == "Germany" ///
	  | ctrname == "Hungary" ///
	  | ctrname == "Ireland" ///
	  | ctrname == "Norway" ///
	  | ctrname == "Poland"  ///
	  | ctrname == "Slovenia" ///
	  )

	replace sample = 3 if survey == "ESS 2002" & ///
	  ( ctrname == "Czech Republic"  ///
	  | ctrname == "Greece" ///
	  | ctrname == "Israel" ///
	  | ctrname == "Italy" ///
	  | ctrname == "Luxembourg" ///
	  | ctrname == "Netherlands" ///
	  | ctrname == "Portugal" ///
	  | ctrname == "Spain" ///
	  | ctrname == "Switzerland" ///
	  | ctrname == "United Kingdom" ///
	  )

	replace sample = 4 if survey == "ESS 2002" & ///
	  ( ctrname ==  "Austria" ///
	  | ctrname ==  "France" ///
	  )

	// Euromodule
	replace sample = 3 if survey == "Euromodule" & ///
	  ( ctrname == "Sweden" ///
	  | ctrname == "Slovenia" ///
	  )

	replace sample = 3 if survey == "Euromodule" & ///
	  ( ctrname == "Hungary" ///
	  | ctrname == "Switzerland" ///
	  | ctrname == "Austria" ///
	  )
	replace sample = 4 if survey == "Euromodule" & ///
	  ( ctrname == "Germany" ///
	  | ctrname == "Spain" ///
	  | ctrname == "Turkey" ///
	  )

	replace sample = 5 if survey == "Euromodule" & ///
	  ( ctrname == "Korea Rep. of" ///
	  )


	// EU and friends only
	// -------------------

	keep if eu > 0
	egen axis = axis(eu ctrname), reverse label(ctrname) gap


	// Fine tune X-Axis coordintas
	// ----------------------------

	// Graph for Sample Method
	// -----------------------

	// Points in section
	gen samplex = sample
	by ctrname sample (survey), sort: gen np = _N
	by ctrname sample (survey): replace samplex = samplex - .125 if np == 2 & _n==1
	by ctrname sample (survey): replace samplex = samplex + .125 if np == 2 & _n==2
	by ctrname sample (survey): replace samplex = samplex - .25 if np == 3 & _n==1
	by ctrname sample (survey): replace samplex = samplex + .25 if np == 3 & _n==3

	by ctrname sample (survey): replace samplex = samplex - .375 if np == 4 & _n==1
	by ctrname sample (survey): replace samplex = samplex - .125 if np == 4 & _n==2
	by ctrname sample (survey): replace samplex = samplex + .125 if np == 4 & _n==3
	by ctrname sample (survey): replace samplex = samplex + .375 if np == 4 & _n==4

	separate samplex, by(survey) veryshortlabel
	graph twoway ///
	  || sc axis samplex1, ms(Oh) mlc(black) mfc(white) /// 
	|| sc axis samplex2, ms(O) mc(black)   /// 
	|| sc axis samplex3, ms(Sh) mlc(black) mfc(white)   /// 
	|| sc axis samplex4, ms(S) mc(black)   /// 
	|| sc axis samplex5, ms(Th) mlc(black) mfc(white)   /// 
	|| sc axis samplex6, ms(T) mc(black)    ///
	  || , legend(off)  ///
	  ylab(1(1)4 6(1)15 17(1)31, valuelabel angle(0) grid ) ytitle("") ///
	  xscale(range(.625 6.375))           ///
	  xline(1.5(1)5.5) ///
	  xlab(1 "SRS" ///
	  2  "Indiv. Reg."   ///
	  3  "Add. Reg."      ///
	  4  "Random-Route"   ///
	  5  "Unknown"   ///
	  6  "Quota"    ///
	  )  ///
	  title(Sample method, pos(12) box bexpand fcolor("228 112 91") ) nodraw name(g1, replace) ///
	  
	// Graph for substitution
	// ----------------------

	// Points in section
	gen substx = subst
	by ctrname subst (survey), sort: replace np = _N
	by ctrname subst (survey): replace substx = substx - .125 if np == 2 & _n==1
	by ctrname subst (survey): replace substx = substx + .125 if np == 2 & _n==2

	by ctrname subst (survey): replace substx = substx - .25 if np == 3 & _n==1
	by ctrname subst (survey): replace substx = substx + .25 if np == 3 & _n==3

	by ctrname subst (survey): replace substx = substx - .375 if np == 4 & _n==1
	by ctrname subst (survey): replace substx = substx - .125 if np == 4 & _n==2
	by ctrname subst (survey): replace substx = substx + .125 if np == 4 & _n==3
	by ctrname subst (survey): replace substx = substx + .375 if np == 4 & _n==4

	separate substx, by(survey) veryshortlabel
	graph twoway ///
	  || sc axis substx1, ms(Oh) mlc(black) mfc(white) /// 
	|| sc axis substx2, ms(O) mc(black)   /// 
	|| sc axis substx3, ms(Sh) mlc(black) mfc(white)   /// 
	|| sc axis substx4, ms(S) mc(black)   /// 
	|| sc axis substx5, ms(Th) mlc(black) mfc(white)   /// 
	|| sc axis substx6, ms(T) mc(black)    ///
	  || if subst > -3 , ///
	  legend(off)  ///
	  ylabel(none)  yline(1(1)4 6(1)15 17(1)31, lstyle(grid) ) ytitle("") ///
	  xlabel(0 "No"  1 `"Yes"') ///
	  xline(0.5) xscale(range(-.25 1.375) ) ///
	  fxsize(20)  ///
	  title(Subst. allowed, pos(12) box bexpand fcolor("228 112 91") ) nodraw name(g2, replace)


	// Graph for substitution
	// ----------------------

	// Points in section
	gen backd = back == 0 if back >= 0
	gen backx = backd
	by ctrname backd (survey), sort: replace np = _N
	by ctrname backd (survey): replace backx = backx - .125 if np == 2 & _n==1
	by ctrname backd (survey): replace backx = backx + .125 if np == 2 & _n==2

	by ctrname backd (survey): replace backx = backx - .25 if np == 3 & _n==1
	by ctrname backd (survey): replace backx = backx + .25 if np == 3 & _n==3

	by ctrname backd (survey): replace backx = backx - .375 if np == 4 & _n==1
	by ctrname backd (survey): replace backx = backx - .125 if np == 4 & _n==2
	by ctrname backd (survey): replace backx = backx + .125 if np == 4 & _n==3
	by ctrname backd (survey): replace backx = backx + .375 if np == 4 & _n==4

	separate backx, by(survey) veryshortlabel
	graph twoway ///
	  || sc axis backx1, ms(Oh) mlc(black) mfc(white) /// 
	|| sc axis backx2, ms(O) mc(black)   /// 
	|| sc axis backx3, ms(Sh) mlc(black) mfc(white)   /// 
	|| sc axis backx4, ms(S) mc(black)   /// 
	|| sc axis backx5, ms(Th) mlc(black) mfc(white)   /// 
	|| sc axis backx6, ms(T) mc(black)    ///
	  || if backd < . , ///
	  legend(off)  ///
	  ylabel(none)  yline(1(1)4 6(1)15 17(1)31, lstyle(grid) ) ytitle("") ///
	  xlabel(0 "Yes" 1 "No" ) ///
	  xline(0.5) xscale(range(-.25 1.375)) ///
	  fxsize(20)   ///
	  title(Back-checks, pos(12) box bexpand fcolor("228 112 91") ) nodraw name(g3, replace)
	
	
	graph combine g1 g2 g3, rows(1) imargin(tiny) nodraw name(combined, replace)
	

	// Legend Graph
	// ------------
	// thanks vwiggins@stata.com

	// Legend
	tw sc substx1 substx2 substx3 substx4 substx5 substx6 axis ///
	  , legend(order(1 "EB" 2 "EQLS" 3 "ESS" 4 "EVS" 5 "Euromodule" 6 "ISSP") rows(1))  ///
	  name(leg, replace) yscale(off) xscale(off) nodraw  ///
	  ms(Oh O Sh S Th T) mc(black ..)
	
	// Delete Plrogregion and fix ysize (Thanks, Vince)
	_gm_edit .leg.plotregion1.draw_view.set_false
	_gm_edit .leg.ystretch.set fixed

	graph combine combined leg, cols(1)  

	graph export ansample02C.eps, replace

	exit
	


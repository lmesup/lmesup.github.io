* Analysis of the ESS 2004
	
	// Compile ESS 2004 and ESS 2002
	// -----------------------------

	use $dublin/eqls_4, clear
   label define s_cntry 11 "United Kingdom", modify
   egen iso3166 = iso3166(s_cntry)


	// Absolute Position
	// -----------------
	
	gen abspos = hhinc4
	label variable abspos "Absolute Income"
	
	// "Mean Absolute Position"
	// ------------------------

	by iso3166, sort: gen mabspos = sum(abspos)/sum(abspos!=.)
	by iso3166, sort: replace mabspos = mabspos[_N]
	label variable mabspos "Mean income"

	// "Relative Position"
	// -------------------

	gen relpos = abspos-mabspos
	label variable relpos "Relative income"


	// Control Variables
	// -----------------

	gen age = hh2b
	label variable age "Age"
	gen age2 = age^2
	label variable age2 "Age squared"
	
	gen men = hh2a==1 if hh2a < .
	label variable men "Men"

   gen hhmmb = hh1
   label variable hhmmb "Household size"

	// Random-effects 
	// ---------------
	encode iso3166, gen(i)
	iis i
	
	// Listwise deletion
	// -----------------

	mark touse
	markout touse abspos mabspos relpos hhmmb men age


	// Describe  Income
	// -----------------

	graph box abspos if touse ///
	  , over(iso3166, sort(1)) note("Outliers excluded") ///
 	  nooutsides /// 
	  box(1, bstyle(outline)) medtype(marker) medmarker(ms(o) mcolor(black)) ///
	  marker(1, ms(oh) mcolor(black) ) note("") ///
	  scheme(s1mono)

	corr abspos relpos mabspos if touse
	  
	// Center Metric Variables, Interactionterms 
	// -----------------------------------------
	
	capture which center
	if _rc == 111 ssc install center, replace
	center abspos relpos mabspos hhmmb age age2 if touse

	// Loop for Models
	// ---------------

	capture which eret2
	if _rc == 111 ssc install eret2, replace
	capture which estout
	if _rc == 111 ssc install estout, replace

	xtreg q31 men c_age c_age2 c_hhmmb c_abspos c_relpos 
	estimates store mod1
			
	estout mod1  ///
		  using anrelative.txt ///
		  , replace label ///
		  equations(Coefs=1) ///		
		collabels(, none) ///
		  cells(b(fmt(%3.2f)) t(fmt(%3.1f) par)) ///
		  stats(r2_o N rho, labels("\$r^2\$" "\$n\$" "\$\rho\$") fmt(%9.2f %9.0f %9.2f)) ///
		  varlabels(_cons Constant) 
	
	estimates clear
	

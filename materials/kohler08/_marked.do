	// The Graph
	twoway ///
	  (rbar womenub womenlb ctrsort if inrange(ctrsort,1,4)   /// Confidence Bounds
	  , horizontal color(gs10) sort)                          ///
	  (rbar womenub womenlb ctrsort if inrange(ctrsort,6,15)  /// Confidence Bounds
	  , horizontal color(gs10) sort)                          ///
	  (rbar womenub womenlb ctrsort if inrange(ctrsort,17,31) /// Confidence Bounds
	  , horizontal color(gs10) sort)                          ///
	  (scatter ctrsort womenbar0                              /// Random Selection
	    , ms(O) mcolor(black) )                               ///
	  (scatter ctrsort womenbar1                              /// Quota Selection 
	    , ms(O) mlcolor(black) mfcolor(white))                ///
	  (pcarrow ctrsort womenbar ctrsort womenbarw             /// Arrorws for weigts
 	    if survey != "ESS 2002"  & quota ~= 1                 ///
	    , msize(small) mcolor(black) lcolor(black))           ///
	  (scatteri 0 0 31 0, c(l) ms(i) clcolor(fg) clpattern(solid))          ///
	  , by(survey, ///
	    title("Figure 2: Fractions of women") ///
	    subtitle("Differences between survey and official sources") ///
	    note(Own calculations. Do-File: anextern01_1.do) ///
	    l1title("") iscale(*.8))          /// 
	    ylab(1(1)4 6(1)15 17(1)31, valuelabel angle(horizontal))            ///
	    legend(rows(1) order(4 "Random" 5 "Quota" 6 "After Weighting")) ///
	  scheme(s1mono) ysize(9) ///
	  
	graph export anextern01_1.eps, replace


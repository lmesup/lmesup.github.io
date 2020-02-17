levelsof natfam, local(K)
local vlines ""
foreach k of local K {
	local vlines ///
	  "`vlines' || line axis MEANb if natfam==`k', lcolor(gs8) lpattern(solid) lwidth(*1.3)"
}

// Graph and Export
levelsof axis, local(ylab)
graph twoway ///
  || sc axis meanb,  ms(O) mcolor(black)                            ///
  || rspike minb maxb axis, horizontal lcolor(black)                ///
  || `vlines'                                                       ///
  || , by(form, rows(1) legend(off) note(""))    ///
  ysize(5) xsize(4.5)                                                               ///
  ylabel(`ylab', valuelabel angle(0) labsize(*.8) gstyle(dot))                      /// 
  ytitle("") 							/// 
  xtitle("Difference of political engagement between voters and non-voters", size(*.9))

graph export ../figure8EN.eps, replace preview(on) 

	

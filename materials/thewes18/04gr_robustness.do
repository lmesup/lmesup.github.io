/* Thewes (2018): Create robustness check: Map+Scatter
----------------------------------------------------------------------------
Files:
- s21_Ri.pdf: Map: 4 different predictions of Y_hat
- s21_scatter.pdf: Scatter: 4 different bias plotted
----------------------------------------------------------------------------
*/ 

use "data/s21_y", clear

// prediction method
// -----------------
// 1 = based on Mikro-Analysis Faas
// 2 = based on Mikro-Analysis Gabriel
// 3 = based on Mikro-Analysis ZA 5625
// 4 = based on Mikro-Analysis ZA 5592

local maps 1              // do not create specific graphs: on (=1) or off (=0)
local scatter 1
local close 1             // close all graphs at the end


foreach x of numlist 1/4 {        // all models should be calculated!
  global m `x'

  // 4 different results 
  // -------------------

  if `maps' == 1 {
    sum Yn$m [fw=EN] 
    local mean : display %5,1f r(mean)

    spmap Yn$m using "data/shp/utm32_de_coor", id(id) ///
      clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin) ///
      title("") caption("M$m Resultat = `mean'%") nodraw ///
      legend(off) name(rihat$m, replace)  /// plotregion(style(none))
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))
  }
}

// Create graph for all 4 data-sources
if `maps' == 1 {
  graph combine rihat1 rihat2 rihat3 rihat4, ///
    rows(2) graphregion(fcolor(white) color(white)) ///
    plotregion(style(none)) xsize(10) ysize(12) name(maps, replace) graphregion(margin(t-5))
  *graph export stout/s21_Ri.pdf, replace
  if `close' == 1 win man close graph
}



// Create Contour-Data:
preserve
  capture confirm file "data/cont.dta"
  if _rc {
    clear all
    // Create Data
    set obs 100
    gen p = (_n-1)/(_N-1)
    gen d = (_n-1)/(_N-1)
    fillin p d
    gen bias = p * d

    label variable bias " "
    drop _fillin

    gen id = _n * (-1)
    
    replace p = p*100
    replace d = d*100
    replace bias = bias*100
    
    save "data/cont", replace
  }
restore

merge 1:1 id using "data/cont", keep(1 2)


if `scatter' == 1 {
  // Create merged plot for all 4 methods
  // ------------------------------------
  foreach x of numlist 1/4 {
    global m `x'

    // Calculate Mean Yn - Ye
    // -----------------------
    gen Mdif = YnYe$m * EN
    sum Mdif, meanonly
    local Mdif_t `r(sum)'
    sum EN, meanonly
    local EN_t `r(sum)'
    local Mdif_mean`x' : display  %04.1f `Mdif_t' / `EN_t'
    drop Mdif
  }
  local pn : display  %04.2f 100 - 48.3

  // Define Colours
  // Source: http://colorbrewer2.org/
  // Palette is colorblind safe but nut print friendly. With 10 levels it is not possible to have both. 

  local c1 75 0 100 40
  local c2 70 15 100 0
  local c3 50 5 80 0
  local c4 28 0 47 0
  local c5 10 0 17 0
  local c6 0 12 0 0
  local c7 4 28 0 0
  local c8 11 52 6 0
  local c9 20 90 10 0
  local c10 10 100 0 35

  twoway  ///
    || contour bias d p if _merge==2,  ///
    levels(10)  ///
    ccolors("`c1'"  "`c2'"  "`c3'"  "`c4'"  "`c5'"  "`c6'"  "`c7'"  "`c8'"  "`c9'"  "`c10'") ///
    || scatteri `Mdif_mean1' `pn' "M1", mlabpos(9) mlabs(large) mlabcolor(black) color(black) msize(medium) ///
    || scatteri `Mdif_mean2' `pn' "M2", mlabpos(3) mlabs(medlarge) mlabcolor(gs6) color(black) ms(x) msize(medlarge) mc(gs6) ///
    || scatteri `Mdif_mean3' `pn' "M3", mlabpos(3) mlabs(medlarge) mlabcolor(gs6) color(black) ms(x) msize(medlarge) mc(gs6) ///
    || scatteri `Mdif_mean4' `pn' "M4", mlabpos(9) mlabs(medlarge) mlabcolor(gs6) color(black) ms(x) msize(medlarge) mc(gs6) ///
    || , legend(off) xlab(0(25)100) ylab(0(25)100) clegend(width(*0.5)) ///
    xtitle("Nonresponse") ///
    ytitle("absolute Meinungsdifferenz") ///
    graphr(c(white) lw(0) istyle(none) style(none) margin(zero)) name(scatter, replace) fxsize(70) fysize(50) graphregion(margin(t+37))
  graph export stout/s21_scatter.pdf, replace
  if `close' == 1 win man close graph
}

graph combine maps scatter, title("Robustheits-Tests", c(black)) ///
   plotregion(style(none)) graphregion(margin(zero)) graphregion(fcolor(white) color(white))  
graph export stout/s21_robust.pdf, replace

exit


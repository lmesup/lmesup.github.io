/* Thewes (2018): Scatterplot with other participation-methods
----------------------------------------------------------------------------
Files:
- s21_scatter$m.pdf: Scatter: Plot S21-Bias and other participation-methods
----------------------------------------------------------------------------
*/ 
use "data/s21_y", clear

local scatter 1
local close 0


// prediction method
// -----------------
// 1 = based on Mikro-Analysis Faas
// 2 = based on Mikro-Analysis Gabriel
// 3 = based on Mikro-Analysis ZA 5625
// 4 = based on Mikro-Analysis ZA 5592


// Scatter: Yn-Ye vs. Pn
// ---------------------

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

if `scatter'== 1 {
  foreach x of numlist 1/1 {            // which model should be calculated?
    global m `x'

    // Calculate Mean Yn - Ye
    // -----------------------
    gen Mdif = YnYe$m * EN
    sum Mdif, meanonly
    local Mdif_t `r(sum)'
    sum EN, meanonly
    local EN_t `r(sum)'
    local Mdif_mean : display %04.1f `Mdif_t' / `EN_t'
    local Mdif_meanc : display %04,1f `Mdif_t' / `EN_t'
    drop Mdif

    local pn : display %04.1f 100 - 48.3
    local pnc : display %04,1f 100 - 48.3

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
      || contour bias d p if _merge==2, levels(10)  ///
      ccolors("`c1'"  "`c2'"  "`c3'"  "`c4'"  "`c5'"  "`c6'"  "`c7'"  "`c8'"  "`c9'"  "`c10'") ///
      || scatter YnYe$m Pn if _merge==1, ms(o) msize (small) mc(gs10) ///
      || scatteri 2  30.2 "BTW 2009", mlabpos(11) mlabs(small) mlabcolor(black) color(black) ///
      || scatteri 24 9.6  "BTW 1972", mlabpos(12) mlabs(small) mlabcolor(black) color(black) ///
      || scatteri 22 64.8 "Petition 2012", mlabpos(3) mlabs(small)  mlabcolor(black) color(black) ///
      || scatteri 44 90.8 "Demo 2012", mlabpos(12) mlabs(small) mlabcolor(black) color(black) ///
      || scatteri `Mdif_mean' `pn' "Stuttgart 21", mlabpos(6) mlabs(medium) mlabcolor(black) color(black) msize(large) ///
      || , legend(off) xlab(0(25)100) ylab(0(25)100) ///
      title("Vergleich unterschiedlicher Beteiligungsformen", c(black)) ///
      xtitle("Nonresponse") ytitle("absolute Meinungsdifferenz") ///
      graphr(c(white) lw(0) istyle(none) style(none))
    graph export stout/s21_scatter$m.pdf, replace
    if `close' == 1 win man close graph

    di as res "YnYe = " `Mdif_mean' "    PN = "`pn'
    di as res "Bias(Y) = " `Mdif_mean' *  `pn' / 100
  }
}

exit


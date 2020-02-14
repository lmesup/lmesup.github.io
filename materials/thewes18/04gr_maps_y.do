/* Thewes (2018): Create bias-maps
----------------------------------------------------------------------------
Files:
- s21_ye_yn$m.pdf: Map: Ye and Yn
- s21_pn_yene$m.pdf: Map: Pn and |Ye-Yn|
- s21_y$m.pdf: Map: absolut bias and relative bias
- s21_influence$m.pdf: Map: influential municipalities
----------------------------------------------------------------------------
*/ 

use "data/s21_y", clear

// prediction method
// -----------------
// 1 = based on Mikro-Analysis Faas
// 2 = based on Mikro-Analysis Gabriel
// 3 = based on Mikro-Analysis ZA 5625
// 4 = based on Mikro-Analysis ZA 5592

local ye_yn 1             // do not create specific maps: on (=1) or off (=0)
local pn_yn_ye 1
local y_ydif 1
local influence 1
local close 1             // close all graphs at the end


local clist1 `""165 0 38" "215 48 39" "244 109 67" "253 174 97" "254 224 139" "255 255 191" "166 217 106" "102 189 99" "26 152 80" "0 104 55" "0 53 28""' 
local clist2 `""0 63 33" "0 104 55" "26 152 80" "102 189 99" "166 217 106" "255 255 191" "254 224 139" "253 174 97" "244 109 67"  "215 48 39" "165 0 38""'

foreach x of numlist 1/1 {      // which model should be calculated?
  global m `x'

  // Map: Ye vs. Yn
  // --------------  
  if `ye_yn' == 1 {
    spmap Ye using "data/shp/utm32_de_coor", id(id) ///
      clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin) eirange(3 67) ///
      subtitle("Wähler") ///  
      legend(off) name(ye, replace) nodraw plotregion(style(none)) /// 
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))

    spmap Yn$m using "data/shp/utm32_de_coor", id(id) ///
      clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin) eirange(3 67) ///   eirange needs to bet set for different models
      subtitle("Nichtwähler (geschätzt)") ///
      legend(off) name(Yn$m, replace) nodraw  plotregion(style(none)) ///  
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))


    sum Ye [fw=E], meanonly
    local mean : display %5,1f r(mean)
    cor distance Ye
    local r : display %4,2f r(rho)
    graph hbox Ye, ytitle("") name(b_Ye,replace) nodraw ///
      graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
      ylabel(, nogrid labsize(small)) fysize(15) ///
      box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
      note("Mean = `mean' ; r{sub:(Distance)} = `r'")

    sum Yn$m [fw=N], meanonly
    local mean : display %5,1f r(mean)
    cor distance Yn$m
    local r : display %4,2f r(rho)
    graph hbox Yn$m, ytitle("") name(b_Yn$m,replace) nodraw ///
      graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
      ylabel(, nogrid labsize(small)) fysize(15) ///
      box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
      note("Mean = `mean' ; r{sub:(Distance)} = `r'")


    graph combine ye Yn$m b_Ye b_Yn$m, title("Anteil Stimmen gegen S21", color(black)) rows(2) graphregion(fcolor(white) color(white)) plotregion(style(none)) 
    graph export stout/s21_ye_yn$m.pdf, replace
    if `close' == 1 win man close graph
  }


  // Map: P(N) vs. |Yn-Ye| 
  // ---------------------
  if `pn_yn_ye' == 1 {
    spmap Pn using "data/shp/utm32_de_coor", id(id) ///
      clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin) ///
      title("Nonresponse")  /// 
      legend(off) name(pn, replace) nodraw /// 
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))

    spmap YnYe$m using "data/shp/utm32_de_coor", id(id) ///
      clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin) eirange(0 48) ///
      title("Meinungsdifferenz")  /// 
      legend(off) name(ynye, replace) nodraw ///  
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))


    sum Pn [fw=EN], meanonly
    local mean : display %5,1f r(mean)
    cor distance Pn
    local r : display %4.2f r(rho)
    graph hbox Pn, ytitle("") name(b_pn,replace) nodraw /// 
      graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
      ylabel(, nogrid labsize(small)) fysize(15) ///
      box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
      note("Mean = `mean' ; r{sub:(Distance)} = `r'")

    sum YnYe$m [fw=EN], meanonly
    local mean : display %5,1f r(mean)
    cor distance YnYe$m
    local r : display %4,2f r(rho)
    graph hbox YnYe$m, ytitle("") name(b_YnYe$m,replace) nodraw ///
      graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
      ylabel(, nogrid labsize(small)) fysize(15) ///
      box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
      note("Mean = `mean' ; r{sub:(Distance)} = `r'")

    graph combine pn ynye b_pn b_YnYe$m,  title("Komponenten des Beteiligungs-Bias",c(black)) rows(2) graphregion(fcolor(white) color(white)) // 
    graph export stout/s21_pn_yene$m.pdf, replace
    if `close' == 1 win man close graph
  }



  // Map: Bais absolut vs. relativ
  // -----------------------------


  if `y_ydif' == 1 {
    spmap Y$m using "data/shp/utm32_de_coor", id(id) ///
      clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin) ///
      title("absolut") ///
      legend(off) name(Y$m, replace) nodraw /// 
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))


    spmap Y_dif$m using "data/shp/utm32_de_coor", id(id) ///
      clmethod(eqint) clnumber(11) fcolor(`clist1') ocolor(`clist1') osize(vvthin) eirange(-24 24) ///   
      title("relativ") ///
      legend(off) name(Y_dif$m, replace) nodraw ///  
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))


    sum Y$m [fw=EN], meanonly
    local mean : display %5,1f r(mean)
    cor distance Y$m
    local r : display %4,2f r(rho)
    graph hbox Y$m, ytitle("") name(b_Y$m,replace) nodraw /// 
      graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
      ylabel(, nogrid labsize(small)) fysize(15) ///
      box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
      note("Mean = `mean' ; r{sub:(Distance)} = `r'")

    sum Y_dif$m [fw=EN], meanonly
    local mean : display %5,1f r(mean)
    cor distance Y_dif$m
    local r : display %4,2f r(rho)
    graph hbox Y_dif$m, ytitle("") name(b_Y_dif$m,replace) nodraw /// 
      graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
      ylabel(, nogrid labsize(small)) fysize(15) ///
      box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
      note("Mean = `mean' ; r{sub:(Distance)} = `r'")


    graph combine Y$m Y_dif$m b_Y$m b_Y_dif$m, title("Beteiligungs-Bias", color(black)) rows(2) graphregion(fcolor(white) color(white))
    graph export stout/s21_y$m.pdf, replace
    if `close' == 1 win man close graph
  }


  // Influence of bias 
  // -----------------
  if `influence' == 1 {
    tempvar md 
    gen `md' = (41.24 - Ri_hat$m)
    egen y_inf$m = pc((`md') * ln(N))
    replace y_inf$m = y_inf$m*100

    // calculate range
    sum y_inf$m
    local min = abs(floor(r(min)))
    local max = abs(ceil(r(max)))
    if `min' > `max' local max = `min'
    local range "-`max' `max'"

    spmap y_inf$m using "data/shp/utm32_de_coor", id(id) nodraw ///
      clmethod(eqint) clnumber(11) fcolor(`clist2') ocolor(`clist2') osize(vvthin) eirange(`range') ///   
      title("Einflussreiche Gemeinden") ///  
      legend(off) name(y_inf$m, replace) plotregion(style(none)) /// 
        polygon(data("data/shp/dlm250_coor2") by(linetype) ///
        fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
        line(data("data/shp/utm32_de_coor") ///
        select(keep if _ID == 6412) color(black) size(medthin))
    if `close' == 1 win man close graph


    sum y_inf$m [fw=EN] , meanonly
    local mean : display %5,1f r(mean)
    cor distance y_inf$m
    local r : display %4,2f r(rho)
    graph hbox y_inf$m, ytitle("") name(b_y_inf$m,replace) nodraw /// 
      graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
      ylabel(, nogrid labsize(small)) fysize(15) fxsize(55) ///
      box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
      note("Mean = `mean' ; r{sub:(Distance)} = `r'")

    graph combine y_inf$m b_y_inf$m, rows(2) graphregion(fcolor(white) color(white))
    graph export stout/s21_influence$m.pdf, replace
    if `close' == 1 win man close graph
  }
}

exit


/* Thewes (2018): Create descriptive Maps
----------------------------------------------------------------------------
Files:
- s21.pdf: Map: Pn and Ye 
- s21_bw.pdf: Map: outline-map of BaWü with cities and waterways
----------------------------------------------------------------------------
*/ 
use "data/s21", clear

local close 0

// Nonresponse instead of turnout
replace turnout = 100 - turnout 

// Map: S21-turnout and S21-approbation 
// ----------------------------------------- 
spmap turnout using "data/shp/utm32_de_coor", id(id) ///
  clnumber(16) fcolor(Heat) clmethod(eqint) eirange(13 78) ocolor(Heat) osize(vvthin) ///
  title("100% - Wahlbeteiligung (Nonresponse)") ///
  legend(off) name(turnout, replace) nodraw /// 
    polygon(data("data/shp/dlm250_coor2") by(linetype) ///
      fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
    line(data("data/shp/utm32_de_coor") ///
      select(keep if _ID == 6412) color(black) size(thin))  /// 
    label(data("data/shp/utm32_de_data_lab") by(z) label(GEN) x(x_center) y(y_center) ///
      length(10 10 10) size(medium) pos(12) color(black) ///   
      select(keep if inlist(id,6412,702,619,8489,1053,11190,871,2350,1108,598,8117))) ///
    point(data("data/shp/utm32_de_data") x(x_center) y(y_center) shape(o) ///
      select(keep if inlist(id,6412,702,619,8489,1053,11190,871,2350,1108,598,8117)))

spmap yes using "data/shp/utm32_de_coor", id(id) ///
  clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin)  eirange(5 80) ///
  title("Anteil Stimmen gegen S21") ///
  legend(off) name(yes, replace) nodraw ///
    polygon(data("data/shp/dlm250_coor2") by(linetype) ///
    fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
    line(data("data/shp/utm32_de_coor") ///
    select(keep if _ID == 6412) color(black) size(medthin))


sum turnout [fw=SB], meanonly
local min : display %4,1f r(min)
local max : display %4,1f r(max)
local mean : display %4,1f r(mean)
cor distance turnout [fw=SB]
local r : display %5,2f r(rho)
graph hbox turnout, ytitle("") name(b_turnout,replace) nodraw /// 
  graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
  ylabel(, nogrid labsize(small)) fysize(15) ///
  box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
  note("Mean = `mean' ; r{sub:(Distance)} = `r'")

sum yes [fw=valid], meanonly
local min : display %3,1f r(min)
local max : display %4,1f r(max)
local mean : display %4,1f r(mean)
cor distance yes [fw=valid]
local r : display %5,2f r(rho)
graph hbox yes, ytitle("") name(b_yes,replace) nodraw /// 
  graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
  ylabel(, nogrid labsize(small)) fysize(15) ///
  box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
  note("Mean = `mean' ; r{sub:(Distance)} = `r'")


graph combine turnout yes b_turnout b_yes, rows(2) graphregion(fcolor(white) color(white)) title("S21-Volksentscheid",c(black))
graph export stout/s21.pdf, replace
if `close' == 1 win man close graph


// Map: S21-turnout vs. BTW2009-turnout
// ------------------------------------
replace diff_turnout = diff_turnout*-1
spmap diff_turnout using "data/shp/utm32_de_coor", id(id) nodraw ///
  clnumber(16) fcolor(Heat) clmethod(eqint) ocolor(Heat) osize(vvthin) ///
  title("Differenz Wahlbeteiligung") subtitle("BTW 2009 vs. S21") ///
  legend(off) name(diff_turnout, replace) /// 
    polygon(data("data/shp/dlm250_coor2") by(linetype) ///
    fcolor(blue*.5 blue*.7) ocolor(blue*.7 blue*.7) osize(vvthin vvthin)) ///
    line(data("data/shp/utm32_de_coor") ///
    select(keep if _ID == 6412) color(black) size(medthin)) ///
    point(data("data/shp/utm32_de_data_btw") x(x_center) y(y_center) ///
    shape(X) os(medthick) select(keep if inlist(id,816,49,24)))


replace diff_turnout = diff_turnout*-1
sum diff_turnout, meanonly
local mean : display %4,1f r(mean)
cor distance diff_turnout
local r : display %5,3f r(rho)
graph hbox diff_turnout, ytitle("") name(b_diff_turnout,replace) nodraw /// 
  graphregion(fcolor(white) color(white) margin(r=5 l=5))  ///
  ylabel(, nogrid labsize(small)) fysize(15) fxsize(55) ///
  box(1, fc(gs10) lc(black) lw(thin)) marker(1, mc(black) msize(small)) ///
  note("Mean = `mean' ; r{sub:(Distance)} = `r'")

graph combine diff_turnout b_diff_turnout, rows(2) graphregion(fcolor(white) color(white))
graph export stout/s21_diff.pdf, replace
if `close' == 1 win man close graph



// BW-Map
// ------
preserve        // prepare Label-Data
  use "data/shp/utm32_de_data", clear
  keep if inlist(id,6412,702,619,8489,1053,11190,871,2350,1108,598,8117,1626,809,836,207,978,10390)

  replace GEN = "Freiburg" if id == 619
  replace GEN = "*" if id == 809 | id == 836
  replace GEN = "Bodensee" if id == 1626
  replace GEN = "Rhein" if id == 207
  replace GEN = "Neckar" if id == 978
  replace GEN = "Donau" if id == 10390


  replace x_center = 542711.6 if id == 809        // lab-position Münsingen
  replace y_center = 5369574 if id == 809

  replace x_center = 401061.5 if id == 836        // lab-position Rheinaue
  replace y_center = 5354221 if id == 836

  replace x_center = 527111.6 if id == 1626       // lab-position Bodensee
  replace y_center = 5269544 if id == 1626

  replace x_center = 436247.4 if id == 207        // lab-position Rhein
  replace y_center = 5412573 if id == 207

  replace x_center = 560235.8 if id == 10390      // lab-position Donau
  replace y_center = 5326783 if id == 10390

  replace x_center = 503235.2 if id == 978        // lab-position Neckar
  replace y_center = 5355487 if id == 978

  gen z = 1 if inlist(id,6412,702,619,8489,1053,11190,871,2350,1108,598,8117)
  replace z = 2 if inlist(id,809,836)
  replace z = 3 if inlist(id,1626,207,978,10390)
  save "data/shp/utm32_de_data_lab", replace
restore

use "data/s21", clear

spmap baden using "data/shp/utm32_de_coor", id(id)  ///nodraw
  legend(off) osize(vvthin) fcolor(gs14 gs11)  ocolor(gs11 gs9) /// 
    polygon(data("data/shp/dlm250_coor2") by(linetype) ///
    fcolor(blue*.3 blue*.5) ocolor(blue*.5 blue*.5) osize(vvthin vvthin)) ///
    line(data("data/shp/utm32_de_coor") ///
    select(keep if _ID == 6412) color(black*.5) size(medthin)) ///
    label(data("data/shp/utm32_de_data_lab") by(z) label(GEN) x(x_center) y(y_center) ///
    length(10 10 10) size(medlarge medsmall medsmall) pos(12 6 9) color(black black blue*.7) ///   
    select(keep if inlist(id,6412,702,619,8489,1053,11190,871,2350,1108,598,8117,809,836,1626,207,978,10390))) ///
    point(data("data/shp/utm32_de_data") x(x_center) y(y_center) shape(o) ///
    select(keep if inlist(id,6412,702,619,8489,1053,11190,871,2350,1108,598,8117))) 

graph export stout/s21_bw.pdf, replace
if `close' == 1 win man close graph
exit




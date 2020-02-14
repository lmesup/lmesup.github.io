/* Thewes (2018): Prepare Shape-Files
----------------------------------------------------------------------------
- Create corr and data files for spmap-ado from shape Files
- drop all water except of "Bodensee","Rhein","Donau","Neckar"

Files:
- utm32_de_data.dta + utm32_de_coor.dta: Municipalities in Baden-Württemberg 
- dlm250_f_data.dta + dlm250_f_coor.dta: Rivers & Lakes as polygons
- dlm250_l_data.dta + dlm250_l_coor.dta: Small Rivers as lines

- dlm250_coor2: selected Rivers & Lakes
----------------------------------------------------------------------------
*/ 

// ------ CREATE DTA-SHAPES --------

// Gemeinden BaWü
//   Source: © GeoBasis-DE / BKG Februar 2015
//   URL:    http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=13&gdz_user_id=0
shp2dta using "data/shp/shape_utm32_de/VG250_GEM",  ///
  database("data/shp/utm32_de_data")  ///
  coordinates("data/shp/utm32_de_coor") genid(id) gencentroids(center) replace

// Flüsse & Seen (Polygons) - Bodensee + Flüsse mit Breite > 10m 
//   Source: GeoBasis-DE / BKG Februar 2015
//   URL:    http://www.geodatenzentrum.de/geodaten/gdz_rahmen.gdz_div?gdz_spr=deu&gdz_akt_zeile=5&gdz_anz_zeile=1&gdz_unt_zeile=1&gdz_user_id=0
//   Karten mit QGIS modifiziert: - Teile von Rhein und Donau per Hand gelöscht (= nicht in BW)
//                                - fehlende Teile des Rheins per Hand eingezeichnet (Schweizer Staatsgebiet)
//                                - Original: "gew01_f"
shp2dta using "data/shp/shape_dlm250/gew01_f2",  ///
  database("data/shp/dlm250_f_data")  ///
  coordinates("data/shp/dlm250_f_coor") genid(id) gencentroids(center) replace

// Flüsse (Lines) - Flüsse mit Breite < 10m (Teile von Donau & Neckar)
//   Source: Siehe oben
//   Karten mit QGIS modifiziert: - Lines zu Polygons umgewandelt (Buffer-Option)
//                                - Original: "gew01_l"
shp2dta using "data/shp/shape_dlm250/gew01_l2",  ///
  database("data/shp/dlm250_l_data")  ///
  coordinates("data/shp/dlm250_l_coor") genid(id) gencentroids(center) replace



// --- PREPARE WATERWAYS ---------
use "data/shp/dlm250_f_coor", clear
clonevar id = _ID 
merge m:1 id using "data/shp/dlm250_f_data", keepus(NAM) nogen
keep if inlist(NAM,"Bodensee","Rhein","Donau","Neckar")
gen linetype = 1
save "data/shp/dlm250_f_coor2", replace


use "data/shp/dlm250_l_coor", clear
clonevar id = _ID 
merge m:1 id using "data/shp/dlm250_l_data", keepus(NAM) nogen
keep if inlist(NAM,"Bodensee","Rhein","Donau","Neckar")
gen linetype = 2

append using "data/shp/dlm250_f_coor2"
drop NAM id
save "data/shp/dlm250_coor2", replace

exit


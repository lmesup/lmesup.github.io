* Ausdruck der Stata-Grafiken in EPS-Dateien

* Custom 3 
gprefs set custom3 pen1_thick 1
gprefs set custom3 pen2_thick 1
gprefs set custom3 pen3_thick 8
gprefs set custom3 pen4_thick 8
gprefs set custom3 pen5_thick 8
gprefs set custom3 pen6_thick 8
gprefs set custom3 pen7_thick 8
gprefs set custom3 pen8_thick 8
gprefs set custom3 pen9_thick 8
gprefs set custom3 symmag_all 150

translator set gph2eps logo off
translator set gph2eps scheme custom3

translate tpaths.gph ../graphs/tpaths.eps, replace
translate pidlv1.gph ../graphs/pidlv1.eps, replace
translate pidlv_uv.gph ../graphs/pidlv_uv.eps, replace
translate mod1.gph ../graphs/mod1.eps, replace 
translate mod2a.gph ../graphs/mod2a.eps, replace 
translate mod2b.gph ../graphs/mod2b.eps, replace 
translate mod3a.gph ../graphs/mod3a.eps, replace 
translate mod3b.gph ../graphs/mod3b.eps, replace 


exit




	

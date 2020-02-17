* Ausdruck der Stata-Grafiken in EPS-Dateien

* Custom 3 
gprefs set custom3 pen1_thick 1
gprefs set custom3 pen2_thick 1
gprefs set custom3 pen3_thick 2
gprefs set custom3 pen4_thick 3
gprefs set custom3 pen5_thick 4
gprefs set custom3 pen6_thick 5
gprefs set custom3 pen7_thick 6
gprefs set custom3 pen8_thick 7
gprefs set custom3 pen9_thick 8
gprefs set custom3 symmag_all 150

* Generelle Größe 3 x 2
translator set gph2eps xsize 4.0
translator set gph2eps ysize 2.5
translator set gph2eps usegphsize off
translator set gph2eps logo off
translator set gph2eps scheme custom3


* Kapitel 3
* ---------

translate ../analysen/cases1.gph	cases1.eps, replace
translate ../analysen/xtreg1.gph 	xtreg1.eps, replace
translate ../analysen/tpaths.gph 	tpaths.eps, replace
translate ../analysen/verbr.gph 	verbr.eps, replace


* Kapitel 4
* ---------

translate ../analysen/normprob.gph normprob.eps, replace
translate ../analysen/simul3a_c.gph simul3a_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul3b_c.gph simul3b_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul3c_c.gph simul3c_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul4a_c.gph simul4a_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul4b_c.gph simul4b_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul4c_c.gph simul4c_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul5a_c.gph simul5a_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul5b_c.gph simul5b_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul5c_c.gph simul5c_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul6a_c.gph simul6a_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul6b_c.gph simul6b_c.eps, replace xsize(4) ysize(2)
translate ../analysen/simul6c_c.gph simul6c_c.eps, replace xsize(4) ysize(2)

* Kapitel 5
* ---------

translate ../analysen/stab2w.gph	stab2w.eps, replace
translate ../analysen/stab4u.gph	stab4u.eps, replace
translate ../analysen/stab4b.gph	stab4b.eps, replace
translate ../analysen/stab5a.gph	stab5a.eps, replace
translate ../analysen/stab5b.gph 	stab5b.eps, replace
translate ../analysen/traeg1a.gph 	traeg1a.eps, replace xsize(2) ysize(2)
translate ../analysen/traeg2a.gph 	traeg2a.eps, replace xsize(2) ysize(2)
translate ../analysen/traeg3a.gph       traeg3a.eps, replace
translate ../analysen/traeg3b.gph 	traeg3b.eps, replace
translate ../analysen/traeg3c.gph       traeg3c.eps, replace
translate ../analysen/traeg4a.gph       traeg4a.eps, replace
translate ../analysen/traeg4b.gph 	traeg4b.eps, replace
translate ../analysen/traeg5a.gph       traeg5a.eps, replace
translate ../analysen/traeg5b.gph 	traeg5b.eps, replace

* Kapitel 6
* ---------

translate ../analysen/pidlv1.gph 	pidlv1.eps, replace
translate ../analysen/pidlv2.gph	pidlv2.eps, replace
translate ../analysen/pidlv_uv.gph	pidlv_uv.eps, replace
translate ../analysen/pidlv3a.gph	pidlv3a.eps, replace xsize(4) ysize(2)
translate ../analysen/pidlv3b.gph	pidlv3b.eps, replace xsize(4) ysize(2)
translate ../analysen/pidlv3c.gph	pidlv3c.eps, replace xsize(4) ysize(2)
translate ../analysen/pidlv4a.gph	pidlv4a.eps, replace
translate ../analysen/pidlv4b.gph	pidlv4b.eps, replace
translate ../analysen/pidlv5.gph	pidlv5.eps, replace
translate ../analysen/pidlv6.gph	pidlv6.eps, replace
translate ../analysen/pidlv7.gph	pidlv7.eps, replace
translate ../analysen/pidlv9a.gph	pidlv9a.eps, replace
translate ../analysen/pidlv9b.gph	pidlv9b.eps, replace
translate ../analysen/pidlv10.gph	pidlv10.eps, replace
translate ../analysen/pidlv11.gph	pidlv11.eps, replace
translate ../analysen/pidlv12.gph	pidlv12.eps, replace


* Anhang
* ------

translate ../analysen/egpfr3.gph	egpfr3.eps, replace
translate ../analysen/holtm41.gph	holtm41.eps, replace
translate ../analysen/holtm42.gph	holtm42.eps, replace

translate ../analysen/egppr12a.gph	egppr12a.eps, replace
translate ../analysen/egppr12b.gph	egppr12b.eps, replace
translate ../analysen/egppr11.gph	egppr11.eps, replace
translate ../analysen/egpei2a.gph	egpei2a.eps, replace
translate ../analysen/egpei1a.gph	egpei1a.eps, replace
*translate ../analysen/egppid.gph	egppid.eps, replace
translate ../analysen/einord.gph 	einord.eps, replace 
translate ../analysen/einor1.gph  	einor1.eps, replace 

exit




	

* Parteiidentifikation, 14 Wellen, Unbalanced Panel-Design
* Mit Marker für das Balanced-Design
* Langes Format, xtdata, weights

clear
set memory 60m
version 6.0

* 0) Cool-Ados
* ------------

capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}

* Retrival
* --------
* (unbalanced Panel-Design)

mkdat  /*
*/ pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93 pid94 pid95  /*
*/ pid96 pid97  /*
*/ using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)  /*
*/ netto(-3,-2,-1,0,1,2,3,4,5)

* Mark the balanced sample
* ------------------------

gen mark = anetto == 1
for any b c d e f g h i j k l m n: replace mark = 0 if Xnetto ~= 1
for any  a b c d e f g h i j k l m n: drop Xnetto 
for any  a b c d e f g h i j k l m n: drop Xhhnr 
count if mark
assert r(N) == 4777  /* Just to be sure */
sort persnr

* Reshape
* ----------

reshape long pid, i(persnr) j(welle)

* XT-Data
* -------

iis persnr
tis welle

* Merge Weights
* --------------
sort persnr
merge persnr using weights
drop if _merge==2
drop _merge


* Save 
* ---

save stab1, replace

exit


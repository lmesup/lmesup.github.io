* PID, Balanced Panel-Design, wide

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
* (Balanced Panel-Design)

mkdat  /*
*/ pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93 pid94 pid95  /*
*/ pid96 pid97  /*
*/ using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)

* Merge weights
* -------------

sort persnr
merge persnr using weights
drop if _merge == 2
drop _merge bw

save stab2b, replace

exit

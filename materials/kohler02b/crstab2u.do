* PID, Unbalanced Panel-Design (2 Teilnahmen), Weites Format

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
* -----------
* (Unbalanced Panel-Design)

mkdat  /*
*/ pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93 pid94 pid95  /*
*/ pid96 pid97  /*
*/ using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n) /*
*/ netto(-3,-2,-1,0,1,2,3,4,5)

* Zur Arbeitserleichertung: Umbenennen von netto
* ---------------------------------------------

capture program drop umben
program define umben
	version 6.0
	local new "`1'"
	macro shift
	local i 84
	while "`1'" ~= "" {
		ren `1'  `new'`i'
		mac shift
		local i = `i' + 1
	}
end

umben netto  /*
*/ anetto bnetto cnetto dnetto enetto fnetto gnetto hnetto inetto jnetto knetto  /*
*/ lnetto mnetto nnetto


* Mindestens 2 Teilnahmen
* -----------------------

gen t = 0
for num 84/97: replace t = t + (nettoX==1)
drop if t <= 1

* Merge weights
* -------------

sort persnr
merge persnr using weights
drop if _merge == 2
drop _merge bw

save stab2u, replace




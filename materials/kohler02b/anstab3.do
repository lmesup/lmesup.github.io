* Stabilität der Parteien Within-Percent
* unbalanced Panel-Design, Teilnahme an mindestens 2 Wellen

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

* 1) Retrival
* -----------
* (unbalanced Panel-Design)

mkdat  /*
*/ pid84 pid85 pid86 pid87 pid88 pid89 pid90 pid91 pid92 pid93 pid94 pid95  /*
*/ pid96 pid97  /*
*/ using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n) /*
*/ netto(-3,-2,-1,0,1,2,3,4,5)

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

 
* 2) Wide -> Long
* ---------------

keep persnr pid* netto*
reshape long pid netto, j(welle) i(persnr)

* 3) Mindestens 2 Teilnahmen
* -------------------------
gen teiln = 1 if netto == 1 
sort persnr
qui by persnr: gen t = sum(teiln)
drop if t == 1


* 4)Stability
* -----------

iis persnr
tis welle

* Alle Parteien
xttab pid

* Nur SPD, CDU, FDP und B90/Gr.
xttab pid if pid >= 2 & pid <= 5

exit



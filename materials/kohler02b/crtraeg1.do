* Parteiidentifikation und Sozialstrukturelle Variablen  
* 14 Wellen, Unbalanced Panel-Design
* Mit Marker für das Balanced-Design
* Langes Format, xtdata, weights

clear
set memory 60m
version 6.0
set more off

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
*/ bil84 bil85 bil86 bil87 bil88 bil89 bil90 bil91 bil92 bil93 bil94 bil95  /*
*/ bil96 bil97  /*
*/ megph84 megph85 megph86 megph87 megph88 megph89 megph90 megph91 megph92 /*
*/ megph93 megph94 megph95 megph96 megph97  /*
*/ est84 est85 est86 est87 est88 est89 est90 est91 est92 /*
*/ est93 est94 est95 est96 est97  /*
*/ ein84 ein85 ein86 ein87 ein88 ein89 ein90 ein91 ein92 /*
*/ ein93 ein94 ein95 ein96 ein97  /*
*/ using $soepdir, files(peigen) waves(a b c d e f g h i j k l m n)  /*
*/ netto(-3,-2,-1,0,1,2,3,4,5) keep(gebjahr sex psample)

holrein aintnr using $soepdir, files(pbrutto) waves(a)

holrein /*
*/ bpintnr cpintnr dpintnr epintnr fpintnr gpintnr hpintnr ipintnr  /*
*/ jpintnr kpintnr lpintnr mpintnr npintnr   /*
*/ bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09 jp09 kp16 lp13  /*
*/ mp12 np08 /*
*/ using $soepdir, files(p) waves(b c d e f g h i j k l m n)


* Mark the balanced sample
* ------------------------

gen mark = anetto == 1
for any b c d e f g h i j k l m n: replace mark = 0 if Xnetto ~= 1
for any  a b c d e f g h i j k l m n: drop Xnetto 
count if mark
assert r(N) == 4777  /* Just to be sure */
sort persnr


* rename to reshape
* -----------------

ren aintnr apintnr
for any a b c d e f g h i j k l m n \ num 84/97: ren Xpintnr intnrY
for any a b c d e f g h i j k l m n \ num 84/97: ren Xhhnr hhnrY

* Programm zum Umbenennen einer Varlist
capture program drop umben
program define umben
	local newname `1'
	mac shift
	local i 84
	while "`1'" ~= "" {
		ren `1' `newname'`i'
		local i = `i' + 1
		mac shift
	}
end

gen apx = .
umben arblos apx bp09 cp05 dp05 ep05 fp06 gp09 hp07 ip09 jp09 kp16 lp13  /*
*/ mp12 np08
replace arblos84 = 1 if est84==5
replace arblos84 = 2 if est84~=5 & est84 ~= .

* Reshape
* ---------

keep persnr hhnr* pid* bil* megph* est* ein* intnr*  arblos* /*
*/ gebjahr sex mark psample 

drop hhnr
reshape long pid bil megph est arblos ein intnr hhnr, i(persnr) j(welle)

* XT-Data
* -------

iis persnr
tis welle

* Merge Weights & Rgroups
* -----------------------
sort persnr
merge persnr using weights
drop if _merge==2
drop _merge


* Save 
* ---

save traeg1, replace

exit


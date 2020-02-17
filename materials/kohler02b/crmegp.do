* Erzeugt EGP-Klassenschema, Variante Walter Mueller fuer SOEP
version 6.0
clear
set memory 60m
set more off


* 0) Cool-Ados
* -------------

* benoetigt mkdat.ado
capture which mkdat
if _rc ~= 0 {
	net from http://www.sowi.uni-mannheim.de/lehrstuehle/lesas/ado
	net install mkdat
}


* 1) Retrival
* -----------

mkdat  /*
*/  egph84 egph85 egph86 egph87 egph88 egph89 egph90 egph91 egph92 egph93  /*
*/ egph94 egph95 egph96 egph97  /*
*/ isch84 isch85 isch86 isch87 isch88 isch89 isch90 isch91 isch92 isch93  /*
*/ isch94 isch95 isch96 isch97 /*
*/ using $soepdir,  /*
*/ waves(a b c d e f g h i j k l m n) files(peigen) netto(-3,-2,-1,0,1,2,3,4,5)

* 2) Einige Umbennennungen, zum einfacheren Arbeiten
* --------------------------------------------------

for any a b c d e f g h i j k l m n \ num 84/97: ren Xnetto nettoY
for any a b c d e f g h i j k l m n \ num 84/97: ren Xhhnr hhnrY

* 3) Verwende langen Datensatz (schneller)
* ----------------------------------------

drop hhnr 										 /* Naming-Konflikt */
keep hhnr* persnr egp* isc* netto*
reshape long hhnr egph isch netto, i(persnr) j(welle)

* 4) Bildung der Variablen 
* ------------------------

* Quelle: http://www.uni-koeln.de/kzfss/ks-mueta.htm

* Administrative Dienstklasse (ISCO 1 und 2; 121-129; 201-999)
gen megph = 1 if (egph == 1 | egph == 2) &  /*
*/ ((isch==1 | isch==2) | (isch>=121 & isch<=129) | (isch>=201 & isch<=999))

* Experten (ISCO 11-54; 81-110)
replace  megph = 2 if (egph == 1 | egph == 2) &   /*
*/ ((isch>=11 & isch<=54) | (isch>=81 & isch<=110))

* Soziale Dienstleistungen  (ISCO 61-79; 131-199) 
replace  megph = 3 if (egph == 1 | egph == 2) &   /*
*/ ((isch>=61 & isch<=79) | (isch>=131 & isch<=199))

* Rest
replace megph = egph + 1 if egph > 2 & egph ~= .  
replace megph = egph if egph < 0

* 5) Beschriftung
* ----------------

lab var megph "Mueller-EGP (Hauptverdiener)"
lab val megph megp 
lab def megp 1 "Admin. D." 2 "Experten" 3 "Soz. D."  4 "Non-man"  /*
*/  5 "gr.Selb." 6 "kl.Selb."  7 "selb.Lw." 8 "Vorarb."  /*
*/  9 "Facharb." 10 "Un/Angel" 11 "Landarb"  12 "Heimber"


* 6) Zurück ins Wide-Format + Mergen der Original hhnr
* ---------------------------------------------------

keep persnr hhnr welle megph netto
reshape wide megph hhnr netto , i(persnr) j(welle)
sort persnr
tempfile temp
save `temp', replace
use persnr hhnr using $soepdir/ppfad
sort persnr
merge persnr using `temp'
 
* 7) Speichern in *peigen
* -----------------------

capture program drop svdat
program define svdat
	tempfile peigen
	save `peigen', replace
    local i 84
    while `i'<=97 {
        use hhnr hhnr`i' persnr netto`i' megph`i' if netto`i'==1  /*
		*/ using `peigen', clear
        ren hhnr`i' hhnrakt
        sort hhnr hhnrakt persnr
        merge hhnr hhnrakt persnr using $soepdir/`1'peigen
        assert _merge==3
        drop netto`i' _merge
        compress
        sort hhnr hhnrakt persnr
        order  hhnr hhnrakt persnr bul`i' hst`i' fam`i' bil`i' bbil`i'  /*
		*/ bdauer`i' est`i' nie`i' bstb`i' iscb`i' bsth`i' isch`i' bstp`i'  /*
		*/ iscp`i' bstt`i' isct`i' bstbex`i' iscbex`i' bstpar`i' iscpar`i'  /*
		*/ bstvpa`i' iscvpa`i' aus`i' hhein`i' ein`i' egpb`i' egph`i' megph  /*
		*/ egpp`i' egpt`i' rl`i' pid`i' 
        save $soepdir/`1'peigen, replace
        local i = `i'+1
        mac shift
    }
end
svdat a b c d e f g h i j k l m n


exit


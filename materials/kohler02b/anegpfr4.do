* Verteilung von EGP im Vergleich mit dem Allbus, nur Westen
* Erstellt Graphik egpfr4.gph

version 6.0
clear
set memory 60m
use persnr egpb welle phrf using egpanh

drop if persnr > 1000000   /* Trennung Ost-West nach Stichprobenart */

* Vorbereitung zum Vergleich mit ALLBUS
ren egpb egpsoep
gen nsoep=1
collapse (sum) nsoep [iweight=phrf] if egpsoep > 0, by(welle egp)
drop if egp==. /* Nonmatchs raus */
sort welle
by welle: gen sumsoep = sum(n)
by welle: gen percsoep = n/sumsoep[_N]*100
save 11, replace

* Vorbereitung ALLBUS zum Vergleich mit dem SOEP
use v2 v5 v363 v844 v845 using $allbdir/allb8098, clear
keep if v5 == 1  /* nur Westen */
ren v363 egpallb
gen welle=v2-1900
gen weight = v844*v845 if v844<99
gen nallb = 1
drop if welle < 84
collapse (sum) nallb [iweight=weight] if egpallb > 0 & egpallb <= 11, /*
*/ by(welle egpallb)
sort welle
by welle: gen sumallb = sum(nallb)
by welle: gen percallb= nallb/sumallb[_N]*100
save 12, replace

* Merge
use 11
merge welle using 12

* Graphische Darstellung
* ----------------------

* Erstellt werden 4X3 "juxtapostioned" Graphs.

* Welle 1990 wird ausgeschlossen, da viele Missings der Berufe
* (DDR-Sample)
local i 1
while `i'<=11 {
        gen p_egp`i'a = percsoep if egpsoep==`i' & welle < 90
        gen p_egp`i'b = percsoep if egpsoep==`i' & welle > 90
        gen pAegp`i' = percallb if egpallb == `i'
        label value p_egp`i'a anteil
        label value p_egp`i'b anteil
        label value pAegp`i' anteil
        local i = `i'+1
}

label define anteil 5 " "
label value welle welle
label define welle 85 " "
label variable welle " "

capture program drop egpfre
program define egpfre
    gph open, saving(anegpfr4, replace)
    local xtics "84,85,86,87,88,89,90,91,92,93,94,95,96,97"
    local ytics "0,5,10,15,20,25,30,35"
    local xlabs "84,86,88,90,92,94,96"
    local ylabs "0,10,20,30"
    local noylab "ylab(5)"
    local noxlab "xlab(85)"
    local yscale "yscale(0,36)"

    * Grapik oben links:
    graph p_egp1a p_egp1b pAegp1 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' ylab(`ylabs') /*
    */ t1title("Dienstklasse 1") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(0,0,5766,12000,400,200,0)

    * Grapik oben mitte:
    graph p_egp2* pAegp2 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' `noylab' tlab(`xlabs') /*
    */ t1title("Dienstklasse 2") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(0,10000,5766,22000,400,200,0)

    * Grapik oben rechts:
    graph p_egp3* pAegp3 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' `noylab'  /*
    */ t1title("Nicht-manuelle Routineberufe") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(0,20000,5766,32000,400,200,0)

    * Grapik 2. Reihe links:
    graph p_egp11* pAegp11 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' `noylab' /*
    */ t1title("Berufe ohne buerokr. Einbindung") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(5766,0,11532,12000,400,200,0)

    * Grapik 2. Reihe mitte:
    graph p_egp4* pAegp4 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' `noylab' /*
    */ t1title("Grosse Selbstaendige") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(5766,10000,11532,22000,400,200,0)

    * Grapik 2. Reihe rechts:
    graph p_egp5* pAegp5 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' `noylab' rlab(`ylabs') /*
    */ t1title("Kleine Selbstaendige") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(5766,20000,11532,32000,400,200,0)

    * Grapik 3. Reihe links:
    graph p_egp6* pAegp6 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' ylab(`ylabs') /*
    */ t1title("Selbstaendige Landwirte") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(11532,0,17297,12000,400,200,0)

    * Grapik 3. Reihe mitte:
    graph p_egp7* pAegp7 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ `noxlab' `noylab' /*
    */ t1title("Vorarbeiter") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(11532,10000,17297,22000,400,200,0)

    * Grapik 3. Reihe rechts:
    graph p_egp8* pAegp8 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ xlab(`xlabs') `noylab' /*
    */ t1title("Facharbeiter") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(11532,20000,17297,32000,400,200,0)

    * Grapik 4. Reihe links:
    graph p_egp9* pAegp9 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics')/*
    */ xlab(`xlabs') `noylab' /*
    */ t1title("Un- und Angelernte Arbeiter") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(17297,0,23063,12000,400,200,0)

    * Grapik 4. Reihe mitte:
    graph p_egp10* pAegp10 welle, sort border `yscale' /*
    */ xtick(`xtics') ttick(`xtics') ytick(`ytics') rtick(`ytics') /*
    */ xlab(`xlabs') `noylab' rlab(`ylabs') /*
    */ t1title("Landarbeiter") /*
    */ s(oop) c(lll) pen(223) /*
    */ bbox(17297,10000,23063,22000,400,200,0)
    gph pen 2
    gph point 18000 22000 275 4
    gph pen 3
    gph point 19000 22000 275 6
    gph pen 1
    gph text 18000 22500 0 -1 SOEP
    gph text 19000 22500 0 -1 ALLBUS
    gph close
end
egpfre

graph using anegpfr4, l1title("Anteil (gewichtet)") b2title(Erhebungsjahr) saving(egpfr4, replace)

erase 11.dta
erase 12.dta

exit
